const db = require('../config/database');

class PlanungsphaseModel {
    /**
     * Get active planning phase
     */
    static async getActivePhase() {
        const query = `
            SELECT * FROM planungsphasen
            WHERE ist_aktiv = true
            LIMIT 1
        `;
        const result = await db.query(query);
        return result.rows[0] || null;
    }

    /**
     * Get all phases for a semester
     */
    static async getAllPhases(semesterId = null) {
        let query = `
            SELECT pp.*,
                   COUNT(DISTINCT ps.professor_id) as unique_professors
            FROM planungsphasen pp
            LEFT JOIN phase_submissions ps ON ps.planungphase_id = pp.id
        `;

        const params = [];
        if (semesterId) {
            query += ' WHERE pp.semester_id = $1';
            params.push(semesterId);
        }

        query += ' GROUP BY pp.id ORDER BY pp.created_at DESC';

        const result = await db.query(query, params);
        return {
            phasen: result.rows,
            total: result.rows.length,
            aktive_phase: result.rows.find(p => p.ist_aktiv) || null
        };
    }

    /**
     * Start a new planning phase
     */
    static async startPhase(data, userId) {
        const client = await db.getClient();

        try {
            await client.query('BEGIN');

            // Close any active phases for this semester
            await client.query(`
                UPDATE planungsphasen
                SET ist_aktiv = false,
                    geschlossen_am = CURRENT_TIMESTAMP,
                    geschlossen_von = $1,
                    geschlossen_grund = 'Neue Phase gestartet'
                WHERE semester_id = $2 AND ist_aktiv = true
            `, [userId, data.semester_id]);

            // Create new phase
            const result = await client.query(`
                INSERT INTO planungsphasen
                (semester_id, name, startdatum, enddatum, ist_aktiv)
                VALUES ($1, $2, $3, $4, true)
                RETURNING *
            `, [
                data.semester_id,
                data.name,
                data.startdatum || new Date(),
                data.enddatum || null
            ]);

            await client.query('COMMIT');
            return result.rows[0];

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Close a planning phase with archiving
     */
    static async closePhase(phaseId, userId, options = {}) {
        const client = await db.getClient();

        try {
            await client.query('BEGIN');

            // Get phase info
            const phaseResult = await client.query(
                'SELECT * FROM planungsphasen WHERE id = $1',
                [phaseId]
            );

            if (!phaseResult.rows[0]) {
                throw new Error('Phase not found');
            }

            const phase = phaseResult.rows[0];

            // Archive submitted/approved/rejected planungen
            const archiveResult = await client.query(`
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
                SELECT
                    sp.id,
                    $1,
                    sp.dozent_id,
                    CONCAT(u.vorname, ' ', u.nachname),
                    sp.semester_id,
                    s.bezeichnung,
                    $2,
                    sp.status,
                    'phase_geschlossen',
                    $3,
                    row_to_json(sp)::jsonb
                FROM semesterplanung sp
                JOIN users u ON u.id = sp.dozent_id
                JOIN semester s ON s.id = sp.semester_id
                WHERE sp.status IN ('eingereicht', 'freigegeben', 'abgelehnt')
                AND sp.semester_id = $4
                RETURNING id
            `, [phaseId, phase.name, userId, phase.semester_id]);

            const archiviertePlanungen = archiveResult.rowCount;

            // Handle drafts
            let geloeschteEntwuerfe = 0;
            if (options.archiviere_entwuerfe) {
                // Archive drafts
                const draftArchiveResult = await client.query(`
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
                    SELECT
                        sp.id,
                        $1,
                        sp.dozent_id,
                        CONCAT(u.vorname, ' ', u.nachname),
                        sp.semester_id,
                        s.bezeichnung,
                        $2,
                        sp.status,
                        'phase_geschlossen',
                        $3,
                        row_to_json(sp)::jsonb
                    FROM semesterplanung sp
                    JOIN users u ON u.id = sp.dozent_id
                    JOIN semester s ON s.id = sp.semester_id
                    WHERE sp.status = 'entwurf'
                    AND sp.semester_id = $4
                    RETURNING id
                `, [phaseId, phase.name, userId, phase.semester_id]);

                geloeschteEntwuerfe = draftArchiveResult.rowCount;
            } else {
                // Delete drafts
                const deleteResult = await client.query(`
                    DELETE FROM semesterplanung
                    WHERE status = 'entwurf'
                    AND semester_id = $1
                    RETURNING id
                `, [phase.semester_id]);

                geloeschteEntwuerfe = deleteResult.rowCount;
            }

            // Close the phase
            const closedPhase = await client.query(`
                UPDATE planungsphasen
                SET ist_aktiv = false,
                    geschlossen_am = CURRENT_TIMESTAMP,
                    geschlossen_von = $1,
                    geschlossen_grund = $2,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = $3
                RETURNING *
            `, [userId, options.grund || 'Manuell geschlossen', phaseId]);

            await client.query('COMMIT');

            return {
                phase: closedPhase.rows[0],
                archivierte_planungen: archiviertePlanungen,
                geloeschte_entwuerfe: geloeschteEntwuerfe
            };

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Update a phase
     */
    static async updatePhase(phaseId, updates) {
        const fields = [];
        const values = [];
        let index = 1;

        if (updates.name !== undefined) {
            fields.push(`name = $${index++}`);
            values.push(updates.name);
        }

        if (updates.enddatum !== undefined) {
            fields.push(`enddatum = $${index++}`);
            values.push(updates.enddatum);
        }

        fields.push(`updated_at = CURRENT_TIMESTAMP`);
        values.push(phaseId);

        const query = `
            UPDATE planungsphasen
            SET ${fields.join(', ')}
            WHERE id = $${index}
            RETURNING *
        `;

        const result = await db.query(query, values);
        return result.rows[0];
    }

    /**
     * Check submission status for a professor
     */
    static async checkSubmissionStatus(professorId) {
        const activePhase = await this.getActivePhase();

        if (!activePhase) {
            return {
                kann_einreichen: false,
                grund: 'keine_aktive_phase'
            };
        }

        // Check if deadline passed
        if (activePhase.enddatum && new Date(activePhase.enddatum) < new Date()) {
            return {
                kann_einreichen: false,
                grund: 'phase_abgelaufen',
                aktive_phase: activePhase
            };
        }

        // Check if already has approved submission
        const approvedSubmission = await db.query(`
            SELECT * FROM phase_submissions
            WHERE planungphase_id = $1
            AND professor_id = $2
            AND status = 'freigegeben'
            LIMIT 1
        `, [activePhase.id, professorId]);

        if (approvedSubmission.rows[0]) {
            return {
                kann_einreichen: false,
                grund: 'bereits_genehmigt',
                aktive_phase: activePhase,
                letzte_einreichung: approvedSubmission.rows[0]
            };
        }

        // Calculate remaining time in minutes
        let verbleibende_zeit = null;
        if (activePhase.enddatum) {
            const diffMs = new Date(activePhase.enddatum) - new Date();
            verbleibende_zeit = Math.floor(diffMs / 60000);
        }

        return {
            kann_einreichen: true,
            aktive_phase: activePhase,
            verbleibende_zeit
        };
    }

    /**
     * Record a submission
     */
    static async recordSubmission(planungId, professorId) {
        const activePhase = await this.getActivePhase();

        if (!activePhase) {
            throw new Error('Keine aktive Planungsphase');
        }

        const result = await db.query(`
            INSERT INTO phase_submissions
            (planungphase_id, professor_id, planung_id, status)
            VALUES ($1, $2, $3, 'eingereicht')
            ON CONFLICT (planungphase_id, professor_id, status)
            DO UPDATE SET
                planung_id = EXCLUDED.planung_id,
                eingereicht_am = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP
            RETURNING *
        `, [activePhase.id, professorId, planungId]);

        // Update phase statistics
        await this.updatePhaseStatistics(activePhase.id);

        return result.rows[0];
    }

    /**
     * Get phase submissions
     */
    static async getPhaseSubmissions(phaseId) {
        const result = await db.query(`
            SELECT ps.*,
                   u.vorname,
                   u.nachname,
                   sp.gesamt_sws,
                   sp.notizen
            FROM phase_submissions ps
            JOIN users u ON u.id = ps.professor_id
            JOIN semesterplanung sp ON sp.id = ps.planung_id
            WHERE ps.planungphase_id = $1
            ORDER BY ps.eingereicht_am DESC
        `, [phaseId]);

        return result.rows;
    }

    /**
     * Update phase statistics
     */
    static async updatePhaseStatistics(phaseId) {
        await db.query(`
            UPDATE planungsphasen
            SET anzahl_einreichungen = (
                    SELECT COUNT(*) FROM phase_submissions
                    WHERE planungphase_id = $1
                ),
                anzahl_genehmigt = (
                    SELECT COUNT(*) FROM phase_submissions
                    WHERE planungphase_id = $1 AND status = 'freigegeben'
                ),
                anzahl_abgelehnt = (
                    SELECT COUNT(*) FROM phase_submissions
                    WHERE planungphase_id = $1 AND status = 'abgelehnt'
                ),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = $1
        `, [phaseId]);

        // Refresh materialized view if it exists
        try {
            await db.query('REFRESH MATERIALIZED VIEW CONCURRENTLY phase_statistiken');
        } catch (e) {
            // View might not exist yet
        }
    }

    /**
     * Get phase statistics
     */
    static async getPhaseStatistics(phaseId) {
        const result = await db.query(`
            SELECT
                pp.*,
                COALESCE(ps.einreichungsquote, 0) as einreichungsquote,
                COALESCE(ps.genehmigungsquote, 0) as genehmigungsquote,
                COALESCE(ps.durchschnittliche_bearbeitungszeit_stunden, 0) as durchschnittliche_bearbeitungszeit,
                COALESCE(ps.professoren_gesamt, 0) as professoren_gesamt,
                COALESCE(ps.professoren_eingereicht, 0) as professoren_eingereicht
            FROM planungsphasen pp
            LEFT JOIN phase_statistiken ps ON ps.phase_id = pp.id
            WHERE pp.id = $1
        `, [phaseId]);

        const phase = result.rows[0];

        if (!phase) {
            throw new Error('Phase not found');
        }

        // Get top modules
        const topModulesResult = await db.query(`
            SELECT modul_name, anzahl
            FROM top_module_pro_phase
            WHERE planungphase_id = $1 AND rang <= 5
            ORDER BY rang
        `, [phaseId]);

        return {
            phase_id: phase.id,
            phase_name: phase.name,
            startdatum: phase.startdatum,
            enddatum: phase.enddatum,
            dauer_tage: Math.floor((new Date(phase.geschlossen_am || new Date()) - new Date(phase.startdatum)) / (1000 * 60 * 60 * 24)),
            professoren_gesamt: phase.professoren_gesamt,
            professoren_eingereicht: phase.professoren_eingereicht,
            einreichungsquote: phase.einreichungsquote,
            genehmigungsquote: phase.genehmigungsquote,
            durchschnittliche_bearbeitungszeit: phase.durchschnittliche_bearbeitungszeit,
            top_module: topModulesResult.rows
        };
    }

    /**
     * Get phase history
     */
    static async getPhaseHistory(professorId = null) {
        let query = `
            SELECT
                pp.*,
                ps_stats.einreichungsquote,
                ps_stats.genehmigungsquote,
                ps_stats.durchschnittliche_bearbeitungszeit_stunden,
                ps_stats.professoren_gesamt,
                ps_stats.professoren_eingereicht
            FROM planungsphasen pp
            LEFT JOIN phase_statistiken ps_stats ON ps_stats.phase_id = pp.id
        `;

        const params = [];
        if (professorId) {
            query += `
                LEFT JOIN phase_submissions ps ON ps.planungphase_id = pp.id AND ps.professor_id = $1
            `;
            params.push(professorId);
        }

        query += ' ORDER BY pp.created_at DESC';

        const result = await db.query(query, params);

        const history = [];
        for (const phase of result.rows) {
            // Calculate duration in days
            let dauer_tage = 0;
            if (phase.startdatum) {
                const startDate = new Date(phase.startdatum);
                const endDate = phase.geschlossen_am ? new Date(phase.geschlossen_am) : new Date();
                dauer_tage = Math.floor((endDate - startDate) / (1000 * 60 * 60 * 24));
            }

            const entry = {
                phase,
                statistik: {
                    phase_id: phase.id,
                    phase_name: phase.name,
                    startdatum: phase.startdatum,
                    dauer_tage: dauer_tage,
                    professoren_gesamt: phase.professoren_gesamt || 0,
                    professoren_eingereicht: phase.professoren_eingereicht || 0,
                    einreichungsquote: phase.einreichungsquote || 0,
                    genehmigungsquote: phase.genehmigungsquote || 0,
                    durchschnittliche_bearbeitungszeit: phase.durchschnittliche_bearbeitungszeit_stunden || 0,
                    top_module: []
                }
            };

            // Get professor's submission for this phase if professorId provided
            if (professorId) {
                const submissionResult = await db.query(`
                    SELECT * FROM phase_submissions
                    WHERE planungphase_id = $1 AND professor_id = $2
                    LIMIT 1
                `, [phase.id, professorId]);

                if (submissionResult.rows[0]) {
                    entry.eigene_einreichung = submissionResult.rows[0];
                }
            }

            // Get top modules
            const topModulesResult = await db.query(`
                SELECT modul_name, anzahl
                FROM top_module_pro_phase
                WHERE planungphase_id = $1 AND rang <= 3
                ORDER BY rang
            `, [phase.id]);

            entry.statistik.top_module = topModulesResult.rows;

            history.push(entry);
        }

        return history;
    }

    /**
     * Send reminders to professors
     */
    static async sendReminders(phaseId, professorIds = []) {
        // Get professors who haven't submitted
        let query = `
            SELECT u.id, u.email, u.vorname, u.nachname
            FROM users u
            WHERE u.rolle IN ('Professor', 'Lehrbeauftragter')
            AND NOT EXISTS (
                SELECT 1 FROM phase_submissions ps
                WHERE ps.planungphase_id = $1
                AND ps.professor_id = u.id
            )
        `;

        const params = [phaseId];

        if (professorIds && professorIds.length > 0) {
            query += ' AND u.id = ANY($2)';
            params.push(professorIds);
        }

        const result = await db.query(query, params);

        let gesendet = 0;
        let fehler = 0;

        for (const professor of result.rows) {
            try {
                // Here you would normally send an email
                // For now, just log to reminder table
                await db.query(`
                    INSERT INTO phase_reminders_log
                    (planungphase_id, professor_id, email_status)
                    VALUES ($1, $2, 'success')
                `, [phaseId, professor.id]);

                gesendet++;
            } catch (e) {
                await db.query(`
                    INSERT INTO phase_reminders_log
                    (planungphase_id, professor_id, email_status, fehler_details)
                    VALUES ($1, $2, 'failed', $3)
                `, [phaseId, professor.id, e.message]);

                fehler++;
            }
        }

        return { gesendet, fehler };
    }
}

module.exports = PlanungsphaseModel;