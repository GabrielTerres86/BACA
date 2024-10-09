begin
  
update cecred.tbgen_analise_fraude fra
  set fra.cdparecer_analise = 0
WHERE fra.idanalise_fraude in (400601413,400601416,400601414,400601415,400601417)
  and fra.cdparecer_analise = 1;


commit;
end;
