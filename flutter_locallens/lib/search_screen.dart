import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // .ms 확장 기능은 AnimationController 등에서 여전히 유용하게 사용될 수 있습니다.
import 'dart:ui' as ui;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  // --- 카드 관련 변수 ---
  final String _heroTag = 'searchBoxHero'; // hero 애니메이션 키 값
  final double _initialCardHeight = 430.0; // 초기 카드 높이, 너비
  final double _initialCardWidth = 390.0;
  final double _expandedCardHeight = 700.0; // 사용자가 스크롤 했을 때 확장 높이, 너비
  final double _expandedCardWidth = 420.0;
  final double _cardBorderRadius = 35.0;

  /* --- 애니메이션 관련 변수 ---
    - late 키워드 : 이 변수가 선언될 때 바로 초기화되지 않고, 나중에 (일반적으로 initState 메소드 내에서)
                 사용되기 전에 반드시 초기화 될 것임을 나타낸다.
    - AnimationController : Flutter 애니메이션 시스템의 핵심 클래스 중 하나이다. 
                            특정 기간 (duration) 동안 0.0에서 1.0 사이의 값을 생성하며,
                            애니메이션을 시작(forward()), 중지(stop()), 반대로 재생(reverse()),
                            또는 특정 값으로 설정(value = ...)하는 등의 제어를 담당한다. 
    - _animationController 변수 : 이 화면에서 카드의 확장 및 축소 애니메이션을 전반적으로 제어하는 컨트롤러
                             사용자의 드래그 제스처에 반응하여 이 컨트롤러의 값이 변경되거나 
                             애니메이션이 시작됨. 
    - Animation<double> : 애니메이션이 진행됨에 따라 시간에 따라 변하는 double 타입의 값을 나타낸다.
                          이 자체는 애니메이션을 제어하지는 않지만, AnimationController 에 의해 
                          '구동되어' 애니메이션 값(높이, 너비)을 제공
    - _heightAnimation, _widthAnimation 변수 : 카드의 높이, 너비가 애니메이션되는 동안 변경될 높이 값을 제공.
                                              일반적으로 Tween<double> (애니메이션의 시작 높이와 끝 높이 정의)
                                              을 사용해 만들어지고, _animationController에 의해 애니메이션 된다. 
                                              AnimationBuilder 같은 위젯이 이 값을 이용해 UI를 업데이트한다.  
    - _isExpanded 변수 : 카드가 현재 "완전히 확장된" 상태인지 아닌지를 추적하는 상태 플래그
                  역할 : UI 여러 부분에서 상태에 따른 결정을 내리는 데 사용됨. 
                        SingleChildScrollView의 스크롤 동작 변경 (확장시 스크롤 가능, 축소시 불가능)
                        블러 효과와 같이 특정 UI 요소의 표시 여부 제어 
                        카드가 확장되었을 때와 축소되었을 때 서로 다른 내용을 보여주는 등의 로직 처리 
          업데이트 시점 : 주로 사용자의 드래그 제스처가 끝나고(_handelVerticalDragEnd 메소드 내에서)
                        _animationController가 forward() 또는 reverse() 를 통해 애니메이션을 완료했을 때
                        그 최종 상태에 맞춰 true 또는 false로 업데이트 

--- 이 변수들이 작동하는 방식 --- 
    1. 사용자가 카드를 드래그하면(_handleVerticalDragUpdate, _handleVerticalDragEnd 메서드)
       _animationController의 값(value)이 변경되거나, forward() (확장) 또는 reverse() (축소) 명령을 받는다. 
    2. _animationController의 값이 0.0에서 1.0사이로 변경됨에 따라, 이 컨트롤러에 연결된 
       _heightAnimation과 _widthAnimation이 각각 새로운 높이와 너비 값을 계산하여 출력한다. 
    3. AnimationBuilder 위젯이 _animationController를 "듣고 있다가" 변경이 발생하면,
       _heightAnimation.value와 _widthAnimation.value를 사용하여 카드의 크기를 새롭게 그려준다. 
    4. 애니메이션 완료된 후 _isExpanded변수가 현재 카드의 최종 확장/축소 상태를 반영하도록 업데이트 되어 다른 UI 로직에 사용된다. 
  */
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _widthAnimation;
  bool _isExpanded = false;

  // --- 지도목록 변수 ---
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

  @override
  void initState() {
    // 1. 부모 클래스의 initState 호출
    super.initState();

    // 2. 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(vsync: this, duration: 400.ms);

    // 3. 높이 애니메이션 설정
    _heightAnimation = Tween<double>(
      begin: _initialCardHeight,
      end: _expandedCardHeight,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // 4. 너비 애니메이션 설정
    _widthAnimation = Tween<double>(
      begin: _initialCardWidth,
      end: _expandedCardWidth,
    ).animate(
      // 이 Tween을 _animationController와 연결하고 애니메이션 커브 적용
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /* 
    사용자가 화면의 특정 위젯(카드)을 잡고 위아래로 드래그하는 동안 지속적으로 호출되어,
    드래그에 맞춰 카드의 크기를 실시간으로 조절하는 역할 

    이 메소드는 GestureDetector 위젯의 onVerticalDragUpdate 콜백으로 등록되어,
    사용자가 수직 방향으로 드래그 제스처를 할 때마다 호출된다. 

    DragUdateDetails details 매개변수에는 드래그 이벤트에 대한 상세 정보가 담겨있다.
  */
  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    /* 
      1. 드래그 변화량 (delta) 계산 :
        details.primaryDelta! : DragUdateDetails 객체의 속성으로, 마지막 업데이트 이후
                                 주 축(수직)을 따라 사용자의 손가락이 얼마나 이동했는지를 나타냄
                                - 위로 드래그하면 보통 음수(-) 값을 가짐
                                - 아래로 드래그하면 보통 양수(+) 값을 가짐
                                - ! (null assertion operator)는 primaryDelta가 null이 아님을 단언       
        (_expandedCardHeight - _initCardHeight) : 카드가 최대로 확장되었을 때 높이와 초기 높이의 차이,
                                                  즉, 카드가 변할 수 있는 전체 높이 범위를 계산 
        -details.primaryDelta! / (전체 높이 범위) : details.primaryDelta! 를 전체 높이 범위로 나누는 것은 
                                                  사용자의 드래그 거리를 0.0에서 1.0사이의 정규화 된 값으로 
                                                  변환하려는 시도이다. 예를 들어, 사용자가 카드의 전체 높이범위 만큼
                                                  드래그 하면 이 부분의 절대값은 대략 1.0이 된다. 
        (-) : 만약 위로 드래그 할 때 (details.primaryDelta가 음수) 카드가 확장되기를 (_animationController.value가 1.0에 가까워지기를)
              원하면 - (음수)는 양수가 되어 컨트롤러 값을 증가시킨다. 
              만약 아래로 드래그 할 때 (detailes.primaryDelta가 양수) 카드가 축소되기를 (_animationController.value가 0.0에 가까워지기를)
              원하면 -(양수)는 음수가 되어 컨트롤러 값을 감소시킨다. 
    */
    double delta =
        -details.primaryDelta! / (_expandedCardHeight - _initialCardHeight);

    // 2. 애니메이션 컨트롤러 값 업데이트
    _animationController.value += delta;

    // 3. 애니메이션 컨트롤러 값 범위 제한 (clamp함수수)
    _animationController.value = _animationController.value.clamp(0.0, 1.0);
  }

  /* 
    사용자가 카드를 위아래로 드래그하다가 손가락을 화면에서 떼었을 때 호출 
    이때 드래그를 놓은 시점의 속도와 카드의 현재 확장 상태를 기준으로 카드를 완전히 펼칠지,
    아니면 원래대로 접을지를 결정해 애니메이션을 실행하는 역할 

    이 메소드는 GestureDetector의 onVerticalDragEnd 콜백으로 지정되어, 
    사용자가 수직 드래그를 끝냈을 때 (화면에서 손가락을 뗐을 때) 호출된다. 

    DragEndDetails details 매개변수는 드래그가 끝나는 순간의 정보를 담고 있으며,
    특히 details.primaryVelocity(주 축 방향의 드래그 속도)가 중요하게 사용된다.

    사용자가 드래그를 마쳤을 때, 카드가 어중간한 위치에 머무르지 않고 완전히 확장, 축소로 
    '착 달라붙는(snap)' 효과를 제공
  */
  void _handleVerticalDragEnd(DragEndDetails details) {
    // 1. 카드를 확장할 조건인지 확인
    if (details.primaryVelocity! < -500 || // 위로 빠르게 쓸어올렸거나
        (_animationController.value >= 0.5 && details.primaryVelocity! < 500)) {
      // 절반 이상 열려있고 아래로 빠르게 쓸어내리지 않았다면
      // 2. 확장 애니메이션 실행
      _animationController.forward();
      if (mounted) setState(() => _isExpanded = true); // 확장 상태로 변경
    } else {
      // 3. 축소 애니메이션 실행
      _animationController.reverse();
      if (mounted) setState(() => _isExpanded = false); // 축소 상태로 변경
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(
            context,
          ).colorScheme.surface, // 카드와 동일한 배경색 또는 약간 다르게 하여 구분감 주기
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
        child: Hero(
          // Hero: 화면 전환 애니메이션을 위한 위젯
          tag: _heroTag,
          createRectTween: (begin, end) {
            // Hero 애니메이션 중 사각형 모양이 변할 때의 애니메이션 방식 정의
            return MaterialRectArcTween(
              begin: begin,
              end: end,
            ); // 아치형으로 부드럽게 변하도록 설정
          },
          child: Material(
            // Hero 애니메이션 중 Material Design 요소(그림자 등)가 깨지지 않도록 유지
            type: MaterialType.transparency, // Hero 전환 중 배경이 투명하도록 설정
            child: AnimatedBuilder(
              // _animationController 값 변경에 따라 UI를 다시 빌드하여 애니메이션 효과 구현
              animation: _animationController, // 이 컨트롤러의 값 변경을 감지
              builder: (context, child) {
                // UI를 빌드하는 함수
                return Container(
                  // 애니메이션 되는 카드 본체
                  width: _widthAnimation.value, // 현재 애니메이션 값에 따른 너비
                  height: _heightAnimation.value, // 현재 애니메이션 값에 따른 높이이
                  decoration: BoxDecoration(
                    // 카드 스타일링
                    color: Theme.of(context).colorScheme.surface,
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
                    // ClipRRect : 카드의 내용이 둥근 모서리를 넘어가지 않도록 잘라냄냄
                    borderRadius: BorderRadius.circular(_cardBorderRadius),
                    child:
                        child, // AnimatedBuilder의 child 매개변수 (아래 Material 위젯)을 내용으로 사용용
                  ),
                );
              },
              child: Material(
                // 내부 컨텐츠 영역도 Material로 감싸서 일관성 유지
                type: MaterialType.transparency,
                child: GestureDetector(
                  onVerticalDragUpdate:
                      _handleVerticalDragUpdate, // 수직 드래그 중일 때 호출될 함수 연결
                  onVerticalDragEnd:
                      _handleVerticalDragEnd, // 수직 드래그가 끝났을 때 호출될 함수 연결결
                  child: Stack(
                    // 여러 위젯을 겹쳐서 표시 (메인 콘텐츠와 블러 효과)
                    children: [
                      SingleChildScrollView(
                        physics:
                            _isExpanded
                                ? const ClampingScrollPhysics() // 카드가 확장되었을 때 스크롤 가능
                                : const NeverScrollableScrollPhysics(), // 축소되었을 때 스크롤 불가능
                        child: Padding(
                          // 콘텐츠 주변에 전체적인 여백 추가
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            // 내부 요소들을 세로로 배치
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // 왼쪽 정렬
                            children: [
                              // --- 카드 내부 UI 요소들 ---
                              Text(
                                '어디로 떠나시나요?',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                decoration: InputDecoration(
                                  // 입력 필드 스타일링
                                  hintText: '여행지 검색',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  border: OutlineInputBorder(
                                    // 기본 테두리
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    // 활성화 상태 테두리
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    // 포커스 상태 테두리
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface, // 포커스 시 primaryColor 사용
                                      width: 1.0,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.5), // 내부 채우기 색 살짝 변경
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
                                      ),
                                      side: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outlineVariant,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      regionNames[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant, // 테마 색상 활용
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

                      // Positioned (블러 효과 위젯)
                      if (!_isExpanded || // 카드가 확장되지 않았거나 애니메이션 중일 때만 표시
                          _animationController.status ==
                              AnimationStatus.forward ||
                          _animationController.status ==
                              AnimationStatus.reverse)
                        Positioned(
                          bottom: 0, // Stack 하단에 배치
                          left: 0,
                          right: 0,
                          height: 60.0, // 블러 효과 높이
                          child: IgnorePointer(
                            // 이 위젯이 터치 이벤트를 가로채지 않도록 설정
                            child: ClipRRect(
                              // 효과 영역을 잘라냄
                              // ClipRRect 사용 (모서리 둥글림은 카드 전체 ClipRRect가 담당)
                              child: ShaderMask(
                                // 그라데이션 마스크를 적용하여 효과를 부드럽게 만듦
                                shaderCallback: (bounds) {
                                  // 그라데이션 정의 함수
                                  return LinearGradient(
                                    // 선형 그라데이션
                                    begin: Alignment.topCenter, // 위에서부터
                                    end: Alignment.bottomCenter, // 아래로
                                    colors: [
                                      // 색상 변화 (여기서는 투명도 변화)
                                      Colors.white.withOpacity(
                                        0.0,
                                      ), // 시작 : 완전 투명
                                      Colors.white.withOpacity(
                                        0.5,
                                      ), // 20% 까지도 투명
                                      Colors.white.withOpacity(
                                        1.0,
                                      ), // 끝 : 완전 불투명
                                    ],
                                    stops: const [0.0, 0.2, 1.0], // 색상 변화 지점
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstIn, // 마스크의 알파값을 자식에게 적용
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(
                                    sigmaX: 4.0, // 블러 강도
                                    sigmaY: 4.0,
                                  ),
                                  child: Container(
                                    color:
                                        Theme.of(context).colorScheme.surface,
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
    );
  }

  /*
    가로로 스크롤되는 '지도목록'의 각 항목(아이템) UI를 생성하는 역할을 한다. 
    ListView.builder의 itemBuilder 속성에 이 함수가 제공되어, 목록의 각 아이템이 화면에 
    필요할 때마다 이 함수를 통해 그려진다. 
  */
  Widget _buildMapListItem(BuildContext context, int index) {
    final Color onSurfaceVariantColor =
        Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: SizedBox(
        width: mapItemWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 이미지 표시 부분 (모서리가 둥근 사각형)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              // 실제 이미지가 들어갈 컨테이너
              child: Container(
                width: mapItemWidth,
                height: mapImageHeight,
                color: Colors.grey.shade300, // 실제 이미지로 대체 필요
                // TODO : child: Image.network(...),
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
