-- Created on 14/04/2020 by T0032717 
DECLARE
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_cdcooper crapcop.cdcooper%TYPE := 1;
  vr_nrdconta crapass.nrdconta%TYPE := 9041605;
  vr_totalest tbcc_prejuizo_detalhe.vllanmto%TYPE := 231.16;
  vr_dtdcorte DATE := to_date('28/02/2020', 'DD/MM/RRRR');
  vr_justific VARCHAR2(500) := 'ESTORNO INC0043779';
  vr_idprej TBCC_PREJUIZO_LANCAMENTO.Idlancto_Prejuizo%TYPE;
  
  PROCEDURE pc_grava_estorno_preju(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                  ,pr_totalest IN tbcc_prejuizo_detalhe.vllanmto%TYPE --> Total a estornar
                                  ,pr_dtdcorte IN DATE
                                  ,pr_justific IN VARCHAR2 --> Descrição da justificativa
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ) IS
  
    --> Consultar ultimo lancamento de prejuizo
    CURSOR cr_detalhe_ult_lanc(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE
                              ,pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE) IS
      SELECT d.dthrtran
            ,d.idprejuizo
        FROM tbcc_prejuizo_detalhe d
       WHERE d.cdcooper = pr_cdcooper
         AND d.nrdconta = pr_nrdconta
         AND d.cdhistor IN (2733, --> REC. PREJUIZO
                            2723, --> ABONO PREJUIZO
                            2725, --> BX.PREJ.PRIN
                            2727, --> BX.PREJ.JUROS
                            2729) --> BX.PREJ.JUROS        
       ORDER BY d.dtmvtolt DESC
               ,d.dthrtran DESC;
    rw_detalhe_ult_lanc cr_detalhe_ult_lanc%ROWTYPE;
  
    --> Consultar todos os historicos para soma à estornar
    --> 2723 – Abono de prejuízo
    --> 2725 – Pagamento do valor principal do prejuízo
    --> 2727 – Pagamento dos juros +60 da transferência para prejuízo
    --> 2729 – Pagamento dos juros remuneratórios do prejuízo
    --> 2323 – Pagamento de IOF provisionado
    --> 2721 – Débito para pagamento do prejuízo (para fins contábeis)
    CURSOR cr_detalhe_tot_est(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE
                             ,pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE
                             ,pr_dthrtran DATE) IS
      SELECT d.cdhistor
            ,d.vllanmto
            ,d.idprejuizo
        FROM tbcc_prejuizo_detalhe d
       WHERE d.cdcooper = pr_cdcooper
         AND d.nrdconta = pr_nrdconta
         AND d.dthrtran > pr_dthrtran
         AND d.dthrtran < pr_dthrtran + 1
         AND (d.cdhistor = 2723 --> 2723 – Abono de prejuízo
             OR d.cdhistor = 2725 --> 2725 – Pagamento do valor principal do prejuízo
             OR d.cdhistor = 2727 --> 2727 – Pagamento dos juros +60 da transferência para prejuízo
             OR d.cdhistor = 2729 --> 2729 – Pagamento dos juros remuneratórios do prejuízo
             OR d.cdhistor = 2323 --> 2323 – Pagamento do IOF
             OR d.cdhistor = 2721 --> 2721 – Débito para pagamento do prejuízo (para fins contábeis)
             OR d.cdhistor = 2733) --> 2733 - Débito para pagamento do prejuízo (para fins contábeis)
       ORDER BY d.dtmvtolt
               ,d.dthrtran DESC
               ,d.cdhistor ASC;
    rw_detalhe_tot_est cr_detalhe_tot_est%ROWTYPE;
  
    -- Carrega o calendário de datas da cooperativa
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  
    -- Variaveis de log
    vr_cdoperad VARCHAR2(100) := 1;
    vr_cdagenci VARCHAR2(100) := 1;
    vr_nrdcaixa VARCHAR2(100) := 1;
  
    --Variaveis Locais
    vr_cdhistor tbcc_prejuizo_detalhe.cdhistor%TYPE;
    vr_valordeb tbcc_prejuizo_detalhe.vllanmto%TYPE;
    vr_nrdocmto NUMBER;
  
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;
  
    vr_incrineg    INTEGER;
    vr_tab_retorno LANC0001.typ_reg_retorno;
    vr_nrseqdig    craplcm.nrseqdig%TYPE;
    vr_vlest_princ NUMBER;
    vr_vlest_jur60 NUMBER;
    vr_vlest_jupre NUMBER;
    vr_vlest_abono NUMBER;
    vr_vlest_IOF   NUMBER := 0;
    vr_vldpagto    NUMBER := 0;
    vr_vlest_saldo NUMBER := 0;
    
    vr_vlrabono       NUMBER := 0;
    vr_vljur60_ctneg  NUMBER := 0;
    vr_vljuprej       NUMBER := 0;
    vr_vlpgprej       NUMBER := 0;
    vr_vlsdprej       NUMBER := 0;
    
  BEGIN
  
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
  
    -----> PROCESSAMENTO PRINCIPAL <-----
  
    IF nvl(ltrim(pr_justific), 'VAZIO') = 'VAZIO' THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Obrigatório o preenchimento do campo justificativa';
      RAISE vr_exc_erro;
    END IF;
  
    OPEN cr_detalhe_ult_lanc(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
  
    FETCH cr_detalhe_ult_lanc
      INTO rw_detalhe_ult_lanc;
  
    IF cr_detalhe_ult_lanc%FOUND THEN
      CLOSE cr_detalhe_ult_lanc;
      FOR rw_detalhe_tot_est IN cr_detalhe_tot_est(pr_cdcooper => pr_cdcooper,
                                                   pr_nrdconta => pr_nrdconta,
                                                   pr_dthrtran => pr_dtdcorte) LOOP
      
        IF rw_detalhe_tot_est.cdhistor = 2723 THEN
          -- 2724 <- ESTORNO - > Abono de prejuízo
          vr_vlest_abono := rw_detalhe_tot_est.vllanmto;
          vr_cdhistor    := 2724;
        ELSIF rw_detalhe_tot_est.cdhistor = 2725 THEN
          -- 2726 <- ESTORNO - > Pagamento do valor principal do prejuízo
          vr_cdhistor    := 2726;
          vr_vldpagto    := nvl(vr_vldpagto, 0) + nvl(rw_detalhe_tot_est.vllanmto, 0);
          vr_vlest_saldo := nvl(rw_detalhe_tot_est.vllanmto, 0);
        ELSIF rw_detalhe_tot_est.cdhistor = 2727 THEN
          -- 2728 <- ESTORNO - > Pagamento dos juros +60 da transferência para prejuízo
          vr_vlest_jur60 := rw_detalhe_tot_est.vllanmto;
          vr_cdhistor    := 2728;
          vr_vldpagto    := nvl(vr_vldpagto, 0) + nvl(rw_detalhe_tot_est.vllanmto, 0);
        ELSIF rw_detalhe_tot_est.cdhistor = 2729 THEN
          -- 2730 <- ESTORNO - > Pagamento dos juros remuneratórios do prejuízo
          vr_vlest_jupre := rw_detalhe_tot_est.vllanmto;
          vr_cdhistor    := 2730;
          vr_vldpagto    := nvl(vr_vldpagto, 0) + nvl(rw_detalhe_tot_est.vllanmto, 0);
        ELSIF rw_detalhe_tot_est.cdhistor = 2323 THEN
          -- 2323 <- ESTORNO - > Pagamento do IOF
          vr_vlest_IOF := rw_detalhe_tot_est.vllanmto;
        ELSIF rw_detalhe_tot_est.cdhistor = 2721 THEN
          -- 2722 <- ESTORNO - > Débito para pagamento do prejuízo (para fins contábeis)
          vr_cdhistor := 2722;
        ELSIF rw_detalhe_tot_est.cdhistor = 2733 THEN
          -- 2732 <- ESTORNO - > Débito para pagamento do prejuízo
          vr_cdhistor    := 2732;
          vr_vlest_princ := rw_detalhe_tot_est.vllanmto;
          vr_valordeb    := rw_detalhe_tot_est.vllanmto;
        END IF;
      
        IF rw_detalhe_tot_est.cdhistor NOT IN (2323, 2723) THEN
          -- insere o estorno com novo histórico
          BEGIN
            INSERT INTO tbcc_prejuizo_detalhe
              (dtmvtolt,
               nrdconta,
               cdhistor,
               vllanmto,
               dthrtran,
               cdoperad,
               cdcooper,
               idprejuizo,
               dsjustificativa)
            VALUES
              (rw_crapdat.dtmvtolt,
               pr_nrdconta,
               vr_cdhistor,
               rw_detalhe_tot_est.vllanmto,
               SYSDATE,
               vr_cdoperad,
               pr_cdcooper,
               rw_detalhe_tot_est.idprejuizo,
               pr_justific);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro de insert na tbcc_prejuizo_detalhe: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          gene0002.pc_escreve_xml(vr_dados_rollback,
                                  vr_texto_rollback,
                                  'DELETE tbcc_prejuizo_detalhe p ' || chr(13) ||
                                  ' WHERE p.cdcooper = ' || pr_cdcooper || chr(13) ||
                                  '   AND p.nrdconta = ' || pr_nrdconta || chr(13) ||
                                  '   AND p.idprejuizo = ' || rw_detalhe_tot_est.idprejuizo ||
                                  chr(13) || '   AND p.dtmvtolt = ''' || rw_crapdat.dtmvtolt || ''' ' ||
                                  chr(13) || '   AND p.vllanmto = ' || replace(rw_detalhe_tot_est.vllanmto, ',', '.') ||
                                  chr(13) || '   AND p.cdhistor = ' || vr_cdhistor || '; ' ||
                                  chr(13) || chr(13),
                                  FALSE);
        END IF;
      END LOOP;
    
      IF vr_valordeb > 0 THEN
        -- Insere lançamento com histórico 2738
        BEGIN
          INSERT INTO TBCC_PREJUIZO_LANCAMENTO
            (dtmvtolt,
             cdagenci,
             nrdconta,
             nrdocmto,
             cdhistor,
             vllanmto,
             dthrtran,
             cdoperad,
             cdcooper,
             cdorigem)
          VALUES
            (rw_crapdat.dtmvtolt,
             vr_cdagenci,
             pr_nrdconta,
             999992722,
             2738,
             vr_valordeb,
             SYSDATE,
             vr_cdoperad,
             pr_cdcooper,
             5) RETURNING idlancto_prejuizo INTO vr_idprej;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        gene0002.pc_escreve_xml(vr_dados_rollback,
                                vr_texto_rollback,
                                'DELETE TBCC_PREJUIZO_LANCAMENTO pl ' || chr(13) ||
                                ' WHERE p.cdcooper = ' || pr_cdcooper || chr(13) ||
                                '   AND p.nrdconta = ' || pr_nrdconta || chr(13) ||
                                '   AND p.idlancto_prejuizo = ' || vr_idprej || '; ' || chr(13) || chr(13),
                                FALSE);
      
        vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT',
                                   pr_nmdcampo => 'NRSEQDIG',
                                   pr_dsdchave => to_char(pr_cdcooper) || ';' ||
                                                  to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                                  '1;100;650009');
      
        vr_nrdocmto := 999992722;
        LOOP
        
          LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                    pr_cdagenci    => vr_cdagenci,
                                    pr_cdbccxlt    => vr_nrdcaixa,
                                    pr_nrdolote    => 650009,
                                    pr_nrdconta    => pr_nrdconta,
                                    pr_nrdocmto    => vr_nrdocmto,
                                    pr_cdhistor    => 2719,
                                    pr_nrseqdig    => vr_nrseqdig,
                                    pr_vllanmto    => vr_valordeb,
                                    pr_nrdctabb    => pr_nrdconta,
                                    pr_cdpesqbb    => 'ESTORNO DE PAGAMENTO DE PREJUÍZO DE C/C',
                                    pr_dtrefere    => rw_crapdat.dtmvtolt,
                                    pr_hrtransa    => gene0002.fn_busca_time,
                                    pr_cdoperad    => vr_cdoperad,
                                    pr_cdcooper    => pr_cdcooper,
                                    pr_cdorigem    => 5,
                                    pr_incrineg    => vr_incrineg,
                                    pr_tab_retorno => vr_tab_retorno,
                                    pr_cdcritic    => vr_cdcritic,
                                    pr_dscritic    => vr_dscritic);

          gene0002.pc_escreve_xml(vr_dados_rollback,
                                  vr_texto_rollback,
                                  'DELETE craplcm l ' || chr(13) ||
                                  ' WHERE l.cdcooper = ' || pr_cdcooper || chr(13) ||
                                  '   AND l.nrdconta = ' || pr_nrdconta || chr(13) ||
                                  '   AND l.nrdocmto = ' || vr_nrdocmto || chr(13) || 
                                  '   AND l.nrdolote = 650009' || chr(13) || 
                                  '   AND l.cdhistor = 2719' || chr(13) || 
                                  '   AND l.vllanmto = ' || replace(vr_valordeb, ',', '.') || chr(13) || 
                                  '   AND l.dtmvtolt = ''' || rw_crapdat.dtmvtolt || '''; ' || chr(13) || chr(13),
                                  FALSE);
          
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            IF vr_incrineg = 0 THEN
              IF vr_cdcritic = 92 THEN
                vr_nrdocmto := vr_nrdocmto + 10000;
                continue;
              END IF;
              RAISE vr_exc_erro;
            ELSE
              RAISE vr_exc_erro;
            END IF;
          END IF;
          
          EXIT;
        
        END LOOP;
      
      END IF;
    
      vr_vldpagto := nvl(vr_vldpagto, 0) - nvl(vr_valordeb, 0);
    
    ELSE
      CLOSE cr_detalhe_ult_lanc;
    END IF;
  
    --> Extornar Abono
    IF vr_vldpagto > 0 AND vr_vlest_abono > 0 THEN
    
      IF vr_vlest_abono < vr_vldpagto THEN
        vr_dscritic := 'Não possui valor de abono suficiente para estorno do pagamento.';
        RAISE vr_exc_erro;
      END IF;
    
      --> Estorno na prejuizo detalhe
      BEGIN
        INSERT INTO tbcc_prejuizo_detalhe
          (dtmvtolt,
           nrdconta,
           cdhistor,
           vllanmto,
           dthrtran,
           cdoperad,
           cdcooper,
           idprejuizo,
           dsjustificativa)
        VALUES
          (rw_crapdat.dtmvtolt,
           pr_nrdconta,
           2724 -- ESTORNO - > Abono de prejuízo
          ,
           vr_vldpagto,
           SYSDATE,
           vr_cdoperad,
           pr_cdcooper,
           rw_detalhe_ult_lanc.idprejuizo,
           pr_justific);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na tbcc_prejuizo_detalhe(2724): ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'DELETE tbcc_prejuizo_detalhe p ' || chr(13) ||
                              ' WHERE p.cdcooper = ' || pr_cdcooper || chr(13) ||
                              '   AND p.nrdconta = ' || pr_nrdconta || chr(13) ||
                              '   AND p.idprejuizo = ' || rw_detalhe_tot_est.idprejuizo || chr(13) ||
                              '   AND p.dtmvtolt = ' || rw_crapdat.dtmvtolt || chr(13) ||
                              '   AND p.vllanmto = ' || replace(rw_detalhe_tot_est.vllanmto, ',', '.') || chr(13) ||
                              '   AND p.cdhistor = 2724; ' || chr(13) || chr(13),
                              FALSE);
    
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT',
                                 pr_nmdcampo => 'NRSEQDIG',
                                 pr_dsdchave => to_char(pr_cdcooper) || ';' ||
                                                to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                                '1;100;650009');
    
      vr_nrdocmto := 999992724;
      LOOP
      
        LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                  pr_cdagenci    => vr_cdagenci,
                                  pr_cdbccxlt    => vr_nrdcaixa,
                                  pr_nrdolote    => 650009,
                                  pr_nrdconta    => pr_nrdconta,
                                  pr_nrdocmto    => vr_nrdocmto,
                                  pr_cdhistor    => 2724,
                                  pr_nrseqdig    => vr_nrseqdig,
                                  pr_vllanmto    => vr_vldpagto,
                                  pr_nrdctabb    => pr_nrdconta,
                                  pr_cdpesqbb    => 'ESTORNO DE ABONO DE PREJUÍZO DE C/C',
                                  pr_dtrefere    => rw_crapdat.dtmvtolt,
                                  pr_hrtransa    => gene0002.fn_busca_time,
                                  pr_cdoperad    => vr_cdoperad,
                                  pr_cdcooper    => pr_cdcooper,
                                  pr_cdorigem    => 5,
                                  pr_incrineg    => vr_incrineg,
                                  pr_tab_retorno => vr_tab_retorno,
                                  pr_cdcritic    => vr_cdcritic,
                                  pr_dscritic    => vr_dscritic);
        
        gene0002.pc_escreve_xml(vr_dados_rollback,
                                vr_texto_rollback,
                                'DELETE craplcm l ' || chr(13) ||
                                ' WHERE l.cdcooper = ' || pr_cdcooper || chr(13) ||
                                '   AND l.nrdconta = ' || pr_nrdconta || chr(13) ||
                                '   AND l.nrdocmto = ' || vr_nrdocmto || chr(13) || 
                                '   AND l.nrdolote = 650009' || chr(13) || 
                                '   AND l.cdhistor = 2724' || chr(13) || 
                                '   AND l.vllanmto = ' || replace(vr_valordeb, ',', '.') || chr(13) || 
                                '   AND l.dtmvtolt = ''' || rw_crapdat.dtmvtolt || '''; ' || chr(13) || chr(13),
                                FALSE);
          
        IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          IF vr_incrineg = 0 THEN
            IF vr_cdcritic = 92 THEN
              vr_nrdocmto := vr_nrdocmto + 10000;
              continue;
            END IF;
            RAISE vr_exc_erro;
          ELSE
            RAISE vr_exc_erro;
          END IF;
        END IF;
      
        EXIT;
      
      END LOOP;
    
      --> atualizar valor de abono com o valor que realmente conseguiu abonar
      vr_vlest_abono := vr_vldpagto;
      vr_vldpagto    := 0;
    
    END IF;
    
    SELECT prj.vlrabono,
           prj.vljur60_ctneg,
           prj.vljuprej,
           prj.vlpgprej,
           prj.vlsdprej
      INTO vr_vlrabono,
           vr_vljur60_ctneg,
           vr_vljuprej,
           vr_vlpgprej,
           vr_vlsdprej
      FROM tbcc_prejuizo prj
     WHERE prj.idprejuizo = rw_detalhe_ult_lanc.idprejuizo;
     
    gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE tbcc_prejuizo p ' || chr(13) ||
                              '   SET p.vlrabono = ' || replace(vr_vlrabono, ',', '.') || chr(13) ||
                              '      ,p.vljur60_ctneg = ' || replace(vr_vljur60_ctneg, ',', '.') || chr(13) ||
                              '      ,p.vljuprej = ' || replace(vr_vljuprej, ',', '.') || chr(13) ||
                              '      ,p.vlpgprej = ' || replace(vr_vlpgprej, ',', '.') || chr(13) ||
                              '      ,p.vlsdprej = ' || replace(vr_vlsdprej, ',', '.') || chr(13) ||
                              ' WHERE p.idprejuizo = ' || rw_detalhe_ult_lanc.idprejuizo ||'; ' || chr(13) || chr(13),
                              FALSE);
    
    BEGIN
      UPDATE tbcc_prejuizo prj
         SET prj.vlrabono      = prj.vlrabono - nvl(vr_vlest_abono, 0)
            ,prj.vljur60_ctneg = prj.vljur60_ctneg + nvl(vr_vlest_jur60, 0)
            ,prj.vljuprej      = prj.vljuprej + nvl(vr_vlest_jupre, 0)
            ,prj.vlpgprej      = prj.vlpgprej - (nvl(vr_vlest_princ, 0) + nvl(vr_vlest_IOF, 0))
            ,prj.vlsdprej      = prj.vlsdprej + (nvl(vr_vlest_saldo, 0))
       WHERE prj.idprejuizo = rw_detalhe_ult_lanc.idprejuizo;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro de update na TBCC_PREJUIZO: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
  
    --COMMIT;
  
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na pc_grava_estorno_preju --> ' || SQLERRM;
  END pc_grava_estorno_preju;
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                            ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      -- Primeiro garantimos que o diretorio exista
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
      
        -- Efetuar a criação do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
      
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      
        -- Adicionar permissão total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
      
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;
  END;
BEGIN
  vr_nmdireto := gene0001.fn_param_sistema('CRED', 0, 'ROOT_MICROS');
  vr_nmdireto       := vr_nmdireto || '/cecred/odirlei/INC0043779/';
  
  -- Primeiro criamos o diretorio da RITM, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto , pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  
  vr_nmarqbkp       := 'ROLLBACK_INC0043779_' || to_char(SYSDATE, 'ddmmyyyy_hh24miss') || '.sql';
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' || chr(13),
                          FALSE);

  pc_grava_estorno_preju(pr_cdcooper => vr_cdcooper,
                         pr_nrdconta => vr_nrdconta,
                         pr_totalest => vr_totalest,
                         pr_dtdcorte => vr_dtdcorte,
                         pr_justific => vr_justific,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;' || chr(13), FALSE);

  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper,
                                      pr_cdprogra  => 'ATENDA',
                                      pr_dtmvtolt  => trunc(SYSDATE),
                                      pr_dsxml     => vr_dados_rollback,
                                      pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarqbkp,
                                      pr_flg_impri => 'N',
                                      pr_flg_gerar => 'S',
                                      pr_flgremarq => 'N',
                                      pr_nrcopias  => 1,
                                      pr_des_erro  => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;
