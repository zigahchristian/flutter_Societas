// test/widget/member_add_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/member.dart';
import 'package:societas/providers/member_provider.dart';
import 'package:societas/screens/members/member_add.dart';

class MockMemberProvider extends Mock implements MemberProvider {}

void main() {
  late MockMemberProvider mockMemberProvider;

  setUp(() {
    mockMemberProvider = MockMemberProvider();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<MemberProvider>.value(
        value: mockMemberProvider,
        child: const MemberAddPage(),
      ),
    );
  }

  group('MemberAddPage Widget Tests', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Add New Member'), findsOneWidget);
      expect(find.text('First Name*'), findsOneWidget);
      expect(find.text('Last Name*'), findsOneWidget);
      expect(find.text('Gender*'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows validation errors for required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Try to submit empty form
      await tester.tap(find.text('Add Member'));
      await tester.pump();

      expect(
        find.text('Required'),
        findsNWidgets(4),
      ); // First, Last, Gender, Membership Type
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid email
      await tester.enterText(find.bySemanticsLabel('Email'), 'invalid-email');
      await tester.tap(find.text('Add Member'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates date format', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid date
      await tester.enterText(
        find.bySemanticsLabel('Date of Birth (YYYY-MM-DD)'),
        'invalid-date',
      );
      await tester.tap(find.text('Add Member'));
      await tester.pump();

      expect(find.text('Invalid date format'), findsOneWidget);
    });

    testWidgets('creates member with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill required fields
      await tester.enterText(find.bySemanticsLabel('First Name*'), 'John');
      await tester.enterText(find.bySemanticsLabel('Last Name*'), 'Doe');
      await tester.tap(find.bySemanticsLabel('Gender*'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.bySemanticsLabel('Membership Type*'),
        'Premium',
      );

      // Fill optional fields
      await tester.enterText(
        find.bySemanticsLabel('Email'),
        'john@example.com',
      );
      await tester.enterText(
        find.bySemanticsLabel('Date of Birth (YYYY-MM-DD)'),
        '1990-01-01',
      );

      // Mock the provider response
      when(mockMemberProvider.addMember(any)).thenAnswer((_) => Future.value());

      // Submit form
      await tester.tap(find.text('Add Member'));
      await tester.pump();

      // Verify member was created with correct data
      final captured = verify(
        mockMemberProvider.addMember(captureAny),
      ).captured;
      final Member addedMember = captured[0] as Member;

      expect(addedMember.membername, 'John Doe');
      expect(addedMember.firstname, 'John');
      expect(addedMember.lastname, 'Doe');
      expect(addedMember.gender, 'Male');
      expect(addedMember.email, 'john@example.com');
      expect(addedMember.membershiptype, 'Premium');
      expect(addedMember.dateofbirth, DateTime(1990, 1, 1));
    });

    testWidgets('shows success message on successful submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill required fields
      await tester.enterText(find.bySemanticsLabel('First Name*'), 'Jane');
      await tester.enterText(find.bySemanticsLabel('Last Name*'), 'Smith');
      await tester.tap(find.bySemanticsLabel('Gender*'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.bySemanticsLabel('Membership Type*'),
        'Basic',
      );

      when(mockMemberProvider.addMember(any)).thenAnswer((_) => Future.value());

      await tester.tap(find.text('Add Member'));
      await tester.pump();

      expect(find.text('Member added successfully'), findsOneWidget);
    });

    testWidgets('shows error message on failed submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill required fields
      await tester.enterText(find.bySemanticsLabel('First Name*'), 'Jane');
      await tester.enterText(find.bySemanticsLabel('Last Name*'), 'Smith');
      await tester.tap(find.bySemanticsLabel('Gender*'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.bySemanticsLabel('Membership Type*'),
        'Basic',
      );

      when(
        mockMemberProvider.addMember(any),
      ).thenThrow(Exception('Database error'));

      await tester.tap(find.text('Add Member'));
      await tester.pump();

      expect(
        find.text('Failed to add member: Exception: Database error'),
        findsOneWidget,
      );
    });
  });
}
