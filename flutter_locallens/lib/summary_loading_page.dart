// lib/summary_loading_page.dart (새 파일)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'summary_page.dart'; // 최종 요약 결과 페이지

class SummaryLoadingPage extends StatefulWidget {
  final List<String> selectedItemIds;
  final DateTimeRange selectedDateRange;
  final int partySize;

  const SummaryLoadingPage({
    super.key,
    required this.selectedItemIds,
    required this.selectedDateRange,
    required this.partySize,
  });

  @override
  State<SummaryLoadingPage> createState() => _SummaryLoadingPageState();
}

class _SummaryLoadingPageState extends State<SummaryLoadingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSummaryAndNavigate();
    });
  }

  Future<void> _fetchSummaryAndNavigate() async {
    // 요약 요청을 위한 백엔드 API 엔드포인트 (백엔드에 맞게 수정 필요)
    const String apiUrl = "http://10.0.2.2:8000/summary/"; // 예시 URL

    final DateFormat formatter = DateFormat('yyyy.MM.dd');
    final String travelDates =
        '${formatter.format(widget.selectedDateRange.start)} ~ ${formatter.format(widget.selectedDateRange.end)}';

    final List<int> contentsIds =
        widget.selectedItemIds.map((id) => int.tryParse(id) ?? 0).toList();

    // API 요청 본문 구성
    final Map<String, dynamic> requestBody = {
      'num_travelers': widget.partySize,
      'travel_dates': travelDates,
      'contents_ids': contentsIds,
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      // (선택 사항) 최소 로딩 시간 보장
      await Future.delayed(const Duration(seconds: 2));

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(
          utf8.decode(response.bodyBytes),
        ); // 한글 깨짐 방지

        if (responseData['error'] != null && responseData['error'].isNotEmpty) {
          Navigator.pop(context, "Error: ${responseData['error']}");
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryPage(summaryData: responseData),
          ),
        );
      } else {
        Navigator.pop(context, "Error: 요약 요청 실패 (${response.statusCode})");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context, "Error: 요약 요청 중 오류 발생 ($e)");
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
              '여행 계획을 요약 중입니다...',
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
