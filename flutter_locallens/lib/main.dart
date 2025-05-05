import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 상태 표시줄 배경 투명
        statusBarIconBrightness: Brightness.dark, // Android 상태 표시줄 아이콘 어둡게
        statusBarBrightness:
            Brightness.light, // iOS 상태 표시줄 아이콘 어둡게 (주의: light가 어두운 아이콘)
      ),
    );

    return MaterialApp(
      title: 'WhereWeGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.white),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> _texts = ['안녕하세요!', '여행지를 추천해드릴게요!'];

  int _currentIndex = 0; //문장 인덱스
  double _opacity = 1.0; //투명도 (1.0이 완전히 보이는 상태, 0.0이 투명한상태)
  Timer? _timer;

  final Duration _fadeDuration = Duration(milliseconds: 750);
  final Duration _displayDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(_displayDuration + _fadeDuration, (timer) {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
        });
      } else {
        timer.cancel();
        return;
      }

      Future.delayed(_fadeDuration, () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _texts.length;
            _opacity = 1.0;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _opacity,
                    duration: _fadeDuration,
                    child: Text(
                      _texts[_currentIndex],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(370, 58),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      elevation: 10,
                      surfaceTintColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      shadowColor: Colors.black.withOpacity(0.35),
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 5),
                        Text('검색 시작하기'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
