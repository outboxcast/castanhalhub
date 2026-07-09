import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/business_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/businesses/businesses_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/splash_screen.dart';
import 'services/onesignal_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CastanhalHubAdminApp());
}

class _AppStartup extends StatefulWidget {
  final Widget child;

  const _AppStartup({required this.child});

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Carregar variáveis de ambiente do arquivo .env
    await dotenv.load(fileName: 'assets/.env');

    // Inicializar Supabase
    await _initializeSupabase();

    // Inicializar OneSignal
    _initializeOneSignal();

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  Future<void> _initializeSupabase() async {
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
          'Credenciais do Supabase não encontradas. Verifique o arquivo .env.',
        );
      }

      await SupabaseService().initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      print('Erro ao inicializar Supabase: $e');
      rethrow;
    }
  }

  void _initializeOneSignal() {
    try {
      final appId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
      final restApiKey = dotenv.env['ONESIGNAL_REST_API_KEY'] ?? '';

      if (appId.isNotEmpty && restApiKey.isNotEmpty) {
        OneSignalService().initialize(appId: appId, restApiKey: restApiKey);
        print('OneSignal inicializado com sucesso.');
      } else {
        print(
          'Aviso: OneSignal não foi inicializado. Verifique o arquivo .env.',
        );
      }
    } catch (e) {
      print('Erro ao inicializar OneSignal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SplashScreen();
    }
    return widget.child;
  }
}

class CastanhalHubAdminApp extends StatelessWidget {
  const CastanhalHubAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Castanhal HUB Admin',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const _AppStartup(child: AuthGuard()),
      ),
    );
  }
}

/// Widget que protege as rotas baseado no estado de autenticação
class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const AdminDashboard();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// Dashboard administrativo com navegação entre telas
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildCurrentScreen());
  }

  Widget _buildCurrentScreen() {
    switch (_currentPageIndex) {
      case 0:
        return DashboardScreen(
          currentIndex: _currentPageIndex,
          onItemSelected: (index) {
            setState(() => _currentPageIndex = index);
          },
        );
      case 1:
        return BusinessesScreen(
          currentIndex: _currentPageIndex,
          onItemSelected: (index) {
            setState(() => _currentPageIndex = index);
          },
        );
      case 2:
        return NotificationsScreen(
          currentIndex: _currentPageIndex,
          onItemSelected: (index) {
            setState(() => _currentPageIndex = index);
          },
        );
      default:
        return DashboardScreen(
          currentIndex: _currentPageIndex,
          onItemSelected: (index) {
            setState(() => _currentPageIndex = index);
          },
        );
    }
  }
}
