DECLARE
  ds_exc_erro_v EXCEPTION;
  ds_critica_v          cecred.crapcri.dscritic%TYPE;
  ds_critica_rollback_v cecred.crapcri.dscritic%TYPE;
  ds_critica_arq_v      cecred.crapcri.dscritic%TYPE;

  ds_dados_rollback_v   CLOB := NULL;
  ds_texto_rollback_v   VARCHAR2(32600);
  nm_arquivo_rollback_v VARCHAR2(100);

  cd_cooperativa_v    cecred.crapcop.cdcooper%TYPE := 3;
  ds_nome_diretorio_v cecred.crapprm.dsvlrprm%TYPE;

  qt_reg_commit  NUMBER(10) := 0;
  nr_arquivo     NUMBER(10) := 1;
  qt_reg_arquivo NUMBER(10) := 50000;

  CURSOR c05 is
    SELECT a.cdcooper, a.nmrescop
      FROM cecred.crapcop a
     WHERE a.cdcooper in (6, 11);

  PROCEDURE valida_diretorio_p(ds_nome_diretorio_p IN VARCHAR2,
                               ds_critica_p        OUT cecred.crapcri.dscritic%TYPE) IS

    ds_critica_v    crapcri.dscritic%TYPE;
    ie_tipo_saida_v VARCHAR2(3);
    ds_saida_v      VARCHAR2(1000);

  BEGIN
    IF (cecred.gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) THEN
      ds_critica_p := NULL;
    ELSE
      cecred.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                           ds_nome_diretorio_p ||
                                                           ' 1> /dev/null',
                                         pr_typ_saida   => ie_tipo_saida_v,
                                         pr_des_saida   => ds_saida_v);

      IF (ie_tipo_saida_v = 'ERR') THEN
        ds_critica_v := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                        ds_saida_v;
        RAISE ds_exc_erro_v;
      END IF;

      cecred.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                           ds_nome_diretorio_p ||
                                                           ' 1> /dev/null',
                                         pr_typ_saida   => ie_tipo_saida_v,
                                         pr_des_saida   => ds_saida_v);

      IF (ie_tipo_saida_v = 'ERR') THEN
        ds_critica_v := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                        ds_saida_v;
        RAISE ds_exc_erro_v;
      END IF;
    END IF;
  EXCEPTION
    WHEN ds_exc_erro_v THEN

      ds_critica_p := ds_critica_v;

  END valida_diretorio_p;

  PROCEDURE pc_gera_arquivo_coop(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE,
                                 pr_diretorio IN cecred.crapprm.dsvlrprm%TYPE,
                                 pr_nmrescop  IN cecred.crapcop.nmrescop%TYPE,
                                 pr_dscritic  OUT VARCHAR2) IS
    vr_cdprogra           cecred.crapprg.cdprogra%type := 'BACA_PRST';
    vr_tab_nrdeanos       PLS_INTEGER;
    vr_dscritic           VARCHAR2(4000);
    dtmvtolt_v            cecred.crapdat.dtmvtolt%type;
    vr_index              VARCHAR2(50);
    vr_vlenviad           NUMBER;
    vr_destinatario_email VARCHAR2(500) := cecred.gene0001.fn_param_sistema('CRED',0,'ENVIA_SEG_PRST_EMAIL');
    vr_exc_saida          EXCEPTION;
    vr_nrsequen           NUMBER(5);
    vr_seqtran            INTEGER := 1;
    vr_vlminimo           NUMBER;
    vr_tpregist           INTEGER;
    vr_nrdmeses           NUMBER;
    vr_contrcpf           cecred.tbseg_prestamista.nrcpfcgc%TYPE;
    vr_vltotenv           NUMBER;
    vr_vlmaximo           NUMBER;
    vr_dscorpem           VARCHAR2(2000);
    vr_apolice            VARCHAR2(20);
    vr_nmarquiv           VARCHAR2(100);
    vr_linha_txt          VARCHAR2(32600);
    vr_ultimoDia          DATE;
    vr_pgtosegu           NUMBER;
    vr_vlprodvl           NUMBER;
    vr_dtfimvig           DATE;
    vr_dtcalcidade        DATE;
    vr_dstextab           VARCHAR2(400);
    vr_nrdeanos           PLS_INTEGER;
    vr_dsdidade           VARCHAR2(50);
    vr_dsdemail           VARCHAR2(100);

    nr_proposta_v cecred.tbseg_prestamista.nrproposta%TYPE;

    TYPE typ_reg_ctrl_prst is RECORD(
      nrcpfcgc cecred.tbseg_prestamista.nrcpfcgc%TYPE,
      nrctremp cecred.tbseg_prestamista.nrctremp%TYPE);

    TYPE typ_tab_ctrl_prst IS TABLE OF typ_reg_ctrl_prst INDEX BY VARCHAR2(40);

    vr_tab_ctrl_prst typ_tab_ctrl_prst;

    vr_ind_arquivo utl_file.file_type;

    CURSOR cr_craptsg(pr_cdcooper cecred.crapcop.cdcooper%TYPE,
                      pr_cdsegura cecred.craptsg.cdsegura%TYPE) IS
      SELECT a.nrtabela
        FROM craptsg a
       WHERE a.cdcooper = pr_cdcooper
         AND a.tpseguro = 4
         AND a.tpplaseg = 1
         AND a.cdsegura = pr_cdsegura;

    CURSOR cr_prestamista(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
      SELECT p.rowid AS nr_linha_tbseg,
             ap.rowid AS nr_linha_crapseg,
             aw.rowid AS nr_linha_crawseg,
             p.idseqtra,
             p.cdcooper,
             p.nrdconta,
             ass.cdagenci,
             p.nrctrseg,
             p.tpregist,
             p.cdapolic,
             p.nrcpfcgc,
             p.nmprimtl,
             p.dtnasctl,
             p.cdsexotl,
             p.dsendres,
             p.dsdemail,
             p.nmbairro,
             p.nmcidade,
             p.cdufresd,
             p.nrcepend,
             p.nrtelefo,
             p.dtdevend,
             p.dtinivig,
             p.nrctremp,
             p.cdcobran,
             p.cdadmcob,
             p.tpfrecob,
             p.tpsegura,
             p.cdplapro,
             p.vlprodut,
             p.tpcobran,
             p.vlsdeved,
             p.vldevatu,
             p.dtfimvig,
             c.inliquid,
             c.dtmvtolt data_emp,
             p.nrproposta,
             LPAD(DECODE(p.cdcooper,
                         5,
                         1,
                         7,
                         2,
                         10,
                         3,
                         11,
                         4,
                         14,
                         5,
                         9,
                         6,
                         16,
                         7,
                         2,
                         8,
                         8,
                         9,
                         6,
                         10,
                         12,
                         11,
                         13,
                         12,
                         1,
                         13),
                  6,
                  '0') cdcooperativa,
             SUM(p.vldevatu) OVER(PARTITION BY p.cdcooper, p.nrcpfcgc) saldo_cpf,
             add_months(c.dtmvtolt, c.qtpreemp) dtfimctr,
             p.dtdenvio,
             p.dtrefcob,
             ap.cdsitseg,
             p.tpcustei,
             p.tprecusa,
             p.cdmotrec,
             p.dtrecusa,
             1 tpregistarq
        FROM cecred.tbseg_prestamista p,
             cecred.crapepr           c,
             cecred.crapass           ass,
             cecred.crawseg           aw,
             cecred.crapseg           ap
       WHERE c.cdcooper = p.cdcooper
         AND c.nrdconta = p.nrdconta
         AND c.nrctremp = p.nrctremp
         AND ass.cdcooper = c.cdcooper
         AND ass.nrdconta = c.nrdconta
         AND ap.cdsitseg = 5
         AND aw.nrctrseg = ap.nrctrseg
         AND aw.nrdconta = ap.nrdconta
         AND aw.cdcooper = ap.cdcooper
         AND p.nrctrseg = aw.nrctrseg
         AND p.nrctremp = aw.nrctrato
         AND p.nrdconta = aw.nrdconta
         AND p.cdcooper = aw.cdcooper
         AND p.cdcooper = pr_cdcooper
         AND p.tpregist = 0
         AND p.nrproposta IN ('770356054580',
                              '770350580921')
         and p.nrdconta not in (719056)
       ORDER BY p.nrcpfcgc ASC, p.cdapolic;

    rw_prestamista cr_prestamista%ROWTYPE;

  BEGIN
    vr_dstextab := cecred.tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                                     pr_nmsistem => 'CRED',
                                                     pr_tptabela => 'USUARI',
                                                     pr_cdempres => 11,
                                                     pr_cdacesso => 'SEGPRESTAM',
                                                     pr_tpregist => 0);

    IF (vr_dstextab IS NULL) THEN
      vr_vlminimo := 0;
    ELSE
      vr_vlminimo := cecred.gene0002.fn_char_para_number(SUBSTR(vr_dstextab,27,12));

      vr_vlmaximo := cecred.gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
    END IF;

    vr_nrsequen := to_number(SUBSTR(vr_dstextab, 139, 5)) + 1;
    vr_apolice  := SUBSTR(vr_dstextab, 146, 16);
    vr_pgtosegu := cecred.gene0002.fn_char_para_number(SUBSTR(vr_dstextab,
                                                              51,
                                                              7));

    IF (qt_reg_arquivo >= 50000) THEN

      qt_reg_arquivo := 0;

      dbms_lob.createtemporary(ds_dados_rollback_v, TRUE, dbms_lob.CALL);

      dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);

      cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                     pr_texto_completo => ds_texto_rollback_v,
                                     pr_texto_novo     => ' LOGS E ROLLBACK ' || CHR(13) ||CHR(13),
                                     pr_fecha_xml      => FALSE);

      cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                     pr_texto_completo => ds_texto_rollback_v,
                                     pr_texto_novo     => ' BEGIN ' || CHR(13) || CHR(13),
                                     pr_fecha_xml      => FALSE);

      nm_arquivo_rollback_v := 'ROLLBACK_INC0195739_coop_' || pr_cdcooper ||
                               '_arq_' || nr_arquivo || '.sql';

      nr_arquivo := nr_arquivo + 1;
    END IF;

    BEGIN
      UPDATE cecred.craptab a
         SET a.dstextab = SUBSTR(a.dstextab, 1, 138) ||
                          cecred.gene0002.fn_mask(vr_nrsequen, '99999') ||
                          SUBSTR(a.dstextab, 144)
       WHERE a.cdcooper = pr_cdcooper
         AND a.nmsistem = 'CRED'
         AND a.tptabela = 'USUARI'
         AND a.cdempres = 11
         AND a.cdacesso = 'SEGPRESTAM'
         AND a.tpregist = 0;

      gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                              pr_texto_completo => ds_texto_rollback_v,
                              pr_texto_novo     => ' UPDATE cecred.craptab a ' || CHR(13) ||
                                                   '    SET a.dstextab  = '    || CHR(39) || vr_dstextab || CHR(39) || CHR(13) ||
                                                   '  WHERE a.cdcooper  = '    || pr_cdcooper || CHR(13) ||
                                                   '    AND a.nmsistem  = '    || CHR(39) || 'CRED' || CHR(39) || CHR(13) ||
                                                   '    AND a.tptabela  = '    || CHR(39) || 'USUARI' || CHR(39) || CHR(13) ||
                                                   '    AND a.cdempres  = 11 ' || CHR(13) ||
                                                   '    AND a.cdacesso  = '    || CHR(39) || 'SEGPRESTAM' || CHR(39) || CHR(13) ||
                                                   '    AND a.tpregist  = 0; ' || CHR(13) || CHR(13),
                             pr_fecha_xml      => FALSE);

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' ||
                       pr_cdcooper || ' - ' || sqlerrm;
        RAISE vr_exc_saida;
    END;

    vr_ultimoDia   := TRUNC(SYSDATE, 'month') - 1;
    vr_dtcalcidade := TO_DATE(add_months(vr_ultimoDia, -1), 'DD/MM/RRRR');

    vr_nmarquiv := 'AILOS_' || REPLACE(pr_nmrescop, ' ', '_') || '_' ||
                   REPLACE(to_char(vr_ultimoDia, 'MM/YYYY'), '/', '_') || '_' ||
                   gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';

    cecred.gene0001.pc_abre_arquivo(pr_nmdireto => pr_diretorio || '/arq/',
                                    pr_nmarquiv => vr_nmarquiv,
                                    pr_tipabert => 'W',
                                    pr_utlfileh => vr_ind_arquivo,
                                    pr_des_erro => vr_dscritic);

    IF (vr_dscritic IS NOT NULL) THEN
      RAISE vr_exc_saida;
    END IF;

    OPEN cr_craptsg(pr_cdcooper => pr_cdcooper,
                    pr_cdsegura => cecred.segu0001.busca_seguradora);
      FETCH cr_craptsg
        INTO vr_tab_nrdeanos;

      IF (cr_craptsg%NOTFOUND) THEN
        vr_tab_nrdeanos := 0;
      END IF;
    CLOSE cr_craptsg;

    SELECT NVL(MAX(a.dtmvtolt), TRUNC(SYSDATE))
      INTO dtmvtolt_v
      FROM cecred.crapdat a
     WHERE a.cdcooper = pr_cdcooper;

    FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP
      IF (qt_reg_arquivo >= 50000) THEN

        qt_reg_arquivo := 0;

        dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);

        dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => ' LOGS E ROLLBACK ' || CHR(13) || CHR(13),
                                       pr_fecha_xml      => FALSE);

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => ' BEGIN ' || CHR(13) || CHR(13),
                                       pr_fecha_xml      => FALSE);

        nm_arquivo_rollback_v := 'ROLLBACK_INC0195739_coop_' || pr_cdcooper ||
                                 '_arq_' || nr_arquivo || '.sql';

        nr_arquivo := nr_arquivo + 1;
      END IF;

      nr_proposta_v := cecred.segu0003.fn_nrproposta(rw_prestamista.tpcustei);

      UPDATE cecred.tbseg_prestamista a
         SET a.nrproposta = nr_proposta_v,
             a.dtrecusa = null,
             a.cdmotrec = null,
             a.tprecusa = null,
             a.tpregist = 1
       WHERE a.rowid = rw_prestamista.nr_linha_tbseg;

      cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                     pr_texto_completo => ds_texto_rollback_v,
                                     pr_texto_novo     => ' UPDATE CECRED.TBSEG_PRESTAMISTA a ' || CHR(13) ||
                                                          '    SET a.nrproposta = ' || CHR(39) || rw_prestamista.nrproposta || CHR(39) || ', ' || CHR(13) ||
                                                          '        a.dtrecusa = to_date(' || chr(39) || trim(to_char(trunc(rw_prestamista.dtrecusa),'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
                                                          '        a.cdmotrec = ' || rw_prestamista.cdmotrec || ', ' || chr(13) ||
                                                          '        a.tprecusa = ' || chr(39) || rw_prestamista.tprecusa || chr(39) || ', ' || chr(13) ||
                                                          '        a.tpregist = ' || rw_prestamista.tpregist || chr(13) ||
                                                          '  WHERE a.rowid    = ' || CHR(39) || rw_prestamista.nr_linha_tbseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                     pr_fecha_xml      => FALSE);
                                     
      update cecred.crapseg a
      set a.cdsitseg = 1
      where a.rowid = rw_prestamista.nr_linha_crapseg;
      
      cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                     pr_texto_completo => ds_texto_rollback_v,
                                     pr_texto_novo     => ' UPDATE  cecred.crapseg a ' || CHR(13) ||
                                                          '    SET  a.cdsitseg  = ' || rw_prestamista.cdsitseg || CHR(13) ||
                                                          '  WHERE  a.rowid    = ' || CHR(39) || rw_prestamista.nr_linha_crapseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                     pr_fecha_xml      => FALSE);

      UPDATE cecred.crawseg a
         SET a.nrproposta = nr_proposta_v
       WHERE a.rowid = rw_prestamista.nr_linha_crawseg;

      cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                     pr_texto_completo => ds_texto_rollback_v,
                                     pr_texto_novo     => ' UPDATE CECRED.CRAWSEG a ' || CHR(13) ||
                                                          '    SET a.nrproposta  = ' || CHR(39) || rw_prestamista.nrproposta || CHR(39) || CHR(13) ||
                                                          '  WHERE a.rowid    = ' || CHR(39) || rw_prestamista.nr_linha_crawseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                     pr_fecha_xml      => FALSE);

      vr_tpregist := rw_prestamista.tpregistarq;
      vr_dtfimvig := NVL(rw_prestamista.dtfimvig, rw_prestamista.dtfimctr);

      cecred.cada0001.pc_busca_idade(pr_dtnasctl => rw_prestamista.dtnasctl,
                                     pr_dtmvtolt => vr_dtcalcidade,
                                     pr_flcomple => 1,
                                     pr_nrdeanos => vr_nrdeanos,
                                     pr_nrdmeses => vr_nrdmeses,
                                     pr_dsdidade => vr_dsdidade,
                                     pr_des_erro => vr_dscritic);

      IF (rw_prestamista.saldo_cpf < vr_vlminimo) THEN
        BEGIN
          UPDATE cecred.tbseg_prestamista a
             SET a.dtdenvio = dtmvtolt_v
           WHERE a.rowid = rw_prestamista.nr_linha_tbseg;

          cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                         pr_texto_completo => ds_texto_rollback_v,
                                         pr_texto_novo     => ' UPDATE CECRED.TBSEG_PRESTAMISTA a ' || CHR(13) ||
                                                              '   SET  a.dtdenvio  = TO_DATE(' || CHR(39) ||trim(to_char(rw_prestamista.dtdenvio,'DD/MM/YYYY')) || CHR(39) || ',' || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ') ' || CHR(13) ||
                                                              '  WHERE a.rowid    = ' || CHR(39) || rw_prestamista.nr_linha_tbseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                         pr_fecha_xml      => FALSE);

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        CONTINUE;
      END IF;

      IF (vr_tab_ctrl_prst.exists(rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp)) THEN

        vr_tpregist := 0;

        BEGIN
          UPDATE cecred.tbseg_prestamista a
             SET a.tpregist = vr_tpregist
           WHERE a.rowid = rw_prestamista.nr_linha_tbseg;

          cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                         pr_texto_completo => ds_texto_rollback_v,
                                         pr_texto_novo     => ' UPDATE CECRED.TBSEG_PRESTAMISTA a ' || CHR(13) ||
                                                              '    SET a.tpregist  = ' || rw_prestamista.tpregist || CHR(13) ||
                                                              '  WHERE  a.rowid = ' || CHR(39) || rw_prestamista.nr_linha_tbseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                         pr_fecha_xml      => FALSE);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        CONTINUE;
      ELSE

        vr_index := rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp;
        vr_tab_ctrl_prst(vr_index).nrcpfcgc := rw_prestamista.nrcpfcgc;
        vr_tab_ctrl_prst(vr_index).nrctremp := rw_prestamista.nrctremp;
      END IF;

      IF (vr_contrcpf IS NULL) OR (vr_contrcpf <> rw_prestamista.nrcpfcgc) THEN
        vr_contrcpf := rw_prestamista.nrcpfcgc;
        vr_vlenviad := rw_prestamista.vldevatu;
        vr_vltotenv := rw_prestamista.vldevatu;
      ELSE
        vr_vlenviad := rw_prestamista.vldevatu;
        vr_vltotenv := vr_vltotenv + rw_prestamista.vldevatu;
      END IF;

      IF (vr_vltotenv > vr_vlmaximo) THEN

        IF (vr_contrcpf IS NULL) OR
           (vr_contrcpf <> rw_prestamista.nrcpfcgc) THEN

          vr_vlenviad := vr_vlmaximo;
        ELSE
          vr_vlenviad := vr_vlmaximo -
                         (vr_vltotenv - rw_prestamista.vldevatu);
        END IF;

        vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
          Cooperativa: ' || pr_nmrescop || '<br />
          Conta: ' || rw_prestamista.nrdconta ||
                       '<br />
          Nome: ' || rw_prestamista.nmprimtl ||
                       '<br />
          Contrato Empréstimo: ' ||
                       rw_prestamista.nrctremp || '<br />
          Proposta seguro: ' || rw_prestamista.nrctrseg ||
                       '<br />
          Valor Empréstimo: ' || rw_prestamista.vldevatu ||
                       '<br />
          Valor saldo devedor total: ' ||
                       rw_prestamista.saldo_cpf ||
                       '<br />
          Valor Limite Máximo: ' || vr_vlmaximo;

        cecred.gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                          pr_des_destino => vr_destinatario_email,
                                          pr_des_assunto => 'Valor limite maximo excedido ',
                                          pr_des_corpo   => vr_dscorpem,
                                          pr_des_anexo   => NULL,
                                          pr_flg_enviar  => 'S',
                                          pr_des_erro    => vr_dscritic);

        IF (vr_vlenviad <= 0) THEN
          CONTINUE;
        END IF;

      END IF;

      IF (vr_nrdeanos > vr_tab_nrdeanos) THEN

        IF (vr_tpregist = 1) THEN
          vr_tpregist := 0;
          CONTINUE;

        ELSIF (vr_tpregist = 3) THEN
          vr_tpregist := 2;

        ELSIF (vr_tpregist = 2) THEN
          IF (vr_tpregist <> rw_prestamista.tpregist) THEN
            vr_tpregist := 2;

          ELSE
            CONTINUE;

          END IF;
        END IF;

      ELSIF (vr_nrdeanos < 14) THEN

        vr_tpregist := 1;

        BEGIN
          UPDATE cecred.tbseg_prestamista a
             SET a.tpregist = vr_tpregist
           WHERE a.rowid = rw_prestamista.nr_linha_tbseg;

          cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                         pr_texto_completo => ds_texto_rollback_v,
                                         pr_texto_novo     => ' UPDATE CECRED.TBSEG_PRESTAMISTA a ' || CHR(13) ||
                                                              '    SET a.tpregist  = ' || rw_prestamista.tpregist || CHR(13) ||
                                                              '  WHERE  a.rowid   = ' || CHR(39) || rw_prestamista.nr_linha_tbseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                         pr_fecha_xml      => FALSE);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' ||
                           pr_cdcooper || ' - nrdconta' ||
                           rw_prestamista.nrdconta || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        CONTINUE;
      END IF;

      IF (vr_vlenviad = 0) OR (rw_prestamista.inliquid = 1) THEN
        IF (vr_tpregist = 3) THEN
          vr_tpregist := 2;
        ELSIF (rw_prestamista.tpregist in (1, 2)) THEN
          vr_tpregist := 0;

          BEGIN
            UPDATE cecred.tbseg_prestamista a
               SET a.tpregist = vr_tpregist
             WHERE a.rowid = rw_prestamista.nr_linha_tbseg;

            cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                           pr_texto_completo => ds_texto_rollback_v,
                                           pr_texto_novo     => ' UPDATE cecred.tbseg_prestamista a ' || CHR(13) ||
                                                                '    SET a.tpregist  = ' || rw_prestamista.tpregist || CHR(13) ||
                                                                '  WHERE a.rowid     = ' || CHR(39) || rw_prestamista.nr_linha_tbseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                           pr_fecha_xml      => FALSE);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' ||
                             pr_cdcooper || ' - nrdconta' ||
                             rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          CONTINUE;
        END IF;
      END IF;

      vr_vlprodvl := vr_vlenviad * (vr_pgtosegu / 100);

      IF (vr_vlprodvl < 0.01) THEN
        vr_vlprodvl := 0.01;
      END IF;

      IF (vr_vlenviad < 0.01) THEN
        vr_vlenviad := 0.01;
      END IF;

      vr_linha_txt := '';
      vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0);
      vr_linha_txt := vr_linha_txt || LPAD(vr_tpregist, 2, 0);
      vr_linha_txt := vr_linha_txt || LPAD(vr_apolice, 15, 0);
      vr_linha_txt := vr_linha_txt || RPAD(TO_CHAR(rw_prestamista.nrcpfcgc, 'fm00000000000'),14,' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(cecred.gene0007.fn_caract_especial(rw_prestamista.nmprimtl)),70,' ');
      vr_linha_txt := vr_linha_txt || LPAD(TO_CHAR(rw_prestamista.dtnasctl, 'YYYY-MM-DD'),10,0);
      vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista.cdsexotl, 2, 0);
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(cecred.gene0007.fn_caract_especial(NVL(rw_prestamista.dsendres,' '))),60,' ');
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(cecred.gene0007.fn_caract_especial(NVL(rw_prestamista.nmbairro,' '))),30,' ');
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(cecred.gene0007.fn_caract_especial(NVL(rw_prestamista.nmcidade,' '))),30,' ');
      vr_linha_txt := vr_linha_txt || RPAD(NVL(to_char(rw_prestamista.cdufresd), ' '),2,' ');
      vr_linha_txt := vr_linha_txt || RPAD(cecred.gene0002.fn_mask(rw_prestamista.nrcepend,'zzzzz-zz9'),10,' ');

      IF (LENGTH(rw_prestamista.nrtelefo) = 11) THEN
        vr_linha_txt := vr_linha_txt || RPAD(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo,'(99)99999-9999'),15,' ');
      ELSIF (LENGTH(rw_prestamista.nrtelefo) = 10) THEN
        vr_linha_txt := vr_linha_txt || RPAD(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo,'(99)9999-9999'),15,' ');
      ELSE
        vr_linha_txt := vr_linha_txt || RPAD(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo,'99999-9999'),15,' ');
      END IF;

      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
      vr_dsdemail  := rw_prestamista.dsdemail;

      segu0003.pc_limpa_email(vr_dsdemail);

      vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(NVL(vr_dsdemail, ' '), 50, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(NVL(rw_prestamista.nrproposta, 0), 30, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(TO_CHAR(rw_prestamista.dtdevend, 'YYYY-MM-DD'), 10, 0);
      vr_linha_txt := vr_linha_txt || LPAD(TO_CHAR(rw_prestamista.dtinivig, 'YYYY-MM-DD'), 10, 0);
      vr_linha_txt := vr_linha_txt || LPAD(' ', 2, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(NVL(TO_CHAR(rw_prestamista.nrctremp), 0), 10, 0);
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(LPAd(rw_prestamista.cdcooper, 4, 0), 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || NVL(TO_CHAR(rw_prestamista.cdcobran), ' ');
      vr_linha_txt := vr_linha_txt || RPAD(NVL(TO_CHAR(rw_prestamista.cdadmcob), ' '), 3,' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 2, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 5, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(NVL(TO_CHAR(rw_prestamista.tpfrecob), ' '),2,' ');
      vr_linha_txt := vr_linha_txt || RPAD(NVL(TO_CHAR(rw_prestamista.tpsegura), ' '),2,' ');
      vr_linha_txt := vr_linha_txt || NVL(TO_CHAR(rw_prestamista.cdcooperativa), ' ');
      vr_linha_txt := vr_linha_txt || NVL(TO_CHAR(rw_prestamista.cdplapro), ' ');
      vr_linha_txt := vr_linha_txt || LPAD(REPLACE(TO_CHAR(vr_vlprodvl, 'fm99999990d00'),',','.'),12,0);
      vr_linha_txt := vr_linha_txt || LPAD(NVL(TO_CHAR(rw_prestamista.tpcobran), ' '),1,' ');
      vr_linha_txt := vr_linha_txt || LPAD(REPLACE(TO_CHAR(vr_vlenviad,'fm999999999999990d00'),',','.'),30,0);
      vr_linha_txt := vr_linha_txt || LPAD(TO_CHAR(vr_ultimoDia, 'YYYY-MM-DD'), 10, 0);
      vr_linha_txt := vr_linha_txt || LPAD(TO_CHAR(vr_dtfimvig, 'YYYY-MM-DD'), 10, 0);
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
      vr_linha_txt := vr_linha_txt || CHR(13);

      IF (vr_tpregist = 1) THEN
        vr_tpregist := 3;
      END IF;

      BEGIN
        UPDATE cecred.tbseg_prestamista a
           SET a.tpregist = vr_tpregist,
               a.dtdenvio = dtmvtolt_v,
               a.vlprodut = vr_vlprodvl,
               a.dtrefcob = vr_ultimoDia,
               a.dtdevend = rw_prestamista.dtdevend,
               a.dtfimvig = vr_dtfimvig
         WHERE a.rowid = rw_prestamista.nr_linha_tbseg;

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => ' UPDATE  cecred.tbseg_prestamista a ' || CHR(13) ||
                                                            '    SET  a.tpregist  = ' || rw_prestamista.tpregist || ', ' || CHR(13) ||
                                                            '         a.dtdenvio  = TO_DATE(' || CHR(39) || TRIM(TO_CHAR(rw_prestamista.dtdenvio, 'DD/MM/YYYY')) || CHR(39) || ',' || CHR(39) || 'DD/MM/YYYY' || CHR(39) || '), ' || CHR(13) ||
                                                            '         a.vlprodut  = ' || REPLACE(TRIM(to_char(rw_prestamista.vlprodut)), ',', '.') || ', ' || CHR(13) ||
                                                            '         a.dtrefcob  = TO_DATE(' || CHR(39) || trim(to_char(rw_prestamista.dtrefcob, 'DD/MM/YYYY')) || CHR(39) || ',' || CHR(39) || 'DD/MM/YYYY' || CHR(39) || '), ' || CHR(13) ||
                                                            '         a.dtdevend  = TO_DATE(' || CHR(39) || trim(to_char(rw_prestamista.dtdevend, 'DD/MM/YYYY')) || CHR(39) || ',' || CHR(39) || 'DD/MM/YYYY' || CHR(39) || '), ' || CHR(13) ||
                                                            '         a.dtfimvig  = TO_DATE(' || CHR(39) || trim(to_char(rw_prestamista.dtfimvig, 'DD/MM/YYYY')) || CHR(39) || ',' || CHR(39) || 'DD/MM/YYYY' || CHR(39) || ') ' || CHR(13) ||
                                                            '   WHERE a.rowid   = ' || CHR(39) || rw_prestamista.nr_linha_tbseg ||CHR(39) || ';' || CHR(13) || CHR(13),
                                       pr_fecha_xml      => FALSE);

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar saldo do contrato: ' ||
                         pr_cdcooper || ' - nrdconta' ||
                         rw_prestamista.nrdconta || ' - ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      IF (vr_tpregist = 2) THEN
        BEGIN
          UPDATE cecred.crapseg c
             SET c.cdsitseg = vr_tpregist
           WHERE c.rowid = rw_prestamista.nr_linha_crapseg;

          cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                         pr_texto_completo => ds_texto_rollback_v,
                                         pr_texto_novo     => ' UPDATE  cecred.crapseg a ' || CHR(13) ||
                                                              '    SET  a.cdsitseg  = ' || rw_prestamista.cdsitseg || CHR(13) ||
                                                              '  WHERE  a.rowid    = ' || CHR(39) || rw_prestamista.nr_linha_crapseg || CHR(39) || ';' || CHR(13) || CHR(13),
                                         pr_fecha_xml      => FALSE);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao cancelar seguro prestamista: ' ||
                           pr_cdcooper || ' - nrdconta' ||
                           rw_prestamista.nrdconta || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      cecred.gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_linha_txt);

      vr_seqtran := vr_seqtran + 1;

      qt_reg_commit  := qt_reg_commit + 1;
      qt_reg_arquivo := qt_reg_arquivo + 1;

      IF (qt_reg_commit >= 1000) THEN
        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => ' COMMIT;' || CHR(13) || CHR(13),
                                       pr_fecha_xml      => FALSE);
        qt_reg_commit := 0;
      END IF;

      IF (qt_reg_arquivo >= 10000) THEN

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => ' END;' || CHR(13),
                                       pr_fecha_xml      => FALSE);

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => CHR(13),
                                       pr_fecha_xml      => TRUE);

        cecred.gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => cd_cooperativa_v,
                                                   pr_cdprogra  => 'ATENDA',
                                                   pr_dtmvtolt  => TRUNC(SYSDATE),
                                                   pr_dsxml     => ds_dados_rollback_v,
                                                   pr_dsarqsaid => ds_nome_diretorio_v || '/' || nm_arquivo_rollback_v,
                                                   pr_flg_impri => 'N',
                                                   pr_flg_gerar => 'S',
                                                   pr_flgremarq => 'N',
                                                   pr_nrcopias  => 1,
                                                   pr_des_erro  => ds_critica_rollback_v);

        IF (TRIM(ds_critica_rollback_v) IS NOT NULL) THEN
          ds_critica_v := ds_critica_v || '-' || ds_critica_rollback_v;
          RAISE ds_exc_erro_v;
        END IF;

        dbms_lob.close(ds_dados_rollback_v);
        dbms_lob.freetemporary(ds_dados_rollback_v);
      END IF;
    END LOOP;

    vr_tab_ctrl_prst.delete;

    cecred.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    cecred.gene0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper,
                                        pr_nmarquiv => pr_diretorio ||
                                                       '/arq/' ||
                                                       vr_nmarquiv,
                                        pr_nmarqenv => vr_nmarquiv,
                                        pr_des_erro => vr_dscritic);

    IF (vr_dscritic IS NOT NULL) THEN
      cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                     pr_texto_completo => ds_texto_rollback_v,
                                     pr_texto_novo     => ' LOG: falha mapeada ao atualizar registro:' || CHR(13) || 'Crítica: ' || vr_dscritic || CHR(13) || CHR(13),
                                     pr_fecha_xml      => FALSE);
      RAISE vr_exc_saida;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic || SQLERRM ||
                     DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      pr_dscritic := vr_dscritic;
  END pc_gera_arquivo_coop;

BEGIN
  IF (UPPER(cecred.gene0001.fn_database_name) like '%AYLLOSP%' or
     UPPER(cecred.gene0001.fn_database_name) like '%AILOSTS%') THEN

    SELECT max(a.dsvlrprm)
      INTO ds_nome_diretorio_v
      FROM cecred.crapprm a
     WHERE a.nmsistem = 'CRED'
       AND a.cdcooper = cd_cooperativa_v
       AND a.cdacesso = 'ROOT_MICROS';

    IF (ds_nome_diretorio_v IS NULL) THEN
      SELECT max(a.dsvlrprm)
        INTO ds_nome_diretorio_v
        FROM cecred.crapprm a
       WHERE a.nmsistem = 'CRED'
         AND a.cdcooper = 0
         AND a.cdacesso = 'ROOT_MICROS';
    END IF;

    ds_nome_diretorio_v := ds_nome_diretorio_v || 'cpd/bacas/INC0195739';

  ELSE

    ds_nome_diretorio_v := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                        pr_cdcooper => 3);

    ds_nome_diretorio_v := ds_nome_diretorio_v || '/INC0195739';

  END IF;

  valida_diretorio_p(ds_nome_diretorio_p => ds_nome_diretorio_v,
                     ds_critica_p        => ds_critica_v);

  IF (TRIM(ds_critica_v) IS NOT NULL) THEN
    RAISE ds_exc_erro_v;
  END IF;

  FOR r05 IN c05 LOOP

    ds_critica_v   := NULL;
    qt_reg_arquivo := 50000;

    pc_gera_arquivo_coop(pr_cdcooper  => r05.cdcooper,
                         pr_diretorio => ds_nome_diretorio_v,
                         pr_nmrescop  => r05.nmrescop,
                         pr_dscritic  => ds_critica_v);

    IF (ds_critica_v IS NULL) THEN

      IF (qt_reg_arquivo <> 50000) THEN

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => ' COMMIT;' || CHR(13) || CHR(13),
                                       pr_fecha_xml      => FALSE);

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => ' END;' || CHR(13),
                                       pr_fecha_xml      => FALSE);

        cecred.gene0002.pc_escreve_xml(pr_xml            => ds_dados_rollback_v,
                                       pr_texto_completo => ds_texto_rollback_v,
                                       pr_texto_novo     => CHR(13),
                                       pr_fecha_xml      => TRUE);

        cecred.gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => cd_cooperativa_v,
                                                   pr_cdprogra  => 'ATENDA',
                                                   pr_dtmvtolt  => TRUNC(SYSDATE),
                                                   pr_dsxml     => ds_dados_rollback_v,
                                                   pr_dsarqsaid => ds_nome_diretorio_v || '/' || nm_arquivo_rollback_v,
                                                   pr_flg_impri => 'N',
                                                   pr_flg_gerar => 'S',
                                                   pr_flgremarq => 'N',
                                                   pr_nrcopias  => 1,
                                                   pr_des_erro  => ds_critica_rollback_v);

        IF (TRIM(ds_critica_rollback_v) IS NOT NULL) THEN
          ds_critica_v := ds_critica_v || '-' || ds_critica_rollback_v;
          RAISE ds_exc_erro_v;
        END IF;

        dbms_lob.close(ds_dados_rollback_v);
        dbms_lob.freetemporary(ds_dados_rollback_v);
      END IF;

      COMMIT;
    ELSE
      ds_critica_arq_v := SUBSTR(ds_critica_arq_v || ' - Coop: ' ||
                                 r05.cdcooper || ' - ' || ds_critica_v ||
                                 CHR(13),
                                 1,
                                 1000);
    END IF;
  END LOOP;

  IF (ds_critica_arq_v is not null) THEN
    ds_critica_v := ds_critica_arq_v;
    RAISE ds_exc_erro_v;
  END IF;

EXCEPTION
  WHEN ds_exc_erro_v THEN
    ROLLBACK;
    raise_application_error(-20111, ds_critica_v);
END;
/
