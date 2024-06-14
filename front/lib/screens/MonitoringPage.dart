import 'package:flutter/material.dart';
import 'package:front/designs/SettingColor.dart';
import 'package:front/functions/ApiService.dart';

class MonitoringPage extends StatefulWidget {
  final Map<String, dynamic> result;

  MonitoringPage({required this.result});
  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> uploadedVideos = [];
  late String graphUrl;
  late int totalBoundingBoxes;
  late String videoName;



  @override
  void initState() {
    super.initState();
    graphUrl = widget.result['graph_data'];
    totalBoundingBoxes = widget.result['total_bounding_boxes'];
    videoName = graphUrl.split('/').last.split('_result.png').first;
    print('MonitoringPage initialized with graphUrl: $graphUrl and totalBoundingBoxes: $totalBoundingBoxes');
  }

  void _updateMonitoringData(Map<String, dynamic> data) {
    print('Received data in MonitoringPage: $data');
    setState(() {
      graphUrl = data['graph_data'];
      totalBoundingBoxes = data['total_bounding_boxes'];
    });
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Result Summary',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '< 탐지 영상 이름 : $videoName >',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          height: screenHeight * 0.65, // 높이 조정
                          width: screenWidth * 0.8, // 너비 조정
                          child: graphUrl.isNotEmpty
                              ? Image.network(graphUrl)
                              : Container(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0), // 그래프와 텍스트 사이 여백 줄이기
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'x축 : 시간',
                                style: TextStyle(fontSize: 13),
                              ),
                              SizedBox(width: 60),
                              Text(
                                'Y축 : 탐지된 객체 수',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              '임계값 : 0.5',
                              style: TextStyle(fontSize: 21),
                            ),
                            SizedBox(width: 60),
                            Icon(Icons.people, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              '총 탐지된 객체 수: $totalBoundingBoxes',
                              style: TextStyle(fontSize: 21),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          '다양한 임계값 설정을 통해 객체 상태를 판별하세요!',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
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