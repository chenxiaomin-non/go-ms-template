package auth

import (
	"log"
	"net/http"
)

func Run(svr *http.Server) {
	err := svr.ListenAndServe()
	if err != nil {
		log.Println(err)
	}

	log.Println("server started in port " + getEnvPort())
}

func Stop(svr *http.Server) {
	err := svr.Close()
	if err != nil {
		log.Println(err)
	}
}
