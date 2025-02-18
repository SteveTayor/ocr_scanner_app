import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ocr_document_scanner_app/features/screens/home_page/home_page.dart';
import 'core/services/network.dart';
import 'features/screens/ocr_page/scan_document_screen.dart';
import 'features/widgets/no_network_widget.dart';
import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'OCR Scanner App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const ScanDocumentScreen(),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniVault OCR App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NetworkChecker _networkChecker = NetworkChecker();

  @override
  void initState() {
    super.initState();
    _checkInitialNetwork();
  }

  Future<void> _checkInitialNetwork() async {
    final hasInternet = await _networkChecker.hasInternetConnection();
    if (!hasInternet) {
      _navigateToNoNetwork();
    }
  }

  void _navigateToNoNetwork() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoNetworkWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _networkChecker.networkStatusStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data!) {
          // If network is lost, navigate to NoNetworkWidget
          Future.microtask(() => _navigateToNoNetwork());
        }
        return const Homepage();
        // return const ScanDocumentScreen();
      },
    );
  }
}
