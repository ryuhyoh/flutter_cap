// lib/results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_locallens/summary_loading_page.dart';
// import 'package:flutter_locallens/summary_page.dart'; // 이 파일에서 직접 사용하지 않으므로 주석 처리 가능

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final DateTimeRange? selectedDateRange;
  final int? partySize;

  const ResultsPage({
    super.key,
    required this.data,
    this.selectedDateRange,
    this.partySize,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  // 선택된 여행지의 contents_id를 저장할 Set
  final Set<String> _selectedItemIds = {};

  @override
  Widget build(BuildContext context) {
    // widget.data를 통해 접근
    final List<dynamic> results =
        widget.data['results'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child:
            results.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '검색 결과가 없습니다.',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '다른 검색어를 시도해 보세요.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> place =
                        results[index] as Map<String, dynamic>;

                    final String title = place['title'] as String? ?? '제목 없음';
                    final String description =
                        place['chroma_document'] as String? ?? '설명 없음';
                    final String? imageUrl = place['image_path'] as String?;
                    final String placeId =
                        (place['contents_id'] as int?)?.toString() ?? '';

                    final bool isSelected = _selectedItemIds.contains(placeId);

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

                    return GestureDetector(
                      onTap: () {
                        if (placeId.isNotEmpty) {
                          setState(() {
                            if (isSelected) {
                              _selectedItemIds.remove(placeId);
                            } else {
                              _selectedItemIds.add(placeId);
                            }
                          });
                          print(
                            'Selected: $title (ID: $placeId), Current selection: $_selectedItemIds',
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side:
                              isSelected
                                  ? BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                  : BorderSide.none,
                        ),
                        clipBehavior: Clip.antiAlias,
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.3)
                                : null,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl != null && imageUrl.isNotEmpty)
                                  Hero(
                                    tag: 'place_image_${place['contents_id']}',
                                    child: Image.network(
                                      imageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 200,
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image_outlined,
                                                    color: Colors.grey[400],
                                                    size: 50,
                                                  ),
                                                ),
                                              ),
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                          height: 200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                              strokeWidth: 2.0,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey[400],
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
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
                                        const SizedBox(height: 10),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (placeId.isNotEmpty)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.grey.withOpacity(0.7),
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 700.ms);
                  },
                ),
      ),
      bottomNavigationBar:
          _selectedItemIds.isNotEmpty
              ? BottomAppBar(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedItemIds.length}개 선택됨',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.library_books_outlined),
                        label: const Text('요약 보기'),
                        onPressed: () async {
                          if (widget.selectedDateRange == null ||
                              widget.partySize == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('날짜 또는 인원 정보가 없습니다.'),
                              ),
                            );
                            return;
                          }

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SummaryLoadingPage(
                                    selectedItemIds: _selectedItemIds.toList(),
                                    selectedDateRange:
                                        widget.selectedDateRange!,
                                    partySize: widget.partySize!,
                                  ),
                            ),
                          );

                          if (result is String && result.startsWith("Error")) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}
