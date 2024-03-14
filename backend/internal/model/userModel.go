package model

type UserModel struct {
	Id           int    `json:"id"`
	UserId       string `json:"uid"`
	Name         string `json:"name"`
	Email        string `json:"email"`
	RefreshToken string `json:"refreshToken"`
}
