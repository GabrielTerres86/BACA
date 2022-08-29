BEGIN
  UPDATE credito.tbcred_pronampe_remessa
     SET cdretorno = '000'
   WHERE nrremessa = 128;
   
  INSERT INTO credito.tbcred_pronampe_remessa
    (nrremessa
    ,dtremessa
    ,dhgeracao
    ,cdsituacao)
  VALUES
    ((SELECT MAX(rem.nrremessa) + 1 nrremessa
       FROM credito.tbcred_pronampe_remessa rem)
    ,trunc(SYSDATE)
    ,SYSDATE
    ,1); 

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;