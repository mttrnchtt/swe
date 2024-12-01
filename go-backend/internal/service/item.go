package service

import (
	"arbashop/internal/domain"
	"arbashop/internal/repository"
	servicemodel "arbashop/internal/service/model"
	"arbashop/internal/transport/http/handlers/model"
	"context"
	"errors"

	"github.com/rs/zerolog"
)

type ItemService struct {
	repository         *repository.ItemRepository
	categoryRepository *repository.CategoryRepository
}

// NewItemService creates a new instance of ItemService.
func NewItemService(repository *repository.ItemRepository, categoryRepository *repository.CategoryRepository) *ItemService {
	return &ItemService{repository: repository, categoryRepository: categoryRepository}
}

// GetByID retrieves an item by its ID.
func (s *ItemService) GetByID(ctx context.Context, id uint) (*model.ItemResponse, error) {
	logger := zerolog.Ctx(ctx)

	item, err := s.repository.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrEntityNotFound) {
			return nil, servicemodel.ErrNotFound
		}
		logger.Error().Err(err).Send()
		return nil, err
	}

	category, err := s.categoryRepository.Get(ctx, item.CategoryID)
	if err != nil {
		logger.Error().Err(err).Send()
		return nil, err
	}

	return &model.ItemResponse{
		ID:       item.ID,
		FarmID:   item.FarmID,
		Name:     item.Name,
		Category: category.Name,
		Unit:     item.Unit,
		Price:    item.Price,
		Quantity: item.Quantity,
	}, nil
}

// Create inserts a new item into the database.
func (s *ItemService) Create(ctx context.Context, request model.CreateItemRequest) error {
	logger := zerolog.Ctx(ctx)

	// Validate input
	if request.Name == "" || request.FarmID == 0 || request.Category == "" {
		logger.Error().Msg("Item name, farm ID, and category are required")
		return servicemodel.ErrInvalidInput
	}

	// Check if the category exists
	category, err := s.categoryRepository.GetByName(ctx, request.Category)
	if err != nil {
		if errors.Is(err, repository.ErrCategoryNotFound) {
			// Create the category if it doesn't exist
			category = &domain.Category{Name: request.Category}
			if err := s.categoryRepository.Create(ctx, category); err != nil {
				logger.Error().Err(err).Msg("Failed to create category")
				return servicemodel.ErrCannotCreateEntity
			}
		} else {
			logger.Error().Err(err).Msg("Failed to fetch category")
			return err
		}
	}

	// Map the request to the domain model
	item := &domain.Item{
		FarmID:     request.FarmID,
		Name:       request.Name,
		CategoryID: category.ID,
		Unit:       request.Unit,
		Price:      request.Price,
		Quantity:   request.Quantity,
	}

	// Insert into the repository
	if err := s.repository.Create(ctx, item); err != nil {
		logger.Error().Err(err).Send()
		return servicemodel.ErrCannotCreateEntity
	}

	return nil
}

// Update modifies an existing item.
func (s *ItemService) Update(ctx context.Context, id uint, request model.UpdateItemRequest) error {
	logger := zerolog.Ctx(ctx)

	// Fetch the existing item
	item, err := s.repository.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrEntityNotFound) {
			return servicemodel.ErrNotFound
		}
		logger.Error().Err(err).Send()
		return err
	}

	// Update fields
	if request.Name != "" {
		item.Name = request.Name
	}
	if request.Unit != "" {
		item.Unit = request.Unit
	}
	if request.Price > 0 {
		item.Price = request.Price
	}
	if request.Quantity >= 0 {
		item.Quantity = request.Quantity
	}

	// Persist the changes
	if err := s.repository.Update(ctx, item); err != nil {
		logger.Error().Err(err).Send()
		return servicemodel.ErrCannotUpdateEntity
	}

	return nil
}

// Delete removes an item by its ID.
func (s *ItemService) Delete(ctx context.Context, id uint) error {
	logger := zerolog.Ctx(ctx)

	if err := s.repository.Delete(ctx, id); err != nil {
		if errors.Is(err, repository.ErrEntityNotFound) {
			return servicemodel.ErrNotFound
		}
		logger.Error().Err(err).Send()
		return servicemodel.ErrCannotDeleteEntity
	}

	return nil
}

// GetAll retrieves all items from the repository and maps them to the HTTP response model.
func (s *ItemService) GetAll(ctx context.Context) ([]*model.ItemResponse, error) {
	logger := zerolog.Ctx(ctx)

	// Fetch all items from the repository
	items, err := s.repository.GetAll(ctx)
	if err != nil {
		logger.Error().Err(err).Msg("Failed to fetch items from repository")
		return nil, err
	}

	// Map domain items to HTTP response models
	response := make([]*model.ItemResponse, len(items))
	for i, item := range items {
		category, err := s.categoryRepository.Get(ctx, item.CategoryID)
		if err != nil {
			continue
		}

		response[i] = &model.ItemResponse{
			ID:       item.ID,
			FarmID:   item.FarmID,
			Name:     item.Name,
			Category: category.Name,
			Unit:     item.Unit,
			Price:    item.Price,
			Quantity: item.Quantity,
		}
	}

	return response, nil
}

// GetAllByFarmID retrieves all items for a specific farm by its farm ID.
func (s *ItemService) GetAllByFarmID(ctx context.Context, farmID uint) ([]*model.ItemResponse, error) {
	logger := zerolog.Ctx(ctx)

	items, err := s.repository.GetAllByFarmID(ctx, farmID)
	if err != nil {
		logger.Error().Err(err).Msg("Failed to fetch items by farm ID")
		return nil, servicemodel.ErrNotFound
	}

	// Map domain items to HTTP response models
	response := make([]*model.ItemResponse, len(items))
	for i, item := range items {
		category, err := s.categoryRepository.Get(ctx, item.CategoryID)
		if err != nil {
			continue
		}

		response[i] = &model.ItemResponse{
			ID:       item.ID,
			FarmID:   item.FarmID,
			Name:     item.Name,
			Category: category.Name,
			Unit:     item.Unit,
			Price:    item.Price,
			Quantity: item.Quantity,
		}
	}

	return response, nil
}

// SearchItems retrieves items based on search keywords and filters.
func (s *ItemService) SearchItems(ctx context.Context, request model.SearchItemRequest) ([]*model.ItemResponse, error) {
	logger := zerolog.Ctx(ctx)

	// Map HTTP request to domain filters
	filters := domain.ItemFilters{
		MinPrice:     request.MinPrice,
		MaxPrice:     request.MaxPrice,
		SortByNewest: request.SortByNewest,
	}

	items, err := s.repository.SearchItems(ctx, request.Keyword, filters)
	if err != nil {
		logger.Error().Err(err).Msg("Failed to search items")
		return nil, err
	}

	// Map domain items to HTTP response models
	response := make([]*model.ItemResponse, len(items))
	for i, item := range items {
		caregory, err := s.categoryRepository.Get(ctx, item.CategoryID)
		if err != nil {
			continue
		}
		response[i] = &model.ItemResponse{
			ID:          item.ID,
			Category:    caregory.Name,
			FarmID:      item.FarmID,
			Name:        item.Name,
			Image:       item.Image,
			Description: item.Description,
			Unit:        item.Unit,
			Price:       item.Price,
			Quantity:    item.Quantity,
		}
	}

	return response, nil
}
