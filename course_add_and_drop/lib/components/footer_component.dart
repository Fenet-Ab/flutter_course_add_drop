import 'package:flutter/material.dart';

enum Screen {
  home,
  addCourse,
  dropCourse,
  dashboard
}

class FooterComponent extends StatelessWidget {
  final Screen currentScreen;
  final Function(Screen) onItemSelected;

  const FooterComponent({
    Key? key,
    required this.currentScreen,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFE0E7FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FooterItem(
              icon: Icons.home,
              label: "Home",
              isSelected: currentScreen == Screen.home,
              onTap: () => onItemSelected(Screen.home),
              addBorder: false,
            ),
            _FooterItem(
              icon: Icons.add,
              label: "Add Course",
              isSelected: currentScreen == Screen.addCourse,
              onTap: () => onItemSelected(Screen.addCourse),
              addBorder: true,
            ),
            _FooterItem(
              icon: Icons.settings,
              label: "Drop Course",
              isSelected: currentScreen == Screen.dropCourse,
              onTap: () => onItemSelected(Screen.dropCourse),
              addBorder: false,
            ),
            _FooterItem(
              icon: Icons.apps,
              label: "Dashboard",
              isSelected: currentScreen == Screen.dashboard,
              onTap: () => onItemSelected(Screen.dashboard),
              addBorder: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool addBorder;

  const _FooterItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.addBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFFD0D7FF),
                  borderRadius: BorderRadius.circular(8),
                  border: addBorder
                      ? Border.all(
                          color: const Color(0xFF3B82F6),
                          width: 1.5,
                        )
                      : null,
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black87 : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 