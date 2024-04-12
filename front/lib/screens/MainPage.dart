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

                      Container(
                        height:600,
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
                        padding: const EdgeInsets.only(top:16.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: EdgeInsets.only(left: 200.0, right: 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('동영상 업로드', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.upload_file, color: Colors.blue, size: 24), // 아이콘 사이즈 조정
                                      label: SizedBox.shrink(), // 레이블 대신에 빈 SizedBox 사용
                                      onPressed: () {
                                        // 동영상 업로드 버튼 이벤트 처리
                                      },
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
                            Expanded(
                              flex: 7,
                              child: Container(
                                margin: EdgeInsets.only(right: 200.0, left: 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('탐지할 객체를 입력해주세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    TextField(
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
                                            //TODO: sendMessage 구현
                                          },
                                          constraints: BoxConstraints(), // IconButton의 크기를 제한하지 않음
                                        ),
                                      ),
                                    ),
                                  ],
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