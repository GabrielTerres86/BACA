begin
  
update crapfdc fdc
  set fdc.incheque = 8, 
      fdc.dtliqchq = trunc(sysdate)
where  fdc.cdcooper = 2
  and  fdc.nrdconta = 961752
  and  fdc.nrcheque in (6, 7);
  
commit;
end;
