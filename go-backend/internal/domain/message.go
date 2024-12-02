package domain

import "time"

type Message struct {
	ID         uint
	ChatID     uint
	SenderID   string
	ReceiverID string
	Content    string
	CreatedAt  time.Time
}
