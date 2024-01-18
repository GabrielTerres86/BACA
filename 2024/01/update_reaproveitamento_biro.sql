begin

  UPDATE crapmbr
  SET    nrordimp = 2
  WHERE cdbircon = 1
  AND   cdmodbir = 2; 
  
  DELETE
  FROM  crapcbd
  WHERE crapcbd.inreapro = 0 -- Utilizar somente consultas que nao foram reaproveitadas
    AND crapcbd.inreterr = 0 -- Que nao teve erros
    AND crapcbd.nrsdtsoc IS NULL -- Nao pode ser socio, pois as informacoes dos socios vem resumidas
    AND trunc(crapcbd.dtconbir) = trunc(SYSDATE);
    
  COMMIT;

end;
