begin
  update crapmpc
  set vlrfaixa = 0.01
  where cdprodut = 1109;
  commit;
end; 
