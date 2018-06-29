DECLARE
   Cursor c1 IS
      SELECT 1 idintegrante              -- not null  (sequencial)
             , x.idgrupo                 -- not null
             , ass.nrcpfcgc   nrcpfcgc            -- not null
             , x.cdcooper
             , x.nrdconta
             , ass.inpessoa   tppessoa -- not null
             , 1 tpcarga       -- not null
             , 2 tpvinculo     -- Tipo do Vinculo (1-Conta PJ/ 2-Socio(A)/ 3-Conjuge/ 4-Companheiro/ 5-Parente Primeiro Grau/ 6-Parente Segundo Grau/ 7-Outro)
             , null peparticipacao
             , x.dtinclusao    --  not null ou sysdate
             , 1    cdoperad_inclusao  -- nvl(ass.cdopeori, ass.cdoplcpa) 
             , null DTEXCLUSAO
             , null CDOPERAD_EXCLUSAO
             , ass.nmprimtl   nmintegrante
         FROM tbcc_grupo_economico x, crapass ass
        WHERE ass.nrdconta = x.nrdconta
          AND ass.cdcooper = x.cdcooper 
          ;

   var_idintegrante   number(10) := 0;
   var_encontrou      number(10)  := 0;
   
BEGIN
--   carrega o codigo do ultimo integrante sequencia unica do grupo integrantes
--     select max(t.idintegrante)  into var_idintegrante
--       from CECRED.TBCC_GRUPO_ECONOMICO_INTEG t;

  var_idintegrante := 0;

  FOR reg_c1 in c1 loop

    BEGIN
      -- Verificar se o CPF/CNPJ já está no grupo integrante
      select count(*) into var_encontrou
        from cecred.tbcc_grupo_economico_integ inte
       where inte.idgrupo  = reg_c1.idgrupo
         AND inte.nrcpfcgc = reg_c1.nrcpfcgc;

      --
      IF var_encontrou = 0 THEN
           
        var_idintegrante := var_idintegrante + 1;
       
        BEGIN
          insert into TBCC_GRUPO_ECONOMICO_INTEG( 
                        idintegrante 
                        ,idgrupo 
                        ,nrcpfcgc 
                        ,cdcooper 
                        ,nrdconta 
                        ,tppessoa  
                        ,tpcarga 
                        ,tpvinculo 
                        ,peparticipacao 
                        ,dtinclusao 
                        ,cdoperad_inclusao 
                        ,cdoperad_exclusao 
                        ,nmintegrante )
                        values (
                        null -- var_idintegrante 
                        ,reg_c1.idgrupo 
                        ,reg_c1.nrcpfcgc 
                        ,reg_c1.cdcooper 
                        ,reg_c1.nrdconta 
                        ,reg_c1.tppessoa  
                        ,reg_c1.tpcarga 
                        ,reg_c1.tpvinculo 
                        ,reg_c1.peparticipacao 
                        ,reg_c1.dtinclusao 
                        ,reg_c1.cdoperad_inclusao 
                        ,reg_c1.cdoperad_exclusao 
                        ,reg_c1.nmintegrante);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro ao inserir: ' || reg_c1.idgrupo || reg_c1.nrcpfcgc || reg_c1.nrdconta);
        END;
      END IF;
    END;

  END LOOP;

  COMMIT;
END;
