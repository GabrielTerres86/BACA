BEGIN
  UPDATE craptel l
     SET l.cdopptel = l.cdopptel || ',R', l.lsopptel = l.lsopptel || ',RELATORIO'
   WHERE l.nmdatela = 'CARCRD' AND l.nmrotina = 'PRMCRD';  
   
   COMMIT;    

  DELETE 
    FROM crapace a 
   WHERE lower(a.cdoperad) IN ('f0030641','f0030947','f0031849','f0031749','f0031296') 
     AND a.nmdatela = 'CARCRD' 
     AND a.nmrotina = 'PRMCRD';  
   
  -- f0030641 
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', '@', 'f0030641', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'C', 'f0030641', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'R', 'f0030641', 'PRMCRD', 3, 1, 1, 2);  
  
  -- f0030947
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', '@', 'f0030947', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'C', 'f0030947', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'R', 'f0030947', 'PRMCRD', 3, 1, 1, 2);
  
  -- f0031849
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', '@', 'f0031849', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'C', 'f0031849', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'R', 'f0031849', 'PRMCRD', 3, 1, 1, 2);  

  -- f0031749
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', '@', 'f0031749', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'C', 'f0031749', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'R', 'f0031749', 'PRMCRD', 3, 1, 1, 2);  

  -- f0031296
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', '@', 'f0031296', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'C', 'f0031296', 'PRMCRD', 3, 1, 1, 2);
  INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
  VALUES ('CARCRD', 'R', 'f0031296', 'PRMCRD', 3, 1, 1, 2);  


  COMMIT;   
END;