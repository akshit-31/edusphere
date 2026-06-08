import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../main_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Event model
// ═══════════════════════════════════════════════════════════════════════════════
enum EventType { holiday, event, exam, emergency, notice }

extension EventTypeExtension on EventType {
  Color get color {
    switch (this) {
      case EventType.holiday:   return const Color(0xFFEF4444);
      case EventType.event:     return const Color(0xFF3B82F6);
      case EventType.exam:      return const Color(0xFFF59E0B);
      case EventType.emergency: return const Color(0xFF8B5CF6);
      case EventType.notice:    return const Color(0xFF94A3B8);
    }
  }

  Color get bgColor {
    switch (this) {
      case EventType.holiday:   return const Color(0xFFFEE2E2);
      case EventType.event:     return const Color(0xFFDBEAFE);
      case EventType.exam:      return const Color(0xFFFEF3C7);
      case EventType.emergency: return const Color(0xFFEDE9FE);
      case EventType.notice:    return const Color(0xFFF1F5F9);
    }
  }

  String get label {
    switch (this) {
      case EventType.holiday:   return 'Holiday';
      case EventType.event:     return 'Event';
      case EventType.exam:      return 'Exam';
      case EventType.emergency: return 'Emergency';
      case EventType.notice:    return 'Notice';
    }
  }
}

class CalendarEvent {
  final String title;
  final EventType type;
  final String? time;
  const CalendarEvent(this.title, this.type, {this.time});
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Event Type Colors ─────────────────────────────────────────────────────────
Color _typeColor(String? type) {
  switch ((type ?? '').toUpperCase()) {
    case 'HOLIDAY':
      return const Color(0xFFEF4444);
    case 'EXAM':
      return const Color(0xFFF59E0B);
    case 'EMERGENCY':
      return const Color(0xFF8B5CF6);
    case 'NOTICE':
      return const Color(0xFF94A3B8);
    default:
      return const Color(0xFF3B82F6);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Academic Calendar Screen
// ═══════════════════════════════════════════════════════════════════════════════
class AcademicCalendarScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  final bool showAppBar;

  const AcademicCalendarScreen({
    super.key,
    this.onOpenDrawer,
    this.showAppBar = true,
  });

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  bool _isMonthView = true;

  // Events keyed by "year-month-day"
  final Map<String, List<CalendarEvent>> _events = {};
  // Real-time events from Supabase
  List<dynamic> _allEvents = [];
  bool _isLoading = true;

  RealtimeChannel? _calendarChannel;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now;
    _loadEvents();
  }

  void _loadEvents() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;

    // Pre-loaded institutional events
    _addEvent(y, m, 1,  const CalendarEvent('Start of Academic Year 2025-2026', EventType.event));
    _addEvent(y, m, 15, const CalendarEvent('Science Fair 2026', EventType.event, time: '10:00 AM'));
    _addEvent(y, m, 20, const CalendarEvent('National Holiday', EventType.holiday));
    _addEvent(y, m, 25, const CalendarEvent('Mid-Term Examinations', EventType.exam));

    // Next month events
    _addEvent(y, m + 1, 5,  const CalendarEvent('Parents Meeting', EventType.event));
    _addEvent(y, m + 1, 14, const CalendarEvent('Independence Day', EventType.holiday));
    _addEvent(y, m + 1, 22, const CalendarEvent('Annual Sports Day', EventType.event));
    _addEvent(y, m + 1, 28, const CalendarEvent('Chemistry Lab Exam', EventType.exam));
  }

  void _addEvent(int year, int month, int day, CalendarEvent event) {
    final key = '$year-$month-$day';
    _events.putIfAbsent(key, () => []).add(event);
  }

  String _eventKey(int year, int month, int day) => '$year-$month-$day';

  List<CalendarEvent> _eventsForDay(int year, int month, int day) =>
      _events[_eventKey(year, month, day)] ?? [];

  void _goToPreviousMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      });

  void _goToNextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      });

  void _goToToday() => setState(() {
        final now = DateTime.now();
        _focusedMonth = DateTime(now.year, now.month, 1);
        _selectedDay = now;
      });

  // All events in focused month sorted by day
  List<MapEntry<DateTime, CalendarEvent>> get _monthEventHorizons {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final List<MapEntry<DateTime, CalendarEvent>> result = [];
    for (int d = 1; d <= daysInMonth; d++) {
      final events = _eventsForDay(year, month, d);
      for (var e in events) {
        result.add(MapEntry(DateTime(year, month, d), e));
      }
    }
    return result;
    _loadCalendarEvents();
    _loadLocalNoticesCount();
    _connectRealtime();
  }

  @override
  void dispose() {
    if (_calendarChannel != null) {
      try {
        Supabase.instance.client.removeChannel(_calendarChannel!);
      } catch (_) {}
    }
    super.dispose();
  }

  void _connectRealtime() {
    try {
      final client = Supabase.instance.client;
      if (_calendarChannel != null) {
        client.removeChannel(_calendarChannel!);
      }
      _calendarChannel = client
          .channel('public:academic_calendar_screen')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'SchoolCalendar',
            callback: (_) {
              if (mounted) _loadCalendarEvents();
            },
          );
      _calendarChannel!.subscribe((status, [error]) {
        dev.log(
          '📡 AcademicCalendarScreen realtime status: $status',
          name: 'AcademicCalendar',
        );
        if (error != null) {
          dev.log(
            '❌ AcademicCalendarScreen realtime error: $error',
            name: 'AcademicCalendar',
          );
        }
      });
    } catch (e) {
      dev.log('Error connecting realtime in AcademicCalendarScreen: $e');
    }
  }

  Future<void> _loadCalendarEvents() async {
    try {
      final res = await Supabase.instance.client
          .from('SchoolCalendar')
          .select()
          .order('date', ascending: true);
      if (mounted) {
        setState(() {
          _allEvents = res as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      dev.log('Error loading calendar events: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalNoticesCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getString('local_announcements_list');
      if (rawList != null) {
        final List<dynamic> decoded = json.decode(rawList);
        if (mounted) {
          setState(() {
            _localNoticesCount = decoded.length;
          });
        }
      }
    } catch (_) {}
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  List<dynamic> _getEventsForDay(int year, int month, int day) {
    return _allEvents.where((event) {
      if (event['date'] == null) return false;
      try {
        final d = DateTime.parse(event['date'].toString()).toLocal();
        return d.year == year && d.month == month && d.day == day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  int get _eventsToday {
    final now = DateTime.now();
    return _getEventsForDay(now.year, now.month, now.day).length;
  }

  int get _upcomingCount {
    int count = 0;
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      count += _getEventsForDay(date.year, date.month, date.day).length;
    }
    return count;
  }

  int get _holidaysThisMonth {
    return _allEvents.where((event) {
      if (event['date'] == null) return false;
      if ((event['type'] ?? '').toString().toUpperCase() != 'HOLIDAY') return false;
      try {
        final d = DateTime.parse(event['date'].toString()).toLocal();
        return d.year == _focusedMonth.year && d.month == _focusedMonth.month;
      } catch (_) {
        return false;
      }
    }).length;
  }

  // Upcoming events sorted by date (next 90 days)
  List<dynamic> get _upcomingEventsList {
    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 90));
    final filtered = _allEvents.where((event) {
      if (event['date'] == null) return false;
      try {
        final d = DateTime.parse(event['date'].toString()).toLocal();
        return d.isAfter(now.subtract(const Duration(days: 1))) &&
            d.isBefore(cutoff);
      } catch (_) {
        return false;
      }
    }).toList();
    filtered.sort((a, b) {
      final da = DateTime.parse(a['date'].toString()).toLocal();
      final db = DateTime.parse(b['date'].toString()).toLocal();
      return da.compareTo(db);
    });
    return filtered;
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _focusedMonth = DateTime(now.year, now.month, 1);
      _selectedDay = now;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF0F4F8),
      drawer: widget.showAppBar
          ? const EduSphereDrawer(role: 'teacher', activeLabel: 'Academic Calendar')
          : null,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, size: 28.sp, color: const Color(0xFF0F172A)),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                  widget.onOpenDrawer?.call();
                },
              ),
              title: Text(
                'EduSphere',
                style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              actions: [
                // Realtime indicator dot
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Live',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon:
                      Icon(Icons.notifications_none_rounded, size: 26.sp),
                  icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black),
                  onPressed: () {},
                ),
                SizedBox(width: 8.w),
              ],
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 18.h),
              _buildCalendarCard(),
              SizedBox(height: 14.h),
              _buildEventHorizons(),
              SizedBox(height: 14.h),
              _buildLegend(),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showAppBar
          ? const TeacherBottomNavBar(activeIndex: 1)
          : null,
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Academic Calendar',
          style: GoogleFonts.outfit(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0077D6)))
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    SizedBox(height: 16.h),
                    _buildStatsRow(),
                    SizedBox(height: 20.h),
                    _buildCalendarCard(),
                    SizedBox(height: 20.h),
                    _buildBottomCards(isDesktop),
                    SizedBox(height: 16.h),
                    _buildBottomStatsBar(),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Title + Date Badge ──────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Academic Calendar',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 14.sp, color: const Color(0xFF1E6091)),
                  SizedBox(width: 4.w),
                  Text(
                    DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E6091),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'Institutional schedule, public holidays, and event horizons.',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ── Full Calendar Card ─────────────────────────────────────────────────────
  Widget _buildCalendarCard() {
    final year  = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay     = DateTime(year, month, 1);
    final daysInMonth  = DateTime(year, month + 1, 0).day;
    // Sunday = 0  (Dart weekday: Mon=1..Sun=7)
    final startOffset  = firstDay.weekday % 7;
    final totalCells   = startOffset + daysInMonth;
    final rows         = (totalCells / 7).ceil();

              fontSize: 11.sp, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  // ── 4 Stats Cards ───────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard('EVENTS TODAY', '$_eventsToday', 'Events scheduled',
              const Color(0xFF3B82F6), Icons.calendar_today_outlined),
          SizedBox(width: 10.w),
          _buildStatCard('UPCOMING EVENTS', '$_upcomingCount', 'Next 7 days',
              const Color(0xFF10B981), Icons.calendar_today_outlined),
          SizedBox(width: 10.w),
          _buildStatCard('HOLIDAYS', '$_holidaysThisMonth', 'This month',
              const Color(0xFFF59E0B), Icons.umbrella_rounded),
          SizedBox(width: 10.w),
          _buildStatCard('NOTICES', '$_localNoticesCount', 'New updates',
              const Color(0xFF8B5CF6), Icons.volume_up_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle,
      Color accent, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(year, month),
          _buildWeekdayRow(),
          SizedBox(height: 4.h),
          // Calendar rows
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              children: List.generate(rows, (row) {
                return _buildCalendarRow(row, startOffset, daysInMonth, year, month);
              }),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  // Calendar top bar: < June 2026 > Today  [Month] [List]
  Widget _buildCalendarHeader(int year, int month) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 10.h),
      child: Row(
        children: [
          // Prev button
          _navBtn(Icons.chevron_left_rounded, _goToPreviousMonth),
          SizedBox(width: 8.w),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.3)),
              ),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, size: 14.sp, color: accent),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A))),
          SizedBox(height: 2.h),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Calendar Card ────────────────────────────────────────────────────────────
  Widget _buildCalendarCard() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sunday = 0
    final totalCells = startOffset + daysInMonth;
    final rows = ((totalCells) / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Calendar Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: Row(
              children: [
                // Month nav
                GestureDetector(
                  onTap: _goToPreviousMonth,
                  child: Icon(Icons.chevron_left_rounded,
                      size: 22.sp, color: const Color(0xFF475569)),
                ),
                SizedBox(width: 12.w),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A)),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: _goToNextMonth,
                  child: Icon(Icons.chevron_right_rounded,
                      size: 22.sp, color: const Color(0xFF475569)),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: _goToToday,
                  child: Text('Today',
                      style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0066CC))),
                ),
                const Spacer(),
                // Month / List toggle
                Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      _toggleButton('Month', _isMonthView,
                          () => setState(() => _isMonthView = true)),
                      _toggleButton('List', !_isMonthView,
                          () => setState(() => _isMonthView = false)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Next button
          _navBtn(Icons.chevron_right_rounded, _goToNextMonth),
          SizedBox(width: 12.w),
          // Today link
          GestureDetector(
            onTap: _goToToday,
            child: Text(
              'Today',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0066CC),

          if (_isMonthView) ...[
            // Day-of-week headers
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF94A3B8))),
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 8.h),

            // Calendar Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: List.generate(rows, (row) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      children: List.generate(7, (col) {
                        final cellIndex = row * 7 + col;
                        final day = cellIndex - startOffset + 1;

                        if (day < 1 || day > daysInMonth) {
                          return Expanded(child: SizedBox(height: 44.h));
                        }

                        final now = DateTime.now();
                        final isToday = day == now.day &&
                            month == now.month &&
                            year == now.year;
                        final isSelected = _selectedDay != null &&
                            day == _selectedDay!.day &&
                            month == _selectedDay!.month &&
                            year == _selectedDay!.year;

                        final dayEventsRaw =
                            _getEventsForDay(year, month, day);
                        final hasEvents = dayEventsRaw.isNotEmpty;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedDay = DateTime(year, month, day)),
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? const Color(0xFF0066CC)
                                    : isSelected
                                        ? const Color(0xFFEFF6FF)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                                border: isSelected && !isToday
                                    ? Border.all(
                                        color: const Color(0xFF3B82F6),
                                        width: 1.5)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$day',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isToday
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  if (hasEvents) ...[
                                    SizedBox(height: 3.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: dayEventsRaw
                                          .take(3)
                                          .map((e) => Container(
                                                width: 4.w,
                                                height: 4.h,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 1.w),
                                                decoration: BoxDecoration(
                                                  color: isToday
                                                      ? Colors.white
                                                      : _typeColor(
                                                          e['type']
                                                              ?.toString()),
                                                  shape: BoxShape.circle,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 12.h),

            // Selected day events list
            if (_selectedDay != null) ...[
              const Divider(color: Color(0xFFE2E8F0), thickness: 1),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: _buildSelectedDayEvents(),
              ),
            ],
          ] else ...[
            // List view
            Padding(
              padding: EdgeInsets.all(16.r),
              child: _buildListView(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    final d = _selectedDay!;
    final events = _getEventsForDay(d.year, d.month, d.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events for ${DateFormat('EEEE, d MMMM').format(d)}',
          style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF475569),
              letterSpacing: 0.5),
        ),
        SizedBox(height: 10.h),
        if (events.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 32.sp, color: const Color(0xFFCBD5E1)),
                  SizedBox(height: 8.h),
                  Text('No events scheduled',
                      style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )
        else
          ...events.map((event) => _buildEventTile(event)),
      ],
    );
  }

  Widget _buildListView() {
    final upcoming = _upcomingEventsList;
    if (upcoming.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 36.sp, color: const Color(0xFFCBD5E1)),
              SizedBox(height: 12.h),
              Text('No upcoming events in the next 90 days',
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic)),
            ],
          ),
          const Spacer(),
          // Month / List toggle
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                _toggleBtn('Month', _isMonthView,
                    () => setState(() => _isMonthView = true)),
                _toggleBtn('List', !_isMonthView,
                    () => setState(() => _isMonthView = false)),
              ],
            ),
          ),
        ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING EVENTS (NEXT 90 DAYS)',
          style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1),
        ),
        SizedBox(height: 12.h),
        ...upcoming.map((event) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildEventTile(event),
            )),
      ],
    );
  }

  Widget _buildEventTile(dynamic event) {
    final type = (event['type'] ?? 'EVENT').toString().toUpperCase();
    final accent = _typeColor(event['type']?.toString());
    DateTime? date;
    try {
      date = DateTime.parse(event['date'].toString()).toLocal();
    } catch (_) {}

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.w, color: accent),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    children: [
                      // Date badge
                      if (date != null)
                        Container(
                          width: 40.w,
                          margin: EdgeInsets.only(right: 12.w),
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('d').format(date),
                                style: GoogleFonts.outfit(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: accent),
                              ),
                              Text(
                                DateFormat('MMM').format(date).toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w700,
                                    color: accent),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    event['title'] ?? 'Event',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A)),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(type,
                                      style: GoogleFonts.inter(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w800,
                                          color: accent)),
                                ),
                              ],
                            ),
                            if (event['description'] != null &&
                                event['description'].toString().isNotEmpty) ...[
                              SizedBox(height: 3.h),
                              Text(
                                event['description'].toString(),
                                style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF475569)),
        ),
      );

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0066CC) : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // SUN MON TUE WED THU FRI SAT
  Widget _buildWeekdayRow() {
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // One row of 7 cells
  Widget _buildCalendarRow(
      int row, int startOffset, int daysInMonth, int year, int month) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(7, (col) {
          final cellIndex = row * 7 + col;
          final day = cellIndex - startOffset + 1;

          if (day < 1 || day > daysInMonth) {
            // Empty cell
            return Expanded(
              child: Container(
                margin: EdgeInsets.all(1.r),
                constraints: BoxConstraints(minHeight: 54.h),
              ),
            );
          }

          final now       = DateTime.now();
          final isToday   = day == now.day && month == now.month && year == now.year;
          final isSelected = _selectedDay != null &&
              day == _selectedDay!.day &&
              month == _selectedDay!.month &&
              year == _selectedDay!.year;

          final dayEvents = _eventsForDay(year, month, day);
          final hasEvents = dayEvents.isNotEmpty;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = DateTime(year, month, day)),
              child: Container(
                margin: EdgeInsets.all(1.r),
                constraints: BoxConstraints(minHeight: 54.h),
                decoration: BoxDecoration(
                  color: isSelected && !isToday
                      ? const Color(0xFFEFF6FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  border: isSelected && !isToday
                      ? Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                          width: 1)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day number row
                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: isToday
                                ? const BoxDecoration(
                                    color: Color(0xFF0066CC),
                                    shape: BoxShape.circle,
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '$day',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: isToday || isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isToday
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                          if (hasEvents)
                            Expanded(
                              child: Text(
                                '${dayEvents.length} ${dayEvents.length == 1 ? 'Item' : 'Items'}',
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Event chips
                    if (hasEvents && _isMonthView) ...[
                      for (final ev in dayEvents.take(2))
                        _buildEventChip(ev),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventChip(CalendarEvent ev) {
    return Container(
      margin: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: ev.type.bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        ev.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 7.5.sp,
          fontWeight: FontWeight.w600,
          color: ev.type.color,
        ),
      ),
    );
  }

  // ── Event Horizons Panel ───────────────────────────────────────────────────
  Widget _buildEventHorizons() {
    final horizons = _monthEventHorizons;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1437),
        borderRadius: BorderRadius.circular(18.r),
      ),
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
  // ── Bottom Cards: Event Horizons + Legend ─────────────────────────────────
  Widget _buildBottomCards(bool isDesktop) {
    final upcomingList = _upcomingEventsList.take(5).toList();

    final children = [
      // Event Horizons (real data)
      Expanded(
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFF0B132B),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  size: 16.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Horizons',
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Chronological list of milestones',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 18.h),

          if (horizons.isEmpty) ...[
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 30.sp, color: const Color(0xFF1C2541)),
                    SizedBox(height: 8.h),
                    Text(
                      'No events this month',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            for (int i = 0; i < horizons.length; i++) ...[
              _buildHorizonItem(horizons[i].key, horizons[i].value,
                  isLast: i == horizons.length - 1),
                  Icon(Icons.calendar_month_rounded,
                      size: 18.sp, color: const Color(0xFF475569)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event Horizons',
                            style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        SizedBox(height: 1.h),
                        Text('Chronological list of milestones',
                            style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (upcomingList.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 28.sp, color: const Color(0xFF1C2541)),
                      SizedBox(height: 8.h),
                      Text('No records in ledger',
                          style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF475569))),
                    ],
                  ),
                )
              else
                ...upcomingList.map((event) {
                  final accent = _typeColor(event['type']?.toString());
                  DateTime? date;
                  try {
                    date =
                        DateTime.parse(event['date'].toString()).toLocal();
                  } catch (_) {}
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? 'Event',
                                style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (date != null)
                                Text(
                                  DateFormat('EEE, d MMM yyyy').format(date),
                                  style: GoogleFonts.inter(
                                      fontSize: 9.sp,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildHorizonItem(DateTime date, CalendarEvent event,
      {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: event.type.color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5.w,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              Text('Institutional Legend',
                  style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A))),
              SizedBox(height: 12.h),
              _legendItem(const Color(0xFFEF4444), 'Holiday'),
              SizedBox(height: 8.h),
              _legendItem(const Color(0xFF3B82F6), 'Event'),
              SizedBox(height: 8.h),
              _legendItem(const Color(0xFFF59E0B), 'Exam'),
              SizedBox(height: 8.h),
              _legendItem(const Color(0xFF8B5CF6), 'Emergency'),
              SizedBox(height: 8.h),
              _legendItem(const Color(0xFF94A3B8), 'Notice'),
            ],
          ),
          SizedBox(width: 12.w),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('d MMM').format(date),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: event.type.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          event.type.label,
                          style: GoogleFonts.inter(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w700,
                            color: event.type.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    event.title,
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (event.time != null) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 10.sp, color: const Color(0xFF64748B)),
                        SizedBox(width: 3.w),
                        Text(
                          event.time!,
                          style: GoogleFonts.inter(
                            fontSize: 9.5.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Institutional Legend ───────────────────────────────────────────────────
  Widget _buildLegend() {
    const items = [
      (Color(0xFFEF4444), 'Holiday'),
      (Color(0xFF3B82F6), 'Event'),
      (Color(0xFFF59E0B), 'Exam'),
      (Color(0xFF8B5CF6), 'Emergency'),
      (Color(0xFF94A3B8), 'Notice'),
    ];

    ];

    return Row(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569))),
      ],
    );
  }

  // ── Bottom Stats Bar ────────────────────────────────────────────────────────
  Widget _buildBottomStatsBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSTITUTIONAL LEGEND',
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 20.w,
            runSpacing: 10.h,
            children: items
                .map((item) => _legendItem(item.$1, item.$2))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
          _bottomStat(Icons.calendar_today_rounded, '$_eventsToday',
              'Events Today', const Color(0xFF3B82F6)),
          _bottomStat(Icons.calendar_today_outlined, '$_upcomingCount',
              'Upcoming', const Color(0xFF10B981)),
          _bottomStat(Icons.umbrella_rounded, '$_holidaysThisMonth',
              'Holidays', const Color(0xFFF59E0B)),
          _bottomStat(Icons.volume_up_outlined, '$_localNoticesCount',
              'Notices', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _bottomStat(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A))),
          ],
        ),
        SizedBox(height: 2.h),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8))),
      ],
    );
  }
}
