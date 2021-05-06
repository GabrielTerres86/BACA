BEGIN
  update tbepr_consignado_pagamento t 
     set instatus = 2
   where t.dtincreg >= trunc(to_date('16/04/2021', 'DD/MM/YYYY'))
     and instatus = 1;

  COMMIT;  

END;  
