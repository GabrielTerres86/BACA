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
     WHERE p.CDPROGRA IN ('CRPS576', 'CRPS577', 'CRPS634', 'CRPS627', 'CRPS641')
       AND cdcooper = pr_cdcooper
    ORDER BY NRSOLICI, NRORDPRG;
BEGIN

  DROP PROCEDURE CECRED.PC_CRPS280_I_FABA;
  DROP PROCEDURE CECRED.PC_CRPS516_FABA;
  DROP PROCEDURE CECRED.PC_JOB_CENTRALRISCO_OCR_odirlei;
  DROP PACKAGE CECRED.RISC0004_ODIRLEI;
  DROP PACKAGE CECRED.RISC0003_ODIRLEI;
  
  DROP TRIGGER CECRED.TRG_CC_GRUPO_ECONOMICO_ID;
  DROP TRIGGER CECRED.TRG_CC_GRUPO_ECONOMICO_INTEGID;
  DROP TRIGGER CECRED.TRG_CRAPGRP_PROGRESS_RECID;
  
  UPDATE craptel SET FLGTELBL = 0 WHERE nmdatela = 'FORMGE';
  
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
