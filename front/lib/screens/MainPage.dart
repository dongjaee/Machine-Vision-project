import 'dart:html';

import 'package:flutter/material.dart';

import 'package:front/designs/SettingButtons.dart';
import 'package:front/designs/SettingColor.dart';
import 'package:front/functions/PlayingVideo.dart';
import 'package:front/functions/ApiService.dart';

import 'dart:typed_data';
import 'dart:html';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';



class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? videoUrl; // 동영상 URL
  Uint8List? videoBytes; // 동영상 Bytes

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
      ApiService.uploadDetectObjects(detectObjects.first).then((_) {
      });
    }
  }

  // Future<void> pickVideo() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //     withData: true, // 파일의 바이트 데이터를 함께 가져오도록 설정합니다.
  //   );
  //
  //   if (result != null) {
  //     // 바이트 데이터로부터 Blob 객체를 생성합니다.
  //     final blob = html.Blob([result.files.single.bytes!]);
  //     // Blob으로부터 임시 URL을 생성합니다.
  //     final url = html.Url.createObjectUrl(blob);
  //
  //     setState(() {
  //       videoUrl = url; // 임시 URL을 videoUrl에 저장
  //     });
  //
  //     // 선택된 파일의 이름과 생성된 임시 URL을 출력하여 확인합니다.
  //     print('선택된 파일: ${result.files.single.name}, 임시 URL: $videoUrl');
  //   }
  // }
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

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
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
              child: Text(
                '메뉴 헤더',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('안녕'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('메롱'),
            ),
            // 다른 메뉴 아이템들을 계속 추가할 수 있습니다.
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
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Text('Today'),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Text('yesterday'),
                      ),
                      // 추가적인 메뉴 아이템들...
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
                          height: screenHeight * 0.55, // 높이 지정
                          width: screenWidth * 0.55, // 너비 지정
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          //child: videoUrl != null
                              //? PlayingVideo(videoUrl: videoUrl!) // 선택된 동영상 재생
                              //: Center(
                              //    child: Text(
                              //      "동영상 재생", // default message
                              //      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              //    ),
                              //  ),
                        ),
                      ),
                      SizedBox(height:50),
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