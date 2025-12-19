-- =============================================================================
-- Recompile All Triggers After Schema Changes
-- AI generated code START - 2025-12-19 15:50
-- =============================================================================

-- Recompile all triggers
ALTER TRIGGER cemtezgelen.orders_bir COMPILE;
ALTER TRIGGER cemtezgelen.trips_bir COMPILE;
ALTER TRIGGER cemtezgelen.stops_bir COMPILE;
ALTER TRIGGER cemtezgelen.assets_bir COMPILE;
ALTER TRIGGER cemtezgelen.stopassets_bir COMPILE;
ALTER TRIGGER cemtezgelen.nonconformities_bir COMPILE;
ALTER TRIGGER cemtezgelen.documents_bir COMPILE;
ALTER TRIGGER cemtezgelen.aichecks_bir COMPILE;
ALTER TRIGGER cemtezgelen.notifications_bir COMPILE;

-- Verification
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type = 'TRIGGER'
AND object_name LIKE '%_BIR'
ORDER BY object_name;

PROMPT
PROMPT ✓ All triggers recompiled
PROMPT

-- AI generated code END - 2025-12-19 15:50

