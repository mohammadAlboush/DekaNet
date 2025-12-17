const express = require('express');
const router = express.Router();
const ArchivController = require('../controllers/archiv.controller');
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
// ARCHIVE QUERY ROUTES
// ============================================

/**
 * Get archived planungen with filters
 * GET /api/archiv/planungen
 * Access: All authenticated users (filtered by role)
 */
router.get('/planungen',
    authenticate,
    [
        query('planungphase_id').optional().isInt().withMessage('Phase ID muss eine Zahl sein'),
        query('professor_id').optional().isInt().withMessage('Professor ID muss eine Zahl sein'),
        query('semester_id').optional().isInt().withMessage('Semester ID muss eine Zahl sein'),
        query('status').optional().isIn(['entwurf', 'eingereicht', 'freigegeben', 'abgelehnt']).withMessage('Ungültiger Status'),
        query('von_datum').optional().isISO8601().withMessage('Ungültiges Von-Datum'),
        query('bis_datum').optional().isISO8601().withMessage('Ungültiges Bis-Datum'),
        query('limit').optional().isInt({ min: 1, max: 1000 }).withMessage('Limit muss zwischen 1 und 1000 liegen'),
        query('offset').optional().isInt({ min: 0 }).withMessage('Offset muss >= 0 sein')
    ],
    validate,
    ArchivController.getArchivedPlanungen
);

/**
 * Get archived planung detail
 * GET /api/archiv/planungen/:id
 * Access: All authenticated users (filtered by role)
 */
router.get('/planungen/:id',
    authenticate,
    [
        param('id').isInt().withMessage('Archiv ID muss eine Zahl sein')
    ],
    validate,
    ArchivController.getArchivedPlanungDetail
);

/**
 * Search archived planungen
 * GET /api/archiv/search
 * Access: All authenticated users (filtered by role)
 */
router.get('/search',
    authenticate,
    [
        query('query').notEmpty().withMessage('Suchbegriff ist erforderlich'),
        query('type').optional().isIn(['professor', 'semester', 'phase', 'status']).withMessage('Ungültiger Suchtyp')
    ],
    validate,
    ArchivController.searchArchiv
);

/**
 * Get archive summary for dashboard
 * GET /api/archiv/summary
 * Access: All authenticated users (filtered by role)
 */
router.get('/summary',
    authenticate,
    ArchivController.getArchiveSummary
);

/**
 * Get archive statistics
 * GET /api/archiv/statistics
 * Access: All authenticated users
 */
router.get('/statistics',
    authenticate,
    ArchivController.getArchiveStatistics
);

// ============================================
// ARCHIVE MANAGEMENT ROUTES (DEKAN ONLY)
// ============================================

/**
 * Restore archived planung
 * POST /api/archiv/planungen/:id/restore
 * Access: Dekan only
 */
router.post('/planungen/:id/restore',
    authenticate,
    [
        param('id').isInt().withMessage('Archiv ID muss eine Zahl sein')
    ],
    validate,
    ArchivController.restoreArchivedPlanung
);

/**
 * Manually archive a planung
 * POST /api/archiv/planungen/archive
 * Access: Dekan only
 */
router.post('/planungen/archive',
    authenticate,
    [
        body('planung_id').isInt().withMessage('Planung ID ist erforderlich'),
        body('phase_id').isInt().withMessage('Phase ID ist erforderlich'),
        body('grund').optional().isString().withMessage('Grund muss ein Text sein')
    ],
    validate,
    ArchivController.archivePlanung
);

/**
 * Export archive to Excel/CSV
 * GET /api/archiv/export
 * Access: All authenticated users (filtered by role)
 */
router.get('/export',
    authenticate,
    [
        query('planungphase_id').optional().isInt().withMessage('Phase ID muss eine Zahl sein'),
        query('professor_id').optional().isInt().withMessage('Professor ID muss eine Zahl sein'),
        query('semester_id').optional().isInt().withMessage('Semester ID muss eine Zahl sein'),
        query('status').optional().isIn(['entwurf', 'eingereicht', 'freigegeben', 'abgelehnt']).withMessage('Ungültiger Status'),
        query('von_datum').optional().isISO8601().withMessage('Ungültiges Von-Datum'),
        query('bis_datum').optional().isISO8601().withMessage('Ungültiges Bis-Datum')
    ],
    validate,
    ArchivController.exportArchiv
);

/**
 * Clean up old archives (Maintenance)
 * DELETE /api/archiv/cleanup
 * Access: Dekan only
 */
router.delete('/cleanup',
    authenticate,
    [
        query('older_than_days').optional().isInt({ min: 30 }).withMessage('older_than_days muss mindestens 30 sein')
    ],
    validate,
    ArchivController.cleanupOldArchives
);

module.exports = router;