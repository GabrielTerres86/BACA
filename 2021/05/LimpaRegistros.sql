-- Efetua limpeza dos campos dos regustros afetados
UPDATE craplau
   SET craplau.nrctrlif = NULL
 WHERE craplau.nrctrlif IS NOT NULL
   AND craplau.insitlau = 1
   AND craplau.progress_recid >= 50963611;

-- Efetua gravacao
COMMIT;

-- Elimina procedure temporaria utilizada em necessidade emergencial
DROP PROCEDURE cecred.pc_crps705_emerg;

