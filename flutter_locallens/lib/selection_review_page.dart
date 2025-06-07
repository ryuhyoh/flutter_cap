// lib/selection_review_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_locallens/selection_model.dart';
import 'package:flutter_locallens/summary_loading_page.dart';
import 'package:provider/provider.dart';

class SelectionReviewPage extends StatelessWidget {
  const SelectionReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectionModel = context.watch<SelectionModel>();
    final items = selectionModel.selectedItems.values.toList();

    // [수정] 임시 데이터 대신 SelectionModel에서 실제 데이터를 가져옵니다.
    final DateTimeRange? dateRange = selectionModel.dateRange;
    final int? partySize = selectionModel.partySize;

    // 요약 생성을 위한 정보가 준비되었는지 확인
    final bool isReadyForSummary = dateRange != null && partySize != null;

    return Scaffold(
      appBar: AppBar(title: Text('내 여행 바구니 (${items.length})')),
      body:
          items.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_basket_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text('여행 바구니가 비어있습니다.'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('여행지 담으러 가기'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final place = items[index];
                  final placeId =
                      (place['contents_id'] as int?)?.toString() ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            place['image_path'] != null &&
                                    place['image_path'].isNotEmpty
                                ? NetworkImage(place['image_path'])
                                : null,
                        child:
                            (place['image_path'] == null ||
                                    place['image_path'].isEmpty)
                                ? const Icon(Icons.image_not_supported)
                                : null,
                      ),
                      title: Text(place['title'] ?? '제목 없음'),
                      subtitle: Text(
                        place['chroma_document'] ?? '설명 없음',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          context.read<SelectionModel>().remove(placeId);
                        },
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          items.isNotEmpty
              ? BottomAppBar(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // [추가] 날짜/인원 정보가 없을 경우 안내 메시지 표시
                    if (!isReadyForSummary)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '요약을 위해 날짜와 인원 정보가 필요합니다.\n새로운 검색을 시작해주세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('여행지 더 추가하기'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.library_books_outlined),
                            label: const Text('요약 생성하기'),
                            // [수정] 정보가 없으면 버튼 비활성화
                            onPressed:
                                !isReadyForSummary
                                    ? null
                                    : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => SummaryLoadingPage(
                                                selectedItemIds:
                                                    selectionModel
                                                        .selectedItems
                                                        .keys
                                                        .toList(),
                                                // [수정] 실제 데이터 전달
                                                selectedDateRange: dateRange,
                                                partySize: partySize,
                                              ),
                                        ),
                                      );
                                    },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : null,
    );
  }
}
