BEGIN
  
    insert into cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('GRAVAR_DADOS_CONVEN_RECEITA', 'TELA_CONVEN', 'pc_grava_conv_receita', 'pr_cddopcao,pr_tparrecd,pr_cdempres,pr_cdempcon,pr_cdsegmto,pr_nmrescon,pr_nmextcon,pr_cdhistor,pr_dsdianor,pr_nrrenorm,pr_nrtolera,pr_dtcancel,pr_nrlayout,pr_vltarcxa,pr_vltardeb,pr_vltarint,pr_vltartaa,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_flgacrfb,pr_forma_arrecadacao,pr_seq_arrecadacao,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));

    update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_codfebraban,pr_cdsegmento,pr_nmfantasia,pr_rzsocial,pr_flgaccec,pr_flgacsic,pr_flgacbcb,flgacrfb,pr_vltarint,pr_vltarcxa,pr_vltartaa,pr_vltardeb,pr_forma_arrecadacao,pr_layout_arrecadacao,pr_tam_optante,pr_origem_inclusao,pr_cod_arquivo,pr_cdcooper,pr_banco,pr_intpconvenio,pr_envia_relatorio_mensal,pr_arq_unico,pr_tipo_envio,pr_diretorio_accesstage,pr_vencto_contrato,pr_envia_relatorio_para,pr_seq_arrecadacao,pr_arq_arrecadacao,pr_envia_arq_parcial,pr_seq_parcial,pr_arq_parcial,pr_valida_vncto,pr_dias_tolera,pr_seq_integracao,pr_arq_integracao,pr_seq_cadastro_retorno,pr_arq_cadastro_optante,pr_arq_retorno,pr_layout_debito,pr_usa_agencia,pr_acata_duplicacao,pr_inclui_debito_facil,pr_envia_alterta_pos,pr_declaracao,pr_valida_cpfcnpj,pr_debita_sem_saldo,pr_envia_data_repasse,pr_identifica_fatura,pr_gera_reg_j,pr_hist_pagto,pr_hist_deb_auto,pr_hist_rep_ailos,pr_conta_deb_filiada,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo' where NMDEACAO = 'GRAVAR_DADOS_CONVEN_AILOS';

    update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_nmfantasia,pr_rzsocial,pr_cdhistor,pr_codfebraban,pr_cdsegmento,pr_vltarint,pr_vltartaa,pr_vltarcxa,pr_vltardeb,pr_vltarcor,pr_vltararq,pr_nrrenorm,pr_nrtolera,pr_dsdianor,pr_dtcancel,pr_layout_arrecadacao,pr_flgaccec,pr_flgacsic,pr_flgacbcb,flgacrfb,pr_forma_arrecadacao,pr_nrlayout_debaut,pr_tam_optante,pr_cdmodalidade,pr_dsdsigla,pr_nrseqint,pr_nrseqatu,pr_canaisli' where NMDEACAO = 'GRAVAR_DADOS_CONVEN_PARC';

    delete from tbfin_remessa_fluxo_caixa where cdremessa = 20;
             
    insert into cecred.tbfin_remessa_fluxo_caixa (CDREMESSA, NMREMESSA, CDOPERADOR, DTALTERACAO, TPFLUXO_ENTRADA, TPFLUXO_SAIDA, FLREMESSA_DINAMICA)
    values (20, 'GPS RECEITA FEDERAL', '1', to_date('15-02-2021 23:03:07', 'dd-mm-yyyy hh24:mi:ss'), '1', '2', 1);

    insert into cecred.tbfin_remessa_fluxo_caixa (CDREMESSA, NMREMESSA, CDOPERADOR, DTALTERACAO, TPFLUXO_ENTRADA, TPFLUXO_SAIDA, FLREMESSA_DINAMICA)
    values (21, 'DAS RECEITA FEDERAL', '1', to_date('15-02-2021 23:03:07', 'dd-mm-yyyy hh24:mi:ss'), '1', '2', 1);

    insert into cecred.tbfin_remessa_fluxo_caixa (CDREMESSA, NMREMESSA, CDOPERADOR, DTALTERACAO, TPFLUXO_ENTRADA, TPFLUXO_SAIDA, FLREMESSA_DINAMICA)
    values (22, 'DAE RECEITA FEDERAL', '1', to_date('15-02-2021 23:03:07', 'dd-mm-yyyy hh24:mi:ss'), '1', '2', 1);

    insert into cecred.tbfin_remessa_fluxo_caixa (CDREMESSA, NMREMESSA, CDOPERADOR, DTALTERACAO, TPFLUXO_ENTRADA, TPFLUXO_SAIDA, FLREMESSA_DINAMICA)
    values (23, 'DARF 385 RECEITA FEDERAL', '1', to_date('15-02-2021 23:03:07', 'dd-mm-yyyy hh24:mi:ss'), '1', '2', 1);

    insert into cecred.tbfin_remessa_fluxo_caixa (CDREMESSA, NMREMESSA, CDOPERADOR, DTALTERACAO, TPFLUXO_ENTRADA, TPFLUXO_SAIDA, FLREMESSA_DINAMICA)
    values (24, 'DARF 64, 153 e SEM COD BARRAS RECEITA FEDERAL', '1', to_date('15-02-2021 23:03:07', 'dd-mm-yyyy hh24:mi:ss'), '1', '2', 1);

    update cecred.crapaca aca set aca.lstparam = 'pr_cdcooper,pr_dtrefere,pr_vldiv085,pr_vldiv001,pr_vldiv756,pr_vldiv748,pr_vldiv093,pr_vldivrec,pr_vldivtot,pr_vlresgat,pr_vlaplica' where aca.nmdeacao = 'FLUXOS_GRAVA_DADOS';

    insert into cecred.tbconv_receita (cdconven, cdhisrep) values ('D0432', 3467);
    insert into cecred.tbconv_receita (cdconven, cdhisrep) values ('D0328', 3467);
    insert into cecred.tbconv_receita (cdconven, cdhisrep) values ('D0064', 3467);
    insert into cecred.tbconv_receita (cdconven, cdhisrep) values ('D0385', 3467);
    insert into cecred.tbconv_receita (cdconven, cdhisrep) values ('D0153', 3467);
    insert into cecred.tbconv_receita (cdconven, cdhisrep) values ('D0100', 3467);
    insert into cecred.tbconv_receita (cdconven, cdhisrep) values ('G0270', 3467);

    update crapcon con set con.tparrecd = 4 where con.cdempcon = 432 and con.nmextcon = 'RFB -DAED';
    update crapcon con set con.tparrecd = 4 where con.cdempcon = 328 and con.nmextcon = 'DAS - SIMPLES NACIONAL';
    update crapcon con set con.tparrecd = 4 where con.cdempcon = 64 and con.nmextcon = 'DARF 81 COOP COD BARRAS 0064';
    update crapcon con set con.tparrecd = 4 where con.cdempcon = 385 and con.nmextcon = 'DARF BANCO COD BARRAS 0385';
    update crapcon con set con.tparrecd = 4 where con.cdempcon = 153 and con.nmextcon = 'DARF 81 COOP COD BARRAS 0153';
    update crapcon con set con.tparrecd = 4 where con.cdempcon = 270 and con.nmextcon = 'GUIA DA PREVIDENCIA SOCIAL';

    update crapcon con set con.cdhistor = 3464 where con.tparrecd = 4;

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'DARF_SEM_BARRA_RFB', 'Flag para controlar se o tributo DARF (sem barra) será arrecadado pela Receita Federal', '1');

    insert into cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('TAB057_REMESSAS_RECEITA_FEDERAL', 'TELA_TAB057', 'pc_busca_remessas_receita_federal', 'pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,pr_enviadoreproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TAB057'));

    insert into cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('TAB057_REGISTROS_REMESSAS_RFB', 'TELA_TAB057', 'pc_busca_registros_remessas_receita_federal', 'pr_idremessa,pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,pr_enviadoreproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TAB057'));

    insert into cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('TAB057_REENVIA_REMESSA', 'TELA_TAB057', 'pc_reenvia_remessa_pagfor', 'pr_idremessa,pr_idsicredi,pr_cdreproces', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TAB057'));

    update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_cdagenci,pr_nmextage,pr_nmresage,pr_insitage,pr_cdcxaage,pr_tpagenci,pr_cdccuage,pr_cdorgpag,pr_cdagecbn,pr_cdcomchq,pr_vercoban,pr_cdbantit,pr_cdagetit,pr_cdbanchq,pr_cdagechq,pr_cdbandoc,pr_cdagedoc,pr_flgdsede,pr_cdagepac,pr_flgutcrm,pr_dsendcop,pr_nrendere,pr_nmbairro,pr_dscomple,pr_nrcepend,pr_idcidade,pr_nmcidade,pr_cdufdcop,pr_dsdemail,pr_dsmailbd,pr_dsemailpj,pr_dsemailpf,pr_dsinform1,pr_dsinform2,pr_dsinform3,pr_hhsicini,pr_hhsicfim,pr_hhtitini,pr_hhtitfim,pr_hhcompel,pr_hhcapini,pr_hhcapfim,pr_hhdoctos,pr_hhtrfini,pr_hhtrffim,pr_hhguigps,pr_hhbolini,pr_hhbolfim,pr_hhenvelo,pr_hhcpaini,pr_hhcpafim,pr_hhlimcan,pr_hhsiccan,pr_nrtelvoz,pr_nrtelfax,pr_qtddaglf,pr_qtmesage,pr_qtddlslf,pr_flsgproc,pr_vllimapv,pr_qtchqprv,pr_flgdopgd,pr_cdageagr,pr_cddregio,pr_tpageins,pr_cdorgins,pr_vlminsgr,pr_vlmaxsgr,pr_flmajora,pr_cdagefgt,pr_cdagecai,pr_hhini_bancoob,pr_hhfim_bancoob,pr_hhcan_bancoob,pr_hhini_rfb,pr_hhfim_rfb,pr_hhcan_rfb,pr_vllimpag,pr_dtabertu,pr_dtfechto,pr_tpuniate' where NMDEACAO = 'CADPAC_GRAVA';

    update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_cdcooper,pr_hrsicatu,pr_hrsicini,pr_hrsicfim,pr_hrbanatu,pr_hrbanini,pr_hrbanfim,pr_hrrfbatu,pr_hrrfbini,pr_hrrfbfim,pr_hrtitatu,pr_hrtitini,pr_hrtitfim,pr_hrnetatu,pr_hrnetini,pr_hrnetfim,pr_hrtaaatu,pr_hrtaaini,pr_hrtaafim,pr_hrgpsatu,pr_hrgpsini,pr_hrgpsfim,pr_hrsiccau,pr_hrsiccan,pr_hrbancau,pr_hrbancan,pr_hrrfbcau,pr_hrrfbcan,pr_hrtitcau,pr_hrtitcan,pr_hrnetcau,pr_hrnetcan,pr_hrtaacau,pr_hrtaacan,pr_hrdiuatu,pr_hrdiuini,pr_hrdiufim,pr_hrnotatu,pr_hrnotini,pr_hrnotfim' where NMDEACAO = 'ALTERA_HORARIO_PARHPG';

    COMMIT;

END;