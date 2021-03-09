import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:savings/Storage.dart';
import 'package:savings/auth/profile.dart';
import 'package:savings/dashboard/dashboard_main.dart';
import 'package:savings/manage/manage_savings.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Storage.getProvider().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.black,
        brightness: Brightness.dark,
        backgroundColor: const Color(0xFF212121),
        accentColor: Colors.white,
        accentIconTheme: IconThemeData(color: Colors.black),
        dividerColor: Colors.black12,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.white,
        brightness: Brightness.light,
        backgroundColor: const Color(0xFFE5E5E5),
        accentColor: Colors.black,
        accentIconTheme: IconThemeData(color: Colors.white),
        dividerColor: Colors.white54,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        bottomNavigationBar: BottomNavBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key key}) : super(key: key);

  @override
  _BottomNavBar createState() => _BottomNavBar();
}

class _BottomNavBar extends State<BottomNavBar> {
  int _selectedIndex = 0;
  static double _titleSize = 22;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static List<Widget> _titleOptions = <Widget>[
    Text(
      'Dashboard',
      style: TextStyle(fontSize: _titleSize),
    ),
    Text(
      'Manage',
      style: TextStyle(fontSize: _titleSize),
    ),
    Text(
      'Profile',
      style: TextStyle(fontSize: _titleSize),
    ),
  ];
  static List<Widget> _widgetOptions = <Widget>[
    DashboardMain(),
    ManageSavingsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Preferences',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
