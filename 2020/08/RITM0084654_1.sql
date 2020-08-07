declare
  nm_nrseqrdr craprdr.nrseqrdr%type;
begin

  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '0', 'Todos');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '1', 'Cambio');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '2', 'Cartao de Credito');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '3', 'Cobranca Bancaria');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '4', 'Consorcio / Seguro / Previdencia');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '5', 'Abertura de conta');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '6', 'Pagamentos / Convenios');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '7', 'Deposito');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '8', 'Cheques');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '9', 'Investimentos');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '10', 'Operacoes de Credito');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '11', 'Saque');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '12', 'TED');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '13', 'Vendas com Cartoes');
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '14', 'Outros');

  insert into craprdr (nmprogra,dtsolici) values ('TELA_MANPLD',sysdate) returning nrseqrdr into nm_nrseqrdr;
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('MANPLD_LISTA_PRODUTOS','TELA_MANPLD','pc_lista_produtos',null,nm_nrseqrdr);
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('MANPLD_LISTA_CONSULTA','TELA_MANPLD','pc_dados_consulta','pr_nrregist,pr_nriniseq,pr_nrdconta,pr_nrcpfcgc,pr_tproduto,pr_dtinicio,pr_datfinal',nm_nrseqrdr);
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('MANPLD_LISTA_INSERIR', 'TELA_MANPLD','pc_inserir_proposta','pr_idorigem,pr_nrseqdig,pr_flgcoope,pr_dtmvtolt,pr_nrcpfcgc,pr_nrdconta,pr_nmpessoa,pr_tproduto,pr_vllanmto,pr_observac', nm_nrseqrdr);
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('MANPLD_LISTA_ALTERAR', 'TELA_MANPLD','pc_alterar_proposta', 'pr_codrowid,pr_observac', nm_nrseqrdr);

  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 1, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 2, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 3, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 4, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 5, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 6, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 7, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 8, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 9, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 10, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 11, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 12, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 13, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 14, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 15, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 16, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'MANPLD', 'Manutencao e Cadastro de PLD', '.', '.', '.', 50, (SELECT max(nrsolici)+1 FROM crapprg), 1, 0, 0, 0, 0, 0, 1, 17, null);

  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 1, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 2, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 3, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 4, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 5, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 6, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 7, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 8, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 9, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 10, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 11, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 12, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 13, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 14, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 15, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 16, 1, 0, 1, 1, ' ', 2);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('MANPLD', 5, 'C,I,A', 'Manutencao e Cadastro de PLD', 'Manutencao e Cadastro de PLD', 0, 1, ' ', 'CONSULTAR,INSERIR,ALTERAR', 1, 17, 1, 0, 1, 1, ' ', 2);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'MANPLD_EMAIL_NOVA_P', 'E-Mail para enviar nova proposta inserida.', 'coaf@ailos.coop.br');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'MANPLD_ENVIA_NOVA_P', 'Flag que baliza envio de nova proposta inserida.', 1);

  commit;

end;