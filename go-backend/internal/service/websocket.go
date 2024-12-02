package service

import (
	"arbashop/internal/domain"
	"arbashop/internal/repository"
	"arbashop/internal/transport/http/handlers/model"
	"context"
	"encoding/json"
	"github.com/gofiber/websocket/v2"
	"github.com/rs/zerolog"
	"sync"
	"time"
)

// WebSocketManager handles WebSocket connections and broadcasting messages.
type WebSocketManager struct {
	mu          sync.Mutex
	connections map[string]*websocket.Conn // Maps user IDs to WebSocket connections
	repository  *repository.ChatRepository // For saving messages
}

// NewWebSocketManager creates a new instance of WebSocketManager.
func NewWebSocketManager(repo *repository.ChatRepository) *WebSocketManager {
	return &WebSocketManager{
		connections: make(map[string]*websocket.Conn),
		repository:  repo,
	}
}

// AddConnection registers a new WebSocket connection for a user.
func (w *WebSocketManager) AddConnection(userID string, conn *websocket.Conn) {
	w.mu.Lock()
	defer w.mu.Unlock()

	// Close any existing connection for the user to avoid duplicates
	if existingConn, exists := w.connections[userID]; exists {
		_ = existingConn.Close()
	}

	w.connections[userID] = conn
}

// RemoveConnection removes a WebSocket connection for a user.
func (w *WebSocketManager) RemoveConnection(userID string) {
	w.mu.Lock()
	defer w.mu.Unlock()

	if conn, exists := w.connections[userID]; exists {
		_ = conn.Close()
		delete(w.connections, userID)
	}
}

// SaveAndBroadcastMessage saves the message to the database and broadcasts it to the receiver.
func (w *WebSocketManager) SaveAndBroadcastMessage(ctx context.Context, message domain.Message) (*domain.Message, error) {
	// Save the message to the repository
	if err := w.repository.CreateMessage(ctx, &message); err != nil {
		return nil, err
	}

	// Convert to MessageResponse for broadcasting
	response := &model.MessageResponse{
		ID:         message.ID,
		ChatID:     message.ChatID,
		SenderID:   message.SenderID,
		ReceiverID: message.ReceiverID,
		Content:    message.Content,
		Timestamp:  message.CreatedAt.Format(time.RFC3339),
	}

	// Serialize the response
	messageBytes, err := json.Marshal(response)
	if err != nil {
		return nil, err
	}

	// Broadcast the message
	w.BroadcastMessage(message.ReceiverID, messageBytes)

	return &message, nil
}

// BroadcastMessage sends a message to a specific user.
func (w *WebSocketManager) BroadcastMessage(userID string, message []byte) {
	w.mu.Lock()
	defer w.mu.Unlock()

	if conn, exists := w.connections[userID]; exists {
		_ = conn.WriteMessage(websocket.TextMessage, message)
	}
}

// BroadcastToAll sends a message to all connected users.
func (w *WebSocketManager) BroadcastToAll(message []byte) {
	w.mu.Lock()
	defer w.mu.Unlock()

	for userID, conn := range w.connections {
		if err := conn.WriteMessage(websocket.TextMessage, message); err != nil {
			// Handle error: remove connection if it's broken
			_ = conn.Close()
			delete(w.connections, userID)
		}
	}
}

// GetActiveConnections retrieves all active user IDs with connections.
func (w *WebSocketManager) GetActiveConnections() []string {
	w.mu.Lock()
	defer w.mu.Unlock()

	users := make([]string, 0, len(w.connections))
	for userID := range w.connections {
		users = append(users, userID)
	}
	return users
}

// HandleIncomingMessage processes an incoming WebSocket message.
func (w *WebSocketManager) HandleIncomingMessage(ctx context.Context, userID string, messageType int, msg []byte) error {
	// Log the incoming message
	zerolog.Ctx(ctx).Info().
		Str("userID", userID).
		Str("message", string(msg)).
		Msg("Received WebSocket message")

	// Deserialize the message
	var incomingMessage domain.Message
	if err := json.Unmarshal(msg, &incomingMessage); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("Failed to unmarshal WebSocket message")
		return err
	}

	// Ensure the sender ID matches the user ID from the WebSocket
	incomingMessage.SenderID = userID

	// Save the message and broadcast it
	if _, err := w.SaveAndBroadcastMessage(ctx, incomingMessage); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("Failed to save and broadcast WebSocket message")
		return err
	}

	return nil
}
