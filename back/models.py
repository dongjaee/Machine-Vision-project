from sqlalchemy import Column, Integer, String
from database import *

class Video(Base):
    __tablename__ = "videoinfo"

    videoName = Column(String(255), primary_key=True, index=True)
    videoURL = Column(String(255), index=True)
    