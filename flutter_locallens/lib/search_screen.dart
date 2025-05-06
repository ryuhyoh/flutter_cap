import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  // Hero 태그 정의 (Home 화면과 동일하게)
  final String _heroTag = 'searchBoxHero';

  // 카드 크기 및 모양 정의
  final double _cardHeight = 430.0;
  final double _cardWidth = 390.0;
  final double _cardBorderRadius = 35.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageRouteBuilder에서 페이드 효과를 주므로 배경색은 최종 상태로 설정
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        forceMaterialTransparency: true,
      ),
      body: Center(
        // Hero 위젯 다시 사용
        child: Hero(
          tag: _heroTag, // 동일 태그
          createRectTween: (begin, end) {
            // 부드러운 호 이동
            return MaterialRectArcTween(begin: begin, end: end);
          },
          // 애니메이션될 최종 컨테이너 모양
          child: Material(
            // Material로 감싸기
            type: MaterialType.transparency,
            child: Container(
              width: _cardWidth,
              height: _cardHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(_cardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10, // 그림자 약간 조절
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // Material 위젯으로 내부 컨텐츠 클리핑 및 효과 보장
              child: Material(
                type: MaterialType.transparency,
                // ==============================================
                // 내부 콘텐츠에 애니메이션 적용 (flutter_animate)
                // ==============================================
                child:
                    Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '어디로 떠나시나요?', // 텍스트 구분용
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: '여행지 검색',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(
                                      context,
                                    ).iconTheme.color?.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      width: 1.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).colorScheme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        )
                        // .animate() 확장 메서드 적용
                        .animate()
                        // PageRouteBuilder의 transitionDuration(500ms)보다 짧은 delay
                        .fadeIn(),
                /*.slideY(
                      begin: 0.2,
                      duration: 300.ms,
                      curve: Curves.easeOutCubic,
                    ),*/
                // ==============================================
              ),
            ),
          ),
        ),
      ),
    );
  }
}
