DECLARE

BEGIN

  UPDATE cecred.tbepr_portabilidade port
     SET port.nrunico_portabilidade = '202212160000248380275'
   WHERE port.cdcooper = 7
     AND port.nrdconta = 15868966
     AND port.nrctremp = 95169;

  UPDATE cecred.tbepr_portabilidade port
     SET port.nrunico_portabilidade = '202212190000248426323'
   WHERE port.cdcooper = 7
     AND port.nrdconta = 15868966
     AND port.nrctremp = 95167;

  UPDATE cecred.tbepr_portabilidade port
     SET port.nrunico_portabilidade = '202212190000248448933'
   WHERE port.cdcooper = 7
     AND port.nrdconta = 15935167
     AND port.nrctremp = 95715;

  UPDATE cecred.tbepr_portabilidade port
     SET port.nrunico_portabilidade = '202212190000248453900'
   WHERE port.cdcooper = 7
     AND port.nrdconta = 15949753
     AND port.nrctremp = 95808;

  UPDATE cecred.tbepr_portabilidade port
     SET port.nrunico_portabilidade = '202212220000248785895'
   WHERE port.cdcooper = 7
     AND port.nrdconta = 15704777
     AND port.nrctremp = 96366;

  UPDATE cecred.tbepr_portabilidade port
     SET port.nrunico_portabilidade = '202212220000248782262'
   WHERE port.cdcooper = 7
     AND port.nrdconta = 15704777
     AND port.nrctremp = 96365;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
