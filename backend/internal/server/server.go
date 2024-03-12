package server

import (
	"gymtrack/internal/database"

	"github.com/gofiber/fiber/v2"
)

type Server struct {
	*fiber.App
	db database.Service
}

func New() *Server {
	server := &Server{
		App: fiber.New(),
		db:  database.New(),
	}

	// var app *fiber.App

	// app.Use(logger.New())

	return server
}
