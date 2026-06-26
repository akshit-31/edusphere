const fs = require('fs');
const filepath = 'C:/edusphere/edusphere/lib/screens/profile_screen.dart';
let content = fs.readFileSync(filepath, 'utf8');

// Normalize all CRLF to LF to make replacements line-ending agnostic
content = content.replace(/\r\n/g, '\n');

// Helper to replace block function using brace matching
function replaceBlockFunction(contentStr, targetSig, newContentStr) {
  const lines = contentStr.split('\n');
  let startIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes(targetSig)) {
      startIdx = i;
      break;
    }
  }

  if (startIdx === -1) {
    console.log(`Signature not found: ${targetSig}`);
    return contentStr;
  }

  // Find the first {
  let firstBraceIdx = -1;
  for (let i = startIdx; i < lines.length; i++) {
    if (lines[i].includes('{')) {
      firstBraceIdx = i;
      break;
    }
  }

  if (firstBraceIdx === -1) {
    console.log(`No opening brace found for signature: ${targetSig}`);
    return contentStr;
  }

  let braces = 0;
  let endIdx = -1;
  for (let i = firstBraceIdx; i < lines.length; i++) {
    const opening = (lines[i].match(/\{/g) || []).length;
    const closing = (lines[i].match(/\}/g) || []).length;
    braces += opening - closing;
    if (braces === 0) {
      endIdx = i;
      break;
    }
  }

  if (endIdx === -1) {
    console.log(`No matching closing brace found for signature: ${targetSig}`);
    return contentStr;
  }

  console.log(`Replacing ${targetSig} from line ${startIdx + 1} to ${endIdx + 1}`);
  lines.splice(startIdx, endIdx - startIdx + 1, newContentStr);
  return lines.join('\n');
}

// 1. Update imports
const targetImports = `import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';`;

const replacementImports = `import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile/profile_header.dart';
import 'profile/profile_info_card.dart';
import 'profile/profile_documents.dart';
import 'profile/profile_fees.dart';
import 'profile/profile_transport.dart';
import '../services/cache_service.dart';
import '../services/student_service.dart';`;

content = content.replace(targetImports, replacementImports);

// 2. Add _currentUserId after _studentUserId
content = content.replace("String? _studentUserId;", "String? _studentUserId;\n  String? _currentUserId;");

// 3. Remove _realtimeChannels
content = content.replace("final List<RealtimeChannel> _realtimeChannels = [];\n", "");

// 4. Update initState to synchronously read _currentUserId
const newInitState = `  @override
  void initState() {
    super.initState();
    _currentUserId = CacheService.instance.prefs.getString('user_id');
    if (widget.role == 'teacher') {
      _loadTeacherDataFromSupabase();
      _loadSessionData();
      _connectRealTimeSync();
    } else if (widget.role == 'student') {
      if (widget.studentName != null) {
        _studentName = widget.studentName!;
      }
      if (widget.studentEmail != null) {
        _studentEmail = widget.studentEmail!;
      }
      if (widget.admissionNo != null) {
        _admissionNo = widget.admissionNo!;
      }
      if (widget.studentClass != null) {
        final className = widget.studentClass!;
        if (className.contains(' - ')) {
          final parts = className.split(' - ');
          _studentClass = parts[0];
          _section = parts[1];
        } else {
          _studentClass = className;
        }
      }
      _loadStudentDataFromSupabase();
      _connectRealTimeSync();
    }
  }`;
content = replaceBlockFunction(content, 'void initState()', newInitState);

// 5. Update dispose
const newDispose = `  @override
  void dispose() {
    _profilePollTimer?.cancel();
    _nameCtrl.dispose();
    _designCtrl.dispose();
    _empIdCtrl.dispose();
    _deptCtrl.dispose();
    _expCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }`;
content = replaceBlockFunction(content, 'void dispose()', newDispose);

// 6. Update _loadStudentDataFromSupabase
const newLoadStudent = `  Future<void> _loadStudentDataFromSupabase() async {
    if (!mounted) return;
    setState(() {
      _isProfileLoading = true;
      _hasProfileError = false;
    });

    if (widget.studentId != null) {
      _resetProfileFields();
    }

    try {
      debugPrint(
          '🔍 API Student Profile request initiated. Student ID: \${widget.studentId}');

      final response = widget.studentId != null
          ? await ApiService.instance.get('students/\${widget.studentId}')
          : await ApiService.instance.get('students/me');

      if (response == null ||
          response['success'] != true ||
          response['student'] == null) {
        throw Exception(
            'API details fetch failed or returned invalid response format.');
      }

      final studentResMap = response['student'] as Map<String, dynamic>;
      debugPrint('✅ REST API student details successfully retrieved.');
      final userMap = studentResMap['user'] as Map<String, dynamic>? ?? {};
      final classMap =
          studentResMap['currentClass'] as Map<String, dynamic>? ?? {};
      final sectionMap =
          studentResMap['section'] as Map<String, dynamic>? ?? {};

      final String firstName = userMap['firstName'] as String? ?? '';
      final String lastName = userMap['lastName'] as String? ?? '';
      _studentUserId =
          studentResMap['userId']?.toString() ?? userMap['id']?.toString();

      final classAcademicYear = classMap['academicYear'] as Map? ??
          classMap['AcademicYear'] as Map? ?? {};
      final studentAcademicYear = studentResMap['academicYear'] as Map? ??
          studentResMap['AcademicYear'] as Map? ?? {};
      final prefs = CacheService.instance.prefs;
      final batchFromPrefs = prefs.getString('student_batch');
      final batchValue = classAcademicYear['name'] as String? ??
          studentAcademicYear['name'] as String? ??
          batchFromPrefs ??
          '—';

      setState(() {
        _studentName = '\$firstName \$lastName'.trim();
        if (_studentName.isEmpty) _studentName = widget.studentName ?? '—';

        _studentEmail =
            userMap['email'] as String? ?? widget.studentEmail ?? '—';
        _admissionNo = studentResMap['admissionNumber'] as String? ??
            widget.admissionNo ??
            '—';
        _studentClass =
            classMap['name'] as String? ?? widget.studentClass ?? '—';
        _section = sectionMap['name'] as String? ?? '—';
        _rollNo = studentResMap['rollNumber']?.toString() ?? '—';
        _batch = batchValue;
        _medium = studentResMap['medium'] as String? ?? '—';

        final joinDateStr = studentResMap['joiningDate'] as String?;
        if (joinDateStr != null) {
          try {
            final parsed = DateTime.parse(joinDateStr);
            _studentJoinedDate = '\${parsed.month}/\${parsed.day}/\${parsed.year}';
          } catch (_) {
            _studentJoinedDate = '—';
          }
        } else {
          _studentJoinedDate = '—';
        }

        _emergencyInfo = studentResMap['emergencyPhone'] as String? ?? '—';
        if (_emergencyInfo.isEmpty) _emergencyInfo = '—';

        final rawGender = userMap['gender'] as String? ?? '—';
        if (rawGender.toUpperCase() == 'MALE') {
          _studentGender = 'Male';
        } else if (rawGender.toUpperCase() == 'FEMALE') {
          _studentGender = 'Female';
        } else {
          _studentGender = rawGender;
        }

        final dobStr = userMap['dateOfBirth'] as String?;
        if (dobStr != null) {
          try {
            final parsed = DateTime.parse(dobStr);
            _studentDob =
                '\${parsed.day.toString().padLeft(2, '0')}/\${parsed.month.toString().padLeft(2, '0')}/\${parsed.year}';
          } catch (_) {
            _studentDob = dobStr;
          }
        } else {
          _studentDob = '—';
        }

        _studentBloodGroup = studentResMap['bloodGroup'] as String? ?? '—';
        _religion = studentResMap['religion'] as String? ?? '—';
        _casteGroup = studentResMap['caste'] as String? ?? '—';
        _nationality = studentResMap['nationality'] as String? ?? '—';
        _dbQrCode = userMap['qrCode'] as String?;

        final rawAvatar = userMap['avatar'] ??
            userMap['photoUrl'] ??
            userMap['profileImage']?.toString() ??
            '';
        if (rawAvatar.isNotEmpty) {
          _avatarUrl = (rawAvatar.startsWith('http') ||
                  rawAvatar.startsWith('data:image'))
              ? rawAvatar
              : '\${ApiConfig.serverBaseUrl}\$rawAvatar';
        } else {
          _avatarUrl = null;
        }

        final prefs = CacheService.instance.prefs;
        if (_avatarUrl != null) {
          prefs.setString('student_photo_url', _avatarUrl!);
        } else {
          prefs.remove('student_photo_url');
        }

        _userName = _studentName;
        _email = _studentEmail;
        _phone = userMap['phone'] as String? ?? '—';
        _gender = _studentGender;
        _dob = _studentDob;
        _bloodGroup = _studentBloodGroup;
        _address = userMap['address'] as String? ?? '—';
        _rollNumber = _rollNo;
        _className = sectionMap['name'] != null
            ? '\$_studentClass - \$_section'
            : _studentClass;
        _admissionId = _admissionNo;
        _currentStudentDbId = studentResMap['id']?.toString();
        
        final transportAlloc = studentResMap['transportAllocation'] as Map<String, dynamic>?;
        if (transportAlloc != null) {
          final routeMap = transportAlloc['route'] as Map<String, dynamic>?;
          final stopMap = transportAlloc['stop'] as Map<String, dynamic>?;
          _transportAllocation = {
            'status': transportAlloc['status'],
            'stop': stopMap,
            'route': routeMap,
          };
        } else {
          _transportAllocation = null;
        }
        
        _isProfileLoading = false;
      });

      if (userMap['id'] != null) {
        try {
          final qrRes =
              await ApiService.instance.get('users/\${userMap['id']}/qr');
          if (qrRes != null &&
              qrRes['success'] == true &&
              qrRes['qrCode'] != null) {
            final qr = qrRes['qrCode'] as String?;
            if (qr != null && qr.isNotEmpty) {
              setState(() {
                _dbQrCode = qr;
              });
              await prefs.setString('student_qrcode', qr);
            }
          }
        } catch (e) {
          debugPrint('Error fetching QR from API: \$e');
        }
      }

      final studentId = studentResMap['id'] as String;
      await prefs.setString('student_id', studentId);

      final String? sectionId = studentResMap['sectionId'] as String?;
      _loadAllTabDetails(studentId, sectionId);
      _connectRealTimeSync();

      try {
        final parentsList = studentResMap['parents'] as List<dynamic>? ?? [];
        if (parentsList.isNotEmpty) {
          String father = '—';
          String mother = '—';
          String guardianPhone = '—';

          for (var sp in parentsList) {
            final spMap = sp as Map<String, dynamic>;
            final rel = spMap['relationship'] as String?;
            final parentObj = spMap['parent'] as Map<String, dynamic>?;

            if (parentObj != null) {
              final pFullName =
                  '\${parentObj['firstName'] ?? ''} \${parentObj['lastName'] ?? ''}'
                      .trim();
              final pPhone = parentObj['phone'] as String? ?? '—';
              if (rel == 'FATHER') {
                father = pFullName;
                if (guardianPhone == '—') guardianPhone = pPhone;
              } else if (rel == 'MOTHER') {
                mother = pFullName;
                if (guardianPhone == '—') guardianPhone = pPhone;
              } else {
                if (guardianPhone == '—') guardianPhone = pPhone;
              }
            }
          }

          setState(() {
            _fatherName = father;
            _motherName = mother;
            _guardianPhone = guardianPhone;
          });
        }
      } catch (e) {
        debugPrint('Error parsing parents: \$e');
      }

      try {
        final docsList = studentResMap['documents'] as List<dynamic>? ?? [];
        setState(() {
          _uploadedDocuments = docsList.map((d) {
            final dMap = d as Map<String, dynamic>;
            final String docName =
                dMap['documentName'] as String? ?? 'Document.pdf';
            final String? uploadDateStr = dMap['uploadedAt'] as String?;
            String dateStr = '—';
            if (uploadDateStr != null) {
              try {
                final parsed = DateTime.parse(uploadDateStr);
                dateStr = '\${parsed.month}/\${parsed.day}/\${parsed.year}';
              } catch (_) {}
            }
            return {
              'name': docName,
              'date': dateStr,
              'id': dMap['id']?.toString() ?? '',
            };
          }).toList();
        });
      } catch (e) {
        debugPrint('Error parsing documents: \$e');
      }

      // Merge local documents that might have failed to sync to the server
      try {
        final prefs = CacheService.instance.prefs;
        final localDocsJson = prefs.getString('student_uploaded_documents');
        if (localDocsJson != null) {
          final List<dynamic> localDocsList = json.decode(localDocsJson);
          final currentIds = _uploadedDocuments.map((e) => e['id']).toSet();
          
          bool modified = false;
          for (var ld in localDocsList) {
            final Map<String, String> localDocMap = Map<String, String>.from(ld);
            if (localDocMap['id'] != null && !currentIds.contains(localDocMap['id'])) {
              _uploadedDocuments.add(localDocMap);
              modified = true;
            }
          }
          if (modified && mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        debugPrint('Error merging local docs: \$e');
      }

    } catch (e) {
      debugPrint(
          '🚨 REST Student Profile queries failed. Error: \$e');
      if (widget.studentId != null) {
        setState(() {
          _isProfileLoading = false;
          _hasProfileError = true;
        });
      } else {
        await _loadProfileData();
        setState(() {
          _isProfileLoading = false;
        });
      }
    }
  }`;
content = replaceBlockFunction(content, 'Future<void> _loadStudentDataFromSupabase()', newLoadStudent);

// 7. Update _loadAllTabDetails
const newLoadAllTabDetails = `  Future<void> _loadAllTabDetails(String studentId, String? sectionId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingTabDetails = true;
    });

    // 1. Fetch Attendance Records
    try {
      final attRes =
          await ApiService.instance.get('students/\$studentId/attendance');
      if (attRes != null && attRes['success'] == true && mounted) {
        setState(() {
          _attendanceRecords =
              List<Map<String, dynamic>>.from(attRes['attendance'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error fetching attendance details: \$e');
    }

    // 2. Fetch Fee Ledger and Payments
    try {
      final feeRes =
          await ApiService.instance.get('fees/students/\$studentId/status');
      if (feeRes != null && feeRes['hasLedger'] == true && mounted) {
        final ledgers = feeRes['ledgers'] as List<dynamic>? ?? [];
        final recentPayments = (feeRes['recentPayments'] ?? feeRes['payments'])
                as List<dynamic>? ??
            [];
        setState(() {
          _feeLedger =
              ledgers.isNotEmpty ? Map<String, dynamic>.from(ledgers[0]) : null;
          _feePayments = List<Map<String, dynamic>>.from(recentPayments);
        });
      }
    } catch (e) {
      debugPrint('Error fetching fee details: \$e');
    }

    // 3. Fetch Timetable slots if sectionId is present
    if (sectionId != null) {
      try {
        final timetableRes =
            await ApiService.instance.get('timetable/student/\$sectionId');
        if (timetableRes != null &&
            timetableRes['success'] == true &&
            mounted) {
          final rawSchedule = timetableRes['schedule'] as List<dynamic>? ?? [];
          final Map<int, List<Map<String, dynamic>>> grouped = {};

          for (var slot in rawSchedule) {
            final sMap = slot as Map<String, dynamic>;
            final day = sMap['dayOfWeek'] as int? ?? 1;

            final teacherObj = sMap['teacher'] as Map<String, dynamic>?;
            final userObj = teacherObj?['user'] as Map<String, dynamic>?;
            final roomObj = sMap['room'] as Map<String, dynamic>?;

            final formattedSlot = {
              'dayOfWeek': day,
              'startTime': sMap['startTime'] ?? '—',
              'endTime': sMap['endTime'] ?? '—',
              'period': sMap['period'],
              'durationMinutes': sMap['durationMinutes'],
              'subject': sMap['subject'],
              'teacher': {
                'User': userObj,
              },
              'room': roomObj,
            };
            grouped.putIfAbsent(day, () => []).add(formattedSlot);
          }
          setState(() {
            _timetableSlots = grouped;
          });
        }
      } catch (e) {
        debugPrint('Error fetching timetable details: \$e');
      }
    }

    // 4. Fetch Documents
    try {
      final docRes =
          await ApiService.instance.get('students/\$studentId/documents');
      if (docRes != null && docRes['success'] == true && mounted) {
        final docsList = docRes['documents'] as List<dynamic>? ?? [];
        setState(() {
          _uploadedDocuments = docsList.map((d) {
            final dMap = d as Map<String, dynamic>;
            final String docName =
                dMap['documentName'] as String? ?? 'Document.pdf';
            final String? uploadDateStr = dMap['uploadedAt'] as String?;
            String dateStr = '—';
            if (uploadDateStr != null) {
              try {
                final parsed = DateTime.parse(uploadDateStr);
                dateStr = '\${parsed.month}/\${parsed.day}/\${parsed.year}';
              } catch (_) {}
            }
            return {
              'name': docName,
              'date': dateStr,
              'id': dMap['id']?.toString() ?? '',
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching documents: \$e');
    }

    if (mounted) {
      setState(() {
        _isLoadingTabDetails = false;
      });
    }
  }`;
content = replaceBlockFunction(content, 'Future<void> _loadAllTabDetails(String studentId, String? sectionId)', newLoadAllTabDetails);

// 8. Update _connectRealTimeSync
const newConnectRealtime = `  void _connectRealTimeSync() {
    try {
      _profilePollTimer?.cancel();
      _profilePollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) {
          if (widget.role == 'student') {
            _loadStudentDataFromSupabase();
          } else if (widget.role == 'teacher') {
            _loadTeacherDataFromSupabase();
          }
        }
      });

      // Socket.IO event updates
      SocketService().on('STUDENT_UPDATED', (data) {
        if (!mounted) return;
        try {
          final String? updatedStudentId =
              data?['id']?.toString() ?? data?['studentId']?.toString();
          debugPrint(
              '📡 Socket.IO STUDENT_UPDATED received. Updated Student ID: \$updatedStudentId, Current Viewed ID: \${widget.studentId}');
          if (widget.studentId != null &&
              updatedStudentId == widget.studentId) {
            debugPrint(
                '🔄 Socket.IO student matches viewed student. Reloading...');
            _loadStudentDataFromSupabase();
          } else if (widget.studentId == null && widget.role == 'student') {
            _loadStudentDataFromSupabase();
          }
        } catch (e) {
          debugPrint('Error handling Socket.IO update: \$e');
        }
      });

      SocketService().on('FEE_UPDATED', (data) {
        if (!mounted) return;
        try {
          final String? updatedStudentId =
              data?['id']?.toString() ?? data?['studentId']?.toString();
          if (widget.role == 'student') {
            _loadStudentDataFromSupabase();
          } else if (widget.studentId != null &&
              updatedStudentId == widget.studentId) {
            _loadStudentDataFromSupabase();
          }
        } catch (e) {
          debugPrint('Error handling Socket.IO FEE_UPDATED: \$e');
        }
      });
    } catch (e) {
      debugPrint('⚠️ Error connecting Realtime in ProfileScreen: \$e');
    }
  }`;
content = replaceBlockFunction(content, 'void _connectRealTimeSync()', newConnectRealtime);

// 9. Update _saveStudentDataToSupabase -> rename and implement backend PUT
const newSaveStudent = `  Future<void> _saveStudentDataToBackend() async {
    try {
      final nameParts = _studentName.trim().split(RegExp(r'\\s+'));
      final String first = nameParts.isNotEmpty ? nameParts[0] : '';
      final String last = nameParts.length >= 2 ? nameParts.sublist(1).join(' ') : '';

      String? dbGender;
      if (_studentGender.toUpperCase().startsWith('M')) {
        dbGender = 'MALE';
      } else if (_studentGender.toUpperCase().startsWith('F')) {
        dbGender = 'FEMALE';
      }

      String? dbDob;
      if (_studentDob.isNotEmpty && _studentDob != '—') {
        try {
          if (_studentDob.contains('/')) {
            final dobParts = _studentDob.split('/');
            if (dobParts.length == 3) {
              dbDob = '\${dobParts[2]}-\${dobParts[1].padLeft(2, '0')}-\${dobParts[0].padLeft(2, '0')}';
            }
          } else {
            dbDob = DateTime.parse(_studentDob).toIso8601String().split('T').first;
          }
        } catch (_) {
          dbDob = null;
        }
      }

      final updatePayload = {
        'firstName': first,
        'lastName': last,
        'phone': _phone,
        'address': _address,
        if (dbGender != null) 'gender': dbGender,
        if (dbDob != null) 'dateOfBirth': dbDob,
        'bloodGroup': _studentBloodGroup == '—' || _studentBloodGroup == 'N/A' ? null : _studentBloodGroup,
        'emergencyPhone': _emergencyInfo == '—' || _emergencyInfo == 'UNSET' ? null : _emergencyInfo,
        'religion': _religion == '—' ? null : _religion.toUpperCase(),
        'caste': _casteGroup == '—' ? null : _casteGroup.toUpperCase(),
        'nationality': _nationality == '—' ? null : _nationality.toUpperCase(),
      };

      if (widget.studentId != null) {
        await ApiService.instance.put('students/\${widget.studentId}', body: updatePayload);
      } else {
        await ApiService.instance.put('users/me', body: updatePayload);
      }
      
      debugPrint('✅ Student profile successfully saved to backend.');
    } catch (e) {
      debugPrint('Error saving student profile to Backend: \$e');
    }
  }`;
content = replaceBlockFunction(content, 'Future<void> _saveStudentDataToSupabase()', newSaveStudent);

// 10. Update _saveTeacherDataToSupabase -> rename and implement backend PUT
const newSaveTeacher = `  Future<void> _saveTeacherDataToBackend(Map<String, String> data) async {
    try {
      final Map<String, dynamic> userUpdates = {};
      if (data.containsKey('name')) {
        final parts = data['name']!.split(' ');
        userUpdates['firstName'] = parts.first;
        userUpdates['lastName'] = parts.skip(1).join(' ');
      }
      if (data.containsKey('phone')) userUpdates['phone'] = data['phone'];
      if (data.containsKey('gender')) {
        userUpdates['gender'] = data['gender']!.toUpperCase().startsWith('M') ? 'MALE' : 'FEMALE';
      }
      if (data.containsKey('dob')) {
        try {
          final parts = data['dob']!.split('/');
          if (parts.length == 3) {
            userUpdates['dateOfBirth'] =
                '\${parts[2]}-\${parts[1].padLeft(2, '0')}-\${parts[0].padLeft(2, '0')}';
          } else {
            userUpdates['dateOfBirth'] =
                DateTime.parse(data['dob']!).toIso8601String();
          }
        } catch (_) {
          userUpdates['dateOfBirth'] = data['dob'];
        }
      }
      if (data.containsKey('bloodGroup')) {
        userUpdates['bloodGroup'] = data['bloodGroup'];
      }
      if (data.containsKey('address')) userUpdates['address'] = data['address'];

      if (data.containsKey('designation')) {
        userUpdates['specialization'] = data['designation'];
      }
      if (data.containsKey('department')) {
        userUpdates['qualification'] = data['department'];
      }

      await ApiService.instance.put('users/me', body: userUpdates);
      debugPrint('✅ Teacher profile successfully saved to backend.');
    } catch (e) {
      debugPrint('Error saving teacher profile to Backend: \$e');
    }
  }`;
content = replaceBlockFunction(content, 'Future<void> _saveTeacherDataToSupabase(Map<String, String> data)', newSaveTeacher);

// 11. Update _loadTeacherDataFromSupabase
const newLoadTeacher = `  Future<void> _loadTeacherDataFromSupabase() async {
    try {
      final prefs = CacheService.instance.prefs;
      String? currentUserId = widget.teacherId ?? _currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        currentUserId = prefs.getString('user_id');
      }

      if (currentUserId == null || currentUserId.isEmpty) {
        await _loadProfileData();
        return;
      }

      // Fetch teacher list from Render API
      final teachersData = await ApiService.instance.get('teachers');
      if (teachersData == null || teachersData['success'] != true) {
        await _loadProfileData();
        return;
      }

      final teachersList = teachersData['teachers'] as List? ?? [];
      final teacherMap = teachersList.firstWhere(
        (t) => t['userId'] == currentUserId,
        orElse: () => null,
      ) as Map<String, dynamic>?;

      if (teacherMap == null) {
        await _loadProfileData();
        return;
      }

      final userMap = teacherMap['user'] as Map<String, dynamic>? ?? {};

      // Fetch QR Code from Render API specifically
      String? qrCode;
      try {
        final qrRes = await ApiService.instance.get('users/\$currentUserId/qr');
        if (qrRes != null &&
            qrRes['success'] == true &&
            qrRes['qrCode'] != null) {
          qrCode = qrRes['qrCode'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching teacher QR from API: \$e');
      }

      setState(() {
        final String firstName = userMap['firstName'] as String? ?? '';
        final String lastName = userMap['lastName'] as String? ?? '';
        _userName = '\$firstName \$lastName'.trim();
        if (_userName.isEmpty) _userName = 'Vikram Yadav';
        _email = userMap['email'] as String? ?? '';
        _phone = userMap['phone'] as String? ?? 'N/A';

        final rawAvatar = userMap['avatar']?.toString() ?? '';
        if (rawAvatar.isNotEmpty) {
          _avatarUrl = (rawAvatar.startsWith('http') ||
                  rawAvatar.startsWith('data:image'))
              ? rawAvatar
              : '\${ApiConfig.serverBaseUrl}\$rawAvatar';
        } else {
          _avatarUrl = null;
        }
        
        final prefs = CacheService.instance.prefs;
        if (_avatarUrl != null) {
          prefs.setString('teacher_photo_url', _avatarUrl!);
        } else {
          prefs.remove('teacher_photo_url');
        }

        final rawGender = userMap['gender'] as String? ?? 'Not Specified';
        if (rawGender.toUpperCase() == 'MALE') {
          _gender = 'Male';
        } else if (rawGender.toUpperCase() == 'FEMALE') {
          _gender = 'Female';
        } else {
          _gender = rawGender;
        }

        final dobStr = userMap['dateOfBirth'] as String?;
        if (dobStr != null) {
          try {
            final parsed = DateTime.parse(dobStr);
            _dob =
                '\${parsed.day.toString().padLeft(2, '0')}/\${parsed.month.toString().padLeft(2, '0')}/\${parsed.year}';
          } catch (_) {
            _dob = dobStr;
          }
        } else {
          _dob = 'Not set';
        }

        _bloodGroup = userMap['bloodGroup'] as String? ?? 'Not assigned';
        _address = userMap['address'] as String? ?? 'No location registered';

        final lastPwdStr = userMap['lastPasswordChange'] as String?;
        if (lastPwdStr != null) {
          try {
            final parsed = DateTime.parse(lastPwdStr);
            _lastPasswordChange =
                '\${parsed.day.toString().padLeft(2, '0')}/\${parsed.month.toString().padLeft(2, '0')}/\${parsed.year}';
          } catch (_) {
            _lastPasswordChange = lastPwdStr;
          }
        }

        _dbQrCode = qrCode ?? userMap['qrCode'] as String?;

        _employeeId = teacherMap['employeeId'] as String? ?? 'ID_PENDING';
        _designation = teacherMap['specialization'] as String? ?? 'TEACHER';
        _department = teacherMap['qualification'] as String? ?? 'CORE_SYSTEM';

        final rawExp = teacherMap['experience']?.toString();
        _experience =
            (rawExp != null && rawExp.isNotEmpty) ? '\$rawExp Years' : 'N/A';

        final joinDateStr = teacherMap['joiningDate'] as String?;
        if (joinDateStr != null) {
          try {
            final parsed = DateTime.parse(joinDateStr);
            _joinedDate =
                '\${parsed.day.toString().padLeft(2, '0')}/\${parsed.month.toString().padLeft(2, '0')}/\${parsed.year}';
          } catch (_) {
            _joinedDate = joinDateStr;
          }
        }

        // Sync local variables which are shared with the QR identity card
        _studentName = _userName;
        _admissionNo = _employeeId;
      });

      if (widget.teacherId == null || widget.teacherId == _currentUserId) {
        await prefs.setString('teacher_name', _userName);
        await prefs.setString('teacher_email', _email);
        await prefs.setString('teacher_mobile', _phone);
        await prefs.setString('teacher_gender', _gender);
        await prefs.setString('teacher_dob', _dob);
        await prefs.setString('teacher_blood', _bloodGroup);
        await prefs.setString('teacher_address', _address);
        await prefs.setString('teacher_emp_id', _employeeId);
        await prefs.setString('teacher_design', _designation);
        await prefs.setString('teacher_dept', _department);
        await prefs.setString('teacher_exp', _experience);
        if (_dbQrCode != null) {
          await prefs.setString('teacher_qrcode', _dbQrCode!);
        }
      }
    } catch (e) {
      debugPrint('Error loading teacher profile from API: \$e');
      await _loadProfileData();
    }
  }`;
content = replaceBlockFunction(content, 'Future<void> _loadTeacherDataFromSupabase()', newLoadTeacher);

// 12. Update _loadProfileData
const newLoadProfile = `  Future<void> _loadProfileData() async {
    final prefs = CacheService.instance.prefs;
    setState(() {
      if (widget.role == 'teacher') {
        if (widget.teacherId != null && widget.teacherId != _currentUserId) {
          _userName = 'Loading Teacher...';
          _email = '';
          _phone = 'N/A';
          _gender = 'Not Specified';
          _dob = 'Not set';
          _bloodGroup = 'Not assigned';
          _address = 'No location registered';
          _employeeId = 'ID_PENDING';
          _designation = 'TEACHER';
          _department = 'CORE_SYSTEM';
          _experience = 'N/A';
          _joinedDate = 'N/A';
          _activityStatus = 'Offline';
          _pushEnabled = true;
          _inAppEnabled = true;
          _lastPasswordChange = 'Action Required';
          _dbQrCode = null;
          _studentName = _userName;
          _admissionNo = _employeeId;
        } else {
          _userName = prefs.getString('teacher_name') ?? 'Vikram Yadav';
          _email =
              prefs.getString('teacher_email') ?? 'teacher1@demoschool.com';
          _phone = prefs.getString('teacher_mobile') ?? 'N/A';
          _gender = prefs.getString('teacher_gender') ?? 'Not Specified';
          _dob = prefs.getString('teacher_dob') ?? 'Not set';
          _bloodGroup = prefs.getString('teacher_blood') ?? 'Not assigned';
          _address =
              prefs.getString('teacher_address') ?? 'No location registered';
          _employeeId = prefs.getString('teacher_emp_id') ?? 'ID_PENDING';
          _designation = prefs.getString('teacher_design') ?? 'TEACHER';
          _department = prefs.getString('teacher_dept') ?? 'CORE_SYSTEM';
          _experience = prefs.getString('teacher_exp') ?? 'N/A';
          _activityStatus = prefs.getString('teacher_activity') ?? 'Offline';
          _pushEnabled = prefs.getBool('notifications_enabled') ?? true;
          _inAppEnabled = prefs.getBool('in_app_notifications') ?? true;
          _lastPasswordChange =
              prefs.getString('teacher_last_pwd') ?? 'Action Required';
          _dbQrCode = prefs.getString('teacher_qrcode');
          _studentName = _userName;
          _admissionNo = _employeeId;
        }
      } else {
        _userName = prefs.getString('student_name') ?? '—';
        _email = prefs.getString('student_email') ?? '—';
        _phone = prefs.getString('student_phone') ?? 'N/A';
        _gender = prefs.getString('student_gender') ?? 'Not Specified';
        _dob = prefs.getString('student_dob') ?? 'Not set';
        _bloodGroup = prefs.getString('student_blood') ?? 'Not assigned';
        _address = prefs.getString('student_address') ?? 'No location registered';
        _rollNumber = prefs.getString('student_roll') ?? '—';
        _className = prefs.getString('student_class') ?? '—';
        _admissionId = prefs.getString('student_admission_id') ?? '—';
        _activityStatus = prefs.getString('student_activity') ?? 'Offline';
        _pushEnabled = prefs.getBool('notifications_enabled') ?? true;
        _inAppEnabled = prefs.getBool('in_app_notifications') ?? true;
        _lastPasswordChange = prefs.getString('student_last_pwd') ?? 'Action Required';
      }
    });
  }`;
content = replaceBlockFunction(content, 'Future<void> _loadProfileData()', newLoadProfile);

// 13. Update _simulateDocumentUpload
const newSimulateDocUpload = `  void _simulateDocumentUpload() async {
    final String? studentId = widget.studentId ?? _currentStudentDbId;
    if (studentId == null || studentId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text('Student details not fully loaded yet.', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploadingDoc = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null) {
        final platformFile = result.files.single;
        final String docName = platformFile.name;
        final String ext = platformFile.extension?.toUpperCase() ?? 'PDF';
        final fileBytes = platformFile.bytes;

        if (fileBytes != null) {
          final response = await StudentService.instance.uploadStudentDocument(
            studentId: studentId,
            fileBytes: fileBytes,
            fileName: docName,
            documentType: ext,
            documentName: docName,
          );

          if (response['success'] == true) {
            final document = response['document'] ?? response['data'] ?? {};
            if (mounted) {
              setState(() {
                final dateStr = '\${DateTime.now().month}/\${DateTime.now().day}/\${DateTime.now().year}';
                _uploadedDocuments.insert(0, {
                  'name': docName,
                  'date': dateStr,
                  'url': document['fileUrl']?.toString() ?? '',
                  'id': document['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                });
              });
              
              _saveStudentData(); // Persist locally just in case

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1A6FDB),
                  content: Text('Document "\$docName" uploaded successfully!',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ),
              );
            }
          } else {
            throw Exception(response['message'] ?? 'Upload failed');
          }
        } else {
          throw Exception('No bytes found in selected file.');
        }
      }
    } catch (e) {
      debugPrint('Error uploading file: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text('Upload failed: \$e', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingDoc = false;
        });
      }
    }
  }`;
content = replaceBlockFunction(content, 'void _simulateDocumentUpload()', newSimulateDocUpload);

// 14. Update _removeDocument
const newRemoveDoc = `  void _removeDocument(int index) async {
    final name = _uploadedDocuments[index]['name'];
    final docId = _uploadedDocuments[index]['id'];

    if (docId == null || docId.isEmpty) {
      setState(() {
        _uploadedDocuments.removeAt(index);
      });
      _saveStudentData();
      return;
    }

    try {
      final response = await StudentService.instance.deleteStudentDocument(docId);
      
      if (response['success'] == true) {
        setState(() {
          _uploadedDocuments.removeAt(index);
        });
        _saveStudentData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1A6FDB),
              content: Text('Document "\$name" deleted successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Delete failed');
      }
    } catch (e) {
      debugPrint('Error deleting document: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text('Delete failed: \$e', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        );
      }
    }
  }`;
content = replaceBlockFunction(content, 'void _removeDocument(int index)', newRemoveDoc);

// 15. Update _pickAndUploadAvatar
const newPickAvatar = `  Future<void> _pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.single;
        final bytes = platformFile.bytes;
        final extension = platformFile.extension?.toLowerCase() ?? 'png';

        if (bytes == null) {
          if (mounted) showToast(context, 'Failed to read image data.');
          return;
        }

        final prefs = CacheService.instance.prefs;
        final userId = _currentUserId ?? prefs.getString('user_id');

        if (userId == null) {
          if (mounted) {
            showToast(context, 'Not logged in. Cannot upload avatar.');
          }
          return;
        }

        if (mounted) showToast(context, 'Uploading avatar...');

        // Optimistically update UI using base64 memory image
        final base64String = base64Encode(bytes);
        final base64DataUrl = 'data:image/\$extension;base64,\$base64String';
        if (mounted) {
          setState(() {
            _avatarUrl = base64DataUrl;
          });
        }

        try {
          final res = await ApiService.instance.multipartRequest(
            'PATCH',
            'users/\$userId/avatar',
            fileKey: 'avatar',
            fileBytes: bytes,
            fileName: '\$userId.\$extension',
          );

          if (res != null && res['success'] == true) {
            final publicUrl = res['user']?['avatar'] as String? ?? base64DataUrl;
            await prefs.setString('\${widget.role}_photo_url', publicUrl);

            if (widget.onAvatarUpdated != null) {
              widget.onAvatarUpdated!(publicUrl);
            }

            if (mounted) {
              setState(() {
                _avatarUrl = publicUrl;
              });
              showToast(context, 'Avatar updated successfully!');
            }
          } else {
            throw Exception(res?['message'] ?? 'Upload failed');
          }
        } catch (storageErr) {
          debugPrint('Backend upload failed: \$storageErr');
          if (mounted) showToast(context, 'Failed to update avatar: \$storageErr');
        }
      }
    } catch (e) {
      debugPrint('Avatar upload error: \$e');
      if (mounted) showToast(context, 'Failed to update avatar: \$e');
    }
  }`;
content = replaceBlockFunction(content, 'Future<void> _pickAndUploadAvatar()', newPickAvatar);

// 16. Replace calls to _saveStudentDataToSupabase/Supabase updating in student saving (emergency number dialog & profile sheet)
content = content.replace("await _saveStudentDataToSupabase();", "await _saveStudentDataToBackend();");
content = content.replace("_saveStudentDataToSupabase();", "await _saveStudentDataToBackend();");

// Replace emergency contact Supabase lines (lines 1676 to 1687 in original file, let's target by signature / content)
const targetEmergencySupabase = `              try {
                if (widget.studentId != null) {
                  final client = Supabase.instance.client;
                  await client.from('Student').update({'emergencyPhone': val.isEmpty ? null : val}).eq('id', widget.studentId!);
                } else {
                  await _saveStudentDataToSupabase();
                  final client = Supabase.instance.client;
                  final currentUser = client.auth.currentUser;
                  if (currentUser != null) {
                    await client.from('Student').update({'emergencyPhone': val.isEmpty ? null : val}).eq('userId', currentUser.id);
                  }
                }
                showToast(context, 'Emergency contact updated!');
              } catch (e) {
                showToast(context, 'Error updating contact');
              }`;

const replacementEmergencySupabase = `              try {
                await _saveStudentDataToBackend();
                showToast(context, 'Emergency contact updated!');
              } catch (e) {
                showToast(context, 'Error updating contact');
              }`;

content = content.replace(targetEmergencySupabase, replacementEmergencySupabase);

// 17. Replace _saveTeacherDataToSupabase with _saveTeacherDataToBackend in _saveProfileEdits
content = content.replace("await _saveTeacherDataToSupabase(data);", "await _saveTeacherDataToBackend(data);");
content = content.replace("await _loadTeacherDataFromSupabase();", "await _loadTeacherDataFromSupabase(); // Reloads teacher data");

// 18. Global replacement of Supabase.instance.client.auth.currentUser?.id
content = content.replace(/Supabase\.instance\.client\.auth\.currentUser\?\.id/g, "_currentUserId");

fs.writeFileSync(filepath, content, 'utf8');
console.log('Successfully completed full refactoring of profile_screen.dart!');
