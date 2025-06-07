// lib/summary_page.dart (공유 기능 추가 버전)
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class SummaryPage extends StatefulWidget {
  final Map<String, dynamic> summaryData;

  const SummaryPage({super.key, required this.summaryData});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  // 스크린샷을 찍기 위한 컨트롤러
  final _screenshotController = ScreenshotController();
  // 이미지 공유 처리 중 로딩 상태를 표시하기 위한 변수
  bool _isSharing = false;

  // 1. 공유 옵션을 보여주는 함수 (Modal Bottom Sheet 사용)
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('텍스트로 공유'),
                onTap: () {
                  Navigator.of(context).pop(); // 바텀 시트 닫기
                  _shareAsText();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('이미지로 공유'),
                onTap: () {
                  Navigator.of(context).pop(); // 바텀 시트 닫기
                  _shareAsImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. 텍스트를 공유하는 함수
  void _shareAsText() {
    final String summaryText =
        widget.summaryData['summary_text'] ?? '요약 정보가 없습니다.';
    // share_plus 패키지를 사용하여 텍스트 공유
    Share.share(summaryText, subject: 'AI 여행 계획 요약');
  }

  // 3. 위젯을 이미지로 캡처하여 공유하는 함수
  void _shareAsImage() async {
    setState(() {
      _isSharing = true; // 로딩 시작
    });

    try {
      // 스크린샷 컨트롤러를 사용하여 위젯을 이미지(Uint8List)로 캡처
      final Uint8List? image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10), // 렌더링을 위한 약간의 딜레이
      );

      if (image == null) return;

      // path_provider를 사용하여 임시 디렉토리 경로 획득
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/summary.png').create();
      // 캡처한 이미지 데이터를 파일로 저장
      await imagePath.writeAsBytes(image);

      // share_plus 패키지를 사용하여 파일(XFile) 공유
      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'AI가 생성한 여행 계획 요약입니다!');
    } finally {
      setState(() {
        _isSharing = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String summaryText =
        widget.summaryData['summary_text'] ?? '요약 정보가 없습니다.';

    // Stack을 사용하여 로딩 오버레이 구현
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('AI 여행 계획 요약'),
            // 4. AppBar에 공유 버튼 추가
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _showShareOptions(context),
              ),
            ],
          ),
          // 5. Screenshot 위젯으로 공유할 영역을 감싸기
          body: Screenshot(
            controller: _screenshotController,
            // 캡처된 이미지의 배경색을 흰색으로 지정
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Markdown(
                data: summaryText,
                padding: const EdgeInsets.all(16.0),
                styleSheet: MarkdownStyleSheet(
                  h2: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                  ),
                  p: const TextStyle(fontSize: 16, height: 1.6),
                  strong: const TextStyle(fontWeight: FontWeight.w800),
                  listBullet: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ),
        ),

        // 6. 로딩 중일 때 화면 전체에 로딩 인디케이터 표시
        if (_isSharing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
