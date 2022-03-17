BEGIN
  INSERT INTO cecred.craprdr ( nmprogra, dtsolici) VALUES ('IMOBILIARIO',SYSDATE);  
  
  INSERT INTO cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('IMPORTAR_ARQ_IMB', '', 'CREDITO.importarArqImobiliario', 'pr_tipo_arq',(SELECT nrseqrdr FROM cecred.craprdr WHERE nmprogra = 'IMOBILIARIO'));

  INSERT INTO cecred.craptel 
  (nmdatela,
   nrmodulo,
   cdopptel,
   tldatela,
   tlrestel,
   flgteldf,
   flgtelbl,
   nmrotina,
   lsopptel,
   inacesso,
   cdcooper,
   idsistem,
   idevento,
   nrordrot,
   nrdnivel,
   nmrotpai,
   idambtel)
  SELECT 'CTGIMB',
		 6,
		 '@,I,C',
		 'CONTINGENCIA DE ARQUIVOS DO IMOBILIARIO',
		 'CTG. IMOBILIA.',
		 0,
		 1, 
		 ' ',
		 'Acesso,Importar,Consultar',
		 1,
		 cdcooper, 
		 1,
		 0,
		 1,
		 1,
		 '',
		 2
	FROM cecred.crapcop
   WHERE cdcooper = 3;

  INSERT INTO cecred.crapprg
  (nmsistem,
   cdprogra,
   dsprogra##1,
   dsprogra##2,
   dsprogra##3,
   dsprogra##4,
   nrsolici,
   nrordprg,
   inctrprg,
   cdrelato##1,
   cdrelato##2,
   cdrelato##3,
   cdrelato##4,
   cdrelato##5,
   inlibprg,
   cdcooper)
  SELECT 'CRED',
		 'CTGIMB',
		 'CONTINGENCIA DE ARQUIVOS DO IMOBILIARIO',
		 '.',
		 '.',
		 '.',
		 50,
		 (SELECT MAX(g.nrordprg)+1 FROM cecred.crapprg g WHERE g.cdcooper = c.cdcooper AND g.nrsolici = 50),
		 1,
		 0,
		 0,
		 0,
		 0,
		 0,
		 1,
		 c.cdcooper
	FROM cecred.crapcop c
   WHERE c.cdcooper IN 3;
   
  INSERT INTO cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('BUSCAR_LOGS_ARQ_IMB', '', 'CREDITO.buscarLogImpArqImobiliario', 'pr_tipo_arq, pr_dtleitura',(SELECT nrseqrdr FROM cecred.craprdr WHERE nmprogra = 'IMOBILIARIO'));
   
  INSERT INTO cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('BUSCAR_DETALHES_LOG_ARQ_IMB', '', 'CREDITO.buscarDetalhesErroLogImobiliario', 'pr_tipo_arq, pr_dtleitura, pr_hrleitura, pr_nmarquivo',(SELECT nrseqrdr FROM cecred.craprdr WHERE nmprogra = 'IMOBILIARIO'));

  insert into cecred.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('CTGIMB', 'C', 'f0032951', ' ', 3, 1, 0, 2);
  
  insert into cecred.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('CTGIMB', 'I', 'f0032951', ' ', 3, 1, 0, 2);  
  
  insert into cecred.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('CTGIMB', '@', 'f0032951', ' ', 3, 1, 0, 2); 
  
  insert into cecred.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('CTGIMB', 'C', 'f0033100', ' ', 3, 1, 0, 2);
  
  insert into cecred.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('CTGIMB', 'I', 'f0033100', ' ', 3, 1, 0, 2); 

  insert into cecred.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('CTGIMB', '@', 'f0033100', ' ', 3, 1, 0, 2); 

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;