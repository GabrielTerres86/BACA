declare

begin

  update cecred.tbepr_consignado_pagamento cp
     set cp.instatus = 2
   where (cp.cdcooper, cp.nrdconta, cp.nrctremp, cp.nrparepr) IN ((13, 350672, 50375, 28));

  commit;

end;
