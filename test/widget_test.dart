import 'package:flutter_test/flutter_test.dart';
import 'package:yusic/main.dart';

void main() {
  testWidgets('Yusic app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const YusicApp());
    expect(find.text('YUSIC'), findsOneWidget);
  });
}
