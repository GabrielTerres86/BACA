begin
  update tbseg_prestamista p
     set p.dtinivig = TO_DATE('14/06/2022', 'DD/MM/RRRR')
   where p.cdcooper = 5
     and p.nrdconta = 302279;
  commit;
end;
/
