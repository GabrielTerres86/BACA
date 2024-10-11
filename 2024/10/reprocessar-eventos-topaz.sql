BEGIN
  DECLARE
  
  CURSOR cd_integracao IS 
    SELECT a.idintegracao_pagamento
      FROM credito.tbcred_integracao_pagamento a
     WHERE a.cdcooperativa <> 1
       AND a.cdsituacao in (2,4)
  ORDER BY a.DHREGISTRO ASC FETCH FIRST 1000 ROWS ONLY;
  rw_integracao cd_integracao%ROWTYPE;
  
  BEGIN
    FOR x IN cd_integracao LOOP
      
      UPDATE credito.tbcred_integracao_pagamento b
      SET b.cdsituacao = 0
      WHERE b.idintegracao_pagamento = x.idintegracao_pagamento;  
      
    END LOOP;  
  COMMIT;
  END;
END;
