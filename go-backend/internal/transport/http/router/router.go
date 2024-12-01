package router

import (
	"arbashop/internal/transport/http/middleware"
	"github.com/gofiber/fiber/v2"
)

type (
	MakeRouter func(router fiber.Router)

	router struct {
		makeRouter         MakeRouter
		middlewaresFactory *middleware.Factory
	}
)

func NewRouter(makeFunc MakeRouter, factory *middleware.Factory) *router {
	return &router{
		makeRouter:         makeFunc,
		middlewaresFactory: factory,
	}
}

func (r *router) Init(app *fiber.App) {
	mainGroup := app.Group("api/v1")

	r.makeRouter(mainGroup)
}
