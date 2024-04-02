package controller

import (
	"encoding/json"
	"fmt"
	"gymtrack/internal"
	"gymtrack/internal/model"
	"net/http"

	"github.com/gin-gonic/gin"
)

func HandleAddSchedule(c *gin.Context) {
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

	var schedule model.ScheduleModel
	err := json.NewDecoder(c.Request.Body).Decode(&schedule)

	if err != nil {
		resp := internal.NewCustomResponse("Invalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	if !(len(schedule.Titles) > 0) {
		resp := internal.NewCustomResponse("Invalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}
	isExists, err := db.ExistsSchedule(userId)
	if err != nil {
		resp := internal.NewCustomResponse("Internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	if isExists {
		resp := make(map[string]any)
		resp["msg"] = "Schedule is already in databse, try to update!"
		c.JSON(http.StatusOK, resp)
		return
	}

	id, err := db.AddSchedule(schedule, userId)
	if err != nil {
		resp := internal.NewCustomResponse("Internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp := make(map[string]any)
	resp["msg"] = "Successfully schedule added!"
	resp["schedule_id"] = id
	c.JSON(http.StatusOK, resp)
}

func HandleUpdateSchedule(c *gin.Context) {
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

	var schedule model.ScheduleModel
	err := json.NewDecoder(c.Request.Body).Decode(&schedule)

	if err != nil {
		resp := internal.NewCustomResponse("Invalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	if !(len(schedule.Titles) > 0) {
		resp := internal.NewCustomResponse("Invalid json data!", http.StatusBadRequest)
		c.JSON(http.StatusBadRequest, resp)
		return
	}
	isExists, err := db.ExistsSchedule(userId)
	if err != nil {
		resp := internal.NewCustomResponse("Internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}
	if !isExists {
		resp := make(map[string]any)
		resp["msg"] = "Schedule is not available in databse, try to add!"
		c.JSON(http.StatusOK, resp)
		return
	}

	err = db.UpdateSchedule(schedule, userId)
	if err != nil {
		fmt.Println(err)
		resp := internal.NewCustomResponse("Internal error", http.StatusInternalServerError)
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp := make(map[string]any)
	resp["msg"] = "Successfully schedule updated!"
	c.JSON(http.StatusOK, resp)
}
