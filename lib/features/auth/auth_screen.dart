import 'package:flutter/material.dart';
import '../../core/auth/session_manager.dart';
import '../../ui/theme/app_theme.dart';
import '../main_navigation_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _demoLogin() async {
    setState(() => _isLoading = true);
    await SessionManager.instance.loginDemoLandlord();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    }
  }

  void _customLogin() async {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();
    if (user.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter username and password');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await SessionManager.instance.loginCustom(user, pass);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Hero Badge
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'LandLord',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remastered • Standalone Edition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Quick Demo Login Button (Fintech Hero CTA)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF6366F1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _demoLogin,
                      icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                      label: const Text(
                        'Quick Demo Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR CUSTOM CREDENTIALS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Custom Login Inputs
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username or Email',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppColors.darkCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppColors.darkCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.coral, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _customLogin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Log In with Credentials',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),

                  if (_isLoading) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
