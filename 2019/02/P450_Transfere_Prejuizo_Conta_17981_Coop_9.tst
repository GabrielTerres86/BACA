PL/SQL Developer Test script 3.0
105
-- Created on 19/02/2019 by T0031667 
declare       
    --Data da cooperativa
    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

    vr_qtdiaatr crapris.qtdiaatr%TYPE;

    vr_vljuro60_37 NUMBER;   -- Juros +60 (Hist. 37 + Hist. 2718)
    vr_vljuro60_38 NUMBER;   -- Juros +60 (Hist. 38)
    vr_vljuro60_57 NUMBER;   -- Juros +60 (Hist. 57)
    vr_vlslddev    NUMBER:= 0; -- Saldo principal (saldo devedor até 59 dias de atraso)

    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
  BEGIN
    :RESULT:= 'Erro';
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(9);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

     -- Cancela produtos/serviços da conta (cartão magnético, senha da internet, limite de crédito)
     PREJ0003.pc_cancela_servicos_cc_prj(pr_cdcooper => 9
                              , pr_nrdconta => 17981
                              , pr_dtinc_prejuizo => rw_crapdat.dtmvtolt
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);

     IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) is not NULL THEN
       :pr_cdcritic:= 0;
       :pr_dscritic:= 'Erro ao cancelar produtos/serviços da conta.';

       RETURN;
     END IF;
     
     vr_vlslddev:= 1575.92;
     vr_vljuro60_37:= 1079.86;
     vr_vljuro60_38:= 0;
     vr_vljuro60_57:= 0;
     
     vr_qtdiaatr := TRUNC(SYSDATE) - to_date('23/11/2018', 'DD/MM/YYYY') + 255;

     BEGIN
       INSERT INTO TBCC_PREJUIZO(cdcooper
                                ,nrdconta
                                ,dtinclusao
                                ,cdsitdct_original
                                ,vldivida_original
                                ,qtdiaatr
                                ,vlsdprej
                                ,vljur60_ctneg
                                ,vljur60_lcred
                                ,intipo_transf)
       VALUES (9,
               17981,
               rw_crapdat.dtmvtolt,
               1,
               vr_vlslddev + vr_vljuro60_37 + vr_vljuro60_57 + vr_vljuro60_38,
               vr_qtdiaatr,
               vr_vlslddev,
               vr_vljuro60_37 + vr_vljuro60_57,
               vr_vljuro60_38,
               0)
       RETURNING idprejuizo INTO vr_idprejuizo;
      EXCEPTION
        WHEN OTHERS THEN
          :pr_cdcritic:=0;
          :pr_dscritic := 'Erro de insert na TBCC_PREJUIZO: '||SQLERRM;
        RETURN;
     END;

     BEGIN
       UPDATE crapass pass
          SET pass.inprejuz = 1
            , pass.cdsitdct = 2
        WHERE pass.cdcooper = 9
          AND pass.nrdconta = 17981;
     EXCEPTION
        WHEN OTHERS THEN
          :pr_cdcritic:=0;
          :pr_dscritic := 'Erro de update na CRAPASS: '||SQLERRM;
        RETURN;
     END;

    

     PREJ0003.pc_lanca_transf_extrato_prj(pr_idprejuizo => vr_idprejuizo
                               , pr_cdcooper   => 9
                               , pr_nrdconta   => 17981
                               , pr_vlsldprj   => vr_vlslddev
                               , pr_vljur60_ctneg => vr_vljuro60_37 + vr_vljuro60_57
                               , pr_vljur60_lcred => vr_vljuro60_38
                               , pr_dtmvtolt   => rw_crapdat.dtmvtolt
                               , pr_tpope      => 'N'
                               , pr_cdcritic   => :pr_cdcritic
                               , pr_dscritic   => :pr_dscritic);
                              
     if nvl(:pr_cdcritic,0) > 0  or TRIM(:pr_dscritic) is not null then
         RETURN;
     end if;
                               
     COMMIT;
     
     :RESULT:= 'Sucesso';
end;
3
RESULT
1
Sucesso
5
pr_cdcritic
0
5
pr_dscritic
0
5
0
