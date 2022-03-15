DECLARE
  CURSOR cr_his(pr_cdcooper IN crapcop.cdcooper%TYPE,
                pr_cdhistor IN craphis.cdhistor%TYPE) IS
    SELECT t.cdhistor, t.dshistor, t.indebcre
      FROM craphis t
     WHERE t.cdcooper = pr_cdcooper
       AND t.cdhistor = pr_cdhistor;
  rw_his cr_his%ROWTYPE;

  CURSOR cr_sld_prj(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT t.vlsdprej, t.idprejuizo
      FROM tbcc_prejuizo t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta;
  rw_sld_prj cr_sld_prj%ROWTYPE;

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  vr_cdcritic INTEGER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(1000);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_exc_erro EXCEPTION;
  vr_upsld_prej CHAR(1);
  vr_tipoajus   CHAR(1);
  vr_indebcre  craphis.indebcre%TYPE;

  vr_cdcooper   crapepr.cdcooper%TYPE;
  vr_nrdconta   crapepr.nrdconta%TYPE;
  vr_nrctremp   crapepr.nrctremp%TYPE;
  vr_vllanmto   craplem.vllanmto%TYPE;
  vr_cdhistor   craplem.cdhistor%TYPE;
  vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;

  vr_conta     GENE0002.typ_split;
  vr_reg_conta GENE0002.typ_split;

  PROCEDURE prc_atlz_prejuizo(prm_cdcooper IN craplcm.cdcooper%TYPE,
                              prm_nrdconta IN craplcm.nrdconta%TYPE,
                              prm_vllanmto IN craplcm.vllanmto%TYPE,
                              prm_cdhistor IN craplcm.cdhistor%TYPE,
                              prm_tipoajus IN VARCHAR2) IS
  
    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
    vr_tipoacao   BOOLEAN;
    vr_vlsdprej   tbcc_prejuizo.vlsdprej%TYPE;
    vr_found      BOOLEAN;
  
  BEGIN
  
    OPEN cr_sld_prj(pr_cdcooper => prm_cdcooper,
                    pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj
      INTO rw_sld_prj;
    vr_found    := cr_sld_prj%FOUND;
    vr_vlsdprej := rw_sld_prj.vlsdprej;
    CLOSE cr_sld_prj;
  
    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao buscar Saldo Prejuizo Cop/Cta (' ||
                     prm_cdcooper || '/' || prm_nrdconta || ')';
      RAISE vr_exc_erro;
    END IF;
    vr_found := NULL;
  
    IF prm_tipoajus IS NULL OR prm_tipoajus NOT IN ('E', 'I') THEN
      vr_dscritic := 'Erro: Tipo de Ajuste invalido! (' || prm_tipoajus || ')';
      RAISE vr_exc_erro;
    END IF;
  
    OPEN cr_his(pr_cdcooper => prm_cdcooper
                ,pr_cdhistor => prm_cdhistor);
    FETCH cr_his
      INTO rw_his;
    vr_found    := cr_his%FOUND;
    vr_indebcre := rw_his.indebcre;
    CLOSE cr_his;
  
    IF NOT vr_found THEN
      vr_dscritic := 'Historico não encontrato Cop/Hist (' || prm_cdcooper || '/' ||
                     prm_cdhistor || ')';
      RAISE vr_exc_erro;
    END IF;
  
    IF prm_tipoajus = 'E' THEN
      IF vr_indebcre = 'C' THEN
        vr_tipoacao := TRUE;
      ELSE
        vr_tipoacao := FALSE;
      END IF;
    ELSE
      IF vr_indebcre = 'C' THEN
        vr_tipoacao := FALSE;
      ELSE
        vr_tipoacao := TRUE;
      END IF;
    END IF;
  
    IF vr_tipoacao THEN
      BEGIN
        UPDATE tbcc_prejuizo a
           SET a.vlsdprej = Nvl(vlsdprej, 0) - Nvl(prm_vllanmto, 0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: ' ||
                         SubStr(SQLERRM, 1, 255);
          RAISE vr_exc_erro;
      END;
    ELSE
      BEGIN
        UPDATE tbcc_prejuizo a
           SET a.vlsdprej = Nvl(vlsdprej, 0) + Nvl(prm_vllanmto, 0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: ' ||
                         SubStr(SQLERRM, 1, 255);
          RAISE vr_exc_erro;
      END;
    END IF;
  
  END prc_atlz_prejuizo;

BEGIN

  vr_conta := GENE0002.fn_quebra_string(pr_string  => '5;108626;2408;0,26;Y;I|13;113255;2721;0,65;N;|1;10824308;2408;11,54;N;|11;380571;2721;10,77;N;|11;534200;2722;0,03;N;|11;543195;2721;0,03;N;|1;10970576;2738;33,34;N;|1;10970576;2739;33,33;N;|1;10970576;2720;33,33;N;|1;10970576;2721;33,33;Y;I|14;728;2721;11,93;Y;I|1;6571883;2738;1462,38;N;|1;6571883;2739;670,90;N;|1;6571883;2720;670,90;N;|1;6571883;2721;670,90;Y;I;|1;6571883;2408;200,59;Y;I|',
                                        pr_delimit => '|');
  IF vr_conta.COUNT > 0 THEN
  
    FOR vr_idx_lst IN 1 .. vr_conta.COUNT - 1 LOOP
      vr_reg_conta := GENE0002.fn_quebra_string(pr_string  => vr_conta(vr_idx_lst),
                                                pr_delimit => ';');
    
      vr_cdcooper   := vr_reg_conta(1);
      vr_nrdconta   := vr_reg_conta(2);
      vr_cdhistor   := vr_reg_conta(3);
      vr_vllanmto   := to_number(vr_reg_conta(4));
      vr_upsld_prej := vr_reg_conta(5);
      vr_tipoajus   := vr_reg_conta(6);
    
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
    
      
      IF vr_cdhistor IN (2408, 2721, 2722) THEN
		
		BEGIN
          SELECT a.idprejuizo
            INTO vr_idprejuizo
            FROM tbcc_prejuizo a
           WHERE a.cdcooper = vr_cdcooper
             AND a.nrdconta = vr_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao Buscar chave prejuizo. Erro: ' ||
                           SubStr(SQLERRM, 1, 255);
            RAISE vr_exc_erro;
        END;
      
        prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => vr_cdcooper,
                                          pr_nrdconta   => vr_nrdconta,
                                          pr_dtmvtolt   => rw_crapdat.dtmvtolt,
                                          pr_cdhistor   => vr_cdhistor,
                                          pr_idprejuizo => vr_idprejuizo,
                                          pr_vllanmto   => vr_vllanmto,
                                          pr_dthrtran   => SYSDATE,
                                          pr_cdcritic   => vr_cdcritic,
                                          pr_dscritic   => vr_dscritic);
        IF Nvl(vr_cdcritic, 0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        IF vr_upsld_prej = 'Y' THEN
          prc_atlz_prejuizo(prm_cdcooper => vr_cdcooper,
                            prm_nrdconta => vr_nrdconta,
                            prm_vllanmto => vr_vllanmto,
                            prm_cdhistor => vr_cdhistor,
                            prm_tipoajus => vr_tipoajus);
        END IF;
      
                    
      ELSIF vr_cdhistor IN (2738) THEN
        
        prej0003.pc_gera_cred_cta_prj(pr_cdcooper => vr_cdcooper,
                                      pr_nrdconta => vr_nrdconta,
                                      pr_vlrlanc  => vr_vllanmto,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_dsoperac => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'),
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);

        IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;
        
      ELSIF vr_cdhistor IN (2739) THEN
        
        prej0003.pc_gera_debt_cta_prj(pr_cdcooper => vr_cdcooper,
                                      pr_nrdconta => vr_nrdconta,
                                      pr_vlrlanc  => vr_vllanmto,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_dsoperac => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'),
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);

        IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;
      
      ELSE
 
          IF vr_cdhistor IN (2720) THEN
          
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => vr_cdcooper 
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                          ,pr_cdagenci => 0 
                                          ,pr_cdbccxlt => 100 
                                          ,pr_cdoperad => '1' 
                                          ,pr_cdpactra => 0 
                                          ,pr_nrdolote => 650001 
                                          ,pr_nrdconta => vr_nrdconta 
                                          ,pr_cdhistor => vr_cdhistor 
                                          ,pr_vllanmto => vr_vllanmto 
                                          ,pr_nrparepr => 0 
                                          ,pr_nrctremp => 0 
                                          ,pr_des_reto => vr_des_erro 
                                          ,pr_tab_erro => vr_tab_erro); 
            IF vr_des_erro <> 'OK' THEN
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
              END IF;
            
              RAISE vr_exc_erro;
            END IF;
          
          END IF;
        
      
      END IF;
    
    END LOOP;
  END IF;

  COMMIT;

  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em ' ||
                       To_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20111, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20111, SQLERRM);
END;
