CREATE OR REPLACE PACKAGE BODY cemtezgelen.pkg_hackathon_demo
-- =============================================================================
-- Package Body: pkg_hackathon_demo
-- Purpose: Hackathon demo data generation implementation
-- AI generated code START - 2025-12-19 15:00
-- =============================================================================
AS

  -- =============================================================================
  -- p_reset_demo_data
  -- =============================================================================
  PROCEDURE p_reset_demo_data
  AS
  BEGIN
    -- AI generated code START - 2025-12-19 15:00
    
    -- Delete in reverse order to respect foreign keys
    DELETE FROM cemtezgelen.notifications;
    DELETE FROM cemtezgelen.aichecks;
    DELETE FROM cemtezgelen.documents;
    DELETE FROM cemtezgelen.nonconformities;
    DELETE FROM cemtezgelen.stopassets;
    DELETE FROM cemtezgelen.stops;
    DELETE FROM cemtezgelen.trips;
    DELETE FROM cemtezgelen.assets;
    DELETE FROM cemtezgelen.orders;
    
    COMMIT;
    
    DBMS_OUTPUT.put_line('✓ Demo data reset completed');
    
    -- AI generated code END - 2025-12-19 15:00
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      xxsd_admin.pkg_error.p_logerror(
        'pkg_hackathon_demo.p_reset_demo_data',
        SQLCODE,
        'Error resetting demo data: ' || SQLERRM
      );
      RAISE_APPLICATION_ERROR(-20001, 'Failed to reset demo data: ' || SQLERRM);
  END p_reset_demo_data;

  -- =============================================================================
  -- p_generate_demo_data
  -- =============================================================================
  PROCEDURE p_generate_demo_data(
    p_provisionerseq in number DEFAULT 1
  )
  AS
    v_order_seq        NUMBER;
    v_trip_seq         NUMBER;
    v_stop_seq         NUMBER;
    v_asset_seq        NUMBER;
    v_stopasset_seq    NUMBER;
    v_nonconf_seq      NUMBER;
    v_counter          NUMBER := 0;
  BEGIN
    -- AI generated code START - 2025-12-19 15:00
    
    DBMS_OUTPUT.put_line('========================================');
    DBMS_OUTPUT.put_line('Generating Hackathon Demo Data');
    DBMS_OUTPUT.put_line('========================================');
    
    -- ==========================================================================
    -- SCENARIO 1: Happy Path - Normal Delivery
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 1: Normal Delivery (Happy Path)');
    
    -- Create Order
    INSERT INTO cemtezgelen.orders (
      ordernumber, customername, customercode, contactperson, contactphone,
      contactemail, deliveryaddress, orderdate, requesteddate, priority,
      status, totalnumberofassets, totalweight, provisionerseq
    ) VALUES (
      'ORD-2025-001',
      'Logistics Solutions GmbH',
      'CUST-DE-001',
      'Hans Mueller',
      '+49 40 12345678',
      'hans.mueller@logisticsolutions.de',
      'Hafenstraße 123, 20457 Hamburg, Germany',
      CURRENT_TIMESTAMP - INTERVAL '2' DAY,
      CURRENT_TIMESTAMP,
      'NORMAL',
      'PROCESSING',
      2,
      22000,
      p_provisionerseq
    ) RETURNING seq INTO v_order_seq;
    
    -- Create Assets
    INSERT INTO cemtezgelen.assets (
      orderseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, length, width, height, dimensionunit, condition,
      isrefrigerated, ishazardous, sealnumber, provisionerseq
    ) VALUES (
      v_order_seq, 'CONTAINER', 'MSCU1234567', 'Standard 20ft Container',
      33, 'CBM', 10000, 'KG', 606, 244, 259, 'CM', 'GOOD',
      'N', 'N', 'SEAL-2025-001', p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    INSERT INTO cemtezgelen.assets (
      orderseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, length, width, height, dimensionunit, condition,
      isrefrigerated, ishazardous, sealnumber, provisionerseq
    ) VALUES (
      v_order_seq, 'CONTAINER', 'HLCU9876543', 'Standard 20ft Container',
      33, 'CBM', 12000, 'KG', 606, 244, 259, 'CM', 'GOOD',
      'N', 'N', 'SEAL-2025-002', p_provisionerseq
    );
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      orderseq, tripnumber, drivername, driverphone, driveremail,
      vehiclenumber, vehicletype, tripdate, plannedstarttime, plannedendtime,
      status, estimatedduration, provisionerseq
    ) VALUES (
      v_order_seq, 'TRIP-2025-001', 'Jan van Dijk', '+31 6 12345678',
      'jan.vandijk@transport.nl', 'NL-AB-123', 'Truck 40ft',
      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '8' HOUR,
      'IN_PROGRESS', 480, p_provisionerseq
    ) RETURNING seq INTO v_trip_seq;
    
    -- Create Stops
    -- Stop 1: Pickup at Port of Rotterdam
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
    
    -- Link asset to stop
    INSERT INTO cemtezgelen.stopassets (
      stopseq, assetseq, deliverystatus, expectedquantity, actualquantity,
      inspectionstatus, delivereddate, provisionerseq
    ) VALUES (
      v_stop_seq, v_asset_seq, 'DELIVERED', 1, 1,
      'PASSED', CURRENT_TIMESTAMP - INTERVAL '1' HOUR, p_provisionerseq
    );
    
    -- Stop 2: Delivery at Hamburg
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
    
    DBMS_OUTPUT.put_line('  ✓ Order: ORD-2025-001');
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-001 (Jan van Dijk)');
    DBMS_OUTPUT.put_line('  ✓ Assets: 2 containers');
    DBMS_OUTPUT.put_line('  ✓ Status: Clean delivery, no issues');
    
    -- ==========================================================================
    -- SCENARIO 2: Damaged Container
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 2: Damaged Container');
    
    -- Create Order
    INSERT INTO cemtezgelen.orders (
      ordernumber, customername, customercode, contactperson, contactphone,
      contactemail, deliveryaddress, orderdate, priority,
      status, totalnumberofassets, totalweight, provisionerseq
    ) VALUES (
      'ORD-2025-002',
      'BelgianTrade BVBA',
      'CUST-BE-002',
      'Pierre Dupont',
      '+32 2 1234567',
      'pierre.dupont@belgiantrade.be',
      'Havenstraat 45, 2030 Antwerp, Belgium',
      CURRENT_TIMESTAMP - INTERVAL '1' DAY,
      'HIGH',
      'PROCESSING',
      1,
      15000,
      p_provisionerseq
    ) RETURNING seq INTO v_order_seq;
    
    -- Create Asset (Damaged)
    INSERT INTO cemtezgelen.assets (
      orderseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, length, width, height, dimensionunit, condition,
      isrefrigerated, ishazardous, sealnumber, provisionerseq
    ) VALUES (
      v_order_seq, 'CONTAINER', 'MAEU2345678', 'Standard 40ft Container',
      67, 'CBM', 15000, 'KG', 1219, 244, 259, 'CM', 'DAMAGED',
      'N', 'N', 'SEAL-2025-003', p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      orderseq, tripnumber, drivername, driverphone,
      vehiclenumber, vehicletype, tripdate, plannedstarttime,
      status, provisionerseq
    ) VALUES (
      v_order_seq, 'TRIP-2025-002', 'Marc Janssen', '+32 476 123456',
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
    
    -- Link asset to stop
    INSERT INTO cemtezgelen.stopassets (
      stopseq, assetseq, deliverystatus, expectedquantity, actualquantity,
      inspectionstatus, inspectedby, inspectiondate,
      inspectionnotes, provisionerseq
    ) VALUES (
      v_stop_seq, v_asset_seq, 'DELIVERED', 1, 1,
      'FAILED', 'Marc Janssen', CURRENT_TIMESTAMP - INTERVAL '10' MINUTE,
      'Visible damage on front corner of container', p_provisionerseq
    ) RETURNING seq INTO v_stopasset_seq;
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      stopassetseq, nonconformitytype, severity, description,
      damagelocation, reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_stopasset_seq, 'DAMAGED', 'HIGH',
      'Container front-left corner shows significant impact damage. Dent approximately 30cm wide and 20cm deep.',
      'Front-left corner, 30cm from bottom',
      'Marc Janssen', CURRENT_TIMESTAMP - INTERVAL '10' MINUTE, 'DRIVER',
      'OPEN', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Order: ORD-2025-002');
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-002 (Marc Janssen)');
    DBMS_OUTPUT.put_line('  ✓ Asset: MAEU2345678 (DAMAGED)');
    DBMS_OUTPUT.put_line('  ⚠ Non-conformity: HIGH severity damage detected');
    
    -- ==========================================================================
    -- SCENARIO 3: Seal Broken
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 3: Seal Broken (Security Issue)');
    
    -- Create Order
    INSERT INTO cemtezgelen.orders (
      ordernumber, customername, customercode, contactperson,
      deliveryaddress, orderdate, priority, status,
      totalnumberofassets, totalweight, provisionerseq
    ) VALUES (
      'ORD-2025-003',
      'SecureFreight Ltd',
      'CUST-UK-003',
      'James Smith',
      'Port Road 789, Southampton SO14 3GG, UK',
      CURRENT_TIMESTAMP - INTERVAL '1' DAY,
      'URGENT',
      'PROCESSING',
      1,
      18000,
      p_provisionerseq
    ) RETURNING seq INTO v_order_seq;
    
    -- Create Asset
    INSERT INTO cemtezgelen.assets (
      orderseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, condition, sealnumber, provisionerseq
    ) VALUES (
      v_order_seq, 'CONTAINER', 'CSNU3456789', 'High Security Container',
      67, 'CBM', 18000, 'KG', 'FAIR', 'SEAL-2025-004', p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      orderseq, tripnumber, drivername, vehiclenumber,
      tripdate, status, provisionerseq
    ) VALUES (
      v_order_seq, 'TRIP-2025-003', 'Thomas Brown', 'UK-AB-456',
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
    
    -- Link asset to stop
    INSERT INTO cemtezgelen.stopassets (
      stopseq, assetseq, deliverystatus, inspectionstatus,
      inspectedby, inspectiondate, provisionerseq
    ) VALUES (
      v_stop_seq, v_asset_seq, 'PENDING', 'FAILED',
      'Thomas Brown', CURRENT_TIMESTAMP - INTERVAL '15' MINUTE,
      p_provisionerseq
    ) RETURNING seq INTO v_stopasset_seq;
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      stopassetseq, nonconformitytype, severity, description,
      damagelocation, reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_stopasset_seq, 'SEAL_BROKEN', 'CRITICAL',
      'Security seal SEAL-2025-004 shows signs of tampering. Seal appears to be broken and replaced.',
      'Container door latch',
      'Thomas Brown', CURRENT_TIMESTAMP - INTERVAL '15' MINUTE, 'DRIVER',
      'ESCALATED', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Order: ORD-2025-003');
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-003 (Thomas Brown)');
    DBMS_OUTPUT.put_line('  ✓ Asset: CSNU3456789');
    DBMS_OUTPUT.put_line('  🚨 CRITICAL: Seal broken - Security investigation required');
    
    -- ==========================================================================
    -- SCENARIO 4: Missing Asset
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 4: Missing Asset');
    
    -- Create Order
    INSERT INTO cemtezgelen.orders (
      ordernumber, customername, customercode, contactperson,
      deliveryaddress, orderdate, priority, status,
      totalnumberofassets, totalweight, provisionerseq
    ) VALUES (
      'ORD-2025-004',
      'Nordic Shipping AS',
      'CUST-NO-004',
      'Lars Olsen',
      'Havnegata 12, 0150 Oslo, Norway',
      CURRENT_TIMESTAMP - INTERVAL '3' DAY,
      'HIGH',
      'PROCESSING',
      2,
      20000,
      p_provisionerseq
    ) RETURNING seq INTO v_order_seq;
    
    -- Create Assets
    INSERT INTO cemtezgelen.assets (
      orderseq, assettype, assetnumber, description,
      weight, weightunit, condition, provisionerseq
    ) VALUES (
      v_order_seq, 'TRAILER', 'TRLR-001234', 'Standard Trailer 13.6m',
      8000, 'KG', 'GOOD', p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    INSERT INTO cemtezgelen.assets (
      orderseq, assettype, assetnumber, description,
      weight, weightunit, condition, provisionerseq
    ) VALUES (
      v_order_seq, 'TRAILER', 'TRLR-005678', 'Standard Trailer 13.6m',
      12000, 'KG', 'GOOD', p_provisionerseq
    );
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      orderseq, tripnumber, drivername, vehiclenumber,
      tripdate, status, provisionerseq
    ) VALUES (
      v_order_seq, 'TRIP-2025-004', 'Erik Andersen', 'NO-CD-789',
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
    
    -- Link asset to stop (missing)
    INSERT INTO cemtezgelen.stopassets (
      stopseq, assetseq, deliverystatus, expectedquantity, actualquantity,
      inspectionstatus, inspectedby, inspectiondate,
      inspectionnotes, provisionerseq
    ) VALUES (
      v_stop_seq, v_asset_seq, 'REJECTED', 1, 0,
      'FAILED', 'Erik Andersen', CURRENT_TIMESTAMP - INTERVAL '30' MINUTE,
      'Trailer TRLR-001234 not found at designated location',
      p_provisionerseq
    ) RETURNING seq INTO v_stopasset_seq;
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      stopassetseq, nonconformitytype, severity, description,
      reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_stopasset_seq, 'MISSING', 'HIGH',
      'Trailer TRLR-001234 cannot be located at the designated pickup point. Checked all surrounding areas.',
      'Erik Andersen', CURRENT_TIMESTAMP - INTERVAL '30' MINUTE, 'DRIVER',
      'IN_REVIEW', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Order: ORD-2025-004');
    DBMS_OUTPUT.put_line('  ✓ Trip: TRIP-2025-004 (Erik Andersen)');
    DBMS_OUTPUT.put_line('  ✓ Assets: 2 trailers ordered');
    DBMS_OUTPUT.put_line('  ⚠ Non-conformity: 1 trailer missing at pickup');
    
    -- ==========================================================================
    -- SCENARIO 5: Temperature Issue (Refrigerated)
    -- ==========================================================================
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('📦 Scenario 5: Temperature Issue (Cold Chain)');
    
    -- Create Order
    INSERT INTO cemtezgelen.orders (
      ordernumber, customername, customercode, contactperson,
      deliveryaddress, orderdate, priority, status,
      totalnumberofassets, totalweight, notes, provisionerseq
    ) VALUES (
      'ORD-2025-005',
      'FreshFood International',
      'CUST-FR-005',
      'Marie Dubois',
      'Rue du Port 56, 76600 Le Havre, France',
      CURRENT_TIMESTAMP - INTERVAL '2' DAY,
      'URGENT',
      'PROCESSING',
      1,
      25000,
      'Temperature-sensitive cargo: Must maintain -18°C',
      p_provisionerseq
    ) RETURNING seq INTO v_order_seq;
    
    -- Create Refrigerated Asset
    INSERT INTO cemtezgelen.assets (
      orderseq, assettype, assetnumber, description, capacity, capacityunit,
      weight, weightunit, condition, temperature, temperatureunit,
      isrefrigerated, sealnumber, provisionerseq
    ) VALUES (
      v_order_seq, 'CONTAINER', 'REEFER-567890', '40ft Refrigerated Container',
      67, 'CBM', 25000, 'KG', 'GOOD', -18, 'C',
      'Y', 'SEAL-2025-005', p_provisionerseq
    ) RETURNING seq INTO v_asset_seq;
    
    -- Create Trip
    INSERT INTO cemtezgelen.trips (
      orderseq, tripnumber, drivername, vehiclenumber,
      tripdate, status, provisionerseq
    ) VALUES (
      v_order_seq, 'TRIP-2025-005', 'François Martin', 'FR-EF-123',
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
    
    -- Link asset to stop
    INSERT INTO cemtezgelen.stopassets (
      stopseq, assetseq, deliverystatus, inspectionstatus,
      inspectedby, inspectiondate, inspectionnotes, provisionerseq
    ) VALUES (
      v_stop_seq, v_asset_seq, 'PENDING', 'FAILED',
      'François Martin', CURRENT_TIMESTAMP - INTERVAL '45' MINUTE,
      'Reefer unit temperature alarm: Current temp -8°C (Target: -18°C)',
      p_provisionerseq
    ) RETURNING seq INTO v_stopasset_seq;
    
    -- Create Non-conformity
    INSERT INTO cemtezgelen.nonconformities (
      stopassetseq, nonconformitytype, severity, description,
      detaileddescription, reportedby, reporteddate, reportedrole,
      resolutionstatus, provisionerseq
    ) VALUES (
      v_stopasset_seq, 'TEMPERATURE_ISSUE', 'CRITICAL',
      'Refrigerated container temperature out of acceptable range',
      'Container REEFER-567890 reefer unit showing temperature of -8°C, which is 10°C above required -18°C. ' ||
      'Unit appears to be running but not cooling effectively. Cold chain may be compromised. ' ||
      'Cargo inspection required before acceptance.',
      'François Martin', CURRENT_TIMESTAMP - INTERVAL '45' MINUTE, 'DRIVER',
      'ESCALATED', p_provisionerseq
    );
    
    DBMS_OUTPUT.put_line('  ✓ Order: ORD-2025-005');
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
        'pkg_hackathon_demo.p_generate_demo_data',
        SQLCODE,
        'Error generating demo data: ' || SQLERRM
      );
      RAISE_APPLICATION_ERROR(-20002, 'Failed to generate demo data: ' || SQLERRM);
  END p_generate_demo_data;

  -- =============================================================================
  -- p_print_demo_summary
  -- =============================================================================
  PROCEDURE p_print_demo_summary(
    p_provisionerseq in number DEFAULT 1
  )
  AS
    v_orders_count       NUMBER;
    v_trips_count        NUMBER;
    v_stops_count        NUMBER;
    v_assets_count       NUMBER;
    v_stopassets_count   NUMBER;
    v_nonconf_count      NUMBER;
  BEGIN
    -- AI generated code START - 2025-12-19 15:00
    
    -- Count records
    SELECT COUNT(*) INTO v_orders_count
    FROM cemtezgelen.orders
    WHERE provisionerseq = p_provisionerseq;
    
    SELECT COUNT(*) INTO v_trips_count
    FROM cemtezgelen.trips
    WHERE provisionerseq = p_provisionerseq;
    
    SELECT COUNT(*) INTO v_stops_count
    FROM cemtezgelen.stops
    WHERE provisionerseq = p_provisionerseq;
    
    SELECT COUNT(*) INTO v_assets_count
    FROM cemtezgelen.assets
    WHERE provisionerseq = p_provisionerseq;
    
    SELECT COUNT(*) INTO v_stopassets_count
    FROM cemtezgelen.stopassets
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
    DBMS_OUTPUT.put_line('📋 Orders:          ' || v_orders_count);
    DBMS_OUTPUT.put_line('🚚 Trips:           ' || v_trips_count);
    DBMS_OUTPUT.put_line('📍 Stops:           ' || v_stops_count);
    DBMS_OUTPUT.put_line('📦 Assets:          ' || v_assets_count);
    DBMS_OUTPUT.put_line('🔗 Stop-Assets:     ' || v_stopassets_count);
    DBMS_OUTPUT.put_line('⚠️  Non-conformities: ' || v_nonconf_count);
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('Scenarios:');
    DBMS_OUTPUT.put_line('  1. ORD-2025-001: Normal delivery (Happy path)');
    DBMS_OUTPUT.put_line('  2. ORD-2025-002: Damaged container');
    DBMS_OUTPUT.put_line('  3. ORD-2025-003: Seal broken (Security)');
    DBMS_OUTPUT.put_line('  4. ORD-2025-004: Missing asset');
    DBMS_OUTPUT.put_line('  5. ORD-2025-005: Temperature issue (Cold chain)');
    DBMS_OUTPUT.put_line('========================================');
    
    -- AI generated code END - 2025-12-19 15:00
  EXCEPTION
    WHEN OTHERS THEN
      xxsd_admin.pkg_error.p_logerror(
        'pkg_hackathon_demo.p_print_demo_summary',
        SQLCODE,
        'Error printing demo summary: ' || SQLERRM
      );
      RAISE_APPLICATION_ERROR(-20003, 'Failed to print demo summary: ' || SQLERRM);
  END p_print_demo_summary;

END pkg_hackathon_demo;
/

