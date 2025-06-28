import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societas/main_tab_page.dart';
import 'package:societas/providers/attendance_provider.dart';
import 'package:societas/providers/payment_provider.dart';
import 'package:societas/providers/theme_provider.dart';
import 'package:societas/providers/turnout_provider.dart';
import 'services/database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:societas/providers/member_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "../.env");
  final String databaseUrl = dotenv.env['DATABASE_URL'] ?? '';
  final DatabaseService dbService = DatabaseService(databaseUrl: databaseUrl);

  await dbService.initialize();
  print("Passed DB Connect & Tables Created");
  // You can now use dbService.fetchMembers() or dbService.addMember()
  // For example, when you need to load data for MemberDetailPage:
  // List<Map<String, dynamic>> members = await dbService.fetchMembers();
  // Member member = Member.fromMap(members[0]); // Convert map to Member object

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => TurnoutProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),

        Provider.value(value: dbService),
      ],
      child: const Societas(),
    ),
  );
}

class Societas extends StatelessWidget {
  const Societas({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Membership Manager',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeService.themeMode,
      home: MainTabPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
