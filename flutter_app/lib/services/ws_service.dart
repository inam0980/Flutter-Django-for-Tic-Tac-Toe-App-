import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';

/// Thin WebSocket helper. The auth token is sent as a query param
/// (Django Channels middleware reads it there — browsers can't set
/// headers on a WS handshake).
class WsConnection {
  final WebSocketChannel channel;
  WsConnection._(this.channel);

  static WsConnection connect(String path, String accessToken) {
    final uri = Uri.parse('${AppConfig.wsBaseUrl}$path?token=$accessToken');
    return WsConnection._(WebSocketChannel.connect(uri));
  }

  Stream<Map<String, dynamic>> get messages => channel.stream.map((raw) {
        if (raw is String) {
          return Map<String, dynamic>.from(jsonDecode(raw) as Map);
        }
        return <String, dynamic>{};
      });

  void send(Map<String, dynamic> data) {
    channel.sink.add(jsonEncode(data));
  }

  Future<void> close() async {
    await channel.sink.close();
  }
}
