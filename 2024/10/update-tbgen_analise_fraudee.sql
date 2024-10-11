begin
  

update cecred.tbgen_analise_fraude fra
  set fra.cdparecer_analise = 1
WHERE fra.idanalise_fraude in (400601478,400601476,400601475,400601477)
  and fra.cdparecer_analise = 0;

commit;
end;
