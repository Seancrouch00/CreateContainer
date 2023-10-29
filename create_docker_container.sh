#!/bin/bash

# Function to create and setup Docker container
setup_container() {
    local container_name=$1
    local image_name=$2
    local github_repo_urls=$3

    # Pull the Docker image
    if ! docker pull $image_name; then
        echo "Failed to pull Docker image $image_name"
        return 1
    fi

    # Create and run the Docker container
    if ! docker run -dit --name $container_name $image_name; then
        echo "Failed to create and start Docker container $container_name"
        return 1
    fi

    # Install git in the Docker container
    if ! docker exec $container_name apt-get update || ! docker exec $container_name apt-get install -y git; then
        echo "Failed to install git in the Docker container $container_name"
        return 1
    fi

    # Split the GitHub repository URLs and clone them inside the Docker container
    IFS=',' read -ra REPO_URLS <<< "$github_repo_urls"
    for REPO_URL in "${REPO_URLS[@]}"; do
        if ! docker exec $container_name git clone $REPO_URL; then
            echo "Failed to clone repository $REPO_URL"
            return 1
        fi
    done

    echo "Setup complete! Docker container '$container_name' is now running with the GitHub repositories cloned inside it."
    return 0
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker could not be found. Please install Docker and try again."
    exit 1
fi

while true; do
    echo "Choose a container to create:"
    echo "1) Ubuntu"
    echo "2) Kali Linux"
    echo "3) Debian"
    echo "4) Exit"
    read -p "Enter choice [1-4]: " choice

    case $choice in
        1)
            read -p "Enter container name: " container_name
            read -p "Enter GitHub repository URLs (comma-separated): " github_repo_urls
            setup_container $container_name "ubuntu" $github_repo_urls
            ;;
        2)
            read -p "Enter container name: " container_name
            read -p "Enter GitHub repository URLs (comma-separated): " github_repo_urls
            setup_container $container_name "kalilinux/kali-rolling" $github_repo_urls
            ;;
        3)
            read -p "Enter container name: " container_name
            read -p "Enter GitHub repository URLs (comma-separated): " github_repo_urls
            setup_container $container_name "debian:latest" $github_repo_urls
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 4."
            ;;
    esac
done
