declare
  vr_nrseqrdr number;
BEGIN
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop where cdcooper = 3) LOOP 
    insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
    values ('TANQUE', 5, '@,C', 'Listar e reprocessar lançamentos Pix', 'Listar e reprocessar lançamentos Pix', 0, 1, ' ', 'ACESSO,CONSULTAR,INSERIR,ALTERAR,EXCLUIR', 2, rw_crapcop.cdcooper, 1, 0, 0, 0, ' ', 0);
	
    insert into crapprg (nmsistem,cdprogra,dsprogra##1,dsprogra##2,dsprogra##3,dsprogra##4,nrsolici,nrordprg,inctrprg,cdrelato##1,cdrelato##2,cdrelato##3,cdrelato##4,cdrelato##5,inlibprg,cdcooper)
    values ('CRED','TANQUE', 'Listar e reprocessar lançamentos Pix',NULL,NULL,NULL,NULL,NULL,1,0,0,0,0,0,0,rw_crapcop.cdcooper);
  END LOOP;  


  insert into craprdr(nmprogra,dtsolici) values('TELA_TANQUE',sysdate) returning nrseqrdr into vr_nrseqrdr;

 INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('BUSCA_TOTAIS_TANQUE','TELA_TANQUE','pc_busca_totais_tanque','pr_cdcooper',vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('LISTA_TANQUE','TELA_TANQUE','pc_lista_tanque','pr_cdcooper,pr_nrregist,pr_nriniseq,pr_id',vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('ATUALIZA_TANQUE','TELA_TANQUE','pc_atualiza_tanque','pr_cdcooper,pr_ids',vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('ATUALIZA_TODOS_TANQUE','TELA_TANQUE','pc_atualiza_todos_tanque','pr_cdcooper',vr_nrseqrdr);
        
  COMMIT;
END;
