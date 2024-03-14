package auth

import (
	"context"
	"encoding/json"
	"gymtrack/internal"
	"gymtrack/internal/database"
	"gymtrack/internal/model"
	"gymtrack/internal/tokens"
	"log"
	"net/http"
	"time"

	"firebase.google.com/go/auth"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
)

var client *auth.Client

func FirebaseClient(c *auth.Client) {
	client = c
}

type Token struct {
	IdToken string `json:"idToken"`
}

// func Verify(idToken string) (bool, string, int, string) {
// 	ctx := context.Background()
// 	token, err := client.VerifyIDTokenAndCheckRevoked(ctx, idToken)
// 	if err != nil {
// 		log.Printf("Error verifying ID token: %v\n", err)
// 		return false, "", 0, ""
// 	}

// 	// Get user email from the verified token
// 	userEmail := token.Claims["email"].(string)
// 	userName := token.Claims["name"].(string)
// 	fmt.Printf("User Email: %s\n", userEmail)
// 	fmt.Printf("User Name: %s\n", userName)

// 	isExists, id := database.New().UserExists(userEmail)

// 	if isExists {
// 		return true, userEmail, id, userName
// 	}

// 	res, id_ := database.New().CreateUser(userEmail, userName)

// 	return res, userEmail, id_, userName
// }

func HandleLogin(c *gin.Context) {
	ctx := context.Background()
	var data Token
	err := json.NewDecoder(c.Request.Body).Decode(&data)
	if err != nil {
		resp := internal.NewCustomResponse("ivalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	idToken := data.IdToken

	if idToken == "" {
		c.JSON(http.StatusBadRequest, internal.NewCustomResponse("ID token not provided", http.StatusBadRequest))
		return
	}

	log.Printf("got idToken: %v", idToken)

	res, msg, user := tokens.VerifyIdToken(idToken, ctx)

	// res, email, userId, name := Verify(data.IdToken)

	if !res {
		c.JSON(http.StatusUnauthorized, internal.NewCustomResponse(msg, http.StatusUnauthorized))
		return
	}

	res, userId := createUser(user)

	jwtToken := jwt.New(jwt.SigningMethodHS256)
	jwtToken.Claims = jwt.MapClaims{
		"sub": userId,
		"exp": time.Now().Add(15 * 24 * time.Hour).Unix(),
	}

	// tokenString, err := jwtToken.SignedString([]byte(os.Getenv("SECRET_KEY")))
	// if err != nil {
	// 	log.Printf("%v", err)
	// 	c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("Failed to create token", http.StatusInternalServerError))
	// 	return
	// }

	// cookie := http.Cookie{
	// 	Name:     "token",
	// 	Domain:   "https://shrink.bhaskaraa45.me",
	// 	Path:     "/",
	// 	Secure:   true,
	// 	HttpOnly: true,
	// 	Expires:  time.Now().Add(15 * 24 * time.Hour),
	// 	Value:    "tokenString",
	// 	SameSite: http.SameSiteNoneMode,
	// }
	// http.SetCookie(c.Writer, &cookie)

	resp := make(map[string]any)
	resp["email"] = "email"
	resp["id"] = "userId"
	resp["name"] = "name"
	c.JSON(http.StatusOK, resp)
}

func createUser(user model.UserModel) (bool, int) {
	isExists, id := database.New().UserExists(user.Email)

	if isExists {
		return true, id
	}

	return database.New().CreateUser(user)
}
