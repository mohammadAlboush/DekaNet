import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Button,
} from '@mui/material';
import {
  NavigateNext,
  NavigateBefore,
} from '@mui/icons-material';
import WunschTagEditor, { WunschTag } from '../../../common/WunschTagEditor';
import { StepWunschFreieTageProps } from '../../../../types/StepProps.types';

/**
 * StepWunschFreieTage
 *
 * Wizard-Schritt für Wunsch-freie Tage.
 * Verwendet den wiederverwendbaren WunschTagEditor.
 */
const StepWunschFreieTage: React.FC<StepWunschFreieTageProps> = ({
  data,
  onUpdate,
  onNext,
  onBack,
}) => {
  const [wunschFreieTage, setWunschFreieTage] = useState<WunschTag[]>(
    data.wunschFreieTage || []
  );

  // Synchronisiere mit parent data
  useEffect(() => {
    if (data.wunschFreieTage) {
      setWunschFreieTage(data.wunschFreieTage);
    }
  }, [data.wunschFreieTage]);

  const handleChange = (tags: WunschTag[]) => {
    setWunschFreieTage(tags);
    onUpdate({ wunschFreieTage: tags });
  };

  return (
    <Box>
      <Typography variant="h6" gutterBottom>
        Wunsch-freie Tage für die Stundenplanung
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Geben Sie an, an welchen Tagen Sie bevorzugt keine Lehrveranstaltungen haben möchten.
      </Typography>

      {/* Wiederverwendbarer WunschTagEditor */}
      <WunschTagEditor
        wunschFreieTage={wunschFreieTage}
        onChange={handleChange}
      />

      {/* Navigation */}
      <Box sx={{ mt: 4, display: 'flex', justifyContent: 'space-between' }}>
        <Button startIcon={<NavigateBefore />} onClick={onBack}>
          Zurück
        </Button>
        <Button
          variant="contained"
          endIcon={<NavigateNext />}
          onClick={onNext}
        >
          Weiter zur Zusammenfassung
        </Button>
      </Box>
    </Box>
  );
};

export default StepWunschFreieTage;
