// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;

  static void connect() {
    socket = IO.io(
      'http://10.0.2.2:5000', // change if using real phone
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("Connected to WebSocket");
    });

    socket!.onDisconnect((_) {
      print(" Disconnected");
    });
  }

  static void listen(void Function(dynamic data) onUpdate) {
    socket!.on("staff-board-update", (data) {
      print(" Real-time update received");
      onUpdate(data);
    });
  }
}