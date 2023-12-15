BEGIN   
    UPDATE crapprm a      
    SET a.dsvlrprm = 58400    
    WHERE a.cdacesso = 'SAQPAG_HORARIO_CORTE';
    
    COMMIT; 
  END;