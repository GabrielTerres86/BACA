DECLARE

  vr_dtrefere         DATE := to_date('01/09/2023', 'DD/MM/RRRR');
  vr_dtrefere_ris     DATE := to_date('31/08/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY a.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  TYPE vr_venc IS RECORD(
      dias INTEGER);

  TYPE typ_vencto IS TABLE OF vr_venc INDEX BY BINARY_INTEGER;
      vr_vencto typ_vencto;


  TYPE typ_decimal IS RECORD(
      valor  NUMBER(25, 2) := 0
     ,dsc    VARCHAR(25));

  TYPE typ_arr_decimal
    IS TABLE OF typ_decimal
      INDEX BY BINARY_INTEGER;

  TYPE typ_decimal_pfpj IS RECORD(
      valorpf  NUMBER(25, 2) := 0
     ,dscpf    VARCHAR(25)
     ,valorpj  NUMBER(25, 2) := 0
     ,dscpj    VARCHAR(25)
     ,valormei NUMBER(25, 2) := 0
     ,dscmei   VARCHAR(25));

  TYPE typ_arr_decimal_pfpj
    IS TABLE OF typ_decimal_pfpj
      INDEX BY BINARY_INTEGER;

  vr_nom_arquivo VARCHAR2(100);
  vr_des_xml     CLOB;
  vr_dstexto     VARCHAR2(32700);
  vr_nom_direto  VARCHAR2(400);
  
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_dtmvtopr            cecred.crapdat.dtmvtopr%type;
  vr_dtultdia            cecred.crapdat.dtultdia%type;
  vr_dtultdia_prxmes     cecred.crapdat.dtultdia%type;
  
  rw_crapdat datascooperativa;
  
 PROCEDURE pc_gera_segregacao_prejuizo(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                                       ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
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
        FROM gestaoderisco.tbrisco_crapvri vri
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

    FOR rw_crapcop IN cr_crapcop LOOP
      
      vr_nom_diretorio := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                                pr_cdcooper => rw_crapcop.cdcooper,
                                                pr_nmsubdir => 'contab');

      
      vr_dsdircop := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
      
      vr_dtmvtolt_yymmdd := to_char(rw_crapdat.dtmvtoan, 'yymmdd');
      vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_SEGREGACAO_PREJUIZO_NOVA_CENTRAL.txt';

      
      cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio, 
                               pr_nmarquiv => vr_nmarqdat,      
                               pr_tipabert => 'W',              
                               pr_utlfileh => vr_arquivo_txt,   
                               pr_des_erro => vr_dscritic);

      if vr_dscritic is not null then
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      end if;

      
      FOR rw_crapvri IN cr_crapvri(pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_dtrefere => pr_dtrefere) LOOP
        
        IF rw_crapvri.cdvencto = 320 THEN
          vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(rw_crapdat.dtmvtoan,'ddmmyy'))||','||
                         '9261,'||
                         '9263,'||
                         trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                         '5210,'||
                         '"VALOR REF. SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 12 MESES"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          
          vr_linhadet := trim(to_char(rw_crapdat.dtmvtolt,'yymmdd'))||','||
                         trim(to_char(rw_crapdat.dtmvtolt,'ddmmyy'))||','||
                         '9263,'||
                         '9261,'||
                         trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                         '5210,'||
                         '"VALOR REF. REVERSAO DE SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 12 MESES"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          
        ELSE 
          
          vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(rw_crapdat.dtmvtoan,'ddmmyy'))||','||
                         '9261,'||
                         '9262,'||
                         trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                         '5210,'||
                         '"VALOR REF. SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 48 MESES"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          
          vr_linhadet := trim(to_char(rw_crapdat.dtmvtolt,'yymmdd'))||','||
                         trim(to_char(rw_crapdat.dtmvtolt,'ddmmyy'))||','||
                         '9262,'||
                         '9261,'||
                         trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                         '5210,'||
                         '"VALOR REF. REVERSAO DE SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 48 MESES"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      
        END IF;
      END LOOP;

      cecred.gene0001.pc_fecha_arquivo(vr_arquivo_txt);

      vr_qtd_arq_gerados := vr_qtd_arq_gerados + 1;

      vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(rw_crapcop.cdcooper),2,0)||'_SEGREGACAO_PREJUIZO_NOVA_CENTRAL.txt';

      
      cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic);
      
      if vr_typ_said = 'ERR' then
         vr_cdcritic := 1040;
         cecred.gene0001.pc_print(cecred.gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
      else
        vr_qtd_arq_movidos := vr_qtd_arq_movidos + 1;
      end if;

      COMMIT;
    END LOOP;

  EXCEPTION
   WHEN vr_exc_erro THEN
     pr_cdcritic := vr_cdcritic;
     pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
     pr_cdcritic := 0;
     pr_dscritic := 'Erro na rotina CONV0001.pc_relat_repasse_dpvat. ' || SQLERRM;
  END;

begin
  
  FOR rw_crapcop IN cr_crapcop LOOP
    GESTAODERISCO.obterCalendario(pr_cdcooper   => rw_crapcop.cdcooper
                                 ,pr_dtrefere   => vr_dtrefere
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_dtmvtolt := rw_crapdat.dtmvtoan;

    vr_dtmvtopr := rw_crapdat.dtmvtolt;

    vr_dtultdia := last_day(vr_dtmvtolt);
    vr_dtultdia_prxmes := last_day(vr_dtmvtopr);

    pc_gera_segregacao_prejuizo(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_dtrefere => vr_dtultdia
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    COMMIT;

  END LOOP;
  
  
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
