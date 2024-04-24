from fastapi import FastAPI, File, Form, UploadFile, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from typing import List
import shutil

import os
from pydantic import BaseModel
from dotenv import load_dotenv
import replicate

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

#비디오 파일 & DB에 저장 
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
    
    

stored_objects = []

@app.post("/upload_detect_objects/")
async def upload_detect_objects(object: str = Form(...)):
    if object is None:
        raise HTTPException(status_code=400, detail="No object provided")

    # 객체를 서버의 리스트에 저장
    stored_objects.append(object)
    return {"message": "Object upload successful", "current_objects": stored_objects}




# 환경 변수 파일 로드
load_dotenv()

# API 토큰 환경변수에서 가져오기
api_token = os.getenv("REPLICATE_API_TOKEN")

class ImageQuery(BaseModel):
    image_url: str
    query: str
    box_threshold: float = 0.2
    text_threshold: float = 0.2
    show_visualisation: bool = True

@app.post("/detecting_video/")
async def process_image(query: ImageQuery):
    try:
        output = replicate.run(
            "adirik/grounding-dino:efd10a8ddc57ea28773327e881ce95e20cc1d734c589f7dd01d2036921ed78aa",
            input={
                "image": query.image_url,
                "query": query.query,
                "box_threshold": query.box_threshold,
                "text_threshold": query.text_threshold,
                "show_visualisation": query.show_visualisation
            }
        )
        return output
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


