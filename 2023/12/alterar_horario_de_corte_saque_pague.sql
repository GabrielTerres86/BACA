BEGIN   
    UPDATE crapprm a      
    SET a.dsvlrprm = 55800    
    WHERE a.cdacesso = 'SAQPAG_HORARIO_CORTE';
    
    COMMIT; 
  END;