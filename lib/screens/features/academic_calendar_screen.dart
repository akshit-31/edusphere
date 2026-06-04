import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/colors.dart';
import '../../widgets/common_widgets.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  DateTime _selectedMonth = DateTime(2026, 6, 1);
  DateTime _selectedDay = DateTime(2026, 6, 4);

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header matching screenshot
          PageHeader(
            title: 'Academic Calendar',
            subtitle: 'Institutional schedule, public holidays, and event horizons.',
            theme: roleThemes['student']!,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      // Navigation & Filter Bar
                      _buildControlBar(isDesktop),
                      SizedBox(height: 20.h),

                      // Responsive grid structure
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _buildCalendarGrid()),
                            SizedBox(width: 24.w),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _buildEventHorizonsCard(),
                                  SizedBox(height: 16.h),
                                  _buildLegendCard(),
                                  SizedBox(height: 16.h),
                                  _buildAssistantBubble(),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildCalendarGrid(),
                            SizedBox(height: 20.h),
                            _buildEventHorizonsCard(),
                            SizedBox(height: 16.h),
                            _buildLegendCard(),
                            SizedBox(height: 16.h),
                            _buildAssistantBubble(),
                          ],
                        ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CONTROL & NAVIGATION BAR ────────────────────────────────────────────────
  Widget _buildControlBar(bool isDesktop) {
    final monthName = _months[_selectedMonth.month - 1];
    
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: 24.sp, color: AppColors.textMedium),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
            });
          },
        ),
        SizedBox(width: 8.w),
        Text(
          '$monthName ${_selectedMonth.year}',
          style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.textDark),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, size: 24.sp, color: AppColors.textMedium),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
            });
          },
        ),
        SizedBox(width: 16.w),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0284C7),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(2026, 6, 1);
              _selectedDay = DateTime(2026, 6, 4);
            });
          },
          child: Text('Today', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w800)),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionOutlineButton(Icons.filter_list_rounded, 'Filters'),
        SizedBox(width: 10.w),
        _actionOutlineButton(Icons.file_download_outlined, 'Export'),
        SizedBox(width: 10.w),
        // Toggle view
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.all(2.r),
          child: Row(
            children: [
              _toggleItem('Month', true),
              _toggleItem('List', false),
            ],
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [controls, actions],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          controls,
          SizedBox(height: 12.h),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: actions),
        ],
      );
    }
  }

  Widget _actionOutlineButton(IconData icon, String label) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMedium,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 16.sp),
      label: Text(label, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700)),
    );
  }

  Widget _toggleItem(String label, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: active ? FontWeight.w900 : FontWeight.w700,
          color: active ? const Color(0xFF0284C7) : AppColors.textLight,
        ),
      ),
    );
  }

  // ── CALENDAR GRID ──────────────────────────────────────────────────────────
  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final firstDayOffset = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;
    
    // We want a Grid representing days
    final weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12.r, offset: Offset(0, 4.h)),
        ],
      ),
      child: Column(
        children: [
          // Weekdays header
          Row(
            children: weekDays.map((d) {
              return Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Center(
                    child: Text(
                      d,
                      style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: 0.5),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Days grid with solid borders
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35, // 5 rows * 7 columns standard grid representation
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemBuilder: (context, index) {
              final dayVal = index - firstDayOffset + 1;
              final isValidDay = dayVal > 0 && dayVal <= daysInMonth;
              
              if (!isValidDay) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
                  ),
                );
              }

              final cellDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayVal);
              final isSelected = cellDate.year == _selectedDay.year && cellDate.month == _selectedDay.month && cellDate.day == _selectedDay.day;
              
              // Hardcoded event June 4, 2026 highlight match
              final isJune4_2026 = cellDate.year == 2026 && cellDate.month == 6 && cellDate.day == 4;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = cellDate;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
                  ),
                  padding: EdgeInsets.all(8.r),
                  child: Stack(
                    children: [
                      // Highlight selector
                      if (isJune4_2026 || isSelected)
                        Center(
                          child: Container(
                            width: 32.w, height: 32.h,
                            decoration: const BoxDecoration(color: Color(0xFF0284C7), shape: BoxShape.circle),
                          ),
                        ),
                      // Day number
                      Align(
                        alignment: isJune4_2026 || isSelected ? Alignment.center : Alignment.topLeft,
                        child: Text(
                          dayVal.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: isJune4_2026 || isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: isJune4_2026 || isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── EVENT HORIZONS CARD ────────────────────────────────────────────────────
  Widget _buildEventHorizonsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16.r, offset: Offset(0, 8.h)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Horizons',
            style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          SizedBox(height: 2.h),
          Text(
            'Chronological list of milestones',
            style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 48.h),
          // Calendar Icon & Empty State
          Center(
            child: Column(
              children: [
                Icon(Icons.calendar_today_rounded, size: 40.sp, color: Colors.white.withValues(alpha: 0.25)),
                SizedBox(height: 12.h),
                Text(
                  'No records in ledger',
                  style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ── INSTITUTIONAL LEGEND CARD ──────────────────────────────────────────────
  Widget _buildLegendCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSTITUTIONAL LEGEND',
            style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: 0.8),
          ),
          SizedBox(height: 16.h),
          _legendItem(const Color(0xFFEF4444), 'Holiday'),
          SizedBox(height: 12.h),
          _legendItem(const Color(0xFF3B82F6), 'Event'),
          SizedBox(height: 12.h),
          _legendItem(const Color(0xFFF59E0B), 'Exam'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8.w, height: 8.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMedium),
        ),
      ],
    );
  }

  // ── ASSISTANT BUBBLE ───────────────────────────────────────────────────────
  Widget _buildAssistantBubble() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HI PRIYA!',
            style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0369A1)),
          ),
          SizedBox(height: 4.h),
          Text(
            'HOW CAN I HELP?',
            style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0284C7)),
          ),
        ],
      ),
    );
  }
}
