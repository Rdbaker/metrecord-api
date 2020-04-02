CREATE EXTENSION pg_trgm;
CREATE INDEX ix_name_trigram ON events USING GIN (name gin_trgm_ops);