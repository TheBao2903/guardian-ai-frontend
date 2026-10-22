class ServerAudioAlert {
  const ServerAudioAlert(
      {required this.id,
      required this.status,
      required this.deadline,
      required this.serverTime,
      this.sessionId,
      this.deliveryStatus = 'NOT_STARTED',
      this.total = 0,
      this.sent = 0,
      this.failed = 0});
  final String id, status, deliveryStatus;
  final DateTime deadline, serverTime;
  final String? sessionId;
  final int total, sent, failed;

  factory ServerAudioAlert.fromJson(Map<dynamic, dynamic> json) {
    final delivery = json['delivery'] as Map<dynamic, dynamic>? ?? {};
    return ServerAudioAlert(
        id: json['alert_id'] as String,
        status: json['status'] as String,
        deadline: DateTime.parse(json['deadline_at'] as String),
        serverTime: DateTime.parse(json['server_time'] as String),
        sessionId: json['emergency_session_id'] as String?,
        deliveryStatus: delivery['status'] as String? ?? 'NOT_STARTED',
        total: (delivery['total'] as num?)?.toInt() ?? 0,
        sent: (delivery['sent'] as num?)?.toInt() ?? 0,
        failed: (delivery['failed'] as num?)?.toInt() ?? 0);
  }
}
