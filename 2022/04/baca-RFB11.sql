begin

update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_codfebraban,pr_cdsegmento,pr_nmfantasia,pr_rzsocial,pr_flgaccec,pr_flgacsic,pr_flgacbcb,flgacrfb,pr_vltarint,pr_vltarcxa,pr_vltartaa,pr_vltardeb,pr_forma_arrecadacao,pr_layout_arrecadacao,pr_tam_optante,pr_origem_inclusao,pr_cod_arquivo,pr_cdcooper,pr_banco,pr_intpconvenio,pr_envia_relatorio_mensal,pr_arq_unico,pr_tipo_envio,pr_diretorio_accesstage,pr_vencto_contrato,pr_envia_relatorio_para,pr_seq_arrecadacao,pr_arq_arrecadacao,pr_envia_arq_parcial,pr_seq_parcial,pr_arq_parcial,pr_hr_arq_fgts,pr_valida_vncto,pr_dias_tolera,pr_seq_integracao,pr_arq_integracao,pr_seq_cadastro_retorno,pr_arq_cadastro_optante,pr_arq_retorno,pr_layout_debito,pr_usa_agencia,pr_acata_duplicacao,pr_inclui_debito_facil,pr_envia_alterta_pos,pr_declaracao,pr_valida_cpfcnpj,pr_debita_sem_saldo,pr_envia_data_repasse,pr_identifica_fatura,pr_gera_reg_j,pr_hist_pagto,pr_hist_deb_auto,pr_hist_rep_ailos,pr_conta_deb_filiada,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo' where NMDEACAO = 'GRAVAR_DADOS_CONVEN_AILOS';

update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_tparrecd,pr_cdconven,pr_nmfantasia,pr_rzsocial,pr_cdhistor,pr_codfebraban,pr_cdsegmento,pr_vltarint,pr_vltartaa,pr_vltarcxa,pr_vltardeb,pr_vltarcor,pr_vltararq,pr_nrrenorm,pr_nrtolera,pr_dsdianor,pr_dtcancel,pr_layout_arrecadacao,pr_flgaccec,pr_flgacsic,pr_flgacbcb,flgacrfb,pr_forma_arrecadacao,pr_nrlayout_debaut,pr_tam_optante,pr_cdmodalidade,pr_dsdsigla,pr_nrseqint,pr_nrseqatu,pr_canaisli' where NMDEACAO = 'GRAVAR_DADOS_CONVEN_PARC';



-- Update na CRAPACA relacionado a TELA FLUXOS, CADPAC e PARHPG

update cecred.crapaca set LSTPARAM = 'pr_cdcooper,pr_dtrefere,pr_vldiv085,pr_vldiv001,pr_vldiv756,pr_vldiv748,pr_vldiv093,pr_vldivrec,pr_vldivtot,pr_vlresgat,pr_vlaplica' where NMDEACAO = 'FLUXOS_GRAVA_DADOS';

update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_cdagenci,pr_nmextage,pr_nmresage,pr_insitage,pr_cdcxaage,pr_tpagenci,pr_cdccuage,pr_cdorgpag,pr_cdagecbn,pr_cdcomchq,pr_vercoban,pr_cdbantit,pr_cdagetit,pr_cdbanchq,pr_cdagechq,pr_cdbandoc,pr_cdagedoc,pr_flgdsede,pr_cdagepac,pr_flgutcrm,pr_dsendcop,pr_nrendere,pr_nmbairro,pr_dscomple,pr_nrcepend,pr_idcidade,pr_nmcidade,pr_cdufdcop,pr_dsdemail,pr_dsmailbd,pr_dsemailpj,pr_dsemailpf,pr_dsinform1,pr_dsinform2,pr_dsinform3,pr_hhsicini,pr_hhsicfim,pr_hhtitini,pr_hhtitfim,pr_hhcompel,pr_hhcapini,pr_hhcapfim,pr_hhdoctos,pr_hhtrfini,pr_hhtrffim,pr_hhguigps,pr_hhbolini,pr_hhbolfim,pr_hhenvelo,pr_hhcpaini,pr_hhcpafim,pr_hhlimcan,pr_hhsiccan,pr_nrtelvoz,pr_nrtelfax,pr_qtddaglf,pr_qtmesage,pr_qtddlslf,pr_flsgproc,pr_vllimapv,pr_qtchqprv,pr_flgdopgd,pr_cdageagr,pr_cddregio,pr_tpageins,pr_cdorgins,pr_vlminsgr,pr_vlmaxsgr,pr_flmajora,pr_cdagefgt,pr_cdagecai,pr_hhini_bancoob,pr_hhfim_bancoob,pr_hhcan_bancoob,pr_hhini_rfb,pr_hhfim_rfb,pr_hhcan_rfb,pr_vllimpag,pr_dtabertu,pr_dtfechto,pr_tpuniate' where NMDEACAO = 'CADPAC_GRAVA';
                                      
update cecred.crapaca set LSTPARAM = 'pr_cddopcao,pr_cdcooper,pr_hrsicatu,pr_hrsicini,pr_hrsicfim,pr_hrbanatu,pr_hrbanini,pr_hrbanfim,pr_hrrfbatu,pr_hrrfbini,pr_hrrfbfim,pr_hrtitatu,pr_hrtitini,pr_hrtitfim,pr_hrnetatu,pr_hrnetini,pr_hrnetfim,pr_hrtaaatu,pr_hrtaaini,pr_hrtaafim,pr_hrgpsatu,pr_hrgpsini,pr_hrgpsfim,pr_hrsiccau,pr_hrsiccan,pr_hrbancau,pr_hrbancan,pr_hrrfbcau,pr_hrrfbcan,pr_hrtitcau,pr_hrtitcan,pr_hrnetcau,pr_hrnetcan,pr_hrtaacau,pr_hrtaacan,pr_hrdiuatu,pr_hrdiuini,pr_hrdiufim,pr_hrnotatu,pr_hrnotini,pr_hrnotfim,pr_hrlimreprocess,pr_hrlimite' where NMDEACAO = 'ALTERA_HORARIO_PARHPG';



commit;

end;