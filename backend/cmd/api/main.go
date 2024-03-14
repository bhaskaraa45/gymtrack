package main

import (
	"fmt"
	"gymtrack/internal/server"

	_ "github.com/joho/godotenv/autoload"
)

func main() {
	server := server.NewServer()

	err := server.ListenAndServe()
	if err != nil {
		panic(fmt.Sprintf("cannot start server: %s", err))
	}

	// logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
}
