DECLARE

  vr_exc_saida           EXCEPTION;
  vr_tipo_saida          VARCHAR2(100);
  vr_cdprogra            CONSTANT CECRED.crapprg.cdprogra%TYPE := 'JB_ARQPRST';
  vr_idprglog            CECRED.tbgen_prglog.idprglog%TYPE := 0;
  vr_cdcritic            PLS_INTEGER;
  vr_dscritic            VARCHAR2(20000);
  vr_exc_erro            EXCEPTION;
  vr_tab_nrdeanos        PLS_INTEGER;
  vr_nrdeanos            PLS_INTEGER;
  vr_dsdidade            VARCHAR2(50);
  vr_dtmvtolt            CECRED.crapdat.dtmvtolt%type;
  vr_index               VARCHAR2(50);
  vr_vlenviad            NUMBER;
  vr_vlprodvl            NUMBER;
  vr_vltotenv            NUMBER;
  vr_dsdemail            VARCHAR2(200);
  vr_destinatario_email  VARCHAR2(500);
  vr_ultimodia           DATE;
  vr_dscorpem            VARCHAR2(2000);
  vr_nmdircop            VARCHAR2(4000); 
  vr_nmarquiv            VARCHAR2(100);
  vr_ind_arquivo         utl_file.file_type;
  vr_nrsequen            NUMBER(5);
  vr_apolice             VARCHAR2(20);
  vr_pgtosegu            NUMBER;
  vr_endereco            VARCHAR2(100);
  vr_login               VARCHAR2(100);
  vr_senha               VARCHAR2(100);
  vr_seqtran             INTEGER;
  vr_nmrescop            cecred.crapcop.nmrescop%TYPE;
  vr_vlsdatua            NUMBER;
  vr_vlminimo            NUMBER;
  vr_vlmaximo            NUMBER;
  vr_vlsdeved            NUMBER := 0;
  vr_tpregist            INTEGER;
  vr_nrproposta          CECRED.tbseg_prestamista.NRPROPOSTA%TYPE;
  vr_cdapolic            CECRED.tbseg_prestamista.cdapolic%TYPE;
  vr_dtdevend            CECRED.tbseg_prestamista.dtdevend%TYPE;
  vr_dtinivig            CECRED.tbseg_prestamista.dtinivig%TYPE;
  vr_dtcalcidade         DATE;
  vr_dtfimvig            CECRED.tbseg_prestamista.DTFIMVIG%TYPE;
  vr_flgnvenv            BOOLEAN;
  vr_nrdmeses            NUMBER;
  vr_contrcpf            CECRED.tbseg_prestamista.nrcpfcgc%TYPE;
  vr_nmsegura            VARCHAR2(200);
  vr_des_xml             CLOB;
  vr_vltotdiv815         NUMBER(30,10):= 0;
  TYPE typ_tab_lancarq IS TABLE OF NUMBER(30,10) INDEX BY PLS_INTEGER;
  vr_tab_lancarq_815     typ_tab_lancarq;
  vr_nom_diretorio       VARCHAR2(200);
  vr_dsdircop            VARCHAR2(200);
  vr_nmarqdat            VARCHAR2(50);
  vr_dtmvtolt_yymmdd     VARCHAR2(8);
  vr_idx_lancarq         PLS_INTEGER;
  vr_linhadet            VARCHAR(4000);
  vr_typ_said            VARCHAR2(4);
  vr_ultimodiaMes        DATE;
  vr_arquivo_txt         utl_file.file_type;
  vr_nmarqnov            VARCHAR2(50);
  vr_nmdir               VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0262220';
  vr_nmarq               VARCHAR2(100);
  vr_ind_arq             utl_file.file_type;
  vr_linha               VARCHAR2(32767);
  vr_cdsitseg            NUMBER;
  vr_linha_txt           VARCHAR2(32600);
  
  TYPE typ_reg_ctrl_prst IS RECORD(nrcpfcgc CECRED.tbseg_prestamista.nrcpfcgc%TYPE,
                                   nrctremp CECRED.tbseg_prestamista.nrctremp%TYPE);  

  --Definicao dos tipos de tabelas
  TYPE typ_tab_ctrl_prst IS TABLE OF typ_reg_ctrl_prst INDEX BY VARCHAR2(40);
  vr_tab_ctrl_prst typ_tab_ctrl_prst ;
  
  TYPE typ_reg_record IS RECORD  (cdcooper CECRED.tbseg_prestamista.cdcooper%TYPE
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
  
  TYPE typ_tab IS TABLE OF typ_reg_record INDEX BY VARCHAR2(30);
  vr_tab_crrl815 typ_tab;
  vr_crrl815     typ_tab;
  
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
    
  -- Tabela para armazenar os saldo devedores por PAC:
  TYPE typ_tab_sldevpac IS TABLE OF typ_reg_totDAT INDEX BY PLS_INTEGER; --> Número do PAC sera a chave
  vr_tab_sldevpac typ_tab_sldevpac;

  CURSOR cr_crapcop IS
      SELECT c.cdcooper
            ,c.dsdircop
            ,c.nmrescop
            ,(SELECT dat.dtmvtolt
                FROM CECRED.crapdat dat 
                WHERE dat.cdcooper = c.cdcooper) dtmvtolt         
        FROM CECRED.crapcop c
       WHERE c.flgativo = 1  -- Somente ativas
         AND c.cdcooper = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
    
  -- Busca da idade limite
  CURSOR cr_craptsg(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT nrtabela
      FROM CECRED.craptsg
     WHERE cdcooper = pr_cdcooper
       AND tpseguro = 4
       AND tpplaseg = 1
       AND cdsegura = CECRED.SEGU0001.busca_seguradora; -- CODITO DA SEGURADORA  

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
          ,(Case When c.dtliquid <= '01/09/2022' and c.inliquid = 1 then 1 else 0 end) inliquid
          ,c.dtmvtolt data_emp
          ,p.nrproposta
          ,lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
          ,SUM (p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf
          ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
          ,s.cdsitseg
          ,p.dtdenvio
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
       and p.nrdconta = 9417389
       and p.nrctremp IN (2047137,2506563)
       and p.tpregist = 1
       AND p.tpcustei = 1
     ORDER BY p.nrcpfcgc ASC , p.dtinivig, p.nrctremp;
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
       AND pp.cdsegura = CECRED.SEGU0001.busca_seguradora
       AND pp.tpcustei = pr_tpcustei;
  rw_seg_parametro_prst cr_seg_parametro_prst%ROWTYPE;

  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
  vr_dscritic  CECRED.crapcri.dscritic%TYPE;
  vr_typ_saida VARCHAR2(3);
  vr_des_saida VARCHAR2(1000);
  vr_exc_erro  EXCEPTION;
  BEGIN
    IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                           pr_nmdireto ||
                                                           ' 1> /dev/null',
                                  pr_typ_saida   => vr_typ_saida,
                                  pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                       vr_des_saida;
        RAISE vr_exc_erro;
      END IF;

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                           pr_nmdireto ||
                                                           ' 1> /dev/null',
                                  pr_typ_saida   => vr_typ_saida,
                                  pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                       vr_des_saida;
        RAISE vr_exc_erro;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
  END;

  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
  END pc_escreve_xml;

  PROCEDURE pc_gera_proposta(pr_cdcooper   IN CECRED.tbseg_prestamista.cdcooper%TYPE
                            ,pr_nrdconta   IN CECRED.tbseg_prestamista.nrdconta%TYPE
                            ,pr_nrctrseg   IN CECRED.tbseg_prestamista.nrctrseg%TYPE
                            ,pr_cdapolic   IN CECRED.tbseg_prestamista.cdapolic%TYPE
                            ,pr_nrproposta IN OUT VARCHAR2) IS
      vr_exc_saida  EXCEPTION;
    BEGIN
      vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.nrproposta = ''' || pr_nrproposta || ''''
                      || '  WHERE p.cdapolic = ' || pr_cdapolic || ';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

      vr_linha :=    ' UPDATE CECRED.crawseg p   '
                      || '    SET p.nrproposta = ''' || pr_nrproposta || ''''
                      || '  WHERE p.cdcooper = ' || pr_cdcooper
                      || '    AND p.nrdconta = ' || pr_nrdconta
                      || '    AND p.nrctrseg = ' || pr_nrctrseg ||';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

      pr_nrproposta := CECRED.SEGU0003.FN_NRPROPOSTA(1);

      BEGIN
        UPDATE CECRED.tbseg_prestamista g
           SET g.nrproposta = pr_nrproposta
         WHERE g.cdapolic = pr_cdapolic;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao gravar numero de proposta pc_gera_proposta 1: ' || pr_nrproposta || ' - '|| SQLERRM;
          RAISE vr_exc_saida;
      END;

      BEGIN
        UPDATE CECRED.crawseg g
           SET g.nrproposta = pr_nrproposta
         WHERE g.cdcooper = pr_cdcooper
           AND g.nrdconta = pr_nrdconta
           AND g.nrctrseg = pr_nrctrseg;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao gravar numero de proposta pc_gera_proposta 2: ' || pr_nrproposta ||' - '|| SQLERRM;
          RAISE vr_exc_saida;
      END;

      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           vr_dscritic := CECRED.gene0001.fn_busca_critica(vr_cdcritic);
         END IF;

         vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

         ROLLBACK;
      WHEN OTHERS THEN
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           vr_dscritic := CECRED.gene0001.fn_busca_critica(vr_cdcritic);
         END IF;

         vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

         ROLLBACK;
  END pc_gera_proposta;

  BEGIN
  
    OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
   CLOSE cr_crapcop;
  
    pc_valida_direto(pr_nmdireto => vr_nmdir,
                     pr_dscritic => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    vr_destinatario_email := CECRED.gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL');

    vr_nmarq  := rw_crapcop.nmrescop || '_ROLLBACK_INC0262220.sql';
      
      CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                     ,pr_nmarquiv => vr_nmarq
                                     ,pr_tipabert => 'W'
                                     ,pr_utlfileh => vr_ind_arq
                                     ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      SELECT nmsegura INTO vr_nmsegura FROM CECRED.crapcsg WHERE cdcooper = rw_crapcop.cdcooper AND cdsegura = 514;

      vr_tab_crrl815.delete;
      vr_crrl815.delete;
      vr_tipo_registro.delete;
      vr_totais.delete;
      vr_tab_sldevpac.delete;

      vr_tipo_registro(0).tpregist := 'NOT FOUND';
      vr_tipo_registro(1).tpregist := 'ADESAO';
      vr_tipo_registro(2).tpregist := 'CANCELAMENTO';
      vr_tipo_registro(3).tpregist := 'ENDOSSO';

      vr_dtmvtolt := to_Date('01/09/2022','dd/mm/yyyy');

      cecred.pc_log_programa(pr_dstiplog   => 'I',
                             pr_cdprograma => vr_cdprogra,
                             pr_cdcooper   => 1,
                             pr_tpexecucao => 2,
                             pr_idprglog   => vr_idprglog);
      vr_seqtran := 1;

      SELECT nmrescop
        INTO vr_nmrescop
        FROM CECRED.crapcop
       WHERE cdcooper = rw_crapcop.cdcooper;

      OPEN cr_seg_parametro_prst(pr_cdcooper => rw_crapcop.cdcooper,
                                 pr_tpcustei => 1);
        FETCH cr_seg_parametro_prst INTO rw_seg_parametro_prst;
        IF cr_seg_parametro_prst%NOTFOUND THEN
          CLOSE cr_seg_parametro_prst;
          vr_dscritic := 'Nao foi possivel localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';
          RAISE vr_exc_saida;
        END IF;
      CLOSE cr_seg_parametro_prst;

      vr_vlminimo := CECRED.SEGU0003.fn_capital_seguravel_min(pr_cdcooper => rw_crapcop.cdcooper,
                                                              pr_tppessoa => rw_seg_parametro_prst.tppessoa,
                                                              pr_cdsegura => rw_seg_parametro_prst.cdsegura,
                                                              pr_tpcustei => rw_seg_parametro_prst.tpcustei,
                                                              pr_dtnasc   => TO_DATE('01/01/1990','DD/MM/RRRR'),
                                                              pr_cdcritic => vr_cdcritic,
                                                              pr_dscritic => vr_dscritic);

      vr_vlmaximo := CECRED.SEGU0003.fn_capital_seguravel_max(pr_cdcooper => rw_crapcop.cdcooper,
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

      vr_linha :=    ' UPDATE CECRED.tbseg_parametros_prst p   '
                  || '    SET p.seqarqu = ''' || rw_seg_parametro_prst.seqarqu || ''''
                  || '  WHERE p.idseqpar = ' || rw_seg_parametro_prst.idseqpar ||';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

      BEGIN
        UPDATE CECRED.tbseg_parametros_prst p
           SET p.seqarqu = vr_nrsequen
         WHERE p.idseqpar = rw_seg_parametro_prst.idseqpar;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || rw_crapcop.cdcooper || ' - ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      vr_ultimoDia := trunc(sysdate,'MONTH')-1;

      vr_nmdircop := CECRED.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                  pr_cdcooper => rw_crapcop.cdcooper);

      vr_nmarquiv := 'AILOS_'||REPLACE(vr_nmrescop,' ','_')||'_'
                   ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '_') || '_' ||
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

      OPEN cr_craptsg(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH cr_craptsg
         INTO vr_tab_nrdeanos;
        IF cr_craptsg%NOTFOUND THEN
          vr_tab_nrdeanos := 0;
        END IF;
      CLOSE cr_craptsg;

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => 'Começo loop CR_PRESTAMISTA',
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      vr_seqtran := 0;

      FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_crapcop.cdcooper,
                                           pr_vlminimo => vr_vlminimo,
                                           pr_idadelim => vr_tab_nrdeanos,
                                           pr_dtmvtolt => TO_DATE(ADD_MONTHS(vr_ultimoDia,-1),'DD/MM/RRRR')) LOOP

        vr_vlsdeved   := rw_prestamista.saldo_cpf;
        vr_vlsdatua   := rw_prestamista.vldevatu;
        vr_tpregist   := rw_prestamista.tpregist;
        vr_cdapolic   := rw_prestamista.cdapolic;
        vr_nrproposta := nvl(rw_prestamista.nrproposta,'0');
        vr_dtdevend   := rw_prestamista.dtdevend;
        vr_dtinivig   := rw_prestamista.dtinivig;
        vr_dtfimvig   := rw_prestamista.dtfimvig;
        vr_flgnvenv   := FALSE;
        vr_cdsitseg   := 1;

        IF vr_dtinivig < '01/09/2022' THEN
          vr_tpregist := 3;
        ELSE
          vr_tpregist := 1;
        END IF;

        if rw_prestamista.dtfimvig is null then
          vr_dtfimvig := rw_prestamista.dtfimctr;
        end if;

        if vr_nrproposta = '0' then
          cecred.pc_log_programa(pr_dstiplog           => 'O',
                                 pr_cdprograma         => vr_cdprogra,
                                 pr_cdcooper           => rw_crapcop.cdcooper,
                                 pr_tpexecucao         => 2,
                                 pr_tpocorrencia       => 0,
                                 pr_cdcriticidade      => 2,
                                 pr_dsmensagem         => 'Entrou em pc_gera_proposta, Conta: ' || rw_prestamista.nrdconta || ' nrctrseg: ' || rw_prestamista.nrctrseg,
                                 pr_flgsucesso         => 0,
                                 pr_nmarqlog           => NULL,
                                 pr_destinatario_email => NULL,
                                 pr_idprglog           => vr_idprglog);

          pc_gera_proposta(rw_crapcop.cdcooper
                          ,rw_prestamista.nrdconta
                          ,rw_prestamista.nrctrseg
                          ,vr_cdapolic
                          ,vr_nrproposta);
        end if;

        if trunc(vr_dtinivig) >= trunc(sysdate) and vr_tpregist = 1 then
          continue;
        end if;

        vr_dtcalcidade:= TO_DATE(ADD_MONTHS(vr_ultimoDia,-1),'DD/MM/RRRR');

        CECRED.CADA0001.pc_busca_idade(pr_dtnasctl => rw_prestamista.dtnasctl
                                      ,pr_dtmvtolt => vr_dtcalcidade
                                      ,pr_flcomple => 1
                                      ,pr_nrdeanos => vr_nrdeanos
                                      ,pr_nrdmeses => vr_nrdmeses
                                      ,pr_dsdidade => vr_dsdidade
                                      ,pr_des_erro => vr_dscritic);

        IF vr_cdsitseg <> 2 THEN
          IF vr_tab_ctrl_prst.EXISTS(rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp) THEN
            vr_tpregist:= 0;

            vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                        || '    SET p.tpregist = ''' || rw_prestamista.tpregist || ''''
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                        || '    AND p.cdapolic = ' || vr_cdapolic ||';';

            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

            vr_linha :=    ' UPDATE CECRED.crapseg p   '
                        || '    SET p.cdsitseg = ''' || rw_prestamista.cdsitseg || ''''
                        || '       ,p.dtcancel = TO_DATE(''' || rw_prestamista.dtcancel || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.tpseguro = ' || 4 ||';';

            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

            BEGIN
               UPDATE CECRED.tbseg_prestamista
                  SET tpregist = vr_tpregist
                WHERE cdcooper = rw_crapcop.cdcooper
                  AND nrdconta = rw_prestamista.nrdconta
                  AND nrctrseg = rw_prestamista.nrctrseg
                  AND nrctremp = rw_prestamista.nrctremp
                  AND cdapolic = vr_cdapolic;

               UPDATE CECRED.crapseg s
                 SET s.cdsitseg = 2,
                     s.dtcancel = vr_dtmvtolt
               WHERE s.cdcooper = rw_crapcop.cdcooper
                 AND s.nrdconta = rw_prestamista.nrdconta
                 AND s.nrctrseg = rw_prestamista.nrctrseg
                 AND s.tpseguro = 4;
                 
              COMMIT;   
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || rw_crapcop.cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
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

             vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                         || '    SET p.tpregist = ''' || rw_prestamista.tpregist || ''''
                         || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                         || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                         || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                         || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                         || '    AND p.cdapolic = ' || vr_cdapolic ||';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

             BEGIN
                UPDATE CECRED.tbseg_prestamista
                   SET tpregist = vr_tpregist
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND nrdconta = rw_prestamista.nrdconta
                   AND nrctrseg = rw_prestamista.nrctrseg
                   AND nrctremp = rw_prestamista.nrctremp
                   AND cdapolic = vr_cdapolic;
                   
                COMMIT;   
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || rw_crapcop.cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
              continue;
           end if;
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

        vr_linha_txt := '';
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
        CECRED.SEGU0003.pc_limpa_email(vr_dsdemail);

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

        IF vr_tpregist = 1 THEN
          vr_tpregist := 3;
        END IF;
        
        vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                    || '    SET p.tpregist = ''' || rw_prestamista.tpregist || ''''
                    || '       ,p.dtdenvio = TO_DATE(''' || rw_prestamista.dtdenvio || ''',''DD/MM/RRRR'')'
                    || '       ,p.vlprodut = ''' || REPLACE(TO_CHAR(rw_prestamista.vlprodut),'.',',') || ''''
                    || '       ,p.dtrefcob = TO_DATE(''' || rw_prestamista.dtrefcob || ''',''DD/MM/RRRR'')'
                    || '       ,p.dtdevend = TO_DATE(''' || rw_prestamista.dtdevend || ''',''DD/MM/RRRR'')'
                    || '       ,p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                    || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                    || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                    || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                    || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                    || '    AND p.cdapolic = ' || vr_cdapolic ||';';

        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

        BEGIN
          UPDATE CECRED.tbseg_prestamista
             SET tpregist = vr_tpregist
                ,dtdenvio = vr_dtmvtolt
                ,vlprodut = vr_vlprodvl
                ,dtrefcob = vr_ultimoDia
                ,dtdevend = vr_dtdevend
                ,dtfimvig = vr_dtfimvig
           WHERE cdcooper = rw_crapcop.cdcooper
             AND nrdconta = rw_prestamista.nrdconta
             AND nrctrseg = rw_prestamista.nrctrseg
             AND nrctremp = rw_prestamista.nrctremp
             AND cdapolic = vr_cdapolic;
             
          COMMIT;   
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || rw_crapcop.cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        IF vr_tpregist = 2 THEN
          vr_linha :=    ' UPDATE CECRED.crapseg p   '
                      || '    SET p.cdsitseg = ''' || rw_prestamista.cdsitseg || ''''
                      || '       ,p.dtcancel = TO_DATE(''' || rw_prestamista.dtcancel || ''',''DD/MM/RRRR'')'
                      || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                      || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                      || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                      || '    AND p.tpseguro = ' || 4 ||';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.tpregist = ''' || rw_prestamista.tpregist || ''''
                      || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                      || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                      || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                      || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                      || '    AND p.cdapolic = ' || vr_cdapolic ||';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

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
             WHERE cdcooper = rw_crapcop.cdcooper
               AND nrdconta = rw_prestamista.nrdconta
               AND nrctrseg = rw_prestamista.nrctrseg
               AND nrctremp = rw_prestamista.nrctremp
               AND cdapolic = vr_cdapolic;
               
            COMMIT;   
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || rw_crapcop.cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        ELSIF vr_tpregist = 3 THEN
          BEGIN
            vr_linha :=    ' UPDATE CECRED.crapseg p   '
                        || '    SET p.cdsitseg = ''' || rw_prestamista.cdsitseg || ''''
                        || '       ,p.dtcancel = TO_DATE(''' || rw_prestamista.dtcancel || ''',''DD/MM/RRRR'')'
                        || '       ,p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.tpseguro = ' || 4 ||';';

            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

            UPDATE CECRED.crapseg c
               SET c.cdsitseg = 1,
                   c.dtcancel = NULL,
                   c.dtfimvig = rw_prestamista.dtfimvig
             WHERE c.cdcooper = rw_prestamista.cdcooper
               AND c.nrdconta = rw_prestamista.nrdconta
               AND c.nrctrseg = rw_prestamista.nrctrseg
               AND c.tpseguro = 4
               AND c.cdsitseg <> 1;
               
            COMMIT;   
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || rw_crapcop.cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

        CECRED.gene0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);

        vr_seqtran := vr_seqtran + 1;
      END LOOP;


      vr_seqtran := vr_seqtran - 1;

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => 'Fim loop CR_PRESTAMISTA, total: ' || vr_seqtran,
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      vr_tab_ctrl_prst.delete;
      --vr_crrl815 := vr_tab_crrl815;

      CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '01 Começo converte arquivo',
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      CECRED.gene0003.pc_converte_arquivo(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv
                                         ,pr_nmarqenv => vr_nmarquiv
                                         ,pr_des_erro => vr_dscritic);

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '02 Fim converte arquivo, vr_dscritic: ' || vr_dscritic,
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '03 Começo envio FTP',
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      CECRED.SEGU0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarquiv,
                                                pr_idoperac => 'E',
                                                pr_nmdireto => vr_nmdircop || '/arq/',
                                                pr_idenvseg => 'S',
                                                pr_ftp_site => vr_endereco,
                                                pr_ftp_user => vr_login,
                                                pr_ftp_pass => vr_senha,
                                                pr_ftp_path => 'Envio',
                                                pr_dscritic => vr_dscritic);

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '04 Fim envio FTP, vr_dscritic: ' || vr_dscritic,
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || rw_crapcop.cdcooper || ' - ' || vr_dscritic;
        CECRED.btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2
                                         ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' > '
                                                             || 'Processamento de ftp retornou erro: '||vr_dscritic);
      END IF;

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '05 Inicio movendo arquivo para a pasta final',
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      if trim(vr_nmarquiv) is not null then
         CECRED.gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquiv||' '||vr_nmdir,
                                     pr_typ_saida   => vr_tipo_saida,
                                     pr_des_saida   => vr_dscritic);
      end if;

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '06 Fim movendo arquivo para a pasta final, vr_dscritic: ' || vr_dscritic,
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      IF vr_tipo_saida = 'ERR' THEN
        vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || rw_crapcop.cdcooper || ' - ' ||vr_dscritic;
        CECRED.btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2
                                         ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' > '
                                                             || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
      END IF;

      cecred.pc_log_programa(pr_dstiplog   => 'F',
                             pr_cdprograma => vr_cdprogra,
                             pr_cdcooper   => rw_crapcop.cdcooper,
                             pr_tpexecucao => 2,
                             pr_idprglog   => vr_idprglog);

      
      vr_ultimodiaMes := trunc(SYSDATE,'MONTH') -1 ;

      vr_dtmvtolt_yymmdd := to_char(vr_ultimodiaMes, 'yyyymmdd');
      vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_'||lpad(rw_crapcop.cdcooper,2,0)||'_PRESTAMISTA.txt';
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

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '01 Inicio geracao do relatorio contabil, total de PA: ' || vr_tab_lancarq_815.count,
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => '02 Fim geracao do relatorio contabil, total de PA: ' || vr_tab_lancarq_815.count || ' vr_dscritic: ' || vr_dscritic,
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
      CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
      
      COMMIT;

    cecred.pc_log_programa(pr_dstiplog           => 'O',
                           pr_cdprograma         => vr_cdprogra,
                           pr_cdcooper           => rw_crapcop.cdcooper,
                           pr_tpexecucao         => 2,
                           pr_tpocorrencia       => 0,
                           pr_cdcriticidade      => 2,
                           pr_dsmensagem         => 'Conclusao e commit',
                           pr_flgsucesso         => 0,
                           pr_nmarqlog           => NULL,
                           pr_destinatario_email => NULL,
                           pr_idprglog           => vr_idprglog);

    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := CECRED.gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      ROLLBACK;
      cecred.pc_log_programa(pr_dstiplog           => 'E',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
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
                                        pr_des_corpo   => vr_dscritic,
                                        pr_des_anexo   => NULL,
                                        pr_flg_enviar  => 'S',
                                        pr_des_erro    => vr_dscritic);
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      vr_dscritic := vr_dscritic;
      ROLLBACK;
      cecred.pc_log_programa(pr_dstiplog           => 'E',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => rw_crapcop.cdcooper,
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
                                        pr_des_corpo   => vr_dscritic,
                                        pr_des_anexo   => NULL,
                                        pr_flg_enviar  => 'S',
                                        pr_des_erro    => vr_dscritic);

  
end;
