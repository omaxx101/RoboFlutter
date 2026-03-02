import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'robot.dart';

class AutoTab extends StatefulWidget {
  final List<Robot> robots;

  const AutoTab({super.key, required this.robots});

  @override
  State<AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends State<AutoTab> {
  final xCtrl = TextEditingController(text: "200");
  final yCtrl = TextEditingController(text: "100");

  final Map<String, Offset> positions = {};
  final Map<String, String> commands = {};

  bool autoEnabled = false;

  // ---------------- SEND TARGET ----------------
  Future<void> sendTarget() async {
    final x = xCtrl.text;
    final y = yCtrl.text;

    for (final r in widget.robots) {
      try {
        await http.get(Uri.parse("${r.url}/target?x=$x&y=$y"));
      } catch (_) {}
    }

    setState(() => autoEnabled = true);
  }

  // ---------------- STOP AUTO ----------------
  Future<void> disableAuto() async {
    for (final r in widget.robots) {
      try {
        await http.get(Uri.parse("${r.url}/s"));
      } catch (_) {}
    }

    setState(() => autoEnabled = false);
  }

  // ---------------- FETCH ROBOT STATES ----------------
  Future<void> fetchStates() async {
    for (final r in widget.robots) {
      try {
        final res = await http.get(Uri.parse("${r.url}/state"));
        final parts = res.body.split("|");

        if (parts.length >= 4) {
          final id = parts[0];
          final x = double.tryParse(parts[1]) ?? 0;
          final y = double.tryParse(parts[2]) ?? 0;
          final cmd = parts[3];

          positions[id] = Offset(x, y);
          commands[id] = cmd;

          r.online = true;
        }
      } catch (_) {
        r.online = false;
      }
    }

    if (mounted) setState(() {});
  }

  // ---------------- POLLING LOOP ----------------
  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      await fetchStates();
      return mounted;
    });
  }

  // ---------------- MAP VIEW ----------------
  Widget buildMap() {
    return Container(
      height: 300,
      color: Colors.black,
      child: CustomPaint(
        painter: MapPainter(positions),
        child: const Center(
          child: Text("Room Map", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // ---------------- ROBOT LIST ----------------
  Widget buildRobotList() {
    return Column(
      children: widget.robots.map((r) {
        final id = r.url;
        final pos = positions[id] ?? const Offset(0, 0);
        final cmd = commands[id] ?? "UNKNOWN";

        return ListTile(
          title: Text(r.url),
          subtitle: Text("X: ${pos.dx.toStringAsFixed(1)}  Y: ${pos.dy.toStringAsFixed(1)}"),
          trailing: Text(cmd),
          leading: Icon(
            r.online ? Icons.circle : Icons.circle_outlined,
            color: r.online ? Colors.green : Colors.red,
          ),
        );
      }).toList(),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (widget.robots.isEmpty) {
      return const Center(child: Text("No robots connected"));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Swarm Auto Control", style: TextStyle(fontSize: 22)),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: xCtrl,
                  decoration: const InputDecoration(labelText: "Target X"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: yCtrl,
                  decoration: const InputDecoration(labelText: "Target Y"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendTarget,
                  child: const Text("SEND TARGET"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: disableAuto,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("STOP AUTO"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          buildMap(),

          const SizedBox(height: 20),

          Expanded(child: SingleChildScrollView(child: buildRobotList())),
        ],
      ),
    );
  }
}

// ================= MAP PAINTER =================
class MapPainter extends CustomPainter {
  final Map<String, Offset> positions;

  MapPainter(this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in positions.values) {
      final x = (p.dx / 300) * size.width;
      final y = (p.dy / 300) * size.height;

      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}