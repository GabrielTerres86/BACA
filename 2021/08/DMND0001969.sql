begin

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIAS_DUPLICPAGTO_CONV', 'Dias verificacao na duplicacao de pagto dos convenios Ailos.', '0');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'PESQ_DUPLICPAGTO_CONV', 'Verificar duplicacao de pagto dos convenios Ailos (0-Coop/1-Coop+Conta).', '0');

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCA_PARAMETRO_PARHPG', 'TELA_PARHPG', 'pc_busca_parametros_parhpg', 'pr_cdcooper', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARHPG'));

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('ALTERA_PARAMETRO_PARHPG', 'TELA_PARHPG', 'pc_altera_parametros_parhpg', 'pr_vrdupgto,pr_fgdupgto', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARHPG'));

commit;

end;