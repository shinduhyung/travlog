import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jidoapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 새 루트 위젯으로 변경
    await tester.pumpWidget(const JidoRoot());

    // 여기서부터는 네가 원하는 대로 검증 로직 작성
    // 예시는 카운터용이라 지금 앱이랑 안 맞을 가능성이 큼
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
