package router

import (
	"github.com/bhaskaraa45/backend/todo_app/controller"
	"github.com/gorilla/mux"
)

func Router() *mux.Router  {

	r := mux.NewRouter()

	r.HandleFunc("/todos/{id}", controller.GetTodos).Methods("GET")
	r.HandleFunc("/todo/{id}", controller.GetTodo).Methods("GET")


	return r
}