PL/SQL Developer Test script 3.0
76
declare 
  -- Local variables here
  i integer;  
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(5000);
  -- CURSOR GENÉRICO DE CALENDÁRIO
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  CURSOR cr_crapcop  IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.cdagesic
      FROM crapcop
      WHERE crapcop.cdcooper <> 3
        AND crapcop.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_craplau (pr_cdcooper IN NUMBER) IS    
  SELECT u.progress_recid    
    FROM craplau u
   WHERE u.cdcooper = pr_cdcooper
     AND u.dtmvtopg > '25/09/2020'
     AND u.insitlau = 1
     AND u.cdhistor IN (1230,1231,1232,1233,1234,2027);
  
  -- VARIAVEIS DE EXCECAO
  vr_exc_erro EXCEPTION;  
    
begin
  -- Test statements here
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
         FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
        -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
       CLOSE btch0001.cr_crapdat;
       -- MONTAR MENSAGEM DE CRITICA
        RAISE vr_exc_erro;
    ELSE
       -- APENAS FECHAR O CURSOR
       CLOSE btch0001.cr_crapdat;
    END IF;
               
    i:=0;
    FOR rw_crapcop IN cr_crapcop LOOP       
    
       dbms_output.put_line('Alterando na coop: -> '||rw_crapcop.cdcooper);      
         
       FOR rw_craplau IN cr_craplau(rw_crapcop.cdcooper) LOOP
                 
          BEGIN
             UPDATE craplau
                SET craplau.dtdebito = rw_crapdat.dtmvtolt,
                    craplau.insitlau = 3
              WHERE craplau.progress_recid = rw_craplau.progress_recid;
            EXCEPTION
              WHEN others THEN
                dbms_output.put_line('Nao foi possivel alterar o LAU : '||rw_crapcop.cdcooper||' -> '||SQLERRM);
                RAISE vr_exc_erro;
          end;
          i:= i + 1;
       END LOOP;      

      commit; 

    END LOOP; -- Crapcop
    
    dbms_output.put_line('Registros atuaizados: '||i);
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro na execução : vr_exc_erro '||SQLERRM);
  WHEN OTHERS THEN
    -- Erro
    dbms_output.put_line('Erro na execução : '||SQLERRM);
end;
0
0
