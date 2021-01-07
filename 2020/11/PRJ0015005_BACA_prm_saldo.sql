begin
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
  select 'CRED'
        ,cdcooper
        ,'DAT_ULT_EXEC_SALDO'
        ,'Data do ultimo calculo de saldo em execução'
        ,to_char(sysdate-1,'dd/mm/rrrr')
    from crapcop;  
  commit;       
end;   
