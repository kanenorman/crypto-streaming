import asyncio
import json
import logging
import os
from typing import Dict

import websockets
from confluent_kafka import KafkaException, Producer
from tenacity import retry, stop_after_attempt, wait_fixed

logger = logging.getLogger(__name__)


def _get_producer_configurations() -> Dict[str, str]:
    return {
        "bootstrap.servers": "localhost:9092",
        "client.id": "bitcoin-price-producer",
    }


async def _create_kafka_producer() -> Producer:
    producer_configurations = _get_producer_configurations()
    return Producer(producer_configurations)


async def _send_record_to_kafka(record, producer):
    try:
        producer.produce(topic="crypto-prices", value=json.dumps(record))
        producer.flush()
    except KafkaException as e:
        logger.error(f"Error producing message to Kafka: {e}")


async def _on_message(message: str, producer: Producer) -> None:
    logger.info("Received message: %s", message)
    try:
        data = json.loads(message)
        if data.get("type") == "trade":
            records = data.get("data")
            if records:
                tasks = (
                    asyncio.ensure_future(_send_record_to_kafka(record, producer))
                    for record in records
                )
                await asyncio.gather(*tasks)
    except KafkaException as e:
        logger.error(f"Error producing message to Kafka: {e}")


@retry(stop=stop_after_attempt(3), wait=wait_fixed(5))
async def _subscribe_to_symbol(
    websocket: websockets.WebSocketClientProtocol, symbol: str
) -> None:
    logger.info(f"Subscribing to symbol: {symbol}")
    await websocket.send(f'{{"type":"subscribe","symbol":"{symbol}"}}')


async def main() -> None:
    api_key = os.environ.get("FINNHUB_API_KEY")
    if not api_key:
        logger.error("FINNHUB_API_KEY not set in environment variables.")
        return

    websocket_url = f"wss://ws.finnhub.io?token={api_key}"
    symbols_to_subscribe = ["BINANCE:BTCUSDT", "BINANCE:ETHUSDT", "BINANCE:DOGEUSDT"]
    kafka_producer = await _create_kafka_producer()

    async with websockets.connect(websocket_url) as websocket:
        await asyncio.gather(
            *(
                _subscribe_to_symbol(websocket, symbol)
                for symbol in symbols_to_subscribe
            )
        )

        async for message in websocket:
            await _on_message(message, kafka_producer)


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    )
    asyncio.run(main())
