const prisma = require('../config/database');
const asyncHandler = require('../utils/asyncHandler');
const NotFoundError = require('../errors/NotFoundError');
const ValidationError = require('../errors/ValidationError');

// Submit an assignment (Student only)
const submitAssignment = asyncHandler(async (req, res) => {
  const { assignmentId } = req.body;
  const student = await prisma.studentProfile.findFirst({
    where: { userId: req.user.id }
  });

  if (!student) {
    throw new NotFoundError('Student profile not found');
  }

  const assignment = await prisma.assignment.findUnique({
    where: { id: assignmentId }
  });

  if (!assignment) {
    throw new NotFoundError('Assignment not found');
  }

  // Check if already submitted
  const existingSubmission = await prisma.assignmentSubmission.findUnique({
    where: {
      assignmentId_studentId: {
        assignmentId,
        studentId: student.id,
      },
    },
  });

  if (existingSubmission && existingSubmission.status !== 'PENDING') {
    throw new ValidationError('Assignment already submitted');
  }

  // Handle file upload
  const filePath = req.file ? `/uploads/submissions/${req.file.filename}` : null;
  
  const status = new Date() > new Date(assignment.dueDate) ? 'LATE' : 'SUBMITTED';

  const submission = await prisma.assignmentSubmission.upsert({
    where: {
      assignmentId_studentId: {
        assignmentId,
        studentId: student.id,
      },
    },
    update: {
      filePath,
      status,
      submittedAt: new Date(),
    },
    create: {
      assignmentId,
      studentId: student.id,
      filePath,
      status,
      submittedAt: new Date(),
    },
  });

  res.status(200).json({
    success: true,
    message: 'Assignment submitted successfully',
    submission,
  });

  // Emit real-time event to the teacher's user room
  const { emitEvent } = require('../services/socketService');
  prisma.assignment.findUnique({
    where: { id: assignmentId },
    select: { teacherId: true, teacher: { select: { userId: true } } }
  }).then(asg => {
    if (asg && asg.teacher && asg.teacher.userId) {
      emitEvent('SUBMISSION_UPDATED', {
        id: submission.id,
        assignmentId,
        studentId: student.id,
        status
      }, `user_${asg.teacher.userId}`);
    }
  }).catch(err => {
    console.error("Error emitting SUBMISSION_UPDATED event on submission:", err);
  });
});

// Grade a submission (Teacher only)
const gradeSubmission = asyncHandler(async (req, res) => {
  const { submissionId } = req.params;
  const { grade, feedback } = req.body;
  const teacherId = req.user.teacherId;

  const submission = await prisma.assignmentSubmission.findUnique({
    where: { id: submissionId },
    include: { assignment: true }
  });

  if (!submission) {
    throw new NotFoundError('Submission not found');
  }

  if (submission.assignment.teacherId !== teacherId && req.user.role !== 'ADMIN' && req.user.role !== 'SUPER_ADMIN') {
    throw new ValidationError('You are not authorized to grade this submission');
  }

  const updatedSubmission = await prisma.assignmentSubmission.update({
    where: { id: submissionId },
    data: {
      grade,
      feedback,
      status: 'GRADED',
    },
  });

  res.status(200).json({
    success: true,
    message: 'Submission graded successfully',
    submission: updatedSubmission,
  });

  // Emit real-time event to student user room
  const { emitEvent } = require('../services/socketService');
  prisma.studentProfile.findUnique({
    where: { id: updatedSubmission.studentId },
    select: { userId: true }
  }).then(student => {
    if (student && student.userId) {
      emitEvent('SUBMISSION_UPDATED', {
        id: updatedSubmission.id,
        assignmentId: updatedSubmission.assignmentId,
        studentId: updatedSubmission.studentId,
        grade,
        status: 'GRADED'
      }, `user_${student.userId}`);
    }
  }).catch(err => {
    console.error("Error emitting SUBMISSION_UPDATED event on grading:", err);
  });
});

module.exports = {
  submitAssignment,
  gradeSubmission,
};
