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

CREATE TABLE orders (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id             UUID NOT NULL,
    order_number        VARCHAR(30) NOT NULL UNIQUE,
    status              VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    subtotal            DECIMAL(12,4) NOT NULL,
    shipping_cost       DECIMAL(12,4) NOT NULL DEFAULT 0,
    discount            DECIMAL(12,4) NOT NULL DEFAULT 0,
    total               DECIMAL(12,4) NOT NULL,
    shipping_address_id UUID,
    payment_method      VARCHAR(30),
    notes               TEXT,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    order_id            UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_variant_id  UUID NOT NULL,
    sku                 VARCHAR(50) NOT NULL,
    product_name        VARCHAR(255) NOT NULL,
    unit_price          DECIMAL(12,4) NOT NULL,
    quantity            INTEGER NOT NULL,
    subtotal            DECIMAL(12,4) NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE order_status_history (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    order_id        UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    from_status     VARCHAR(30),
    to_status       VARCHAR(30) NOT NULL,
    changed_by      VARCHAR(100),
    reason          TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_status_history_order ON order_status_history(order_id);
