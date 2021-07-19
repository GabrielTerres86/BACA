begin
  update crapprm p
     set p.dsvlrprm = 'prev.fraudes03@ailos.coop.br'
   where p.cdacesso = 'EMAIL_RISCOFRAUDE_ADM';
  
  commit;
end;
