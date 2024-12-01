package repository

import "errors"

var (
	ErrEntityNotFound = errors.New("entity not found")
	ErrCannotParseID  = errors.New("cannot parse id")
	ErrEntityConflict = errors.New("entity conflict")
)
