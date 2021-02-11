begin

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED'
         ,0
         ,'CHQ_UNICRED_LST_EMAIL'
         ,'Email das pessoas responsáveis por receber a informação de '||
          'sinistros em cheques UNICRED'
         ,'prev.fraudes03@ailos.coop.br');

  for rw_crapcop in (select cdcooper from crapcop order by cdcooper) loop
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED'
           ,rw_crapcop.cdcooper
           ,'CHQ_UNICRED_LST_EMAIL'
           ,'Email das pessoas responsáveis por receber a informação de '||
            'sinistros em cheques UNICRED'
           ,'prev.fraudes03@ailos.coop.br');
  end loop;
  
  commit;

end;
