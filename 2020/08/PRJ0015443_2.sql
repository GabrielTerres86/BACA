begin
  
  update crapaca c
     set c.nmpackag = 'TELA_QBRSIG'
   where c.nmdeacao = 'QBRSIG_LISTA_QUEBRA';
 
  commit;
 
end;
