BEGIN

UPDATE tbqbrsig_solicita_quebra
   SET dhrequisicao = dhrequisicao - 1
 WHERE nrcontrole in ('CCS20210707100000000', 'CCS20210707200000000');
 
COMMIT;

END;