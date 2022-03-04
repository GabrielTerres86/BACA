DECLARE

  CURSOR cr_respon IS
    select t.nrcpfcgc
         , t.nmrespon
         , ROWID dsdrowid
      from crapcrl t
     WHERE t.cdcooper = 1
       AND t.nrctamen = 9659307
       AND t.idseqmen = 1;
  
  CURSOR cr_pessoa(pr_nrcpfcgc IN NUMBER) IS
    SELECT t.nmpessoa
      FROM vwcadast_pessoa_fisica t 
     WHERE t.nrcpf = pr_nrcpfcgc;
  rg_pessoa cr_pessoa%ROWTYPE;
  
BEGIN 

  -- Percorrer os registros de responsável
  FOR reg IN cr_respon LOOP
    
    -- Buscar o nome no cadastro
    OPEN  cr_pessoa(reg.nrcpfcgc);
    FETCH cr_pessoa INTO rg_pessoa;
    CLOSE cr_pessoa;
  
    -- Se o nome está diferente
    IF reg.nmrespon <> rg_pessoa.nmpessoa THEN
      
      -- Realizar o update
      UPDATE crapcrl t
         SET t.nmrespon = rg_pessoa.nmpessoa
       WHERE ROWID = reg.dsdrowid;
    
    END IF;
    
  END LOOP;
  
  COMMIT;
  
END;
