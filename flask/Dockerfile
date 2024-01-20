FROM python:3.10

ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8

WORKDIR /app

COPY flask/requirements.txt .
RUN python -m pip install -r requirements.txt

COPY flask/ /app/flask
WORKDIR /app/flask

EXPOSE 5000

CMD ["flask", "run", "--host", "0.0.0.0"]