const express = require('express');
const router = express.Router();
const PlanungsphaseController = require('../controllers/planungsphase.controller');
const { authenticate } = require('../middleware/auth');
const { body, param, query, validationResult } = require('express-validator');

/**
 * Validation middleware
 */
const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    next();
};

// ============================================
// PHASE MANAGEMENT ROUTES (DEKAN)
// ============================================

/**
 * Start a new planning phase
 * POST /api/planungphase/start
 * Access: Dekan only
 */
router.post('/start',
    authenticate,
    [
        body('semester_id').isInt().withMessage('Semester ID muss eine Zahl sein'),
        body('name').notEmpty().withMessage('Phasenname ist erforderlich'),
        body('startdatum').optional().isISO8601().withMessage('Ungültiges Startdatum'),
        body('enddatum').optional().isISO8601().withMessage('Ungültiges Enddatum')
    ],
    validate,
    PlanungsphaseController.startPhase
);

/**
 * Close current planning phase
 * POST /api/planungphase/:id/close
 * Access: Dekan only
 */
router.post('/:id/close',
    authenticate,
    [
        param('id').isInt().withMessage('Phase ID muss eine Zahl sein'),
        body('archiviere_entwuerfe').optional().isBoolean().withMessage('archiviere_entwuerfe muss boolean sein'),
        body('grund').optional().isString().withMessage('Grund muss ein Text sein')
    ],
    validate,
    PlanungsphaseController.closePhase
);

/**
 * Update planning phase
 * PUT /api/planungphase/:id
 * Access: Dekan only
 */
router.put('/:id',
    authenticate,
    [
        param('id').isInt().withMessage('Phase ID muss eine Zahl sein'),
        body('name').optional().notEmpty().withMessage('Phasenname darf nicht leer sein'),
        body('enddatum').optional().isISO8601().withMessage('Ungültiges Enddatum')
    ],
    validate,
    PlanungsphaseController.updatePhase
);

// ============================================
// PHASE QUERY ROUTES (ALL USERS)
// ============================================

/**
 * Get all planning phases
 * GET /api/planungphase
 * Access: All authenticated users
 */
router.get('/',
    authenticate,
    [
        query('semester_id').optional().isInt().withMessage('Semester ID muss eine Zahl sein')
    ],
    validate,
    PlanungsphaseController.getAllPhases
);

/**
 * Get active planning phase
 * GET /api/planungphase/active
 * Access: All authenticated users
 */
router.get('/active',
    authenticate,
    PlanungsphaseController.getActivePhase
);

/**
 * Get phase history
 * GET /api/planungphase/history
 * Access: All authenticated users
 */
router.get('/history',
    authenticate,
    [
        query('professor_id').optional().isInt().withMessage('Professor ID muss eine Zahl sein')
    ],
    validate,
    PlanungsphaseController.getPhaseHistory
);

// ============================================
// SUBMISSION TRACKING ROUTES
// ============================================

/**
 * Check submission status
 * GET /api/planungphase/submission-status
 * Access: All authenticated users
 */
router.get('/submission-status',
    authenticate,
    [
        query('professor_id').optional().isInt().withMessage('Professor ID muss eine Zahl sein')
    ],
    validate,
    PlanungsphaseController.checkSubmissionStatus
);

/**
 * Record submission
 * POST /api/planungphase/record-submission
 * Access: Professor/Lehrbeauftragter
 */
router.post('/record-submission',
    authenticate,
    [
        body('planung_id').isInt().withMessage('Planung ID ist erforderlich')
    ],
    validate,
    PlanungsphaseController.recordSubmission
);

/**
 * Get phase submissions
 * GET /api/planungphase/:id/submissions
 * Access: Dekan only
 */
router.get('/:id/submissions',
    authenticate,
    [
        param('id').isInt().withMessage('Phase ID muss eine Zahl sein')
    ],
    validate,
    PlanungsphaseController.getPhaseSubmissions
);

// ============================================
// STATISTICS & REPORTS
// ============================================

/**
 * Get phase statistics
 * GET /api/planungphase/:id/statistics
 * Access: All authenticated users
 */
router.get('/:id/statistics',
    authenticate,
    [
        param('id').isInt().withMessage('Phase ID muss eine Zahl sein')
    ],
    validate,
    PlanungsphaseController.getPhaseStatistics
);

/**
 * Generate phase report (PDF)
 * GET /api/planungphase/:id/report
 * Access: Dekan only
 */
router.get('/:id/report',
    authenticate,
    [
        param('id').isInt().withMessage('Phase ID muss eine Zahl sein')
    ],
    validate,
    PlanungsphaseController.generatePhaseReport
);

/**
 * Get phase dashboard data
 * GET /api/planungphase/dashboard
 * Access: Dekan only
 */
router.get('/dashboard',
    authenticate,
    PlanungsphaseController.getPhaseDashboard
);

// ============================================
// NOTIFICATIONS & REMINDERS
// ============================================

/**
 * Send reminders to professors
 * POST /api/planungphase/:id/reminders
 * Access: Dekan only
 */
router.post('/:id/reminders',
    authenticate,
    [
        param('id').isInt().withMessage('Phase ID muss eine Zahl sein'),
        body('professor_ids').optional().isArray().withMessage('Professor IDs müssen ein Array sein')
    ],
    validate,
    PlanungsphaseController.sendReminders
);

/**
 * Get notification settings
 * GET /api/planungphase/notification-settings
 * Access: Dekan only
 */
router.get('/notification-settings',
    authenticate,
    PlanungsphaseController.getNotificationSettings
);

/**
 * Update notification settings
 * PUT /api/planungphase/notification-settings
 * Access: Dekan only
 */
router.put('/notification-settings',
    authenticate,
    [
        body('deadline_reminder_days').optional().isInt().withMessage('Reminder days muss eine Zahl sein'),
        body('auto_close_after_deadline').optional().isBoolean().withMessage('auto_close muss boolean sein'),
        body('send_submission_confirmation').optional().isBoolean().withMessage('confirmation muss boolean sein')
    ],
    validate,
    PlanungsphaseController.updateNotificationSettings
);

module.exports = router;