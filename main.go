package main

import (
	"my-microservice/auth"
)

func main() {
	svr := auth.NewServer(auth.NewHandler())
	auth.Run(svr)

}
