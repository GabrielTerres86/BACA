BEGIN
 
delete credito.tbepr_contrato_imobiliario a
WHERE a.cdcooper = 16
AND a.data_efetivacao is NOT NULL
AND a.nrctremp NOT IN (366856
,421162);
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
