BEGIN
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('GERA_PGTO_EMPR_PREJUIZO'
    ,'empr0001'
    ,'pc_gera_pagamentos_parcelas_prejuizo'
    ,'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_totatual,pr_totpagto,pr_vldabono,pr_idseqttl'
    ,71);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
