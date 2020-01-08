declare

begin
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('CADMOB', 5, '@,C,A,E', 'CADASTRO DE MODALIDADE OPERACAO BACEN', 'CADASTRO DE MOD. OPER. BACEN', 0, 1, ' ', 'ACESSO,CONSULTAR MODALIDADE,ALTERAR MODALIDADE,EXCLUIR MODALIDADE', 1, 3, 1, 0, 1, 1, ' ', 2);

  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CADMOB', 'CADASTRO DE MODALIDADE OPERACAO BACEN', ' ', ' ', ' ', 50, (select max(c.nrordprg) + 1
                                                                                           from crapprg c
                                                                                          where c.nmsistem = 'CRED'
                                                                                            and c.nrsolici = 50), 1, 0, 0, 0, 0, 0, 1, 3, null);

  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CADMOB', 'A', 'f0030445', 3, 2);

  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CADMOB', 'C', 'f0030445', 3, 2);

  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CADMOB', 'E', 'f0030445', 3, 2);

  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CADMOB', 'A', 'f0030907', 3, 2);

  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CADMOB', 'C', 'f0030907', 3, 2);

  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CADMOB', 'E', 'f0030907', 3, 2);

  commit;
end;
