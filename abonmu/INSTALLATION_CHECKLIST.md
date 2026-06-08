# Installation Checklist

## Pre-Installation

- [ ] PHP 8.1+ installed
- [ ] Composer installed
- [ ] MySQL/PostgreSQL installed
- [ ] Web server (Apache/Nginx) or use PHP built-in server
- [ ] Git installed (optional)

## Installation Steps

### 1. Download/Clone Project
- [ ] Download project files or clone from repository
- [ ] Extract to desired directory

### 2. Install Dependencies
```bash
composer install
```
- [ ] Dependencies installed successfully
- [ ] No errors during installation

### 3. Environment Setup
```bash
cp .env.example .env
```
- [ ] .env file created
- [ ] Edit .env file with correct settings:
  - [ ] APP_NAME
  - [ ] APP_URL
  - [ ] DB_DATABASE
  - [ ] DB_USERNAME
  - [ ] DB_PASSWORD
  - [ ] APP_TIMEZONE (Asia/Jakarta)

### 4. Generate Application Key
```bash
php artisan key:generate
```
- [ ] Application key generated
- [ ] Key appears in .env file

### 5. Database Setup
- [ ] Create database in MySQL/PostgreSQL
- [ ] Database name matches .env setting
- [ ] Test database connection

### 6. Run Migrations
```bash
php artisan migrate
```
- [ ] All migrations run successfully
- [ ] 8 tables created:
  - [ ] products
  - [ ] employees
  - [ ] productions
  - [ ] production_employees
  - [ ] expenses
  - [ ] customers
  - [ ] sales
  - [ ] sale_items

### 7. Seed Initial Data (Optional)
```bash
php artisan db:seed --class=InitialDataSeeder
```
- [ ] Seeder run successfully
- [ ] Sample data created:
  - [ ] 3 products
  - [ ] 3 employees
  - [ ] 3 customers

### 8. Set Permissions (Linux/Mac)
```bash
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```
- [ ] Storage permissions set
- [ ] Bootstrap cache permissions set

### 9. Test Application
```bash
php artisan serve
```
- [ ] Server starts successfully
- [ ] Access http://localhost:8000
- [ ] Dashboard loads correctly
- [ ] No errors in browser console

### 10. Test Core Features
- [ ] Can view dashboard
- [ ] Can create product
- [ ] Can create employee
- [ ] Can create production
- [ ] Can create sale
- [ ] Stock updates correctly
- [ ] Invoice generates correctly
- [ ] Reports display correctly

## Post-Installation

### Configuration
- [ ] Set APP_DEBUG=false for production
- [ ] Configure timezone if needed
- [ ] Set up backup schedule
- [ ] Configure mail settings (if needed)

### Optimization (Production)
```bash
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan view:cache
```
- [ ] Autoloader optimized
- [ ] Config cached
- [ ] Routes cached
- [ ] Views cached

### Security
- [ ] Change default database password
- [ ] Set strong APP_KEY
- [ ] Configure firewall (if VPS)
- [ ] Set up SSL certificate (if production)
- [ ] Regular backups configured

### Documentation
- [ ] Read README.md
- [ ] Read QUICK_START.md
- [ ] Bookmark PANDUAN_PENGGUNAAN.md
- [ ] Review FAQ.md

## Troubleshooting

### Common Issues

#### "composer: command not found"
- [ ] Install Composer from https://getcomposer.org

#### "No application encryption key"
- [ ] Run: `php artisan key:generate`

#### Database connection error
- [ ] Check .env database credentials
- [ ] Verify MySQL/PostgreSQL is running
- [ ] Test connection: `mysql -u username -p`

#### Permission denied errors
- [ ] Run: `chmod -R 775 storage bootstrap/cache`
- [ ] Check file ownership

#### 500 Internal Server Error
- [ ] Check storage/logs/laravel.log
- [ ] Set APP_DEBUG=true temporarily
- [ ] Clear cache: `php artisan cache:clear`

#### Blank page
- [ ] Check PHP error log
- [ ] Verify all dependencies installed
- [ ] Check .env configuration

## Verification

### Final Checks
- [ ] All pages load without errors
- [ ] Forms submit successfully
- [ ] Data saves to database
- [ ] Stock calculations work
- [ ] Invoice prints correctly
- [ ] Reports generate correctly
- [ ] No JavaScript errors in console
- [ ] Responsive design works on mobile

### Performance
- [ ] Page load time < 2 seconds
- [ ] Database queries optimized
- [ ] No memory issues
- [ ] Server resources adequate

## Success Criteria

✅ System is ready when:
- All installation steps completed
- All test features working
- No errors in logs
- Documentation reviewed
- Backup configured
- Users trained (if applicable)

## Next Steps

1. [ ] Train users on system usage
2. [ ] Set up regular backup schedule
3. [ ] Monitor system performance
4. [ ] Plan for future enhancements
5. [ ] Document any customizations

---

**Installation Date:** _______________
**Installed By:** _______________
**Version:** 1.0.0
**Status:** ⬜ In Progress  ⬜ Completed  ⬜ Issues

**Notes:**
_________________________________
_________________________________
_________________________________
