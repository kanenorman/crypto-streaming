import unittest
from unittest.mock import Mock

import pytest
from confluent_kafka import KafkaException, Producer
from hamcrest import assert_that, equal_to, has_key, instance_of

from kafka_producer import main


def test_get_producer_configurations_is_dict():
    config = main._get_producer_configurations()
    assert_that(config, instance_of(dict))


def test_get_producer_configurations_has_bootstrap_servers():
    config = main._get_producer_configurations()
    assert_that(config, has_key("bootstrap.servers"))


def test_get_producer_configurations_has_client_id():
    config = main._get_producer_configurations()
    assert_that(config, has_key("client.id"))


def test_get_producer_configurations_bootstrap_servers_value():
    config = main._get_producer_configurations()
    assert_that(
        config["bootstrap.servers"],
        equal_to("broker1:9092,broker2:19092,broker3:29092"),
    )


def test_get_producer_configurations_client_id_value():
    config = main._get_producer_configurations()
    assert_that(config["client.id"], equal_to("crypto-price-producer"))


@pytest.mark.asyncio
async def test_create_kafka_producer():
    mock_get_producer_configurations = Mock(
        return_value={"bootstrap.servers": "mock_servers", "client.id": "mock_id"}
    )

    with unittest.mock.patch(
        "kafka_producer.main._get_producer_configurations",
        mock_get_producer_configurations,
    ):
        producer = await main._create_kafka_producer()

        assert_that(producer, instance_of(Producer))

    mock_get_producer_configurations.assert_called_once()


@pytest.mark.asyncio
async def test_send_record_to_kafka():
    mock_producer = Mock()

    sample_record = {"spam": "eggs"}

    await main._send_record_to_kafka(sample_record, mock_producer)

    mock_producer.produce.assert_called_once_with(
        topic="crypto-prices", value='{"spam": "eggs"}'
    )
    mock_producer.flush.assert_called_once()


@pytest.mark.asyncio
async def test_send_record_to_kafka_error_handling():
    mock_logger = Mock()
    mock_producer = Mock()
    mock_producer.produce.side_effect = KafkaException("Test KafkaException")

    sample_record = {"spam": "eggs"}

    await main._send_record_to_kafka(sample_record, mock_producer)

    mock_producer.produce.assert_called_once_with(
        topic="crypto-prices", value='{"spam": "eggs"}'
    )

    mock_logger.error.assert_called_once_with(
        "Error producing message to Kafka: Test KafkaException"
    )
