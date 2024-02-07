package auth

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func (h *AuthHandler) Greet() func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {

		err := writeResponse(w, 200, "greet", "Hello, world!")
		if err != nil {
			log.Println(fmt.Errorf("error writing response: %w", err))
		}

		var TimeFormat = "2006-02-01 15:04:05Z+07"
		var notification = "GET /auth - 200 OK"
		format := fmt.Sprintf("[%s] - info: %s", time.Now().Format(TimeFormat), notification)
		log.Println(format)
	}
}
