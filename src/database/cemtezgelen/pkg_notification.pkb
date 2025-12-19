-- =============================================================================
-- Package Body: pkg_notification
-- Schema: cemtezgelen
-- Purpose: Unified notification creation implementation
-- AI generated code START - 2025-12-19 16:00
-- =============================================================================

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
