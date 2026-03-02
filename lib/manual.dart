import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'robot.dart';

class ManualTab extends StatefulWidget {
  final List<Robot> robots;
  const ManualTab({super.key, required this.robots});

  @override
  State<ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<ManualTab> {
  int selectedIndex = 0;

  Robot? get robot =>
      widget.robots.isEmpty ? null : widget.robots[selectedIndex];

  Future<void> send(String path) async {
    if (robot == null) return;
    try {
      await http.get(Uri.parse("${robot!.url}$path"));
    } catch (_) {}
  }

  Future<void> fetchStatus() async {
    if (robot == null) return;
    try {
      final r = await http.get(Uri.parse("${robot!.url}/status"));
      setState(() => robot!.status = r.body);
    } catch (_) {
      setState(() => robot!.online = false);
    }
  }

  @override
  void initState() {
    super.initState();
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
    if (widget.robots.isEmpty) {
      return const Center(child: Text("No robots connected"));
    }

    return Row(
      children: [

        // LEFT PANEL → ROBOT SELECTOR
        Container(
          width: 200,
          color: Colors.black87,
          child: ListView.builder(
            itemCount: widget.robots.length,
            itemBuilder: (_, i) {
              final r = widget.robots[i];
              return ListTile(
                title: Text("Robot ${i + 1}"),
                subtitle: Text(r.url),
                selected: i == selectedIndex,
                onTap: () => setState(() => selectedIndex = i),
              );
            },
          ),
        ),

        // RIGHT PANEL → CONTROLS
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Controlling: ${robot!.url}",
                  style: const TextStyle(fontSize: 18)),

              const SizedBox(height: 10),

              Text("STATUS: ${robot!.status}",
                  style: const TextStyle(fontSize: 18)),

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
          ),
        ),
      ],
    );
  }
}