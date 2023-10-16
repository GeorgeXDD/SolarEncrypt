// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solarencrypt/pages/welcome_page.dart';

import '../services/MQTTAppState.dart';
import '../services/MQTTManager.dart';
import 'home_page.dart';

class SensorsPage extends StatefulWidget {
  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  late MQTTAppState currentAppState;
  List<MQTTManager> managers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _disconnect();
    _hostTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sensors Page'),
        backgroundColor: Color.fromARGB(255, 223, 107, 30),
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
      body: ListView(
        children: <Widget>[
          // _buildConnectionStateText(
          //     _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
          _buildEditableColumn(),
          _buildScrollableTextWith(currentAppState.getHistoryText),
        ],
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

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          _buildTextFieldWith(
              _topicTextController,
              'Enter a topic to subscribe or listen',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildConnectionButtons(currentAppState.getAppConnectionState),
        ],
      ),
    );
  }

  Widget _buildConnectionButtons(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlueAccent,
            ),
            child: Text(state == MQTTAppConnectionState.disconnected
                ? 'Connect'
                : 'Connecting...'),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.redAccent,
            ),
            child: const Text('Disconnect'),
            onPressed:
                state == MQTTAppConnectionState.connecting ? _disconnect : null,
          ),
        ),
      ],
    );
  }

  // Widget _buildConnectionStateText(String status) {
  //   return Row(
  //     children: <Widget>[
  //       Expanded(
  //         child: Container(
  //             color: Colors.deepOrangeAccent,
  //             child: Text(status, textAlign: TextAlign.center)),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if ((controller == _hostTextController ||
            controller == _topicTextController) &&
        state == MQTTAppConnectionState.disconnected) {
      shouldEnable = true;
    }
    return TextField(
      enabled: shouldEnable,
      controller: controller,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
        labelText: hintText,
      ),
    );
  }

  Widget _buildScrollableTextWith(String text) {
    List<Widget> dataWidgets = [];

    List<String> lines = text.split('\n');

    for (String line in lines) {
      if (line.trim().isNotEmpty) {
        dataWidgets.add(
          Container(
            width: 400,
            height: 60,
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 223, 107, 30),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                line,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        );
      }
    }

    if (dataWidgets.length > 3) {
      dataWidgets = dataWidgets.sublist(dataWidgets.length - 3);
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children:
                  dataWidgets.isNotEmpty ? dataWidgets : [Text('No data')],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 223, 107, 30),
            ),
            onPressed: _clearHistoryText,
            child: Text('Clear History'),
          ),
        ],
      ),
    );
  }

  void _clearHistoryText() {
    currentAppState.clearHistoryText();
  }

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    String host = _hostTextController.text;
    String topic = 'test/' + _topicTextController.text + '/current';

    MQTTManager manager = MQTTManager(state: currentAppState);

    manager.initializeMQTTClient(topic: topic, identifier: 'identifier');

    managers.add(manager);

    _connectAllManagers();

    currentAppState.setAppConnectionState(MQTTAppConnectionState.connecting);
  }

  void _connectAllManagers() async {
    for (var manager in managers) {
      await manager.connectAll();
    }
  }

  void _disconnect() {
    for (var manager in managers) {
      manager.disconnectAll();
    }
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
