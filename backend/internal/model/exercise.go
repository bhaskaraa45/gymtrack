package model

type ExerciseModel struct {
	Id      int      `json:"id"`
	Name    string   `json:"name"`
	Sets    []int    `json:"sets"`
	Reps    []int    `json:"reps"`
	Weights []string `json:"weight"`
	IsDone  bool     `json:"isdone"`
}
