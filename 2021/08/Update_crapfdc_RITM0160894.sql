begin
  update crapfdc fdc
    set fdc.nrctatic = 0, 
        fdc.cdbantic = 0, 
        fdc.cdagetic = 0, 
        fdc.incheque = 8,
        fdc.dtliqchq = trunc(sysdate)
  where  fdc.cdcooper = 16
    and  fdc.nrdconta = 818798
    and  fdc.nrcheque in (5,7,17,18);
  commit;  
end;  
