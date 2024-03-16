package model

import "time"

type HistoryModel struct {
	ID     int       `json:"id"`
	Date   time.Time `json:"date"`
	UserID int       `json:"user_id"`
}
