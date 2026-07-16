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

CREATE TABLE event_store (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    event_type      VARCHAR(100) NOT NULL,
    event_key       VARCHAR(100),
    payload         JSONB NOT NULL,
    metadata        JSONB,
    occurred_at     TIMESTAMP WITH TIME ZONE NOT NULL,
    ingested_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE materialized_metrics (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    metric_name     VARCHAR(100) NOT NULL,
    metric_key      VARCHAR(100),
    metric_value    DECIMAL(15,2) NOT NULL,
    period_start    TIMESTAMP WITH TIME ZONE NOT NULL,
    period_end      TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_event_store_type ON event_store(event_type);
CREATE INDEX idx_event_store_occurred ON event_store(occurred_at);
CREATE INDEX idx_materialized_metrics_name ON materialized_metrics(metric_name);
CREATE INDEX idx_materialized_metrics_period ON materialized_metrics(period_start, period_end);
