begin
  
delete craptit t 
where t.cdcooper = 1 
  and t.nrdconta = 2121131
  and t.dtmvtolt = to_date('29/12/2021','DD/MM/YYYY') 
  and t.vltitulo = 8068.17;

commit;

end;
