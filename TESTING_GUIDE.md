# Testing Guide

## Manual Testing Checklist

### 1. Dashboard Testing

#### Test Cases:
- [ ] Dashboard loads successfully
- [ ] Statistics cards display correct data
- [ ] Production count shows current month data
- [ ] Sales amount shows current month data
- [ ] Expense amount shows current month data
- [ ] Net profit calculation is correct (Sales - Expenses)
- [ ] Recent productions list shows latest 5 entries
- [ ] Recent sales list shows latest 5 entries
- [ ] Low stock alert appears for products with stock < 50
- [ ] All navigation links work correctly

### 2. Product Management Testing

#### Test Cases:
- [ ] Product list page loads
- [ ] Can create new product
- [ ] Product name is required
- [ ] Price must be numeric and positive
- [ ] Can edit existing product
- [ ] Can delete product (with confirmation)
- [ ] Stock displays correctly
- [ ] Stock color indicator works (red < 50, green >= 50)
- [ ] Pagination works if more than 10 products
- [ ] Search functionality works (if implemented)

#### Test Data:
```
Name: Abon Test
Description: Test product
Price: 45000
Unit: bungkus
```

### 3. Production Testing

#### Test Cases:
- [ ] Production list page loads
- [ ] Can create new production
- [ ] Product selection works
- [ ] Date picker works
- [ ] Quantity must be positive integer
- [ ] Type selection (Rutin/Pesanan) works
- [ ] Employee selection (multiple) works
- [ ] At least 1 employee must be selected
- [ ] Stock increases after production created
- [ ] Can view production details
- [ ] Employee list shows in detail page
- [ ] Can delete production
- [ ] Stock decreases after production deleted

#### Test Data:
```
Product: Abon Sapi Original
Date: Today
Quantity: 50
Type: Rutin
Employees: Select 2 employees
```

### 4. Expense Testing

#### Test Cases:
- [ ] Expense list page loads
- [ ] Can create new expense
- [ ] Date picker works
- [ ] Category field accepts text
- [ ] Amount must be numeric and positive
- [ ] Production link is optional
- [ ] Can edit expense
- [ ] Can delete expense
- [ ] Total expense calculation is correct

#### Test Data:
```
Date: Today
Category: Bahan Baku
Amount: 500000
Description: Daging sapi 5 kg
```

### 5. Sales Testing

#### Test Cases:
- [ ] Sales list page loads
- [ ] Can create new sale
- [ ] Date picker works
- [ ] Type selection (Ecer/Pesanan) works
- [ ] Customer selection is optional
- [ ] Can add multiple items
- [ ] Product dropdown shows available products
- [ ] Quantity validation works
- [ ] Price auto-fills from product
- [ ] Can manually change price
- [ ] Subtotal calculates correctly
- [ ] Total amount calculates correctly
- [ ] Can remove item
- [ ] Stock decreases after sale created
- [ ] Invoice number auto-generates (INV-YYYYMMDD-XXXX)
- [ ] Can view sale details
- [ ] Can print invoice
- [ ] Invoice displays correctly
- [ ] Can delete sale
- [ ] Stock increases after sale deleted

#### Test Data:
```
Date: Today
Type: Ecer
Customer: (leave empty for "Umum")
Items:
  - Product: Abon Sapi Original
    Quantity: 10
    Price: 50000
```

### 6. Customer Testing

#### Test Cases:
- [ ] Customer list page loads
- [ ] Can create new customer
- [ ] Name is required
- [ ] Phone and address are optional
- [ ] Can edit customer
- [ ] Can delete customer
- [ ] Customer appears in sales dropdown

#### Test Data:
```
Name: Toko Test
Phone: 081234567890
Address: Jl. Test No. 123
```

### 7. Employee Testing

#### Test Cases:
- [ ] Employee list page loads
- [ ] Can create new employee
- [ ] Name is required
- [ ] Production rate must be numeric
- [ ] Packing rate must be numeric
- [ ] Active status checkbox works
- [ ] Can edit employee
- [ ] Can delete employee
- [ ] Employee appears in production form
- [ ] Only active employees show in production form

#### Test Data:
```
Name: Karyawan Test
Phone: 081234567890
Address: Jl. Test No. 123
Production Rate: 500
Packing Rate: 200
Active: Yes
```

### 8. Salary Testing

#### Test Cases:
- [ ] Salary page loads
- [ ] Date range filter works
- [ ] Production count calculates correctly
- [ ] Production salary = production count × rate
- [ ] Packing count = total sales quantity
- [ ] Packing salary = packing count × rate
- [ ] Total salary = production salary + packing salary
- [ ] Grand total calculates correctly
- [ ] Only active employees appear

#### Test Scenario:
1. Create production with 100 units, assign Employee A
2. Create sale with 50 units
3. Check salary page
4. Verify Employee A has:
   - Production: 100 units
   - Production Salary: 100 × 500 = 50,000
   - Packing: 50 units
   - Packing Salary: 50 × 200 = 10,000
   - Total: 60,000

### 9. Reports Testing

#### Test Cases:
- [ ] Reports index page loads
- [ ] Date range filter works
- [ ] Summary cards show correct totals
- [ ] Production summary by product is correct
- [ ] Sales summary by product is correct
- [ ] Expense summary by category is correct
- [ ] Net profit calculation is correct
- [ ] Production detail report loads
- [ ] Sales detail report loads
- [ ] Expense detail report loads
- [ ] All data matches selected period

### 10. Invoice Testing

#### Test Cases:
- [ ] Invoice opens in new tab
- [ ] Invoice number displays correctly
- [ ] Date displays correctly
- [ ] Customer information displays (if selected)
- [ ] Item table displays correctly
- [ ] Quantities and prices are correct
- [ ] Total amount is correct
- [ ] Print button works
- [ ] Close button works
- [ ] Invoice is print-friendly (no sidebar/header)

## Automated Testing

### Setup PHPUnit
```bash
composer require --dev phpunit/phpunit
```

### Run Tests
```bash
php artisan test
```

### Example Test Cases

#### ProductTest.php
```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_product()
    {
        $response = $this->post('/products', [
            'name' => 'Test Product',
            'price' => 50000,
            'unit' => 'bungkus'
        ]);

        $response->assertRedirect('/products');
        $this->assertDatabaseHas('products', [
            'name' => 'Test Product'
        ]);
    }

    public function test_product_name_is_required()
    {
        $response = $this->post('/products', [
            'price' => 50000,
            'unit' => 'bungkus'
        ]);

        $response->assertSessionHasErrors('name');
    }
}
```

## Performance Testing

### Load Testing with Apache Bench
```bash
# Test dashboard
ab -n 1000 -c 10 http://localhost:8000/

# Test product list
ab -n 1000 -c 10 http://localhost:8000/products
```

### Expected Results:
- Response time < 200ms for most pages
- No errors under normal load
- Database queries optimized (< 10 queries per page)

## Security Testing

### Test Cases:
- [ ] CSRF protection works on all forms
- [ ] SQL injection prevention (try: `' OR '1'='1`)
- [ ] XSS prevention (try: `<script>alert('XSS')</script>`)
- [ ] File upload validation (if implemented)
- [ ] Proper error messages (no sensitive data exposed)
- [ ] Session security
- [ ] Password hashing (if auth implemented)

## Browser Compatibility Testing

### Browsers to Test:
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Chrome
- [ ] Mobile Safari

### Test Points:
- [ ] Layout displays correctly
- [ ] Forms work properly
- [ ] JavaScript functions work
- [ ] Print functionality works
- [ ] Responsive design works on mobile

## Database Testing

### Test Cases:
- [ ] Migrations run successfully
- [ ] Seeders work correctly
- [ ] Foreign keys enforce relationships
- [ ] Cascade delete works
- [ ] Stock updates are atomic
- [ ] No orphaned records after delete

### Test Commands:
```bash
# Fresh migration
php artisan migrate:fresh

# With seeder
php artisan migrate:fresh --seed

# Rollback
php artisan migrate:rollback
```

## API Testing

### Test with cURL:
```bash
# Get dashboard stats
curl http://localhost:8000/api/v1/dashboard/stats

# Get products
curl http://localhost:8000/api/v1/products

# Check stock
curl http://localhost:8000/api/v1/products/1/stock
```

### Expected Responses:
- Status code 200 for successful requests
- Valid JSON format
- Correct data structure
- Proper error handling (404, 422, 500)

## Regression Testing

After any code changes, test:
- [ ] All CRUD operations still work
- [ ] Stock calculations are correct
- [ ] Invoice generation works
- [ ] Salary calculations are accurate
- [ ] Reports show correct data
- [ ] No broken links
- [ ] No JavaScript errors in console

## User Acceptance Testing (UAT)

### Scenario 1: Daily Operations
1. Record morning production
2. Record expenses
3. Record afternoon sales
4. Check dashboard for daily summary
5. Print invoice for customer

### Scenario 2: Monthly Closing
1. Set date range for the month
2. Review production report
3. Review sales report
4. Review expense report
5. Calculate employee salaries
6. Verify net profit

### Scenario 3: Stock Management
1. Check current stock levels
2. Identify low stock items
3. Plan production based on stock
4. Record production
5. Verify stock increased

## Bug Reporting Template

```
Title: [Brief description]

Steps to Reproduce:
1. Go to...
2. Click on...
3. Enter...
4. See error

Expected Result:
[What should happen]

Actual Result:
[What actually happened]

Environment:
- Browser: Chrome 120
- OS: Windows 11
- PHP Version: 8.1
- Laravel Version: 10.x

Screenshots:
[Attach if applicable]

Additional Notes:
[Any other relevant information]
```

## Test Data Cleanup

After testing, clean up test data:
```bash
# Reset database
php artisan migrate:fresh --seed

# Or manually delete test records
# through the application interface
```