import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth/session_manager.dart';
import 'features/auth/auth_screen.dart';
import 'features/landlord_provider.dart';
import 'features/main_navigation_shell.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.instance.init();

  runApp(const LandLordApp());
}

class LandLordApp extends StatelessWidget {
  const LandLordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandlordProvider()..init()),
        ChangeNotifierProvider.value(value: SessionManager.instance),
      ],
      child: Consumer<SessionManager>(
        builder: (context, session, _) {
          return MaterialApp(
            title: 'LandLord Remastered',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: session.isDarkMode ? ThemeMode.dark : ThemeMode.system,
            home: session.isLoggedIn
                ? const MainNavigationShell()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}
