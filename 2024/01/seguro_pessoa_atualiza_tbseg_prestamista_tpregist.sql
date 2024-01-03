begin
  update tbseg_prestamista p
     set p.tpregist = 3
   where p.cdcooper = 7
     and p.nrdconta = 99733013
     and p.nrproposta = '202315148652';
  commit;
end;
/
