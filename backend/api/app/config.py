# from pydantic_settings import BaseSettings


# class Settings(BaseSettings):

#     APP_NAME: str = "PulseOps Platform"
#     APP_ENV: str

#     HOST: str = "0.0.0.0"
#     PORT: int = 8000

#     DB_HOST: str
#     DB_PORT: int
#     DB_NAME: str

#     DB_USERNAME: str
#     DB_PASSWORD: str

#     REDIS_HOST: str
#     REDIS_PORT: int

#     SQS_QUEUE_NAME: str
#     SQS_QUEUE_URL: str

#     LOG_LEVEL: str = "INFO"

#     AWS_REGION: str

#     POLL_INTERVAL: int = 5

#     class Config:
#         env_file = ".env"


# settings = Settings()


from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = "PulseOps Platform"
    APP_ENV: str = "development"

    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # --------------------------------------------------
    # PostgreSQL
    # --------------------------------------------------

    DB_HOST: str
    DB_PORT: int = 5432
    DB_NAME: str
    DB_USERNAME: str
    DB_PASSWORD: str

    # --------------------------------------------------
    # Redis
    # --------------------------------------------------

    REDIS_HOST: str
    REDIS_PORT: int = 6379
    REDIS_TTL: int = 600

    # --------------------------------------------------
    # SQS
    # --------------------------------------------------

    SQS_QUEUE_NAME: str
    SQS_QUEUE_URL: str

    # --------------------------------------------------
    # AWS
    # --------------------------------------------------

    AWS_REGION: str = "ap-south-1"

    # --------------------------------------------------
    # Application
    # --------------------------------------------------

    LOG_LEVEL: str = "INFO"
    POLL_INTERVAL: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()
