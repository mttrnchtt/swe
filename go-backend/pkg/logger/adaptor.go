package logger

import (
	"github.com/rs/zerolog"
)

type GooseLoggerAdaptor struct {
	*zerolog.Logger
}

func NewGooseLoggerAdaptor() *GooseLoggerAdaptor {
	return &GooseLoggerAdaptor{}
}

func (l *GooseLoggerAdaptor) Fatalf(format string, v ...any) {
	l.Fatal().Msgf(format, v)
}
