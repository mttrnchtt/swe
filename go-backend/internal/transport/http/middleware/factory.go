package middleware

import "arbashop/pkg/jwt"

type (
	Factory struct{}
)

func NewFactory() *Factory {
	return &Factory{}
}

func (m *Factory) NewAuthMiddleware(parser *jwt.Parser) *Auth { return NewAuth(parser) }
