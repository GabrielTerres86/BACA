begin
  update crapprm p
     set p.dsvlrprm = 'base2-erika.andrade@ailos.coop.br'
   WHERE p.cdacesso = 'EMAIL_TESTE';
  commit;
end;
/
