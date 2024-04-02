package database

import (
	"fmt"
	"gymtrack/internal/model"
)

func (s *service) AddSchedule(schedule model.ScheduleModel, userId int) (int, error) {
	query := "INSERT INTO schedule (user_id, titles) VALUES ($1, $2) RETURNING id"
	var id int
	err := s.db.QueryRow(query, userId, schedule.Titles).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("failed to create user, err: %v", err)
	}
	return id, nil
}

func (s *service) ExistsSchedule(userId int) (bool, error) {
	query := "SELECT EXISTS (SELECT 1 FROM schedule WHERE user_id = $1)"
	var exists bool
	err := s.db.QueryRow(query, userId).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("failed to create user, err: %v", err)
	}
	return exists, nil
}

func (s *service) UpdateSchedule(schedule model.ScheduleModel, userId int) error {
	query := "UPDATE schedule SET titles = $1 WHERE user_id = $2"
	_, err := s.db.Exec(query, schedule.Titles, userId)
	if err != nil {
		return fmt.Errorf("failed to create user, err: %v", err)
	}
	return nil
}
