PL/SQL Developer Test script 3.0
127
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
    
    vr_cdcooper NUMBER := 1;
    vr_nrdconta NUMBER := 8834547;
    
    CURSOR cr_crapsda(pr_dtmvtolt DATE) IS
    SELECT abs(vlsddisp)
      FROM crapsda
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta
       AND dtmvtolt = pr_dtmvtolt;
  BEGIN
    :RESULT:= 'Erro';
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

     -- Cancela produtos/serviços da conta (cartão magnético, senha da internet, limite de crédito)
     PREJ0003.pc_cancela_servicos_cc_prj(pr_cdcooper => vr_cdcooper
                              , pr_nrdconta => vr_nrdconta
                              , pr_dtinc_prejuizo => rw_crapdat.dtmvtolt
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);

     IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) is not NULL THEN
       :pr_cdcritic:= 0;
       :pr_dscritic:= 'Erro ao cancelar produtos/serviços da conta.';

       RETURN;
     END IF;
     
     -- Recupera saldo devedor atual da conta corrente
     OPEN cr_crapsda(rw_crapdat.dtmvtoan);
     FETCH cr_crapsda INTO vr_vlslddev;
     CLOSE cr_crapsda;
     
     vr_vljuro60_37:= 0; --- *******************
     vr_vljuro60_38:= 0;
     vr_vljuro60_57:= 0;
     
     vr_qtdiaatr := TRUNC(SYSDATE) - to_date('28/11/2018', 'DD/MM/YYYY') + 211;

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
       VALUES (vr_cdcooper,
               vr_nrdconta,
               rw_crapdat.dtmvtolt,
               5,
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
        WHERE pass.cdcooper = vr_cdcooper
          AND pass.nrdconta = vr_nrdconta;
     EXCEPTION
        WHEN OTHERS THEN
          :pr_cdcritic :=0;
          :pr_dscritic := 'Erro de update na CRAPASS: '||SQLERRM;
        RETURN;
     END;

     PREJ0003.pc_lanca_transf_extrato_prj(pr_idprejuizo => vr_idprejuizo
                               , pr_cdcooper   => vr_cdcooper
                               , pr_nrdconta   => vr_nrdconta
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
     
     UPDATE crapsld  sld
         SET vlsmnmes = 0
           , vlsmnesp = 0
           , vlsmnblq = 0
           , vljurmes = 0
           , vljuresp = 0
           , vljursaq = 0
       WHERE cdcooper = vr_cdcooper
         AND nrdconta = vr_nrdconta;
                               
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
