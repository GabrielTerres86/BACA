declare 
  -- Variaveis tratamento de erros
  vr_cdcritic            crapcri.cdcritic%TYPE;
  vr_dscritic            crapcri.dscritic%TYPE;
  vr_exc_erro            EXCEPTION;
  vr_dtmvtolt            date;

CURSOR cr_crawepr(pr_cdcooper IN tbcc_prejuizo_lancamento.cdcooper%TYPE
                 ,pr_nrdconta IN tbcc_prejuizo_lancamento.nrdconta%TYPE
                 ,pr_idlancto_prejuizo IN tbcc_prejuizo_lancamento.idlancto_prejuizo%TYPE) IS
    select *
      from CECRED.tbcc_prejuizo_lancamento t
      where t.cdcooper = pr_cdcooper
      and t.nrdconta   = pr_nrdconta
      and t.idlancto_prejuizo = pr_idlancto_prejuizo;

rw_crawepr cr_crawepr%ROWTYPE;

begin
  -- liberação 10/09/2019
  vr_dtmvtolt    := trunc(sysdate);

  OPEN  cr_crawepr(pr_cdcooper => 1
                  ,pr_nrdconta => 9553100
                  ,pr_idlancto_prejuizo => 20909
                  );
   FETCH cr_crawepr INTO rw_crawepr;
   -- 
   cecred.prej0003.pc_gera_cred_cta_prj(pr_cdcooper => rw_crawepr.cdcooper,
                                       pr_nrdconta => rw_crawepr.nrdconta,
                                       pr_cdoperad => 1,
                                       pr_vlrlanc  => rw_crawepr.vllanmto, 
                                       pr_dtmvtolt => vr_dtmvtolt, 
                                       pr_nrdocmto => rw_crawepr.nrdocmto, 
                                       pr_dsoperac => null, 
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('prej0003 - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;

  CLOSE cr_crawepr;
    ---
  commit;
EXCEPTION
  WHEN OTHERS THEN
    vr_dscritic := 'Erro ao atualizar prej0003 = '||SQLERRM;
    RAISE_APPLICATION_ERROR(-20510,vr_dscritic);
end;
