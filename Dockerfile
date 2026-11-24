FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /srv

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY api ./api
WORKDIR /srv/api

# Cloud Run injects $PORT
CMD ["sh", "-c", "python -m fastapi run main.py --port ${PORT:-8080}"]
