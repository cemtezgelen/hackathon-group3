# Driver APEX Application - Concept Document

**Version:** 1.0  
**Date:** 2025-12-19  
**Project:** Hackathon Group 3 - AI Document Check  
**Application Type:** Mobile Web Application (Oracle APEX 24.1.6)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Core Features](#core-features)
3. [Mobile-First Design](#mobile-first-design)
4. [Order Completion Workflow](#order-completion-workflow)
5. [Non-Conformity Reporting](#non-conformity-reporting)
6. [Document Upload](#document-upload)
7. [Comment and Notes System](#comment-and-notes-system)
8. [Technical Implementation](#technical-implementation)
9. [User Workflows](#user-workflows)
10. [Offline Capability](#offline-capability)

---

## 🎯 Overview

### Purpose
The Driver APEX application is a mobile-optimized interface that enables drivers to complete delivery orders, report non-conformities, upload photos/PDFs, and add comments while on the road. It provides a streamlined, touch-friendly experience designed for use on smartphones and tablets in various lighting and network conditions.

### Target Users
- **Delivery Drivers** - Primary users completing deliveries
- **Field Inspectors** - Quality control staff in the field
- **Pickup Drivers** - Drivers collecting assets from locations

### Key Value Propositions
- ✅ Complete orders directly from mobile device
- ✅ Report non-conformities with photo evidence
- ✅ Upload multiple document types (PDF, images)
- ✅ Add detailed comments and notes
- ✅ Works offline with sync capability
- ✅ Fast, intuitive mobile interface

---

## 🎨 Core Features

### 1. Order Completion

#### 1.1 Order List View

**Mobile-Optimized Card Layout:**
```
┌─────────────────────────────────────┐
│ 📦 ORD-2025-001                     │
│ Logistics Solutions GmbH            │
│ ─────────────────────────────────── │
│ 🚛 Trip: TRP-2025-001               │
│ 👤 Driver: Jan van Dijk             │
│ 📍 Next Stop: Hamburg Warehouse     │
│ ⏰ ETA: 14:30                        │
│                                     │
│ [View Details] [Start Trip]         │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 📦 ORD-2025-002                     │
│ BelgianTrade BVBA                   │
│ ─────────────────────────────────── │
│ 🚛 Trip: TRP-2025-002               │
│ 👤 Driver: Marc Janssen              │
│ 📍 Next Stop: Antwerp Port         │
│ ⏰ ETA: 16:00                        │
│ ⚠️ 1 Non-Conformity                  │
│                                     │
│ [View Details] [Continue Trip]     │
└─────────────────────────────────────┘
```

**Features:**
- **Swipe Actions:** Swipe left to mark complete, swipe right to report issue
- **Quick Status:** Visual indicators for order status
- **GPS Integration:** Shows distance to next stop
- **Offline Indicator:** Badge showing sync status

#### 1.2 Order Detail View

**Single Order Focus:**
```
┌─────────────────────────────────────┐
│ ← Back        Order: ORD-2025-001  │
├─────────────────────────────────────┤
│                                     │
│ Customer: Logistics Solutions GmbH  │
│ Address: Hauptstraße 123           │
│         10115 Berlin, Germany       │
│                                     │
│ 📍 GPS: 52.520008, 13.404954       │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ Assets (2):                          │
│ ┌─────────────────────────────────┐ │
│ │ 📦 MAEU2345678                  │ │
│ │ Container 40ft                  │ │
│ │ Status: IN_TRANSIT              │ │
│ │ [Mark Delivered] [Report Issue] │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📦 CSNU3456789                  │ │
│ │ Container 20ft                  │ │
│ │ Status: IN_TRANSIT              │ │
│ │ [Mark Delivered] [Report Issue] │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ [Complete Order] [Save for Later]   │
│                                     │
└─────────────────────────────────────┘
```

#### 1.3 Complete Order Action

**Completion Workflow:**
1. Driver taps "Complete Order" button
2. System checks:
   - All assets marked as DELIVERED or have non-conformity
   - Required documents uploaded (if applicable)
   - Signature captured (if required)
3. If validation passes:
   - Order status → COMPLETED
   - Trip status → COMPLETED
   - Stop status → COMPLETED
   - Confirmation message displayed
4. If validation fails:
   - Shows missing items
   - Prevents completion until resolved

**Completion Screen:**
```
┌─────────────────────────────────────┐
│ ✅ Order Completed!                 │
│                                     │
│ Order: ORD-2025-001                 │
│ Completed: 2025-12-19 14:35         │
│                                     │
│ Summary:                            │
│ • 2 Assets Delivered                │
│ • 0 Non-Conformities                │
│ • 3 Documents Uploaded              │
│                                     │
│ [View Receipt] [Next Order]         │
└─────────────────────────────────────┘
```

---

### 2. Non-Conformity Reporting

#### 2.1 Report Non-Conformity Flow

**Step 1: Select Non-Conformity Type**
```
┌─────────────────────────────────────┐
│ Report Non-Conformity               │
├─────────────────────────────────────┤
│                                     │
│ Asset: MAEU2345678                  │
│                                     │
│ Select Type:                        │
│                                     │
│ ○ DAMAGED                           │
│ ○ MISSING                           │
│ ○ WRONG_QUANTITY                    │
│ ○ SEAL_BROKEN                       │
│ ○ TEMPERATURE_ISSUE                 │
│ ○ CONTAMINATION                     │
│ ○ OTHER                             │
│                                     │
│ [Cancel] [Next →]                   │
└─────────────────────────────────────┘
```

**Step 2: Enter Details**
```
┌─────────────────────────────────────┐
│ Non-Conformity Details              │
├─────────────────────────────────────┤
│                                     │
│ Type: DAMAGED                       │
│                                     │
│ Severity:                           │
│ ○ LOW                               │
│ ● MEDIUM                            │
│ ○ HIGH                              │
│ ○ CRITICAL                          │
│                                     │
│ Description:                        │
│ ┌─────────────────────────────────┐ │
│ │ Front-left corner impact        │ │
│ │ damage. Visible dent and        │ │
│ │ scratch marks.                  │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Damage Location:                    │
│ [Front-Left Corner ▼]               │
│                                     │
│ Estimated Loss:                     │
│ [500] [EUR ▼]                       │
│                                     │
│ [← Back] [Next →]                   │
└─────────────────────────────────────┘
```

**Step 3: Add Photos/Documents**
```
┌─────────────────────────────────────┐
│ Add Evidence                        │
├─────────────────────────────────────┤
│                                     │
│ 📷 Take Photo                       │
│ 📄 Upload PDF                       │
│ 📁 Choose from Gallery              │
│                                     │
│ Attached Files (2):                 │
│ ┌─────────────────────────────────┐ │
│ │ 🖼️ damage-photo-1.jpg          │ │
│ │    [View] [Remove]              │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🖼️ damage-photo-2.jpg          │ │
│ │    [View] [Remove]              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [← Back] [Submit Report]            │
└─────────────────────────────────────┘
```

**Step 4: Confirmation**
```
┌─────────────────────────────────────┐
│ ✅ Non-Conformity Reported          │
│                                     │
│ Report Number: NC-2025-001          │
│ Type: DAMAGED                       │
│ Severity: MEDIUM                    │
│                                     │
│ Status: Pending AI Validation       │
│                                     │
│ Your report has been submitted      │
│ and will be reviewed by the         │
│ backoffice team.                    │
│                                     │
│ [View Report] [Continue Order]     │
└─────────────────────────────────────┘
```

#### 2.2 Non-Conformity Types

**Available Types:**
- **DAMAGED** - Physical damage to asset
- **MISSING** - Asset not found or missing
- **WRONG_QUANTITY** - Quantity mismatch
- **SEAL_BROKEN** - Security seal compromised
- **TEMPERATURE_ISSUE** - Temperature out of range
- **CONTAMINATION** - Contamination detected
- **OTHER** - Other issues not listed

**Severity Levels:**
- **LOW** - Minor issue, no immediate action needed
- **MEDIUM** - Moderate issue, requires attention
- **HIGH** - Significant issue, urgent action needed
- **CRITICAL** - Critical issue, immediate escalation

#### 2.3 Quick Report (One-Tap)

**Quick Report Button:**
- Long-press on asset card
- Quick menu appears:
  - "Report Damage"
  - "Report Missing"
  - "Report Seal Issue"
- Pre-fills common fields
- Driver adds photos and submits

---

### 3. Document Upload

#### 3.1 Upload Capabilities

**Supported File Types:**
- **Images:** JPEG, PNG, HEIC (iOS), WebP
- **Documents:** PDF
- **Maximum Size:** 10 MB per file
- **Maximum Files:** 10 files per non-conformity

#### 3.2 Photo Capture

**Camera Integration:**
```
┌─────────────────────────────────────┐
│ Take Photo                          │
├─────────────────────────────────────┤
│                                     │
│     [Camera Preview Area]           │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ [📷 Capture] [🔄 Flip] [❌ Cancel]  │
│                                     │
│ [Use Photo] [Retake]                │
└─────────────────────────────────────┘
```

**Features:**
- **Auto-focus:** Tap to focus
- **Flash control:** Toggle flash on/off
- **Front/Back camera:** Switch between cameras
- **Image quality:** Automatic compression for mobile
- **GPS metadata:** Automatically captures location
- **Timestamp:** Automatically adds timestamp

#### 3.3 PDF Upload

**Upload Options:**
```
┌─────────────────────────────────────┐
│ Upload PDF                          │
├─────────────────────────────────────┤
│                                     │
│ Select Source:                      │
│                                     │
│ [📁 Device Storage]                 │
│ [☁️  Cloud Storage]                  │
│ [📧 Email Attachment]               │
│ [📷 Scan Document]                  │
│                                     │
│ Recent Files:                       │
│ • delivery-receipt-001.pdf          │
│ • inspection-report.pdf             │
│                                     │
│ [Cancel] [Select File]              │
└─────────────────────────────────────┘
```

**PDF Features:**
- **File picker:** Native file picker integration
- **Cloud storage:** Google Drive, iCloud, Dropbox
- **Document scanner:** Scan physical documents to PDF
- **Preview:** View PDF before upload
- **Progress indicator:** Shows upload progress

#### 3.4 Document Gallery View

**Attached Documents:**
```
┌─────────────────────────────────────┐
│ Documents (3)                       │
├─────────────────────────────────────┤
│                                     │
│ ┌─────┐ ┌─────┐ ┌─────┐            │
│ │ 📷  │ │ 📷  │ │ 📄  │            │
│ │     │ │     │ │     │            │
│ └─────┘ └─────┘ └─────┘            │
│ Photo 1 Photo 2  Receipt            │
│                                     │
│ [Add More] [View All]              │
└─────────────────────────────────────┘
```

**Document Actions:**
- **View:** Full-screen preview
- **Delete:** Remove document
- **Reorder:** Drag to reorder
- **Add Description:** Add caption/description

#### 3.5 Upload Progress

**Progress Indicator:**
```
┌─────────────────────────────────────┐
│ Uploading...                        │
├─────────────────────────────────────┤
│                                     │
│ damage-photo-1.jpg                  │
│ ████████████░░░░░░░░ 60%            │
│                                     │
│ [Cancel Upload]                     │
└─────────────────────────────────────┘
```

**Features:**
- **Real-time progress:** Shows upload percentage
- **Multiple uploads:** Queue multiple files
- **Retry on failure:** Automatic retry on network error
- **Background upload:** Continue uploading in background

---

### 4. Comment and Notes System

#### 4.1 Add Comment to Non-Conformity

**Comment Entry:**
```
┌─────────────────────────────────────┐
│ Add Comment                         │
├─────────────────────────────────────┤
│                                     │
│ Non-Conformity: NC-2025-001         │
│ Type: DAMAGED                       │
│                                     │
│ Your Comment:                       │
│ ┌─────────────────────────────────┐ │
│ │ Customer was present during    │ │
│ │ inspection. Confirmed damage   │ │
│ │ was pre-existing.              │ │
│ │                                 │ │
│ │ Weather: Clear, dry             │ │
│ │ Time: 14:30                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Attach Photo: [📷]                  │
│                                     │
│ [Cancel] [Post Comment]             │
└─────────────────────────────────────┘
```

**Comment Features:**
- **Rich text:** Basic formatting (bold, italic)
- **Photo attachment:** Attach photo to comment
- **Timestamp:** Automatic timestamp
- **Location:** Optional GPS location
- **Edit/Delete:** Edit or delete own comments

#### 4.2 Comment Thread View

**Comments List:**
```
┌─────────────────────────────────────┐
│ Comments (3)                        │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 Jan van Dijk                 │ │
│ │ 14:35 - Today                  │ │
│ │                                 │ │
│ │ Customer confirmed pre-existing │ │
│ │ damage. Weather clear.          │ │
│ │                                 │ │
│ │ [View Photo] [Reply]           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 Backoffice Team               │ │
│ │ 15:20 - Today                  │ │
│ │                                 │ │
│ │ Thank you for the update. We'll │ │
│ │ follow up with customer.        │ │
│ │                                 │ │
│ │ [Reply]                          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Add Comment]                        │
└─────────────────────────────────────┘
```

#### 4.3 Notes Field (Additional Details)

**Detailed Notes:**
```
┌─────────────────────────────────────┐
│ Additional Notes                    │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Enter any additional            │ │
│ │ information, observations, or   │ │
│ │ context that might be helpful   │ │
│ │ for review.                     │ │
│ │                                 │ │
│ │ (Max 4000 characters)           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Character count: 0/4000             │
│                                     │
│ [Save Notes] [Clear]               │
└─────────────────────────────────────┘
```

**Notes Features:**
- **Character limit:** 4000 characters
- **Auto-save:** Auto-saves as you type
- **Draft mode:** Saves draft if not submitted
- **Formatting:** Basic text formatting support

---

## 📱 Mobile-First Design

### 5.1 Responsive Layout

#### 5.1.1 Screen Sizes

**Small Phones (320px - 480px):**
- Single column layout
- Stacked cards
- Large touch targets (min 44x44px)
- Bottom navigation bar

**Large Phones (481px - 768px):**
- Single column with wider cards
- Side-by-side buttons where appropriate
- Tab navigation

**Tablets (769px+):**
- Two-column layout (if space allows)
- Sidebar navigation
- Larger cards and images

#### 5.1.2 Touch Targets

**Minimum Sizes:**
- Buttons: 44x44px minimum
- Links: 44px height minimum
- Input fields: 44px height
- Checkboxes/Radio: 44x44px
- Swipe areas: Full card width

**Spacing:**
- Minimum 8px between touch targets
- Comfortable padding (16px) around content
- Generous margins for thumb reach

#### 5.1.3 Navigation Patterns

**Bottom Navigation (Primary):**
```
┌─────────────────────────────────────┐
│                                     │
│         [Main Content]              │
│                                     │
├─────────────────────────────────────┤
│ 🏠  📦  ⚠️  👤                      │
│ Home Orders Issues Profile          │
└─────────────────────────────────────┘
```

**Top Navigation (Secondary):**
- Back button (always visible)
- Page title
- Action button (context-dependent)

**Swipe Gestures:**
- Swipe left: Mark complete
- Swipe right: Report issue
- Pull down: Refresh
- Swipe up: Show more details

### 5.2 Visual Design

#### 5.2.1 Color Scheme

**Primary Colors:**
- **Primary:** #007bff (Blue) - Actions, links
- **Success:** #28a745 (Green) - Completed, success
- **Warning:** #ffc107 (Yellow) - Warnings, pending
- **Danger:** #dc3545 (Red) - Errors, critical issues
- **Info:** #17a2b8 (Cyan) - Information

**Background:**
- **Light:** #ffffff (White) - Main background
- **Light Gray:** #f8f9fa - Card backgrounds
- **Dark:** #212529 - Text on light background

#### 5.2.2 Typography

**Font Sizes:**
- **H1 (Page Title):** 24px, Bold
- **H2 (Section Title):** 20px, Semi-bold
- **H3 (Card Title):** 18px, Semi-bold
- **Body:** 16px, Regular
- **Small:** 14px, Regular
- **Caption:** 12px, Regular

**Font Family:**
- System fonts (San Francisco on iOS, Roboto on Android)
- Fallback: Arial, sans-serif

#### 5.2.3 Icons

**Icon Set:**
- Material Icons or Font Awesome
- Consistent sizing (24px default)
- High contrast for visibility
- Accessible (ARIA labels)

**Common Icons:**
- 📦 Order/Asset
- 🚛 Trip/Vehicle
- 📍 Location/GPS
- ⚠️ Non-Conformity
- 📷 Camera/Photo
- 📄 Document/PDF
- ✅ Complete/Success
- ❌ Cancel/Error
- 💬 Comment/Notes

### 5.3 Performance Optimization

#### 5.3.1 Image Optimization

**Compression:**
- Automatic image compression before upload
- Target: < 2MB per image
- Maintain quality: 85% JPEG quality
- Resize if > 2048px on longest side

**Lazy Loading:**
- Load images as user scrolls
- Placeholder while loading
- Progressive JPEG loading

#### 5.3.2 Caching

**Offline Cache:**
- Cache order data locally
- Cache images for offline viewing
- Cache form data (draft mode)
- Sync when online

**Service Worker:**
- Cache static assets
- Offline fallback page
- Background sync for uploads

#### 5.3.3 Network Optimization

**Request Batching:**
- Batch multiple API calls
- Reduce round trips
- Compress JSON responses

**Progressive Enhancement:**
- Core functionality works offline
- Enhanced features require online
- Graceful degradation

---

## 🛠️ Technical Implementation

### 6.1 APEX Mobile Pages

#### 6.1.1 Order List Page (Page 200)

**Page Type:** Mobile - List View

**Regions:**
1. **Header Region** - Title, filter button, sync status
2. **Order Cards Region** - Cards with order information
3. **Bottom Navigation** - Home, Orders, Issues, Profile

**Page Items:**
- `P200_DRIVER_SEQ` - Hidden, current driver
- `P200_FILTER_STATUS` - Select list (All, Active, Completed)
- `P200_SEARCH` - Search field

**Dynamic Actions:**
- **Card Tap** → Navigate to Order Detail
- **Swipe Left** → Mark Complete (with confirmation)
- **Swipe Right** → Quick Report Non-Conformity
- **Pull to Refresh** → Refresh order list

#### 6.1.2 Order Detail Page (Page 201)

**Page Type:** Mobile - Form

**Regions:**
1. **Order Header** - Order info, customer, address
2. **Asset List** - Cards for each asset
3. **Action Buttons** - Complete Order, Save for Later
4. **GPS Map** - Embedded map (optional)

**Page Items:**
- `P201_ORDER_SEQ` - Hidden, from page 200
- `P201_CURRENT_LAT` - Hidden, GPS latitude
- `P201_CURRENT_LON` - Hidden, GPS longitude

#### 6.1.3 Report Non-Conformity Page (Page 202)

**Page Type:** Mobile - Wizard (Multi-step)

**Step 1: Type Selection**
- Radio button group for non-conformity type
- Next button

**Step 2: Details Entry**
- Severity select list
- Description text area
- Damage location select list
- Estimated loss number field

**Step 3: Document Upload**
- Camera button
- File upload button
- Document gallery
- Submit button

**Page Items:**
- `P202_STOPASSET_SEQ` - Hidden, asset being reported
- `P202_NONCONF_TYPE` - Select list
- `P202_SEVERITY` - Select list
- `P202_DESCRIPTION` - Text area
- `P202_DAMAGE_LOCATION` - Select list
- `P202_ESTIMATED_LOSS` - Number field
- `P202_DOCUMENTS` - File upload (multiple)

#### 6.1.4 Document Upload Page (Page 203)

**Page Type:** Mobile - Gallery

**Regions:**
1. **Upload Options** - Camera, File, Gallery buttons
2. **Document Gallery** - Grid of uploaded documents
3. **Upload Progress** - Progress bars for active uploads

**Page Items:**
- `P203_NONCONF_SEQ` - Hidden, non-conformity
- `P203_UPLOADED_FILES` - File upload (multiple)

#### 6.1.5 Comments Page (Page 204)

**Page Type:** Mobile - Comments Thread

**Regions:**
1. **Comment List** - Chronological comments
2. **Add Comment** - Text area and submit button

**Page Items:**
- `P204_NONCONF_SEQ` - Hidden, non-conformity
- `P204_COMMENT_TEXT` - Text area
- `P204_COMMENT_PHOTO` - File upload (optional)

### 6.2 JavaScript Functions

#### 6.2.1 Camera Integration

```javascript
// Capture photo using device camera
function capturePhoto() {
  // Check if camera API available
  if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    navigator.mediaDevices.getUserMedia({ video: true })
      .then(function(stream) {
        // Show camera preview
        showCameraPreview(stream);
      })
      .catch(function(error) {
        console.error('Camera access denied:', error);
        apex.message.showErrors(['Camera access is required to take photos']);
      });
  } else {
    // Fallback to file input
    $('#file-input').click();
  }
}

// Take photo from preview
function takePhotoFromPreview(videoElement) {
  var canvas = document.createElement('canvas');
  canvas.width = videoElement.videoWidth;
  canvas.height = videoElement.videoHeight;
  var ctx = canvas.getContext('2d');
  ctx.drawImage(videoElement, 0, 0);
  
  // Convert to blob
  canvas.toBlob(function(blob) {
    // Upload photo
    uploadPhoto(blob);
  }, 'image/jpeg', 0.85);
}
```

#### 6.2.2 File Upload with Progress

```javascript
// Upload file with progress tracking
function uploadFile(file, nonconfSeq) {
  var formData = new FormData();
  formData.append('file', file);
  formData.append('nonconf_seq', nonconfSeq);
  formData.append('document_type', getDocumentType(file));
  
  // Show progress bar
  var progressId = 'progress-' + Date.now();
  showProgressBar(progressId, file.name);
  
  // Upload using AJAX
  $.ajax({
    url: apex.util.makeApplicationUrl({
      x01: 'UPLOAD_DOCUMENT',
      x02: nonconfSeq
    }),
    type: 'POST',
    data: formData,
    processData: false,
    contentType: false,
    xhr: function() {
      var xhr = new window.XMLHttpRequest();
      xhr.upload.addEventListener('progress', function(e) {
        if (e.lengthComputable) {
          var percentComplete = (e.loaded / e.total) * 100;
          updateProgressBar(progressId, percentComplete);
        }
      }, false);
      return xhr;
    },
    success: function(response) {
      hideProgressBar(progressId);
      addDocumentToGallery(response.document_seq, file.name);
      apex.message.showSuccess('File uploaded successfully');
    },
    error: function(xhr, status, error) {
      hideProgressBar(progressId);
      apex.message.showErrors(['Upload failed: ' + error]);
    }
  });
}
```

#### 6.2.3 Swipe Gestures

```javascript
// Handle swipe gestures on order cards
function initSwipeGestures() {
  var startX, startY, distX, distY;
  var threshold = 50; // Minimum swipe distance
  var restraint = 100; // Maximum perpendicular distance
  var allowedTime = 300; // Maximum swipe time (ms)
  var startTime;
  
  $('.order-card').on('touchstart', function(e) {
    var touch = e.originalEvent.touches[0];
    startX = touch.pageX;
    startY = touch.pageY;
    startTime = new Date().getTime();
    e.preventDefault();
  });
  
  $('.order-card').on('touchend', function(e) {
    var touch = e.originalEvent.changedTouches[0];
    distX = touch.pageX - startX;
    distY = touch.pageY - startY;
    var elapsedTime = new Date().getTime() - startTime;
    
    if (elapsedTime <= allowedTime) {
      if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint) {
        if (distX > 0) {
          // Swipe right - Report issue
          quickReportNonConformity($(this).data('order-seq'));
        } else {
          // Swipe left - Mark complete
          markOrderComplete($(this).data('order-seq'));
        }
      }
    }
    e.preventDefault();
  });
}

// Initialize on page load
$(document).ready(function() {
  initSwipeGestures();
});
```

#### 6.2.4 GPS Location Capture

```javascript
// Get current GPS location
function getCurrentLocation() {
  return new Promise(function(resolve, reject) {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        function(position) {
          resolve({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy
          });
        },
        function(error) {
          console.error('GPS error:', error);
          reject(error);
        },
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 0
        }
      );
    } else {
      reject(new Error('Geolocation not supported'));
    }
  });
}

// Capture location for non-conformity
function captureLocationForNonConf() {
  getCurrentLocation()
    .then(function(location) {
      apex.item('P202_GPS_LAT').setValue(location.latitude);
      apex.item('P202_GPS_LON').setValue(location.longitude);
      apex.message.showSuccess('Location captured');
    })
    .catch(function(error) {
      apex.message.showInfo('Location capture failed. You can continue without location.');
    });
}
```

#### 6.2.5 Offline Detection and Sync

```javascript
// Check online/offline status
function checkOnlineStatus() {
  if (navigator.onLine) {
    $('.offline-indicator').hide();
    return true;
  } else {
    $('.offline-indicator').show();
    return false;
  }
}

// Sync pending uploads when online
function syncPendingUploads() {
  if (!checkOnlineStatus()) {
    return;
  }
  
  // Get pending uploads from local storage
  var pendingUploads = JSON.parse(localStorage.getItem('pending_uploads') || '[]');
  
  if (pendingUploads.length > 0) {
    apex.message.showInfo('Syncing ' + pendingUploads.length + ' pending uploads...');
    
    pendingUploads.forEach(function(upload) {
      uploadFile(upload.file, upload.nonconf_seq)
        .then(function() {
          // Remove from pending list
          var updated = pendingUploads.filter(function(u) {
            return u.id !== upload.id;
          });
          localStorage.setItem('pending_uploads', JSON.stringify(updated));
        })
        .catch(function(error) {
          console.error('Sync failed for upload:', upload.id);
        });
    });
  }
}

// Monitor online/offline events
window.addEventListener('online', function() {
  apex.message.showSuccess('Connection restored. Syncing...');
  syncPendingUploads();
});

window.addEventListener('offline', function() {
  apex.message.showWarning('You are offline. Changes will be saved locally.');
});
```

### 6.3 PL/SQL Processes

#### 6.3.1 Complete Order Process

```sql
-- Process: COMPLETE_ORDER
-- Type: PL/SQL Code
DECLARE
  v_order_seq NUMBER := :P201_ORDER_SEQ;
  v_driver_seq NUMBER := :P200_DRIVER_SEQ;
  v_user VARCHAR2(200) := NVL(v('APP_USER'), USER);
  v_validation_errors VARCHAR2(4000);
BEGIN
  -- Validate all assets are processed
  FOR rec IN (
    SELECT 
      sa.seq,
      sa.assetnumber,
      sa.deliverystatus
    FROM stopassets sa
    JOIN stops s ON s.seq = sa.stopseq
    JOIN trips t ON t.seq = s.tripseq
    WHERE t.orderseq = v_order_seq
    AND sa.deliverystatus NOT IN ('DELIVERED', 'REJECTED', 'NON_CONFORMITY')
  ) LOOP
    v_validation_errors := v_validation_errors || 
      'Asset ' || rec.assetnumber || ' is not marked as delivered or rejected. ';
  END LOOP;
  
  -- Check for required documents (if applicable)
  -- Add validation logic here
  
  -- If validation passes, complete order
  IF v_validation_errors IS NULL THEN
    -- Update order status
    UPDATE orders
    SET status = 'COMPLETED',
        updatedate = CURRENT_TIMESTAMP,
        updateuser = v_user,
        update_timezone = SESSIONTIMEZONE
    WHERE seq = v_order_seq
    AND provisionerseq = NVL(v('PROVISIONERSEQ'), 
                            xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));
    
    -- Update trip status
    UPDATE trips
    SET status = 'COMPLETED',
        actualenddate = CURRENT_TIMESTAMP,
        updatedate = CURRENT_TIMESTAMP,
        updateuser = v_user,
        update_timezone = SESSIONTIMEZONE
    WHERE orderseq = v_order_seq
    AND provisionerseq = NVL(v('PROVISIONERSEQ'), 
                             xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));
    
    -- Update stops status
    UPDATE stops
    SET status = 'COMPLETED',
        updatedate = CURRENT_TIMESTAMP,
        updateuser = v_user,
        update_timezone = SESSIONTIMEZONE
    WHERE tripseq IN (
      SELECT seq FROM trips 
      WHERE orderseq = v_order_seq
    )
    AND status != 'COMPLETED'
    AND provisionerseq = NVL(v('PROVISIONERSEQ'), 
                            xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));
    
    apex_application.g_print_success_message := 'Order completed successfully';
  ELSE
    apex_application.g_print_success_message := 'Validation failed: ' || v_validation_errors;
    apex_application.g_print_success_message_type := 'ERROR';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    xxsd_admin.pkg_error.p_logerror(
      'COMPLETE_ORDER',
      SQLCODE,
      'Error completing order: ' || SQLERRM
    );
    apex_application.g_print_success_message := 'Error completing order: ' || SQLERRM;
    apex_application.g_print_success_message_type := 'ERROR';
END;
```

#### 6.3.2 Create Non-Conformity Process

```sql
-- Process: CREATE_NONCONFORMITY
-- Type: PL/SQL Code
DECLARE
  v_stopasset_seq NUMBER := :P202_STOPASSET_SEQ;
  v_type VARCHAR2(50) := :P202_NONCONF_TYPE;
  v_severity VARCHAR2(20) := :P202_SEVERITY;
  v_description VARCHAR2(4000) := :P202_DESCRIPTION;
  v_damage_location VARCHAR2(200) := :P202_DAMAGE_LOCATION;
  v_estimated_loss NUMBER := :P202_ESTIMATED_LOSS;
  v_user VARCHAR2(200) := NVL(v('APP_USER'), USER);
  v_nonconf_seq NUMBER;
  v_nonconf_number VARCHAR2(50);
BEGIN
  -- Generate non-conformity number
  v_nonconf_number := 'NC-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
                      LPAD(nonconformities_seq.NEXTVAL, 3, '0');
  
  -- Get GPS location if provided
  -- (stored in separate table or metadata)
  
  -- Insert non-conformity
  INSERT INTO nonconformities (
    seq,
    stopassetseq,
    nonconformitynumber,
    nonconformitytype,
    severity,
    description,
    damagelocation,
    estimatedloss,
    reportedby,
    reporteddate,
    reportedrole,
    resolutionstatus,
    provisionerseq,
    createdate,
    createuser,
    create_timezone
  ) VALUES (
    nonconformities_seq.NEXTVAL,
    v_stopasset_seq,
    v_nonconf_number,
    v_type,
    v_severity,
    v_description,
    v_damage_location,
    v_estimated_loss,
    v_user,
    CURRENT_TIMESTAMP,
    'DRIVER',
    'OPEN',
    NVL(v('PROVISIONERSEQ'), 
        xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ')),
    CURRENT_TIMESTAMP,
    v_user,
    SESSIONTIMEZONE
  )
  RETURNING seq INTO v_nonconf_seq;
  
  -- Update stop asset status
  UPDATE stopassets
  SET deliverystatus = 'NON_CONFORMITY',
      updatedate = CURRENT_TIMESTAMP,
      updateuser = v_user,
      update_timezone = SESSIONTIMEZONE
  WHERE seq = v_stopasset_seq;
  
  -- Trigger AI check (if configured)
  -- INSERT INTO aichecks (...)
  
  apex_application.g_print_success_message := 
    'Non-conformity reported: ' || v_nonconf_number;
  
  -- Return non-conformity seq for document upload
  :P202_NONCONF_SEQ := v_nonconf_seq;
EXCEPTION
  WHEN OTHERS THEN
    xxsd_admin.pkg_error.p_logerror(
      'CREATE_NONCONFORMITY',
      SQLCODE,
      'Error creating non-conformity: ' || SQLERRM
    );
    apex_application.g_print_success_message := 
      'Error reporting non-conformity: ' || SQLERRM;
    apex_application.g_print_success_message_type := 'ERROR';
END;
```

#### 6.3.3 Upload Document Process

```sql
-- Process: UPLOAD_DOCUMENT
-- Type: Multi-Row File Upload
DECLARE
  v_nonconf_seq NUMBER := :P203_NONCONF_SEQ;
  v_user VARCHAR2(200) := NVL(v('APP_USER'), USER);
  v_document_seq NUMBER;
  v_filename VARCHAR2(500);
  v_file_content BLOB;
  v_file_size NUMBER;
  v_mime_type VARCHAR2(100);
BEGIN
  -- Process each uploaded file
  FOR i IN 1..apex_application.g_f01.COUNT LOOP
    v_filename := apex_application.g_f01(i);
    v_file_content := apex_application.g_f02(i);
    v_file_size := DBMS_LOB.getlength(v_file_content);
    v_mime_type := apex_application.g_f03(i);
    
    -- Determine document type from MIME type
    DECLARE
      v_doc_type VARCHAR2(50);
    BEGIN
      IF v_mime_type LIKE 'image/%' THEN
        v_doc_type := 'PHOTO';
      ELSIF v_mime_type = 'application/pdf' THEN
        v_doc_type := 'PDF';
      ELSE
        v_doc_type := 'OTHER';
      END IF;
      
      -- Insert document
      INSERT INTO documents (
        seq,
        stopassetseq,
        nonconformityseq,
        documentnumber,
        documenttype,
        filename,
        filecontent,
        filesize,
        mime_type,
        uploaddate,
        uploadedby,
        provisionerseq,
        createdate,
        createuser,
        create_timezone
      ) VALUES (
        documents_seq.NEXTVAL,
        (SELECT stopassetseq FROM nonconformities WHERE seq = v_nonconf_seq),
        v_nonconf_seq,
        'DOC-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || 
        LPAD(documents_seq.CURRVAL + 1, 4, '0'),
        v_doc_type,
        v_filename,
        v_file_content,
        v_file_size,
        v_mime_type,
        CURRENT_TIMESTAMP,
        v_user,
        NVL(v('PROVISIONERSEQ'), 
            xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ')),
        CURRENT_TIMESTAMP,
        v_user,
        SESSIONTIMEZONE
      )
      RETURNING seq INTO v_document_seq;
      
      -- Trigger AI check for photos (if non-conformity related)
      IF v_doc_type = 'PHOTO' AND v_nonconf_seq IS NOT NULL THEN
        INSERT INTO aichecks (
          seq,
          stopseq,
          stopassetseq,
          nonconformityseq,
          documentseq,
          checknumber,
          checktype,
          status,
          provisionerseq,
          createdate,
          createuser,
          create_timezone
        ) VALUES (
          aichecks_seq.NEXTVAL,
          (SELECT s.seq 
           FROM stops s
           JOIN stopassets sa ON sa.stopseq = s.seq
           JOIN nonconformities nc ON nc.stopassetseq = sa.seq
           WHERE nc.seq = v_nonconf_seq),
          (SELECT stopassetseq FROM nonconformities WHERE seq = v_nonconf_seq),
          v_nonconf_seq,
          v_document_seq,
          'CHK-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || 
          LPAD(aichecks_seq.CURRVAL + 1, 4, '0'),
          'NON_CONF_CHECK',
          'PENDING',
          NVL(v('PROVISIONERSEQ'), 
              xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ')),
          CURRENT_TIMESTAMP,
          v_user,
          SESSIONTIMEZONE
        );
      END IF;
    END;
  END LOOP;
  
  apex_application.g_print_success_message := 
    'Documents uploaded successfully';
EXCEPTION
  WHEN OTHERS THEN
    xxsd_admin.pkg_error.p_logerror(
      'UPLOAD_DOCUMENT',
      SQLCODE,
      'Error uploading document: ' || SQLERRM
    );
    apex_application.g_print_success_message := 
      'Error uploading document: ' || SQLERRM;
    apex_application.g_print_success_message_type := 'ERROR';
END;
```

#### 6.3.4 Add Comment Process

```sql
-- Process: ADD_COMMENT
-- Type: PL/SQL Code
DECLARE
  v_nonconf_seq NUMBER := :P204_NONCONF_SEQ;
  v_comment_text VARCHAR2(4000) := :P204_COMMENT_TEXT;
  v_user VARCHAR2(200) := NVL(v('APP_USER'), USER);
BEGIN
  -- Store comment in detaileddescription or separate comments table
  -- For now, append to detaileddescription
  UPDATE nonconformities
  SET detaileddescription = NVL(detaileddescription, '') || 
      CHR(10) || CHR(10) || 
      '[' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || '] ' || 
      v_user || ': ' || CHR(10) || 
      v_comment_text,
      updatedate = CURRENT_TIMESTAMP,
      updateuser = v_user,
      update_timezone = SESSIONTIMEZONE
  WHERE seq = v_nonconf_seq
  AND provisionerseq = NVL(v('PROVISIONERSEQ'), 
                          xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));
  
  apex_application.g_print_success_message := 'Comment added successfully';
EXCEPTION
  WHEN OTHERS THEN
    xxsd_admin.pkg_error.p_logerror(
      'ADD_COMMENT',
      SQLCODE,
      'Error adding comment: ' || SQLERRM
    );
    apex_application.g_print_success_message := 'Error adding comment: ' || SQLERRM;
    apex_application.g_print_success_message_type := 'ERROR';
END;
```

---

## 🔄 User Workflows

### 7.1 Complete Order Workflow

1. **Driver opens app** → Sees list of assigned orders
2. **Driver selects order** → Views order details and assets
3. **Driver arrives at stop** → GPS location captured
4. **Driver marks assets** → Delivered or Non-Conformity
5. **Driver completes order** → All assets processed
6. **System validates** → Checks all requirements met
7. **Order completed** → Status updated, confirmation shown

### 7.2 Report Non-Conformity Workflow

1. **Driver notices issue** → Taps "Report Issue" on asset
2. **Select type** → DAMAGED, MISSING, SEAL_BROKEN, etc.
3. **Enter details** → Severity, description, location, loss estimate
4. **Take photos** → Capture evidence with camera
5. **Upload documents** → Add PDFs if available
6. **Add comments** → Additional context and observations
7. **Submit report** → Non-conformity created, AI check triggered
8. **Confirmation** → Report number shown, status pending

### 7.3 Document Upload Workflow

1. **Driver needs to upload document** → Taps upload button
2. **Choose source** → Camera, Gallery, or File
3. **Capture/Select** → Take photo or select file
4. **Preview** → Review before upload
5. **Upload** → Progress indicator shown
6. **Confirmation** → Document added to gallery
7. **AI Processing** → If photo, AI check automatically triggered

### 7.4 Add Comment Workflow

1. **Driver wants to add comment** → Opens comments section
2. **View existing comments** → See previous comments from driver/backoffice
3. **Type comment** → Enter text in comment field
4. **Optional photo** → Attach photo to comment
5. **Post comment** → Comment added to thread
6. **Notification** → Backoffice notified of new comment

---

## 📴 Offline Capability

### 8.1 Offline Features

**Available Offline:**
- View cached orders
- View cached documents
- Fill out non-conformity forms
- Take photos (stored locally)
- Add comments (stored locally)

**Requires Online:**
- Submit non-conformity reports
- Upload documents
- Complete orders
- Sync data

### 8.2 Offline Data Storage

**Local Storage:**
- Order data (JSON)
- Draft non-conformity reports
- Pending document uploads
- Pending comments
- GPS coordinates

**IndexedDB:**
- Document thumbnails
- Cached images
- Large data objects

### 8.3 Sync Strategy

**When Online:**
1. Check for pending items
2. Upload in background
3. Update local cache
4. Clear pending queue

**Conflict Resolution:**
- Server timestamp wins
- Last write wins for status updates
- Merge comments chronologically

---

## 🔐 Security Considerations

### 9.1 Authentication
- Driver login required
- Session timeout (30 minutes inactive)
- Biometric authentication (optional)

### 9.2 Authorization
- Drivers can only see assigned orders
- Drivers can only report non-conformities for their trips
- Data filtered by PROVISIONERSEQ

### 9.3 Data Protection
- Encrypt sensitive data in transit (HTTPS)
- Secure file uploads
- Validate file types and sizes
- Sanitize user inputs

---

## 📊 Analytics and Tracking

### 10.1 Usage Metrics
- Orders completed per driver
- Non-conformities reported per driver
- Average time to complete order
- Document upload success rate

### 10.2 Performance Metrics
- Page load times
- Upload success rates
- Offline usage frequency
- Error rates

---

## 🎯 Success Criteria

- ✅ Orders can be completed from mobile device
- ✅ Non-conformities can be reported with photos
- ✅ Documents (PDF, images) can be uploaded
- ✅ Comments can be added to non-conformities
- ✅ Mobile-optimized design works on all screen sizes
- ✅ Offline capability for core features
- ✅ Fast performance (< 2s page load)
- ✅ Intuitive touch-friendly interface

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-19  
**Author:** Hackathon Group 3  
**Status:** Concept - Ready for Implementation

