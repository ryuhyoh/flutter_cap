// lib/results_page.dart (태그/감정 UI 복원 최종 버전)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_locallens/selection_model.dart';
import 'package:flutter_locallens/trip_basket_icon.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String destination;
  final DateTimeRange? selectedDateRange;
  final int? partySize;

  const ResultsPage({
    super.key,
    required this.data,
    required this.destination,
    this.selectedDateRange,
    this.partySize,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isLoading = false;

  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final String? newQuery = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('여행지 추가 검색'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '다른 검색어를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '검색어를 입력해주세요.';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop(searchController.text);
                  }
                },
                child: const Text('검색'),
              ),
            ],
          ),
    );

    if (newQuery != null && newQuery.isNotEmpty) {
      _searchAndReplace(newQuery);
    }
  }

  Future<void> _searchAndReplace(String query) async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl = "http://10.0.2.2:8000/search/";
    final Map<String, String> requestBody = {
      'destination': widget.destination,
      'query_text': query,
    };
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ResultsPage(
                  data: responseData,
                  destination: widget.destination,
                  selectedDateRange: widget.selectedDateRange,
                  partySize: widget.partySize,
                ),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버 요청 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("통신 중 오류 발생: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionModel = context.watch<SelectionModel>();
    final List<dynamic> results =
        widget.data['results'] as List<dynamic>? ?? [];

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('검색 결과'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: const [TripBasketIcon(), SizedBox(width: 8)],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child:
                results.isEmpty
                    ? const Center(child: Text('검색 결과가 없습니다.'))
                    : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> place =
                            results[index] as Map<String, dynamic>;
                        final String placeId =
                            (place['contents_id'] as int?)?.toString() ?? '';
                        final bool isSelected = selectionModel.contains(
                          placeId,
                        );

                        final String title = place['title'] ?? '제목 없음';
                        final String description =
                            place['chroma_document'] as String? ?? '설명 없음';
                        final String? imageUrl = place['image_path'] as String?;

                        // *** 누락되었던 데이터 파싱 로직 복원 ***
                        final String placeContextString =
                            place['place_context'] as String? ?? '';
                        final List<String> contextChipsData =
                            placeContextString
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList();

                        final List<dynamic>? rawEmotions =
                            place['top_emotions'] as List<dynamic>?;
                        final List<String> emotionChipsData =
                            (rawEmotions ?? [])
                                .map((emotion) => emotion.toString().trim())
                                .where((s) => s.isNotEmpty)
                                .toList();

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl != null && imageUrl.isNotEmpty)
                                Image.network(
                                  imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                ),

                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      description,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // *** 누락되었던 UI 위젯 복원 ***
                                    if (contextChipsData.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.tag_rounded,
                                            size: 16,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '관련 태그:',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6.0,
                                        runSpacing: 4.0,
                                        children:
                                            contextChipsData
                                                .map(
                                                  (tag) => Chip(
                                                    label: Text(
                                                      tag,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onSecondaryContainer,
                                                      ),
                                                    ),
                                                    backgroundColor: Theme.of(
                                                          context,
                                                        )
                                                        .colorScheme
                                                        .secondaryContainer
                                                        .withOpacity(0.8),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8.0,
                                                          vertical: 2.0,
                                                        ),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    side: BorderSide.none,
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    if (emotionChipsData.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .sentiment_satisfied_alt_rounded,
                                            size: 16,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '주요 감정:',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6.0,
                                        runSpacing: 4.0,
                                        children:
                                            emotionChipsData
                                                .map(
                                                  (emotion) => Chip(
                                                    label: Text(
                                                      emotion,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onTertiaryContainer,
                                                      ),
                                                    ),
                                                    backgroundColor: Theme.of(
                                                          context,
                                                        )
                                                        .colorScheme
                                                        .tertiaryContainer
                                                        .withOpacity(0.8),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8.0,
                                                          vertical: 2.0,
                                                        ),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    side: BorderSide.none,
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      final model =
                                          context.read<SelectionModel>();
                                      if (isSelected) {
                                        model.remove(placeId);
                                      } else {
                                        model.add(place);
                                      }
                                    },
                                    icon: Icon(
                                      isSelected
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.add_shopping_cart_rounded,
                                      size: 18,
                                    ),
                                    label: Text(isSelected ? '추가됨' : '담기'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          isSelected
                                              ? Colors.teal
                                              : Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms);
                      },
                    ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showSearchDialog,
            label: const Text('여행지 추가 검색'),
            icon: const Icon(Icons.search),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '추가 검색 중...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
