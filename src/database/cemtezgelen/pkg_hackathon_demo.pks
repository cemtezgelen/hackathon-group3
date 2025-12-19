CREATE OR REPLACE PACKAGE cemtezgelen.pkg_hackathon_demo
-- =============================================================================
-- Package: pkg_hackathon_demo
-- Purpose: Hackathon demo data generation
-- Description: Creates sample orders, trips, stops, assets for AI Document Check demo
-- AI generated code START - 2025-12-19 15:00
-- =============================================================================
AS

  -- =============================================================================
  -- p_reset_demo_data
  -- Purpose: Delete all demo data (in reverse order to respect foreign keys)
  -- =============================================================================
  PROCEDURE p_reset_demo_data;

  -- =============================================================================
  -- p_generate_demo_data
  -- Purpose: Generate complete demo dataset with multiple scenarios
  -- Parameters:
  --   p_provisionerseq in number - Customer identifier
  -- Scenarios:
  --   1. Happy Path - Normal delivery
  --   2. Damaged Container - With damage photos
  --   3. Seal Broken - Security issue
  --   4. Missing Asset - Asset not found at pickup
  --   5. Temperature Issue - Refrigerated container problem
  -- =============================================================================
  PROCEDURE p_generate_demo_data(
    p_provisionerseq in number DEFAULT 1
  );

  -- =============================================================================
  -- p_print_demo_summary
  -- Purpose: Print summary of generated demo data
  -- Parameters:
  --   p_provisionerseq in number - Customer identifier
  -- =============================================================================
  PROCEDURE p_print_demo_summary(
    p_provisionerseq in number DEFAULT 1
  );

END pkg_hackathon_demo;
/

