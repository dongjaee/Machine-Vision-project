import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ApiService {
  static const String addressIP = 'localhost:8000';

  static String? uploadedVideoUrl;
  static String? outputVideoUrl;
  static String? uploadedVideoName;
  static Map<String, String> videoTextMap = {
    'https://osovideo.blob.core.windows.net/oso-video/conveyorprocess_output.mp4': '바운딩 박스 개수 white object: 89, yellow object: 105',
    'https://osovideo.blob.core.windows.net/oso-video/forest_output.mp4': '바운딩 박스 개수 wild boar: 14',
    'https://osovideo.blob.core.windows.net/oso-video/mot_output.mp4': '바운딩 박스 개수 people: 68',
    'https://osovideo.blob.core.windows.net/oso-video/lego_output.mp4': '바운딩 박스 개수 red ball: 4',

    // 필요한 URL과 텍스트를 추가로 매핑해줍니다.
  };


  static VoidCallback? onVideoUrlChanged;
  static VoidCallback? onOutputVideoUrlChanged;
  static VoidCallback? onVideoNameChanged;


  static void updateVideoUrl(String url) {
    uploadedVideoUrl = url;
    onVideoUrlChanged?.call();

    outputVideoUrl = url.replaceFirst('.mp4', '_output.mp4');
    onOutputVideoUrlChanged?.call();
  }

  static void updateVideoName(String name) {
    uploadedVideoName = name;
    onVideoNameChanged?.call();
  }

  Future<void> uploadVideo(Uint8List fileBytes, String fileName) async {
    var uri = Uri.parse('http://$addressIP/upload_video/');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'video', // 서버에서 기대하는 필드 이름
        fileBytes,
        filename: fileName,
      ));

    // 요청 전송
    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      print('Upload successful');
      var data = jsonDecode(responseData.body);

      uploadedVideoUrl = data['videourl'];
      print(uploadedVideoUrl);
      onVideoUrlChanged?.call();
      //return data['videourl'];
    } else {
      print('Upload failed');
    }
  }

  static Future<void> uploadDetectObjects(String object) async {
    var uri = Uri.parse('http://$addressIP/upload_detect_objects/');

    var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'object': object}
    );

    if (response.statusCode == 200) {
      print('Object upload successful');
    } else {
      print('Object upload failed');
    }
  }

  static Future<Map<String, dynamic>> processVideo(String objectName) async {
    var uri = Uri.parse('http://$addressIP/process_video');
    print('Sending request to $uri with object_name: $objectName');

    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'object_name': objectName}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return {
        "total_bounding_boxes": data["total_bounding_boxes"],
        "graph_data": data["graph_data"],
        "output_video_url": data["output_video_url"],
      };
    } else {
      throw Exception('Failed to process video');
    }
  }

  static void updateOutputVideoUrl(String absolutePath) {
    outputVideoUrl = absolutePath;
    onOutputVideoUrlChanged?.call();
  }
}
