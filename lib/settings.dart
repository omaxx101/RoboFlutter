import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'robot.dart';

class SettingsTab extends StatefulWidget {
  final Function(Robot) onRobotAdded;
  final List<Robot> robots;

  const SettingsTab({
    super.key,
    required this.onRobotAdded,
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
        final existing = widget.robots
            .where((r) => r.url == url)
            .toList();

        if (existing.isNotEmpty) {
          // reconnect existing robot
          existing.first.online = true;
          existing.first.status = res.body;
        } else {
          widget.onRobotAdded(
            Robot(url: url, status: res.body, online: true),
          );
        }

        setState(() => status = "Connected to $url");
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
      await http
          .get(Uri.parse("${robot.url}/s"))
          .timeout(const Duration(seconds: 1));
    } catch (_) {}

    setState(() {
      robot.online = false;
      robot.status = "Disconnected";
      status = "Disconnected ${robot.url}";
    });
  }

  Future<void> reconnect(Robot robot) async {
    try {
      final res = await http
          .get(Uri.parse("${robot.url}/status"))
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        setState(() {
          robot.online = true;
          robot.status = res.body;
          status = "Reconnected ${robot.url}";
        });
      }
    } catch (_) {
      setState(() => status = "Reconnect failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(status),
          const SizedBox(height: 10),

          TextField(
            controller: ipCtrl,
            decoration: const InputDecoration(
              labelText: "Robot IP",
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: connect,
            child: const Text("Connect"),
          ),

          const Divider(height: 40),

          Text(
            "Robots Saved: ${widget.robots.length}",
            style: const TextStyle(fontSize: 18),
          ),

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
                      r.online
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                          r.online ? Colors.green : Colors.red,
                    ),
                    trailing: r.online
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => disconnect(r),
                            child: const Text("Disconnect"),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () => reconnect(r),
                            child: const Text("Reconnect"),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}