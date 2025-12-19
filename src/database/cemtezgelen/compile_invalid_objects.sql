-- =============================================================================
-- Compile All Invalid Objects
-- Automatically recompile all invalid triggers, packages, views, etc.
-- AI generated code START - 2025-12-19 15:50
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
  v_count NUMBER := 0;
BEGIN
  DBMS_OUTPUT.put_line('========================================');
  DBMS_OUTPUT.put_line('Compiling Invalid Objects');
  DBMS_OUTPUT.put_line('========================================');
  
  -- Show invalid objects before compilation
  FOR rec IN (
    SELECT object_type, object_name, status
    FROM user_objects
    WHERE status = 'INVALID'
    ORDER BY object_type, object_name
  ) LOOP
    DBMS_OUTPUT.put_line('Invalid: ' || rec.object_type || ' - ' || rec.object_name);
    v_count := v_count + 1;
  END LOOP;
  
  IF v_count = 0 THEN
    DBMS_OUTPUT.put_line('No invalid objects found.');
  ELSE
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('Found ' || v_count || ' invalid objects. Compiling...');
    DBMS_OUTPUT.put_line('');
    
    -- Compile all invalid objects using Oracle utility
    DBMS_UTILITY.compile_schema(
      schema         => USER,
      compile_all    => FALSE,  -- Only invalid objects
      reuse_settings => TRUE
    );
    
    DBMS_OUTPUT.put_line('✓ Compilation complete');
    DBMS_OUTPUT.put_line('');
  END IF;
  
  -- Show status after compilation
  v_count := 0;
  DBMS_OUTPUT.put_line('========================================');
  DBMS_OUTPUT.put_line('Final Status');
  DBMS_OUTPUT.put_line('========================================');
  
  FOR rec IN (
    SELECT object_type, COUNT(*) as obj_count,
           SUM(CASE WHEN status = 'VALID' THEN 1 ELSE 0 END) as valid_count,
           SUM(CASE WHEN status = 'INVALID' THEN 1 ELSE 0 END) as invalid_count
    FROM user_objects
    WHERE object_type IN ('TRIGGER', 'PACKAGE', 'PACKAGE BODY', 'VIEW', 'PROCEDURE', 'FUNCTION')
    GROUP BY object_type
    ORDER BY object_type
  ) LOOP
    DBMS_OUTPUT.put_line(
      RPAD(rec.object_type, 15) || ': ' || 
      rec.valid_count || ' valid, ' || 
      rec.invalid_count || ' invalid'
    );
    v_count := v_count + rec.invalid_count;
  END LOOP;
  
  DBMS_OUTPUT.put_line('========================================');
  
  IF v_count > 0 THEN
    DBMS_OUTPUT.put_line('⚠ Warning: ' || v_count || ' objects still invalid');
    DBMS_OUTPUT.put_line('Check errors with: SHOW ERRORS');
  ELSE
    DBMS_OUTPUT.put_line('✓ All objects are valid');
  END IF;
  
END;
/

-- List any remaining invalid objects with errors
PROMPT
PROMPT Remaining Invalid Objects (if any):
PROMPT

SELECT object_type, object_name, status
FROM user_objects
WHERE status = 'INVALID'
ORDER BY object_type, object_name;

-- AI generated code END - 2025-12-19 15:50

