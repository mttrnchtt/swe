package model

// CreateChatRequest represents the payload for initiating a new chat.
type CreateChatRequest struct {
	BuyerID  string `json:"buyer_id" binding:"required"`  // ID of the buyer initiating the chat
	FarmerID string `json:"farmer_id" binding:"required"` // ID of the farmer
}

// SendMessageRequest represents the payload for sending a new message.
type SendMessageRequest struct {
	ChatID     uint   `json:"chat_id" binding:"required"`     // Chat ID to which the message belongs
	SenderID   string `json:"sender_id" binding:"required"`   // ID of the sender (buyer or farmer)
	ReceiverID string `json:"receiver_id" binding:"required"` // ID of the receiver (buyer or farmer)
	Content    string `json:"content" binding:"required"`     // The message content
}

// ChatResponse represents the chat details returned to the client.
type ChatResponse struct {
	ID          uint   `json:"id"`
	BuyerID     string `json:"buyer_id"`
	FarmerID    string `json:"farmer_id"`
	LastMessage string `json:"last_message"`
}

// MessageResponse represents a single message in a chat.
type MessageResponse struct {
	ID         uint   `json:"id"`
	ChatID     uint   `json:"chat_id"`
	SenderID   string `json:"sender_id"`
	ReceiverID string `json:"receiver_id"`
	Content    string `json:"content"`
	Timestamp  string `json:"timestamp"` // ISO 8601 format
}
