package http

import (
	_ "arbashop/docs"
	"context"
	swagger "github.com/arsmn/fiber-swagger/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"time"

	"github.com/gofiber/fiber/v2"
)

type (
	Router interface {
		Init(app *fiber.App)
	}

	server struct {
		fiber   *fiber.App
		address string
		routers []Router
	}
)

func NewServer(address string, routers ...Router) *server {
	s := server{
		fiber: fiber.New(fiber.Config{
			CaseSensitive: true,
			AppName:       "basement",
			ReadTimeout:   30 * time.Second,
			WriteTimeout:  30 * time.Second,
		}),
		routers: routers,
		address: address,
	}

	s.fiber.Use(
		cors.New(cors.Config{
			AllowOrigins: "*",
		}),
	)

	s.fiber.Get("/docs/*", swagger.HandlerDefault)

	for idx := range s.routers {
		s.routers[idx].Init(s.fiber)
	}

	return &s
}

func (s *server) Run() error {
	return s.fiber.Listen(s.address)
}

func (s *server) Shutdown(ctx context.Context) error {
	return s.fiber.ShutdownWithContext(ctx)
}
