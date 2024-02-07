package auth

import (
	"net/http"
)

func NewServer(h *AuthHandler) *http.Server {
	mux := http.NewServeMux()

	mux.HandleFunc("/auth", h.Greet())

	return &http.Server{
		Addr:    ":" + getEnvPort(),
		Handler: mux,
	}
}

func getEnvPort() string {
	return "8080"
}
