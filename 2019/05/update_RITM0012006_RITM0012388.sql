
-- Update para delimitar tamanho maximo de 10 digitos da referencia para o 
-- convênio BR TELECOM CRT - FEBRABAN => RITM0012388/RITM0012006
UPDATE crapscn n
   SET n.qtdigito = 10, n.tppreenc = 1
 WHERE upper(n.cdempres) = '18';

UPDATE crapscn n
   SET n.qtdigito = 25, n.tppreenc = 1
 WHERE upper(n.cdempres) = '252';
 
commit;
