package model

type CreateFarmRequest struct {
	FarmName string  `json:"farm_name" binding:"required"`
	FarmSize float64 `json:"farm_size" binding:"required"`
	Address  string  `json:"address" binding:"required"`
}

// UpdateFarmRequest represents the payload for updating an existing farm.
type UpdateFarmRequest struct {
	FarmName string  `json:"farm_name"`
	FarmSize float64 `json:"farm_size"`
	Address  string  `json:"address"`
}

// FarmResponse represents the farm data returned to the client.
type FarmResponse struct {
	ID       uint    `json:"id"`
	FarmerID string  `json:"farmer_id"`
	FarmName string  `json:"farm_name"`
	FarmSize float64 `json:"farm_size"`
	Address  string  `json:"address"`
}
