class Robot {
  final String url;
  String status;
  bool online;

  Robot({required this.url, this.status = "UNKNOWN", this.online = true});
}
