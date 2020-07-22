DECLARE
       vr_cdrelato number;
BEGIN
  
        SELECT Max(cdrelato) + 1 into vr_cdrelato
          FROM craprel rel;
         
        INSERT INTO CRAPREL 
              (CDRELATO, NRVIADEF, NMRELATO,                     NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, PROGRESS_RECID, CDFILREL, NRSEQPRI)
        SELECT vr_cdrelato, NRVIADEF, 'ARQUIVO DE TED/TRANSFERENCIA', NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, NULL, CDFILREL, NRSEQPRI
        FROM craprel rel
        WHERE cdrelato = 735
        AND  nmrelato = 'PAGAMENTO DE TITULO POR ARQUIVO';
        
        COMMIT;
        dbms_output.put_line('Nr Relato - ' ||vr_cdrelato);
END;
  
