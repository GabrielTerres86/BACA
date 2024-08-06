DECLARE
  CURSOR cr_work_arquv(pr_cdcooper    cecred.tbgen_batch_relatorio_wrk.cdcooper%TYPE
                      ,pr_cdprograma  cecred.tbgen_batch_relatorio_wrk.cdprograma%TYPE
                      ,pr_dsrelatorio cecred.tbgen_batch_relatorio_wrk.dsrelatorio%TYPE
                      ,pr_dtmvtolt    cecred.tbgen_batch_relatorio_wrk.dtmvtolt%TYPE) IS
    SELECT dsxml
      FROM cecred.tbgen_batch_relatorio_wrk
     WHERE cdcooper = pr_cdcooper
       AND cdprograma = pr_cdprograma
       AND dsrelatorio = pr_dsrelatorio
       AND dtmvtolt = pr_dtmvtolt
     ORDER BY cdagenci
             ,nrdconta
             ,dschave
             ,nrctremp;

  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop
     WHERE crapcop.cdcooper <> 3
       AND crapcop.flgativo = 1
     ORDER BY cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  TYPE vr_reg_texto IS RECORD(
    dsdchave VARCHAR2(30),
    dsdtexto VARCHAR2(6000));

  TYPE vr_typ_texto IS TABLE OF vr_reg_texto INDEX BY PLS_INTEGER;

  vr_tab_texto1       vr_typ_texto;
  vr_tab_texto2       vr_typ_texto;
  vr_tab_texto3       vr_typ_texto;
  vr_tab_texto4       vr_typ_texto;
  vr_tab_texto5       vr_typ_texto;
  vr_tab_texto6       vr_typ_texto;
  vr_tab_texto7       vr_typ_texto;
  vr_tab_texto8       vr_typ_texto;
  vr_tab_texto9       vr_typ_texto;
  vr_tab_texto10      vr_typ_texto;
  vr_tab_texto11      vr_typ_texto;
  vr_tab_texto_Generi vr_typ_texto;

  TYPE typ_tab_contlinh IS VARRAY(11) OF PLS_INTEGER;
  TYPE typ_tab_nmclob IS VARRAY(11) OF VARCHAR2(100);
  TYPE typ_tab_linha IS VARRAY(11) OF VARCHAR2(6000);

  vr_tab_contlinh typ_tab_contlinh := typ_tab_contlinh(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  vr_tab_nmclob   typ_tab_nmclob := typ_tab_nmclob(NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL);
  vr_tab_linha    typ_tab_linha := typ_tab_linha(NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL);

  pr_cdcooper          cecred.crapcop.cdcooper%TYPE := 3;
  pr_cdprogra          VARCHAR2(4000) := 'CRPS652';
  vr_dtatual           DATE := sistema.datascooperativa(3).dtmvtoan;
  vr_dtmvtolt          VARCHAR2(10) := to_char(sistema.datascooperativa(3).dtmvtoan, 'YYYYMMDD');
  vr_dtmvtopr          VARCHAR2(10) := to_char(sistema.datascooperativa(3).dtmvtolt, 'YYYYMMDD');
  vr_setlinha          VARCHAR2(6000);
  vr_nmarquivo         VARCHAR2(6000);
  vr_caminho           VARCHAR2(1000);
  vr_caminho_ailosmais VARCHAR2(1000);
  vr_tparquiv          VARCHAR2(1000);
  vr_comando           VARCHAR2(1000);
  vr_typ_saida         VARCHAR2(1000);
  vr_tempoatu          VARCHAR2(1000);
  vr_qtdlinha          INTEGER;
  vr_cdcritic          INTEGER := 0;
  vr_dscritic          VARCHAR2(4000);
  vr_exc_saida EXCEPTION;

  vr_des_xml1  CLOB;
  vr_des_xml2  CLOB;
  vr_des_xml3  CLOB;
  vr_des_xml4  CLOB;
  vr_des_xml5  CLOB;
  vr_des_xml6  CLOB;
  vr_des_xml7  CLOB;
  vr_des_xml8  CLOB;
  vr_des_xml9  CLOB;
  vr_des_xml10 CLOB;
  vr_des_xml11 CLOB;
  vr_des_txt1  VARCHAR2(32767);
  vr_des_txt2  VARCHAR2(32767);
  vr_des_txt3  VARCHAR2(32767);
  vr_des_txt4  VARCHAR2(32767);
  vr_des_txt5  VARCHAR2(32767);
  vr_des_txt6  VARCHAR2(32767);
  vr_des_txt7  VARCHAR2(32767);
  vr_des_txt8  VARCHAR2(32767);
  vr_des_txt9  VARCHAR2(32767);
  vr_des_txt10 VARCHAR2(32767);
  vr_des_txt11 VARCHAR2(32767);

  PROCEDURE pc_escreve_dado(pr_des_text IN VARCHAR2
                           ,pr_cod_info IN INTEGER
                           ,pr_des_chav IN VARCHAR2) IS
    vr_count NUMBER;
    vr_linha VARCHAR2(6000);
  BEGIN
    IF pr_des_text IS NOT NULL THEN
      vr_linha := pr_des_text;
    ELSE
      vr_linha := vr_tab_linha(pr_cod_info);
      vr_tab_linha(pr_cod_info) := NULL;
    END IF;
  
    IF pr_cod_info = 1 THEN
      vr_count := vr_tab_texto1.count();
      vr_tab_texto1(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto1(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 2 THEN
      vr_count := vr_tab_texto2.count();
      vr_tab_texto2(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto2(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 3 THEN
      vr_count := vr_tab_texto3.count();
      vr_tab_texto3(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto3(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 4 THEN
      vr_count := vr_tab_texto4.count();
      vr_tab_texto4(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto4(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 5 THEN
      vr_count := vr_tab_texto5.count();
      vr_tab_texto5(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto5(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 6 THEN
      vr_count := vr_tab_texto6.count();
      vr_tab_texto6(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto6(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 7 THEN
      vr_count := vr_tab_texto7.count();
      vr_tab_texto7(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto7(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 8 THEN
      vr_count := vr_tab_texto8.count();
      vr_tab_texto8(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto8(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 9 THEN
      vr_count := vr_tab_texto9.count();
      vr_tab_texto9(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto9(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 10 THEN
      vr_count := vr_tab_texto10.count();
      vr_tab_texto10(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto10(vr_count).dsdtexto := vr_linha;
    ELSIF pr_cod_info = 11 THEN
      vr_count := vr_tab_texto11.count();
      vr_tab_texto11(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto11(vr_count).dsdtexto := vr_linha;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao escrever na PLTABLE(' || pr_cod_info || '). ' || SQLERRM;
      RAISE vr_exc_saida;
  END pc_escreve_dado;

  PROCEDURE pc_inicializa_clob IS
  BEGIN
    dbms_lob.createtemporary(vr_des_xml1, TRUE);
    dbms_lob.open(vr_des_xml1, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml2, TRUE);
    dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml3, TRUE);
    dbms_lob.open(vr_des_xml3, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml4, TRUE);
    dbms_lob.open(vr_des_xml4, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml5, TRUE);
    dbms_lob.open(vr_des_xml5, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml6, TRUE);
    dbms_lob.open(vr_des_xml6, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml7, TRUE);
    dbms_lob.open(vr_des_xml7, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml8, TRUE);
    dbms_lob.open(vr_des_xml8, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml9, TRUE);
    dbms_lob.open(vr_des_xml9, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml10, TRUE);
    dbms_lob.open(vr_des_xml10, dbms_lob.lob_readwrite);
    dbms_lob.createtemporary(vr_des_xml11, TRUE);
    dbms_lob.open(vr_des_xml11, dbms_lob.lob_readwrite);
  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao inicializar CLOB. Rotina pc_inicializa_clob. ' || SQLERRM;
      RAISE vr_exc_saida;
  END pc_inicializa_clob;

  PROCEDURE pc_escreve_clob(pr_des_text IN VARCHAR2
                           ,pr_cod_info IN INTEGER
                           ,pr_flfechar IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CASE pr_cod_info
      WHEN 1 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml1, vr_des_txt1, pr_des_text, pr_flfechar);
      WHEN 2 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml2, vr_des_txt2, pr_des_text, pr_flfechar);
      WHEN 3 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml3, vr_des_txt3, pr_des_text, pr_flfechar);
      WHEN 4 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml4, vr_des_txt4, pr_des_text, pr_flfechar);
      WHEN 5 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml5, vr_des_txt5, pr_des_text, pr_flfechar);
      WHEN 6 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml6, vr_des_txt6, pr_des_text, pr_flfechar);
      WHEN 7 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml7, vr_des_txt7, pr_des_text, pr_flfechar);
      WHEN 8 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml8, vr_des_txt8, pr_des_text, pr_flfechar);
      WHEN 9 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml9, vr_des_txt9, pr_des_text, pr_flfechar);
      WHEN 10 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml10, vr_des_txt10, pr_des_text, pr_flfechar);
      WHEN 11 THEN
        cecred.gene0002.pc_escreve_xml(vr_des_xml11, vr_des_txt11, pr_des_text, pr_flfechar);
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao escrever no CLOB(' || pr_cod_info || ') --> ' || SQLERRM;
      RAISE vr_exc_saida;
  END pc_escreve_clob;

  PROCEDURE pc_monta_linha(pr_text    IN VARCHAR2
                          ,pr_nrposic IN INTEGER
                          ,pr_arquivo IN INTEGER) IS
    vr_linha       VARCHAR2(6000) := NULL;
    vr_tam_linha   INTEGER;
    vr_qtd_brancos INTEGER;
  BEGIN
    vr_linha := vr_tab_linha(pr_arquivo);
    vr_tam_linha := nvl(length(vr_linha), 0);
    vr_qtd_brancos := pr_nrposic - vr_tam_linha - 1;
    vr_linha := vr_linha || rpad(' ', vr_qtd_brancos, ' ') || pr_text;
    vr_tab_linha(pr_arquivo) := cecred.gene0007.fn_caract_acento(cecred.gene0007.fn_caract_acento(vr_linha,
                                                                                                  0),
                                                                 1,
                                                                 cecred.cybe0005.vr_translate_chr_de,
                                                                 cecred.cybe0005.vr_translate_chr_para);
  END pc_monta_linha;

  PROCEDURE pc_gera_carga_pagto_acordo(pr_idarquivo IN INTEGER
                                      ,pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                                      ,pr_dtmvtolt  IN cecred.crapdat.dtmvtolt%TYPE
                                      ,pr_cdcritic  OUT INTEGER
                                      ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    DECLARE
      CURSOR cr_crapret(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN cecred.crapdat.dtmvtolt%TYPE
                       ,pr_nrcnvcob IN cecred.crapret.nrcnvcob%TYPE) IS
      
        SELECT tbrecup_acordo.nracordo
              ,tbrecup_acordo_parcela.nrparcela
              ,crapcob.nrnosnum
              ,crapoco.dsocorre
              ,crapret.vlrpagto
              ,crapret.dtocorre
              ,crapcob.vltitulo
          FROM cecred.crapret
          JOIN cecred.crapcco
            ON crapcco.cdcooper = crapret.cdcooper
           AND crapcco.nrconven = crapret.nrcnvcob
          JOIN cecred.crapcob
            ON crapcob.cdcooper = crapret.cdcooper
           AND crapcob.nrcnvcob = crapret.nrcnvcob
           AND crapcob.nrdconta = crapret.nrdconta
           AND crapcob.nrdocmto = crapret.nrdocmto
           AND crapcob.nrdctabb = crapcco.nrdctabb
           AND crapcob.cdbandoc = crapcco.cddbanco
          JOIN cecred.crapoco
            ON crapoco.cdcooper = crapcob.cdcooper
           AND crapoco.cddbanco = crapcob.cdbandoc
           AND crapoco.cdocorre = crapret.cdocorre
           AND crapoco.tpocorre = 2
          JOIN cecred.tbrecup_acordo_parcela
            ON tbrecup_acordo_parcela.nrboleto = crapcob.nrdocmto
           AND tbrecup_acordo_parcela.nrconvenio = crapcob.nrcnvcob
           AND tbrecup_acordo_parcela.nrdconta_cob = crapcob.nrdconta
          JOIN cecred.tbrecup_acordo
            ON tbrecup_acordo.nracordo = tbrecup_acordo_parcela.nracordo
         WHERE crapret.cdcooper = pr_cdcooper
           AND crapret.nrcnvcob = pr_nrcnvcob
           AND crapret.dtocorre = pr_dtmvtolt
           AND crapret.cdocorre IN (6, 76);
      vr_nrcnvcob cecred.crapprm.dsvlrprm%TYPE;
    BEGIN
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      vr_nrcnvcob := cecred.gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper,
                                                      pr_nmsistem => 'CRED',
                                                      pr_cdacesso => 'ACORDO_NRCONVEN');
    
      FOR rw_crapret IN cr_crapret(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => pr_dtmvtolt,
                                   pr_nrcnvcob => vr_nrcnvcob) LOOP
        pc_monta_linha(RPAD('', 3, ' '), 1, pr_idarquivo);
        pc_monta_linha(RPAD(rw_crapret.nrnosnum, 20, ' '), 4, pr_idarquivo);
        pc_monta_linha(GENE0002.fn_mask(rw_crapret.nracordo, '9999999999999'), 24, pr_idarquivo);
        pc_monta_linha(GENE0002.fn_mask(rw_crapret.nrparcela, '99999'), 37, pr_idarquivo);
        pc_monta_linha(RPAD(rw_crapret.dsocorre, 2, ' '), 42, pr_idarquivo);
        pc_monta_linha(GENE0002.fn_mask(rw_crapret.vlrpagto * 100, '999999999999999'),
                       44,
                       pr_idarquivo);
        pc_monta_linha(cecred.gene0002.fn_mask(rw_crapret.vltitulo * 100, '999999999999999'),
                       59,
                       pr_idarquivo);
        pc_monta_linha(RPAD(TO_CHAR(rw_crapret.dtocorre, 'MMDDYYYY'), 8, ' '), 74, pr_idarquivo);
        pc_monta_linha(RPAD(TO_CHAR(rw_crapret.dtocorre, 'MMDDYYYY'), 8, ' '), 82, pr_idarquivo);
        pc_monta_linha(RPAD('Acordo:' ||
                            cecred.gene0002.fn_mask(rw_crapret.nracordo, '9999999999999') ||
                            ', Parcela:' || cecred.gene0002.fn_mask(rw_crapret.nrparcela, '99999'),
                            100,
                            ' '),
                       90,
                       pr_idarquivo);
        pc_escreve_dado(NULL, pr_idarquivo, NULL);
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina pc_crps652.pc_gera_carga_pagto_acordo. ' || SQLERRM;
    END;
  END pc_gera_carga_pagto_acordo;
BEGIN
  vr_caminho  := cecred.gene0001.fn_param_sistema('CRED', pr_cdcooper, 'CRPS652_CYBER_ENVIA');
  vr_tempoatu := to_char(SYSDATE, 'HH24MISS');

  FOR vr_idx IN 1 .. 11 LOOP
    FOR rw_work IN cr_work_arquv(pr_cdcooper    => pr_cdcooper,
                                 pr_cdprograma  => pr_cdprogra,
                                 pr_dsrelatorio => 'dados_arquivo_' || lpad(vr_idx, 2, '0'),
                                 pr_dtmvtolt    => vr_dtatual) LOOP
      pc_escreve_dado(rw_work.dsxml, vr_idx, NULL);
    END LOOP;
  END LOOP;

  pc_inicializa_clob;

  FOR idx IN 1 .. 11 LOOP
    vr_setlinha  := vr_caminho || vr_dtmvtolt || '_' || vr_tempoatu;
    vr_nmarquivo := vr_dtmvtolt || '_' || vr_tempoatu;
    CASE idx
      WHEN 1 THEN
        vr_nmarquivo := vr_nmarquivo || '_carga_in.txt';
        vr_setlinha  := vr_setlinha || '_carga_in.txt';
        vr_tparquiv  := 'completa';
      WHEN 2 THEN
        vr_nmarquivo := vr_nmarquivo || '_cadastral_in.txt';
        vr_setlinha  := vr_setlinha || '_cadastral_in.txt';
        vr_tparquiv  := 'cadastral';
      WHEN 3 THEN
        vr_nmarquivo := vr_nmarquivo || '_financeira_in.txt';
        vr_setlinha  := vr_setlinha || '_financeira_in.txt';
        vr_tparquiv  := 'financeira';
      WHEN 4 THEN
        vr_nmarquivo := vr_nmarquivo || '_gar_in.txt';
        vr_setlinha  := vr_setlinha || '_gar_in.txt';
        vr_tparquiv  := 'garantia';
      WHEN 5 THEN
        vr_nmarquivo := vr_nmarquivo || '_rel_in.txt';
        vr_setlinha  := vr_setlinha || '_rel_in.txt';
        vr_tparquiv  := 'relation';
      WHEN 6 THEN
        vr_nmarquivo := vr_nmarquivo || '_pagamentos_in.txt';
        vr_setlinha  := vr_setlinha || '_pagamentos_in.txt';
        vr_tparquiv  := 'pagamentos';
      WHEN 7 THEN
        vr_nmarquivo := vr_nmarquivo || '_baixa_in.txt';
        vr_setlinha  := vr_setlinha || '_baixa_in.txt';
        vr_tparquiv  := 'baixa';
      WHEN 8 THEN
        vr_nmarquivo := vr_nmarquivo || '_pagboleto_in.txt';
        vr_setlinha  := vr_setlinha || '_pagboleto_in.txt';
        vr_tparquiv  := 'acordo';
      WHEN 9 THEN
        vr_nmarquivo := vr_nmarquivo || '_telefone_in.txt';
        vr_setlinha  := vr_setlinha || '_telefone_in.txt';
        vr_tparquiv  := 'telefone';
      WHEN 10 THEN
        vr_nmarquivo := vr_nmarquivo || '_endereco_in.txt';
        vr_setlinha  := vr_setlinha || '_endereco_in.txt';
        vr_tparquiv  := 'endereco';
      WHEN 11 THEN
        vr_nmarquivo := vr_nmarquivo || '_score_in.txt';
        vr_setlinha  := vr_setlinha || '_score_in.txt';
        vr_tparquiv  := 'score';
    END CASE;
    vr_tab_nmclob(idx) := vr_nmarquivo;
  
    IF idx = 9 THEN
      vr_setlinha := rpad('H', 1, ' ') || RPAD('ASCOB', 8, ' ') || rpad('TELEFONE', 30, ' ') ||
                     rpad(vr_dtmvtolt, 8, ' ') || rpad('0000000000', 10, ' ') || chr(10);
    ELSIF idx = 10 THEN
      vr_setlinha := rpad('H', 1, ' ') || RPAD('ASCOB', 8, ' ') || rpad('ENDERECO', 30, ' ') ||
                     rpad(vr_dtmvtolt, 8, ' ') || rpad('0000000000', 10, ' ') || chr(10);
    ELSE
      vr_setlinha := rpad('H', 3, ' ') || RPAD('AYLLOS', 15, ' ') || rpad('CYBER', 15, ' ') ||
                     RPAD(vr_tparquiv, 10, ' ') || rpad('00000000', 8, ' ') ||
                     rpad(vr_dtmvtolt, 8, ' ') || chr(10);
    END IF;
    pc_escreve_clob(vr_setlinha, idx);
  END LOOP;

  FOR rw_crapcop IN cr_crapcop LOOP
    pc_gera_carga_pagto_acordo(pr_idarquivo => 8,
                               pr_cdcooper  => rw_crapcop.cdcooper,
                               pr_dtmvtolt  => vr_dtatual,
                               pr_cdcritic  => vr_cdcritic,
                               pr_dscritic  => vr_dscritic);
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  END LOOP;

  FOR idx IN 1 .. 11 LOOP
    CASE idx
      WHEN 1 THEN
        vr_tab_texto_Generi := vr_tab_texto1;
      WHEN 2 THEN
        vr_tab_texto_Generi := vr_tab_texto2;
      WHEN 3 THEN
        vr_tab_texto_Generi := vr_tab_texto3;
      WHEN 4 THEN
        vr_tab_texto_Generi := vr_tab_texto4;
      WHEN 5 THEN
        vr_tab_texto_Generi := vr_tab_texto5;
      WHEN 6 THEN
        vr_tab_texto_Generi := vr_tab_texto6;
      WHEN 7 THEN
        vr_tab_texto_Generi := vr_tab_texto7;
      WHEN 8 THEN
        vr_tab_texto_Generi := vr_tab_texto8;
      WHEN 9 THEN
        vr_tab_texto_Generi := vr_tab_texto9;
      WHEN 10 THEN
        vr_tab_texto_Generi := vr_tab_texto10;
      WHEN 11 THEN
        vr_tab_texto_Generi := vr_tab_texto11;
    END CASE;
    vr_tab_contlinh(idx) := vr_tab_texto_Generi.count();
  
    FOR idx2 IN 0 .. vr_tab_texto_Generi.count() - 1 LOOP
      IF idx2 != vr_tab_texto_Generi.last OR TRIM(vr_tab_texto_Generi(idx2).dsdtexto) IS NOT NULL THEN
        pc_escreve_clob(vr_tab_texto_Generi(idx2).dsdtexto || chr(10), idx);
      END IF;
    END LOOP;
    vr_tab_texto_generi.delete;
  END LOOP;

  FOR idx IN 1 .. 11 LOOP
    vr_qtdlinha := vr_tab_contlinh(idx) + 2;
    IF idx IN (9, 10) THEN
      vr_setlinha := RPad('T', 1, ' ') || rpad(vr_dtmvtolt, 8, ' ') ||
                     cecred.gene0002.fn_mask(vr_qtdlinha, '9999999999') ||
                     rpad('0000000000', 10, ' ') || chr(10);
    ELSE
      vr_setlinha := RPad('T', 3, ' ') || cecred.gene0002.fn_mask(vr_qtdlinha, '9999999') ||
                     chr(10);
    END IF;
    pc_escreve_clob(vr_setlinha, idx, TRUE);
    CASE idx
      WHEN 1 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml1,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml1);
        dbms_lob.freetemporary(vr_des_xml1);
      WHEN 2 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml2,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml2);
        dbms_lob.freetemporary(vr_des_xml2);
      WHEN 3 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml3,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml3);
        dbms_lob.freetemporary(vr_des_xml3);
      WHEN 4 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml4,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml4);
        dbms_lob.freetemporary(vr_des_xml4);
      WHEN 5 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml5,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml5);
        dbms_lob.freetemporary(vr_des_xml5);
      WHEN 6 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml6,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml6);
        dbms_lob.freetemporary(vr_des_xml6);
      WHEN 7 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml7,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml7);
        dbms_lob.freetemporary(vr_des_xml7);
      WHEN 8 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml8,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml8);
        dbms_lob.freetemporary(vr_des_xml8);
      WHEN 9 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml9,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml9);
        dbms_lob.freetemporary(vr_des_xml9);
      WHEN 10 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml10,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml10);
        dbms_lob.freetemporary(vr_des_xml10);
      WHEN 11 THEN
        cecred.gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml11,
                                             pr_caminho  => vr_caminho,
                                             pr_arquivo  => vr_tab_nmclob(idx),
                                             pr_des_erro => vr_dscritic);
        dbms_lob.close(vr_des_xml11);
        dbms_lob.freetemporary(vr_des_xml11);
    END CASE;
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  END LOOP;

  vr_comando := 'zip ' || vr_caminho || '/' || vr_dtmvtopr || '_' || vr_tempoatu ||
                '_CYBER.zip -j ' || vr_caminho || '/' || vr_dtmvtolt || '_' || vr_tempoatu ||
                '*.txt 1> /dev/null';

  cecred.gene0001.pc_OScommand(pr_typ_comando => 'S',
                               pr_des_comando => vr_comando,
                               pr_typ_saida   => vr_typ_saida,
                               pr_des_saida   => vr_dscritic);
  IF vr_typ_saida = 'ERR' THEN
    vr_dscritic := 'Nao foi possivel executar comando unix. ' || vr_comando;
    RAISE vr_exc_saida;
  END IF;

  vr_caminho_ailosmais := cecred.gene0001.fn_param_sistema('CRED',
                                                           pr_cdcooper,
                                                           'CRPS652_CYBER_ENVAILOS+');
  IF vr_caminho_ailosmais IS NOT NULL THEN
    vr_comando := 'cp ' || vr_caminho || '/' || vr_dtmvtopr || '_' || vr_tempoatu || '_CYBER.zip  ' ||
                  vr_caminho_ailosmais;
  
    cecred.gene0001.pc_OScommand(pr_typ_comando => 'S',
                                 pr_des_comando => vr_comando,
                                 pr_typ_saida   => vr_typ_saida,
                                 pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic := 'Nao foi possivel executar comando unix. ' || vr_comando;
      RAISE vr_exc_saida;
    END IF;
  END IF;

  IF vr_caminho IS NOT NULL THEN
    vr_comando := 'rm ' || vr_caminho || '/' || vr_dtmvtolt || '_' || vr_tempoatu ||
                  '*.txt 2> /dev/null';
  
    cecred.gene0001.pc_OScommand(pr_typ_comando => 'S',
                                 pr_des_comando => vr_comando,
                                 pr_typ_saida   => vr_typ_saida,
                                 pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic := 'Nao foi possivel executar comando unix. ' || vr_comando;
      RAISE vr_exc_saida;
    END IF;
  END IF;

  cecred.cybe0001.pc_importa_arquivo_cyber(pr_dtmvto   => SYSDATE,
                                           pr_des_reto => vr_typ_saida,
                                           pr_des_erro => vr_dscritic);
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
