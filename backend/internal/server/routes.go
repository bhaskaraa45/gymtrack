package server

import (
	"gymtrack/internal/auth"
	"net/http"

	"github.com/gofiber/fiber/v2"
)

func (s *Server) RegisterFiberRoutes() {

	s.App.Use(func(c *fiber.Ctx) error {
		c.Set("Access-Control-Allow-Origin", "localhost")
		c.Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Set("Access-Control-Allow-Credentials", "true")

		if c.Method() == fiber.MethodOptions {
			return c.Status(http.StatusOK).SendString("")
		}

		return c.Next()
	})

	s.App.Get("/", s.HelloWorldHandler)
	s.App.Get("/health", s.healthHandler)
	s.App.Post("/auth", auth.HandleLogin)

}

func (s *Server) HelloWorldHandler(c *fiber.Ctx) error {
	resp := map[string]string{
		"message": "Hello World",
	}
	return c.JSON(resp)
}

func (s *Server) healthHandler(c *fiber.Ctx) error {
	return c.JSON(s.db.Health())
}
