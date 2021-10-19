PL/SQL Developer Test script 3.0
306
DECLARE
  CURSOR CR_CRAPLOT IS
      SELECT L.CDCOOPER
           , L.DTMVTOLT
           , L.NRSEQDIG
           , L.CDAGENCI
           , L.CDBCCXLT
           , L.NRDOLOTE
           , L.ROWID
        FROM CECRED.CRAPLOT L
       WHERE DTMVTOLT >= to_date('01/03/2021','dd/mm/rrrr')
         AND DTMVTOLT < to_date('01/10/2021','dd/mm/rrrr')
         AND CDAGENCI = 1
         AND CDBCCXLT = 100
         AND NRDOLOTE = 8361
         AND CDCOOPER=14
       ORDER BY DTMVTOLT, CDCOOPER;
    RW_CRAPLOT CR_CRAPLOT%ROWTYPE;

    -- EMPRESTIMO EM PREJUIZO SEM LANCAMENTO DE JUROS (2409) NO MES (PARAMETRO)
    CURSOR CR_CRAPEPR(PR_DTMVTOLT CECRED.CRAPDAT.DTMVTOLT%TYPE) IS
      SELECT EPR.CDCOOPER
           , EPR.NRDCONTA
           , EPR.NRCTREMP
           , EPR.VLSDPREJ
           , EPR.TXMENSAL
           , EPR.VLSPRJAT
           , EPR.VLJRAPRJ
           , EPR.VLJRMPRJ
           , EPR.DTMVTOLT
           , EPR.ROWID
        FROM CECRED.CRAPEPR EPR
       WHERE EPR.CDCOOPER = 14
         AND EPR.NRDCONTA = 138940
         AND EPR.NRCTREMP = 14479
         AND EPR.TPEMPRST = 1 -- PRE-FIXADO
         AND EPR.INLIQUID = 1 -- LIQUIDADO
         AND EPR.INPREJUZ = 1 -- EM PREJUIZO
         AND NOT EXISTS (SELECT 1
                FROM CECRED.CRAPLEM LEM
               WHERE LEM.CDCOOPER = EPR.CDCOOPER
                 AND LEM.NRDCONTA = EPR.NRDCONTA
                 AND LEM.NRCTREMP = EPR.NRCTREMP
                 AND LEM.CDHISTOR = 2409
                 AND LEM.DTMVTOLT = PR_DTMVTOLT)
        ORDER BY EPR.DTMVTOLT;
    RW_CRAPEPR CR_CRAPEPR%ROWTYPE;

      -- Cursor para buscar o lote
      CURSOR cr_craplot2(pr_cdcooper IN craplot.cdcooper%TYPE,
                        pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.vlinfodb
              ,craplot.vlcompdb
              ,craplot.qtinfoln
              ,craplot.qtcompln
              ,craplot.nrseqdig
              ,craplot.tplotmov
              ,craplot.rowid
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = 8361
           ORDER BY craplot.dtmvtolt;
    rw_craplot2 cr_craplot2%ROWTYPE;

    V_VLJURMES     CECRED.CRAPEPR.VLJURMES%TYPE;
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    vr_texto_completo  CLOB;
    vr_des_log         CLOB;   
    vr_dsdireto        VARCHAR2(1000);
    vr_nmarqbkp        VARCHAR2(100);
    
    vr_cdcooper        crapepr.cdcooper%TYPE;
    vr_nrdconta        crapepr.nrdconta%TYPE;
    vr_nrctremp        crapepr.nrctremp%TYPE;
    vr_dtmvtolt        crapepr.dtmvtolt%TYPE;
    vr_split           GENE0002.typ_split;
    
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
    
    TYPE typ_rec_lancto IS RECORD (txmensal crapepr.txmensal%TYPE
                                  ,vllanmto crapepr.vljurmes%TYPE
                                  ,dtmvtolt crapepr.dtmvtolt%type);

    TYPE typ_campos_lancto IS TABLE OF typ_rec_lancto INDEX BY VARCHAR2(32);
    
    vr_tab_lancto     typ_campos_lancto;
    vr_indice         VARCHAR2(32);
  
  BEGIN
    vr_texto_completo := NULL;
    vr_des_log        := NULL;
    vr_dsdireto       := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
    vr_dsdireto       := vr_dsdireto ||'cpd/bacas/INC0105112'; 
    vr_nmarqbkp       := 'LANC_JUROS_REMUNER_' ||to_char(sysdate,'ddmmyyyy_hh24miss')||'.csv';

    dbms_lob.createtemporary(vr_des_log, TRUE, dbms_lob.call);
    dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

    GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, 'Coop.;Conta;Contrato;Data sem lancto;Valor lcto do Juros;Saldo Prejuizo dia Anterior;Saldo Prejuizo;Juros Acumulados;Juros Calculados no Mes' || chr(10));

    vr_tab_lancto.DELETE;

    OPEN CR_CRAPLOT;
    LOOP
      FETCH CR_CRAPLOT
        INTO RW_CRAPLOT;
      EXIT WHEN CR_CRAPLOT%NOTFOUND;

      OPEN CR_CRAPEPR(RW_CRAPLOT.DTMVTOLT);
      LOOP
        FETCH CR_CRAPEPR
          INTO RW_CRAPEPR;
        EXIT WHEN CR_CRAPEPR%NOTFOUND;
        
        IF to_char(RW_CRAPLOT.DTMVTOLT,'dd/mm/rrrr') = to_char(to_date('31/03/2021'),'dd/mm/rrrr') then 
          V_VLJURMES     := NVL(ROUND(((RW_CRAPEPR.VLSDPREJ) * RW_CRAPEPR.TXMENSAL / 100),2), 0);
          V_VLJURMES     := V_VLJURMES -12.68; -- tirando o prejuizo que ja esta contabilizado do mes 3
        ELSE
          V_VLJURMES     := NVL(ROUND((RW_CRAPEPR.VLSDPREJ * RW_CRAPEPR.TXMENSAL / 100),2), 0);
        END IF;

        

        GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, rw_crapepr.cdcooper || ';' || 
                                                               rw_crapepr.nrdconta || ';' ||
                                                               rw_crapepr.nrctremp || ';' ||
                                                               to_char(RW_CRAPLOT.DTMVTOLT,'dd/mm/rrrr') || ';' ||
                                                               to_char(V_VLJURMES
                                                                      ,'999999990D90'
                                                                      ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                               to_char(rw_crapepr.vlsprjat
                                                                      ,'999999990D90'
                                                                      ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                               to_char(rw_crapepr.vlsdprej
                                                                      ,'999999990D90'
                                                                      ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                               to_char(rw_crapepr.vljraprj
                                                                      ,'999999990D90'
                                                                      ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                               to_char(rw_crapepr.vljrmprj
                                                                      ,'999999990D90'
                                                                      ,'NLS_NUMERIC_CHARACTERS = '',.''') ||
                                                               chr(10));                            
           -- Atualiza o emprestimo
           UPDATE CECRED.CRAPEPR
              SET VLSPRJAT = VLSDPREJ
                , VLSDPREJ = VLSDPREJ + V_VLJURMES
                , VLJRAPRJ = VLJRAPRJ + V_VLJURMES
                , VLJRMPRJ = V_VLJURMES
            WHERE ROWID = RW_CRAPEPR.ROWID;

        vr_indice := rw_crapepr.cdcooper || '_' || rw_crapepr.nrdconta || '_' || rw_crapepr.nrctremp || '_' || to_char(RW_CRAPLOT.DTMVTOLT,'MM') ;
        vr_tab_lancto(vr_indice).txmensal := RW_CRAPEPR.TXMENSAL;
        vr_tab_lancto(vr_indice).vllanmto := NVL(vr_tab_lancto(vr_indice).vllanmto,0) + NVL(V_VLJURMES,0);
        vr_tab_lancto(vr_indice).dtmvtolt := RW_CRAPLOT.DTMVTOLT;
      END LOOP;

      IF (CR_CRAPEPR%ISOPEN) THEN
        CLOSE CR_CRAPEPR;
      END IF;

    END LOOP;
  
    IF (CR_CRAPLOT%ISOPEN) THEN
      CLOSE CR_CRAPLOT;
    END IF;
  
    GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, ' ' || chr(10),TRUE);
    
     -- Grava o arquivo de rollback
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 14                             --> Cooperativa conectada
                                     ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_log             --> Arquivo XML de dados
                                     ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  --commit;
    --DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
            
    dbms_lob.close(vr_des_log);
    dbms_lob.freetemporary(vr_des_log);
    
    
    vr_indice := vr_tab_lancto.FIRST;
    WHILE vr_indice IS NOT NULL LOOP
      vr_split := GENE0002.fn_quebra_string(pr_string  => vr_indice
                                           ,pr_delimit => '_');
      vr_cdcooper := vr_split(1);
      vr_nrdconta := vr_split(2);
      vr_nrctremp := vr_split(3);
      --vr_dtmvtolt := vr_split(4);

      OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      OPEN cr_craplot2(pr_cdcooper => vr_cdcooper
                     ,pr_dtmvtolt => vr_tab_lancto(vr_indice).dtmvtolt);
      FETCH cr_craplot2 INTO rw_craplot2;
      IF cr_craplot2%NOTFOUND THEN
         CLOSE cr_craplot2;
         INSERT INTO craplot(cdcooper
                            ,dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,tplotmov)
                      VALUES(vr_cdcooper         -- Cooperativa
                            ,vr_tab_lancto(vr_indice).dtmvtolt 
                            ,1                   -- PA
                            ,100                 -- Banco/Caixa
                            ,8361                -- Numero do Lote
                            ,5)                  -- Tipo de movimento
                    RETURNING vr_tab_lancto(vr_indice).dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,nrseqdig
                             ,rowid
                         INTO rw_craplot2.dtmvtolt
                             ,rw_craplot2.cdagenci
                             ,rw_craplot2.cdbccxlt
                             ,rw_craplot2.nrdolote
                             ,rw_craplot2.tplotmov
                             ,rw_craplot2.nrseqdig
                             ,rw_craplot2.rowid;
      ELSE
        CLOSE cr_craplot2;
      END IF;

      -- Cria lancamento no extrato da operação
      INSERT INTO CECRED.CRAPLEM
        (CDCOOPER,
         DTMVTOLT,
         CDAGENCI,
         CDBCCXLT,
         NRDOLOTE,
         NRDCONTA,
         NRCTREMP,
         NRDOCMTO,
         CDHISTOR,
         NRSEQDIG,
         VLLANMTO,
         TXJUREPR,
         DTPAGEMP,
         VLPREEMP)
      VALUES
        (vr_cdcooper,
         vr_tab_lancto(vr_indice).dtmvtolt,
         rw_craplot2.cdagenci,
         rw_craplot2.cdbccxlt,
         rw_craplot2.nrdolote,
         vr_nrdconta,
         vr_nrctremp,
         vr_nrctremp,
         2409,
         rw_craplot2.nrseqdig + 1,
         vr_tab_lancto(vr_indice).vllanmto,
         vr_tab_lancto(vr_indice).txmensal,
         NULL,
         0);

      -- Atualiza o lote
      UPDATE craplot
         SET vlinfodb = vlinfodb + vr_tab_lancto(vr_indice).vllanmto
            ,vlcompdb = vlcompdb + vr_tab_lancto(vr_indice).vllanmto
            ,qtinfoln = qtinfoln + 1
            ,qtcompln = qtcompln + 1
            ,nrseqdig = nrseqdig + 1
       WHERE rowid = rw_craplot2.rowid;

      vr_indice := vr_tab_lancto.NEXT(vr_indice);
    END LOOP;

    COMMIT;

  EXCEPTION
    /*WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);*/
    WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao inserir lancamentos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao inserir lancamentos - ' || SQLERRM);
  END;
0
7
vr_texto_completo
V_VLJURMES
RW_CRAPLOT.DTMVTOLT
RW_CRAPEPR.DTMVTOLT
vr_dsdireto
RW_CRAPEPR.TXMENSAL
RW_CRAPEPR.VLSDPREJ
