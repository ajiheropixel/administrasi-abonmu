# Command Reference

## Setup & Installation

### Install Dependencies
```bash
composer install
```

### Setup Environment
```bash
# Copy environment file
copy .env.example .env

# Generate application key
php artisan key:generate
```

### Database Setup
```bash
# Run migrations
php artisan migrate

# Run migrations with seed data
php artisan migrate --seed

# Or seed separately
php artisan db:seed --class=InitialDataSeeder
```

### Clear Cache
```bash
# Clear all cache
php artisan optimize:clear

# Or individually
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## Development

### Run Development Server
```bash
php artisan serve
```

Access at: http://localhost:8000

### Run on Custom Port
```bash
php artisan serve --port=8080
```

### Run on Network
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

## Database Management

### Fresh Migration (Reset Database)
```bash
# WARNING: This will delete all data
php artisan migrate:fresh

# With seeder
php artisan migrate:fresh --seed
```

### Rollback Migration
```bash
# Rollback last batch
php artisan migrate:rollback

# Rollback specific steps
php artisan migrate:rollback --step=2
```

### Check Migration Status
```bash
php artisan migrate:status
```

### Create New Migration
```bash
php artisan make:migration create_table_name
```

## Model & Controller

### Create Model
```bash
php artisan make:model ModelName
```

### Create Model with Migration
```bash
php artisan make:model ModelName -m
```

### Create Controller
```bash
php artisan make:controller ControllerName
```

### Create Resource Controller
```bash
php artisan make:controller ControllerName --resource
```

## Seeder

### Create Seeder
```bash
php artisan make:seeder SeederName
```

### Run Specific Seeder
```bash
php artisan db:seed --class=SeederName
```

## Maintenance

### Put Application in Maintenance Mode
```bash
php artisan down
```

### Bring Application Back Online
```bash
php artisan up
```

### Maintenance Mode with Secret
```bash
php artisan down --secret="my-secret-token"
```
Access via: http://localhost:8000/my-secret-token

## Useful Commands

### List All Routes
```bash
php artisan route:list
```

### List Specific Routes
```bash
php artisan route:list --name=products
```

### Tinker (Interactive Shell)
```bash
php artisan tinker
```

### Generate IDE Helper (if installed)
```bash
composer require --dev barryvdh/laravel-ide-helper
php artisan ide-helper:generate
php artisan ide-helper:models
```

## Production Deployment

### Optimize for Production
```bash
# Cache configuration
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Optimize autoloader
composer install --optimize-autoloader --no-dev
```

### Clear Production Cache
```bash
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## Backup & Restore

### Backup Database
```bash
# MySQL
mysqldump -u username -p database_name > backup_$(date +%Y%m%d).sql

# PostgreSQL
pg_dump -U username database_name > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
# MySQL
mysql -u username -p database_name < backup.sql

# PostgreSQL
psql -U username database_name < backup.sql
```

## Testing

### Run Tests
```bash
php artisan test
```

### Run Specific Test
```bash
php artisan test --filter=TestName
```

## Queue (if using)

### Run Queue Worker
```bash
php artisan queue:work
```

### Run Queue with Specific Connection
```bash
php artisan queue:work redis
```

### List Failed Jobs
```bash
php artisan queue:failed
```

## Logs

### View Logs
```bash
# Windows
type storage\logs\laravel.log

# Linux/Mac
tail -f storage/logs/laravel.log
```

### Clear Logs
```bash
# Windows
del storage\logs\laravel.log

# Linux/Mac
rm storage/logs/laravel.log
```

## Permissions (Linux/Mac)

### Set Storage Permissions
```bash
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

## Composer

### Update Dependencies
```bash
composer update
```

### Install Specific Package
```bash
composer require package/name
```

### Remove Package
```bash
composer remove package/name
```

### Dump Autoload
```bash
composer dump-autoload
```