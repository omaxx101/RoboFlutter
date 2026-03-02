import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsTab extends StatefulWidget {
  final Function(String) onConnected;
  const SettingsTab({super.key, required this.onConnected});

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
          .get(Uri.parse("$url/ping"))
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        widget.onConnected(url);
      } else {
        setState(() => status = "Bad response");
      }
    } catch (_) {
      setState(() => status = "Connection failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(status),
        const SizedBox(height: 20),
        TextField(
          controller: ipCtrl,
          decoration: const InputDecoration(labelText: "Robot IP"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: connect, child: const Text("Connect")),
      ]),
    );
  }
}