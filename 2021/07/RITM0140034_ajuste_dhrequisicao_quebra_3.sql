BEGIN

UPDATE tbqbrsig_solicita_quebra
   SET dhrequisicao = dhrequisicao - 1
 WHERE nrcontrole = 'CCS20210702888800003';
 
 COMMIT;
 
 END;