const ArchivModel = require('../models/archiv.model');
const { validationResult } = require('express-validator');

class ArchivController {
    /**
     * Get archived planungen with filters
     * GET /api/archiv/planungen
     */
    static async getArchivedPlanungen(req, res) {
        try {
            const filter = {
                planungphase_id: req.query.planungphase_id,
                professor_id: req.query.professor_id,
                semester_id: req.query.semester_id,
                status: req.query.status,
                von_datum: req.query.von_datum,
                bis_datum: req.query.bis_datum,
                limit: parseInt(req.query.limit) || 50,
                offset: parseInt(req.query.offset) || 0
            };

            // Professors can only see their own archived planungen
            if (req.user.rolle === 'Professor' || req.user.rolle === 'Lehrbeauftragter') {
                filter.professor_id = req.user.id;
                filter.nur_eigene = true;
            }

            const result = await ArchivModel.getArchivedPlanungen(filter);

            res.json({
                success: true,
                ...result
            });

        } catch (error) {
            console.error('Error getting archived planungen:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der archivierten Planungen',
                error: error.message
            });
        }
    }

    /**
     * Get archived planung detail
     * GET /api/archiv/planungen/:id
     */
    static async getArchivedPlanungDetail(req, res) {
        try {
            const archivId = req.params.id;
            const detail = await ArchivModel.getArchivedPlanungDetail(archivId);

            // Check authorization
            if (req.user.rolle !== 'Dekan' && detail.professor_id !== req.user.id) {
                return res.status(403).json({
                    success: false,
                    message: 'Nicht autorisiert'
                });
            }

            res.json({
                success: true,
                data: detail
            });

        } catch (error) {
            console.error('Error getting archived detail:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Archivdetails',
                error: error.message
            });
        }
    }

    /**
     * Restore archived planung
     * POST /api/archiv/planungen/:id/restore
     */
    static async restoreArchivedPlanung(req, res) {
        try {
            const archivId = req.params.id;

            // Only Dekan can restore
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können archivierte Planungen wiederherstellen'
                });
            }

            const result = await ArchivModel.restoreArchivedPlanung(
                archivId,
                req.user.id
            );

            res.json({
                success: true,
                message: 'Planung erfolgreich wiederhergestellt',
                planung_id: result.planung_id
            });

        } catch (error) {
            console.error('Error restoring archived planung:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Wiederherstellen der Planung',
                error: error.message
            });
        }
    }

    /**
     * Export archive to Excel
     * GET /api/archiv/export
     */
    static async exportArchiv(req, res) {
        try {
            // Only Dekan can export all
            const filter = {
                planungphase_id: req.query.planungphase_id,
                professor_id: req.query.professor_id,
                semester_id: req.query.semester_id,
                status: req.query.status,
                von_datum: req.query.von_datum,
                bis_datum: req.query.bis_datum
            };

            // Professors can only export their own
            if (req.user.rolle === 'Professor' || req.user.rolle === 'Lehrbeauftragter') {
                filter.professor_id = req.user.id;
                filter.nur_eigene = true;
            }

            const data = await ArchivModel.exportArchiv(filter);

            // In production, convert to actual Excel file using exceljs
            // For now, return CSV format
            const csv = this.convertToCSV(data);

            res.setHeader('Content-Type', 'text/csv');
            res.setHeader('Content-Disposition', 'attachment; filename="archiv_export.csv"');
            res.send(csv);

        } catch (error) {
            console.error('Error exporting archive:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Exportieren des Archivs',
                error: error.message
            });
        }
    }

    /**
     * Manually archive a planung
     * POST /api/archiv/planungen/archive
     */
    static async archivePlanung(req, res) {
        try {
            const { planung_id, phase_id, grund } = req.body;

            // Only Dekan can manually archive
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nur Dekane können Planungen manuell archivieren'
                });
            }

            await ArchivModel.archivePlanung(
                planung_id,
                phase_id,
                req.user.id,
                grund || 'manuell'
            );

            res.json({
                success: true,
                message: 'Planung erfolgreich archiviert'
            });

        } catch (error) {
            console.error('Error archiving planung:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Archivieren der Planung',
                error: error.message
            });
        }
    }

    /**
     * Get archive statistics
     * GET /api/archiv/statistics
     */
    static async getArchiveStatistics(req, res) {
        try {
            const statistics = await ArchivModel.getArchiveStatistics();

            res.json({
                success: true,
                data: statistics
            });

        } catch (error) {
            console.error('Error getting archive statistics:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Archivstatistiken',
                error: error.message
            });
        }
    }

    /**
     * Clean up old archives (Admin/Maintenance)
     * DELETE /api/archiv/cleanup
     */
    static async cleanupOldArchives(req, res) {
        try {
            // Only Dekan/Admin can cleanup
            if (req.user.rolle !== 'Dekan') {
                return res.status(403).json({
                    success: false,
                    message: 'Nicht autorisiert'
                });
            }

            const olderThanDays = parseInt(req.query.older_than_days) || 365;
            const result = await ArchivModel.cleanupOldArchives(olderThanDays);

            res.json({
                success: true,
                ...result
            });

        } catch (error) {
            console.error('Error cleaning up archives:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Bereinigen des Archivs',
                error: error.message
            });
        }
    }

    /**
     * Search archived planungen
     * GET /api/archiv/search
     */
    static async searchArchiv(req, res) {
        try {
            const { query, type } = req.query;

            if (!query) {
                return res.status(400).json({
                    success: false,
                    message: 'Suchbegriff erforderlich'
                });
            }

            const filter = {
                limit: 100
            };

            // Add role-based filtering
            if (req.user.rolle === 'Professor' || req.user.rolle === 'Lehrbeauftragter') {
                filter.professor_id = req.user.id;
                filter.nur_eigene = true;
            }

            const results = await ArchivModel.getArchivedPlanungen(filter);

            // Filter results based on search query
            const filtered = results.planungen.filter(p => {
                const searchStr = query.toLowerCase();
                return p.professor_name.toLowerCase().includes(searchStr) ||
                       p.semester_name.toLowerCase().includes(searchStr) ||
                       p.phase_name.toLowerCase().includes(searchStr) ||
                       p.status_bei_archivierung.toLowerCase().includes(searchStr);
            });

            res.json({
                success: true,
                planungen: filtered,
                total: filtered.length
            });

        } catch (error) {
            console.error('Error searching archive:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler bei der Archivsuche',
                error: error.message
            });
        }
    }

    /**
     * Get archive summary for dashboard
     * GET /api/archiv/summary
     */
    static async getArchiveSummary(req, res) {
        try {
            const statistics = await ArchivModel.getArchiveStatistics();

            // Get recent archives
            const recentFilter = {
                limit: 5,
                offset: 0
            };

            if (req.user.rolle === 'Professor' || req.user.rolle === 'Lehrbeauftragter') {
                recentFilter.professor_id = req.user.id;
                recentFilter.nur_eigene = true;
            }

            const recent = await ArchivModel.getArchivedPlanungen(recentFilter);

            res.json({
                success: true,
                statistics,
                recent_archives: recent.planungen
            });

        } catch (error) {
            console.error('Error getting archive summary:', error);
            res.status(500).json({
                success: false,
                message: 'Fehler beim Abrufen der Archivzusammenfassung',
                error: error.message
            });
        }
    }

    /**
     * Helper method to convert JSON to CSV
     */
    static convertToCSV(data) {
        if (!data || data.length === 0) {
            return '';
        }

        const headers = Object.keys(data[0]);
        const csvHeaders = headers.join(',');

        const csvRows = data.map(row => {
            return headers.map(header => {
                const value = row[header];
                // Escape quotes and wrap in quotes if contains comma
                if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
                    return `"${value.replace(/"/g, '""')}"`;
                }
                return value;
            }).join(',');
        });

        return [csvHeaders, ...csvRows].join('\n');
    }
}

module.exports = ArchivController;