package models

type TodoModel struct {
	ID          int      `json:"id"`
	Title       string   `json:"title"`
	Description string   `json:"description"`
	IsDone      bool     `json:"isDone"`
	Tags        []string `json:"tags"`
	User        string   `json:"user"`
	Time        string   `json:"time"`
}