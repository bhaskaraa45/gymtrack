package main

import (
	"database/sql"
	"fmt"
	"log"

	// "net/http"
	"os"

	"github.com/bhaskaraa45/backend/todo_app/database"
	"github.com/bhaskaraa45/backend/todo_app/env"
	// "github.com/bhaskaraa45/backend/todo_app/router"
)

var db *sql.DB

func main() {
	env.LoadEnv()

	connStr := os.Getenv("DB_CONNSTRING")
	var err error
	db, err = sql.Open("postgres", connStr)
	fmt.Println(1)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(2)

	if err = db.Ping(); err != nil {
		log.Fatal(err)
	}

	database.InitDB(db)
	database.CreateTable()

	// r := router.Router()
	// log.Fatal(http.ListenAndServe(":8080", r))
}
