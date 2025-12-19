-- =============================================================================
-- Fix timezone column size - Increase from VARCHAR2(10 CHAR) to VARCHAR2(50 CHAR)
-- Problem: SESSIONTIMEZONE can return values like 'Europe/Istanbul' (15 chars)
-- Solution: Increase all create_timezone and update_timezone columns to 50 chars
-- AI generated code START - 2025-12-19 15:45
-- =============================================================================

-- =============================================================================
-- 1. ORDERS
-- =============================================================================
ALTER TABLE cemtezgelen.orders MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 2. TRIPS
-- =============================================================================
ALTER TABLE cemtezgelen.trips MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 3. STOPS
-- =============================================================================
ALTER TABLE cemtezgelen.stops MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 4. ASSETS
-- =============================================================================
ALTER TABLE cemtezgelen.assets MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 5. STOPASSETS
-- =============================================================================
ALTER TABLE cemtezgelen.stopassets MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 6. NONCONFORMITIES
-- =============================================================================
ALTER TABLE cemtezgelen.nonconformities MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 7. DOCUMENTS
-- =============================================================================
ALTER TABLE cemtezgelen.documents MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 8. AICHECKS
-- =============================================================================
ALTER TABLE cemtezgelen.aichecks MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- 9. NOTIFICATIONS
-- =============================================================================
ALTER TABLE cemtezgelen.notifications MODIFY (
  create_timezone  VARCHAR2(50 CHAR),
  update_timezone  VARCHAR2(50 CHAR)
);

-- =============================================================================
-- Verification
-- =============================================================================
SELECT table_name, 
       column_name, 
       data_type || '(' || data_length || ' ' || char_used || ')' as column_type
FROM user_tab_columns
WHERE table_name IN (
  'ORDERS', 'TRIPS', 'STOPS', 'ASSETS', 'STOPASSETS',
  'NONCONFORMITIES', 'DOCUMENTS', 'AICHECKS', 'NOTIFICATIONS'
)
AND column_name LIKE '%_TIMEZONE'
ORDER BY table_name, column_name;

PROMPT
PROMPT ✓ All timezone columns updated to VARCHAR2(50 CHAR)
PROMPT

-- AI generated code END - 2025-12-19 15:45

