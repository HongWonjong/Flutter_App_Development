import 'package:flutter/material.dart';

class DrawerWithToggle extends StatelessWidget {
  final bool isOpen;
  final double drawerWidth;
  final double iconPositionTop;
  final Widget drawerContent;
  final IconData icon;
  final VoidCallback onToggle;
  final bool isAnotherDrawerOpen; // 다른 드로어가 열렸는지 여부

  const DrawerWithToggle({
    Key? key,
    required this.isOpen,
    required this.drawerWidth,
    required this.iconPositionTop,
    required this.drawerContent,
    required this.icon,
    required this.onToggle,
    required this.isAnotherDrawerOpen, // 추가된 인자
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: isOpen ? 0 : -drawerWidth,
          top: 0,
          height: MediaQuery.of(context).size.height,
          width: drawerWidth,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: drawerContent,
          ),
        ),
        // 토글 버튼 (다른 드로어가 열리지 않았을 때만 표시)
        if (!isOpen && !isAnotherDrawerOpen)
          Positioned(
            left: 0,
            top: iconPositionTop,
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
      ],
    );
  }
}


