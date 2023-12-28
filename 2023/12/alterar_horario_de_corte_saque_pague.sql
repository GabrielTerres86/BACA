BEGIN   
    UPDATE crapprm a      
    SET a.dsvlrprm = 55200    
    WHERE a.cdacesso = 'SAQPAG_HORARIO_CORTE';
    
    COMMIT; 
  END;