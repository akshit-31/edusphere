const fs = require('fs');

const path = 'lib/screens/features/create_assignment_screen.dart';
let content = fs.readFileSync(path, 'utf8');

// Normalize CRLF to LF
content = content.replace(/\r\n/g, '\n');

// Helper to replace and print status
function doReplace(label, target, replacement) {
  const normTarget = target.replace(/\r\n/g, '\n');
  if (content.includes(normTarget)) {
    content = content.replace(normTarget, replacement);
    console.log(`✅ Success: ${label}`);
  } else {
    console.log(`❌ Target NOT found: ${label}`);
  }
}

// 1. Add import for url_launcher
doReplace(
  '1. Import url_launcher',
  "import 'package:flutter/material.dart';",
  "import 'package:flutter/material.dart';\nimport 'package:url_launcher/url_launcher.dart';"
);

// 2. Modify _loadAllData assignment mapping
doReplace(
  '2. _loadAllData mapping',
  `      final List<Map<String, dynamic>> temp = raw.map((row) {
        final subject = row['subject'] as Map<String, dynamic>?;
        final cls = row['class'] as Map<String, dynamic>?;
        final section = row['section'] as Map<String, dynamic>?;
        final count = row['_count']?['submissions'] ?? 0;
        return {
          'id': row['id'],
          'title': row['title'] ?? 'Untitled',
          'subject': subject?['name'] ?? 'General',
          'class_name': cls?['name'] ?? 'N/A',
          'section': section?['name'] ?? 'All',
          'due_date': row['dueDate'] != null
              ? _formatDueDate(row['dueDate'] as String)
              : 'No Due Date',
          'submissions_count': count,
          'description': row['description'] ?? '',
        };
      }).toList();`,
  `      final List<Map<String, dynamic>> temp = raw.map((row) {
        final subject = row['subject'] as Map<String, dynamic>?;
        final cls = row['class'] as Map<String, dynamic>?;
        final section = row['section'] as Map<String, dynamic>?;
        final count = row['_count']?['submissions'] ?? 0;
        
        // Resolve teacher name
        String tName = _teacherName;
        final teacherUser = row['teacher']?['user'] as Map<String, dynamic>?;
        if (teacherUser != null) {
          final fn = teacherUser['firstName'] as String? ?? '';
          final ln = teacherUser['lastName'] as String? ?? '';
          if ('$fn $ln'.trim().isNotEmpty) {
            tName = '$fn $ln'.trim();
          }
        }
        
        return {
          'id': row['id'],
          'title': row['title'] ?? 'Untitled',
          'subject': subject?['name'] ?? 'General',
          'class_name': cls?['name'] ?? 'N/A',
          'section': section?['name'] ?? 'All',
          'due_date': row['dueDate'] != null
              ? _formatDueDate(row['dueDate'] as String)
              : 'No Due Date',
          'submissions_count': count,
          'description': row['description'] ?? '',
          'fileName': row['fileName'] ?? '',
          'filePath': row['filePath'] ?? '',
          'createdAt': row['createdAt'] ?? '',
          'teacher_name': tName,
        };
      }).toList();`
);

// 3. Replaces chosenSection declaration
doReplace(
  '3. chosenSection declaration',
  `    Map<String, dynamic>? chosenSection;`,
  `    String? chosenSectionName;`
);

// 4. Class dropdown in dialog
doReplace(
  '4. Class dropdown in dialog',
  `                                           DropdownButtonFormField<
                                               Map<String, dynamic>>(
                                             initialValue: chosenClass,
                                             decoration:
                                                 dropDeco('Select Class'),
                                             style: AppTypography.caption
                                                 .copyWith(
                                                     color: const Color(
                                                         0xFF0F172A)),
                                             isExpanded: true,
                                             items: _classes
                                                 .map((cls) => DropdownMenuItem(
                                                       value: cls,
                                                       child: Text(
                                                           cls['name']
                                                                   as String? ??
                                                               '',
                                                           style: AppTypography
                                                               .caption
                                                               .copyWith(
                                                                   color: const Color(
                                                                       0xFF0F172A))),
                                                     ))
                                                 .toList(),
                                             onChanged: (val) =>
                                                 setDialogState(() {
                                               chosenClass = val;
                                               chosenSection = null;
                                             }),
                                           ),`,
  `                                           DropdownButtonFormField<
                                               Map<String, dynamic>>(
                                             value: chosenClass,
                                             decoration:
                                                 dropDeco('Select Class'),
                                             style: AppTypography.caption
                                                 .copyWith(
                                                     color: const Color(
                                                         0xFF0F172A)),
                                             isExpanded: true,
                                             items: _classes
                                                 .map((cls) => DropdownMenuItem(
                                                       value: cls,
                                                       child: Text(
                                                           cls['name']
                                                                   as String? ??
                                                               '',
                                                           style: AppTypography
                                                               .caption
                                                               .copyWith(
                                                                   color: const Color(
                                                                       0xFF0F172A))),
                                                     ))
                                                 .toList(),
                                             onChanged: (val) =>
                                                 setDialogState(() {
                                               chosenClass = val;
                                               chosenSectionName = null;
                                               chosenSubject = null;
                                             }),
                                           ),`
);

// 5. Section dropdown in dialog
doReplace(
  '5. Section dropdown in dialog',
  `                                           DropdownButtonFormField<
                                               Map<String, dynamic>?>(
                                             initialValue: chosenSection,
                                             decoration:
                                                 dropDeco('All Sections'),
                                             style: AppTypography.caption
                                                 .copyWith(
                                                     color: const Color(
                                                         0xFF0F172A)),
                                             isExpanded: true,
                                             items: [
                                               DropdownMenuItem<
                                                   Map<String, dynamic>?>(
                                                 value: null,
                                                 child: Text('All Sections',
                                                     style: AppTypography.caption
                                                         .copyWith(
                                                             color: const Color(
                                                                 0xFF94A3B8))),
                                               ),
                                               ..._sections.map((sec) =>
                                                   DropdownMenuItem<
                                                       Map<String, dynamic>?>(
                                                     value: sec,
                                                     child: Text(
                                                         sec['name']
                                                                 as String? ??
                                                             '',
                                                         style: AppTypography
                                                             .caption
                                                             .copyWith(
                                                                 color: const Color(
                                                                     0xFF0F172A))),
                                                   )),
                                             ],
                                             onChanged: (val) => setDialogState(
                                                 () => chosenSection = val),
                                           ),`,
  `                                           DropdownButtonFormField<String?>(
                                             value: chosenSectionName,
                                             decoration:
                                                 dropDeco('All Sections'),
                                             style: AppTypography.caption
                                                 .copyWith(
                                                     color: const Color(
                                                         0xFF0F172A)),
                                             isExpanded: true,
                                             items: [
                                               DropdownMenuItem<String?>(
                                                 value: null,
                                                 child: Text('All Sections',
                                                     style: AppTypography.caption
                                                         .copyWith(
                                                             color: const Color(
                                                                 0xFF94A3B8))),
                                               ),
                                               ...(() {
                                                 final sortedSecs = _sections
                                                     .map((sec) => sec['name'] as String? ?? '')
                                                     .where((name) => name.isNotEmpty && name != 'C')
                                                     .toSet()
                                                     .toList();
                                                 sortedSecs.sort();
                                                 return sortedSecs.map((name) => DropdownMenuItem<String?>(
                                                       value: name,
                                                       child: Text(name,
                                                           style: AppTypography.caption
                                                               .copyWith(
                                                                   color: const Color(
                                                                       0xFF0F172A))),
                                                     ));
                                               })(),
                                             ],
                                             onChanged: (val) => setDialogState(
                                                 () => chosenSectionName = val),
                                           ),`
);

// 6. Subject dropdown in dialog
doReplace(
  '6. Subject dropdown in dialog',
  `                                           DropdownButtonFormField<
                                               Map<String, dynamic>>(
                                             initialValue: chosenSubject,
                                             decoration:
                                                 dropDeco('Select Subject'),
                                             style: AppTypography.caption
                                                 .copyWith(
                                                     color: const Color(
                                                         0xFF0F172A)),
                                             isExpanded: true,
                                             items: _subjects
                                                 .map((s) => DropdownMenuItem(
                                                       value: s,
                                                       child: Text(
                                                           s['name']
                                                                   as String? ??
                                                               '',
                                                           style: AppTypography
                                                               .caption
                                                               .copyWith(
                                                                   color: const Color(
                                                                       0xFF0F172A))),
                                                     ))
                                                 .toList(),
                                             onChanged: (val) => setDialogState(
                                                 () => chosenSubject = val),
                                           ),`,
  `                                           DropdownButtonFormField<
                                               Map<String, dynamic>>(
                                             value: chosenSubject,
                                             decoration:
                                                 dropDeco('Select Subject'),
                                             style: AppTypography.caption
                                                 .copyWith(
                                                     color: const Color(
                                                         0xFF0F172A)),
                                             isExpanded: true,
                                             items: (() {
                                               if (chosenClass == null) return <DropdownMenuItem<Map<String, dynamic>>>[];
                                               final classIdStr = chosenClass!['id']?.toString() ?? '';
                                               final filteredList = _subjects
                                                   .where((s) => s['classId']?.toString() == classIdStr)
                                                   .toList();
                                               final seenNames = <String>{};
                                               final deduplicated = <Map<String, dynamic>>[];
                                               for (var s in filteredList) {
                                                 final name = s['name'] as String? ?? '';
                                                 if (name.isNotEmpty && !seenNames.contains(name)) {
                                                   seenNames.add(name);
                                                   deduplicated.add(s);
                                                 }
                                               }
                                               return deduplicated.map((s) => DropdownMenuItem<Map<String, dynamic>>(
                                                     value: s,
                                                     child: Text(
                                                         s['name'] as String? ?? '',
                                                         style: AppTypography.caption
                                                             .copyWith(
                                                                 color: const Color(
                                                                     0xFF0F172A))),
                                                   )).toList();
                                             })(),
                                             onChanged: (val) => setDialogState(
                                                 () => chosenSubject = val),
                                           ),`
);

// 7. Submit logic in dialog
doReplace(
  '7. Submit resolution',
  `                                            final result = await ApiService
                                                .instance
                                                .post('assignments', body: {
                                              'title': titleCtrl.text.trim(),
                                              'description': descCtrl.text.trim(),
                                              'dueDate': fmtDue,
                                              'subjectId': chosenSubject!['id'],
                                              'classId': chosenClass!['id'],
                                              if (chosenSection != null)
                                                'sectionId': chosenSection!['id'],
                                            });`,
  `                                            String? resolvedSectionId;
                                            if (chosenClass != null && chosenSectionName != null) {
                                              final match = _sections.firstWhere(
                                                (sec) => sec['classId']?.toString() == chosenClass['id']?.toString() &&
                                                         sec['name']?.toString() == chosenSectionName,
                                                orElse: () => <String, dynamic>{},
                                              );
                                              if (match.isNotEmpty) {
                                                resolvedSectionId = match['id']?.toString();
                                              }
                                            }

                                            final result = await ApiService
                                                .instance
                                                .post('assignments', body: {
                                              'title': titleCtrl.text.trim(),
                                              'description': descCtrl.text.trim(),
                                              'dueDate': fmtDue,
                                              'subjectId': chosenSubject!['id'],
                                              'classId': chosenClass!['id'],
                                              if (resolvedSectionId != null)
                                                'sectionId': resolvedSectionId,
                                            });`
);

// 8. View button tap handler
doReplace(
  '8. View button tap handler',
  `                        GestureDetector(
                          onTap: () => _selectAssignment(a),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 5.h),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(6.r),
                                color: Colors.white),
                            child: Text('View',
                                style: AppTypography.caption
                                    .copyWith(color: const Color(0xFF334155))),
                          ),
                        ),`,
  `                        GestureDetector(
                          onTap: () {
                            _selectAssignment(a);
                            _showAssignmentDetailsBottomSheet(context, a);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 5.h),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(6.r),
                                color: Colors.white),
                            child: Text('View',
                                style: AppTypography.caption
                                    .copyWith(color: const Color(0xFF334155))),
                          ),
                        ),`
);

// 9. Modal details helper method
doReplace(
  '9. Modal details bottom sheet helper methods',
  `  Future<void> _selectAssignment(Map<String, dynamic> assignment) async {
    setState(() {
      _selectedAssignment = assignment;
      _isLoadingSubmissions = true;
    });
    final subs = await _fetchSubmissions(assignment['id'] as String);
    if (mounted) {
      setState(() {
        _submissionsList.clear();
        _submissionsList.addAll(subs);
        _isLoadingSubmissions = false;
      });
    }
  }`,
  `  Future<void> _selectAssignment(Map<String, dynamic> assignment) async {
    setState(() {
      _selectedAssignment = assignment;
      _isLoadingSubmissions = true;
    });
    final subs = await _fetchSubmissions(assignment['id'] as String);
    if (mounted) {
      setState(() {
        _submissionsList.clear();
        _submissionsList.addAll(subs);
        _isLoadingSubmissions = false;
      });
    }
  }

  Future<void> _downloadFile(String filePath, String fileName) async {
    try {
      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showToast(context, 'Could not open file URL', isError: true);
      }
    } catch (e) {
      showToast(context, 'Error opening file: $e', isError: true);
    }
  }

  void _showAssignmentDetailsBottomSheet(BuildContext context, Map<String, dynamic> a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              a['title'] ?? 'Untitled Assignment',
              style: AppTypography.small.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            if (a['description'] != null && a['description'].toString().isNotEmpty) ...[
              Text(
                a['description'],
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            const Divider(color: Color(0xFFE2E8F0)),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.class_outlined, 'Class', a['class_name'] ?? 'N/A'),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.layers_outlined, 'Section', a['section'] ?? 'All'),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.book_outlined, 'Subject', a['subject'] ?? 'General'),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.calendar_today_outlined, 'Due Date', a['due_date'] ?? 'No Due Date'),
            SizedBox(height: 12.h),
            _buildDetailRow(
              Icons.create_new_folder_outlined, 
              'Creation Date', 
              a['createdAt'] != null && a['createdAt'].toString().isNotEmpty
                  ? _formatDueDate(a['createdAt'] as String)
                  : 'N/A'
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.person_outline_rounded, 'Teacher', a['teacher_name'] ?? 'Emma Johnson'),
            SizedBox(height: 12.h),
            _buildDetailRow(
              Icons.info_outline_rounded, 
              'Submission Status', 
              a['submissions_count'] > 0 ? 'Submissions Received' : 'No Submissions Yet'
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.people_outline_rounded, 'Student Submission Count', '\${a['submissions_count']} submissions'),
            if (a['fileName'] != null && a['fileName'].toString().isNotEmpty) ...[
              SizedBox(height: 16.h),
              const Divider(color: Color(0xFFE2E8F0)),
              SizedBox(height: 12.h),
              Text(
                'Attachment',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file_rounded, color: const Color(0xFF1976D2), size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        a['fileName'],
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF0F172A),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (a['filePath'] != null && a['filePath'].toString().isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.download_rounded, color: Color(0xFF1976D2)),
                        onPressed: () => _downloadFile(a['filePath'], a['fileName']),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 10.w),
        Text(
          '\$label:',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }`
);

fs.writeFileSync(path, content, 'utf8');
console.log('Done!');
