DECLARE

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  PROCEDURE pc_gera_segregacao_prejuizo(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT cecred.crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT cecred.crapcri.dscritic%TYPE) IS
    CURSOR cr_crapcop IS
      SELECT c.cdcooper
        FROM cecred.crapcop c
       WHERE c.flgativo = 1
         AND c.cdcooper = pr_cdcooper;

    CURSOR cr_crapvri(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtrefere IN DATE) IS
      SELECT vri.cdvencto
           , SUM(vri.vldivida) vlprejuz
        FROM cecred.crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.dtrefere = pr_dtrefere
         AND vri.cdvencto IN (320, 330)
       GROUP
          BY vri.cdvencto
       ORDER
          BY vri.cdvencto;

    vr_dtmvtolt_yymmdd     varchar2(6);

    vr_nom_diretorio       varchar2(200);
    vr_dsdircop            varchar2(200);

    vr_nmarqnov            VARCHAR2(50); 
    vr_nmarqdat            varchar2(50);

    vr_arquivo_txt         utl_file.file_type;
    vr_linhadet            varchar2(200);

    vr_typ_said            VARCHAR2(4);
    vr_qtd_arq_gerados     INTEGER := 0;
    vr_qtd_arq_movidos     INTEGER := 0;
    
    vr_dtrefere            DATE;

    vr_cdcritic cecred.crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

  BEGIN

    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    IF TO_CHAR(btch0001.rw_crapdat.dtmvtoan, 'MM') <> TO_CHAR(btch0001.rw_crapdat.dtmvtolt, 'MM') THEN

      FOR rw_crapcop IN cr_crapcop LOOP
        vr_nom_diretorio := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                  pr_cdcooper => rw_crapcop.cdcooper,
                                                  pr_nmsubdir => 'contab');

        vr_dsdircop := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => 0
                                                       ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
        vr_dtmvtolt_yymmdd := to_char(btch0001.rw_crapdat.dtmvtoan, 'yymmdd');
        vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_SEGREGACAO_PREJUIZO.txt';

        cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,
                                        pr_nmarquiv => vr_nmarqdat,         
                                        pr_tipabert => 'W',                 
                                        pr_utlfileh => vr_arquivo_txt,      
                                        pr_des_erro => vr_dscritic);

        if vr_dscritic is not null then
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        end if;
        
        GESTAODERISCO.obterDataCentralMensal(pr_cdcooper  => pr_cdcooper
                                            ,pr_rwcrapdat => btch0001.rw_crapdat
                                            ,pr_dtultdma  => vr_dtrefere);
        
        FOR rw_crapvri IN cr_crapvri(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtrefere => vr_dtrefere) LOOP
          IF rw_crapvri.cdvencto = 320 THEN
            vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtoan,'ddmmyy'))||','||
                           '9261,'||
                           '9263,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 12 MESES"';

            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            vr_linhadet := trim(to_char(btch0001.rw_crapdat.dtmvtolt,'yymmdd'))||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtolt,'ddmmyy'))||','||
                           '9263,'||
                           '9261,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. REVERSAO DE SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 12 MESES"';

            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          ELSE 
            vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtoan,'ddmmyy'))||','||
                           '9261,'||
                           '9262,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 48 MESES"';

            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            vr_linhadet := trim(to_char(btch0001.rw_crapdat.dtmvtolt,'yymmdd'))||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtolt,'ddmmyy'))||','||
                           '9262,'||
                           '9261,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. REVERSAO DE SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 48 MESES"';

            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          END IF;
        END LOOP;

        gene0001.pc_fecha_arquivo(vr_arquivo_txt);
        
        vr_qtd_arq_gerados := vr_qtd_arq_gerados + 1;

        vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(rw_crapcop.cdcooper),2,0)||'_SEGREGACAO_PREJUIZO.txt';

        cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        if vr_typ_said = 'ERR' then
           vr_cdcritic := 1040;
           cecred.gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
        else
          vr_qtd_arq_movidos := vr_qtd_arq_movidos + 1;
        end if;

        COMMIT;
      END LOOP;
      
    END IF;
  EXCEPTION
   WHEN vr_exc_erro THEN
     pr_cdcritic := vr_cdcritic;
     pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
     pr_cdcritic := 0;
     pr_dscritic := 'Erro na rotina pc_gera_segregacao_prejuizo. ' || SQLERRM;
  END;

BEGIN 

  FOR rw_crapcop IN cr_crapcop LOOP

    pc_gera_segregacao_prejuizo(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
