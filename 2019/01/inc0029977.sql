/* Encerrar conta por demissão

select ass.cdsitdct
      ,ass.*
  from crapass ass
 WHERE ass.cdcooper = 9
   AND ass.nrdconta = 149713;

*/

UPDATE crapass ass
   SET ass.cdsitdct = 4
 WHERE ass.cdcooper = 9
   AND ass.nrdconta = 149713;
   
COMMIT;
  

