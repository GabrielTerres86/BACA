Declare
  vr_instatus cecred.tbepr_consignado_pagamento.instatus%type := 2;
begin
  update cecred.tbepr_consignado_pagamento cp
     set INSTATUS = vr_instatus
   where cp.cdcooper = 13
     and cp.nrdconta = 172855
     and cp.nrctremp = 287889
     and cp.nrparepr = 49;

  COMMIT;
exception
  when others then
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
