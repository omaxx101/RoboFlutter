import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManualTab extends StatefulWidget {
  final String robotUrl;
  const ManualTab({super.key, required this.robotUrl});

  @override
  State<ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<ManualTab> {
  String status = "STOP";

  Future<void> send(String path) async {
    if (widget.robotUrl.isEmpty) return;
    try {
      await http.get(Uri.parse("${widget.robotUrl}$path"));
    } catch (_) {}
  }

  Future<void> fetchStatus() async {
    if (widget.robotUrl.isEmpty) return;
    try {
      final r = await http.get(Uri.parse("${widget.robotUrl}/status"));
      setState(() => status = r.body);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    // poll robot state (like webpage)
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      await fetchStatus();
      return mounted;
    });
  }

  Widget holdBtn(String label, String cmd) {
    return Listener(
      onPointerDown: (_) => send("/$cmd"),
      onPointerUp: (_) => send("/s"),
      onPointerCancel: (_) => send("/s"),
      child: Container(
        width: 90,
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(label, style: const TextStyle(fontSize: 30)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.robotUrl.isEmpty) {
      return const Center(child: Text("Not connected"));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("STATUS: $status",
            style: const TextStyle(fontSize: 18, color: Colors.white)),

        const SizedBox(height: 20),

        holdBtn("▲", "f"),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            holdBtn("◀", "l"),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => send("/s"),
              child: Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("STOP"),
              ),
            ),
            const SizedBox(width: 10),
            holdBtn("▶", "r"),
          ],
        ),

        const SizedBox(height: 10),
        holdBtn("▼", "b"),
      ],
    );
  }
}