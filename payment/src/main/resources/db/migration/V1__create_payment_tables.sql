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

CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    order_id        UUID NOT NULL UNIQUE,
    asaas_id        VARCHAR(50),
    status          VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    method          VARCHAR(30),
    amount          DECIMAL(12,4) NOT NULL,
    fee             DECIMAL(12,4) DEFAULT 0,
    net_amount      DECIMAL(12,4) DEFAULT 0,
    paid_at         TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE payment_events (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    payment_id      UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    event_type      VARCHAR(50) NOT NULL,
    payload         JSONB,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE idempotency_keys (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    idempotency_key VARCHAR(255) NOT NULL UNIQUE,
    response_status INTEGER NOT NULL,
    response_body   TEXT,
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_asaas ON payments(asaas_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payment_events_payment ON payment_events(payment_id);
CREATE INDEX idx_idempotency_keys_expires ON idempotency_keys(expires_at);
