DECLARE

  CURSOR cr_respon IS
    select t.nrcpfcgc
         , t.nmrespon
         , ROWID dsdrowid
      from crapcrl t
     WHERE t.cdcooper = 1 AND t.nrctamen = 7245181;
  
  CURSOR cr_pessoa(pr_nrcpfcgc IN NUMBER) IS
    SELECT t.nmpessoa
      FROM vwcadast_pessoa_fisica t 
     WHERE t.nrcpf = pr_nrcpfcgc;
  rg_pessoa cr_pessoa%ROWTYPE;
  
BEGIN 

  FOR reg IN cr_respon LOOP
    
    OPEN  cr_pessoa(reg.nrcpfcgc);
    FETCH cr_pessoa INTO rg_pessoa;
    CLOSE cr_pessoa;
  
    IF reg.nmrespon <> rg_pessoa.nmpessoa THEN
      
      UPDATE crapcrl t
         SET t.nmrespon = rg_pessoa.nmpessoa
       WHERE ROWID = reg.dsdrowid;
    
    END IF;
    
  END LOOP;
  
  COMMIT;
  
END;
