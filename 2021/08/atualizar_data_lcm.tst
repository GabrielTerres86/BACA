PL/SQL Developer Test script 3.0
19
-- Created on 25/08/2021 by T0032717 
DECLARE
  --Registro do tipo calendario
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  -- Verifica se a data esta cadastrada
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => 10);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;
  
  UPDATE craplcm l SET l.dtmvtolt = rw_crapdat.dtmvtolt WHERE l.cdcooper = 10 AND l.nrdconta = 109207 AND l.cdhistor = 15 AND l.dtmvtolt = '16/08/2021';
  UPDATE craplcm l SET l.dtmvtolt = rw_crapdat.dtmvtolt WHERE l.cdcooper = 12 AND l.nrdconta = 94617  AND l.cdhistor = 15 AND l.dtmvtolt = '13/08/2021';
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao atualizar lancamentos - ' || SQLERRM);
END;
0
0
