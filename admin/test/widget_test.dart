import 'package:flutter_test/flutter_test.dart';

import 'package:admin/main.dart';

void main() {
  testWidgets('admin app loads', (tester) async {
    await tester.pumpWidget(const CastanhalHubAdminApp());
    expect(find.byType(CastanhalHubAdminApp), findsOneWidget);
  });
}
