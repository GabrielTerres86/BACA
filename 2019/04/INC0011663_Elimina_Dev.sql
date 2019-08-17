-- Eliminação de devolução inválida. INC0011663. Wagner - Sustentação.
DELETE crapdev a
 where a.cdcooper = 1
   and a.nrdconta = 8457972
   and a.progress_recid IN (2341954,2341955);
   
COMMIT;
   
