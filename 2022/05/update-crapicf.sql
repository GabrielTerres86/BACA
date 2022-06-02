begin
  
update cecred.crapicf crapicf
  set crapicf.dtmvtolt = trunc(sysdate)
WHERE crapicf.cdcooper = 1  
  AND crapicf.dacaojud = Upper('SIMBA_CCS_QBRSIG')
  and crapicf.nrctaori in (6898408,6898432, 7869843)
  and crapicf.dtmvtolt = to_date('21/12/2021','DD/MM/YYYY')
  and crapicf.nrcpfcgc = 0;

commit;
end;
