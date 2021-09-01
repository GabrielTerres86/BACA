    /*Limpa registros */
    DELETE craptel WHERE upper(nmdatela) = 'CONPIX';
    DELETE crapprg WHERE upper(nmsistem) = 'CRED' and upper(cdprogra) = 'CONPIX';
    COMMIT;

 

INSERT INTO craptel
   (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, 
   nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrordrot, 
   nrdnivel, nmrotpai, idambtel)
   SELECT 'CONPIX', 5, '@,C', 'Conciliações PIX',
          'Conciliações PIX', 0, 1, ' ', 'ACESSO,CONCILIACAO',
          2, cdcooper, 1, 0, 0, 0, ' ', 0 
     FROM dual lista, crapcop cop;

 

 

 

-- Gera cadastro do programa para todas cooperativas
INSERT INTO crapprg
   (cdcooper, nmsistem, cdprogra, dsprogra##1, dsprogra##2, dsprogra##3, dsprogra##4, nrsolici, 
    nrordprg, inctrprg, cdrelato##1, cdrelato##2, cdrelato##3, cdrelato##4, cdrelato##5, inlibprg)
   SELECT cdcooper, 'CRED', 'CONPIX', 'Conciliações PIX', ' ', 
          ' ', ' ', 991,  999, 1, 0, 0, 0, 0, 0, 0
     FROM dual lista, crapcop cop;