DECLARE 
  vr_cdcooper CECRED.crapsnh.cdcooper%TYPE := 9;
  vr_nrdconta CECRED.crapsnh.nrdconta%TYPE := 99094444;
BEGIN 
  UPDATE CECRED.crapsnh snh
     SET snh.vllimtrf = 900000.01
        ,snh.dtlimtrf = TRUNC(SYSDATE)
        ,snh.vllimpgo = 900000.02
        ,snh.dtlimpgo = TRUNC(SYSDATE)
        ,snh.vllimted = 900000.03
        ,snh.dtlimted = TRUNC(SYSDATE)
        ,snh.vllimflp = 900000.04
        ,snh.dtlimflp = TRUNC(SYSDATE)
        ,snh.vllimvrb = 900000.05
        ,snh.dtlimvrb = TRUNC(SYSDATE)
   WHERE snh.tpdsenha = 1
     AND snh.cdcooper = vr_cdcooper
     AND snh.nrdconta = vr_nrdconta;

  UPDATE CECRED.tbcc_limite_preposto tlp
     SET tlp.vllimite_transf   = 2000.01
        ,tlp.dtlimite_transf   = TRUNC(SYSDATE)
        ,tlp.vllimite_ted      = 1000.01
        ,tlp.dtlimite_ted      = TRUNC(SYSDATE)
        ,tlp.vllimite_folha    = 3000.01
        ,tlp.dtlimite_folha    = TRUNC(SYSDATE)
        ,tlp.vllimite_pagto    = 2000.01
        ,tlp.dtlimite_pagto    = TRUNC(SYSDATE)
        ,tlp.vllimite_vrboleto = 4000.01
        ,tlp.dtlimite_vrboleto = TRUNC(SYSDATE)
   WHERE tlp.cdcooper = vr_cdcooper
     AND tlp.nrdconta = vr_nrdconta
     AND tlp.nrcpf = 73609080;
   
  UPDATE CECRED.tbcc_limite_preposto tlp
     SET tlp.vllimite_transf   = 7000.02
        ,tlp.dtlimite_transf   = TRUNC(SYSDATE)
        ,tlp.vllimite_ted      = 1000.02
        ,tlp.dtlimite_ted      = TRUNC(SYSDATE)
        ,tlp.vllimite_folha    = 3000.02
        ,tlp.dtlimite_folha    = TRUNC(SYSDATE)
        ,tlp.vllimite_pagto    = 2000.02
        ,tlp.dtlimite_pagto    = TRUNC(SYSDATE)
        ,tlp.vllimite_vrboleto = 4000.02
        ,tlp.dtlimite_vrboleto = TRUNC(SYSDATE)
   WHERE tlp.cdcooper = vr_cdcooper
     AND tlp.nrdconta = vr_nrdconta
     AND tlp.nrcpf = 29176310078;
     
  UPDATE CECRED.crapopi opi
    SET opi.vllimtrf = 2000.03
       ,opi.vllimted = 1000.03
       ,opi.vllimflp = 3000.03
       ,opi.vllimvrb = 4000.03
  WHERE opi.cdcooper = vr_cdcooper
    AND opi.nrdconta = vr_nrdconta;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN 
   ROLLBACK;  
END;
