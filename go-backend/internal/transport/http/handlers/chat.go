package handlers

import (
	"arbashop/internal/service"
	model "arbashop/internal/transport/http/handlers/model"
	"arbashop/internal/transport/http/middleware"
	"arbashop/internal/transport/http/router"
	"context"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
	"github.com/rs/zerolog"
	"net/http"
)

type chatHandler struct {
	validator        *validator.Validate
	makeRouter       router.MakeRouter
	service          *service.ChatService
	websocketManager *service.WebSocketManager
}

// NewChatHandler initializes a new ChatHandler.
func NewChatHandler(auth *middleware.Auth, service *service.ChatService, websocketManager *service.WebSocketManager) *chatHandler {
	h := &chatHandler{
		validator:        validator.New(),
		service:          service,
		websocketManager: websocketManager,
	}

	h.makeRouter = func(router fiber.Router) {
		g := router.Group("/chats", auth.Handle)
		g.Get("/:farmer_id", h.GetChatsForFarmer)
		g.Get("/:buyer_id", h.GetChatsForBuyer)
		g.Get("/:chat_id/messages", h.GetMessages)
		g.Post("", h.CreateChat)
		g.Get("/ws/:user_id", websocket.New(h.WebSocketConnection)) // WebSocket route

	}

	return h
}

// Router exposes the routes for this handler.
func (h *chatHandler) Router() router.MakeRouter {
	return h.makeRouter
}

// CreateChat godoc
//
// @Summary Create a new chat
// @Tags Chat
// @Security Bearer
// @Accept json
// @Produce json
//
// @Param request body model.CreateChatRequest true "Create chat request"
// @Success 200 {object} model.ChatResponse
// @Failure 400 {object} model.ErrorResponse
// @Failure 500 {object} model.ErrorResponse
// @Router /api/v1/chats [post]
func (h *chatHandler) CreateChat(c *fiber.Ctx) error {
	ctx := c.Context()
	logger := zerolog.Ctx(ctx)

	var request model.CreateChatRequest
	if err := c.BodyParser(&request); err != nil {
		logger.Error().Err(err).Send()
		return c.Status(http.StatusBadRequest).JSON(model.ErrorResponse{Error: "Invalid request body"})
	}

	chat, err := h.service.CreateChat(ctx, request.BuyerID, request.FarmerID)
	if err != nil {
		logger.Error().Err(err).Send()
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.Status(http.StatusOK).JSON(chat)
}

// GetMessages godoc
//
// @Summary Get all messages for a chat
// @Tags Chat
// @Security Bearer
// @Accept json
// @Produce json
//
// @Param chat_id path int true "Chat ID"
// @Success 200 {array} []model.MessageResponse
// @Failure 400 {object} model.ErrorResponse
// @Failure 500 {object} model.ErrorResponse
// @Router /api/v1/chats/{chat_id}/messages [get]
func (h *chatHandler) GetMessages(c *fiber.Ctx) error {
	chatID, err := c.ParamsInt("chat_id")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(model.ErrorResponse{Error: "Invalid chat ID"})
	}

	messages, err := h.service.GetMessages(c.Context(), uint(chatID))
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(messages)
}

// GetChatsForFarmer godoc
//
// @Summary Get all chats for a farmer
// @Tags Chat
// @Security Bearer
// @Accept json
// @Produce json
//
// @Param farmer_id query string true "Farmer ID"
// @Success 200 {array} []model.ChatResponse
// @Failure 400 {object} model.ErrorResponse
// @Failure 500 {object} model.ErrorResponse
// @Router /api/v1/chats/{farmer_id} [get]
func (h *chatHandler) GetChatsForFarmer(c *fiber.Ctx) error {
	farmerID := c.Query("farmer_id")
	if farmerID == "" {
		return c.Status(http.StatusBadRequest).JSON(model.ErrorResponse{Error: "Farmer ID is required"})
	}

	chats, err := h.service.GetChatsForFarmer(c.Context(), farmerID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(chats)
}

// GetChatsForBuyer godoc
//
// @Summary Get all chats for a farmer
// @Tags Chat
// @Security Bearer
// @Accept json
// @Produce json
//
// @Param farmer_id query string true "Farmer ID"
// @Success 200 {array} []model.ChatResponse
// @Failure 400 {object} model.ErrorResponse
// @Failure 500 {object} model.ErrorResponse
// @Router /api/v1/chats/{buyer_id} [get]
func (h *chatHandler) GetChatsForBuyer(c *fiber.Ctx) error {
	farmerID := c.Query("buyer_id")
	if farmerID == "" {
		return c.Status(http.StatusBadRequest).JSON(model.ErrorResponse{Error: "Farmer ID is required"})
	}

	chats, err := h.service.GetChatsForBuyer(c.Context(), farmerID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(model.ErrorResponse{Error: err.Error()})
	}

	return c.JSON(chats)
}

// WebSocketConnection godoc
//
// @Summary WebSocket connection for real-time chat
// @Description Establish a WebSocket connection for real-time chat messages between users.
// @Tags Chat
// @Security Bearer
// @Param user_id path string true "User ID"
// @Success 101 "Switching Protocols to WebSocket"
// @Failure 400 {object} model.ErrorResponse "Invalid user ID"
// @Failure 500 {object} model.ErrorResponse "Internal server error"
// @Router /api/v1/chats/ws/{user_id} [get]
func (h *chatHandler) WebSocketConnection(c *websocket.Conn) {
	userID := c.Params("user_id")
	h.websocketManager.AddConnection(userID, c)

	defer func() {
		h.websocketManager.RemoveConnection(userID)
		c.Close()
	}()

	for {
		messageType, msg, err := c.ReadMessage()
		if err != nil {
			return // Exit on connection error
		}

		// Process the incoming message
		if err := h.websocketManager.HandleIncomingMessage(context.TODO(), userID, messageType, msg); err != nil {
			zerolog.Ctx(context.TODO()).Error().Err(err).Msg("Error handling WebSocket message")
		}
	}
}
