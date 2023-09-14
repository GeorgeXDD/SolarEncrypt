// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, empty_constructor_bodies

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:solarencrypt/pages/sensors_page.dart';

import 'welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late MqttService mqttService;

  // @override
  // void initState() {
  //   super.initState();
  //   final MqttServerClient client =
  //       MqttServerClient('localhost', ''); // Use MqttServerClient
  //   client.port = 1883; // Port number
  //   mqttService = MqttService(client: client, topic: 'sensor_data');
  //   mqttService.connect();
  // }

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Color.fromARGB(255, 223, 107, 30),
      ),
      drawer: NavigationDrawer(user: user),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.email}!'),
            SizedBox(height: 20),
            // StreamBuilder<String>(
            //   stream: mqttService
            //       .mqttDataStream, // Replace with your MQTT data stream
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       print('Received data: ${snapshot.data}');
            //       Map<String, dynamic> data = jsonDecode(snapshot.data!);
            //       temperature = data['temperature'].toString();
            //       humidity = data['humidity'].toString();

            //       return Column(
            //         children: [
            //           Text('Temperature: $temperature°C'),
            //           Text('Humidity: $humidity%'),
            //         ],
            //       );
            //     } else {
            //       return Text('Waiting for data...');
            //     }
            //   },
            // ),
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
      color: Color.fromARGB(255, 53, 52, 52),
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
                    backgroundImage: NetworkImage(
                        'https://img.freepik.com/free-photo/waist-up-portrait-handsome-serious-unshaven-male-keeps-hands-together-dressed-dark-blue-shirt-has-talk-with-interlocutor-stands-against-white-wall-self-confident-man-freelancer_273609-16320.jpg'),
                  ),
                  SizedBox(height: 20),
                  FutureBuilder<String?>(
                    future: fetchUsername(),
                    builder: (context, snapshot) {
                      String welcomeText = snapshot.data ?? 'Welcome user!';

                      return Text(
                        welcomeText,
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      );
                    },
                  ),
                  SizedBox(height: 5),
                  Text(
                    user.email!,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  MaterialButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                      );
                    },
                    color: Color.fromARGB(255, 223, 107, 30),
                    child: Text('Sign Out'),
                  )
                ],
              ))));
  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Chat'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
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
            ListTile(
              leading: const Icon(Icons.control_camera),
              title: const Text('Control Panel'),
              onTap: () {},
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
