declare

  CURSOR cr_dados IS
    SELECT A.CDCOOPER
      , A.NRDCONTA
    FROM CECRED.CRAPASS A
    WHERE A.DTDEMISS IS NULL
      AND NMPAIPTL NOT LIKE 'TST CARGA MDM%'
      AND ROWNUM <= 4
    UNION ALL 
    SELECT A.CDCOOPER
      , A.NRDCONTA
    FROM CECRED.CRAPASS A
    WHERE A.DTDEMISS IS NOT NULL
      AND NMPAIPTL NOT LIKE 'TST CARGA MDM%'
      AND ROWNUM <= 6;

  rg_dados cr_dados%ROWTYPE;
  
  vr_dscritic VARCHAR2(2000);
  vr_exception EXCEPTION;

begin
  
  OPEN cr_dados;
  
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    BEGIN
      
      UPDATE CECRED.CRAPASS ASS
        SET ASS.QTFOLTAL = ASS.QTFOLTAL + 2
          , ASS.QTEXTMES = ASS.QTEXTMES + 2
          , ASS.QTFOLMES = ASS.QTFOLMES + 2
          , ASS.NMPAIPTL = 'TST CARGA MDM TESTE 04'
      WHERE ASS.CDCOOPER = rg_dados.CDCOOPER
        AND ASS.NRDCONTA = rg_dados.NRDCONTA;
      
    EXCEPTION 
      WHEN OTHERS THEN
        
        vr_dscritic := 'Erro no Update: ' || SQLERRM;
        RAISE vr_exception;
        
    END;
    
  END LOOP;
  
  CLOSE cr_dados;
  
  COMMIT;
  
exception
  WHEN vr_exception THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  when others then
    ROLLBACK;
    raise_application_error(-20001, 'erro: ' || SQLERRM);
end;
