/************************************************************
                      SQL SCHEMA DEFINITION

Database and Table Creation Script

This SQL script is designed to define the schema for a MySQL
database used for storing cryptocurrency price data. It includes
the creation of the database, tables, and necessary structures
to organize and query the data.

Author: Kane Norman
Date: 2024

Notes:
- Ensure that the MySQL user executing this script has the necessary
  privileges to create databases and tables.

************************************************************/

/************************************************************
                          PRIVILEGES
************************************************************/

GRANT ALL PRIVILEGES ON *.* TO 'user'@'%' IDENTIFIED BY 'password';

/************************************************************
                    DATABASE CREATION
************************************************************/
CREATE DATABASE IF NOT EXISTS crypto;

/************************************************************
                    DATABASE TABLES
************************************************************/

CREATE TABLE IF NOT EXISTS crypto.price_history
(
    conditions VARCHAR(255),
    price DECIMAL(18, 2),
    exchange VARCHAR(255),
    trading_pair VARCHAR(255),
    at_time TIMESTAMP,
    volume DOUBLE,
    PRIMARY KEY (exchange, trading_pair, at_time)
);

CREATE TABLE IF NOT EXISTS crypto.average_price
(
    exchange VARCHAR(255),
    trading_pair VARCHAR(255),
    average_price DOUBLE,
    PRIMARY KEY (exchange, trading_pair)
);