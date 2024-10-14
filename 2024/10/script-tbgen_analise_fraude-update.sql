begin
  

update cecred.tbgen_analise_fraude fra
  set fra.cdparecer_analise = 1
WHERE fra.idanalise_fraude in (400602411,400602412,400602413)
  and fra.cdparecer_analise = 0;

commit;
end;
