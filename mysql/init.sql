/************************************************************
|                  SQL SCHEMA DEFINITION                     |
|                                                            |
|  Database and Table Creation Script                        |
|                                                            |
|  This SQL script is designed to define the schema for a    |
|  MySQL database used for storing cryptocurrency price      |
|  data. It includes the creation of the database, tables,   |
|  and necessary structures to organize and query the data.  |
|                                                            |
|  Author: Kane Norman                                       |
|  Date: 2024                                                |
|                                                            |
|  Notes:                                                    |
|  - Ensure that the MySQL user executing this script has    |
|    the necessary privileges to create databases and tables.|
|                                                            |
************************************************************/

/************************************************************
|                       USER CREATION                       |
************************************************************/
CREATE USER 'user'@'%' IDENTIFIED BY 'password';

/************************************************************
|                       PRIVILEGES                          |
************************************************************/
GRANT ALL PRIVILEGES ON *.* TO 'user'@'%';

/************************************************************
|                     DATABASE CREATION                     |
************************************************************/
CREATE DATABASE IF NOT EXISTS crypto;

/************************************************************
|                      DATABASE TABLES                      |
************************************************************/

CREATE TABLE IF NOT EXISTS crypto.price_history
(
    price           DECIMAL(18, 2),
    exchange        VARCHAR(255),
    trading_pair    VARCHAR(255),
    volume          DOUBLE,
    event_time      TIMESTAMP(3),
    ingestion_time  TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
);

CREATE TABLE IF NOT EXISTS crypto.average_price
(
    exchange              VARCHAR(255),
    trading_pair          VARCHAR(255),
    trading_window_start  TIMESTAMP(3),
    trading_window_end    TIMESTAMP(3),
    average_price         DOUBLE,
    PRIMARY KEY(exchange, trading_pair, trading_window_start, trading_window_end)
);
