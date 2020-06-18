DECLARE
    cursor cr_crawepr is (
      select a.txdiaria
        from crawepr a
       where a.cdcooper = 1
         and a.nrdconta = 3102521
         and a.nrctremp = 2205202
         and rownum = 1);
    rw_crawepr cr_crawepr%ROWTYPE;
    --Variaveis Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
        
    vr_nrseqdig       number;


BEGIN
      open cr_crawepr;
      fetch cr_crawepr into rw_crawepr;
      if cr_crawepr%NOTFOUND THEN
        close cr_crawepr;
        vr_cdcritic := 0;
        vr_dscritic := 'Registro não encontrado crawepr: Cooperativa='||'1'||
                         ' Conta='||'3102521'||' Contrato empréstimo='||'2205202';        
        
        raise_application_error(-20001,'Erro: '||vr_dscritic);
        
       
      end if;
      CLOSE cr_crawepr;  

      cecred.empr0001.pc_cria_lancamento_lem_chave(pr_cdcooper => 1,
                                                    pr_dtmvtolt => '06/04/2020', --pr_dtmvtolt,
                                                    pr_cdagenci => 90, --pr_cdagenci,
                                                    pr_cdbccxlt => 100,
                                                    pr_cdoperad => '1', --pr_cdoperad,
                                                    pr_cdpactra => 90, --pr_cdagenci,
                                                    pr_tplotmov => 4,
                                                    pr_nrdolote => 600005, --vr_nrdolote_cred,
                                                    pr_nrdconta => 3102521, --pr_nrdconta,
                                                    pr_cdhistor => 1036, --vr_cdhistor_cred,
                                                    pr_nrctremp => 2205202, --pr_nrctremp,
                                                    pr_vllanmto => 1690.00, --vr_vltotemp, --> Valor total emprestado
                                                    pr_dtpagemp => '06/04/2020', --pr_dtmvtolt,
                                                    pr_txjurepr => rw_crawepr.txdiaria,
                                                    pr_vlpreemp => 0,
                                                    pr_nrsequni => 0,
                                                    pr_nrparepr => 0,
                                                    pr_flgincre => true,
                                                    pr_flgcredi => true,
                                                    pr_nrseqava => 0,
                                                    pr_cdorigem => 0, --pr_idorigem,
                                                    pr_qtdiacal => 0,
                                                    pr_vltaxprd => 0,
                                                    pr_nrseqdig => vr_nrseqdig,
                                                    pr_cdcritic => vr_cdcritic,
                                                    pr_dscritic => vr_dscritic);
      
      IF NVL(vr_cdcritic,0) > 0 or NVL(vr_dscritic,'OK') <> 'OK' THEN
        raise_application_error(-20002,'Erro: Código: '||vr_cdcritic || ' Descrição: ' ||vr_dscritic);
      END IF;                                                    


END;
