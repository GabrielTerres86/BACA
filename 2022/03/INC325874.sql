BEGIN
   BEGIN
   
     UPDATE crapprm rm
        SET rm.dsvlrprm = ',47777303953,48954659934,02503542921,'
      WHERE rm.nmsistem = 'CRED'
        AND rm.cdcooper = 1
        AND rm.cdacesso = 'PESSOA_LIGADA_DIRETORIA';
   
   EXCEPTION 
       WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000,'Ocorreu um erro ao atualizar o registro da tabela crapprm.'||SQLERRM);
   
   END;
   
   COMMIT;
            
END;

