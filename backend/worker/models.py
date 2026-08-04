from sqlalchemy import Column
from sqlalchemy import String
from sqlalchemy import DateTime
from sqlalchemy.sql import func

from database import Base


class Job(Base):

    __tablename__ = "jobs"

    id = Column(String, primary_key=True)

    input = Column(String)

    status = Column(String)

    result = Column(String)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
