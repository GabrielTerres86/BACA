begin
   UPDATE tbepr_folha_pagto_saldo f
   SET    f.vldesbloqueado = f.vlbloqueado
   WHERE      (f.cdcooper = 1
         AND    f.nrdconta in (2295717	,8749388)
         AND    f.nrctremp IN (3114395,3120540)
   )
   AND   f.vldesbloqueado = 0;
   --      
   COMMIT;
end;
