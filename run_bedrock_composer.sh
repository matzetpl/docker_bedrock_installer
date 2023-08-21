#!/bin/bash

# Get the current directory name
dir_name=$(basename "$PWD")

# Form the new container name by appending -php-1
new_container_name="${dir_name}-php-1"

# Check if the PHP container is running
if docker ps -q -f name="$new_container_name" >/dev/null; then
  # Execute composer install inside the PHP container
  docker exec -it "$new_container_name" composer install --working-dir /var/www/html/
else
  echo "PHP container $new_container_name not found. Make sure your Docker Compose is running."
fi
