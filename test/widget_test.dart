import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:formfield_presentation/main.dart';

void main() {
  testWidgets('empty form shows validation errors on submit', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FormFieldDemoApp());
    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please choose a track'), findsOneWidget);
    expect(find.text('Please rate your Flutter experience'), findsOneWidget);
    expect(find.text('You must accept the terms to continue'), findsOneWidget);
  });
}
