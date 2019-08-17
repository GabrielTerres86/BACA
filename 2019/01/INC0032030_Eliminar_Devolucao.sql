-- Eliminar devolução por contra ordem, devido a ser cheque fraudado. RDM0035394 - Wagner - Sustentação.
delete crapdev a WHERE a.progress_recid IN (2213039,2213040);

COMMIT;
