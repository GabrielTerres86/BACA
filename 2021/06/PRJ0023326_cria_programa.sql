declare
  v_nrordprg  crapprg.nrordprg%type;
  v_nrseqrdr  craprdr.nrseqrdr%type;
begin
  -- Buscar nrordprg
  select max(nrordprg)+1
    into v_nrordprg
    from crapprg p 
   where p.nmsistem = 'CRED'
     and p.nrsolici = 50;
  -- Inserir CRAPPRG
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 1, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 2, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 3, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 4, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 5, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 6, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 7, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 8, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 9, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 10, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 11, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 12, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 13, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 14, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 15, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 16, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONVPA', 'PARÂMETROS DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 17, null, null);
  -- Inserir CRAPTEL
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 1, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 2, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 3, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 4, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 5, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 6, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 7, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 8, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 9, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 10, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 11, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 12, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 13, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 14, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 15, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 16, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONVPA', 5, 'A,C,E,I', 'Parâmetros de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 17, 1, 0, 1, 1, ' ', 2, null);
  -- Inserir CRAPRDR
  insert into craprdr (nrseqrdr, nmprogra, dtsolici)
  values ((select max(nrseqrdr) + 1 from craprdr), 'TELA_CONVPA', sysdate)
  returning nrseqrdr into v_nrseqrdr;
  -- Inserir CRAPACA
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'GRAVAR_SEGMTO_LIMITE', 'TELA_CONVPA', 'pc_grava_segmto_limite', 'pr_cddopcao,pr_cdcooper,pr_cdsegmto,pr_flagbarr,pr_vllimite,pr_hrlimite,pr_vhlimite', v_nrseqrdr);
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'CONSULTAR_SEGMTO_LIMITE', 'TELA_CONVPA', 'pc_consulta_segmto_limite', 'pr_cdcooper,pr_cdsegmto,pr_flagbarr,pr_nrregist,pr_nriniseq', v_nrseqrdr);
  -- Inserir CRAPACE
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'A', 't0032628', 17, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'C', 't0032628', 17, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'E', 't0032628', 17, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONVPA', 'I', 't0032628', 17, 2);
  --
  commit;
end;
