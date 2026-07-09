CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS destinations_name_trgm_idx ON destinations USING gin (name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS destinations_location_trgm_idx ON destinations USING gin (location gin_trgm_ops);
CREATE INDEX IF NOT EXISTS hotels_name_trgm_idx ON hotels USING gin (name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS hotels_location_trgm_idx ON hotels USING gin (location gin_trgm_ops);
CREATE INDEX IF NOT EXISTS tour_packages_name_trgm_idx ON tour_packages USING gin (name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS tour_packages_departure_trgm_idx ON tour_packages USING gin (departure gin_trgm_ops);
CREATE INDEX IF NOT EXISTS tour_packages_description_trgm_idx ON tour_packages USING gin (description gin_trgm_ops);
