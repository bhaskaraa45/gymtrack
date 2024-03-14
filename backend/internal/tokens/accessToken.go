package tokens

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt"
)

func GenerateAccessToken(userId int) (string, error) {
	jwtToken := jwt.New(jwt.SigningMethodHS256)
	jwtToken.Claims = jwt.MapClaims{
		"sub": userId,
		"exp": time.Now().Add(7 * 24 * time.Hour).Unix(),
	}

	token, err := jwtToken.SignedString([]byte(os.Getenv("ACCESS_TOKEN_KEY")))

	if err != nil {
		log.Printf("Error while generating access token: %v", err)
		return "", err
	}

	return token, nil
}

func VerifyAccessToken(accessToken string) (bool, int /*userId*/) {
	result, err := jwt.Parse(accessToken, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(os.Getenv("ACCESS_TOKEN_KEY")), nil
	})

	if err != nil || !result.Valid {
		return false, 0
	}

	mp := result.Claims.(jwt.MapClaims)
	subject, ok := mp["sub"]

	if !ok {
		return false, 0
	}

	exp, ok := mp["exp"].(float64)
	if !ok {
		return false, 0
	}

	expirationTime := time.Unix(int64(exp), 0)
	sub := fmt.Sprintf("%v", subject)
	sub_int, err := strconv.Atoi(sub)

	if err != nil {
		return false, 0
	}

	return !expirationTime.Before(time.Now()), sub_int
}
