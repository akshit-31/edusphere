import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/academic_service.dart';
import '../../services/homework_service.dart';
import '../../theme/typography.dart';
import '../../widgets/common_widgets.dart';

class CreateHomeworkScreen extends StatefulWidget {
  const CreateHomeworkScreen({super.key});

  @override
  State<CreateHomeworkScreen> createState() => _CreateHomeworkScreenState();
}

class _CreateHomeworkScreenState extends State<CreateHomeworkScreen> {
  final Color darkNavy = const Color(0xFF1E40AF);
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));
  
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _subjects = [];
  
  String? _selectedClassId;
  String? _selectedSectionId;
  String? _selectedSubjectId;
  
  bool _loadingDropdowns = true;
  bool _submitting = false;
  
  PlatformFile? _attachedFile;

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDropdowns() async {
    setState(() => _loadingDropdowns = true);
    try {
      final classesRes = await AcademicService.instance.getClasses();
      final sectionsRes = await AcademicService.instance.getSections();
      final subjectsRes = await AcademicService.instance.getSubjects();

      if (classesRes != null && classesRes['classes'] != null) {
        _classes = List<Map<String, dynamic>>.from(classesRes['classes']);
      }
      if (sectionsRes != null && sectionsRes['sections'] != null) {
        _sections = List<Map<String, dynamic>>.from(sectionsRes['sections']);
      }
      if (subjectsRes != null && subjectsRes['subjects'] != null) {
        _subjects = List<Map<String, dynamic>>.from(subjectsRes['subjects']);
      }

      if (_classes.isNotEmpty) _selectedClassId = _classes[0]['id']?.toString();
      if (_sections.isNotEmpty) _selectedSectionId = _sections[0]['id']?.toString();
      if (_subjects.isNotEmpty) _selectedSubjectId = _subjects[0]['id']?.toString();
    } catch (e) {
      debugPrint('Error loading dropdown lists: $e');
    }
    setState(() => _loadingDropdowns = false);
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
      );
      if (result != null) {
        setState(() {
          _attachedFile = result.files.single;
        });
      }
    } catch (_) {}
  }

  Future<void> _submitAssignment() async {
    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();

    if (title.isEmpty || _selectedClassId == null || _selectedSubjectId == null) {
      showToast(context, 'Title, Class and Subject are required');
      return;
    }

    setState(() => _submitting = true);
    
    try {
      List<int>? fileBytes;
      if (_attachedFile != null && _attachedFile!.path != null) {
        fileBytes = _attachedFile!.bytes ?? 
            File(_attachedFile!.path!).readAsBytesSync();
      }

      final res = await HomeworkService.instance.createHomework(
        title: title,
        description: description,
        dueDate: _dueDate.toIso8601String(),
        subjectId: _selectedSubjectId!,
        classId: _selectedClassId!,
        sectionId: _selectedSectionId,
        fileBytes: fileBytes,
        fileName: _attachedFile?.name,
      );

      if (res['message'] != null || res['assignment'] != null) {
        showToast(context, 'Homework assigned successfully!');
        Navigator.pop(context);
      } else {
        showToast(context, 'Failed to create assignment');
      }
    } catch (e) {
      showToast(context, 'Error submitting assignment');
    }
    setState(() => _submitting = false);
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: _loadingDropdowns
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF)))
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputLabel('Title'),
                        _textField(_titleCtrl, 'e.g. Worksheet 4 — Entropy Numericals'),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _inputLabel('Class'),
                                  _classDropdown(),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _inputLabel('Section (Optional)'),
                                  _sectionDropdown(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _inputLabel('Subject'),
                                  _subjectDropdown(),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _inputLabel('Due Date'),
                                  _dateSelector(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _inputLabel('Description'),
                        _textArea(_descCtrl, 'Describe homework parameters, NCERT questions, etc.'),
                        SizedBox(height: 20.h),
                        _inputLabel('Worksheet Attachment'),
                        _uploadArea(),
                        SizedBox(height: 32.h),
                        _buildPrimaryButton(),
                        SizedBox(height: 40.h),
                      ],
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
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Homework',
                    style: AppTypography.h4.copyWith(color: Colors.white)),
                Text('Assign real-time tasks to classes',
                    style: AppTypography.small.copyWith(color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(label,
          style: AppTypography.caption.copyWith(color: Colors.grey.shade600)),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _textArea(TextEditingController ctrl, String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: ctrl,
        maxLines: 4,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _classDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClassId,
          isExpanded: true,
          items: _classes
              .map((c) => DropdownMenuItem(
                  value: c['id']?.toString(),
                  child: Text(c['name']?.toString() ?? 'Class',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600))))
              .toList(),
          onChanged: (v) => setState(() => _selectedClassId = v),
        ),
      ),
    );
  }

  Widget _sectionDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSectionId,
          isExpanded: true,
          hint: Text('All Sections', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All Sections', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            ..._sections.map((s) => DropdownMenuItem(
                value: s['id']?.toString(),
                child: Text(s['name']?.toString() ?? 'Section',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)))),
          ],
          onChanged: (v) => setState(() => _selectedSectionId = v),
        ),
      ),
    );
  }

  Widget _subjectDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubjectId,
          isExpanded: true,
          items: _subjects
              .map((s) => DropdownMenuItem(
                  value: s['id']?.toString(),
                  child: Text(s['name']?.toString() ?? 'Subject',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600))))
              .toList(),
          onChanged: (v) => setState(() => _selectedSubjectId = v),
        ),
      ),
    );
  }

  Widget _dateSelector(BuildContext context) {
    final String formattedDate = '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}';
    return GestureDetector(
      onTap: () => _selectDueDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formattedDate, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            Icon(Icons.calendar_month_outlined, size: 20.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _uploadArea() {
    final String labelText = _attachedFile != null ? _attachedFile!.name : 'Upload PDF / Worksheet';
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(
              _attachedFile != null ? Icons.attach_file_rounded : Icons.cloud_upload_outlined,
              color: Colors.grey.shade400,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(labelText,
                style: AppTypography.small.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitAssignment,
        style: ElevatedButton.styleFrom(
            backgroundColor: darkNavy,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            elevation: 0),
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text('Assign Homework', style: AppTypography.tableHeader),
      ),
    );
  }
}
