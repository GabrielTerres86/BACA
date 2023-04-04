BEGIN
 update CECRED.crapprm m 
    set m.dsvlrprm = 'creditoimobiliario@ailos.coop.br'
  where m.cdacesso = 'EMAIL_INTEGRA_PROGNUM';
 commit;
exception 
WHEN OTHERS THEN     
  DBMS_OUTPUT.put_line('Erro ao atualizar EMAIL_INTEGRA_PROGNUM: '|| sqlerrm);
  ROLLBACK;
END;
