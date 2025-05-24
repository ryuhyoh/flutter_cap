import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// SearchScreen import
import 'package:flutter_animate/flutter_animate.dart'; // .ms 확장 기능 등 사용
import 'screens/test.dart';
import 'package:flutter_locallens/screens/main_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android 기준: 아이콘 어둡게
        statusBarBrightness: Brightness.light, // iOS 기준: 아이콘 어둡게 (내용은 밝게)
      ),
    );

    return MaterialApp(
      title: 'WhereWeGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.white,
        useMaterial3: true,
        fontFamily: 'Gmacket',
      ),
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
  final double _buttonBorderRadius = 20.0; // 버튼 모서리 둥글기
  final String _heroTag = 'searchBoxHero';
  final double _cardBorderRadius = 35.0; // SearchScreen의 카드 모서리와 일치

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTextTimer();
      }
    });
  }

  @override
  void dispose() {
    _textAnimationTimer?.cancel();
    super.dispose();
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

  Widget _buildSearchButton() {
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
      borderRadius: BorderRadius.circular(25.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: 450.ms, // 애니메이션 시간 조정
            reverseTransitionDuration: 400.ms,
            opaque: false, // 배경을 투명하게 하여 Hero 애니메이션이 더 잘 보이도록 설정
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const InteractiveAnimatedCardsScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
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
        tag: 'searchBoxHero',
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
          // SearchScreen의 카드 모양과 일치하도록 flightShuttle 정의
          return Material(
            type: MaterialType.transparency,
            child: Container(decoration: destinationCardDecoration),
          );
        },
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
                _buildSearchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
