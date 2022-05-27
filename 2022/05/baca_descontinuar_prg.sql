DECLARE

  vr_nrsolici crapprg.NRSOLICI%TYPE;
  vr_nrordprg crapprg.NRORDPRG%TYPE;
  vr_cdcooper crapcop.cdcooper%TYPE := 0;

  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop c
     WHERE c.FLGATIVO = 1;

  CURSOR cr_crapprg(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT *
      FROM cecred.crapprg p
     WHERE p.CDPROGRA IN ('CRPS203', 'CRPS195', 'CRPS442', 
                          'CRPS102', 'CRPS084', 'CRPS030',
                          'CRPS401', 'CRPS396', 'CRPS197',
                          'CRPS037', 'CRPS298', 'CRPS528',
                          'CRPS508', 'CRPS204', 'CRPS212',
                          'CRPS638', 'CRPS054', 'CRPS281',
                          'CRPS147', 'CRPS439', 'CRPS190',
                          'CRPS214', 'CRPS604', 'CRPS327',
                          'CRPS360')
       AND cdcooper = pr_cdcooper
    ORDER BY NRSOLICI, NRORDPRG;
     
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    vr_nrsolici := 0;
    vr_nrordprg := 0;

    FOR rw_crapprg IN cr_crapprg(pr_cdcooper => rw_crapcop.cdcooper) LOOP
    
      IF vr_nrordprg >= 9 THEN
        vr_nrordprg := 0;
      ELSE
        vr_nrordprg := vr_nrordprg + 1;
      END IF;
      
      vr_nrsolici := TO_NUMBER( '9' || NVL(vr_nrordprg,0) || LPAD(rw_crapprg.nrsolici,3,'0') );

      UPDATE cecred.crapprg p
         SET p.NRSOLICI = vr_nrsolici
           , p.INLIBPRG = 2
       WHERE p.CDCOOPER = rw_crapcop.cdcooper
         AND p.CDPROGRA = rw_crapprg.cdprogra;
         
    END LOOP;                        
  END LOOP;
   
  COMMIT; 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
END;
