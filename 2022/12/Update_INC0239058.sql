BEGIN
  BEGIN
      UPDATE cecred.crappro pro
         SET pro.dsprotoc = 'CC77.1D4C.ECCD.B190.CA6A.C9A7.13CF.CEE9'
       WHERE pro.cdcooper = 1
         AND UPPER(pro.dsprotoc) = 'CC77.1D4C.ECCD.B190.CA6A.C9A7.13CF.CEE9 **ESTORNADO(25/08/22-20:00:01)';
       
  EXCEPTION 
       WHEN OTHERS THEN
          raise_application_error(-20000,'Ocorreu um erro ao atualizar o registro da tabela CRAPPRO. Código do erro:'||SQLERRM);   
  END;

  BEGIN
      UPDATE cecred.tbconv_registro_remessa_pagfor reg
         SET reg.dhretorno_processamento = to_date('25-08-2022 13:10:01', 'dd-mm-yyyy hh24:mi:ss'), reg.nmarquivo_retorno = '1QTH250813048441.RET'
       WHERE reg.idsicredi = 6167417;    
      
  EXCEPTION 
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20001,'Ocorreu um erro ao atualizar o registro 6167417. Código do erro:'||SQLERRM);
  END;

  BEGIN
      UPDATE cecred.tbconv_registro_remessa_pagfor reg
         SET reg.cdstatus_processamento = 3, reg.dsprocessamento = 'Aceito para processamento - 341000000009704852508202201042400322923',
             reg.dhretorno_processamento = to_date('25-08-2022 13:10:01', 'dd-mm-yyyy hh24:mi:ss'), reg.nmarquivo_retorno = '1QTH250813048441.RET'
       WHERE reg.idsicredi = 6167418;    
      
  EXCEPTION 
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20001,'Ocorreu um erro ao atualizar o registro 6167418. Código do erro:'||SQLERRM);
  END;

  BEGIN
      UPDATE cecred.tbconv_registro_remessa_pagfor reg
         SET reg.dhretorno_processamento = to_date('25-08-2022 13:10:01', 'dd-mm-yyyy hh24:mi:ss'), reg.nmarquivo_retorno = '1QTH250813048441.RET'
       WHERE reg.idsicredi = 6167419;    
      
  EXCEPTION 
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20001,'Ocorreu um erro ao atualizar o registro 6167419. Código do erro:'||SQLERRM);
  END;

  COMMIT;
  
END;