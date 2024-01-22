# Apache Flink

## Kafka to MySQL Data Pipeline

This README provides an overview of the data pipeline that ingests cryptocurrency price data from a Kafka source and transforms it before storing it in MySQL sink tables.

## Kafka Source Tables

### `SOURCE_CRYPTO_PRICES`

The `SOURCE_CRYPTO_PRICES` table represents the raw cryptocurrency price data obtained from a Kafka topic.

- `c`: Trade conditions.
- `p`: Last price (decimal with 18, 2 precision).
- `s`: Symbol. (Provided in format exchange:trading_pair)
- `t`: UNIX milliseconds timestamp (ms since 1970-01-01 00:00:00.000 UTC).
- `event_time`: Local timestamp with millisecond precision derived from `t`.
- `v`: Volume.
- `WATERMARK`: Watermark for time-based processing.

The table is configured to read data from a Kafka topic named 'crypto-prices' using the JSON format.

## Transformed Data

### `TRANSFORMED_CRYPTO_PRICES`

The `TRANSFORMED_CRYPTO_PRICES` view is created by transforming the raw data from `SOURCE_CRYPTO_PRICES`.

- `price`: Last price.
- `exchange`: Trading exchange (e.g., Binance).
- `trading_pair`: Trading pair (e.g., BTCUSD).
- `event_time`: Local timestamp with millisecond precision.
- `volume`: Volume.

## MySQL Sink Tables

### `CRYPTO_PRICES_HISTORY_SINK`

The `CRYPTO_PRICES_HISTORY_SINK` table stores historical cryptocurrency price data.

- `price`: Last price (decimal with 18, 2 precision).
- `exchange`: Trading exchange (VARCHAR).
- `trading_pair`: Trading pair (VARCHAR).
- `event_time`: Timestamp with milliseconds (TIMESTAMP(6)).
- `volume`: Volume (DOUBLE PRECISION).

### `CRYPTO_PRICES_AVERAGE_SINK`

The `CRYPTO_PRICES_AVERAGE_SINK` table stores the average cryptocurrency prices over a specified time interval.

- `price`: Last price (decimal with 18, 2 precision).
- `exchange`: Trading exchange (VARCHAR).
- `trading_pair`: Trading pair (VARCHAR).
- `trading_window_start`: Start of trading interval
- `trading_window_end`: End of trading interval
- `average_price`: Average price between `trading_window_start` and `trading_window_end`
- `total_volume`: Total volume traded between `trading_window_start` and `trading_window_end` (DOUBLE PRECISION).


This table has a primary key defined on `(exchange, trading_pair, trading_window_start, trading_window_end)` but is not enforced.

## Inserting Transformed Data into MySQL Sink Tables

Data from `TRANSFORMED_CRYPTO_PRICES` is inserted into the MySQL sink tables:

- `CRYPTO_PRICES_HISTORY_SINK`: Historical price data.
- `CRYPTO_PRICES_AVERAGE_SINK`: Average price data computed over a 5-minute interval.
