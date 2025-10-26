import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/homepage/FunctionPage.dart';
import 'package:vocabsimple/src/components/homepage/progress_page.dart';
import 'package:vocabsimple/src/components/user/ProfileSetting.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<State> _progressPageKey = GlobalKey<State>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      FunctionPage(),
      ProgressPage(key: _progressPageKey),
      Center(
        child: Text(
          'Thông báo',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ), // Placeholder
      ProfileSetting(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // Reload ProgressPage khi chuyển đến tab Tiến trình
          if (index == 1) {
            final progressState = _progressPageKey.currentState;
            if (progressState != null && progressState.mounted) {
              (progressState as dynamic).loadProgressData();
            }
          }
        },
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Tiến trình'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
        ],
      ),
    );
  }
}