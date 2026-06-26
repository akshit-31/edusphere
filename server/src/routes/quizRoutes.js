const express = require('express');
const {
  createQuiz,
  getQuizzes,
  submitQuiz,
  getQuizSubmissions,
  deleteQuiz,
} = require('../controllers/quizController');
const { authMiddleware, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.post('/', requireRole('SUPER_ADMIN', 'ADMIN', 'TEACHER'), createQuiz);
router.get('/', getQuizzes);
router.post('/:id/submit', requireRole('STUDENT'), submitQuiz);
router.get('/:id/submissions', requireRole('SUPER_ADMIN', 'ADMIN', 'TEACHER'), getQuizSubmissions);
router.delete('/:id', requireRole('SUPER_ADMIN', 'ADMIN', 'TEACHER'), deleteQuiz);

module.exports = router;
