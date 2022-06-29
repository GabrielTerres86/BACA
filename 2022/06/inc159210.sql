begin
update cecred.crapepr 
set DTDPAGTO = to_date('10/07/2022','DD/MM/YYYY'),
    QTPRECAL = 46,
    INDPAGTO = 1
where cdcooper = 1
  and nrdconta = 8355614
  and nrctremp = 1193088;
commit;
end;