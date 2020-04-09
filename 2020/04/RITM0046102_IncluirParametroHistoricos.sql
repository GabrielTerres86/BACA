BEGIN
  INSERT INTO crapprm(nmsistem
                     ,cdcooper
                     ,cdacesso
                     ,dstexprm
                     ,dsvlrprm)
               VALUES('CRED'
                     ,0
                     ,'HISTOR_SALDO_FIM_SEMANA'
                     ,'Históricos que contabilizam no saldo do fim de semana'
                     ,'2308,2719,856,857');
  
  COMMIT;
      
EXCEPTION
  WHEN dup_val_on_index THEN
    BEGIN
      UPDATE crapprm   t
         SET t.dsvlrprm = t.dsvlrprm||',856,857'
       WHERE t.nmsistem = 'CRED'
         AND t.cdcooper = 0
         AND t.cdacesso = 'HISTOR_SALDO_FIM_SEMANA'
         AND t.dsvlrprm NOT LIKE '%856%' 
         AND t.dsvlrprm NOT LIKE '%857%';
         
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,'Erro ao atualizar parametro: '||SQLERRM);
    END;
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,'Erro ao incluir parametro: '||SQLERRM);
END;
