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
       WHERE DTMVTOLT >= to_date('01/04/2020','dd/mm/rrrr')
         AND DTMVTOLT < to_date('01/10/2020','dd/mm/rrrr')
         AND CDAGENCI = 1
         AND CDBCCXLT = 100
         AND NRDOLOTE = 8361
       ORDER BY DTMVTOLT, CDCOOPER;
    RW_CRAPLOT CR_CRAPLOT%ROWTYPE;

    -- EMPRESTIMOS TR EM PREJUIZO SEM LANCAMENTO DE JUROS (2409) NO MES (PARAMETRO)
    CURSOR CR_CRAPEPR(PR_DTMVTOLT CECRED.CRAPDAT.DTMVTOLT%TYPE,
                      PR_CDCOOPER CECRED.CRAPDAT.CDCOOPER%TYPE) IS
      SELECT EPR.CDCOOPER
           , EPR.NRDCONTA
           , EPR.NRCTREMP
           , EPR.VLSDPREJ
           , EPR.TXMENSAL
           , EPR.VLSPRJAT
           , EPR.VLJRAPRJ
           , EPR.VLJRMPRJ
           , EPR.ROWID
        FROM CECRED.CRAPEPR EPR
       WHERE EPR.CDCOOPER = PR_CDCOOPER
         AND EPR.TPEMPRST = 0 -- TR
         AND EPR.INLIQUID = 1 -- LIQUIDADO
         AND EPR.INPREJUZ = 1 -- EM PREJUIZO
         AND EPR.VLSDPREJ > 0 -- SALDO PREJUIZO
         AND NOT EXISTS (SELECT 1
                FROM CECRED.CRAPLEM LEM
               WHERE LEM.CDCOOPER = EPR.CDCOOPER
                 AND LEM.NRDCONTA = EPR.NRDCONTA
                 AND LEM.NRCTREMP = EPR.NRCTREMP
                 AND LEM.CDHISTOR = 2409
                 AND LEM.DTMVTOLT = PR_DTMVTOLT);
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
           AND craplot.nrdolote = 8361;
    rw_craplot2 cr_craplot2%ROWTYPE;

    V_VLJURMES     CECRED.CRAPEPR.VLJURMES%TYPE;
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    vr_texto_completo  CLOB;
    vr_des_log         CLOB;   
    vr_dsdireto        VARCHAR2(1000);
    vr_cdcooper        crapepr.cdcooper%TYPE;
    vr_nrdconta        crapepr.nrdconta%TYPE;
    vr_nrctremp        crapepr.nrctremp%TYPE;
    vr_split           GENE0002.typ_split;
    
    TYPE typ_rec_lancto IS RECORD (txmensal crapepr.txmensal%TYPE
                                  ,vllanmto crapepr.vljurmes%TYPE);

    TYPE typ_campos_lancto IS TABLE OF typ_rec_lancto INDEX BY VARCHAR2(22);
    
    vr_tab_lancto     typ_campos_lancto;
    vr_indice         VARCHAR2(22);
  
  BEGIN
    vr_texto_completo := NULL;
    vr_des_log        := NULL;
    vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison';

    vr_tab_lancto.DELETE;

    dbms_lob.createtemporary(vr_des_log, TRUE);
    dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

    GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, 'Coop.;Conta;Contrato;Data sem lancto;Valor lcto do Juros;Saldo Prejuizo dia Anterior;Saldo Prejuizo;Juros Acumulados;Juros Calculados no Mes' || chr(10));

    OPEN CR_CRAPLOT;
    LOOP
      FETCH CR_CRAPLOT
        INTO RW_CRAPLOT;
      EXIT WHEN CR_CRAPLOT%NOTFOUND;

      OPEN CR_CRAPEPR(RW_CRAPLOT.DTMVTOLT, RW_CRAPLOT.CDCOOPER);
      LOOP
        FETCH CR_CRAPEPR
          INTO RW_CRAPEPR;
        EXIT WHEN CR_CRAPEPR%NOTFOUND;

        V_VLJURMES     := NVL(ROUND((RW_CRAPEPR.VLSDPREJ * RW_CRAPEPR.TXMENSAL / 100),2), 0);

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

        vr_indice := rw_crapepr.cdcooper || '_' || rw_crapepr.nrdconta || '_' || rw_crapepr.nrctremp;
        vr_tab_lancto(vr_indice).txmensal := RW_CRAPEPR.TXMENSAL;
        vr_tab_lancto(vr_indice).vllanmto := NVL(vr_tab_lancto(vr_indice).vllanmto,0) + NVL(V_VLJURMES,0);
      END LOOP;

      IF (CR_CRAPEPR%ISOPEN) THEN
        CLOSE CR_CRAPEPR;
      END IF;

    END LOOP;
  
    IF (CR_CRAPLOT%ISOPEN) THEN
      CLOSE CR_CRAPLOT;
    END IF;
  
    GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, ' ' || chr(10),TRUE);
    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, 'tr_prejuizo_lanctos' || to_char(SYSDATE,'ddmmrrrr') || '.csv', NLS_CHARSET_ID('UTF8'));
            
    dbms_lob.close(vr_des_log);
    dbms_lob.freetemporary(vr_des_log);
    
    vr_indice := vr_tab_lancto.FIRST;
    WHILE vr_indice IS NOT NULL LOOP
      vr_split := GENE0002.fn_quebra_string(pr_string  => vr_indice
                                           ,pr_delimit => '_');
      vr_cdcooper := vr_split(1);
      vr_nrdconta := vr_split(2);
      vr_nrctremp := vr_split(3);

      OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      OPEN cr_craplot2(pr_cdcooper => vr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
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
                            ,rw_crapdat.dtmvtolt -- Data Atual
                            ,1                   -- PA
                            ,100                 -- Banco/Caixa
                            ,8361                -- Numero do Lote
                            ,5)                  -- Tipo de movimento
                    RETURNING dtmvtolt
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
         rw_craplot2.dtmvtolt,
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
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END;
