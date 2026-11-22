// lib/Routes/app_routes.dart

class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // Auth
  static const String auth = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // User Screens
  static const String home = '/home';
  static const String heatmap = '/heatmap';
  static const String report = '/report';
  static const String reportList = '/report-list';
  static const String comment = '/comment';
  static const String profile = '/profile';

  // Admin Screens
  static const String adminHome = '/admin-home';
}