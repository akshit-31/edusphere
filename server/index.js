require('dotenv').config();

// ── Validate critical environment variables ──────────────────────────────
const REQUIRED_ENV = ['JWT_SECRET', 'DATABASE_URL'];
const missing = REQUIRED_ENV.filter((key) => !process.env[key]);
if (missing.length > 0) {
  console.error(`\n❌ Missing required environment variables: ${missing.join(', ')}`);
  console.error('   Please check your .env file.\n');
  process.exit(1);
}

const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const logger = require('./src/config/logger');
const cookieParser = require('cookie-parser');

// Routes
const authRoutes = require('./src/routes/authRoutes');
const studentRoutes = require('./src/routes/studentRoutes');
const teacherRoutes = require('./src/routes/teacherRoutes');
const attendanceRoutes = require('./src/routes/attendanceRoutes');
const academicRoutes = require('./src/routes/academicRoutes');
const feeRoutes = require('./src/routes/feeRoutes');
const examRoutes = require('./src/routes/examRoutes');
const libraryRoutes = require('./src/routes/libraryRoutes');
const inventoryRoutes = require('./src/routes/inventoryRoutes');
const announcementRoutes = require('./src/routes/announcementRoutes');
const dashboardRoutes = require('./src/routes/dashboard');
const userRoutes = require('./src/routes/userRoutes');
const serviceRoutes = require('./src/routes/serviceRoutes');
const hrRoutes = require('./src/routes/hrRoutes');
const payrollRoutes = require('./src/routes/payrollRoutes');
const termRoutes = require('./src/routes/termRoutes');
const gradeScaleRoutes = require('./src/routes/gradeScaleRoutes');
const reportCardRoutes = require('./src/routes/reportCardRoutes');
const paymentRoutes = require('./src/routes/paymentRoutes');
const schoolConfigRoutes = require('./src/routes/schoolConfigRoutes');
const enquiryRoutes = require('./src/routes/enquiryRoutes');
const scannerRoutes = require('./src/routes/scannerRoutes');
const assignmentRoutes = require('./src/routes/assignmentRoutes');
const transportRoutes = require('./src/routes/transportRoutes');
const calendarRoutes = require('./src/routes/calendarRoutes');
const timetableRoutes = require('./src/routes/timetableRoutes');
const backupRoutes = require('./src/routes/backupRoutes');
const aiRoutes = require('./src/routes/AiRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');
const quizRoutes = require('./src/routes/quizRoutes');
const { initSocket } = require('./src/services/socketService');
const { initScheduler } = require('./src/config/scheduler');
const errorHandler = require('./src/middleware/errorHandler');

// Initialize app
const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 5001;

// Trust proxy for Render's load balancer (needed for rate limiting and secure cookies)
app.set('trust proxy', 1);

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim()) : true,
  credentials: true,
};
app.use(cors(corsOptions));

// Initialize Socket.io
const io = initSocket(server, corsOptions);
app.set('io', io);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser(process.env.COOKIE_SECRET));

// Compression
app.use(compression());

// Static files (uploaded PDFs, images, etc.)
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Rate limiting
if (process.env.RATE_LIMIT_ENABLED === 'true') {
  const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000,
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 200,
    message: 'Too many requests from this IP, please try again later.',
  });
  app.use('/api/', limiter);
}

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'EduSphere School ERP',
    schoolId: process.env.SCHOOL_ID,
    schoolName: process.env.SCHOOL_NAME,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

// API Routes
const apiRouter = express.Router();

apiRouter.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'EduSphere School ERP',
    schoolId: process.env.SCHOOL_ID,
    schoolName: process.env.SCHOOL_NAME,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

apiRouter.use('/auth', authRoutes);
apiRouter.use('/students', studentRoutes);
apiRouter.use('/teachers', teacherRoutes);
apiRouter.use('/attendance', attendanceRoutes);
apiRouter.use('/academic', academicRoutes);
apiRouter.use('/fees', feeRoutes);
apiRouter.use('/exams', examRoutes);
apiRouter.use('/library', libraryRoutes);
apiRouter.use('/inventory', inventoryRoutes);
apiRouter.use('/announcements', announcementRoutes);
apiRouter.use('/dashboard', dashboardRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/services', serviceRoutes);
apiRouter.use('/hr', hrRoutes);
apiRouter.use('/payroll', payrollRoutes);
apiRouter.use('/terms', termRoutes);
apiRouter.use('/grade-scales', gradeScaleRoutes);
apiRouter.use('/report-cards', reportCardRoutes);
apiRouter.use('/payments', paymentRoutes);
apiRouter.use('/school-config', schoolConfigRoutes);
apiRouter.use('/enquiries', enquiryRoutes);
apiRouter.use('/scanners', scannerRoutes);
apiRouter.use('/assignments', assignmentRoutes);
apiRouter.use('/transport', transportRoutes);
apiRouter.use('/calendar', calendarRoutes);
apiRouter.use('/timetables', timetableRoutes);
apiRouter.use('/timetable', timetableRoutes);
apiRouter.use('/admin/backups', backupRoutes);
apiRouter.use('/ai', aiRoutes);
apiRouter.use('/notifications', notificationRoutes);
apiRouter.use('/quizzes', quizRoutes);

app.use('/api', apiRouter);
app.use('/api/v1', apiRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use(errorHandler);

// Start server
server.listen(PORT, () => {
  logger.info(`🚀 School ERP Server running on http://localhost:${PORT}`);
  logger.info(`🏫 School: ${process.env.SCHOOL_NAME} (${process.env.SCHOOL_ID})`);
  logger.info(`📊 Environment: ${process.env.NODE_ENV}`);
  logger.info(`🏥 Health check: http://localhost:${PORT}/health`);
  
  // Start Backup Scheduler
  initScheduler();
});
