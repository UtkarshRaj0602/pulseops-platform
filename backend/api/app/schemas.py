from pydantic import BaseModel


class JobCreate(BaseModel):
    text: str


class JobResponse(BaseModel):
    id: str
    input: str
    status: str
    result: str | None = None

    class Config:
        from_attributes = True
