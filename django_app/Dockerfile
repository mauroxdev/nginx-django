FROM python:3.10-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk --no-cache add build-base

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup -S django && adduser -S django -G django

RUN chown -R django:django /app

USER django

CMD ["/bin/sh", "-c", "${GUNICORN_CMD}"]
