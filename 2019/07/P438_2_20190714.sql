DECLARE
  vr_nrseqrdr NUMBER;
  vr_nrseqaca NUMBER;

BEGIN

  SELECT nrseqrdr INTO vr_nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ANALISE_CREDITO';

  INSERT INTO cecred.crapaca
    (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ((SELECT MAX(nrseqaca) + 1 FROM crapaca),
     'INSERE_CONTROLE_ACESSO',
     'TELA_ANALISE_CREDITO',
     'pc_insere_analise_cred_acessos',
     'pr_cdcooper, pr_nrdconta, pr_cdoperador, pr_nrcontrato, pr_tpproduto, pr_dhinicio_acesso, pr_dhfim_acesso, pr_idanalise_contrato_acesso',
     vr_nrseqrdr);
  COMMIT;
END;

/
insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '0', 'CDC Diversos');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '1', 'CDC Veículos');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '10', 'Rating');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '2', 'Empréstimos /Financiamentos');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '3', 'Desconto Cheques - Limite');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '4', 'Desconto Cheques - Borderô');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '5', 'Desconto de Título - Limite');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '6', 'Desconto de Título - Borderô');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '7', 'Cartão de Crédito');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '8', 'Limite de Crédito');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '9', 'Consignado');

commit;
