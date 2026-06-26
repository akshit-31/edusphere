import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:edusphere/theme/typography.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quiz list — reads published quizzes, filters by student class, polls every 3s
// ─────────────────────────────────────────────────────────────────────────────
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizModel> _quizzes = [];
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (mounted) _loadAll();
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final list = await QuizService.instance.fetchQuizzes();
      if (mounted) {
        setState(() {
          _quizzes = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
            title: 'Quiz & Assessments',
            subtitle: 'Live & Upcoming',
            theme: roleThemes['student']!,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.studentPrimary))
                : RefreshIndicator(
                    onRefresh: _loadAll,
                    color: AppColors.studentPrimary,
                    child: _quizzes.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: EdgeInsets.all(16.r),
                            itemCount: _quizzes.length,
                            itemBuilder: (_, i) {
                              final quiz = _quizzes[i];
                              return _QuizCard(
                                quiz: quiz,
                                onAttemptSaved: _loadAll,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => ListView(children: [
        SizedBox(height: 80.h),
        Center(
          child: Column(children: [
            Icon(Icons.quiz_rounded, size: 64.sp, color: AppColors.textLight),
            SizedBox(height: 16.h),
            Text('No quizzes yet',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textMedium)),
            SizedBox(height: 8.h),
            Text('Your teacher will publish quizzes here',
                style:
                    AppTypography.caption.copyWith(color: AppColors.textLight)),
          ]),
        ),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Quiz card — shows attempt result if already done
// ─────────────────────────────────────────────────────────────────────────────
// Quiz card — shows attempt result if already done
// ─────────────────────────────────────────────────────────────────────────────
class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onAttemptSaved;

  const _QuizCard({
    required this.quiz,
    required this.onAttemptSaved,
  });

  @override
  Widget build(BuildContext context) {
    final title = quiz.title;
    final subject = quiz.subject;
    final duration = quiz.durationMinutes;
    final qCount = quiz.questions.length;
    final cls = quiz.targetClass ?? '';
    final sections = quiz.targetSections.join(', ');
    final isDone = quiz.isAttempted;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDone
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : AppColors.studentPrimary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title + status badge
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(title,
                style: AppTypography.small.copyWith(color: AppColors.textDark)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFECFDF5) : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              isDone ? '✅ Done' : '🔴 Live',
              style: AppTypography.caption.copyWith(
                  color: isDone ? const Color(0xFF10B981) : Colors.red),
            ),
          ),
        ]),
        SizedBox(height: 6.h),
        Text(subject,
            style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
        SizedBox(height: 10.h),

        // Info chips
        Wrap(spacing: 8.w, runSpacing: 6.h, children: [
          _chip('📝 $qCount questions'),
          _chip('⏱ $duration min'),
          if (cls.isNotEmpty) _chip('🏫 Class $cls - $sections'),
        ]),

        // Previous score if done
        if (isDone) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(children: [
              Icon(Icons.emoji_events_rounded,
                  color: const Color(0xFF10B981), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Your Score: ${quiz.score}/${quiz.totalQuestions}  •  ${quiz.totalQuestions != null && quiz.totalQuestions! > 0 ? (quiz.score! / quiz.totalQuestions! * 100).round() : 0}%',
                style: AppTypography.caption
                    .copyWith(color: const Color(0xFF10B981)),
              ),
            ]),
          ),
        ],

        SizedBox(height: 14.h),

        // Action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _QuizAttemptScreen(
                  quiz: quiz,
                  onAttemptSaved: onAttemptSaved,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDone ? const Color(0xFF10B981) : AppColors.studentPrimary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
            ),
            child: Text(
              isDone ? 'View Result' : 'Start Quiz',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _chip(String t) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r)),
        child: Text(t,
            style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Quiz attempt screen
// ─────────────────────────────────────────────────────────────────────────────
class _QuizAttemptScreen extends StatefulWidget {
  final QuizModel quiz;
  final VoidCallback onAttemptSaved;

  const _QuizAttemptScreen({
    required this.quiz,
    required this.onAttemptSaved,
  });

  @override
  State<_QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<_QuizAttemptScreen> {
  int _current = 0;
  final Map<int, int> _selected = {};
  late int _timeLeft;
  Timer? _timer;
  bool _submitted = false;
  late final List<QuizQuestionModel> _questions;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.quiz.questions;

    // If already attempted, jump straight to result view
    if (widget.quiz.isAttempted) {
      _submitted = true;
      _timeLeft = 0;
      // Restore previous selections from saved attempt if they exist
      final saved = widget.quiz.studentAnswers;
      if (saved != null) {
        for (int i = 0; i < saved.length; i++) {
          _selected[i] = saved[i];
        }
      }
      return;
    }

    _timeLeft = (widget.quiz.durationMinutes * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _submitAndSave();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitAndSave() {
    _timer?.cancel();
    setState(() => _submitted = true);
    _saveAttempt();
  }

  int get _score {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selected[i] != null && _selected[i] == _questions[i].ans) {
        score++;
      }
    }
    return score;
  }

  Future<void> _saveAttempt() async {
    if (widget.quiz.isAttempted) return;
    
    setState(() => _isSubmitting = true);
    try {
      final quizId = widget.quiz.id;
      final List<int> answers = List.generate(_questions.length, (i) => _selected[i] ?? -1);

      final res = await QuizService.instance.submitQuizAttempt(quizId, answers);

      if (res != null && res['success'] == true) {
        widget.onAttemptSaved();
      }
    } catch (_) {
      // Handled silently or custom toast
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildResult(context);
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('No questions found',
              style: GoogleFonts.inter(color: AppColors.textMedium)),
        ),
      );
    }
    return _buildQuiz(context);
  }

  // ── Quiz UI ───────────────────────────────────────────────────────────────
  Widget _buildQuiz(BuildContext context) {
    final q = _questions[_current];
    final opts = q.options;
    final mins = _timeLeft ~/ 60;
    final secs = _timeLeft % 60;
    final title = widget.quiz.title;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.toUpperCase(),
                          style: AppTypography.caption
                              .copyWith(color: const Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis),
                      Text('Question ${_current + 1} / ${_questions.length}',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color:
                        _timeLeft < 60 ? Colors.red : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(children: [
                    Icon(Icons.timer_rounded, color: Colors.white, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text('$mins:${secs.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900, color: Colors.white)),
                  ]),
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: (_current + 1) / _questions.length,
                minHeight: 4,
                backgroundColor: const Color(0xFF1E293B),
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.studentPrimary),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // ── Question + options ────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(q.question,
                      style: AppTypography.tableHeader
                          .copyWith(color: Colors.white, height: 1.5)),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: opts.length,
                    itemBuilder: (_, i) {
                      final isSel = _selected[_current] == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selected[_current] = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(18.r),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.studentPrimary
                                    .withValues(alpha: 0.15)
                                : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.studentPrimary
                                  : const Color(0xFF334155),
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(children: [
                            Container(
                              width: 28.w,
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.studentPrimary
                                    : const Color(0xFF334155),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(String.fromCharCode(65 + i),
                                    style: AppTypography.caption
                                        .copyWith(color: Colors.white)),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(opts[i],
                                  style: AppTypography.small.copyWith(
                                      color: isSel
                                          ? Colors.white
                                          : const Color(0xFF94A3B8))),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),

          // ── Navigation ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(children: [
              if (_current > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _current--),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF334155)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text('Previous',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8))),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_current < _questions.length - 1) {
                            setState(() => _current++);
                          } else {
                            _submitAndSave();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.studentPrimary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: _isSubmitting
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Text(
                          _current == _questions.length - 1
                              ? 'Submit Quiz'
                              : 'Next →',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Result screen ─────────────────────────────────────────────────────────
  Widget _buildResult(BuildContext context) {
    final total = _questions.length;
    final score = widget.quiz.isAttempted ? (widget.quiz.score ?? 0) : _score;
    final pct = total > 0 ? (score / total * 100).round() : 0;
    final title = widget.quiz.title;

    final String emoji;
    final String message;
    if (pct >= 80) {
      emoji = '🎉';
      message = 'Excellent Work!';
    } else if (pct >= 60) {
      emoji = '👍';
      message = 'Good Job!';
    } else if (pct >= 40) {
      emoji = '📚';
      message = 'Keep Practicing!';
    } else {
      emoji = '💪';
      message = "Don't Give Up!";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(children: [
            SizedBox(height: 20.h),

            // Score circle
            Container(
              width: 130.w,
              height: 130.h,
              decoration: BoxDecoration(
                gradient: roleThemes['student']!.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.studentPrimary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$score/$total',
                        style: AppTypography.h3.copyWith(color: Colors.white)),
                    Text('$pct%',
                        style: AppTypography.small.copyWith(
                            color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Text('$emoji $message',
                style: AppTypography.h3.copyWith(color: AppColors.textDark)),
            SizedBox(height: 6.h),
            Text('$title — Result',
                style:
                    AppTypography.small.copyWith(color: AppColors.textMedium),
                textAlign: TextAlign.center),
            SizedBox(height: 28.h),

            // Answer review
            const SectionTitle(title: 'Answer Review'),
            SizedBox(height: 12.h),

            ..._questions.asMap().entries.map((e) {
              final qi = e.key;
              final q = e.value;
              final opts = q.options;
              final correctIdx = q.ans;
              final studentIdx = _selected[qi];
              final wasSkipped = studentIdx == null;
              final isCorrect = !wasSkipped && studentIdx == correctIdx;

              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: wasSkipped
                      ? const Color(0xFFFFFBEB)
                      : isCorrect
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: wasSkipped
                        ? AppColors.warning
                        : isCorrect
                            ? const Color(0xFF10B981)
                            : Colors.red,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: wasSkipped
                              ? AppColors.warning
                              : isCorrect
                                  ? const Color(0xFF10B981)
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('Q${qi + 1}',
                            style: AppTypography.caption
                                .copyWith(color: Colors.white)),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(q.question,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textDark)),
                      ),
                    ]),
                    SizedBox(height: 8.h),
                    if (wasSkipped)
                      Text('⚠️ Skipped — Correct: ${opts[correctIdx]}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.warning))
                    else if (isCorrect)
                      Text('✅ Correct: ${opts[correctIdx]}',
                          style: AppTypography.caption
                              .copyWith(color: const Color(0xFF10B981)))
                    else ...[
                      Text('❌ Your answer: ${studentIdx < opts.length && studentIdx >= 0 ? opts[studentIdx] : 'Invalid Selection'}',
                          style: AppTypography.caption
                              .copyWith(color: Colors.red)),
                      Text('✅ Correct: ${opts[correctIdx]}',
                          style: AppTypography.caption
                              .copyWith(color: const Color(0xFF10B981))),
                    ],
                  ],
                ),
              );
            }),

            SizedBox(height: 24.h),
            LoadingButton(
              label: 'Back to Quizzes',
              color: AppColors.studentPrimary,
              onPressed: () async => Navigator.pop(context),
            ),
            SizedBox(height: 20.h),
          ]),
        ),
      ),
    );
  }
}
