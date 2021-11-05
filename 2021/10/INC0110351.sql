DECLARE
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic varchar2(4000);
  vr_cdcooper crapcop.cdcooper%TYPE := 2;
  vr_nrdconta crapass.nrdconta%TYPE := 708763;
  vr_nrctremp crapepr.nrctremp%TYPE := 237863;
  vr_dtmvtolt date := sysdate;
  --
BEGIN
  --
  rati0003.pc_grava_rating_operacao(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => vr_nrdconta
                                    ,pr_nrctrato => vr_nrctremp
                                    ,pr_tpctrato => 90
                                    ,pr_ntrataut => 2
                                    ,pr_strating => 4
                                    ,pr_cdoprrat => '1'
                                    ,pr_dtrating => vr_dtmvtolt
                                    ,pr_cdoperad => '1'
                                    ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_valor => 2191.41
                                    ,pr_justificativa => 'INC0110351 - Acredicoop'
                                    ,pr_tpoperacao_rating => 2 -- (não tem informações em tbrating_historicos)
                                    --Variáveis de crítica
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

  if (vr_cdcritic is null and vr_dscritic is null) then
    update tbrisco_operacoes roper
       set roper.flintegrar_sas = 1 
     where 1=1
       and roper.cdcooper = vr_cdcooper
       and roper.nrdconta = vr_nrdconta
       and roper.nrctremp = vr_nrctremp
       ;
    commit;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line(vr_cdcritic||' - '||vr_dscritic);
    dbms_output.put_line(SQLERRM);
END;
