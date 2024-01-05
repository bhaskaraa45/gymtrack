package database

import (
	"database/sql"
	"fmt"
	"log"
	"strings"

	"github.com/bhaskaraa45/backend/todo_app/models"
	_ "github.com/lib/pq"
)

var db *sql.DB

func InitDB(datab *sql.DB) {
	db = datab
}

func InsertData(data models.TodoModel) int {
	query := `INSERT INTO todos (title, description, isDone, tag, "User", time )
		VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`
	var id int
	err := db.QueryRow(query, data.Title, data.Description, data.IsDone, data.Tag, data.User, data.Time).Scan(&id)
	if err != nil {
		log.Fatal(err)
	}
	return id
}

func DeleteData(id int) bool {
	query := "DELETE FROM todos WHERE id = $1"

	result, err := db.Exec(query, id)
	if err != nil {
		log.Fatal(err)
		return false
	}

	deletedRow, err := result.RowsAffected()
	if err != nil {
		log.Fatal(err)
		return false
	}

	log.Printf("Deleted %d rows", deletedRow)
	return true
}

func SearchData(id int) *models.TodoModel {
	query := "SELECT * FROM todos WHERE id = $1"

	row := db.QueryRow(query, id)

	var todo models.TodoModel
	err := row.Scan(&todo.ID, &todo.Title, &todo.Description, &todo.IsDone, &todo.Tag, &todo.User, &todo.Time)
	if err != nil {
		if err == sql.ErrNoRows {
			fmt.Println("No data found for the given ID")
			return nil
		}
		log.Fatal(err)
	}

	fmt.Printf("Todo: %+v\n", todo)

	return &todo
}

func SearchDataByUserId(id string) *models.TodoModel {
	query := `SELECT * FROM todos WHERE "User" = $1`

	row := db.QueryRow(query, id)

	var todo models.TodoModel
	err := row.Scan(&todo.ID, &todo.Title, &todo.Description, &todo.IsDone, &todo.Tag, &todo.User, &todo.Time)
	if err != nil {
		if err == sql.ErrNoRows {
			fmt.Printf("No data found for the given user ID: %s\n", id)
			return nil
		}
		log.Printf("Error retrieving data for user ID %s: %v\n", id, err)
		return nil
	}

	fmt.Printf("Todo: %+v\n", todo)

	return &todo
}

func UpdateData(id int, todo models.TodoModel) bool {
	fields := map[string]interface{}{
		"title":       todo.Title,
		"description": todo.Description,
		"isDone":      todo.IsDone,
		"tag":         todo.Tag,
		"\"User\"":    todo.User,
		"time":        todo.Time,
	}

	var setStatements []string
	var values []interface{}
	var index = 1

	for k, v := range fields {
		if v != nil && v != "" {
			setStatements = append(setStatements, fmt.Sprintf("%s = $%d", k, index))
			values = append(values, v)
			index++
			fmt.Println(v)
		}
	}

	if index == 1 {
		fmt.Println("No data given")
		return false
	}

	query := fmt.Sprintf(`UPDATE todos SET %s WHERE id = $%d`, strings.Join(setStatements, ", "), index)

	fmt.Println(query)

	values = append(values, id)

	result, err := db.Exec(query, values...)
	if err != nil {
		log.Fatal(err)
		return false
	}

	affectedRows, err := result.RowsAffected()
	if err != nil {
		log.Fatal(err)
		return false
	}

	if affectedRows == 0 {
		fmt.Printf("No rows updated for ID: %d\n", id)
	} else {
		fmt.Printf("Updated %d rows for ID: %d\n", affectedRows, id)
	}
	return true
}

func SearchAllDataByUserId(id string) ([]models.TodoModel, error) {
	query := `SELECT * FROM todos WHERE "User" = $1`

	rows, err := db.Query(query, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var todos []models.TodoModel

	for rows.Next() {
		var todo models.TodoModel
		err := rows.Scan(&todo.ID, &todo.Title, &todo.Description, &todo.IsDone, &todo.Tag, &todo.User, &todo.Time)
		if err != nil {
			return nil, err
		}
		todos = append(todos, todo)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	fmt.Println(todos)

	return todos, nil
}

// func CreateTable() {

// 	connStr := os.Getenv("DB_CONNSTRING")
// 	db, err := sql.Open("postgres", connStr)
// 	fmt.Println(1)
// 	if err != nil {
// 		log.Fatal(err)
// 	}
// 	fmt.Println(2)

// 	if err = db.Ping(); err != nil {
// 		log.Fatal(err)
// 	}
// 	fmt.Println(3)

// 	query := `CREATE TABLE IF NOT EXISTS todos (
// 		id SERIAL PRIMARY KEY,
// 		title VARCHAR(100) NOT NULL,
// 		description VARCHAR(1000),
// 		isDone BOOLEAN,
// 		tag VARCHAR(100),
// 		"User" VARCHAR(500),
// 		time timestamp
// 	)`
// 	_, err = db.Exec(query)

// 	if err != nil {
// 		log.Fatal(err)
// 	}

// }
