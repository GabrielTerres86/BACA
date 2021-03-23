declare
  vr_nrseqrdr number/* := 2184*/;
BEGIN

  -- Criação dos acessos de novas telas
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop where cdcooper = 3) LOOP 
    -- LIMITE
    insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
    values ('LIMITE', 5, '@,C,I,A,E', 'Consulta e Gerenciamento de Limites', 'Consulta e Gerenciamento de Limites', 0, 1, ' ', 'ACESSO,CONSULTAR,INSERIR,ALTERAR,EXCLUIR', 2, rw_crapcop.cdcooper, 1, 0, 0, 0, ' ', 0);
    insert into CRAPPRG (nmsistem,cdprogra,dsprogra##1,dsprogra##2,dsprogra##3,dsprogra##4,nrsolici,nrordprg,inctrprg,cdrelato##1,cdrelato##2,cdrelato##3,cdrelato##4,cdrelato##5,inlibprg,cdcooper)
    values ('CRED','LIMITE', 'Consulta e Gerenciamento de Limites',NULL,NULL,NULL,989,999,1,0,0,0,0,0,0,RW_CRAPCOP.CDCOOPER);
  END LOOP;  


  insert into craprdr(nmprogra,dtsolici) 
               values('LIMITE',sysdate)
            returning nrseqrdr into vr_nrseqrdr;

 INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('LISTAR_PRODUTOS','TELA_LIMITE','pc_lista_produtos','',vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('CONSULTAR','TELA_LIMITE','pc_busca_parametros','pr_tlcooper,pr_cdprodut',vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('MANTER_PARAMETROS','TELA_LIMITE','pc_mantem_parametros','pr_tlcooper,pr_cdprodut,pr_flgativo,pr_qtdias_carencia',vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('EXCLUIR_FAIXA','TELA_LIMITE','pc_excluir_faixa','pr_idfailim',vr_nrseqrdr);
    
  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('MANTER_FAIXA','TELA_LIMITE','pc_mantem_faixa','pr_idfailim,pr_tlcooper,pr_cdprodut,pr_vlfaixa_ate,pr_vlaumento_permitido',vr_nrseqrdr);

    
  COMMIT;
END;
