// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, empty_constructor_bodies
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solarencrypt/pages/chat_page.dart';
import 'package:solarencrypt/pages/control_page.dart';
import 'package:solarencrypt/pages/radar_local_area_page.dart';
import 'package:solarencrypt/pages/sensors_page.dart';
import 'package:solarencrypt/pages/earnings_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 30),
              child: FutureBuilder<String?>(
                future: fetchUsername(),
                builder: (context, snapshot) {
                  String username = snapshot.data ?? user.email!;
                  return RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Welcome, ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 223, 107, 30),
                            fontSize: 22,
                          ),
                        ),
                        TextSpan(
                          text: '$username!',
                          style: TextStyle(
                            color: Color.fromARGB(255, 223, 107, 30),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // SizedBox(height: 20),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(70.0),
            //   child: Image.asset(
            //     'assets/solarpanel_home2.jpg',
            //     width: double.infinity,
            //     height: 200,
            //   ),
            // ),
            ArchedLineAnimation(),
            // SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SensorsPage()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 50),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 223, 107, 30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.solar_power,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Connect to your solar panel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatPage()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 50),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 223, 107, 30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Chat with users',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Container(
              child: Text(
                'Last 7 days Watt consumption',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 53, 52, 52),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Line chart displaying power and voltage
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  showAvg ? avgData() : mainData(),
                ),
              ),
            ),
            SizedBox(height: 20),
            // 'avg' button
            Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: showAvg
                    ? const Color.fromARGB(255, 223, 107, 30).withOpacity(0.5)
                    : const Color.fromARGB(255, 223, 107, 30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'Average',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Add more widgets as needed
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
        ),
        bottomTitles: SideTitles(showTitles: true),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color.fromARGB(255, 223, 107, 30))),
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: 200,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(1, 80),
            FlSpot(2, 82),
            FlSpot(3, 79),
            FlSpot(4, 70),
            FlSpot(5, 85),
            FlSpot(6, 79),
            FlSpot(7, 90),
          ],
          isCurved: true,
          colors: [const Color.fromARGB(255, 223, 107, 30)],
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        )
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
        ),
        bottomTitles: SideTitles(showTitles: true),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color.fromARGB(255, 223, 107, 30))),
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: 200,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(1, 80),
            FlSpot(2, 80),
            FlSpot(3, 80),
            FlSpot(4, 80),
            FlSpot(5, 80),
            FlSpot(6, 80),
            FlSpot(7, 80),
          ],
          isCurved: true,
          colors: [const Color.fromARGB(255, 223, 107, 30)],
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        )
      ],
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

class ArchedLineAnimation extends StatefulWidget {
  @override
  _ArchedLineAnimationState createState() => _ArchedLineAnimationState();
}

class _ArchedLineAnimationState extends State<ArchedLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DateTime currentTime = DateTime.now();
  DateTime customDateTime = DateTime(2023, 11, 7, 11, 00, 0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(300, 300),
        painter: LinePainter(customDateTime),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final DateTime currentTime;

  LinePainter(this.currentTime);

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Paint objectPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(pi);

    double startAngle = 0;
    double sweepAngle = pi;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, 0), radius: 100),
      startAngle,
      sweepAngle,
      false,
      linePaint,
    );

    double currentPos = _calculateCurrentPosition(currentTime);

    double objectX = 100 * cos(startAngle - sweepAngle * currentPos);
    double objectY = 100 * sin(startAngle - sweepAngle * currentPos);

    canvas.drawCircle(Offset(objectX, objectY), 10, objectPaint);

    canvas.restore();
  }

  double _calculateCurrentPosition(DateTime time) {
    int totalSeconds = time.hour * 3600 + time.minute * 60 + time.second;
    double normalizedTime = totalSeconds / (24 * 3600);
    return normalizedTime * 1.8 * pi / 2;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
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
                  backgroundImage: ExactAssetImage('assets/logo1.png'),
                  backgroundColor: Color.fromARGB(255, 53, 52, 52),
                ),
                SizedBox(height: 10),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                color: Color.fromARGB(255, 223, 107, 30),
                child: ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Chat'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
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
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RadarLocalAreaPage()),
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
