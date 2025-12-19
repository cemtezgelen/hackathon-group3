-- =============================================================================
-- Check Trigger Compilation Errors/Warnings
-- AI generated code START - 2025-12-19 15:55
-- =============================================================================

SET LINESIZE 200;
SET PAGESIZE 100;

PROMPT ========================================
PROMPT Trigger Status
PROMPT ========================================

SELECT object_name, 
       object_type, 
       status,
       CASE 
         WHEN status = 'VALID' THEN '✓'
         WHEN status = 'INVALID' THEN '✗'
       END as mark
FROM user_objects
WHERE object_type = 'TRIGGER'
AND object_name LIKE '%_BIR'
ORDER BY object_name;

PROMPT
PROMPT ========================================
PROMPT Compilation Errors/Warnings
PROMPT ========================================

SELECT name,
       type,
       line,
       position,
       text,
       attribute
FROM user_errors
WHERE name LIKE '%_BIR'
ORDER BY name, sequence;

PROMPT
PROMPT ========================================
PROMPT If no errors shown above, warnings are
PROMPT likely non-critical (e.g., PLW-07204)
PROMPT ========================================

-- AI generated code END - 2025-12-19 15:55

