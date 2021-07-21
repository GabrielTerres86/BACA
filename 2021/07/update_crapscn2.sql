begin

update crapaca set crapaca.lstparam = 'pr_cddopcao,pr_tparrecd,pr_cdempres,pr_cdempcon,pr_cdsegmto,pr_nmrescon,pr_nmextcon,pr_cdhistor,pr_dsdianor,pr_nrrenorm,pr_nrtolera,pr_dtcancel,pr_nrlayout,pr_vltarcxa,pr_vltardeb,pr_vltarint,pr_vltartaa,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_flgacrfb,pr_forma_arrecadacao,pr_seq_arrecadacao,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo,pr_situacaoRFB,pr_arqRFB,pr_dirArqRetorno,pr_dirArqEnvio,pr_dirArqRetorno2,pr_nmArqRFBTIVIT,pr_hrInicioEnvioRemessa,pr_hrFinalEnvioRemessa,pr_intervaloEnvioRemessa,pr_dtUltExecucaoRemessa,pr_dsEmailMonitoracao'
  where crapaca.nmpackag = 'TELA_CONVEN' and crapaca.nmdeacao = 'GRAVAR_DADOS_CONVEN_RECEITA';

commit;
end;