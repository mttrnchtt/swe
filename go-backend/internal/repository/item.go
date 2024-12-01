package repository

import (
	"arbashop/internal/domain"
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
	"strings"
)

type ItemRepository struct {
	conn *pgx.Conn
}

// NewItemRepository initializes a new ItemRepository instance.
func NewItemRepository(conn *pgx.Conn) *ItemRepository {
	return &ItemRepository{conn: conn}
}

// GetAll retrieves all items from the database.
func (r *ItemRepository) GetAll(ctx context.Context) ([]domain.Item, error) {
	query := `SELECT id, category_id, farm_id, name, image, description, unit, price, quantity FROM items`
	rows, err := r.conn.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []domain.Item
	for rows.Next() {
		var item domain.Item
		if err := rows.Scan(&item.ID, &item.CategoryID, &item.FarmID, &item.Name, &item.Image, &item.Description, &item.Unit, &item.Price, &item.Quantity); err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	return items, rows.Err()
}

// GetByID retrieves a single item by its ID.
func (r *ItemRepository) GetByID(ctx context.Context, id uint) (*domain.Item, error) {
	query := `SELECT id, category_id, farm_id, name, image, description, unit, price, quantity FROM items WHERE id = $1`
	var item domain.Item
	err := r.conn.QueryRow(ctx, query, id).Scan(&item.ID, &item.CategoryID, &item.FarmID, &item.Name, &item.Image, &item.Description, &item.Unit, &item.Price, &item.Quantity)
	if err != nil {
		return nil, err
	}
	return &item, nil
}

// Create inserts a new item into the database.
func (r *ItemRepository) Create(ctx context.Context, item *domain.Item) error {
	query := `INSERT INTO items (category_id, farm_id, name, image, description, unit, price, quantity) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`
	err := r.conn.QueryRow(ctx, query, item.CategoryID, item.FarmID, item.Name, item.Image, item.Description, item.Unit, item.Price, item.Quantity).Scan(&item.ID)
	return err
}

// Update modifies an existing item in the database.
func (r *ItemRepository) Update(ctx context.Context, item *domain.Item) error {
	query := `UPDATE items SET category_id = $1, farm_id = $2, name = $3, image = $4, description = $5, unit = $6, price = $7, quantity = $8 WHERE id = $9`
	_, err := r.conn.Exec(ctx, query, item.CategoryID, item.FarmID, item.Name, item.Image, item.Description, item.Unit, item.Price, item.Quantity, item.ID)
	return err
}

// Delete removes an item from the database by its ID.
func (r *ItemRepository) Delete(ctx context.Context, id uint) error {
	query := `DELETE FROM items WHERE id = $1`
	_, err := r.conn.Exec(ctx, query, id)
	return err
}

// GetAllByFarmID retrieves all items associated with a specific farm by its farm ID.
func (r *ItemRepository) GetAllByFarmID(ctx context.Context, farmID uint) ([]domain.Item, error) {
	query := `SELECT id, farm_id, name, category_id, unit, price, quantity FROM items WHERE farm_id = $1`
	rows, err := r.conn.Query(ctx, query, farmID)
	if err != nil {
		return nil, fmt.Errorf("failed to query items by farm ID: %w", err)
	}
	defer rows.Close()

	var items []domain.Item
	for rows.Next() {
		var item domain.Item
		if err := rows.Scan(
			&item.ID,
			&item.FarmID,
			&item.Name,
			&item.CategoryID,
			&item.Unit,
			&item.Price,
			&item.Quantity,
		); err != nil {
			return nil, fmt.Errorf("failed to scan item: %w", err)
		}
		items = append(items, item)
	}

	if rows.Err() != nil {
		return nil, fmt.Errorf("error iterating over rows: %w", rows.Err())
	}

	return items, nil
}

func (r *ItemRepository) SearchItems(ctx context.Context, searchTerm string, filters domain.ItemFilters) ([]domain.Item, error) {
	var queryBuilder strings.Builder
	queryBuilder.WriteString("SELECT id, category_id, farm_id, name, image, description, unit, price, quantity FROM items WHERE 1=1 ")

	args := []interface{}{}
	argIndex := 1

	// Add search term to query
	if searchTerm != "" {
		queryBuilder.WriteString(fmt.Sprintf("AND (name ILIKE $%d OR description ILIKE $%d) ", argIndex, argIndex))
		args = append(args, "%"+searchTerm+"%")
		argIndex++
	}

	// Add filters to query
	if filters.MinPrice != nil {
		queryBuilder.WriteString(fmt.Sprintf("AND price >= $%d ", argIndex))
		args = append(args, *filters.MinPrice)
		argIndex++
	}
	if filters.MaxPrice != nil {
		queryBuilder.WriteString(fmt.Sprintf("AND price <= $%d ", argIndex))
		args = append(args, *filters.MaxPrice)
		argIndex++
	}

	// Sorting
	if filters.SortByNewest {
		queryBuilder.WriteString("ORDER BY created_at DESC ")
	} else {
		queryBuilder.WriteString("ORDER BY name ASC ")
	}

	rows, err := r.conn.Query(ctx, queryBuilder.String(), args...)
	if err != nil {
		return nil, fmt.Errorf("failed to execute query: %w", err)
	}
	defer rows.Close()

	var items []domain.Item
	for rows.Next() {
		var item domain.Item
		if err := rows.Scan(&item.ID, &item.CategoryID, &item.FarmID, &item.Name, &item.Image, &item.Description, &item.Unit, &item.Price, &item.Quantity); err != nil {
			return nil, fmt.Errorf("failed to scan row: %w", err)
		}
		items = append(items, item)
	}

	return items, nil
}
