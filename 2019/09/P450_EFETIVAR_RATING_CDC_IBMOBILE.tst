PL/SQL Developer Test script 3.0
35
declare 
  cursor cr_rating_efetivar is
    SELECT e.cdcooper, e.nrdconta, e.nrctremp, o.tpctrato, e.dtmvtolt, e.cdopeefe, d.dtmvtolt as dtcooper
      FROM crapepr e, tbrisco_operacoes o, crapdat d
     WHERE e.cdcooper = o.cdcooper
       AND e.nrdconta = o.nrdconta
       AND e.nrctremp = o.nrctremp
       AND d.cdcooper = o.cdcooper
       AND e.inliquid = 0
       AND o.tpctrato = 90
       AND o.insituacao_rating = 2
       AND e.cdopeefe IN ('996', 'AUTOCDC');

  rw_rating_efetivar cr_rating_efetivar%ROWTYPE;
  vr_cdcritic        pls_integer;
  vr_dscritic        varchar2(4000);

BEGIN
  
  for rw_rating_efetivar IN cr_rating_efetivar LOOP

    rati0003.pc_grava_rating_operacao(pr_cdcooper => rw_rating_efetivar.cdcooper
                                     ,pr_nrdconta => rw_rating_efetivar.nrdconta
                                     ,pr_nrctrato => rw_rating_efetivar.nrctremp
                                     ,pr_tpctrato => rw_rating_efetivar.tpctrato
                                     ,pr_strating => 4
                                     ,pr_dtrating => to_date(rw_rating_efetivar.dtmvtolt, 'DD/MM/YYYY')
                                     ,pr_justificativa => 'Efetivação de contratos via IB/CDC sem endividamento'
                                     ,pr_tpoperacao_rating => 2
                                     ,pr_cdoperad => rw_rating_efetivar.cdopeefe
                                     ,pr_dtmvtolt => to_date(rw_rating_efetivar.dtcooper, 'DD/MM/YYYY')
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
  end loop;
end;
0
0
