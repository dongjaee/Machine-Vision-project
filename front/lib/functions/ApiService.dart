import 'dart:io';
import 'dart:html';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';

class ApiService {
  static const String addressIP = 'localhost:8000';

  static String? uploadedVideoUrl;
  static String? outputVideoUrl;
  static String? uploadedVideoName;

  static VoidCallback? onVideoUrlChanged;
  static VoidCallback? onOutputVideoUrlChanged;
  static VoidCallback? onVideoNameChanged;

  static Function(Map<String, dynamic>)? onMonitoringDataChanged;

  static void updateVideoUrl(String url) {
    uploadedVideoUrl = url;
    onVideoUrlChanged?.call();

    //여기부분 검토 필요
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
        'video',
        fileBytes,
        filename: fileName,
      ));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      print('Upload successful');
      var data = jsonDecode(responseData.body);

      uploadedVideoUrl = data['videourl'];
      print(uploadedVideoUrl);
      onVideoUrlChanged?.call();
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
