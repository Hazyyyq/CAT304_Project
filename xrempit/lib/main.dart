import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import 'firebase_options.dart';
import 'Admins/admin_home.dart';
import 'Routes/app_routes.dart';
import 'Services/auth_service.dart';
import 'Services/firestore_service.dart';
import 'Pages/user_profiles_screen.dart';
import 'Pages/report_screen.dart';
import 'Pages/report_list_screen.dart';
import 'Pages/heatmap_screen.dart';

//import 'Admins/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    firestoreDb.settings = const Settings(
      webExperimentalForceLongPolling: true,
      webExperimentalAutoDetectLongPolling: false,
    );
  }
  runApp(const XRempitApp());
}

class XRempitApp extends StatelessWidget {
  const XRempitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XRempit',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: AppRoutes.auth,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return MaterialPageRoute(
          builder: (_) => AuthPage(),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.heatmap:
        return MaterialPageRoute(
          builder: (_) => HeatmapScreen(),
        );

      case AppRoutes.report:
        return MaterialPageRoute(
          builder: (_) => ReportScreen(),
        );

      case AppRoutes.reportList:
        return MaterialPageRoute(
          builder: (_) => ReportListScreen(),
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => UserProfilesScreen(),
        );

      case AppRoutes.adminHome:
        return MaterialPageRoute(
          builder: (_) => AdminHomePage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => AuthPage(),
        );
    }
  }
}

// ================= Sign out =================

void signOut() {
  FirebaseAuth.instance.signOut();
}

// ================= Home Screen =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  List<LatLng> userPoints = [];

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await firestoreDb
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;
        if (doc.exists) {
          setState(() {
            userName = doc.data()?['name'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    debugPrint("UserProfile button pressed");
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                  icon: const Icon(Icons.account_circle_sharp, size: 30),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.4,
                  ),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: firestoreDb
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Hello, ...',
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text(
                          'Hello, User',
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      final userData = snapshot.data!.data() as Map<String, dynamic>;
                      final username = userData['name'] ?? 'User';
                      return Text(
                        'Hello, $username',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'X',
                    style: TextStyle(color: Color(0xFFFF0000)),
                  ),
                  TextSpan(text: 'Rempit'),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Sign Out"),
                  content: const Text("Are you sure you want to sign out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Sign Out"),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );
                navigator.pushNamedAndRemoveUntil(
                  AppRoutes.auth,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: HeatmapScreen(),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                          shape: const CircleBorder(),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.reportList);
                        },
                        child: const Icon(Icons.article, color: Colors.deepPurple, size: 25),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.report);
                        },
                        icon: const Icon(Icons.report),
                        label: const Text('Report Incident'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}