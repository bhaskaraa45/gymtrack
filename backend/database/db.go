package db

import (
	"database/sql"
	"log"
	"os"
)


func CreateTable() {

	connStr := os.Getenv("DB_CONNSTRING")
	db, err := sql.Open("postgres", connStr)

	if err != nil {
		log.Fatal(err)
	}
	if err = db.Ping(); err != nil {
		log.Fatal(err)
	}

	query := `CREATE TABLE IF NOT EXISTS todos (
		id SERIAL PRIMARY KEY,
		title VARCHAR(100) NOT NULL,
		description VARCHAR(1000),
		isDone BOOLEAN,
		tag VARCHAR(100),
		user VARCHAR(500),
		time timestamp
	)`

	_, err = db.Exec(query)

	if err != nil {
		log.Fatal(err)
	}

}

