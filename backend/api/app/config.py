from pydantic_settings import BaseSettings


class Settings(BaseSettings):

    APP_NAME: str = "PulseOps Platform"
    APP_ENV: str = "development"

    HOST: str = "0.0.0.0"
    PORT: int = 8000

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
