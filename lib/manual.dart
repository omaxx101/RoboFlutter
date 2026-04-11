import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'robot.dart';

class ManualTab extends StatefulWidget {
  final List<Robot> robots;
  const ManualTab({super.key, required this.robots});

  @override
  State<ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<ManualTab> {
  int selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();

  bool useKeyboard = true;

  Robot? get robot =>
      widget.robots.isEmpty ? null : widget.robots[selectedIndex];

  Future<void> send(String path) async {
    if (robot == null || !robot!.online) return;
    try {
      await http.get(Uri.parse("${robot!.url}$path"));
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  // KEYBOARD CONTROL
  void _handleKey(RawKeyEvent event) {
    if (!useKeyboard) return;

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey.keyLabel.toLowerCase() == 'w') {
        send("/f");
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey.keyLabel.toLowerCase() == 's') {
        send("/b");
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey.keyLabel.toLowerCase() == 'a') {
        send("/l");
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey.keyLabel.toLowerCase() == 'd') {
        send("/r");
      }
      if (event.logicalKey == LogicalKeyboardKey.space) {
        send("/s");
      }
    }

    if (event is RawKeyUpEvent) {
      send("/s");
    }
  }

  Widget holdBtn(String label, String cmd) {
    return Listener(
      onPointerDown: (_) => send("/$cmd"),
      onPointerUp: (_) => send("/s"),
      onPointerCancel: (_) => send("/s"),
      child: Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(label, style: const TextStyle(fontSize: 32)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKey,
      child: Row(
        children: [
          // LEFT SIDEBAR
          Container(
            width: 260,
            padding: const EdgeInsets.all(20),
            color: Colors.black87,
            child: widget.robots.isEmpty
                ? const Center(
                    child: Text(
                      "No Robot Connected",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Robot Info",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text("IP: ${robot!.url}"),
                      const SizedBox(height: 10),
                      Text("Status: ${robot!.status}"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            robot!.online
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: robot!.online
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(robot!.online ? "ONLINE" : "OFFLINE"),
                        ],
                      ),
                    ],
                  ),
          ),

          // RIGHT SIDE
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 🔥 TOGGLE SWITCH
                ToggleButtons(
                  isSelected: [useKeyboard, !useKeyboard],
                  onPressed: (index) {
                    setState(() {
                      useKeyboard = index == 0;
                      _focusNode.requestFocus();
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Keyboard"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Mouse"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔥 ALWAYS SHOW CONTROLS
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        holdBtn("▲", "f"),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            holdBtn("◀", "l"),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => send("/s"),
                              child: Container(
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Text("STOP"),
                              ),
                            ),
                            const SizedBox(width: 15),
                            holdBtn("▶", "r"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        holdBtn("▼", "b"),

                        const SizedBox(height: 30),

                        const Text(
                          "Keyboard Controls:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text("WSAD or Arrow Keys to Move  "),
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}