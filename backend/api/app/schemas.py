# from pydantic import BaseModel


# class JobCreate(BaseModel):
#     text: str


# class JobResponse(BaseModel):
#     id: str
#     input: str
#     status: str
#     result: str | None = None

#     class Config:
#         from_attributes = True


from datetime import datetime

from pydantic import BaseModel
from pydantic import Field
from pydantic import field_validator


class JobCreate(BaseModel):

    text: str = Field(
        min_length=1,
        max_length=5000,
    )

    @field_validator("text")
    @classmethod
    def validate_text(cls, value: str) -> str:

        value = value.strip()

        if not value:
            raise ValueError("Text cannot be empty")

        return value


class JobCreateResponse(BaseModel):

    job_id: str
    status: str
    message: str


class JobResponse(BaseModel):

    id: str
    input: str
    status: str
    result: str | None = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
