begin
  
update crapfdc fdc
  set fdc.incheque = 8, 
      fdc.dtliqchq = trunc(sysdate)
where  fdc.cdcooper = 1
  and  fdc.nrdconta = 7420161
  and  fdc.nrcheque in (47, 48, 49);
  
commit;
end;
