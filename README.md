# Real-Time Cryptocurrency Price Data Pipeline
[![Unit Tests](https://github.com/kanenorman/crypto-streaming/actions/workflows/unit-test.yaml/badge.svg)](https://github.com/kanenorman/crypto-streaming/actions/workflows/unit-test.yaml)
[![codecov](https://codecov.io/gh/kanenorman/crypto-streaming/graph/badge.svg?token=BZYYA8YX2W)](https://codecov.io/gh/kanenorman/crypto-streaming)

## Overview

This repository implements a real-time data pipeline for processing cryptocurrency price data. It uses a suite of technologies including Docker, WebSockets, Apache Kafka, Apache Flink, and MySQL.

## Architecture

The pipeline is designed as follows:

- **WebSockets**: Streams real-time cryptocurrency price data.
- **Apache Kafka**: Acts as a messaging system that decouples the data ingestion from processing.
- **Apache Flink**: Processes the streaming data and applies transformations.
- **MySQL**: Stores the processed data for further analysis or querying.

![System-Design](./assets/system-design.png)

## Components

### `producer.py`

This Python script is responsible for establishing a connection to Finnhub via WebSockets. It ingests real-time cryptocurrency price data and then publishes it to a specified Kafka topic, ensuring that the data is ready for stream processing.

### `queries.sql`

This file contains a collection of Flink SQL queries. These queries are used for streaming the data from Kafka, performing necessary transformations, and ultimately publishing the processed data to a MySQL sink.

### `init.sql`

This SQL script is designed to set up the initial database schema in MySQL. It defines the structure of the tables and other database objects necessary for storing the cryptocurrency price data that has been processed by Flink.

## Setup and Configuration

### Prerequisites

- Docker
- Finnhub API Key

### Usage

1. Clone the repository to your local machine.
   ```
   git clone git@github.com:kanenorman/crypto-streaming.git
   ```
2. Ensure Docker is running
   ```
   sudo systemctl start docker
   ```
3. Create a `.env` file
   ```
   FINNHUB_API_KEY=<your-api-key>
   MYSQL_ROOT_USER=user
   MYSQL_ROOT_PASSWORD=password
   ```
4. Start the containers
   ```
   docker compose build && docker compose up -d
   ```

## Demonstration

The `crypto.price_history` function logs individual trades, providing precise information on the price, volume, and exact timing of each trade. On the far right, we display the latency to demonstrate the real-time nature of our stream.
![Price-History](./assets/price-history.png)


The `crypto.average_price` function consolidates trade data into predefined intervals, presenting the average price and total trading volume within those specified time windows. This feature proves valuable in gaining insights into market trends over these intervals.
![Average-Price](./assets/average-price.png)


## License

This project is licensed under the [MIT License](LICENSE).

