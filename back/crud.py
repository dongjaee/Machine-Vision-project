from sqlalchemy.orm import Session
from models import *

def create_video(db: Session, video_name: str, video_url: str):
    video_entry = Video(videoName=video_name, videoURL=video_url)
    db.add(video_entry)
    db.commit()
    db.refresh(video_entry)
    return video_entry