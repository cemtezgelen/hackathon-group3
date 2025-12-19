-- =============================================================================
-- Hackathon AI-Document Check - Data Model v2.0
-- Schema: cemtezgelen
-- Purpose: Track 5 - AI Integration for cargo/asset damage and document check
-- Changes: Non-conformities in separate table, Assets (containers/trailers)
-- AI generated code START - 2025-12-19 14:45
-- =============================================================================

-- =============================================================================
-- 1. ORDERS TABLE (Siparişler)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.orders_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.orders (
  seq                  NUMBER,
  ordernumber          VARCHAR2(50 CHAR) NOT NULL,
  customername         VARCHAR2(200 CHAR),
  customercode         VARCHAR2(50 CHAR),
  contactperson        VARCHAR2(200 CHAR),
  contactphone         VARCHAR2(50 CHAR),
  contactemail         VARCHAR2(200 CHAR),
  deliveryaddress      VARCHAR2(500 CHAR),
  deliveryinstructions VARCHAR2(4000 CHAR),
  orderdate            TIMESTAMP(6) WITH LOCAL TIME ZONE,
  requesteddate        TIMESTAMP(6) WITH LOCAL TIME ZONE,
  priority             VARCHAR2(20 CHAR) DEFAULT 'NORMAL', -- LOW, NORMAL, HIGH, URGENT
  status               VARCHAR2(20 CHAR) DEFAULT 'NEW', -- NEW, PROCESSING, COMPLETED, CANCELLED
  totalnumberofassets  NUMBER,
  totalweight          NUMBER,
  notes                VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate           TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser           VARCHAR2(200 CHAR),
  create_timezone      VARCHAR2(50 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser           VARCHAR2(200 CHAR),
  update_timezone      VARCHAR2(50 CHAR),
  provisionerseq       NUMBER,
  CONSTRAINT orders_seq_pk PRIMARY KEY (seq),
  CONSTRAINT orders_ordernumber_uk UNIQUE (ordernumber, provisionerseq),
  CONSTRAINT orders_status_ck CHECK (status IN ('NEW', 'PROCESSING', 'COMPLETED', 'CANCELLED')),
  CONSTRAINT orders_priority_ck CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT'))
);

COMMENT ON TABLE cemtezgelen.orders IS 'Hackathon - Order master data with customer and delivery details';
COMMENT ON COLUMN cemtezgelen.orders.priority IS 'Order priority: LOW, NORMAL, HIGH, URGENT';
COMMENT ON COLUMN cemtezgelen.orders.status IS 'Order status: NEW, PROCESSING, COMPLETED, CANCELLED';

CREATE INDEX cemtezgelen.idx_orders_1 ON cemtezgelen.orders(provisionerseq, status);
CREATE INDEX cemtezgelen.idx_orders_2 ON cemtezgelen.orders(orderdate);
CREATE INDEX cemtezgelen.idx_orders_3 ON cemtezgelen.orders(customercode);
CREATE INDEX cemtezgelen.idx_orders_4 ON cemtezgelen.orders(priority, status);

CREATE OR REPLACE VIEW cemtezgelen.v_orders AS
SELECT * FROM cemtezgelen.orders
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.orders_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.orders
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.orders_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 2. TRIPS TABLE (Sürüşler)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.trips_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.trips (
  seq                  NUMBER,
  orderseq             NUMBER NOT NULL,
  tripnumber           VARCHAR2(50 CHAR) NOT NULL,
  drivername           VARCHAR2(200 CHAR),
  driverphone          VARCHAR2(50 CHAR),
  driveremail          VARCHAR2(200 CHAR),
  vehiclenumber        VARCHAR2(50 CHAR),
  vehicletype          VARCHAR2(50 CHAR),
  tripdate             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  plannedstarttime     TIMESTAMP(6) WITH LOCAL TIME ZONE,
  plannedendtime       TIMESTAMP(6) WITH LOCAL TIME ZONE,
  actualstarttime      TIMESTAMP(6) WITH LOCAL TIME ZONE,
  actualendtime        TIMESTAMP(6) WITH LOCAL TIME ZONE,
  status               VARCHAR2(20 CHAR) DEFAULT 'PLANNED', -- PLANNED, IN_PROGRESS, COMPLETED, CANCELLED
  routeinfo            VARCHAR2(500 CHAR),
  totaldistance        NUMBER,
  estimatedduration    NUMBER, -- minutes
  actualduration       NUMBER, -- minutes
  notes                VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate           TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser           VARCHAR2(200 CHAR),
  create_timezone      VARCHAR2(50 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser           VARCHAR2(200 CHAR),
  update_timezone      VARCHAR2(50 CHAR),
  provisionerseq       NUMBER,
  CONSTRAINT trips_seq_pk PRIMARY KEY (seq),
  CONSTRAINT trips_orderseq_fk FOREIGN KEY (orderseq) REFERENCES cemtezgelen.orders(seq),
  CONSTRAINT trips_tripnumber_uk UNIQUE (tripnumber, provisionerseq),
  CONSTRAINT trips_status_ck CHECK (status IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
);

COMMENT ON TABLE cemtezgelen.trips IS 'Hackathon - Trip assignments with driver and vehicle details';
COMMENT ON COLUMN cemtezgelen.trips.status IS 'Trip status: PLANNED, IN_PROGRESS, COMPLETED, CANCELLED';
COMMENT ON COLUMN cemtezgelen.trips.estimatedduration IS 'Estimated duration in minutes';
COMMENT ON COLUMN cemtezgelen.trips.actualduration IS 'Actual duration in minutes';

CREATE INDEX cemtezgelen.idx_trips_1 ON cemtezgelen.trips(provisionerseq, status);
CREATE INDEX cemtezgelen.idx_trips_2 ON cemtezgelen.trips(orderseq);
CREATE INDEX cemtezgelen.idx_trips_3 ON cemtezgelen.trips(tripdate);
CREATE INDEX cemtezgelen.idx_trips_4 ON cemtezgelen.trips(drivername);

CREATE OR REPLACE VIEW cemtezgelen.v_trips AS
SELECT * FROM cemtezgelen.trips
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.trips_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.trips
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.trips_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 3. STOPS TABLE (Duraklar)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.stops_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.stops (
  seq                  NUMBER,
  tripseq              NUMBER NOT NULL,
  stoporder            NUMBER NOT NULL,
  stoptype             VARCHAR2(20 CHAR) DEFAULT 'DELIVERY', -- PICKUP, DELIVERY, INSPECTION
  address              VARCHAR2(500 CHAR),
  latitude             NUMBER(10,7),
  longitude            NUMBER(10,7),
  contactname          VARCHAR2(200 CHAR),
  contactphone         VARCHAR2(50 CHAR),
  contactemail         VARCHAR2(200 CHAR),
  status               VARCHAR2(20 CHAR) DEFAULT 'PENDING', -- PENDING, ARRIVED, IN_PROGRESS, COMPLETED, SKIPPED
  plannedtime          TIMESTAMP(6) WITH LOCAL TIME ZONE,
  arrivaltime          TIMESTAMP(6) WITH LOCAL TIME ZONE,
  departuretime        TIMESTAMP(6) WITH LOCAL TIME ZONE,
  waitingtime          NUMBER, -- minutes
  specialinstructions  VARCHAR2(4000 CHAR),
  accesscodes          VARCHAR2(200 CHAR),
  notes                VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate           TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser           VARCHAR2(200 CHAR),
  create_timezone      VARCHAR2(50 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser           VARCHAR2(200 CHAR),
  update_timezone      VARCHAR2(50 CHAR),
  provisionerseq       NUMBER,
  CONSTRAINT stops_seq_pk PRIMARY KEY (seq),
  CONSTRAINT stops_tripseq_fk FOREIGN KEY (tripseq) REFERENCES cemtezgelen.trips(seq),
  CONSTRAINT stops_status_ck CHECK (status IN ('PENDING', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED')),
  CONSTRAINT stops_stoptype_ck CHECK (stoptype IN ('PICKUP', 'DELIVERY', 'INSPECTION'))
);

COMMENT ON TABLE cemtezgelen.stops IS 'Hackathon - Delivery/pickup stops with GPS and contact details';
COMMENT ON COLUMN cemtezgelen.stops.stoporder IS 'Sequence number of stop in trip';
COMMENT ON COLUMN cemtezgelen.stops.stoptype IS 'Stop type: PICKUP, DELIVERY, INSPECTION';
COMMENT ON COLUMN cemtezgelen.stops.status IS 'Stop status: PENDING, ARRIVED, IN_PROGRESS, COMPLETED, SKIPPED';
COMMENT ON COLUMN cemtezgelen.stops.waitingtime IS 'Waiting time in minutes';

CREATE INDEX cemtezgelen.idx_stops_1 ON cemtezgelen.stops(provisionerseq, status);
CREATE INDEX cemtezgelen.idx_stops_2 ON cemtezgelen.stops(tripseq, stoporder);
CREATE INDEX cemtezgelen.idx_stops_3 ON cemtezgelen.stops(plannedtime);

CREATE OR REPLACE VIEW cemtezgelen.v_stops AS
SELECT * FROM cemtezgelen.stops
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.stops_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.stops
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.stops_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 4. ASSETS TABLE (Containers & Trailers)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.assets_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.assets (
  seq                  NUMBER,
  orderseq             NUMBER NOT NULL,
  assettype            VARCHAR2(20 CHAR) NOT NULL, -- CONTAINER, TRAILER
  assetnumber          VARCHAR2(50 CHAR) NOT NULL,
  description          VARCHAR2(500 CHAR),
  capacity             NUMBER,
  capacityunit         VARCHAR2(20 CHAR), -- CBM, PALLET, TON
  weight               NUMBER,
  weightunit           VARCHAR2(10 CHAR) DEFAULT 'KG', -- KG, TON, LB
  length               NUMBER,
  width                NUMBER,
  height               NUMBER,
  dimensionunit        VARCHAR2(10 CHAR) DEFAULT 'CM', -- CM, M, INCH
  condition            VARCHAR2(20 CHAR) DEFAULT 'GOOD', -- GOOD, FAIR, DAMAGED, CRITICAL
  temperature          NUMBER,
  temperatureunit      VARCHAR2(10 CHAR), -- C, F
  isrefrigerated       VARCHAR2(1 CHAR) DEFAULT 'N',
  ishazardous          VARCHAR2(1 CHAR) DEFAULT 'N',
  hazardousclass       VARCHAR2(50 CHAR),
  sealnumber           VARCHAR2(50 CHAR),
  barcode              VARCHAR2(100 CHAR),
  rfidtag              VARCHAR2(100 CHAR),
  notes                VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate           TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser           VARCHAR2(200 CHAR),
  create_timezone      VARCHAR2(50 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser           VARCHAR2(200 CHAR),
  update_timezone      VARCHAR2(50 CHAR),
  provisionerseq       NUMBER,
  CONSTRAINT assets_seq_pk PRIMARY KEY (seq),
  CONSTRAINT assets_orderseq_fk FOREIGN KEY (orderseq) REFERENCES cemtezgelen.orders(seq),
  CONSTRAINT assets_assetnumber_uk UNIQUE (assetnumber, orderseq, provisionerseq),
  CONSTRAINT assets_assettype_ck CHECK (assettype IN ('CONTAINER', 'TRAILER')),
  CONSTRAINT assets_condition_ck CHECK (condition IN ('GOOD', 'FAIR', 'DAMAGED', 'CRITICAL')),
  CONSTRAINT assets_isrefrigerated_ck CHECK (isrefrigerated IN ('Y', 'N')),
  CONSTRAINT assets_ishazardous_ck CHECK (ishazardous IN ('Y', 'N'))
);

COMMENT ON TABLE cemtezgelen.assets IS 'Hackathon - Assets (containers and trailers) with detailed specifications';
COMMENT ON COLUMN cemtezgelen.assets.assettype IS 'Asset type: CONTAINER, TRAILER';
COMMENT ON COLUMN cemtezgelen.assets.condition IS 'Asset condition: GOOD, FAIR, DAMAGED, CRITICAL';
COMMENT ON COLUMN cemtezgelen.assets.isrefrigerated IS 'Refrigerated asset flag: Y=Yes, N=No';
COMMENT ON COLUMN cemtezgelen.assets.ishazardous IS 'Contains hazardous materials: Y=Yes, N=No';

CREATE INDEX cemtezgelen.idx_assets_1 ON cemtezgelen.assets(provisionerseq);
CREATE INDEX cemtezgelen.idx_assets_2 ON cemtezgelen.assets(orderseq);
CREATE INDEX cemtezgelen.idx_assets_3 ON cemtezgelen.assets(assettype);
CREATE INDEX cemtezgelen.idx_assets_4 ON cemtezgelen.assets(condition);
CREATE INDEX cemtezgelen.idx_assets_5 ON cemtezgelen.assets(assetnumber);

CREATE OR REPLACE VIEW cemtezgelen.v_assets AS
SELECT * FROM cemtezgelen.assets
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.assets_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.assets
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.assets_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 5. STOP_ASSETS TABLE (Duraklara Atanmış Asset'ler)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.stopassets_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.stopassets (
  seq                    NUMBER,
  stopseq                NUMBER NOT NULL,
  assetseq               NUMBER NOT NULL,
  deliverystatus         VARCHAR2(20 CHAR) DEFAULT 'PENDING', -- PENDING, DELIVERED, REJECTED, PARTIAL
  expectedquantity       NUMBER DEFAULT 1,
  actualquantity         NUMBER,
  inspectionstatus       VARCHAR2(20 CHAR), -- NOT_INSPECTED, PASSED, FAILED, PENDING_REVIEW
  inspectedby            VARCHAR2(200 CHAR),
  inspectiondate         TIMESTAMP(6) WITH LOCAL TIME ZONE,
  inspectionnotes        VARCHAR2(4000 CHAR),
  delivereddate          TIMESTAMP(6) WITH LOCAL TIME ZONE,
  deliveredby            VARCHAR2(200 CHAR),
  recipientname          VARCHAR2(200 CHAR),
  recipientsignature     VARCHAR2(500 CHAR), -- file path
  notes                  VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate             TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser             VARCHAR2(200 CHAR),
  create_timezone        VARCHAR2(10 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser             VARCHAR2(200 CHAR),
  update_timezone        VARCHAR2(10 CHAR),
  provisionerseq         NUMBER,
  CONSTRAINT stopassets_seq_pk PRIMARY KEY (seq),
  CONSTRAINT stopassets_stopseq_fk FOREIGN KEY (stopseq) REFERENCES cemtezgelen.stops(seq),
  CONSTRAINT stopassets_assetseq_fk FOREIGN KEY (assetseq) REFERENCES cemtezgelen.assets(seq),
  CONSTRAINT stopassets_delstatus_ck CHECK (deliverystatus IN ('PENDING', 'DELIVERED', 'REJECTED', 'PARTIAL')),
  CONSTRAINT stopassets_inspstatus_ck CHECK (inspectionstatus IN ('NOT_INSPECTED', 'PASSED', 'FAILED', 'PENDING_REVIEW'))
);

COMMENT ON TABLE cemtezgelen.stopassets IS 'Hackathon - Assets assigned to stops with delivery and inspection status';
COMMENT ON COLUMN cemtezgelen.stopassets.deliverystatus IS 'Delivery status: PENDING, DELIVERED, REJECTED, PARTIAL';
COMMENT ON COLUMN cemtezgelen.stopassets.inspectionstatus IS 'Inspection status: NOT_INSPECTED, PASSED, FAILED, PENDING_REVIEW';

CREATE INDEX cemtezgelen.idx_stopassets_1 ON cemtezgelen.stopassets(provisionerseq, deliverystatus);
CREATE INDEX cemtezgelen.idx_stopassets_2 ON cemtezgelen.stopassets(stopseq);
CREATE INDEX cemtezgelen.idx_stopassets_3 ON cemtezgelen.stopassets(assetseq);
CREATE INDEX cemtezgelen.idx_stopassets_4 ON cemtezgelen.stopassets(inspectionstatus);

CREATE OR REPLACE VIEW cemtezgelen.v_stopassets AS
SELECT * FROM cemtezgelen.stopassets
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.stopassets_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.stopassets
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.stopassets_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 6. NONCONFORMITIES TABLE (Non-Conformity Main Table)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.nonconformities_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.nonconformities (
  seq                    NUMBER,
  stopassetseq           NUMBER NOT NULL,
  nonconformitynumber    VARCHAR2(50 CHAR),
  nonconformitytype      VARCHAR2(50 CHAR) NOT NULL, -- DAMAGED, MISSING, WRONG_QUANTITY, SEAL_BROKEN, TEMPERATURE_ISSUE, CONTAMINATION, OTHER
  severity               VARCHAR2(20 CHAR) DEFAULT 'MEDIUM', -- LOW, MEDIUM, HIGH, CRITICAL
  description            VARCHAR2(4000 CHAR),
  detaileddescription    CLOB,
  damagelocation         VARCHAR2(200 CHAR),
  estimatedloss          NUMBER,
  lossunit               VARCHAR2(20 CHAR), -- EUR, USD, PERCENTAGE
  reportedby             VARCHAR2(200 CHAR),
  reporteddate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  reportedrole           VARCHAR2(50 CHAR), -- DRIVER, INSPECTOR, CUSTOMER, BACKOFFICE
  verifiedby             VARCHAR2(200 CHAR),
  verifieddate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  resolutionstatus       VARCHAR2(20 CHAR) DEFAULT 'OPEN', -- OPEN, IN_REVIEW, RESOLVED, REJECTED, ESCALATED
  resolutiondate         TIMESTAMP(6) WITH LOCAL TIME ZONE,
  resolutionnotes        VARCHAR2(4000 CHAR),
  responsibleparty       VARCHAR2(200 CHAR),
  rootcause              VARCHAR2(4000 CHAR),
  correctiveaction       VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate             TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser             VARCHAR2(200 CHAR),
  create_timezone        VARCHAR2(10 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser             VARCHAR2(200 CHAR),
  update_timezone        VARCHAR2(10 CHAR),
  provisionerseq         NUMBER,
  CONSTRAINT nonconformities_seq_pk PRIMARY KEY (seq),
  CONSTRAINT nonconformities_stopasset_fk FOREIGN KEY (stopassetseq) REFERENCES cemtezgelen.stopassets(seq),
  CONSTRAINT nonconformities_number_uk UNIQUE (nonconformitynumber, provisionerseq),
  CONSTRAINT nonconformities_type_ck CHECK (nonconformitytype IN ('DAMAGED', 'MISSING', 'WRONG_QUANTITY', 'SEAL_BROKEN', 'TEMPERATURE_ISSUE', 'CONTAMINATION', 'OTHER')),
  CONSTRAINT nonconformities_severity_ck CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  CONSTRAINT nonconformities_status_ck CHECK (resolutionstatus IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'REJECTED', 'ESCALATED'))
);

COMMENT ON TABLE cemtezgelen.nonconformities IS 'Hackathon - Main table for all non-conformities with detailed tracking';
COMMENT ON COLUMN cemtezgelen.nonconformities.nonconformitytype IS 'Type: DAMAGED, MISSING, WRONG_QUANTITY, SEAL_BROKEN, TEMPERATURE_ISSUE, CONTAMINATION, OTHER';
COMMENT ON COLUMN cemtezgelen.nonconformities.severity IS 'Severity level: LOW, MEDIUM, HIGH, CRITICAL';
COMMENT ON COLUMN cemtezgelen.nonconformities.resolutionstatus IS 'Resolution status: OPEN, IN_REVIEW, RESOLVED, REJECTED, ESCALATED';

CREATE INDEX cemtezgelen.idx_nonconformities_1 ON cemtezgelen.nonconformities(provisionerseq, resolutionstatus);
CREATE INDEX cemtezgelen.idx_nonconformities_2 ON cemtezgelen.nonconformities(stopassetseq);
CREATE INDEX cemtezgelen.idx_nonconformities_3 ON cemtezgelen.nonconformities(nonconformitytype);
CREATE INDEX cemtezgelen.idx_nonconformities_4 ON cemtezgelen.nonconformities(severity);
CREATE INDEX cemtezgelen.idx_nonconformities_5 ON cemtezgelen.nonconformities(reporteddate);

CREATE OR REPLACE VIEW cemtezgelen.v_nonconformities AS
SELECT * FROM cemtezgelen.nonconformities
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.nonconformities_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.nonconformities
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.nonconformities_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
    
    -- Auto-generate non-conformity number if not provided
    IF :new.nonconformitynumber IS NULL THEN
      :new.nonconformitynumber := 'NC-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' || LPAD(:new.seq, 6, '0');
    END IF;
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 7. DOCUMENTS TABLE (Dökümanlar)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.documents_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.documents (
  seq                  NUMBER,
  stopseq              NUMBER,
  stopassetseq         NUMBER,
  nonconformityseq     NUMBER,
  documenttype         VARCHAR2(50 CHAR), -- PHOTO, SIGNATURE, POD, DAMAGE_PHOTO, INSPECTION_PHOTO, SEAL_PHOTO, CMR, INVOICE, OTHER
  documentcategory     VARCHAR2(50 CHAR), -- DELIVERY, DAMAGE, INSPECTION, ADMINISTRATIVE
  filepath             VARCHAR2(500 CHAR),
  filename             VARCHAR2(200 CHAR),
  filesize             NUMBER, -- bytes
  mimetype             VARCHAR2(100 CHAR),
  uploaddate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  uploadedby           VARCHAR2(200 CHAR),
  description          VARCHAR2(500 CHAR),
  isverified           VARCHAR2(1 CHAR) DEFAULT 'N',
  verifiedby           VARCHAR2(200 CHAR),
  verifieddate         TIMESTAMP(6) WITH LOCAL TIME ZONE,
  verificationstatus   VARCHAR2(20 CHAR), -- NOT_VERIFIED, PASSED, FAILED, PENDING
  aichecked            VARCHAR2(1 CHAR) DEFAULT 'N',
  metadata             CLOB, -- JSON format for additional metadata
  -- Audit columns
  createdate           TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser           VARCHAR2(200 CHAR),
  create_timezone      VARCHAR2(50 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser           VARCHAR2(200 CHAR),
  update_timezone      VARCHAR2(50 CHAR),
  provisionerseq       NUMBER,
  CONSTRAINT documents_seq_pk PRIMARY KEY (seq),
  CONSTRAINT documents_stopseq_fk FOREIGN KEY (stopseq) REFERENCES cemtezgelen.stops(seq),
  CONSTRAINT documents_stopassetseq_fk FOREIGN KEY (stopassetseq) REFERENCES cemtezgelen.stopassets(seq),
  CONSTRAINT documents_nonconformity_fk FOREIGN KEY (nonconformityseq) REFERENCES cemtezgelen.nonconformities(seq),
  CONSTRAINT documents_doctype_ck CHECK (documenttype IN ('PHOTO', 'SIGNATURE', 'POD', 'DAMAGE_PHOTO', 'INSPECTION_PHOTO', 'SEAL_PHOTO', 'CMR', 'INVOICE', 'OTHER')),
  CONSTRAINT documents_doccat_ck CHECK (documentcategory IN ('DELIVERY', 'DAMAGE', 'INSPECTION', 'ADMINISTRATIVE')),
  CONSTRAINT documents_isverified_ck CHECK (isverified IN ('Y', 'N')),
  CONSTRAINT documents_aichecked_ck CHECK (aichecked IN ('Y', 'N')),
  CONSTRAINT documents_verifstatus_ck CHECK (verificationstatus IN ('NOT_VERIFIED', 'PASSED', 'FAILED', 'PENDING')),
  CONSTRAINT documents_parent_ck CHECK (stopseq IS NOT NULL OR stopassetseq IS NOT NULL OR nonconformityseq IS NOT NULL)
);

COMMENT ON TABLE cemtezgelen.documents IS 'Hackathon - Documents/photos with verification and AI check tracking';
COMMENT ON COLUMN cemtezgelen.documents.documenttype IS 'Type: PHOTO, SIGNATURE, POD, DAMAGE_PHOTO, INSPECTION_PHOTO, SEAL_PHOTO, CMR, INVOICE, OTHER';
COMMENT ON COLUMN cemtezgelen.documents.isverified IS 'Verification flag: Y=Yes, N=No';
COMMENT ON COLUMN cemtezgelen.documents.aichecked IS 'AI processed flag: Y=Yes, N=No';

CREATE INDEX cemtezgelen.idx_documents_1 ON cemtezgelen.documents(provisionerseq);
CREATE INDEX cemtezgelen.idx_documents_2 ON cemtezgelen.documents(stopseq);
CREATE INDEX cemtezgelen.idx_documents_3 ON cemtezgelen.documents(stopassetseq);
CREATE INDEX cemtezgelen.idx_documents_4 ON cemtezgelen.documents(nonconformityseq);
CREATE INDEX cemtezgelen.idx_documents_5 ON cemtezgelen.documents(uploaddate);
CREATE INDEX cemtezgelen.idx_documents_6 ON cemtezgelen.documents(documenttype);
CREATE INDEX cemtezgelen.idx_documents_7 ON cemtezgelen.documents(aichecked, verificationstatus);

CREATE OR REPLACE VIEW cemtezgelen.v_documents AS
SELECT * FROM cemtezgelen.documents
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.documents_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.documents
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.documents_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 8. AI_CHECKS TABLE (AI Kontrolleri)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.aichecks_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.aichecks (
  seq                  NUMBER,
  stopseq              NUMBER,
  stopassetseq         NUMBER,
  nonconformityseq     NUMBER,
  documentseq          NUMBER,
  checknumber          VARCHAR2(50 CHAR),
  checktype            VARCHAR2(50 CHAR), -- DOCUMENT_CHECK, NON_CONF_CHECK, DELIVERY_CHECK, SEAL_CHECK, TEMPERATURE_CHECK
  status               VARCHAR2(20 CHAR) DEFAULT 'PENDING', -- PENDING, IN_PROGRESS, PASSED, FAILED, ERROR
  aimodel              VARCHAR2(100 CHAR),
  aimodelversion       VARCHAR2(50 CHAR),
  airesult             CLOB, -- JSON format - AI response details
  confidencescore      NUMBER(5,2), -- 0-100
  detectedissues       VARCHAR2(4000 CHAR),
  recommendations      VARCHAR2(4000 CHAR),
  checkdate            TIMESTAMP(6) WITH LOCAL TIME ZONE,
  completeddate        TIMESTAMP(6) WITH LOCAL TIME ZONE,
  processingtime       NUMBER, -- milliseconds
  retrycount           NUMBER DEFAULT 0,
  lasterrormessage     VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate           TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser           VARCHAR2(200 CHAR),
  create_timezone      VARCHAR2(50 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser           VARCHAR2(200 CHAR),
  update_timezone      VARCHAR2(50 CHAR),
  provisionerseq       NUMBER,
  CONSTRAINT aichecks_seq_pk PRIMARY KEY (seq),
  CONSTRAINT aichecks_stopseq_fk FOREIGN KEY (stopseq) REFERENCES cemtezgelen.stops(seq),
  CONSTRAINT aichecks_stopassetseq_fk FOREIGN KEY (stopassetseq) REFERENCES cemtezgelen.stopassets(seq),
  CONSTRAINT aichecks_nonconformity_fk FOREIGN KEY (nonconformityseq) REFERENCES cemtezgelen.nonconformities(seq),
  CONSTRAINT aichecks_documentseq_fk FOREIGN KEY (documentseq) REFERENCES cemtezgelen.documents(seq),
  CONSTRAINT aichecks_checknumber_uk UNIQUE (checknumber, provisionerseq),
  CONSTRAINT aichecks_checktype_ck CHECK (checktype IN ('DOCUMENT_CHECK', 'NON_CONF_CHECK', 'DELIVERY_CHECK', 'SEAL_CHECK', 'TEMPERATURE_CHECK')),
  CONSTRAINT aichecks_status_ck CHECK (status IN ('PENDING', 'IN_PROGRESS', 'PASSED', 'FAILED', 'ERROR'))
);

COMMENT ON TABLE cemtezgelen.aichecks IS 'Hackathon - AI validation checks with detailed results and performance metrics';
COMMENT ON COLUMN cemtezgelen.aichecks.checktype IS 'Check type: DOCUMENT_CHECK, NON_CONF_CHECK, DELIVERY_CHECK, SEAL_CHECK, TEMPERATURE_CHECK';
COMMENT ON COLUMN cemtezgelen.aichecks.status IS 'Check status: PENDING, IN_PROGRESS, PASSED, FAILED, ERROR';
COMMENT ON COLUMN cemtezgelen.aichecks.processingtime IS 'AI processing time in milliseconds';

CREATE INDEX cemtezgelen.idx_aichecks_1 ON cemtezgelen.aichecks(provisionerseq, status);
CREATE INDEX cemtezgelen.idx_aichecks_2 ON cemtezgelen.aichecks(stopseq);
CREATE INDEX cemtezgelen.idx_aichecks_3 ON cemtezgelen.aichecks(stopassetseq);
CREATE INDEX cemtezgelen.idx_aichecks_4 ON cemtezgelen.aichecks(nonconformityseq);
CREATE INDEX cemtezgelen.idx_aichecks_5 ON cemtezgelen.aichecks(documentseq);
CREATE INDEX cemtezgelen.idx_aichecks_6 ON cemtezgelen.aichecks(checkdate);
CREATE INDEX cemtezgelen.idx_aichecks_7 ON cemtezgelen.aichecks(checktype);

CREATE OR REPLACE VIEW cemtezgelen.v_aichecks AS
SELECT * FROM cemtezgelen.aichecks
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.aichecks_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.aichecks
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.aichecks_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
    
    -- Auto-generate check number if not provided
    IF :new.checknumber IS NULL THEN
      :new.checknumber := 'CHK-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD-HH24MISS') || '-' || LPAD(:new.seq, 6, '0');
    END IF;
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- 9. NOTIFICATIONS TABLE (Bildirimler)
-- =============================================================================
CREATE SEQUENCE cemtezgelen.notifications_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cemtezgelen.notifications (
  seq                  NUMBER,
  aicheckseq           NUMBER,
  nonconformityseq     NUMBER,
  notificationtype     VARCHAR2(20 CHAR), -- WARNING, ERROR, INFO, SUCCESS
  priority             VARCHAR2(20 CHAR) DEFAULT 'NORMAL', -- LOW, NORMAL, HIGH, URGENT
  channel              VARCHAR2(20 CHAR), -- EMAIL, PUSH, SMS, IN_APP
  recipientuser        VARCHAR2(200 CHAR),
  recipientemail       VARCHAR2(200 CHAR),
  recipientphone       VARCHAR2(50 CHAR),
  subject              VARCHAR2(500 CHAR),
  message              VARCHAR2(4000 CHAR),
  messagebody          CLOB,
  isread               VARCHAR2(1 CHAR) DEFAULT 'N',
  readdate             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  sentdate             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  deliverystatus       VARCHAR2(20 CHAR), -- PENDING, SENT, DELIVERED, FAILED, BOUNCED
  deliverydate         TIMESTAMP(6) WITH LOCAL TIME ZONE,
  retrycount           NUMBER DEFAULT 0,
  lasterror            VARCHAR2(4000 CHAR),
  -- Audit columns
  createdate           TIMESTAMP(6) WITH LOCAL TIME ZONE DEFAULT ON NULL CURRENT_TIMESTAMP,
  createuser           VARCHAR2(200 CHAR),
  create_timezone      VARCHAR2(50 CHAR) DEFAULT ON NULL SESSIONTIMEZONE,
  updatedate           TIMESTAMP(6) WITH LOCAL TIME ZONE,
  updateuser           VARCHAR2(200 CHAR),
  update_timezone      VARCHAR2(50 CHAR),
  provisionerseq       NUMBER,
  CONSTRAINT notifications_seq_pk PRIMARY KEY (seq),
  CONSTRAINT notifications_aicheckseq_fk FOREIGN KEY (aicheckseq) REFERENCES cemtezgelen.aichecks(seq),
  CONSTRAINT notifications_nonconf_fk FOREIGN KEY (nonconformityseq) REFERENCES cemtezgelen.nonconformities(seq),
  CONSTRAINT notifications_type_ck CHECK (notificationtype IN ('WARNING', 'ERROR', 'INFO', 'SUCCESS')),
  CONSTRAINT notifications_priority_ck CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
  CONSTRAINT notifications_channel_ck CHECK (channel IN ('EMAIL', 'PUSH', 'SMS', 'IN_APP')),
  CONSTRAINT notifications_isread_ck CHECK (isread IN ('Y', 'N')),
  CONSTRAINT notifications_delstatus_ck CHECK (deliverystatus IN ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED'))
);

COMMENT ON TABLE cemtezgelen.notifications IS 'Hackathon - Notifications with multi-channel delivery tracking';
COMMENT ON COLUMN cemtezgelen.notifications.notificationtype IS 'Type: WARNING, ERROR, INFO, SUCCESS';
COMMENT ON COLUMN cemtezgelen.notifications.priority IS 'Priority: LOW, NORMAL, HIGH, URGENT';
COMMENT ON COLUMN cemtezgelen.notifications.channel IS 'Channel: EMAIL, PUSH, SMS, IN_APP';
COMMENT ON COLUMN cemtezgelen.notifications.deliverystatus IS 'Delivery status: PENDING, SENT, DELIVERED, FAILED, BOUNCED';

CREATE INDEX cemtezgelen.idx_notifications_1 ON cemtezgelen.notifications(provisionerseq, isread);
CREATE INDEX cemtezgelen.idx_notifications_2 ON cemtezgelen.notifications(aicheckseq);
CREATE INDEX cemtezgelen.idx_notifications_3 ON cemtezgelen.notifications(nonconformityseq);
CREATE INDEX cemtezgelen.idx_notifications_4 ON cemtezgelen.notifications(recipientuser, isread);
CREATE INDEX cemtezgelen.idx_notifications_5 ON cemtezgelen.notifications(sentdate);
CREATE INDEX cemtezgelen.idx_notifications_6 ON cemtezgelen.notifications(priority, deliverystatus);

CREATE OR REPLACE VIEW cemtezgelen.v_notifications AS
SELECT * FROM cemtezgelen.notifications
WHERE provisionerseq = NVL(SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'), xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));

CREATE OR REPLACE TRIGGER cemtezgelen.notifications_bir
BEFORE INSERT OR UPDATE ON cemtezgelen.notifications
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :new.seq := NVL(:new.seq, cemtezgelen.notifications_seq.NEXTVAL);
    :new.createuser := NVL(:new.createuser, SYS_CONTEXT('APEX$SESSION', 'APP_USER'));
    :new.createdate := NVL(:new.createdate, CURRENT_TIMESTAMP);
    :new.create_timezone := NVL(:new.create_timezone, SESSIONTIMEZONE);
  END IF;
  
  IF UPDATING THEN
    IF NOT UPDATING('updatedate') THEN
      :new.updatedate := CURRENT_TIMESTAMP;
    END IF;
    IF NOT UPDATING('updateuser') THEN
      :new.updateuser := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
    END IF;
    IF NOT UPDATING('update_timezone') THEN
      :new.update_timezone := SESSIONTIMEZONE;
    END IF;
  END IF;
END;
/

-- =============================================================================
-- AI JSON Format Examples
-- =============================================================================

/*
=============================================================================
AI_CHECKS.airesult JSON Example:
=============================================================================
{
  "check_id": "CHK-20251219-143000-000001",
  "timestamp": "2025-12-19T14:30:00Z",
  "model": "gpt-4-vision-preview",
  "model_version": "1.0",
  "processing_time_ms": 2340,
  "analysis": {
    "document_verified": true,
    "non_conformity_matched": true,
    "detected_damage_type": "DAMAGED",
    "damage_severity": "HIGH",
    "confidence": 89.7,
    "seal_intact": false,
    "temperature_within_range": true
  },
  "findings": [
    {
      "type": "DAMAGE_DETECTED",
      "description": "Container shows significant damage on the front-left corner",
      "location": "Front-left corner, approximately 30cm from bottom",
      "severity": "HIGH",
      "confidence": 92.3,
      "bounding_box": {"x": 145, "y": 230, "width": 180, "height": 150}
    },
    {
      "type": "SEAL_BROKEN",
      "description": "Security seal appears to be tampered with",
      "location": "Container door latch",
      "severity": "CRITICAL",
      "confidence": 95.1
    }
  ],
  "validation": {
    "driver_selection_correct": true,
    "required_documents_present": true,
    "photo_quality": "EXCELLENT",
    "photo_clarity_score": 94.5,
    "lighting_adequate": true,
    "angle_appropriate": true
  },
  "recommendations": [
    "Document appears correct for selected non-conformity type DAMAGED",
    "Photo quality is excellent for detailed inspection",
    "Recommend immediate inspection by supervisor due to HIGH severity",
    "Seal breach requires security investigation"
  ],
  "detected_objects": [
    {"object": "container", "confidence": 99.2, "type": "20ft_standard"},
    {"object": "damage_mark", "confidence": 89.7, "location": "corner"},
    {"object": "security_seal", "confidence": 88.4, "status": "broken"}
  ]
}

=============================================================================
DOCUMENTS.metadata JSON Example:
=============================================================================
{
  "capture_info": {
    "device": "iPhone 14 Pro",
    "os": "iOS 17.2",
    "app_version": "1.0.5",
    "camera": "12MP Wide",
    "gps_enabled": true,
    "timestamp": "2025-12-19T14:28:33Z"
  },
  "location": {
    "latitude": 52.520008,
    "longitude": 13.404954,
    "accuracy_meters": 5.2,
    "address": "Hauptstraße 123, 10115 Berlin, Germany"
  },
  "image_properties": {
    "width": 4032,
    "height": 3024,
    "format": "JPEG",
    "color_space": "sRGB",
    "orientation": "landscape",
    "compression": "85%"
  },
  "exif_data": {
    "focal_length": "6.86mm",
    "f_number": "f/1.78",
    "iso": 160,
    "exposure_time": "1/120",
    "flash": "off"
  }
}
*/

-- =============================================================================
-- Summary
-- =============================================================================
-- Tables: 9
--   1. ORDERS (detailed customer and delivery info)
--   2. TRIPS (detailed driver and vehicle tracking)
--   3. STOPS (GPS coordinates, timing, instructions)
--   4. ASSETS (containers & trailers with full specs)
--   5. STOP_ASSETS (delivery and inspection tracking)
--   6. NONCONFORMITIES (main table for all non-conformities)
--   7. DOCUMENTS (multi-purpose with verification)
--   8. AI_CHECKS (detailed AI analysis with performance metrics)
--   9. NOTIFICATIONS (multi-channel delivery tracking)
--
-- Sequences: 9
-- Views: 9
-- Triggers: 9
-- Indexes: 46
-- 
-- Key Changes from v1.0:
--   - Non-conformities moved to separate main table (NONCONFORMITIES)
--   - GOODS replaced with ASSETS (supports CONTAINER and TRAILER types)
--   - All tables enhanced with detailed columns
--   - Better tracking for inspections, verifications, and AI checks
--   - Multi-channel notification support
--   - Performance metrics for AI processing
--
-- AI generated code END - 2025-12-19 14:45
-- =============================================================================

