import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'create_homework_screen.dart';
import '../../services/homework_service.dart';
import '../../services/cache_service.dart';
import '../../models/homework_model.dart';
import '../../theme/typography.dart';
import '../../widgets/common_widgets.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final Color darkNavy = const Color(0xFF1E40AF);
  final Color accentGreen = const Color(0xFF10B981);
  final Color accentAmber = const Color(0xFFF59E0B);
  
  bool _isLoading = true;
  String _userRole = 'STUDENT';
  List<HomeworkModel> _homeworkList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final user = await CacheService.instance.getUser();
    final role = user?['role']?.toString().toUpperCase() ?? 'STUDENT';
    _userRole = role;

    List<HomeworkModel> list = [];
    if (role == 'TEACHER') {
      list = await HomeworkService.instance.getTeacherHomework();
    } else {
      list = await HomeworkService.instance.getStudentHomework();
    }

    setState(() {
      _homeworkList = list;
      _isLoading = false;
    });
  }

  Future<void> _submitHomeworkFile(String assignmentId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        showToast(context, 'Uploading submission...');
        final fileBytes = result.files.single.bytes ?? 
            File(result.files.single.path!).readAsBytesSync();
        
        final res = await HomeworkService.instance.submitHomework(
          assignmentId: assignmentId,
          fileBytes: fileBytes,
          fileName: result.files.single.name,
        );

        if (res['success'] == true) {
          showToast(context, 'Homework submitted successfully!');
          _loadData();
        } else {
          showToast(context, res['message'] ?? 'Failed to submit homework');
        }
      }
    } catch (e) {
      showToast(context, 'Error picking/uploading file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF)))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _homeworkList.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: EdgeInsets.all(16.r),
                            itemCount: _homeworkList.length,
                            itemBuilder: (context, idx) => _buildHwCard(_homeworkList[idx]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: darkNavy,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          bottom: 20,
          left: 20,
          right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context)),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Homework',
                      style: AppTypography.h4.copyWith(color: Colors.white)),
                  Text(
                    _userRole == 'TEACHER' ? 'Assign & track homework' : 'Your active assignments',
                    style: AppTypography.small.copyWith(color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          ),
          if (_userRole == 'TEACHER')
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateHomeworkScreen()),
              ).then((_) => _loadData()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '+ New',
                  style: AppTypography.small.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 150.h),
        Center(
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'No homework assignments found',
                style: AppTypography.bodyLarge.copyWith(color: Colors.grey.shade600),
              ),
              SizedBox(height: 8.h),
              Text(
                _userRole == 'TEACHER' ? 'Tap + New to create an assignment' : 'Check back later for active assignments',
                style: AppTypography.caption.copyWith(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHwCard(HomeworkModel hw) {
    final bool isSubmitted = hw.submissionStatus == 'SUBMITTED' || hw.submissionStatus == 'GRADED';
    final Color statusColor = hw.submissionStatus == 'GRADED'
        ? accentGreen
        : (isSubmitted ? accentGreen : accentAmber);

    final statusText = hw.submissionStatus ?? 'PENDING';
    final String subjectText = hw.subjectName ?? 'General';
    final String dateText = '${hw.dueDate.day}/${hw.dueDate.month}/${hw.dueDate.year}';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(hw.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
              ),
              if (_userRole != 'TEACHER')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Text(
                    statusText,
                    style: AppTypography.caption.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Subject: $subjectText · Due: $dateText',
            style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
          ),
          if (hw.description != null && hw.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              hw.description!,
              style: AppTypography.small.copyWith(color: Colors.grey.shade700),
            ),
          ],
          if (_userRole == 'TEACHER') ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${hw.createdAt.day}/${hw.createdAt.month}/${hw.createdAt.year}',
                  style: AppTypography.caption.copyWith(color: Colors.grey.shade400),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to assignment details if needed
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'View Submissions',
                      style: AppTypography.caption.copyWith(color: darkNavy, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          ] else ...[
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hw.submissionGrade != null ? 'Grade: ${hw.submissionGrade}' : 'Not graded yet',
                    style: AppTypography.caption.copyWith(color: Colors.grey.shade500),
                  ),
                ),
                if (!isSubmitted)
                  GestureDetector(
                    onTap: () => _submitHomeworkFile(hw.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: darkNavy,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'Submit Work',
                        style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  Text(
                    'Submitted',
                    style: AppTypography.caption.copyWith(color: accentGreen, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
