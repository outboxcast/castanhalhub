import 'package:flutter_test/flutter_test.dart';

import 'package:castanhal_hub/main.dart';

void main() {
  testWidgets('app shows the Castanhal Hub home screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Castanhal Hub'), findsOneWidget);
  });
}
