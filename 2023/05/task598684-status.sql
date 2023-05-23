BEGIN
  UPDATE cecred.tbepr_consignado_pagamento c
  SET c.instatus = 4,
      c.idintegracao = 1,
      c.dtupdreg = to_date(sysdate, 'dd/mm/rrrr')
   WHERE c.cdcooper = 10
     AND c.nrdconta = 110329
     AND c.nrctremp = 44937
     AND c.nrparepr IN (4,5);
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
