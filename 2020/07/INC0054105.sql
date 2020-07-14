declare 
  vr_exc_saida     EXCEPTION;
  
  vr_cdcooper      crapcop.cdcooper%TYPE := 12;
  vr_nrdconta      crapass.nrdconta%TYPE := 123196;
  vr_nrctremp      craplem.nrctremp%TYPE := 13110;
  vr_vlsdeved      crapepr.vlsdeved%TYPE := 72752.16;
 
BEGIN
  
  -- Atualiza os dados do Emprestimo
  BEGIN
    UPDATE crapepr
       SET crapepr.vlsdeved = vr_vlsdeved
     WHERE crapepr.cdcooper = vr_cdcooper
       AND crapepr.nrdconta = vr_nrdconta
       AND crapepr.nrctremp = vr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;

  commit;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
end;
