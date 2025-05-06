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
  int _currentIndex = 0; // 리스트를 순환하면서 텍스트를 출력해주기 위해 현재 인덱스 번호를 기록
  double _textOpacity = 1.0; // 텍스트의 투명도 1.0이 완전히 투명
  Timer? _textAnimationTimer; // 텍스트를 반복적(주기적)으로 페이드인 페이드아웃 시켜주기 위한 타이머 객체
  final Duration _fadeDuration = const Duration(
    milliseconds: 750,
  ); // 페이드 간격 (속도)
  final Duration _displayDuration = const Duration(
    milliseconds: 2500,
  ); // 출력 간격 (유지)

  // --- 버튼 모양 및 Hero 태그 정의 ---
  final double _buttonHeight = 58.0;
  final double _buttonWidth = 370.0;
  final double _buttonBorderRadius = 20.0;
  final String _heroTag = 'searchBoxHero'; // Hero 태그 다시 사용
  final double _cardBorderRadius =
      35.0; // flightBuild 시 사용되므로 search_screen 곡률과 맞춰놔야 자연스러움!

  // --- 생명주기 메서드 ---
  @override
  void initState() {
    // 앱이 실행되자마자 실행 되어야하는 함수
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 위젯이 화면에 완전히 그려진 후 타이머 시작작
      if (mounted) {
        // 위젯이 여전히 화면에 있는지 확인
        _startTextTimer();
      }
    });
  }

  @override
  void dispose() {
    _textAnimationTimer?.cancel();
    super.dispose();
  }

  // --- 메서드 ---
  // 상단 텍스트 애니메이션 타이머 시작 로직
  void _startTextTimer() {
    _textAnimationTimer?.cancel(); // 혹시 이전 타이머가 있다면 취소
    // Timer.periodic: 주기적 타이머 생성
    _textAnimationTimer = Timer.periodic(_displayDuration + _fadeDuration, (
      timer,
    ) {
      // 3.25초마다 실행될 콜백 함수
      if (!mounted) {
        // 위젯이 화면에서 사라졌다면
        timer.cancel(); // 타이머 중지
        return; // 함수도 종료
      }

      // 1단계 : 텍스트 페이드 아웃 시작
      setState(() {
        _textOpacity = 0.0;
      });
      // AnimatedOpacity 위젯이 이 변화를 감지하고 _fadeDuration(750ms) 동안 서서히 투명하게 만듦

      // 2단계 : 페이드 아웃 애니메이션 시간(750ms)만큼 기다림
      Future.delayed(_fadeDuration, () {
        if (mounted) {
          // 기다리는 동안 위젯 사라졌다면 중단

          // 3단계 : 텍스트 변경 및 페이드 인 시작
          setState(() {
            // 상태 변경 및 UI 업데이트 요청
            _currentIndex =
                (_currentIndex + 1) % _texts.length; // 다음 인덱스로 넘어가기기
            _textOpacity = 1.0; // 투명도를 다시 1로 설정
          });
          // AnimatedOpacity 위젯이 이 변화를 감지하고 _fadeDuration(750ms) 동안안 서서히 불투명하게 만듦
          // 동시에 Text 위젯은 새로운 _currentIndex의 텍스트를 표시
        }
      });
    });
  }

  // --- '검색 시작하기' 버튼 위젯 빌드 메서드 (Hero 방식) ---
  Widget _buildSearchButton() {
    // 1. 버튼의 기본 모양 정의 (Container 사용)
    Widget buttonShape = Container(
      width: _buttonWidth,
      height: _buttonHeight,
      decoration: BoxDecoration(
        // Container 스타일링
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_buttonBorderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        boxShadow: [
          // 그림자 효과
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        // Material 위젯 : Material Design 시각적 요소 제공공
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

    // 2.flightShuttleBuilder에서 사용할 목적지 카드 스타일 미리 정의
    final destinationCardDecoration = BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(_cardBorderRadius), // 목적지와 맞춰주기 (곡률)
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );

    // 3. GestureDetector: 탭 이벤트를 감지하는 위젯
    return GestureDetector(
      onTap: () {
        // 탭했을 때 실행될 함수
        Navigator.push(
          // 새 화면(Route)을 화면 스택에 올림
          context,
          PageRouteBuilder(
            // PageRouteBuilder: 커스텀 페이지 전환 효과를 만들기 위한 클래스
            transitionDuration: 450.ms, // 화면 전환 애니메이션 시간
            reverseTransitionDuration: 400.ms,
            opaque: false, // 전환 중 이전 화면이 비치도록 배경을 투명하게 처리
            pageBuilder: // 실제로 표시될 화면 위젯을 생성하는 함수
                (context, animation, secondaryAnimation) =>
                    const SearchScreen(),
            transitionsBuilder: (
              // 화면 전환 애니메이션을 정의하는 함수
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                // FadeTransition: 자식 위젯의 투명도를 애니메이션 값에 따라 변경
                opacity: CurvedAnimation(
                  // animation 값 (0.0 -> 1.0)에 따라 투명도 조절
                  parent: animation,
                  curve: Curves.easeIn,
                ),
                child: child, // child는 pageBuilder에서 반환된 SearchScreen 위젯
              );
            },
          ),
        );
      },
      // 4. Hero 위젯: 화면 전환 시 부드러운 '영웅' 애니메이션 효과 적용
      child: Hero(
        tag: _heroTag, // 이 Hero위젯을 식별하는 태그, SearchScreen의 Hero와 같아야함.
        // createRectTween: Hero 애니메이션 중 사각형 영역이 변형되는 방식을 정의의
        createRectTween: (begin, end) {
          return MaterialRectArcTween(
            begin: begin,
            end: end,
          ); // 직선이 아닌 호(arc)를 그리며 부드럽게 이동/변형
        },
        flightShuttleBuilder: (
          // flightShuttleBuilder: Hero 애니메이션 '비행(flight)' 중에 보여질 위젯을 직접 정의
          // 비행 중에는 내용물 없이 목적지 카드 모양의 빈 Container만 보여줌
          // SearchScreen 내용물이 미리 그려져 깜빡이는 현상 방지
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          return Material(
            // Material로 감싸야 Hero가 제대로 처리
            // child: Hero 애니메이션의 대상이 되는 실제 위젯
            type: MaterialType.transparency,
            child: Container(decoration: destinationCardDecoration),
          );
          // 참고: 기본 동작은 return toHeroContext.widget;.
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
                  // 상단 텍스트 (AnimatedOpacity로 감싸 페이드 효과 적용용)
                  opacity: _textOpacity,
                  duration: _fadeDuration,
                  child: Text(
                    _texts[_currentIndex],
                    textAlign: TextAlign.center, // 텍스트 가운데 정렬
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                _buildSearchButton(), // 위에서 정의한 버튼 생성 메서드 호출
              ],
            ),
          ),
        ),
      ),
    );
  }
}
