begin 

UPDATE crapass a SET a.vllimcre = (SELECT NVL(l.vllimite,0) FROM craplim l WHERE l.cdcooper = a.cdcooper AND l.nrdconta = a.nrdconta  AND l.insitlim = 2 AND l.tpctrlim = 1) WHERE a.cdcooper = 1 AND a.nrdconta = 99999625;  

commit;

end;

