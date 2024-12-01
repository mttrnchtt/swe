package domain

type Item struct {
	ID          uint
	CategoryID  uint
	FarmID      uint
	Name        string
	Image       *string
	Description string
	Unit        string
	Price       float64
	Quantity    int
}
type ItemFilters struct {
	MinPrice     *float64
	MaxPrice     *float64
	SortByNewest bool
}
