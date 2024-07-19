// import 'package:pusher_client/pusher_client.dart';
//
// class PusherService {
//   late PusherClient _pusher;
//   late Channel _channel;
//   final String _appKey =
//       '1ae635fc4ca9f011e201'; // Replace with your Pusher app key
//   final String _cluster = 'ap1'; // Replace with your Pusher cluster
//
//   PusherService() {
//     _initializePusher();
//   }
//
//   void _initializePusher() {
//     final PusherOptions options = PusherOptions(
//       cluster: _cluster,
//       encrypted: true,
//     );
//
//     _pusher = PusherClient(
//       _appKey,
//       options,
//       enableLogging: false,
//       autoConnect: true,
//     );
//
//
//     _pusher.connect();
//
//     _channel = _pusher.subscribe('orders');
//
//     _channel.bind('App\\Events\\SendPusherMessage', (event) {
//       _handleMessage("alenovan");
//     });
//   }
//
//   void _handleMessage(String message) {
//     // Handle incoming messages
//     print("Handling message: $message");
//   }
//
//   void disconnect() {
//     _pusher.disconnect();
//   }
// }
