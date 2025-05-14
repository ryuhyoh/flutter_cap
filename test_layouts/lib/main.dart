import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '상시 확장 카드 데모',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // 테마 색상 변경
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AlwaysExpandedCardScreen(),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}

class AlwaysExpandedCardScreen extends StatefulWidget {
  const AlwaysExpandedCardScreen({super.key});

  @override
  _AlwaysExpandedCardScreenState createState() =>
      _AlwaysExpandedCardScreenState();
}

class _AlwaysExpandedCardScreenState extends State<AlwaysExpandedCardScreen> {
  // 0: 카드 1 확장, 1: 카드 2 확장 (항상 둘 중 하나는 확장)
  int _currentlyExpandedCardIndex = 0; // 기본값: 카드 1 확장

  // Flex 비율 (실제 값은 _updateCardVisualStates에서 설정)
  late int _flexCard1;
  late int _flexCard2;

  // 카드 높이 관련 상수 및 상태 변수
  final double _normalCardHeight = 130.0; // 일반 상태 카드 높이
  final double _expandedCardHeight = 300.0; // 확장 상태 카드 높이 (비율에 맞게 조절)

  late double _currentCard1Height;
  late double _currentCard2Height;

  @override
  void initState() {
    super.initState();
    // 초기 시각적 상태 설정 (카드 1 확장)
    _updateCardVisualStates();
  }

  // 현재 _currentlyExpandedCardIndex에 따라 flex와 height를 설정하는 헬퍼 함수
  void _updateCardVisualStates() {
    if (_currentlyExpandedCardIndex == 0) {
      // 카드 1 확장
      _flexCard1 = 3; // 확장된 카드가 더 많은 flex 비율을 가짐
      _flexCard2 = 1;
      _currentCard1Height = _expandedCardHeight;
      _currentCard2Height = _normalCardHeight;
    } else {
      // 카드 2 확장 (_currentlyExpandedCardIndex == 1)
      _flexCard1 = 1;
      _flexCard2 = 3; // 확장된 카드가 더 많은 flex 비율을 가짐
      _currentCard1Height = _normalCardHeight;
      _currentCard2Height = _expandedCardHeight;
    }
  }

  // 확장된 카드를 전환하는 함수
  void _switchExpandedCard(int cardIndexToExpand) {
    // 이미 확장된 카드를 다시 탭한 경우, 아무 작업도 하지 않음
    if (_currentlyExpandedCardIndex == cardIndexToExpand) {
      return;
    }

    setState(() {
      _currentlyExpandedCardIndex = cardIndexToExpand;
      _updateCardVisualStates(); // 변경된 인덱스에 따라 시각적 상태 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    // 애니메이션 지속 시간 및 커브. 부드러움을 위해 조절 가능.
    const Duration animationDuration = Duration(milliseconds: 400);
    const Curve animationCurve = Curves.easeInOutCubic; // 부드러운 전환을 위한 커브

    return Scaffold(
      appBar: AppBar(title: Text('항상 하나는 확장된 카드')),
      body: Column(
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose, // 자식의 크기를 존중하되, 할당된 공간 내로 제한
            flex: _flexCard1, // 동적으로 변하는 flex 값
            child: GestureDetector(
              onTap: () => _switchExpandedCard(0), // 카드 1 탭 시
              child: AnimatedContainer(
                height: _currentCard1Height, // 동적으로 변하는 높이
                duration: animationDuration,
                curve: animationCurve,
                margin: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color:
                      _currentlyExpandedCardIndex == 0
                          ? Colors.deepPurpleAccent
                          : Colors.deepPurple[200],
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: _currentlyExpandedCardIndex == 0 ? 3 : 1,
                      blurRadius: _currentlyExpandedCardIndex == 0 ? 8 : 4,
                      offset: Offset(
                        0,
                        _currentlyExpandedCardIndex == 0 ? 4 : 2,
                      ),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '카드 1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            flex: _flexCard2, // 동적으로 변하는 flex 값
            child: GestureDetector(
              onTap: () => _switchExpandedCard(1), // 카드 2 탭 시
              child: AnimatedContainer(
                height: _currentCard2Height, // 동적으로 변하는 높이
                duration: animationDuration,
                curve: animationCurve,
                margin: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color:
                      _currentlyExpandedCardIndex == 1
                          ? Colors.pinkAccent
                          : Colors.pink[100],
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: _currentlyExpandedCardIndex == 1 ? 3 : 1,
                      blurRadius: _currentlyExpandedCardIndex == 1 ? 8 : 4,
                      offset: Offset(
                        0,
                        _currentlyExpandedCardIndex == 1 ? 4 : 2,
                      ),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '카드 2',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
}
