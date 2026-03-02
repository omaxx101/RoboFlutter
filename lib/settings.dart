import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'robot.dart';

class SettingsTab extends StatefulWidget {
  final Function(Robot) onRobotAdded;
  final Function(Robot) onRobotRemoved;   // ⭐ NEW
  final List<Robot> robots;

  const SettingsTab({
    super.key,
    required this.onRobotAdded,
    required this.onRobotRemoved,
    required this.robots,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final ipCtrl = TextEditingController();
  String status = "Enter robot IP";

  Future<void> connect() async {
    final url = "http://${ipCtrl.text}";
    try {
      final res = await http
          .get(Uri.parse("$url/status"))
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        widget.onRobotAdded(Robot(url: url, status: res.body));
        setState(() => status = "Connected!");
        ipCtrl.clear();
      } else {
        setState(() => status = "Bad response");
      }
    } catch (_) {
      setState(() => status = "Connection failed");
    }
  }

  Future<void> disconnect(Robot robot) async {
    try {
      // tell robot to stop before disconnecting
      await http.get(Uri.parse("${robot.url}/s"))
          .timeout(const Duration(seconds: 1));
    } catch (_) {}

    widget.onRobotRemoved(robot);

    setState(() => status = "Disconnected ${robot.url}");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Text(status),
        const SizedBox(height: 10),

        TextField(
          controller: ipCtrl,
          decoration: const InputDecoration(labelText: "Robot IP"),
        ),

        const SizedBox(height: 10),

        ElevatedButton(onPressed: connect, child: const Text("Connect")),

        const Divider(height: 40),

        Text("Connected Robots: ${widget.robots.length}",
            style: const TextStyle(fontSize: 18)),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            itemCount: widget.robots.length,
            itemBuilder: (_, i) {
              final r = widget.robots[i];
              return Card(
                color: Colors.black54,
                child: ListTile(
                  title: Text(r.url),
                  subtitle: Text("Status: ${r.status}"),
                  leading: Icon(
                    r.online ? Icons.check_circle : Icons.error,
                    color: r.online ? Colors.green : Colors.red,
                  ),

                  // ⭐ REAL DISCONNECT BUTTON
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => disconnect(r),
                    child: const Text("Disconnect"),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}