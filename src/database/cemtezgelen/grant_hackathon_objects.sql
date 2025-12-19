-- =============================================================================
-- Grant Script for Hackathon Objects
-- Execute this as xxsd_admin or DBA user
-- AI generated code START - 2025-12-19 15:30
-- =============================================================================

-- =============================================================================
-- Grant execute on pkg_error to cemtezgelen schema
-- =============================================================================
GRANT EXECUTE ON xxsd_admin.pkg_error TO cemtezgelen;

-- =============================================================================
-- Grant select on pkg_util functions (if needed)
-- =============================================================================
GRANT EXECUTE ON xxsd_admin.pkg_util TO cemtezgelen;

-- =============================================================================
-- Grant execute on cemtezgelen packages (if APEX needs access)
-- Execute as cemtezgelen user or as DBA:
-- =============================================================================
-- GRANT EXECUTE ON cemtezgelen.pkg_hackathon_demo TO APEX_PUBLIC_USER;
-- GRANT EXECUTE ON cemtezgelen.pkg_hackathon_demo TO your_apex_workspace;

-- =============================================================================
-- Grant select on cemtezgelen views (for APEX application)
-- Execute as cemtezgelen user:
-- =============================================================================
GRANT SELECT ON cemtezgelen.v_orders TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_trips TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_stops TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_assets TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_stopassets TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_nonconformities TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_documents TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_aichecks TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.v_notifications TO APEX_PUBLIC_USER;

-- =============================================================================
-- Grant insert/update on tables (if APEX needs to modify data)
-- Execute as cemtezgelen user:
-- =============================================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.orders TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.trips TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.stops TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.assets TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.stopassets TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.nonconformities TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.documents TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.aichecks TO APEX_PUBLIC_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON cemtezgelen.notifications TO APEX_PUBLIC_USER;

-- =============================================================================
-- Grant execute on sequences (for APEX inserts)
-- Execute as cemtezgelen user:
-- =============================================================================
GRANT SELECT ON cemtezgelen.orders_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.trips_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.stops_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.assets_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.stopassets_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.nonconformities_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.documents_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.aichecks_seq TO APEX_PUBLIC_USER;
GRANT SELECT ON cemtezgelen.notifications_seq TO APEX_PUBLIC_USER;

-- =============================================================================
-- Create synonyms (optional - for easier access from APEX)
-- Execute as cemtezgelen user or in APEX workspace:
-- =============================================================================
/*
CREATE OR REPLACE SYNONYM v_orders FOR cemtezgelen.v_orders;
CREATE OR REPLACE SYNONYM v_trips FOR cemtezgelen.v_trips;
CREATE OR REPLACE SYNONYM v_stops FOR cemtezgelen.v_stops;
CREATE OR REPLACE SYNONYM v_assets FOR cemtezgelen.v_assets;
CREATE OR REPLACE SYNONYM v_stopassets FOR cemtezgelen.v_stopassets;
CREATE OR REPLACE SYNONYM v_nonconformities FOR cemtezgelen.v_nonconformities;
CREATE OR REPLACE SYNONYM v_documents FOR cemtezgelen.v_documents;
CREATE OR REPLACE SYNONYM v_aichecks FOR cemtezgelen.v_aichecks;
CREATE OR REPLACE SYNONYM v_notifications FOR cemtezgelen.v_notifications;

CREATE OR REPLACE SYNONYM pkg_hackathon_demo FOR cemtezgelen.pkg_hackathon_demo;
*/

-- =============================================================================
-- Verify grants
-- =============================================================================
-- SELECT * FROM USER_TAB_PRIVS WHERE TABLE_NAME LIKE '%HACKATHON%' OR TABLE_NAME LIKE 'V_%';
-- SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE = 'PACKAGE' AND OBJECT_NAME = 'PKG_HACKATHON_DEMO';

-- AI generated code END - 2025-12-19 15:30

