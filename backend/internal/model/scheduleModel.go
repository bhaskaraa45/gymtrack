package model

type ScheduleModel struct {
	Id     int      `json:"id"`
	Titles []string `json:"titles"` // 0->monday,....6->sunday
}
