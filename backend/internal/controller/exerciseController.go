package controller

import (
	"encoding/json"
	"gymtrack/internal"
	"gymtrack/internal/database"
	"gymtrack/internal/model"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func HandleAdd(c *gin.Context) {
	userIdInterface, exists := c.Get("UserId")

	if !exists {
		c.JSON(http.StatusUnauthorized, internal.NewCustomResponse("Unauthorized, user ID not found", http.StatusUnauthorized))
		return
	}
	userId, ok := userIdInterface.(int)
	if !ok {
        c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("Internal error, user ID invalid", http.StatusInternalServerError))
        return
    }

	var exercise model.ExerciseModel

	err := json.NewDecoder(c.Request.Body).Decode(&exercise)

	if err != nil {
		resp := internal.NewCustomResponse("ivalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	added, w_id := database.New().AddExercise(exercise)

	if !added {
		resp := internal.NewCustomResponse("internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	h_id, err := database.New().AddWorkoutInHistory(time.Now(), userId)
	if err != nil {
		resp := internal.NewCustomResponse("internal error", http.StatusInternalServerError)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	result := database.New().AddDataInLinkedTableHistoryWorkout(h_id, w_id)
	if !result {
		resp := internal.NewCustomResponse("internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp := make(map[string]any)
	resp["id"] = h_id
	resp["msg"] = "Successfully added"
	c.JSON(http.StatusOK, resp)
}

func HandleUpdate(c *gin.Context) {
	var exercise model.ExerciseModel

	err := json.NewDecoder(c.Request.Body).Decode(&exercise)

	if err != nil {
		log.Printf("error: %v", err)
		resp := internal.NewCustomResponse("ivalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	if exercise.Id == 0 {
		resp := internal.NewCustomResponse("id is not provided", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	updated := database.New().UpdateExercise(exercise, exercise.Id)
	if !updated {
		resp := internal.NewCustomResponse("internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp := make(map[string]any)
	resp["msg"] = "Successfully updated"
	c.JSON(http.StatusOK, resp)
}
