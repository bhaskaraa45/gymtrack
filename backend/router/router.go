package router

import (
	"github.com/bhaskaraa45/backend/todo_app/controller"
	"github.com/gorilla/mux"
)

func Router() *mux.Router {

	r := mux.NewRouter()

	r.HandleFunc("/todos/{id}", controller.GetTodos).Methods("GET")     //getAllTodos
	r.HandleFunc("/todo/{id}", controller.GetTodo).Methods("GET")       //getTodoByTODOId
	r.HandleFunc("/todo/{id}", controller.DeleteTodo).Methods("DELETE") //deleteTodoByID
	r.HandleFunc("/todo", controller.CreateTodo).Methods("POST")        //addTodo
	r.HandleFunc("/todo/{id}", controller.UpdateTodo).Methods("POST")   //updateTodo

	return r
}
