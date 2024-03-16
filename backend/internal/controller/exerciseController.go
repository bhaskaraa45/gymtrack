package controller

import (
	"encoding/json"
	"gymtrack/internal"
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

	if c.Request.Body == nil || c.Request.ContentLength == 0 {
        resp := internal.NewCustomResponse("No body provided!", http.StatusBadRequest)
        c.JSON(http.StatusBadRequest, resp)
        return
    }
	var exercise model.ExerciseModel

	err := json.NewDecoder(c.Request.Body).Decode(&exercise)

	if err != nil {
		resp := internal.NewCustomResponse("ivalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	added, w_id := db.AddExercise(exercise)

	if !added {
		resp := internal.NewCustomResponse("internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	isExists, h_id := db.WorkoutInHistoryExists(time.Now(), userId)
	if !isExists {
		h_id, err = db.AddWorkoutInHistory(time.Now(), userId)
		if err != nil {
			resp := internal.NewCustomResponse("internal error", http.StatusInternalServerError)
			c.JSON(http.StatusBadRequest, resp)
			return
		}
	}

	result := db.AddDataInLinkedTableHistoryWorkout(h_id, w_id)
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

	if c.Request.Body == nil || c.Request.ContentLength == 0 {
        resp := internal.NewCustomResponse("No body provided!", http.StatusBadRequest)
        c.JSON(http.StatusBadRequest, resp)
        return
    }

	if err != nil {
		log.Printf("error: %v", err)
		resp := internal.NewCustomResponse("Invalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	if exercise.Id == 0 {
		resp := internal.NewCustomResponse("Id is not provided", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	updated := db.UpdateExercise(exercise, exercise.Id)
	if !updated {
		resp := internal.NewCustomResponse("internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp := make(map[string]any)
	resp["msg"] = "Successfully updated"
	c.JSON(http.StatusOK, resp)
}

func HandleGetHistory(c *gin.Context) {
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

	history, err := db.GetHistoryByUserID(userId)

	if err != nil {
		log.Println(err.Error())
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("Internal error, couldn't fetch history data", http.StatusInternalServerError))
		return
	}

	if len(history) == 0 {
		c.JSON(http.StatusOK, make(map[string][]model.ExerciseModel))
		return
	}

	historyIDs := make([]int, len(history))
	for i, h := range history {
		if h.Date.Format("02-01-2006") != time.Now().Format("02-01-2006") {
			historyIDs[i] = h.ID
		}
	}
	exercisesMap, err := db.GetExercisesByHistoryIDs(historyIDs)
	if err != nil {
		log.Println(err.Error())
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("Internal error", http.StatusInternalServerError))
		return
	}
	resp := make(map[string][]model.ExerciseModel)

	for _, h := range history {
		if ex, found := exercisesMap[h.ID]; found {
			formattedDate := h.Date.Format("02-01-2006")
			resp[formattedDate] = ex
		}
	}

	c.JSON(http.StatusOK, resp)
}

func HandleGetToday(c *gin.Context) {
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

	history, err := db.GetHistoryByUserIDAndDate(userId, time.Now())
	if err != nil {
		log.Println(err.Error())
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("Internal error, couldn't fetch history data", http.StatusInternalServerError))
		return
	}

	exercisesMap, err := db.GetExercisesByHistoryIDs([]int{history.ID})
	if err != nil {
		log.Println(err.Error())
		c.JSON(http.StatusInternalServerError, internal.NewCustomResponse("Internal error, couldn't fetch history data", http.StatusInternalServerError))
		return
	}

	resp := make(map[string][]model.ExerciseModel)

	if ex, found := exercisesMap[history.ID]; found {
		formattedDate := history.Date.Format("02-01-2006")
		resp[formattedDate] = ex
	}

	c.JSON(http.StatusOK, resp)
}
