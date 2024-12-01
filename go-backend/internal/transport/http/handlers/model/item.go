package model

type ItemResponse struct {
	ID          uint    `json:"id"`
	Category    string  `json:"category_id"`
	FarmID      uint    `json:"farm_id"`
	Name        string  `json:"name"`
	Image       *string `json:"image"`
	Description string  `json:"description"`
	Unit        string  `json:"unit"`
	Price       float64 `json:"price"`
	Quantity    int     `json:"quantity"`
}

type SearchItemRequest struct {
	Keyword      string   `query:"keyword"`
	MinPrice     *float64 `query:"min_price"`
	MaxPrice     *float64 `query:"max_price"`
	SortByNewest bool     `query:"sort_by_newest"`
}

type CreateItemRequest struct {
	FarmID   uint    `json:"farm_id" validate:"required"`        // Farm ID to associate the item
	Name     string  `json:"name" validate:"required"`           // Name of the item
	Category string  `json:"category" validate:"required"`       // Category of the item
	Unit     string  `json:"unit" validate:"required"`           // Unit of measurement
	Price    float64 `json:"price" validate:"required,gt=0"`     // Price per unit
	Quantity int     `json:"quantity" validate:"required,gte=0"` // Available quantity
}

type UpdateItemRequest struct {
	Name     string  `json:"name,omitempty"`     // Name of the item
	Category string  `json:"category,omitempty"` // Category of the item
	Unit     string  `json:"unit,omitempty"`     // Unit of measurement
	Price    float64 `json:"price,omitempty"`    // Price per unit
	Quantity int     `json:"quantity,omitempty"` // Available quantity
}
