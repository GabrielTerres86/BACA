begin
  
update crapfdc fdc
  set fdc.incheque = 8, fdc.dtretchq = trunc(sysdate), fdc.dtliqchq = trunc(sysdate), fdc.cdbantic = 0, fdc.cdagetic = 0, fdc.nrctatic = 0
where fdc.cdcooper = 1
  and fdc.incheque = 0
  and fdc.nrdconta = 9583700
  and fdc.nrcheque in (370, 368, 367, 365, 363);
  
commit;
end;
