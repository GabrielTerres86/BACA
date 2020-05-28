/* Opção M - Consultar movimento de remessa */
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'CONDADOREMTED', 'PGTA0001', 'pc_consulta_dados_remessa', 'pr_cdcooper, pr_nrdconta, pr_nrremssa, pr_dtremini
, pr_dtremfim, pr_dtageini, pr_dtagefim, pr_nmfavorito, pr_situacao, pr_iniconta, pr_nrregist', 886);


/* Opção G -  Geração de Relatorios */
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'GERARELARQTED', 'PGTA0001', 'pc_gera_relato_arq_ted_web','pr_nrdconta, pr_nrremssa, pr_idstatus, pr_dtiniper, pr_dtfimper, pr_dtageini, pr_dtagefim
,pr_nmfavorito, pr_tprelato', 886);


/* Opção K -  Kit de Materiais  - Consultar */
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'CONSULTARKITMAT', 'PGTA0001', 'pc_consulta_kit_material','pr_cdcooper, pr_cdproduto', 886);


/* Opção K -  Kit de Materiais  - Incluir*/
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'INCLUIRKITMAT', 'PGTA0001', 'pc_incluir_kit_material','pr_cdcooper, pr_cdproduto, pr_nmarquivokit, pr_dsarquivokit, pr_dsdireto, pr_dsendarqkit', 886);

/* Opção K -  Kit de Materiais  - Excluir*/
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'EXCLUIRKITMAT', 'PGTA0001', 'pc_excluir_kit_material','pr_nrseqkit', 886);

/* Opção K -  Kit de Materiais  - Alterar*/
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'ALTERARKITMAT', 'PGTA0001', 'pc_alterar_kit_material','pr_nrseqkit, pr_desarquivokit_nova', 886);

/* Opção K -  Kit de Materiais  - Download*/
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'DOWNLOADKITMAT', 'PGTA0001', 'pc_download_kit_material','pr_nrseqkit, pr_idorigem', 886);


/* Opção E - Novos parametros e mudança no nome da procedure. Atenderá as opções E e H*/
Insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (null, 'IMPARQCNABTED', 'PGTA0001', 'pc_importa_arquivo_cnab_ted','pr_cdcooper,pr_nrdconta,pr_dsarquiv,pr_dsdireto,pr_operacao,pr_nmrescop 
,pr_idseqttl,pr_nrcpfope,pr_dtmvtolt,pr_iptransa,pr_cdorigem,pr_dsorigem 
,pr_cdagenci,pr_nrdcaixa,pr_nmprogra', 886);

/* Opção E/H - Ajuste de parametro */
update crapaca aca
set aca.lstparam = 'pr_cdcooper, pr_nrdconta, pr_operacao'
where aca.nmpackag = 'PGTA0001' 
and   aca.nmproced = 'pc_consulta_arquivo_remessa'; 

commit;

