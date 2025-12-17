const db = require('../config/database');

class ArchivModel {
    /**
     * Get archived planungen with filters
     */
    static async getArchivedPlanungen(filter = {}) {
        let query = `
            SELECT ap.*
            FROM archivierte_planungen ap
            WHERE 1=1
        `;

        const params = [];
        let paramIndex = 1;

        // Apply filters
        if (filter.planungphase_id) {
            query += ` AND ap.planungphase_id = $${paramIndex++}`;
            params.push(filter.planungphase_id);
        }

        if (filter.professor_id) {
            query += ` AND ap.professor_id = $${paramIndex++}`;
            params.push(filter.professor_id);
        }

        if (filter.semester_id) {
            query += ` AND ap.semester_id = $${paramIndex++}`;
            params.push(filter.semester_id);
        }

        if (filter.status) {
            query += ` AND ap.status_bei_archivierung = $${paramIndex++}`;
            params.push(filter.status);
        }

        if (filter.von_datum) {
            query += ` AND ap.archiviert_am >= $${paramIndex++}`;
            params.push(filter.von_datum);
        }

        if (filter.bis_datum) {
            query += ` AND ap.archiviert_am <= $${paramIndex++}`;
            params.push(filter.bis_datum);
        }

        if (filter.nur_eigene) {
            query += ` AND ap.professor_id = $${paramIndex++}`;
            params.push(filter.professor_id);
        }

        // Add ordering and pagination
        query += ` ORDER BY ap.archiviert_am DESC`;

        const limit = filter.limit || 50;
        const offset = filter.offset || 0;

        query += ` LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
        params.push(limit, offset);

        const result = await db.query(query, params);

        // Get total count
        let countQuery = `
            SELECT COUNT(*) as total
            FROM archivierte_planungen ap
            WHERE 1=1
        `;

        // Apply same filters for count (without pagination)
        const countParams = params.slice(0, -2); // Remove limit and offset
        if (filter.planungphase_id) {
            countQuery += ` AND ap.planungphase_id = $1`;
        }
        // ... add other filter conditions ...

        const countResult = await db.query(countQuery, countParams);
        const total = parseInt(countResult.rows[0]?.total || 0);

        return {
            planungen: result.rows,
            total,
            pages: Math.ceil(total / limit)
        };
    }

    /**
     * Get archived planung details
     */
    static async getArchivedPlanungDetail(archivId) {
        const result = await db.query(`
            SELECT ap.*,
                   u.vorname,
                   u.nachname,
                   u.email
            FROM archivierte_planungen ap
            LEFT JOIN users u ON u.id = ap.professor_id
            WHERE ap.id = $1
        `, [archivId]);

        if (!result.rows[0]) {
            throw new Error('Archivierte Planung nicht gefunden');
        }

        return result.rows[0];
    }

    /**
     * Restore archived planung
     */
    static async restoreArchivedPlanung(archivId, restoredBy) {
        const client = await db.getClient();

        try {
            await client.query('BEGIN');

            // Get archived planung
            const archivResult = await client.query(
                'SELECT * FROM archivierte_planungen WHERE id = $1',
                [archivId]
            );

            if (!archivResult.rows[0]) {
                throw new Error('Archivierte Planung nicht gefunden');
            }

            const archived = archivResult.rows[0];
            const planungData = archived.planung_daten;

            // Restore the planung
            const restoreResult = await client.query(`
                INSERT INTO semesterplanung
                (dozent_id, semester_id, status, gesamt_sws, notizen, created_at, updated_at)
                VALUES ($1, $2, 'entwurf', $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                RETURNING id
            `, [
                archived.professor_id,
                archived.semester_id,
                planungData.gesamt_sws || 0,
                planungData.notizen || ''
            ]);

            const newPlanungId = restoreResult.rows[0].id;

            // Restore modules if they exist in the archived data
            if (planungData.geplante_module && Array.isArray(planungData.geplante_module)) {
                for (const modul of planungData.geplante_module) {
                    await client.query(`
                        INSERT INTO geplantes_modul
                        (planung_id, modul_id, multiplikator_vorlesung, multiplikator_seminar,
                         multiplikator_uebung, multiplikator_praktikum, berechnete_sws)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    `, [
                        newPlanungId,
                        modul.modul_id,
                        modul.multiplikator_vorlesung || 1,
                        modul.multiplikator_seminar || 1,
                        modul.multiplikator_uebung || 1,
                        modul.multiplikator_praktikum || 1,
                        modul.berechnete_sws || 0
                    ]);
                }
            }

            // Delete from archive
            await client.query(
                'DELETE FROM archivierte_planungen WHERE id = $1',
                [archivId]
            );

            await client.query('COMMIT');

            return {
                success: true,
                planung_id: newPlanungId
            };

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Export archive to Excel format (returns JSON for now)
     */
    static async exportArchiv(filter = {}) {
        const result = await this.getArchivedPlanungen({
            ...filter,
            limit: 10000 // Get all for export
        });

        // Transform data for Excel export
        const exportData = result.planungen.map(p => ({
            'ID': p.id,
            'Professor': p.professor_name,
            'Semester': p.semester_name,
            'Phase': p.phase_name,
            'Status': p.status_bei_archivierung,
            'Archiviert am': p.archiviert_am,
            'Grund': p.archiviert_grund,
            'Original ID': p.original_planung_id
        }));

        // In production, you would use a library like exceljs to create actual Excel file
        // For now, return JSON
        return exportData;
    }

    /**
     * Archive a planung manually
     */
    static async archivePlanung(planungId, phaseId, archiviertVon, grund = 'manuell') {
        const client = await db.getClient();

        try {
            await client.query('BEGIN');

            // Get planung data
            const planungResult = await client.query(`
                SELECT sp.*,
                       u.vorname,
                       u.nachname,
                       s.bezeichnung as semester_name
                FROM semesterplanung sp
                JOIN users u ON u.id = sp.dozent_id
                JOIN semester s ON s.id = sp.semester_id
                WHERE sp.id = $1
            `, [planungId]);

            if (!planungResult.rows[0]) {
                throw new Error('Planung nicht gefunden');
            }

            const planung = planungResult.rows[0];

            // Get phase name
            const phaseResult = await client.query(
                'SELECT name FROM planungsphasen WHERE id = $1',
                [phaseId]
            );

            const phaseName = phaseResult.rows[0]?.name || 'Unbekannte Phase';

            // Archive the planung
            await client.query(`
                INSERT INTO archivierte_planungen (
                    original_planung_id,
                    planungphase_id,
                    professor_id,
                    professor_name,
                    semester_id,
                    semester_name,
                    phase_name,
                    status_bei_archivierung,
                    archiviert_grund,
                    archiviert_von,
                    planung_daten
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb)
            `, [
                planungId,
                phaseId,
                planung.dozent_id,
                `${planung.vorname} ${planung.nachname}`,
                planung.semester_id,
                planung.semester_name,
                phaseName,
                planung.status,
                grund,
                archiviertVon,
                JSON.stringify(planung)
            ]);

            // Delete original if not draft
            if (planung.status !== 'entwurf') {
                await client.query(
                    'DELETE FROM semesterplanung WHERE id = $1',
                    [planungId]
                );
            }

            await client.query('COMMIT');

            return { success: true };

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Get archive statistics
     */
    static async getArchiveStatistics() {
        const result = await db.query(`
            SELECT
                COUNT(*) as total_archived,
                COUNT(DISTINCT professor_id) as unique_professors,
                COUNT(DISTINCT planungphase_id) as unique_phases,
                COUNT(DISTINCT semester_id) as unique_semesters,
                COUNT(CASE WHEN status_bei_archivierung = 'freigegeben' THEN 1 END) as approved_count,
                COUNT(CASE WHEN status_bei_archivierung = 'abgelehnt' THEN 1 END) as rejected_count,
                COUNT(CASE WHEN status_bei_archivierung = 'eingereicht' THEN 1 END) as submitted_count,
                COUNT(CASE WHEN status_bei_archivierung = 'entwurf' THEN 1 END) as draft_count,
                COUNT(CASE WHEN archiviert_grund = 'phase_geschlossen' THEN 1 END) as phase_closed_count,
                COUNT(CASE WHEN archiviert_grund = 'manuell' THEN 1 END) as manual_count,
                MIN(archiviert_am) as oldest_archive,
                MAX(archiviert_am) as newest_archive
            FROM archivierte_planungen
        `);

        return result.rows[0];
    }

    /**
     * Clean up old archives (maintenance task)
     */
    static async cleanupOldArchives(olderThanDays = 365) {
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

        const result = await db.query(`
            DELETE FROM archivierte_planungen
            WHERE archiviert_am < $1
            AND archiviert_grund != 'manuell'
            RETURNING id
        `, [cutoffDate]);

        return {
            deleted: result.rowCount,
            message: `${result.rowCount} alte Archiveinträge gelöscht`
        };
    }
}

module.exports = ArchivModel;