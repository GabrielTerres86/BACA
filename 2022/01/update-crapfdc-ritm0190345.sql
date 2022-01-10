BEGIN
--Update pra cancelamento de folhas de cheque
update crapfdc fdc
  set fdc.dtretchq = trunc(sysdate), 
      fdc.dtliqchq = trunc(sysdate), 
      fdc.incheque = 8
where  cdcooper = 1
  and  nrdconta = 12232416
  and  nrcheque = 70;
commit;
END;

