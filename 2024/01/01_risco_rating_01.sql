DECLARE
  vr_exc_erro       EXCEPTION;
  vr_dsdireto       VARCHAR2(2000);
  vr_nmarquiv       VARCHAR2(100);
  vr_cdcritic       INTEGER;
  vr_dscritic       VARCHAR2(4000);
  vr_ind_arquiv     utl_file.file_type;
  vr_ind_arqlog     utl_file.file_type;
  vr_dslinha        VARCHAR2(4000);
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_dttransa       cecred.craplgm.dttransa%type;
  vr_hrtransa       cecred.craplgm.hrtransa%type;
  vr_nrdrowid       ROWID;
  vr_typ_saida      VARCHAR2(3);

  vr_vet_dados      cecred.gene0002.typ_split;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);

  CURSOR cr_crapris(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapris.nrdconta%TYPE
                   ,pr_nrctremp IN cecred.crapris.nrctremp%TYPE) IS
    SELECT o.inrisco_rating
          ,o.inrisco_rating_autom
          ,o.dtrisco_rating_autom
          ,o.dtrisco_rating
          ,o.dtvencto_rating
          ,o.inpontos_rating
          ,o.insegmento_rating
          ,o.flintegrar_sas
          ,o.tpctrato
          ,o.cdoperad_rating
          ,o.insituacao_rating
          ,o.inorigem_rating
      FROM cecred.crapris r, cecred.crapdat d, cecred.tbrisco_operacoes o
     WHERE d.cdcooper = r.cdcooper
       AND r.dtrefere = d.dtmvcentral
       AND o.cdcooper = r.cdcooper
       AND o.nrdconta = r.nrdconta
       AND o.nrctremp = r.nrctremp
       AND r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp
       AND o.tpctrato <> 4;
  rw_crapris cr_crapris%ROWTYPE;
  rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
  vr_dtvencimento     DATE;
  vr_contador         NUMBER:=0;
BEGIN

  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD/MM/RRRR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_numeric_characters = '',.''';
  
  vr_dtvencimento := to_date('10/01/2024','DD/MM/RRRR');

  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, Chr(45) || Chr(45) || ' Rollback das informacoes'||chr(13), FALSE);

  vr_dsdireto := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto := vr_dsdireto||'cpd/bacas/RATING';
  vr_nmarqbkp := 'ROLLBACK_RATING_2024_OUTRAS_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  vr_nmarquiv := 'RISCO_RATING_2024_OUTRAS.csv';

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' Nao foi possivel ler o arquivo de entrada');
    RAISE vr_exc_erro;
  END IF;

  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;

  BEGIN

    LOOP

      IF utl_file.IS_OPEN(vr_ind_arquiv) THEN

        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv
                                    ,pr_des_text => vr_dslinha );

        vr_dslinha := replace(vr_dslinha, chr(13));

        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_dslinha, pr_delimit => ';');

        OPEN cr_crapris(pr_cdcooper => vr_vet_dados(1)
                       ,pr_nrdconta => vr_vet_dados(2)
                       ,pr_nrctremp => vr_vet_dados(3));
        FETCH cr_crapris INTO rw_crapris;
        IF cr_crapris%FOUND THEN
          UPDATE cecred.tbrisco_operacoes a
             SET a.inrisco_rating       = vr_vet_dados(4)
                ,a.inrisco_rating_autom = vr_vet_dados(4)
                ,a.dtrisco_rating_autom = vr_dtvencimento
                ,a.dtrisco_rating       = vr_dtvencimento
                ,a.dtvencto_rating      = vr_dtvencimento + a.qtdiasvencto_rating
                ,a.inpontos_rating      = vr_vet_dados(5)
                ,a.insegmento_rating    = TRIM(vr_vet_dados(6))
                ,a.cdoperad_rating      = '1'
                ,a.insituacao_rating    = 4
                ,a.inorigem_rating      = 1
                ,a.flintegrar_sas       = 0
           WHERE a.cdcooper = vr_vet_dados(1)
             AND a.nrdconta = vr_vet_dados(2)
             AND a.nrctremp = vr_vet_dados(3);

          vr_contador := vr_contador + 1;

          gene0002.pc_escreve_xml(vr_dados_rollback
                                 ,vr_texto_rollback
                                 ,'UPDATE cecred.tbrisco_operacoes o' || chr(13) ||
                                  '   SET o.inrisco_rating       = ' || nvl(to_char(rw_crapris.inrisco_rating), 'null') || chr(13) ||
                                  '      ,o.inrisco_rating_autom = ' || nvl(to_char(rw_crapris.inrisco_rating_autom), 'null') || chr(13) ||
                                  '      ,o.dtrisco_rating_autom = to_date(''' || nvl(to_char(rw_crapris.dtrisco_rating_autom), '01/01/2020') ||''',''dd/mm/RRRR'')' || chr(13) ||
                                  '      ,o.dtrisco_rating       = to_date(''' || nvl(to_char(rw_crapris.dtrisco_rating), '01/01/2020') ||''',''dd/mm/RRRR'')' || chr(13) ||
                                  '      ,o.dtvencto_rating      = to_date(''' || nvl(to_char(rw_crapris.dtvencto_rating), '01/01/2020') ||''',''dd/mm/RRRR'')' || chr(13) ||
                                  '      ,o.inpontos_rating      = ' || nvl(to_char(rw_crapris.inpontos_rating), '0') || chr(13) ||
                                  '      ,o.insegmento_rating    = ''' || nvl(to_char(rw_crapris.insegmento_rating), ' ') ||''''  || chr(13) ||
                                  '      ,o.cdoperad_rating      = ''' || nvl(to_char(rw_crapris.cdoperad_rating), ' ') ||''''  || chr(13) ||
                                  '      ,o.insituacao_rating    = ' || nvl(to_char(rw_crapris.insituacao_rating), 'null') || chr(13) ||
                                  '      ,o.inorigem_rating      = ' || nvl(to_char(rw_crapris.inorigem_rating), 'null') || chr(13) ||
                                  '      ,o.flintegrar_sas       = ' || nvl(to_char(rw_crapris.flintegrar_sas), 0) || chr(13) ||
                                  ' WHERE o.cdcooper = ' || vr_vet_dados(1) || chr(13) ||
                                  '   AND o.nrdconta = ' || vr_vet_dados(2) || chr(13) ||
                                  '   AND o.nrctremp = ' || vr_vet_dados(3) ||
                                  ';' ||chr(13)||chr(13), FALSE);

        ELSE
          gene0002.pc_escreve_xml(vr_dados_rollback
                                 ,vr_texto_rollback
                                 ,'Contrato nao encontrado - cdcooper = ' || vr_vet_dados(1) ||
                                  ' nrdconta = ' || vr_vet_dados(2) ||
                                  ' nrctremp = ' || vr_vet_dados(3) ||
                                  ';' ||chr(13)||chr(13), FALSE);
        END IF;
        CLOSE cr_crapris;

        IF Mod (vr_contador,1000) = 0 THEN
          COMMIT;
        END IF;

      END IF;
    END LOOP;

  EXCEPTION
    WHEN no_data_found THEN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  END;

  gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '|| vr_nmdireto||'/' || vr_nmarquiv || ' '
                                                     || vr_nmdireto||'/' || 'PROC_' || to_char(sysdate,'ddmmyyyy_hh24miss') || vr_nmarquiv
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
  IF NVL(vr_typ_saida,' ') = 'ERR' THEN
    RAISE vr_exc_erro;
  END IF;


  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);

  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3
                                     ,pr_cdprogra  => 'ATENDA'
                                     ,pr_dtmvtolt  => trunc(SYSDATE)
                                     ,pr_dsxml     => vr_dados_rollback
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp
                                     ,pr_flg_impri => 'N'
                                     ,pr_flg_gerar => 'S'
                                     ,pr_flgremarq => 'N'
                                     ,pr_nrcopias  => 1
                                     ,pr_des_erro  => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  COMMIT;

  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;
