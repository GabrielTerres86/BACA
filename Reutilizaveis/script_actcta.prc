/* 12/04/2019 - RITM0013981 aplicação massiva da opção A da tela ACTCTA (Carlos) */
create or replace procedure script_actcta is

  vr_nmdireto    VARCHAR2(100);
  vr_nmarquiv    VARCHAR2(50) := 'actcta.csv'; 
  vr_nmarqbkp    VARCHAR2(50) := 'ROLLBACK_actcta.sql';
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_texto_completo  VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha   INTEGER := 0;  
  vr_crapalt_progress_recid  VARCHAR2(30);

  vr_dsaltera VARCHAR2(50) := 'Ativacao de conta efetuada';

  vr_cdcooper INTEGER;
  vr_nrdconta NUMBER;
  vr_dtelimin crapass.dtelimin%TYPE;

  vr_des_xml         CLOB := NULL;
  vr_des_alt         CLOB := NULL;
  vr_des_ret         CLOB := NULL;
  vr_setlinha    VARCHAR2(10000);

  vr_dscritic    crapcri.dscritic%TYPE;

  vr_exc_saida   EXCEPTION;
  
  CURSOR cr_crapalt(pr_cdcooper crapcop.cdcooper%TYPE,
                    pr_nrdconta crapass.nrdconta%TYPE,
                    pr_dtaltera DATE) IS
  SELECT dsaltera, cdoperad, progress_recid
    FROM crapalt
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND dtaltera = TRUNC(pr_dtaltera);
  
  rw_crapalt cr_crapalt%ROWTYPE;


  PROCEDURE pc_escreve_alt(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_alt
                           ,vr_texto_completo
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 
  
  -- Arquivo de retorno da execução
  PROCEDURE pc_escreve_ret(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_ret
                           ,vr_texto_completo_ret
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 


begin
  
  -- Buscar caminho do micros
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/actcta/';
    
  -- Abrir o arquivo PESSOA FISICA
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto    --> Diretório do arquivo
                           ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                           ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                           ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                           ,pr_des_erro => vr_dscritic);  --> Erro
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
        
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  vr_des_ret := NULL;
  dbms_lob.createtemporary(vr_des_ret, TRUE);
  dbms_lob.open(vr_des_ret, dbms_lob.lob_readwrite);

  -- Laco para leitura de linhas do arquivo
  LOOP
    -- Carrega handle do arquivo
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                ,pr_des_text => vr_setlinha); --> Texto lido         
    vr_contlinha:= vr_contlinha + 1;
          
    -- ignorar primeira linha
    IF vr_contlinha = 1 THEN
      continue;
    END IF;

    -- Retirar quebra de linha
    vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
    
    vr_cdcooper := TRIM(gene0002.fn_busca_entrada(1,vr_setlinha,';'));
    vr_nrdconta := replace(replace(gene0002.fn_busca_entrada(2,vr_setlinha,';'),'.',''),'-','');
    
    BEGIN

      BEGIN -- Atualizar crapass.dtelimin para null
        SELECT dtelimin INTO vr_dtelimin FROM crapass WHERE cdcooper = vr_cdcooper AND nrdconta = vr_nrdconta;
      
        UPDATE crapass a SET a.dtelimin = NULL WHERE a.cdcooper = vr_cdcooper AND a.nrdconta = vr_nrdconta;

        -- Retornar data de elimin anterior
        pc_escreve_ret('UPDATE crapass SET dtelimin = ''' || to_char(vr_dtelimin,'dd/mm/rrrr') || ''' WHERE cdcooper = ' || vr_cdcooper || ' AND nrdconta = ' || vr_nrdconta || ';'||chr(10));
        
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(pr_cdcooper => 0, pr_compleme => 'cdcooper: ' || vr_cdcooper || ' nrdconta:' || vr_nrdconta);
      END;
      
      OPEN cr_crapalt(pr_cdcooper => vr_cdcooper,
                      pr_nrdconta => vr_nrdconta,
                      pr_dtaltera => trunc(sysdate));
      FETCH cr_crapalt INTO rw_crapalt;
      
      -- Alterar alt encontrado
      IF cr_crapalt%FOUND THEN
        CLOSE cr_crapalt;
        BEGIN          
          -- se não houver log de ativação da conta no dia, concatenar
          IF dbms_lob.instr(lob_loc => rw_crapalt.dsaltera, pattern => vr_dsaltera) = 0 THEN           
            vr_des_alt := NULL;
            vr_texto_completo := NULL;
            pc_escreve_alt(rw_crapalt.dsaltera);
            pc_escreve_alt(vr_dsaltera || ',');
            UPDATE crapalt
               SET dsaltera = vr_des_alt
                  ,cdoperad = '996'
             WHERE cdcooper = vr_cdcooper
               AND nrdconta = vr_nrdconta
               AND dtaltera = TRUNC(SYSDATE);               

            -- Retornar crapalt.dsaltera e crapalt.cdoperad

            pc_escreve_ret('UPDATE crapalt SET dsaltera = ''' || rw_crapalt.dsaltera || ''', cdoperad = ''' || rw_crapalt.cdoperad || ''' WHERE progress_recid = ' || vr_crapalt_progress_recid||';'||chr(10), TRUE);
            
          END IF;
        EXCEPTION          
          WHEN OTHERS THEN
            cecred.pc_internal_exception(pr_cdcooper => 0, pr_compleme => 'cdcooper: ' || vr_cdcooper || ' nrdconta:' || vr_nrdconta);
        END;
      -- insere alteração
      ELSE
        CLOSE cr_crapalt;        
        BEGIN
          vr_des_alt := NULL;
          vr_texto_completo := NULL;
          pc_escreve_alt(vr_dsaltera || ',');
          INSERT INTO crapalt
            (cdcooper
            ,nrdconta
            ,dtaltera
            ,tpaltera
            ,cdoperad
            ,dsaltera)
          VALUES
            (vr_cdcooper
            ,vr_nrdconta
            ,TRUNC(SYSDATE)
            ,2
            ,'996'
            ,vr_des_alt) RETURNING progress_recid INTO vr_crapalt_progress_recid; 

          -- Script para Retornar o insert da crapalt
          pc_escreve_ret('DELETE crapalt a WHERE a.progress_recid = '||vr_crapalt_progress_recid||';'||chr(10));
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception(pr_cdcooper => 0, pr_compleme => 'cdcooper: ' || vr_cdcooper || ' nrdconta:' || vr_nrdconta);
        END;
      END IF;

    END;
  END LOOP; -- Loop Arquivo

   EXCEPTION 
  WHEN no_data_found THEN
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
	COMMIT;
    -- Finaliza o arquivo de rollback da execução
    pc_escreve_ret('COMMIT;');
    pc_escreve_ret(' ',TRUE);
    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_ret, vr_nmdireto, to_char(sysdate,'ddmmyyyy_hh24miss')||'_'||vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_ret);
    dbms_lob.freetemporary(vr_des_ret);
    
  WHEN vr_exc_saida THEN
    dbms_output.put_line(vr_dscritic);
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
end script_actcta;
/
