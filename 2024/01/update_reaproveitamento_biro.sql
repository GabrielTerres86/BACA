begin

  UPDATE craprbi
  SET qtdiarpv = -1
  WHERE craprbi.cdcooper = 1
  AND craprbi.inprodut = 7;    
    
  commit;

end;
