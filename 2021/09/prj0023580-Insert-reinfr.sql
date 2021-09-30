INSERT INTO craptel (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrordrot, nrdnivel, nmrotpai, idambtel)
   SELECT 'REINFR', 5, '@,C,L', 'Relatos de Infração PIX', 'Relatos de Infração PIX', 0, 1, ' ', 'ACESSO,CONCILIACAO,LISTAGEM', 2, cdcooper, 1, 0, 0, 0, ' ', 0 FROM crapcop cop;

-- Gera cadastro do programa para todas cooperativas
INSERT INTO crapprg (cdcooper, nmsistem, cdprogra, dsprogra##1, dsprogra##2, dsprogra##3, dsprogra##4, nrsolici, nrordprg, inctrprg, cdrelato##1, cdrelato##2, cdrelato##3, cdrelato##4, cdrelato##5, inlibprg)
   SELECT cdcooper, 'CRED', 'REINFR', 'Relatos de Infração PIX', ' ', ' ', ' ', 50,  10851, 1, 0, 0, 0, 0, 0, 0 FROM crapcop cop;

-- Acessos iniciais
insert into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
select 'REINFR', opc.cddopcao, ope.cdoperad, null, 3, 1, 1, 2
  from crapope ope, (select regexp_substr('@,C,L','[^,]+', 1, level) cddopcao from dual connect BY level <= 2) opc
 where ope.cdcooper = 3
   and lower(ope.cdoperad) in ( 'f0030640', 'f0033467', 'f0030614', 'f0033559', 'f0030614', 'f0030191', 'f0031264', 'f0030588', 'f0033116', 'f0031976', 'f0033322','f0032563','f0030606','f0033550');
 
commit;
