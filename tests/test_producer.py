import json
from unittest.mock import AsyncMock, Mock, call, patch

import pytest
from confluent_kafka import KafkaException, Producer
from hamcrest import assert_that, equal_to, has_key, instance_of

from kafka import producer as service
from kafka.producer import WebSocketException


@pytest.fixture
def sample_record():
    return {"spam": "eggs"}


@pytest.fixture
def mock_producer():
    return Mock()


@pytest.fixture
def producer_config():
    return service._get_producer_configurations()


@pytest.fixture
def mock_logger():
    with patch("kafka.producer.logger") as mock_logger:
        yield mock_logger


@pytest.fixture
def mock_get_producer_configurations():
    with patch("kafka.producer._get_producer_configurations") as mock_config:
        mock_config.return_value = {
            "bootstrap.servers": "mock_servers",
            "client.id": "mock_id",
        }
        yield mock_config


def test_get_producer_configurations_is_dict(producer_config):
    assert_that(producer_config, instance_of(dict))


def test_get_producer_configurations_has_keys(producer_config):
    assert_that(producer_config, has_key("bootstrap.servers"))
    assert_that(producer_config, has_key("client.id"))


def test_get_producer_configurations_values(producer_config):
    assert_that(
        producer_config["bootstrap.servers"],
        equal_to("broker1:9092,broker2:19092,broker3:29092"),
    )
    assert_that(producer_config["client.id"], equal_to("crypto-price-producer"))


@pytest.mark.asyncio
async def test_create_kafka_producer(mock_get_producer_configurations):
    producer = await service._create_kafka_producer()
    assert_that(producer, instance_of(Producer))
    mock_get_producer_configurations.assert_called_once()


@pytest.mark.asyncio
async def test_send_record_to_kafka(sample_record, mock_producer):
    await service._send_record_to_kafka(sample_record, mock_producer)
    mock_producer.produce.assert_called_once_with(
        topic="crypto-prices", value=json.dumps(sample_record)
    )
    mock_producer.flush.assert_called_once()


@pytest.mark.asyncio
async def test_send_record_to_kafka_error_handling(
    sample_record, mock_producer, mock_logger
):
    mock_producer.produce.side_effect = KafkaException("Test KafkaException")
    await service._send_record_to_kafka(sample_record, mock_producer)
    mock_producer.produce.assert_called_once_with(
        topic="crypto-prices", value=json.dumps(sample_record)
    )
    mock_logger.error.assert_called_once_with(
        "Error producing message to Kafka: Test KafkaException"
    )


@pytest.mark.parametrize(
    "message_type, expected_call_count", [("trade", 2), ("non-trade", 0)]
)
@pytest.mark.asyncio
async def test_on_message(message_type, expected_call_count, mock_logger):
    mock_producer = Producer({"bootstrap.servers": "dummy"})
    mock_send_record = AsyncMock()

    message = json.dumps(
        {"type": message_type, "data": [{"spam": "eggs"}, {"foo": "bar"}]}
    )

    with patch("kafka.producer._send_record_to_kafka", mock_send_record):
        await service._on_message(message, mock_producer)

    mock_logger.info.assert_called_with(f"Received message: {message}")
    assert_that(mock_send_record.call_count, equal_to(expected_call_count))


@pytest.mark.asyncio
async def test_subscribe_to_symbol_success():
    mock_websocket = AsyncMock()
    symbol = "BTCUSD"

    with patch("kafka.producer.logger") as mock_logger:
        await service._subscribe_to_symbol(mock_websocket, symbol)

    mock_logger.info.assert_called_with(f"Subscribing to symbol: {symbol}")
    mock_websocket.send.assert_awaited_once_with(
        f'{{"type":"subscribe","symbol":"{symbol}"}}'
    )


@pytest.mark.asyncio
async def test_subscribe_to_symbol_with_retries():
    mock_websocket = AsyncMock()
    mock_websocket.send.side_effect = [WebSocketException("Connection error"), None]
    symbol = "BTCUSD"

    with patch("kafka.producer.logger") as mock_logger:
        await service._subscribe_to_symbol(mock_websocket, symbol)

    # assert the logger was called twice - once for each attempt
    assert_that(mock_logger.info.call_count, equal_to(2))

    # assert the WebSocket send method was called twice - once for each attempt
    assert_that(mock_websocket.send.call_count, equal_to(2))

    # verify that the correct message was sent each time
    mock_websocket.send.assert_has_awaits(
        [call(f'{{"type":"subscribe","symbol":"{symbol}"}}')] * 2
    )
