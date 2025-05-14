import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_locallens/screens/sub_screen.dart';
import '../card/card_shell.dart'; // 사용자 정의 위젯
import 'dart:ui' as ui;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final String _heroTag = 'searchBoxHero';
  final String _subHeroTag = 'subCardHeroTag';

  // 초기 카드 크기 (축소 상태)
  final double _initialCardHeight =
      440.0; // 사용자가 아래로 확장되는 것을 더 잘 느끼도록 초기 높이를 줄여볼 수 있습니다.
  final double _initialCardWidth = 390.0;

  // 확장 시 카드 크기 및 위치 관련 변수 (didChangeDependencies에서 계산됨)
  double _currentExpandedCardHeight = 850.0; // 화면에 따라 계산될, 아래로 확장되는 최대 높이
  final double _expandedCardWidth = 430.0; // 확장 시 너비
  final double _cardBorderRadius = 35.0;
  late double _cardFixedTopPosition; // 카드의 고정될 상단 Y 위치

  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _widthAnimation;
  bool _isExpanded = false;
  bool _layoutDataInitialized = false;
  bool _isSubCardVisible = false;

  // --- 지도목록 및 지역 이름 데이터 (기존과 동일) ---
  final double mapListHeight = 120.0;
  final double mapItemWidth = 120.0;
  final double mapImageHeight = 95.0;
  final double mapCaptionSpacing = 4.0;
  final List<String> mapLocations = List.generate(
    8,
    (index) => 'Location $index',
  );
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
  // --- 데이터 끝 ---

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: 400.ms);
    _rebuildAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const Duration heroTransitionDurationsFromHome = Duration(
        microseconds: 450,
      );
      const Duration additionalDelay = Duration(microseconds: 100);

      Future.delayed(heroTransitionDurationsFromHome + additionalDelay, () {
        if (mounted) {
          setState(() {
            _isSubCardVisible = true;
          });
        }
      });
    });
  }

  void _rebuildAnimations() {
    _heightAnimation = Tween<double>(
      begin: _initialCardHeight,
      end: _currentExpandedCardHeight,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _widthAnimation = Tween<double>(
      begin: _initialCardWidth,
      end: _expandedCardWidth,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_layoutDataInitialized) {
      final screenHeight = MediaQuery.of(context).size.height;
      final appBar = AppBar(); // AppBar 높이 정보 가져오기
      final appBarHeight = appBar.preferredSize.height;
      final statusBarHeight = MediaQuery.of(context).padding.top;

      const topMargin = 10.0; // AppBar 아래 카드 상단까지의 여백
      const bottomMargin = 20.0; // 카드 하단과 화면 바닥 사이의 여백

      // 1. 카드의 상단 Y 위치 고정
      _cardFixedTopPosition = appBarHeight + 15.0;

      // 2. 카드가 아래로 확장될 수 있는 최대 높이 계산
      double calculatedMaxHeight =
          screenHeight - _cardFixedTopPosition - bottomMargin;

      if (calculatedMaxHeight < _initialCardHeight) {
        calculatedMaxHeight = _initialCardHeight + 50.0; // 최소 높이 보장
      }

      // 3. 계산된 값으로 상태 업데이트 및 애니메이션 재설정
      // setState를 호출하여 _layoutDataInitialized가 true로 변경된 후 위젯 트리가 다시 빌드되도록 함
      setState(() {
        _currentExpandedCardHeight = calculatedMaxHeight;
        _rebuildAnimations();
        _layoutDataInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    double dragRange = _currentExpandedCardHeight - _initialCardHeight;
    if (dragRange.abs() < 1.0) dragRange = 1.0; // 0으로 나누기 방지

    _animationController.value += -details.primaryDelta! / dragRange;
    _animationController.value = _animationController.value.clamp(0.0, 1.0);
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // 기존 로직과 동일
    if (details.primaryVelocity! < -500 ||
        (_animationController.value >= 0.5 && details.primaryVelocity! < 500)) {
      _animationController.forward();
      if (mounted) setState(() => _isExpanded = true);
    } else {
      _animationController.reverse();
      if (mounted) setState(() => _isExpanded = false);
    }
  }

  void _onSubCardTap() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: 450.ms, // 애니메이션 시간 조정
        reverseTransitionDuration: 400.ms,
        opaque: false, // 배경을 투명하게 하여 Hero 애니메이션이 더 잘 보이도록 설정
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const SubScreen(subHeroTag: 'subCardHeroTag'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
      body: Stack(
        children: [
          // 더미 카드 (화면 하단에 위치)
          if (_isSubCardVisible)
            Positioned(
              bottom: 230.0,
              left: 20.0,
              right: 20.0,
              child: Hero(
                tag: _subHeroTag,
                createRectTween: (begin, end) {
                  return MaterialRectArcTween(begin: begin, end: end);
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: GestureDetector(
                    onTap: _onSubCardTap,
                    child: CardShell(
                          currentWidth: 370.0,
                          currentHeight: 80.0,
                          borderRadius: 25.0,
                          contentChild: const Center(child: Text('dummy')),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 00.ms, curve: Curves.easeIn)
                        .slideY(
                          begin: -1.0,
                          end: 0.0,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ),
              ),
            ),

          // 메인 검색 카드 - Positioned 위젯으로 상단 고정
          if (_layoutDataInitialized) // 레이아웃 값 계산 완료 후 빌드
            AnimatedBuilder(
              animation: _widthAnimation, // 너비 애니메이션에 따라 left 오프셋 조정
              builder: (context, heroChild) {
                final currentCardWidth = _widthAnimation.value;
                final cardLeftOffset = (screenWidth - currentCardWidth) / 2;
                return Positioned(
                  top: _cardFixedTopPosition, // 고정된 상단 위치
                  left: cardLeftOffset, // 수평 중앙 정렬
                  // height는 AnimatedCardShell 내부에서 _heightAnimation.value로 결정됨
                  child: heroChild!,
                );
              },
              child: Hero(
                tag: _heroTag,
                createRectTween:
                    (begin, end) =>
                        MaterialRectArcTween(begin: begin, end: end),
                child: Material(
                  type: MaterialType.transparency,
                  child: AnimatedBuilder(
                    animation: _animationController, // 높이/너비 애니메이션 구동
                    builder: (context, cardContent) {
                      return CardShell(
                        currentWidth: _widthAnimation.value,
                        currentHeight:
                            _heightAnimation.value, // 아래로만 확장되는 높이 적용
                        borderRadius: _cardBorderRadius,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        contentChild: cardContent!,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 7,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      );
                    },
                    child: Material(
                      // 카드 내부 컨텐츠
                      type: MaterialType.transparency,
                      child: GestureDetector(
                        onVerticalDragUpdate: _handleVerticalDragUpdate,
                        onVerticalDragEnd: _handleVerticalDragEnd,
                        // GestureDetector는 AnimatedCardShell의 크기만큼만 터치 이벤트를 받음
                        child: Stack(
                          children: [
                            SingleChildScrollView(
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: '여행지 검색',
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.outlineVariant,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                            width: 1.0,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.5),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                      color: Colors.grey.shade400,
                                      thickness: 0.5,
                                      indent: 3,
                                      endIndent: 3,
                                      height: 30,
                                    ),
                                    const Text(
                                      '인기 여행지',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                            print(
                                              '${regionNames[index]} 버튼 클릭됨',
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            side: BorderSide(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.outlineVariant,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                          ),
                                          child: Text(
                                            regionNames[index],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ).animate().fade(
                                begin: 0.0,
                                end: 1.0,
                                duration: 200.ms,
                              ),
                            ),
                            // 블러 효과 (기존과 동일)
                            if (!_isExpanded ||
                                _animationController.status ==
                                    AnimationStatus.forward ||
                                _animationController.status ==
                                    AnimationStatus.reverse)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 60.0,
                                child: IgnorePointer(
                                  child: ClipRRect(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white.withOpacity(0.5),
                                            Colors.white.withOpacity(1.0),
                                          ],
                                          stops: const [0.0, 0.3, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(
                                          sigmaX: 4.0,
                                          sigmaY: 4.0,
                                        ),
                                        child: Container(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapListItem(BuildContext context, int index) {
    // ... 기존 코드와 동일 ...
    final Color onSurfaceVariantColor =
        Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: SizedBox(
        width: mapItemWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: mapItemWidth,
                height: mapImageHeight,
                color: Colors.grey.shade300, // 실제 이미지로 대체 필요
              ),
            ),
            SizedBox(height: mapCaptionSpacing),
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
