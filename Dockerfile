# syntax=docker/dockerfile:1
FROM golang:1.21-alpine as builder
RUN apk --no-cache add gcc g++ make git
WORKDIR /go-ms-template
COPY . .
RUN go mod download
RUN GOOS=linux go build -o ./auth ./main.go
ENV ENV_USER app-user
ENV ENV_UID 10001
RUN adduser \ 
    --disabled-password \ 
    --gecos "" \ 
    --home "/nonexistent" \ 
    --shell "/sbin/nologin" \ 
    --no-create-home \ 
    --uid "10001" \ 
    "app-user" 
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /usr/bin
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /go-ms-template/auth .
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
USER app-user:app-user
EXPOSE 8080
ENTRYPOINT ["./auth"] --port 8080
