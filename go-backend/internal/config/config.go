package config

type (
	Config struct {
		DatabaseUrl string `env:"DATABASE_URL"`
	}
)
