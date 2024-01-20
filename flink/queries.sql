/*****************************************************
                KAFKA SOURCE TABLES
*****************************************************/

CREATE TABLE SOURCE_CRYPTO_PRICES (
  c STRING,                                               -- Trade conditions
  p DECIMAL(18, 2),                                       -- Last price
  s STRING,                                               -- Symbol
  t BIGINT,                                               -- UNIX milliseconds timestamp (ms since 1970-01-01 00:00:00.000 UTC)              
  at_time AS TO_TIMESTAMP_LTZ(t, 3),                      -- Local timestamp with millisecond precision
  v DOUBLE,                                               -- Volume
  WATERMARK FOR at_time AS at_time - INTERVAL '5' SECOND  -- Watermark
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

CREATE VIEW TRANSFORMED_CRYPTO_PRICES  AS
SELECT
  p AS price,                               -- Last price       
  SPLIT_INDEX(s, ':',0) AS exchange,        -- Trading exchange (e.g. Coinbase)
  SPLIT_INDEX(s, ':',1) AS trading_pair,    -- Trading pair     (e.g. BTCUSD)
  at_time,                                  -- Local timestamp with millisecond precision
  v AS volume                               -- Volume
FROM SOURCE_CRYPTO_PRICES;

/*****************************************************
                 MYSQL SINK TABLES
*****************************************************/

CREATE TABLE CRYPTO_PRICES_HISTORY_SINK (
    price DECIMAL(18, 2),
    exchange VARCHAR(255),
    trading_pair VARCHAR(255),
    at_time TIMESTAMP(6),
    volume DOUBLE PRECISION,
    PRIMARY KEY (exchange, trading_pair, at_time) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:mysql://mysql:3306/crypto',
    'table-name' = 'price_history',
    'username' = 'user',
    'password' = 'password',
    'lookup.cache.max-rows' = '5000',
    'lookup.cache.ttl' = '10min'
);

CREATE TABLE CRYPTO_PRICES_AVERAGE_SINK (
    exchange VARCHAR(255),
    trading_pair VARCHAR(255),
    average_price DECIMAL(18, 2),
    PRIMARY KEY (exchange, trading_pair) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:mysql://mysql:3306/crypto',
    'table-name' = 'average_price',
    'username' = 'user',
    'password' = 'password',
    'lookup.cache.max-rows' = '5000',
    'lookup.cache.ttl' = '10min'
);

/*****************************************************
    INSERT TRANSFORMED DATA INTO MYSQL SINK TABLES
*****************************************************/

INSERT INTO CRYPTO_PRICES_HISTORY_SINK
SELECT
    price,
    exchange,
    trading_pair,
    at_time,
    volume
FROM TRANSFORMED_CRYPTO_PRICES;

INSERT INTO CRYPTO_PRICES_AVERAGE_SINK
SELECT
  exchange,            
  trading_pair,        
  AVG(price) AS average_price
FROM TRANSFORMED_CRYPTO_PRICES
GROUP BY
  exchange,
  trading_pair,
  TUMBLE(at_time, INTERVAL '5' MINUTES);
