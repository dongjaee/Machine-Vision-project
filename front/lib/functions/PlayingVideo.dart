import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:front/functions/ApiService.dart';

class PlayingVideo extends StatefulWidget {
  @override
  _PlayingVideoState createState() => _PlayingVideoState();
}

class _PlayingVideoState extends State<PlayingVideo> {
  VideoPlayerController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ApiService.onOutputVideoUrlChanged = () {
      setState(() {
        initializeVideo();
      });
    };
    ApiService.onVideoUrlChanged = () {
      setState(() {
        initializeVideo();
      });
    };
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    try {
      if (ApiService.outputVideoUrl != null) {
        _controller?.dispose();
        _controller = VideoPlayerController.network(ApiService.outputVideoUrl!);
      } else if (ApiService.uploadedVideoUrl != null) {
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
        : _controller != null && _controller!.value.isInitialized
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