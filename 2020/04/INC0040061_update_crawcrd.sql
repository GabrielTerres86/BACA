--INC0040061 - INC0041629 - Encerrar cartão do BB.

update crawcrd c
set c.insitcrd = 6
where c.cdcooper = 1
  and c.nrdconta = 2530066
  and c.nrcrcard = 0
  and c.nrctrcrd = 1011791; 
  
  
update crawcrd c
set c.insitcrd = 6
where c.cdcooper = 1
  and c.nrdconta = 2017300
  and c.nrcrcard = 62578712
  and c.nrctrcrd = 74402;
  
COMMIT;  
