const PlanungsphaseModel = require('../models/planungsphase.model');
const ArchivModel = require('../models/archiv.model');
const { validationResult } = require('express-validator');

class PlanungsphaseController {
    /**
     * Start a new planning phase
     * POST /api/planungphase/start
     */
    static async startPhase(req, res) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }

            const { semester_id, name, startdatum, enddatum } = req.body;
            const userId = req.user.id;

            // Check if user is Dekan
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können Planungsphasen starten'
                });
            }

            const phase = await PlanungsphaseModel.startPhase({
                semester_id,
                name,
                startdatum,
                enddatum
            }, userId);

            res.status(201).json(phase);

        } catch (error) {
            console.error('Error starting phase:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Starten der Planungsphase',
                error: error.message
            });
        }
    }

    /**
     * Close current planning phase
     * POST /api/planungphase/:id/close
     */
    static async closePhase(req, res) {
        try {
            const phaseId = req.params.id;
            const { archiviere_entwuerfe, grund } = req.body;
            const userId = req.user.id;

            // Check if user is Dekan
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können Planungsphasen schließen'
                });
            }

            const result = await PlanungsphaseModel.closePhase(
                phaseId,
                userId,
                { archiviere_entwuerfe, grund }
            );

            res.json(result);

        } catch (error) {
            console.error('Error closing phase:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Schließen der Planungsphase',
                error: error.message
            });
        }
    }

    /**
     * Get all planning phases
     * GET /api/planungphase
     */
    static async getAllPhases(req, res) {
        try {
            const { semester_id } = req.query;
            const result = await PlanungsphaseModel.getAllPhases(semester_id);

            res.json(result);

        } catch (error) {
            console.error('Error getting phases:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Planungsphasen',
                error: error.message
            });
        }
    }

    /**
     * Get active planning phase
     * GET /api/planungphase/active
     */
    static async getActivePhase(req, res) {
        try {
            const phase = await PlanungsphaseModel.getActivePhase();
            res.json(phase);

        } catch (error) {
            console.error('Error getting active phase:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der aktiven Phase',
                error: error.message
            });
        }
    }

    /**
     * Update planning phase
     * PUT /api/planungphase/:id
     */
    static async updatePhase(req, res) {
        try {
            const phaseId = req.params.id;
            const updates = req.body;

            // Check if user is Dekan
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können Planungsphasen bearbeiten'
                });
            }

            const phase = await PlanungsphaseModel.updatePhase(phaseId, updates);

            if (!phase) {
                return res.status(404).json({
                    success: false,
                    message: 'Planungsphase nicht gefunden'
                });
            }

            res.json(phase);

        } catch (error) {
            console.error('Error updating phase:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Aktualisieren der Planungsphase',
                error: error.message
            });
        }
    }

    /**
     * Check submission status
     * GET /api/planungphase/submission-status
     */
    static async checkSubmissionStatus(req, res) {
        try {
            const professorId = req.query.professor_id || req.user.id;

            // Check if requesting own status or is Dekan
            if (professorId != req.user.id && req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nicht autorisiert'
                });
            }

            const status = await PlanungsphaseModel.checkSubmissionStatus(professorId);
            res.json(status);

        } catch (error) {
            console.error('Error checking submission status:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Prüfen des Einreichungsstatus',
                error: error.message
            });
        }
    }

    /**
     * Get phase submissions
     * GET /api/planungphase/:id/submissions
     */
    static async getPhaseSubmissions(req, res) {
        try {
            const phaseId = req.params.id;

            // Only Dekan can see all submissions
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können alle Einreichungen sehen'
                });
            }

            const submissions = await PlanungsphaseModel.getPhaseSubmissions(phaseId);
            res.json(submissions);

        } catch (error) {
            console.error('Error getting submissions:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Einreichungen',
                error: error.message
            });
        }
    }

    /**
     * Record submission
     * POST /api/planungphase/record-submission
     */
    static async recordSubmission(req, res) {
        try {
            const { planung_id } = req.body;
            const professorId = req.user.id;

            const submission = await PlanungsphaseModel.recordSubmission(
                planung_id,
                professorId
            );

            res.status(201).json(submission);

        } catch (error) {
            console.error('Error recording submission:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Aufzeichnen der Einreichung',
                error: error.message
            });
        }
    }

    /**
     * Get phase statistics
     * GET /api/planungphase/:id/statistics
     */
    static async getPhaseStatistics(req, res) {
        try {
            const phaseId = req.params.id;
            const statistics = await PlanungsphaseModel.getPhaseStatistics(phaseId);

            res.json(statistics);

        } catch (error) {
            console.error('Error getting statistics:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Statistiken',
                error: error.message
            });
        }
    }

    /**
     * Get phase history
     * GET /api/planungphase/history
     */
    static async getPhaseHistory(req, res) {
        try {
            const professorId = req.query.professor_id;

            // If professor_id provided, check authorization
            if (professorId && professorId != req.user.id && req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nicht autorisiert'
                });
            }

            const history = await PlanungsphaseModel.getPhaseHistory(
                professorId || (req.user.rolle !== 'Dekan' ? req.user.id : null)
            );

            res.json(history);

        } catch (error) {
            console.error('Error getting history:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Historie',
                error: error.message
            });
        }
    }

    /**
     * Generate phase report (PDF)
     * GET /api/planungphase/:id/report
     */
    static async generatePhaseReport(req, res) {
        try {
            const phaseId = req.params.id;

            // Only Dekan can generate reports
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können Berichte generieren'
                });
            }

            // Get phase data and statistics
            const phase = await PlanungsphaseModel.getPhaseStatistics(phaseId);
            const submissions = await PlanungsphaseModel.getPhaseSubmissions(phaseId);

            // Here you would generate a PDF
            // For now, return data as JSON
            const reportData = {
                phase,
                submissions,
                generated_at: new Date(),
                generated_by: req.user.id
            };

            // In production, you would use a PDF library like pdfkit or puppeteer
            // const pdf = await generatePDF(reportData);
            // res.setHeader('Content-Type', 'application/pdf');
            // res.setHeader('Content-Disposition', `attachment; filename=phase_${phaseId}_report.pdf`);
            // res.send(pdf);

            res.json(reportData);

        } catch (error) {
            console.error('Error generating report:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Generieren des Berichts',
                error: error.message
            });
        }
    }

    /**
     * Get phase dashboard data
     * GET /api/planungphase/dashboard
     */
    static async getPhaseDashboard(req, res) {
        try {
            const activePhase = await PlanungsphaseModel.getActivePhase();

            if (!activePhase) {
                return res.json({
                    phase: null,
                    einreichungen_heute: 0,
                    offene_reviews: 0,
                    durchschnittliche_bearbeitungszeit: 0,
                    deadline_warnung: false,
                    professoren_ohne_einreichung: []
                });
            }

            const submissions = await PlanungsphaseModel.getPhaseSubmissions(activePhase.id);
            const statistics = await PlanungsphaseModel.getPhaseStatistics(activePhase.id);

            // Calculate today's submissions
            const heute = new Date();
            heute.setHours(0, 0, 0, 0);
            const einreichungen_heute = submissions.filter(s => {
                const eingereicht = new Date(s.eingereicht_am);
                eingereicht.setHours(0, 0, 0, 0);
                return eingereicht.getTime() === heute.getTime();
            }).length;

            // Count pending reviews
            const offene_reviews = submissions.filter(s => s.status === 'eingereicht').length;

            // Check deadline warning (within 3 days)
            let deadline_warnung = false;
            if (activePhase.enddatum) {
                const diffDays = Math.ceil((new Date(activePhase.enddatum) - new Date()) / (1000 * 60 * 60 * 24));
                deadline_warnung = diffDays <= 3 && diffDays > 0;
            }

            res.json({
                phase: activePhase,
                einreichungen_heute,
                offene_reviews,
                durchschnittliche_bearbeitungszeit: statistics.durchschnittliche_bearbeitungszeit || 0,
                deadline_warnung,
                professoren_ohne_einreichung: [] // Would need to implement this query
            });

        } catch (error) {
            console.error('Error getting dashboard data:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Dashboard-Daten',
                error: error.message
            });
        }
    }

    /**
     * Send reminders to professors
     * POST /api/planungphase/:id/reminders
     */
    static async sendReminders(req, res) {
        try {
            const phaseId = req.params.id;
            const { professor_ids } = req.body;

            // Only Dekan can send reminders
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können Erinnerungen senden'
                });
            }

            const result = await PlanungsphaseModel.sendReminders(phaseId, professor_ids);
            res.json(result);

        } catch (error) {
            console.error('Error sending reminders:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Senden der Erinnerungen',
                error: error.message
            });
        }
    }

    /**
     * Get notification settings
     * GET /api/planungphase/notification-settings
     */
    static async getNotificationSettings(req, res) {
        try {
            // Mock implementation - should fetch from database
            const settings = {
                deadline_reminder_days: 3,
                auto_close_after_deadline: false,
                send_submission_confirmation: true
            };

            res.json(settings);

        } catch (error) {
            console.error('Error getting notification settings:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Benachrichtigungseinstellungen',
                error: error.message
            });
        }
    }

    /**
     * Update notification settings
     * PUT /api/planungphase/notification-settings
     */
    static async updateNotificationSettings(req, res) {
        try {
            // Only Dekan can update settings
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können Einstellungen ändern'
                });
            }

            const settings = req.body;

            // Mock implementation - should update in database
            res.json({
                success: true,
                message: 'Einstellungen aktualisiert',
                settings
            });

        } catch (error) {
            console.error('Error updating notification settings:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Aktualisieren der Benachrichtigungseinstellungen',
                error: error.message
            });
        }
    }
}

module.exports = PlanungsphaseController;