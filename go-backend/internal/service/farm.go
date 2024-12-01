package service

import (
	"arbashop/internal/domain"
	"arbashop/internal/repository"
	servicemodel "arbashop/internal/service/model"
	"arbashop/internal/transport/http/handlers/model"
	"context"
	"errors"
	"github.com/gofrs/uuid"

	"github.com/rs/zerolog"
)

type FarmService struct {
	repository *repository.FarmRepository
}

// NewFarmService creates a new instance of FarmService.
func NewFarmService(repository *repository.FarmRepository) *FarmService {
	return &FarmService{repository: repository}
}

// GetByID retrieves a farm by its ID.
func (s *FarmService) GetByID(ctx context.Context, id uint) (*model.FarmResponse, error) {
	logger := zerolog.Ctx(ctx)

	farm, err := s.repository.Get(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrEntityNotFound) {
			return nil, servicemodel.ErrNotFound
		}
		logger.Error().Err(err).Send()
		return nil, err
	}

	return &model.FarmResponse{
		ID:       farm.ID,
		FarmerID: farm.FarmerID.String(),
		FarmName: farm.FarmName,
		FarmSize: farm.FarmSize,
		Address:  farm.Address,
	}, nil
}

// Create inserts a new farm into the database.
func (s *FarmService) Create(ctx context.Context, request model.CreateFarmRequest, userID uuid.UUID) error {
	logger := zerolog.Ctx(ctx)

	// Validate input
	if request.FarmName == "" {
		logger.Error().Msg("Farm name is required")
		return servicemodel.ErrInvalidInput
	}

	// Map the request to the domain model
	farm := &domain.Farm{
		FarmerID: userID,
		FarmName: request.FarmName,
		FarmSize: request.FarmSize,
		Address:  request.Address,
	}

	// Insert into the repository
	if err := s.repository.Create(ctx, farm); err != nil {
		logger.Error().Err(err).Send()
		return servicemodel.ErrCannotCreateEntity
	}

	return nil
}

// Update modifies an existing farm.
func (s *FarmService) Update(ctx context.Context, id uint, request model.UpdateFarmRequest) error {
	logger := zerolog.Ctx(ctx)

	// Fetch the existing farm
	farm, err := s.repository.Get(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrEntityNotFound) {
			return servicemodel.ErrNotFound
		}
		logger.Error().Err(err).Send()
		return err
	}

	// Update fields
	if request.FarmName != "" {
		farm.FarmName = request.FarmName
	}
	if request.FarmSize > 0 {
		farm.FarmSize = request.FarmSize
	}
	if request.Address != "" {
		farm.Address = request.Address
	}

	// Persist the changes
	if err := s.repository.Update(ctx, farm); err != nil {
		logger.Error().Err(err).Send()
		return servicemodel.ErrCannotUpdateEntity
	}

	return nil
}

// GetAll retrieves all farms from the repository and maps them to the HTTP response model.
func (s *FarmService) GetAll(ctx context.Context) ([]*model.FarmResponse, error) {
	logger := zerolog.Ctx(ctx)

	// Fetch all farms from the repository.
	farms, err := s.repository.GetAll(ctx)
	if err != nil {
		logger.Error().Err(err).Msg("Failed to fetch farms from repository")
		return nil, err
	}

	// Map domain farms to HTTP response models.
	response := make([]*model.FarmResponse, len(farms))
	for i, farm := range farms {
		response[i] = &model.FarmResponse{
			ID:       farm.ID,
			FarmerID: farm.FarmerID.String(),
			FarmName: farm.FarmName,
			FarmSize: farm.FarmSize,
			Address:  farm.Address,
		}
	}

	return response, nil
}
