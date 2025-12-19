CREATE OR REPLACE PACKAGE BODY cemtezgelen.pkg_hackathon_demo
-- =============================================================================
-- Package Body: pkg_hackathon_demo
-- Purpose: Hackathon demo data generation implementation
-- AI generated code START - 2025-12-19 16:30
-- =============================================================================
AS

  -- =============================================================================
  -- p_reset_demo_data
  -- =============================================================================
  PROCEDURE p_reset_demo_data
  AS
  BEGIN
    -- AI generated code START - 2025-12-19 16:30
    
    -- Delete in reverse order to respect foreign keys
    DELETE FROM cemtezgelen.notifications;
    DELETE FROM cemtezgelen.aichecks;
    DELETE FROM cemtezgelen.documents;
    DELETE FROM cemtezgelen.nonconformities;
    DELETE FROM cemtezgelen.assets;
    DELETE FROM cemtezgelen.stops;
    DELETE FROM cemtezgelen.trips;
    
    COMMIT;
    
    DBMS_OUTPUT.put_line('✓ Demo data reset completed');
    
    -- AI generated code END - 2025-12-19 15:00
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      xxsd_admin.pkg_error.p_logerror(
        p_module        => 'pkg_hackathon_demo.p_reset_demo_data',
        p_errorCode     => TO_CHAR(SQLCODE),
        p_errorMessage  => 'Error resetting demo data: ' || SQLERRM
      );
      RAISE_APPLICATION_ERROR(-20001, 'Failed to reset demo data: ' || SQLERRM);
  END p_reset_demo_data;

  -- =============================================================================
  -- p_generate_demo_data
  -- =============================================================================
  PROCEDURE p_generate_demo_data(
    p_provisionerseq in number
  )
  AS
    v_trip_seq         NUMBER;
    v_stop_seq         NUMBER;
    v_asset_seq        NUMBER;
    v_nonconf_seq      NUMBER;
    v_counter          NUMBER := 0;
  BEGIN
    -- AI generated code START - 2025-12-19 16:30
    
    DBMS_OUTPUT.put_line('========================================');
    DBMS_OUTPUT.put_line('Generating Hackathon Demo Data');
    DBMS_OUTPUT.put_line('========================================');
    
    -- ==========================================================================
    -- SCENARIO 1: Happy Path - Normal Delivery
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 1: Normal Delivery (Happy Path)');
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      tripnumber, drivername, driverphone, driveremail,
      vehiclenumber, vehicletype, tripdate, plannedstarttime, plannedendtime,
      status, estimatedduration, provisionerseq
    ) VALUES (
      'TRIP-2025-001', 'Jan van Dijk', '+31 6 12345678',
      'jan.vandijk@transport.nl', 'NL-AB-123', 'Truck 40ft',
      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '8' HOUR,
      'IN_PROGRESS', 480, p_provisionerseq
    ) RETURNING seq INTO v_trip_seq;
    
    -- Create Stop 1: Pickup at Port of Rotterdam
    INSERT INTO cemtezgelen.stops (
      tripseq, stoporder, stoptype, address, latitude, longitude,
      contactname, contactphone, status, plannedtime,
      arrivaltime, departuretime, provisionerseq
    ) VALUES (
      v_trip_seq, 1, 'PICKUP', 'Europoort, 3198 LD Rotterdam, Netherlands',
      51.9225, 4.4792, 'Port Manager', '+31 10 1234567',
      'COMPLETED', CURRENT_TIMESTAMP - INTERVAL '2' HOUR,
      CURRENT_TIMESTAMP - INTERVAL '2' HOUR, CURRENT_TIMESTAMP - INTERVAL '1' HOUR,
      p_provisionerseq
    ) RETURNING seq INTO v_stop_seq;
    
    -- Create Asset 1 (linked to stop)
    INSERT INTO cemtezgelen.assets (
      stopseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, length, width, height, dimensionunit, condition,
      isrefrigerated, ishazardous, sealnumber, deliverystatus,
      expectedquantity, actualquantity, inspectionstatus, delivereddate,
      provisionerseq
    ) VALUES (
      v_stop_seq, 'CONTAINER', 'MSCU1234567', 'Standard 20ft Container',
      33, 'CBM', 10000, 'KG', 606, 244, 259, 'CM', 'GOOD',
      'N', 'N', 'SEAL-2025-001', 'DELIVERED',
      1, 1, 'PASSED', CURRENT_TIMESTAMP - INTERVAL '1' HOUR,
      p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Asset 2 (same stop)
    INSERT INTO cemtezgelen.assets (
      stopseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, length, width, height, dimensionunit, condition,
      isrefrigerated, ishazardous, sealnumber, deliverystatus,
      expectedquantity, actualquantity, inspectionstatus, delivereddate,
      provisionerseq
    ) VALUES (
      v_stop_seq, 'CONTAINER', 'HLCU9876543', 'Standard 20ft Container',
      33, 'CBM', 12000, 'KG', 606, 244, 259, 'CM', 'GOOD',
      'N', 'N', 'SEAL-2025-002', 'DELIVERED',
      1, 1, 'PASSED', CURRENT_TIMESTAMP - INTERVAL '1' HOUR,
      p_provisionerseq
    );
    
    -- Create Stop 2: Delivery at Hamburg
    INSERT INTO cemtezgelen.stops (
      tripseq, stoporder, stoptype, address, latitude, longitude,
      contactname, contactphone, status, plannedtime,
      provisionerseq
    ) VALUES (
      v_trip_seq, 2, 'DELIVERY', 'Hafenstraße 123, 20457 Hamburg, Germany',
      53.5511, 9.9937, 'Hans Mueller', '+49 40 12345678',
      'PENDING', CURRENT_TIMESTAMP + INTERVAL '4' HOUR,
      p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-001 (Jan van Dijk)');
    DBMS_OUTPUT.put_line('  ✓ Assets: 2 containers');
    DBMS_OUTPUT.put_line('  ✓ Status: Clean delivery, no issues');
    
    -- ==========================================================================
    -- SCENARIO 2: Damaged Container
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 2: Damaged Container');
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      tripnumber, drivername, driverphone,
      vehiclenumber, vehicletype, tripdate, plannedstarttime,
      status, provisionerseq
    ) VALUES (
      'TRIP-2025-002', 'Marc Janssen', '+32 476 123456',
      'BE-XY-789', 'Truck 40ft', CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP - INTERVAL '1' HOUR, 'IN_PROGRESS', p_provisionerseq
    ) RETURNING seq INTO v_trip_seq;
    
    -- Create Stop (Delivery with damage)
    INSERT INTO cemtezgelen.stops (
      tripseq, stoporder, stoptype, address, latitude, longitude,
      contactname, contactphone, status, plannedtime, arrivaltime,
      provisionerseq
    ) VALUES (
      v_trip_seq, 1, 'DELIVERY', 'Havenstraat 45, 2030 Antwerp, Belgium',
      51.2194, 4.4025, 'Pierre Dupont', '+32 2 1234567',
      'IN_PROGRESS', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP - INTERVAL '30' MINUTE,
      p_provisionerseq
    ) RETURNING seq INTO v_stop_seq;
    
    -- Create Asset (Damaged, linked to stop)
    INSERT INTO cemtezgelen.assets (
      stopseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, length, width, height, dimensionunit, condition,
      isrefrigerated, ishazardous, sealnumber, deliverystatus,
      expectedquantity, actualquantity, inspectionstatus, inspectedby,
      inspectiondate, inspectionnotes, delivereddate,
      provisionerseq
    ) VALUES (
      v_stop_seq, 'CONTAINER', 'MAEU2345678', 'Standard 40ft Container',
      67, 'CBM', 15000, 'KG', 1219, 244, 259, 'CM', 'DAMAGED',
      'N', 'N', 'SEAL-2025-003', 'DELIVERED',
      1, 1, 'FAILED', 'Marc Janssen',
      CURRENT_TIMESTAMP - INTERVAL '10' MINUTE,
      'Visible damage on front corner of container',
      CURRENT_TIMESTAMP - INTERVAL '10' MINUTE,
      p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      assetseq, nonconformitytype, severity, description,
      damagelocation, reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_asset_seq, 'DAMAGED', 'HIGH',
      'Container front-left corner shows significant impact damage. Dent approximately 30cm wide and 20cm deep.',
      'Front-left corner, 30cm from bottom',
      'Marc Janssen', CURRENT_TIMESTAMP - INTERVAL '10' MINUTE, 'DRIVER',
      'OPEN', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-002 (Marc Janssen)');
    DBMS_OUTPUT.put_line('  ✓ Asset: MAEU2345678 (DAMAGED)');
    DBMS_OUTPUT.put_line('  ⚠ Non-conformity: HIGH severity damage detected');
    
    -- ==========================================================================
    -- SCENARIO 3: Seal Broken
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 3: Seal Broken (Security Issue)');
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      tripnumber, drivername, vehiclenumber,
      tripdate, status, provisionerseq
    ) VALUES (
      'TRIP-2025-003', 'Thomas Brown', 'UK-AB-456',
      CURRENT_TIMESTAMP, 'IN_PROGRESS', p_provisionerseq
    ) RETURNING seq INTO v_trip_seq;
    
    -- Create Stop
    INSERT INTO cemtezgelen.stops (
      tripseq, stoporder, stoptype, address, latitude, longitude,
      status, arrivaltime, provisionerseq
    ) VALUES (
      v_trip_seq, 1, 'INSPECTION', 'Port Road 789, Southampton SO14 3GG, UK',
      50.9097, -1.4044, 'IN_PROGRESS',
      CURRENT_TIMESTAMP - INTERVAL '20' MINUTE, p_provisionerseq
    ) RETURNING seq INTO v_stop_seq;
    
    -- Create Asset (linked to stop)
    INSERT INTO cemtezgelen.assets (
      stopseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, condition, sealnumber, deliverystatus,
      inspectionstatus, inspectedby, inspectiondate,
      provisionerseq
    ) VALUES (
      v_stop_seq, 'CONTAINER', 'CSNU3456789', 'High Security Container',
      67, 'CBM', 18000, 'KG', 'FAIR', 'SEAL-2025-004', 'PENDING',
      'FAILED', 'Thomas Brown', CURRENT_TIMESTAMP - INTERVAL '15' MINUTE,
      p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      assetseq, nonconformitytype, severity, description,
      damagelocation, reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_asset_seq, 'SEAL_BROKEN', 'CRITICAL',
      'Security seal SEAL-2025-004 shows signs of tampering. Seal appears to be broken and replaced.',
      'Container door latch',
      'Thomas Brown', CURRENT_TIMESTAMP - INTERVAL '15' MINUTE, 'DRIVER',
      'ESCALATED', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-003 (Thomas Brown)');
    DBMS_OUTPUT.put_line('  ✓ Asset: CSNU3456789');
    DBMS_OUTPUT.put_line('  🚨 CRITICAL: Seal broken - Security investigation required');
    
    -- ==========================================================================
    -- SCENARIO 4: Missing Asset
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 4: Missing Asset');
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      tripnumber, drivername, vehiclenumber,
      tripdate, status, provisionerseq
    ) VALUES (
      'TRIP-2025-004', 'Erik Andersen', 'NO-CD-789',
      CURRENT_TIMESTAMP, 'IN_PROGRESS', p_provisionerseq
    ) RETURNING seq INTO v_trip_seq;
    
    -- Create Stop
    INSERT INTO cemtezgelen.stops (
      tripseq, stoporder, stoptype, address, latitude, longitude,
      status, arrivaltime, provisionerseq
    ) VALUES (
      v_trip_seq, 1, 'PICKUP', 'Havnegata 12, 0150 Oslo, Norway',
      59.9139, 10.7522, 'IN_PROGRESS',
      CURRENT_TIMESTAMP - INTERVAL '45' MINUTE, p_provisionerseq
    ) RETURNING seq INTO v_stop_seq;
    
    -- Create Asset 1 (missing)
    INSERT INTO cemtezgelen.assets (
      stopseq, assettype, assetnumber, description,
      weight, weightunit, condition, deliverystatus,
      expectedquantity, actualquantity, inspectionstatus,
      inspectedby, inspectiondate, inspectionnotes,
      provisionerseq
    ) VALUES (
      v_stop_seq, 'TRAILER', 'TRLR-001234', 'Standard Trailer 13.6m',
      8000, 'KG', 'GOOD', 'REJECTED',
      1, 0, 'FAILED',
      'Erik Andersen', CURRENT_TIMESTAMP - INTERVAL '30' MINUTE,
      'Trailer TRLR-001234 not found at designated location',
      p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Asset 2 (found)
    INSERT INTO cemtezgelen.assets (
      stopseq, assettype, assetnumber, description,
      weight, weightunit, condition, deliverystatus,
      expectedquantity, actualquantity, inspectionstatus,
      provisionerseq
    ) VALUES (
      v_stop_seq, 'TRAILER', 'TRLR-005678', 'Standard Trailer 13.6m',
      12000, 'KG', 'GOOD', 'DELIVERED',
      1, 1, 'PASSED',
      p_provisionerseq
    );
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      assetseq, nonconformitytype, severity, description,
      reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_asset_seq, 'MISSING', 'HIGH',
      'Trailer TRLR-001234 cannot be located at the designated pickup point. Checked all surrounding areas.',
      'Erik Andersen', CURRENT_TIMESTAMP - INTERVAL '30' MINUTE, 'DRIVER',
      'IN_REVIEW', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-004 (Erik Andersen)');
    DBMS_OUTPUT.put_line('  ✓ Assets: 2 trailers ordered');
    DBMS_OUTPUT.put_line('  ⚠ Non-conformity: 1 trailer missing at pickup');
    
    -- ==========================================================================
    -- SCENARIO 5: Temperature Issue (Refrigerated)
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 5: Temperature Issue (Cold Chain)');
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      tripnumber, drivername, vehiclenumber,
      tripdate, status, provisionerseq
    ) VALUES (
      'TRIP-2025-005', 'François Martin', 'FR-EF-123',
      CURRENT_TIMESTAMP, 'IN_PROGRESS', p_provisionerseq
    ) RETURNING seq INTO v_trip_seq;
    
    -- Create Stop
    INSERT INTO cemtezgelen.stops (
      tripseq, stoporder, stoptype, address, latitude, longitude,
      status, arrivaltime, specialinstructions, provisionerseq
    ) VALUES (
      v_trip_seq, 1, 'DELIVERY', 'Rue du Port 56, 76600 Le Havre, France',
      49.4944, 0.1079, 'IN_PROGRESS',
      CURRENT_TIMESTAMP - INTERVAL '1' HOUR,
      'Temperature-sensitive: Check reefer unit immediately upon arrival',
      p_provisionerseq
    ) RETURNING seq INTO v_stop_seq;
    
    -- Create Refrigerated Asset (linked to stop)
    INSERT INTO cemtezgelen.assets (
      stopseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, condition, temperature, temperatureunit,
      isrefrigerated, sealnumber, deliverystatus, inspectionstatus,
      inspectedby, inspectiondate, inspectionnotes,
      provisionerseq
    ) VALUES (
      v_stop_seq, 'CONTAINER', 'REEFER-567890', '40ft Refrigerated Container',
      67, 'CBM', 25000, 'KG', 'GOOD', -18, 'C',
      'Y', 'SEAL-2025-005', 'PENDING', 'FAILED',
      'François Martin', CURRENT_TIMESTAMP - INTERVAL '45' MINUTE,
      'Reefer unit temperature alarm: Current temp -8°C (Target: -18°C)',
      p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      assetseq, nonconformitytype, severity, description,
      detaileddescription, reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_asset_seq, 'TEMPERATURE_ISSUE', 'CRITICAL',
      'Refrigerated container temperature out of acceptable range',
      'Container REEFER-567890 reefer unit showing temperature of -8°C, which is 10°C above required -18°C. ' ||
      'Unit appears to be running but not cooling effectively. Cold chain may be compromised. ' ||
      'Cargo inspection required before acceptance.',
      'François Martin', CURRENT_TIMESTAMP - INTERVAL '45' MINUTE, 'DRIVER',
      'ESCALATED', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-005 (François Martin)');
    DBMS_OUTPUT.put_line('  ✓ Asset: REEFER-567890 (Refrigerated)');
    DBMS_OUTPUT.put_line('  🚨 CRITICAL: Temperature out of range (-8°C vs -18°C target)');
    
    COMMIT;
    
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('========================================');
    DBMS_OUTPUT.put_line('✓ Demo Data Generation Complete');
    DBMS_OUTPUT.put_line('========================================');
    
    -- AI generated code END - 2025-12-19 15:00
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      xxsd_admin.pkg_error.p_logerror(
        p_module        => 'pkg_hackathon_demo.p_generate_demo_data',
        p_errorCode     => TO_CHAR(SQLCODE),
        p_errorMessage  => 'Error generating demo data: ' || SQLERRM
      );
      RAISE_APPLICATION_ERROR(-20002, 'Failed to generate demo data: ' || SQLERRM);
  END p_generate_demo_data;

  -- =============================================================================
  -- p_print_demo_summary
  -- =============================================================================
  PROCEDURE p_print_demo_summary(
    p_provisionerseq in number
  )
  AS
    v_trips_count        NUMBER;
    v_stops_count        NUMBER;
    v_assets_count       NUMBER;
    v_nonconf_count      NUMBER;
  BEGIN
    -- AI generated code START - 2025-12-19 16:30
    
    -- Count records
    SELECT COUNT(*) INTO v_trips_count
    FROM cemtezgelen.trips
    WHERE provisionerseq = p_provisionerseq;
    
    SELECT COUNT(*) INTO v_stops_count
    FROM cemtezgelen.stops
    WHERE provisionerseq = p_provisionerseq;
    
    SELECT COUNT(*) INTO v_assets_count
    FROM cemtezgelen.assets
    WHERE provisionerseq = p_provisionerseq;
    
    SELECT COUNT(*) INTO v_nonconf_count
    FROM cemtezgelen.nonconformities
    WHERE provisionerseq = p_provisionerseq;
    
    -- Print summary
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('========================================');
    DBMS_OUTPUT.put_line('Demo Data Summary');
    DBMS_OUTPUT.put_line('========================================');
    DBMS_OUTPUT.put_line('ProvisionerSeq: ' || p_provisionerseq);
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('🚚 Trips:           ' || v_trips_count);
    DBMS_OUTPUT.put_line('📍 Stops:           ' || v_stops_count);
    DBMS_OUTPUT.put_line('📦 Assets:          ' || v_assets_count);
    DBMS_OUTPUT.put_line('⚠️  Non-conformities: ' || v_nonconf_count);
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('Scenarios:');
    DBMS_OUTPUT.put_line('  1. TRIP-2025-001: Normal delivery (Happy path)');
    DBMS_OUTPUT.put_line('  2. TRIP-2025-002: Damaged container');
    DBMS_OUTPUT.put_line('  3. TRIP-2025-003: Seal broken (Security)');
    DBMS_OUTPUT.put_line('  4. TRIP-2025-004: Missing asset');
    DBMS_OUTPUT.put_line('  5. TRIP-2025-005: Temperature issue (Cold chain)');
    DBMS_OUTPUT.put_line('========================================');
    
    -- AI generated code END - 2025-12-19 15:00
  EXCEPTION
    WHEN OTHERS THEN
      xxsd_admin.pkg_error.p_logerror(
        p_module        => 'pkg_hackathon_demo.p_print_demo_summary',
        p_errorCode     => TO_CHAR(SQLCODE),
        p_errorMessage  => 'Error printing demo summary: ' || SQLERRM
      );
      RAISE_APPLICATION_ERROR(-20003, 'Failed to print demo summary: ' || SQLERRM);
  END p_print_demo_summary;

END pkg_hackathon_demo;
/

