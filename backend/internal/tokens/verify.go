package tokens

import (
	"context"
	"fmt"
	"gymtrack/internal/model"
	"log"
	"os"

	"google.golang.org/api/idtoken"
)

var (
	clientID = os.Getenv("GOOGLE_CLIENT")
)

func VerifyIdToken(idTokenString string, ctx context.Context) (bool, string, model.UserModel) {
	var user model.UserModel
	fmt.Println(clientID)

	payload, err := idtoken.Validate(ctx, idTokenString, clientID)
	if err != nil {
		log.Printf("Invalid ID token: %v", err)
		return false, "Invalid ID token", user
	}

	userId := payload.Subject
	email, _ := payload.Claims["email"].(string)
	name, _ := payload.Claims["name"].(string)

	user.Email = email
	user.UserId = userId
	user.Name = name

	return true, "Successfully verified", user
}
