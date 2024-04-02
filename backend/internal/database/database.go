package database

import (
	"context"
	"database/sql"
	"fmt"
	"gymtrack/internal/model"
	"log"
	"os"
	"strconv"
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
	GetExercise(id int) (model.ExerciseModel, error)
	GetExercisesByHistoryIDs(historyIDs []int) (map[int][]model.ExerciseModel, error)
	DeleteExercise(id int) (bool, error)
	UpdateExercise(exercise model.ExerciseModel, id int) bool
	AddWorkoutInHistory(date time.Time, userID int) (int, error)
	AddDataInLinkedTableHistoryWorkout(history_id int, workout_id int) bool
	DeleteDataInLinkedTableHistoryWorkout(history_id int, workout_id int) bool
	GetHistoryByUserID(userID int) ([]model.HistoryModel, error)
	WorkoutInHistoryExists(date time.Time, userID int) (bool, int)
	GetDataInLinkedTableHistoryWorkout(history_id int) ([]model.HistoryWorkoutLinkModel, error)
	GetHistoryByUserIDAndDate(userID int, date time.Time) (model.HistoryModel, error)
	AddSchedule(schedule model.ScheduleModel, userId int) (int, error)
	ExistsSchedule(userId int) (bool, error)
	UpdateSchedule(schedule model.ScheduleModel, userId int) (error)
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

func (s *service) GetExercise(id int) (model.ExerciseModel, error) {
	query := "SELECT * FROM workout WHERE id = $1"
	var exercise model.ExerciseModel
	err := s.db.QueryRow(query, id).Scan(&exercise.Id, &exercise.Name, &exercise.Sets, &exercise.Reps, &exercise.Weights, &exercise.IsDone)

	if err != nil {
		return exercise, fmt.Errorf("error getting exercise : %v", err)
	}

	return exercise, nil
}

func (s *service) DeleteExercise(id int) (bool, error) {
	query := "DELETE FROM workout WHERE id = $1"

	_, err := s.db.Exec(query, id)

	if err != nil {
		return false, fmt.Errorf("error deleting exercise : %v", err)
	}

	return true, nil
}

func (s *service) GetExercisesByHistoryIDs(historyIDs []int) (map[int][]model.ExerciseModel, error) {

	var idsPlaceholder []string
	var params []interface{}
	for i, id := range historyIDs {
		idsPlaceholder = append(idsPlaceholder, fmt.Sprintf("$%d", i+1))
		params = append(params, id)
	}

	query := fmt.Sprintf(`
		SELECT hw.history_id, w.id, w.name, w.sets, w.reps, w.weight, w.isdone 
		FROM history_workout_link hw 
		JOIN workout w ON hw.workout_id = w.id 
		WHERE hw.history_id IN (%s)
	`, strings.Join(idsPlaceholder, ","))

	rows, err := s.db.Query(query, params...)
	if err != nil {
		return nil, fmt.Errorf("error querying exercises by history IDs: %v", err)
	}
	defer rows.Close()

	exercisesByHistory := make(map[int][]model.ExerciseModel)

	for rows.Next() {
		var hID int
		var tempExercise model.TempExerciseModel

		if err := rows.Scan(&hID, &tempExercise.Id, &tempExercise.Name, &tempExercise.Sets, &tempExercise.Reps, &tempExercise.Weights, &tempExercise.IsDone); err != nil {
			return nil, fmt.Errorf("error scanning exercise record: %v", err)
		}

		var reps []int
		if tempExercise.Reps.Valid {
			trimmedReps := strings.Trim(tempExercise.Reps.String, "{}")
			if trimmedReps != "" {
				for _, repStr := range strings.Split(trimmedReps, ",") {
					rep, err := strconv.Atoi(repStr)
					if err != nil {
						return nil, fmt.Errorf("error converting rep from string to int: %v", err)
					}
					reps = append(reps, rep)
				}
			}
		}

		var weights []string
		if tempExercise.Weights.Valid {
			cleanedWeights := strings.Trim(tempExercise.Weights.String, "{}")
			for _, weightStr := range strings.Split(cleanedWeights, ",") {
				cleanedWeight := strings.Trim(weightStr, "\"")
				weights = append(weights, cleanedWeight)
			}
		}

		exercise := model.ExerciseModel{
			Id:      tempExercise.Id,
			Name:    tempExercise.Name,
			Sets:    tempExercise.Sets,
			Reps:    reps,
			Weights: weights,
			IsDone:  tempExercise.IsDone,
		}

		exercisesByHistory[hID] = append(exercisesByHistory[hID], exercise)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating over exercises records: %v", err)
	}

	return exercisesByHistory, nil
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

func (s *service) AddWorkoutInHistory(date time.Time, userID int) (int, error) {
	query := `INSERT INTO history (date, user_id) VALUES ($1, $2) RETURNING id`
	var id int
	err := s.db.QueryRow(query, date, userID).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("error adding history to the database: %v", err)
	}
	return id, nil
}

func (s *service) WorkoutInHistoryExists(date time.Time, userID int) (bool, int) {
	query := `SELECT EXISTS(SELECT 1 FROM history WHERE date = $1 AND user_id = $2)`
	var id int
	var exists bool
	err := s.db.QueryRow(query, date, userID).Scan(&exists)
	if err != nil {
		fmt.Printf("error adding history to the database: %v", err)
		return false, 0
	}
	if exists {
		query := `SELECT id FROM history WHERE date = $1 AND user_id = $2`
		err := s.db.QueryRow(query, date, userID).Scan(&id)
		if err != nil {
			fmt.Printf("error adding history to the database: %v", err)
			return false, 0
		}
		return true, id
	}
	return false, 0
}

func (s *service) GetHistoryByUserID(userID int) ([]model.HistoryModel, error) {
	query := `SELECT * FROM history WHERE user_id = $1`
	rows, err := s.db.Query(query, userID)
	if err != nil {
		return nil, fmt.Errorf("error retrieving history from the database: %v", err)
	}
	defer rows.Close()

	var history []model.HistoryModel
	for rows.Next() {
		var entry model.HistoryModel
		if err := rows.Scan(&entry.ID, &entry.Date, &entry.UserID); err != nil {
			return nil, fmt.Errorf("error scanning history record: %v", err)
		}
		history = append(history, entry)
	}
	fmt.Println("HELLO WROLD")

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error reading history records: %v", err)
	}

	return history, nil
}

func (s *service) GetHistoryByUserIDAndDate(userID int, date time.Time) (model.HistoryModel, error) {
	query := `SELECT * FROM history WHERE user_id = $1 and date = $2`
	var entry model.HistoryModel
	err := s.db.QueryRow(query, userID, date).Scan(&entry.ID, &entry.Date, &entry.UserID)
	if err != nil {
		return entry, fmt.Errorf("error retrieving history from the database: %v", err)
	}
	return entry, nil
}

func (s *service) AddDataInLinkedTableHistoryWorkout(history_id int, workout_id int) bool {
	query := `INSERT INTO history_workout_link (history_id, workout_id) VALUES ($1, $2)`
	_, err := s.db.Exec(query, history_id, workout_id)
	if err != nil {
		log.Printf("error adding history_workout_link to the database: %v", err)
		return false
	}
	return true
}

func (s *service) DeleteDataInLinkedTableHistoryWorkout(history_id int, workout_id int) bool {
	query := `DELETE FROM history_workout_link WHERE history_id = $1 AND workout_id = $2`
	_, err := s.db.Exec(query, history_id, workout_id)
	if err != nil {
		log.Printf("error deleting history_workout_link to the database: %v", err)
		return false
	}
	return true
}

func (s *service) GetDataInLinkedTableHistoryWorkout(history_id int) ([]model.HistoryWorkoutLinkModel, error) {
	query := `SELECT * FROM history_workout_link WHERE history_id = $1`
	rows, err := s.db.Query(query, history_id)
	if err != nil {
		return nil, fmt.Errorf("error getting history_workout_link to the database: %v", err)
	}
	var data []model.HistoryWorkoutLinkModel

	for rows.Next() {
		var entry model.HistoryWorkoutLinkModel
		if err := rows.Scan(&entry.HistoryId, &entry.WorkoutId); err != nil {
			return nil, fmt.Errorf("error scanning history_workout_link record: %v", err)
		}
		data = append(data, entry)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error reading history_workout_link records: %v", err)
	}

	return data, nil
}
