/*****************************************************
                KAFKA SOURCE TABLES
*****************************************************/

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

/*****************************************************
                  TRANSFORMED DATA
*****************************************************/

CREATE VIEW CRYPTO_PRICES_SILVER  AS
SELECT
  c AS conditions,                    -- Trade conditions
  p AS price,                         -- Last price
  s AS symbol,                        -- Symbol
  TO_TIMESTAMP_LTZ(t, 3) AS at_time,  -- Local timestamp with millisecond precision
  v AS volume                         -- Volume
FROM CRYPTO_PRICES_BRONZE;

/*****************************************************
                 MYSQL SINK TABLES
*****************************************************/

CREATE TABLE MYSQL_PRICE_HISTORY_SINK (
    conditions VARCHAR(255),
    price DECIMAL(18, 2),
    symbol VARCHAR(255),
    at_time TIMESTAMP(6),
    volume DOUBLE PRECISION,
    PRIMARY KEY (symbol, at_time) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:mysql://mysql:3306/crypto',
    'table-name' = 'price_history',
    'username' = 'user',
    'password' = 'password',
    'lookup.cache.max-rows' = '5000',
    'lookup.cache.ttl' = '10min'
);

/*****************************************************
    INSERT TRANSFORMED DATA INTO MYSQL SINK TABLES
*****************************************************/

INSERT INTO MYSQL_PRICE_HISTORY_SINK
SELECT
    conditions,
    price,
    symbol,
    at_time,
    volume
FROM CRYPTO_PRICES_SILVER;
