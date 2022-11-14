BEGIN
  INSERT INTO pagamento.ta_canal_pagamento
    (CDCANAL_PAGAMENTO
    ,DSCANAL_PAGAMENTO)
  VALUES
    (9
    ,'Correspondente Digital');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024458');
    ROLLBACK;  
END;
