declare
  
  cursor cr_crapcop is
  select cop.cdcooper
    from crapcop cop;
    
begin
  
  for rw_crapcop in cr_crapcop loop
    insert into crapprm (NMSISTEM
                       , CDCOOPER
                       , CDACESSO
                       , DSTEXPRM
                       , DSVLRPRM)
                 values ('CRED'
                       , rw_crapcop.cdcooper
                       , 'P484_FLAG_INTEGRA_SOA'
                       , 'Flag para auxilio durante implantacao do produto em cooperativas.'
                       , '0');
  end loop;

  insert into crapprm (NMSISTEM
                     , CDCOOPER
                     , CDACESSO
                     , DSTEXPRM
                     , DSVLRPRM)
               values ('CRED'
                     , '3'
                     , 'P484_EMAIL_INTEGRA_SOA'
                     , 'Grupo de email predefinido para erros serem enviados'
                     , 'integracaoaimarobrc@ailos.coop.br');

  commit;

end;