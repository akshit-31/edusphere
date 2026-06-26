const notificationService = require('../services/NotificationService');
const asyncHandler = require('../utils/asyncHandler');

const getNotifications = asyncHandler(async (req, res) => {
    const result = await notificationService.getNotifications(req.user.userId);
    res.status(200).json({
        success: true,
        ...result
    });
});

const markAsRead = asyncHandler(async (req, res) => {
    const { id } = req.params;
    await notificationService.markAsRead(id, req.user.userId);
    res.status(200).json({
        success: true,
        message: 'Notification marked as read'
    });
});

const markAllRead = asyncHandler(async (req, res) => {
    await notificationService.markAllRead(req.user.userId);
    res.status(200).json({
        success: true,
        message: 'All notifications marked as read'
    });
});

const sendNotification = asyncHandler(async (req, res) => {
    const { role, userIds, title, message, type, entityType, entityId } = req.body;
    
    if (!title || !message) {
        return res.status(400).json({ success: false, error: 'Title and message are required.' });
    }

    if (role) {
        // Send to all users matching role(s)
        await notificationService.notifyRoles(Array.isArray(role) ? role : [role], {
            title,
            message,
            type: type || 'SYSTEM',
            entityType,
            entityId
        });
    } else if (userIds && Array.isArray(userIds) && userIds.length > 0) {
        // Send to specific users
        await notificationService.notify({
            userIds,
            title,
            message,
            type: type || 'SYSTEM',
            entityType,
            entityId
        });
    } else {
        return res.status(400).json({ success: false, error: 'Either target role or userIds list is required.' });
    }

    res.status(201).json({
        success: true,
        message: 'Notification sent successfully'
    });
});

module.exports = {
    getNotifications,
    markAsRead,
    markAllRead,
    sendNotification
};
