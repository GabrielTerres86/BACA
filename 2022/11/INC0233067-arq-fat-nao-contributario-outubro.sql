BEGIN
  DECLARE
  TYPE typ_reg_record IS RECORD (cdcooper CECRED.tbseg_prestamista.cdcooper%TYPE
                                ,nrdconta CECRED.tbseg_prestamista.nrdconta%TYPE
                                ,cdagenci CECRED.crapass.cdagenci%TYPE
                                ,dtmvtolt CECRED.crapdat.dtmvtolt%TYPE
                                ,dtinivig CECRED.crapdat.dtmvtolt%TYPE
                                ,dtrefcob CECRED.crapdat.dtmvtolt%TYPE
                                ,nmrescop CECRED.crapcop.nmrescop%TYPE
                                ,vlenviad NUMBER(25,2)
                                ,dsregist VARCHAR2(20)
                                ,inpessoa PLS_INTEGER
                                ,tpregist CECRED.tbseg_prestamista.tpregist%TYPE
                                ,nmprimtl CECRED.tbseg_prestamista.nmprimtl%TYPE
                                ,nrcpfcgc CECRED.tbseg_prestamista.nrcpfcgc%TYPE
                                ,nrctrseg VARCHAR2(15)
                                ,nrctremp CECRED.tbseg_prestamista.nrctremp%TYPE
                                ,vlprodut CECRED.tbseg_prestamista.vlprodut%TYPE
                                ,vlsdeved CECRED.tbseg_prestamista.vlsdeved%TYPE
                                ,insitlau VARCHAR2(20)
                                ,dspessoa VARCHAR(20)
                                ,vlpreemp CECRED.crapepr.vlpreemp%TYPE
                                ,nmsegura CECRED.crapcsg.nmsegura%TYPE);

  vr_cdprogra       CONSTANT CECRED.crapprg.cdprogra%TYPE := 'JB_ARQPRST';
  vr_idprglog       CECRED.tbgen_prglog.idprglog%TYPE := 0;
  vr_regras_segpre  VARCHAR2(1);

  vr_exc_saida  EXCEPTION;
  vr_tipo_saida VARCHAR2(100);
  
  pr_cdcooper CECRED.crapcop.cdcooper%TYPE := 5;
  vr_nmarqnov  VARCHAR2(50);
  vr_dsdircop  VARCHAR2(200);
  vr_typ_said  VARCHAR2(4);
  
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(4000);
  vr_exc_erro  EXCEPTION;
  vr_dsdemail  VARCHAR2(100);
  
  vr_dstextab  CECRED.craptab.dstextab%TYPE;
  vr_ultimodiaMes DATE;
               
  vr_nrdeanos     PLS_INTEGER;
  vr_tab_nrdeanos PLS_INTEGER;
  vr_dsdidade     VARCHAR2(50);
  vr_dtmvtolt  CECRED.crapdat.dtmvtolt%type;
  vr_index         VARCHAR2(50);
  vr_destinatario_email  VARCHAR2(500);
  vr_nmsegura            VARCHAR2(200);
  pr_dscritic  VARCHAR2(1000);
  vr_nrsequen  NUMBER(5);
  vr_endereco  VARCHAR2(100);
  vr_login     VARCHAR2(100);
  vr_senha     VARCHAR2(100);
  vr_seqtran   INTEGER;
  vr_vlsdatua  NUMBER;
  vr_vlminimo  NUMBER;
  vr_vlsdeved  NUMBER := 0;
  vr_vlenviad  NUMBER;
  vr_tpregist  INTEGER;
  vr_NRPROPOSTA CECRED.tbseg_prestamista.NRPROPOSTA%TYPE;
  vr_cdapolic  CECRED.tbseg_prestamista.cdapolic%TYPE;
  vr_cdapolic_canc  CECRED.tbseg_prestamista.cdapolic%TYPE;
  vr_dtdevend  CECRED.tbseg_prestamista.dtdevend%TYPE;
  vr_dtinivig  CECRED.tbseg_prestamista.dtinivig%TYPE;
  vr_flgnvenv  BOOLEAN;
  vr_nrdmeses NUMBER;
  vr_contrcpf CECRED.tbseg_prestamista.nrcpfcgc%TYPE;

  vr_vltotenv NUMBER;
  vr_vlmaximo NUMBER;
  vr_dscorpem VARCHAR2(2000);
  vr_nmrescop CECRED.crapcop.nmrescop%TYPE;
  vr_apolice  VARCHAR2(20);
  vr_nmdircop  VARCHAR2(100);
  vr_nmarquiv  VARCHAR2(100);
  vr_linha_txt VARCHAR2(32600);
  vr_ultimoDia DATE;
  vr_pgtosegu  NUMBER;
  vr_vlprodvl  NUMBER;
  vr_dtfimvig  DATE;
  vr_dtcalcidade DATE;
  
  vr_index_815  PLS_INTEGER := 0;
  
  TYPE typ_tab IS TABLE OF typ_reg_record INDEX BY VARCHAR2(30);
  vr_crrl815     typ_tab;
  vr_tab_crrl815 typ_tab;

  TYPE typ_reg_ctrl_prst IS RECORD(nrcpfcgc CECRED.tbseg_prestamista.nrcpfcgc%TYPE,
                                   nrctremp CECRED.tbseg_prestamista.nrctremp%TYPE);

  TYPE typ_tab_ctrl_prst IS TABLE OF typ_reg_ctrl_prst INDEX BY VARCHAR2(40);
  vr_tab_ctrl_prst typ_tab_ctrl_prst ;
  
  TYPE pl_tipo_registros IS RECORD (tpregist VARCHAR2(20));

  TYPE typ_registros IS TABLE OF pl_tipo_registros INDEX BY PLS_INTEGER;

  vr_tipo_registro typ_registros;
  
  TYPE typ_reg_totais IS RECORD (vlpremio NUMBER(25,2)
                                ,slddeved NUMBER(25,2)
                                ,qtdadesao PLS_INTEGER
                                ,dsadesao VARCHAR(20));

  TYPE typ_tab_totais IS TABLE OF typ_reg_totais INDEX BY VARCHAR2(100);

  vr_totais typ_tab_totais;
      
  TYPE typ_reg_totDAT IS RECORD (vlpremio NUMBER(25,2)
                                ,slddeved NUMBER(25,2));
  
  TYPE typ_tab_sldevpac IS TABLE OF typ_reg_totDAT INDEX BY PLS_INTEGER;
  vr_tab_sldevpac typ_tab_sldevpac;

  vr_ind_arquivo utl_file.file_type;
  
  TYPE typ_tab_lancarq IS TABLE OF NUMBER(30,10) INDEX BY PLS_INTEGER;          
  vr_tab_lancarq_815 typ_tab_lancarq;
  
  vr_des_xml           CLOB;
  vr_dsadesao          VARCHAR2(100);
  vr_dir_relatorio_815 VARCHAR2(100);
  vr_vltotarq          NUMBER(30,10);
  vr_vltotdiv815       NUMBER(30,10):= 0;
  vr_flgachou          BOOLEAN := FALSE;
  
  vr_arquivo_txt         utl_file.file_type;
  vr_nom_diretorio       VARCHAR2(200);       
  vr_nmarqdat            VARCHAR2(50);
  vr_dtmvtolt_yymmdd     VARCHAR2(8);
  vr_idx_lancarq         PLS_INTEGER;
  vr_linhadet            VARCHAR(4000);
  vr_linha               VARCHAR2(32767);
  vr_ind_arquivo_backup utl_file.file_type;
  vr_nmdir    VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0233067';
  vr_nmarq    VARCHAR2(100)  := 'ROLLBACK_INC0233067_outubro.sql';
  
  CURSOR cr_crapcop(pr_cdcooper in CECRED.crapcop.cdcooper%type) IS
    SELECT c.cdcooper
          ,c.dsdircop
          ,c.nmrescop
          ,(SELECT dat.dtmvtolt
              FROM CECRED.crapdat dat 
              WHERE dat.cdcooper = c.cdcooper) dtmvtolt         
      FROM CECRED.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_craptsg(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE) IS
    SELECT nrtabela
      FROM CECRED.craptsg
     WHERE cdcooper = pr_cdcooper
       AND tpseguro = 4
       AND tpplaseg = 1
       AND cdsegura = CECRED.segu0001.busca_seguradora;

  CURSOR cr_prestamista(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE,
                        pr_vlminimo IN NUMBER,
                        pr_idadelim IN NUMBER,
                        pr_dtmvtolt IN DATE) IS
    SELECT p.idseqtra
          ,p.cdcooper
          ,p.nrdconta
          ,ass.cdagenci
          ,p.nrctrseg
          ,p.tpregist
          ,p.cdapolic
          ,p.nrcpfcgc
          ,p.nmprimtl
          ,p.dtnasctl
          ,p.cdsexotl
          ,p.dsendres
          ,p.dsdemail
          ,p.nmbairro
          ,p.nmcidade
          ,p.cdufresd
          ,p.nrcepend
          ,p.nrtelefo
          ,p.dtdevend
          ,p.dtinivig
          ,p.nrctremp
          ,p.cdcobran
          ,p.cdadmcob
          ,p.tpfrecob
          ,p.tpsegura
          ,p.cdplapro
          ,p.vlprodut
          ,p.tpcobran
          ,p.vlsdeved
          ,p.vldevatu
          ,p.dtfimvig
          ,c.inliquid
          ,c.dtmvtolt data_emp
          ,p.nrproposta
          ,p.dtdenvio
          ,lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
          ,SUM (
             CASE
               WHEN (TRUNC(p.dtinivig) >= TRUNC(SYSDATE) AND p.tpregist = 1) THEN
                 0
               WHEN (p.vlsdeved >= pr_vlminimo AND p.tpregist = 2 AND p.vldevatu > 0 AND
                    (TRUNC(Months_Between(pr_dtmvtolt,p.dtnasctl) /12,0) > pr_idadelim OR
                     TRUNC(Months_Between(pr_dtmvtolt,p.dtnasctl) /12,0) < 14))THEN
                 0
               WHEN (p.idseqtra <> (SELECT MAX(t.idseqtra)
                                      FROM CECRED.tbseg_prestamista t
                                     WHERE t.cdcooper = p.cdcooper
                                       AND t.nrdconta = p.nrdconta
                                       AND t.nrctremp = p.nrctremp
                                       AND TRUNC(t.dtinivig) < TRUNC(SYSDATE)
                                       AND t.tpregist <> 0
                                       AND t.tpcustei = 1)) THEN
                 0
               ELSE
                 p.vldevatu
               END) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf

          ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
          ,s.cdsitseg
          ,s.dtcancel
          ,p.dtrefcob
      FROM CECRED.tbseg_prestamista p, CECRED.crapepr c, CECRED.crapass ass, CECRED.crapseg s
     WHERE p.cdcooper = pr_cdcooper
       AND c.cdcooper = p.cdcooper
       AND c.nrdconta = p.nrdconta
       AND c.nrctremp = p.nrctremp
       AND ass.cdcooper = c.cdcooper
       AND ass.nrdconta = c.nrdconta
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.tpcustei = 1
       and p.nrproposta IN ('770655841644',
                            '770656164662',
                            '770658023560',
                            '770351484616',
                            '770658023560',
                            '770655822607',
                            '770655906002',
                            '770655906010',
                            '770655906029',
                            '770655757384',
                            '770655757392',
                            '770655757406',
                            '770655757414',
                            '770655756841',
                            '770656195622')
    ORDER BY nrcpfcgc ASC , dtinivig, nrctremp;
  rw_prestamista cr_prestamista%ROWTYPE;

  CURSOR cr_seg_parametro_prst(pr_cdcooper IN CECRED.tbseg_prestamista.cdcooper%TYPE
                              ,pr_tpcustei IN CECRED.tbseg_parametros_prst.tpcustei%TYPE) IS
    SELECT pp.idseqpar,
           pp.tppessoa,
           pp.cdsegura,
           pp.tpcustei,
           pp.nrapolic,
           pp.pagsegu,
           pp.seqarqu,
           pp.enderftp,
           pp.loginftp,
           pp.senhaftp
      FROM CECRED.tbseg_parametros_prst pp
     WHERE pp.cdcooper = pr_cdcooper
       AND pp.tppessoa = 1
       AND pp.cdsegura = CECRED.segu0001.busca_seguradora
       AND pp.tpcustei = pr_tpcustei;
  rw_seg_parametro_prst cr_seg_parametro_prst%ROWTYPE;

  CURSOR cr_crawepr(pr_cdcooper IN CECRED.crawepr.cdcooper%TYPE
                   ,pr_nrdconta IN CECRED.crawepr.nrdconta%TYPE
                   ,pr_nrctremp IN CECRED.crawepr.nrctremp%TYPE) IS
    SELECT e.dtmvtolt,
           (SELECT MAX(pe.dtvencto)
              FROM crappep pe
             WHERE e.cdcooper = pe.cdcooper
               AND e.nrdconta = pe.nrdconta
               AND e.nrctremp = pe.nrctremp) dtvencto
      FROM CECRED.crawepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp
       AND e.flgreneg = 1;
  rw_crawepr cr_crawepr%ROWTYPE;

  CURSOR cr_nrproposta(pr_nrproposta CECRED.tbseg_prestamista.nrproposta%TYPE) IS
    SELECT p.idseqtra
      FROM (SELECT p.nrproposta
              FROM CECRED.tbseg_prestamista p
             GROUP BY p.nrproposta
            HAVING COUNT(1) > 1) x,
           CECRED.tbseg_prestamista p
     WHERE x.nrproposta = p.nrproposta
       AND p.tpregist = 1
       AND p.nrproposta = pr_nrproposta;
  rw_nrproposta cr_nrproposta%ROWTYPE;

  CURSOR cr_crapcooperativa IS
    SELECT c.cdcooper
          ,c.nmrescop
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper IN (1,16)
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
  END pc_escreve_xml;        
        
  BEGIN
    vr_regras_segpre := CECRED.gene0001.fn_param_sistema('CRED', 0, 'UTILIZA_REGRAS_SEGPRE');
    vr_destinatario_email := CECRED.gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL');  
   
    CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                   ,pr_nmarquiv => vr_nmarq   
                                   ,pr_tipabert => 'W'
                                   ,pr_utlfileh => vr_ind_arquivo_backup
                                   ,pr_des_erro => vr_dscritic);
                                    
    IF vr_dscritic IS NOT NULL THEN         
      RAISE vr_exc_erro;
    END IF;

    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,'BEGIN');
  
    FOR rw_crapcop IN cr_crapcooperativa LOOP
      vr_seqtran := 1;
      vr_linha_txt := '';
      vr_nmrescop := rw_crapcop.nmrescop;
      pr_cdcooper := rw_crapcop.cdcooper;
       
      SELECT nmsegura INTO vr_nmsegura FROM CECRED.crapcsg WHERE cdcooper = pr_cdcooper AND cdsegura = 514; 
    
      vr_tab_crrl815.delete;
      vr_crrl815.delete;
      vr_tipo_registro.delete;
      vr_totais.delete;
      vr_tab_sldevpac.delete;
      vr_index_815 := 0;
      
      vr_tipo_registro(0).tpregist := 'ADESAO';
      vr_tipo_registro(1).tpregist := 'ADESAO';
      vr_tipo_registro(2).tpregist := 'CANCELAMENTO';
      vr_tipo_registro(3).tpregist := 'ADESAO';    
        
      cecred.pc_log_programa(pr_dstiplog   => 'I',
                             pr_cdprograma => vr_cdprogra,
                             pr_cdcooper   => pr_cdcooper,
                             pr_tpexecucao => 2,
                             pr_idprglog   => vr_idprglog);
       
      vr_dtmvtolt := rw_crapcop.dtmvtolt;   

      IF NVL(vr_regras_segpre,'N') = 'S' THEN
        OPEN cr_seg_parametro_prst(pr_cdcooper => pr_cdcooper,
                                   pr_tpcustei => 1);
          FETCH cr_seg_parametro_prst INTO rw_seg_parametro_prst;
          IF cr_seg_parametro_prst%NOTFOUND THEN
            CLOSE cr_seg_parametro_prst;
            vr_dscritic := 'Não foi possível localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';
            RAISE vr_exc_saida;
          END IF;
        CLOSE cr_seg_parametro_prst;

        vr_vlminimo := CECRED.segu0003.fn_capital_seguravel_min(pr_cdcooper => pr_cdcooper,
                                                         pr_tppessoa => rw_seg_parametro_prst.tppessoa,
                                                         pr_cdsegura => rw_seg_parametro_prst.cdsegura,
                                                         pr_tpcustei => rw_seg_parametro_prst.tpcustei,
                                                         pr_dtnasc   => TO_DATE('01/01/1990','DD/MM/RRRR'),
                                                         pr_cdcritic => vr_cdcritic,
                                                         pr_dscritic => vr_dscritic);

        vr_vlmaximo := CECRED.segu0003.fn_capital_seguravel_max(pr_cdcooper => pr_cdcooper,
                                                         pr_tppessoa => rw_seg_parametro_prst.tppessoa,
                                                         pr_cdsegura => rw_seg_parametro_prst.cdsegura,
                                                         pr_tpcustei => rw_seg_parametro_prst.tpcustei,
                                                         pr_dtnasc   => TO_DATE('01/01/1990','DD/MM/RRRR'),
                                                         pr_cdcritic => vr_cdcritic,
                                                         pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        vr_nrsequen := rw_seg_parametro_prst.seqarqu+ 1;

        vr_apolice  := rw_seg_parametro_prst.nrapolic;

        vr_pgtosegu := rw_seg_parametro_prst.pagsegu;

        vr_endereco := rw_seg_parametro_prst.enderftp;
        vr_login    := rw_seg_parametro_prst.loginftp;
        vr_senha    := rw_seg_parametro_prst.senhaftp;

        BEGIN
          UPDATE CECRED.tbseg_parametros_prst p
             SET p.seqarqu = vr_nrsequen
           WHERE p.idseqpar = rw_seg_parametro_prst.idseqpar;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        vr_dstextab := CECRED.tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'USUARI'
                                                        ,pr_cdempres => 11
                                                        ,pr_cdacesso => 'SEGPRESTAM'
                                                        ,pr_tpregist => 0);

        IF vr_dstextab IS NULL THEN
          vr_vlminimo := 0;
        ELSE
          vr_vlminimo := CECRED.gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 27, 12));
          vr_vlmaximo := CECRED.gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
        END IF;

        vr_nrsequen := to_number(substr(vr_dstextab, 139, 5)) + 1;

        vr_apolice  := SUBSTR(vr_dstextab,146,16);

        vr_pgtosegu := CECRED.gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));

        vr_endereco := CECRED.gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_ENDERECO');
        vr_login    := CECRED.gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_LOGIN');
        vr_senha    := CECRED.gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_SENHA');

        BEGIN
          UPDATE CECRED.craptab
             SET CECRED.craptab.dstextab = substr(CECRED.craptab.dstextab, 1, 138) ||
                                    CECRED.gene0002.fn_mask(vr_nrsequen, '99999') ||
                                    substr(CECRED.craptab.dstextab, 144)
           WHERE CECRED.craptab.cdcooper = pr_cdcooper
             AND CECRED.craptab.nmsistem = 'CRED'
             AND CECRED.craptab.tptabela = 'USUARI'
             AND CECRED.craptab.cdempres = 11
             AND CECRED.craptab.cdacesso = 'SEGPRESTAM'
             AND CECRED.craptab.tpregist = 0;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      vr_ultimoDia := trunc(sysdate,'MONTH')-1;

      vr_nmdircop := CECRED.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                           pr_cdcooper => pr_cdcooper);
      vr_nmarquiv := 'AILOS_'||replace(vr_nmrescop,' ','_')||'_'
                   ||REPLACE('09/2022', '/', '_') || '_' ||
                     CECRED.gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';

      CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'
                              ,pr_nmarquiv => vr_nmarquiv           
                              ,pr_tipabert => 'W'                   
                              ,pr_utlfileh => vr_ind_arquivo        
                              ,pr_des_erro => vr_dscritic);         
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      vr_contrcpf := NULL;

      OPEN cr_craptsg(pr_cdcooper => pr_cdcooper);
        FETCH cr_craptsg INTO vr_tab_nrdeanos;
        IF cr_craptsg%NOTFOUND THEN
          vr_tab_nrdeanos := 0;
        END IF;
      CLOSE cr_craptsg;

      FOR rw_prestamista IN cr_prestamista(pr_cdcooper   => pr_cdcooper,
                                           pr_vlminimo   => vr_vlminimo,
                                           pr_idadelim   => vr_tab_nrdeanos,
                                           pr_dtmvtolt   => TO_DATE(ADD_MONTHS(vr_ultimoDia,-1),'DD/MM/RRRR')) LOOP

            vr_vlsdeved := rw_prestamista.saldo_cpf;
            vr_vlsdatua := rw_prestamista.vldevatu;
            vr_tpregist := rw_prestamista.tpregist;
            vr_cdapolic := rw_prestamista.cdapolic;
            vr_NRPROPOSTA := nvl(rw_prestamista.NRPROPOSTA,0);
            vr_dtdevend := rw_prestamista.dtdevend;
            vr_dtinivig := rw_prestamista.dtinivig;
            vr_dtfimvig := rw_prestamista.dtfimvig;
            vr_flgnvenv := FALSE;

            if rw_prestamista.dtfimvig is null then
              vr_dtfimvig := rw_prestamista.dtfimctr;
            end if;
            
            if trunc(vr_dtinivig) >= trunc(sysdate) and vr_tpregist = 1 then
              continue;
            end if;

            vr_dtcalcidade:= TO_DATE(ADD_MONTHS(vr_ultimoDia,-1),'DD/MM/RRRR');

            CADA0001.pc_busca_idade(pr_dtnasctl => rw_prestamista.dtnasctl
                                   ,pr_dtmvtolt => vr_dtcalcidade
                                   ,pr_flcomple => 1
                                   ,pr_nrdeanos => vr_nrdeanos
                                   ,pr_nrdmeses => vr_nrdmeses
                                   ,pr_dsdidade => vr_dsdidade
                                   ,pr_des_erro => vr_dscritic);

            IF (vr_vlsdeved < vr_vlminimo AND vr_tpregist = 3) THEN
              vr_tpregist := 2;
            ELSE
              IF vr_vlsdeved >= vr_vlminimo AND vr_tpregist = 2 and vr_vlsdatua > 0 THEN
                if vr_nrdeanos > vr_tab_nrdeanos or
                   vr_nrdeanos < 14 then
                   if vr_nrdeanos > vr_tab_nrdeanos then
                      vr_tpregist:= 0;
                     BEGIN
                        UPDATE CECRED.tbseg_prestamista
                           SET tpregist = vr_tpregist
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = rw_prestamista.nrdconta
                           AND nrctrseg = rw_prestamista.nrctrseg
                           AND nrctremp = rw_prestamista.nrctremp
                           AND cdapolic = vr_cdapolic;
                           
                        vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                    ||'   SET tpregist =  ' || rw_prestamista.tpregist          
                                    ||' WHERE cdcooper =  ' || rw_prestamista.cdcooper                
                                    ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                    ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                    ||'   AND nrctremp =  ' || rw_prestamista.nrctremp 
                                    ||'   AND cdapolic =  ' || vr_cdapolic ||' ; ';
                                          
                        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);   
                           
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_cdcritic := 0;
                          vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                   end if;
                   continue;
                end if;
                
                IF NVL(vr_nrproposta,0) = 0 THEN
                  vr_NRPROPOSTA := nvl(rw_prestamista.NRPROPOSTA,0);
                END IF;

                vr_dtdevend := rw_prestamista.data_emp;
                vr_dtinivig := vr_ultimoDia;
                vr_tpregist := 1;

                vr_flgnvenv := TRUE;
              ELSIF vr_vlsdeved < vr_vlminimo AND vr_tpregist IN(2, 1) THEN

                IF vr_tpregist = 1 THEN
                  BEGIN
                    UPDATE CECRED.tbseg_prestamista
                       SET dtdenvio = vr_dtmvtolt
                     WHERE cdcooper = pr_cdcooper
                       AND nrdconta = rw_prestamista.nrdconta
                       AND nrctrseg = rw_prestamista.nrctrseg
                       AND nrctremp = rw_prestamista.nrctremp
                       AND cdapolic = vr_cdapolic;
                       
                   vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                    ||'   SET dtdenvio =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdenvio,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'
                                    ||' WHERE cdcooper =  ' || rw_prestamista.cdcooper                
                                    ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                    ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                    ||'   AND nrctremp =  ' || rw_prestamista.nrctremp 
                                    ||'   AND cdapolic =  ' || vr_cdapolic ||' ; ';
                                          
                    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);    
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF;

                CONTINUE;
              END IF;
            END IF;

            IF rw_prestamista.cdsitseg <> 2 THEN
              IF vr_tab_ctrl_prst.EXISTS(rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp) THEN
                vr_tpregist:= 0;
                BEGIN
                   UPDATE CECRED.tbseg_prestamista
                      SET tpregist = vr_tpregist
                    WHERE cdcooper = pr_cdcooper
                      AND nrdconta = rw_prestamista.nrdconta
                      AND nrctrseg = rw_prestamista.nrctrseg
                      AND nrctremp = rw_prestamista.nrctremp
                      AND cdapolic = vr_cdapolic;

                   UPDATE CECRED.crapseg s
                     SET s.cdsitseg = 2,
                         s.dtcancel = vr_dtmvtolt
                   WHERE s.cdcooper = pr_cdcooper
                     AND s.nrdconta = rw_prestamista.nrdconta
                     AND s.nrctrseg = rw_prestamista.nrctrseg
                     AND s.tpseguro = 4;
                     
                    vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                    ||'   SET tpregist =  ' || rw_prestamista.tpregist          
                                    ||' WHERE cdcooper =  ' || pr_cdcooper                
                                    ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                    ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                    ||'   AND nrctremp =  ' || rw_prestamista.nrctremp 
                                    ||'   AND cdapolic =  ' || vr_cdapolic ||' ; ';
                                          
                    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
                    
                    if rw_prestamista.dtcancel IS NULL THEN
                      vr_linha :=   'UPDATE CECRED.crapseg '                    
                                      ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                      ||'      ,dtcancel =  NULL'      
                                      ||' WHERE cdcooper =  ' || pr_cdcooper                
                                      ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                      ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                      ||'   AND tpseguro = 4; ' ;
                    else
                      vr_linha :=   'UPDATE CECRED.crapseg '                    
                                      ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                      ||'      ,dtcancel = to_date(' || chr(39) || trim(to_char(rw_prestamista.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'      
                                      ||' WHERE cdcooper =  ' || pr_cdcooper                
                                      ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                      ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                      ||'   AND tpseguro = 4; ' ;
                    end if;                      
                    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);   
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
                CONTINUE;
              ELSE
                vr_index := rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp;
                vr_tab_ctrl_prst(vr_index).nrcpfcgc := rw_prestamista.nrcpfcgc;
                vr_tab_ctrl_prst(vr_index).nrctremp := rw_prestamista.nrctremp;
              END IF;
            END IF;

            if vr_nrdeanos > vr_tab_nrdeanos or
               vr_nrdeanos < 14 then
               if vr_nrdeanos > vr_tab_nrdeanos then
                 if vr_tpregist = 1 then
                   vr_tpregist:= 0;
                   continue;
                 elsif vr_tpregist = 3 then
                   vr_tpregist:= 2;
                 elsif vr_tpregist = 2 then
                   IF vr_tpregist <> rw_prestamista.tpregist THEN
                     vr_tpregist := 2;
                   ELSE
                      CONTINUE;
                   END IF;
                 end if;
               elsif vr_nrdeanos < 14 then
                 vr_tpregist:= 1;
                 BEGIN
                    UPDATE CECRED.tbseg_prestamista
                       SET tpregist = vr_tpregist
                     WHERE cdcooper = pr_cdcooper
                       AND nrdconta = rw_prestamista.nrdconta
                       AND nrctrseg = rw_prestamista.nrctrseg
                       AND nrctremp = rw_prestamista.nrctremp
                       AND cdapolic = vr_cdapolic;
                       
                   vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                    ||'   SET tpregist =  ' || rw_prestamista.tpregist          
                                    ||' WHERE cdcooper =  ' || pr_cdcooper                
                                    ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                    ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                    ||'   AND nrctremp =  ' || rw_prestamista.nrctremp 
                                    ||'   AND cdapolic =  ' || vr_cdapolic ||' ; ';
                                          
                    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);    
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  continue;
               end if;
            end if;

            if (vr_vlenviad = 0 or rw_prestamista.inliquid = 1) and vr_tpregist = 3 then
              vr_tpregist := 2;
            elsif (vr_vlenviad = 0 or rw_prestamista.inliquid = 1) and rw_prestamista.tpregist in( 1,2) then
              vr_tpregist:= 0;
               BEGIN
                  UPDATE CECRED.tbseg_prestamista
                     SET tpregist = vr_tpregist
                   WHERE cdcooper = pr_cdcooper
                     AND nrdconta = rw_prestamista.nrdconta
                     AND nrctrseg = rw_prestamista.nrctrseg
                     AND nrctremp = rw_prestamista.nrctremp
                     AND cdapolic = vr_cdapolic;

                  UPDATE CECRED.crapseg s
                     SET s.cdsitseg = 2,
                         s.dtcancel = vr_dtmvtolt
                   WHERE s.cdcooper = pr_cdcooper
                     AND s.nrdconta = rw_prestamista.nrdconta
                     AND s.nrctrseg = rw_prestamista.nrctrseg
                     AND s.tpseguro = 4;
                     
                 vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                ||'   SET tpregist =  ' || rw_prestamista.tpregist          
                                ||' WHERE cdcooper =  ' || pr_cdcooper                
                                ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                ||'   AND nrctremp =  ' || rw_prestamista.nrctremp 
                                ||'   AND cdapolic =  ' || vr_cdapolic ||' ; ';
                                          
                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
                  
                  IF rw_prestamista.dtcancel IS NULL THEN
                    vr_linha :=   'UPDATE CECRED.crapseg '                    
                                    ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                    ||'      ,dtcancel =  NULL'
                                    ||' WHERE cdcooper =  ' || pr_cdcooper                
                                    ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                    ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                    ||'   AND tpseguro = 4; ' ;
                  ELSE    
                    vr_linha :=   'UPDATE CECRED.crapseg '                    
                                    ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                    ||'      ,dtcancel =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                    ||' WHERE cdcooper =  ' || pr_cdcooper                
                                    ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                    ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                    ||'   AND tpseguro = 4; ' ;
                  END IF;                          
                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);    
                     
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              continue;
            end if;

            IF vr_contrcpf IS NULL OR vr_contrcpf <> rw_prestamista.nrcpfcgc THEN
              vr_contrcpf := rw_prestamista.nrcpfcgc;
              vr_vlenviad := vr_vlsdatua;
              vr_vltotenv := vr_vlsdatua;

              IF vr_vlenviad > vr_vlmaximo AND vr_tpregist NOT IN (0,2) THEN
                vr_vlenviad := vr_vlmaximo;

                vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                                Cooperativa: ' || vr_nmrescop || '<br />
                                Conta: '       || rw_prestamista.nrdconta || '<br />
                                Nome: '        || rw_prestamista.nmprimtl || '<br />
                                Contrato Empréstimo: '|| rw_prestamista.nrctremp || '<br />
                                Proposta seguro: '    || rw_prestamista.nrctrseg || '<br />
                                Valor Empréstimo: '   || rw_prestamista.vldevatu || '<br />
                                Valor saldo devedor total: '|| vr_vlsdeved || '<br />
                                Valor Limite Máximo: ' || vr_vlmaximo;

                CECRED.gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                           pr_des_destino => vr_destinatario_email,
                                           pr_des_assunto => 'Valor limite maximo excedido ',
                                           pr_des_corpo   => vr_dscorpem,
                                           pr_des_anexo   => NULL,
                                           pr_flg_enviar  => 'S',
                                           pr_des_erro    => vr_dscritic);
                IF vr_vlenviad <= 0 THEN
                  continue;
                END IF;
              END IF;
            ELSE
              vr_vltotenv := vr_vltotenv + vr_vlsdatua;
              IF vr_vltotenv > vr_vlmaximo AND vr_tpregist NOT IN (0,2) THEN
                vr_vlenviad := vr_vlmaximo - (vr_vltotenv - vr_vlsdatua);

                vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                                Cooperativa: ' || vr_nmrescop || '<br />
                                Conta: '       || rw_prestamista.nrdconta || '<br />
                                Nome: '        || rw_prestamista.nmprimtl || '<br />
                                Contrato Empréstimo: '|| rw_prestamista.nrctremp || '<br />
                                Proposta seguro: '    || rw_prestamista.nrctrseg || '<br />
                                Valor Empréstimo: '   || rw_prestamista.vldevatu || '<br />
                                Valor saldo devedor total: '|| vr_vlsdeved || '<br />
                                Valor Limite Máximo: ' || vr_vlmaximo;

                CECRED.gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                           pr_des_destino => vr_destinatario_email,
                                           pr_des_assunto => 'Valor limite maximo excedido ',
                                           pr_des_corpo   => vr_dscorpem,
                                           pr_des_anexo   => NULL,
                                           pr_flg_enviar  => 'S',
                                           pr_des_erro    => vr_dscritic);
                IF vr_vlenviad <= 0 THEN
                  continue;
                END IF;
              ELSE
                vr_vlenviad := vr_vlsdatua;
              END IF;
            END IF;

            vr_vlprodvl := vr_vlenviad * (vr_pgtosegu/100);

            if vr_vlprodvl < 0.01 then
              vr_vlprodvl:= 0.01;
            end if;
            
            if vr_vlenviad < 0.01 then
              vr_vlenviad:= 0.01;
            end if;

            IF vr_tpregist = 1 THEN
              OPEN cr_nrproposta(pr_nrproposta => vr_NRPROPOSTA);
                FETCH cr_nrproposta INTO rw_nrproposta;
                IF cr_nrproposta%FOUND THEN
                   BEGIN
                     vr_NRPROPOSTA := CECRED.segu0003.fn_nrproposta;

                     UPDATE CECRED.tbseg_prestamista p
                        SET p.nrproposta = vr_NRPROPOSTA
                      WHERE p.idseqtra = rw_prestamista.idseqtra;

                     UPDATE CECRED.crawseg w
                        SET w.nrproposta = vr_NRPROPOSTA
                      WHERE w.cdcooper = pr_cdcooper
                        AND w.nrdconta = rw_prestamista.nrdconta
                        AND w.nrctrseg = rw_prestamista.nrctrseg
                        AND w.tpseguro = 4;
                        
                    vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                    ||'   SET nrproposta =  ' || rw_prestamista.nrproposta          
                                    ||' WHERE p.idseqtra =  ' || rw_prestamista.idseqtra ||' ; ';
                                          
                    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
                    
                    vr_linha :=   'UPDATE CECRED.crawseg '                    
                                    ||'   SET nrproposta =  ' || rw_prestamista.nrproposta       
                                    ||' WHERE cdcooper =  ' || pr_cdcooper                
                                    ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                    ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                    ||'   AND tpseguro = 4; ' ;
                                          
                    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);    
                        
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                END IF;
              CLOSE cr_nrproposta;
            END IF;

            OPEN cr_crawepr(pr_cdcooper => rw_prestamista.cdcooper,
                            pr_nrdconta => rw_prestamista.nrdconta,
                            pr_nrctremp => rw_prestamista.nrctremp);
              FETCH cr_crawepr INTO rw_crawepr;
              IF cr_crawepr%FOUND THEN
                IF rw_crawepr.dtvencto <> rw_prestamista.dtfimvig THEN
                  UPDATE CECRED.tbseg_prestamista p
                     SET p.dtinivig = rw_crawepr.dtmvtolt
                        ,p.dtfimvig = rw_crawepr.dtvencto
                   WHERE p.cdcooper = rw_prestamista.cdcooper
                     AND p.nrdconta = rw_prestamista.nrdconta
                     AND p.nrctrseg = rw_prestamista.nrctrseg;

                  UPDATE CECRED.crawseg w
                     SET w.dtinivig = rw_crawepr.dtmvtolt
                        ,w.dtfimvig = rw_crawepr.dtvencto
                   WHERE w.cdcooper = rw_prestamista.cdcooper
                     AND w.nrdconta = rw_prestamista.nrdconta
                     AND w.nrctrseg = rw_prestamista.nrctrseg;

                  UPDATE CECRED.crapseg p
                     SET p.dtinivig = rw_crawepr.dtmvtolt
                        ,p.dtfimvig = rw_crawepr.dtvencto
                   WHERE p.cdcooper = rw_prestamista.cdcooper
                     AND p.nrdconta = rw_prestamista.nrdconta
                     AND p.nrctrseg = rw_prestamista.nrctrseg;

                  vr_dtinivig := rw_crawepr.dtmvtolt;
                  vr_dtfimvig := rw_crawepr.dtvencto;
                  
                  vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                ||'   SET dtinivig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                ||'      ,dtfimvig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                ||' WHERE cdcooper =  ' || rw_prestamista.cdcooper                
                                ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg ||' ; ';
                                          
                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
                  
                  vr_linha :=   'UPDATE CECRED.crawseg '                    
                                  ||'   SET dtinivig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||'      ,dtfimvig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||' WHERE cdcooper =  ' || rw_prestamista.cdcooper                
                                  ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                  ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg || ';' ;
                                            
                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha); 
                      
                  vr_linha :=   'UPDATE CECRED.crapseg '                    
                                  ||'   SET dtinivig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||'      ,dtfimvig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||' WHERE cdcooper =  ' || rw_prestamista.cdcooper                
                                  ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                  ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg || ';' ;
                                            
                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha); 
                  
                END IF;
              END IF;
            CLOSE cr_crawepr;

            IF rw_prestamista.cdsitseg = 2 AND rw_prestamista.tpregist = 3 THEN
              vr_tpregist := 2;
            END IF;

            vr_linha_txt := '';
            IF vr_tpregist = 0 THEN
              vr_tpregist := 1;
            END IF;
            vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0);
            vr_linha_txt := vr_linha_txt || LPAD(vr_tpregist, 2, 0);
            vr_linha_txt := vr_linha_txt || LPAD(vr_apolice, 15, 0);
            vr_linha_txt := vr_linha_txt || RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' '); 
            vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' ');
            vr_linha_txt := vr_linha_txt ||
                            RPAD(UPPER(CECRED.gene0007.fn_caract_especial(rw_prestamista.nmprimtl)), 70, ' ');
            vr_linha_txt := vr_linha_txt ||
                            LPAD(to_char(rw_prestamista.dtnasctl, 'YYYY-MM-DD'), 10, 0);
            vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista.cdsexotl, 2, 0);
            vr_linha_txt := vr_linha_txt ||
                            RPAD(UPPER(CECRED.gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))), 60, ' ');
            vr_linha_txt := vr_linha_txt ||
                            RPAD(UPPER(CECRED.gene0007.fn_caract_especial(nvl(substr(rw_prestamista.nmbairro,0,30),' '))), 30, ' ');
            vr_linha_txt := vr_linha_txt ||
                            RPAD(UPPER(CECRED.gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))), 30, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdufresd), ' '),2,' ');
            vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrcepend, 'zzzzz-zz9'), 10, ' ');

            IF length(rw_prestamista.nrtelefo) = 11 THEN
              vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)99999-9999'), 15, ' ');
            ELSIF length(rw_prestamista.nrtelefo) = 10 THEN
              vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)9999-9999'), 15, ' ');
            ELSE
              vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrtelefo, '99999-9999'), 15, ' ');
            END IF;

            vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');

            vr_dsdemail := rw_prestamista.dsdemail;
            CECRED.segu0003.pc_limpa_email(vr_dsdemail);

            vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(nvl(vr_dsdemail, ' '), 50, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
            vr_linha_txt := vr_linha_txt || RPAD( vr_NRPROPOSTA, 30, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtdevend, 'YYYY-MM-DD'), 10, 0);
            vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtinivig, 'YYYY-MM-DD'), 10, 0);
            vr_linha_txt := vr_linha_txt || LPAD(' ', 2, ' ');

            vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.nrctremp), 0), 10, 0);

            vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');

            vr_linha_txt := vr_linha_txt || RPAD(LPAD(rw_prestamista.cdcooper, 4, 0), 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcobran), ' ');
            vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdadmcob), ' '), 3, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 2, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 5, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpfrecob), ' '), 2, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpsegura), ' '), 2, ' ');
            vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcooperativa), ' ');
            vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdplapro), ' ');

            vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlprodvl,'fm99999990d00'), ',', '.'), 12, 0);
            vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.tpcobran), ' '), 1, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlenviad,'fm999999999999990d00'), ',', '.'), 30, 0);
            vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_ultimoDia, 'YYYY-MM-DD'), 10, 0);
            vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtfimvig, 'YYYY-MM-DD'), 10, 0);

            vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 89, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 15, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
            vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
            vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');

            vr_linha_txt := vr_linha_txt || chr(13);

            vr_index_815 := vr_index_815 + 1;
            vr_tab_crrl815(vr_index_815) := NULL;
            vr_tab_crrl815(vr_index_815).dtmvtolt := vr_dtmvtolt;
            vr_tab_crrl815(vr_index_815).nmrescop := vr_nmrescop;
            vr_tab_crrl815(vr_index_815).nmprimtl := rw_prestamista.nmprimtl;
            vr_tab_crrl815(vr_index_815).nrdconta := rw_prestamista.nrdconta;
            vr_tab_crrl815(vr_index_815).cdagenci := rw_prestamista.cdagenci;
            vr_tab_crrl815(vr_index_815).nrctrseg := vr_NRPROPOSTA;
            vr_tab_crrl815(vr_index_815).nrctremp := rw_prestamista.nrctremp;
            vr_tab_crrl815(vr_index_815).nrcpfcgc := rw_prestamista.nrcpfcgc;
            vr_tab_crrl815(vr_index_815).vlprodut := vr_vlprodvl;
            vr_tab_crrl815(vr_index_815).vlenviad := vr_vlenviad;
            vr_tab_crrl815(vr_index_815).vlsdeved := vr_vlsdeved;
            vr_tab_crrl815(vr_index_815).dtinivig := vr_dtinivig;
            vr_tab_crrl815(vr_index_815).dtrefcob := vr_ultimoDia;
            vr_tab_crrl815(vr_index_815).tpregist := vr_tpregist;
            vr_tab_crrl815(vr_index_815).dsregist := vr_tipo_registro(vr_tpregist).tpregist;

            IF vr_tpregist = 1 THEN
              vr_tpregist := 3;
            END IF;

            IF vr_flgnvenv THEN
              BEGIN
                UPDATE CECRED.tbseg_prestamista
                   SET tpregist = vr_tpregist
                      ,dtdenvio = vr_dtmvtolt
                      ,vlprodut = vr_vlprodvl
                      ,dtrefcob = vr_ultimoDia
                      ,dtdevend = vr_dtdevend
                      ,dtfimvig = vr_dtfimvig
                 WHERE cdcooper = pr_cdcooper
                   AND nrdconta = rw_prestamista.nrdconta
                   AND nrctrseg = rw_prestamista.nrctrseg
                   AND nrctremp = rw_prestamista.nrctremp
                   AND cdapolic = vr_cdapolic_canc;
                   
                vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                ||'   SET tpregist =  ' || rw_prestamista.tpregist
                                ||'      ,dtdenvio =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdenvio,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                ||'      ,vlprodut =  ' || REPLACE(TO_CHAR(rw_prestamista.vlprodut ,'fm999999999999990d00'), ',', '.')
                                ||'      ,dtrefcob =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtrefcob,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                ||'      ,dtdevend =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdevend,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                ||'      ,dtfimvig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                ||' WHERE cdcooper =  ' || rw_prestamista.cdcooper                
                                ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg
                                ||'   AND nrctremp =  ' || rw_prestamista.nrctremp
                                ||'   AND cdapolic =  ' || vr_cdapolic_canc || ';';
                                          
                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
              
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
              vr_tpregist := 0;
            END IF;

            BEGIN
              UPDATE CECRED.tbseg_prestamista
                 SET tpregist = vr_tpregist
                    ,dtdenvio = vr_dtmvtolt
                    ,vlprodut = vr_vlprodvl
                    ,dtrefcob = vr_ultimoDia
                    ,dtdevend = vr_dtdevend
                    ,dtfimvig = vr_dtfimvig
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = rw_prestamista.nrdconta
                 AND nrctrseg = rw_prestamista.nrctrseg
                 AND nrctremp = rw_prestamista.nrctremp
                 AND cdapolic = vr_cdapolic;
                 
              vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                            ||'   SET tpregist =  ' || rw_prestamista.tpregist
                            ||'      ,dtdenvio =   to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdenvio,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                            ||'      ,vlprodut =  ' || REPLACE(TO_CHAR(rw_prestamista.vlprodut ,'fm999999999999990d00'), ',', '.')
                            ||'      ,dtrefcob =   to_date(' || chr(39) || trim(to_char(rw_prestamista.dtrefcob,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                            ||'      ,dtdevend =   to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdevend,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                            ||'      ,dtfimvig =   to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                            ||' WHERE cdcooper =  ' || rw_prestamista.cdcooper                
                            ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                            ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg
                            ||'   AND nrctremp =  ' || rw_prestamista.nrctremp
                            ||'   AND cdapolic =  ' || vr_cdapolic || ';';
                                          
                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);   
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            IF vr_tpregist = 2 THEN
              BEGIN
                UPDATE CECRED.crapseg c
                   SET c.cdsitseg = vr_tpregist,
                       c.dtcancel = vr_dtmvtolt
                 WHERE c.cdcooper = rw_prestamista.cdcooper
                   AND c.nrdconta = rw_prestamista.nrdconta
                   AND c.nrctrseg = rw_prestamista.nrctrseg
                   AND c.tpseguro = 4;

                UPDATE CECRED.tbseg_prestamista
                   SET tpregist = 0
                 WHERE cdcooper = pr_cdcooper
                   AND nrdconta = rw_prestamista.nrdconta
                   AND nrctrseg = rw_prestamista.nrctrseg
                   AND nrctremp = rw_prestamista.nrctremp
                   AND cdapolic = vr_cdapolic;
                   
                vr_linha :=   'UPDATE CECRED.tbseg_prestamista '                    
                                ||'   SET tpregist =  ' || rw_prestamista.tpregist          
                                ||' WHERE cdcooper =  ' || pr_cdcooper                
                                ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                ||'   AND nrctremp =  ' || rw_prestamista.nrctremp 
                                ||'   AND cdapolic =  ' || vr_cdapolic ||' ; ';
                                          
                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
                
                IF rw_prestamista.dtcancel IS NULL THEN
                    vr_linha :=   'UPDATE CECRED.crapseg '                    
                                  ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                  ||'      ,dtcancel =  NULL'
                                  ||' WHERE cdcooper =  ' || pr_cdcooper                
                                  ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                  ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                  ||'   AND tpseguro = 4; ' ;
                ELSE
                  vr_linha :=   'UPDATE CECRED.crapseg '                    
                                  ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                  ||'      ,dtcancel =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||' WHERE cdcooper =  ' || pr_cdcooper                
                                  ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                  ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                  ||'   AND tpseguro = 4; ' ;
                END IF;                            
                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);    
                   
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
            ELSIF vr_tpregist = 3 THEN
              BEGIN
                UPDATE CECRED.crapseg c
                   SET c.cdsitseg = 1,
                       c.dtcancel = NULL,
                       c.dtfimvig = rw_prestamista.dtfimvig
                 WHERE c.cdcooper = rw_prestamista.cdcooper
                   AND c.nrdconta = rw_prestamista.nrdconta
                   AND c.nrctrseg = rw_prestamista.nrctrseg
                   AND c.tpseguro = 4
                   AND c.cdsitseg <> 1;
                   
                IF  rw_prestamista.dtcancel IS NULL THEN  
                  vr_linha :=   'UPDATE CECRED.crapseg '                    
                                  ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                  ||'      ,dtcancel =  NULL'
                                  ||'      ,dtfimvig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||' WHERE cdcooper =  ' || pr_cdcooper                
                                  ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                  ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                  ||'   AND tpseguro = 4' 
                                  ||'   AND cdsitseg <> 1;';
                ELSE
                  vr_linha :=   'UPDATE CECRED.crapseg '                    
                                  ||'   SET cdsitseg =  ' || rw_prestamista.cdsitseg 
                                  ||'      ,dtcancel =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||'      ,dtfimvig =  to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')'       
                                  ||' WHERE cdcooper =  ' || pr_cdcooper                
                                  ||'   AND nrdconta =  ' || rw_prestamista.nrdconta 
                                  ||'   AND nrctrseg =  ' || rw_prestamista.nrctrseg 
                                  ||'   AND tpseguro = 4' 
                                  ||'   AND cdsitseg <> 1;';
                END IF;                            
                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);    
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;

            CECRED.gene0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);

            vr_seqtran := vr_seqtran + 1;
          END LOOP;
          
          vr_tab_ctrl_prst.delete;
          vr_crrl815 := vr_tab_crrl815;

          CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

          CECRED.gene0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                      ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv
                                      ,pr_nmarqenv => vr_nmarquiv
                                      ,pr_des_erro => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          CECRED.segu0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarquiv,
                                             pr_idoperac => 'E',
                                             pr_nmdireto => vr_nmdircop || '/arq/',
                                             pr_idenvseg => 'S',
                                             pr_ftp_site => vr_endereco,
                                             pr_ftp_user => vr_login,
                                             pr_ftp_pass => vr_senha,
                                             pr_ftp_path => 'Envio',
                                             pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || pr_cdcooper || ' - ' || vr_dscritic;
            CECRED.btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' -> '
                                                          || 'Processamento de ftp retornou erro: '||vr_dscritic);
          END IF;

          if trim(vr_nmarquiv) is not null then
             CECRED.gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquiv||' '||vr_nmdircop||'/salvar',
                                         pr_typ_saida   => vr_tipo_saida,
                                         pr_des_saida   => vr_dscritic);
          end if;

          IF vr_tipo_saida = 'ERR' THEN
            vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || pr_cdcooper || ' - ' ||vr_dscritic;
            CECRED.btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' -> '
                                                          || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
          END IF;

          cecred.pc_log_programa(pr_dstiplog   => 'F',
                                 pr_cdprograma => vr_cdprogra,
                                 pr_cdcooper   => pr_cdcooper,
                                 pr_tpexecucao => 2,
                                 pr_idprglog   => vr_idprglog);
            
          vr_totais.delete;
        
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          vr_vltotarq := 0;
          vr_tab_sldevpac.delete;

          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl815><dados>');  
          vr_index_815 :=  vr_crrl815.first;          
          WHILE vr_index_815 IS NOT NULL LOOP
            IF NOT vr_crrl815(vr_index_815).vlenviad IS NULL THEN
              vr_vlenviad := vr_crrl815(vr_index_815).vlenviad;
            ELSE 
              vr_vlenviad := 0;
            END IF;
            
            pc_escreve_xml(
                  '<registro>'||
                           '<dtmvtolt>' || TO_CHAR(vr_crrl815(vr_index_815).dtmvtolt , 'DD/MM/RRRR') || '</dtmvtolt>' ||
                           '<nmrescop>' || vr_crrl815(vr_index_815).nmrescop || '</nmrescop>' ||
                           '<nmprimtl>' || vr_crrl815(vr_index_815).nmprimtl || '</nmprimtl>' ||
                           '<nrdconta>' || TRIM(CECRED.gene0002.fn_mask_conta(vr_crrl815(vr_index_815).nrdconta)) || '</nrdconta>' ||
                           '<cdagenci>' ||                     TO_CHAR(vr_crrl815(vr_index_815).cdagenci)  || '</cdagenci>' ||                           
                           '<nrctrseg>' || TRIM(                       vr_crrl815(vr_index_815).nrctrseg) || '</nrctrseg>' ||
                           '<nrctremp>' || TRIM(CECRED.gene0002.fn_mask_contrato(vr_crrl815(vr_index_815).nrctremp)) || '</nrctremp>' ||
                           '<nrcpfcgc>' || TRIM(CECRED.gene0002.fn_mask_cpf_cnpj(vr_crrl815(vr_index_815).nrcpfcgc, 1)) || '</nrcpfcgc>' ||
                           '<vlprodut>' || to_char(vr_crrl815(vr_index_815).vlprodut, 'FM99G999G999G999G999G999G999G990D00') || '</vlprodut>' ||
                           '<vlenviad>' || to_char(vr_vlenviad, 'FM99G999G999G999G999G999G999G990D00') || '</vlenviad>' ||
                           '<vlsdeved>' || to_char(vr_crrl815(vr_index_815).vlsdeved, 'FM99G999G999G999G999G999G999G990D00') || '</vlsdeved>' ||
                           '<dtrefcob>' || NVL(TO_CHAR( vr_crrl815(vr_index_815).dtrefcob, 'DD/MM/RRRR') , '') || '</dtrefcob>' ||
                           '<dsregist>' ||              vr_crrl815(vr_index_815).dsregist || '</dsregist>' ||
                           '<dtinivig>' || NVL(TO_CHAR( vr_crrl815(vr_index_815).dtinivig , 'DD/MM/RRRR') , '') || '</dtinivig>'
                   ||'</registro>');
           
            vr_dsadesao := vr_crrl815(vr_index_815).dsregist;
      
            IF NOT vr_tab_sldevpac.EXISTS(vr_crrl815(vr_index_815).cdagenci) THEN
               vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved := 0;
               vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio := 0;
            END IF;
            
            vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved := vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved 
                                                                      + vr_vlenviad;
            vr_vltotarq := vr_vltotarq + vr_vlenviad;
      
            IF vr_totais.EXISTS(vr_dsadesao) = FALSE THEN
              vr_totais(vr_dsadesao).qtdadesao := 1;
              vr_totais(vr_dsadesao).slddeved := vr_vlenviad;
              vr_totais(vr_dsadesao).vlpremio := vr_crrl815(vr_index_815).vlprodut;
              vr_totais(vr_dsadesao).dsadesao := vr_dsadesao;
            ELSE
              vr_totais(vr_dsadesao).slddeved := vr_totais(vr_dsadesao).slddeved +
                                                         vr_vlenviad;
              vr_totais(vr_dsadesao).vlpremio := vr_totais(vr_dsadesao).vlpremio +
                                                         vr_crrl815(vr_index_815).vlprodut;
              vr_totais(vr_dsadesao).qtdadesao := vr_totais(vr_dsadesao).qtdadesao + 1;
            END IF;
            
            vr_vltotdiv815 := vr_vltotdiv815 + vr_crrl815(vr_index_815).vlprodut;
            vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio := vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio 
                                                                         + vr_crrl815(vr_index_815).vlprodut;
                      
            vr_index_815 := vr_crrl815.next(vr_index_815);
            vr_flgachou := TRUE;
          END LOOP;
          pc_escreve_xml('</dados>');

          pc_escreve_xml('<totais>');        
          vr_index := vr_totais.first;
          WHILE vr_index IS NOT NULL LOOP
            IF vr_totais.EXISTS(vr_index) = TRUE THEN                  
              pc_escreve_xml('<registro>'||
                               '<dsadesao>' ||         NVL(vr_totais(vr_index).dsadesao, ' ') || '</dsadesao>' ||
                               '<vlpremio>' || to_char(NVL(vr_totais(vr_index).vlpremio, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</vlpremio>' ||
                               '<slddeved>' || to_char(NVL(vr_totais(vr_index).slddeved, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</slddeved>' ||
                               '<qtdadesao>' ||        NVL(vr_totais(vr_index).qtdadesao, 0) || '</qtdadesao>'||
                             '</registro>');
     
            END IF;
            vr_index := vr_totais.next(vr_index);
          END LOOP;
     
          pc_escreve_xml(  '</totais>');

          IF vr_flgachou THEN          
            vr_tab_lancarq_815.delete;
            
            pc_escreve_xml(  '<totpac vltotdiv="'||to_char(vr_vltotarq,'fm999g999g999g990d00')||   '">');
            
            IF vr_tab_sldevpac.COUNT > 0 THEN
              FOR vr_cdagenci IN vr_tab_sldevpac.FIRST..vr_tab_sldevpac.LAST LOOP
                IF vr_tab_sldevpac.EXISTS(vr_cdagenci) THEN
                     pc_escreve_xml('<registro>'
                                   ||  '<cdagenci>'||LPAD(vr_cdagenci,3,' ')||'</cdagenci>'
                                   ||  '<sldevpac>'||to_char(vr_tab_sldevpac(vr_cdagenci).slddeved,'fm999g999g999g990d00')||'</sldevpac>'
                                 ||'</registro>');  
                  vr_tab_lancarq_815(vr_cdagenci) := vr_tab_sldevpac(vr_cdagenci).vlpremio;
     
                END IF;
              END LOOP;
              pc_escreve_xml(  '</totpac>');          
            END IF;          
          END IF;        
          pc_escreve_xml('</crrl815>');
          
          vr_dir_relatorio_815 := CECRED.gene0001.fn_diretorio('C', rw_crapcop.cdcooper, 'rl') || '/crrl815_outubro.lst';
          
          IF vr_crrl815.EXISTS(1) = TRUE THEN
            CECRED.gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper
                                       ,pr_cdprogra  => vr_cdprogra
                                       ,pr_dtmvtolt  => rw_crapcop.dtmvtolt
                                       ,pr_dsxml     => vr_des_xml 
                                       ,pr_dsxmlnode => '/crrl815'
                                       ,pr_dsjasper  => 'crrl815.jasper'
                                       ,pr_dsparams  => NULL
                                       ,pr_dsarqsaid => vr_dir_relatorio_815
                                       ,pr_cdrelato  => 815
                                       ,pr_flg_gerar => 'S'
                                       ,pr_qtcoluna  => 234
                                       ,pr_sqcabrel  => 1
                                       ,pr_nmformul  => '234col'
                                       ,pr_flg_impri => 'S'
                                       ,pr_nrcopias  => 1
                                       ,pr_nrvergrl  => 1
                                       ,pr_des_erro  => pr_dscritic);
     
            IF pr_dscritic IS NOT NULL THEN            
              RAISE vr_exc_erro;
            END IF;
          END IF;
   
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
          
          vr_nom_diretorio := CECRED.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                    pr_cdcooper => pr_cdcooper,
                                                    pr_nmsubdir => 'contab');
          
         
          vr_dsdircop := CECRED.gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 0
                                                  ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
          
          vr_ultimodiaMes := trunc(SYSDATE,'MONTH') -1 ;
          
          vr_dtmvtolt_yymmdd := to_char(vr_ultimodiaMes, 'yyyymmdd');
          vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_PRESTAMISTA.txt';
          vr_linhadet        := '';
          
          CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,
                                   pr_nmarquiv => vr_nmarqdat,    
                                   pr_tipabert => 'W',            
                                   pr_utlfileh => vr_arquivo_txt, 
                                   pr_des_erro => vr_dscritic);   
         
          IF vr_dscritic IS NOT NULL THEN
             vr_cdcritic := 0;
             RAISE vr_exc_erro;
          END IF;        
       
          IF vr_tab_lancarq_815.count > 0 THEN
             vr_idx_lancarq := vr_tab_lancarq_815.first;
             
             vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                                 TRIM(to_char(vr_ultimodiaMes,'ddmmyy'))||
                                 ',8304,4963,'||
                                 TRIM(to_char(vr_vltotdiv815,'FM99999999999999990D90', 'NLS_NUMERIC_CHARACTERS = ''.,'''))||
                                 ',5210,'||
                                 '"VLR. REF. PROVISAO P/ PAGAMENTO DE SEGURO PRESTAMISTA - '|| vr_nmsegura ||' - REF. ' 
                                 || to_CHAR(vr_ultimodiaMes,'MM/YYYY') ||'"';
       
             CECRED.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
             
             WHILE vr_idx_lancarq IS NOT NULL LOOP                      
                vr_linhadet := lpad(vr_idx_lancarq,3,0) || ',' || 
                    TRIM(to_char(round(vr_tab_lancarq_815(vr_idx_lancarq),2),'FM99999999999999990D90', 'NLS_NUMERIC_CHARACTERS = ''.,''')); 
                    
                CECRED.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);                        
                vr_idx_lancarq := vr_tab_lancarq_815.next(vr_idx_lancarq);             
             END LOOP;           
          END IF;
            
          CECRED.gene0001.pc_fecha_arquivo(vr_arquivo_txt);      
          vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_PRESTAMISTA.txt';

          IF TRIM(vr_nmarqdat) IS NOT NULL THEN              
            CECRED.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||
                         vr_nom_diretorio||'/'||vr_nmarqdat||' > '||
                         vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                          pr_typ_saida   => vr_typ_said,
                                          pr_des_saida   => vr_dscritic);
          END IF;
                    
          IF vr_typ_said = 'ERR' THEN
             vr_cdcritic := 1040;
             CECRED.gene0001.pc_print(CECRED.gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
          END IF;
        COMMIT;
      
      END LOOP;
      
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,' COMMIT;');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,' END; ');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,'/ ');
      CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo_backup );
      
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := CECRED.gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          ROLLBACK;
          cecred.pc_log_programa(pr_dstiplog           => 'E',
                                 pr_cdprograma         => vr_cdprogra,
                                 pr_cdcooper           => pr_cdcooper,
                                 pr_tpexecucao         => 2,
                                 pr_tpocorrencia       => 0,
                                 pr_cdcriticidade      => 2,
                                 pr_dsmensagem         => vr_dscritic,
                                 pr_flgsucesso         => 0,
                                 pr_nmarqlog           => NULL,
                                 pr_idprglog           => vr_idprglog);

          CECRED.gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic);
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          pr_dscritic := vr_dscritic;
          ROLLBACK;
          cecred.pc_log_programa(pr_dstiplog           => 'E',
                                 pr_cdprograma         => vr_cdprogra,
                                 pr_cdcooper           => pr_cdcooper,
                                 pr_tpexecucao         => 2,
                                 pr_tpocorrencia       => 0,
                                 pr_cdcriticidade      => 2,
                                 pr_dsmensagem         => vr_dscritic,
                                 pr_flgsucesso         => 0,
                                 pr_nmarqlog           => NULL,
                                 pr_destinatario_email => vr_destinatario_email,
                                 pr_idprglog           => vr_idprglog);
                                 
          CECRED.gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic);
    
    END;  