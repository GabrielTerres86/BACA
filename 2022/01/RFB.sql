begin

update crapscn set crapscn.dsnomres = 'DARF64' where crapscn.cdempres = 'D0064';       
update crapscn set crapscn.dsnomres = 'DAS' where crapscn.cdempres = 'D0328';  
update crapscn set crapscn.dsnomres = 'DARF385' where crapscn.cdempres = 'D0385';  
update crapscn set crapscn.dsnomres = 'DARF153' where crapscn.cdempres = 'D0153';  
update crapscn set crapscn.dsnomres = 'DARF' where crapscn.cdempres = 'D0100';  
update crapscn set crapscn.dsnomres = 'GPS' where crapscn.cdempres = 'G0270';  
update crapscn set crapscn.dsnomres = 'DAE' where crapscn.cdempres = 'D0432';

update crapaca set crapaca.lstparam = 'pr_cddopcao,pr_tparrecd,pr_cdempres,pr_cdempcon,pr_cdsegmto,pr_nmrescon,pr_nmextcon,pr_cdhistor,pr_dsdianor,pr_nrrenorm,pr_nrtolera,pr_dtcancel,pr_nrlayout,pr_vltarcxa,pr_vltardeb,pr_vltarint,pr_vltartaa,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_flgacrfb,pr_forma_arrecadacao,pr_seq_arrecadacao,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo,pr_situacaoRFB,pr_arqRFB,pr_dirArqRetorno,pr_dirArqEnvio,pr_dirArqRetorno2,pr_nmArqRFBTIVIT,pr_hrInicioEnvioRemessa,pr_hrFinalEnvioRemessa,pr_intervaloEnvioRemessa,pr_dtUltExecucaoRemessa,pr_dsEmailMonitoracao,pr_flComprovanteRFB'
  where crapaca.nmpackag = 'TELA_CONVEN' and crapaca.nmdeacao = 'GRAVAR_DADOS_CONVEN_RECEITA';

UPDATE CRAPACA SET LSTPARAM='pr_cddopcao,pr_tparrecd,pr_cdempres,pr_cdempcon,pr_cdsegmto,pr_nmrescon,pr_nmextcon,pr_cdhistor,pr_dsdianor,pr_nrrenorm,pr_nrtolera,pr_dtcancel,pr_nrlayout,pr_vltarcxa,pr_vltardeb,pr_vltarint,pr_vltartaa,pr_flgaccec,pr_flgacsic,pr_flgacbcb,pr_flgacrfb,pr_forma_arrecadacao,pr_seq_arrecadacao,pr_repasse_banco,pr_repasse_agencia,pr_repasse_conta,pr_repasse_cnpj,pr_repasse_dia,pr_repasse_tipo,pr_arqRFB,pr_dirArqRetorno,pr_dirArqEnvio,pr_dirArqRetorno2,pr_num_ISPB,pr_agenciaRecargaCelular,pr_contaRecargaCelular,pr_cnpjRecargaCelular,pr_repasseRecargaCelular,pr_nmArqRFBTIVIT,pr_situacaoRFB,pr_hrInicioEnvioRemessa,pr_hrFinalEnvioRemessa,pr_intervaloEnvioRemessa,pr_dtUltExecucaoRemessa'
WHERE NMDEACAO='GRAVAR_DADOS_CONVEN_RECEITA';

commit;

end;