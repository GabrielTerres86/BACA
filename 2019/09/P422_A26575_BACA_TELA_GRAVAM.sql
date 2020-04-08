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
                   ,'GRAVAM_ENV_AUTO_CTR'
                   ,'Parametro de envio automatico de registro de contrato'
                   ,'N');
				   
	insert into crapprm (nmsistem
                   ,cdcooper
                   ,cdacesso
                   ,dstexprm
                   ,dsvlrprm) 
            values ('CRED'
                   ,rw_crapcop.cdcooper
                   ,'GRAVAM_SIGLAS_UF_ENV_CTR'
                   ,'Parametro de unidades federativas a enviar o contrato'
                   ,'');
  END LOOP;
   insert into crapprm (nmsistem
                   ,cdcooper
                   ,cdacesso
                   ,dstexprm
                   ,dsvlrprm) 
            values ('CRED'
                   ,0
                   ,'GRAVAM_ENV_AUTO_CTR'
                   ,'Parametro de envio automatico de registro de contrato'
                   ,'N');
				   
	insert into crapprm (nmsistem
                   ,cdcooper
                   ,cdacesso
                   ,dstexprm
                   ,dsvlrprm) 
            values ('CRED'
                   ,0
                   ,'GRAVAM_SIGLAS_UF_ENV_CTR'
                   ,'Parametro de unidades federativas a enviar o contrato'
                   ,'');
	
update crapaca set lstparam = (select lstparam from crapaca where nmproced = 'pc_gravacao_parametros' and nmpackag = 'TELA_GRAVAM') || ',pr_flgenaut,pr_siglaufs'
where nmproced = 'pc_gravacao_parametros' and nmpackag = 'TELA_GRAVAM';
  
  commit;
end;
