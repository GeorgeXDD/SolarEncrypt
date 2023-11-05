// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solarencrypt/pages/control_page.dart';
import 'package:solarencrypt/pages/home_page.dart';
import 'package:solarencrypt/pages/sensors_page.dart';
import 'package:solarencrypt/pages/welcome_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chat');
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
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
        body: Stack(children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.transparent,
              BlendMode.srcOver,
            ),
            child: Image.asset(
              'assets/logo1transp.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: chatCollection.orderBy('timestamp').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final messages = snapshot.data?.docs;
                    List<Widget> messageWidgets = [];
                    for (var message in messages!) {
                      final messageText = message['text'];
                      final messageSender = message['sender'];
                      final messageWidget = MessageWidget(
                        text: messageText,
                        sender: messageSender,
                        isMe: user.email == messageSender,
                      );
                      messageWidgets.insert(0, messageWidget);
                    }
                    return ListView(
                      reverse: true, // Reverse the ListView
                      children: messageWidgets,
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 53, 52, 52),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 53, 52, 52),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          color: Colors.white,
                          onPressed: () {
                            sendMessage();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ]));
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      chatCollection.add({
        'text': text,
        'sender': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      messageController.clear();
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageWidget({required this.text, required this.sender, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20, top: 5.0, right: 20, bottom: 5.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isMe ? const Color.fromARGB(255, 223, 107, 30) : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: fetchUsername(sender),
                  builder: (context, snapshot) {
                    final username = snapshot.data ?? sender;
                    return Text(
                      username,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 53, 52, 52),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> fetchUsername(String userEmail) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['username'];
    }

    return null;
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
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                color: const Color.fromARGB(255, 223, 107, 30),
                child: ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: const Text('Chat'),
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  ),
                ),
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
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ControlPage()),
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
