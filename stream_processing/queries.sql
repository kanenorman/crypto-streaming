/*********************************
CREATE A KAFKA SOURCE TABLE

READS KAFKA TOPIC `crypto-prices`
AND CREATES A SOURCE TABLE WITH THE DATA
FROM THE TOPIC
*********************************/

CREATE TABLE CRYPTO_PRICES_BRONZE (
  c STRING,              -- Trade conditions
  p DECIMAL(18, 2),      -- Last price
  s STRING,              -- Symbol
  t BIGINT,              -- UNIX timestamp in milliseconds
  v DOUBLE               -- Volume
) WITH (
  'connector' = 'kafka',
  'topic' = 'crypto-prices',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker1:9092,broker2:19092,broker3:29092',
  'properties.group.id' = 'crypto-price-consumer',
  'format' = 'json'
);

/*********************************
CREATE A VIEW FOR TRANSFORMED DATA

READS DATA FROM CRYPTO_PRICES_BRONZE TABLE
AND CREATES A VIEW WITH TRANSFORMED COLUMNS
**********************************/

CREATE VIEW CRYPTO_PRICES_SILVER  AS
SELECT
  c AS conditions,                    -- Trade conditions
  p AS price,                         -- Last price
  s AS symbol,                        -- Symbol
  TO_TIMESTAMP_LTZ(t, 3) AS at_time,  -- Local timestamp with millisecond precision
  v AS volume                         -- Volume
FROM CRYPTO_PRICES_BRONZE;
