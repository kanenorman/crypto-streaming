FROM flink:1.18.0-scala_2.12-java11

# Download the Flink Kafka connector dependency and add it to the Flink lib directory
RUN apt-get update && apt-get install -y wget
RUN wget -O /opt/flink/lib/flink-sql-connector-kafka-3.0.2-1.18.jar \
    https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.0.2-1.18/flink-sql-connector-kafka-3.0.2-1.18.jar


COPY /stream_processing/queries.sql /opt/queries.sql

