begin
  -- Adi��o do P�rametro da FGCOOP na tela CADCOP
  update CRAPACA
   set LSTPARAM = LSTPARAM || ',pr_vlfgcoop'
  where NMDEACAO = 'ALTCOOP'
   and NMPACKAG = 'TELA_CADCOP';  

  COMMIT;
      
end;  
