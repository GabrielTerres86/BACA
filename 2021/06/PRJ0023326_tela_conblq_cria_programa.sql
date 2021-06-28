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
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 1, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 2, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 3, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 4, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 5, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 6, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 7, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 8, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 9, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 10, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 11, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 12, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 13, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 14, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 15, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 16, null, null);
  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
  values ('CRED', 'CONBLQ', 'CONSULTA DE BLOQUEIO DE PAGAMENTOS POR SEGMENTO', '.', '.', '.', 50, v_nrordprg, 1, 0, 0, 0, 0, 0, 1, 17, null, null);

  -- Inserir CRAPTEL
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 1, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 2, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 3, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 4, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 5, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 6, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 7, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 8, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 9, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 10, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 11, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 12, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 13, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 14, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 15, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 16, 1, 0, 1, 1, ' ', 2, null);
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL, PROGRESS_RECID)
  values ('CONBLQ', 5, 'A,C,E,I', 'CONSULTA de bloqueio de pagamentos por segmento', 'PRM BLOQUEIO PAGTOS POR SEGMENTO', 0, 1, ' ', 'ALTERACAO,CONSULTA,EXCLUSAO,INCLUSAO', 1, 17, 1, 0, 1, 1, ' ', 2, null);
    -- Inserir CRAPRDR
  insert into craprdr(nrseqrdr,nmprogra,dtsolici) values ((select max(nrseqrdr) + 1 from craprdr),'TELA_CONBLQ', SYSDATE) 
  returning nrseqrdr into v_nrseqrdr;
  -- Inserir crapaca
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'CONSULTAR_CONV_BLOQPAG', 'TELA_CONBLQ', 'pc_consulta_conv_bloqpag', 'pr_cdcooper, pr_periodoini,pr_periodofim,pr_NRDCONTA,pr_cdsegmto,pr_NRCONVEN,pr_flagbarr, pr_canalpagamento,pr_nrregist,pr_nriniseq', v_nrseqrdr);
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'EXPORTAR_CONV_BLOQPAG', 'TELA_CONBLQ', 'pc_gera_csv_bloqpag', 'PR_CDCOOPER,PR_PERIODOINI, PR_PERIODOFIM, PR_NRDCONTA ,PR_CDSEGMTO,PR_NRCONVEN, PR_FLAGBARR,PR_CANALPAGAMENTO ', v_nrseqrdr);
  
    -- Inserir CRAPACE
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 1, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 2, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 3, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 4, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 5, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 6, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 7, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 8, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 9, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 10, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 11, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 12, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 13, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 14, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 15, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 16, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'A', 't0033835', 17, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'C', 't0033835', 17, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'E', 't0033835', 17, 2);
  insert into crapace(nmdatela, cddopcao, cdoperad, cdcooper, idambace)
  values('CONBLQ', 'I', 't0033835', 17, 2);

   commit;
end;
