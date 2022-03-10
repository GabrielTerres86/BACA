DECLARE
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  vr_exc_erro EXCEPTION;
  vr_dscritic VARCHAR2(4000);  
  vr_cdcooper   tbcc_grupo_economico_integ.cdcooper%TYPE;  

BEGIN
 
  vr_cdcooper := 1; 

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  BEGIN
    update tbcc_grupo_economico_integ
       set dtexclusao        = to_date(rw_crapdat.dtmvtolt, 'dd/mm/rrrr'),
           cdoperad_exclusao = 1
     where cdcooper = vr_cdcooper
       and nrdconta in (13933094, 9750487, 2388669);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao desassociar contas do GE. Erro: ' ||
                     SubStr(SQLERRM, 1, 255);
      RAISE vr_exc_erro;
  END;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20111, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20111, SQLERRM);
  
END;
