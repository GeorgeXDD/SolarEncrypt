import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:solarencrypt/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:solarencrypt/services/MQTTAppState.dart';

import 'auth/check_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // Define your MQTTAppState provider here
        ChangeNotifierProvider(create: (_) => MQTTAppState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckPage(),
    );
  }
}
