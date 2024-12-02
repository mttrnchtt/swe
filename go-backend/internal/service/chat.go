package service

import (
	"arbashop/internal/domain"
	"arbashop/internal/repository"
	"arbashop/internal/transport/http/handlers/model"
	"context"
	"github.com/rs/zerolog"
	"time"
)

type ChatService struct {
	repository *repository.ChatRepository
}

func NewChatService(repository *repository.ChatRepository) *ChatService {
	return &ChatService{repository: repository}
}

func (s *ChatService) CreateChat(ctx context.Context, buyerID, farmerID string) (*model.ChatResponse, error) {
	chat, err := s.repository.GetChatByParticipants(ctx, buyerID, farmerID)
	if err == nil {
		return &model.ChatResponse{
			ID:          chat.ID,
			BuyerID:     chat.BuyerID,
			FarmerID:    chat.FarmerID,
			LastMessage: "",
		}, nil
	}

	if err != repository.ErrChatNotFound {
		return nil, err
	}

	// Create a new chat
	chat = &domain.Chat{
		BuyerID:         buyerID,
		FarmerID:        farmerID,
		LastMessage:     "",
		LastMessageTime: time.Now(),
	}

	if err := s.repository.CreateChat(ctx, chat); err != nil {
		return nil, err
	}

	return &model.ChatResponse{
		ID:          chat.ID,
		BuyerID:     chat.BuyerID,
		FarmerID:    chat.FarmerID,
		LastMessage: "", // Empty chat initially
	}, nil
}

func (s *ChatService) GetMessages(ctx context.Context, chatID uint) ([]*model.MessageResponse, error) {
	logger := zerolog.Ctx(ctx)

	messages, err := s.repository.GetMessagesByChatID(ctx, chatID)
	if err != nil {
		logger.Error().Err(err).Send()
		return []*model.MessageResponse{}, err
	}

	response := make([]*model.MessageResponse, 0, len(messages))

	for _, message := range messages {
		response = append(response, &model.MessageResponse{
			ID:         message.ID,
			ChatID:     message.ChatID,
			SenderID:   message.SenderID,
			ReceiverID: message.ReceiverID,
			Content:    message.Content,
			Timestamp:  message.CreatedAt.String(),
		})
	}

	return response, nil
}

func (s *ChatService) GetChatsForFarmer(ctx context.Context, farmerID string) ([]*model.ChatResponse, error) {
	logger := zerolog.Ctx(ctx)

	chats, err := s.repository.GetChatsForFarmer(ctx, farmerID)
	if err != nil {
		logger.Error().Err(err).Send()
		return []*model.ChatResponse{}, err
	}

	response := make([]*model.ChatResponse, 0, len(chats))

	for _, chat := range chats {
		response = append(response, &model.ChatResponse{
			ID:          chat.ID,
			BuyerID:     chat.BuyerID,
			FarmerID:    chat.FarmerID,
			LastMessage: chat.LastMessage,
		})
	}

	return response, nil
}

func (s *ChatService) GetChatsForBuyer(ctx context.Context, buyerID string) ([]*model.ChatResponse, error) {
	logger := zerolog.Ctx(ctx)

	chats, err := s.repository.GetChatsForBuyer(ctx, buyerID)
	if err != nil {
		logger.Error().Err(err).Send()
		return []*model.ChatResponse{}, err
	}

	response := make([]*model.ChatResponse, 0, len(chats))

	for _, chat := range chats {
		response = append(response, &model.ChatResponse{
			ID:          chat.ID,
			BuyerID:     chat.BuyerID,
			FarmerID:    chat.FarmerID,
			LastMessage: chat.LastMessage,
		})
	}

	return response, nil
}
