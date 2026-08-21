import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';
import 'home_page.dart';
import 'ai_page.dart';
import 'course_page.dart';
import 'activity_page.dart';
import 'mine_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;
  final _pages = const [
    HomePage(),
    AiPage(),
    CoursePage(),
    ActivityPage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppStyles.primary,
        unselectedItemColor: AppStyles.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: _TabIcon(icon: 'assets/icons/tab_home.png'),
            activeIcon: _TabIcon(icon: 'assets/icons/tab_home_active.png'),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(icon: 'assets/icons/tab_ai.png'),
            activeIcon: _TabIcon(icon: 'assets/icons/tab_ai_active.png'),
            label: '智能',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(icon: 'assets/icons/tab_course.png'),
            activeIcon: _TabIcon(icon: 'assets/icons/tab_course_active.png'),
            label: '课程',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(icon: 'assets/icons/tab_activity.png'),
            activeIcon: _TabIcon(icon: 'assets/icons/tab_activity_active.png'),
            label: '活动',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(icon: 'assets/icons/tab_mine.png'),
            activeIcon: _TabIcon(icon: 'assets/icons/tab_mine_active.png'),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 底部 Tab 图标(固定尺寸的本地图片)
class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      icon,
      width: 26,
      height: 26,
      fit: BoxFit.contain,
    );
  }
}
