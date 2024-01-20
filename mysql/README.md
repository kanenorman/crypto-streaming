# MySQL 

## Overview
This README provides a comprehensive explanation of the SQL schema definition script designed for the creation 
and organization of a MySQL database intended for the storage of cryptocurrency price data. 
These tables are pivotal as sink connectors for Apache Flink, and they securely house the data.


## Table Structures

```sql
CREATE TABLE IF NOT EXISTS crypto.price_history
(
    price DECIMAL(18, 2),
    exchange VARCHAR(255),
    trading_pair VARCHAR(255),
    at_time TIMESTAMP,
    volume DOUBLE,
    PRIMARY KEY (exchange, trading_pair, at_time)
);
```
This table, crypto.price_history, is used to store historical cryptocurrency price data. 
The combination of `exchange`, `trading_pair`, and `at_time` forms the primary key, ensuring uniqueness.

```sql
CREATE TABLE IF NOT EXISTS crypto.average_price
(
    exchange VARCHAR(255),
    trading_pair VARCHAR(255),
    average_price DOUBLE,
    PRIMARY KEY (exchange, trading_pair)
);
```

The crypto.average_price table is dedicated to storing average cryptocurrency prices over the past 5 minutes.
The primary key consists of `exchange` and `trading_pair`.
