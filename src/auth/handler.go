package auth

import (
	"fmt"
	"net/http"
)

type AuthHandler struct{}

func NewHandler() *AuthHandler {
	return &AuthHandler{}
}

func writeResponse(w http.ResponseWriter, status int, key, value string) error {

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	info := []byte(fmt.Sprintf(`{"%v": "%v"}`, key, value))

	_, err := w.Write(info)
	if err != nil {
		return err
	}

	return nil
}
