PL/SQL Developer Test script 3.0
65
-- Created on 23/09/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
  
  -- CURSOR GENÉRICO DE CALENDÁRIO
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  CURSOR cr_crapcop  IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,crapcop.cdagesic
          FROM crapcop
          WHERE crapcop.cdcooper <> 3;
  rw_crapcop cr_crapcop%ROWTYPE;
  
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
               
    FOR rw_crapcop IN cr_crapcop LOOP
   
       dbms_output.put_line('Alterando na coop: -> '||rw_crapcop.cdcooper);  
      
      begin

         UPDATE crapatr
                SET crapatr.dtfimatr = rw_crapdat.dtmvtopr,
                    crapatr.cdopeexc = '1'
              WHERE crapatr.cdcooper = rw_crapcop.cdcooper
                AND crapatr.cdhistor = 1019
                AND crapatr.dtfimatr IS NULL;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('Nao foi possivel alterar o ATR : '||rw_crapcop.cdcooper||'->'||SQLERRM);
                RAISE vr_exc_erro;
      end;

      commit; 

      END LOOP; -- Crapcop

    EXCEPTION

      WHEN vr_exc_erro THEN
        dbms_output.put_line('Erro na execução : vr_exc_erro '||SQLERRM);
      WHEN OTHERS THEN
        -- Erro
        dbms_output.put_line('Erro na execução : '||SQLERRM);
end;
0
0
