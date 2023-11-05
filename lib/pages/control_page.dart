// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:solarencrypt/pages/home_page.dart';
import 'package:solarencrypt/pages/sensors_page.dart';
import 'package:solarencrypt/pages/welcome_page.dart';
import 'package:typed_data/src/typed_buffer.dart';

import 'chat_page.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key}) : super(key: key);

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final MqttServerClient client =
      MqttServerClient('test.mosquitto.org', 'your_client_id');
  final String topic = 'solar/current';
  final user = FirebaseAuth.instance.currentUser!;
  bool isManualMode = true;

  @override
  void initState() {
    super.initState();
    setupMqtt();
  }

  Future<void> setupMqtt() async {
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('your_client_id')
        .startClean()
        .keepAliveFor(60)
        .withWillTopic('will-topic')
        .withWillMessage('Will message')
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect();
      client.subscribe(topic, MqttQos.atLeastOnce);
    } catch (e) {
      print('Exception: $e');
    }
  }

  void publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    final Uint8List payload = Uint8List.fromList(builder.payload ?? <int>[]);
    final Uint8Buffer buffer = Uint8Buffer();
    buffer.addAll(payload);

    client.publishMessage(topic, MqttQos.atLeastOnce, buffer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel'),
        backgroundColor: const Color.fromARGB(255, 223, 107, 30),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)),
        ),
        elevation: 0.00,
      ),
      drawer: NavigationDrawer(user: user),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isManualMode = !isManualMode;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 223, 107, 30),
                minimumSize: Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(isManualMode
                  ? 'Switch to Automatic Mode'
                  : 'Switch to Manual Mode'),
            ),
            SizedBox(height: 30),
            Visibility(
              visible: isManualMode,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          publishMessage('W');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 223, 107, 30),
                          minimumSize: Size(100, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Icon(Icons.undo),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          publishMessage('S');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 223, 107, 30),
                          minimumSize: Size(100, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Icon(Icons.redo),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          publishMessage('A');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 223, 107, 30),
                          minimumSize: Size(100, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Icon(Icons.rotate_left),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          publishMessage('D');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 223, 107, 30),
                          minimumSize: Size(100, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Icon(Icons.rotate_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  final User user;
  const NavigationDrawer({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeader(context), buildMenuItems(context)],
      )),
    );
  }

  Future<String?> fetchUsername() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['username'];
    }

    return null;
  }

  Widget buildHeader(BuildContext context) => Material(
        color: const Color.fromARGB(255, 53, 52, 52),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20.0),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.only(
                top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  // backgroundImage: NetworkImage(
                  //     'https://img.freepik.com/free-photo/waist-up-portrait-handsome-serious-unshaven-male-keeps-hands-together-dressed-dark-blue-shirt-has-talk-with-interlocutor-stands-against-white-wall-self-confident-man-freelancer_273609-16320.jpg'),
                  backgroundImage: ExactAssetImage('assets/logo1.png'),
                  backgroundColor: Color.fromARGB(255, 53, 52, 52),
                ),
                const SizedBox(height: 20),
                FutureBuilder<String?>(
                  future: fetchUsername(),
                  builder: (context, snapshot) {
                    String welcomeText = snapshot.data ?? 'Welcome user!';

                    return Text(
                      welcomeText,
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Text(
                  user.email!,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: MaterialButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomePage()),
                      );
                    },
                    color: const Color.fromARGB(255, 223, 107, 30),
                    child: const Text('Sign Out'),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Chat'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.workspaces_outline),
              title: const Text('Sensors'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SensorsPage()),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                color: const Color.fromARGB(255, 223, 107, 30),
                child: ListTile(
                  leading: const Icon(Icons.control_camera),
                  title: const Text('Control Panel'),
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ControlPage()),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.radar),
              title: const Text('Radar local area'),
              onTap: () {},
            ),
          ],
        ),
      );
}
