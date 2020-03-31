DECLARE 
  CURSOR cr_tbcpessoa(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS 
    SELECT tbcp.idpessoa, tbcp.dtrevisao_cadastral
    FROM tbcadast_pessoa tbcp
       , crapass ass
    WHERE tbcp.nrcpfcgc = ass.nrcpfcgc
    AND ass.cdcooper= pr_cdcooper 
    AND ass.nrdconta= pr_nrdconta;

  vr_arq_path  VARCHAR2(1000):= gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                      pr_cdcooper => 0, 
                                                      pr_nmsubdir => 'cpd/bacas/ritm0054534'); 

  vr_nmarquiv  VARCHAR2(100) := 'revisao_cadastral.csv';
  vr_nmarqbkp  VARCHAR2(100) := 'ROLLBACK_revisao_contas.sql';
  vr_nmarqcri  VARCHAR2(100) := 'CRITICAS_revisao_contas.txt';  
  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_contador INTEGER := 0;
  vr_tab_linhacsv   gene0002.typ_split;


 -- Variaveis da revisao cadastral
  rw_tbpessoa cr_tbcpessoa%ROWTYPE;
  vr_cdcooper crapass.cdcooper%TYPE;
  vr_nrdconta crapass.nrdconta%TYPE;

 -- Variaveis de excessao
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;


 -- Variaveis de arquivo rollback
  vr_des_rollback_xml         CLOB;
  vr_texto_rb_completo  VARCHAR2(32600);
 -- Variaveis do arquivo de critica
  vr_des_critic_xml         CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);  
  

  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN 
  -- Inicializar o CLOB do rollback
  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  -- Inicializar o CLOB das criticas
  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;

  
  -- Efetuar abertura do arquivo para processamento
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarquiv   --> Nome do arquivo
                          ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_hutlfile   --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic); --> Erro
                          
  IF vr_dscritic IS NOT NULL THEN
    --Levantar Excecao
    vr_dscritic := 'Erro na leitura do arquivo --> '||vr_dscritic;
    pc_escreve_xml_critica(vr_dscritic || chr(10));
    RAISE vr_exc_erro;
  END IF;  
  
  --Verifica se o arquivo esta aberto
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN   
      -- Laço para efetuar leitura de todas as linhas do arquivo 
      LOOP  
        vr_cdcooper := 0;
        vr_nrdconta := 0;

        -- Leitura da linha x
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile --> Handle do arquivo aberto
                                    ,pr_des_text => vr_dstxtlid); --> Texto lido
       
        -- Ignorar linhas vazias
        IF length(vr_dstxtlid) <= 1 THEN 
          continue;
        END IF;
        
        vr_contador := vr_contador + 1;
        
        -- Busca o numero da conta e da cooperativa 
        vr_tab_linhacsv := gene0002.fn_quebra_string(vr_dstxtlid,';');
        vr_cdcooper := gene0002.fn_char_para_number(vr_tab_linhacsv(1));
        vr_nrdconta := gene0002.fn_char_para_number(vr_tab_linhacsv(3));       
        
        IF nvl(vr_cdcooper,0) = 0 OR nvl(vr_nrdconta,0) = 0 THEN 
          pc_escreve_xml_critica('Erro ao encontrar cooperativa e conta ' || vr_dstxtlid  || chr(10));
          CONTINUE;
        END IF;
        
        -- INICIO DAS VALIDACOES DE REVISAO CADASTRAL
        -- Busca em que será realizada a revisão cadastral
        OPEN cr_tbcpessoa(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
        FETCH cr_tbcpessoa INTO rw_tbpessoa;
        IF cr_tbcpessoa%NOTFOUND THEN
          CLOSE cr_tbcpessoa;
          pc_escreve_xml_critica('Pessoa nao encontrada. ' || vr_dstxtlid  || chr(10));
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_tbcpessoa;

        BEGIN        
          -- Atualiza a data de revisão cadastral
          UPDATE tbcadast_pessoa 
          SET dtrevisao_cadastral = SYSDATE
          WHERE idpessoa = rw_tbpessoa.idpessoa;

          -- Insere a descrição da alteração para a tela ALTERA          
          INSERT INTO crapalt (
             crapalt.nrdconta
            ,crapalt.dtaltera
            ,crapalt.tpaltera
            ,crapalt.dsaltera
            ,crapalt.cdcooper
            ,crapalt.flgctitg
            ,crapalt.cdoperad)
          VALUES(
            vr_nrdconta,
            trunc(SYSDATE),
            1,
            'Ação rev. cadastral com base na movimentação da conta',
            vr_cdcooper,
            1,
            1
          );
          
          pc_escreve_xml_rollback('UPDATE tbcadast_pessoa '||
                       ' SET dtrevisao_cadastral = ' || nvl('''' || to_char(rw_tbpessoa.dtrevisao_cadastral, 'DD/MM/YYYY') || '''', 'NULL') ||
                       ' WHERE idpessoa = ' ||rw_tbpessoa.idpessoa ||';'||chr(10));
          
          pc_escreve_xml_rollback('DELETE FROM crapalt '||
                       ' WHERE cdcooper = ' ||vr_cdcooper ||
                       '   AND nrdconta = ' || vr_nrdconta ||
                       '   AND dtaltera = ''' || TRUNC(SYSDATE) || 
                       ''';'||chr(10));
          
        EXCEPTION
          WHEN OTHERS THEN
            pc_escreve_xml_critica('Erro ao criar crapalt ' || vr_dstxtlid || ' ' || SQLERRM || chr(10));
            ROLLBACK;
            CONTINUE;
        END;
   
        COMMIT;   
      END LOOP; --Fim loop arquivo


    EXCEPTION 
      WHEN no_data_found THEN 
        pc_escreve_xml_critica('Qtde contas lidas:'||vr_contador, TRUE);
        dbms_output.put_line('Qtde contas lidas:'||vr_contador);
        
        pc_escreve_xml_rollback('COMMIT;');
        pc_escreve_xml_rollback(' ',TRUE);
        
        -- fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        
        -- Tansforma em arquivo de bkp
        DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_rollback_xml, vr_arq_path, vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
        DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_critic_xml, vr_arq_path, vr_nmarqcri, NLS_CHARSET_ID('UTF8'));        

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_rollback_xml);
        dbms_lob.freetemporary(vr_des_rollback_xml);

        dbms_lob.close(vr_des_critic_xml);
        dbms_lob.freetemporary(vr_des_critic_xml);

        dbms_output.put_line('Rotina finalizada, verifique arquivo de criticas em :' || vr_arq_path);
      WHEN OTHERS THEN
        dbms_output.put_line('Erro inesperado 1 ' || SQLERRM);
        cecred.pc_internal_exception;
    END;
  END IF;  
  
  
  COMMIT; 

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro inesperado 2' || SQLERRM);    
    cecred.pc_internal_exception;
    ROLLBACK;
END;
