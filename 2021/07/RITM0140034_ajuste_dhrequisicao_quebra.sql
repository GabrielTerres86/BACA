BEGIN

UPDATE tbqbrsig_solicita_quebra
   SET dhrequisicao = dhrequisicao - 1
 WHERE nrcontrole = 'CCS20210701120000002';
 
 COMMIT;
 
 END;