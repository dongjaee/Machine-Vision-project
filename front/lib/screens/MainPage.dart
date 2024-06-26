import 'package:flutter/material.dart';

import 'package:front/designs/SettingButtons.dart';
import 'package:front/designs/SettingColor.dart';
import 'package:front/functions/PlayingVideo.dart';
import 'package:front/functions/ApiService.dart';
import 'MonitoringPage.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;



class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? videoUrl; // 동영상 URL
  Uint8List? videoBytes; // 동영상 Bytes
  VideoPlayerController? _controller;
  bool useOutputUrl = false;
  List<Map<String, String>> uploadedVideos = [];
  Map<String, dynamic>? result;

  final List<String> detectObjects = []; // 탐지할 객체 저장
  final TextEditingController textEditingController = TextEditingController();

  void addObject(String object) {
    if (object.isNotEmpty) {
      setState(() {
        detectObjects.clear(); // 리스트 초기화
        detectObjects.add(object);
        textEditingController.clear();  // 텍스트 필드 초기화
      });
      debugPrint('List updated: $detectObjects');
      ApiService.uploadDetectObjects(detectObjects.first).then((_) {});
    }
  }

  Future<void> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true, // 파일의 바이트 데이터를 가져오도록 설정
    );

    if (result != null && result.files.single.bytes != null) {
      Uint8List fileBytes = result.files.single.bytes!;
      String fileName = result.files.single.name;

      await ApiService().uploadVideo(fileBytes, fileName);
      print('선택된 파일: $fileName');
    }
  }

  //새롭게 추가된 부분 6.12
  Future<void> processAndPlayVideo(String objectName) async {
    try {
      var resultData = await ApiService.processVideo(objectName);
      print('Result from API: $resultData');

      if (resultData['output_video_url'] == null) {
        throw Exception('output_video_url is null');
      }

      String outputVideoUrl = resultData['output_video_url'];
      ApiService.updateOutputVideoUrl(outputVideoUrl); // 서버 URL 업데이트

      // 실행 버튼 클릭 시 uploadedVideos 리스트에 동영상 정보 추가
      String videoName = outputVideoUrl.split('/').last.split('_output_video.mp4').first; // 수정된 부분
      String uploadTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      setState(() {
        uploadedVideos.add({
          'name': videoName,
          'time': uploadTime,
        });
        result = resultData;
      });
    } catch (e) {
      print('Failed to process video: $e');
    }
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _goToMonitoringPage() {
    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MonitoringPage(result : result!)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSize = screenWidth < 970 ? 12 : 16;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        // 사이드바 메뉴 구현
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat-Monitoring_v1 Guide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '다양한 원하는 모든 것을 탐지하세요!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('로컬에서 동영상을 선택해주세요'),
            ),
            SizedBox(height:20),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('객체명은 영어로 입력해주세요'),
            ),
            SizedBox(height:20),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('실행 버튼을 눌러주세요'),
            ),
            SizedBox(height:150),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('탐지 언어: 영어'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              //왼쪽메뉴
              Flexible(
                flex: 1,
                child: Container(
                  color: colorLeftBg,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Text('Today'),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: uploadedVideos.length,
                          itemBuilder: (context, index) {
                            final video = uploadedVideos[index];
                            return ListTile(
                              title: Text(video['name']!),
                              subtitle: Text(video['time']!),
                            );
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.history),
                        title: Text('History'),
                      ),
                    ],
                  ),
                ),
              ),
              //메인 컨텐츠 영역
              Flexible(
                flex: 4,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Chat-Monitoring',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      SizedBox(height:50),


                      Center(
                        child: Container(
                          height: screenHeight * 0.55, // 높이
                          width: screenWidth * 0.55, // 너비
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: PlayingVideo(),
                        ),
                      ),
                      SizedBox(height:20),
                      Center(  // Center 위젯으로 감싸기
                        child: Container(
                          width: screenWidth * 0.55,
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      SizedBox(height:20),
                      Row(
                        children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.only(left: (screenWidth * 0.125) ,right:16), // right 고민
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('동영상 업로드', style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.upload_file, color: Colors.blue, size: 24), // 아이콘 사이즈 조정
                                    label: SizedBox.shrink(), // 레이블 대신에 빈 SizedBox 사용
                                    onPressed: pickVideo,
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                      foregroundColor: MaterialStateProperty.all(Colors.blue),
                                      elevation: MaterialStateProperty.all(0),
                                      padding: MaterialStateProperty.all(EdgeInsets.zero), // 버튼 내부 여백을 제거
                                      minimumSize: MaterialStateProperty.all(Size(200, 56)), // 버튼의 높이와 너비를 조정
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(color: Color(0xFF8B8B8B)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 7,
                            child: Container(
                              margin: EdgeInsets.only(left:16,right:(screenWidth * 0.125)), //left 고민
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('탐지할 객체를 입력해주세요', style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    TextField(
                                      controller: textEditingController,
                                      decoration: InputDecoration(
                                      isDense: true, // 필드의 높이를 줄임
                                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16), // 좌우 패딩을 추가
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Color(0xFF8B8B8B)),
                                      ),
                                      hintText: '',
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.add_box_outlined, color: Colors.blue, size: 24), // 아이콘 크기를 조정
                                        onPressed: () {
                                          addObject(textEditingController.text);
                                        },
                                        constraints: BoxConstraints(), // IconButton의 크기를 제한하지 않음
                                      ),
                                    ),
                                    onSubmitted: addObject,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                if (ApiService.uploadedVideoUrl != null) {
                                  processAndPlayVideo(detectObjects.isNotEmpty ? detectObjects.first : "");
                                }
                              },
                              child: Text('실행', style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _goToMonitoringPage,
                              child: Text('결과', style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 24.0, right: 8.0),
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: _openEndDrawer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}