package repository

import (
	"arbashop/internal/domain"
	"context"
	"errors"
	"fmt"
	"github.com/jackc/pgx/v5"
)

var (
	// ErrCategoryNotFound is returned when a category is not found in the database.
	ErrCategoryNotFound = errors.New("category not found")
)

type CategoryRepository struct {
	conn *pgx.Conn
}

// NewCategoryRepository creates a new instance of CategoryRepository.
func NewCategoryRepository(conn *pgx.Conn) *CategoryRepository {
	return &CategoryRepository{conn: conn}
}

// Create adds a new category to the database.
func (r *CategoryRepository) Create(ctx context.Context, category *domain.Category) error {
	query := `
		INSERT INTO category (name)
		VALUES ($1)
		RETURNING id;
	`

	var id uint
	if err := r.conn.QueryRow(ctx, query, category.Name).Scan(&id); err != nil {
		return fmt.Errorf("failed to insert category: %w", err)
	}

	category.ID = id
	return nil
}

// Get retrieves a category by its ID from the database.
func (r *CategoryRepository) Get(ctx context.Context, id uint) (*domain.Category, error) {
	query := `
		SELECT id, name
		FROM category
		WHERE id = $1;
	`

	var category domain.Category
	err := r.conn.QueryRow(ctx, query, id).Scan(&category.ID, &category.Name)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrCategoryNotFound
		}
		return nil, fmt.Errorf("failed to fetch category: %w", err)
	}

	return &category, nil
}

func (r *CategoryRepository) GetByName(ctx context.Context, name string) (*domain.Category, error) {
	query := `
		SELECT id, name
		FROM category
		WHERE name = $1;
	`

	var category domain.Category
	err := r.conn.QueryRow(ctx, query, name).Scan(&category.ID, &category.Name)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrCategoryNotFound
		}
		return nil, fmt.Errorf("failed to fetch category by name: %w", err)
	}

	return &category, nil
}
