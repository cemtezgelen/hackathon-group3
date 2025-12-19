-- =============================================================================
-- Drop ORDERSEQ column from ASSETS table
-- Schema: cemtezgelen
-- AI generated code START - 2025-12-19 16:45
-- =============================================================================

PROMPT =============================================================================
PROMPT Dropping ORDERSEQ column from ASSETS table
PROMPT =============================================================================
PROMPT

BEGIN
  -- Drop unique constraint that references orderseq
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets DROP CONSTRAINT assets_assetnumber_uk';
    DBMS_OUTPUT.put_line('  ✓ Dropped assets_assetnumber_uk constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop foreign key constraint if exists
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets DROP CONSTRAINT assets_orderseq_fk';
    DBMS_OUTPUT.put_line('  ✓ Dropped assets_orderseq_fk constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop index on orderseq if exists
  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX cemtezgelen.idx_assets_2';
    DBMS_OUTPUT.put_line('  ✓ Dropped idx_assets_2 index');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop the column with CASCADE CONSTRAINTS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets DROP COLUMN orderseq CASCADE CONSTRAINTS';
    DBMS_OUTPUT.put_line('  ✓ Dropped orderseq column from assets table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -904 THEN
        RAISE;
      END IF;
  END;
  
  -- Recreate unique constraint without orderseq
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets ADD CONSTRAINT assets_assetnumber_uk 
      UNIQUE (assetnumber, stopseq, provisionerseq)';
    DBMS_OUTPUT.put_line('  ✓ Recreated assets_assetnumber_uk constraint (without orderseq)');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
END;
/

COMMIT;

PROMPT
PROMPT =============================================================================
PROMPT ✓ ORDERSEQ column dropped successfully from ASSETS table
PROMPT =============================================================================

-- AI generated code END - 2025-12-19 16:45

