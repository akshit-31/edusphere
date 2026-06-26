const prisma = require('../config/database');
const asyncHandler = require('express-async-handler');

/**
 * QuizController handles database-backed quiz creation and submissions.
 */
const QuizController = {
  // Create a new quiz (Teacher / Admin)
  createQuiz: asyncHandler(async (req, res) => {
    const { title, subject, durationMinutes, targetClass, targetSections, questions } = req.body;

    if (!title || !questions || !Array.isArray(questions)) {
      return res.status(400).json({ success: false, error: 'Title and questions list are required.' });
    }

    const quiz = await prisma.quiz.create({
      data: {
        title,
        subject: subject || 'General',
        durationMinutes: parseInt(durationMinutes) || 20,
        targetClass,
        targetSections: targetSections || [],
        questions,
        createdBy: req.user.userId,
      }
    });

    // Send realtime notification to students of target class
    const io = req.app.get('io');
    if (io) {
      io.to(`class_${targetClass}`).emit('NEW_QUIZ_PUBLISHED', {
        quizId: quiz.id,
        title: quiz.title,
        subject: quiz.subject,
      });
    }

    res.status(201).json({ success: true, data: quiz });
  }),

  // Get active quizzes (Student: filtered by class; Teacher: all or created by them)
  getQuizzes: asyncHandler(async (req, res) => {
    const userId = req.user.userId;
    const role = req.user.role;

    let quizzes = [];

    if (role === 'STUDENT') {
      // Find student profile to get class
      const student = await prisma.studentProfile.findFirst({
        where: { userId }
      });

      if (!student) {
        return res.status(404).json({ success: false, error: 'Student profile not found.' });
      }

      quizzes = await prisma.quiz.findMany({
        where: {
          isPublished: true,
          OR: [
            { targetClass: student.currentClassId },
            { targetClass: null },
            { targetClass: '' }
          ]
        },
        orderBy: { createdAt: 'desc' }
      });
      
      // Fetch submissions by this student to mark completed ones
      const submissions = await prisma.quizSubmission.findMany({
        where: { studentId: student.id }
      });

      const submissionMap = {};
      submissions.forEach(sub => {
        submissionMap[sub.quizId] = sub;
      });

      const data = quizzes.map(q => ({
        ...q,
        isAttempted: !!submissionMap[q.id],
        score: submissionMap[q.id]?.score,
        totalQuestions: submissionMap[q.id]?.totalQuestions,
        answers: submissionMap[q.id]?.answers,
      }));

      return res.json({ success: true, data });
    } else {
      // Teachers and Admins get all quizzes
      quizzes = await prisma.quiz.findMany({
        orderBy: { createdAt: 'desc' }
      });
      return res.json({ success: true, data: quizzes });
    }
  }),

  // Submit a quiz attempt (Student)
  submitQuiz: asyncHandler(async (req, res) => {
    const { answers } = req.body;
    const quizId = req.params.id;
    const userId = req.user.userId;

    if (!Array.isArray(answers)) {
      return res.status(400).json({ success: false, error: 'Answers array is required.' });
    }

    const student = await prisma.studentProfile.findFirst({
      where: { userId }
    });

    if (!student) {
      return res.status(404).json({ success: false, error: 'Student profile not found.' });
    }

    const quiz = await prisma.quiz.findUnique({
      where: { id: quizId }
    });

    if (!quiz) {
      return res.status(404).json({ success: false, error: 'Quiz not found.' });
    }

    // Calculate score
    const questions = quiz.questions;
    let score = 0;
    questions.forEach((q, idx) => {
      if (answers[idx] !== undefined && answers[idx] === q.ans) {
        score++;
      }
    });

    const submission = await prisma.quizSubmission.create({
      data: {
        quizId,
        studentId: student.id,
        score,
        totalQuestions: questions.length,
        answers,
      }
    });

    // Notify teacher/admin of submission in realtime
    const io = req.app.get('io');
    if (io) {
      io.to('admin_dashboard').emit('QUIZ_SUBMITTED', {
        submissionId: submission.id,
        studentName: `${req.user.firstName} ${req.user.lastName}`,
        quizTitle: quiz.title,
        score,
        totalQuestions: questions.length,
      });
    }

    res.status(201).json({
      success: true,
      data: {
        score,
        totalQuestions: questions.length,
        submission,
      }
    });
  }),

  // Delete quiz (Teacher / Admin)
  deleteQuiz: asyncHandler(async (req, res) => {
    const quizId = req.params.id;
    await prisma.quiz.delete({
      where: { id: quizId }
    });
    res.json({ success: true, message: 'Quiz deleted successfully.' });
  }),

  // Get submissions for a quiz (Teacher / Admin)
  getQuizSubmissions: asyncHandler(async (req, res) => {
    const quizId = req.params.id;
    const submissions = await prisma.quizSubmission.findMany({
      where: { quizId },
      include: {
        student: {
          include: {
            user: {
              select: {
                firstName: true,
                lastName: true,
                email: true
              }
            }
          }
        }
      },
      orderBy: { submittedAt: 'desc' }
    });

    res.json({ success: true, data: submissions });
  })
};

module.exports = QuizController;
