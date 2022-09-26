set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- USERS
    CREATE USER admin WITH SUPERUSER PASSWORD '$ADMIN_USER_PASSWORD';
    CREATE USER sensors_reader WITH PASSWORD '$SENSORS_READER_PASSWORD';
    CREATE USER dashboard WITH PASSWORD '$DASHBOARD_PASSWORD';

    -- Create database
    CREATE DATABASE weather_station;
    GRANT CONNECT ON DATABASE weather_station TO sensors_reader;
    GRANT CONNECT ON DATABASE weather_station TO dashboard;

    \c weather_station

    -- Table ambient_temperatures
    CREATE TABLE ambient_temperatures (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        temperature NUMERIC(5, 2) NOT NULL,
        date_time TIMESTAMP WITH TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON ambient_temperatures TO sensors_reader;
    GRANT SELECT ON ambient_temperatures TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE ambient_temperatures_id_seq TO sensors_reader;

    -- Table ambient_temperatures
    CREATE TABLE ground_temperatures (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        temperature NUMERIC(5, 2) NOT NULL,
        date_time TIMESTAMP WITH TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON ground_temperatures TO sensors_reader;
    GRANT SELECT ON ground_temperatures TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE ground_temperatures_id_seq TO sensors_reader;

    -- Table air_measurements
    CREATE TABLE air_measurements (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        pressure NUMERIC(6, 2) NOT NULL,
        humidity NUMERIC(5, 2) NOT NULL,
        date_time TIMESTAMP WITH TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON air_measurements TO sensors_reader;
    GRANT SELECT ON air_measurements TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE air_measurements_id_seq TO sensors_reader;

    -- Table wind_measurements
    CREATE TABLE wind_measurements (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        direction VARCHAR(4) NOT NULL,
        speed NUMERIC(5, 2) NOT NULL,
        date_time TIMESTAMP WITH TIME ZONE NOT NULL
    );

    GRANT SELECT, INSERT ON wind_measurements TO sensors_reader;
    GRANT SELECT ON wind_measurements TO dashboard;
    GRANT USAGE, SELECT ON SEQUENCE wind_measurements_id_seq TO sensors_reader;

    -- Table rainfall
    CREATE TABLE rainfall (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        amount INT NOT NULL,
        date_time TIMESTAMP WITH TIME ZONE NOT NULL
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

# Users allowed to log from anywhere - NOT SECURE
host all admin 0.0.0.0/0 scram-sha-256
host all sensors_reader 0.0.0.0/0 scram-sha-256
host all dashboard 0.0.0.0/0 scram-sha-256
EOF
