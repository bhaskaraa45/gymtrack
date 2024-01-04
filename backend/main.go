package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/bhaskaraa45/todo_app/database"
	"github.com/bhaskaraa45/todo_app/env"
	"github.com/bhaskaraa45/todo_app/models"
)

func main() {
	env.LoadEnv()

	fmt.Println("Hello World")

	data := models.TodoModel{User: "Bhaskar AA45", Time: "2024-01-04 12:34:56"}

	connStr := os.Getenv("DB_CONNSTRING")
	db, err := sql.Open("postgres", connStr)
	fmt.Println(1)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(2)

	if err = db.Ping(); err != nil {
		log.Fatal(err)
	}

	// database.InsertData(data, db)
	// database.DeleteData(5, db)
	// database.SearchDataByUserId("123", db)
	database.UpdateData(3, data, db)
}
