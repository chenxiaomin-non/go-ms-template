#!/bin/sh
default_go_version="1.21"
if [ -z "$GO_VERSION" ]; then
  GO_VERSION=$default_go_version
fi

default_go_service="auth"
if [ -z "$GO_SERVICE" ]; then
  GO_SERVICE=$default_go_service
fi

default_user="app-user"
if [ -z "$ENV_USER" ]; then
  ENV_USER=$default_user
fi

default_uid="10001"
if [ -z "$ENV_UID" ]; then
  ENV_UID=$default_uid
fi

default_port="8080"
if [ -z "$PORT" ]; then
  PORT=$default_port
fi

default_source_path="$PWD"
if [ -z "$SOURCE_PATH" ]; then
  SOURCE_PATH=$default_source_path
fi

default_work_dir="/go-ms-template"

echo "# syntax=docker/dockerfile:1"
echo "FROM golang:$GO_VERSION-alpine as builder"
echo "RUN apk --no-cache add gcc g++ make git"
echo "WORKDIR $default_work_dir"
echo "COPY . ."
echo "RUN go mod download"
echo "RUN GOOS=linux go build -o ./$GO_SERVICE ./main.go"
echo "ENV ENV_USER $ENV_USER"
echo "ENV ENV_UID $ENV_UID"
echo "RUN adduser \ "
echo "    --disabled-password \ "
echo "    --gecos \"\" \ "
echo "    --home \"/nonexistent\" \ "
echo "    --shell \"/sbin/nologin\" \ "
echo "    --no-create-home \ "
echo "    --uid \"$ENV_UID\" \ "
echo "    \"$ENV_USER\" "

echo "FROM alpine:latest"
echo "RUN apk --no-cache add ca-certificates"
# Non root user info
echo "WORKDIR /usr/bin"
echo "COPY --from=builder /etc/passwd /etc/passwd"
echo "COPY --from=builder /etc/group /etc/group"
# Copying the binary
echo "COPY --from=builder $default_work_dir/$GO_SERVICE ."
# Certs for making https requests
echo "COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/"
# Running as appuser
echo "USER $ENV_USER:$ENV_USER"
echo "EXPOSE $PORT"
echo "ENTRYPOINT [\"./$GO_SERVICE\"] --port $PORT"

exit 0