# Notification System - Complete Implementation Guide

**Complete code and examples for notification system implementation**

---

## 📝 Table of Contents

1. [Usage Examples](#usage-examples)
2. [APEX Client-Side Polling](#apex-client-side-polling)
3. [Mark Notification as Read](#mark-notification-as-read)
4. [Toast Notification Display](#toast-notification-display)
5. [AI Integration](#ai-integration)

---

## 📝 Usage Examples

### Example 1: AI Error Notification

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

### Example 2: AI Validation Success

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

### Example 3: Critical Non-Conformity Alert

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

### Example 4: General Information Notification

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
  toastDuration: 3000  // 3 seconds - auto-dismiss after a couple of seconds
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

---

## ✅ Mark Notification as Read

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
/* Toast Container - Floating above everything */
.notification-toast-container {
  position: fixed;
  top: 80px;  /* Below header - adjust based on your header height */
  right: 20px;
  z-index: 99999;  /* Very high z-index to float above everything */
  max-width: 400px;
  width: 100%;
  pointer-events: none;  /* Allow clicks to pass through container */
}

/* Individual Toast - Floating with pointer events */
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
  pointer-events: auto;  /* Enable clicks on toast itself */
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
    duration = duration * 1.5;  // Urgent notifications stay a bit longer (4.5 seconds)
  } else if (notification.priority === 'HIGH') {
    duration = duration * 1.2;  // High priority stays slightly longer (3.6 seconds)
  }
  
  // Auto-dismiss timer
  var dismissTimer = setTimeout(function() {
    closeToast(notification.seq);
  }, duration);
  
  // Store timer reference so we can clear it if user hovers
  toast.data('dismiss-timer', dismissTimer);
  
  // Pause auto-dismiss on hover
  toast.on('mouseenter', function() {
    clearTimeout(dismissTimer);
  });
  
  // Resume auto-dismiss when mouse leaves
  toast.on('mouseleave', function() {
    var remainingTime = duration * 0.5;  // Give at least 1.5 seconds after hover
    dismissTimer = setTimeout(function() {
      closeToast(notification.seq);
    }, remainingTime);
    toast.data('dismiss-timer', dismissTimer);
  });
  
  // Mark as read after display
  markNotificationAsRead(notification.seq);
}

// Close toast
function closeToast(notificationSeq) {
  var toast = $('.notification-toast[data-notification-seq="' + notificationSeq + '"]');
  
  // Clear any pending dismiss timer
  var dismissTimer = toast.data('dismiss-timer');
  if (dismissTimer) {
    clearTimeout(dismissTimer);
  }
  
  // Add closing animation
  toast.addClass('closing');
  
  // Remove after animation completes
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

// Mark notification as read
function markNotificationAsRead(notificationSeq) {
  apex.server.process('MARK_NOTIFICATION_READ', {
    x01: notificationSeq
  }, {
    success: function(data) {
      if (data.success) {
        // Notification marked as read
      }
    },
    error: function() {
      console.error('Error marking notification as read');
    }
  });
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

## 📋 Quick Reference

### Notification Types
- `ERROR` - Red, exclamation circle icon
- `WARNING` - Orange, exclamation triangle icon
- `INFO` - Blue, info circle icon
- `SUCCESS` - Green, check circle icon

### Priorities
- `URGENT` - Red border, stays longer
- `HIGH` - Orange border
- `NORMAL` - Blue border (default)
- `LOW` - Gray border

### Channels
- `IN_APP` - Toast notification in APEX
- `EMAIL` - Email to static address (c.tezgelen@rail-flow.com)
- `PUSH` - Push notification (future)
- `SMS` - SMS notification (future)

---

**End of Implementation Guide**
