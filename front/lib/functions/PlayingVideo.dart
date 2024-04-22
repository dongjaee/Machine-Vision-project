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
