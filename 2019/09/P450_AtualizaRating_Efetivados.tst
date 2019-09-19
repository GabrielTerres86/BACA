PL/SQL Developer Test script 3.0
225
DECLARE

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  vr_cdcooper           tbrisco_operacoes.cdcooper%TYPE; 
  vr_nrdconta           tbrisco_operacoes.nrdconta%TYPE;
  vr_nrctremp           tbrisco_operacoes.nrctremp%TYPE;
  vr_tpctrato           tbrisco_operacoes.tpctrato%TYPE;
  vr_inrisco_rating     tbrisco_operacoes.inrisco_rating%TYPE;
  vr_innivel_rating     tbrisco_operacoes.innivel_rating%TYPE;
  vr_dtrisco_rating     tbrisco_operacoes.dtrisco_rating%TYPE;
  
  

  vchar varchar2(100);
  vchar2 varchar2(100);
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  -- Variaveis locais
  vr_dsextens varchar2(3);
  vr_nmarquiv VARCHAR2(100);
  vr_dsdireto VARCHAR2(1000);
  vr_dsdirarq VARCHAR2(1000);
  vr_dsdlinha VARCHAR2(2000);
  vr_lerlinha VARCHAR2(2000); 
  vr_linetaxas VARCHAR2(2000);
  vr_lertxfinal VARCHAR2(2000);
  vr_contline INTEGER := 0;

  vr_arqhandl utl_file.file_type;
  vr_vet_arqv GENE0002.typ_split;
  vr_vet_dado GENE0002.typ_split;
      
      
  vr_qtregist INTEGER := 0;


BEGIN

  -- Seta as variaveis
  vr_nmarquiv := 'rating_carga.csv';
  -- diretorio do homol6 - TROCAR PARA O DE PROD
  vr_dsdireto := '/micros/cecred/equipe/jaison/';
  vr_vet_arqv := GENE0002.fn_quebra_string(pr_string  => vr_nmarquiv, pr_delimit => '.');
  vr_dsextens := LOWER(vr_vet_arqv(2));
  vr_nmarquiv := vr_vet_arqv(1) || '.' || vr_dsextens;
  vr_dsdirarq := vr_dsdireto || vr_nmarquiv;

  -- Se NAO for CSV
  IF vr_dsextens <> 'csv' THEN
    vr_cdcritic := 0;
    vr_dscritic := 'Extensão de arquivo não permitida.';
    RAISE vr_exc_saida;
  END IF;

  -- Se NAO encontrar o arquivo com a extensao em letras minusculas
  IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq) THEN
    vr_nmarquiv := vr_vet_arqv(1) || '.' || UPPER(vr_dsextens);
    vr_dsdirarq := vr_dsdireto || vr_nmarquiv;
    -- Se NAO encontrar o arquivo com a extensao em letras maiusculas
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Arquivo não encontrado no diretório.';
      RAISE vr_exc_saida;
    END IF;
  END IF;

  -- Abrir arquivo
  GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto   --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nmarquiv   --> Nome do arquivo
                          ,pr_tipabert => 'R'           --> Modo de abertura
                          ,pr_utlfileh => vr_arqhandl   --> Handle arquiv aberto
                          ,pr_des_erro => vr_dscritic); --> Erro
  IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_saida;
  END IF;

  
  dbms_output.put_line('TBRISCO;Coop;Conta;Contrato;Tipo;SIT;DT RAT;DTRAT AUT;Risco;RIS AUT;ORIG;NIVEL;VENCTO;ENC;SAS');

  LOOP
    -- Verifica se o arquivo esta aberto
    IF utl_file.IS_OPEN(vr_arqhandl) THEN

      BEGIN 
        -- Faz a leitura da linha
        GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandl   --> Arquivo aberto
                                    ,pr_des_text => vr_dsdlinha); --> Texto lido

        vr_contline := vr_contline + 1;

        IF vr_contline >= 2 THEN -- busca linhas de registros
          -- LAYOUT ARQUIVO
          --> CDCOOPER;NRDCONTA;CDMODALI;NRCTREMP;CDRATING;DTRATING;NIVEL;TPCTRATO
          -- vr_cdcooper         
          -- vr_nrdconta         
          -- vr_nrctremp         
          -- vr_tpctrato         
          -- vr_inrisco_rating   
          -- vr_innivel_rating   
          -- vr_dtrisco_rating       
           
          --cooperativa
          vr_cdcooper := REPLACE(SUBSTR(vr_dsdlinha, 1, (INSTR(vr_dsdlinha, ';', 1, 1))), ';');
          IF (TRIM(vr_cdcooper) = '') THEN
            vr_dscritic := 'Cooperativa vazia. Erro no arquivo, linha: ' || vr_contline || '.';
            RAISE  vr_exc_saida;
          END IF;
          --dbms_output.put_line('Coop: ' || vr_cdcooper);
          
          -- conta
          vchar := SUBSTR(vr_dsdlinha, (INSTR(vr_dsdlinha, ';', 1,1)));
          vr_nrdconta :=       TRIM(REPLACE(SUBSTR(vchar, 1, (INSTR(vchar, ';', 1, 2))), ';'));
          IF (TRIM(vr_nrdconta) = '') THEN
            vr_dscritic := 'Conta vazia. Erro no arquivo, linha: ' || vr_contline || '.';
            RAISE  vr_exc_saida;
          END IF;
          --dbms_output.put_line('Conta: ' || vr_nrdconta);
          
          -- Contrato
          vchar := SUBSTR(vr_dsdlinha, (INSTR(vr_dsdlinha, ';', 1,3)));
          vr_nrctremp := TRIM(REPLACE(SUBSTR(vchar, 1, (INSTR(vchar, ';', 1, 2))), ';'));
          IF (TRIM(vr_nrctremp) = '') THEN
            vr_dscritic := 'Contrato vazio. Erro no arquivo, linha: ' || vr_contline || '.';
            RAISE  vr_exc_saida;
          END IF;
          --dbms_output.put_line('Contrato: ' || vr_nrctremp);

          -- Risco Rating
          vchar := SUBSTR(vr_dsdlinha, (INSTR(vr_dsdlinha, ';', 1,4)));
          vr_inrisco_rating := TRIM(REPLACE(SUBSTR(vchar, 1, (INSTR(vchar, ';', 1, 2))), ';'));
          IF (TRIM(vr_inrisco_rating) = '') THEN
            vr_dscritic := 'Risco. Erro no arquivo, linha: ' || vr_contline || '.';
            RAISE  vr_exc_saida;
          END IF;
          --dbms_output.put_line('Risco: ' || vr_inrisco_rating);

          -- Data Rating
          vchar := SUBSTR(vr_dsdlinha, (INSTR(vr_dsdlinha, ';', 1,5)));
          vr_dtrisco_rating := to_date(TRIM(REPLACE(SUBSTR(vchar, 1, (INSTR(vchar, ';', 1, 2))), ';')),'dd/mm/yyyy');
          IF (TRIM(vr_dtrisco_rating) = '') THEN
            vr_dscritic := 'Data vazia. Erro no arquivo, linha: ' || vr_contline || '.';
            RAISE  vr_exc_saida;
          END IF;
          --dbms_output.put_line('Data Risco: ' || vr_dtrisco_rating);

          -- Nivel Rating
          vchar := SUBSTR(vr_dsdlinha, (INSTR(vr_dsdlinha, ';', 1,6)));
          vr_innivel_rating := TRIM(REPLACE(SUBSTR(vchar, 1, (INSTR(vchar, ';', 1, 2))), ';'));
          IF (TRIM(vr_innivel_rating) = '') THEN
            vr_dscritic := 'Nivel vazio. Erro no arquivo, linha: ' || vr_contline || '.';
            RAISE  vr_exc_saida;
          END IF;
          --dbms_output.put_line('Nivel Risco: ' || vr_innivel_rating);
              
          --tem que ser o ultimo 
          vchar := SUBSTR(vr_dsdlinha, (INSTR(vr_dsdlinha, ';', 1,7)));             
          vchar :=  substr(SUBSTR(vr_dsdlinha, (INSTR(vr_dsdlinha, ';', 1,7))),2,length(vchar)-2);                            
          vr_tpctrato := vchar;
          IF (TRIM(vr_tpctrato) = '') THEN
            vr_dscritic := 'Tipo vazio. Erro no arquivo, linha: ' || vr_contline || '.';
            RAISE  vr_exc_saida;
          END IF;
          --dbms_output.put_line('Tipo: ' || vr_tpctrato);


-----------------------------------------------------------------------
          rati0003.pc_grava_rating_operacao(pr_cdcooper          => vr_cdcooper
                                           ,pr_nrdconta          => vr_nrdconta
                                           ,pr_nrctrato          => vr_nrctremp
                                           ,pr_tpctrato          => vr_tpctrato
                                           ,pr_ntrating          => vr_inrisco_rating
                                           ,pr_ntrataut          => vr_inrisco_rating
                                           ,pr_dtrating          => vr_dtrisco_rating
                                           ,pr_dtrataut          => vr_dtrisco_rating
                                           ,pr_strating          => 4 -- EFETIVO
                                           ,pr_innivel_rating    => vr_innivel_rating
                                           ,pr_orrating          => 3 -- Carga Inicial - Regra Aimaro
                                           --Variáveis para gravar o histórico
                                           ,pr_cdoperad          => '1'
                                           ,pr_dtmvtolt          => SYSDATE
                                           ,pr_justificativa     => 'SCRIPT - CARGA RATING PROVISAO'
                                           ,pr_tpoperacao_rating => 1
                                           --Variáveis de crítica
                                           ,pr_cdcritic          => vr_cdcritic
                                           ,pr_dscritic          => vr_dscritic);
------------------------------------------------------------------------------------------

        END IF;  -- Fim do contador > 1
                                                 
      EXCEPTION
        WHEN no_data_found THEN
              
          -- Fechamos o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl); 
          EXIT;
      END;

    END IF; -- utl_file.IS_OPEN()

    IF  mod(vr_contline,100) = 0 THEN
      COMMIT;
    END IF;

  END LOOP; -- contratos

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN

    dbms_output.put_line('Erro:' || vr_dscritic);
    ROLLBACK;
   
  WHEN OTHERS THEN
        
  --  dbms_output.put_line('Erro ao executar o programa1:' ||vr_dscritic|| SQLERRM);
    dbms_output.put_line('Erro_1:' ||vr_cdcooper||'-'||vr_nrdconta||'-'||vr_nrctremp||' '||sqlerrm);

    ROLLBACK;

END;
0
10
vr_cdcooper
vr_nrdconta
vr_nrctremp
vr_tpctrato
vr_inrisco_rating
vr_innivel_rating
vr_dtrisco_rating

vr_dsdlinha
vchar
