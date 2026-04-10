import 'package:admin_process/screens/office_finder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigate draws a polyline route on the map', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OfficeFinderScreen(),
      ),
    );

    expect(find.byKey(const Key('office_route_polyline')), findsNothing);

    await tester.tap(find.byKey(const Key('navigate_button_1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('office_route_polyline')), findsOneWidget);
  });
}
