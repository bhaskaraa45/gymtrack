package database

import (
	"context"
	"database/sql"
	"fmt"
	"gymtrack/internal/model"
	"log"
	"os"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
	_ "github.com/joho/godotenv/autoload"
)

type Service interface {
	Health() map[string]string
	UserExists(email string) (bool, int)
	CreateUser(user model.UserModel) (bool, int)
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

func (s *service) GetUserById(id int) (bool, model.UserModel) {
	que := "SELECT * FROM users WHERE id = $1"
	var user model.UserModel
	err := s.db.QueryRow(que, id).Scan(&user.Id, &user.Name, &user.Email, &user.UserId)
	if err != nil {
		log.Printf("Failed to create user, err: %v", err)
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

func (s *service) AddExercise(exercise model.ExerciseModel) (bool, int) {
	query := "INSERT INTO workout (name, sets, reps, weight) VALUES ($1, $2, $3, $4) RETURNING id"
	var id int
	err := s.db.QueryRow(query, exercise.Name, exercise.Sets, exercise.Reps, exercise.Weights).Scan(&id)

	if err != nil {
		log.Printf("error adding exercise : %v", err)
		return false, 0
	}

	return true, id
}
