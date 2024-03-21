DECLARE

  CURSOR cr_crapass IS
    SELECT t.cdcooper
         , t.nrdconta
      FROM crapass t
     WHERE t.progress_recid = 2077318;

  vr_cdcooper  NUMBER;
  vr_nrdconta  NUMBER;

BEGIN
  
  OPEN  cr_crapass;
  FETCH cr_crapass INTO vr_cdcooper, vr_nrdconta;
  CLOSE cr_crapass;
  
  IF vr_cdcooper IS NULL OR vr_nrdconta IS NULL THEN
    raise_application_error(-20001,'Cooperativa e conta não encontrada pelo recid: '||vr_cdcooper||'-'||vr_nrdconta);
  END IF;
  
  BEGIN
    UPDATE crapsld t 
       SET t.vlsddisp = t.vlsddisp + t.vlsdblpr
         , t.vlsdblpr = 0
     WHERE t.cdcooper = vr_cdcooper
       AND t.nrdconta = vr_nrdconta;
  EXCEPTION 
    WHEN OTHERS THEN
      raise_application_error(-20002,'Erro ao atualizar registro de saldo CRAPSLD: '||SQLERRM);
  END;
    
  COMMIT;
END;
