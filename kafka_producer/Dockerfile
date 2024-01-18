FROM python:3.10

WORKDIR /app

COPY kafka_producer/requirements.txt .
RUN pip install -r requirements.txt

COPY kafka_producer/ kafka_producer/

CMD ["python", "-m", "kafka_producer.main"]
