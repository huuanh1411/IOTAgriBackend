import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/app.dart';

void main() {
  testWidgets('AgriSenseApp khoi tao khong loi', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriSenseApp());
    expect(find.text('AgriSense'), findsOneWidget);
  });
}
