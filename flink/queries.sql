/*****************************************************
|               KAFKA SOURCE TABLES                  |
*****************************************************/
CREATE TABLE SOURCE_CRYPTO_PRICES (
  c                  STRING,                                       -- Trade conditions
  p                  DECIMAL(18, 2),                               -- Last price
  s                  STRING,                                       -- Symbol
  t                  BIGINT,                                       -- UNIX milliseconds timestamp (ms since 1970-01-01 00:00:00.000 UTC)              
  event_time AS      TO_TIMESTAMP_LTZ(t, 3),                       -- Trade execution timestamp with millisecond precision
  v                  DOUBLE,                                       -- Volume
  WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND     -- Watermark
) WITH (
  'connector'                    = 'kafka',
  'topic'                        = 'crypto-prices',
  'scan.startup.mode'            = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker1:9092,broker2:19092,broker3:29092',
  'properties.group.id'          = 'crypto-price-consumer',
  'format'                       = 'json'
);

/*****************************************************
|                 TRANSFORMED DATA                   |
*****************************************************/
CREATE VIEW TRANSFORMED_CRYPTO_PRICES  AS
SELECT
  p AS price,                                -- Last price       
  SPLIT_INDEX(s, ':', 0) AS exchange,        -- Trading exchange (e.g. Coinbase)
  SPLIT_INDEX(s, ':', 1) AS trading_pair,    -- Trading pair     (e.g. BTCUSD)
  event_time,                                -- Trade execution timestamp with millisecond precision
  v AS volume                                -- Volume
FROM SOURCE_CRYPTO_PRICES;

/*****************************************************
|                MYSQL SINK TABLES                   |
*****************************************************/
CREATE TABLE CRYPTO_PRICES_HISTORY_SINK (
    price           DECIMAL(18, 2),
    exchange        VARCHAR(255),
    trading_pair    VARCHAR(255),
    volume          DOUBLE PRECISION,
    event_time      TIMESTAMP(3)
) WITH (
    'connector'  = 'jdbc',
    'url'        = 'jdbc:mysql://mysql:3306/crypto',
    'table-name' = 'price_history',
    'username'   = 'user',
    'password'   = 'password'
);

CREATE TABLE CRYPTO_PRICES_AVERAGE_SINK (
    exchange               VARCHAR(255),
    trading_pair           VARCHAR(255),
    trading_window_start   TIMESTAMP(3),
    trading_window_end     TIMESTAMP(3),
    average_price          DECIMAL(18, 2),
    total_volume           DECIMAL(18, 2),
    PRIMARY KEY(exchange, trading_pair, trading_window_start, trading_window_end) NOT ENFORCED
) WITH (
    'connector'  = 'jdbc',
    'url'        = 'jdbc:mysql://mysql:3306/crypto',
    'table-name' = 'average_price',
    'username'   = 'user',
    'password'   = 'password'
);

/*****************************************************
|   INSERT TRANSFORMED DATA INTO MYSQL SINK TABLES   |
*****************************************************/
INSERT INTO CRYPTO_PRICES_HISTORY_SINK
(
  price,
  exchange,
  trading_pair,
  volume,
  event_time
)
SELECT
  price,
  exchange,
  trading_pair,
  volume,
  event_time
FROM TRANSFORMED_CRYPTO_PRICES;


INSERT INTO CRYPTO_PRICES_AVERAGE_SINK
SELECT
  exchange,            
  trading_pair,        
  window_start  AS trading_window_start,
  window_end    AS trading_widow_end,
  AVG(price)    AS average_price,
  SUM(volume)   AS total_volume
FROM 
TABLE(
  TUMBLE(
     DATA    => TABLE TRANSFORMED_CRYPTO_PRICES,
     TIMECOL => DESCRIPTOR(event_time),
     SIZE    => INTERVAL '5' MINUTES
  ) 
)
GROUP BY
  exchange,
  trading_pair,
  window_start,
  window_end;
