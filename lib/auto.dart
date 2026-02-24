import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class AutoTab extends StatelessWidget {
  const AutoTab({super.key});

  Future<void> sendCommand(String cmd) async {
    await http.get(Uri.parse("http://192.168.1.50:5000/auto?command=$cmd"));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Automatic Mode",
            style: TextStyle(color: white, fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: green),
            onPressed: () => sendCommand("auto_on"),
            child: const Text("ENABLE AUTO"),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: red),
            onPressed: () => sendCommand("auto_off"),
            child: const Text("DISABLE AUTO"),
          ),
        ],
      ),
    );
  }
}
