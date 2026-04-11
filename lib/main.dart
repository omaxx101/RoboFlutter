import 'package:flutter/material.dart';
import 'manual.dart';
import 'auto.dart';
import 'settings.dart';
import 'robot.dart';

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

  final List<Robot> robots = [];

  String get title => ["Home", "Manual", "Auto", "Settings"][_currentIndex];

  void addRobot(Robot robot) {
    setState(() {
      robots.add(robot);
    });
  }

  void removeRobot(Robot robot) {
    setState(() {
      robots.remove(robot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            onGoToSettings: () {
              setState(() {
                _currentIndex = 3;
              });
            },
          ),

          ManualTab(robots: robots),

          AutoTab(robots: robots),

          SettingsTab(
            robots: robots,
            onRobotAdded: addRobot,
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: red,
        selectedItemColor: white,
        unselectedItemColor:white,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: "Manual"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "Auto"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

//
// ---------------- HOME TAB ----------------
//

class HomeTab extends StatelessWidget {
  final VoidCallback onGoToSettings;

  const HomeTab({super.key, required this.onGoToSettings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Robot Swarm Control System",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // 🔥 SIDE BY SIDE SECTIONS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Manual Explanation
              Expanded(
                child: Card(
                  color: Colors.black54,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.gamepad, size: 50, color: Colors.red),
                        SizedBox(height: 15),
                        Text(
                          "Manual Mode",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Directly control the robot in real-time. "
                          "Send movement commands, steer direction, "
                          "and manually operate the system.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Auto Explanation
              Expanded(
                child: Card(
                  color: Colors.black54,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.smart_toy, size: 50, color: Colors.red),
                        SizedBox(height: 15),
                        Text(
                          "Autonomous Mode",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Allow the robot to operate automatically. "
                          "Run pre-programmed behaviors, swarm logic, "
                          "and obstacle avoidance systems.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          const Text(
            "To connect to a robot, go to the Settings page.",
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}