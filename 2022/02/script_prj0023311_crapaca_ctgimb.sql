BEGIN
  INSERT INTO craprdr ( nmprogra, dtsolici) VALUES ('IMOBILIARIO',SYSDATE);  
  
  INSERT INTO crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('IMPORTAR_ARQ_IMB', '', 'CREDITO.importarArqImobiliario', 'pr_tipo_arq',(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'IMOBILIARIO'));

INSERT INTO craptel
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
		 5,
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
	FROM crapcop
   WHERE cdcooper = 3;

   INSERT INTO crapprg
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
		 (SELECT MAX(g.nrordprg)+1 FROM crapprg g WHERE g.cdcooper = c.cdcooper AND g.nrsolici = 50),
		 1,
		 0,
		 0,
		 0,
		 0,
		 0,
		 1,
		 c.cdcooper
	FROM crapcop c
   WHERE c.cdcooper IN 3;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;