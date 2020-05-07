--UPDATE FOR RITM0073937 BY t0031898

  UPDATE tbepr_folha_pagto_saldo f
         SET f.vldesbloqueado = f.vlbloqueado
       WHERE( f.cdcooper = 1
              AND f.nrdconta  = 868094
              AND f.nrctremp = 2494438
            )
         OR ( f.cdcooper = 1
              AND f.nrdconta  = 9616063
              AND f.nrctremp = 2493361
            )
         OR ( f.cdcooper = 1
              AND f.nrdconta  = 3937933
              AND f.nrctremp = 2493208
            )
         OR ( f.cdcooper = 1
              AND f.nrdconta  = 10879447
              AND f.nrctremp = 2498926
            )
         OR ( f.cdcooper = 9
               AND f.nrdconta = 200557
               AND f.nrctremp = 26590
            )
         OR ( f.cdcooper = 10
               AND f.nrdconta = 1031
               AND f.nrctremp = 12159
            )
         OR ( f.cdcooper = 10
               AND f.nrdconta  = 122947
               AND f.nrctremp = 12115
            )
         OR ( f.cdcooper = 16
               AND f.nrdconta  = 108308
               AND f.nrctremp = 160324
            )
         OR ( f.cdcooper = 16
               AND f.nrdconta  = 134996
               AND f.nrctremp = 160515
            )
         OR ( f.cdcooper = 16
               AND f.nrdconta  = 6554911
               AND f.nrctremp = 162433
             )
            ;
            
  COMMIT;            
