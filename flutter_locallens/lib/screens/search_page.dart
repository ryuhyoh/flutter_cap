import 'package:flutter/material.dart';
import 'package:flutter_locallens/loading_page.dart'; // LoadingPage import 확인
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_locallens/selection_model.dart';

class InteractiveAnimatedCardsScreen extends StatefulWidget {
  const InteractiveAnimatedCardsScreen({super.key});

  @override
  _InteractiveAnimatedCardsScreenState createState() =>
      _InteractiveAnimatedCardsScreenState();
}

class _InteractiveAnimatedCardsScreenState
    extends State<InteractiveAnimatedCardsScreen> {
  //--------변수들-----------
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

  int _expandedCardIndex = -1; // -1: 모두 기본, 0: 여행지, 1: 날짜, 2: 인원, 3: 느낌

  final double _defaultCardWidth = 380.0;
  final double _expandedCardWidth = 430.0;

  // 카드별 높이 정의
  final double _defaultDestCardHeight = 300.0; // 여행지 기본 높이 (내용이 많으므로)
  final double _expandedDestCardHeight = 400.0; // 여행지 확장 높이 (내용에 맞춰 조절)
  final double _collapsedDestCardHeight = 70.0;

  final double _defaultDateCardHeight = 70.0;
  final double _expandedDateCardHeight = 200.0; // 날짜 선택기 높이 고려
  final double _collapsedDateCardHeight = 70.0;

  final double _defaultPartySizeCardHeight = 70.0;
  final double _expandedPartySizeCardHeight = 180.0; // 인원 수 입력 필드 높이 고려
  final double _collapsedPartySizeCardHeight = 70.0;

  final double _defaultVibeCardHeight = 70.0;
  final double _expandedVibeCardHeight = 220.0; // 느낌 입력 필드 및 텍스트 애니메이션 높이 고려
  final double _collapsedVibeCardHeight = 70.0;

  final Duration _animationDuration = const Duration(milliseconds: 350);

  // --- 컨트롤러 및 상태 변수 ---
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vibeController = TextEditingController();
  final TextEditingController _partySizeController =
      TextEditingController(); // 인원 수 컨트롤러

  bool _showDestinationSuggestions = false;
  List<String> _filteredDestinations = [];
  final LayerLink _textFieldLink = LayerLink();
  String? _selectedDestination;
  DateTimeRange? _selectedDateRange;
  int? _partySize;

  // --- 기타 UI용 상수 ---
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

  //---------함수들 -----------
  void _toggleCardExpansion(int cardIndex) {
    setState(() {
      // 어떤 카드를 탭하든, 여행지 검색창 포커스는 해제 (추천목록 닫기 위함)
      if (cardIndex != 0 && _searchFocusNode.hasFocus) {
        _searchFocusNode.unfocus();
      }
      // 인원수 입력창 포커스도 해제
      // if (cardIndex != 2 && _partySizeFocusNode.hasFocus) { // 만약 인원수 카드에 FocusNode가 있다면
      //   _partySizeFocusNode.unfocus();
      // }

      if (_expandedCardIndex == cardIndex) {
        _expandedCardIndex = -1; // 이미 확장된 카드면 모두 기본 크기로
      } else {
        _expandedCardIndex = cardIndex; // 다른 카드면 해당 카드 확장
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredDestinations = regionNames;
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _showDestinationSuggestions = true;
          _filterDestinations(_searchController.text);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          // 딜레이 약간 늘림
          if (mounted && !_searchFocusNode.hasFocus) {
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
    _vibeController.dispose();
    _partySizeController.dispose(); // partySizeController 추가
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
    });
  }

  // 여행지 카드 빌드 함수
  Widget _buildDestinationCard(
    BuildContext context,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: () {
        _toggleCardExpansion(0);
        // 여행지 카드가 축소될 때 (다른 카드가 열리거나 모두 닫힐 때) 포커스 해제
        if (_expandedCardIndex != 0) {
          _searchFocusNode.unfocus();
        }
      },
      child: Hero(
        tag: 'searchBoxHero',
        child: AnimatedContainer(
          width: width,
          height: height,
          duration: _animationDuration,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color:
                  _expandedCardIndex == 0
                      ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                      : Colors.transparent,
              width: _expandedCardIndex == 0 ? 2 : 0,
            ),
          ),
          child: SingleChildScrollView(
            physics:
                (_expandedCardIndex == 0 || _expandedCardIndex == -1)
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(19.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '어디로 떠나시나요?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 확장되었거나, 기본 상태(-1)일 때만 상세 UI 표시
                  if (_expandedCardIndex == 0 || _expandedCardIndex == -1) ...[
                    const SizedBox(height: 20),
                    CompositedTransformTarget(
                      link: _textFieldLink,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: '여행지 검색',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                          ),
                        ),
                        onTap: () {
                          // 탭하면 무조건 확장되도록 (이미 확장된 상태에서 탭해도 유지)
                          if (_expandedCardIndex != 0) {
                            _toggleCardExpansion(0);
                          }
                          _searchFocusNode.requestFocus();
                          if (!_showDestinationSuggestions) {
                            setState(() {
                              _showDestinationSuggestions = true; // 추천 목록 강제 표시
                              _filterDestinations(_searchController.text);
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
                        itemCount: mapLocations.length, // 실제 데이터로 변경 필요
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
                            childAspectRatio: 2.8 / 1,
                          ), // 비율 조정
                      itemCount: regionNames.length,
                      itemBuilder: (context, index) {
                        return OutlinedButton(
                          onPressed: () {
                            final String destination = regionNames[index];
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
                              _expandedCardIndex = 1; // 다음 카드(날짜) 확장
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
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
                  ] else if (_selectedDestination != null &&
                      _selectedDestination!.isNotEmpty) ...[
                    // 축소되었지만 값이 선택된 경우
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        _selectedDestination!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 날짜 선택 카드 빌드 함수
  Widget _buildDateSelectionCard(
    BuildContext context,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: () => _toggleCardExpansion(1), // 날짜 카드는 인덱스 1
      child: AnimatedContainer(
        width: width,
        height: height,
        duration: _animationDuration,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(19.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color:
                _expandedCardIndex == 1
                    ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                    : Colors.transparent,
            width: _expandedCardIndex == 1 ? 2 : 0,
          ),
        ),
        child: SingleChildScrollView(
          physics:
              _expandedCardIndex == 1 || _expandedCardIndex == -1
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '언제 떠나시나요?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_expandedCardIndex == 1 || _expandedCardIndex == -1) ...[
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _selectedDateRange == null
                          ? '여행 날짜 선택하기'
                          : '${_selectedDateRange!.start.year}.${_selectedDateRange!.start.month}.${_selectedDateRange!.start.day} ~ ${_selectedDateRange!.end.year}.${_selectedDateRange!.end.month}.${_selectedDateRange!.end.day}',
                      style: TextStyle(
                        fontSize: _selectedDateRange == null ? 16 : 14,
                      ), // 날짜 길이에 따라 폰트 크기 조절
                    ),
                    onPressed: () async {
                      final DateTimeRange? pickedRange =
                          await showDateRangePicker(
                            context: context,
                            initialDateRange: _selectedDateRange,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ), // 어제부터 선택 가능 (혹시 오늘을 시작일로 못 고를까봐)
                            lastDate: DateTime(DateTime.now().year + 2),
                            helpText: '여행 기간을 선택해주세요.',
                            saveText: '확인',
                            cancelText: '취소',
                            builder: (context, child) {
                              // DatePicker 테마 적용
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  // 혹은 현재 테마 기반으로 수정
                                  colorScheme: ColorScheme.dark(
                                    primary:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primary, // 주요 색상
                                    onPrimary:
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimary, // 주요 색상 위의 텍스트/아이콘
                                    surface:
                                        Theme.of(context).colorScheme.surface,
                                    onSurface:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  dialogTheme: DialogThemeData(
                                    backgroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerLowest,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                      if (pickedRange != null) {
                        setState(() {
                          _selectedDateRange = pickedRange;
                          _expandedCardIndex = 2; // 다음 카드(인원 수) 자동 확장
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_expandedCardIndex == 1 &&
                    _selectedDateRange == null) // 확장되었지만 날짜 선택 안했을 때 가이드 텍스트
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Center(
                      child: Text(
                        '위 버튼을 눌러 여행 기간을 설정해주세요.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ] else if (_selectedDateRange != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${_selectedDateRange!.start.year}.${_selectedDateRange!.start.month}.${_selectedDateRange!.start.day} ~ ${_selectedDateRange!.end.year}.${_selectedDateRange!.end.month}.${_selectedDateRange!.end.day}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 인원 수 선택 카드 빌드 함수
  Widget _buildPartySizeCard(
    BuildContext context,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: () => _toggleCardExpansion(2),
      child: AnimatedContainer(
        width: width,
        height: height,
        duration: _animationDuration,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(19.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color:
                _expandedCardIndex == 2
                    ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                    : Colors.transparent,
            width: _expandedCardIndex == 2 ? 2 : 0,
          ),
        ),
        child: SingleChildScrollView(
          physics:
              _expandedCardIndex == 2 || _expandedCardIndex == -1
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '몇 분이서 여행가시나요?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_expandedCardIndex == 2 || _expandedCardIndex == -1) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _partySizeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '예: 2 (숫자만 입력)',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.5),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _partySize = int.tryParse(value);
                      // 인원 수 입력 후 다음 카드(느낌)로 자동 확장 (선택 사항)
                      if (_partySize != null && _partySize! > 0) {
                        FocusScope.of(context).unfocus(); // 키보드 숨기기
                        _expandedCardIndex = 3;
                      }
                    });
                  },
                ),
              ] else if (_partySize != null && _partySize! > 0) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '총 $_partySize명',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: mapItemWidth,
                height: mapImageHeight,
                color: Colors.grey.shade300, // 실제 이미지로 대체 필요
                // child: Image.network('실제 이미지 URL', fit: BoxFit.cover), // 예시
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

  @override
  Widget build(BuildContext context) {
    double destCardWidth;
    double dateCardWidth;
    double partySizeCardWidth;
    double vibeCardWidth;

    double destCardHeight;
    double dateCardHeight;
    double partySizeCardHeight;
    double vibeCardHeight;

    switch (_expandedCardIndex) {
      case 0: // 여행지 카드 확장
        destCardHeight = _expandedDestCardHeight;
        destCardWidth = _expandedCardWidth;
        dateCardHeight = _collapsedDateCardHeight;
        dateCardWidth = _defaultCardWidth;
        partySizeCardHeight = _collapsedPartySizeCardHeight;
        partySizeCardWidth = _defaultCardWidth;
        vibeCardHeight = _collapsedVibeCardHeight;
        vibeCardWidth = _defaultCardWidth;
        break;
      case 1: // 날짜 카드 확장
        destCardHeight = _collapsedDestCardHeight;
        destCardWidth = _defaultCardWidth;
        dateCardHeight = _expandedDateCardHeight;
        dateCardWidth = _expandedCardWidth;
        partySizeCardHeight = _collapsedPartySizeCardHeight;
        partySizeCardWidth = _defaultCardWidth;
        vibeCardHeight = _collapsedVibeCardHeight;
        vibeCardWidth = _defaultCardWidth;
        break;
      case 2: //인원 수 확장
        destCardHeight = _collapsedDestCardHeight;
        destCardWidth = _defaultCardWidth;
        dateCardHeight = _collapsedDateCardHeight;
        dateCardWidth = _defaultCardWidth;
        partySizeCardHeight = _expandedPartySizeCardHeight;
        partySizeCardWidth = _expandedCardWidth;
        vibeCardHeight = _collapsedVibeCardHeight;
        vibeCardWidth = _defaultCardWidth;
        break;
      case 3: // 느낌 확장
        destCardHeight = _collapsedDestCardHeight;
        destCardWidth = _defaultCardWidth;
        dateCardHeight = _collapsedDateCardHeight;
        dateCardWidth = _defaultCardWidth;
        partySizeCardHeight = _collapsedPartySizeCardHeight;
        partySizeCardWidth = _defaultCardWidth;
        vibeCardHeight = _expandedVibeCardHeight;
        vibeCardWidth = _expandedCardWidth;
        break;
      default: // 모두 기본 크기 (-1) 또는 초기 상태
        destCardHeight = _defaultDestCardHeight;
        destCardWidth = _expandedCardWidth; // 여행지 카드는 기본 상태에서도 넓게
        dateCardHeight = _defaultDateCardHeight;
        dateCardWidth = _defaultCardWidth;
        partySizeCardHeight = _defaultPartySizeCardHeight;
        partySizeCardWidth = _defaultCardWidth;
        vibeCardHeight = _defaultVibeCardHeight;
        vibeCardWidth = _defaultCardWidth;
        break;
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 30),
                    // 0: 여행지 카드
                    _buildDestinationCard(
                      context,
                      destCardWidth,
                      destCardHeight,
                    ),
                    // 1: 날짜 선택 카드
                    _buildDateSelectionCard(
                      context,
                      dateCardWidth,
                      dateCardHeight,
                    ),
                    // 2: 인원 수 선택 카드
                    _buildPartySizeCard(
                      context,
                      partySizeCardWidth,
                      partySizeCardHeight,
                    ),
                    // 3: 느낌(Vibe) 카드
                    GestureDetector(
                      onTap: () => _toggleCardExpansion(3),
                      child: AnimatedContainer(
                        width: vibeCardWidth,
                        height: vibeCardHeight,
                        duration: _animationDuration,
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(19.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color:
                                _expandedCardIndex == 3
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.surface.withOpacity(0.5)
                                    : Colors.transparent,
                            width: _expandedCardIndex == 3 ? 2 : 0,
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics:
                              _expandedCardIndex == 3 ||
                                      _expandedCardIndex == -1
                                  ? const ClampingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '어떤 느낌을 원하세요?',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (_expandedCardIndex == 3 ||
                                  _expandedCardIndex == -1) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                  ),
                                  child: AnimatedOpacity(
                                    opacity: _textOpacity,
                                    duration: _fadeDuration,
                                    child: Center(
                                      child: Text(
                                        _vibeTexts[_currentIndex],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18.0, // 폰트 크기 약간 조정
                                          fontWeight: FontWeight.w600, // 두께 조정
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TextField(
                                  controller: _vibeController,
                                  decoration: InputDecoration(
                                    hintText: 'ex) "고요하게 사색을 즐길 수 있는"',
                                    prefixIcon: Icon(
                                      Icons.lightbulb_outline,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                        width: 1.5,
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
                              ] else if (_vibeController.text.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '"${_vibeController.text}"',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0, bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RawMaterialButton(
                            onPressed: () async {
                              // 모든 카드 포커스 해제
                              FocusScope.of(context).unfocus();

                              if (_selectedDestination != null &&
                                  _selectedDestination!.isNotEmpty) {
                                if (_selectedDateRange == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('여행 날짜를 선택해주세요!'),
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (_partySize == null || _partySize! <= 0) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('인원 수를 입력해주세요!'),
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (_vibeController.text.isEmpty) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('원하는 느낌을 입력해주세요!'),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                context.read<SelectionModel>().clear();
                                context
                                    .read<SelectionModel>()
                                    .updateTripDetails(
                                      dateRange: _selectedDateRange!,
                                      partySize: _partySize!,
                                    );

                                print(
                                  "선택된 여행지: $_selectedDestination, "
                                  "날짜: ${_selectedDateRange?.start.toIso8601String()} ~ ${_selectedDateRange?.end.toIso8601String()}, "
                                  "인원: $_partySize, "
                                  "원하는 느낌: ${_vibeController.text}",
                                );

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => LoadingPage(
                                          destination: _selectedDestination!,
                                          vibe: _vibeController.text,
                                          selectedDateRange: _selectedDateRange,
                                          partySize: _partySize,
                                        ),
                                  ),
                                );

                                if (!mounted) return;
                                if (result is String &&
                                    result.startsWith("Error:")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('여행지를 먼저 선택해주세요!'),
                                  ),
                                );
                              }
                            },
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            highlightColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            splashColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            fillColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.all(5.0),
                            constraints: const BoxConstraints.tightFor(
                              width: 120.0,
                              height: 53.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 25.0,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '검색',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
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
            ),
          ),
          // 추천 목록 오버레이
          if (_showDestinationSuggestions &&
              (_expandedCardIndex == 0 || _expandedCardIndex == -1))
            Positioned(
              // Positioned 위젯은 Stack 내에서 Context를 직접 참조하기 어려우므로,
              // MediaQuery를 사용하거나, LayoutBuilder를 통해 부모의 제약조건을 얻어와서
              // _textFieldLink의 글로벌 위치를 기반으로 오프셋을 계산해야 할 수 있습니다.
              // 여기서는 간단하게 _textFieldLink를 따르도록만 설정합니다.
              // 실제 정확한 위치를 위해서는 추가적인 위치 계산 로직이 필요할 수 있습니다.
              child: CompositedTransformFollower(
                link: _textFieldLink,
                showWhenUnlinked: false,
                offset: const Offset(0.0, 58.0), // TextField 아래로 위치 조정
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200.0,
                      // 여행지 카드의 현재 너비를 기준으로 설정 (주의: destCardWidth는 build 스코프 변수)
                      // 이 부분은 _textFieldLink RenderBox의 너비를 가져와 설정하는 것이 더 정확합니다.
                      // 지금은 단순화를 위해 고정값 또는 화면 너비 비율을 사용할 수 있습니다.
                      maxWidth: MediaQuery.of(context).size.width * 0.85, // 예시
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerLowest,
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
                          dense: true,
                          onTap: () {
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
                              _expandedCardIndex = 1; // 날짜 카드 확장
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
}
