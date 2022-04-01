BEGIN
  UPDATE CRAPPRG c
     SET c.cdrelato##3 = '819',
         c.cdrelato##4 = '820'     
    WHERE c.cdprogra = 'JB_ARQPRST';    
   
  FOR st_coop IN (SELECT cdcooper
                   FROM crapcop) LOOP
    INSERT INTO crapprg(nmsistem,cdprogra,dsprogra##1,cdrelato##1,cdcooper,nrsolici,nrordprg)
           VALUES ('CRED','CRPS814','REL DE EMPRESTIMO CONTRATADO SEM SEGURO PRESTAMISTA CONTRIBUTARIO',814,st_coop.cdcooper,1,2);       
  END LOOP; 
  COMMIT;
END;
/
