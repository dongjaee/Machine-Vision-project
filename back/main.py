import io
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient, ContentSettings
from fastapi import FastAPI, File, Form, UploadFile, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from matplotlib import pyplot as plt
from sqlalchemy.orm import Session
from sqlalchemy import desc
from datetime import datetime
from typing import List
import shutil
import uuid
import base64

import requests
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

load_dotenv()

@app.post("/upload_video/")
async def upload_video(video: UploadFile = File(...), db: Session = Depends(get_db)):
    video_name = video.filename
    video_path = f"video/{video_name}"
    video_url = f"https://osovideo.blob.core.windows.net/oso-video/{video_name}"
    container_name = "oso-video"
    AZURE_ACCOUNT_KEY = os.getenv("AZURE_ACCOUNT_KEY")
    connection_string = f'DefaultEndpointsProtocol=https;AccountName=osovideo;AccountKey={AZURE_ACCOUNT_KEY};EndpointSuffix=core.windows.net'
    blob_client = BlobClient.from_connection_string(conn_str=connection_string, container_name=container_name, blob_name=video.filename)

    try:
        # 비동기로 파일 데이터 읽기
        file_data = await video.read()
        
        # ContentSettings 객체 생성 및 콘텐츠 형식 설정
        content_settings = ContentSettings(
            content_type="video/mp4",
            content_disposition=None
        )
        
        # 동기로 Azure Blob Storage에 업로드
        blob_client.upload_blob(file_data, overwrite=True, content_settings=content_settings)
        
        # DB에 추가
        video_entry = Video(videoName=video_name, videoURL=video_url)
        db.add(video_entry)
        db.commit()
        db.refresh(video_entry)
        
        return {"filename": video.filename, "videourl": video_url, "message": "Video uploaded successfully."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred while uploading the video. Error: {str(e)}")
    


@app.post("/upload_detect_objects/")
async def upload_detect_objects(object: str = Form(...)):
    stored_objects = []
    if object is None:
        raise HTTPException(status_code=400, detail="No object provided")

    # 객체를 서버의 리스트에 저장
    stored_objects.append(object)
    return {"message": "Object upload successful", "current_objects": stored_objects}



@app.post("/process_video")
async def process_video(object_name: str, db: Session = Depends(get_db)):
    # DB에서 가장 마지막에 업로드된 동영상 URL 조회
    last_video = db.query(Video).order_by(desc(Video.videoName)).first()
    if last_video is None:
        raise HTTPException(status_code=404, detail="No videos found in the database")

    video_url = last_video.videoURL
    video_name = os.path.basename(video_url)
    video_name_without_ext = os.path.splitext(video_name)[0]

    # 코랩의 FastAPI 앱 호출
    colab_url = "https://21dc-35-194-182-53.ngrok-free.app/detect_objects"  # 최신 ngrok URL로 업데이트 필요
    response = requests.post(colab_url, json={"video_url": video_url, "object_name": object_name})

    if response.status_code == 200:
        result = response.json()
        total_bounding_boxes = result["total_bounding_boxes"]
        graph_data = result["graph_data"]
        video_data = result["video_data"]

        # Base64 디코딩
        graph_data = base64.b64decode(graph_data)
        video_data = base64.b64decode(video_data)

        # 로컬 저장 경로 설정
        output_dir = os.path.join('.', 'output_asset')
        os.makedirs(output_dir, exist_ok=True)
        graph_path = os.path.join(output_dir, f"{video_name_without_ext}_result.png")
        video_path = os.path.join(output_dir, f"{video_name_without_ext}_output_video.mp4")

        # 그래프 이미지 저장
        with open(graph_path, "wb") as f:
            f.write(graph_data)

        # 비디오 파일 저장
        with open(video_path, "wb") as f:
            f.write(video_data)

        return {
            "total_bounding_boxes": total_bounding_boxes,
            "graph_data": graph_path,  # 로컬에 저장된 그래프 이미지 경로
            "output_video_url": video_path  # 로컬에 저장된 아웃풋 비디오 경로
        }
    else:
        raise HTTPException(status_code=500, detail="Failed to process video")
    
# 로컬 서버 실행
import uvicorn
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
    







