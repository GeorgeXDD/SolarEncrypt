// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, empty_constructor_bodies

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// class _HomePageState extends State<HomePage> {
//   final user = FirebaseAuth.instance.currentUser!;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Home'),
//           backgroundColor: Color.fromARGB(255, 223, 107, 30),
//         ),
//         body: Center(
//             child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Signed in as: ' + user.email!),
//             MaterialButton(
//               onPressed: () {
//                 FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => WelcomePage()),
//                 );
//               },
//               color: Color.fromARGB(255, 223, 107, 30),
//               child: Text('Sign Out'),
//             )
//           ],
//         )));
//   }
// }

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Color.fromARGB(255, 223, 107, 30),
      ),
      drawer: NavigationDrawer(user: user),
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
                  Text(
                    'Welcome user!',
                    style: TextStyle(fontSize: 28, color: Colors.white),
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
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favourites'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.workspaces_outline),
              title: const Text('Sensors'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Update solar panels'),
              onTap: () {},
            ),
          ],
        ),
      );
}
