BEGIN
 
  UPDATE credito.tbepr_contrato_imobiliario a
  SET  a.cdlcremp = 10000,
       a.cdfinemp = 100 
  WHERE a.cdcooper = 16
  AND NVL(a.valor_atraso,0) > 0 ;
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
