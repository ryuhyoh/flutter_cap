import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'search_screen.dart'; // SearchScreen import
import 'package:flutter_animate/flutter_animate.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'WhereWeGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.white, useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // --- 상단 텍스트 애니메이션 관련 변수 ---
  final List<String> _texts = ['안녕하세요👋', '여행지를 추천해드릴게요', '원하시는 느낌이 있나요?'];
  int _currentIndex = 0;
  double _textOpacity = 1.0;
  Timer? _textAnimationTimer;
  final Duration _fadeDuration = const Duration(milliseconds: 750);
  final Duration _displayDuration = const Duration(milliseconds: 2500);

  // --- 버튼 모양 및 Hero 태그 정의 ---
  final double _buttonHeight = 58.0;
  final double _buttonWidth = 370.0;
  final double _buttonBorderRadius = 29.0;
  final String _heroTag = 'searchBoxHero'; // Hero 태그 다시 사용
  final double _cardBorderRadius = 15.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTextTimer();
      }
    });
  }

  void _startTextTimer() {
    _textAnimationTimer?.cancel();
    _textAnimationTimer = Timer.periodic(_displayDuration + _fadeDuration, (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _textOpacity = 0.0;
      });
      Future.delayed(_fadeDuration, () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _texts.length;
            _textOpacity = 1.0;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _textAnimationTimer?.cancel();
    super.dispose();
  }

  // --- '검색 시작하기' 버튼 위젯 빌드 (Hero 방식) ---
  Widget _buildSearchButton() {
    // 버튼의 시각적 모양 정의
    Widget buttonShape = Container(
      width: _buttonWidth,
      height: _buttonHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_buttonBorderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        // Material 효과 일관성
        type: MaterialType.transparency,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(
              '검색 시작하기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
    final destinationCardDecoration = BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );

    // GestureDetector와 Hero 사용
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          // PageRouteBuilder 사용 (이전과 동일)
          PageRouteBuilder(
            transitionDuration: 500.ms, // 애니메이션 시간
            reverseTransitionDuration: 400.ms,
            opaque: false, // 배경 투명하게 시작
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const SearchScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              // 페이지 전체 페이드 효과
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: _heroTag, // 고유 태그
        // 부드러운 호 이동 효과
        createRectTween: (begin, end) {
          return MaterialRectArcTween(begin: begin, end: end);
        },
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          // 애니메이션 중에는 내용물 없이 목적지 카드의 모양만 렌더링
          // 이렇게 하면 SearchScreen의 내용물이 미리 그려지는 것을 방지
          return Material(
            // Material로 감싸야 Hero가 제대로 처리
            type: MaterialType.transparency,
            child: Container(decoration: destinationCardDecoration),
          );
          // 참고: 기본 동작은 return toHeroContext.widget; 입니다.
        },
        // ==================================================
        child: Material(type: MaterialType.transparency, child: buttonShape),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _textOpacity,
                  duration: _fadeDuration,
                  child: Text(
                    _texts[_currentIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                _buildSearchButton(), // Hero 방식 버튼 호출
              ],
            ),
          ),
        ),
      ),
    );
  }
}
