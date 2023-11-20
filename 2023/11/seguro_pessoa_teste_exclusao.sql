begin
delete
  from tbseg_prestamista p
 where p.cdcooper = 1
  and p.nrdconta = 90479998
  and p.nrctrseg = 1555135;
commit;
end;
/
