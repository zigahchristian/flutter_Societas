import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:societas/screens/members/member_add.dart';
import 'package:societas/providers/member_provider.dart';

// Mock class
class MockMemberProvider extends Mock implements MemberProvider {}

void main() {
  late MockMemberProvider mockProvider;

  setUp(() {
    mockProvider = MockMemberProvider();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<MemberProvider>.value(
      value: mockProvider,
      child: const MaterialApp(home: MemberAddPage()),
    );
  }

  testWidgets('should show error on empty required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Submit without filling required fields
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Member'));
    await tester.pumpAndSettle();

    expect(find.text('First Name is required'), findsOneWidget);
    expect(find.text('Last Name is required'), findsOneWidget);
    expect(find.text('Membership Type is required'), findsOneWidget);
  });

  testWidgets('should show error on invalid email format', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Fill with invalid email
    await tester.enterText(find.bySemanticsLabel('Email'), 'invalid-email');

    // Submit
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Member'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email format'), findsOneWidget);
  });
}
