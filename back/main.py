from fastapi import FastAPI, File, UploadFile, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
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

#정적 파일 디렉토리 설정
app.mount('/video',StaticFiles(directory='video'),name='video')

@app.post("/upload_video/")
async def upload_video(video: UploadFile = File(...), db: Session = Depends(get_db)):
    video_name = video.filename
    video_path = f"video/{video_name}"
    video_url = f"http://localhost:8000/video/{video_name}"  

    try:
        # 비디오 파일을 디렉토리에 저장
        with open(video_path, "wb+") as file_object:
            file_object.write(await video.read())

        # 비디오 데이터베이스 항목 생성
        video_entry = Video(videoName=video_name, videoURL=video_url)
        db.add(video_entry)
        db.commit()
        db.refresh(video_entry)
        return {
            "videoName": video_entry.videoName,
            "videoURL": video_entry.videoURL,
            "message": "Video uploaded successfully and info saved to database."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred while uploading the video. Error: {e}")
