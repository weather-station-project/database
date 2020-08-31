#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- USERS
    CREATE USER admin WITH SUPERUSER PASSWORD '$ADMIN_USER_PASSWORD';

    CREATE USER sensors_reader_dev WITH PASSWORD '$SENSORS_READER_DEV_PASSWORD';
    CREATE USER sensors_reader WITH PASSWORD '$SENSORS_READER_PASSWORD';

    CREATE USER dashboard_dev WITH PASSWORD '$DASHBOARD_DEV_PASSWORD';
    CREATE USER dashboard WITH PASSWORD '$DASHBOARD_PASSWORD';

    -- Create databases
    CREATE DATABASE weather_station_dev;
    GRANT CONNECT ON DATABASE weather_station_dev TO sensors_reader_dev;
    GRANT CONNECT ON DATABASE weather_station_dev TO dashboard_dev;

    CREATE DATABASE weather_station;
    GRANT CONNECT ON DATABASE weather_station TO sensors_reader;
    GRANT CONNECT ON DATABASE weather_station TO dashboard;

    -- DEV ENVIRONMENT
    \c weather_station_dev

    -- Table ambient_temperatures
    CREATE TABLE ambient_temperatures (
        id SERIAL PRIMARY KEY,
        temperature INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON ambient_temperatures TO sensors_reader_dev;
    GRANT SELECT ON ambient_temperatures TO dashboard_dev;
    GRANT USAGE, SELECT ON SEQUENCE ambient_temperatures_id_seq TO sensors_reader_dev;

    -- Table ground_temperatures
    CREATE TABLE ground_temperatures (
        id SERIAL PRIMARY KEY,
        temperature INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON ground_temperatures TO sensors_reader_dev;
    GRANT SELECT ON ground_temperatures TO dashboard_dev;
    GRANT USAGE, SELECT ON SEQUENCE ground_temperatures_id_seq TO sensors_reader_dev;

    -- Table air_measurements
    CREATE TABLE air_measurements (
        id SERIAL PRIMARY KEY,
        pressure INT NOT NULL,
        humidity INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON air_measurements TO sensors_reader_dev;
    GRANT SELECT ON air_measurements TO dashboard_dev;
    GRANT USAGE, SELECT ON SEQUENCE air_measurements_id_seq TO sensors_reader_dev;

    -- Table wind_measurements
    CREATE TABLE wind_measurements (
        id SERIAL PRIMARY KEY,
        direction INT NOT NULL,
        speed INT NOT NULL,
        gust_speed INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON wind_measurements TO sensors_reader_dev;
    GRANT SELECT ON wind_measurements TO dashboard_dev;
    GRANT USAGE, SELECT ON SEQUENCE wind_measurements_id_seq TO sensors_reader_dev;

    -- Table rainfall
    CREATE TABLE rainfall (
        id SERIAL PRIMARY KEY,
        amount INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON rainfall TO sensors_reader_dev;
    GRANT SELECT ON rainfall TO dashboard_dev;
    GRANT USAGE, SELECT ON SEQUENCE rainfall_id_seq TO sensors_reader_dev;


    -- PROD ENVIRONMENT
    \c weather_station

    -- Table ambient_temperatures
    CREATE TABLE ambient_temperatures (
        id SERIAL PRIMARY KEY,
        temperature INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON ambient_temperatures TO sensors_reader;
    GRANT SELECT ON ambient_temperatures TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE ambient_temperatures_id_seq TO sensors_reader;

    -- Table ambient_temperatures
    CREATE TABLE ground_temperatures (
        id SERIAL PRIMARY KEY,
        temperature INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON ground_temperatures TO sensors_reader;
    GRANT SELECT ON ground_temperatures TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE ground_temperatures_id_seq TO sensors_reader;

    -- Table air_measurements
    CREATE TABLE air_measurements (
        id SERIAL PRIMARY KEY,
        pressure INT NOT NULL,
        humidity INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON air_measurements TO sensors_reader;
    GRANT SELECT ON air_measurements TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE air_measurements_id_seq TO sensors_reader;

    -- Table wind_measurements
    CREATE TABLE wind_measurements (
        id SERIAL PRIMARY KEY,
        direction INT NOT NULL,
        speed INT NOT NULL,
        gust_speed INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON wind_measurements TO sensors_reader;
    GRANT SELECT ON wind_measurements TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE wind_measurements_id_seq TO sensors_reader;

    -- Table rainfall
    CREATE TABLE rainfall (
        id SERIAL PRIMARY KEY,
        amount INT NOT NULL,
        date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON rainfall TO sensors_reader;
    GRANT SELECT ON rainfall TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE rainfall_id_seq TO sensors_reader;
EOSQL

cat > /var/lib/postgresql/data/pg_hba.conf <<- EOF
# You may want to improve this configuration by using this link https://www.postgresql.org/docs/current/auth-pg-hba-conf.html

# From local, no connections available
local all all reject

# Default user is not allowed
host all "$POSTGRES_USER" all reject

# Super user can only connect from its specific device
host all admin $ADMIN_HOST_IP_ADDRESS/32 scram-sha-256

# Sensors-reader users can connect from the Sensors Reader host on PROD and from everywhere on DEV
host weather_station_dev sensors_reader_dev 0.0.0.0/0 scram-sha-256
host weather_station sensors_reader $SENSORS_READER_HOST_IP_ADDRESS/32 scram-sha-256

# Dashboard users can connect from the Dashboard Server host on PROD and from everywhere on DEV
host weather_station_dev dashboard_dev 0.0.0.0/0 scram-sha-256
host weather_station dashboard $DASHBOARD_HOST_IP_ADDRESS/32 scram-sha-256
EOF
