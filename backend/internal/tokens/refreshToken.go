package tokens

import (
	"log"
	"os"

	"github.com/golang-jwt/jwt"
)

func GenerateRefreshToken(userId int) (string, error) {
	jwtToken := jwt.New(jwt.SigningMethodHS256)
	jwtToken.Claims = jwt.MapClaims{
		"sub": userId,
	}

	token, err := jwtToken.SignedString([]byte(os.Getenv("REFRESH_TOKEN_KEY")))

	if err != nil {
		log.Printf("Error while generating refresh token: %v", err)
		return "", err
	}

	return token, nil
}
