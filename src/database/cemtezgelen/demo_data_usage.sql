-- =============================================================================
-- Demo Data Generation - Usage Examples
-- =============================================================================
-- AI generated code START - 2025-12-19 15:00

-- Enable DBMS_OUTPUT to see progress messages
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- =============================================================================
-- Option 1: Reset and Generate Fresh Demo Data
-- =============================================================================
EXEC cemtezgelen.pkg_hackathon_demo.p_reset_demo_data;
EXEC cemtezgelen.pkg_hackathon_demo.p_generate_demo_data(p_provisionerseq => 1);
EXEC cemtezgelen.pkg_hackathon_demo.p_print_demo_summary(p_provisionerseq => 1);

-- =============================================================================
-- Option 2: Generate Demo Data for Different Provisioner
-- =============================================================================
-- EXEC cemtezgelen.pkg_hackathon_demo.p_generate_demo_data(p_provisionerseq => 2);
-- EXEC cemtezgelen.pkg_hackathon_demo.p_print_demo_summary(p_provisionerseq => 2);

-- =============================================================================
-- Verification Queries
-- =============================================================================

-- View all orders
SELECT ordernumber, 
       customername, 
       status, 
       totalnumberofassets,
       totalweight
FROM cemtezgelen.v_orders
ORDER BY orderdate DESC;

-- View trips with driver info
SELECT t.tripnumber,
       o.ordernumber,
       t.drivername,
       t.vehiclenumber,
       t.status,
       COUNT(s.seq) as stop_count
FROM cemtezgelen.v_trips t
JOIN cemtezgelen.v_orders o ON o.seq = t.orderseq
LEFT JOIN cemtezgelen.v_stops s ON s.tripseq = t.seq
GROUP BY t.tripnumber, o.ordernumber, t.drivername, t.vehiclenumber, t.status
ORDER BY t.tripdate DESC;

-- View assets by type
SELECT assettype,
       COUNT(*) as count,
       SUM(weight) as total_weight_kg
FROM cemtezgelen.v_assets
GROUP BY assettype;

-- View non-conformities by severity
SELECT nc.nonconformitytype,
       nc.severity,
       nc.description,
       nc.reportedby,
       nc.resolutionstatus,
       o.ordernumber
FROM cemtezgelen.v_nonconformities nc
JOIN cemtezgelen.v_stopassets sa ON sa.seq = nc.stopassetseq
JOIN cemtezgelen.v_stops s ON s.seq = sa.stopseq
JOIN cemtezgelen.v_trips t ON t.seq = s.tripseq
JOIN cemtezgelen.v_orders o ON o.seq = t.orderseq
ORDER BY nc.severity DESC, nc.reporteddate DESC;

-- View detailed stop information
SELECT s.stoporder,
       s.stoptype,
       s.address,
       s.status,
       sa.deliverystatus,
       sa.inspectionstatus,
       a.assetnumber,
       a.assettype
FROM cemtezgelen.v_stops s
JOIN cemtezgelen.v_stopassets sa ON sa.stopseq = s.seq
JOIN cemtezgelen.v_assets a ON a.seq = sa.assetseq
ORDER BY s.seq, s.stoporder;

-- AI generated code END - 2025-12-19 15:00

