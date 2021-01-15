BEGIN
  UPDATE crawcrd
     SET nrcrcard = 0
        ,nrcctitg = 0
        ,insitcrd = 6
   WHERE cdcooper = 16
     AND nrdconta = 720828
     AND nrctrcrd = 116743;

  DELETE tbcrd_conta_cartao
   WHERE cdcooper = 16
     AND nrdconta = 720828
     AND nrconta_cartao = 7564438048478;      
  COMMIT;   
END; 