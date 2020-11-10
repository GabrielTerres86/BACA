PL/SQL Developer Test script 3.0
94
DECLARE
  CURSOR cr_risco_inclusao IS
    SELECT  w.cdcooper
          , w.nrdconta
          , w.nrctremp
          , w.dsnivris
          , w.dsnivori
          , w.rowid
          , w.progress_recid
          , e.dtmvtolt
          , o.inrisco_inclusao
          , o.inrisco_rating
      FROM crawepr w
          ,craplcr l
          ,crapepr e
          ,tbrisco_operacoes o
     WHERE w.cdcooper = e.cdcooper
       AND w.nrdconta = e.nrdconta
       AND w.nrctremp = e.nrctremp
       AND l.cdcooper = e.cdcooper
       AND l.cdlcremp = e.cdlcremp
       AND o.cdcooper = e.cdcooper
       AND o.nrdconta = e.nrdconta
       AND o.nrctremp = e.nrctremp
       AND o.tpctrato = 90
       AND l.flgdisap = 0
       AND e.cdfinemp NOT IN (68)
       AND e.inliquid = 0
       AND e.cdcooper NOT IN (3)
       AND (TRIM(w.dsnivris) IS NULL OR TRIM(w.dsnivori) IS NULL OR w.dsnivori = '0' OR w.dsnivris = '0')
       AND (w.nrctrliq##1+w.nrctrliq##2+w.nrctrliq##3+w.nrctrliq##4+
            w.nrctrliq##5+w.nrctrliq##6+w.nrctrliq##7+w.nrctrliq##8+
            w.nrctrliq##9+w.nrctrliq##10) = 0
       AND NVL(w.nrliquid,0) = 0
       AND NVL(o.inrisco_rating,0) > 0
    ORDER BY w.cdcooper;

  vr_des_log              CLOB;
  vr_texto_completo       VARCHAR2(32600);

  vr_dsdireto             VARCHAR2(4000);
  vr_dirname              VARCHAR2(100);

  vr_typ_saida            VARCHAR2(3);
  vr_dscritic             VARCHAR2(2000);
  vr_incidente            VARCHAR2(50);

  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_rollback(pr_des_dados IN VARCHAR2,
                                pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_log, vr_texto_completo, pr_des_dados || chr(10), pr_fecha_xml);
  END;

BEGIN

  vr_incidente := 'RITM0092703';
  vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas';
  gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir ' || vr_dsdireto || '/' || vr_incidente
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

  vr_dsdireto := vr_dsdireto || '/' || vr_incidente;
  vr_dirname := sistema.obternomedirectory(vr_dsdireto);

  -- Inicializar o CLOB
  vr_texto_completo := NULL;
  vr_des_log := NULL;
  dbms_lob.createtemporary(vr_des_log, TRUE);
  dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

  FOR rw_risco_inclusao IN cr_risco_inclusao LOOP
    UPDATE crawepr
       SET dsnivris = risc0004.fn_traduz_risco(rw_risco_inclusao.inrisco_rating)
         , dsnivori = risc0004.fn_traduz_risco(rw_risco_inclusao.inrisco_rating)
     WHERE rowid = rw_risco_inclusao.rowid;

--     DBMS_OUTPUT.PUT_LINE(rw_risco_inclusao.cdcooper || ' - ' || rw_risco_inclusao.nrdconta || ' - ' || rw_risco_inclusao.nrctremp || ' - ' || risc0004.fn_traduz_risco(rw_risco_inclusao.inrisco_rating));

     pc_escreve_rollback('UPDATE crawepr w SET w.dsnivris = '''|| rw_risco_inclusao.dsnivris ||
                         ''', w.dsnivori = '''|| rw_risco_inclusao.dsnivori ||
                         ''' WHERE w.progress_recid = '''
                         || rw_risco_inclusao.progress_recid ||''';');
  END LOOP;
  COMMIT;

  pc_escreve_rollback('COMMIT;',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dirname, 'RISCOS_INCLUSAO_ROLLBACK_' || to_char(sysdate,'ddmmyyyy_hh24miss')|| '.sql', NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

END;
0
0
