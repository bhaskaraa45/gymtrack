package controller

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/bhaskaraa45/backend/todo_app/database"
	"github.com/gorilla/mux"
)

func GetTodos(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)

	todos, err := database.SearchAllDataByUserId(params["id"])

	if err != nil {
		log.Fatal(err)
		json.NewEncoder(w).Encode("Failed to get all todos")
		return
	}
	json.NewEncoder(w).Encode(todos)
}

func GetTodo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)

	id, err := strconv.Atoi(params["id"])

	if err != nil {
		json.NewEncoder(w).Encode("Please Send valid ID")
	}

	todo := database.SearchData(id)
	json.NewEncoder(w).Encode(todo)
}
