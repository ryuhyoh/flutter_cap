// lib/widgets/trip_basket_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_locallens/selection_model.dart';
import 'package:flutter_locallens/selection_review_page.dart'; // 곧 만들 페이지
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class TripBasketIcon extends StatelessWidget {
  const TripBasketIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // SelectionModel의 변경사항을 감지
    final selectionModel = context.watch<SelectionModel>();
    final int itemCount = selectionModel.selectedItems.length;

    return badges.Badge(
      // 아이템이 있을 때만 뱃지(숫자)를 표시
      showBadge: itemCount > 0,
      badgeContent: Text(
        itemCount.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      position: badges.BadgePosition.topEnd(top: 0, end: 3),
      child: IconButton(
        icon: const Icon(Icons.shopping_basket_outlined),
        onPressed: () {
          // 아이콘 클릭 시 '여행 바구니' 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectionReviewPage(),
            ),
          );
        },
      ),
    );
  }
}
