import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../widgets/common_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  Map<String, dynamic>? _uploading;
  bool _success = false;

  final _pending = [
    {'title': 'Quantum Theory Lab Report', 'subject': 'Physics',          'due': 'Today, 5:00 PM',    'urgent': true},
    {'title': 'Calculus Problem Set #7',   'subject': 'Mathematics',      'due': 'Tomorrow, 11:59 PM','urgent': false},
    {'title': 'Essay: Industrial Revolution','subject': 'History',        'due': 'May 5, 2026',       'urgent': false},
    {'title': 'Python Data Structures',    'subject': 'Computer Science', 'due': 'May 8, 2026',       'urgent': false},
  ];

  final _submitted = [
    {'title': "Newton's Laws Analysis", 'subject': 'Physics',   'submitted': 'Apr 28', 'grade': 'A+', 'score': '95/100'},
    {'title': 'Organic Chemistry Notes', 'subject': 'Chemistry','submitted': 'Apr 25', 'grade': 'A',  'score': '88/100'},
    {'title': 'Shakespeare Essay',       'subject': 'English',  'submitted': 'Apr 20', 'grade': 'B+', 'score': '82/100'},
  ];

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(title: 'Assignments', subtitle: '${_pending.length} pending • ${_submitted.length} submitted', theme: roleThemes['student']!),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.studentPrimary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.studentPrimary,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13.sp),
              tabs: [Tab(text: '📋 Pending (${_pending.length})'), Tab(text: '✅ Submitted (${_submitted.length})')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: _pending.length,
                  itemBuilder: (_, i) {
                    final a = _pending[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: a['urgent'] == true ? Colors.red.shade200 : AppColors.border, width: a['urgent'] == true ? 2 : 1),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (a['urgent'] == true)
                          Row(children: [
                            Icon(Icons.warning_rounded, color: Colors.red, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text('DUE TODAY!', style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w900, color: Colors.red)),
                          ]),
                        if (a['urgent'] == true) SizedBox(height: 8.h),
                        Text(a['title'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, fontSize: 14.sp)),
                        SizedBox(height: 4.h),
                        Text(a['subject'] as String, style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textMedium)),
                        SizedBox(height: 4.h),
                        Text('📅 ${a['due']}', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: a['urgent'] == true ? Colors.red : AppColors.textLight)),
                        SizedBox(height: 14.h),
                        LoadingButton(
                          label: '📤 Upload Submission',
                          color: AppColors.studentPrimary,
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() => _uploading = a);
                              await Future.delayed(const Duration(milliseconds: 1500));
                              if (mounted) {
                                setState(() {
                                  final now = DateTime.now();
                                  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                  final dateStr = '${months[now.month - 1]} ${now.day}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                                  
                                  _submitted.insert(0, {
                                    'title': a['title'] as String,
                                    'subject': a['subject'] as String,
                                    'submitted': dateStr,
                                    'grade': 'Pending',
                                    'score': 'Not Graded',
                                  });
                                  _pending.removeAt(i);
                                  _uploading = null;
                                });
                                showToast(context, 'Successfully submitted ${a['title']}!');
                                await Future.delayed(const Duration(milliseconds: 500));
                                if (mounted) _tab.animateTo(1); // Switch to Submitted tab
                              }
                            } else {
                              showToast(context, 'No file selected');
                            }
                          },
                        ),
                      ]),
                    );
                  },
                ),
                ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: _submitted.length,
                  itemBuilder: (_, i) {
                    final a = _submitted[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, fontSize: 14.sp)),
                          Text('${a['subject']} • Submitted ${a['submitted']}', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textMedium)),
                          SizedBox(height: 8.h),
                          Row(children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16.sp),
                            SizedBox(width: 4.w),
                            Text('Score: ${a['score']}', style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
                          ]),
                        ])),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(color: AppColors.studentLight, borderRadius: BorderRadius.circular(12.r)),
                          child: Text(a['grade']!, style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.studentPrimary)),
                        ),
                      ]),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
