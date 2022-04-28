BEGIN
 
  UPDATE credito.tbepr_contrato_imobiliario a
    SET  a.cdagenci = 17
  WHERE a.cdcooper = 16;
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
