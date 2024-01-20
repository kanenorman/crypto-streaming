# Apache Kafka
## Crypto Price WebSocket to Kafka Producer

This Python script sets up a WebSocket connection to retrieve cryptocurrency price data and sends it to a Kafka topic. 
It uses the [Finnhub](https://finnhub.io/docs/api/websocket-trades) WebSocket API to subscribe to specific cryptocurrency pairs (symbols) 
and then forwards the received data to a Kafka topic called `crypto-prices`.

## Prerequisites

Before running the script, make sure you have the following:
- A valid Finnhub API key set in your environment variables as `FINNHUB_API_KEY`

## Customization
You can customize the following aspects of the script:

Symbols to subscribe to: Modify the `symbols_to_subscribe` list in the main function to include the cryptocurrency pairs you're interested in.
