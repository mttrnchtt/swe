package main

import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
)

func setupDatabaseConnection(ctx context.Context, url string) (*pgx.Conn, error) {
	conn, err := pgx.Connect(ctx, url)
	if err != nil {
		return nil, err
	}

	// Verify the connection with a Ping
	if err := conn.Ping(ctx); err != nil {
		err := conn.Close(ctx)
		if err != nil {
			return nil, err
		}
		return nil, err
	}

	// Query and print all table names
	query := `
		SELECT table_name 
		FROM information_schema.tables 
		WHERE table_schema = 'public'
	`
	rows, err := conn.Query(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch table names: %w", err)
	}
	defer rows.Close()

	fmt.Println("Existing tables in the database:")
	for rows.Next() {
		var tableName string
		if err := rows.Scan(&tableName); err != nil {
			return nil, fmt.Errorf("failed to scan table name: %w", err)
		}
		fmt.Println("- ", tableName)
	}
	if rows.Err() != nil {
		return nil, fmt.Errorf("error iterating over table rows: %w", rows.Err())
	}

	return conn, nil
}
