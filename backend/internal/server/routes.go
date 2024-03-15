package server

import (
	"gymtrack/internal"
	"gymtrack/internal/controller"
	"gymtrack/internal/tokens"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

var UserId int //use it if needed

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	// Add CORS middleware
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusOK)
			return
		}

		// No guard waala (no authorization required) routes.
		if c.FullPath() == "/update" || c.FullPath() == "/auth" || c.FullPath() == "/" || c.FullPath() == "/refreshToken" {
			c.Next()
			return
		}

		// Extract the Authorization header.
		authHeader := c.GetHeader("Authorization")

		parts := strings.Split(authHeader, " ")

		if len(parts) == 2 && parts[0] == "Bearer" {
			accessToken := parts[1]
			isVerified, id := tokens.VerifyAccessToken(accessToken)
			if !isVerified {
				c.JSON(http.StatusUnauthorized, internal.NewCustomResponse("Unauthorized, try refreshing!", http.StatusUnauthorized))
				c.Abort()
				return
			} else {
				UserId = id
				c.Set("UserId", id)
				c.Next()
				return
			}
		} else {
			c.JSON(http.StatusUnauthorized, internal.NewCustomResponse("Unauthorized, try refreshing!", http.StatusUnauthorized))
			c.Abort()
			return
		}

	})

	r.GET("/", s.HelloWorldHandler)
	r.GET("/health", s.healthHandler)
	r.POST("/auth", controller.HandleLogin)
	r.POST("/refreshToken", controller.HandleRefreshToken)
	r.POST("/post", controller.HandleAdd)
	r.POST("/update", controller.HandleUpdate)

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
