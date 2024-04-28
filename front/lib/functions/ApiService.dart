import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ApiService {
  static const String addressIP = 'localhost:8000';
  //static List<String> uploadedVideoUrls = [];
  static String? uploadedVideoUrl;
  static String? outputVideoUrl;
  //static Function? onVideoUrlChanged;

  static VoidCallback? onVideoUrlChanged;
  static VoidCallback? onOutputVideoUrlChanged;

  static void updateVideoUrl(String url) {
    uploadedVideoUrl = url;
    onVideoUrlChanged?.call();

    outputVideoUrl = url.replaceFirst('.mp4', '_converted.mp4');
    onOutputVideoUrlChanged?.call();
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
      //uploadedVideoUrls.add(data['videourl']);
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
}