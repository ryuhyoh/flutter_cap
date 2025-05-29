// lib/results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // flutter_animate 패키지 import

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
    final String queryText = data['query_text'] as String? ?? '검색';

    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과'),
        backgroundColor: Colors.transparent,
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
                    final double distance = place['distance'] as double? ?? 0.0;

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

                    return InkWell(
                          onTap: () {
                            print(
                              'Tapped on: $title (ID: ${place['contents_id']})',
                            );
                            // TODO: 상세 페이지로 이동
                          },
                          splashColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                          highlightColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.1),
                          child: Card(
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
                                        if (loadingProgress == null) {
                                          return child;
                                        }
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
                          ),
                        )
                        // 🔥 애니메이션 적용 부분 🔥
                        .animate()
                        .fadeIn(
                          duration: 700.ms,
                        ); // 각 아이템이 index에 따라 순차적으로 delay 후 fadeIn
                  },
                ),
      ),
    );
  }
}
