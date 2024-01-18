CREATE TABLE CryptoPrices (
  c STRING,
  p DECIMAL(18, 2),
  s STRING,
  t BIGINT,
  v DECIMAL(18, 3)
) WITH (
  'connector' = 'kafka',
  'topic' = 'crypto-prices',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker1:9092,broker2:19092,broker3:29092',
  'properties.group.id' = 'crypto-price-consumer',
  'format' = 'json'
);