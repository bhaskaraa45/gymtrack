package controller

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/bhaskaraa45/backend/todo_app/database"
	"github.com/bhaskaraa45/backend/todo_app/models"
	"github.com/gorilla/mux"
)

func GetTodos(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)
	userID, ok := params["id"]

	if !ok {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Please provide a valid ID")
		return
	}

	todos, err := database.SearchAllDataByUserId(userID)

	if err != nil {
		log.Fatal(err)
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Failed to get all todos")
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(todos)
}

func GetTodo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	idStr, ok := params["id"]

	if !ok {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Please provide a valid ID")
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Invalid ID")
		return
	}

	todo := database.SearchData(id)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(todo)
}

func DeleteTodo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)
	idStr, ok := params["id"]

	if !ok {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Please provide a valid ID")
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Invalid ID")
		return
	}

	result := database.DeleteData(id)

	if !result {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode("Failed to delete todo")
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode("Successfully deleted todo")
}

func CreateTodo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var todo models.TodoModel
	err := json.NewDecoder(r.Body).Decode(&todo)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Invalid JSON format")
		return
	}

	id := database.InsertData(todo)

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]int{"id": id})
}

func UpdateTodo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)

	idStr, ok := params["id"]
	var todo models.TodoModel

	if !ok {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Please provide a valid ID")
		return
	}

	id, err := strconv.Atoi(idStr)

	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Invalid ID")
		return
	}

	err2 := json.NewDecoder(r.Body).Decode(&todo)
	if err2 != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Invalid JSON format")
		return
	}

	result := database.UpdateData(id, todo)

	if !result {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode("Failed to update")
		return
	}

	w.WriteHeader(http.StatusAccepted)
	json.NewEncoder(w).Encode("Successfully updated")

}
