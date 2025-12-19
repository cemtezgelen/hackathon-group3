-- =============================================================================
-- Package: pkg_notification
-- Schema: cemtezgelen
-- Purpose: Unified notification creation interface
-- AI generated code START - 2025-12-19 16:00
-- =============================================================================

CREATE OR REPLACE PACKAGE cemtezgelen.pkg_notification AS

  -- <HACKATHON-001>
  -- Create notification with unified interface
  -- Supports AI errors, validation results, and general notifications
  PROCEDURE p_create_notification(
    p_notification_type   IN VARCHAR2,  -- WARNING, ERROR, INFO, SUCCESS
    p_priority            IN VARCHAR2 DEFAULT 'NORMAL',  -- LOW, NORMAL, HIGH, URGENT
    p_channel             IN VARCHAR2 DEFAULT 'IN_APP',  -- IN_APP, EMAIL, PUSH, SMS
    p_subject             IN VARCHAR2,  -- Notification subject/title
    p_message             IN VARCHAR2,  -- Short message (toast display)
    p_message_body        IN CLOB DEFAULT NULL,  -- Detailed message (optional)
    p_recipient_user       IN VARCHAR2 DEFAULT NULL,  -- Target user (APP_USER if NULL)
    p_recipient_email      IN VARCHAR2 DEFAULT NULL,  -- Email (optional, for EMAIL channel)
    p_recipient_phone      IN VARCHAR2 DEFAULT NULL,  -- Phone (optional, for SMS channel)
    p_ai_check_seq         IN NUMBER DEFAULT NULL,  -- Related AI check
    p_nonconformity_seq    IN NUMBER DEFAULT NULL,  -- Related non-conformity
    p_order_seq            IN NUMBER DEFAULT NULL,  -- Related order (for context)
    p_action_url           IN VARCHAR2 DEFAULT NULL,  -- URL to navigate on click
    p_provisionerseq       IN NUMBER DEFAULT NULL   -- Auto-resolved if NULL
  );

END pkg_notification;
/
