begin

 update crapprm 
    set dsvlrprm = 'S'
  where cdacesso = 'UTILIZA_REGRAS_SEGPRE';
  
commit;

exception

    WHEN others THEN
        rollback;
        raise_application_error(-20501, SQLERRM);
end;