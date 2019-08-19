CREATE OR REPLACE PACKAGE cecred.crip0001 AS
  
  PROCEDURE pc_mascarar(p_parallel_level IN NUMBER
                       ,p_erro OUT VARCHAR2);
                       
  FUNCTION fn_criptografar(p_string IN VARCHAR2) RETURN VARCHAR2;
  
END crip0001;
/
CREATE OR REPLACE PACKAGE BODY cecred.crip0001 AS
/*----------------------------------------------------------------------------
       Nome: pc_mascarar.prc
      Autor: Guilherme Strube
       Data: Agosto/2011
         
   Objetivo: - Mascarar nomes relevantes, telefones e e-mail dos cooperados.
             - Deixar a senha dos operadores como padrao "senha".
             
       OBS.: Quando utilizar as senhas de operadores com criptografia ENCODE, 
             deve-se alterar esse programa para ENCODE("senha").
             
 Alterações: 10/08/2011 - Utilizar o nome do titular na ASS e TTL (Guilherme)
      
             15/08/2011 - Inlcuir crapcrm p/ mascarar (Guilherme). 
             
             01/02/2011 - Mascarar senhas do crapcrm - com encode (Guilherme).
              
             09/06/2015 - Conversão Progress para PLSQL SD 294596 (Kelvin).
           
             31/10/2016 - Realizar criptografia atraves das tabelas e colunas
                          cadastradas na tabela cecreddba.tbcampos_criptografados
                          conforme solicitado no chamado 543847. (Kelvin)
                          
             27/03/2018 - Adicionado novo parametro para que o dba possa informar
                          a quantidade de paralelismo pois é variável de acordo
                          com o servidor que será executado.
-----------------------------------------------------------------------------*/
  
  /*Essa função embaralha todas as letras e números, porém mantem os caracteres
    especiais, por exemplo: AQESNS@CHCDED.CDF.UJ*/
  FUNCTION fn_criptografar(p_string IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cr_crip(p_string VARCHAR2) IS
      SELECT listagg(cstragg) WITHIN GROUP(ORDER BY r) string_cript
        FROM (SELECT CASE WHEN regexp_replace(stragg, '\d+', '0') = '0' THEN -- Se for Numérico
                            LPAD(ROUND(dbms_random.value(0, RPAD(9,LENGTH(stragg),'9'))),LENGTH(stragg),'0')
                          WHEN regexp_replace(stragg, '[A-z]+', '0') = '0' THEN -- Se for caracter A-Z
                            dbms_random.string('U', LENGTH(stragg))
                          ELSE -- Se for caracter especial
                            stragg
                          END cstragg
                    ,r
                FROM (SELECT regexp_substr(p_string, '\d+|[A-z]+|\W+', 1, LEVEL) stragg
                            ,ROWNUM r
                        FROM dual
                      CONNECT BY LEVEL <= LENGTH(p_string))
               WHERE stragg IS NOT NULL);

    rw_crip cr_crip%ROWTYPE; 
  BEGIN
    OPEN cr_crip(p_string);
      FETCH cr_crip
      INTO rw_crip;
    CLOSE cr_crip;

    RETURN rw_crip.string_cript;

  END;  

  
  /*OBS1.:************************************************************************
  
    Para o funcionamento desse script é necessário estar logado com usuário com 
    permissão máxima para executar a função "dbms_parallel_execute"
    
  *******************************************************************************/
  /*OBS2.:************************************************************************
  
    Caso ocorra algum problema na execução desse script, é possível identificar
    o problema olhando nas tabelas abaixo, olhando a situação da task e a mensagem de
    erro gerado ao executar.
    
    DBMS_PARALLEL_EXECUTE_TASK$;
    DBMS_PARALLEL_EXECUTE_CHUNKS$;
    
  *******************************************************************************/
  
  PROCEDURE pc_mascarar(p_parallel_level IN NUMBER
                       ,p_erro OUT VARCHAR2) IS
  
    CURSOR cr_parallel_table IS
      SELECT DISTINCT crpt.nmtabela
                     ,crpt.nmowner
                     ,crpt.nmtarefa
        FROM cecreddba.tbcampos_criptografados crpt;
      
    CURSOR cr_parallel_column(p_nmtabela cecreddba.tbcampos_criptografados.nmtabela%TYPE
                             ,p_nmowner cecreddba.tbcampos_criptografados.nmowner%TYPE) IS
      SELECT crpc.nmtabela
            ,crpc.nmcampo
            ,crpc.nmowner
            ,crpc.nmtarefa
            ,crpc.tpcampo
        FROM cecreddba.tbcampos_criptografados crpc
       WHERE crpc.nmtabela = p_nmtabela
         AND crpc.nmowner = p_nmowner;

    CURSOR cr_triggers IS
      SELECT * 
        FROM all_triggers trig
        JOIN cecreddba.tbcampos_criptografados crip
          ON trig.table_owner = crip.nmowner
         AND trig.table_name = crip.nmtabela
        WHERE trig.owner = 'CECRED';
  
    vr_comando VARCHAR2(5000);
    vr_contador NUMBER;
    vr_exc_error EXCEPTION;
       
  BEGIN
    
    IF p_parallel_level IS NULL OR
       p_parallel_level = 0 THEN       
       RAISE vr_exc_error;
    END IF;
    --Desabilita as triggers (Estavam gerando problemas)
    FOR rw_triggers IN cr_triggers LOOP
      EXECUTE IMMEDIATE 'ALTER TRIGGER ' || rw_triggers.trigger_name || ' DISABLE';
    END LOOP;
    
    --Loop nas tabels
    FOR rw_parallel_table IN cr_parallel_table LOOP
     
      --Monta o comando das tabelas
      vr_comando := 'UPDATE ' || rw_parallel_table.nmtabela;
      
      vr_contador := 0;
      
      --Loop nas colunas
      FOR rw_parallel_column IN cr_parallel_column(rw_parallel_table.nmtabela
                                                  ,rw_parallel_table.nmowner) LOOP
        --Valida se é a primeira vez para aplicar o SET do update
        IF vr_contador = 0 THEN
          --Valida se o campo é number para realizar o tratamento to_number
          IF rw_parallel_column.tpcampo = 1 THEN                                                                                    
            
            --Como o nrtelefo faz parte da chave, ao tentar criptografar numeros de telefones invalidos
            --que tem menos de 8 digitos, existe uma possibilidade de gerar erro no indice unico.
            --Para resolver e diminuir a chance desse problema ocorrer, apenas é feito o update 
            --para numeros com digitos maior que 7
            IF rw_parallel_column.nmcampo = 'NRTELEFO' THEN
              --Monta o comando das colunas dinamicamente 
              vr_comando := vr_comando || ' SET ' || rw_parallel_column.nmcampo 
                                       || ' = CASE WHEN LENGTH(' || rw_parallel_column.nmcampo || ') > 7 THEN 
                                              TO_NUMBER(cecred.crip0001.fn_criptografar('||rw_parallel_column.nmcampo ||')) ELSE 
                                              TO_NUMBER('||rw_parallel_column.nmcampo ||') END';
            ELSE 
              --Monta o comando das colunas dinamicamente 
              vr_comando := vr_comando || ' SET ' || rw_parallel_column.nmcampo 
                                       || ' = to_number(cecred.crip0001.fn_criptografar('||rw_parallel_column.nmcampo ||'))';
            END IF;                                        
          --Se o campo for varchar
          ELSE
            --Monta o comando das colunas dinamicamente 
            vr_comando := vr_comando || ' SET ' || rw_parallel_column.nmcampo 
                                     || ' = cecred.crip0001.fn_criptografar('||rw_parallel_column.nmcampo ||')';
          END IF;
        ELSE
          --Valida se o campo é number para realizar o tratamento to_number        
          IF rw_parallel_column.tpcampo = 1 THEN
            
            --Como o nrtelefo faz parte da chave, ao tentar criptografar numeros de telefones invalidos
            --que tem menos de 8 digitos, existe uma possibilidade de gerar erro no indice unico.
            --Para resolver e diminuir a chance desse problema ocorrer, apenas é feito o update 
            --para numeros com digitos maior que 7
            IF rw_parallel_column.nmcampo = 'NRTELEFO' THEN
              vr_comando := vr_comando || ',' || rw_parallel_column.nmcampo 
                                       || ' = CASE WHEN LENGTH(' || rw_parallel_column.nmcampo || ') > 7 THEN 
                                              TO_NUMBER(cecred.crip0001.fn_criptografar('||rw_parallel_column.nmcampo ||')) ELSE 
                                              TO_NUMBER('||rw_parallel_column.nmcampo ||') END';  
            ELSE 
              vr_comando := vr_comando || ',' || rw_parallel_column.nmcampo 
                                       || ' = to_number(cecred.crip0001.fn_criptografar('||rw_parallel_column.nmcampo ||'))';   
            END IF;  

          --Se o campo for varchar           
          ELSE
            vr_comando := vr_comando || ',' || rw_parallel_column.nmcampo 
                                     || ' = cecred.crip0001.fn_criptografar('||rw_parallel_column.nmcampo ||')';           
          END IF;   
         
        END IF;  
      
        vr_contador := vr_contador + 1;                                              
      
      END LOOP;
      
      vr_comando :=  vr_comando || ' WHERE rowid BETWEEN :start_id AND :end_id';             

      --Cria a tarefa
      dbms_parallel_execute.create_task(rw_parallel_table.nmtarefa);
      
      --Particiona os updates que serão executados
      dbms_parallel_execute.create_chunks_by_rowid(task_name   => rw_parallel_table.nmtarefa,
                                                   table_owner => rw_parallel_table.nmowner,
                                                   table_name  => rw_parallel_table.nmtabela,
                                                   by_row      => TRUE,
                                                   chunk_size  => 100000);   
      
      --Executa a task                                                                                                        
      dbms_parallel_execute.run_task(task_name      => rw_parallel_table.nmtarefa,
                                     sql_stmt       => vr_comando,
                                     language_flag  => DBMS_SQL.NATIVE,
                                     parallel_level => p_parallel_level);
                                              
    END LOOP;
    
    

    --Faz o update separadamente da senha do operador para "teste".
    dbms_parallel_execute.create_task('CRAPOPETASK');
    dbms_parallel_execute.create_chunks_by_rowid(task_name   => 'CRAPOPETASK',
                                                 table_owner => 'CECRED',
                                                 table_name  => 'CRAPOPE',
                                                 by_row      => TRUE,
                                                 chunk_size  => 100000);
      
    --Muda a senha dos operadores para 'teste'
    vr_comando := 'UPDATE crapope
                     SET cddsenha = ''teste''
                   WHERE rowid BETWEEN :start_id AND :end_id';
      
    dbms_parallel_execute.run_task(task_name      => 'CRAPOPETASK',
                                   sql_stmt       => vr_comando,
                                   language_flag  => DBMS_SQL.NATIVE,
                                   parallel_level => p_parallel_level); 
    
    --Habilita as triggers
    FOR rw_triggers IN cr_triggers LOOP
      EXECUTE IMMEDIATE 'ALTER TRIGGER ' || rw_triggers.trigger_name || ' ENABLE';
    END LOOP;
    
    
  EXCEPTION    
    WHEN vr_exc_error THEN
      p_erro := 'Informe o parâmetro de paralelismo de acordo com a capacidade do servidor (p_parallel_level).';
    WHEN OTHERS THEN
      --Habilita as triggers
      FOR rw_triggers IN cr_triggers LOOP
        EXECUTE IMMEDIATE 'ALTER TRIGGER ' || rw_triggers.trigger_name || ' ENABLE';
      END LOOP;   
      ROLLBACK;
      p_erro := 'Erro na procedure pc_mascarar: ' || SQLERRM;
  END pc_mascarar;

END crip0001;
/
