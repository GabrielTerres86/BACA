
insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '0', 'CDC Diversos');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '1', 'CDC Ve�culos');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '10', 'Rating');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '2', 'Empr�stimos /Financiamentos');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '3', 'Desconto Cheques - Limite');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '4', 'Desconto Cheques - Border�');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '5', 'Desconto de T�tulo - Limite');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '6', 'Desconto de T�tulo - Border�');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '7', 'Cart�o de Cr�dito');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '8', 'Limite de Cr�dito');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('TPPRODUTO_ANALISE', '9', 'Consignado');

commit;

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'QTD_DIAS_EXIBE_PROP_IB', 'Quantidade de dias para determinar quando as propostas/simula��es n�o devem mais ser apresentadas na conta online.', '60');

UPDATE tbcadast_dominio_campo x
  set x.nmdominio = trim(x.nmdominio)
where x.nmdominio = 'TPRENDA '
and x.cddominio = 7;

COMMIT;

/
DECLARE
  vr_nrseqrdr NUMBER;
  vr_nrseqaca NUMBER;

BEGIN

  SELECT nrseqrdr INTO vr_nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ANALISE_CREDITO';

  INSERT INTO cecred.crapaca
    ( nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    (
     'INSERE_CONTROLE_ACESSO',
     'TELA_ANALISE_CREDITO',
     'pc_insere_analise_cred_acessos',
     'pr_cdcooper, pr_nrdconta, pr_cdoperador, pr_nrcontrato, pr_tpproduto, pr_dhinicio_acesso, pr_dhfim_acesso, pr_idanalise_contrato_acesso',
     vr_nrseqrdr);
  COMMIT;
END;
/
