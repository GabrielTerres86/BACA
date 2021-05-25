DECLARE

  -- Cursores
  CURSOR cr_crapcop IS 
    SELECT c.cdcooper
          ,c.dsdircop
      FROM crapcop c;
     
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- RANGE DE CARTÕES PARA VERIFICAR
  CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT w.rowid
    FROM crawcrd w
     WHERE w.cdcooper = pr_cdcooper
           and w.insitcrd not in (4,5,6)
           and w.dtsolici >= '01/03/2021' and dtsolici < '19/05/2021' 
           and SUBSTR(w.nrcrcard, 8, 5) = '00000'
           and not exists ( select * from crapcrd a
               where a.cdcooper = w.cdcooper 
               and a.nrdconta = w.nrdconta
               and a.nrctrcrd = w.nrctrcrd
               and a.nrcrcard = w.nrcrcard ); 

  rw_crawcrd cr_crawcrd%ROWTYPE;
 
BEGIN
                              
  FOR rw_crapcop IN cr_crapcop LOOP  
    -- crawcrd                 
    FOR rw_crawcrd IN cr_crawcrd(rw_crapcop.cdcooper) LOOP                     
       -- remove o cartão
      BEGIN
         DELETE FROM crawcrd
         WHERE rowid = rw_crawcrd.rowid;
      END; 
    END LOOP;  
     COMMIT;
  END LOOP;  
    -- Efetuamos a transação  
    COMMIT;
END;

