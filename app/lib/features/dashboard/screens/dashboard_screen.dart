import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/models/user_model.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../auth/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  late UserModel? _currentUser;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user ?? _authService.getLocalUser();
  }

  Future<void> _handleLogout() async {
    setState(() => _loggingOut = true);
    await _authService.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final user = _currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ShadBadge(
                    child: const Text('ACTIVE SESSION'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // User Profile Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Row(
                  children: [
                    // Avatar Initials
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          (user?.firstName.isNotEmpty ?? false)
                              ? user!.firstName[0].toUpperCase()
                              : 'K',
                          style: TextStyle(
                            color: theme.colorScheme.primaryForeground,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null
                                ? 'Hello, ${user.fullName}'
                                : 'Welcome to Kin',
                            style: theme.textTheme.h4.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.muted.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Overview note
              Text(
                'Ready for bills & deadlines',
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account is secured. Bills, household sharing, and upcoming reminders will show here.',
                style: theme.textTheme.muted.copyWith(fontSize: 14),
              ),

              const Spacer(),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ShadButton.outline(
                  onPressed: _loggingOut ? null : _handleLogout,
                  child: _loggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.logOut, size: 16),
                            SizedBox(width: 8),
                            Text('Sign out'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
