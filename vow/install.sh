#!/bin/bash

# Permissions
sudo find . -type f -exec chmod 664 {} \;
sudo find . -type d -exec chmod 775 {} \;
sudo chgrp -R $USER storage bootstrap/cache
sudo chmod -R ug+rwx storage bootstrap/cache

# Environment
cp .env.example .env

# Install container
docker-compose up -d --build

# Vendor
docker run --rm -v $(pwd):/app composer install

# Setup Laravel Application
docker exec -it vow_fpm php artisan key:generate
docker exec -it vow_fpm php artisan migrate --seed
docker exec -it vow_fpm php artisan passport:install

# Generate client for rocket.chat
docker exec -it vow_fpm php artisan passport:client --name=rocket.chat --redirect_uri=http://localhost:3000/_oauth/vow

# Generate client for odoo
docker exec -it vow_fpm php artisan passport:client --public --name=odoo --redirect_uri=http://localhost:8069/auth_oauth/signin
