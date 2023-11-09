// ignore_for_file: unnecessary_null_comparison, prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:solarencrypt/pages/chat_page.dart';
import 'package:solarencrypt/pages/control_page.dart';
import 'package:solarencrypt/pages/home_page.dart';
import 'package:solarencrypt/pages/sensors_page.dart';
import 'package:solarencrypt/pages/welcome_page.dart';
import 'package:solarencrypt/pages/earnings_page.dart';
import 'package:geolocator/geolocator.dart';

class RadarLocalAreaPage extends StatefulWidget {
  @override
  _RadarLocalAreaPageState createState() => _RadarLocalAreaPageState();
}

class _RadarLocalAreaPageState extends State<RadarLocalAreaPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController messageController = TextEditingController();
  late Position _userPosition;

  @override
  void initState() {
    super.initState();
    _userPosition = const Position(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        timestamp: null);
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userPosition = position;
      });
    } catch (e) {
      print('Error fetching user location: $e');
    }
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Radar Local Area'),
//         backgroundColor: const Color.fromARGB(255, 223, 107, 30),
//         titleSpacing: 00.0,
//         centerTitle: true,
//         toolbarHeight: 60.2,
//         toolbarOpacity: 0.8,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//               bottomRight: Radius.circular(25),
//               bottomLeft: Radius.circular(25)),
//         ),
//         elevation: 0.00,
//       ),
//       drawer: NavigationDrawer(user: user),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_userPosition != null && _userPosition.latitude != 0.0)
//               Column(
//                 children: [
//                   Text(
//                     'Your current coordinates:',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Latitude: ${_userPosition.latitude}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     'Longitude: ${_userPosition.longitude}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             if (_userPosition == null || _userPosition.latitude == 0.0)
//               Text(
//                 'Fetching user location...',
//                 style: TextStyle(fontSize: 18),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Radar Local Area'),
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
            child: Container(
                child: Column(children: [
          Flexible(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(45.603354, 25.244930),
                zoom: 6.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(45.746713, 21.237726),
                      child: Icon(Icons.pin_drop,
                          color: const Color.fromARGB(255, 223, 107, 30)),
                    ),
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(44.438333, 26.051388),
                      child: Icon(Icons.pin_drop,
                          color: const Color.fromARGB(255, 223, 107, 30)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ]))));
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
                const CircleAvatar(
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
            ListTile(
              leading: const Icon(Icons.control_camera),
              title: const Text('Control Panel'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ControlPage()),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                color: const Color.fromARGB(255, 223, 107, 30),
                child: ListTile(
                  leading: const Icon(Icons.radar),
                  title: const Text('Radar Local Area'),
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RadarLocalAreaPage()),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Earnings Page'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EarningsPage()),
              ),
            ),
          ],
        ),
      );
}
