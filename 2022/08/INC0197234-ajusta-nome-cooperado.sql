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
  
  
  UPDATE CECRED.CRAPTTL t
    SET t.nmextttl = 'GILSON POSSAMAI'
  WHERE t.nrcpfcgc = 5860572930
    AND t.cdcooper = 1;
  
  UPDATE CECRED.CRAPASS a
    SET a.nmprimtl = 'GILSON POSSAMAI'
      , a.nmttlrfb = 'GILSON POSSAMAI'
  WHERE a.nrcpfcgc = 5860572930
    and a.cdcooper = 1;
  
  
  UPDATE CECRED.CRAPTTL t
    SET t.nmextttl = 'PEDRO HENRIQUE ALMEIDA SANTOS'
  WHERE t.nrcpfcgc = 12729879650
    AND t.cdcooper = 1;
  
  UPDATE CECRED.CRAPASS a
    SET a.nmprimtl = 'PEDRO HENRIQUE ALMEIDA SANTOS'
      , a.nmttlrfb = 'PEDRO HENRIQUE ALMEIDA SANTOS'
  WHERE a.nrcpfcgc = 12729879650
    and a.cdcooper = 1;
  
  
  UPDATE CECRED.CRAPTTL t
    SET t.nmextttl = 'BRUNO COELHO'
  WHERE t.nrcpfcgc = 10826112986
    AND t.cdcooper = 16;
  
  UPDATE CECRED.CRAPASS a
    SET a.nmprimtl = 'BRUNO COELHO'
      , a.nmttlrfb = 'BRUNO COELHO'
  WHERE a.nrcpfcgc = 10826112986
    and a.cdcooper = 16;
    
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
