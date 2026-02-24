import 'package:flutter/material.dart';
import 'manual.dart';
import 'auto.dart';
import 'settings.dart';

const red = Colors.red;
const black = Colors.black;
const white = Colors.white;
const green = Colors.green;


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: black,
        appBarTheme: const AppBarTheme(
          backgroundColor: red,
          foregroundColor: black,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String robotUrl = ""; // ✅ SINGLE SOURCE OF TRUTH

  String get title => ["Home", "Manual", "Auto", "Settings"][_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            onStartPressed: () => setState(() => _currentIndex = 3),
          ),
          ManualTab(robotUrl: robotUrl),
          AutoTab(),
          SettingsTab(
            onConnected: (url) {
              setState(() {
                robotUrl = url;
                _currentIndex = 1;
              });
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: red,
        selectedItemColor: white,
        unselectedItemColor: white,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: "Manual"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "Auto"),
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: "Settings"),
        ],
      ),
    );
  }
}

// ---------------- HOME TAB ----------------
class HomeTab extends StatelessWidget {
  final VoidCallback onStartPressed;
  const HomeTab({super.key, required this.onStartPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text(
          "Robot Car Control",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onStartPressed,
          child: const Text("Start"),
        ),
      ]),
    );
  }
}
