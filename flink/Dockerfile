FROM flink:1.17.0-scala_2.12-java11

RUN apt-get update && apt-get install -y wget && \
    wget -P /opt/flink/lib/ \
    https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.0.2-1.17/flink-sql-connector-kafka-3.0.2-1.17.jar \
    https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.1-1.17/flink-connector-jdbc-3.1.1-1.17.jar  \
    https://repo.maven.apache.org/maven2/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar;

COPY /flink/queries.sql /opt/queries.sql
