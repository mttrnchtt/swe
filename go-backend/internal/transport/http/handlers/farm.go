package handlers

import (
	serviceModel "arbashop/internal/service/model"
	"arbashop/internal/transport/http/handlers/model"
	"arbashop/internal/transport/http/middleware"
	"arbashop/internal/transport/http/router"
	"arbashop/pkg/jwt"
	"context"
	"errors"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/gofrs/uuid"
	"github.com/rs/zerolog"
	"net/http"
)

type (
	FarmService interface {
		GetByID(ctx context.Context, id uint) (*model.FarmResponse, error)
		Create(ctx context.Context, request model.CreateFarmRequest, userID uuid.UUID) error
		Update(ctx context.Context, id uint, request model.UpdateFarmRequest) error
		GetAll(ctx context.Context) ([]*model.FarmResponse, error)
	}

	farmHandler struct {
		validator  *validator.Validate
		makeRouter router.MakeRouter
		service    FarmService
	}
)

// NewFarmHandler initializes a new farmHandler with the required service and middleware.
func NewFarmHandler(auth *middleware.Auth, service FarmService) *farmHandler {
	h := &farmHandler{validator: validator.New(), service: service}

	h.makeRouter = func(router fiber.Router) {
		g := router.Group("/farms", auth.Handle)
		g.Get("", h.GetAll)
		g.Get("/:id", h.GetByID)
		g.Post("", h.Create)
	}

	return h
}

// Router exposes the routes for this handler.
func (h *farmHandler) Router() router.MakeRouter {
	return h.makeRouter
}

// GetAll godoc
//
//	@Summary	Get all farms
//	@Tags		Farm
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Success	200		{object}	[]model.FarmResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/farms [get]
func (h *farmHandler) GetAll(c *fiber.Ctx) error {
	response, err := h.service.GetAll(c.Context())
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(response)
}

// GetByID godoc
//
//	@Summary	Get farm by ID
//	@Tags		Farm
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		id		path		uint	true	"Farm ID"
//	@Success	200		{object}	model.FarmResponse
//	@Failure	404		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/farms/{id} [get]
func (h *farmHandler) GetByID(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Invalid farm ID"))
	}

	response, err := h.service.GetByID(c.Context(), uint(id))
	switch {
	case errors.Is(err, serviceModel.ErrNotFound):
		return c.Status(http.StatusNotFound).JSON(model.NewErrorResponse("Farm not found", err.Error()))
	case err != nil:
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(response)
}

// Create godoc
//
//	@Summary	Create a new farm
//	@Tags		Farm
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		request	body		model.CreateFarmRequest	true	"Create farm request"
//	@Success	201		"Farm created successfully"
//	@Failure	400		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/farms [post]
func (h *farmHandler) Create(c *fiber.Ctx) error {
	ctx := c.Context()
	userID, err := jwt.GetUserIdFromCtx(c)
	if err != nil {
		return c.SendStatus(fiber.StatusUnauthorized)
	}
	logger := zerolog.Ctx(ctx)

	var request model.CreateFarmRequest
	if err := c.BodyParser(&request); err != nil {
		logger.Error().Err(err).Send()
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Cannot parse body"))
	}

	err = h.service.Create(ctx, request, userID)
	switch {
	case errors.Is(err, serviceModel.ErrCannotCreateEntity):
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Unable to create farm", err.Error()))
	case err != nil:
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.SendStatus(fiber.StatusCreated)
}

// Update godoc
//
//	@Summary	Update an existing farm
//	@Tags		Farm
//	@Security	Bearer
//	@Accept		json
//	@Produce	json
//
//	@Param		id		path		uint					true	"Farm ID"
//	@Param		request	body		model.UpdateFarmRequest	true	"Update farm request"
//	@Success	200		"Farm updated successfully"
//	@Failure	400		{object}	model.ErrorResponse
//	@Failure	404		{object}	model.ErrorResponse
//	@Failure	500		{object}	model.ErrorResponse
//	@Router		/api/v1/farms/{id} [put]
func (h *farmHandler) Update(c *fiber.Ctx) error {
	ctx := c.Context()
	logger := zerolog.Ctx(ctx)

	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Invalid farm ID"))
	}

	var request model.UpdateFarmRequest
	if err := c.BodyParser(&request); err != nil {
		logger.Error().Err(err).Send()
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Cannot parse body"))
	}

	err = h.service.Update(ctx, uint(id), request)
	switch {
	case errors.Is(err, serviceModel.ErrNotFound):
		return c.Status(http.StatusNotFound).JSON(model.NewErrorResponse("Farm not found", err.Error()))
	case errors.Is(err, serviceModel.ErrCannotUpdateEntity):
		return c.Status(http.StatusBadRequest).JSON(model.NewErrorResponse("Unable to update farm", err.Error()))
	case err != nil:
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.SendStatus(fiber.StatusOK)
}
