package domain

import "time"

type Chat struct {
	ID              uint
	BuyerID         string
	FarmerID        string
	CreatedAt       time.Time
	LastMessage     string
	LastMessageTime time.Time
}
