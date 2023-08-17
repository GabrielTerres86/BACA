DECLARE
  
  vr_cdcriticGeral       cecred.crapcri.cdcritic%type;
  vr_dscriticGeral       cecred.crapcri.dscritic%type;
  vr_cdcooper            cecred.crapcop.cdcooper%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vr_vldcotasGeral       cecred.crapcot.vldcotas%type;
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_arq_path            VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/RITM0319734';
  vr_nmarquiv            VARCHAR2(100) := 'base_contas_prodB.txt';
  vr_nmarqbkp            VARCHAR2(100) := 'RITM0319734b_script_rollback_test.sql';
  vr_nmarqcri            VARCHAR2(100) := 'RITM0319734b_script_log_test.txt';

  vr_hutlfile            utl_file.file_type;
  vr_dstxtlid            VARCHAR2(1000);
  vr_contador            INTEGER := 0;
  vr_qtdctatt            INTEGER := 0;
  vr_flagfind            BOOLEAN := FALSE;
  vr_tab_linhacsv        cecred.gene0002.typ_split;
  vr_vet_dados           SISTEMA.tipoSplit.typ_split;
  vr_dstextab            varchar2(4000);
  vr_dsdrowid            VARCHAR2(50);

  vr_flarqrol            utl_file.file_type;
  vr_flarqlog            utl_file.file_type;
  vr_des_rollback_xml    CLOB;
  vr_texto_rb_completo   VARCHAR2(32600);
  vr_des_critic_xml      CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);  
  
  vr_exc_erro            EXCEPTION;
  vr_exc_clob            EXCEPTION;
  vr_des_erroGeral       VARCHAR2(4000);

  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
  END;

  procedure encerraConta(pr_cdcooper  IN  crapass.cdcooper%TYPE
                        ,pr_nrdconta  IN  crapass.nrdconta%TYPE
                        ,pr_vldcotas  IN  NUMBER               
                        ,pr_qtdparce  IN  INTEGER              
                        ,pr_datadevo  IN  VARCHAR2             
                        ,pr_mtdemiss  IN  INTEGER              
                        ,pr_dtdemiss  IN  VARCHAR2             
                        ,pr_idorigem  IN  INTEGER              
                        ,pr_cdoperad  IN  VARCHAR2             
                        ,pr_nrdcaixa  IN  NUMBER               
                        ,pr_nmdatela  IN  VARCHAR2             
                        ,pr_cdagenci  IN  NUMBER               
                        ,pr_oporigem  IN  INTEGER              
                        ,pr_cdcritic  OUT PLS_INTEGER          
                        ,pr_dscritic  OUT VARCHAR2) IS         


    cr_crapass SYS_REFCURSOR;
    rw_crapass cecred.crapass%ROWTYPE;

    cr_crapalt SYS_REFCURSOR;
    rw_crapalt cecred.crapalt%ROWTYPE;

    cr_crapcot SYS_REFCURSOR;
    rw_crapcot cecred.crapcot%ROWTYPE;

    cr_tbcotas_devolucao SYS_REFCURSOR;
    rw_tbcotas_devolucao cecred.TBCOTAS_DEVOLUCAO%ROWTYPE;

    rw_crapdat SISTEMA.DatasCooperativa;

    vr_nrdolote  NUMBER(10);

    vr_nrseqdig  NUMBER(10);
    vr_cdsitdct  cecred.crapass.cdsitdct%TYPE;
    vr_vldcotas  cecred.crapcot.vldcotas%TYPE;
    vr_nrdrowid  ROWID;
    vr_nrdocmto  NUMBER(25);
    vr_busca     VARCHAR2(100);
    vr_datadevo  DATE;
    vr_dtdemiss  DATE;
    vr_dstextab  VARCHAR2(4000);
    vr_vlrsaldo  cecred.crapcot.vldcotas%TYPE;
    vr_dsmotdem  VARCHAR2(100);
    vr_flgctitg  cecred.crapass.flgctitg%TYPE;
    vr_cdhistor  PLS_INTEGER;
    vr_cdhistor_insert PLS_INTEGER;

    vr_tab_saldos CONTACORRENTE.tipoSaldos.typ_tab_saldos;

    vr_tab_libera_epr CONTACORRENTE.tipoLiberaEpr.typ_tab_libera_epr;
    vr_tab_retorno CONTACORRENTE.tipoRegRetorno.typ_reg_retorno;
    vr_tab_erro SISTEMA.tipoErro.typ_tab_erro;
    vr_incrineg INTEGER;

    vr_vet_dados SISTEMA.tipoSplit.typ_split;

    vr_cdcritic NUMBER(5);
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_exc_saida EXCEPTION;

    BEGIN
      vr_tab_erro.DELETE;
      vr_tab_saldos.DELETE;
      vr_tab_libera_epr.DELETE;

      rw_crapdat := SISTEMA.DatasCooperativa(pr_cdcooper);

      CADASTRO.obterDstextab(pr_cdcooper => pr_cdcooper
                            ,pr_nmsistem => 'CRED'
                            ,pr_tptabela => 'GENERI'
                            ,pr_cdempres => 0
                            ,pr_cdacesso => 'PRAZODESLIGAMENTO'
                            ,pr_tpregist => 1
                            ,pr_dstextab => vr_dstextab);

      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dscritic := 'Não foi possivel encontrar o prazo para desligamento.';
        RAISE vr_exc_saida;
      END IF;

      vr_vet_dados := SISTEMA.quebraString(pr_string => vr_dstextab, pr_delimit => ';');

      cr_crapass := COTASCAPITAL.obterDadosAssociadoBB(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

      FETCH cr_crapass
       INTO rw_crapass.nrdconta
           ,rw_crapass.cdsitdct
           ,rw_crapass.cdagenci
           ,rw_crapass.inpessoa
           ,rw_crapass.nrdctitg
           ,rw_crapass.flgctitg
           ,rw_crapass.dtdemiss
           ,rw_crapass.nmprimtl
           ,rw_crapass.nrcpfcgc
           ,rw_crapass.vllimcre;

      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 09;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      cr_tbcotas_devolucao := COTASCAPITAL.obterRegistroDevolucaoCotas(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
      cr_crapcot := COTASCAPITAL.obterValorCotas(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

      IF rw_crapass.cdsitdct = 8 THEN

        FETCH cr_tbcotas_devolucao
          INTO rw_tbcotas_devolucao.tpdevolucao
              ,rw_tbcotas_devolucao.qtparcelas
              ,rw_tbcotas_devolucao.vlcapital;

        IF cr_tbcotas_devolucao%NOTFOUND THEN
          vr_dscritic := 'Não foi encontrado registro de devolucão das cotas.';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_tbcotas_devolucao;

        IF nvl(pr_vldcotas, 0) > rw_tbcotas_devolucao.vlcapital THEN
          vr_dscritic := 'Valor de devolucão de cotas maior que o valor de cotas disponivel.';
          RAISE vr_exc_saida;
        END IF;

        FETCH cr_crapcot
          INTO rw_crapcot.vldcotas;

        IF cr_crapcot%NOTFOUND THEN
          CLOSE cr_crapcot;
          vr_dscritic := 'Valor de cotas não encontrado.';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcot;

        IF nvl(rw_crapcot.vldcotas, 0) > 0 THEN
          IF nvl(pr_vldcotas, 0) > nvl(rw_crapcot.vldcotas,0) THEN
            vr_dscritic := '(1) Valor de devolucao de cotas maior que o valor de cotas disponivel.';
            RAISE vr_exc_saida;
          END IF;

          vr_vldcotas := pr_vldcotas;

          BEGIN
            COTASCAPITAL.atualizarValorCotas(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_vldcotas => pr_vldcotas
                                            ,pr_vlcotatt => vr_vldcotas);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := '(1) Erro ao atualizar a tabela crapcot.' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          pc_escreve_xml_rollback('UPDATE cecred.crapcot' || chr(10) ||
                                  '   SET vldcotas = vldcotas + ' || to_char(NVL(pr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') || chr(10) ||
                                  ' WHERE cdcooper = ' || pr_cdcooper || chr(10) ||
                                  '   AND nrdconta = ' || pr_nrdconta || ';' || chr(10) || chr(10));
        END IF;

      ELSE

        FETCH cr_tbcotas_devolucao
          INTO rw_tbcotas_devolucao.tpdevolucao
              ,rw_tbcotas_devolucao.qtparcelas
              ,rw_tbcotas_devolucao.vlcapital;

        IF cr_tbcotas_devolucao%FOUND THEN
          CLOSE cr_tbcotas_devolucao;
          IF rw_tbcotas_devolucao.tpdevolucao = 1 THEN
            vr_dscritic := 'Ja foi optado pela devolucão da forma TOTAL.';
            RAISE vr_exc_saida;
          ELSE
            vr_dscritic := 'Ja foi optado pela devolucão da forma PARCIAL em ' ||
                           rw_tbcotas_devolucao.qtparcelas || ' parcelas.';
            RAISE vr_exc_saida;
          END IF;
        END IF;
        CLOSE cr_tbcotas_devolucao;

        FETCH cr_crapcot
          INTO rw_crapcot.vldcotas;

        IF cr_crapcot%NOTFOUND THEN
          CLOSE cr_crapcot;
          vr_dscritic := 'Valor de cotas não encontrado.';
          RAISE vr_exc_saida;
        END IF;

        CLOSE cr_crapcot;

        IF nvl(pr_vldcotas, 0) > nvl(rw_crapcot.vldcotas,0) THEN
          vr_dscritic := 'Valor de devolucão de cotas maior que o valor de cotas disponivel.';
          RAISE vr_exc_saida;
        END IF;

        vr_vldcotas := pr_vldcotas;

        BEGIN
          COTASCAPITAL.atualizarValorCotas(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_vldcotas => pr_vldcotas
                             ,pr_vlcotatt => vr_vldcotas);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '(2)Erro ao atualizar a tabela crapcot.' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        pc_escreve_xml_rollback('UPDATE cecred.crapcot' || chr(10) ||
                                '   SET vldcotas = vldcotas + ' || to_char(NVL(pr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') || chr(10) ||
                                ' WHERE cdcooper = ' || pr_cdcooper || chr(10) ||
                                '   AND nrdconta = ' || pr_nrdconta || ';' || chr(10) || chr(10));
      END IF;

      BEGIN
        vr_datadevo := to_date(pr_datadevo, 'DD/MM/RRRR');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Data de devolucão invalida.';
          RAISE vr_exc_saida;
      END;

      BEGIN
        vr_dtdemiss := to_date(pr_dtdemiss, 'DD/MM/RRRR');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Data de demissão invalida.';
          RAISE vr_exc_saida;
      END;

      IF vr_datadevo < rw_crapdat.dtmvtolt THEN
        vr_dscritic := 'Data de devolucão deve ser maior ou igual a data atual.';
        RAISE vr_exc_saida;
      END IF;

      IF pr_vldcotas > 0 THEN
        IF rw_crapass.cdsitdct = 8 THEN
          IF vr_vet_dados(1) = 1 THEN

            vr_nrdolote := 600038;
            vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                        TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')) || ';' ||
                        TRIM(to_char(rw_crapass.cdagenci)) || ';' || '100;' ||
                        vr_nrdolote;
            vr_nrdocmto := SISTEMA.obterSequence('CRAPLCT', 'NRDOCMTO', vr_busca);
            vr_nrseqdig := SISTEMA.obterSequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,'' || pr_cdcooper || ';' ||
                                       to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                       rw_crapass.cdagenci || ';100;' ||
                                       vr_nrdolote);

            BEGIN
              
              vr_dsdrowid := null;
              
              INSERT INTO CECRED.craplct
              (cdcooper
              ,cdagenci
              ,cdbccxlt
              ,nrdolote
              ,dtmvtolt
              ,cdhistor
              ,nrctrpla
              ,nrdconta
              ,nrdocmto
              ,nrseqdig
              ,vllanmto)
            VALUES
              (pr_cdcooper
              ,rw_crapass.cdagenci
              ,100
              ,vr_nrdolote
              ,rw_crapdat.dtmvtolt
              ,2136
              ,0
              ,pr_nrdconta              
              ,vr_nrdocmto
              ,vr_nrseqdig
              ,pr_vldcotas) RETURN ROWID INTO vr_dsdrowid;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplct.' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));   
            
            BEGIN
              CONTACORRENTE.registrarLancamentoConta(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                    ,pr_dtrefere => rw_crapdat.dtmvtolt
                                                    ,pr_cdagenci => rw_crapass.cdagenci
                                                    ,pr_cdbccxlt => 100
                                                    ,pr_nrdolote => vr_nrdolote
                                                    ,pr_nrdconta => pr_nrdconta
                                                    ,pr_nrdctabb => pr_nrdconta
                                                    ,pr_nrdctitg => TO_CHAR(SISTEMA.formatarMascara(pr_nrdconta,'99999999'))
                                                    ,pr_nrdocmto => vr_nrdocmto
                                                    ,pr_cdhistor => 2137
                                                    ,pr_vllanmto => pr_vldcotas
                                                    ,pr_nrseqdig => vr_nrseqdig
                                                    ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                                                    ,pr_tab_retorno => vr_tab_retorno
                                                    ,pr_incrineg    => vr_incrineg
                                                    ,pr_cdcritic    => vr_cdcritic
                                                    ,pr_dscritic    => vr_dscritic);

              IF nvl(vr_cdcritic, 0) > 0 OR
                 vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

              pc_escreve_xml_rollback('DELETE cecred.craplcm ' || 
                                      'WHERE cdcooper = '||pr_cdcooper || 
                                      ' AND nrdconta = '||pr_nrdconta ||
                                      ' AND dtmvtolt = to_date('''||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')' ||
                                      ' AND cdagenci = '||rw_crapass.cdagenci ||
                                      ' AND cdbccxlt = 100' ||
                                      ' AND nrdolote = ' || vr_nrdolote ||
                                      ' AND nrdocmto = '||vr_nrdocmto||';' || chr(10) || chr(10));

            EXCEPTION
              WHEN vr_exc_saida THEN
                RAISE vr_exc_saida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplcm.' || SQLERRM;
                RAISE vr_exc_saida;
            END;

          ELSE
            vr_dsdrowid := null;
            vr_nrdolote := 600040;
            vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                        TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')) || ';' ||
                        TRIM(to_char(rw_crapass.cdagenci)) || ';' || '100;' ||
                        vr_nrdolote;
            vr_nrdocmto := SISTEMA.obterSequence('CRAPLCT', 'NRDOCMTO', vr_busca);
            vr_nrseqdig := SISTEMA.obterSequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,'' || pr_cdcooper || ';' ||
                                       to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                       rw_crapass.cdagenci || ';100;' ||
                                       vr_nrdolote);
            BEGIN
              IF rw_crapass.inpessoa = 1 THEN
                vr_cdhistor_insert := 2079;
              ELSE
                vr_cdhistor_insert := 2080;
              END IF;
              INSERT INTO CECRED.craplct
                (cdcooper
                ,cdagenci
                ,cdbccxlt
                ,nrdolote
                ,dtmvtolt
                ,cdhistor
                ,nrctrpla
                ,nrdconta
                ,nrdocmto
                ,nrseqdig
                ,vllanmto)
              VALUES
                (pr_cdcooper
                ,rw_crapass.cdagenci
                ,100
                ,vr_nrdolote
                ,rw_crapdat.dtmvtolt
                ,vr_cdhistor_insert
                ,0
                ,pr_nrdconta
                ,vr_nrdocmto
                ,vr_nrseqdig
                ,rw_crapcot.vldcotas) RETURN ROWID INTO vr_dsdrowid;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplct.' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));
            
            BEGIN
              COTASCAPITAL.registrarCotasDevolucao(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_tpdevolc => 3
                                     ,pr_vlcotdev => rw_crapcot.vldcotas);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir 3.1-TBCOTAS_DEVOLUCAO. ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.TBCOTAS_DEVOLUCAO WHERE CDCOOPER = ' || pr_cdcooper || ' AND NRDCONTA = ' || pr_nrdconta || ' AND TPDEVOLUCAO = 3;' || chr(10) || chr(10));
            
          END IF;
        ELSE
          IF vr_vet_dados(1) = 1 THEN
            vr_nrdolote := 600038;
            vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                        TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')) || ';' ||
                        TRIM(to_char(rw_crapass.cdagenci)) || ';' || '100;' ||
                        vr_nrdolote;
            vr_nrdocmto := SISTEMA.obterSequence('CRAPLCT', 'NRDOCMTO', vr_busca);
            vr_nrseqdig := SISTEMA.obterSequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,'' || pr_cdcooper || ';' ||
                                       to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                       rw_crapass.cdagenci || ';100;' ||
                                       vr_nrdolote);
            BEGIN
              COTASCAPITAL.registrarCotDevParcelado(pr_cdcooper     => pr_cdcooper
                                      ,pr_nrdconta     => pr_nrdconta
                                      ,pr_tpdevolucao  => 1
                                      ,pr_vlcapital    => pr_vldcotas
                                      ,pr_qtparcelas   => pr_qtdparce
                                      ,pr_dtinicredito => vr_datadevo);

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela tbcotas_devolucao.' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.TBCOTAS_DEVOLUCAO WHERE CDCOOPER = ' || pr_cdcooper || ' AND NRDCONTA = ' || pr_nrdconta || ' AND TPDEVOLUCAO = 1;' || chr(10) || chr(10));

            BEGIN
              vr_dsdrowid := null;
              
              INSERT INTO CECRED.craplct
                (cdcooper
                ,cdagenci
                ,cdbccxlt
                ,nrdolote
                ,dtmvtolt
                ,cdhistor
                ,nrctrpla
                ,nrdconta
                ,nrdocmto
                ,nrseqdig
                ,vllanmto)
              VALUES
                (pr_cdcooper
                ,rw_crapass.cdagenci
                ,100
                ,vr_nrdolote
                ,rw_crapdat.dtmvtolt
                ,2136
                ,0
                ,pr_nrdconta
                ,vr_nrdocmto
                ,vr_nrseqdig
                ,pr_vldcotas) RETURN ROWID INTO vr_dsdrowid;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplct.' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));

            BEGIN
              CONTACORRENTE.registrarLancamentoConta(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dtrefere => rw_crapdat.dtmvtolt
                                      ,pr_cdagenci => rw_crapass.cdagenci
                                      ,pr_cdbccxlt => 100
                                      ,pr_nrdolote => vr_nrdolote
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrdctabb => pr_nrdconta
                                      ,pr_nrdctitg => TO_CHAR(SISTEMA.formatarMascara(pr_nrdconta,'99999999'))
                                      ,pr_nrdocmto => vr_nrdocmto
                                      ,pr_cdhistor => 2137
                                      ,pr_vllanmto => pr_vldcotas
                                      ,pr_nrseqdig => vr_nrseqdig
                                      ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                                      ,pr_tab_retorno => vr_tab_retorno
                                      ,pr_incrineg    => vr_incrineg
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

              IF nvl(vr_cdcritic, 0) > 0 OR
                 vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            EXCEPTION
              WHEN vr_exc_saida THEN
                RAISE vr_exc_saida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplcm.' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.craplcm ' || 
                                    'WHERE cdcooper = '||pr_cdcooper || 
                                    ' AND nrdconta = '||pr_nrdconta ||
                                    ' AND dtmvtolt = to_date('''||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')' ||
                                    ' AND cdagenci = '||rw_crapass.cdagenci ||
                                    ' AND cdbccxlt = 100' ||
                                    ' AND nrdolote = ' || vr_nrdolote ||
                                    ' AND nrdocmto = '||vr_nrdocmto||';' || chr(10) || chr(10));
            

          ELSE
            vr_nrdolote := 600040;
            vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                        TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')) || ';' ||
                        TRIM(to_char(rw_crapass.cdagenci)) || ';' || '100;' ||
                        vr_nrdolote;
            vr_nrdocmto := SISTEMA.obterSequence('CRAPLCT', 'NRDOCMTO', vr_busca);
            vr_nrseqdig := SISTEMA.obterSequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,'' || pr_cdcooper || ';' ||
                                       to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                       rw_crapass.cdagenci || ';100;' ||
                                       vr_nrdolote);

            BEGIN
              IF rw_crapass.inpessoa = 1 THEN
                vr_cdhistor_insert := 2079;
              ELSE
                vr_cdhistor_insert := 2080;
              END IF;
              
              vr_dsdrowid := null;
              
              INSERT INTO CECRED.craplct
                (cdcooper
                ,cdagenci
                ,cdbccxlt
                ,nrdolote
                ,dtmvtolt
                ,cdhistor
                ,nrctrpla
                ,nrdconta
                ,nrdocmto
                ,nrseqdig
                ,vllanmto)
              VALUES
                (pr_cdcooper
                ,rw_crapass.cdagenci
                ,100
                ,vr_nrdolote
                ,rw_crapdat.dtmvtolt
                ,vr_cdhistor_insert
                ,0
                ,pr_nrdconta
                ,vr_nrdocmto
                ,vr_nrseqdig
                ,rw_crapcot.vldcotas) RETURN ROWID INTO vr_dsdrowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplct.' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));
            
            BEGIN
              COTASCAPITAL.registrarCotasDevolucao(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_tpdevolc => 3
                                     ,pr_vlcotdev => rw_crapcot.vldcotas);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir 3.2-TBCOTAS_DEVOLUCAO. ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            pc_escreve_xml_rollback('DELETE cecred.TBCOTAS_DEVOLUCAO WHERE CDCOOPER = ' || pr_cdcooper || ' AND NRDCONTA = ' || pr_nrdconta || ' AND TPDEVOLUCAO = 3;' || chr(10) || chr(10));

          END IF;

        END IF;
      END IF;

      CONTACORRENTE.obterDepositosAVista(pr_cdcooper       => pr_cdcooper
                                        ,pr_cdagenci       => pr_cdagenci
                                        ,pr_nrdcaixa       => pr_nrdcaixa
                                        ,pr_cdoperad       => pr_cdoperad
                                        ,pr_nrdconta       => pr_nrdconta
                                        ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                        ,pr_idorigem       => pr_idorigem
                                        ,pr_idseqttl       => 1
                                        ,pr_nmdatela       => pr_nmdatela
                                        ,pr_flgerlog       => 'S'
                                        ,pr_tab_saldos     => vr_tab_saldos
                                        ,pr_tab_libera_epr => vr_tab_libera_epr
                                        ,pr_des_reto       => vr_des_erro
                                        ,pr_tab_erro       => vr_tab_erro);
      IF vr_des_erro = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro ao executar a obterDepositosAVista.';
        END IF;
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_saldos.exists(vr_tab_saldos.first) AND
         vr_tab_saldos(vr_tab_saldos.first).vlsddisp > 0 THEN

        vr_vlrsaldo := vr_tab_saldos(vr_tab_saldos.first).vlsddisp;
        vr_nrdolote := 600041;
        vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                    TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')) || ';' ||
                    TRIM(to_char(rw_crapass.cdagenci)) || ';' || '100;' ||
                    vr_nrdolote;
        vr_nrdocmto := SISTEMA.obterSequence('CRAPLAU', 'NRDOCMTO', vr_busca);
        vr_nrseqdig := SISTEMA.obterSequence('CRAPLOT'
                                  ,'NRSEQDIG'
                                  ,'' || pr_cdcooper || ';' ||
                                   to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                   rw_crapass.cdagenci || ';100;' ||
                                   vr_nrdolote);

        BEGIN
          IF rw_crapass.inpessoa = 1 THEN
            vr_cdhistor := 2061;
          ELSE
            vr_cdhistor := 2062;
          END IF;

          CONTACORRENTE.registrarLancamentoConta(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_dtrefere => rw_crapdat.dtmvtolt
                                                ,pr_cdagenci => rw_crapass.cdagenci
                                                ,pr_cdbccxlt => 100
                                                ,pr_nrdolote => vr_nrdolote
                                                ,pr_nrdconta => pr_nrdconta
                                                ,pr_nrdctabb => pr_nrdconta
                                                ,pr_nrdctitg => TO_CHAR(SISTEMA.formatarMascara(pr_nrdconta,'99999999'))
                                                ,pr_nrdocmto => vr_nrdocmto
                                                ,pr_cdhistor => vr_cdhistor
                                                ,pr_vllanmto => NVL(TO_CHAR(vr_vlrsaldo), '0')
                                                ,pr_nrseqdig => vr_nrseqdig
                                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                                                ,pr_tab_retorno => vr_tab_retorno
                                                ,pr_incrineg    => vr_incrineg
                                                ,pr_cdcritic    => vr_cdcritic
                                                ,pr_dscritic    => vr_dscritic);

          IF nvl(vr_cdcritic, 0) > 0 OR
             vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
            
          pc_escreve_xml_rollback('DELETE cecred.craplcm ' || 
                                  'WHERE cdcooper = '||pr_cdcooper || 
                                  ' AND nrdconta = '||pr_nrdconta ||
                                  ' AND dtmvtolt = to_date('''||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')' ||
                                  ' AND cdagenci = '||rw_crapass.cdagenci ||
                                  ' AND cdbccxlt = 100' ||
                                  ' AND nrdolote = ' || vr_nrdolote ||
                                  ' AND nrdocmto = '||vr_nrdocmto||';' || chr(10) || chr(10));
            
        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplcm. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          COTASCAPITAL.registrarCotasDevolucao(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_tpdevolc => 4
                                              ,pr_vlcotdev => NVL(TO_CHAR(vr_vlrsaldo), '0'));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir 4-TBCOTAS_DEVOLUCAO. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
          
        pc_escreve_xml_rollback('DELETE cecred.TBCOTAS_DEVOLUCAO WHERE CDCOOPER = ' || pr_cdcooper || ' AND NRDCONTA = ' || pr_nrdconta || ' AND TPDEVOLUCAO = 4;' || chr(10) || chr(10));
          
      END IF;
        
	  begin
	  UPDATE crapass SET cdmotdem = pr_mtdemiss
                        ,cdsitdct = 4 
                        ,dtdemiss = rw_crapdat.dtmvtolt
						,dtelimin = rw_crapdat.dtmvtolt
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
		 RETURNING cdsitdct INTO vr_cdsitdct;
	  EXCEPTION
	    when others THEN  
		    vr_dscritic := 'Erro ao atualizar a tabela crapass.' || SQLERRM;
                 RAISE vr_exc_saida;
	  end;      
      pc_escreve_xml_rollback('UPDATE CECRED.crapass' ||
                              ' SET cdsitdct = '|| rw_crapass.cdsitdct ||
                              case
                                when rw_crapass.dtdemiss IS NULL THEN
                                  ', dtdemiss = NULL'
                                else
                                  ', dtdemiss = to_date('''||to_char(rw_crapass.dtdemiss,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                              end ||
                              ', cdmotdem = 0'||
                              ' WHERE cdcooper = '||pr_cdcooper ||
                              ' AND nrdconta = '||pr_nrdconta||';' || chr(10) || chr(10));
      

      IF rw_crapass.nrdctitg IS NOT NULL AND
         rw_crapass.flgctitg = 2 THEN
        vr_flgctitg := 0;
      ELSE
        vr_flgctitg := 3;
      END IF;

      cr_crapalt := COTASCAPITAL.obterDescricaoAltProgressId(pr_cdcooper => pr_cdcooper
                                                            ,pr_nrdconta => pr_nrdconta
                                                            ,pr_dtaltera => rw_crapdat.dtmvtolt);

      FETCH cr_crapalt
       INTO rw_crapalt.dsaltera
           ,rw_crapalt.progress_recid;

      IF cr_crapalt%NOTFOUND THEN
        BEGIN
          CLOSE cr_crapalt;
          
          vr_dsdrowid := null;
          
          INSERT INTO CECRED.crapalt
            (nrdconta
            ,dtaltera
            ,cdoperad
            ,dsaltera
            ,tpaltera
            ,flgctitg
            ,cdcooper)
          VALUES
            (pr_nrdconta
            ,rw_crapdat.dtmvtolt
            ,pr_cdoperad
            ,'demissao,sit.cta,'
            ,1
            ,vr_flgctitg
            ,pr_cdcooper) RETURNING ROWID INTO vr_dsdrowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPALT: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        pc_escreve_xml_rollback('DELETE FROM cecred.CRAPALT where rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));

      ELSE
        BEGIN
          CLOSE cr_crapalt;
          CADASTRO.atualizarAlteracoesAssociado(pr_progrsid => rw_crapalt.progress_recid
                                               ,pr_dsaltera => rw_crapalt.dsaltera);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crapalt: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        pc_escreve_xml_rollback('DELETE FROM cecred.CRAPALT where progress_recid = ' || rw_crapalt.progress_recid || ';' || chr(10) || chr(10));

      END IF;

      SISTEMA.geraLog(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad
                     ,pr_dscritic => NULL
                     ,pr_dsorigem => 'AIMARO'
                     ,pr_dstransa => 'Conta encerrada por script - RITM0319734'
                     ,pr_dttransa => TRUNC(SYSDATE)
                     ,pr_flgtrans => 1
                     ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                     ,pr_idseqttl => 1
                     ,pr_nmdatela => 'SCRIPT'
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrdrowid => vr_nrdrowid);

      SISTEMA.geraLogItem(pr_nrdrowid => vr_nrdrowid
                         ,pr_nmdcampo => 'vldcotas'
                         ,pr_dsdadant => to_char(nvl(rw_crapcot.vldcotas, 0),'fm999g999g990d00')
                         ,pr_dsdadatu => to_char(nvl(vr_vldcotas, 0), 'fm999g999g990d00'));

      SISTEMA.geraLogItem(pr_nrdrowid => vr_nrdrowid
                         ,pr_nmdcampo => 'cdsitdct'
                         ,pr_dsdadant => TRIM(to_char(rw_crapass.cdsitdct, '999999'))
                         ,pr_dsdadatu => TRIM(to_char(vr_cdsitdct, '999999')));

      vr_dscritic := NULL;

      CONTACORRENTE.registrarDadosHistorico(pr_nmtabela => 'CRAPASS'
                                           ,pr_nmdcampo => 'CDSITDCT'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdtipcta => 0
                                           ,pr_cdsituac => 0
                                           ,pr_cdprodut => 0
                                           ,pr_tpoperac => 2
                                           ,pr_dsvalant => rw_crapass.cdsitdct
                                           ,pr_dsvalnov => vr_cdsitdct
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      pc_escreve_xml_rollback('DELETE FROM CECRED.tbcc_conta_historico WHERE cdcooper = ' || pr_cdcooper || 
                              ' AND nrdconta = ' || pr_nrdconta ||
                              ' AND idcampo = 2 ' ||
                              ' AND cdtipo_conta = 0' ||
                              ' AND cdsituacao = 0' ||
                              ' AND dsvalor_anterior = ' || rw_crapass.cdsitdct ||
                              ' AND dsvalor_novo = ' || vr_cdsitdct || 
                              ' AND dhalteracao >= trunc(sysdate);' || chr(10) || chr(10));

      SISTEMA.geraLogItem(pr_nrdrowid => vr_nrdrowid
                         ,pr_nmdcampo => 'dtdemiss'
                         ,pr_dsdadant => to_char(rw_crapass.dtdemiss, 'DD/MM/RRRR')
                         ,pr_dsdadatu => to_char(nvl(vr_dtdemiss, rw_crapdat.dtmvtolt)
                                                ,'DD/MM/RRRR'));

      CADASTRO.obterMotivoDemissao(pr_cdcooper => pr_cdcooper
                                  ,pr_cdmotdem => pr_mtdemiss
                                  ,pr_dsmotdem => vr_dstextab
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic = 848 THEN
        vr_dsmotdem := 'MOTIVO NAO CADASTRADO';
      ELSIF vr_dscritic IS NULL THEN
        vr_dsmotdem := pr_mtdemiss || ' - ' || vr_dstextab;
      ELSE
        vr_dsmotdem := 'ERRO NA BUSCA DE MOTIVO';
      END IF;

      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dsmotdem := 'MOTIVO NAO CADASTRADO';
      ELSE
        vr_dsmotdem := pr_mtdemiss || ' - ' || vr_dstextab;
      END IF;

      SISTEMA.geraLogItem(pr_nrdrowid => vr_nrdrowid
                         ,pr_nmdcampo => 'cdmotdem'
                         ,pr_dsdadant => ' '
                         ,pr_dsdadatu => vr_dsmotdem);

      vr_des_erro := 'OK';
      

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF nvl(vr_cdcritic, 0) > 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := obterCritica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        vr_des_erro := 'NOK';

      WHEN OTHERS THEN
        excecaoInterna(3);
        pr_cdcritic := 0;
        pr_dscritic := 'não foi possivel gerar a devolucão do capital.';
        vr_des_erro := 'NOK';
  end encerraConta;

begin
    CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_hutlfile
                          ,pr_des_erro => vr_dscriticGeral);

  IF vr_dscriticGeral IS NOT NULL THEN
    vr_dscriticGeral := 'Erro na leitura do arquivo -> '||vr_dscriticGeral;
    pc_escreve_xml_critica(vr_dscriticGeral || chr(10));
    RAISE vr_exc_erro;
  END IF;

  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;

  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN
      LOOP
        SAVEPOINT sessao_associado;
        vr_cdcooper := 0;
        vr_nrdconta := 0;

        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile
                                           ,pr_des_text => vr_dstxtlid);

        IF length(vr_dstxtlid) <= 1 THEN
          continue;
        END IF;

        vr_contador := vr_contador + 1;
        vr_flagfind := FALSE;

        vr_tab_linhacsv := CECRED.gene0002.fn_quebra_string(vr_dstxtlid,';');
        vr_cdcooper := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(1));
        vr_nrdconta := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(2));
        
        vr_dtmvtolt := sistema.datascooperativa(vr_cdcooper).dtmvtolt;

        IF nvl(vr_cdcooper,0) = 0 OR nvl(vr_nrdconta,0) = 0 THEN
          pc_escreve_xml_critica('Erro ao encontrar cooperativa e conta ' || vr_dstxtlid  || chr(10));
          CONTINUE;
        END IF;
        
        vr_dscriticGeral := null;
        CECRED.CADA0012.pc_retorna_cotas_liberada(vr_cdcooper
                                                 ,vr_nrdconta
                                                 ,vr_vldcotasGeral
                                                 ,vr_dscriticGeral);
        IF TRIM(vr_dscriticGeral) IS NOT NULL THEN
          pc_escreve_xml_critica('Não foi possível retornar as cotas do cooperado (' || vr_cdcooper || '/' || vr_nrdconta || '). ' || vr_dscriticGeral);
          ROLLBACK TO sessao_associado;
          continue;
        END IF;
        
        encerraConta(vr_cdcooper
                    ,vr_nrdconta
                    ,vr_vldcotasGeral
                    ,1
                    ,vr_dtmvtolt
                    ,11
                    ,vr_dtmvtolt
                    ,1
                    ,0
                    ,0
                    ,''
                    ,0
                    ,1
                    ,vr_cdcriticGeral
                    ,vr_dscriticGeral);
                    
        IF TRIM(vr_dscriticGeral) IS NOT NULL THEN
           pc_escreve_xml_critica('Não foi possível devolver capital do cooperado (' || vr_cdcooper || '/' || vr_nrdconta || '). ' || vr_dscriticGeral);
           ROLLBACK TO sessao_associado;
           continue;
        END IF;
        
        vr_qtdctatt := vr_qtdctatt + 1;
        
        IF mod(vr_qtdctatt,100) = 0 THEN
          COMMIT;
          dbms_output.put_line('Commit de ' || vr_qtdctatt || ' registros.');
        END IF;
        
      END LOOP;      

    EXCEPTION
      WHEN no_data_found THEN
        pc_escreve_xml_critica('Qtde contas lidas:'||vr_contador||chr(10));
        pc_escreve_xml_critica('Qtde contas atualizadas:'||vr_qtdctatt);
        pc_escreve_xml_critica(' ',TRUE);

        pc_escreve_xml_rollback('COMMIT;');
        pc_escreve_xml_rollback(' ',TRUE);

        CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqbkp,
                                      pr_des_erro => vr_des_erroGeral);
        IF (vr_des_erroGeral IS NOT NULL) THEN
          dbms_lob.close(vr_des_rollback_xml);
          dbms_lob.freetemporary(vr_des_rollback_xml);
          RAISE vr_exc_clob;
        END IF;

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqcri,
                                      pr_des_erro => vr_des_erroGeral);
        IF (vr_des_erroGeral IS NOT NULL) THEN
          dbms_lob.close(vr_des_critic_xml);
          dbms_lob.freetemporary(vr_des_critic_xml);
          RAISE vr_exc_clob;
        END IF;

        dbms_lob.close(vr_des_rollback_xml);
        dbms_lob.freetemporary(vr_des_rollback_xml);

        dbms_lob.close(vr_des_critic_xml);
        dbms_lob.freetemporary(vr_des_critic_xml);

        dbms_output.put_line('Rotina finalizada, verifique arquivo de criticas em :' || vr_arq_path);
      WHEN OTHERS THEN
        dbms_output.put_line('Erro inesperado 1 - ' || SQLERRM);
        cecred.pc_internal_exception;
    END;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;

    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);

    raise_application_error(-20001, vr_dscriticGeral);

  WHEN OTHERS THEN
    ROLLBACK;

    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);

    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);  
END;
