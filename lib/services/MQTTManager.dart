import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'MQTTAppState.dart';

class MQTTManager {
  final List<MqttServerClient> _clients = [];
  final List<String> _topics = [];
  final MQTTAppState _currentState;
  final String _host = 'test.mosquitto.org';

  MQTTManager({required MQTTAppState state}) : _currentState = state;

  void initializeMQTTClient(
      {required String topic, required String identifier}) {
    final client = MqttServerClient(_host, identifier);
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = () => onDisconnected(client);
    client.secure = false;
    client.logging(on: true);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(identifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    _clients.add(client);
    _topics.add(topic);

    client.onConnected = () {
      _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    };

    client.onDisconnected = () {
      onDisconnected(client);
    };
  }

  Future<void> connectAll() async {
    for (var i = 0; i < _clients.length; i++) {
      final client = _clients[i];
      final topic = _topics[i];
      try {
        await client.connect();
        _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
        client.subscribe(topic, MqttQos.atLeastOnce);
        client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
          final recMess = c![0].payload as MqttPublishMessage;
          final pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          _currentState.setReceivedText(pt);
          print(
              'Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
          print('');
        });
      } on Exception catch (e) {
        print('Client exception - $e');
        disconnectAll();
      }
    }
  }

  void disconnectAll() {
    for (var client in _clients) {
      client.disconnect();
    }
  }

  void onDisconnected(MqttServerClient client) {
    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }
}
