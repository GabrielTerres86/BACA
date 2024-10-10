begin
  
update cecred.tbgen_analise_fraude fra
  set fra.cdparecer_analise = 1
WHERE fra.idanalise_fraude in (400601447,400601446,400601445,400601444)
  and fra.cdparecer_analise = 0;


commit;
end;
