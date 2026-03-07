import 'package:flutter/material.dart';
import 'package:jidoapp/models/badge_model.dart';
import 'package:jidoapp/screens/badge_detail_screen.dart';

class BadgeCollectedScreen extends StatelessWidget {
  final Achievement achievement;

  const BadgeCollectedScreen({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 뱃지 카테고리별 색상
    Color categoryColor;
    switch (achievement.category) {
      case AchievementCategory.Country:
        categoryColor = Colors.teal;
        break;
      case AchievementCategory.City:
        categoryColor = Colors.orange;
        break;
      case AchievementCategory.Flight:
        categoryColor = Colors.blue;
        break;
      case AchievementCategory.Landmarks:
        categoryColor = Colors.purple;
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 20),
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(0, 10), blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // 상단 문구 (수정됨: 더 세련된 스타일 적용)
                Text(
                  "NEW BADGE UNLOCKED!",
                  style: TextStyle(
                    fontSize: 20, // 크기 키움
                    fontWeight: FontWeight.w900, // 두께를 더 굵게
                    color: categoryColor, // 카테고리 색상 적용하여 통일감 부여
                    letterSpacing: 1.5, // 자간을 넓혀 고급스러운 느낌
                    shadows: const [
                      Shadow(
                        color: Colors.black12,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 뱃지 이미지
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(color: categoryColor, width: 3),
                    image: DecorationImage(
                      image: AssetImage(achievement.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // 이름 및 설명
                Text(
                  achievement.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  achievement.description,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                // 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 알림 닫기
                      // 상세 화면으로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BadgeDetailScreen(achievement: achievement),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 닫기(X) 아이콘
          Positioned(
            right: 10,
            top: 30,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}