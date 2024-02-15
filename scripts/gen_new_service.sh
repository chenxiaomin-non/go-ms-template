#! /bin/sh

num_of_services=$#
current_dir="$(pwd)/src"

if [ -z $GO_CURR_PROJECT_PATH ]; then
    echo "*** GO_CURR_PROJECT_PATH is not set"
    echo "*** Please set GO_CURR_PROJECT_PATH to the root of your project"
    echo "[Warning]: GO_CURR_PROJECT_PATH is not set"
    echo "Use current directory as root of project"
    echo ""
else
    current_dir=$GO_CURR_PROJECT_PATH
fi

if [ -z $GO_DEV_NAME ]; then
    echo "*** GO_DEV_NAME is not set"
    echo "*** Please set GO_DEV_NAME to your development name"
    echo "[Warning]: GO_DEV_NAME is not set"
    echo "Use default development name: local/my-microservice"
    echo ""
    GO_DEV_NAME="local/my-microservice"
fi

if [ $num_of_services -eq 0 ]; then
    echo "Lack of service name"
    echo "Usage: gen_new_service.sh <service_name1> <service_name2> ..."
    echo ""
    echo "[Error]: No service name"
    exit 1
fi


for service in $@; do
    echo "Generating service: $service"
    mkdir -p $current_dir/$service
    cd $current_dir/$service && go mod init $GO_DEV_NAME/$service
    echo "Generated service: $service"
done
exit 0