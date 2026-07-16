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

CREATE TABLE shipments (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    order_id            UUID NOT NULL,
    tracking_code       VARCHAR(50),
    carrier             VARCHAR(50),
    status              VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    shipping_method     VARCHAR(50),
    estimated_delivery  DATE,
    delivered_at        TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE tracking_events (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    shipment_id     UUID NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
    status          VARCHAR(50) NOT NULL,
    location        VARCHAR(255),
    description     TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shipments_order ON shipments(order_id);
CREATE INDEX idx_shipments_tracking ON shipments(tracking_code);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_tracking_events_shipment ON tracking_events(shipment_id);
