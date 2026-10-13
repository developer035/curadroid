import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curadroid/features/library/library_screen.dart';

void main() {
  testWidgets('LibraryScreen renders without exception', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Exercise Library'), findsOneWidget);
  });
}
