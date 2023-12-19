BEGIN   
    UPDATE crapprm a      
    SET a.dsvlrprm = 54000    
    WHERE a.cdacesso = 'SAQPAG_HORARIO_CORTE';
    
    COMMIT; 
  END;