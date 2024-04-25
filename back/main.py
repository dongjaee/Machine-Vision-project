from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from fastapi import FastAPI, File, Form, UploadFile, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from typing import List
import shutil
import uuid

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

        # 동기로 Azure Blob Storage에 업로드
        blob_client.upload_blob(file_data, overwrite=True)

        # DB에 추가
        video_entry = Video(videoName=video_name, videoURL=video_url)
#         db.add(video_entry)
#         db.commit()
#         db.refresh(video_entry)

        return {"filename": video.filename, "message": "Video uploaded successfully."}
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


class VideoQuery(BaseModel):
    video_url: str
    query: str
    box_threshold: float = 0.2
    text_threshold: float = 0.2
    show_visualisation: bool = True

@app.post("/detecting_video/")
async def detecting_video(query: VideoQuery):
    api_token = os.getenv("REPLICATE_API_TOKEN")
    
    try:
        output = replicate.run(
            "adirik/grounding-dino:efd10a8ddc57ea28773327e881ce95e20cc1d734c589f7dd01d2036921ed78aa",
            input={
                "image": query.video_url,
                "query": query.query,
                "box_threshold": query.box_threshold,
                "text_threshold": query.text_threshold,
                "show_visualisation": query.show_visualisation
            }
        )
        return output
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


## 아웃풋 예시
# {'detections': [{'bbox': [19, 204, 408, 563], 'confidence': 0.8077122569084167, 'label': 'pink mug'},
#                 {'bbox': [545, 263, 952, 650], 'confidence': 0.7644544839859009, 'label': 'pink mug'}, 
#                 {'bbox': [416, 60, 764, 380], 'confidence': 0.4754282832145691, 'label': 'pink mug'}, 
#                 {'bbox': [909, 161, 1078, 487], 'confidence': 0.43150201439857483, 'label': 'pink mug'}],
#                 'result_image': 'https://replicate.delivery/pbxt/u0xqdnJ0Dx7WNByxUzyg18GL0M7y6AWeclwMPwZ5Ndp0AoWJA/result.png'}
