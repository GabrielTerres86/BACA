begin
  

update cecred.tbgen_analise_fraude fra
  set fra.cdparecer_analise = 1
WHERE fra.idanalise_fraude in (400601486,400601488,400601487)
  and fra.cdparecer_analise = 0;

commit;
end;
