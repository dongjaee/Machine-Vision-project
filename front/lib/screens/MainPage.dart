import 'package:flutter/material.dart';
import 'package:front/designs/SettingButtons.dart';
import 'package:front/designs/SettingColor.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 이곳에서 상태를 관리합니다. 예를 들어, 채팅 메시지 목록을 저장할 수 있습니다.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
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
              Flexible(
                flex: 2,
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
              Flexible(
                flex: 8,
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

                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          itemCount: 3, // 채팅 메시지의 수
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('메시지 #$index'),
                              subtitle: Text('Yellow filling'),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex:1,
                              child: Container(
                                margin: EdgeInsets.only(left: 40.0,right:10),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.upload_file), // 버튼에 아이콘 추가
                                  label: Text('동영상 업로드'),
                                  onPressed: () {
                                    // 동영상 업로드 버튼 이벤트 처리
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 63), // 버튼 높이 설정
                                    shape: RoundedRectangleBorder( // 모양 설정
                                      borderRadius: BorderRadius.circular(10), // 둥근 모서리의 radius
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 0), // 버튼 내부 여백 제거
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex:4,
                              child: Container(
                                margin: EdgeInsets.only(right: 40.0,left:10),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder( // 경계선 설정
                                      borderRadius: BorderRadius.circular(10), // 둥근 모서리의 radius
                                    ),
                                    labelText: '탐지할 객체를 입력해주세요', // 라벨 텍스트 추가
                                    suffixIcon: Icon(Icons.search), // 검색 아이콘 추가
                                  ),
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