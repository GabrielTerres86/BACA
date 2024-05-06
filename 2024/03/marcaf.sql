BEGIN
 
INSERT INTO craptel (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrordrot, nrdnivel, nmrotpai, idambtel)
   SELECT 'MARCAF', 5, '@,C,L', 'Marcação de Fraude PIX', 'Marcação de Fraude PIX', 0, 1, ' ', 'ACESSO,CADASTRO,LISTAGEM', 2, cdcooper, 1, 0, 0, 0, ' ', 0 FROM crapcop cop;
INSERT INTO crapprg (cdcooper, nmsistem, cdprogra, dsprogra##1, dsprogra##2, dsprogra##3, dsprogra##4, nrsolici, nrordprg, inctrprg, cdrelato##1, cdrelato##2, cdrelato##3, cdrelato##4, cdrelato##5, inlibprg)
SELECT cdcooper, 'CRED', 'MARCAF', 'Marcação de Fraude PIX', ' ', ' ', ' ', 50,(SELECT MAX(nrordprg) + 1 FROM crapprg WHERE nrsolici = 50), 1, 0, 0, 0, 0, 0, 0 FROM crapcop cop;
insert into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
select 'MARCAF', opc.cddopcao, ope.cdoperad, null, 3, 1, 1, 2
  from crapope ope, (select regexp_substr('@,C,L','[^,]+', 1, level) cddopcao from dual connect BY level <= 2) opc
 where ope.cdcooper = 3
   and lower(ope.cdoperad) in ( 'f0033673', 't0036149' ,'f0030631', 'f0034744' ,'f0034735' );
 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;