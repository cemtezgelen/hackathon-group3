# Backoffice APEX Application - Concept Document

**Version:** 1.0  
**Date:** 2025-12-19  
**Project:** Hackathon Group 3 - AI Document Check  
**Application Type:** Desktop Web Application (Oracle APEX 24.1.6)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Core Features](#core-features)
3. [User Interface Design](#user-interface-design)
4. [Master-Child Relationships](#master-child-relationships)
5. [Non-Conformity Highlighting](#non-conformity-highlighting)
6. [AI Status Integration](#ai-status-integration)
7. [Order Status Dashboard](#order-status-dashboard)
8. [Technical Implementation](#technical-implementation)
9. [User Workflows](#user-workflows)
10. [Performance Considerations](#performance-considerations)

---

## 🎯 Overview

### Purpose
The Backoffice APEX application provides comprehensive order management, real-time monitoring, and non-conformity processing capabilities for logistics operations. It serves as the central command center for backoffice staff to monitor driver activities, review AI-validated non-conformities, and manage order lifecycles.

### Target Users
- **Backoffice Managers** - Order oversight and decision-making
- **Quality Control Staff** - Non-conformity review and resolution
- **Operations Coordinators** - Real-time monitoring and escalation
- **Customer Service** - Order status inquiries and updates

### Key Value Propositions
- ✅ Real-time visibility into all orders and their statuses
- ✅ AI-powered non-conformity detection and validation
- ✅ Master-child data visualization for complex relationships
- ✅ Automated highlighting of problematic orders
- ✅ Comprehensive order status tracking and reporting

---

## 🎨 Core Features

### 1. Master-Child Table Visualization

#### 1.1 Order → Trip → Stop → Asset Hierarchy

**Visual Structure:**
```
📦 ORDER (ORD-2025-001)
  └── 🚛 TRIP (TRP-2025-001)
      ├── 📍 STOP 1: Pickup (Rotterdam Port)
      │   └── 📦 ASSET: MAEU2345678 (Container 40ft)
      │       └── ⚠️ NON-CONFORMITY: DAMAGED (Front corner)
      │           └── 🤖 AI CHECK: PASSED (95% confidence)
      │           └── 📄 DOCUMENTS: 3 photos, 1 signature
      ├── 📍 STOP 2: Delivery (Hamburg Warehouse)
      │   └── 📦 ASSET: CSNU3456789 (Container 20ft)
      │       └── ✅ DELIVERED (No issues)
      └── 📍 STOP 3: Return (Rotterdam Port)
          └── 📦 ASSET: TRLR-001234 (Trailer)
              └── ⚠️ NON-CONFORMITY: SEAL_BROKEN
                  └── 🤖 AI CHECK: FAILED (Seal mismatch)
```

#### 1.2 Interactive Master-Child Regions

**APEX Implementation:**
- **Master Region:** Interactive Report (Orders)
- **Child Region 1:** Classic Report (Trips) - Shows when order selected
- **Child Region 2:** Classic Report (Stops) - Shows when trip selected
- **Child Region 3:** Cards (Assets) - Visual cards with status badges
- **Child Region 4:** Interactive Report (Non-Conformities) - Filtered by order
- **Child Region 5:** Gallery (Documents) - Thumbnail view with preview

**Navigation Flow:**
1. User clicks Order row → Expands to show Trips
2. User clicks Trip row → Expands to show Stops
3. User clicks Stop → Shows Assets in card layout
4. User clicks Asset → Shows Non-Conformities + Documents

**APEX Components:**
- **Master:** Interactive Report with `apex_item` for row selection
- **Child:** Classic Reports with `WHERE` clause based on master selection
- **Drill-down:** Modal dialogs or separate pages for detailed views
- **Breadcrumb:** Shows current navigation path (Order > Trip > Stop > Asset)

---

### 2. Non-Conformity Highlighting

#### 2.1 Visual Indicators

**Color Coding System:**
- 🔴 **RED Background** - CRITICAL severity non-conformity (unresolved)
- 🟠 **ORANGE Background** - HIGH severity non-conformity (unresolved)
- 🟡 **YELLOW Background** - MEDIUM severity non-conformity (unresolved)
- 🟢 **GREEN Background** - All non-conformities resolved
- ⚪ **WHITE Background** - No non-conformities

**Implementation in APEX:**
```sql
-- Conditional Row Highlighting (Interactive Report)
SELECT 
  o.seq,
  o.ordernumber,
  o.customername,
  o.status,
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM nonconformities nc
      JOIN stopassets sa ON sa.seq = nc.stopassetseq
      JOIN stops s ON s.seq = sa.stopseq
      JOIN trips t ON t.seq = s.tripseq
      WHERE t.orderseq = o.seq
      AND nc.resolutionstatus IN ('OPEN', 'IN_REVIEW')
      AND nc.severity = 'CRITICAL'
    ) THEN 'CRITICAL'
    WHEN EXISTS (
      SELECT 1 
      FROM nonconformities nc
      JOIN stopassets sa ON sa.seq = nc.stopassetseq
      JOIN stops s ON s.seq = sa.stopseq
      JOIN trips t ON t.seq = s.tripseq
      WHERE t.orderseq = o.seq
      AND nc.resolutionstatus IN ('OPEN', 'IN_REVIEW')
      AND nc.severity = 'HIGH'
    ) THEN 'HIGH'
    WHEN EXISTS (
      SELECT 1 
      FROM nonconformities nc
      JOIN stopassets sa ON sa.seq = nc.stopassetseq
      JOIN stops s ON s.seq = sa.stopseq
      JOIN trips t ON t.seq = s.tripseq
      WHERE t.orderseq = o.seq
      AND nc.resolutionstatus IN ('OPEN', 'IN_REVIEW')
    ) THEN 'MEDIUM'
    ELSE 'NONE'
  END AS nonconf_status
FROM orders o
WHERE o.provisionerseq = :PROVISIONERSEQ;
```

**CSS Highlighting:**
```css
/* APEX Page CSS */
.apex-row-highlight-CRITICAL {
  background-color: #ffebee !important;
  border-left: 4px solid #d32f2f !important;
}

.apex-row-highlight-HIGH {
  background-color: #fff3e0 !important;
  border-left: 4px solid #f57c00 !important;
}

.apex-row-highlight-MEDIUM {
  background-color: #fffde7 !important;
  border-left: 4px solid #fbc02d !important;
}

.apex-row-highlight-NONE {
  background-color: #e8f5e9 !important;
  border-left: 4px solid #388e3c !important;
}
```

#### 2.2 Badge Indicators

**Order List Badges:**
- 🔴 **"CRITICAL"** badge - Red badge next to order number
- 🟠 **"HIGH"** badge - Orange badge
- 🟡 **"REVIEW"** badge - Yellow badge (non-conformities pending)
- ✅ **"CLEAN"** badge - Green badge (no issues)
- ⏳ **"AI PROCESSING"** badge - Blue badge (AI check in progress)

**Implementation:**
```sql
-- Badge Column in Order Report
SELECT 
  o.ordernumber,
  o.customername,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM nonconformities nc
      JOIN stopassets sa ON sa.seq = nc.stopassetseq
      JOIN stops s ON s.seq = sa.stopseq
      JOIN trips t ON t.seq = s.tripseq
      WHERE t.orderseq = o.seq
      AND nc.resolutionstatus IN ('OPEN', 'IN_REVIEW')
      AND nc.severity = 'CRITICAL'
    ) THEN '<span class="badge badge-danger">CRITICAL</span>'
    WHEN EXISTS (
      SELECT 1 FROM nonconformities nc
      JOIN stopassets sa ON sa.seq = nc.stopassetseq
      JOIN stops s ON s.seq = sa.stopseq
      JOIN trips t ON t.seq = s.tripseq
      WHERE t.orderseq = o.seq
      AND nc.resolutionstatus IN ('OPEN', 'IN_REVIEW')
    ) THEN '<span class="badge badge-warning">REVIEW</span>'
    ELSE '<span class="badge badge-success">CLEAN</span>'
  END AS status_badge
FROM orders o;
```

#### 2.3 Quick Filter Buttons

**Filter Bar:**
- 🔴 **Show Critical Only** - Filters orders with CRITICAL non-conformities
- 🟠 **Show High Priority** - Filters HIGH severity issues
- ⚠️ **Show All Issues** - Shows all orders with any non-conformity
- ✅ **Show Clean Orders** - Shows orders without issues
- 🔄 **Show AI Processing** - Shows orders with pending AI checks

---

### 3. AI Status Integration

#### 3.1 AI Status Display

**AI Check Status Indicators:**

**In Order List:**
- 🤖 **AI Status Column** - Shows current AI processing status
  - `PENDING` - Not yet processed
  - `IN_PROGRESS` - Currently being analyzed
  - `PASSED` - AI validation successful (with confidence score)
  - `FAILED` - AI detected issues (with detected problems)
  - `ERROR` - AI processing error

**Visual Representation:**
```
Order: ORD-2025-001
├── AI Status: ✅ PASSED (95% confidence)
├── AI Check: Document verification complete
├── Detected Issues: None
└── Recommendations: Proceed with delivery
```

**In Non-Conformity Detail:**
- **AI Validation Card** - Shows full AI analysis
  - Confidence Score (0-100%)
  - Detected Issues (list)
  - Recommendations (action items)
  - Processing Time
  - AI Model Version
  - Check Date/Time

#### 3.2 Real-Time AI Status Updates

**Background Processing:**
- **AJAX Refresh** - Every 30 seconds, check for new AI results
- **WebSocket Integration** (optional) - Real-time push notifications
- **Status Badge Updates** - Automatically refresh when AI completes

**Implementation:**
```javascript
// APEX Dynamic Action - Auto-refresh AI status
setInterval(function() {
  apex.server.process('CHECK_AI_STATUS', {
    x01: $v('P1_ORDER_SEQ')
  }, {
    success: function(data) {
      if (data.ai_status === 'PASSED' || data.ai_status === 'FAILED') {
        // Update AI status badge
        $('#ai-status-badge').html(data.status_html);
        // Show notification
        apex.message.showSuccess('AI validation completed');
      }
    }
  });
}, 30000); // 30 seconds
```

#### 3.3 AI Results Visualization

**AI Check Detail Page:**
- **Confidence Score Gauge** - Circular progress indicator
- **Detected Issues List** - Expandable cards with details
- **Recommendations Panel** - Actionable items with checkboxes
- **AI Analysis Timeline** - Shows processing steps
- **Document Comparison** - Side-by-side view of uploaded vs. expected

**Example AI Result Display:**
```
┌─────────────────────────────────────────┐
│ AI Validation Results                   │
├─────────────────────────────────────────┤
│ Confidence Score: 95%                   │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                         │
│ Detected Issues:                        │
│ ✅ Document completeness: PASSED        │
│ ✅ Damage photo matches description     │
│ ⚠️  Seal photo quality: LOW (retake)    │
│                                         │
│ Recommendations:                        │
│ 1. Request higher resolution seal photo │
│ 2. Verify seal number matches manifest  │
│ 3. Proceed with delivery (low risk)     │
│                                         │
│ Processing Time: 2.3 seconds            │
│ AI Model: GPT-4 Vision v1.2            │
│ Check Date: 2025-12-19 14:28:33        │
└─────────────────────────────────────────┘
```

---

### 4. Order Status Dashboard

#### 4.1 Comprehensive Status Overview

**Status Components to Display:**

1. **Order Header Information:**
   - Order Number, Customer Name, Order Date
   - Requested Delivery Date, Priority Level
   - Current Status (NEW, PROCESSING, COMPLETED, CANCELLED)
   - Total Assets, Total Weight

2. **Trip Status:**
   - Trip Number, Driver Name, Vehicle Info
   - Trip Status (PLANNED, IN_PROGRESS, COMPLETED, CANCELLED)
   - Start Date/Time, Expected End Date/Time
   - Current Location (GPS coordinates)

3. **Stop Status:**
   - Stop Sequence, Stop Type (PICKUP, DELIVERY, RETURN)
   - Address, GPS Coordinates
   - Scheduled Time, Actual Arrival Time, Actual Departure Time
   - Stop Status (PENDING, IN_PROGRESS, COMPLETED, SKIPPED)

4. **Asset Status:**
   - Asset Number, Asset Type (CONTAINER, TRAILER)
   - Asset Status (ALLOCATED, IN_TRANSIT, DELIVERED, REJECTED)
   - Delivery Date/Time, Signature Status

5. **Non-Conformity Status:**
   - Count of non-conformities by severity
   - Count of resolved vs. open issues
   - Latest non-conformity report date
   - AI validation status summary

6. **Document Status:**
   - Total documents uploaded
   - Document types breakdown (Photo, PDF, Signature)
   - Missing required documents (if any)

7. **AI Check Status:**
   - Total AI checks performed
   - Passed vs. Failed count
   - Average confidence score
   - Pending AI checks count

#### 4.2 Status Summary Cards

**Dashboard Layout:**
```
┌─────────────────────────────────────────────────────────────┐
│ Order: ORD-2025-001 | Customer: Logistics Solutions GmbH  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📦 Order Status      🚛 Trip Status      📍 Stop Status    │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│  │ PROCESSING  │     │ IN_PROGRESS │     │ 2 of 3 Done  │  │
│  │ 75% Complete│     │ Driver: Jan  │     │ 1 Pending    │  │
│  └─────────────┘     └─────────────┘     └─────────────┘  │
│                                                             │
│  ⚠️  Non-Conformities  📄 Documents      🤖 AI Status      │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│  │ 2 Open       │     │ 8 Uploaded  │     │ 3 Passed    │  │
│  │ 1 Critical   │     │ 1 Missing   │     │ 1 Pending   │  │
│  └─────────────┘     └─────────────┘     └─────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 4.3 Status Timeline View

**Chronological Status Flow:**
```
Order Timeline: ORD-2025-001
─────────────────────────────────────────────────────────────
📅 2025-12-19 08:00  Order Created (Status: NEW)
📅 2025-12-19 09:15  Trip Assigned (Status: PROCESSING)
📅 2025-12-19 10:30  Trip Started (Status: IN_PROGRESS)
📅 2025-12-19 11:45  Stop 1: Pickup Completed
📅 2025-12-19 12:00  ⚠️  Non-Conformity Reported (DAMAGED)
📅 2025-12-19 12:01  🤖 AI Check Initiated
📅 2025-12-19 12:03  🤖 AI Check Completed (PASSED - 95%)
📅 2025-12-19 14:30  Stop 2: Delivery In Progress
📅 2025-12-19 15:00  Stop 2: Delivery Completed
📅 2025-12-19 16:00  Stop 3: Return Completed
📅 2025-12-19 16:30  Trip Completed (Status: COMPLETED)
```

#### 4.4 Status Filtering and Search

**Advanced Filters:**
- **Status Filter:** NEW, PROCESSING, COMPLETED, CANCELLED
- **Priority Filter:** LOW, NORMAL, HIGH, URGENT
- **Non-Conformity Filter:** Has Issues, No Issues, Critical Only
- **AI Status Filter:** Pending, Passed, Failed, Error
- **Date Range:** Order Date, Delivery Date, Report Date
- **Customer Filter:** Customer Name, Customer Code
- **Driver Filter:** Driver Name
- **Asset Filter:** Asset Number, Asset Type

**Search Capabilities:**
- Order Number search
- Customer Name search
- Asset Number search
- Non-Conformity Number search
- Driver Name search

---

## 🛠️ Technical Implementation

### 5.1 Database Queries

#### 5.1.1 Order List with Non-Conformity Status

```sql
-- Query for Order List with Highlighting
SELECT 
  o.seq AS order_seq,
  o.ordernumber,
  o.customername,
  o.orderdate,
  o.requesteddate,
  o.priority,
  o.status AS order_status,
  o.totalnumberofassets,
  -- Non-conformity summary
  (SELECT COUNT(*) 
   FROM nonconformities nc
   JOIN stopassets sa ON sa.seq = nc.stopassetseq
   JOIN stops s ON s.seq = sa.stopseq
   JOIN trips t ON t.seq = s.tripseq
   WHERE t.orderseq = o.seq
   AND nc.resolutionstatus IN ('OPEN', 'IN_REVIEW')
  ) AS open_nonconf_count,
  (SELECT MAX(nc.severity)
   FROM nonconformities nc
   JOIN stopassets sa ON sa.seq = nc.stopassetseq
   JOIN stops s ON s.seq = sa.stopseq
   JOIN trips t ON t.seq = s.tripseq
   WHERE t.orderseq = o.seq
   AND nc.resolutionstatus IN ('OPEN', 'IN_REVIEW')
  ) AS max_severity,
  -- AI status summary
  (SELECT COUNT(*)
   FROM aichecks ac
   JOIN stops s ON s.seq = ac.stopseq
   JOIN trips t ON t.seq = s.tripseq
   WHERE t.orderseq = o.seq
   AND ac.status = 'PENDING'
  ) AS pending_ai_checks,
  (SELECT COUNT(*)
   FROM aichecks ac
   JOIN stops s ON s.seq = ac.stopseq
   JOIN trips t ON t.seq = s.tripseq
   WHERE t.orderseq = o.seq
   AND ac.status = 'PASSED'
  ) AS passed_ai_checks
FROM orders o
WHERE o.provisionerseq = :PROVISIONERSEQ
ORDER BY 
  CASE o.priority
    WHEN 'URGENT' THEN 1
    WHEN 'HIGH' THEN 2
    WHEN 'NORMAL' THEN 3
    WHEN 'LOW' THEN 4
  END,
  o.orderdate DESC;
```

#### 5.1.2 Master-Child Query Structure

```sql
-- Master: Orders
SELECT seq, ordernumber, customername, status
FROM orders
WHERE provisionerseq = :PROVISIONERSEQ;

-- Child 1: Trips (when order selected)
SELECT 
  t.seq,
  t.tripnumber,
  t.drivername,
  t.vehiclenumber,
  t.status AS trip_status,
  t.startdate,
  t.expectedenddate
FROM trips t
WHERE t.orderseq = :P1_ORDER_SEQ
AND t.provisionerseq = :PROVISIONERSEQ;

-- Child 2: Stops (when trip selected)
SELECT 
  s.seq,
  s.stopsequence,
  s.stoptype,
  s.address,
  s.scheduledarrivaltime,
  s.actualarrivaltime,
  s.status AS stop_status
FROM stops s
WHERE s.tripseq = :P1_TRIP_SEQ
AND s.provisionerseq = :PROVISIONERSEQ
ORDER BY s.stopsequence;

-- Child 3: Assets (when stop selected)
SELECT 
  sa.seq,
  a.assetnumber,
  a.assettype,
  sa.deliverystatus,
  sa.deliverydate,
  sa.signaturestatus
FROM stopassets sa
JOIN assets a ON a.seq = sa.assetseq
WHERE sa.stopseq = :P1_STOP_SEQ
AND sa.provisionerseq = :PROVISIONERSEQ;

-- Child 4: Non-Conformities (when order selected)
SELECT 
  nc.seq,
  nc.nonconformitynumber,
  nc.nonconformitytype,
  nc.severity,
  nc.description,
  nc.resolutionstatus,
  nc.reporteddate,
  a.assetnumber,
  s.stopsequence
FROM nonconformities nc
JOIN stopassets sa ON sa.seq = nc.stopassetseq
JOIN assets a ON a.seq = sa.assetseq
JOIN stops s ON s.seq = sa.stopseq
JOIN trips t ON t.seq = s.tripseq
WHERE t.orderseq = :P1_ORDER_SEQ
AND nc.provisionerseq = :PROVISIONERSEQ
ORDER BY nc.reporteddate DESC;
```

#### 5.1.3 AI Status Query

```sql
-- AI Status for Order
SELECT 
  ac.seq,
  ac.checknumber,
  ac.checktype,
  ac.status AS ai_status,
  ac.confidencescore,
  ac.detectedissues,
  ac.recommendations,
  ac.completeddate,
  ac.processingtime,
  nc.nonconformitynumber,
  d.documenttype,
  d.filename
FROM aichecks ac
LEFT JOIN nonconformities nc ON nc.seq = ac.nonconformityseq
LEFT JOIN documents d ON d.seq = ac.documentseq
JOIN stops s ON s.seq = ac.stopseq
JOIN trips t ON t.seq = s.tripseq
WHERE t.orderseq = :P1_ORDER_SEQ
AND ac.provisionerseq = :PROVISIONERSEQ
ORDER BY ac.checkdate DESC;
```

### 5.2 APEX Page Structure

#### 5.2.1 Main Order List Page (Page 100)

**Regions:**
1. **Header Region** - Title, filters, search
2. **Order List Region** - Interactive Report (Master)
3. **Trip Detail Region** - Classic Report (Child 1) - Conditional display
4. **Stop Detail Region** - Classic Report (Child 2) - Conditional display
5. **Asset Cards Region** - Cards (Child 3) - Conditional display
6. **Non-Conformity List Region** - Interactive Report (Child 4) - Conditional display
7. **Document Gallery Region** - Gallery (Child 5) - Conditional display

**Page Items:**
- `P100_ORDER_SEQ` - Hidden, stores selected order
- `P100_TRIP_SEQ` - Hidden, stores selected trip
- `P100_STOP_SEQ` - Hidden, stores selected stop
- `P100_SEARCH` - Search field
- `P100_STATUS_FILTER` - Select list (Status filter)
- `P100_PRIORITY_FILTER` - Select list (Priority filter)
- `P100_NONCONF_FILTER` - Select list (Non-conformity filter)

**Dynamic Actions:**
- **Order Row Click** → Set `P100_ORDER_SEQ`, refresh child regions
- **Trip Row Click** → Set `P100_TRIP_SEQ`, refresh stop/asset regions
- **Stop Row Click** → Set `P100_STOP_SEQ`, refresh asset region
- **Filter Change** → Refresh order list
- **Auto-refresh AI Status** → AJAX call every 30 seconds

#### 5.2.2 Order Detail Page (Page 101)

**Regions:**
1. **Order Header** - Order information cards
2. **Status Timeline** - Chronological status flow
3. **Trip Summary** - Trip status cards
4. **Non-Conformity Summary** - Count by severity
5. **AI Status Summary** - AI check results
6. **Document Summary** - Document count by type
7. **Action Buttons** - Process, Resolve, Escalate

**Page Items:**
- `P101_ORDER_SEQ` - Hidden, from page 100
- `P101_ORDER_NUMBER` - Display only
- `P101_CUSTOMER_NAME` - Display only
- `P101_STATUS` - Display only with badge

#### 5.2.3 Non-Conformity Detail Page (Page 102)

**Regions:**
1. **Non-Conformity Header** - Issue details
2. **AI Validation Card** - AI results with confidence score
3. **Document Gallery** - Photos, PDFs related to issue
4. **Resolution Panel** - Status update, notes, actions
5. **Comments/History** - Timeline of actions

**Page Items:**
- `P102_NONCONF_SEQ` - Hidden
- `P102_RESOLUTION_STATUS` - Select list
- `P102_RESOLUTION_NOTES` - Text area
- `P102_VERIFIED_BY` - Display only
- `P102_VERIFIED_DATE` - Display only

### 5.3 JavaScript Functions

#### 5.3.1 Auto-Refresh AI Status

```javascript
// Auto-refresh AI status every 30 seconds
function autoRefreshAIStatus() {
  setInterval(function() {
    apex.server.process('CHECK_AI_STATUS', {
      x01: $v('P100_ORDER_SEQ')
    }, {
      success: function(data) {
        if (data.has_updates) {
          // Update AI status badges
          $('.ai-status-badge').each(function() {
            var checkSeq = $(this).data('check-seq');
            if (data.updates[checkSeq]) {
              $(this).html(data.updates[checkSeq].badge_html);
              $(this).removeClass('badge-secondary')
                     .addClass(data.updates[checkSeq].badge_class);
            }
          });
          
          // Show notification if critical update
          if (data.critical_update) {
            apex.message.showInfo('AI validation completed for order: ' + data.order_number);
          }
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.error('Error refreshing AI status:', errorThrown);
      }
    });
  }, 30000); // 30 seconds
}

// Initialize on page load
$(document).ready(function() {
  if ($v('P100_ORDER_SEQ')) {
    autoRefreshAIStatus();
  }
});
```

#### 5.3.2 Master-Child Navigation

```javascript
// Handle master row click
function handleOrderRowClick(orderSeq) {
  // Set hidden item
  apex.item('P100_ORDER_SEQ').setValue(orderSeq);
  
  // Refresh child regions
  apex.region('TRIP_DETAIL_REGION').refresh();
  apex.region('NONCONF_LIST_REGION').refresh();
  
  // Highlight selected row
  $('.order-row').removeClass('selected');
  $('.order-row[data-order-seq="' + orderSeq + '"]').addClass('selected');
}

// Handle trip row click
function handleTripRowClick(tripSeq) {
  apex.item('P100_TRIP_SEQ').setValue(tripSeq);
  apex.region('STOP_DETAIL_REGION').refresh();
  apex.region('ASSET_CARDS_REGION').refresh();
}
```

#### 5.3.3 Non-Conformity Highlighting

```javascript
// Apply row highlighting based on non-conformity status
function applyRowHighlighting() {
  $('.order-row').each(function() {
    var row = $(this);
    var severity = row.data('max-severity');
    var hasOpenNonConf = row.data('open-nonconf-count') > 0;
    
    // Remove existing highlight classes
    row.removeClass('highlight-critical highlight-high highlight-medium highlight-clean');
    
    // Apply appropriate highlight
    if (hasOpenNonConf) {
      if (severity === 'CRITICAL') {
        row.addClass('highlight-critical');
      } else if (severity === 'HIGH') {
        row.addClass('highlight-high');
      } else {
        row.addClass('highlight-medium');
      }
    } else {
      row.addClass('highlight-clean');
    }
  });
}

// Apply on page load and after refresh
$(document).ready(function() {
  applyRowHighlighting();
});

// Re-apply after region refresh
apex.region('ORDER_LIST_REGION').widget().interactiveReport('refreshAfter', function() {
  applyRowHighlighting();
});
```

### 5.4 PL/SQL Processes

#### 5.4.1 Check AI Status Process

```sql
-- Process: CHECK_AI_STATUS
-- Type: AJAX Callback
DECLARE
  v_order_seq NUMBER := apex_application.g_x01;
  v_has_updates BOOLEAN := FALSE;
  v_updates_json CLOB;
BEGIN
  -- Check for completed AI checks
  FOR rec IN (
    SELECT 
      ac.seq AS check_seq,
      ac.status AS ai_status,
      ac.confidencescore,
      nc.nonconformitynumber
    FROM aichecks ac
    LEFT JOIN nonconformities nc ON nc.seq = ac.nonconformityseq
    JOIN stops s ON s.seq = ac.stopseq
    JOIN trips t ON t.seq = s.tripseq
    WHERE t.orderseq = v_order_seq
    AND ac.status IN ('PASSED', 'FAILED')
    AND ac.completeddate > SYSDATE - (1/24) -- Last hour
    AND ac.provisionerseq = NVL(apex_application.g_provisionerseq, 
                                xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'))
  ) LOOP
    v_has_updates := TRUE;
    -- Build JSON response
    apex_json.open_object;
    apex_json.write('check_seq', rec.check_seq);
    apex_json.write('ai_status', rec.ai_status);
    apex_json.write('confidence_score', rec.confidencescore);
    apex_json.write('nonconf_number', rec.nonconformitynumber);
    apex_json.close_object;
  END LOOP;
  
  apex_json.open_object;
  apex_json.write('has_updates', v_has_updates);
  apex_json.write('updates', v_updates_json);
  apex_json.close_object;
END;
```

#### 5.4.2 Update Non-Conformity Status

```sql
-- Process: UPDATE_NONCONF_STATUS
-- Type: PL/SQL Code
DECLARE
  v_nonconf_seq NUMBER := :P102_NONCONF_SEQ;
  v_status VARCHAR2(20) := :P102_RESOLUTION_STATUS;
  v_notes VARCHAR2(4000) := :P102_RESOLUTION_NOTES;
  v_user VARCHAR2(200) := NVL(v('APP_USER'), USER);
BEGIN
  UPDATE nonconformities
  SET resolutionstatus = v_status,
      resolutionnotes = v_notes,
      resolutiondate = CASE WHEN v_status = 'RESOLVED' THEN CURRENT_TIMESTAMP ELSE resolutiondate END,
      verifiedby = CASE WHEN v_status IN ('RESOLVED', 'REJECTED') THEN v_user ELSE verifiedby END,
      verifieddate = CASE WHEN v_status IN ('RESOLVED', 'REJECTED') THEN CURRENT_TIMESTAMP ELSE verifieddate END,
      updatedate = CURRENT_TIMESTAMP,
      updateuser = v_user,
      update_timezone = SESSIONTIMEZONE
  WHERE seq = v_nonconf_seq
  AND provisionerseq = NVL(v('PROVISIONERSEQ'), 
                           xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));
  
  COMMIT;
  
  apex_application.g_print_success_message := 'Non-conformity status updated successfully';
EXCEPTION
  WHEN OTHERS THEN
    xxsd_admin.pkg_error.p_logerror(
      'UPDATE_NONCONF_STATUS',
      SQLCODE,
      'Error updating non-conformity: ' || SQLERRM
    );
    apex_application.g_print_success_message := 'Error updating status: ' || SQLERRM;
END;
```

---

## 🔄 User Workflows

### 6.1 Order Monitoring Workflow

1. **User opens Order List page**
   - Sees all orders with color-coded highlighting
   - Red/orange rows indicate non-conformities

2. **User clicks on highlighted order**
   - Order expands to show trips
   - Non-conformity count and severity displayed

3. **User clicks on trip**
   - Stops for that trip displayed
   - Asset status shown

4. **User clicks on non-conformity**
   - Opens Non-Conformity Detail page
   - Sees AI validation results
   - Reviews documents (photos, PDFs)

5. **User processes non-conformity**
   - Updates resolution status
   - Adds resolution notes
   - Marks as resolved or escalates

### 6.2 AI Status Monitoring Workflow

1. **User views order with pending AI checks**
   - Sees "AI PROCESSING" badge
   - Status shows "IN_PROGRESS"

2. **AI completes processing**
   - Badge automatically updates (via AJAX)
   - Status changes to "PASSED" or "FAILED"
   - Notification appears

3. **User reviews AI results**
   - Opens AI Check Detail
   - Reviews confidence score
   - Reads detected issues and recommendations

4. **User takes action based on AI results**
   - If PASSED: Proceeds with normal workflow
   - If FAILED: Reviews issues, takes corrective action

### 6.3 Non-Conformity Resolution Workflow

1. **User identifies non-conformity requiring resolution**
   - Filters orders by "Has Issues"
   - Sorts by severity (CRITICAL first)

2. **User opens non-conformity detail**
   - Reviews description and photos
   - Checks AI validation results
   - Reads driver comments

3. **User updates resolution status**
   - Changes status to "IN_REVIEW" or "RESOLVED"
   - Adds resolution notes
   - Assigns responsible party

4. **System updates order highlighting**
   - If all non-conformities resolved: Order turns green
   - If critical issue resolved: Badge changes from red to orange/yellow

---

## ⚡ Performance Considerations

### 7.1 Query Optimization

- **Indexes:** Ensure indexes on:
  - `orders.provisionerseq, orders.status`
  - `nonconformities.resolutionstatus, nonconformities.severity`
  - `aichecks.status, aichecks.completeddate`
  - Foreign keys: `trips.orderseq`, `stops.tripseq`, `stopassets.stopseq`

- **Pagination:** Use APEX pagination (25-50 rows per page)
- **Lazy Loading:** Load child regions only when parent selected
- **Caching:** Cache static data (status lists, severity lists)

### 7.2 AJAX Optimization

- **Debouncing:** Debounce filter changes (wait 500ms before querying)
- **Batch Updates:** Batch multiple AI status checks in single AJAX call
- **Conditional Refresh:** Only refresh regions that have changed

### 7.3 Real-Time Updates

- **WebSocket Alternative:** Use Server-Sent Events (SSE) for real-time updates
- **Polling Interval:** Adjust based on user activity (30s active, 60s inactive)
- **Selective Updates:** Only update changed elements, not entire regions

---

## 📱 Responsive Design

### 8.1 Desktop Layout (Default)
- Multi-column layout with master-child regions side-by-side
- Full-width tables and reports
- Hover tooltips for additional information

### 8.2 Tablet Layout
- Stacked regions (master above, children below)
- Collapsible sidebars
- Touch-friendly buttons and links

### 8.3 Mobile Layout (Future)
- Single-column stacked layout
- Accordion-style master-child navigation
- Bottom navigation for quick actions

---

## 🔐 Security Considerations

### 9.1 Data Isolation
- All queries filtered by `PROVISIONERSEQ`
- Security views enforce tenant isolation
- No cross-tenant data access

### 9.2 Authorization
- Role-based access control (RBAC)
- Different permissions for viewing vs. updating
- Audit trail for all status changes

### 9.3 Input Validation
- Validate all user inputs
- Sanitize file uploads
- Prevent SQL injection

---

## 📊 Reporting and Analytics

### 10.1 Order Status Report
- Summary by status, priority, customer
- Non-conformity statistics
- AI validation success rates

### 10.2 Non-Conformity Analysis
- Trends over time
- Severity distribution
- Resolution time metrics

### 10.3 AI Performance Metrics
- Average confidence scores
- Processing time statistics
- Accuracy rates (manual validation vs. AI)

---

## 🎯 Success Criteria

- ✅ All orders visible with proper highlighting
- ✅ Master-child navigation works smoothly
- ✅ AI status updates in real-time (< 30s delay)
- ✅ Non-conformities easily identifiable
- ✅ Order status comprehensive and accurate
- ✅ Page load time < 2 seconds
- ✅ Mobile-responsive design (future)

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-19  
**Author:** Hackathon Group 3  
**Status:** Concept - Ready for Implementation

