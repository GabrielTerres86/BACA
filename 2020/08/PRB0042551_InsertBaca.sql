
insert into CRAPACA (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
values 
( (select MAX(nrseqaca)+ 1 from CRAPACA), 
'LANC_FUTUROS', 
'EXTR0002', 
'pc_consulta_lancto_web', 
'pr_cdcooper,pr_cdagenci,pr_nrdcaixa,pr_cdoperad,pr_nrdconta,pr_idorigem,pr_idseqttl,pr_nmdatela,pr_flgerlog,pr_iniregis,pr_qtregpag', 
71);

COMMIT;
