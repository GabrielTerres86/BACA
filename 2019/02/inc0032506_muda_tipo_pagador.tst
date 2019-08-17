PL/SQL Developer Test script 3.0
331
declare

  vr_calculou BOOLEAN;
  vr_inpessoa INTEGER;
  vr_contador integer:=0;

  PROCEDURE pc_valida_cpf(pr_nrcalcul IN NUMBER, --Numero a ser verificado
                          pr_stsnrcal OUT BOOLEAN) IS --Situacao
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_nrdigito INTEGER := 0;
      vr_nrposica INTEGER := 0;
      vr_vlrdpeso INTEGER := 2;
      vr_vlcalcul INTEGER := 0;
      vr_vldresto INTEGER := 0;
      vr_vlresult INTEGER := 0;
    BEGIN
      IF LENGTH(pr_nrcalcul) < 5 OR LENGTH(pr_nrcalcul) > 11 OR
         pr_nrcalcul IN (11111111111,
                         22222222222,
                         33333333333,
                         44444444444,
                         55555555555,
                         66666666666,
                         77777777777,
                         88888888888,
                         99999999999) THEN
        --Retornar com erro
        pr_stsnrcal := FALSE;
      ELSE
        --Inicializar variaveis calculo
        vr_vlrdpeso := 9;
        vr_nrposica := 0;
        vr_vlcalcul := 0;
      
        --Calcular digito
        FOR vr_nrposica IN REVERSE 1 .. LENGTH(pr_nrcalcul) - 2 LOOP
          vr_vlcalcul := vr_vlcalcul +
                         (TO_NUMBER(SUBSTR(pr_nrcalcul, vr_nrposica, 1)) *
                         vr_vlrdpeso);
          --Diminuir peso
          vr_vlrdpeso := vr_vlrdpeso - 1;
        END LOOP;
      
        --Calcular resto modulo 11
        vr_vldresto := Mod(vr_vlcalcul, 11);
      
        IF vr_vldresto = 10 THEN
          --Digito recebe zero
          vr_nrdigito := 0;
        ELSE
          --Digito recebe resto
          vr_nrdigito := vr_vldresto;
        END IF;
      
        vr_vlrdpeso := 8;
        vr_vlcalcul := vr_nrdigito * 9;
      
        --Calcular digito
        FOR vr_nrposica IN REVERSE 1 .. LENGTH(pr_nrcalcul) - 2 LOOP
          vr_vlcalcul := vr_vlcalcul +
                         (TO_NUMBER(SUBSTR(pr_nrcalcul, vr_nrposica, 1)) *
                         vr_vlrdpeso);
          --Diminuir peso
          vr_vlrdpeso := vr_vlrdpeso - 1;
        END LOOP;
      
        --Calcular resto modulo 11
        vr_vldresto := Mod(vr_vlcalcul, 11);
      
        IF vr_vldresto = 10 THEN
          --Digito multiplicado 10
          vr_nrdigito := vr_nrdigito * 10;
        ELSE
          --Digito recebe digito * 10 + resto
          vr_nrdigito := (vr_nrdigito * 10) + vr_vldresto;
        END IF;
      
        --Comparar digito calculado com informado
        IF TO_NUMBER(SUBSTR(pr_nrcalcul, LENGTH(pr_nrcalcul) - 1, 2)) <>
           vr_nrdigito THEN
          pr_stsnrcal := FALSE;
        ELSE
          pr_stsnrcal := TRUE;
        END IF;
      
      END IF;
    END;
  END pc_valida_cpf;

  --Validar o cnpj
  PROCEDURE pc_valida_cnpj(pr_nrcalcul IN NUMBER, --Numero a ser verificado
                           pr_stsnrcal OUT BOOLEAN) IS --Situacao
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_nrdigito INTEGER := 0;
      vr_nrposica INTEGER := 0;
      vr_vlrdpeso INTEGER := 2;
      vr_vlcalcul INTEGER := 0;
      vr_vldresto INTEGER := 0;
      vr_vlresult INTEGER := 0;
    BEGIN
      IF LENGTH(pr_nrcalcul) < 3 THEN
        --Retornar com erro
        pr_stsnrcal := FALSE;
      ELSE
        vr_vlcalcul := TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,
                                                'fm00000000000000'),
                                        1,
                                        1)) * 2;
        vr_vlresult := TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,
                                                'fm00000000000000'),
                                        2,
                                        1)) +
                       TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,
                                                'fm00000000000000'),
                                        4,
                                        1)) +
                       TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,
                                                'fm00000000000000'),
                                        6,
                                        1)) +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 1, 1)) +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 2, 1));
        vr_vlcalcul := TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,
                                                'fm00000000000000'),
                                        3,
                                        1)) * 2;
        vr_vlresult := vr_vlresult +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 1, 1)) +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 2, 1));
        vr_vlcalcul := TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,
                                                'fm00000000000000'),
                                        5,
                                        1)) * 2;
        vr_vlresult := vr_vlresult +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 1, 1)) +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 2, 1));
        vr_vlcalcul := TO_NUMBER(SUBSTR(TO_CHAR(pr_nrcalcul,
                                                'fm00000000000000'),
                                        7,
                                        1)) * 2;
        vr_vlresult := vr_vlresult +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 1, 1)) +
                       TO_NUMBER(SUBSTR(TO_CHAR(vr_vlcalcul), 2, 1));
        vr_vldresto := Mod(vr_vlresult, 10);
      
        --Se valor resto for zero
        IF vr_vldresto = 0 THEN
          --Digito recebe resto
          vr_nrdigito := vr_vldresto;
        ELSE
          vr_nrdigito := 10 - vr_vldresto;
        END IF;
        --Zerar valor calculado
        vr_vlcalcul := 0;
      
        --Calcular digito
        FOR vr_nrposica IN REVERSE 1 .. LENGTH(pr_nrcalcul) - 2 LOOP
          vr_vlcalcul := vr_vlcalcul +
                         (TO_NUMBER(SUBSTR(pr_nrcalcul, vr_nrposica, 1)) *
                         vr_vlrdpeso);
          --Incrementar peso
          vr_vlrdpeso := vr_vlrdpeso + 1;
          --Se peso > 9
          IF vr_vlrdpeso > 9 THEN
            vr_vlrdpeso := 2;
          END IF;
        END LOOP;
      
        --Calcular resto modulo 11
        vr_vldresto := Mod(vr_vlcalcul, 11);
      
        IF vr_vldresto < 2 THEN
          --Digito recebe zero
          vr_nrdigito := 0;
        ELSE
          --Digito recebe 11 menos resto
          vr_nrdigito := 11 - vr_vldresto;
        END IF;
      
        --Comparar digito calculado com informado
        IF TO_NUMBER(SUBSTR(pr_nrcalcul, LENGTH(pr_nrcalcul) - 1, 1)) <>
           vr_nrdigito THEN
          pr_stsnrcal := FALSE;
        END IF;
      
        vr_vlrdpeso := 2;
        vr_vlcalcul := 0;
      
        --Calcular digito
        FOR vr_nrposica IN REVERSE 1 .. LENGTH(pr_nrcalcul) - 1 LOOP
          vr_vlcalcul := vr_vlcalcul +
                         (TO_NUMBER(SUBSTR(pr_nrcalcul, vr_nrposica, 1)) *
                         vr_vlrdpeso);
          --Incrementar peso
          vr_vlrdpeso := vr_vlrdpeso + 1;
          --Se peso > 9
          IF vr_vlrdpeso > 9 THEN
            vr_vlrdpeso := 2;
          END IF;
        END LOOP;
      
        --Calcular resto modulo 11
        vr_vldresto := Mod(vr_vlcalcul, 11);
      
        IF vr_vldresto < 2 THEN
          --Digito recebe zero
          vr_nrdigito := 0;
        ELSE
          --Digito recebe 11 menos resto
          vr_nrdigito := 11 - vr_vldresto;
        END IF;
      
        --Comparar digito calculado com informado
        IF TO_NUMBER(SUBSTR(pr_nrcalcul, LENGTH(pr_nrcalcul), 1)) <>
           vr_nrdigito THEN
          pr_stsnrcal := FALSE;
        ELSE
          --Retornar Verdadeiro
          pr_stsnrcal := TRUE;
        END IF;
      
      END IF;
    
    END;
  
  END pc_valida_cnpj;

  /* Procedure para validar cpf ou cnpj */
  PROCEDURE pc_valida_cpf_cnpj(pr_nrcalcul IN NUMBER, --Numero a ser verificado
                               pr_stsnrcal OUT BOOLEAN, --Situacao
                               pr_inpessoa OUT INTEGER) IS --Tipo Inscricao Cedente
  BEGIN
  
    DECLARE
      --Variavel erro
      vr_flgok BOOLEAN;
      -- Variavel de retorno de erro
      vr_des_erro VARCHAR2(4000);
      -- Variavel de Excecao
      vr_exc_erro EXCEPTION;
    
    BEGIN
      --Inicializar variaveis retorno
      pr_stsnrcal := FALSE;
      pr_inpessoa := 1;
      --Se tamanho > 11 eh cnpj
      IF LENGTH(pr_nrcalcul) > 11 THEN
        --Pessoa juridica
        pr_inpessoa := 2;
      
        --Validar CNPJ
        pc_valida_cnpj(pr_nrcalcul => pr_nrcalcul,
                       pr_stsnrcal => pr_stsnrcal);
      
      ELSE
        --Pessoa Fisica
        pr_inpessoa := 1;
      
        --Validar CPF
        pc_valida_cpf(pr_nrcalcul => pr_nrcalcul,
                      pr_stsnrcal => pr_stsnrcal);
      
        --Se nao validou tentar como cnpj
        IF NOT pr_stsnrcal THEN
          --Validar CNPJ
          pc_valida_cnpj(pr_nrcalcul => pr_nrcalcul,
                         pr_stsnrcal => pr_stsnrcal);
          --Se validou
          IF pr_stsnrcal THEN
            --Pessoa Juridica
            pr_inpessoa := 2;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        --> Erro tratado
        -- Retornar erro
        pr_stsnrcal := FALSE;
      WHEN OTHERS THEN
        -- Gerar log de erro
        -- Retornar o erro
        pr_stsnrcal := FALSE;
    END;
  END pc_valida_cpf_cnpj;

begin
  for rw in (select *
               from crapsab
              where cdcooper = 2
                and nrdconta = 707740 ) LOOP
  
    vr_calculou := FALSE;
    vr_inpessoa := 0;
  
    pc_valida_cpf_cnpj(pr_nrcalcul => rw.nrinssac,
                       pr_stsnrcal => vr_calculou,
                       pr_inpessoa => vr_inpessoa);
  
    IF NOT vr_calculou THEN
      dbms_output.put_line('Erro: ' || rw.nrinssac);
      CONTINUE;
    END IF;
  
    IF rw.cdtpinsc <> vr_inpessoa THEN
      /*dbms_output.put_line('Tipo Documento incorreto: ' || rw.nrinssac ||
                           ' Nome: ' || rpad(substr(rw.nmdsacad,1,40),40,' ')||
                           ' INPESSOA: ' || vr_inpessoa || 
                           ' TIPO: ' ||rw.cdtpinsc); */
                           
      vr_contador:= vr_contador + 1;
      
      begin
        update crapsab b 
           set b.cdtpinsc = vr_inpessoa
         where b.progress_recid = rw.progress_recid;
      exception
        when others then
          dbms_output.put_line('Erro ao atualizar crapsab: conta: ' ||rw.nrdconta||' cpf: '||rw.nrinssac );
      end;
          
    END IF;    
  
  END LOOP;
  commit;
  dbms_output.put_line('Registros atualizados: '||vr_contador);
end;
0
0
