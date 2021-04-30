PL/SQL Developer Test script 3.0
17
declare
  -- Non-scalar parameters require additional processing 
  pr_tab_erro CECRED.GENE0001.TYP_TAB_ERRO;
begin
  -- o juro60 é calculado na empr9999.pc_calcula_juros_60d_pp - breakpoint
  -- em torno da linha 2983 faz os calculos e lançamentos do vlsdprej - vr_vljura60
  cecred.PREJ0001.pc_transfere_epr_prejuizo_PP(pr_cdcooper => :pr_cdcooper,
                                               pr_cdagenci => :pr_cdagenci,
                                               pr_nrdcaixa => :pr_nrdcaixa,
                                               pr_cdoperad => :pr_cdoperad,
                                               pr_nrdconta => :pr_nrdconta,
                                               pr_idseqttl => :pr_idseqttl,
                                               pr_dtmvtolt => :pr_dtmvtolt,
                                               pr_nrctremp => :pr_nrctremp,
                                               pr_des_reto => :pr_des_reto,
                                               pr_tab_erro => pr_tab_erro);
end;
9
pr_cdcooper
1
1
4
pr_cdagenci
1
1
4
pr_nrdcaixa
1
1
4
pr_cdoperad
1
1
5
pr_nrdconta
1
9660470
4
pr_idseqttl
1
1
4
pr_dtmvtolt
1
28/12/2020
12
pr_nrctremp
1
2194869
4
pr_des_reto
0
5
0
