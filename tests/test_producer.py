import json
from unittest.mock import AsyncMock, Mock, call, patch

import pytest
from confluent_kafka import KafkaException, Producer
from hamcrest import assert_that, equal_to, has_key, instance_of

from kafka import producer as service


@pytest.fixture
def sample_record():
    return {"spam": "eggs"}


@pytest.fixture
def mock_producer():
    return Mock()


@pytest.fixture
def producer_config():
    return service._get_producer_configurations()


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
async def test_create_kafka_producer():
    mock_get_producer_configurations = Mock(
        return_value={"bootstrap.servers": "mock_servers", "client.id": "mock_id"}
    )
    with patch(
        "kafka.producer._get_producer_configurations", mock_get_producer_configurations
    ):
        producer = await service._create_kafka_producer()
        assert_that(producer, instance_of(Producer))
    mock_get_producer_configurations.assert_called_once()


@pytest.mark.asyncio
async def test_send_record_to_kafka(sample_record, mock_producer):
    await service._send_record_to_kafka(sample_record, mock_producer)
    mock_producer.produce.assert_called_once_with(
        topic="crypto-prices", value='{"spam": "eggs"}'
    )
    mock_producer.flush.assert_called_once()


@pytest.mark.asyncio
async def test_send_record_to_kafka_error_handling(sample_record):
    with patch("kafka.producer.logger") as mock_logger:
        mock_producer = Mock()
        mock_producer.produce.side_effect = KafkaException("Test KafkaException")
        await service._send_record_to_kafka(sample_record, mock_producer)
        mock_producer.produce.assert_called_once_with(
            topic="crypto-prices", value='{"spam": "eggs"}'
        )
        mock_logger.error.assert_called_once_with(
            "Error producing message to Kafka: Test KafkaException"
        )


@pytest.mark.asyncio
async def test_on_message_with_trade_type():
    mock_producer = Producer({"bootstrap.servers": "dummy"})
    mock_send_record = AsyncMock()

    message = json.dumps({"type": "trade", "data": [{"spam": "eggs"}, {"foo": "bar"}]})

    with patch("kafka.producer.logger") as mock_logger, patch(
        "kafka.producer._send_record_to_kafka", mock_send_record
    ):
        await service._on_message(message, mock_producer)

    mock_logger.info.assert_called_with("Received message: %s", message)

    assert_that(mock_send_record.call_count, equal_to(2))
    mock_send_record.assert_any_call({"spam": "eggs"}, mock_producer)
    mock_send_record.assert_any_call({"foo": "bar"}, mock_producer)


@pytest.mark.asyncio
async def test_on_message_with_non_trade_type():
    mock_producer = Mock()
    mock_send_record = AsyncMock()

    message = json.dumps(
        {"type": "non-trade", "data": [{"spam": "eggs"}, {"foo": "bar"}]}
    )

    with patch("kafka.producer.logger") as mock_logger, patch(
        "kafka.producer._send_record_to_kafka", mock_send_record
    ):
        await service._on_message(message, mock_producer)

    mock_logger.info.assert_called_with("Received message: %s", message)
    mock_send_record.assert_not_called()
