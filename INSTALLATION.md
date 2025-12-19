# Installation Guide - Hackathon AI Document Check

## 📋 Prerequisites

- Oracle 19c database
- Oracle APEX 24.1.6
- Access to `xxsd_admin` schema (for error logging)
- Access to `cemtezgelen` schema (for hackathon objects)

## 🚀 Installation Steps

### Step 1: Execute as DBA or xxsd_admin

Grant necessary permissions to `cemtezgelen` schema:

```sql
-- Connect as xxsd_admin or DBA
GRANT EXECUTE ON xxsd_admin.pkg_error TO cemtezgelen;
GRANT EXECUTE ON xxsd_admin.pkg_util TO cemtezgelen;
```

### Step 2: Execute as cemtezgelen user

Create all database objects:

```sql
-- Connect as cemtezgelen
CONN cemtezgelen/password@database

-- 1. Create tables, views, sequences, triggers
@src/database/cemtezgelen/hackathon_ai_check_ddl.sql

-- 2. Create demo package
@src/database/cemtezgelen/pkg_hackathon_demo.pks
@src/database/cemtezgelen/pkg_hackathon_demo.pkb

-- 3. Grant permissions for APEX
@src/database/cemtezgelen/grant_hackathon_objects.sql
```

### Step 3: Generate Demo Data

```sql
-- Enable output
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Reset any existing demo data
EXEC cemtezgelen.pkg_hackathon_demo.p_reset_demo_data;

-- Generate fresh demo data
EXEC cemtezgelen.pkg_hackathon_demo.p_generate_demo_data(p_provisionerseq => 1);

-- View summary
EXEC cemtezgelen.pkg_hackathon_demo.p_print_demo_summary(p_provisionerseq => 1);
```

### Step 4: Verify Installation

Check that all objects are created:

```sql
-- Check tables
SELECT table_name 
FROM user_tables 
WHERE table_name IN (
  'ORDERS', 'TRIPS', 'STOPS', 'ASSETS', 'STOPASSETS',
  'NONCONFORMITIES', 'DOCUMENTS', 'AICHECKS', 'NOTIFICATIONS'
)
ORDER BY table_name;

-- Check views
SELECT view_name 
FROM user_views 
WHERE view_name LIKE 'V_%'
ORDER BY view_name;

-- Check sequences
SELECT sequence_name 
FROM user_sequences 
WHERE sequence_name LIKE '%_SEQ'
ORDER BY sequence_name;

-- Check packages
SELECT object_name, object_type, status
FROM user_objects 
WHERE object_name = 'PKG_HACKATHON_DEMO';

-- Check data counts
SELECT 
  (SELECT COUNT(*) FROM cemtezgelen.orders) as orders,
  (SELECT COUNT(*) FROM cemtezgelen.trips) as trips,
  (SELECT COUNT(*) FROM cemtezgelen.stops) as stops,
  (SELECT COUNT(*) FROM cemtezgelen.assets) as assets,
  (SELECT COUNT(*) FROM cemtezgelen.nonconformities) as nonconformities
FROM dual;
```

Expected results:
- 9 tables
- 9 views
- 9 sequences
- 1 package (VALID status)
- Data: 5 orders, 5 trips, 7 stops, 7 assets, 4 non-conformities

## 🔧 Troubleshooting

### Error: ORA-00942: table or view does not exist

**Solution:** Make sure you're connected as `cemtezgelen` user when creating objects.

```sql
SHOW USER;
-- Should return: USER is "CEMTEZGELEN"
```

### Error: PLS-00201: identifier must be declared

**Solution:** Grant execute permissions from xxsd_admin:

```sql
-- Connect as xxsd_admin or DBA
GRANT EXECUTE ON xxsd_admin.pkg_error TO cemtezgelen;
GRANT EXECUTE ON xxsd_admin.pkg_util TO cemtezgelen;
```

### Error: ORA-04043: object does not exist

**Solution:** Check schema name and object name:

```sql
-- List all objects
SELECT object_name, object_type, status
FROM user_objects
ORDER BY object_type, object_name;
```

### Package compilation errors

**Solution:** Check compilation errors:

```sql
-- Show compilation errors
SHOW ERRORS PACKAGE cemtezgelen.pkg_hackathon_demo;
SHOW ERRORS PACKAGE BODY cemtezgelen.pkg_hackathon_demo;

-- Or query error details
SELECT line, position, text
FROM user_errors
WHERE name = 'PKG_HACKATHON_DEMO'
ORDER BY sequence;
```

### APEX cannot access objects

**Solution:** Grant proper permissions and create synonyms:

```sql
-- As cemtezgelen user
GRANT EXECUTE ON cemtezgelen.pkg_hackathon_demo TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_orders TO APEX_PUBLIC_USER;
-- ... (see grant_hackathon_objects.sql for all grants)

-- Create synonyms in APEX parsing schema
CREATE OR REPLACE SYNONYM v_orders FOR cemtezgelen.v_orders;
-- ... (see grant_hackathon_objects.sql for all synonyms)
```

## 🎨 Configure APEX Application

### Import Application
1. Login to APEX workspace
2. Go to App Builder
3. Import `hackathon_ai_check.sql` (when available)
4. Set Application ID: 135

### Configure Parsing Schema
1. Go to Application → Edit Application Definition
2. Set Parsing Schema: `CEMTEZGELEN`
3. Save changes

### Set PROVISIONERSEQ
Add application item:
1. Go to Shared Components → Application Items
2. Create item: `PROVISIONERSEQ`
3. Set Session State Protection: Unrestricted
4. Set default value: `1` (for demo)

### Test Connection
Create test page with query:

```sql
SELECT ordernumber, customername, status
FROM cemtezgelen.v_orders;
```

## 📝 Quick Commands Reference

```sql
-- One-liner installation (as cemtezgelen)
@src/database/cemtezgelen/hackathon_ai_check_ddl.sql
@src/database/cemtezgelen/pkg_hackathon_demo.pks
@src/database/cemtezgelen/pkg_hackathon_demo.pkb

-- Quick demo data generation
SET SERVEROUTPUT ON SIZE UNLIMITED;
EXEC cemtezgelen.pkg_hackathon_demo.p_reset_demo_data;
EXEC cemtezgelen.pkg_hackathon_demo.p_generate_demo_data(1);
EXEC cemtezgelen.pkg_hackathon_demo.p_print_demo_summary(1);

-- Or use the all-in-one script
@src/database/cemtezgelen/demo_data_usage.sql
```

## 🆘 Support

For issues or questions:
- Check GitHub repository: https://github.com/cemtezgelen/hackathon-group3
- Review README.md for detailed scenarios
- Check demo_data_usage.sql for query examples

---

**Last Updated:** 2025-12-19
**Version:** 1.0

