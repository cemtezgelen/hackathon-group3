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
            └── hackathon_ai_check_ddl.sql   # Complete data model
```

## 📝 Getting Started

### Prerequisites
- Oracle 19c database
- APEX 24.1.6 workspace
- Schema: `cemtezgelen`

### Installation

1. **Create Database Objects:**
```sql
@src/database/cemtezgelen/hackathon_ai_check_ddl.sql
```

2. **Load Demo Data:**
(Coming soon - demo data package)

3. **Configure APEX App:**
- Import APEX application (App ID: 135)
- Configure AI API endpoints
- Set up notification channels

## 🎨 Demo Scenarios

### Scenario 1: Successful Delivery
- Driver delivers container intact
- Uploads signature and photo
- AI validates → ✅ PASSED
- No notifications

### Scenario 2: Damage Detected
- Driver reports DAMAGED non-conformity
- Uploads damage photo
- AI validates → ✅ PASSED (damage matches report)
- INFO notification to backoffice

### Scenario 3: Mismatch Detected
- Driver reports DAMAGED
- Uploads photo showing different issue
- AI validates → ❌ FAILED (mismatch detected)
- 🚨 URGENT notification to backoffice

### Scenario 4: Missing Documents
- Driver attempts to mark as delivered
- No POD signature uploaded
- AI validates → ⚠️ WARNING
- Driver prompted to upload missing document

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
