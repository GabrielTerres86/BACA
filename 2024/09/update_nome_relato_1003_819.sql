BEGIN
    UPDATE CECRED.craprel c 
       SET c.nmrelato = 'ENVIO ARQUIVO PRESTAMISTA CONTRIBUTARIO PF'
     WHERE c.cdrelato = 819;
     
    UPDATE CECRED.craprel c
       SET c.nmrelato = 'ENVIO ARQUIVO PRESTAMISTA CONTRIBUTARIO PJ'
     WHERE c.cdrelato = 1003;
    
    COMMIT;
END;
