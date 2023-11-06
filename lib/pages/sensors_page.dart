// ignore_for_file: sort_child_properties_last, unused_local_variable, prefer_interpolation_to_compose_strings, prefer_const_constructors, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solarencrypt/pages/chat_page.dart';
import 'package:solarencrypt/pages/control_page.dart';
import 'package:solarencrypt/pages/radar_local_area_page.dart';
import 'package:solarencrypt/pages/welcome_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'home_page.dart';

class SensorsPage extends StatefulWidget {
  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  late MqttServerClient client;
  String receivedDataCPU = '0';
  String receivedDataVoltage = '0';
  String receivedDataCurrent = '0';
  String receivedDataRPM = '0';

  final List<ExpansionPanelItem> _expansionPanelItems = [
    ExpansionPanelItem(
      headerText: 'External panel 1',
      buttons: ['CPU', 'Voltage', 'Current', 'RPM'],
      isExpanded: false,
    ),
    ExpansionPanelItem(
      headerText: 'External panel 2',
      buttons: ['CPU', 'Voltage', 'Current', 'RPM'],
      isExpanded: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    client = MqttServerClient('test.mosquitto.org', '');
    connect();
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  void connect() async {
    client.logging(on: true);
    client.onConnected = onConnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .keepAliveFor(60)
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void onConnected() {
    client.subscribe('test/sensors/cpu', MqttQos.atMostOnce);
    client.subscribe('test/sensors/voltage', MqttQos.atMostOnce);
    client.subscribe('test/sensors/current', MqttQos.atMostOnce);
    client.subscribe('test/sensors/rpm', MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String newMessage =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final String topic = c[0].topic;

      setState(() {
        if (topic == 'test/sensors/cpu') {
          receivedDataCPU = newMessage;
        } else if (topic == 'test/sensors/voltage') {
          receivedDataVoltage = newMessage;
        } else if (topic == 'test/sensors/current') {
          receivedDataCurrent = newMessage;
        } else if (topic == 'test/sensors/rpm') {
          receivedDataRPM = newMessage;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors Page'),
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                'My panel data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildContainer('CPU', receivedDataCPU),
                  SizedBox(width: 20),
                  buildContainer('Voltage', receivedDataVoltage),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildContainer('Current', receivedDataCurrent),
                  SizedBox(width: 20),
                  buildContainer('RPM', receivedDataRPM),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Other panels sample data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _expansionPanelItems[index].isExpanded = !isExpanded;
                  });
                },
                children: _expansionPanelItems
                    .map<ExpansionPanel>((ExpansionPanelItem item) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            item.isExpanded = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(item.headerText),
                        ),
                      );
                    },
                    body: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: (item.buttons).map<Widget>((button) {
                          return buildSmallContainer(button, '0');
                        }).toList(),
                      ),
                    ),
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContainer(String title, String data) {
    return Container(
      width: 150,
      height: 80,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 223, 107, 30),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        '$title: $data',
        style: TextStyle(fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildSmallContainer(String title, String data) {
    String value = '';

    switch (title) {
      case 'CPU':
        value = '70.0*C';
        break;
      case 'Voltage':
        value = '5.0 V';
        break;
      case 'Current':
        value = '2.0 A';
        break;
      case 'RPM':
        value = '1000';
        break;
    }

    return Container(
      width: 80,
      height: 50,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 53, 52, 52),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        '$title: $value',
        style: TextStyle(fontSize: 14, color: Colors.white),
        textAlign: TextAlign.center,
      ),
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
}

class ExpansionPanelItem {
  final String headerText;
  final List<String> buttons;
  bool isExpanded;

  ExpansionPanelItem({
    required this.headerText,
    required this.buttons,
    this.isExpanded = false,
  });
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
              top: 24 + MediaQuery.of(context).padding.top,
              bottom: 24,
            ),
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(20.0),
          ),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  color: Color.fromARGB(255, 223, 107, 30),
                  child: ListTile(
                    leading: const Icon(Icons.workspaces_outline),
                    title: const Text('Sensors'),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SensorsPage()),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.control_camera),
                title: const Text('Control Panel'),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ControlPage()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.radar),
                title: const Text('Radar local area'),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RadarLocalAreaPage()),
                ),
              ),
            ],
          ),
        ),
      );
}
