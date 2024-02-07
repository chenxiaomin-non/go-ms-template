package auth_test

import (
	"net/http"
	"testing"

	"my-microservice/auth"
)

func TestAuthServiceStart(t *testing.T) {

	svr := auth.NewServer(auth.NewHandler())
	go auth.Run(svr)

	t.Log("Waiting for server to start...")
	res, err := http.Get("http://127.0.0.1:8080/auth")
	if err != nil {
		t.Error(err)
	}
	if res.StatusCode != 200 {
		t.Errorf("Expected status code 200, got %d", res.StatusCode)
	}

	body := make([]byte, 100)
	_, err = res.Body.Read(body)
	if err != nil && err.Error() != "EOF" {
		t.Error(err)
	}

	t.Log(string(body))
	defer auth.Stop(svr)
	defer res.Body.Close()
}
