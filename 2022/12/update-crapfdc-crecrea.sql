begin
   
update cecred.crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), 
      fdc.dtliqchq = trunc(SYSDATE), 
      fdc.incheque = 8   
where  fdc.cdcooper = 7
  and  fdc.incheque = 0
  and  fdc.nrdconta = 1279;
 
commit;  
end;
