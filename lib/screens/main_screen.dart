import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/common_widgets.dart';
import 'dashboards/student_dashboard.dart';
import 'dashboards/teacher_dashboard.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'welcome_screen.dart';
import 'features/class_management_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainScreen extends StatefulWidget {
  final String role;
  const MainScreen({super.key, required this.role});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  RoleTheme get _theme => roleThemes[widget.role]!;

  Widget _dashboard() {
    switch (widget.role) {
      case 'student':    return StudentDashboard(theme: _theme);
      case 'teacher':    return TeacherDashboard(theme: _theme);
      default:           return StudentDashboard(theme: _theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    final screens = [
      _dashboard(),
      if (widget.role == 'teacher') ClassManagementScreen(theme: _theme, onBack: () => setState(() => _idx = 0)),
      MessagesScreen(theme: _theme),
      ProfileScreen(role: widget.role, theme: _theme),
    ];

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: IndexedStack(index: _idx, children: screens),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', selected: _idx == 0, color: _theme.primary, onTap: () => setState(() => _idx = 0)),
                if (widget.role == 'teacher')
                  _NavItem(icon: Icons.school_rounded, label: 'Classes', selected: _idx == 1, color: _theme.primary, onTap: () => setState(() => _idx = 1)),
                _NavItem(icon: Icons.chat_bubble_rounded, label: 'Messages', selected: selectedIdx(widget.role == 'teacher' ? 2 : 1), color: _theme.primary, onTap: () => setState(() => _idx = widget.role == 'teacher' ? 2 : 1)),
                _NavItem(icon: Icons.person_rounded, label: 'My Profile', selected: selectedIdx(widget.role == 'teacher' ? 3 : 2), color: _theme.primary, onTap: () => setState(() => _idx = widget.role == 'teacher' ? 3 : 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool selectedIdx(int i) => _idx == i;
  Widget _buildSidebar() {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  width: 40.w, height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                ),
                SizedBox(width: 12.w),
                Text('EDUSPHERE', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1)),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _SidebarItem(icon: Icons.home_rounded, label: 'Dashboard', selected: _idx == 0, color: _theme.primary, onTap: () => setState(() => _idx = 0)),
                  SizedBox(height: 8.h),
                  if (widget.role == 'teacher') ...[
                    _SidebarItem(icon: Icons.school_rounded, label: 'Class Management', selected: _idx == 1, color: _theme.primary, onTap: () => setState(() => _idx = 1)),
                    SizedBox(height: 8.h),
                  ],
                  _SidebarItem(icon: Icons.chat_bubble_rounded, label: 'Messages', selected: selectedIdx(widget.role == 'teacher' ? 2 : 1), color: _theme.primary, onTap: () => setState(() => _idx = widget.role == 'teacher' ? 2 : 1)),
                  SizedBox(height: 8.h),
                  _SidebarItem(icon: Icons.person_rounded, label: 'My Profile', selected: selectedIdx(widget.role == 'teacher' ? 3 : 2), color: _theme.primary, onTap: () => setState(() => _idx = widget.role == 'teacher' ? 3 : 2)),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: _theme.light, child: Icon(Icons.person_rounded, color: _theme.primary)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alex Rivera', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      Text(_theme.label, style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textLight)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 20.sp), 
                  onPressed: () => Navigator.pushAndRemoveUntil(context, 
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()), (r) => false)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _SidebarItem({required this.icon, required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : AppColors.textLight, size: 22.sp),
            SizedBox(width: 16.w),
            Text(label, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? color : AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? color : AppColors.textLight, size: 24.sp),
            SizedBox(height: 2.h),
            Text(label, style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w700, color: selected ? AppColors.textDark : AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}
