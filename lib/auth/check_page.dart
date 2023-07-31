import 'package:firebase_auth/firebase_auth.dart';
import '../pages/home_page.dart';
import '../pages/welcome_page.dart';
import 'package:flutter/material.dart';

class CheckPage extends StatelessWidget {
  const CheckPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const WelcomePage();
            }
          }),
    );
  }
}
