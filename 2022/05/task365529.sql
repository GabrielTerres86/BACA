begin
update cecred.tbepr_consignado_pagamento
set instatus = 2
where cdcooper = 13 
and nrdconta = 187194
and nrctremp = 56891
and nrparepr = 24
and idsequencia = 1457623;
commit;
end;
