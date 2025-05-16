# Stage 1: Build
FROM python:3.11-slim as builder

WORKDIR /app

COPY pyproject.toml .

RUN pip install .[test]

COPY . .

# Stage 2: Production image
FROM python:3.11-slim

RUN useradd -m appuser

WORKDIR /app
COPY --from=builder /app /app

RUN pip install --no-cache-dir .

user appuser

ENV PATH="/root/.local/bin:$PATH" \
    PYTHONPATH="/app" \
    DATABASE_URL="postgresql+psycopg://kubsu:kubsu@db:5432/kubsu"

EXPOSE 8115

CMD ["unicorn", "src.main:app","--host","0.0.0.0","--port", "8115"]
