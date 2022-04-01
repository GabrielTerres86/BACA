begin
update tbseg_prestamista p
  set p.tpregist = 2
 where p.cdcooper = 14
   and p.nrdconta = 157090
   and p.nrproposta = 770354879158;
   commit;
end;
/
