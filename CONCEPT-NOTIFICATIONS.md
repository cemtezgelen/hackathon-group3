# Notification System - Concept Document

**Version:** 1.0  
**Date:** 2025-12-19  
**Project:** Hackathon Group 3 - AI Document Check  
**Application Type:** Universal Notification System (APEX Backoffice & Driver Apps)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Core Features](#core-features)
4. [Notification Creation Procedure](#notification-creation-procedure)
5. [APEX Client-Side Polling](#apex-client-side-polling)
6. [Toast Notification Display](#toast-notification-display)
7. [Sound Notifications](#sound-notifications)
8. [AI Integration](#ai-integration)
9. [Technical Implementation](#technical-implementation)
10. [User Workflows](#user-workflows)
11. [Performance Considerations](#performance-considerations)

---

## 🎯 Overview

### Purpose
The Notification System provides a unified, real-time notification mechanism for both Backoffice and Driver APEX applications. It enables any system component (especially AI processing) to create notifications that are automatically displayed to users via toast messages with sound alerts.

### Key Value Propositions
- ✅ **Single Procedure Interface** - One procedure to create any notification
- ✅ **Real-Time Delivery** - Polling-based instant notification delivery
- ✅ **Toast Display** - Non-intrusive toast messages in APEX
- ✅ **Sound Alerts** - Audio feedback for important notifications
- ✅ **AI Integration** - Seamless integration with AI processing workflows
- ✅ **Multi-Channel Support** - IN_APP, EMAIL, PUSH, SMS (extensible)

### Target Use Cases
- **AI Processing Errors** - When AI validation fails or encounters errors
- **AI Validation Results** - When AI completes analysis (PASSED/FAILED)
- **Non-Conformity Alerts** - Critical non-conformities requiring attention
- **Order Status Updates** - Important order status changes
- **System Warnings** - System-level warnings and errors

---

## 🏗️ System Architecture

### 2.1 Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Notification System                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐         ┌──────────────┐                │
│  │   AI Layer   │─────────▶│  Notification│                │
│  │  (PL/SQL)    │         │   Procedure  │                │
│  └──────────────┘         └──────┬───────┘                │
│                                   │                        │
│  ┌──────────────┐                 │                        │
│  │ Other Systems│─────────▶       │                        │
│  │  (PL/SQL)    │                 │                        │
│  └──────────────┘                 ▼                        │
│                          ┌──────────────┐                 │
│                          │ NOTIFICATIONS│                 │
│                          │    Table     │                 │
│                          └──────┬───────┘                 │
│                                 │                        │
│                                 │                        │
│  ┌─────────────────────────────┼─────────────────────┐  │
│  │                               │                     │  │
│  ▼                               ▼                     ▼  │
│  ┌──────────────┐    ┌──────────────┐   ┌──────────┐ │
│  │  Backoffice   │    │ Driver App   │   │  Email   │ │
│  │  APEX App     │    │ APEX App     │   │  Service │ │
│  │               │    │              │   │          │ │
│  │  Polling      │    │  Polling     │   │  (Future)│ │
│  │  (30s)        │    │  (30s)       │   │          │ │
│  └──────────────┘    └──────────────┘   └──────────┘ │
│                                                       │
└───────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

1. **Notification Creation:**
   - AI process or system component calls notification procedure
   - Procedure inserts record into NOTIFICATIONS table
   - Record marked as `isread = 'N'` and `channel = 'IN_APP'`

2. **Notification Polling:**
   - APEX client-side JavaScript polls every X seconds
   - Queries for unread notifications (`isread = 'N'`)
   - Filters by current user and PROVISIONERSEQ

3. **Notification Display:**
   - New notifications displayed as toast messages
   - Sound played based on notification type/priority
   - Notification marked as read after display

4. **Notification Tracking:**
   - Read status updated in database
   - Read timestamp recorded
   - Notification history maintained

---

## 🎨 Core Features

### 3.1 Unified Notification Procedure

**Single Entry Point:**
- One procedure handles all notification creation
- Flexible parameters for different notification types
- Automatic recipient resolution
- Context-aware message generation

### 3.2 Real-Time Polling

**Client-Side Polling:**
- Configurable polling interval (default: 30 seconds)
- Efficient query (only unread notifications)
- Automatic start/stop based on page visibility
- Background polling when tab is inactive

### 3.3 Toast Notification Display

**Toast Features:**
- Non-intrusive popup messages
- Auto-dismiss after X seconds (configurable)
- Click to view details or navigate
- Stack multiple notifications
- Priority-based styling (color, icon)

### 3.4 Sound Notifications

**Audio Feedback:**
- Different sounds for different notification types
- Priority-based volume/urgency
- User-configurable (enable/disable)
- Browser notification API integration

### 3.5 AI Integration

**AI-Specific Features:**
- Automatic notification on AI errors
- Notification on AI validation completion
- Confidence score in notification message
- Link to AI check details

---

## 🔧 Notification Creation Procedure

### 4.1 Procedure Signature

```sql
PROCEDURE p_create_notification(
  p_notification_type   IN VARCHAR2,  -- WARNING, ERROR, INFO, SUCCESS
  p_priority            IN VARCHAR2,  -- LOW, NORMAL, HIGH, URGENT
  p_channel             IN VARCHAR2,  -- IN_APP, EMAIL, PUSH, SMS
  p_subject             IN VARCHAR2,  -- Notification subject/title
  p_message             IN VARCHAR2,  -- Short message (toast display)
  p_message_body        IN CLOB,       -- Detailed message (optional)
  p_recipient_user       IN VARCHAR2,  -- Target user (APP_USER if NULL)
  p_recipient_email      IN VARCHAR2,  -- Email (optional, for EMAIL channel)
  p_recipient_phone      IN VARCHAR2,  -- Phone (optional, for SMS channel)
  p_ai_check_seq         IN NUMBER DEFAULT NULL,  -- Related AI check
  p_nonconformity_seq    IN NUMBER DEFAULT NULL,  -- Related non-conformity
  p_order_seq            IN NUMBER DEFAULT NULL,  -- Related order (for context)
  p_action_url           IN VARCHAR2 DEFAULT NULL,  -- URL to navigate on click
  p_provisionerseq       IN NUMBER DEFAULT NULL   -- Auto-resolved if NULL
)
```

### 4.2 Procedure Implementation

```sql
-- AI generated code START - 2025-12-19 16:00
CREATE OR REPLACE PACKAGE cemtezgelen.pkg_notification AS

  -- <HACKATHON-001>
  -- Create notification with unified interface
  -- Supports AI errors, validation results, and general notifications
  PROCEDURE p_create_notification(
    p_notification_type   IN VARCHAR2,
    p_priority            IN VARCHAR2 DEFAULT 'NORMAL',
    p_channel             IN VARCHAR2 DEFAULT 'IN_APP',
    p_subject             IN VARCHAR2,
    p_message             IN VARCHAR2,
    p_message_body        IN CLOB DEFAULT NULL,
    p_recipient_user       IN VARCHAR2 DEFAULT NULL,
    p_recipient_email      IN VARCHAR2 DEFAULT NULL,
    p_recipient_phone      IN VARCHAR2 DEFAULT NULL,
    p_ai_check_seq         IN NUMBER DEFAULT NULL,
    p_nonconformity_seq    IN NUMBER DEFAULT NULL,
    p_order_seq            IN NUMBER DEFAULT NULL,
    p_action_url           IN VARCHAR2 DEFAULT NULL,
    p_provisionerseq       IN NUMBER DEFAULT NULL
  );

END pkg_notification;
/

CREATE OR REPLACE PACKAGE BODY cemtezgelen.pkg_notification AS

  PROCEDURE p_create_notification(
    p_notification_type   IN VARCHAR2,
    p_priority            IN VARCHAR2 DEFAULT 'NORMAL',
    p_channel             IN VARCHAR2 DEFAULT 'IN_APP',
    p_subject             IN VARCHAR2,
    p_message             IN VARCHAR2,
    p_message_body        IN CLOB DEFAULT NULL,
    p_recipient_user       IN VARCHAR2 DEFAULT NULL,
    p_recipient_email      IN VARCHAR2 DEFAULT NULL,
    p_recipient_phone      IN VARCHAR2 DEFAULT NULL,
    p_ai_check_seq         IN NUMBER DEFAULT NULL,
    p_nonconformity_seq    IN NUMBER DEFAULT NULL,
    p_order_seq            IN NUMBER DEFAULT NULL,
    p_action_url           IN VARCHAR2 DEFAULT NULL,
    p_provisionerseq       IN NUMBER DEFAULT NULL
  ) AS
    v_recipient_user  VARCHAR2(200);
    v_provisionerseq  NUMBER;
    v_user            VARCHAR2(200) := NVL(SYS_CONTEXT('APEX$SESSION', 'APP_USER'), USER);
  BEGIN
    -- Resolve recipient user
    v_recipient_user := NVL(p_recipient_user, v_user);
    
    -- Resolve provisionerseq
    v_provisionerseq := NVL(
      p_provisionerseq,
      NVL(
        SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'),
        xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ')
      )
    );
    
    -- Validate notification type
    IF p_notification_type NOT IN ('WARNING', 'ERROR', 'INFO', 'SUCCESS') THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid notification type: ' || p_notification_type);
    END IF;
    
    -- Validate priority
    IF p_priority NOT IN ('LOW', 'NORMAL', 'HIGH', 'URGENT') THEN
      RAISE_APPLICATION_ERROR(-20002, 'Invalid priority: ' || p_priority);
    END IF;
    
    -- Validate channel
    IF p_channel NOT IN ('IN_APP', 'EMAIL', 'PUSH', 'SMS') THEN
      RAISE_APPLICATION_ERROR(-20003, 'Invalid channel: ' || p_channel);
    END IF;
    
    -- Insert notification
    INSERT INTO cemtezgelen.notifications (
      seq,
      aicheckseq,
      nonconformityseq,
      notificationtype,
      priority,
      channel,
      recipientuser,
      recipientemail,
      recipientphone,
      subject,
      message,
      messagebody,
      isread,
      deliverystatus,
      provisionerseq,
      createdate,
      createuser,
      create_timezone
    ) VALUES (
      cemtezgelen.notifications_seq.NEXTVAL,
      p_ai_check_seq,
      p_nonconformity_seq,
      p_notification_type,
      p_priority,
      p_channel,
      v_recipient_user,
      p_recipient_email,
      p_recipient_phone,
      p_subject,
      p_message,
      p_message_body,
      'N',  -- Not read
      CASE 
        WHEN p_channel = 'IN_APP' THEN 'DELIVERED'  -- Instant for in-app
        ELSE 'PENDING'  -- Other channels need processing
      END,
      v_provisionerseq,
      CURRENT_TIMESTAMP,
      v_user,
      SESSIONTIMEZONE
    );
    
    -- If EMAIL channel, trigger email sending (future implementation)
    IF p_channel = 'EMAIL' AND p_recipient_email IS NOT NULL THEN
      -- TODO: Call email service
      NULL;
    END IF;
    
    -- If SMS channel, trigger SMS sending (future implementation)
    IF p_channel = 'SMS' AND p_recipient_phone IS NOT NULL THEN
      -- TODO: Call SMS service
      NULL;
    END IF;
    
    -- If PUSH channel, trigger push notification (future implementation)
    IF p_channel = 'PUSH' THEN
      -- TODO: Call push notification service
      NULL;
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      xxsd_admin.pkg_error.p_logerror(
        'pkg_notification.p_create_notification',
        SQLCODE,
        'Error creating notification: ' || SQLERRM || 
        ' | Type: ' || p_notification_type ||
        ' | Priority: ' || p_priority ||
        ' | Channel: ' || p_channel ||
        ' | Recipient: ' || v_recipient_user
      );
      RAISE_APPLICATION_ERROR(-20000, 'Failed to create notification: ' || SQLERRM);
  END p_create_notification;

END pkg_notification;
/
-- AI generated code END - 2025-12-19 16:00
```

### 4.3 Usage Examples

#### Example 1: AI Error Notification

```sql
-- When AI processing fails
BEGIN
  cemtezgelen.pkg_notification.p_create_notification(
    p_notification_type => 'ERROR',
    p_priority          => 'HIGH',
    p_channel           => 'IN_APP',
    p_subject           => 'AI Processing Error',
    p_message           => 'AI validation failed for Order ORD-2025-001. Error: Connection timeout.',
    p_message_body      => 'Detailed error: AI service connection timeout after 30 seconds. Retry recommended.',
    p_ai_check_seq      => 123,
    p_order_seq         => 456,
    p_action_url        => 'f?p=&APP_ID.:101:&SESSION.::&DEBUG.:101:P101_ORDER_SEQ:456'
  );
END;
/
```

#### Example 2: AI Validation Success

```sql
-- When AI validation completes successfully
BEGIN
  cemtezgelen.pkg_notification.p_create_notification(
    p_notification_type => 'SUCCESS',
    p_priority          => 'NORMAL',
    p_channel           => 'IN_APP',
    p_subject           => 'AI Validation Complete',
    p_message           => 'AI validation PASSED for Non-Conformity NC-2025-001 (95% confidence)',
    p_message_body      => 'AI analysis completed successfully. Confidence score: 95%. All documents verified. No issues detected.',
    p_ai_check_seq      => 124,
    p_nonconformity_seq => 789,
    p_action_url        => 'f?p=&APP_ID.:102:&SESSION.::&DEBUG.:102:P102_NONCONF_SEQ:789'
  );
END;
/
```

#### Example 3: Critical Non-Conformity Alert

```sql
-- When critical non-conformity is reported
BEGIN
  cemtezgelen.pkg_notification.p_create_notification(
    p_notification_type => 'WARNING',
    p_priority          => 'URGENT',
    p_channel           => 'IN_APP',
    p_subject           => 'Critical Non-Conformity Reported',
    p_message           => 'CRITICAL: Seal broken on Order ORD-2025-002. Immediate action required.',
    p_message_body      => 'Driver reported SEAL_BROKEN on Asset CSNU3456789. Security breach detected. Escalation required.',
    p_nonconformity_seq => 790,
    p_order_seq         => 457,
    p_action_url        => 'f?p=&APP_ID.:102:&SESSION.::&DEBUG.:102:P102_NONCONF_SEQ:790'
  );
END;
/
```

#### Example 4: General Information Notification

```sql
-- General system notification
BEGIN
  cemtezgelen.pkg_notification.p_create_notification(
    p_notification_type => 'INFO',
    p_priority          => 'NORMAL',
    p_channel           => 'IN_APP',
    p_subject           => 'Order Status Updated',
    p_message           => 'Order ORD-2025-003 has been completed successfully.',
    p_order_seq         => 458
  );
END;
/
```

---

## 📱 APEX Client-Side Polling

### 5.1 Polling Mechanism

**JavaScript Polling Function:**
```javascript
// Notification polling configuration
var notificationConfig = {
  pollingInterval: 30000,  // 30 seconds (configurable)
  enabled: true,
  lastCheckTime: null,
  unreadCount: 0,
  soundEnabled: true,
  toastDuration: 5000  // 5 seconds
};

// Main polling function
function pollNotifications() {
  if (!notificationConfig.enabled) {
    return;
  }
  
  // Check if page is visible (don't poll when tab is hidden)
  if (document.hidden) {
    return;
  }
  
  apex.server.process('GET_UNREAD_NOTIFICATIONS', {
    x01: notificationConfig.lastCheckTime  // Only get notifications after this time
  }, {
    success: function(data) {
      if (data.notifications && data.notifications.length > 0) {
        // Process new notifications
        data.notifications.forEach(function(notification) {
          displayToastNotification(notification);
          playNotificationSound(notification);
        });
        
        // Update unread count badge
        updateNotificationBadge(data.unread_count);
        
        // Update last check time
        notificationConfig.lastCheckTime = data.last_check_time;
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      console.error('Error polling notifications:', errorThrown);
      // Don't show error to user, just log it
    }
  });
}

// Start polling
function startNotificationPolling() {
  // Initial poll
  pollNotifications();
  
  // Set up interval
  if (notificationConfig.pollingInterval > 0) {
    setInterval(pollNotifications, notificationConfig.pollingInterval);
  }
}

// Stop polling
function stopNotificationPolling() {
  notificationConfig.enabled = false;
}

// Pause polling when page is hidden
document.addEventListener('visibilitychange', function() {
  if (document.hidden) {
    stopNotificationPolling();
  } else {
    notificationConfig.enabled = true;
    startNotificationPolling();
  }
});

// Initialize on page load
$(document).ready(function() {
  startNotificationPolling();
});
```

### 5.2 APEX AJAX Callback Process

**Process: GET_UNREAD_NOTIFICATIONS**

```sql
-- Process: GET_UNREAD_NOTIFICATIONS
-- Type: AJAX Callback
DECLARE
  v_last_check_time TIMESTAMP(6) WITH LOCAL TIME ZONE;
  v_user VARCHAR2(200) := NVL(v('APP_USER'), USER);
  v_provisionerseq NUMBER := NVL(v('PROVISIONERSEQ'), 
                                 xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));
  v_notification_count NUMBER := 0;
BEGIN
  -- Parse last check time from parameter
  IF apex_application.g_x01 IS NOT NULL THEN
    v_last_check_time := TO_TIMESTAMP_TZ(apex_application.g_x01, 'YYYY-MM-DD"T"HH24:MI:SS.FF TZH:TZM');
  ELSE
    -- If no last check time, get notifications from last 5 minutes
    v_last_check_time := CURRENT_TIMESTAMP - INTERVAL '5' MINUTE;
  END IF;
  
  -- Build JSON response
  apex_json.open_object;
  apex_json.open_array('notifications');
  
  -- Query unread notifications
  FOR rec IN (
    SELECT 
      n.seq,
      n.notificationtype,
      n.priority,
      n.subject,
      n.message,
      n.createdate,
      n.aicheckseq,
      n.nonconformityseq,
      n.order_seq  -- If stored in metadata or separate field
    FROM cemtezgelen.notifications n
    WHERE n.recipientuser = v_user
    AND n.provisionerseq = v_provisionerseq
    AND n.channel = 'IN_APP'
    AND n.isread = 'N'
    AND n.createdate > v_last_check_time
    ORDER BY 
      CASE n.priority
        WHEN 'URGENT' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'NORMAL' THEN 3
        WHEN 'LOW' THEN 4
      END,
      n.createdate DESC
    FETCH FIRST 20 ROWS ONLY  -- Limit to 20 most recent
  ) LOOP
    v_notification_count := v_notification_count + 1;
    
    apex_json.open_object;
    apex_json.write('seq', rec.seq);
    apex_json.write('type', rec.notificationtype);
    apex_json.write('priority', rec.priority);
    apex_json.write('subject', rec.subject);
    apex_json.write('message', rec.message);
    apex_json.write('created_at', TO_CHAR(rec.createdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF TZH:TZM'));
    apex_json.write('ai_check_seq', rec.aicheckseq);
    apex_json.write('nonconf_seq', rec.nonconformityseq);
    apex_json.write('order_seq', rec.order_seq);
    apex_json.close_object;
  END LOOP;
  
  apex_json.close_array;
  apex_json.write('unread_count', v_notification_count);
  apex_json.write('last_check_time', TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.FF TZH:TZM'));
  apex_json.close_object;
END;
```

### 5.3 Mark Notification as Read

**Process: MARK_NOTIFICATION_READ**

```sql
-- Process: MARK_NOTIFICATION_READ
-- Type: AJAX Callback
DECLARE
  v_notification_seq NUMBER := apex_application.g_x01;
  v_user VARCHAR2(200) := NVL(v('APP_USER'), USER);
  v_provisionerseq NUMBER := NVL(v('PROVISIONERSEQ'), 
                                 xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ'));
BEGIN
  UPDATE cemtezgelen.notifications
  SET isread = 'Y',
      readdate = CURRENT_TIMESTAMP,
      updatedate = CURRENT_TIMESTAMP,
      updateuser = v_user,
      update_timezone = SESSIONTIMEZONE
  WHERE seq = v_notification_seq
  AND recipientuser = v_user
  AND provisionerseq = v_provisionerseq
  AND isread = 'N';
  
  -- Return success
  apex_json.open_object;
  apex_json.write('success', TRUE);
  apex_json.write('notification_seq', v_notification_seq);
  apex_json.close_object;
EXCEPTION
  WHEN OTHERS THEN
    xxsd_admin.pkg_error.p_logerror(
      'MARK_NOTIFICATION_READ',
      SQLCODE,
      'Error marking notification as read: ' || SQLERRM
    );
    apex_json.open_object;
    apex_json.write('success', FALSE);
    apex_json.write('error', SQLERRM);
    apex_json.close_object;
END;
```

---

## 🍞 Toast Notification Display

### 6.1 Toast UI Component

**Toast HTML Structure:**
```html
<div class="notification-toast" data-notification-seq="123" data-priority="URGENT">
  <div class="toast-icon">
    <i class="fa fa-exclamation-triangle"></i>
  </div>
  <div class="toast-content">
    <div class="toast-title">Critical Non-Conformity Reported</div>
    <div class="toast-message">CRITICAL: Seal broken on Order ORD-2025-002</div>
    <div class="toast-time">2 minutes ago</div>
  </div>
  <div class="toast-actions">
    <button class="toast-close" onclick="closeToast(123)">×</button>
  </div>
</div>
```

**Toast CSS Styling:**
```css
/* Toast Container */
.notification-toast-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 9999;
  max-width: 400px;
  width: 100%;
}

/* Individual Toast */
.notification-toast {
  display: flex;
  align-items: flex-start;
  padding: 16px;
  margin-bottom: 12px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  background: #ffffff;
  border-left: 4px solid;
  animation: slideInRight 0.3s ease-out;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.notification-toast:hover {
  transform: translateX(-4px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
}

/* Priority-based colors */
.notification-toast[data-priority="URGENT"] {
  border-left-color: #dc3545;
  background: #fff5f5;
}

.notification-toast[data-priority="HIGH"] {
  border-left-color: #fd7e14;
  background: #fff8f0;
}

.notification-toast[data-priority="NORMAL"] {
  border-left-color: #007bff;
  background: #f0f8ff;
}

.notification-toast[data-priority="LOW"] {
  border-left-color: #6c757d;
  background: #f8f9fa;
}

/* Type-based icon colors */
.notification-toast[data-type="ERROR"] .toast-icon {
  color: #dc3545;
}

.notification-toast[data-type="WARNING"] .toast-icon {
  color: #fd7e14;
}

.notification-toast[data-type="INFO"] .toast-icon {
  color: #007bff;
}

.notification-toast[data-type="SUCCESS"] .toast-icon {
  color: #28a745;
}

/* Toast Icon */
.toast-icon {
  font-size: 24px;
  margin-right: 12px;
  flex-shrink: 0;
}

/* Toast Content */
.toast-content {
  flex: 1;
  min-width: 0;
}

.toast-title {
  font-weight: 600;
  font-size: 14px;
  margin-bottom: 4px;
  color: #212529;
}

.toast-message {
  font-size: 13px;
  color: #6c757d;
  margin-bottom: 4px;
  line-height: 1.4;
}

.toast-time {
  font-size: 11px;
  color: #adb5bd;
}

/* Toast Actions */
.toast-actions {
  margin-left: 12px;
}

.toast-close {
  background: none;
  border: none;
  font-size: 20px;
  color: #adb5bd;
  cursor: pointer;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: background 0.2s, color 0.2s;
}

.toast-close:hover {
  background: #f8f9fa;
  color: #212529;
}

/* Animations */
@keyframes slideInRight {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideOutRight {
  from {
    transform: translateX(0);
    opacity: 1;
  }
  to {
    transform: translateX(100%);
    opacity: 0;
  }
}

.notification-toast.closing {
  animation: slideOutRight 0.3s ease-out forwards;
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .notification-toast-container {
    top: 10px;
    right: 10px;
    left: 10px;
    max-width: none;
  }
  
  .notification-toast {
    padding: 12px;
  }
  
  .toast-title {
    font-size: 13px;
  }
  
  .toast-message {
    font-size: 12px;
  }
}
```

### 6.2 JavaScript Toast Functions

**Display Toast Function:**
```javascript
// Display toast notification
function displayToastNotification(notification) {
  // Create toast element
  var toast = $('<div>')
    .addClass('notification-toast')
    .attr('data-notification-seq', notification.seq)
    .attr('data-type', notification.type)
    .attr('data-priority', notification.priority);
  
  // Determine icon based on type
  var iconClass = 'fa-info-circle';
  if (notification.type === 'ERROR') {
    iconClass = 'fa-exclamation-circle';
  } else if (notification.type === 'WARNING') {
    iconClass = 'fa-exclamation-triangle';
  } else if (notification.type === 'SUCCESS') {
    iconClass = 'fa-check-circle';
  }
  
  // Build toast HTML
  var toastHTML = `
    <div class="toast-icon">
      <i class="fa ${iconClass}"></i>
    </div>
    <div class="toast-content">
      <div class="toast-title">${escapeHtml(notification.subject)}</div>
      <div class="toast-message">${escapeHtml(notification.message)}</div>
      <div class="toast-time">${formatTimeAgo(notification.created_at)}</div>
    </div>
    <div class="toast-actions">
      <button class="toast-close" onclick="closeToast(${notification.seq})">×</button>
    </div>
  `;
  
  toast.html(toastHTML);
  
  // Add click handler to navigate (if action_url provided)
  if (notification.action_url) {
    toast.css('cursor', 'pointer');
    toast.on('click', function() {
      navigateToNotification(notification);
    });
  }
  
  // Ensure container exists
  var container = $('.notification-toast-container');
  if (container.length === 0) {
    container = $('<div>').addClass('notification-toast-container');
    $('body').append(container);
  }
  
  // Add toast to container
  container.append(toast);
  
  // Auto-dismiss after configured duration
  var duration = notificationConfig.toastDuration;
  if (notification.priority === 'URGENT') {
    duration = duration * 2;  // Urgent notifications stay longer
  }
  
  setTimeout(function() {
    closeToast(notification.seq);
  }, duration);
  
  // Mark as read after display
  markNotificationAsRead(notification.seq);
}

// Close toast
function closeToast(notificationSeq) {
  var toast = $('.notification-toast[data-notification-seq="' + notificationSeq + '"]');
  toast.addClass('closing');
  
  setTimeout(function() {
    toast.remove();
    updateNotificationBadge();  // Refresh badge count
  }, 300);
}

// Navigate to notification target
function navigateToNotification(notification) {
  if (notification.action_url) {
    // Replace APEX placeholders if needed
    var url = notification.action_url
      .replace('&APP_ID.', apex.env.APP_ID)
      .replace('&SESSION.', apex.env.SESSION_ID);
    
    window.location.href = url;
  } else {
    // Default: navigate to notifications page
    apex.navigation.redirect('f?p=' + apex.env.APP_ID + ':300:' + apex.env.SESSION_ID);
  }
  
  // Close toast
  closeToast(notification.seq);
}

// Format time ago
function formatTimeAgo(timestamp) {
  var now = new Date();
  var time = new Date(timestamp);
  var diffMs = now - time;
  var diffMins = Math.floor(diffMs / 60000);
  var diffHours = Math.floor(diffMs / 3600000);
  var diffDays = Math.floor(diffMs / 86400000);
  
  if (diffMins < 1) {
    return 'Just now';
  } else if (diffMins < 60) {
    return diffMins + ' minute' + (diffMins > 1 ? 's' : '') + ' ago';
  } else if (diffHours < 24) {
    return diffHours + ' hour' + (diffHours > 1 ? 's' : '') + ' ago';
  } else {
    return diffDays + ' day' + (diffDays > 1 ? 's' : '') + ' ago';
  }
}

// Escape HTML
function escapeHtml(text) {
  var map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };
  return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

// Update notification badge
function updateNotificationBadge(count) {
  if (count !== undefined) {
    notificationConfig.unreadCount = count;
  }
  
  var badge = $('.notification-badge');
  if (badge.length === 0) {
    // Create badge if it doesn't exist
    badge = $('<span>').addClass('notification-badge');
    $('.notification-icon').append(badge);
  }
  
  if (notificationConfig.unreadCount > 0) {
    badge.text(notificationConfig.unreadCount > 99 ? '99+' : notificationConfig.unreadCount);
    badge.show();
  } else {
    badge.hide();
  }
}
```

---

## 🔊 Sound Notifications

### 7.1 Sound Configuration

**Sound Files:**
- `notification-error.mp3` - For ERROR type
- `notification-warning.mp3` - For WARNING type
- `notification-info.mp3` - For INFO type
- `notification-success.mp3` - For SUCCESS type

**Sound Priority Mapping:**
- URGENT → Full volume, longer duration
- HIGH → 80% volume
- NORMAL → 60% volume
- LOW → 40% volume (or silent)

### 7.2 JavaScript Sound Functions

```javascript
// Play notification sound
function playNotificationSound(notification) {
  if (!notificationConfig.soundEnabled) {
    return;
  }
  
  // Check user preference (stored in localStorage)
  var soundEnabled = localStorage.getItem('notification_sound_enabled');
  if (soundEnabled === 'false') {
    return;
  }
  
  // Determine sound file based on type
  var soundFile = 'notification-' + notification.type.toLowerCase() + '.mp3';
  
  // Create audio element
  var audio = new Audio('#' + soundFile);  // Use APEX static file reference
  // Or: var audio = new Audio(apex.util.makeApplicationUrl({x01: 'SOUND', x02: soundFile}));
  
  // Set volume based on priority
  var volume = 0.6;  // Default
  if (notification.priority === 'URGENT') {
    volume = 1.0;
  } else if (notification.priority === 'HIGH') {
    volume = 0.8;
  } else if (notification.priority === 'NORMAL') {
    volume = 0.6;
  } else if (notification.priority === 'LOW') {
    volume = 0.4;
  }
  
  audio.volume = volume;
  
  // Play sound
  audio.play().catch(function(error) {
    console.log('Sound playback failed:', error);
    // Fail silently - don't interrupt user experience
  });
}

// Browser notification API (optional, for desktop notifications)
function showBrowserNotification(notification) {
  if (!('Notification' in window)) {
    return;  // Browser doesn't support notifications
  }
  
  // Request permission if not granted
  if (Notification.permission === 'default') {
    Notification.requestPermission();
  }
  
  if (Notification.permission === 'granted') {
    var browserNotification = new Notification(notification.subject, {
      body: notification.message,
      icon: '/path/to/icon.png',
      tag: 'notification-' + notification.seq,  // Prevent duplicates
      requireInteraction: notification.priority === 'URGENT'  // Stay until user interacts
    });
    
    // Click handler
    browserNotification.onclick = function() {
      window.focus();
      navigateToNotification(notification);
      browserNotification.close();
    };
    
    // Auto-close after 5 seconds (unless URGENT)
    if (notification.priority !== 'URGENT') {
      setTimeout(function() {
        browserNotification.close();
      }, 5000);
    }
  }
}
```

---

## 🤖 AI Integration

### 8.1 AI Error Handling

**AI Check Error Notification:**
```sql
-- In AI processing procedure/trigger
-- When AI check fails
BEGIN
  cemtezgelen.pkg_notification.p_create_notification(
    p_notification_type => 'ERROR',
    p_priority          => 'HIGH',
    p_channel           => 'IN_APP',
    p_subject           => 'AI Processing Error',
    p_message           => 'AI validation failed for Order ' || v_order_number || '. ' || v_error_message,
    p_message_body      => 'AI Check: ' || v_check_number || CHR(10) ||
                          'Error: ' || v_error_message || CHR(10) ||
                          'Retry recommended.',
    p_ai_check_seq      => v_ai_check_seq,
    p_order_seq         => v_order_seq,
    p_action_url        => 'f?p=&APP_ID.:101:&SESSION.::&DEBUG.:101:P101_ORDER_SEQ:' || v_order_seq
  );
END;
```

### 8.2 AI Validation Complete Notification

**AI Success/Failure Notification:**
```sql
-- When AI validation completes
DECLARE
  v_notification_type VARCHAR2(20);
  v_priority VARCHAR2(20);
  v_message VARCHAR2(4000);
BEGIN
  IF v_ai_status = 'PASSED' THEN
    v_notification_type := 'SUCCESS';
    v_priority := 'NORMAL';
    v_message := 'AI validation PASSED for Non-Conformity ' || v_nonconf_number || 
                 ' (Confidence: ' || v_confidence_score || '%)';
  ELSIF v_ai_status = 'FAILED' THEN
    v_notification_type := 'WARNING';
    v_priority := 'HIGH';
    v_message := 'AI validation FAILED for Non-Conformity ' || v_nonconf_number || 
                 '. Issues detected: ' || v_detected_issues;
  ELSE
    v_notification_type := 'ERROR';
    v_priority := 'HIGH';
    v_message := 'AI validation ERROR for Non-Conformity ' || v_nonconf_number || 
                 '. Error: ' || v_error_message;
  END IF;
  
  cemtezgelen.pkg_notification.p_create_notification(
    p_notification_type => v_notification_type,
    p_priority          => v_priority,
    p_channel           => 'IN_APP',
    p_subject           => 'AI Validation ' || v_ai_status,
    p_message           => v_message,
    p_message_body      => 'AI Check: ' || v_check_number || CHR(10) ||
                          'Confidence: ' || v_confidence_score || '%' || CHR(10) ||
                          'Detected Issues: ' || NVL(v_detected_issues, 'None') || CHR(10) ||
                          'Recommendations: ' || NVL(v_recommendations, 'None'),
    p_ai_check_seq      => v_ai_check_seq,
    p_nonconformity_seq => v_nonconformity_seq,
    p_action_url        => 'f?p=&APP_ID.:102:&SESSION.::&DEBUG.:102:P102_NONCONF_SEQ:' || v_nonconformity_seq
  );
END;
```

### 8.3 AI Processing Timeout

**Timeout Notification:**
```sql
-- When AI processing times out
BEGIN
  cemtezgelen.pkg_notification.p_create_notification(
    p_notification_type => 'WARNING',
    p_priority          => 'HIGH',
    p_channel           => 'IN_APP',
    p_subject           => 'AI Processing Timeout',
    p_message           => 'AI validation timed out for Order ' || v_order_number || '. Manual review recommended.',
    p_message_body      => 'AI Check: ' || v_check_number || CHR(10) ||
                          'Timeout after: 30 seconds' || CHR(10) ||
                          'Action: Manual review required',
    p_ai_check_seq      => v_ai_check_seq,
    p_order_seq         => v_order_seq
  );
END;
```

---

## 🛠️ Technical Implementation

### 9.1 APEX Page Setup

#### 9.1.1 Global Notification Component

**Page 0 (Global Page) or Shared Component:**

**JavaScript File (Global):**
```javascript
// File: notification-system.js
// Include in APEX Application → Shared Components → JavaScript → File URLs

// Configuration
var notificationConfig = {
  pollingInterval: 30000,  // 30 seconds
  enabled: true,
  lastCheckTime: null,
  unreadCount: 0,
  soundEnabled: true,
  toastDuration: 5000
};

// Initialize on page load
$(document).ready(function() {
  // Load CSS
  loadNotificationCSS();
  
  // Start polling
  startNotificationPolling();
  
  // Set up visibility change handler
  document.addEventListener('visibilitychange', handleVisibilityChange);
});

// Load CSS dynamically
function loadNotificationCSS() {
  if (!$('#notification-css').length) {
    $('<link>')
      .attr('id', 'notification-css')
      .attr('rel', 'stylesheet')
      .attr('href', '#NOTIFICATION_CSS#')  // APEX static file
      .appendTo('head');
  }
}
```

**CSS File (Global):**
```css
/* File: notification-toast.css */
/* Include in APEX Application → Shared Components → CSS → File URLs */

/* (Include all CSS from section 6.1) */
```

#### 9.1.2 Notification Settings Page

**Page 300: Notification Settings**

**Regions:**
1. **Notification Preferences** - Enable/disable sound, polling interval
2. **Notification History** - List of all notifications
3. **Unread Notifications** - List of unread notifications

**Page Items:**
- `P300_SOUND_ENABLED` - Switch (Y/N)
- `P300_POLLING_INTERVAL` - Number field (seconds)
- `P300_MARK_ALL_READ` - Button

---

### 9.2 Database Functions

#### 9.2.1 Get Unread Count Function

```sql
-- Function to get unread notification count
CREATE OR REPLACE FUNCTION cemtezgelen.f_get_unread_count(
  p_user IN VARCHAR2 DEFAULT NULL,
  p_provisionerseq IN NUMBER DEFAULT NULL
) RETURN NUMBER AS
  v_user VARCHAR2(200) := NVL(p_user, NVL(SYS_CONTEXT('APEX$SESSION', 'APP_USER'), USER));
  v_provisionerseq NUMBER := NVL(
    p_provisionerseq,
    NVL(
      SYS_CONTEXT('APEX$SESSION', 'PROVISIONERSEQ'),
      xxsd_admin.pkg_util.get_context_value('PROVISIONERSEQ')
    )
  );
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM cemtezgelen.notifications
  WHERE recipientuser = v_user
  AND provisionerseq = v_provisionerseq
  AND channel = 'IN_APP'
  AND isread = 'N';
  
  RETURN v_count;
EXCEPTION
  WHEN OTHERS THEN
    xxsd_admin.pkg_error.p_logerror(
      'f_get_unread_count',
      SQLCODE,
      'Error getting unread count: ' || SQLERRM
    );
    RETURN 0;
END;
/
```

---

## 🔄 User Workflows

### 10.1 Notification Creation Workflow

1. **System event occurs** (AI error, validation complete, etc.)
2. **Procedure called** → `pkg_notification.p_create_notification`
3. **Notification inserted** → NOTIFICATIONS table
4. **Status set** → `isread = 'N'`, `channel = 'IN_APP'`

### 10.2 Notification Delivery Workflow

1. **APEX page loads** → Polling starts
2. **Every 30 seconds** → AJAX call to GET_UNREAD_NOTIFICATIONS
3. **New notifications returned** → JavaScript processes
4. **Toast displayed** → User sees notification
5. **Sound played** → Audio feedback (if enabled)
6. **Notification marked as read** → `isread = 'Y'`

### 10.3 User Interaction Workflow

1. **User sees toast** → Notification appears
2. **User clicks toast** → Navigates to related page
3. **User closes toast** → Toast dismissed, marked as read
4. **Auto-dismiss** → Toast closes after 5 seconds (or longer for URGENT)

---

## ⚡ Performance Considerations

### 11.1 Polling Optimization

**Efficient Query:**
- Index on `(recipientuser, provisionerseq, isread, createdate)`
- Only fetch notifications after last check time
- Limit to 20 most recent notifications
- Use FETCH FIRST for pagination

**Polling Frequency:**
- Default: 30 seconds (configurable)
- Pause when page hidden (visibility API)
- Reduce frequency when no new notifications
- Increase frequency when URGENT notifications detected

### 11.2 Caching Strategy

**Client-Side Caching:**
- Cache last check time
- Cache notification count
- Don't re-fetch already displayed notifications

**Server-Side Optimization:**
- Use bind variables
- Index optimization
- Query result caching (if applicable)

### 11.3 Scalability

**For High Volume:**
- Batch notification processing
- Queue-based delivery
- WebSocket alternative (future)
- Server-Sent Events (SSE) alternative

---

## 🔐 Security Considerations

### 12.1 Data Isolation
- All queries filtered by PROVISIONERSEQ
- User can only see own notifications
- Security views enforce tenant isolation

### 12.2 Authorization
- Validate recipient user
- Prevent notification spoofing
- Audit trail for notification creation

### 12.3 Input Validation
- Validate all procedure parameters
- Sanitize notification messages
- Prevent XSS in toast display

---

## 📊 Analytics and Monitoring

### 13.1 Notification Metrics
- Tota