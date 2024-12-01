package domain

import (
	"github.com/gofrs/uuid"
)

type Farm struct {
	ID       uint
	FarmerID uuid.UUID
	FarmName string
	FarmSize float64
	Address  string
}
