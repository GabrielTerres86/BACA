BEGIN   
    UPDATE crapprm a      
    SET a.dsvlrprm = 63000    
    WHERE a.cdacesso = 'SAQPAG_HORARIO_CORTE';
    
    COMMIT; 
  END;