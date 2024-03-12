package auth

import (
	"context"
	"encoding/json"
	"fmt"
	"gymtrack/internal"
	"gymtrack/internal/database"
	"log"
	"net/http"
	"os"
	"time"

	"firebase.google.com/go/auth"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt"
)

var client *auth.Client

func FirebaseClient(c *auth.Client) {
	client = c
}

type Token struct {
	IdToken string `json:"idToken"`
}

func Verify(idToken string) (bool, string, int, string) {
	ctx := context.Background()
	token, err := client.VerifyIDToken(ctx, idToken)
	if err != nil {
		log.Printf("Error verifying ID token: %v\n", err)
		return false, "", 0, ""
	}

	// Get user email from the verified token
	userEmail := token.Claims["email"].(string)
	userName := token.Claims["name"].(string)
	fmt.Printf("User Email: %s\n", userEmail)
	fmt.Printf("User Name: %s\n", userName)

	isExists, id := database.New().UserExists(userEmail)

	if isExists {
		return true, userEmail, id, userName
	}

	res, id_ := database.New().CreateUser(userEmail, userName)

	return res, userEmail, id_, userName
}

func HandleLogin(c *fiber.Ctx) error {

	bodyBytes := c.Body()

	if len(bodyBytes) == 0 {
		return c.Status(http.StatusBadRequest).JSON(internal.NewCustomResponse("Empty request body", http.StatusBadRequest))
	}
	var data Token
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		return c.Status(http.StatusBadRequest).JSON(internal.NewCustomResponse("Invalid JSON data", http.StatusBadRequest))
	}

	// var data Token
	// err := json.NewDecoder(c.Request().BodyStream()).Decode(&data)
	// if err != nil {
	// 	resp := internal.NewCustomResponse("invalid JSON data!", http.StatusBadRequest)
	// 	return c.Status(http.StatusBadRequest).JSON(resp)
	// }
	idToken := data.IdToken

	if idToken == "" {
		return c.Status(http.StatusBadRequest).JSON(internal.NewCustomResponse("ID token not provided", http.StatusBadRequest))

	}

	log.Printf("got idToken: %v", idToken)

	res, email, userId, name := Verify(data.IdToken)

	if !res {
		return c.Status(http.StatusUnauthorized).JSON(internal.NewCustomResponse("Failed to verify token", http.StatusUnauthorized))
	}

	jwtToken := jwt.New(jwt.SigningMethodHS256)
	jwtToken.Claims = jwt.MapClaims{
		"sub": userId,
		"exp": time.Now().Add(15 * 24 * time.Hour).Unix(),
	}

	tokenString, err := jwtToken.SignedString([]byte(os.Getenv("SECRET_KEY")))
	if err != nil {
		log.Printf("%v", err)
		return c.Status(http.StatusInternalServerError).JSON(internal.NewCustomResponse("Failed to create token", http.StatusInternalServerError))
	}

	cookie := new(fiber.Cookie)
	cookie.Name = "token"
	cookie.Value = tokenString
	cookie.Domain = "localhost"
	cookie.Path = "/"
	cookie.Secure = true
	cookie.HTTPOnly = true
	cookie.Expires = time.Now().Add(15 * 24 * time.Hour)
	cookie.SameSite = "None"

	c.Cookie(cookie)

	resp := make(map[string]any)
	resp["email"] = email
	resp["id"] = userId
	resp["name"] = name
	return c.Status(http.StatusOK).JSON(resp)
}
