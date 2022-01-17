BEGIN
--Update pra cancelamento de folhas de cheque
update crapfdc fdc
  set fdc.dtliqchq = trunc(sysdate), 
      fdc.incheque = 8
where  cdcooper = 1
  and  nrdconta = 7611790
  and  nrcheque IN (259,258,257);
  
update crapfdc fdc
  set fdc.dtliqchq = trunc(sysdate), 
      fdc.incheque = 8
where  cdcooper = 1
  and  nrdconta = 12232416
  and  nrcheque = 70;
    
commit;
END;

