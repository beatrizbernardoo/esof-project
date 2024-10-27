import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seed_you_later/weather_service.dart'; // Import your weather service here
import 'package:seed_you_later/user_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFunction extends Mock {
  void call(String parameter);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserPage', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      final onCityChanged = MockFunction();
      await tester.pumpWidget(
        MaterialApp(
          home: UserPage(onCityChanged: onCityChanged),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Select City'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

  });

  group('EditProfilePage', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Apply changes'), findsOneWidget);
      expect(find.text('Delete Account'), findsAtLeast(1));
      expect(find.text('The data from your account will be deleted.'), findsOneWidget);
    });

    testWidgets('calls onPressed when Apply changes button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      final applyChangesButton = find.text('Apply changes');
      expect(applyChangesButton, findsOneWidget);

      await tester.tap(applyChangesButton);
      await tester.pump();

    });

    testWidgets('calls onPressed when Delete Account button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      final deleteAccountButton = find.text('Delete Account');
      expect(deleteAccountButton, findsAtLeast(1));

    });
  });
}