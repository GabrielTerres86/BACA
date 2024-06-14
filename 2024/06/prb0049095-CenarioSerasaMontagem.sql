BEGIN

  FOR r_mae IN (SELECT *
                  FROM tbgen_prglog plog
                 WHERE trunc(plog.dhinicio) >= trunc(sysdate)
                   AND (UPPER(plog.cdprograma) like UPPER('PRB0049095%'))
                   )
  LOOP
    DELETE tbgen_prglog_ocorrencia plogoco
     WHERE plogoco.idprglog = r_mae.idprglog;
    DELETE tbgen_prglog plog
     WHERE plog.idprglog = r_mae.idprglog;
  END LOOP;

DELETE FROM crapcob cob
 WHERE (cob.cdcooper, cob.nrdconta, cob.nrcnvcob, cob.nrdocmto) IN
       ((12, 99799189, 111002, 380), (12, 83170278, 111002, 200), (12, 99842718, 111002, 1203));

DELETE FROM crapcol col
 WHERE (col.cdcooper, col.nrdconta, col.nrcnvcob, col.nrdocmto) IN
       ((12, 99799189, 111002, 380), (12, 83170278, 111002, 200), (12, 99842718, 111002, 1203));

DELETE FROM tbcobran_his_neg_serasa thns
 WHERE (thns.cdcooper, thns.nrdconta, thns.nrcnvcob, thns.nrdocmto) IN
       ((12, 99799189, 111002, 380), (12, 83170278, 111002, 200), (12, 99842718, 111002, 1203));

insert into crapcob (DTMVTOLT, INCOBRAN, NRDCONTA, NRDCTABB, CDBANDOC, NRDOCMTO, DTRETCOB, NRCNVCOB, CDOPERAD, HRTRANSA, CDCOOPER, INDPAGTO, DTDPAGTO, VLDPAGTO, VLTITULO, DSINFORM, DSDINSTR, DTVENCTO, CDCARTEI, CDDESPEC, CDTPINSC, NMDSACAD, DSENDSAC, NMBAISAC, NRCEPSAC, NMCIDSAC, CDUFSACA, CDTPINAV, CDIMPCOB, FLGIMPRE, NRINSAVA, NRINSSAC, NMDAVALI, NRDOCCOP, VLDESCTO, CDMENSAG, DSDOCCOP, IDSEQTTL, DTELIMIN, DTDBAIXA, VLABATIM, VLTARIFA, CDAGEPAG, CDBANPAG, DTDOCMTO, NRCTASAC, NRCTREMP, NRNOSNUM, INSITCRT, DTSITCRT, NRSEQTIT, FLGDPROT, QTDIAPRT, INDIAPRT, VLJURDIA, VLRMULTA, FLGACEIT, DSUSOEMP, FLGREGIS, DTLIMDSC, INEMITEN, TPJURMOR, VLOUTCRE, TPDMULTA, VLOUTDEB, FLGCBDDA, VLMULPAG, VLJURPAG, IDTITLEG, IDOPELEG, INSITPRO, NRREMASS, CDTITPRT, DCMC7CHQ, INEMIEXP, DTEMIEXP, FLSERASA, QTDIANEG, INSERASA, DTRETSER, DTBLOQUE, INPAGDIV, VLMINIMO, NRDIDENT, DHENVCIP, INENVCIP, NRISPBRC, INREGCIP, NRATUTIT, DTVCTORI, INAVISMS, INSMSANT, INSMSVCT, INSMSPOS, DTREFATU, ININSCIP, DHINSCIP, INSRVPRT, TPVLRDESC, IDLOTTCK, INFMTDOC, DTLIPGTO)
values (to_date('22-11-2023', 'dd-mm-yyyy'), 0, 83170278, 111002, 85, 200, to_date('22-11-2023', 'dd-mm-yyyy'), 111002, ' ', 0, 12, 0, null, 0.00, 260.00, ' ', ' ', to_date('30-01-2024', 'dd-mm-yyyy'), 1, 1, 1, ' ', ' ', ' ', 0, ' ', ' ', 0, 3, 1, 0.00, 85190179915.00, ' ', 0.00, 0.00, 0, 'AWO7E47/0002', 1, null, null, 0.00, 0.00, 0, 0, to_date('22-11-2023', 'dd-mm-yyyy'), 0, 0, '16829662000000200', 0, null, 0, 0, 0, 0, 0.50, 20.00, 0, ' ', 1, null, 2, 1, 0.00, 1, 0.00, 1, 0.00, 0.00, 119098659, 220834457, 3, 0, ' ', ' ', 0, null, 1, 15, 4, to_date('16-02-2024', 'dd-mm-yyyy'), null, 0, 0.00, '3023112205128576024', to_date('22-11-2023 18:16:48', 'dd-mm-yyyy hh24:mi:ss'), 3, 0, 1, '1708033573271000215', to_date('30-01-2024', 'dd-mm-yyyy'), 0, 0, 0, 0, to_date('24-05-2024', 'dd-mm-yyyy'), 2, to_date('15-02-2024 18:39:52', 'dd-mm-yyyy hh24:mi:ss'), 0, null, null, 0, to_date('29-01-2030', 'dd-mm-yyyy'));

insert into crapcob (DTMVTOLT, INCOBRAN, NRDCONTA, NRDCTABB, CDBANDOC, NRDOCMTO, DTRETCOB, NRCNVCOB, CDOPERAD, HRTRANSA, CDCOOPER, INDPAGTO, DTDPAGTO, VLDPAGTO, VLTITULO, DSINFORM, DSDINSTR, DTVENCTO, CDCARTEI, CDDESPEC, CDTPINSC, NMDSACAD, DSENDSAC, NMBAISAC, NRCEPSAC, NMCIDSAC, CDUFSACA, CDTPINAV, CDIMPCOB, FLGIMPRE, NRINSAVA, NRINSSAC, NMDAVALI, NRDOCCOP, VLDESCTO, CDMENSAG, DSDOCCOP, IDSEQTTL, DTELIMIN, DTDBAIXA, VLABATIM, VLTARIFA, CDAGEPAG, CDBANPAG, DTDOCMTO, NRCTASAC, NRCTREMP, NRNOSNUM, INSITCRT, DTSITCRT, NRSEQTIT, FLGDPROT, QTDIAPRT, INDIAPRT, VLJURDIA, VLRMULTA, FLGACEIT, DSUSOEMP, FLGREGIS, DTLIMDSC, INEMITEN, TPJURMOR, VLOUTCRE, TPDMULTA, VLOUTDEB, FLGCBDDA, VLMULPAG, VLJURPAG, IDTITLEG, IDOPELEG, INSITPRO, NRREMASS, CDTITPRT, DCMC7CHQ, INEMIEXP, DTEMIEXP, FLSERASA, QTDIANEG, INSERASA, DTRETSER, DTBLOQUE, INPAGDIV, VLMINIMO, NRDIDENT, DHENVCIP, INENVCIP, NRISPBRC, INREGCIP, NRATUTIT, DTVCTORI, INAVISMS, INSMSANT, INSMSVCT, INSMSPOS, DTREFATU, ININSCIP, DHINSCIP, INSRVPRT, TPVLRDESC, IDLOTTCK, INFMTDOC, DTLIPGTO)
values (to_date('01-02-2023', 'dd-mm-yyyy'), 5, 99799189, 111002, 85, 380, to_date('01-02-2023', 'dd-mm-yyyy'), 111002, ' ', 0, 12, 0, to_date('24-05-2024', 'dd-mm-yyyy'), 572.03, 555.55, ' ', ' ', to_date('25-04-2024', 'dd-mm-yyyy'), 1, 1, 1, ' ', ' ', ' ', 0, ' ', ' ', 0, 3, 1, 0.00, 2280942917.00, ' ', 0.00, 0.00, 0, '0000350/0012', 1, null, null, 0.00, 0.00, 1, 633, to_date('01-02-2023', 'dd-mm-yyyy'), 0, 0, '00200751000000380', 0, null, 0, 0, 0, 0, 1.00, 2.00, 0, ' ', 1, null, 2, 2, 0.00, 2, 0.00, 1, 0.00, 16.48, 96618126, 226866206, 3, 0, ' ', ' ', 0, null, 1, 15, 4, to_date('14-05-2024', 'dd-mm-yyyy'), null, 0, 0.00, '2023020103866954842', to_date('01-02-2023 18:56:55', 'dd-mm-yyyy hh24:mi:ss'), 3, 68900810, 0, '1715635774558000513', to_date('25-04-2024', 'dd-mm-yyyy'), 0, 0, 0, 0, to_date('24-05-2024', 'dd-mm-yyyy'), 2, to_date('13-05-2024 18:23:23', 'dd-mm-yyyy hh24:mi:ss'), 0, null, null, 0, to_date('23-06-2029', 'dd-mm-yyyy'));

insert into crapcob (DTMVTOLT, INCOBRAN, NRDCONTA, NRDCTABB, CDBANDOC, NRDOCMTO, DTRETCOB, NRCNVCOB, CDOPERAD, HRTRANSA, CDCOOPER, INDPAGTO, DTDPAGTO, VLDPAGTO, VLTITULO, DSINFORM, DSDINSTR, DTVENCTO, CDCARTEI, CDDESPEC, CDTPINSC, NMDSACAD, DSENDSAC, NMBAISAC, NRCEPSAC, NMCIDSAC, CDUFSACA, CDTPINAV, CDIMPCOB, FLGIMPRE, NRINSAVA, NRINSSAC, NMDAVALI, NRDOCCOP, VLDESCTO, CDMENSAG, DSDOCCOP, IDSEQTTL, DTELIMIN, DTDBAIXA, VLABATIM, VLTARIFA, CDAGEPAG, CDBANPAG, DTDOCMTO, NRCTASAC, NRCTREMP, NRNOSNUM, INSITCRT, DTSITCRT, NRSEQTIT, FLGDPROT, QTDIAPRT, INDIAPRT, VLJURDIA, VLRMULTA, FLGACEIT, DSUSOEMP, FLGREGIS, DTLIMDSC, INEMITEN, TPJURMOR, VLOUTCRE, TPDMULTA, VLOUTDEB, FLGCBDDA, VLMULPAG, VLJURPAG, IDTITLEG, IDOPELEG, INSITPRO, NRREMASS, CDTITPRT, DCMC7CHQ, INEMIEXP, DTEMIEXP, FLSERASA, QTDIANEG, INSERASA, DTRETSER, DTBLOQUE, INPAGDIV, VLMINIMO, NRDIDENT, DHENVCIP, INENVCIP, NRISPBRC, INREGCIP, NRATUTIT, DTVCTORI, INAVISMS, INSMSANT, INSMSVCT, INSMSPOS, DTREFATU, ININSCIP, DHINSCIP, INSRVPRT, TPVLRDESC, IDLOTTCK, INFMTDOC, DTLIPGTO)
values (to_date('08-05-2024', 'dd-mm-yyyy'), 3, 99842718, 111002, 85, 1203, to_date('08-05-2024', 'dd-mm-yyyy'), 111002, ' ', 0, 12, 0, null, 0.00, 391.40, ' ', ' ', to_date('18-05-2024', 'dd-mm-yyyy'), 1, 1, 2, ' ', ' ', ' ', 0, ' ', ' ', 0, 3, 1, 0.00, 17933652000858.00, ' ', 0.00, 0.00, 0, 'NFE 1022/0001', 1, null, to_date('27-05-2024', 'dd-mm-yyyy'), 0.00, 0.00, 0, 0, to_date('08-05-2024', 'dd-mm-yyyy'), 0, 0, '00157228000001203', 0, null, 0, 0, 0, 0, 1.00, 2.00, 0, ' ', 1, null, 2, 2, 0.00, 2, 0.00, 1, 0.00, 0.00, 135214543, 227679632, 3, 0, ' ', ' ', 0, null, 1, 5, 6, null, null, 0, 0.00, '3024050802919555773', to_date('08-05-2024 18:11:49', 'dd-mm-yyyy hh24:mi:ss'), 3, 0, 0, '1716671949239000525', to_date('18-05-2024', 'dd-mm-yyyy'), 0, 0, 0, 0, to_date('27-05-2024', 'dd-mm-yyyy'), 2, to_date('25-05-2024 18:16:13', 'dd-mm-yyyy hh24:mi:ss'), 0, null, null, 0, to_date('14-11-2024', 'dd-mm-yyyy'));

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Titulo gerado', '996', to_date('08-05-2024', 'dd-mm-yyyy'), 64375);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Data limite de pagamento é 14/11/2024', '996', to_date('08-05-2024', 'dd-mm-yyyy'), 64376);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Nao autoriza pagamento divergente para este boleto', '1', to_date('08-05-2024 18:00:04', 'dd-mm-yyyy hh24:mi:ss'), 64804);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Titulo enviado a CIP', '1', to_date('08-05-2024 18:00:04', 'dd-mm-yyyy hh24:mi:ss'), 64804);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Boleto registrado no Sistema Financeiro Nacional', '1', to_date('08-05-2024 18:11:49', 'dd-mm-yyyy hh24:mi:ss'), 65509);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Boleto enviado para negativacao', '1', to_date('24-05-2024 18:22:42', 'dd-mm-yyyy hh24:mi:ss'), 66162);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Alteração de Titulo Registrado no Sistema Financeiro Nacional', '1', to_date('24-05-2024 18:41:49', 'dd-mm-yyyy hh24:mi:ss'), 67309);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Falha no processo de negativacao - Motivo Retorno Serasa ', '1', to_date('25-05-2024 18:16:13', 'dd-mm-yyyy hh24:mi:ss'), 65773);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Alteração de Titulo Registrado no Sistema Financeiro Nacional', '1', to_date('25-05-2024 18:21:44', 'dd-mm-yyyy hh24:mi:ss'), 66104);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99842718, 1203, 111002, 'Instrucao de Baixa', '996', to_date('27-05-2024 07:57:43', 'dd-mm-yyyy hh24:mi:ss'), 28663);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Titulo gerado - Carne', '996', to_date('01-02-2023', 'dd-mm-yyyy'), 66862);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Data limite de pagamento é 23/06/2024', '996', to_date('01-02-2023', 'dd-mm-yyyy'), 66862);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Nao autoriza pagamento divergente para este boleto', '1', to_date('01-02-2023 18:45:09', 'dd-mm-yyyy hh24:mi:ss'), 67509);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Titulo enviado a CIP', '1', to_date('01-02-2023 18:45:09', 'dd-mm-yyyy hh24:mi:ss'), 67509);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Boleto registrado no Sistema Financeiro Nacional', '1', to_date('01-02-2023 18:56:55', 'dd-mm-yyyy hh24:mi:ss'), 68215);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Boleto enviado para negativacao', '1', to_date('13-05-2024 18:23:23', 'dd-mm-yyyy hh24:mi:ss'), 66203);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Alteração de Titulo Registrado no Sistema Financeiro Nacional', '1', to_date('13-05-2024 18:32:06', 'dd-mm-yyyy hh24:mi:ss'), 66726);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Negativacao em andamento', '1', to_date('14-05-2024 18:16:17', 'dd-mm-yyyy hh24:mi:ss'), 65777);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Serasa - Recebido informacoes apenas informacionais', '1', to_date('22-05-2024 18:16:21', 'dd-mm-yyyy hh24:mi:ss'), 65781);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Retorno Serasa 304-REGISTRO ESPECIAL - DEVOLUCAO COMUNICADO DO CORREIO - DESCONHECIDO', '1', to_date('22-05-2024 18:16:21', 'dd-mm-yyyy hh24:mi:ss'), 65781);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Liquidacao - Liq Corresp Digital', '1', to_date('24-05-2024 12:12:42', 'dd-mm-yyyy hh24:mi:ss'), 43962);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Solicitacao de cancelamento de negativacao do boleto', '1', to_date('24-05-2024 12:12:42', 'dd-mm-yyyy hh24:mi:ss'), 43962);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 99799189, 380, 111002, 'Envio do cancelamento de negativacao do boleto - Serasa', '1', to_date('24-05-2024 18:22:42', 'dd-mm-yyyy hh24:mi:ss'), 66162);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Titulo gerado', '996', to_date('22-11-2023', 'dd-mm-yyyy'), 65697);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Data limite de pagamento é 29/01/2025', '996', to_date('22-11-2023', 'dd-mm-yyyy'), 65697);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Nao autoriza pagamento divergente para este boleto', '1', to_date('22-11-2023 18:15:06', 'dd-mm-yyyy hh24:mi:ss'), 65706);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Titulo enviado a CIP', '1', to_date('22-11-2023 18:15:07', 'dd-mm-yyyy hh24:mi:ss'), 65707);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Boleto registrado no Sistema Financeiro Nacional', '1', to_date('22-11-2023 18:16:48', 'dd-mm-yyyy hh24:mi:ss'), 65808);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Boleto enviado para negativacao', '1', to_date('15-02-2024 18:39:52', 'dd-mm-yyyy hh24:mi:ss'), 67192);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Alteração de Titulo Registrado no Sistema Financeiro Nacional', '1', to_date('15-02-2024 18:51:54', 'dd-mm-yyyy hh24:mi:ss'), 67914);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Negativacao em andamento', '1', to_date('16-02-2024 18:16:59', 'dd-mm-yyyy hh24:mi:ss'), 65819);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Boleto negativado - Serasa', '1', to_date('29-02-2024 18:34:06', 'dd-mm-yyyy hh24:mi:ss'), 66846);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Solicitacao de cancelamento de negativacao do boleto', '996', to_date('24-05-2024 16:47:21', 'dd-mm-yyyy hh24:mi:ss'), 60441);

insert into crapcol (CDCOOPER, NRDCONTA, NRDOCMTO, NRCNVCOB, DSLOGTIT, CDOPERAD, DTALTERA, HRTRANSA)
values (12, 83170278, 200, 111002, 'Envio do cancelamento de negativacao do boleto - Serasa', '1', to_date('24-05-2024 18:22:42', 'dd-mm-yyyy hh24:mi:ss'), 66162);

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 99842718, 1203, 1, to_date('24-05-2024 18:22:42', 'dd-mm-yyyy hh24:mi:ss'), 2, null, '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 99842718, 1203, 2, to_date('25-05-2024 18:16:13', 'dd-mm-yyyy hh24:mi:ss'), 6, null, '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 99799189, 380, 1, to_date('13-05-2024 18:23:23', 'dd-mm-yyyy hh24:mi:ss'), 2, null, '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 99799189, 380, 2, to_date('14-05-2024 18:16:17', 'dd-mm-yyyy hh24:mi:ss'), 2, to_date('14-05-2024', 'dd-mm-yyyy'), '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 99799189, 380, 3, to_date('22-05-2024 18:16:21', 'dd-mm-yyyy hh24:mi:ss'), 2, to_date('14-05-2024', 'dd-mm-yyyy'), '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 99799189, 380, 4, to_date('24-05-2024 12:12:42', 'dd-mm-yyyy hh24:mi:ss'), 3, null, '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 99799189, 380, 5, to_date('24-05-2024 18:22:42', 'dd-mm-yyyy hh24:mi:ss'), 4, null, '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 83170278, 200, 1, to_date('15-02-2024 18:39:52', 'dd-mm-yyyy hh24:mi:ss'), 2, null, '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 83170278, 200, 2, to_date('16-02-2024 18:16:59', 'dd-mm-yyyy hh24:mi:ss'), 2, to_date('16-02-2024', 'dd-mm-yyyy'), '1');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 83170278, 200, 3, to_date('24-05-2024 16:47:21', 'dd-mm-yyyy hh24:mi:ss'), 3, null, '996');

insert into tbcobran_his_neg_serasa (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
values (12, 85, 111002, 111002, 83170278, 200, 4, to_date('24-05-2024 18:22:42', 'dd-mm-yyyy hh24:mi:ss'), 4, null, '1');

COMMIT;

END;
