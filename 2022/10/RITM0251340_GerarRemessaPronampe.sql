DECLARE
  rw_crapdat  cecred.BTCH0001.cr_crapdat%ROWTYPE;
  rw_repasse  credito.tbcred_pronampe_repasse%ROWTYPE;
  rw_contrato credito.tbcred_pronampe_contrato%ROWTYPE;

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic cecred.crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  vr_tab_erro cecred.gene0001.typ_tab_erro;
  vr_des_reto VARCHAR2(100);

  vr_cdlcremp_pronampe     cecred.craplcr.cdlcremp%TYPE := 2600;
  vr_cdlcremp_pronampe_pf  cecred.craplcr.cdlcremp%TYPE := 2610;
  vr_cdhistor_pronampe     cecred.craplcm.cdhistor%TYPE := 3280;
  vr_caminho_arquivo       cecred.crapprm.dsvlrprm%TYPE := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                                            pr_cdcooper => 0,
                                                                                            pr_cdacesso => 'DIR_BB_CONNECTDIRECT');
  vr_caminho_arquivo_envia cecred.crapprm.dsvlrprm%TYPE := vr_caminho_arquivo || 'envia/';
  vr_caminho_arquivo_tmp   cecred.crapprm.dsvlrprm%TYPE := vr_caminho_arquivo || 'tmp/';
  vr_caminho_arquivo_log   cecred.crapprm.dsvlrprm%TYPE := vr_caminho_arquivo || 'log/';

  vr_dscomando VARCHAR2(4000);
  vr_typ_saida VARCHAR2(4000);

  vr_arqremessa     CLOB;
  vr_arqlog_erro    CLOB;
  vr_arqlog_geracao CLOB;
  vr_arq_csv        CLOB;
  vr_linha          NUMBER;
  vr_seq_arquivo    NUMBER(7);
  vr_arquivo        VARCHAR2(100);
  vr_arquivo2       VARCHAR2(100);
  vr_progcredito    VARCHAR2(2);
  vr_gerou_detalhe  INT;

  vr_diapagto     INTEGER;
  vr_qtprecal     cecred.crapepr.qtprecal%TYPE;
  vr_vlprepag     NUMBER;
  vr_vlpreapg     NUMBER;
  vr_vljurmes     NUMBER;
  vr_vljuracu     NUMBER;
  vr_vljurdia     NUMBER;
  vr_vlsdeved     NUMBER;
  vr_dtultpag     cecred.crapepr.dtultpag%TYPE;
  vr_vlmrapar     cecred.crappep.vlmrapar%TYPE;
  vr_vlmtapar     cecred.crappep.vlmtapar%TYPE;
  vr_vliofcpl     cecred.crappep.vliofcpl%TYPE;
  vr_vlprvenc     NUMBER;
  vr_vlpraven     NUMBER;
  vr_publico_alvo NUMBER(1);
  vr_tp_pes       NUMBER(1);

  vr_vlprincipal_normal NUMBER(25, 6);
  vr_vlprincipal_atraso NUMBER(25, 6);
  vr_vlencargos_normal  NUMBER(25, 6);
  vr_vlencargos_atraso  NUMBER(25, 6);
  vr_vlparcela_sjuros   NUMBER(25, 6);
  vr_qt_parc_pg         NUMBER;
  vr_qt_parc_npg        NUMBER;
  vr_fatura_ano         NUMBER(25, 6);
  vr_cdnatopc           cecred.crapttl.cdnatopc%TYPE;
  vr_cdcnae             credito.TBCRED_CNAEPRONAMPE.cdcnae%TYPE;

  vr_tab_parcelas     cecred.empr0011.typ_tab_parcelas;
  vr_tab_calculado    cecred.empr0011.typ_tab_calculado;
  vr_contratospronamp credito.tiposDadosPronampe.typ_tab_contratospronamp;
  vr_liqparpronamp    credito.tiposDadosPronampe.typ_tab_liqparpronamp;
  vr_vlrepasse        credito.tbcred_pronampe_repasse.vlrepasse%TYPE;
  vr_coop_honra       cecred.crappco.dsconteu%TYPE;
  vr_sit_honra        NUMBER;
  vr_idx              NUMBER;
  vr_vldHonra         NUMBER;
  vr_inremgerada      BOOLEAN;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,c.cdagectl
          ,c.nmcidade
          ,c.cdufdcop
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
     ORDER BY decode(c.cdcooper, 1,  1,
                                16,  2,
                                 9,  3,
                                 7,  4,
                                13,  5,
                                14,  6,
                                 2,  7,
                                10,  8,
                                12,  9,
                                 8, 10,
                                11, 11,
                                 6, 12,
                                 5, 13, 
                                    14);

  CURSOR cr_crapepr(pr_cdcooper cecred.crapepr.cdcooper%TYPE
                   ,pr_dtmvtolt cecred.crawepr.dtmvtolt%TYPE
                   ,pr_cdlcremp cecred.crapepr.cdlcremp%TYPE
                   ,pr_cdlcrepf cecred.crapepr.cdlcremp%TYPE) IS
    SELECT e.*
          ,w.vlemprst valor_solicitado
      FROM cecred.crapepr                   e
          ,cecred.crawepr                   w
          ,credito.tbcred_pronampe_contrato p
     WHERE e.cdcooper = pr_cdcooper
       AND ((to_char(pr_dtmvtolt, 'D') = 2 AND e.dtmvtolt BETWEEN pr_dtmvtolt - 3 AND pr_dtmvtolt) OR
           (to_char(pr_dtmvtolt, 'D') <> 2 AND e.dtmvtolt BETWEEN pr_dtmvtolt - 1 AND pr_dtmvtolt))
       AND e.cdlcremp IN (pr_cdlcremp, pr_cdlcrepf)
       AND w.cdcooper = e.cdcooper
       AND w.nrdconta = e.nrdconta
       AND w.nrctremp = e.nrctremp
       AND e.cdcooper = p.cdcooper
       AND e.nrdconta = p.nrdconta
       AND e.nrctremp = p.nrcontrato
       AND p.dtenvformal IS NULL;

  CURSOR cr_crapass(pr_cdcooper cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta cecred.crapass.nrdconta%TYPE) IS
    SELECT a.nrcpfcgc
          ,a.cdagenci
          ,a.inpessoa
          ,a.cdclcnae
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta;

  CURSOR cr_crapage(pr_cdcooper cecred.crapage.cdcooper%TYPE
                   ,pr_cdagenci cecred.crapage.cdagenci%TYPE) IS
    SELECT substr(m.cdcomarc, 1, length(m.cdcomarc) - 1) cdcomarc
      FROM cecred.crapage a
          ,cecred.crapmun m
     WHERE a.cdufdcop = m.cdestado
       AND a.nmcidade = m.dscidade
       AND a.cdcooper = pr_cdcooper
       AND a.cdagenci = pr_cdagenci
       AND a.insitage = 1;

  CURSOR cr_craplcm(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                   ,pr_cdhistor cecred.craplcm.cdhistor%TYPE
                   ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE) IS
    SELECT l.cdcooper
          ,l.dtmvtolt
          ,l.vllanmto
          ,l.nrdconta
          ,e.cdagenci
          ,e.cdopeori
          ,e.nrctremp
          ,e.progress_recid
          ,e.vlemprst
      FROM cecred.craplcm l
          ,cecred.crapepr e
     WHERE l.cdcooper = pr_cdcooper
       AND l.cdhistor = pr_cdhistor
       AND l.dtmvtolt = pr_dtmvtolt
       AND e.cdcooper = l.cdcooper
       AND e.nrdconta = l.nrdconta
       AND e.nrctremp = l.nrdocmto;

  CURSOR cr_crapmun(pr_cdestado cecred.crapmun.cdestado%TYPE
                   ,pr_dscidade cecred.crapmun.dscidade%TYPE) IS
    SELECT substr(m.cdcomarc, 1, length(m.cdcomarc) - 1) cdcomarc
      FROM cecred.crapmun m
     WHERE m.cdestado = pr_cdestado
       AND m.dscidade = pr_dscidade;

  CURSOR cr_crappep(PR_CDCOOPER cecred.CRAPPEP.CDCOOPER%TYPE
                   ,PR_NRDCONTA cecred.CRAPPEP.NRDCONTA%TYPE
                   ,PR_NRCTREMP cecred.CRAPPEP.NRCTREMP%TYPE) IS
    SELECT MAX(DTVENCTO) DTVENCTO
      FROM cecred.CRAPPEP
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND NRCTREMP = PR_NRCTREMP;

  CURSOR cr_crapjur(pr_cdcooper cecred.crapjur.cdcooper%TYPE
                   ,pr_nrdconta cecred.crapjur.nrdconta%TYPE) IS
    SELECT j.natjurid
          ,CASE
             WHEN nvl(j.vlfatano, 0) > 1 THEN
              nvl(j.vlfatano, 0)
             ELSE
              0
           END vlfatano
      FROM cecred.crapjur j
     WHERE j.cdcooper = pr_cdcooper
       AND j.nrdconta = pr_nrdconta;

  CURSOR cr_epr_saldos(pr_cdcooper cecred.crapepr.cdcooper%TYPE
                      ,pr_dtmvtolt cecred.crapdat.dtmvtolt%TYPE
                      ,pr_cdlcremp cecred.crapepr.cdlcremp%TYPE
                      ,pr_cdlcrepf cecred.crapepr.cdlcremp%TYPE) IS
    SELECT p.cdcooper
          ,p.nrdconta
          ,p.nrctremp
          ,p.dtmvtolt
          ,p.cdlcremp
          ,p.vlemprst
          ,p.txmensal
          ,w.dtdpagto
          ,p.vlsprojt
          ,p.progress_recid
          ,p.qtpreemp
          ,p.inliquid
          ,p.inprejuz
          ,p.vlprejuz
          ,p.vlttmupr
          ,p.vlttjmpr
          ,p.vltiofpr
          ,p.vljraprj
      FROM cecred.crapepr p
          ,cecred.crawepr w
     WHERE p.cdcooper = pr_cdcooper
       AND (p.inliquid = 0 OR (p.inliquid = 1 AND p.inprejuz = 1))
       AND p.cdlcremp IN (pr_cdlcremp, pr_cdlcrepf)
       AND p.dtmvtolt < pr_dtmvtolt
       AND w.cdcooper = p.cdcooper
       AND w.nrdconta = p.nrdconta
       AND w.nrctremp = p.nrctremp;

  CURSOR cr_parcela(pr_cdcooper cecred.crappep.cdcooper%TYPE
                   ,pr_nrdconta cecred.crappep.nrdconta%TYPE
                   ,pr_nrctremp cecred.crappep.nrctremp%TYPE) IS
    SELECT COUNT(A) NRPAREPR
          ,COUNT(B) NRPARNPG
      FROM (SELECT CASE
                     WHEN P.DTULTPAG IS NOT NULL THEN
                      1
                   END AS A
                  ,CASE
                     WHEN P.DTULTPAG IS NULL THEN
                      2
                   END AS B
              FROM CECRED.CRAPPEP P
             WHERE P.CDCOOPER = PR_CDCOOPER
               AND P.NRDCONTA = PR_NRDCONTA
               AND P.NRCTREMP = PR_NRCTREMP);

  CURSOR cr_tco(pr_cdcooper cecred.tbrisco_central_ocr.cdcooper%TYPE
               ,pr_nrdconta cecred.tbrisco_central_ocr.nrdconta%TYPE
               ,pr_nrctremp cecred.tbrisco_central_ocr.nrctremp%TYPE) IS
    SELECT cecred.RISC0004.fn_traduz_risco(r.inrisco_operacao) rating_operacao
      FROM cecred.tbrisco_central_ocr r
     WHERE r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp
       AND rownum = 1
     ORDER BY r.dtrefere DESC;

  CURSOR cr_remessa IS
    SELECT nvl(MAX(rem.nrremessa), 0) nrremessa
      FROM credito.tbcred_pronampe_remessa rem;

  CURSOR cr_remessadia(pr_dtremessa credito.tbcred_pronampe_remessa.dtremessa%TYPE) IS
    SELECT nvl(MAX(rem.nrremessa), 0) nrremessa
      FROM credito.tbcred_pronampe_remessa rem
     WHERE rem.dtremessa = pr_dtremessa;

  CURSOR cr_totrepasse(pr_cdcooper   credito.tbcred_pronampe_repasse.cdcooper%TYPE
                      ,pr_nrdconta   credito.tbcred_pronampe_repasse.nrdconta%TYPE
                      ,pr_nrcontrato credito.tbcred_pronampe_repasse.nrcontrato%TYPE) IS
    SELECT SUM(vlrepasse) vlrepasse
      FROM credito.tbcred_pronampe_repasse
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrcontrato = pr_nrcontrato;

  CURSOR cr_natocup(pr_cdcooper cecred.tbrisco_central_ocr.cdcooper%TYPE
                   ,pr_nrdconta cecred.tbrisco_central_ocr.nrdconta%TYPE) IS
    SELECT cdnatopc
      FROM cecred.crapttl
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;

  CURSOR cr_cnae(pr_cdcnae credito.TBCRED_CNAEPRONAMPE.cdcnae%TYPE) IS
    SELECT c.cdcnae
      FROM credito.tbcred_cnaepronampe c
     WHERE c.cdcnae = pr_cdcnae;

  CURSOR cr_pessoafisica(pr_cdcooper cecred.tbrisco_central_ocr.cdcooper%TYPE
                        ,pr_nrdconta cecred.tbrisco_central_ocr.nrdconta%TYPE) IS
    SELECT (vlsalari +
           (vldrendi##1 + vldrendi##2 + vldrendi##3 + vldrendi##4 + vldrendi##5 + vldrendi##6)) * 12 fatano
      FROM cecred.crapttl
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND idseqttl = 1;

  CURSOR cr_tbcred_pronampe_contrato(pr_cdcooper credito.tbcred_pronampe_contrato.cdcooper%TYPE) IS
    SELECT p.cdcooper
          ,p.nrdconta
          ,p.nrcontrato
          ,e.progress_recid
          ,p.dtcancelamento
      FROM credito.tbcred_pronampe_contrato p
          ,credito.crapepr                  e
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrcontrato = e.nrctremp
       AND p.dtcancelamento IS NOT NULL
       AND ((to_char(SYSDATE, 'D') = 2 AND p.dtcancelamento BETWEEN SYSDATE - 3 AND SYSDATE) OR
           (to_char(SYSDATE, 'D') <> 2 AND p.dtcancelamento BETWEEN SYSDATE - 1 AND SYSDATE));

  CURSOR cr_sit_honra(pr_cdcooper   credito.tbcred_pronampe_contrato.cdcooper%TYPE
                     ,pr_nrdconta   credito.tbcred_pronampe_contrato.nrdconta%TYPE
                     ,pr_nrcontrato credito.tbcred_pronampe_contrato.nrcontrato%TYPE) IS
    SELECT 1
      FROM credito.tbcred_pronampe_contrato s
     WHERE s.tpsituacaohonra = 2
       AND s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.nrcontrato = pr_nrcontrato;

  rw_crapass    cr_crapass%ROWTYPE;
  rw_crapepr    cr_crapepr%ROWTYPE;
  rw_crapcop    cr_crapcop%ROWTYPE;
  rw_crapmun    cr_crapmun%ROWTYPE;
  rw_crappep    cr_crappep%ROWTYPE;
  rw_crapjur    cr_crapjur%ROWTYPE;
  rw_tco        cr_tco%ROWTYPE;
  rw_crapage    cr_crapage%ROWTYPE;
  rw_remessa    cr_remessa%ROWTYPE;
  rw_totrepasse cr_totrepasse%ROWTYPE;

  FUNCTION f_ret_campo(pr_vlr_campo IN VARCHAR2
                      ,pr_tam_campo IN NUMBER
                      ,pr_tip_campo IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    IF length(pr_vlr_campo) <= pr_tam_campo THEN
      IF pr_tip_campo = 'D' THEN
        IF length(pr_vlr_campo) = 8 THEN
          RESULT := pr_vlr_campo;
        END IF;
      END IF;
      IF pr_tip_campo IN ('N', 'M') THEN
        RESULT := lpad(to_char(to_number(pr_vlr_campo)), pr_tam_campo, '0');
      END IF;
      IF pr_tip_campo = 'A' THEN
        RESULT := rpad(UPPER(to_char(pr_vlr_campo)), pr_tam_campo, ' ');
      END IF;
      IF pr_tip_campo = 'H' THEN
        IF length(pr_vlr_campo) = 6 THEN
          RESULT := pr_vlr_campo;
        END IF;
      END IF;
    END IF;
    RETURN(RESULT);
  END f_ret_campo;

  FUNCTION f_ret_header(pr_linha   IN VARCHAR2
                       ,pr_seqcoop IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('1', 2, 'N') ||
              f_ret_campo('GFGF0010', 8, 'A') || f_ret_campo('20170331', 8, 'D') ||
              f_ret_campo('20', 3, 'N') || f_ret_campo('2', 3, 'N') ||
              f_ret_campo(pr_seqcoop, 4, 'N') || f_ret_campo(' ', 175, 'A');
    RETURN(RESULT);
  END f_ret_header;

  FUNCTION f_ret_detalhe_03(pr_linha       IN VARCHAR2
                           ,pr_1           IN VARCHAR2
                           ,pr_2           IN VARCHAR2
                           ,pr_3           IN VARCHAR2
                           ,pr_4           IN VARCHAR2
                           ,pr_5           IN VARCHAR2
                           ,pr_6           IN VARCHAR2
                           ,pr_7           IN VARCHAR2
                           ,pr_8           IN VARCHAR2
                           ,pr_9           IN VARCHAR2
                           ,pr_progcredito IN VARCHAR2
                           ,vr_tp_pes      IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('3', 2, 'N') ||
              f_ret_campo(pr_1, 20, 'A') || f_ret_campo(pr_2, 4, 'N') || f_ret_campo(pr_3, 7, 'N') ||
              f_ret_campo(vr_tp_pes, 1, 'N') || f_ret_campo(pr_4, 14, 'N') ||
              f_ret_campo(pr_5, 2, 'N') || f_ret_campo(pr_6, 17, 'M') || f_ret_campo(pr_7, 17, 'M') ||
              f_ret_campo('10000', 5, 'N') || f_ret_campo('1', 1, 'N') || f_ret_campo('2', 1, 'N') ||
              f_ret_campo('11', 3, 'N') || f_ret_campo(pr_progcredito, 4, 'N') ||
              f_ret_campo(pr_8, 8, 'D') || f_ret_campo(pr_9, 8, 'D') || f_ret_campo('1', 1, 'N') ||
              f_ret_campo('1', 2, 'N') || f_ret_campo('00000000', 8, 'D') ||
              f_ret_campo('1', 1, 'N') || f_ret_campo('0', 9, 'N') || f_ret_campo(' ', 68, 'A');
    RETURN(RESULT);
  END f_ret_detalhe_03;

  FUNCTION f_ret_detalhe_04(pr_linha IN VARCHAR2
                           ,pr_1     IN VARCHAR2
                           ,pr_2     IN VARCHAR2
                           ,pr_3     IN VARCHAR2
                           ,pr_4     IN VARCHAR2
                           ,pr_5     IN VARCHAR2
                           ,pr_6     IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('4', 2, 'N') ||
              f_ret_campo(pr_1, 20, 'A') || f_ret_campo(pr_2, 8, 'D') || f_ret_campo(pr_3, 17, 'M') ||
              f_ret_campo(pr_4, 8, 'D') || f_ret_campo(pr_5, 17, 'M') || f_ret_campo(pr_6, 17, 'M') ||
              f_ret_campo('0', 17, 'M') || f_ret_campo('0', 9, 'N') || f_ret_campo('0', 17, 'M') ||
              f_ret_campo(' ', 71, 'A');
    RETURN(RESULT);
  END f_ret_detalhe_04;

  FUNCTION f_ret_detalhe_05(pr_linha IN VARCHAR2
                           ,pr_1     IN VARCHAR2
                           ,pr_2     IN VARCHAR2
                           ,pr_3     IN VARCHAR2
                           ,pr_4     IN VARCHAR2
                           ,pr_5     IN VARCHAR2
                           ,pr_6     IN VARCHAR2
                           ,pr_7     IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('5', 2, 'N') ||
              f_ret_campo(pr_1, 20, 'A') || f_ret_campo(pr_2, 8, 'D') || f_ret_campo(pr_3, 17, 'M') ||
              f_ret_campo(pr_4, 17, 'M') || f_ret_campo(pr_5, 17, 'M') ||
              f_ret_campo(pr_6, 17, 'M') || f_ret_campo(pr_7, 2, 'A') || f_ret_campo(' ', 103, 'A');
    RETURN(RESULT);
  END f_ret_detalhe_05;

  FUNCTION f_ret_detalhe_06(pr_linha IN VARCHAR2
                           ,pr_1     IN VARCHAR2
                           ,pr_2     IN VARCHAR2
                           ,pr_3     IN VARCHAR2
                           ,pr_4     IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('6', 2, 'N') ||
              f_ret_campo(pr_1, 20, 'A') || f_ret_campo(pr_2, 8, 'D') || f_ret_campo(pr_3, 8, 'D') ||
              f_ret_campo(pr_4, 17, 'M') || f_ret_campo(' ', 149, 'A');
    RETURN(RESULT);
  END f_ret_detalhe_06;

  FUNCTION f_ret_detalhe_07(pr_linha IN VARCHAR2
                           ,pr_1     IN VARCHAR2
                           ,pr_2     IN VARCHAR2
                           ,pr_3     IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('7', 2, 'N') ||
              f_ret_campo(pr_1, 20, 'A') || f_ret_campo(pr_2, 8, 'D') || f_ret_campo(pr_3, 17, 'M') ||
              f_ret_campo(' ', 157, 'A');
    RETURN(RESULT);
  END f_ret_detalhe_07;

  FUNCTION f_ret_trailer(pr_linha IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('99', 2, 'N') ||
              f_ret_campo(pr_linha, 7, 'N') || f_ret_campo(' ', 194, 'A');
    RETURN(RESULT);
  END f_ret_trailer;

  FUNCTION f_ret_detalhe_11(pr_linha IN VARCHAR2
                           ,pr_1     IN VARCHAR2
                           ,pr_2     IN VARCHAR2) RETURN VARCHAR2 IS
    RESULT VARCHAR2(4000);
  BEGIN
    RESULT := f_ret_campo(pr_linha, 7, 'N') || f_ret_campo('11', 2, 'N') ||
              f_ret_campo(pr_1, 20, 'A') || f_ret_campo(pr_2, 8, 'D') || f_ret_campo(' ', 173, 'A');
    RETURN(RESULT);
  END f_ret_detalhe_11;

  PROCEDURE geralog(pr_dsexecut IN VARCHAR2 DEFAULT NULL) IS
    vr_nmarqlog VARCHAR2(500);
    vr_desdolog VARCHAR2(4000);
  BEGIN  
    vr_nmarqlog := 'GerarArquivoPronampe.log';
    vr_desdolog := to_char(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') || ' Coop: 3 ' || ' - ' || pr_dsexecut;
  
    cecred.btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                      pr_ind_tipo_log => 1,
                                      pr_des_log      => vr_desdolog,
                                      pr_nmarqlog     => vr_nmarqlog,
                                      pr_cdprograma   => 'GerarArquivoPronampe',
                                      pr_dstiplog     => 'O');  
  END geralog;
BEGIN
  vr_gerou_detalhe := 0;
  vr_inremgerada   := FALSE;

  OPEN cecred.BTCH0001.cr_crapdat(pr_cdcooper => 3);
  FETCH cecred.BTCH0001.cr_crapdat
    INTO rw_crapdat;
  IF cecred.BTCH0001.cr_crapdat%NOTFOUND THEN
    vr_cdcritic := 1;
    CLOSE cecred.BTCH0001.cr_crapdat;
    RAISE vr_exc_erro;
  ELSE
    CLOSE cecred.BTCH0001.cr_crapdat;
  END IF;

  OPEN cr_remessadia(pr_dtremessa => rw_crapdat.dtmvtolt);
  FETCH cr_remessadia
    INTO rw_remessa;
  CLOSE cr_remessadia;

  IF nvl(rw_remessa.nrremessa, 0) = 0 THEN
    OPEN cr_remessa;
    FETCH cr_remessa
      INTO rw_remessa;
    IF rw_remessa.nrremessa > 0 THEN
      vr_seq_arquivo := rw_remessa.nrremessa + 1;
    ELSE
      vr_dscritic := 'Erro ao buscar sequencial de remessa. Tabela TBCRED_PRONAMPE_REMESSA não inicializada.';
    END IF;
    CLOSE cr_remessa;
  ELSE
    vr_seq_arquivo := rw_remessa.nrremessa;
    vr_inremgerada := TRUE;
  END IF;

  vr_linha      := 1;
  vr_arqremessa := to_clob(f_ret_header(to_char(vr_linha), to_char(vr_seq_arquivo)));

  vr_arqlog_erro    := to_clob(' ');
  vr_arqlog_geracao := vr_arqlog_geracao ||
                       to_clob('HEADER Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                               ' Sequencial de Remessa:  ' || vr_seq_arquivo || chr(10));
  vr_arq_csv        := to_clob('Codigo da Cooperativa' || ';' || 'Numero da Conta' || ';' ||
                               'Numero do Contrato' || ';' || 'Valor Solicitado');

  FOR rw_crapcop IN cr_crapcop LOOP
    OPEN cecred.BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH cecred.BTCH0001.cr_crapdat
      INTO rw_crapdat;
    IF cecred.BTCH0001.cr_crapdat%NOTFOUND THEN
      vr_cdcritic := 1;
      CLOSE cecred.BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cecred.BTCH0001.cr_crapdat;
    END IF;
  
    vr_coop_honra := NVL(credito.obterStatusBloqHonraPronampe(pr_cdcooper => rw_crapcop.cdcooper),
                         'NAO');
  
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper => rw_crapcop.cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_cdlcremp => vr_cdlcremp_pronampe,
                                 pr_cdlcrepf => vr_cdlcremp_pronampe_pf) LOOP
      OPEN cr_crapass(pr_cdcooper => rw_crapepr.cdcooper, pr_nrdconta => rw_crapepr.nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        vr_arqlog_erro := vr_arqlog_erro ||
                          to_clob(chr(10) || 'Sem dados do associado: Cooperativa ' ||
                                  rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta);
        CONTINUE;
        CLOSE cr_crapass;
      ELSE
        CLOSE cr_crapass;
      END IF;
    
      OPEN cr_crapmun(pr_cdestado => rw_crapcop.cdufdcop, pr_dscidade => rw_crapcop.nmcidade);
      FETCH cr_crapmun
        INTO rw_crapmun;
    
      IF cr_crapmun%NOTFOUND THEN
        vr_arqlog_erro := vr_arqlog_erro ||
                          to_clob(chr(10) || 'Associado sem dados de Município: Cooperativa ' ||
                                  rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta || ' UF ' ||
                                  rw_crapcop.cdufdcop || ' Cidade ' || rw_crapcop.nmcidade);
        CLOSE cr_crapmun;
      ELSE
        CLOSE cr_crapmun;
      END IF;
    
      OPEN cr_crapage(pr_cdcooper => rw_crapepr.cdcooper, pr_cdagenci => rw_crapass.cdagenci);
      FETCH cr_crapage
        INTO rw_crapage;
      CLOSE cr_crapage;
    
      OPEN cr_crappep(pr_cdcooper => rw_crapepr.cdcooper,
                      pr_nrdconta => rw_crapepr.nrdconta,
                      pr_nrctremp => rw_crapepr.nrctremp);
      FETCH cr_crappep
        INTO rw_crappep;
      IF cr_crappep%NOTFOUND THEN
        vr_arqlog_erro := vr_arqlog_erro ||
                          to_clob(chr(10) ||
                                  'Associado sem dados de Data de Vencimento: Cooperativa ' ||
                                  rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta ||
                                  'Contrato ' || rw_crapepr.nrctremp);
        CLOSE cr_crappep;
      ELSE
        CLOSE cr_crappep;
      END IF;
    
      IF rw_crapass.inpessoa = 1 THEN
        vr_tp_pes := 1;
        OPEN cr_natocup(pr_cdcooper => rw_crapepr.cdcooper, pr_nrdconta => rw_crapepr.nrdconta);
        FETCH cr_natocup
          INTO vr_cdnatopc;
        CLOSE cr_natocup;
      
        IF vr_cdnatopc = 2 THEN
          vr_publico_alvo := 6;
        ELSE
          vr_publico_alvo := 2;
        END IF;
      
        OPEN cr_pessoafisica(pr_cdcooper => rw_crapepr.cdcooper,
                             pr_nrdconta => rw_crapepr.nrdconta);
        FETCH cr_pessoafisica
          INTO vr_fatura_ano;
        CLOSE cr_pessoafisica;
      ELSE
        vr_tp_pes := 2;
      
        OPEN cr_crapjur(pr_cdcooper => rw_crapepr.cdcooper, pr_nrdconta => rw_crapepr.nrdconta);
        FETCH cr_crapjur
          INTO rw_crapjur;
        CLOSE cr_crapjur;
      
        vr_fatura_ano := rw_crapjur.vlfatano;
      
        IF (nvl(rw_crapjur.vlfatano, 0) <= 360000) THEN
          vr_publico_alvo := 1;
        ELSIF (nvl(rw_crapjur.vlfatano, 0) > 360000) AND (nvl(rw_crapjur.vlfatano, 0) <= 4800000) THEN
          vr_publico_alvo := 4;
        ELSIF (nvl(rw_crapjur.vlfatano, 0) > 4800000) THEN
          vr_publico_alvo := 5;
        END IF;
      END IF;
    
      OPEN cr_cnae(rw_crapass.cdclcnae);
      FETCH cr_cnae
        INTO vr_cdcnae;
      IF cr_cnae%NOTFOUND THEN
        vr_progcredito := '39';
      ELSE
        vr_progcredito := '40';
      END IF;
      CLOSE cr_cnae;
    
      vr_gerou_detalhe := 1;
      vr_linha         := vr_linha + 1;
      vr_arqremessa    := vr_arqremessa ||
                          to_clob(chr(10) ||
                                  f_ret_detalhe_03(to_char(vr_linha),
                                                   to_char(rw_crapepr.progress_recid),
                                                   to_char(nvl(rw_crapcop.cdagectl, 0)),
                                                   to_char(nvl(rw_crapage.cdcomarc,
                                                               nvl(rw_crapmun.cdcomarc, 0))),
                                                   to_char(nvl(rw_crapass.nrcpfcgc, 0)),
                                                   to_char(vr_publico_alvo),
                                                   to_char((nvl(vr_fatura_ano, 0) * 100)),
                                                   to_char((nvl(rw_crapepr.vlemprst, 0) * 100)),
                                                   nvl(to_char(rw_crapepr.dtmvtolt, 'rrrrmmdd'),
                                                       '00000000'),
                                                   nvl(to_char(rw_crappep.dtvencto, 'rrrrmmdd'),
                                                       '00000000'),
                                                   vr_progcredito,
                                                   to_char(vr_tp_pes)));
    
      vr_arqlog_geracao := vr_arqlog_geracao ||
                           to_clob('REG 03 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                   ' Id Unico Emprestimo:  ' || rw_crapepr.progress_recid ||
                                   ' Cooperativa: ' || rw_crapcop.cdcooper || ' Conta: ' ||
                                   rw_crapepr.nrdconta || ' Contrato: ' || rw_crapepr.nrctremp ||
                                   ' Valor Financiado: ' || rw_crapepr.vlemprst ||
                                   ' Valor Solicitado: ' || rw_crapepr.valor_solicitado ||
                                   ' Financia Tarifas: ' || CASE
                                     WHEN nvl(rw_crapepr.idfiniof, 0) > 0 THEN
                                      'SIM'
                                     ELSE
                                      'NAO'
                                   END || chr(10));
    
      vr_arq_csv := vr_arq_csv ||
                    to_clob(chr(10) || to_char(rw_crapcop.cdcooper) || ';' ||
                            to_char(rw_crapepr.nrdconta) || ';' || to_char(rw_crapepr.nrctremp) || ';' ||
                            to_char(nvl(rw_crapepr.valor_solicitado, 0)));
    
      BEGIN
        UPDATE credito.tbcred_pronampe_contrato
           SET dtenvformal = SYSDATE
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrdconta = rw_crapepr.nrdconta
           AND nrcontrato = rw_crapepr.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_arqlog_erro := vr_arqlog_erro ||
                            to_clob(chr(10) ||
                                    'Erro ao atualizar a data de envio da formalização. Cooperativa ' ||
                                    rw_crapcop.cdcooper || ' Conta ' || rw_crapepr.nrdconta ||
                                    'Contrato ' || rw_crapepr.nrctremp || ' Erro:' ||
                                    SQLERRM(SQLCODE));
      END;
    END LOOP;
  
    FOR rw_craplcm IN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper,
                                 pr_cdhistor => vr_cdhistor_pronampe,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      BEGIN
        cecred.empr0001.pc_calc_saldo_deved_epr_lem(pr_cdcooper   => rw_craplcm.cdcooper,
                                                    pr_cdprogra   => 'CREDITO.GerarArquivoPronampe',
                                                    pr_cdagenci   => rw_craplcm.cdagenci,
                                                    pr_nrdcaixa   => 90,
                                                    pr_cdoperad   => rw_craplcm.cdopeori,
                                                    pr_rw_crapdat => rw_crapdat,
                                                    pr_nrdconta   => rw_craplcm.nrdconta,
                                                    pr_idseqttl   => 1,
                                                    pr_nrctremp   => rw_craplcm.nrctremp,
                                                    pr_idorigem   => 5,
                                                    pr_txdjuros   => 0,
                                                    pr_dtcalcul   => rw_crapdat.dtmvtolt,
                                                    pr_diapagto   => vr_diapagto,
                                                    pr_qtprecal   => vr_qtprecal,
                                                    pr_vlprepag   => vr_vlprepag,
                                                    pr_vlpreapg   => vr_vlpreapg,
                                                    pr_vljurmes   => vr_vljurmes,
                                                    pr_vljuracu   => vr_vljuracu,
                                                    pr_vlsdeved   => vr_vlsdeved,
                                                    pr_dtultpag   => vr_dtultpag,
                                                    pr_vlmrapar   => vr_vlmrapar,
                                                    pr_vlmtapar   => vr_vlmtapar,
                                                    pr_vliofcpl   => vr_vliofcpl,
                                                    pr_vlprvenc   => vr_vlprvenc,
                                                    pr_vlpraven   => vr_vlpraven,
                                                    pr_flgerlog   => 'N',
                                                    pr_des_reto   => vr_des_reto,
                                                    pr_tab_erro   => vr_tab_erro);
      EXCEPTION
        WHEN OTHERS THEN
          vr_arqlog_erro := vr_arqlog_erro ||
                            to_clob(chr(10) ||
                                    'Erro na chamada de empr0001.pc_calc_saldo_deved_epr_lem ' ||
                                    rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta ||
                                    'Contrato ' || rw_crapepr.nrctremp || ' Erro:' ||
                                    SQLERRM(SQLCODE));
      END;
      IF vr_des_reto = 'NOK' THEN
        vr_arqlog_erro := vr_arqlog_erro ||
                          to_clob(chr(10) ||
                                  'Erro na execução de empr0001.pc_calc_saldo_deved_epr_lem ' ||
                                  rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta ||
                                  'Contrato ' || rw_crapepr.nrctremp || ' Erro:' ||
                                  SQLERRM(SQLCODE));
        vr_vlsdeved    := NULL;
      END IF;
    
      OPEN cr_crappep(pr_cdcooper => rw_craplcm.cdcooper,
                      pr_nrdconta => rw_craplcm.nrdconta,
                      pr_nrctremp => rw_craplcm.nrctremp);
      FETCH cr_crappep
        INTO rw_crappep;
      IF cr_crappep%NOTFOUND THEN
        vr_arqlog_erro := vr_arqlog_erro ||
                          to_clob(chr(10) ||
                                  'Associado sem dados de Data de Vencimento: Cooperativa ' ||
                                  rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta ||
                                  'Contrato ' || rw_crapepr.nrctremp);
        CLOSE cr_crappep;
      ELSE
        CLOSE cr_crappep;
      END IF;
    
      vr_gerou_detalhe := 1;
      vr_linha         := vr_linha + 1;
      vr_arqremessa    := vr_arqremessa ||
                          to_clob(chr(10) ||
                                  f_ret_detalhe_04(to_char(vr_linha),
                                                   to_char(rw_craplcm.progress_recid),
                                                   nvl(to_char(rw_craplcm.dtmvtolt, 'rrrrmmdd'),
                                                       '00000000'),
                                                   to_char((nvl(rw_craplcm.vllanmto, 0) * 100)),
                                                   nvl(to_char(rw_crappep.dtvencto, 'rrrrmmdd'),
                                                       '00000000'),
                                                   to_char((nvl(rw_craplcm.vlemprst, 0) * 100)),
                                                   to_char((nvl(vr_vlsdeved, 0) * 100))));
    
      vr_arqlog_geracao := vr_arqlog_geracao ||
                           to_clob('REG 04 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                   ' Id Unico Emprestimo:  ' || rw_craplcm.progress_recid ||
                                   ' Cooperativa: ' || rw_craplcm.cdcooper || ' Conta: ' ||
                                   rw_craplcm.nrdconta || ' Contrato: ' || rw_craplcm.nrctremp ||
                                   ' Valor Liberado: ' || rw_craplcm.vllanmto || chr(10));
    END LOOP;
  
    IF to_char(rw_crapdat.dtmvtolt, 'mm') <> to_char(rw_crapdat.dtmvtoan, 'mm') THEN
      FOR rw_epr_saldo IN cr_epr_saldos(pr_cdcooper => rw_crapcop.cdcooper,
                                        pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                        pr_cdlcremp => vr_cdlcremp_pronampe,
                                        pr_cdlcrepf => vr_cdlcremp_pronampe_pf) LOOP
      
        vr_sit_honra := 0;
        OPEN cr_sit_honra(pr_cdcooper   => rw_epr_saldo.cdcooper,
                          pr_nrdconta   => rw_epr_saldo.nrdconta,
                          pr_nrcontrato => rw_epr_saldo.nrctremp);
        FETCH cr_sit_honra
          INTO vr_sit_honra;
        CLOSE cr_sit_honra;
      
        IF NVL(vr_sit_honra, 0) = 0 THEN
          vr_vlprincipal_normal := 0;
          vr_vlprincipal_atraso := 0;
          vr_vlencargos_normal  := 0;
          vr_vlencargos_atraso  := 0;
          vr_vlparcela_sjuros   := 0;
        
          IF rw_epr_saldo.inliquid = 1 AND rw_epr_saldo.inprejuz = 1 THEN
            OPEN cr_tco(pr_cdcooper => rw_epr_saldo.cdcooper,
                        pr_nrdconta => rw_epr_saldo.nrdconta,
                        pr_nrctremp => rw_epr_saldo.nrctremp);
            FETCH cr_tco
              INTO rw_tco;
            IF cr_tco%NOTFOUND THEN
              vr_arqlog_erro := vr_arqlog_erro ||
                                to_clob(chr(10) ||
                                        'Associado sem dados de Rating de Operação: Cooperativa ' ||
                                        rw_epr_saldo.cdcooper || ' Conta ' || rw_epr_saldo.nrdconta ||
                                        ' Contrato ' || rw_epr_saldo.nrctremp);
              CLOSE cr_tco;
              rw_tco.rating_operacao := 'A';
            ELSE
              IF rw_tco.rating_operacao = 'HH' THEN
                rw_tco.rating_operacao := 'H';
              END IF;
              CLOSE cr_tco;
            END IF;
          
            vr_vljurdia := 0;
          
            cecred.prej0001.pc_calcula_juros_diario(pr_cdcooper => rw_epr_saldo.cdcooper,
                                                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                    pr_dtmvtoan => rw_crapdat.dtmvtoan,
                                                    pr_nrdconta => rw_epr_saldo.nrdconta,
                                                    pr_nrctremp => rw_epr_saldo.nrctremp,
                                                    pr_flconlan => FALSE,
                                                    pr_vljurdia => vr_vljurdia,
                                                    pr_cdcritic => vr_cdcritic,
                                                    pr_dscritic => vr_dscritic);
            IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              vr_arqlog_erro := vr_arqlog_erro ||
                                to_clob(chr(10) ||
                                        'Erro ao chamar prej0001.pc_calcula_juros_diario: Cooperativa ' ||
                                        rw_epr_saldo.cdcooper || ' Conta ' || rw_epr_saldo.nrdconta ||
                                        'Contrato ' || rw_epr_saldo.nrctremp);
              CONTINUE;
            END IF;
          
            vr_qt_parc_pg  := 0;
            vr_qt_parc_npg := 0;
          
            OPEN cr_parcela(pr_cdcooper => rw_epr_saldo.cdcooper,
                            pr_nrdconta => rw_epr_saldo.nrdconta,
                            pr_nrctremp => rw_epr_saldo.nrctremp);
            FETCH cr_parcela
              INTO vr_qt_parc_pg
                  ,vr_qt_parc_npg;
            CLOSE cr_parcela;
          
            vr_vlprincipal_normal := 0;
            vr_vlprincipal_atraso := rw_epr_saldo.vlemprst / (vr_qt_parc_pg + vr_qt_parc_npg);
            vr_vlprincipal_atraso := ROUND(vr_vlprincipal_atraso * vr_qt_parc_npg, 2);
            vr_vlencargos_normal  := 0;
            vr_vlencargos_atraso  := (rw_epr_saldo.vlprejuz + rw_epr_saldo.vlttmupr +
                                     rw_epr_saldo.vlttjmpr + rw_epr_saldo.vltiofpr + vr_vljurdia +
                                     rw_epr_saldo.vljraprj) - vr_vlprincipal_atraso;
          
            vr_gerou_detalhe := 1;
            vr_linha         := vr_linha + 1;
            vr_arqremessa    := vr_arqremessa ||
                                to_clob(chr(10) ||
                                        f_ret_detalhe_05(to_char(vr_linha),
                                                         to_char(rw_epr_saldo.progress_recid),
                                                         nvl(to_char(rw_crapdat.dtultdma, 'rrrrmmdd'),
                                                             '00000000'),
                                                         to_char(ROUND(nvl(vr_vlprincipal_normal, 0),
                                                                       2) * 100),
                                                         to_char(ROUND(nvl(vr_vlprincipal_atraso, 0),
                                                                       2) * 100),
                                                         to_char(ROUND(nvl(vr_vlencargos_normal, 0),
                                                                       2) * 100),
                                                         to_char(ROUND(nvl(vr_vlencargos_atraso, 0),
                                                                       2) * 100),
                                                         rw_tco.rating_operacao));
          
            vr_arqlog_geracao := vr_arqlog_geracao ||
                                 to_clob('REG 05 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                         ' Id Unico Emprestimo:  ' || rw_epr_saldo.progress_recid ||
                                         '. Cooperativa: ' || rw_epr_saldo.cdcooper || ' Conta: ' ||
                                         rw_epr_saldo.nrdconta || ' Contrato: ' ||
                                         rw_epr_saldo.nrctremp || '. Rating da Operação: ' ||
                                         TO_CHAR(rw_tco.rating_operacao) ||
                                         '. Saldo Principal normal: ' ||
                                         to_char(ROUND(nvl(vr_vlprincipal_normal, 0), 2)) ||
                                         '. Saldo Principal atraso: ' ||
                                         to_char(ROUND(nvl(vr_vlprincipal_atraso, 0), 2)) ||
                                         '. Saldo Encargos normal: ' ||
                                         to_char(ROUND(nvl(vr_vlencargos_normal, 0), 2)) ||
                                         '. Saldo Encargos atraso: ' ||
                                         to_char(ROUND(nvl(vr_vlencargos_atraso, 0), 2)) ||
                                         '. Valor do Emprestimo: ' ||
                                         TO_CHAR(rw_epr_saldo.vlemprst) || chr(10));
          ELSE
            cecred.empr0011.pc_busca_pagto_parc_pos(pr_cdcooper      => rw_epr_saldo.cdcooper,
                                                    pr_cdprogra      => 'PRON',
                                                    pr_flgbatch      => FALSE,
                                                    pr_dtmvtolt      => rw_crapdat.dtmvtolt,
                                                    pr_dtmvtoan      => rw_crapdat.dtmvtoan,
                                                    pr_nrdconta      => rw_epr_saldo.nrdconta,
                                                    pr_nrctremp      => rw_epr_saldo.nrctremp,
                                                    pr_dtefetiv      => rw_epr_saldo.dtmvtolt,
                                                    pr_cdlcremp      => rw_epr_saldo.cdlcremp,
                                                    pr_vlemprst      => rw_epr_saldo.vlemprst,
                                                    pr_txmensal      => rw_epr_saldo.txmensal,
                                                    pr_dtdpagto      => rw_epr_saldo.dtdpagto,
                                                    pr_vlsprojt      => rw_epr_saldo.vlsprojt,
                                                    pr_qttolatr      => 0,
                                                    pr_tab_parcelas  => vr_tab_parcelas,
                                                    pr_tab_calculado => vr_tab_calculado,
                                                    pr_cdcritic      => vr_cdcritic,
                                                    pr_dscritic      => vr_dscritic);
          
            IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              vr_arqlog_erro := vr_arqlog_erro ||
                                to_clob(chr(10) ||
                                        'Erro ao chamar empr0011.pc_busca_pagto_parc_pos: Cooperativa ' ||
                                        rw_epr_saldo.cdcooper || ' Conta ' || rw_epr_saldo.nrdconta ||
                                        'Contrato ' || rw_epr_saldo.nrctremp);
              CONTINUE;
            END IF;
          
            IF NVL(rw_epr_saldo.qtpreemp, 0) > 0 THEN
              vr_vlparcela_sjuros := NVL(rw_epr_saldo.vlemprst, 0) / NVL(rw_epr_saldo.qtpreemp, 0);
            ELSE
              vr_vlparcela_sjuros := 0;
            END IF;
          
            IF vr_tab_parcelas.COUNT > 0 THEN
              FOR idx IN vr_tab_parcelas.FIRST .. vr_tab_parcelas.LAST LOOP
                IF vr_tab_parcelas(idx).insitpar = 2 THEN
                  vr_vlprincipal_atraso := nvl(vr_vlprincipal_atraso, 0) +
                                           nvl(vr_vlparcela_sjuros, 0);
                  IF nvl(vr_tab_parcelas(idx).vlatrpag, 0) > nvl(vr_vlparcela_sjuros, 0) THEN
                    vr_vlencargos_atraso := nvl(vr_vlencargos_atraso, 0) +
                                            (nvl(vr_tab_parcelas(idx).vlatrpag, 0) -
                                             nvl(vr_vlparcela_sjuros, 0));
                  END IF;
                ELSE
                  vr_vlprincipal_normal := nvl(vr_vlprincipal_normal, 0) +
                                           nvl(vr_vlparcela_sjuros, 0);
                  IF nvl(vr_tab_parcelas(idx).vlatrpag, 0) > nvl(vr_vlparcela_sjuros, 0) THEN
                    vr_vlencargos_normal := nvl(vr_vlencargos_normal, 0) +
                                            (nvl(vr_tab_parcelas(idx).vlatrpag, 0) -
                                             nvl(vr_vlparcela_sjuros, 0));
                  END IF;
                END IF;
              END LOOP;
            
              OPEN cr_tco(pr_cdcooper => rw_epr_saldo.cdcooper,
                          pr_nrdconta => rw_epr_saldo.nrdconta,
                          pr_nrctremp => rw_epr_saldo.nrctremp);
              FETCH cr_tco
                INTO rw_tco;
              IF cr_tco%NOTFOUND THEN
                vr_arqlog_erro := vr_arqlog_erro ||
                                  to_clob(chr(10) ||
                                          'Associado sem dados de Rating de Operação: Cooperativa ' ||
                                          rw_epr_saldo.cdcooper || ' Conta ' ||
                                          rw_epr_saldo.nrdconta || ' Contrato ' ||
                                          rw_epr_saldo.nrctremp);
                CLOSE cr_tco;
                rw_tco.rating_operacao := 'A';
              ELSE
                CLOSE cr_tco;
              END IF;
            
              IF ROUND(nvl(vr_vlprincipal_normal, 0), 2) + ROUND(nvl(vr_vlprincipal_atraso, 0), 2) >
                 NVL(rw_epr_saldo.vlemprst, 0) THEN
                vr_vlprincipal_normal := vr_vlprincipal_normal -
                                         ((ROUND(nvl(vr_vlprincipal_normal, 0), 2) +
                                         ROUND(nvl(vr_vlprincipal_atraso, 0), 2)) -
                                         NVL(rw_epr_saldo.vlemprst, 0));
              END IF;
            
              vr_gerou_detalhe := 1;
              vr_linha         := vr_linha + 1;
              vr_arqremessa    := vr_arqremessa ||
                                  to_clob(chr(10) ||
                                          f_ret_detalhe_05(to_char(vr_linha),
                                                           to_char(rw_epr_saldo.progress_recid),
                                                           nvl(to_char(rw_crapdat.dtultdma,
                                                                       'rrrrmmdd'),
                                                               '00000000'),
                                                           to_char(ROUND(nvl(vr_vlprincipal_normal,
                                                                             0),
                                                                         2) * 100),
                                                           to_char(ROUND(nvl(vr_vlprincipal_atraso,
                                                                             0),
                                                                         2) * 100),
                                                           to_char(ROUND(nvl(vr_vlencargos_normal, 0),
                                                                         2) * 100),
                                                           to_char(ROUND(nvl(vr_vlencargos_atraso, 0),
                                                                         2) * 100),
                                                           rw_tco.rating_operacao));
            
              vr_arqlog_geracao := vr_arqlog_geracao ||
                                   to_clob('REG 05 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                           ' Id Unico Emprestimo:  ' || rw_epr_saldo.progress_recid ||
                                           '. Cooperativa: ' || rw_epr_saldo.cdcooper || ' Conta: ' ||
                                           rw_epr_saldo.nrdconta || ' Contrato: ' ||
                                           rw_epr_saldo.nrctremp || '. Rating da Operação: ' ||
                                           TO_CHAR(rw_tco.rating_operacao) ||
                                           '. Saldo Principal normal: ' ||
                                           to_char(ROUND(nvl(vr_vlprincipal_normal, 0), 2)) ||
                                           '. Saldo Principal atraso: ' ||
                                           to_char(ROUND(nvl(vr_vlprincipal_atraso, 0), 2)) ||
                                           '. Saldo Encargos normal: ' ||
                                           to_char(ROUND(nvl(vr_vlencargos_normal, 0), 2)) ||
                                           '. Saldo Encargos atraso: ' ||
                                           to_char(ROUND(nvl(vr_vlencargos_atraso, 0), 2)) ||
                                           '. Valor do Emprestimo: ' ||
                                           TO_CHAR(rw_epr_saldo.vlemprst) || chr(10));
            END IF;
          END IF;
        ELSE
          vr_arqlog_geracao := vr_arqlog_geracao ||
                               to_clob('REG 05 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                       ' Id Unico Emprestimo:  ' || rw_epr_saldo.progress_recid ||
                                       '. Cooperativa: ' || rw_epr_saldo.cdcooper || ' Conta: ' ||
                                       rw_epr_saldo.nrdconta || ' Contrato: ' ||
                                       rw_epr_saldo.nrctremp ||
                                       '. Motivo: Saldo nao enviado em funcao da operacao ja ter sido honrada.' ||
                                       chr(10));
        END IF;
        BEGIN
          UPDATE credito.tbcred_pronampe_contrato
             SET tbcred_pronampe_contrato.vlsaldocontrato = ROUND(nvl(vr_vlprincipal_normal, 0) +
                                                                  nvl(vr_vlprincipal_atraso, 0),
                                                                  2)
           WHERE cdcooper = rw_epr_saldo.cdcooper
             AND nrdconta = rw_epr_saldo.nrdconta
             AND nrcontrato = rw_epr_saldo.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao alterar TBCRED_PRONAMPE_CONTRATO: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END LOOP;
    END IF;
    IF nvl(vr_coop_honra, 'NAO') = 'SIM' THEN
      IF TRUE THEN
        cecred.tela_pronam.pc_consultar_contratos(pr_cdcooper         => rw_crapcop.cdcooper,
                                                  pr_nrdconta         => 0,
                                                  pr_nrctremp         => 0,
                                                  pr_nriniseq         => NULL,
                                                  pr_nrregist         => NULL,
                                                  pr_datrini          => 181,
                                                  pr_datrfim          => 999,
                                                  pr_contratospronamp => vr_contratospronamp,
                                                  pr_cdcritic         => vr_cdcritic,
                                                  pr_dscritic         => vr_dscritic);
        IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        vr_idx := vr_contratospronamp.first;
        WHILE vr_idx IS NOT NULL LOOP
          IF (vr_contratospronamp(vr_idx).inbloqueiohonra = 0 AND vr_contratospronamp(vr_idx).tpsituacaohonra = 0) THEN
            credito.calcularValorHonraPronampe(pr_cdcooper   => vr_contratospronamp(vr_idx).cdcooper,
                                               pr_dtcontrato => trunc(vr_contratospronamp(vr_idx).dtvlrcredit),
                                               pr_dtmvtolt   => rw_crapdat.dtmvtoan,
                                               pr_vlsaldo    => vr_contratospronamp(vr_idx).vlsaldocontrato,
                                               pr_vldHonra   => vr_vldHonra,
                                               pr_cdcritic   => vr_cdcritic,
                                               pr_dscritic   => vr_dscritic);
            IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            IF vr_vldHonra > 0 THEN
              vr_gerou_detalhe  := 1;
              vr_linha          := vr_linha + 1;
              vr_arqremessa     := vr_arqremessa ||
                                   to_clob(chr(10) ||
                                           f_ret_detalhe_06(to_char(vr_linha),
                                                            to_char(vr_contratospronamp(vr_idx).progress_recid),
                                                            nvl(to_char(vr_contratospronamp(vr_idx).dtiniatraso,
                                                                        'rrrrmmdd'),
                                                                '00000000'),
                                                            nvl(to_char(rw_crapdat.dtmvtolt,
                                                                        'rrrrmmdd'),
                                                                '00000000'),
                                                            to_char(ROUND(nvl(vr_vldHonra, 0), 2) * 100)));
              vr_arqlog_geracao := vr_arqlog_geracao ||
                                   to_clob('REG 06 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                           ' Id Unico Emprestimo:  ' || vr_contratospronamp(vr_idx).progress_recid ||
                                           '. Cooperativa: ' || vr_contratospronamp(vr_idx).cdcooper ||
                                           ' Conta: ' || vr_contratospronamp(vr_idx).nrdconta ||
                                           ' Contrato: ' || vr_contratospronamp(vr_idx).nrctremp ||
                                           '. Valor do Emprestimo: ' ||
                                           TO_CHAR(vr_contratospronamp(vr_idx).vlemprst) ||
                                           '. Valor do Saldo Atualizado: ' || TO_CHAR(vr_vldHonra) ||
                                           chr(10));
              BEGIN
                UPDATE credito.tbcred_pronampe_contrato
                   SET dtsolicitacaohonra = rw_crapdat.dtmvtolt
                      ,vlsolicitacaohonra = vr_vldHonra
                      ,tpsituacaohonra    = 1
                 WHERE cdcooper = vr_contratospronamp(vr_idx).cdcooper
                   AND nrdconta = vr_contratospronamp(vr_idx).nrdconta
                   AND nrcontrato = vr_contratospronamp(vr_idx).nrctremp;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao alterar TBCRED_PRONAMPE_CONTRATO: ' || SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF;
          vr_idx := vr_contratospronamp.next(vr_idx);
        END LOOP;
      END IF;
    
      credito.obterparcelaspronampe(pr_cdcooper      => rw_crapcop.cdcooper,
                                    pr_liqparpronamp => vr_liqparpronamp,
                                    pr_cdcritic      => vr_cdcritic,
                                    pr_dscritic      => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      vr_idx := vr_liqparpronamp.first;
      WHILE vr_idx IS NOT NULL LOOP
        vr_gerou_detalhe  := 1;
        vr_linha          := vr_linha + 1;
        vr_arqremessa     := vr_arqremessa ||
                             to_clob(chr(10) ||
                                     f_ret_detalhe_07(to_char(vr_linha),
                                                      to_char(vr_liqparpronamp(vr_idx).progress_recid),
                                                      nvl(to_char(vr_liqparpronamp(vr_idx).dtultpag,
                                                                  'rrrrmmdd'),
                                                          '00000000'),
                                                      to_char((nvl(vr_liqparpronamp(vr_idx).vlpagpar,
                                                                   0) * 100))));
        vr_arqlog_geracao := vr_arqlog_geracao ||
                             to_clob('REG 07 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                     ' Id Unico Emprestimo:  ' || vr_liqparpronamp(vr_idx).progress_recid ||
                                     '. Cooperativa: ' || vr_liqparpronamp(vr_idx).cdcooper ||
                                     ' Conta: ' || vr_liqparpronamp(vr_idx).nrdconta ||
                                     ' Contrato: ' || vr_liqparpronamp(vr_idx).nrctremp ||
                                     '. Data Pagamento: ' ||
                                     to_char(vr_liqparpronamp(vr_idx).dtultpag, 'dd/mm/rrrr') ||
                                     '. Valor Pagamento: ' ||
                                     TO_CHAR(nvl(vr_liqparpronamp(vr_idx).vlpagpar, 0)) || chr(10));
      
        rw_repasse            := NULL;
        rw_repasse.cdcooper   := vr_liqparpronamp(vr_idx).cdcooper;
        rw_repasse.nrdconta   := vr_liqparpronamp(vr_idx).nrdconta;
        rw_repasse.nrcontrato := vr_liqparpronamp(vr_idx).nrctremp;
        rw_repasse.nrremessa  := nvl(vr_seq_arquivo, 0);
        rw_repasse.idcontrato := vr_liqparpronamp(vr_idx).progress_recid;
        rw_repasse.dtrepasse  := vr_liqparpronamp(vr_idx).dtultpag;
        rw_repasse.vlrepasse  := vr_liqparpronamp(vr_idx).vlpagpar;
      
        credito.incluirRepassePronamp(pr_repasse  => rw_repasse,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        vr_vlrepasse := 0;
        OPEN cr_totrepasse(pr_cdcooper   => rw_repasse.cdcooper,
                           pr_nrdconta   => rw_repasse.nrdconta,
                           pr_nrcontrato => rw_repasse.nrcontrato);
        FETCH cr_totrepasse
          INTO rw_totrepasse;
        IF cr_totrepasse%NOTFOUND THEN
          vr_vlrepasse := 0;
        ELSE
          vr_vlrepasse := rw_totrepasse.vlrepasse;
        END IF;
        CLOSE cr_totrepasse;
      
        rw_contrato                := NULL;
        rw_contrato.cdcooper       := rw_repasse.cdcooper;
        rw_contrato.nrdconta       := rw_repasse.nrdconta;
        rw_contrato.nrcontrato     := rw_repasse.nrcontrato;
        rw_contrato.vltotalrepasse := vr_vlrepasse;
      
        CREDITO.atualizarContratoPronamp(pr_contrato => rw_contrato,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
      
        IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        vr_idx := vr_liqparpronamp.next(vr_idx);
      END LOOP;
    END IF;
  
    FOR rw_tbcred_pronampe_contrato IN cr_tbcred_pronampe_contrato(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      vr_gerou_detalhe := 1;
      vr_linha         := vr_linha + 1;
      vr_arqremessa    := vr_arqremessa ||
                          to_clob(chr(10) || f_ret_detalhe_11(to_char(vr_linha),
                                                              to_char(rw_tbcred_pronampe_contrato.progress_recid),
                                                              nvl(to_char(rw_tbcred_pronampe_contrato.dtcancelamento,
                                                                          'rrrrmmdd'),
                                                                  '00000000')));
    
      vr_arqlog_geracao := vr_arqlog_geracao ||
                           to_clob('REG 11 Linha: ' || f_ret_campo(vr_linha, 7, 'N') ||
                                   ' Cooperativa: ' || rw_tbcred_pronampe_contrato.cdcooper ||
                                   ' Conta: ' || rw_tbcred_pronampe_contrato.nrdconta ||
                                   ' Contrato no Aimaro: ' ||
                                   rw_tbcred_pronampe_contrato.nrcontrato || ' Contrato no BB: ' ||
                                   rw_tbcred_pronampe_contrato.progress_recid ||
                                   ' Data Cancelamento: ' ||
                                   rw_tbcred_pronampe_contrato.dtcancelamento || chr(10));
    END LOOP;
  END LOOP;

  vr_linha      := vr_linha + 1;
  vr_arqremessa := vr_arqremessa || to_clob(chr(10) || f_ret_trailer(to_char(vr_linha)));

  IF vr_gerou_detalhe = 1 THEN
    vr_arquivo  := 'BRP.CDT.GFG010.D' || to_char(SYSDATE, 'rrmmdd') || '.BR.OEAIL.H' ||
                   to_char(SYSDATE, 'HH24MISS');
    vr_arquivo2 := 'BRP.CDT.GFG010.D' || to_char(SYSDATE, 'rrmmdd') || '.BR.OEAIL.H' ||
                   to_char(SYSDATE, 'HH24MISS') || '_UNIX';
    cecred.gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arqremessa),
                                         pr_caminho  => vr_caminho_arquivo_tmp,
                                         pr_arquivo  => vr_arquivo2,
                                         pr_flappend => 'N',
                                         pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 1044;
      vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic) || ' Caminho: ' ||
                     vr_caminho_arquivo_tmp || vr_arquivo2 || ', erro: ' || vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
  
    vr_dscomando := 'ux2dos < ' || vr_caminho_arquivo_tmp || vr_arquivo2 || ' | tr -d "\032" ' ||
                    ' > ' || vr_caminho_arquivo_envia || vr_arquivo || ' 2>/dev/null';
  
    cecred.GENE0001.pc_OScommand(pr_typ_comando => 'S',
                                 pr_des_comando => vr_dscomando,
                                 pr_typ_saida   => vr_typ_saida,
                                 pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;
  
    cecred.gene0001.pc_oscommand_shell('rm ' || vr_caminho_arquivo_tmp || vr_arquivo2);
  END IF;

  IF vr_gerou_detalhe = 1 THEN
    vr_arquivo := to_char(SYSDATE, 'rrrrmmdd') || '_' || lpad(to_char(vr_seq_arquivo), 4, '0') ||
                  '_CSV.CSV';
    cecred.gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arq_csv),
                                         pr_caminho  => vr_caminho_arquivo_log,
                                         pr_arquivo  => vr_arquivo,
                                         pr_flappend => 'N',
                                         pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 1044;
      vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic) || ' Caminho: ' ||
                     vr_caminho_arquivo_log || vr_arquivo || ', erro: ' || vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
  END IF;

  vr_arquivo := to_char(SYSDATE, 'rrrrmmdd') || '_' || lpad(to_char(vr_seq_arquivo), 4, '0') ||
                '_ERROS.TXT';
  cecred.gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arqlog_erro),
                                       pr_caminho  => vr_caminho_arquivo_log,
                                       pr_arquivo  => vr_arquivo,
                                       pr_flappend => 'N',
                                       pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    vr_cdcritic := 1044;
    vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic) || ' Caminho: ' ||
                   vr_caminho_arquivo_log || vr_arquivo || ', erro: ' || vr_dscritic;
    RAISE vr_exc_erro;
  END IF;

  vr_arquivo := to_char(SYSDATE, 'rrrrmmdd') || '_' || lpad(to_char(vr_seq_arquivo), 4, '0') ||
                '_LOG.TXT';
  cecred.gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arqlog_geracao),
                                       pr_caminho  => vr_caminho_arquivo_log,
                                       pr_arquivo  => vr_arquivo,
                                       pr_flappend => 'N',
                                       pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    vr_cdcritic := 1044;
    vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic) || ' Caminho: ' ||
                   vr_caminho_arquivo_log || vr_arquivo || ', erro: ' || vr_dscritic;
    RAISE vr_exc_erro;
  END IF;

  IF vr_gerou_detalhe = 1 AND NOT vr_inremgerada THEN
    BEGIN
      INSERT INTO credito.tbcred_pronampe_remessa
        (nrremessa
        ,dtremessa
        ,dhgeracao
        ,cdsituacao)
      VALUES
        (vr_seq_arquivo
        ,rw_crapdat.dtmvtolt
        ,SYSDATE
        ,1);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao gravar TBCRED_PRONAMPE_REMESSA: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
  END IF;

  geraLog(pr_dsexecut => 'Operação realizada com sucesso.');
  
  COMMIT;  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    IF NVL(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
      vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    geraLog(pr_dsexecut => vr_cdcritic || ' - ' || vr_dscritic);
  
  WHEN OTHERS THEN
    ROLLBACK;
    geraLog(pr_dsexecut => SQLCODE || ' - ' || SQLERRM);
END;
