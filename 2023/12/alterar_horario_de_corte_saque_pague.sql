BEGIN   
    UPDATE crapprm a      
    SET a.dsvlrprm = 57600    
    WHERE a.cdacesso = 'SAQPAG_HORARIO_CORTE';
    
    COMMIT; 
  END;