--SCRIPT para gerar registro de devolu��o

UPDATE crapneg n
   SET n.cdobserv = 12
WHERE n.progress_recid = 18209622;
                 
COMMIT;
