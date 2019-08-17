DECLARE
  aux_dsmotivo tbcobran_motivos_cin.dsmotivo%type;
BEGIN
  BEGIN
    SELECT t.dsmotivo
      INTO aux_dsmotivo
      FROM tbcobran_motivos_cin t
     WHERE t.cdmotivo = 8; 
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
        INSERT INTO cecred.tbcobran_motivos_cin
          (cdmotivo, dsmotivo)
        values
          (8, 'REPASSE CONSIGNADO');
         
        COMMIT; 
      END;
  END;      
END;

