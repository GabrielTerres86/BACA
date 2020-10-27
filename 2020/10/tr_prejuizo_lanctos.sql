DECLARE
  CURSOR cr_crapepr IS
    SELECT e.cdcooper
         , e.nrdconta
         , e.nrctremp
         , e.vlsdprej
         , e.txmensal
         , l.vllanmto
         , e.rowid epr_rowid
         , l.rowid lem_rowid
      FROM crapepr e
      JOIN craplem l
        ON l.cdcooper = e.cdcooper
       AND l.nrdconta = e.nrdconta
       AND l.nrctremp = e.nrctremp
     WHERE e.tpemprst = 0 -- TR
       AND e.inliquid = 1 -- LIQUIDADO
       AND e.inprejuz = 1 -- EM PREJUIZO
       AND e.vlsdprej > 0 -- SALDO PREJUIZO
       AND l.cdhistor = 2409 -- JUROS PREJUIZO
       AND l.dtmvtolt = to_date('21/10/2020','dd/mm/rrrr')
       AND NOT EXISTS (SELECT 1
                         FROM craplem lem
                        WHERE lem.cdcooper = e.cdcooper
                          AND lem.nrdconta = e.nrdconta
                          AND lem.nrctremp = e.nrctremp
                          AND lem.cdhistor = 2701 -- REC.PREJUIZO
                          AND lem.dtmvtolt >= to_date('21/10/2020','dd/mm/rrrr'));

  vr_dsdireto        VARCHAR2(1000);
  vr_texto_completo  CLOB;
  vr_des_log         CLOB;   
  vr_des_erro        VARCHAR2(2000);
  vr_input_file      utl_file.file_type;
  vr_linha_arq       VARCHAR2(110);
  vr_campo           GENE0002.typ_split;
  vr_bi_cdcooper     crapepr.cdcooper%TYPE;
  vr_bi_nrdconta     crapepr.nrdconta%TYPE;
  vr_bi_nrctremp     crapepr.nrctremp%TYPE;
  vr_bi_vlsdprej     crapepr.vlsdprej%TYPE;
  vr_bi_vljraprj     crapepr.vlsdprej%TYPE;
  vr_bi_vljrmprj     crapepr.vlsdprej%TYPE;
  vr_bi_vlsprjat     crapepr.vlsdprej%TYPE;
  vr_vljurmes        crapepr.vljurmes%TYPE;
  vr_tot_vljurmes    crapepr.vljurmes%TYPE;
    
  TYPE typ_rec_lancto IS RECORD (txmensal  crapepr.txmensal%TYPE
                                ,vlsdprej  crapepr.vlsdprej%TYPE
                                ,vllanmto  craplem.vllanmto%TYPE
                                ,epr_rowid ROWID
                                ,lem_rowid ROWID);

  TYPE typ_campos_lancto IS TABLE OF typ_rec_lancto INDEX BY VARCHAR2(22);
    
  vr_tab_lancto     typ_campos_lancto;
  vr_indice         VARCHAR2(22);

BEGIN
  vr_dsdireto := SISTEMA.obternomedirectory(GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison');

  vr_tab_lancto.DELETE;
  FOR rw_crapepr IN cr_crapepr LOOP
    vr_indice := rw_crapepr.cdcooper || '_' || rw_crapepr.nrdconta || '_' || rw_crapepr.nrctremp;
    vr_tab_lancto(vr_indice).txmensal := rw_crapepr.txmensal;
    vr_tab_lancto(vr_indice).vlsdprej := rw_crapepr.vlsdprej;
    vr_tab_lancto(vr_indice).vllanmto := rw_crapepr.vllanmto;
    vr_tab_lancto(vr_indice).epr_rowid := rw_crapepr.epr_rowid;
    vr_tab_lancto(vr_indice).lem_rowid := rw_crapepr.lem_rowid;
  END LOOP;
  
  GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_dsdireto || '/crapepr_tr_preju_bi.csv'
                          ,pr_tipabert => 'R'                --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_input_file      --> Handle do arquivo aberto
                          ,pr_des_erro => vr_des_erro);

  IF utl_file.IS_OPEN(vr_input_file) THEN

    dbms_lob.createtemporary(vr_des_log, TRUE);
    dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

    GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, 'Coop.;Conta;Contrato;Valor lcto do Juros;Lcto Unico dia 21-10;Saldo Prejuizo Anterior;Saldo Prejuizo' || chr(10));

    BEGIN
      LOOP
        GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_linha_arq);
        vr_linha_arq := REPLACE(REPLACE(vr_linha_arq,'"',''),',','.');
        vr_campo := GENE0002.fn_quebra_string(pr_string  => vr_linha_arq
                                             ,pr_delimit => ';');
        IF vr_campo(1) <> 'CDCOOPER' THEN
          vr_bi_cdcooper := GENE0002.fn_char_para_number(vr_campo(1));
          vr_bi_nrdconta := GENE0002.fn_char_para_number(vr_campo(2));
          vr_bi_nrctremp := GENE0002.fn_char_para_number(vr_campo(3));
          vr_bi_vlsdprej := GENE0002.fn_char_para_number(vr_campo(4));
          vr_bi_vljraprj := GENE0002.fn_char_para_number(vr_campo(5));
          vr_bi_vljrmprj := GENE0002.fn_char_para_number(vr_campo(6));

          -- Este contrato ja foi executado
          IF vr_bi_cdcooper = 1 AND vr_bi_nrdconta = 2615690 AND vr_bi_nrctremp = 794105 THEN
            CONTINUE;
          ELSE
            vr_indice := vr_bi_cdcooper || '_' || vr_bi_nrdconta || '_' || vr_bi_nrctremp;
            IF vr_tab_lancto.EXISTS(vr_indice) THEN

              vr_tot_vljurmes := 0;
              FOR vr_idx IN 1..6 LOOP
                vr_vljurmes := NVL(ROUND((vr_bi_vlsdprej * vr_tab_lancto(vr_indice).txmensal / 100),2), 0);
                vr_bi_vlsprjat := vr_bi_vlsdprej;
                vr_tot_vljurmes := vr_tot_vljurmes + vr_vljurmes;
                vr_bi_vlsdprej := vr_bi_vlsdprej + vr_vljurmes;
                GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, vr_bi_cdcooper || ';' || 
                                                                       vr_bi_nrdconta || ';' ||
                                                                       vr_bi_nrctremp || ';' ||
                                                                       to_char(vr_vljurmes
                                                                              ,'999999990D90'
                                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                       to_char(vr_tab_lancto(vr_indice).vllanmto
                                                                              ,'999999990D90'
                                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                       to_char(vr_bi_vlsprjat
                                                                              ,'999999990D90'
                                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                       to_char(vr_bi_vlsdprej
                                                                              ,'999999990D90'
                                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') ||
                                                                       chr(10));
              END LOOP;

              -- Atualiza o emprestimo
              UPDATE crapepr
                 SET vlsprjat = vr_bi_vlsprjat
                   , vlsdprej = vr_bi_vlsdprej
                   , vljraprj = vr_tab_lancto(vr_indice).vljraprj + vr_tot_vljurmes
                   , vljrmprj = vr_tot_vljurmes
               WHERE ROWID = vr_tab_lancto(vr_indice).epr_rowid;
            
              -- Atualiza o lancamento extrato
              UPDATE craplem
                 SET vllanmto = vr_tot_vljurmes
               WHERE ROWID = vr_tab_lancto(vr_indice).lem_rowid;

            END IF;
          END IF;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Fim das linhas do arquivo
        NULL;
    END;

    GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, ' ' || chr(10),TRUE);
    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, 'tr_prejuizo_lanctos' || to_char(SYSDATE,'ddmmrrrr') || '.csv', NLS_CHARSET_ID('UTF8'));

    dbms_lob.close(vr_des_log);
    dbms_lob.freetemporary(vr_des_log);

  END IF;

  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

  COMMIT;
  dbms_output.put_line('Sucesso!');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    IF utl_file.IS_OPEN(vr_input_file) THEN
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    END IF;
END;
