CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS UUID
LANGUAGE plpgsql VOLATILE
AS $$
DECLARE
  unix_ts_ms BYTEA;
  rand_bytes BYTEA;
BEGIN
  unix_ts_ms = substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::bigint) FROM 1 FOR 6);
  rand_bytes = gen_random_bytes(10);
  RETURN encode(
    unix_ts_ms ||
    set_byte(rand_bytes, 0, (get_byte(rand_bytes, 0) & 0x0f) | 0x70) ||
    set_byte(rand_bytes, 2, (get_byte(rand_bytes, 2) & 0x3f) | 0x80),
    'hex'
  )::UUID;
END;
$$;

CREATE TABLE notification_log (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    event_type      VARCHAR(50) NOT NULL,
    recipient       VARCHAR(255) NOT NULL,
    channel         VARCHAR(20) NOT NULL,
    subject         VARCHAR(255),
    body_preview    VARCHAR(500),
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    retry_count     INTEGER NOT NULL DEFAULT 0,
    max_retries     INTEGER NOT NULL DEFAULT 3,
    error_message   TEXT,
    sent_at         TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE notification_templates (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    event_type      VARCHAR(50) NOT NULL UNIQUE,
    channel         VARCHAR(20) NOT NULL DEFAULT 'EMAIL',
    subject_template VARCHAR(255),
    body_template   TEXT NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notification_log_status ON notification_log(status);
CREATE INDEX idx_notification_log_event ON notification_log(event_type);
CREATE INDEX idx_notification_log_created ON notification_log(created_at);
