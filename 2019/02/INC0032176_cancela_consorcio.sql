--Atualiza 1 registro
--CHAVE TABELA CDCOOPER, NRDGRUPO, NRCTACNS, NRCOTCNS, NRCTRATO
UPDATE crapcns c
   SET c.flgativo = 0
     , c.dtcancel = TO_DATE('12/02/2019','DD/MM/RRRR')  
 WHERE c.cdcooper = 16
   AND c.nrdgrupo = 30348
   AND c.nrctacns = 134280
   AND c.nrcotcns = 113
   AND c.nrctrato = 333496
   AND c.nrdconta = 2930200;
   
COMMIT;
