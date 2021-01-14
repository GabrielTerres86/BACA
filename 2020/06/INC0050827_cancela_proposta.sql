UPDATE crawcrd c
   SET c.insitcrd = 6
      ,c.dtcancel = TRUNC(SYSDATE)
      ,c.cdmotivo = 4
 WHERE c.cdcooper = 7
   AND c.nrdconta = 102008
   AND c.nrctrcrd = 91108;  
   
COMMIT;
