BEGIN
  UPDATE cecred.crapaca
     SET nmpackag = NULL
       , nmproced = 'pc_gera_pagamentos_parcelas_prejuizo'
   WHERE nmdeacao = 'GERA_PGTO_EMPR_PREJUIZO'
     AND nrseqrdr = 71;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
