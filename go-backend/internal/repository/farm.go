package repository

import (
	"arbashop/internal/domain"
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
)

type FarmRepository struct {
	conn *pgx.Conn
}

// NewFarmRepository initializes a new FarmRepository with the provided pgx connection.
func NewFarmRepository(conn *pgx.Conn) *FarmRepository {
	return &FarmRepository{conn: conn}
}

// Create inserts a new farm record into the database.
func (r *FarmRepository) Create(ctx context.Context, farm *domain.Farm) error {
	query := `
		INSERT INTO farms (farmer_id, farm_name, farm_size, address)
		VALUES ($1, $2, $3, $4)
		RETURNING id;
	`

	err := r.conn.QueryRow(ctx, query, farm.FarmerID, farm.FarmName, farm.FarmSize, farm.Address).Scan(&farm.ID)
	if err != nil {
		return err
	}
	return nil
}

// Update modifies an existing farm record in the database.
func (r *FarmRepository) Update(ctx context.Context, farm *domain.Farm) error {
	query := `
		UPDATE farms
		SET farm_name = $1, farm_size = $2, address = $3
		WHERE id = $4;
	`

	cmdTag, err := r.conn.Exec(ctx, query, farm.FarmName, farm.FarmSize, farm.Address, farm.ID)
	if err != nil {
		return err
	}

	if cmdTag.RowsAffected() == 0 {
		return errors.New("farm not found")
	}
	return nil
}

// Get retrieves a farm record by its ID.
func (r *FarmRepository) Get(ctx context.Context, id uint) (*domain.Farm, error) {
	query := `
		SELECT id, farmer_id, farm_name, farm_size, address
		FROM farms
		WHERE id = $1;
	`

	farm := &domain.Farm{}
	err := r.conn.QueryRow(ctx, query, id).Scan(
		&farm.ID,
		&farm.FarmerID,
		&farm.FarmName,
		&farm.FarmSize,
		&farm.Address,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.New("farm not found")
		}
		return nil, err
	}
	return farm, nil
}

// GetAll retrieves all farms from the database.
func (r *FarmRepository) GetAll(ctx context.Context) ([]domain.Farm, error) {
	query := `SELECT id, farmer_id, farm_name, farm_size, address FROM farms`
	rows, err := r.conn.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var farms []domain.Farm
	for rows.Next() {
		var farm domain.Farm
		if err := rows.Scan(&farm.ID, &farm.FarmerID, &farm.FarmName, &farm.FarmSize, &farm.Address); err != nil {
			return nil, err
		}
		farms = append(farms, farm)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return farms, nil
}
