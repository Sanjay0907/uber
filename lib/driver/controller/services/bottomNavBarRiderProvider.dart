import 'package:flutter/material.dart';

class BottomNavBarDriverProvider extends ChangeNotifier {
  int currentTab = 0;
  updateTab(int newTab) {
    currentTab = newTab;
    notifyListeners();
  }
}
