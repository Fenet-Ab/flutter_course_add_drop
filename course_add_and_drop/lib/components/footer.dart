import 'package:flutter/material.dart';

// Define the Screen enum to match the Compose version
enum Screen {
  HomeScreen,
  AddCourse,
  DropCourse,
  UserDashboardScreen,
  AdminDashboard,
}

class Footer extends StatelessWidget {
  final Screen currentScreen;
  final ValueChanged<Screen> onItemSelected;

  const Footer({
    Key? key,
    required this.currentScreen,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _screenToIndex(currentScreen),
      onTap: (index) => onItemSelected(_indexToScreen(index)),
      selectedItemColor: const Color(0xFF655BEC), // Selected color
      unselectedItemColor: const Color(0xFF5D6677), // Unselected color
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add, size: 30),
          label: 'Add Course',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.remove, size: 30),
          label: 'Drop Course',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: 30),
          label: 'Dashboard',
        ),
      ],
    );
  }

  int _screenToIndex(Screen screen) {
    switch (screen) {
      case Screen.HomeScreen:
        return 0;
      case Screen.AddCourse:
        return 1;
      case Screen.DropCourse:
        return 2;
      case Screen.UserDashboardScreen:
      case Screen.AdminDashboard: // Treat both as same index for Footer
        return 3;
    }
  }

  Screen _indexToScreen(int index) {
    switch (index) {
      case 0:
        return Screen.HomeScreen;
      case 1:
        return Screen.AddCourse;
      case 2:
        return Screen.DropCourse;
      case 3:
        return Screen.UserDashboardScreen; // Footer uses UserDashboardScreen
      default:
        return Screen.HomeScreen;
    }
  }
}

class FooterAdmin extends StatelessWidget {
  final Screen currentScreen;
  final ValueChanged<Screen> onItemSelected;

  const FooterAdmin({
    Key? key,
    required this.currentScreen,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _screenToIndex(currentScreen),
      onTap: (index) => onItemSelected(_indexToScreen(index)),
      selectedItemColor: const Color(0xFF655BEC),
      unselectedItemColor: const Color(0xFF5D6677),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add, size: 30),
          label: 'Add Course',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.remove, size: 30),
          label: 'Drop Course',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: 30),
          label: 'Dashboard',
        ),
      ],
    );
  }

  int _screenToIndex(Screen screen) {
    switch (screen) {
      case Screen.HomeScreen:
        return 0;
      case Screen.AddCourse:
        return 1;
      case Screen.DropCourse:
        return 2;
      case Screen.UserDashboardScreen:
      case Screen.AdminDashboard:
        return 3;
    }
  }

  Screen _indexToScreen(int index) {
    switch (index) {
      case 0:
        return Screen.HomeScreen;
      case 1:
        return Screen.AddCourse;
      case 2:
        return Screen.DropCourse;
      case 3:
        return Screen.AdminDashboard; // FooterAdmin uses AdminDashboard
      default:
        return Screen.HomeScreen;
    }
  }
}