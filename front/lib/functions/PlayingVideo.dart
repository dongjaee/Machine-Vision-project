// import 'dart:ui' as ui;
// import 'dart:html' as html;
//
// import 'package:flutter/material.dart';
//
// class PlayingVideo extends StatefulWidget {
//   final String videoUrl;
//
//   PlayingVideo({Key? key, required this.videoUrl}) : super(key: key);
//
//   @override
//   _PlayingVideoState createState() => _PlayingVideoState();
// }
//
// class _PlayingVideoState extends State<PlayingVideo> {
//   late String viewType;
//
//   @override
//   void initState() {
//     super.initState();
//     initViewType();
//   }
//
//   @override
//   void didUpdateWidget(PlayingVideo oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.videoUrl != widget.videoUrl) {
//       // videoUrl이 변경될 경우, 새로운 viewType을 생성하여 플랫폼 뷰를 재등록합니다.
//       initViewType();
//     }
//   }
//
//   void initViewType() {
//     // viewType을 현재 시간을 기반으로 재정의하여 고유하게 만듭니다.
//     viewType = 'video-view-type-${DateTime.now().millisecondsSinceEpoch}';
//     // 플랫폼 뷰에서 사용할 HTML <video> 태그를 등록합니다.
//     ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
//       final videoElement = html.VideoElement()
//         ..src = widget.videoUrl
//         ..autoplay = true
//         ..controls = true
//         ..style.width = '100%'
//         ..style.height = '100%';
//       return videoElement;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return HtmlElementView(viewType: viewType);
//   }
// }
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import 'package:front/functions/ApiService.dart';

class PlayingVideo extends StatefulWidget {
  final bool useOutputUrl;

  PlayingVideo({this.useOutputUrl = false});

  @override
  _PlayingVideoState createState() => _PlayingVideoState();
}

class _PlayingVideoState extends State<PlayingVideo> {
  VideoPlayerController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ApiService.onVideoUrlChanged = () {
      setState(() {
        initializeVideo(useUploadedUrl: true);
      });
    };
    ApiService.onOutputVideoUrlChanged = () {
      setState(() {
        initializeVideo(useUploadedUrl: false);
      });
    };
    initializeVideo(useUploadedUrl: true);
  }

  Future<void> initializeVideo({required bool useUploadedUrl}) async {
    try {
      if (!useUploadedUrl && ApiService.outputVideoUrl != null) {
        _controller?.dispose();
        _controller = VideoPlayerController.network(ApiService.outputVideoUrl!);
      } else if (useUploadedUrl && ApiService.uploadedVideoUrl != null) {
        _controller?.dispose();
        _controller = VideoPlayerController.network(ApiService.uploadedVideoUrl!);
      }

      if (_controller != null) {
        await _controller!.initialize();
        setState(() {
          _isLoading = false;
        });
        _controller!.play();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
      child: CircularProgressIndicator(),
    )
        : ApiService.uploadedVideoUrl != null &&
        _controller != null &&
        _controller!.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(_controller!),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
            ),
          ),
        ],
      ),
    )
        : Center(
      child: Text(
        "동영상 업로드를 기다리는 중...",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}