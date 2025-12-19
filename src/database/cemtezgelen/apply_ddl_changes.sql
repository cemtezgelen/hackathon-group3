-- =============================================================================
-- Apply DDL Changes - Remove ORDERS and STOPASSETS tables
-- Schema: cemtezgelen
-- Purpose: Simplify data model to TRIPS -> STOPS -> ASSETS -> NONCONFORMITIES
-- AI generated code START - 2025-12-19 16:30
-- =============================================================================

PROMPT =============================================================================
PROMPT Applying DDL Changes - Removing ORDERS and STOPASSETS
PROMPT =============================================================================
PROMPT

-- =============================================================================
-- Step 1: Drop existing objects that reference ORDERS and STOPASSETS
-- =============================================================================
PROMPT Step 1: Dropping dependent objects...

BEGIN
  -- Drop foreign key constraints
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.trips DROP CONSTRAINT trips_orderseq_fk';
    DBMS_OUTPUT.put_line('  ✓ Dropped trips.orderseq_fk');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets DROP CONSTRAINT assets_orderseq_fk';
    DBMS_OUTPUT.put_line('  ✓ Dropped assets.orderseq_fk');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.nonconformities DROP CONSTRAINT nonconformities_stopasset_fk';
    DBMS_OUTPUT.put_line('  ✓ Dropped nonconformities.stopasset_fk');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.documents DROP CONSTRAINT documents_stopassetseq_fk';
    DBMS_OUTPUT.put_line('  ✓ Dropped documents.stopassetseq_fk');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.aichecks DROP CONSTRAINT aichecks_stopassetseq_fk';
    DBMS_OUTPUT.put_line('  ✓ Dropped aichecks.stopassetseq_fk');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop views
  BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW cemtezgelen.v_orders';
    DBMS_OUTPUT.put_line('  ✓ Dropped v_orders view');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW cemtezgelen.v_stopassets';
    DBMS_OUTPUT.put_line('  ✓ Dropped v_stopassets view');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop triggers
  BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER cemtezgelen.orders_bir';
    DBMS_OUTPUT.put_line('  ✓ Dropped orders_bir trigger');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER cemtezgelen.stopassets_bir';
    DBMS_OUTPUT.put_line('  ✓ Dropped stopassets_bir trigger');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop indexes
  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX cemtezgelen.idx_trips_2';
    DBMS_OUTPUT.put_line('  ✓ Dropped idx_trips_2');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX cemtezgelen.idx_assets_2';
    DBMS_OUTPUT.put_line('  ✓ Dropped idx_assets_2 (old)');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX cemtezgelen.idx_nonconformities_2';
    DBMS_OUTPUT.put_line('  ✓ Dropped idx_nonconformities_2 (old)');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX cemtezgelen.idx_documents_3';
    DBMS_OUTPUT.put_line('  ✓ Dropped idx_documents_3 (old)');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX cemtezgelen.idx_aichecks_3';
    DBMS_OUTPUT.put_line('  ✓ Dropped idx_aichecks_3 (old)');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop tables
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE cemtezgelen.stopassets CASCADE CONSTRAINTS';
    DBMS_OUTPUT.put_line('  ✓ Dropped stopassets table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE cemtezgelen.orders CASCADE CONSTRAINTS';
    DBMS_OUTPUT.put_line('  ✓ Dropped orders table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  
  -- Drop sequences
  BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE cemtezgelen.stopassets_seq';
    DBMS_OUTPUT.put_line('  ✓ Dropped stopassets_seq');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE cemtezgelen.orders_seq';
    DBMS_OUTPUT.put_line('  ✓ Dropped orders_seq');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
        RAISE;
      END IF;
  END;
  
END;
/

PROMPT
PROMPT Step 2: Modifying existing tables...
PROMPT

-- =============================================================================
-- Step 2: Modify TRIPS table - Remove orderseq column
-- =============================================================================
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.trips DROP COLUMN orderseq';
  DBMS_OUTPUT.put_line('  ✓ Removed orderseq from trips table');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -904 THEN
      RAISE;
    END IF;
END;
/

-- =============================================================================
-- Step 3: Modify ASSETS table - Add stopseq and delivery/inspection columns
-- =============================================================================
BEGIN
  -- Add stopseq column
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets ADD (stopseq NUMBER NOT NULL)';
    DBMS_OUTPUT.put_line('  ✓ Added stopseq to assets table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1435 THEN
        RAISE;
      END IF;
  END;
  
  -- Add delivery and inspection columns
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets ADD (
      deliverystatus VARCHAR2(20 CHAR) DEFAULT ''PENDING'',
      expectedquantity NUMBER DEFAULT 1,
      actualquantity NUMBER,
      inspectionstatus VARCHAR2(20 CHAR),
      inspectedby VARCHAR2(200 CHAR),
      inspectiondate TIMESTAMP(6) WITH LOCAL TIME ZONE,
      inspectionnotes VARCHAR2(4000 CHAR),
      delivereddate TIMESTAMP(6) WITH LOCAL TIME ZONE,
      deliveredby VARCHAR2(200 CHAR),
      recipientname VARCHAR2(200 CHAR),
      recipientsignature VARCHAR2(500 CHAR)
    )';
    DBMS_OUTPUT.put_line('  ✓ Added delivery/inspection columns to assets table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -1435 THEN
        RAISE;
      END IF;
  END;
  
  -- Add foreign key constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets ADD CONSTRAINT assets_stopseq_fk 
      FOREIGN KEY (stopseq) REFERENCES cemtezgelen.stops(seq)';
    DBMS_OUTPUT.put_line('  ✓ Added assets_stopseq_fk constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
  -- Add check constraints
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets ADD CONSTRAINT assets_delstatus_ck 
      CHECK (deliverystatus IN (''PENDING'', ''DELIVERED'', ''REJECTED'', ''PARTIAL''))';
    DBMS_OUTPUT.put_line('  ✓ Added assets_delstatus_ck constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets ADD CONSTRAINT assets_inspstatus_ck 
      CHECK (inspectionstatus IN (''NOT_INSPECTED'', ''PASSED'', ''FAILED'', ''PENDING_REVIEW''))';
    DBMS_OUTPUT.put_line('  ✓ Added assets_inspstatus_ck constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
  -- Modify unique constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets DROP CONSTRAINT assets_assetnumber_uk';
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.assets ADD CONSTRAINT assets_assetnumber_uk 
      UNIQUE (assetnumber, stopseq, provisionerseq)';
    DBMS_OUTPUT.put_line('  ✓ Updated assets_assetnumber_uk constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 AND SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
END;
/

-- =============================================================================
-- Step 4: Modify NONCONFORMITIES table - Change stopassetseq to assetseq
-- =============================================================================
BEGIN
  -- Drop old constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.nonconformities DROP CONSTRAINT nonconformities_stopasset_fk';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  -- Rename column
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.nonconformities RENAME COLUMN stopassetseq TO assetseq';
    DBMS_OUTPUT.put_line('  ✓ Renamed stopassetseq to assetseq in nonconformities table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -904 THEN
        RAISE;
      END IF;
  END;
  
  -- Add new foreign key constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.nonconformities ADD CONSTRAINT nonconformities_assetseq_fk 
      FOREIGN KEY (assetseq) REFERENCES cemtezgelen.assets(seq)';
    DBMS_OUTPUT.put_line('  ✓ Added nonconformities_assetseq_fk constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
END;
/

-- =============================================================================
-- Step 5: Modify DOCUMENTS table - Change stopassetseq to assetseq
-- =============================================================================
BEGIN
  -- Drop old constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.documents DROP CONSTRAINT documents_stopassetseq_fk';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  -- Rename column
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.documents RENAME COLUMN stopassetseq TO assetseq';
    DBMS_OUTPUT.put_line('  ✓ Renamed stopassetseq to assetseq in documents table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -904 THEN
        RAISE;
      END IF;
  END;
  
  -- Add new foreign key constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.documents ADD CONSTRAINT documents_assetseq_fk 
      FOREIGN KEY (assetseq) REFERENCES cemtezgelen.assets(seq)';
    DBMS_OUTPUT.put_line('  ✓ Added documents_assetseq_fk constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
  -- Update check constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.documents DROP CONSTRAINT documents_parent_ck';
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.documents ADD CONSTRAINT documents_parent_ck 
      CHECK (stopseq IS NOT NULL OR assetseq IS NOT NULL OR nonconformityseq IS NOT NULL)';
    DBMS_OUTPUT.put_line('  ✓ Updated documents_parent_ck constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 AND SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
END;
/

-- =============================================================================
-- Step 6: Modify AI_CHECKS table - Change stopassetseq to assetseq
-- =============================================================================
BEGIN
  -- Drop old constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.aichecks DROP CONSTRAINT aichecks_stopassetseq_fk';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2443 THEN
        RAISE;
      END IF;
  END;
  
  -- Rename column
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.aichecks RENAME COLUMN stopassetseq TO assetseq';
    DBMS_OUTPUT.put_line('  ✓ Renamed stopassetseq to assetseq in aichecks table');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -904 THEN
        RAISE;
      END IF;
  END;
  
  -- Add new foreign key constraint
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cemtezgelen.aichecks ADD CONSTRAINT aichecks_assetseq_fk 
      FOREIGN KEY (assetseq) REFERENCES cemtezgelen.assets(seq)';
    DBMS_OUTPUT.put_line('  ✓ Added aichecks_assetseq_fk constraint');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -2260 THEN
        RAISE;
      END IF;
  END;
  
END;
/

-- =============================================================================
-- Step 7: Create new indexes
-- =============================================================================
PROMPT
PROMPT Step 3: Creating new indexes...
PROMPT

BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cemtezgelen.idx_assets_2 ON cemtezgelen.assets(stopseq)';
    DBMS_OUTPUT.put_line('  ✓ Created idx_assets_2 on stopseq');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cemtezgelen.idx_assets_6 ON cemtezgelen.assets(deliverystatus)';
    DBMS_OUTPUT.put_line('  ✓ Created idx_assets_6 on deliverystatus');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cemtezgelen.idx_assets_7 ON cemtezgelen.assets(inspectionstatus)';
    DBMS_OUTPUT.put_line('  ✓ Created idx_assets_7 on inspectionstatus');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cemtezgelen.idx_nonconformities_2 ON cemtezgelen.nonconformities(assetseq)';
    DBMS_OUTPUT.put_line('  ✓ Created idx_nonconformities_2 on assetseq');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cemtezgelen.idx_documents_3 ON cemtezgelen.documents(assetseq)';
    DBMS_OUTPUT.put_line('  ✓ Created idx_documents_3 on assetseq');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955 THEN
        RAISE;
      END IF;
  END;
  
  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cemtezgelen.idx_aichecks_3 ON cemtezgelen.aichecks(assetseq)';
    DBMS_OUTPUT.put_line('  ✓ Created idx_aichecks_3 on assetseq');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -955 THEN
        RAISE;
      END IF;
  END;
  
END;
/

-- =============================================================================
-- Step 8: Update comments
-- =============================================================================
PROMPT
PROMPT Step 4: Updating table comments...
PROMPT

BEGIN
  EXECUTE IMMEDIATE 'COMMENT ON TABLE cemtezgelen.assets IS ''Hackathon - Assets (containers and trailers) with detailed specifications and delivery tracking''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN cemtezgelen.assets.deliverystatus IS ''Delivery status: PENDING, DELIVERED, REJECTED, PARTIAL''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN cemtezgelen.assets.inspectionstatus IS ''Inspection status: NOT_INSPECTED, PASSED, FAILED, PENDING_REVIEW''';
  DBMS_OUTPUT.put_line('  ✓ Updated assets table comments');
END;
/

COMMIT;

PROMPT
PROMPT =============================================================================
PROMPT ✓ DDL Changes Applied Successfully!
PROMPT =============================================================================
PROMPT
PROMPT New Data Model: TRIPS -> STOPS -> ASSETS -> NONCONFORMITIES
PROMPT
PROMPT Changes:
PROMPT   - Removed ORDERS table
PROMPT   - Removed STOPASSETS table
PROMPT   - ASSETS now directly linked to STOPS
PROMPT   - NONCONFORMITIES linked to ASSETS (not STOPASSETS)
PROMPT   - All foreign keys and indexes updated
PROMPT
PROMPT Next step: Run the updated DDL script to recreate all objects
PROMPT =============================================================================

-- AI generated code END - 2025-12-19 16:30

