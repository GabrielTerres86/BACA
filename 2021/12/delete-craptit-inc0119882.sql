begin
  
delete craptit t 
where t.cdcooper = 1 
  and t.nrdconta = 2121131
  and t.dtmvtolt = '29/12/2021' 
  and t.vltitulo = 8068.17;

commit;

end;
