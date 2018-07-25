PL/SQL Developer Test script 3.0
61
DECLARE
  --Seleciona os cooperados
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3;


  -- Cursor identifica os registros pela "chave" distintamente
  CURSOR c1 (pr_cdcooper IN crapcop.cdcooper%TYPE)is
    SELECT *
      FROM (
        SELECT cdcooper
             , nrdconta
             , nrctremp
             , dtinreg
             , dthistreg        
             , cdmotivo
             , ROWID
             , ROW_NUMBER () OVER (PARTITION BY t.cdcooper
                                               ,t.nrdconta
                                               ,t.nrctremp
                                               ,t.dtinreg
                                               ,t.dthistreg
                                               ,t.cdmotivo         
                                       ORDER BY cdcooper
                                              , nrdconta
                                              , nrctremp
                                              , dtinreg
                                              , dthistreg        
                                              , cdmotivo) SEQ_AT
          FROM tbhist_ativo_probl t
         WHERE cdcooper = pr_cdcooper
         ORDER BY cdcooper
               , nrdconta
               , nrctremp
               , dtinreg
               , dthistreg        
               , cdmotivo
     ) tmp
     WHERE seq_at <> 1;


BEGIN

  dbms_output.put_line('inicio: ' || to_char(SYSDATE,'hh24:mi:ss'));  
  FOR rw_cop IN cr_cop LOOP
    dbms_output.put_line('COOP: ' || rw_cop.cdcooper );
    FOR r1 IN c1 (rw_cop.cdcooper) LOOP
      DELETE tbhist_ativo_probl
       WHERE ROWID = r1.rowid;
    END LOOP;  
    COMMIT;   -- Commit apos cada cooperativa
  END LOOP;

  dbms_output.put_line('fim: ' || to_char(SYSDATE,'hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
0
0
