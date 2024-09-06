BEGIN
INSERT INTO CECRED.CRAPREL (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf, dsdemail, cdfilrel, nrseqpri) 
SELECT 1003, 
       nrviadef, 
       nrviamax, 
       'EMPRESTIMOS CONTRAT. SEM SEG. PRST. PJ', 
       nrmodulo, 
       nmdestin, 
       nmformul, 
       indaudit, 
       cdcooper, 
       periodic, 
       tprelato, 
       inimprel, 
       ingerpdf, 
       dsdemail, 
       cdfilrel,
       nrseqpri
  FROM craprel
 WHERE cdrelato = 598;

INSERT INTO CECRED.CRAPREL (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf, dsdemail, cdfilrel, nrseqpri) 
SELECT 1004,
       nrviadef,
       nrviamax,
       'ENVIO DO ARQUIVO PRST CONTRIBUTARIO PJ',
       nrmodulo,
       nmdestin,
       nmformul,
       indaudit,
       cdcooper,
       periodic,
       tprelato,
       inimprel,
       ingerpdf,
       dsdemail,
       cdfilrel,
       nrseqpri
  FROM craprel
 WHERE cdrelato = 819;

INSERT INTO CECRED.CRAPREL (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf, dsdemail, cdfilrel, nrseqpri) 
SELECT 1005,
       nrviadef,
       nrviamax,
       'ENVIO DO ARQUIVO PRST CONTRIBUTARIO HIST. 4577 PJ',
       nrmodulo,
       nmdestin,
       nmformul,
       indaudit,
       cdcooper,
       periodic,
       tprelato,
       inimprel,
       ingerpdf,
       dsdemail,
       cdfilrel,
       nrseqpri
  FROM craprel
 WHERE cdrelato = 819;

INSERT INTO CECRED.CRAPREL (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf, dsdemail, cdfilrel, nrseqpri) 
SELECT 1006, 
       nrviadef, 
       nrviamax, 
       'RECUSA DE SEGURO PRESTAMISTA MENSAL PJ', 
       nrmodulo, 
       nmdestin, 
       nmformul, 
       indaudit, 
       cdcooper, 
       periodic, 
       tprelato, 
       inimprel, 
       ingerpdf, 
       dsdemail, 
       cdfilrel, 
       nrseqpri 
  FROM craprel
 WHERE cdrelato = 822;

INSERT INTO CECRED.CRAPREL (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf, dsdemail, cdfilrel, nrseqpri) 
SELECT 1007, 
       nrviadef, 
       nrviamax, 
       'ARQUIVO PRESTAMISTA INADIMPLENTES PJ', 
       nrmodulo, 
       nmdestin, 
       nmformul, 
       indaudit, 
       cdcooper, 
       periodic, 
       tprelato, 
       inimprel, 
       ingerpdf, 
       dsdemail, 
       cdfilrel, 
       nrseqpri
  FROM craprel  
 WHERE cdrelato = 820;
 
 COMMIT;
END;
