from pydantic_settings import BaseSettings


class Settings(BaseSettings):

    AWS_REGION: str
    SQS_QUEUE_URL: str

    POSTGRES_HOST: str
    POSTGRES_PORT: int
    POSTGRES_DB: str
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str

    REDIS_HOST: str
    REDIS_PORT: int

    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"


settings = Settings()
