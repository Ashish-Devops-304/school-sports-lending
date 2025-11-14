import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_sports_lending/providers/user_provider.dart';
import 'package:school_sports_lending/screens/login_screen.dart';
import 'package:school_sports_lending/screens/register_screen.dart';
import 'package:school_sports_lending/screens/home_screen.dart';
import 'package:school_sports_lending/screens/loan_list_screen.dart';
import 'package:school_sports_lending/screens/add_loan_screen.dart';
import 'package:school_sports_lending/screens/sports_item_list_screen.dart';
import 'package:school_sports_lending/screens/add_sports_item_screen.dart';


const keyApplicationId = 'ziCuCbYm5081Ts5h7jkDDRMCX3FsLQcfedoqtrOW';
const keyClientKey = 'OOgOhb7oemww9MgAZYiBZ6IBOYSETtK6Xs2Ak8TJ';
const keyParseServerUrl = 'https://parseapi.back4app.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
    debug: true,
  );

  runApp(
    // Set up your UserProvider so the whole app can access it
    ChangeNotifierProvider(
      create: (context) => UserProvider()..loadCurrentUser(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Sports Lending',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define all your app's routes
      routes: {
        '/': (context) => const AuthWrapper(), // Start with the wrapper
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/loans': (context) => const LoanListScreen(),
        '/add_loan': (context) => const AddLoanScreen(),
        '/sports_items': (context) => const SportsItemListScreen(),
        '/add_item': (context) => const AddSportsItemScreen(),
      },
      initialRoute: '/',
    );
  }
}

// New widget checks if the user is logged in
// and sends them to the right screen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the UserProvider for changes
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}