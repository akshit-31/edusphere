import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:edusphere/theme/typography.dart';
import '../../services/quiz_service.dart';
import '../../services/academic_service.dart';
import '../../models/quiz_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a single MCQ question
// ─────────────────────────────────────────────────────────────────────────────
class _Question {
  final TextEditingController questionCtrl;
  final List<TextEditingController> optionCtrls;
  int correctIndex;

  _Question()
      : questionCtrl = TextEditingController(),
        optionCtrls = List.generate(4, (_) => TextEditingController()),
        correctIndex = 0;

  void dispose() {
    questionCtrl.dispose();
    for (final c in optionCtrls) {
      c.dispose();
    }
  }

  Map<String, dynamic> toJson() => {
        'q': questionCtrl.text.trim(),
        'opts': optionCtrls.map((c) => c.text.trim()).toList(),
        'ans': correctIndex,
      };

  bool get isValid =>
      questionCtrl.text.trim().isNotEmpty &&
      optionCtrls.every((c) => c.text.trim().isNotEmpty);
}

// ─────────────────────────────────────────────────────────────────────────────
// Create Quiz Screen
// ─────────────────────────────────────────────────────────────────────────────
class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});
  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleCtrl = TextEditingController(text: 'Physics Chapter 4');
  final _durationCtrl = TextEditingController(text: '20');
  final List<_Question> _questions = [_Question()];

  String? _selectedClass;
  final List<String> _selectedSections = [];
  bool get _isTargetSelected =>
      _selectedClass != null && _selectedSections.isNotEmpty;

  int _activeTab = 0; // 0 = MCQ Builder, 1 = Submissions
  List<Map<String, dynamic>> _submissions = [];
  bool _loadingSubmissions = true;

  List<Map<String, dynamic>> _availableClasses = [];
  List<Map<String, dynamic>> _availableSections = [];
  bool _loadingTargetData = true;

  @override
  void initState() {
    super.initState();
    _loadTargetData();
    _loadSubmissions();
  }

  Future<void> _loadTargetData() async {
    try {
      final classesRes = await AcademicService.instance.getClasses();
      final sectionsRes = await AcademicService.instance.getSections();

      if (classesRes != null && classesRes['classes'] != null) {
        _availableClasses = List<Map<String, dynamic>>.from(classesRes['classes']);
      }
      if (sectionsRes != null && sectionsRes['sections'] != null) {
        _availableSections = List<Map<String, dynamic>>.from(sectionsRes['sections']);
      }
    } catch (e) {
      debugPrint('Error loading target data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingTargetData = false;
        });
      }
    }
  }

  Future<void> _loadSubmissions() async {
    try {
      final quizzes = await QuizService.instance.fetchQuizzes();
      final List<Map<String, dynamic>> allSubmissions = [];

      for (final quiz in quizzes) {
        final subs = await QuizService.instance.fetchQuizSubmissions(quiz.id);
        for (final sub in subs) {
          final studentObj = sub['student'] as Map<String, dynamic>?;
          final userObj = studentObj != null ? studentObj['user'] as Map<String, dynamic>? : null;
          final firstName = userObj != null ? userObj['firstName'] as String? ?? '' : '';
          final lastName = userObj != null ? userObj['lastName'] as String? ?? '' : '';
          final studentName = '$firstName $lastName'.trim();
          
          final score = sub['score'] as int? ?? 0;
          final total = sub['totalQuestions'] as int? ?? 1;
          final pct = (score / total * 100).round();

          final classId = studentObj != null ? studentObj['currentClassId'] as String? ?? '' : '';
          final sectionId = studentObj != null ? studentObj['sectionId'] as String? ?? '' : '';
          final classMatch = _availableClasses.firstWhere((c) => c['id'] == classId, orElse: () => <String, dynamic>{});
          final sectionMatch = _availableSections.firstWhere((s) => s['id'] == sectionId, orElse: () => <String, dynamic>{});
          
          final className = classMatch.isNotEmpty ? classMatch['name']?.toString() ?? 'Class' : 'Class';
          final sectionName = sectionMatch.isNotEmpty ? sectionMatch['name']?.toString() ?? '' : '';

          allSubmissions.add({
            'quizId': quiz.id,
            'quizTitle': quiz.title,
            'studentName': studentName.isEmpty ? 'Student' : studentName,
            'studentClass': className,
            'studentSection': sectionName,
            'score': score,
            'total': total,
            'pct': pct,
            'submittedAt': sub['submittedAt'] ?? '',
          });
        }
      }

      // Sort by submittedAt descending
      allSubmissions.sort((a, b) {
        final dateA = DateTime.tryParse(a['submittedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b['submittedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _submissions = allSubmissions;
          _loadingSubmissions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSubmissions = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  // ── Add a blank question ──────────────────────────────────────────────────
  void _addQuestion() {
    setState(() => _questions.add(_Question()));
  }

  // ── Remove a question ─────────────────────────────────────────────────────
  void _removeQuestion(int index) {
    if (_questions.length == 1) {
      showToast(context, 'At least one question is required', isError: true);
      return;
    }
    _questions[index].dispose();
    setState(() => _questions.removeAt(index));
  }

  // ── Publish quiz to database ──────────────────────────────────────────────
  Future<void> _publishQuiz() async {
    // Validate title
    if (_titleCtrl.text.trim().isEmpty) {
      showToast(context, 'Please enter a quiz title', isError: true);
      return;
    }
    // Validate all questions
    for (int i = 0; i < _questions.length; i++) {
      if (!_questions[i].isValid) {
        showToast(context, 'Q${i + 1}: Fill in the question and all 4 options',
            isError: true);
        return;
      }
    }
    if (!_isTargetSelected) {
      showToast(context, 'Please select a class and section', isError: true);
      return;
    }

    try {
      final durationMins = int.tryParse(_durationCtrl.text.trim()) ?? 20;
      final questionsList = _questions.map((q) {
        return QuizQuestionModel(
          question: q.questionCtrl.text.trim(),
          options: q.optionCtrls.map((c) => c.text.trim()).toList(),
          ans: q.correctIndex,
        );
      }).toList();

      final res = await QuizService.instance.createQuiz(
        title: _titleCtrl.text.trim(),
        subject: 'General',
        durationMinutes: durationMins,
        targetClass: _selectedClass,
        targetSections: _selectedSections,
        questions: questionsList,
      );

      if (res != null && res['success'] == true) {
        if (mounted) {
          showToast(context, 'Quiz published successfully!');
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          showToast(context, 'Failed to publish: ${res['error'] ?? 'Unknown error'}', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to publish: $e', isError: true);
      }
    }
  }

  Widget _buildSubmissionsTab() {
    if (_loadingSubmissions) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teacherPrimary),
      );
    }

    if (_submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_rounded,
                size: 64.sp, color: AppColors.textLight),
            SizedBox(height: 16.h),
            Text(
              'No submissions yet',
              style:
                  AppTypography.bodyLarge.copyWith(color: AppColors.textMedium),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'When students complete their quizzes, their results will appear here.',
                textAlign: TextAlign.center,
                style:
                    AppTypography.caption.copyWith(color: AppColors.textLight),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      color: AppColors.teacherPrimary,
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: _submissions.length,
        itemBuilder: (_, i) => _buildSubmissionCard(_submissions[i]),
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> sub) {
    final title = sub['quizTitle'] as String? ?? 'Quiz';
    final name = sub['studentName'] as String? ?? 'Student';
    final cls = sub['studentClass'] as String? ?? 'N/A';
    final sec = sub['studentSection'] as String? ?? '';
    final score = sub['score'] as int? ?? 0;
    final total = sub['total'] as int? ?? 0;
    final pct = sub['pct'] as int? ?? 0;
    final dateStr = sub['submittedAt'] as String? ?? '';

    String timeFormatted = '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        timeFormatted =
            '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final Color scoreColor;
    final Color scoreBg;
    if (pct >= 80) {
      scoreColor = const Color(0xFF10B981);
      scoreBg = const Color(0xFFECFDF5);
    } else if (pct >= 50) {
      scoreColor = const Color(0xFFF59E0B);
      scoreBg = const Color(0xFFFFFBEB);
    } else {
      scoreColor = const Color(0xFFEF4444);
      scoreBg = const Color(0xFFFEF2F2);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textMedium, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (timeFormatted.isNotEmpty)
                Text(
                  timeFormatted,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textLight),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.small
                          .copyWith(color: AppColors.textDark),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.school_rounded,
                            size: 13.sp, color: AppColors.teacherPrimary),
                        SizedBox(width: 4.w),
                        Text(
                          'Class $cls${sec.isNotEmpty ? ' - Section $sec' : ''}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: scoreBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score/$total',
                      style: AppTypography.small.copyWith(color: scoreColor),
                    ),
                    Text(
                      '$pct%',
                      style: AppTypography.caption
                          .copyWith(color: scoreColor.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
              title: 'Create Quiz',
              subtitle: _activeTab == 0 ? 'MCQ Builder' : 'Student Submissions',
              theme: roleThemes['teacher']!),
          // ── Custom Segmented Tabs ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _activeTab == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _activeTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4.r,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'MCQ Builder',
                            style: AppTypography.caption.copyWith(
                                color: _activeTab == 0
                                    ? AppColors.teacherPrimary
                                    : AppColors.textMedium),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 1;
                          _loadingSubmissions = true;
                        });
                        _loadSubmissions();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _activeTab == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _activeTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4.r,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Submissions',
                            style: AppTypography.caption.copyWith(
                                color: _activeTab == 1
                                    ? AppColors.teacherPrimary
                                    : AppColors.textMedium),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _activeTab == 0
                ? SingleChildScrollView(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        // ── Title & Duration ───────────────────────────────────
                        Row(children: [
                          Expanded(
                              child: _labelField('QUIZ TITLE', _titleCtrl,
                                  'e.g. Physics Chapter 4')),
                          SizedBox(width: 12.w),
                          SizedBox(
                            width: 110.w,
                            child: _labelField(
                                'DURATION (min)', _durationCtrl, '20'),
                          ),
                        ]),
                        SizedBox(height: 20.h),

                        // ── Question cards ─────────────────────────────────────
                        ...List.generate(
                          _questions.length,
                          (i) => _QuestionCard(
                            index: i,
                            question: _questions[i],
                            onDelete: () => _removeQuestion(i),
                            onChanged: () => setState(() {}),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // ── Add Question button ────────────────────────────────
                        GestureDetector(
                          onTap: _addQuestion,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border:
                                  Border.all(color: AppColors.teacherPrimary),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_rounded,
                                      color: AppColors.teacherPrimary,
                                      size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text('Add Question',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.teacherPrimary)),
                                ]),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ── Publish button ─────────────────────────────────────
                        LoadingButton(
                          label:
                              'Publish Quiz (${_questions.length} Question${_questions.length == 1 ? '' : 's'})',
                          color: AppColors.teacherPrimary,
                          onPressed: () async => _showTargetSheet(context),
                        ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  )
                : _buildSubmissionsTab(),
          ),
        ],
      ),
    );
  }

  Widget _labelField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textLight, letterSpacing: 0.8)),
        SizedBox(height: 6.h),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTypography.caption.copyWith(color: AppColors.textLight),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: AppColors.teacherPrimary, width: 2.w)),
            contentPadding: EdgeInsets.all(12.r),
          ),
        ),
      ],
    );
  }

  // ── Target class/section bottom sheet ────────────────────────────────────
  void _showTargetSheet(BuildContext context) {
    // Validate before showing sheet
    if (_titleCtrl.text.trim().isEmpty) {
      showToast(context, 'Please enter a quiz title', isError: true);
      return;
    }
    for (int i = 0; i < _questions.length; i++) {
      if (!_questions[i].isValid) {
        showToast(context, 'Q${i + 1}: Fill in the question and all 4 options',
            isError: true);
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 32.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Select Target',
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textDark)),
                IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded)),
              ]),
              SizedBox(height: 20.h),
              Text('CHOOSE CLASS',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textLight, letterSpacing: 1)),
              SizedBox(height: 12.h),
              _loadingTargetData
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teacherPrimary))
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableClasses.map((c) {
                        final name = c['name']?.toString() ?? 'Class';
                        final id = c['id']?.toString() ?? '';
                        final sel = _selectedClass == id;
                        return GestureDetector(
                          onTap: () =>
                              setSheet(() => setState(() {
                                _selectedClass = id;
                                _selectedSections.clear(); // Reset sections when class changes
                              })),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.teacherPrimary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: sel
                                      ? AppColors.teacherPrimary
                                      : AppColors.border),
                            ),
                            child: Text(name,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        sel ? Colors.white : AppColors.textMedium)),
                          ),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 24.h),
              Text('CHOOSE SECTION',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textLight, letterSpacing: 1)),
              SizedBox(height: 12.h),
              _loadingTargetData
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teacherPrimary))
                  : _selectedClass == null
                      ? Text('Please select a class first',
                          style: AppTypography.caption.copyWith(color: AppColors.textLight))
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availableSections
                              .where((s) => s['classId'] == _selectedClass)
                              .map((s) {
                            final name = s['name']?.toString() ?? '';
                            final sel = _selectedSections.contains(name);
                            return GestureDetector(
                              onTap: () => setSheet(() => setState(() {
                                    if (sel) {
                                      _selectedSections.remove(name);
                                    } else {
                                      _selectedSections.add(name);
                                    }
                                  })),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.teacherPrimary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                      color: sel
                                          ? AppColors.teacherPrimary
                                          : AppColors.border),
                                ),
                                child: Text(name,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? Colors.white
                                            : AppColors.textMedium)),
                              ),
                            );
                          }).toList(),
                        ),
              SizedBox(height: 32.h),
              LoadingButton(
                label: 'Confirm & Publish Quiz',
                color: AppColors.teacherPrimary,
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _publishQuiz();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual question card widget
// ─────────────────────────────────────────────────────────────────────────────
class _QuestionCard extends StatefulWidget {
  final int index;
  final _Question question;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: AppColors.teacherLight,
                    borderRadius: BorderRadius.circular(8.r)),
                child: Text('Q${widget.index + 1}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.teacherPrimary)),
              ),
              GestureDetector(
                onTap: widget.onDelete,
                child:
                    Icon(Icons.delete_rounded, color: Colors.red, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Question text field ──────────────────────────────────────
          TextField(
            controller: q.questionCtrl,
            maxLines: 2,
            onChanged: (_) => widget.onChanged(),
            decoration: InputDecoration(
              hintText: 'Type your question here…',
              hintStyle:
                  AppTypography.caption.copyWith(color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(12.r),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Option fields ────────────────────────────────────────────
          ...List.generate(4, (i) {
            final isCorrect = q.correctIndex == i;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color:
                    isCorrect ? const Color(0xFFECFDF5) : AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isCorrect ? const Color(0xFF10B981) : AppColors.border,
                  width: isCorrect ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Correct answer selector
                  GestureDetector(
                    onTap: () {
                      setState(() => q.correctIndex = i);
                      widget.onChanged();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Container(
                        width: 22.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? const Color(0xFF10B981)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCorrect
                                ? const Color(0xFF10B981)
                                : AppColors.border,
                          ),
                        ),
                        child: isCorrect
                            ? Icon(Icons.check,
                                color: Colors.white, size: 14.sp)
                            : null,
                      ),
                    ),
                  ),
                  // Option text field
                  Expanded(
                    child: TextField(
                      controller: q.optionCtrls[i],
                      onChanged: (_) => widget.onChanged(),
                      decoration: InputDecoration(
                        hintText: 'Option ${String.fromCharCode(65 + i)}',
                        hintStyle: AppTypography.caption
                            .copyWith(color: AppColors.textLight),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(right: 12.w),
                      ),
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Hint ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              '● Tap the circle to mark the correct answer',
              style: AppTypography.caption.copyWith(color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
