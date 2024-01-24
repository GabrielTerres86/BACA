BEGIN

  update cecred.tbepr_consignado_pagamento
     set instatus = 2
   where nrdconta = 614610
     and nrctremp in (210061, 211585)
     and cdcooper = 13
     and instatus = 1 ;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;