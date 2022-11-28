BEGIN
 
  BEGIN
    UPDATE CECRED.crapprm t 
       SET t.dsvlrprm = t.dsvlrprm||',3728,3729,3886,3730,3731,3743,3744,3888,3890'
     WHERE t.nmsistem = 'CRED'
       AND t.cdcooper = 0
       AND t.cdacesso = 'HISTOR_SALDO_FIM_SEMANA';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao atualizar parametro: '||SQLERRM);
  END;
  
  COMMIT;

END;
