// dummy_card_detail_screen.dart
import 'package:flutter/material.dart';
import '../card/card_shell.dart'; // AnimatedCardShell 경로에 맞게 수정해주세요.

class SubScreen extends StatelessWidget {
  final String subHeroTag; // SearchScreen으로부터 전달받을 Hero 태그

  const SubScreen({super.key, required this.subHeroTag});

  @override
  Widget build(BuildContext context) {
    // 화면 크기에 따라 확장될 더미 카드의 크기를 결정합니다.
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double expandedHeight = screenHeight * 0.75 - 90.0; // 화면 높이의 75%
    final double expandedWidth = screenWidth * 0.9; // 화면 너비의 90%

    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface, // 확장 시 배경색 변경 (예시)
      appBar: AppBar(
        title: const Text('Dummy Card Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          fontSize: 20,
        ),
      ),
      body: Center(
        child: Hero(
          tag: subHeroTag, // 전달받은 Hero 태그 사용
          createRectTween: (begin, end) {
            // 모서리 둥근 사각형 간의 부드러운 전환
            return MaterialRectArcTween(begin: begin, end: end);
          },
          child: Material(
            // Hero 애니메이션 중 Material 위젯 깨짐 방지
            type: MaterialType.transparency,
            child: CardShell(
              currentHeight: expandedHeight,
              currentWidth: expandedWidth,
              borderRadius: 35.0, // SearchScreen의 카드와 동일한 borderRadius
              contentChild: const Padding(
                padding: EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  // 내용이 길어질 경우 스크롤 가능
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Expanded Dummy Card Content',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      FlutterLogo(size: 100),
                      SizedBox(height: 20),
                      Text(
                        '여기에 더미 카드의 상세 내용이 표시됩니다. ',
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.surface, // 확장 시 카드 배경색
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
