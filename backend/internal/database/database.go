package database

import (
	"context"
	"database/sql"
	"fmt"
	"gymtrack/internal/model"
	"log"
	"os"
	"strings"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
	_ "github.com/joho/godotenv/autoload"
)

type Service interface {
	Health() map[string]string
	UserExists(email string) (bool, int)
	CreateUser(user model.UserModel) (bool, int)
	UpdateRefreshToken(id int, rtoken string) bool
	GetUserById(id int) (bool, model.UserModel)
	VerifyRefreshToken(rtoken string, id int) bool
	AddExercise(exercise model.ExerciseModel) (bool, int)
	UpdateExercise(exercise model.ExerciseModel, id int) bool
}

type service struct {
	db *sql.DB
}

var (
	database = os.Getenv("DB_DATABASE")
	password = os.Getenv("DB_PASSWORD")
	username = os.Getenv("DB_USERNAME")
	port     = os.Getenv("DB_PORT")
	host     = os.Getenv("DB_HOST")
)

func New() Service {
	connStr := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", username, password, host, port, database)
	db, err := sql.Open("pgx", connStr)
	if err != nil {
		log.Fatalf("ERROR: %v", err)
	}
	s := &service{db: db}
	return s
}

func (s *service) Health() map[string]string {
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	err := s.db.PingContext(ctx)
	if err != nil {
		log.Fatalf(fmt.Sprintf("db down: %v", err))
	}

	return map[string]string{
		"message": "It's healthy",
	}
}

func (s *service) CreateUser(user model.UserModel) (bool, int) {
	que := "INSERT INTO users (email, name, uid) VALUES ( $1, $2, $3 ) RETURNING id"
	var id int
	err := s.db.QueryRow(que, user.Email, user.Name, user.UserId).Scan(&id)
	if err != nil {
		log.Printf("Failed to create user, err: %v", err)
		return false, 0
	}
	return true, id
}

func (s *service) UpdateRefreshToken(id int, rtoken string) bool {
	que := "UPDATE users SET rtoken = $1 WHERE id = $2"
	_, err := s.db.Exec(que, rtoken, id)
	if err != nil {
		log.Printf("userID: %v, refreshToken: %v", id, rtoken)
		log.Printf("Failed to update refresh token, err: %v", err)
		return false
	}
	return true
}

func (s *service) GetUserById(id int) (bool, model.UserModel) {
	que := "SELECT * FROM users WHERE id = $1"
	var user model.UserModel
	err := s.db.QueryRow(que, id).Scan(&user.Id, &user.Name, &user.Email, &user.UserId, &user.RefreshToken)
	if err != nil {
		log.Printf("Failed to get user, err: %v", err)
		return false, user
	}
	return true, user
}

func (s *service) UserExists(email string) (bool, int) {
	query := "SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)"
	var exists bool

	err := s.db.QueryRow(query, email).Scan(&exists)
	if err != nil {
		log.Printf("error checking users email = %v, error: %v", email, err)
		return false, 0
	}

	if exists {
		var id int
		query = "SELECT id FROM users WHERE email = $1"
		err := s.db.QueryRow(query, email).Scan(&id)
		if err != nil {
			log.Printf("error checking users email = %v, error: %v", email, err)
			return false, 0
		}
		return true, id
	}

	return false, 0
}

func (s *service) VerifyRefreshToken(rtoken string, id int) bool {
	query := "SELECT EXISTS(SELECT 1 FROM users WHERE rtoken = $1 AND id = $2)"
	var exists bool

	err := s.db.QueryRow(query, rtoken, id).Scan(&exists)
	if err != nil {
		log.Printf("error Verifying RefreshToken: %v", err)
		return false
	}

	return exists
}

func (s *service) AddExercise(exercise model.ExerciseModel) (bool, int) {
	query := "INSERT INTO workout (name, sets, reps, weight, isdone) VALUES ($1, $2, $3, $4, $5) RETURNING id"
	var id int
	err := s.db.QueryRow(query, exercise.Name, exercise.Sets, exercise.Reps, exercise.Weights, exercise.IsDone).Scan(&id)

	if err != nil {
		log.Printf("error adding exercise : %v", err)
		return false, 0
	}

	return true, id
}

func (s *service) UpdateExercise(exercise model.ExerciseModel, id int) bool {
	fields := map[string]interface{}{
		"name":   exercise.Name,
		"isDone": exercise.IsDone,
		"sets":   exercise.Sets,
		"reps":   exercise.Reps,
		"weight": exercise.Weights,
	}

	var setStatements []string
	var values []interface{}
	var index = 1

	// for k, v := range fields {
	// 	if v != nil && v != "" && v != 0 && len(v)!=0{
	// 		setStatements = append(setStatements, fmt.Sprintf("%s = $%d", k, index))
	// 		values = append(values, v)
	// 		index++
	// 		fmt.Println(v)
	// 	}
	// }

	for k, v := range fields {
		switch v := v.(type) {
		case []int:
			if len(v) > 0 {
				setStatements = append(setStatements, fmt.Sprintf("%s = $%d", k, index))
				values = append(values, v)
				index++
			}
		case []string:
			if len(v) > 0 {
				setStatements = append(setStatements, fmt.Sprintf("%s = $%d", k, index))
				values = append(values, v)
				index++
			}
		case int:
			if v != 0 {
				setStatements = append(setStatements, fmt.Sprintf("%s = $%d", k, index))
				values = append(values, v)
				index++
			}
		case bool:
			setStatements = append(setStatements, fmt.Sprintf("%s = $%d", k, index))
			values = append(values, v)
			index++
		case string:
			if v != "" {
				setStatements = append(setStatements, fmt.Sprintf("%s = $%d", k, index))
				values = append(values, v)
				index++
			}
		}
	}

	if index == 1 {
		log.Println("No data given")
		return false
	}

	query := fmt.Sprintf(`UPDATE workout SET %s WHERE id = $%d`, strings.Join(setStatements, ", "), index)

	values = append(values, id)
	result, err := s.db.Exec(query, values...)
	if err != nil {
		log.Println(err.Error())
		return false
	}

	affectedRows, err := result.RowsAffected()
	if err != nil {
		log.Println(err.Error())
		return false
	}
	if affectedRows == 0 {
		log.Printf("No rows updated for ID: %d\n", id)
	} else {
		log.Printf("Updated %d rows for ID: %d\n", affectedRows, id)
	}
	return true
}
