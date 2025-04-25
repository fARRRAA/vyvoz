import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:vyvoz/pages/home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // AuthService authService = AuthService();
  int _currentIndex = 0;
  String title = "Главная";

  final pages = [HomePage()];

  void _updateTitle(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          title = "Главная";
          break;
        case 1:
          title = "Заявки";
          break;
        case 2:
          title = "Мои смены";
          break;
        case 3:
          title = "Профиль";
          break;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              onPressed: () async {
                // await authService.signOut();
                // final prefs = await SharedPreferences.getInstance();
                // await prefs.setBool('isLoggedIn', false);
                // Navigator.popAndPushNamed(context, '/');
              },
              icon: Icon(Icons.notifications))
        ],
      ),
      body: pages.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _updateTitle,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Заявки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_outlined),
            label: 'Мои смены',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Профиль',
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        enableFeedback: false,
      ),
    );
  }
}
