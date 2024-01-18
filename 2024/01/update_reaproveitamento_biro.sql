begin

  UPDATE craprbi
  SET qtdiarpv = 30
  WHERE craprbi.cdcooper = 1
  AND craprbi.inprodut = 7
  AND craprbi.inpessoa = 2;       
  
  UPDATE crapmbr
  SET    nrordimp = 3
  WHERE cdbircon = 1
  AND   cdmodbir = 2; 
    
  COMMIT;

end;
