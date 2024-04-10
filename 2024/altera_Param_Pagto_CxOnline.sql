BEGIN

  UPDATE tbcc_monitoramento_parametro p
     SET p.vllimite_pagamento_especie = 2500
   WHERE p.cdcooper = 1;  

  COMMIT;

END;