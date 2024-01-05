package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/bhaskaraa45/backend/todo_app/database"
	"github.com/bhaskaraa45/backend/todo_app/env"
	"github.com/bhaskaraa45/backend/todo_app/router"
)

var db *sql.DB

func main() {
	env.LoadEnv()

	connStr := os.Getenv("DB_CONNSTRING")
	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}

	if err = db.Ping(); err != nil {
		log.Fatal(err)
	}

	database.InitDB(db)

	fmt.Println("Server starting @ 3000....")

	r := router.Router()
	err = http.ListenAndServe(":3000", r)

	if err != nil {
		log.Fatal(err)
	}
}
