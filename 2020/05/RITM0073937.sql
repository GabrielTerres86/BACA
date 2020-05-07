--UPDATE FOR RITM0073937 BY t0031898

  UPDATE tbepr_folha_pagto_saldo f
       SET f.vldesbloqueado = f.vlbloqueado
     WHERE (f.cdcooper = 1
             AND f.nrdconta in (868094,
                                3937933,
                                9616063)
           )
       OR ( f.cdcooper = 1
            AND f.nrdconta  = 10879447
            AND f.nrctremp = 2498926
          )
       OR ( f.cdcooper = 9
             AND f.nrdconta = 200557
          )
       OR ( f.cdcooper = 10
             AND f.nrdconta in (1031, 122947)
          )
       OR ( f.cdcooper = 16
             AND f.nrdconta in (108308, 6554911, 134996)
          );
            
  COMMIT;            
