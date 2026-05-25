# Deployment Guide

## Persiapan Server

### Minimum Requirements
- PHP 8.1 atau lebih tinggi
- MySQL 5.7+ atau PostgreSQL 10+
- Composer
- Web Server (Apache/Nginx)
- 512 MB RAM minimum (1 GB recommended)
- 1 GB disk space

### PHP Extensions Required
- BCMath
- Ctype
- Fileinfo
- JSON
- Mbstring
- OpenSSL
- PDO
- Tokenizer
- XML

## Deployment ke Shared Hosting

### 1. Upload Files
Upload semua file kecuali folder `node_modules` dan `.git`

### 2. Setup Environment
```bash
# Copy .env.example ke .env
cp .env.example .env

# Edit .env dan sesuaikan:
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### 3. Install Dependencies
```bash
composer install --optimize-autoloader --no-dev
```

### 4. Generate Key
```bash
php artisan key:generate
```

### 5. Run Migrations
```bash
php artisan migrate --force
php artisan db:seed --class=InitialDataSeeder
```

### 6. Optimize
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 7. Set Permissions
```bash
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

### 8. Configure Web Server

#### Apache (.htaccess)
Pastikan file `.htaccess` ada di folder `public`:
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
```

#### Nginx
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /path/to/your/project/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

## Deployment ke VPS (Ubuntu)

### 1. Update System
```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Install PHP 8.1
```bash
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.1 php8.1-fpm php8.1-mysql php8.1-mbstring php8.1-xml php8.1-bcmath php8.1-curl php8.1-zip -y
```

### 3. Install Composer
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### 4. Install MySQL
```bash
sudo apt install mysql-server -y
sudo mysql_secure_installation
```

### 5. Create Database
```bash
sudo mysql -u root -p
```
```sql
CREATE DATABASE abon_db;
CREATE USER 'abon_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON abon_db.* TO 'abon_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 6. Install Nginx
```bash
sudo apt install nginx -y
```

### 7. Clone Project
```bash
cd /var/www
sudo git clone <repository-url> abon
cd abon
```

### 8. Setup Project
```bash
# Install dependencies
composer install --optimize-autoloader --no-dev

# Setup environment
cp .env.example .env
nano .env  # Edit database credentials

# Generate key
php artisan key:generate

# Run migrations
php artisan migrate --force
php artisan db:seed --class=InitialDataSeeder

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
sudo chown -R www-data:www-data /var/www/abon
sudo chmod -R 775 /var/www/abon/storage
sudo chmod -R 775 /var/www/abon/bootstrap/cache
```

### 9. Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/abon
```

Paste konfigurasi Nginx di atas, lalu:
```bash
sudo ln -s /etc/nginx/sites-available/abon /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 10. Setup SSL (Optional)
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

## Deployment dengan Docker

### 1. Create Dockerfile
```dockerfile
FROM php:8.1-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy project
COPY . /var/www

# Install dependencies
RUN composer install --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data /var/www
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
```

### 2. Create docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: abon-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./:/var/www
    networks:
      - abon-network

  nginx:
    image: nginx:alpine
    container_name: abon-nginx
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./:/var/www
      - ./docker/nginx:/etc/nginx/conf.d
    networks:
      - abon-network

  db:
    image: mysql:8.0
    container_name: abon-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: abon_db
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_USER: abon_user
      MYSQL_PASSWORD: abon_password
    volumes:
      - dbdata:/var/lib/mysql
    networks:
      - abon-network

networks:
  abon-network:
    driver: bridge

volumes:
  dbdata:
    driver: local
```

### 3. Run Docker
```bash
docker-compose up -d
docker-compose exec app php artisan migrate --force
docker-compose exec app php artisan db:seed --class=InitialDataSeeder
```

## Backup & Restore

### Backup Database
```bash
# Manual backup
mysqldump -u username -p database_name > backup_$(date +%Y%m%d_%H%M%S).sql

# Automated backup (cron)
0 2 * * * mysqldump -u username -p'password' database_name > /backups/db_$(date +\%Y\%m\%d).sql
```

### Restore Database
```bash
mysql -u username -p database_name < backup.sql
```

### Backup Files
```bash
tar -czf backup_$(date +%Y%m%d).tar.gz /var/www/abon
```

## Monitoring

### Setup Log Rotation
```bash
sudo nano /etc/logrotate.d/laravel
```

```
/var/www/abon/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 0640 www-data www-data
}
```

### Monitor Logs
```bash
# Real-time log monitoring
tail -f storage/logs/laravel.log

# Check error logs
grep "ERROR" storage/logs/laravel.log
```

## Troubleshooting

### Permission Issues
```bash
sudo chown -R www-data:www-data /var/www/abon
sudo chmod -R 775 storage bootstrap/cache
```

### Clear Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Database Connection Error
- Check `.env` database credentials
- Verify MySQL service is running: `sudo systemctl status mysql`
- Test connection: `mysql -u username -p`

### 500 Server Error
- Check `storage/logs/laravel.log`
- Verify file permissions
- Check `.env` configuration
- Run `php artisan config:clear`

## Security Checklist

- [ ] Set `APP_DEBUG=false` in production
- [ ] Use strong database passwords
- [ ] Enable HTTPS/SSL
- [ ] Set proper file permissions (775 for storage, 644 for files)
- [ ] Keep Laravel and dependencies updated
- [ ] Configure firewall (UFW)
- [ ] Regular database backups
- [ ] Monitor error logs
- [ ] Disable directory listing
- [ ] Use environment variables for sensitive data

## Performance Optimization

### Enable OPcache
```bash
sudo nano /etc/php/8.1/fpm/php.ini
```

```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
```

### Configure PHP-FPM
```bash
sudo nano /etc/php/8.1/fpm/pool.d/www.conf
```

```ini
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
```

### Restart Services
```bash
sudo systemctl restart php8.1-fpm
sudo systemctl restart nginx
```

## Maintenance Mode

### Enable Maintenance
```bash
php artisan down --secret="my-secret-token"
```

Access via: `https://yourdomain.com/my-secret-token`

### Disable Maintenance
```bash
php artisan up
```