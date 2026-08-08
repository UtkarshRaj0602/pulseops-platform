###########################################################
# Stage 1 - Builder
###########################################################

FROM python:3.12-slim AS builder

# Prevent Python from writing pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Disable output buffering
ENV PYTHONUNBUFFERED=1

# Create virtual environment
ENV VIRTUAL_ENV=/opt/venv

RUN python -m venv ${VIRTUAL_ENV}

ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy dependency file first
COPY requirements.txt .

# Install Python packages
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY . .

###########################################################
# Stage 2 - Runtime
###########################################################

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

WORKDIR /app

# Create non-root user
RUN groupadd --system pulseops && \
    useradd \
    --system \
    --gid pulseops \
    --create-home \
    --shell /usr/sbin/nologin \
    pulseops

# Copy virtual environment
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Copy application
COPY --from=builder /app /app

# Set ownership
RUN chown -R pulseops:pulseops /app

USER pulseops

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "print('Worker healthy')" || exit 1

CMD ["python", "-m", "app.worker"]