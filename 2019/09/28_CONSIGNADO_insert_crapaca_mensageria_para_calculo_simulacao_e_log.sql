
insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'SIM_BUSCA_DADOS_CALC_FIS', 'EMPR0020', 'pc_busca_dados_soa_fis_calcula', '', (select NRSEQRDR from crapRDR where nmprogra = 'TELA_ATENDA_SIMULACAO'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'SIM_LOG_ERRO_SOA_FIS_CALCULA', 'EMPR0020', 'prc_log_erro_soa_fis_calcula', '', (select NRSEQRDR from crapRDR where nmprogra = 'TELA_ATENDA_SIMULACAO'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'PRO_BUSCA_DADOS_CALC_FIS', 'EMPR0020', 'pc_busca_dados_soa_fis_calcula', '', (select NRSEQRDR from crapRDR where nmprogra = 'TELA_ATENDA_EMPRESTIMO'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'PRO_LOG_ERRO_SOA_FIS_CALCULA', 'EMPR0020', 'prc_log_erro_soa_fis_calcula', '', (select NRSEQRDR from crapRDR where nmprogra = 'TELA_ATENDA_EMPRESTIMO'));

COMMIT;