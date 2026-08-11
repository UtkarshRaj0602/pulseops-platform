# from sqlalchemy import Column
# from sqlalchemy import String
# from sqlalchemy import DateTime
# from sqlalchemy.sql import func

# from app.database import Base


# class Job(Base):

#     __tablename__ = "jobs"

#     id = Column(String, primary_key=True)

#     input = Column(String)

#     status = Column(String)

#     result = Column(String)

#     created_at = Column(DateTime(timezone=True), server_default=func.now())

#     updated_at = Column(DateTime(timezone=True), onupdate=func.now())


from sqlalchemy import Column
from sqlalchemy import DateTime
from sqlalchemy import String
from sqlalchemy import Text
from sqlalchemy.sql import func

from app.database import Base


class Job(Base):

    __tablename__ = "jobs"

    id = Column(
        String,
        primary_key=True,
        nullable=False,
    )

    input = Column(
        Text,
        nullable=False,
    )

    status = Column(
        String(20),
        nullable=False,
        default="QUEUED",
    )

    result = Column(
        Text,
        nullable=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
