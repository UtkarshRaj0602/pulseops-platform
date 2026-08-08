from pydantic_settings import BaseSettings


class Settings(BaseSettings):

    APP_NAME: str = "PulseOps Platform"
    APP_ENV: str

    # HOST: str = "0.0.0.0"
    # PORT: int = 8000

    DB_HOST: str
    DB_PORT: int
    DB_NAME: str

    DB_USERNAME: str
    DB_PASSWORD: str

    REDIS_HOST: str
    REDIS_PORT: int

    SQS_QUEUE_NAME: str
    SQS_QUEUE_URL: str

    LOG_LEVEL: str = "INFO"

    AWS_REGION: str

    POLL_INTERVAL: int = 5

    class Config:
        env_file = ".env"


settings = Settings()
