BEGIN
  UPDATE TBCADAST_PESSOA A
     SET A.NMPESSOA = 'PACIFICO SUL INDUSTRIA TEXTIL E CONFECCOES LTDA'
   WHERE A.NRCPFCGC = 81336398000133;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
