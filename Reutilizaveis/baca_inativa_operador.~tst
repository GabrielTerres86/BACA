PL/SQL Developer Test script 3.0
164
-- Created on 15/03/2018 by F0030344 
DECLARE 
 
  vr_arq_path  VARCHAR2(1000):= gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                      pr_cdcooper => 0, 
                                                      pr_nmsubdir => 'cpd/bacas/861384/'); --'/usr/coopd3/sistemad3/equipe/tiago/'; --> Diretorio que sera criado o relatorio
  vr_nmarquiv  VARCHAR2(100) := 'OPERADORES_INATIVAR.csv';
  vr_nmarqbkp  VARCHAR2(100) := 'ROLLBACK_OPE_INAT.sql';

  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_txtauxil VARCHAR2(200); -- Texto auxiliar
  
  vr_contador INTEGER := 0;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdagenci crapass.cdagenci%TYPE;
  vr_cdoperad crapope.cdoperad%TYPE;


  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE
                   ,pr_cdagenci crapope.cdagenci%TYPE
                   ,pr_cdoperad crapope.cdoperad%TYPE) IS
    SELECT ROWID 
      FROM crapope
     WHERE crapope.cdcooper = pr_cdcooper
       AND crapope.cdagenci = pr_cdagenci
       AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);

  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN 

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
  
  -- Efetuar abertura do arquivo para processamento
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarquiv   --> Nome do arquivo
                          ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_hutlfile   --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic); --> Erro
                          
  IF vr_dscritic IS NOT NULL THEN
    --Levantar Excecao
    vr_dscritic := 'Erro na leitura do arquivo --> '||vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_erro;
  END IF;  
  
  --Verifica se o arquivo esta aberto
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN   
      -- Laço para efetuar leitura de todas as linhas do arquivo 
      LOOP  
        -- Leitura da linha x
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile --> Handle do arquivo aberto
                                    ,pr_des_text => vr_dstxtlid); --> Texto lido
        
        vr_contador := vr_contador + 1;
        
        --Se for primeira linha desconsiderar pois é o cabeçalho
        IF vr_contador = 1 THEN
           continue;
        END IF;
            
        -- Ignorar linhas vazias
        IF length(vr_dstxtlid) <= 3 THEN 
          continue;
        END IF;
            
        -- Efetuar leitura do operador
        BEGIN
          --Cooperativa
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 1
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');
          vr_cdcooper := TO_NUMBER(vr_txtauxil);                                                  
                                                  
          --PA                                        
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 2
                                        ,pr_dstext      => vr_dstxtlid
                                        ,pr_delimitador => ';');
          vr_cdagenci := TO_NUMBER(vr_txtauxil);
          
          --Operador
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 3
                                        ,pr_dstext      => vr_dstxtlid
                                        ,pr_delimitador => ';');
          vr_cdoperad := vr_txtauxil;
                                        
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            vr_dscritic := 'Erro na leitura do arquivo2 linha: '||vr_contador||' --> '||vr_txtauxil;  
            dbms_output.put_line(vr_dscritic);            
            RAISE vr_exc_erro;
        END;
        
        --Procurar o operador 
        FOR rw_crapope IN cr_crapope(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_cdoperad => vr_cdoperad) LOOP
                                    
          BEGIN
            --Inativa operador naquele PA
            UPDATE crapope
               SET crapope.cdsitope = 2
             WHERE crapope.rowid = rw_crapope.rowid;
             
            pc_escreve_xml('UPDATE crapope ope '||
                              'SET ope.cdsitope = 1' ||
                           ' WHERE ope.rowid = '''||rw_crapope.rowid||''';'||chr(10));        

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problemas na hora de atualizar o registro linha: '||vr_contador||' '|| SQLERRM;
              dbms_output.put_line(vr_dscritic);
              RAISE vr_exc_erro;
          END;                                    
                                    
        END LOOP;
         
      END LOOP; --Fim loop arquivo
      
      COMMIT;
    EXCEPTION 
      WHEN no_data_found THEN 
        -- fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        
        pc_escreve_xml('COMMIT;');
        pc_escreve_xml(' ',TRUE);
        DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, to_char(sysdate,'ddmmyyyy_hh24miss')||'_'||vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
    END;
  END IF;  
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    ROLLBACK;
END;
0
0
