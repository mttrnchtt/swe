package main

import (
	"arbashop/internal/config"
	"arbashop/internal/repository"
	"arbashop/internal/service"
	"arbashop/internal/transport/http"
	"arbashop/internal/transport/http/handlers"
	"arbashop/internal/transport/http/middleware"
	"arbashop/internal/transport/http/router"
	"arbashop/pkg/jwt"
	"arbashop/pkg/logger"
	"context"
	"fmt"
	"github.com/caarlos0/env/v11"
	"github.com/gofrs/uuid"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/rs/zerolog/log"
)

//	@securityDefinitions.apikey	Bearer
//	@in							header
//	@name						Authorization

// @BasePath	/
func main() {
	generator := jwt.MustGenerator()
	tokens, _, err := generator.Tokens(context.TODO(), uuid.UUID{1})
	fmt.Println(tokens)
	if err != nil {
		return
	}

	rootLogger := logger.InitRootLogger(
		true,
		logger.ParseEnvLoggerEnv("DEBUG"),
		"basement",
	)

	ctx, cancelCtx := context.WithCancel(context.Background())

	cfg, err := env.ParseAs[config.Config]()
	if err != nil {
		log.Fatal().Err(err).Msg("Can't parse config")
	}

	conn, err := setupDatabaseConnection(ctx, cfg.DatabaseUrl)
	if err != nil {
		log.Fatal().Err(err).Msg("Can't setup database connection")
	}
	defer conn.Close(ctx)
	rootLogger.Info().Msg("Successfully connected to database")

	auth := middleware.NewAuth(jwt.MustParser())

	chatRepository := repository.NewChatRepository(conn)
	chatHandler := handlers.NewChatHandler(auth, service.NewChatService(chatRepository), service.NewWebSocketManager(chatRepository))
	chatRouter := router.NewRouter(
		chatHandler.Router(),
		middleware.NewFactory(),
	)

	server := http.NewServer(":8080", chatRouter)

	errChannel := make(chan error)

	go func() {
		slog.Info("Starting public http server", slog.String("address", "localhost:8080"))
		errChannel <- server.Run()
	}()

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	select {
	case sig := <-signalChan:
		slog.Info("Shutting down due to signal", slog.String("signal", sig.String()))
		cancelCtx()
		os.Exit(0)

	case err := <-errChannel:
		slog.Error("Error while serving connection", slog.String("error", err.Error()))
		cancelCtx()
		os.Exit(-1)
	}
}
