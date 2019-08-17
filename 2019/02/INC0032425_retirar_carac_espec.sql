--CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRCTRSEG
--Gravar nome do beneficiario sem caracter especial
UPDATE crapseg s
   SET s.nmbenvid##1 = 'GABRIEL SANT ANNA EUZÉBIO'
 WHERE s.cdcooper = 1
   AND s.dtmvtolt = TO_DATE('12/01/2018','DD/MM/RRRR')
   AND s.cdagenci = 31
   AND s.cdbccxlt = 0
   AND s.nrdolote = 0
   AND s.nrdconta = 3167232
   AND s.nrctrseg = 144709;
   
COMMIT;
