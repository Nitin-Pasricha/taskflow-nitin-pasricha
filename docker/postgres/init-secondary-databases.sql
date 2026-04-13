-- Rails 8 production uses separate DBs for Solid Cache, Solid Queue, and Solid Cable.
-- POSTGRES_DB already created the primary database on first boot.
CREATE DATABASE taskflow_nitin_pasricha_production_cache;
CREATE DATABASE taskflow_nitin_pasricha_production_queue;
CREATE DATABASE taskflow_nitin_pasricha_production_cable;
