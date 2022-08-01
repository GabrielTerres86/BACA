BEGIN
  
  UPDATE CECRED.CRAPTTL t
    SET t.nmextttl = 'EGON BAHR NETO'
  WHERE t.nrcpfcgc = 7214755904
    AND t.cdcooper IN ( 1, 2 );
  
  UPDATE CECRED.CRAPASS a
    SET a.nmprimtl = 'EGON BAHR NETO'
      , a.nmttlrfb = 'EGON BAHR NETO'
  WHERE a.nrcpfcgc = 7214755904
    and a.cdcooper IN ( 1, 2 );
  
  
  UPDATE CECRED.CRAPTTL t
    SET t.nmextttl = 'KEILA CINARA DOS SANTOS MIRANDA DA SILVA BARBOSA'
  WHERE t.nrcpfcgc = 7259740957
    AND t.cdcooper = 1;
  
  UPDATE CECRED.CRAPASS a
    SET a.nmprimtl = 'KEILA CINARA DOS SANTOS MIRANDA DA SILVA BARBOSA'
      , a.nmttlrfb = 'KEILA CINARA DOS SANTOS MIRANDA DA SILVA BARBOSA'
  WHERE a.nrcpfcgc = 7259740957
    and a.cdcooper = 1;
    
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
