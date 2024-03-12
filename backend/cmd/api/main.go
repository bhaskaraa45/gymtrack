package main

import (
	"context"
	"fmt"
	"gymtrack/internal/auth"
	"gymtrack/internal/server"
	"log"
	"os"
	"strconv"

	firebase "firebase.google.com/go"
	_ "github.com/joho/godotenv/autoload"
	"google.golang.org/api/option"
)

func main() {
	ctx := context.Background()

	opt := option.WithCredentialsFile("credentials.json")
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		log.Fatalf("Error initializing app: %v\n", err)
	}
	client, err := app.Auth(ctx)
	if err != nil {
		log.Fatalf("Error initializing Auth client: %v\n", err)
	}
	auth.FirebaseClient(client)
	log.Printf("Firebase Admin SDK initialized")

	server := server.New()
	server.RegisterFiberRoutes()
	port, _ := strconv.Atoi(os.Getenv("PORT"))
	err = server.Listen(fmt.Sprintf(":%d", port))
	if err != nil {
		panic(fmt.Sprintf("cannot start server: %s", err))
	}

	// logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

}
