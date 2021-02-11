DECLARE

  VR_NOME_BACA  VARCHAR2(100);
  VR_NMARQLOG   VARCHAR2(100);
  VR_NMARQBKP   VARCHAR2(100);
  VR_IND_ARQLOG UTL_FILE.FILE_TYPE;
  VR_NMDIRETO   VARCHAR2(4000);
  VR_DSCRITIC   VARCHAR2(4000);
  VR_EXC_ERRO EXCEPTION;

  -- Criacao do diretorio de arquivos
  VR_TYP_SAIDA VARCHAR2(100);
  VR_DES_SAIDA VARCHAR2(1000);

  PROCEDURE PC_ATUALIZA_REGISTRO(PR_DSDIRETO IN VARCHAR2 -- Diretorio onde vai gravar o backup
                                ,
                                 PR_NMARQBKP IN VARCHAR2 -- Arquivo de bkp que restaura os campos alterados
                                ,
                                 PR_DSCRITIC OUT CRAPCRI.DSCRITIC%TYPE) IS
  
    VR_DES_XML        CLOB;
    VR_TEXTO_COMPLETO VARCHAR2(32600);
    VR_EXC_ERRO EXCEPTION;
  
    NOVO_nmmaettl VARCHAR2(60);
    NOVO_nmpaittl VARCHAR2(58);
    CN_REGEXSTR CONSTANT VARCHAR2(200) := '[ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\.\,\/\:\(\)\;\\=\+\°\º\ª\*\_\>\<\$\#\"\!\@\%\{\}\?\&\-]';
  
    CURSOR CR_nmmaettl IS
      SELECT C.*
        FROM CRAPTTL C
       WHERE REGEXP_LIKE( nmmaettl , CN_REGEXSTR);

  
    CURSOR CR_nmpaittl IS
      SELECT C.*
        FROM CRAPTTL C
       WHERE REGEXP_LIKE( nmpaittl, CN_REGEXSTR);


  
  BEGIN
  
    -- Inicializar o CLOB
    VR_DES_XML := NULL;
    VR_TEXTO_COMPLETO := NULL;

    -- Faz o loop dos endereços com caracteres invalidos
    FOR RW_nmmaettl IN CR_nmmaettl LOOP
    
           
      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,'UPDATE CRAPTTL ' || 'SET CRAPTTL.nmmaettl = q''[' ||
                   RW_nmmaettl.nmmaettl || ']'' ' ||
                   'WHERE CRAPTTL.PROGRESS_RECID = ''' ||
                   RW_nmmaettl.PROGRESS_RECID || ''';' || CHR(10));           
           
      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                     'COMMIT;');         
           
    
      -- Update para atualizar o endereço
      BEGIN
      
        -- Remove caracteres especiais do campo RW_nmmaettl.nmmaettl
        NOVO_nmmaettl := RW_nmmaettl.nmmaettl;
        NOVO_nmmaettl := REGEXP_REPLACE(NOVO_nmmaettl, 'Ã§{1,}', 'ç');
        NOVO_nmmaettl := REGEXP_REPLACE(NOVO_nmmaettl, CN_REGEXSTR, '');
        NOVO_nmmaettl := TRIM(NOVO_nmmaettl);
      
        IF NOVO_nmmaettl = '' THEN
          NOVO_nmmaettl := '-';
        END IF;
      
        UPDATE CRAPTTL
           SET CRAPTTL.nmmaettl = NOVO_nmmaettl -- Saida somente com caracteres validos
         WHERE CRAPTTL.PROGRESS_RECID = RW_nmmaettl.PROGRESS_RECID;
      
      EXCEPTION
        WHEN OTHERS THEN
          PR_DSCRITIC := 'Erro ao atualizar o registro de endereço ( ' ||
                         RW_nmmaettl.PROGRESS_RECID || ' ):' || SQLERRM;
          RAISE VR_EXC_ERRO;
      END;
    
    END LOOP;
  
    -- Faz o loop dos endereços com caracteres invalidos
    FOR RW_nmpaittl IN CR_nmpaittl LOOP
    

      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,'UPDATE CRAPTTL ' || 'SET CRAPTTL.nmpaittl = q''[' ||
                  RW_nmpaittl.nmpaittl || ']'' ' ||
                  'WHERE CRAPTTL.PROGRESS_RECID = ''' ||
                  RW_nmpaittl.PROGRESS_RECID || ''';' || CHR(10));

      BEGIN
      
        -- Remove caracteres especiais do campo RW_nmpaittl.nmpaittl
        NOVO_nmpaittl := RW_nmpaittl.nmpaittl;
        NOVO_nmpaittl := REGEXP_REPLACE(NOVO_nmpaittl, 'Ã§{1,}', 'ç');
        NOVO_nmpaittl := REGEXP_REPLACE(NOVO_nmpaittl, CN_REGEXSTR, '');
        NOVO_nmpaittl := REGEXP_REPLACE(NOVO_nmpaittl, ' {2,}', ' ');
        NOVO_nmpaittl := TRIM(NOVO_nmpaittl);
      
        IF NOVO_nmpaittl = '' THEN
          NOVO_nmpaittl := '-';
        END IF;
      
        UPDATE CRAPTTL
           SET CRAPTTL.nmpaittl = NOVO_nmpaittl -- Saida somente com caracteres validos
         WHERE CRAPTTL.PROGRESS_RECID = RW_nmpaittl.PROGRESS_RECID;
      
      EXCEPTION
        WHEN OTHERS THEN
          PR_DSCRITIC := 'Erro ao atualizar o registro de endereço ( ' ||
                         RW_nmpaittl.PROGRESS_RECID || ' ):' || SQLERRM;
          RAISE VR_EXC_ERRO;
      END;
    
    END LOOP;
  
  
      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                     'COMMIT;');  
  
  EXCEPTION
    WHEN VR_EXC_ERRO THEN
      --LOG
      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                     TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                     PR_DSCRITIC);
    WHEN OTHERS THEN
      PR_DSCRITIC := ' Problemas na pc_atualiza_registro - ' || SQLERRM;
      --LOG
      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                     TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                     PR_DSCRITIC);
  END PC_ATUALIZA_REGISTRO;

BEGIN

  VR_NOME_BACA := 'BACA_FILIACAO_INV';
  VR_NMDIRETO  := '/micros/cpd/bacas/INC0063531';
  VR_NMARQBKP  := 'ROLLBACK_FILIACAO_INV.txt';
  VR_NMARQLOG  := 'LOG_' || VR_NOME_BACA || '_' ||
                  TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '.txt';

  IF NOT GENE0001.FN_EXIS_DIRETORIO(VR_NMDIRETO) THEN
  
    -- Efetuar a criação do mesmo
    GENE0001.PC_OSCOMMAND_SHELL(PR_DES_COMANDO => 'mkdir ' || VR_NMDIRETO ||
                                                  ' 1> /dev/null',
                                PR_TYP_SAIDA   => VR_TYP_SAIDA,
                                PR_DES_SAIDA   => VR_DES_SAIDA);
  
    --Se ocorreu erro dar RAISE
    IF VR_TYP_SAIDA = 'ERR' THEN
      VR_DSCRITIC := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                     VR_DES_SAIDA;
      RAISE VR_EXC_ERRO;
    END IF;
  
    -- Adicionar permissão total na pasta
    GENE0001.PC_OSCOMMAND_SHELL(PR_DES_COMANDO => 'chmod 777 ' ||
                                                  VR_NMDIRETO ||
                                                  ' 1> /dev/null',
                                PR_TYP_SAIDA   => VR_TYP_SAIDA,
                                PR_DES_SAIDA   => VR_DES_SAIDA);
  
    --Se ocorreu erro dar RAISE
    IF VR_TYP_SAIDA = 'ERR' THEN
      VR_DSCRITIC := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                     VR_DES_SAIDA;
      RAISE VR_EXC_ERRO;
    END IF;
  
  END IF;

  /* ############# LOG ########################### */
  --Criar arquivo de log
  GENE0001.PC_ABRE_ARQUIVO(PR_NMDIRETO => VR_NMDIRETO --> Diretorio do arquivo
                          ,
                           PR_NMARQUIV => VR_NMARQLOG --> Nome do arquivo
                          ,
                           PR_TIPABERT => 'W' --> modo de abertura (r,w,a)
                          ,
                           PR_UTLFILEH => VR_IND_ARQLOG --> handle do arquivo aberto
                          ,
                           PR_DES_ERRO => VR_DSCRITIC); --> erro
  -- em caso de crítica
  IF VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_ERRO;
  END IF;

  GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                 TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Inicio Processo');
  GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                 TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Inicio pc_atualiza_registro ');

  PC_ATUALIZA_REGISTRO(PR_DSDIRETO => VR_NMDIRETO,
                       PR_NMARQBKP => VR_NMARQBKP,
                       PR_DSCRITIC => VR_DSCRITIC);

  -- Se houve erro ao carregar o arquivo aborta
  IF VR_DSCRITIC IS NOT NULL THEN
    --LOG
    GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                   TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' - Fim pc_atualiza_registro com ERRO ' ||
                                   VR_DSCRITIC);
    RAISE VR_EXC_ERRO;
  END IF;

  GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                 TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Fim Processo com sucesso');
  GENE0001.PC_FECHA_ARQUIVO(PR_UTLFILEH => VR_IND_ARQLOG); --> Handle do arquivo aberto;  

  COMMIT;

EXCEPTION
  WHEN VR_EXC_ERRO THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    --LOG
    GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                   TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' - Fim Processo com erro');
    GENE0001.PC_FECHA_ARQUIVO(PR_UTLFILEH => VR_IND_ARQLOG); --> Handle do arquivo aberto;  
    ROLLBACK;
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    --LOG
    GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                   TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' - Fim Processo com erro:' || SQLERRM);
    GENE0001.PC_FECHA_ARQUIVO(PR_UTLFILEH => VR_IND_ARQLOG); --> Handle do arquivo aberto;  
    ROLLBACK;
END;
