#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)." 
   exit 1
fi

current_user='matzet'
# TODO: Change this current user for user running a script - but some thing dont work with sudo - try to fix that

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to the parent directory
parent_dir=$(dirname "$script_dir")
last_part=$(basename "$parent_dir")

new_container_name="${last_part}-php-1"

# Temporary directory to create the Bedrock project
temporary_dir="temp_bedrock_project"
cd $parent_dir

# Run composer create-project inside a container
docker run --rm -v "$PWD:/app" composer create-project roots/bedrock "$temporary_dir"

echo "Bedrock project created in the temporary directory."

# Move the project files to the desired directory

mkdir -p app_files
mv "$temporary_dir"/* app_files/
mv "$temporary_dir"/.env* app_files/

echo "Project files moved to the desired directory."

sudo chown -R "$current_user":"$current_user" "$temporary_dir"
sudo chmod -R u+w "$temporary_dir"

# Remove the temporary directory
rm -rf "$temporary_dir"

echo "Temporary directory removed."

# Rename .env.example to .env
mv app_files/.env.example app_files/.env

# Add MySQL database configuration to .env
sed -i "s,WP_HOME='http://example.com',WP_HOME='http://localhost:8000',g" app_files/.env
sed -i "s,# DB_HOST='localhost',DB_HOST='mariadb',g" app_files/.env
sed -i "s,# DB_PREFIX='wp_',DB_PREFIX='bd_wp_',g" app_files/.env


echo "Database configuration added to .env."

# Change ownership to current user and www-data group
sudo chown -R "$current_user":www-data ./app_files

echo "Ownership changed to $current_user."

echo "Temporary directory removed."


docker compose up --build && echo "REMEMBER TO RUN WP_INSTALL.SH "



