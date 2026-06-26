const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const prisma = require('../config/database');
const logger = require('../config/logger');
let io;

const initSocket = (server, corsOptions) => {
  io = new Server(server, {
    cors: {
      ...corsOptions,
      methods: ["GET", "POST"]
    }
  });

  // JWT Verification Middleware
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.replace('Bearer ', '');
    if (!token) {
      logger.warn(`Unauthenticated Socket.IO connection attempt from socket: ${socket.id}`);
      return next(new Error('Authentication token required'));
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret_here');
      if (!decoded.userId || !decoded.role) {
        logger.warn(`Invalid Socket.IO token structure for socket: ${socket.id}`);
        return next(new Error('Invalid token structure'));
      }
      socket.user = decoded;
      next();
    } catch (err) {
      logger.warn(`Failed Socket.IO authentication: ${socket.id} - ${err.message}`);
      return next(new Error('Authentication failed'));
    }
  });

  io.on('connection', (socket) => {
    logger.info(`Secure client connected: ${socket.id} (User: ${socket.user.userId}, Role: ${socket.user.role})`);

    // Join room based on role (Dashboard)
    socket.on('join_dashboard', (role) => {
      // Validate role access
      const userRoles = socket.user.roles || [socket.user.role];
      if (!userRoles.includes(role)) {
        logger.warn(`Unauthorized join_dashboard attempt by user ${socket.user.userId} to dashboard_${role}`);
        return;
      }
      socket.join(`dashboard_${role}`);
      logger.info(`Socket ${socket.id} joined dashboard_${role}`);
    });

    // Join room based on user ID for targeted notifications
    socket.on('join_user', (userId) => {
      // Only allow if it matches their user ID
      if (socket.user.userId !== userId) {
        logger.warn(`Unauthorized join_user attempt by user ${socket.user.userId} to user_${userId}`);
        return;
      }
      socket.join(`user_${userId}`);
      logger.info(`Socket ${socket.id} joined user_${userId}`);
    });

    // Join specific entity room (e.g., student ID or class ID)
    socket.on('join_room', async (roomName) => {
      // Enforce boundary checks
      if (roomName.startsWith('student_')) {
        const studentId = roomName.replace('student_', '');
        if (socket.user.role === 'STUDENT') {
          const studentProfile = await prisma.studentProfile.findUnique({
            where: { id: studentId },
            select: { userId: true }
          });
          if (!studentProfile || studentProfile.userId !== socket.user.userId) {
            logger.warn(`Unauthorized student room join: user ${socket.user.userId} to student room ${roomName}`);
            return;
          }
        } else if (!['TEACHER', 'ADMIN', 'SUPER_ADMIN'].includes(socket.user.role)) {
          logger.warn(`Unauthorized student room join: user ${socket.user.userId} (Role: ${socket.user.role}) to ${roomName}`);
          return;
        }
      } else if (roomName.startsWith('teacher_')) {
        const teacherId = roomName.replace('teacher_', '');
        if (socket.user.role === 'TEACHER') {
          const teacherProfile = await prisma.teacher.findUnique({
            where: { id: teacherId },
            select: { userId: true }
          });
          if (!teacherProfile || teacherProfile.userId !== socket.user.userId) {
            logger.warn(`Unauthorized teacher room join: user ${socket.user.userId} to teacher room ${roomName}`);
            return;
          }
        } else if (!['ADMIN', 'SUPER_ADMIN'].includes(socket.user.role)) {
          logger.warn(`Unauthorized teacher room join: user ${socket.user.userId} (Role: ${socket.user.role}) to ${roomName}`);
          return;
        }
      } else if (roomName === 'admin_dashboard') {
        const userRoles = socket.user.roles || [socket.user.role];
        const isAdmin = userRoles.includes('ADMIN') || userRoles.includes('SUPER_ADMIN');
        if (!isAdmin) {
          logger.warn(`Unauthorized admin room join: user ${socket.user.userId} to admin_dashboard`);
          return;
        }
      } else if (roomName.startsWith('trip_')) {
        // Authorized roles check if needed, but typically shared for transit notifications
      } else {
        // Block raw room joins for dashboards or generic user rooms
        if (roomName.startsWith('dashboard_') || roomName.startsWith('user_')) {
          logger.warn(`Unauthorized raw join_room attempt to ${roomName}`);
          return;
        }
      }

      socket.join(roomName);
      logger.info(`Socket ${socket.id} joined ${roomName}`);
    });

    socket.on('join_trip', (data) => {
      const roomName = `trip_${data.tripId}`;
      socket.join(roomName);
      logger.info(`Socket ${socket.id} joined ${roomName}`);
    });

    socket.on('leave_room', (roomName) => {
      socket.leave(roomName);
      logger.info(`Socket ${socket.id} left ${roomName}`);
    });

    socket.on('leave_trip', (data) => {
      const roomName = `trip_${data.tripId}`;
      socket.leave(roomName);
      logger.info(`Socket ${socket.id} left ${roomName}`);
    });

    // Real-time chat message broker
    socket.on('send_message', (data) => {
      const { senderId, senderName, recipientId, text } = data;
      if (!recipientId || !text) {
        logger.warn(`Invalid send_message received from socket ${socket.id}:`, data);
        return;
      }

      // Check if the sender is actually the authenticated user
      if (socket.user.userId !== senderId) {
        logger.warn(`Spoofed sender ID in chat: authenticated ${socket.user.userId} sent as ${senderId}`);
        return;
      }

      logger.info(`Relaying chat: ${senderName} (${senderId}) -> ${recipientId}: "${text.substring(0, 30)}..."`);

      // Emit receive_message event to the targeted user room
      io.to(`user_${recipientId}`).emit('receive_message', {
        senderId,
        senderName,
        text,
        timestamp: new Date().toISOString()
      });
    });

    socket.on('disconnect', () => {
      logger.info(`Client disconnected: ${socket.id}`);
    });
  });

  return io;
};

const getIO = () => {
  if (!io) {
    throw new Error('Socket.io not initialized');
  }
  return io;
};

const emitEvent = (event, data, target = null) => {
  if (!io) return;
  
  if (target) {
    let room = target;
    
    // Check if target is already a prefixed room
    const isPrefixed = target.startsWith('dashboard_') || 
                      target.startsWith('class_') || 
                      target.startsWith('student_') || 
                      target.startsWith('user_') || 
                      target.startsWith('trip_');
    
    if (!isPrefixed) {
      room = `dashboard_${target}`;
    }

    io.to(room).emit(event, data);
    logger.debug(`Socket emit: [${event}] to [${room}]`);

    // Emit to admins for broader visibility
    if (room.startsWith('dashboard_') && !room.includes('SUPER_ADMIN') && !room.includes('ADMIN')) {
        io.to('dashboard_SUPER_ADMIN').emit(event, data);
        io.to('dashboard_ADMIN').emit(event, data);
    }
  } else {
    io.emit(event, data);
  }
};

module.exports = {
  initSocket,
  getIO,
  emitEvent
};
