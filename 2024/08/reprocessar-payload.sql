BEGIN
  UPDATE credito.tbcred_integracao_contrato c SET c.cdsituacao = 0 WHERE c.idintegracao_contrato = '1FB8B12E4914079AE0630ACC82063375';        
  UPDATE credito.tbcred_integracao_pagamento i SET i.cdsituacao = 0  WHERE i.idintegracao_pagamento = '1FB8B7BA0BA20822E0630ACC8206B7ED';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
