PL/SQL Developer Test script 3.0
187
-- Created on 22/06/2016 by F0030344 
DECLARE

  TYPE typ_reg_ope IS
    RECORD (cdcooper   crapcop.cdcooper%TYPE,
            cdoperad   crapope.cdoperad%TYPE);

  TYPE typ_tab_ope IS TABLE OF typ_reg_ope INDEX BY PLS_INTEGER;    
    
  CURSOR cr_crapope(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT ope.cdcooper
          ,ope.cdoperad
      FROM crapope ope
     WHERE ope.cdcooper = pr_cdcooper
       AND ope.cdsitope = 1;
     
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper   
      FROM crapcop cop
     WHERE cop.cdcooper = 1;
     
  vr_arq_path  VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
  vr_rowid     ROWID;
  
  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  vr_tab_ope   typ_tab_ope;
  vr_chave     PLS_INTEGER := 0;
  vr_exc_erro  EXCEPTION;

  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_txtauxil VARCHAR2(200); -- Texto auxiliar
  vr_achou PLS_INTEGER;  
  vr_dscritic crapcri.dscritic%TYPE;

  
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN 

  -- Iniciar Variáveis     
  vr_arq_path := '/micros/cecred/thiago/'; --'/usr/coop/sistema/equipe/tiago/'; 
  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
  pc_escreve_xml( 'ROWID'||chr(10));
  
  --carrega tab
  /***********************************************************/
  -- Efetuar abertura do arquivo para processamento
  gene0001.pc_abre_arquivo(pr_nmdireto => '/micros/cecred/thiago/'; --'/usr/coop/sistema/equipe/tiago'   --> Diretorio do arquivo
                          ,pr_nmarquiv => 'DESCTO_PERMIS.csv'  --> Nome do arquivo
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
            
            -- Ignorar linhas vazias
            IF length(vr_dstxtlid) <= 3 THEN 
              continue;
            END IF;
            
            -- Efetuar leitura do operador
            BEGIN
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 1
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
                         
              vr_chave := vr_chave + 1;                             
              vr_tab_ope(vr_chave).cdcooper := 1;
              vr_tab_ope(vr_chave).cdoperad := TRIM(vr_txtauxil);                                                      
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura do arquivo2 --> '||vr_txtauxil;  
                dbms_output.put_line(vr_dscritic);
                RAISE vr_exc_erro;
            END;
          
          END LOOP;
        EXCEPTION 
          WHEN no_data_found THEN 
            -- fechar arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        END;
      END IF;
  
  
  
  /************************************************************/
  
  
  dbms_output.put_line('Carregou a tab');
  
  vr_chave := vr_tab_ope.FIRST;
  
  WHILE vr_chave IS NOT NULL LOOP
  
    BEGIN
      SELECT 1 INTO vr_achou
          FROM crapope 
         WHERE crapope.cdcooper = vr_tab_ope(vr_chave).cdcooper 
           AND UPPER(crapope.cdoperad) = UPPER(vr_tab_ope(vr_chave).cdoperad);           
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Usuario: '||vr_tab_ope(vr_chave).cdoperad||' Nao existe');
        vr_chave := vr_tab_ope.NEXT(vr_chave);
        CONTINUE;
    END;
  
    BEGIN
      INSERT 
        INTO crapace(nmdatela, cddopcao, 
                     cdoperad, nmrotina, 
                     cdcooper, nrmodulo, 
                     idevento, idambace)
         VALUES('DESCTO', 'L',
                vr_tab_ope(vr_chave).cdoperad, ' ',
                vr_tab_ope(vr_chave).cdcooper,1,
                0,2)
       RETURNING ROWID INTO vr_rowid;
                
      pc_escreve_xml( vr_rowid || chr(10) );

      INSERT 
        INTO crapace(nmdatela, cddopcao, 
                     cdoperad, nmrotina, 
                     cdcooper, nrmodulo, 
                     idevento, idambace)
         VALUES('DESCTO', 'N',
                vr_tab_ope(vr_chave).cdoperad, ' ',
                vr_tab_ope(vr_chave).cdcooper,1,
                0,2)
       RETURNING ROWID INTO vr_rowid;
                
      pc_escreve_xml( vr_rowid || chr(10) );
                
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        --dbms_output.put_line(vr_tab_ace(vr_chave).cdoperad);
        vr_chave := vr_tab_ope.NEXT(vr_chave);
        CONTINUE;
      WHEN OTHERS THEN
        RAISE vr_exc_erro;
    END;
  
    vr_chave := vr_tab_ope.NEXT(vr_chave);
  END LOOP;
  
  pc_escreve_xml(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, 'BKP_PERMIS_DESCTO.txt', NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);  
  
  --descomentar para prod
  --COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Excecao '||Sqlerrm);
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Excecao others '||Sqlerrm);
    ROLLBACK;    
END;
0
0
