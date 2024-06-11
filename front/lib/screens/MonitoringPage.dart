import 'package:flutter/material.dart';
import 'package:front/designs/SettingColor.dart';

class MonitoringPage extends StatefulWidget {
  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> uploadedVideos = [];

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
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('객체명은 영어로 입력해주세요'),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('실행 버튼을 눌러주세요'),
            ),
            SizedBox(height: 150),
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
              // 왼쪽 메뉴
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
                      // 추가적인 메뉴 아이템들...
                    ],
                  ),
                ),
              ),
              // 메인 컨텐츠 영역
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
                      SizedBox(height: 50),
                      Center(
                        child: Container(
                          height: screenHeight * 0.55, // 높이
                          width: screenWidth * 0.55, // 너비
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(  // Center 위젯으로 감싸기
                        child: Container(
                          width: screenWidth * 0.55,
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '', // 빈 문자열
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}