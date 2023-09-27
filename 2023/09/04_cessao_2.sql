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
  
  PROCEDURE pc_crps715_interno(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                              ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                              ,pr_dtultdia IN cecred.crapdat.dtultdia%TYPE
                              ,pr_dscritic OUT cecred.crapcri.dscritic%TYPE) IS
    vr_cdprogra   CONSTANT cecred.crapprg.cdprogra%TYPE := 'CRPS715';
    vr_cdcooper   NUMBER  := 3;


    vr_exc_saida  EXCEPTION;
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.cdcooper
        FROM cecred.crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND cop.cdcooper <> 3
         AND cop.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;

    CURSOR cr_crapris (pr_cdcooper cecred.crapass.cdcooper%TYPE,
                       pr_dtultdma cecred.crapdat.dtultdma%TYPE) IS
       SELECT ass.inpessoa,
              ass.cdagenci,
              (SUM(vri.vldivida) + ROUND(AVG(NVL(j.vljura60,0)),2)) vltotdiv,
              row_number() OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) seqdreg,
              COUNT(1) OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) qtddreg
         FROM gestaoderisco.tbrisco_crapvri vri,
              gestaoderisco.tbrisco_crapris ris,
              cecred.tbcrd_cessao_credito ces,
              cecred.crapass ass,
              gestaoderisco.tbrisco_juros_emprestimo j
        WHERE ces.cdcooper = ass.cdcooper
          AND ces.nrdconta = ass.nrdconta
          AND vri.cdcooper = ris.cdcooper
          AND vri.nrdconta = ris.nrdconta
          AND vri.dtrefere = ris.dtrefere
          AND vri.cdmodali = ris.cdmodali
          AND vri.nrctremp = ris.nrctremp
          AND vri.nrseqctr = ris.nrseqctr
          AND ces.cdcooper = ris.cdcooper
          AND ces.nrdconta = ris.nrdconta
          AND ces.nrctremp = ris.nrctremp
          AND ris.cdcooper = j.cdcooper(+)
          AND ris.nrdconta = j.nrdconta(+)
          AND ris.nrctremp = j.nrctremp(+)
          AND ris.dtrefere = j.dtrefere(+)
          AND vri.cdvencto BETWEEN 110 AND 290
          AND ces.cdcooper = pr_cdcooper
          AND ris.cdorigem = 3
          AND ris.dtrefere = pr_dtultdma
          
          GROUP BY ROLLUP  (ass.inpessoa, ass.cdagenci)
          
          ORDER BY ass.inpessoa, nvl(ass.cdagenci,0) ASC;


    CURSOR cr_cessao (pr_cdcooper cecred.crapass.cdcooper%TYPE,
                      pr_dtultdma cecred.crapdat.dtultdma%TYPE) IS
      SELECT ass.cdagenci
            ,ass.inpessoa
            ,SUM(lem.vllanmto) vltotdiv
            ,row_number() OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) seqdreg
            ,COUNT(1) OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) qtddreg
        FROM cecred.tbcrd_cessao_credito ces
        JOIN cecred.craplem lem
          ON lem.cdcooper = ces.cdcooper
         AND lem.nrdconta = ces.nrdconta
         AND lem.nrctremp = ces.nrctremp
        JOIN cecred.crapass ass
          ON ass.cdcooper = ces.cdcooper
         AND ass.nrdconta = ces.nrdconta
       WHERE ces.cdcooper = pr_cdcooper
         AND lem.dtmvtolt BETWEEN trunc(pr_dtultdma,'MM') AND pr_dtultdma  
         AND lem.cdhistor IN (1038, 1037) 
        
        GROUP BY ROLLUP  (ass.inpessoa, ass.cdagenci)
        
        ORDER BY ass.inpessoa, ass.cdagenci DESC;

    

    vr_nmdireto     VARCHAR2(500);
    vr_nmarqdat     VARCHAR2(500);
    vr_dircopia     VARCHAR2(500);

    vr_vltotali     cecred.crapris.vldivida%TYPE;

    
    vr_dtultdma_util_yymmdd  varchar2(6);
    vr_dtultdma_util_ddmmyy  varchar2(6);
    vr_dtultdia_util_ddmmyy  varchar2(6);

    vr_lshistor     VARCHAR2(600);
    vr_dshistor     VARCHAR2(600);
    vr_lshistor_rev VARCHAR2(600);
    vr_dshistor_rev VARCHAR2(600);


    
    vr_desclob         CLOB;
    vr_desclob_rev     CLOB;
    
    vr_txtcompl        VARCHAR2(32600);
    vr_txtcompl_rev    VARCHAR2(32600);
    vr_dsdlinha        VARCHAR2(32600);

    

    
    PROCEDURE pc_escreve_linha(pr_dsdlinha IN VARCHAR2,
                               pr_flrevers IN BOOLEAN DEFAULT FALSE,
                               pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
      vr_des_dados VARCHAR2(32000);
    BEGIN
      vr_des_dados := pr_dsdlinha;
      IF pr_flrevers = FALSE THEN
        cecred.gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, vr_des_dados, pr_fechaarq);
      ELSE
        cecred.gene0002.pc_escreve_xml(vr_desclob_rev, vr_txtcompl_rev, vr_des_dados, pr_fechaarq);
      END IF;
    END;


  BEGIN

    

    
    IF pr_cdcooper = 0 THEN
      vr_cdcooper := 3;
    ELSE
      vr_cdcooper := pr_cdcooper;
    END IF;


    
    FOR rw_crapcop IN cr_crapcop LOOP
      BEGIN

        
        vr_desclob := NULL;
        dbms_lob.createtemporary(vr_desclob, TRUE);
        dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);

        vr_desclob_rev := NULL;
        dbms_lob.createtemporary(vr_desclob_rev, TRUE);
        dbms_lob.open(vr_desclob_rev, dbms_lob.lob_readwrite);

        
        vr_txtcompl_rev := NULL;
        vr_txtcompl     := NULL;

        
        vr_dtultdma_util_yymmdd  := to_char(pr_dtrefere, 'yymmdd');
        vr_dtultdma_util_ddmmyy  := to_char(pr_dtrefere, 'DDMMRR');
        vr_dtultdia_util_ddmmyy  := to_char(pr_dtultdia, 'DDMMRR');
        
        FOR rw_crapris IN cr_crapris (pr_cdcooper => rw_crapcop.cdcooper,
                                      pr_dtultdma => pr_dtrefere) LOOP

          
          IF rw_crapris.cdagenci IS NULL AND
             rw_crapris.inpessoa IS NULL THEN
            continue;
          
          ELSIF rw_crapris.cdagenci IS NULL THEN

            IF rw_crapris.inpessoa = 1 THEN
              vr_lshistor := '1766,1664';
              vr_dshistor := '"(Cessao) SALDO CESSÃO CARTÃO PESSOA FISICA."';

              vr_lshistor_rev := '1664,1766';
              vr_dshistor_rev := '"(Cessao) REVERSÃO SALDO CESSÃO CARTÃO PESSOA FISICA."';

            ELSIF rw_crapris.inpessoa = 2 THEN
              vr_lshistor := '1766,1664';
              vr_dshistor := '"(Cessao) SALDO CESSÃO CARTÃO PESSOA JURIDICA."';

              vr_lshistor_rev := '1664,1766';
              vr_dshistor_rev := '"(Cessao) REVERSÃO SALDO CESSÃO CARTÃO PESSOA JURIDICA."';

            END IF;

            
            vr_dsdlinha := '99'||TRIM(vr_dtultdma_util_yymmdd)        ||','||
                           TRIM(vr_dtultdma_util_ddmmyy)              ||','||
                           vr_lshistor                                ||','||
                           to_char(rw_crapris.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                           '5210'                                     ||','||
                           vr_dshistor||
                           chr(10);
            
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha);
            vr_dsdlinha := NULL;

            
            vr_dsdlinha := '99'||TRIM(vr_dtultdma_util_yymmdd)        ||','||
                           TRIM(vr_dtultdia_util_ddmmyy)              ||','||
                           vr_lshistor_rev                            ||','||
                           to_char(rw_crapris.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                           '5210'                                     ||','||
                           vr_dshistor_rev                            ||
                           chr(10);
            
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                             pr_flrevers => TRUE);
            vr_dsdlinha := NULL;

            
            vr_vltotali := rw_crapris.vltotdiv;
          ELSE
            
            IF rw_crapris.seqdreg = 2 THEN
            
              vr_dsdlinha := '999,'||
                             to_char(vr_vltotali,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                           chr(10);

            
              pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                               pr_flrevers => TRUE);
          END IF;

            
            vr_dsdlinha := to_char(rw_crapris.cdagenci,'fm000')||','||
                           to_char(rw_crapris.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                           chr(10);

            
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha);
            
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                             pr_flrevers => TRUE,
                             pr_fechaarq => (rw_crapris.seqdreg = rw_crapris.qtddreg)); 

            
            IF rw_crapris.seqdreg = rw_crapris.qtddreg THEN
              
              vr_dsdlinha := '999,'||
                             to_char(vr_vltotali,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                             chr(10);

              pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                             pr_fechaarq => TRUE);  
          END IF;
          END IF;

        END LOOP;

        
        dbms_lob.append(vr_desclob,vr_desclob_rev);

        
        FOR rw_cessao IN cr_cessao (pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_dtultdma => pr_dtrefere) LOOP


          
          IF rw_cessao.cdagenci IS NULL AND
             rw_cessao.inpessoa IS NULL THEN
            continue;
          
          ELSIF rw_cessao.cdagenci IS NULL THEN

            IF rw_cessao.inpessoa = 1 THEN
              vr_lshistor := '7122,7539';
              vr_dshistor := '"(Cessao) AJUSTE RENDAS CONTRATO CESSAO CARTAO PESSOA FISICA."';

            ELSIF rw_cessao.inpessoa = 2 THEN
              vr_lshistor := '7122,7539';
              vr_dshistor := '"(Cessao) AJUSTE RENDAS CONTRATO CESSAO CARTAO PESSOA JURIDICA."';
            END IF;

            
            vr_dsdlinha := '99'||TRIM(vr_dtultdma_util_yymmdd)        ||','||
                           TRIM(vr_dtultdma_util_ddmmyy)              ||','||
                           vr_lshistor                                ||','||
                           to_char(rw_cessao.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                           '5210'                                     ||','||
                           vr_dshistor||
                           chr(10);
            
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha);
            vr_dsdlinha := NULL;

          ELSE
            
            vr_dsdlinha := vr_dsdlinha ||
                           to_char(rw_cessao.cdagenci,'fm000')||','||
                           to_char(rw_cessao.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                           chr(10);
          END IF;

          
          IF rw_cessao.seqdreg = rw_cessao.qtddreg THEN
            
            vr_dsdlinha := vr_dsdlinha || vr_dsdlinha;
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                             pr_fechaarq => TRUE);  

          END IF;

        END LOOP;

        
        vr_nmdireto := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                             pr_cdcooper => rw_crapcop.cdcooper,
                                             pr_nmsubdir => '/contab');
        
        vr_nmarqdat := vr_dtultdma_util_yymmdd||'_'||lpad(rw_crapcop.cdcooper,2,'0')||'_cessao_NOVA_CENTRAL.txt';

        
        cecred.gene0001.pc_param_sistema(pr_nmsistem => 'CRED',
                                  pr_cdcooper => rw_crapcop.cdcooper,
                                  pr_cdacesso => 'DIR_ARQ_CONTAB_X',
                                  pr_dsvlrprm => vr_dircopia);


        cecred.gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => rw_crapcop.cdcooper,
                                            pr_cdprogra  => 'CRPS715',
                                            pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                            pr_dsxml     => vr_desclob,
                                            pr_dsarqsaid => vr_nmdireto||'/novacentral/erro/'||vr_nmarqdat,
                                            pr_cdrelato  => 0,
                                            pr_dspathcop => vr_dircopia,
                                            pr_fldoscop  => 'S',
                                            pr_flg_gerar => 'S',
                                            pr_des_erro  => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        IF dbms_lob.isopen(vr_desclob) <> 1 THEN
          
          dbms_lob.close(vr_desclob);
        END IF;

        dbms_lob.freetemporary(vr_desclob);

        IF dbms_lob.isopen(vr_desclob_rev) <> 0 THEN
          
          dbms_lob.close(vr_desclob_rev);
        END IF;
        dbms_lob.freetemporary(vr_desclob_rev);

        
        COMMIT;


      EXCEPTION

        WHEN vr_exc_erro THEN
          
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            
            vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          vr_dscritic := NULL;
          
          dbms_lob.close(vr_desclob);
          dbms_lob.freetemporary(vr_desclob);
          dbms_lob.close(vr_desclob_rev);
          dbms_lob.freetemporary(vr_desclob_rev);


        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          vr_dscritic := 'Nao foi possivel gerar arquivo contabil: '||SQLERRM;
          vr_dscritic := NULL;
          
          dbms_lob.close(vr_desclob);
          dbms_lob.freetemporary(vr_desclob);
          dbms_lob.close(vr_desclob_rev);
          dbms_lob.freetemporary(vr_desclob_rev);

      END;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        
        pr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_dscritic := sqlerrm;
      
      ROLLBACK;

  END pc_crps715_interno;

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

    pc_crps715_interno(pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_dtrefere => vr_dtultdia
                      ,pr_dtultdia => vr_dtultdia_prxmes
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
