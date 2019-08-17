PL/SQL Developer Test script 3.0
56
declare 

  --Busca todas as cooperativas
  CURSOR cr_crapcop IS
  SELECT crapcop.cdcooper
    FROM crapcop;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  vr_dscritic VARCHAR2(2000);
  vr_exec_erro EXCEPTION; 

begin
  
  --Percorre todas as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
    
    BEGIN
      INSERT INTO craptab
                 (nmsistem
                 ,tptabela
                 ,cdempres
                 ,cdacesso
                 ,tpregist
                 ,dstextab
                 ,cdcooper)
          VALUES('CRED'
                ,'GENERI'
                ,00
                ,'FINTRFTEDS'
                ,400
                ,'Tributos Municipais ISS - LCP 157'
                ,rw_crapcop.cdcooper);
              
    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir registro: ' || SQLERRM; 
         RAISE vr_exec_erro;
    END;
              
  END LOOP;
   
  COMMIT;
  
EXCEPTION  
  WHEN vr_exec_erro THEN
     dbms_output.put_line(vr_dscritic);

    ROLLBACK;
    
  WHEN OTHERS THEN
        
    dbms_output.put_line('Erro a executar o programa:' || SQLERRM);

    ROLLBACK;
    
end;
0
0
