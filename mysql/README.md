# MySQL 

## Overview
This README provides a comprehensive explanation of the SQL schema definition script designed for the creation 
and organization of a MySQL database intended for the storage of cryptocurrency price data. 
These tables are pivotal as sink connectors for Apache Flink, and they securely house the data.


## Table Structures

This table, `crypto.price_history`, is used to store historical cryptocurrency price data.
There is no primary key. There can be duplicate rows. 

```sql
CREATE TABLE IF NOT EXISTS crypto.price_history
(
    price           DECIMAL(18, 2),
    exchange        VARCHAR(255),
    trading_pair    VARCHAR(255),
    volume          DOUBLE,
    event_time      TIMESTAMP(3),
    ingestion_time  TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
);
```



The `crypto.average_price` table is dedicated to storing average cryptocurrency prices and total volume over 5-minute fixed windows.
The primary key consists of `exchange`, `trading_pair`, `trading_window_start`, and `trading_window_end`.

```sql
CREATE TABLE IF NOT EXISTS crypto.average_price
(
    exchange              VARCHAR(255),
    trading_pair          VARCHAR(255),
    trading_window_start  TIMESTAMP(3),
    trading_window_end    TIMESTAMP(3),
    average_price         DOUBLE,
    total_volume          DOUBLE,
    PRIMARY KEY(exchange, trading_pair, trading_window_start, trading_window_end)
);
```
