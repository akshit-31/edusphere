const express = require('express');
const {
    getNotifications,
    markAsRead,
    markAllRead,
    sendNotification
} = require('../controllers/notificationController');
const { authMiddleware, requireRole } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/', getNotifications);
router.post('/send', requireRole('SUPER_ADMIN', 'ADMIN', 'TEACHER'), sendNotification);
router.put('/:id/read', markAsRead);
router.put('/mark-all-read', markAllRead);

module.exports = router;
