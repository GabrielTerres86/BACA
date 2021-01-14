begin
   UPDATE tbepr_folha_pagto_saldo f
   SET    f.vldesbloqueado = f.vlbloqueado
  WHERE ( f.cdcooper = 1
         AND    f.nrdconta in (2048680,10524703,8749388,11367725,2466066,10538046,4023471
                              ,2788080,6589111,11763191,10561110,10560955,9438424,8965978
                              ,9957570,868094)
         AND    f.nrctremp IN (3019765,3017436,3018428,3018307,3018627,3015418,3022024
                              ,3018376,3021926,3020382,3020095,3019990,3025987,3023591
                              ,3016064,3022447)
             )
  OR ( f.cdcooper = 10
       AND    f.nrdconta in (138924,164089)
       AND    f.nrctremp IN (16333,16325)
           ) 
  OR ( f.cdcooper = 14
       AND    f.nrdconta in (12521,167304)
       AND    f.nrctremp IN (17587,17664)
           )                           
                        
   AND f.vldesbloqueado = 0;
   --      
   COMMIT;
end;
