package model

import "errors"

var (
	ErrNotFound           = errors.New("entity not found")
	ErrInvalidInput       = errors.New("invalid input")
	ErrCannotCreateEntity = errors.New("cannot create entity")
	ErrCannotUpdateEntity = errors.New("cannot update entity")
	ErrCannotDeleteEntity = errors.New("cannot delete entity")
	ErrUserNotConnected   = errors.New("user not connected")
	ErrInvalidConnection  = errors.New("invalid WebSocket connection")
)
