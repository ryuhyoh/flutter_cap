import 'package:flutter/material.dart';
import 'package:flutter_locallens/loading_page.dart';
import 'dart:async';
import 'package:flutter/services.dart';

/*void main() {
  runApp(MaterialApp(home: InteractiveAnimatedCardsScreen()));
}*/

class InteractiveAnimatedCardsScreen extends StatefulWidget {
  const InteractiveAnimatedCardsScreen({super.key});

  @override
  _InteractiveAnimatedCardsScreenState createState() =>
      _InteractiveAnimatedCardsScreenState();
}

class _InteractiveAnimatedCardsScreenState
    extends State<InteractiveAnimatedCardsScreen> {
  final List<String> _vibeTexts = [
    '" 한적하고 교통이 편리한 "',
    '" 활발하고 즐길거리가 많은 "',
    '" 주차공간이 넓고 아이와 갈 수 있는 "',
    '" 청결하고 맛집이 많은 "',
  ];
  int _currentIndex = 0;
  double _textOpacity = 1.0;
  Timer? _textAnimationTimer;
  final Duration _fadeDuration = const Duration(milliseconds: 750);
  final Duration _displayDuration = const Duration(milliseconds: 3500);

  // -1: 아무 카드도 특별히 확장되지 않음 (둘 다 기본 크기)
  // 0: 첫 번째 카드 확장
  // 1: 두 번째 카드 확장
  int _expandedCardIndex = -1;

  final double _defaultCardHeight = 70.0;
  final double _defaultCard1Height = 300.0;

  final double _defaultCardWidth = 390.0;
  final double _expandedCardWidth = 430.0;
  final double _expandedCardHeight = 450.0;
  final double _expandedCard2Height = 200.0;
  final double _collapsedCardHeight = 70.0;
  final Duration _animationDuration = Duration(milliseconds: 350);

  // --- 첫 번째 카드 여행지 검색 관련 상태 변수 ---
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vibeController =
      TextEditingController(); // 두 번째 카드용 컨트롤러
  bool _showDestinationSuggestions = false;
  List<String> _filteredDestinations = [];
  final LayerLink _textFieldLink = LayerLink();
  String? _selectedDestination; // 선택된 여행지 저장

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

  void _toggleCardExpansion(int cardIndex) {
    setState(() {
      if (_expandedCardIndex == cardIndex) {
        // 이미 확장된 카드를 다시 탭하면 모두 기본 크기로
        _expandedCardIndex = -1;
      } else {
        // 다른 카드를 탭하면 해당 카드 확장, 나머지는 축소
        _expandedCardIndex = cardIndex;
      }
    });
  }

  // --- 백엔드 통신 관련 상태 변수 (선택 사항: 로딩 표시 등) ---
  //bool _isLoading = false; // 로딩 상태를 관리하기 위한 변수

  /*Future<void> _sendDataToBackend() async {
    if (_selectedDestination == null || _selectedDestination!.isEmpty) {
      print("여행지를 선택해주세요.");
      // 사용자에게 알림 (예: SnackBar)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('여행지를 먼저 선택해주세요!')));
      return;
    }

    // 로딩 시작 (UI에 로딩 인디케이터를 표시할 수 있음)
    setState(() {
      _isLoading = true;
    });

    // 백엔드 API 엔드포인트 URL (실제 사용하시는 URL로 변경해야 합니다)
    const String apiUrl =
        "http://127.0.0.1:8000/search/"; // 예: "https://api.example.com/search"

    // 전송할 데이터 구성
    final Map<String, String> requestBody = {
      'destination': _selectedDestination!,
      'vibe': _vibeController.text,
    };

    // HTTP 요청 헤더 (필요에 따라 Content-Type 등을 설정)
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      // 필요하다면 인증 토큰 등을 여기에 추가할 수 있습니다.
      // 'Authorization': 'Bearer YOUR_AUTH_TOKEN',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl), // 문자열 URL을 Uri 객체로 변환
        headers: headers,
        body: jsonEncode(requestBody), // Map을 JSON 문자열로 인코딩
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 성공적으로 요청이 처리된 경우 (백엔드 응답 코드에 따라 다를 수 있음)
        print("데이터 전송 성공!");
        print("응답 상태 코드: ${response.statusCode}");
        print("응답 본문: ${response.body}");

        // 백엔드로부터 받은 응답 데이터를 파싱하여 사용할 수 있습니다.
        // final responseData = jsonDecode(response.body);
        // print("파싱된 데이터: $responseData");

        // 성공 후 처리 (예: 결과 화면으로 이동, 성공 메시지 표시 등)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('검색 요청 성공: ${response.body}')));
      } else {
        // 서버에서 오류 응답을 보낸 경우 (4xx, 5xx 등)
        print("서버 오류 발생: ${response.statusCode}");
        print("오류 응답: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // 네트워크 오류 또는 요청 중 예외 발생 시
      print("데이터 전송 중 오류 발생: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('요청 중 오류 발생: $e')));
    } finally {
      // 로딩 종료 (UI에서 로딩 인디케이터를 숨김)
      setState(() {
        _isLoading = false;
      });
    }
  }*/

  @override
  void initState() {
    super.initState();
    _filteredDestinations = regionNames; // 초기에는 모든 지역 표시
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _showDestinationSuggestions = true;
          // 포커스 시 현재 텍스트로 필터링 또는 전체 목록 표시
          _filterDestinations(_searchController.text);
        });
      } else {
        // 포커스를 잃을 때 약간의 딜레이를 주어 추천 항목 탭 가능하게 함
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && !_searchFocusNode.hasFocus) {
            // 여전히 포커스가 없는지 재확인
            setState(() {
              _showDestinationSuggestions = false;
            });
          }
        });
      }
    });
    _searchController.addListener(() {
      _filterDestinations(_searchController.text);
    });
    _startTextTimer();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _vibeController.dispose(); // vibeController dispose 추가
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
            _currentIndex = (_currentIndex + 1) % _vibeTexts.length;
            _textOpacity = 1.0;
          });
        }
      });
    });
  }

  void _filterDestinations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDestinations = regionNames;
      } else {
        _filteredDestinations =
            regionNames
                .where(
                  (dest) => dest.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
      // 추천 목록이 활성화되어 있지 않다면, 텍스트 변경 시 활성화 (선택적)
      // if (!_showDestinationSuggestions && query.isNotEmpty) {
      //   _showDestinationSuggestions = true;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    double card1Height;
    double card2Height;
    double card1Width;
    double card2Width;

    switch (_expandedCardIndex) {
      case 0: // 첫 번째 카드 확장
        card1Height = _expandedCardHeight;
        card1Width = _expandedCardWidth;
        card2Width = _defaultCardWidth;
        card2Height = _collapsedCardHeight;
        break;
      case 1: // 두 번째 카드 확장
        card1Height = _collapsedCardHeight;
        card1Width = _defaultCardWidth;
        card2Height = _expandedCard2Height;
        card2Width = _expandedCardWidth;
        break;
      default: // 둘 다 기본 크기 (-1)
        card1Height = _defaultCard1Height;
        card2Height = _defaultCardHeight;
        card1Width = _defaultCardWidth;
        card2Width = _defaultCardWidth;
        break;
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android 기준: 아이콘 어둡게
        statusBarBrightness: Brightness.light, // iOS 기준: 아이콘 어둡게 (내용은 밝게)
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        // 추천 목록을 오버레이하기 위해 Stack 사용
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _toggleCardExpansion(0);
                    if (_expandedCardIndex != 0) {
                      // 첫번째 카드가 축소되면 추천목록도 숨김
                      _searchFocusNode.unfocus();
                    }
                  },
                  child: Hero(
                    tag: 'searchBoxHero',
                    child: AnimatedContainer(
                      width: card1Width,
                      duration: _animationDuration,
                      curve: Curves.easeInOut,
                      height: card1Height,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.transparent,
                          width: _expandedCardIndex == 0 ? 3 : 0,
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics:
                            (_expandedCardIndex == 0 ||
                                    _expandedCardIndex == -1)
                                ? const ClampingScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(19.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '어디로 떠나시나요?',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 40),
                              CompositedTransformTarget(
                                // TextField 위치 추적
                                link: _textFieldLink,
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
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
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outlineVariant,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
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
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                    ),
                                  ),
                                  onTap: () {
                                    // 명시적으로 포커스를 요청하여 키보드가 나타나도록 합니다.
                                    _searchFocusNode.requestFocus();

                                    // 탭 시에도 추천 목록 표시 (포커스 리스너와 중복될 수 있으나 확실히 하기 위함)
                                    if (!_showDestinationSuggestions) {
                                      setState(() {
                                        _filterDestinations(
                                          _searchController.text,
                                        );
                                      });
                                    }
                                  },
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
                                      // 인기 여행지 버튼 클릭 시
                                      final String destination =
                                          regionNames[index];
                                      print('$destination 버튼 클릭됨');
                                      _selectedDestination = destination;
                                      _searchController.text = destination;
                                      _searchController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  _searchController.text.length,
                                            ),
                                          );
                                      _showDestinationSuggestions = false;
                                      _searchFocusNode.unfocus();
                                      setState(() {
                                        _expandedCardIndex = 1; // 두 번째 카드 확장
                                      });
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
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleCardExpansion(1),
                  child: AnimatedContainer(
                    width: card2Width,
                    duration: _animationDuration,
                    curve: Curves.easeInOut,
                    height: card2Height,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.transparent,
                        width: _expandedCardIndex == 1 ? 3 : 0,
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics:
                          _expandedCardIndex == 1
                              ? const ClampingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(19.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '어떤 느낌을 원하세요?',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.0),
                              child: AnimatedOpacity(
                                opacity: _textOpacity,
                                duration: _fadeDuration,
                                child: Text(
                                  _vibeTexts[_currentIndex],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            TextField(
                              controller: _vibeController, // vibeController 연결
                              decoration: InputDecoration(
                                hintText: ' ex) "고요하게 사색을 즐길 수 있는"',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surface.withOpacity(0.5),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.only(right: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //_isLoading
                      //? const CircularProgressIndicator() // 로딩 중일 때 표시할 위젯
                      RawMaterialButton(
                        onPressed: () async {
                          // async 키워드는 _sendDataToBackend 함수 내부에서 처리되므로 여기엔 필수는 아님
                          _searchFocusNode.unfocus();
                          // 백엔드 호출 함수 실행
                          // _sendDataToBackend();
                          if (_selectedDestination != null &&
                              _selectedDestination!.isNotEmpty) {
                            print(
                              "선택된 여행지: $_selectedDestination, 원하는 느낌: ${_vibeController.text}",
                            );

                            // LoadingPage로 이동하고, 결과를 기다림
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LoadingPage(
                                      destination: _selectedDestination!,
                                      vibe: _vibeController.text,
                                    ),
                              ),
                            );

                            // LoadingPage에서 오류 메시지를 가지고 돌아온 경우 처리
                            if (result is String &&
                                result.startsWith("Error:")) {
                              if (mounted) {
                                // 위젯이 여전히 화면에 마운트되어 있는지 확인
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result,
                                    ), // LoadingPage에서 전달된 오류 메시지
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          } else {
                            print(
                              "여행지를 선택해주세요. 원하는 느낌: ${_vibeController.text}",
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('여행지를 먼저 선택해주세요!'),
                                ),
                              );
                            }
                          }
                        },
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        highlightColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.1),
                        splashColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.2),
                        fillColor: Colors.blue,
                        padding: EdgeInsets.all(5.0),
                        constraints: BoxConstraints.tightFor(
                          width: 120.0,
                          height: 53.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 25.0,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '검색',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_showDestinationSuggestions &&
              _expandedCardIndex != 1) // 두 번째 카드가 확장되지 않았을 때만 표시
            Positioned(
              child: CompositedTransformFollower(
                link: _textFieldLink,
                showWhenUnlinked: false,
                offset: const Offset(
                  0.0,
                  58.0,
                ), // TextField 아래로 위치 조정 (TextField 높이 + 약간의 간격)
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200.0, // 추천 목록 최대 높이
                      maxWidth:
                          card1Width - 38, // TextField 좌우 패딩(19*2) 제외한 너비와 유사하게
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filteredDestinations.length,
                      itemBuilder: (context, index) {
                        final destination = _filteredDestinations[index];
                        return ListTile(
                          title: Text(destination),
                          dense: true, // 리스트 항목을 더 간결하게 표시
                          onTap: () {
                            // 추천 목록에서 항목 탭 시
                            _selectedDestination = destination;
                            _searchController.text = destination;
                            _searchController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: _searchController.text.length,
                              ),
                            );
                            _showDestinationSuggestions = false;
                            _searchFocusNode.unfocus();
                            setState(() {
                              _expandedCardIndex = 1; // 두 번째 카드 확장
                            });
                          },
                        );
                      },
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
