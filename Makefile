current_dir = $(shell pwd)


define decorate
    $(eval $@_msg = $(1))
	$(eval $@_len = $(shell echo $($@_msg) | wc -m))	
    printf '=%.0s' $(shell seq 1 $(shell expr $($@_len) + 11))
	echo "\n     $($@_msg)"
	printf '=%.0s' $(shell seq 1 $(shell expr $($@_len) + 11))
	echo ""
endef

define final
	$(eval $@_msg = $(1))

	echo "\n[Makefile] $($@_msg)"
	echo "Made by tnn404."
	exit 0
endef

define task_log
	$(eval $@_msg = $(1))
	echo "\n\033[0;33m[task]\033[0m $($@_msg)\n"
endef

define info_log
	$(eval $@_msg = $(1))
	echo "\033[0;34m[info]\033[0m $($@_msg)"
endef

define err_log
	$(eval $@_msg = $(1))
	echo "\033[0;31m[err]\033[0m $($@_msg)"
endef

define ok
	$(eval $@_msg = $(1))
	echo "\033[0;32m[ok]\033[0m $($@_msg)"
endef



# Make new name=<name> will first check if the name already exists in the ./src directory
# If it does, it will return an error message and exit, otherwise it will create a new file with the name
new: 
	@$(call task_log,"Make new $(name) service")
	@$(call decorate,"Creating new directory \& init go module")
	@sh ./scripts/gen_new_service.sh $(name)
	@$(call ok,"Done")
	@$(call decorate,"Creating Dockerfile for the new service")
	@sh ./scripts/gen_dockerfile.sh > ./src/$(name)/Dockerfile
	@echo "Dockerfile created"
	@$(call ok,"Done")
	@$(call final,"Service $(name) created")

# Make remove name=<name> will first check if the name exists in the ./src directory
# If it does, it will remove the directory, otherwise it will return an error message and exit
remove: 
	@$(call task_log,"Make remove $(name) service")
ifndef name
	@$(call err_log,"Name is not set")
	@exit 1
endif
ifeq ($(wildcard ./src/$(name)),)
	@$(call err_log,"Directory $(name) does not exist")
	@exit 1
endif
	@$(call decorate,"Removing directory")
	@rm -rf ./src/$(name)
	@$(call info_log,"Directory removed")
	@$(call ok,"Done")
	@$(call final,"Service $(name) removed")
#
#
# Make test will run the tests in the ./src/$(name) directory
test: check
	@$(call task_log,"Make test $(name) service")
	@$(call info_log,"Running tests")
	cd $(current_dir)/src/$(name) && go test -v .
	@$(call ok,"Done")
	@$(call final,"Tests passed")
#
#
build: check
	@$(call info_log,"Building source code")
	GOOS=linux go build -o ./$(name) ./main.go
	@$(call ok,"Done")
	@$(call final,"Source code built, binary is in ./$(name)")
#
#
# Make docker will do something with docker

docker-check:
# Check if docker is installed
	@$(call info_log,"Checking if docker is installed")
	@docker -v
ifeq ($(shell echo $$?),0)
	@echo "Docker is installed"
else
	@echo "Docker is not installed"
	@exit 1
endif
# Check if Dockerfile is present
	@$(call info_log,"Checking if Dockerfile is present")
ifneq ("","$(wildcard Dockerfile)")
	@echo "Dockerfile is present"
else 
	@echo "Dockerfile is not present"
	@exit 1
endif
# Check environment variables
	@$(call info_log,"Checking environment variables")
ifneq ("","$(wildcard .env)")
	@echo "Environment variables are present"
	@export $(shell grep -v '^#' $(pwd)/.env | xargs)
else
	@echo "User defined environment variables are not present"
	@echo "Use .env.default as a template"
	@make docker-default-env
endif
	@$(call ok,"Done")

#
#
docker-default-env:
	@$(call info_log,"Checking if .env.default is present")
ifneq ("","$(wildcard .env.default)")
	@echo "Environment variables are present"
	@echo "Env vars: $(shell grep -v '^#' .env.default | xargs)"
	@export $(shell grep -v '^#' .env.default | xargs)
else 
	@echo "Environment variables are not present"
	@exit 1
endif
	@$(call ok,"Done")
#
#
# Make docker build will build the docker image by using the Dockerfile
# The name of the image will be the name of the service
docker-build: docker-check
ifdef name
	@echo "Name is not set"
	@exit 1
endif
	@$(call info_log,"Building docker image")
	docker build . -f $(current_dir)/Dockerfile --no-cache=true -t $(name)
	@$(call ok,"Done")
	@$(call final,"Docker image $(name) built")
#
#
# Make docker run will run the docker image
docker-run: docker-check
ifdef name
	@echo "Name is not set"
	@exit 1
endif
	@$(call info_log,"Running docker image")
	docker run -p $(echo $PORT):$(echo $PORT) $(name)
	@$(call ok,"Done")

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
