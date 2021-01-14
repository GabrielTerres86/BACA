
  UPDATE tbepr_folha_pagto_saldo f
         SET f.vldesbloqueado = f.vlbloqueado
       WHERE ( f.cdcooper = 9
              AND f.nrdconta  IN( 298174)
              AND f.nrctremp IN (27329)
             );
    COMMIT;
