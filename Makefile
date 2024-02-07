current_dir = $(shell pwd)

# Make new name=<name> will first check if the name already exists in the ./src directory
# If it does, it will return an error message and exit, otherwise it will create a new file with the name
new: 
	@mkdir ./src/$(name)
	@echo "Directory created"
	@sh ./scripts/gen_dockerfile.sh > ./Dockerfile


# Make remove name=<name> will first check if the name exists in the ./src directory
# If it does, it will remove the directory, otherwise it will return an error message and exit
remove: check
	@rm -rf ./src/$(name)
	echo "Directory removed"
#
#
check:
	@if [ -d ./src/$(name) ]; then \
		echo "Directory exists"; \
	else \
		echo "Directory does not exist"; \
		exit 1; \
	fi
#
#
# Make test will run the tests in the ./src/$(name) directory
test: check
	go test -v $(current_dir)/src/$(name)
#
#
build: check
	GOOS=linux go build -o ./$(name) ./main.go
#
#
# Make docker will do something with docker

docker-check:
# Check if docker is installed, and Dockerfile is present
	@docker -v
	@if [ $$? -eq 0 ]; then \
		echo "Docker is installed"; \
	else \
		echo "Docker is not installed"; \
		exit 1; \
	fi

	@if [ -f ./Dockerfile ]; then \
		echo "Dockerfile is present"; \
	else \
		echo "Dockerfile is not present"; \
		exit 1; \
	fi

# Check environment variables
	@if [ -f .env ]; \
	then \
		echo "Environment variables are present"; \
		export $(grep -v '^#' .env | xargs); \
	else \
		echo "User defined environment variables are not present"; \
		echo "Use .env.default as a template"; \
		make docker-default-env; \
	fi

#
#
docker-default-env:
	@if [ -f .env.default ]; \
	then \
		echo "Environment variables are present"; \
		export $(grep -v '^#' .env.default | xargs); \
	else \
		echo "Environment variables are not present"; \
		exit 1; \
	fi 
#
#
# Make docker build will build the docker image by using the Dockerfile
# The name of the image will be the name of the service
docker-build: docker-check
	@if [ -z $(name) ]; then \
		echo "Name is not set"; \
		exit 1; \
	fi
	docker build . -f $(current_dir)/Dockerfile --no-cache=true -t $(name)
#
#
# Make docker run will run the docker image
docker-run: docker-check
	@if [ -z $(name) ]; then \
		echo "Name is not set"; \
		exit 1; \
	fi
	docker run -p $(echo $PORT):$(echo $PORT) $(name)
#
#
# Make help will display the help message
help:
	@echo "Options:"
	@echo "make new name=<name> \t\t - Create a new directory (microservice) with the name <name>"
	@echo "make remove name=<name> \t - Remove the directory (microservice) with the name <name>"
	@echo "make test name=<name> \t\t - Run the tests in the directory (microservice) with the name <name>"
	@echo "make build name=<name> \t\t - Build the source code in the directory (microservice) with the name <name>"
	@echo "make docker \t\t\t - Do something with docker"
	@echo "make docker-check \t\t - Check if docker is installed, and Dockerfile is present"
	@echo "make docker-build name=<name>\t - Build microservice's source code to the docker image by using the Dockerfile"
	@echo "make docker-run name=<name> \t - Run the docker image"
