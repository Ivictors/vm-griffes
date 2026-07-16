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

CREATE TABLE carts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id         UUID,
    session_id      VARCHAR(100),
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE cart_items (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    cart_id             UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_variant_id  UUID NOT NULL,
    sku                 VARCHAR(50) NOT NULL,
    product_name        VARCHAR(255) NOT NULL,
    unit_price          DECIMAL(12,4) NOT NULL,
    quantity            INTEGER NOT NULL,
    image_url           VARCHAR(500),
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_carts_user ON carts(user_id);
CREATE INDEX idx_carts_session ON carts(session_id);
CREATE INDEX idx_carts_status ON carts(status);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
