begin
  update cecred.tbepr_consignado_pagamento
     set instatus = 2 
   WHERE cdcooper = 9
     AND nrdconta = 532177
     AND nrctremp = 21200016
     and nrparepr = 12
     and idsequencia = 1463038;
     
commit;
 
exception 
  when others then
    raise_application_error(-2500, SQLERRM);
    rollback;

end;