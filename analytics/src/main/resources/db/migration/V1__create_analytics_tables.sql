CREATE TABLE event_store (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type      VARCHAR(100) NOT NULL,
    event_key       VARCHAR(100),
    payload         JSONB NOT NULL,
    metadata        JSONB,
    occurred_at     TIMESTAMP WITH TIME ZONE NOT NULL,
    ingested_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE materialized_metrics (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
