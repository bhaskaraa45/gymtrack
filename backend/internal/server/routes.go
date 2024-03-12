package server

import (
	"github.com/gin-gonic/gin"
	"net/http"
)


func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	// Add CORS middleware
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")

		// Handle preflight requests
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusOK)
			return
		}

		//no guard waala routes
		if c.FullPath() == "/" || c.FullPath() == "/verify" || c.FullPath() == "/:shorturl" || c.FullPath() == "/logout" {
			c.Next()
			return
		}
		c.Next()
	})

	r.GET("/", s.HelloWorldHandler)
	r.GET("/health", s.healthHandler)

	return r
}


func (s *Server) HelloWorldHandler(c *gin.Context) {
	resp := make(map[string]string)
	resp["message"] = "Hello World"

	c.JSON(http.StatusOK, resp)
}

func (s *Server) healthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, s.db.Health())
}
