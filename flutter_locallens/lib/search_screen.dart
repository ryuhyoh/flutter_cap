import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'dart:math' as math; // math.max 사용 안 하므로 제거 가능

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final String _heroTag = 'searchBoxHero';

  final double _initialCardHeight = 430.0;
  final double _expandedCardHeight = 700.0; // 확장 시 예시 높이
  final double _initialCardWidth = 390.0;
  final double _expandedCardWidth = 420.0; // 확장 시 예시 너비 (화면 너비에 맞출 수도 있음)

  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _widthAnimation;
  bool _isExpanded = false;

  final double _cardBorderRadius = 35.0;

  final List<String> mapLocations = List.generate(
    8,
    (index) => 'Location $index',
  );
  final double mapListHeight = 120.0;
  final double mapItemWidth = 120.0;
  final double mapImageHeight = 95.0;
  final double mapCaptionSpacing = 4.0;

  final List<String> regionNames = [
    '서울',
    '부산',
    '제주',
    '강릉',
    '경주',
    '전주',
    '여수',
    '속초',
    '인천',
    '대구',
    '광주',
    '대전',
    '수원',
    '고양',
    '용인',
  ];
  // final double gridHeight = 120.0; // GridView shrinkWrap 사용으로 불필요

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: 400.ms, // 애니메이션 지속시간 조정 (예: 400ms)
    );

    _heightAnimation = Tween<double>(
      begin: _initialCardHeight,
      end: _expandedCardHeight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // 부드러운 커브 (예: easeOut)
      ),
    );

    _widthAnimation = Tween<double>(
      begin: _initialCardWidth,
      end: _expandedCardWidth,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // 동일 커브 적용
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    double delta =
        -details.primaryDelta! / (_expandedCardHeight - _initialCardHeight);
    _animationController.value += delta;
    _animationController.value = _animationController.value.clamp(0.0, 1.0);
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! < -500 ||
        (_animationController.value >= 0.5 && details.primaryVelocity! < 500)) {
      _animationController.forward();
      if (mounted) setState(() => _isExpanded = true);
    } else {
      _animationController.reverse();
      if (mounted) setState(() => _isExpanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).colorScheme.surface;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color surfaceContainerHighest =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color outlineVariantColor =
        Theme.of(context).colorScheme.outlineVariant;
    final Color outlineColor =
        Theme.of(context).colorScheme.outline; // TextField focusedBorder 등에 사용
    final Color onSurfaceVariantColor =
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: Hero(
          tag: _heroTag,
          createRectTween: (begin, end) {
            return MaterialRectArcTween(begin: begin, end: end);
          },
          child: Material(
            type: MaterialType.transparency,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: _widthAnimation.value,
                  height: _heightAnimation.value,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(_cardBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_cardBorderRadius),
                    child: child,
                  ),
                );
              },
              child: Material(
                type: MaterialType.transparency,
                child: GestureDetector(
                  onVerticalDragUpdate: _handleVerticalDragUpdate,
                  onVerticalDragEnd: _handleVerticalDragEnd,
                  child: SingleChildScrollView(
                    physics:
                        _isExpanded
                            ? const ClampingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '어디로 떠나시나요?',
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
                                  color: Theme.of(context).colorScheme.outline,
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
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1.5,
                                ), // 포커스 시 primaryColor 사용
                              ),
                              filled: true,
                              fillColor: surfaceContainerHighest, // 내부 채우기 색
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: mapListHeight,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: mapLocations.length,
                              itemBuilder: _buildMapListItem,
                            ),
                          ),
                          Divider(
                            // const 추가
                            color: Colors.grey.shade400,
                            thickness: 0.5,
                            indent: 3,
                            endIndent: 3,
                            height: 30,
                          ),
                          const Text(
                            // const 추가
                            '인기 여행지',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10), // const 추가
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 2.5 / 1,
                                ),
                            itemCount: regionNames.length,
                            itemBuilder: (context, index) {
                              return OutlinedButton(
                                onPressed: () {
                                  print('${regionNames[index]} 버튼 클릭됨');
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ), // const 추가
                                  side: BorderSide(color: outlineVariantColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: Text(
                                  regionNames[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: onSurfaceVariantColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ).animate().fade(begin: 0.0, end: 1.0, duration: 300.ms),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 지도 목록 아이템 빌더 함수
  Widget _buildMapListItem(BuildContext context, int index) {
    final Color onSurfaceVariantColor =
        Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0), // const 추가
      child: SizedBox(
        width: mapItemWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: mapItemWidth,
                height: mapImageHeight,
                color: Colors.grey.shade300, // 실제 이미지로 대체 필요
                // child: Image.network(...),
              ),
            ),
            SizedBox(height: mapCaptionSpacing), // const SizedBox 불가능 (변수 사용)
            Text(
              mapLocations[index],
              style: TextStyle(fontSize: 12, color: onSurfaceVariantColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
