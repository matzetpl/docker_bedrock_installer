#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)." 
   exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to the parent directory
parent_dir=$(dirname "$script_dir")
last_part=$(basename "$parent_dir")

new_container_name="${last_part}-php-1"

yaml_file="$script_dir/install.yml"
sudo chmod 777 $yaml_file

if [ ! -f "$yaml_file" ]; then
  echo "ERROR: $yaml_file does not exist."
  exit 1
fi


wp_cli_url=$(sudo cat "$yaml_file" | yq e '.wp_args.wp_cli_url' -)
wp_cli_title=$(sudo cat "$yaml_file" | yq e '.wp_args.wp_cli_title' -)
wp_cli_admin_user=$(sudo cat "$yaml_file" | yq e '.wp_args.wp_cli_admin_user' -)
wp_cli_admin_password=$(sudo cat "$yaml_file" | yq e '.wp_args.wp_cli_admin_password' -)
wp_cli_admin_email=$(sudo cat "$yaml_file" | yq e '.wp_args.wp_cli_admin_email' -)

docker exec -it "$new_container_name" /bin/bash -c \
    "cd /var/www/html/ && wp core install --allow-root \
    --url='$wp_cli_url' \
    --title='$wp_cli_title' \
    --admin_user='$wp_cli_admin_user' \
    --admin_password='$wp_cli_admin_password' \
    --admin_email='$wp_cli_admin_email'" \
    --working-dir /var/www/html/