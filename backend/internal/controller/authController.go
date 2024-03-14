package controller

import (
	"context"
	"encoding/json"
	"gymtrack/internal"
	"gymtrack/internal/database"
	"gymtrack/internal/tokens"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Token struct {
	IdToken string `json:"idToken"`
}

type RToken struct {
	RefreshToken string `json:"refreshToken"`
	UserId       int    `json: id`
}

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

	log.Printf("idToken: %v", idToken)

	res, msg, user := tokens.VerifyIdToken(idToken, ctx)

	if !res {
		c.JSON(http.StatusUnauthorized, internal.NewCustomResponse(msg, http.StatusUnauthorized))
		return
	}

	isExists, userId := database.New().UserExists(user.Email)

	if isExists {
		e, currUser := database.New().GetUserById(userId)
		if !e {
			c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("internal error", http.StatusInternalServerError))
			return
		}

		accessToken, err := tokens.GenerateAccessToken(userId)
		if err != nil {
			c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("internal error", http.StatusInternalServerError))
			return
		}

		resp := make(map[string]any)
		resp["email"] = currUser.Email
		resp["id"] = userId
		resp["name"] = currUser.Name
		resp["uid"] = currUser.UserId
		resp["accessToken"] = accessToken
		resp["refreshToken"] = currUser.RefreshToken

		finalresp := make(map[string]any)
		finalresp["user"] = resp
		finalresp["isNew"] = false
		c.JSON(http.StatusOK, finalresp)
		return
	}

	isCreated, userId := database.New().CreateUser(user)

	if !isCreated {
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("internal error(CreateUser)", http.StatusInternalServerError))
		return
	}

	refreshToken, err := tokens.GenerateRefreshToken(userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("internal error(GenerateRefreshToken)", http.StatusInternalServerError))
		return
	}

	isUpdated := database.New().UpdateRefreshToken(userId, refreshToken)

	if !isUpdated {
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("internal error(UpdateRefreshToken)", http.StatusInternalServerError))
		return
	}

	accessToken, err := tokens.GenerateAccessToken(userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("internal error", http.StatusInternalServerError))
		return
	}

	user.RefreshToken = refreshToken

	resp := make(map[string]any)
	resp["email"] = user.Email
	resp["id"] = userId
	resp["name"] = user.Name
	resp["uid"] = user.UserId
	resp["accessToken"] = accessToken
	resp["refreshToken"] = refreshToken

	finalresp := make(map[string]any)
	finalresp["user"] = resp
	finalresp["isNew"] = true
	c.JSON(http.StatusOK, finalresp)
}

func HandleRefreshToken(c *gin.Context) { //POST RToken(json) in body
	var data RToken
	err := json.NewDecoder(c.Request.Body).Decode(&data)
	if err != nil {
		resp := internal.NewCustomResponse("ivalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	refreshToken := data.RefreshToken

	if refreshToken == "" {
		c.JSON(http.StatusBadRequest, internal.NewCustomResponse("Refresh token not provided", http.StatusBadRequest))
		return
	}
	id := data.UserId

	if id == 0 {
		c.JSON(http.StatusBadRequest, internal.NewCustomResponse("User id not provided", http.StatusBadRequest))
		return
	}

	result := database.New().VerifyRefreshToken(refreshToken, id)

	if !result {
		c.JSON(http.StatusUnauthorized, internal.NewCustomResponse("Unauthorized, invalid refresh token or user id", http.StatusUnauthorized))
		return
	}

	atoken, err := tokens.GenerateAccessToken(id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("internal error(GenerateAccessToken)", http.StatusInternalServerError))
		return
	}

	resp := make(map[string]string)
	resp["accessToken"] = atoken
	resp["refreshToken"] = refreshToken
	c.JSON(http.StatusOK, resp)
}
