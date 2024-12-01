package handlers

import (
	servicemodel "arbashop/internal/service/model"
	"arbashop/internal/transport/http/handlers/model"
	"arbashop/internal/transport/http/middleware"
	"arbashop/internal/transport/http/router"
	"context"
	"errors"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/rs/zerolog"
	"net/http"
)

type (
	ItemService interface {
		GetByID(ctx context.Context, id uint) (*model.ItemResponse, error)
		Create(ctx context.Context, request model.CreateItemRequest) error
		Update(ctx context.Context, id uint, request model.UpdateItemRequest) error
		GetAll(ctx context.Context) ([]*model.ItemResponse, error)
		Delete(ctx context.Context, id uint) error
		GetAllByFarmID(ctx context.Context, farmID uint) ([]*model.ItemResponse, error)
		SearchItems(ctx context.Context, request model.SearchItemRequest) ([]*model.ItemResponse, error)
	}

	itemHandler struct {
		validator  *validator.Validate
		makeRouter router.MakeRouter
		service    ItemService
	}
)

// NewItemHandler initializes a new itemHandler with the required service and middleware.
func NewItemHandler(auth *middleware.Auth, service ItemService) *itemHandler {
	h := &itemHandler{validator: validator.New(), service: service}

	h.makeRouter = func(router fiber.Router) {
		g := router.Group("/items", auth.Handle)
		g.Get("", h.GetAll)
		g.Get("/:id", h.GetByID)
		g.Post("", h.Create)
		g.Put("/:id", h.Update)
		g.Delete("/:id", h.Delete)
		g.Get("/farm/:farmId", h.GetAllByFarmID) // Route to get all items of a farm
		g.Get("/search", h.Search)
	}

	return h
}

// Router exposes the routes for this handler.
func (h *itemHandler) Router() router.MakeRouter {
	return h.makeRouter
}

// GetAll godoc
//
//	@Summary	Get all items
//	@Tags		Item
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Success	200		{object}	[]model.ItemResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/items [get]
func (h *itemHandler) GetAll(c *fiber.Ctx) error {
	response, err := h.service.GetAll(c.Context())
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(response)
}

// GetByID godoc
//
//	@Summary	Get item by ID
//	@Tags		Item
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		id		path		uint	true	"Item ID"
//	@Success	200		{object}	model.ItemResponse
//	@Failure	404		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/items/{id} [get]
func (h *itemHandler) GetByID(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Invalid item ID"))
	}

	response, err := h.service.GetByID(c.Context(), uint(id))
	switch {
	case errors.Is(err, servicemodel.ErrNotFound):
		return c.Status(http.StatusNotFound).JSON(model.NewErrorResponse("Item not found", err.Error()))
	case err != nil:
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(response)
}

// Create godoc
//
//	@Summary	Create a new item
//	@Tags		Item
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		request	body		model.CreateItemRequest	true	"Create item request"
//	@Success	201		"Item created successfully"
//	@Failure	400		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/items [post]
func (h *itemHandler) Create(c *fiber.Ctx) error {
	ctx := c.Context()
	logger := zerolog.Ctx(ctx)

	var request model.CreateItemRequest
	if err := c.BodyParser(&request); err != nil {
		logger.Error().Err(err).Send()
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Cannot parse body"))
	}

	err := h.service.Create(ctx, request)
	switch {
	case errors.Is(err, servicemodel.ErrCannotCreateEntity):
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Unable to create item", err.Error()))
	case err != nil:
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.SendStatus(fiber.StatusCreated)
}

// Update godoc
//
//	@Summary	Update an existing item
//	@Tags		Item
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		id		path		uint					true	"Item ID"
//	@Param		request	body		model.UpdateItemRequest	true	"Update item request"
//	@Success	200		"Item updated successfully"
//	@Failure	400		{object}	model.ErrorResponse
//	@Failure	404		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/items/{id} [put]
func (h *itemHandler) Update(c *fiber.Ctx) error {
	ctx := c.Context()
	logger := zerolog.Ctx(ctx)

	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Invalid item ID"))
	}

	var request model.UpdateItemRequest
	if err := c.BodyParser(&request); err != nil {
		logger.Error().Err(err).Send()
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Cannot parse body"))
	}

	err = h.service.Update(ctx, uint(id), request)
	switch {
	case errors.Is(err, servicemodel.ErrNotFound):
		return c.Status(http.StatusNotFound).JSON(model.NewErrorResponse("Item not found", err.Error()))
	case errors.Is(err, servicemodel.ErrCannotUpdateEntity):
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Unable to update item", err.Error()))
	case err != nil:
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.SendStatus(fiber.StatusOK)
}

// Delete godoc
//
//	@Summary	Delete an item
//	@Tags		Item
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		id		path		uint	true	"Item ID"
//	@Success	204		"Item deleted successfully"
//	@Failure	404		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/items/{id} [delete]
func (h *itemHandler) Delete(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Invalid item ID"))
	}

	if err := h.service.Delete(c.Context(), uint(id)); err != nil {
		if errors.Is(err, servicemodel.ErrNotFound) {
			return c.Status(http.StatusNotFound).JSON(model.NewErrorResponse("Item not found", err.Error()))
		}
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.SendStatus(http.StatusNoContent)
}

// GetAllByFarmID godoc
//
//	@Summary	Get all items of a farm
//	@Tags		Item
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		farmId	path		uint	true	"Farm ID"
//	@Success	200		{object}	[]model.ItemResponse
//	@Failure	404		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/items/farm/{farmId} [get]
func (h *itemHandler) GetAllByFarmID(c *fiber.Ctx) error {
	farmID, err := c.ParamsInt("farmId")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Invalid farm ID"))
	}

	response, err := h.service.GetAllByFarmID(c.Context(), uint(farmID))
	switch {
	case errors.Is(err, servicemodel.ErrNotFound):
		return c.Status(http.StatusNotFound).JSON(model.NewErrorResponse("No items found for this farm", err.Error()))
	case err != nil:
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(response)
}

// Search godoc
//
//	@Summary	Search items
//	@Tags		Item
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		request	query		model.SearchItemRequest	false	"Search items request"
//	@Success	200		{object}	[]model.ItemResponse
//	@Failure	404		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/items [get]
func (h *itemHandler) Search(c *fiber.Ctx) error {
	var request model.SearchItemRequest
	if err := c.QueryParser(&request); err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Invalid query parameters"))
	}

	response, err := h.service.SearchItems(c.Context(), request)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}
	if len(response) == 0 {
		return c.Status(http.StatusNotFound).JSON(model.NewErrorResponse("No items found matching your criteria"))
	}

	return c.JSON(response)
}
