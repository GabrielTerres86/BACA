BEGIN
  UPDATE crapprm   t
     SET t.dsvlrprm = t.dsvlrprm||',856,857'
   WHERE t.nmsistem = 'CRED'
     AND t.cdcooper = 0
     AND t.cdacesso = 'HISTOR_SALDO_FIM_SEMANA';
         
  COMMIT;
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000,'Erro ao incluir parametro: '||SQLERRM);
END;
