package main

import (
	"fmt"

	db "github.com/bhaskaraa45/todo_app/database"
	"github.com/bhaskaraa45/todo_app/env"
)

func main() {
	env.LoadEnv()

	fmt.Println("Hello World")

	db.CreateTable()

}
