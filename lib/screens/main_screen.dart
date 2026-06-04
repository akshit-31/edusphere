import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/colors.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../widgets/common_widgets.dart';
import 'dashboards/student_dashboard.dart';
import 'dashboards/teacher_dashboard.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'welcome_screen.dart';
import 'academic_screen.dart';
import 'features/class_management_screen.dart';
import 'features/academic_calendar_screen.dart';
import 'features/assignments_screen.dart';
import 'features/fee_ledger_screen.dart';
import 'features/transport_screen.dart';
import 'features/announcements_screen.dart';
import 'features/services_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String role;
  const MainScreen({super.key, required this.role});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _userName = 'Alex Rivera';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initSocketConnection();
  }

  @override
  void dispose() {
    try {
      SocketService().off('NEW_NOTIFICATION');
      SocketService().off('attendance:qr-scan');
      SocketService().off('ATTENDANCE_MARKED');
      SocketService().disconnect();
    } catch (_) {}
    super.dispose();
  }

  void _initSocketConnection() {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        SocketService().connect(
          userId: currentUser.id,
          role: widget.role,
        );
        _setupSocketListeners();
      }
    } catch (e) {
      dev.log('⚠️ Failed to initialize socket connection: $e', name: 'MainScreen');
    }
  }

  void _setupSocketListeners() {
    SocketService().on('NEW_NOTIFICATION', (data) {
      if (!mounted) return;
      dev.log('🔔 Real-time notification: $data', name: 'MainScreen');
      
      final title = data['title'] as String? ?? 'Notification';
      final message = data['message'] as String? ?? 'You have a new update';
      
      showToast(context, '📣 $title: $message');
    });

    SocketService().on('attendance:qr-scan', (data) {
      if (!mounted) return;
      dev.log('🟢 Attendance QR Scan: $data', name: 'MainScreen');
      
      final action = data['action'] as String? ?? 'checkin';
      final user = data['user'] as Map? ?? {};
      final userName = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
      
      showToast(context, '🚨 Live Scan! $userName marked ${action.toUpperCase()}');
    });

    SocketService().on('ATTENDANCE_MARKED', (data) {
      if (!mounted) return;
      dev.log('🟢 Attendance Marked: $data', name: 'MainScreen');
      
      final studentName = data['studentName'] as String? ?? 'User';
      final status = data['status'] as String? ?? 'PRESENT';
      final type = data['type'] as String? ?? 'System';
      
      showToast(context, '📅 Attendance: $studentName marked $status via $type');
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('${widget.role}_name') ?? 
                  (widget.role == 'teacher' ? prefs.getString('teacher_name') : null) ??
                  (widget.role == 'student' ? prefs.getString('student_name') : null) ??
                  kCredentials[widget.role]?['name'] ?? 
                  'EduSphere User';
    });
  }
  int _idx = 0;

  RoleTheme get _theme => roleThemes[widget.role]!;

  Widget _dashboard() {
    switch (widget.role) {
      case 'student':    return StudentDashboard(theme: _theme);
      case 'teacher':    return TeacherDashboard(theme: _theme);
      default:           return StudentDashboard(theme: _theme);
    }
  }

  List<Widget> _buildScreensList() {
    if (widget.role == 'student') {
      return [
        _dashboard(), // 0: Dashboard
        const AcademicCalendarScreen(), // 1: Academic Calendar
        const AssignmentsScreen(), // 2: Assignments
        AcademicScreen(theme: _theme, onBack: () => setState(() => _idx = 0)), // 3: Academic
        FeeLedgerScreen(theme: _theme), // 4: Fees
        TransportScreen(theme: _theme), // 5: Transport
        AnnouncementsScreen(theme: _theme), // 6: Announcements
        MessagesScreen(theme: _theme, isActive: _idx == 7, onBack: () => setState(() => _idx = 0)), // 7: Community
        ServicesScreen(theme: _theme), // 8: Services
        ProfileScreen(role: widget.role, theme: _theme, onBack: () => setState(() => _idx = 0)), // 9: My Profile
      ];
    } else {
      return [
        _dashboard(), // 0: Dashboard
        ClassManagementScreen(theme: _theme, onBack: () => setState(() => _idx = 0)), // 1: Classes
        MessagesScreen(theme: _theme, isActive: _idx == 2, onBack: () => setState(() => _idx = 0)), // 2: Messages
        ProfileScreen(role: widget.role, theme: _theme, onBack: () => setState(() => _idx = 0)), // 3: Profile
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final screens = _buildScreensList();

    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        title: Text(
          widget.role == 'student' ? 'EduSphere Student' : 'EduSphere Teacher',
          style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.textDark)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark, size: 24.sp),
      ),
      drawer: isDesktop ? null : _buildDrawer(),
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', selected: _idx == 0, color: _theme.primary, onTap: () => setState(() => _idx = 0)),
                if (widget.role == 'student')
                  _NavItem(icon: Icons.school_rounded, label: 'Academic', selected: _idx == 3, color: _theme.primary, onTap: () => setState(() => _idx = 3)),
                if (widget.role == 'teacher')
                  _NavItem(icon: Icons.class_rounded, label: 'Classes', selected: _idx == 1, color: _theme.primary, onTap: () => setState(() => _idx = 1)),
                _NavItem(
                  icon: Icons.chat_bubble_rounded, 
                  label: 'Messages', 
                  selected: widget.role == 'student' ? _idx == 7 : _idx == 2, 
                  color: _theme.primary, 
                  onTap: () => setState(() => _idx = widget.role == 'student' ? 7 : 2)
                ),
                _NavItem(
                  icon: Icons.person_rounded, 
                  label: 'My Profile', 
                  selected: widget.role == 'student' ? _idx == 9 : _idx == 3, 
                  color: _theme.primary, 
                  onTap: () => setState(() => _idx = widget.role == 'student' ? 9 : 3)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: _theme.gradient),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2), 
                    child: Icon(widget.role == 'student' ? Icons.school_rounded : Icons.person_rounded, color: Colors.white)
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('EduSphere', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text(widget.role == 'student' ? 'Student Portal' : 'Teacher Portal', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: _sidebarItems(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: _theme.light, child: Icon(Icons.person_rounded, color: _theme.primary)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
      ),
    );
  }

  List<Widget> _sidebarItems() {
    if (widget.role == 'student') {
      return [
        _SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', selected: _idx == 0, color: _theme.primary, onTap: () { setState(() => _idx = 0); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.calendar_month_rounded, label: 'Academic Calendar', selected: _idx == 1, color: _theme.primary, onTap: () { setState(() => _idx = 1); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.assignment_rounded, label: 'Assignments', selected: _idx == 2, color: _theme.primary, onTap: () { setState(() => _idx = 2); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.school_rounded, label: 'Academic', selected: _idx == 3, color: _theme.primary, onTap: () { setState(() => _idx = 3); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.credit_card_rounded, label: 'Fees', selected: _idx == 4, color: _theme.primary, onTap: () { setState(() => _idx = 4); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.directions_bus_rounded, label: 'Transport', selected: _idx == 5, color: _theme.primary, onTap: () { setState(() => _idx = 5); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.campaign_rounded, label: 'Announcements', selected: _idx == 6, color: _theme.primary, onTap: () { setState(() => _idx = 6); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.people_rounded, label: 'Community', selected: _idx == 7, color: _theme.primary, onTap: () { setState(() => _idx = 7); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.support_agent_rounded, label: 'Services', selected: _idx == 8, color: _theme.primary, onTap: () { setState(() => _idx = 8); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.person_rounded, label: 'My Profile', selected: _idx == 9, color: _theme.primary, onTap: () { setState(() => _idx = 9); if (Navigator.canPop(context)) Navigator.pop(context); }),
      ];
    } else {
      return [
        _SidebarItem(icon: Icons.home_rounded, label: 'Dashboard', selected: _idx == 0, color: _theme.primary, onTap: () { setState(() => _idx = 0); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.class_rounded, label: 'Class Management', selected: _idx == 1, color: _theme.primary, onTap: () { setState(() => _idx = 1); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.chat_bubble_rounded, label: 'Messages', selected: _idx == 2, color: _theme.primary, onTap: () { setState(() => _idx = 2); if (Navigator.canPop(context)) Navigator.pop(context); }),
        SizedBox(height: 8.h),
        _SidebarItem(icon: Icons.person_rounded, label: 'My Profile', selected: _idx == 3, color: _theme.primary, onTap: () { setState(() => _idx = 3); if (Navigator.canPop(context)) Navigator.pop(context); }),
      ];
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 280.w,
      decoration: const BoxDecoration(
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
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
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
              child: SingleChildScrollView(
                child: Column(
                  children: _sidebarItems(),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: _theme.light, child: Icon(Icons.person_rounded, color: _theme.primary)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : AppColors.textLight, size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? color : AppColors.textMedium))),
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
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
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
