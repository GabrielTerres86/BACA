begin

  UPDATE crapmbr
  SET    nrordimp = 2
  WHERE cdbircon = 1
  AND   cdmodbir = 2; 
  
  DELETE
  FROM  crapcbd
  WHERE crapcbd.inreapro = 0
    AND crapcbd.inreterr = 0
    AND crapcbd.nrsdtsoc IS NULL
    AND trunc(crapcbd.dtconbir) = trunc(SYSDATE);
    
  COMMIT;

end;
