package repository

import (
	"arbashop/internal/domain"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
)

var ErrChatNotFound = errors.New("chat not found")

type ChatRepository struct {
	conn *pgx.Conn
}

func NewChatRepository(conn *pgx.Conn) *ChatRepository {
	return &ChatRepository{conn: conn}
}

// CreateChat initializes a new chat between a buyer and a farmer.
func (r *ChatRepository) CreateChat(ctx context.Context, chat *domain.Chat) error {
	query := `
		INSERT INTO chats (buyer_id, farmer_id, last_message, last_message_time)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at;
	`
	err := r.conn.QueryRow(ctx, query, chat.BuyerID, chat.FarmerID, chat.LastMessage, chat.LastMessageTime).
		Scan(&chat.ID, &chat.CreatedAt)
	return err
}

// GetChatByParticipants retrieves an existing chat between a buyer and a farmer.
func (r *ChatRepository) GetChatByParticipants(ctx context.Context, buyerID, farmerID string) (*domain.Chat, error) {
	query := `
		SELECT id, buyer_id, farmer_id, created_at, last_message, last_message_time
		FROM chats
		WHERE buyer_id = $1 AND farmer_id = $2;
	`

	chat := &domain.Chat{}
	err := r.conn.QueryRow(ctx, query, buyerID, farmerID).Scan(
		&chat.ID, &chat.BuyerID, &chat.FarmerID, &chat.CreatedAt, &chat.LastMessage, &chat.LastMessageTime,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrChatNotFound
		}
		return nil, err
	}
	return chat, nil
}

// CreateMessage saves a new message in the database.
func (r *ChatRepository) CreateMessage(ctx context.Context, message *domain.Message) error {
	query := `
		INSERT INTO messages (chat_id, sender_id, receiver_id, content, created_at)
		VALUES ($1, $2, $3, $4, NOW())
		RETURNING id;
	`
	err := r.conn.QueryRow(ctx, query, message.ChatID, message.SenderID, message.ReceiverID, message.Content).
		Scan(&message.ID)
	return err
}

// GetMessagesByChatID retrieves all messages for a specific chat.
func (r *ChatRepository) GetMessagesByChatID(ctx context.Context, chatID uint) ([]domain.Message, error) {
	query := `
		SELECT id, chat_id, sender_id, receiver_id, content, created_at
		FROM messages
		WHERE chat_id = $1
		ORDER BY created_at;
	`

	rows, err := r.conn.Query(ctx, query, chatID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []domain.Message
	for rows.Next() {
		var message domain.Message
		if err := rows.Scan(
			&message.ID, &message.ChatID, &message.SenderID, &message.ReceiverID, &message.Content, &message.CreatedAt,
		); err != nil {
			return nil, err
		}
		messages = append(messages, message)
	}
	return messages, rows.Err()
}

// GetChatsForFarmer retrieves all ongoing chats for a farmer.
func (r *ChatRepository) GetChatsForFarmer(ctx context.Context, farmerID string) ([]domain.Chat, error) {
	query := `
		SELECT id, buyer_id, farmer_id, created_at, last_message, last_message_time
		FROM chats
		WHERE farmer_id = $1
		ORDER BY last_message_time DESC;
	`

	rows, err := r.conn.Query(ctx, query, farmerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var chats []domain.Chat
	for rows.Next() {
		var chat domain.Chat
		if err := rows.Scan(
			&chat.ID, &chat.BuyerID, &chat.FarmerID, &chat.CreatedAt, &chat.LastMessage, &chat.LastMessageTime,
		); err != nil {
			return nil, err
		}
		chats = append(chats, chat)
	}
	return chats, rows.Err()
}

// GetChatsForFarmer retrieves all ongoing chats for a farmer.
func (r *ChatRepository) GetChatsForBuyer(ctx context.Context, buyerID string) ([]domain.Chat, error) {
	query := `
		SELECT id, buyer_id, farmer_id, created_at, last_message, last_message_time
		FROM chats
		WHERE buyer_id = $1
		ORDER BY last_message_time DESC;
	`

	rows, err := r.conn.Query(ctx, query, buyerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var chats []domain.Chat
	for rows.Next() {
		var chat domain.Chat
		if err := rows.Scan(
			&chat.ID, &chat.BuyerID, &chat.FarmerID, &chat.CreatedAt, &chat.LastMessage, &chat.LastMessageTime,
		); err != nil {
			return nil, err
		}
		chats = append(chats, chat)
	}
	return chats, rows.Err()
}
