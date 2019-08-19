UPDATE craprpp p
   SET p.cdsitrpp = 3
 WHERE p.cdcooper = 1 
   AND p.nrdconta = 8034877 
   AND p.nrctrrpp = 29968;
   
COMMIT;       
