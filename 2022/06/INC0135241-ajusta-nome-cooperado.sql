BEGIN
  
  UPDATE CECRED.CRAPTTL t
    SET t.nmextttl = 'SHIRLENE CANDIDO'
  WHERE t.nrcpfcgc = 844575976
    AND t.cdcooper = 1;
  
  UPDATE CECRED.CRAPASS a
    SET a.nmprimtl = 'SHIRLENE CANDIDO'
      , a.nmttlrfb = 'SHIRLENE CANDIDO'
  WHERE a.nrcpfcgc = 844575976
    and a.cdcooper = 1;
  
    
    
  UPDATE CECRED.CRAPTTL t
    SET t.nmextttl = 'ANDRESSA DA SILVA MARQUES'
  WHERE t.nrcpfcgc = 5740877962
    AND t.cdcooper = 11;
  
  UPDATE CECRED.CRAPASS a
    SET a.nmprimtl = 'ANDRESSA DA SILVA MARQUES'
      , a.nmttlrfb = 'ANDRESSA DA SILVA MARQUES'
  WHERE a.nrcpfcgc = 5740877962
    and a.cdcooper = 11;
    
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
