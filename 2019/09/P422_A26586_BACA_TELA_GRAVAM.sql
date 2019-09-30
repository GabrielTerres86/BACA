declare
  cursor cr_crapcop IS
    select cdcooper
      from crapcop c;
  rw_crapcop cr_crapcop%rowtype;  
  
begin
  
  for rw_crapcop in cr_crapcop LOOP
    insert into crapprm (nmsistem
                   ,cdcooper
                   ,cdacesso
                   ,dstexprm
                   ,dsvlrprm) 
            values ('CRED'
                   ,rw_crapcop.cdcooper
                   ,'GRAVAM_DIA_AVISO_SEM_IMG'
                   ,'Parametro de dias para aviso de contrato sem imagem'
                   ,'0');
           
  END LOOP;
   insert into crapprm (nmsistem
                   ,cdcooper
                   ,cdacesso
                   ,dstexprm
                   ,dsvlrprm) 
            values ('CRED'
                   ,0
                   ,'GRAVAM_DIA_AVISO_SEM_IMG'
                   ,'Parametro de dias para aviso de contrato sem imagem'
                   ,'0');
   
   update crapaca set lstparam = (select lstparam from crapaca where nmproced = 'pc_gravacao_parametros' and nmpackag = 'TELA_GRAVAM') || ',pr_nrdsemim'
   where nmproced = 'pc_gravacao_parametros' and nmpackag = 'TELA_GRAVAM';
  
  commit;
end;
