BEGIN

UPDATE tbqbrsig_solicita_quebra
   SET dhrequisicao = dhrequisicao - 1
 WHERE nrcontrole in ('CCS20210702590000001', 'CCS20210702999000002');
 
 COMMIT;
 
 END;