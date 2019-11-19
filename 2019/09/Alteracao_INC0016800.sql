/*
  INC0016800 - Folha de cheque emitida para o cooperado manteve dados incorretos.
  Realiza correção dos campos incorretos: cdbandep, cdagedep, cdtpdchq e nrctadep.
*/

UPDATE crapfdc
   SET cdbandep = 85, cdagedep = 101, cdtpdchq = 0, nrctadep = 8040125
 WHERE progress_recid = 51543642;

COMMIT;
 
