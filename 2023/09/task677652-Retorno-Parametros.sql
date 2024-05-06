DECLARE

BEGIN

  UPDATE cecred.crapaca
     SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_dsobservacao'
   WHERE NMDEACAO = 'EFETUA_BLOQ_DEBITO_OP_CREDITO';

  UPDATE cecred.crapaca
     SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp'
   WHERE NMDEACAO = 'CONSULTA_BLOQ_DEBITO_OP_CREDITO';

  UPDATE cecred.crapaca
     SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_dsobservacao'
   WHERE NMDEACAO = 'ALTERA_BLOQ_DEBITO_OP_CREDITO';

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
