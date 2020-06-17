PL/SQL Developer Test script 3.0
46
DECLARE
  rw_crapdat     btch0001.cr_crapdat%ROWTYPE;

begin

  -- SCRIPT SO PODE SER EXECUTADO UMA VEZ!!!!

  -- BUSCA A DATA DO DIA DA COOPERATIVA
  OPEN btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH btch0001.cr_crapdat
  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  -- EFETUA O LANÇAMENTO NA CONTA TRANSITORIA
  cecred.prej0003.pc_gera_cred_cta_prj(pr_cdcooper => 1,
                                       pr_nrdconta => 2467496,
                                       pr_cdoperad => '1',
                                       pr_vlrlanc => 6000,
                                       pr_dtmvtolt => rw_crapdat.Dtmvtolt,
                                       pr_nrdocmto => 6,
                                       pr_dsoperac => 'Acerto Conta Transitoria',
                                       pr_cdcritic => :pr_cdcritic,
                                       pr_dscritic => :pr_dscritic);


  -- ATUALIZA 2 LANCAMENTOS QUE ESTAVAM COM 0.00 PARA O VALOR CORRETO DE R$ 200.89
  UPDATE tbcc_prejuizo_lancamento t
     SET t.vllanmto = 200.89
   WHERE t.idlancto_prejuizo IN (45024,45025)  ;

  -- ATUALIZAR O SALDO DO DIA COM OS 2 LANCAMENTOS ACIMA ATUALIZADOS
  UPDATE crapsld sld
     SET vlblqprj =  -6000
   WHERE sld.cdcooper = 1
     AND sld.nrdconta = 2467496;

  -- ATUALIZAR O SALDO DOS DIAS DESDE O DIA 15/04/2020, COM OS 2 LANCAMENTOS ACIMA ATUALIZADOS
  UPDATE crapsda sld
     SET vlblqprj =  -6000
   WHERE sld.cdcooper = 1
     AND sld.nrdconta = 2467496
     AND sld.dtmvtolt >= to_date('15/04/2020','dd/mm/yyyy');

 COMMIT;

end;
9
pr_cdcooper
0
-4
pr_nrdconta
0
-4
pr_cdoperad
0
-5
pr_vlrlanc
0
-4
pr_dtmvtolt
0
-12
pr_nrdocmto
0
-4
pr_dsoperac
0
-5
pr_cdcritic
0
3
pr_dscritic
0
5
2
vr_nrdocmto_prj
pr_vlrlanc
