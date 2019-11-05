declare 
  -- Variaveis tratamento de erros
  vr_cdcritic            crapcri.cdcritic%TYPE;
  vr_dscritic            crapcri.dscritic%TYPE;
  vr_exc_erro            EXCEPTION;
  vr_dtmvtolt            date;

CURSOR cr_crawepr IS

    select *
      from CECRED.tbcc_prejuizo_lancamento t
      where t.cdcooper in (2,11,16)
      and t.nrdconta   in( 610283,330051,233900 )
      and t.idlancto_prejuizo in (21603,21318 ,21536);

rw_crawepr cr_crawepr%ROWTYPE;

begin
  -- liberação 17/09/2019
  vr_dtmvtolt    := trunc(sysdate);

  for rw_crawepr in  cr_crawepr loop

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

    --dbms_output.put_line('rw_crawepr.nrdconta - '||rw_crawepr.nrdconta||' - '||rw_crawepr.vllanmto);

   end loop;
    ---
  commit;
EXCEPTION
  WHEN OTHERS THEN
    vr_dscritic := 'Erro ao atualizar prej0003 = '||SQLERRM;
    RAISE_APPLICATION_ERROR(-20510,vr_dscritic);
end;
