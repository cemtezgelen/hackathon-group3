# Hackathon Group 3 - AI Document Check

**Track 5:** AI Integration for Cargo/Asset Damage and Document Check

## 🎯 Project Overview

This project addresses the challenge of documenting non-conformities efficiently. Our solution integrates AI to automatically check cargo and asset damages/non-conformities, and verify if all required documents are present.

### Challenge Statement
Non-conformities need to be documented well, taking up significant time. AI Integration to:
- Check cargo and asset damages/non-conformities
- Confirm if all documents are in
- Automate verification and validation processes

## 🏗️ Architecture

### Components
1. **Driver App** (APEX Mobile)
   - Trip management
   - Stop processing
   - Asset delivery/rejection
   - Non-conformity reporting with photo upload
   - Real-time AI validation

2. **Backoffice App** (APEX Desktop)
   - Dashboard for AI validation results
   - Non-conformity review and management
   - Real-time notifications
   - Analytics and reporting

3. **AI Integration Layer**
   - Document verification
   - Damage detection via image analysis
   - Seal integrity check
   - Automatic matching of reported issues with visual evidence

## 📊 Data Model

### Main Tables (9 Tables)

1. **ORDERS** - Shipment orders with customer details
2. **TRIPS** - Driver assignments and trip tracking
3. **STOPS** - Delivery/pickup locations with GPS
4. **ASSETS** - Containers and trailers (unified model)
5. **STOP_ASSETS** - Asset delivery tracking per stop
6. **NONCONFORMITIES** - Main table for all issues (damage, missing, seal broken, etc.)
7. **DOCUMENTS** - Photos, signatures, POD, damage photos
8. **AI_CHECKS** - AI validation results with confidence scores
9. **NOTIFICATIONS** - Multi-channel alerts (email, push, SMS, in-app)

### Key Features
- ✅ Multi-tenant support (PROVISIONERSEQ)
- ✅ Audit columns on all tables
- ✅ Automated triggers for data integrity
- ✅ Security views for data isolation
- ✅ 46 indexes for performance
- ✅ JSON support for AI results and metadata

## 🚀 Workflow

### Phase 1: Data Ingestion (Demo Mode)
- Generate sample orders, trips, stops, and assets
- Simulate realistic delivery scenarios

### Phase 2: Order Processing
- Assign trips to drivers
- Plan routes and stops
- Allocate assets to stops

### Phase 3: Driver Operations
- Driver starts trip
- Arrives at stop
- Marks assets as DELIVERED or NON_CONFORMITY
- **AI Check #1:** Immediate validation
  - Verifies uploaded documents
  - Checks if non-conformity matches visual evidence
  - Warns driver if required documents are missing

### Phase 4: Backoffice Monitoring
- Sees driver actions in real-time
- AI validation status visible on dashboard
- Automatic background processing

### Phase 5: AI Validation
- Analyzes uploaded documents and photos
- Verifies non-conformity claims
- Checks product/damage consistency
- Validates driver's actions
- Returns confidence scores and recommendations

### Phase 6: Notifications
- Problem detected → instant alert
- Email + push notification to backoffice
- Escalation for HIGH/CRITICAL severity

## 🛠️ Tech Stack

- **Database:** Oracle 19c
- **Frontend:** Oracle APEX 24.1.6
- **AI Integration:** Vision AI APIs (GPT-4 Vision or similar)
- **Languages:** PL/SQL, JavaScript (ES6+), HTML5, CSS3

## 📁 Repository Structure

```
hackathon-group3/
├── README.md
└── src/
    └── database/
        └── cemtezgelen/
            ├── hackathon_ai_check_ddl.sql     # Complete data model
            ├── pkg_hackathon_demo.pks         # Demo package spec
            ├── pkg_hackathon_demo.pkb         # Demo package body
            └── demo_data_usage.sql            # Usage examples
```

## 📝 Getting Started

### Prerequisites
- Oracle 19c database
- APEX 24.1.6 workspace
- Schema: `cemtezgelen`

### Installation

1. **Create Database Objects:**
```sql
-- Create tables, views, triggers, indexes
@src/database/cemtezgelen/hackathon_ai_check_ddl.sql
```

2. **Install Demo Package:**
```sql
-- Install demo data generation package
@src/database/cemtezgelen/pkg_hackathon_demo.pks
@src/database/cemtezgelen/pkg_hackathon_demo.pkb
```

3. **Generate Demo Data:**
```sql
-- Enable output to see progress
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Reset and generate fresh demo data
EXEC cemtezgelen.pkg_hackathon_demo.p_reset_demo_data;
EXEC cemtezgelen.pkg_hackathon_demo.p_generate_demo_data(p_provisionerseq => 1);

-- View summary
EXEC cemtezgelen.pkg_hackathon_demo.p_print_demo_summary(p_provisionerseq => 1);
```

4. **Configure APEX App:**
- Import APEX application (App ID: 135)
- Configure AI API endpoints
- Set up notification channels

### Quick Start

Run all setup commands at once:
```sql
@src/database/cemtezgelen/demo_data_usage.sql
```

## 🎨 Demo Scenarios

Demo package creates 5 realistic scenarios with complete data:

### Scenario 1: Normal Delivery (Happy Path) ✅
- **Order:** ORD-2025-001 (Logistics Solutions GmbH)
- **Route:** Rotterdam → Hamburg
- **Assets:** 2 x 20ft containers
- **Driver:** Jan van Dijk
- **Status:** Clean delivery, no issues
- **Use Case:** Baseline for successful delivery workflow

### Scenario 2: Damaged Container ⚠️
- **Order:** ORD-2025-002 (BelgianTrade BVBA)
- **Route:** Antwerp delivery
- **Asset:** MAEU2345678 (40ft container)
- **Driver:** Marc Janssen
- **Issue:** Front-left corner impact damage (HIGH severity)
- **Non-conformity:** DAMAGED with detailed description
- **Use Case:** AI validates damage photo matches reported issue

### Scenario 3: Seal Broken 🚨
- **Order:** ORD-2025-003 (SecureFreight Ltd)
- **Route:** Southampton inspection
- **Asset:** CSNU3456789 (High security container)
- **Driver:** Thomas Brown
- **Issue:** Security seal tampering (CRITICAL severity)
- **Non-conformity:** SEAL_BROKEN - escalated status
- **Use Case:** Security breach detection and immediate escalation

### Scenario 4: Missing Asset 📦
- **Order:** ORD-2025-004 (Nordic Shipping AS)
- **Route:** Oslo pickup
- **Assets:** 2 trailers (1 missing)
- **Driver:** Erik Andersen
- **Issue:** TRLR-001234 not found at pickup location
- **Non-conformity:** MISSING (HIGH severity)
- **Use Case:** Asset tracking failure and investigation workflow

### Scenario 5: Temperature Issue ❄️
- **Order:** ORD-2025-005 (FreshFood International)
- **Route:** Le Havre delivery
- **Asset:** REEFER-567890 (40ft refrigerated)
- **Driver:** François Martin
- **Issue:** Temperature -8°C (target: -18°C) - CRITICAL
- **Non-conformity:** TEMPERATURE_ISSUE - cold chain compromised
- **Use Case:** Real-time temperature monitoring and urgent response

### Generated Data Summary

After running `p_generate_demo_data`:
- **5 Orders** across different countries (DE, BE, UK, NO, FR)
- **5 Trips** with unique drivers and vehicles
- **7 Stops** (pickup/delivery/inspection)
- **7 Assets** (5 containers + 2 trailers)
- **4 Non-conformities** (various severity levels)
- **Realistic GPS coordinates** and addresses
- **Complete audit trail** with timestamps

## 📈 Success Metrics

- ⚡ **Speed:** AI validation in <3 seconds
- 🎯 **Accuracy:** 95%+ confidence in damage detection
- 📉 **Efficiency:** 70% reduction in manual verification time
- 🔔 **Responsiveness:** Instant notifications for issues

## 👥 Team

Group 3 - Hackathon Participants

## 📄 License

Proprietary - Hackathon Project

---

**Built with ❤️ for Hackathon Track 5**
