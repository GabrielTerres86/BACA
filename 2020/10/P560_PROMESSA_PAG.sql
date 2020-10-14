insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCAR_PROMESSAS_PAG', '', 'RECUPERACAO.buscarPromessasPagamento', 'pr_nrdconta,pr_nrcontrato', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_COBEMP'));

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('CONTROLA_PROMESSA', '', 'RECUPERACAO.ControlarPromessaPag', 'pr_nrdconta,pr_nrctremp,pr_idpromes,pr_tpdtrata', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_COBEMP'));

insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (5027, '5027 - Boleto gerado com sucesso, mas ocorreu um erro ao gerar a promessa para o contrato.', 4, 0);

insert into recuperacao.tbrecup_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('SITUA_PROMESSA', '0', 'Pendente');

insert into recuperacao.tbrecup_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('SITUA_PROMESSA', '1', 'Em Processamento');

insert into recuperacao.tbrecup_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('SITUA_PROMESSA', '2', 'Processado');

insert into recuperacao.tbrecup_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('SITUA_PROMESSA', '3', 'Erro');

insert into recuperacao.tbrecup_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('SITUA_PROMESSA', '4', 'Envio Cancelado');

insert into recuperacao.tbrecup_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('STATUS_PROMESSA', '1', 'Inclusao');

insert into recuperacao.tbrecup_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('STATUS_PROMESSA', '2', 'Cancelamento');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'LISTA_CANAL_PROMESSA', 'Lista de canal que deve gerar promessa de pagamento', '5');

commit;
