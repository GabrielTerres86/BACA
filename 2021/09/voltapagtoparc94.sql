declare 

  vr_exc_saida     EXCEPTION;
 
  vr_cdcooper      crapcop.cdcooper%TYPE := 3;
  vr_nrdconta      crapass.nrdconta%TYPE := 94;
  vr_nrctremp      craplem.nrctremp%TYPE := 211409;

BEGIN

  
   -- Atualiza os dados da Parcela
  BEGIN
    UPDATE crappep c
       SET vlparepr = 46624.43
          ,vlsdvpar = 46624.43
          ,vlsdvatu = 46624.43
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 5;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 44500.74
          ,vlsdvpar = 44500.74
          ,vlsdvatu = 44500.74
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 6;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 40254.53
          ,vlsdvpar = 40254.53
          ,vlsdvatu = 40254.53
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 7;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 46624.54
          ,vlsdvpar = 46624.54
          ,vlsdvatu = 46624.54
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 8;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 46624.43
          ,vlsdvpar = 46624.43
          ,vlsdvatu = 46624.43
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 9;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 46624.54
          ,vlsdvpar = 46624.54
          ,vlsdvatu = 46624.54
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 10;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 38132.01
          ,vlsdvpar = 38132.01
          ,vlsdvatu = 38132.01
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 11;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
   BEGIN
    UPDATE crappep c
       SET vlparepr = 46624.43
          ,vlsdvpar = 46624.43
          ,vlsdvatu = 46624.43
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 12;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 484851.05 
          ,vlsdvpar = 484851.05
          ,vlsdvatu = 484851.05
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr >= 13 
       and c.inliquid = 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
