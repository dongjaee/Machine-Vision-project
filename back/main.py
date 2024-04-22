from fastapi import FastAPI, File, UploadFile, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import shutil

from crud import *
from database import *

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,  # cookie 포함 여부 (default=False)
    allow_methods=["*"],     # 허용할 method(default=['GET']
    allow_headers=["*"],     # 허용할 HTTP Header 목록
)

@app.post("/upload_video/")
async def upload_video(video: UploadFile = File(...), db: Session = Depends(get_db)):
    video_name = video.filename
    video_url = f"http://yourdomain.com/uploaded_videos/{video_name}"  # 접근 가능한 URL 형식으로 변경해야 합니다.

    try:
        video_entry = create_video(db=db, video_name=video_name, video_url=video_url)
        return {
            "videoName": video_entry.videoName,
            "videoURL": video_entry.videoURL,
            "message": "Video uploaded successfully and info saved to database."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred while uploading the video. Error: {e}")
