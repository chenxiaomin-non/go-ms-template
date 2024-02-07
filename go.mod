module github.com/chenxiaomin-non/go-ms-template

go 1.21.6

replace my-microservice/auth => ./src/auth

require my-microservice/auth v0.0.0-00010101000000-000000000000
