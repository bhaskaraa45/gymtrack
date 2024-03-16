package model

import "database/sql"

type ExerciseModel struct {
	Id      int      `json:"id"`
	Name    string   `json:"name"`
	Sets    int      `json:"sets"`
	Reps    []int    `json:"reps"`
	Weights []string `json:"weight"`
	IsDone  bool     `json:"isdone"`
}

type TempExerciseModel struct {
	Id      int
	Name    string
	Sets    int
	Reps    sql.NullString
	Weights sql.NullString
	IsDone  bool
}
