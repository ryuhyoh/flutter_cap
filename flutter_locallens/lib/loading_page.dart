// lib/loading_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 통신
import 'dart:convert'; // JSON 인코딩/디코딩
import 'results_page.dart'; // 결과 페이지 import
import 'package:flutter_animate/flutter_animate.dart';

/*void main() {
  runApp(MaterialApp(home: LoadingPage(destination: '제주', vibe: '아아')));
}*/

class LoadingPage extends StatefulWidget {
  final String destination;
  final String vibe;
  final DateTimeRange? selectedDateRange;
  final int? partySize;

  const LoadingPage({
    super.key,
    required this.destination,
    required this.vibe,
    this.selectedDateRange,
    this.partySize,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 API 호출 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataAndNavigate();
    });
  }

  Future<void> _fetchDataAndNavigate() async {
    // 실제 백엔드 API 엔드포인트로 변경 필요
    const String apiUrl = "http://10.0.2.2:8000/search/";
    final Map<String, String> requestBody = {
      'destination': widget.destination,
      'query_text': widget.vibe,
    };
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      // (선택 사항) 최소 로딩 시간을 보장하여 애니메이션이 보이도록 함
      await Future.delayed(const Duration(seconds: 2));

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (!mounted) return; // 위젯이 화면에서 사라졌다면 이후 코드 실행 방지

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // 성공: 결과 페이지로 이동 (현재 로딩 페이지는 스택에서 제거)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ResultsPage(
                      data: responseData,
                      selectedDateRange: widget.selectedDateRange,
                      partySize: widget.partySize,
                    ).animate().fadeIn(),
          ),
        );
      } else {
        // 실패: 이전 페이지로 돌아가면서 오류 메시지 전달
        Navigator.pop(context, "Error: 서버 요청 실패 (${response.statusCode})");
        print('이유는요${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      // 예외 발생: 이전 페이지로 돌아가면서 오류 메시지 전달
      Navigator.pop(context, "Error: 통신 중 오류 발생 ($e)");
      print('이유는바로$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              '데이터를 검색 중입니다...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
