// lib/models/selection_model.dart
import 'package:flutter/material.dart';

class SelectionModel extends ChangeNotifier {
  // Key: contents_id (String), Value: 해당 장소의 전체 데이터 (Map)
  final Map<String, Map<String, dynamic>> _selectedItems = {};

  // [추가] 날짜와 인원 정보를 저장할 변수
  DateTimeRange? _dateRange;
  int? _partySize;

  // 외부에서 직접 수정하지 못하도록 getter를 제공
  Map<String, Map<String, dynamic>> get selectedItems => _selectedItems;

  // [추가] 날짜와 인원 정보 getter
  DateTimeRange? get dateRange => _dateRange;
  int? get partySize => _partySize;

  // [추가] 날짜와 인원 정보를 업데이트하는 메소드
  void updateTripDetails({
    required DateTimeRange dateRange,
    required int partySize,
  }) {
    _dateRange = dateRange;
    _partySize = partySize;
    // 이 정보는 UI를 즉시 변경할 필요가 없을 수도 있으므로 notifyListeners()는 선택사항입니다.
    // 하지만 일관성을 위해 호출해주는 것이 좋습니다.
    notifyListeners();
  }

  bool contains(String placeId) {
    return _selectedItems.containsKey(placeId);
  }

  void add(Map<String, dynamic> place) {
    final String placeId = (place['contents_id'] as int?)?.toString() ?? '';
    if (placeId.isNotEmpty) {
      _selectedItems[placeId] = place;
      notifyListeners();
    }
  }

  void remove(String placeId) {
    if (placeId.isNotEmpty) {
      _selectedItems.remove(placeId);
      notifyListeners();
    }
  }

  // [수정] clear 메소드가 모든 정보를 초기화하도록 변경
  void clear() {
    _selectedItems.clear();
    _dateRange = null;
    _partySize = null;
    notifyListeners();
  }
}
