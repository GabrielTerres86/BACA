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
  
    NOVO_DSENDERE VARCHAR2(40);
    NOVO_COMPLEND VARCHAR2(58);
    CN_REGEXSTR CONSTANT VARCHAR2(200) := '[^A-z0-9 ����������������������������������������������������\.\,\/\:\(\)\;\=\+\�\�\�\*\_\>\<\$\#\"\!\@\%\{\}\?\&\-]';
  
    CURSOR CR_DSENDERE IS
      SELECT C.*
        FROM CRAPENC C
       WHERE REGEXP_LIKE(TRANSLATE(DSENDERE, '[]', '()'), CN_REGEXSTR);
  
    CURSOR CR_COMPLEND IS
      SELECT C.*
        FROM CRAPENC C
       WHERE REGEXP_LIKE(TRANSLATE(COMPLEND, '[]', '()'), CN_REGEXSTR);
  
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE PC_ESCREVE_XML(PR_DES_DADOS IN VARCHAR2,
                             PR_FECHA_XML IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      GENE0002.PC_ESCREVE_XML(VR_DES_XML,
                              VR_TEXTO_COMPLETO,
                              PR_DES_DADOS,
                              PR_FECHA_XML);
    END;
  
  BEGIN
  
    -- Inicializar o CLOB
    VR_DES_XML := NULL;
    DBMS_LOB.CREATETEMPORARY(VR_DES_XML, TRUE);
    DBMS_LOB.OPEN(VR_DES_XML, DBMS_LOB.LOB_READWRITE);
    VR_TEXTO_COMPLETO := NULL;
  
    -- Faz o loop dos endere�os com caracteres invalidos
    FOR RW_DSENDERE IN CR_DSENDERE LOOP
    
      -- Grava os dados originais no arquivo de backup
      PC_ESCREVE_XML('UPDATE CRAPENC ' || 'SET CRAPENC.DSENDERE = q''[' ||
                     RW_DSENDERE.DSENDERE || ']'' ' ||
                     'WHERE CRAPENC.PROGRESS_RECID = ''' ||
                     RW_DSENDERE.PROGRESS_RECID || ''';' || CHR(10));
    
      -- Update para atualizar o endere�o
      BEGIN
      
        -- Remove caracteres especiais do campo RW_DSENDERE.DSENDERE
        NOVO_DSENDERE := RW_DSENDERE.DSENDERE;
        NOVO_DSENDERE := REGEXP_REPLACE(NOVO_DSENDERE, 'ç{1,}', '�');
        NOVO_DSENDERE := REGEXP_REPLACE(NOVO_DSENDERE, CN_REGEXSTR, '');
        NOVO_DSENDERE := TRIM(NOVO_DSENDERE);
      
        IF NOVO_DSENDERE = '' THEN
          NOVO_DSENDERE := '-';
        END IF;
      
        UPDATE CRAPENC
           SET CRAPENC.DSENDERE = NOVO_DSENDERE -- Saida somente com caracteres validos
         WHERE CRAPENC.PROGRESS_RECID = RW_DSENDERE.PROGRESS_RECID;
      
      EXCEPTION
        WHEN OTHERS THEN
          PR_DSCRITIC := 'Erro ao atualizar o registro de endere�o ( ' ||
                         RW_DSENDERE.PROGRESS_RECID || ' ):' || SQLERRM;
          RAISE VR_EXC_ERRO;
      END;
    
    END LOOP;
  
    -- Faz o loop dos endere�os com caracteres invalidos
    FOR RW_COMPLEND IN CR_COMPLEND LOOP
    
      -- Grava os dados originais no arquivo de backup
      PC_ESCREVE_XML('UPDATE CRAPENC ' || 'SET CRAPENC.COMPLEND = q''[' ||
                     RW_COMPLEND.COMPLEND || ']'' ' ||
                     'WHERE CRAPENC.PROGRESS_RECID = ''' ||
                     RW_COMPLEND.PROGRESS_RECID || ''';' || CHR(10));
    
      -- Update para atualizar o endere�o
      BEGIN
      
        -- Remove caracteres especiais do campo RW_COMPLEND.COMPLEND
        NOVO_COMPLEND := RW_COMPLEND.COMPLEND;
        NOVO_COMPLEND := REGEXP_REPLACE(NOVO_COMPLEND, 'ç{1,}', '�');
        NOVO_COMPLEND := REGEXP_REPLACE(NOVO_COMPLEND, CN_REGEXSTR, '');
        NOVO_COMPLEND := REGEXP_REPLACE(NOVO_COMPLEND, ' {2,}', ' ');
        NOVO_COMPLEND := TRIM(NOVO_COMPLEND);
      
        IF NOVO_COMPLEND = '' THEN
          NOVO_COMPLEND := '-';
        END IF;
      
        UPDATE CRAPENC
           SET CRAPENC.COMPLEND = NOVO_COMPLEND -- Saida somente com caracteres validos
         WHERE CRAPENC.PROGRESS_RECID = RW_COMPLEND.PROGRESS_RECID;
      
      EXCEPTION
        WHEN OTHERS THEN
          PR_DSCRITIC := 'Erro ao atualizar o registro de endere�o ( ' ||
                         RW_COMPLEND.PROGRESS_RECID || ' ):' || SQLERRM;
          RAISE VR_EXC_ERRO;
      END;
    
    END LOOP;
  
    PC_ESCREVE_XML('COMMIT;');
    PC_ESCREVE_XML(' ', TRUE);
    DBMS_XSLPROCESSOR.CLOB2FILE(VR_DES_XML,
                                PR_DSDIRETO,
                                TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '_' ||
                                PR_NMARQBKP,
                                NLS_CHARSET_ID('UTF8'));
    -- Liberando a mem�ria alocada pro CLOB
    DBMS_LOB.CLOSE(VR_DES_XML);
    DBMS_LOB.FREETEMPORARY(VR_DES_XML);
  
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

  VR_NOME_BACA := 'BACA_ENDERECOS_INV';
  VR_NMDIRETO  := '/micros/cpd/bacas/INC0031756';
  VR_NMARQBKP  := 'ROLLBACK_ENDERECOS_INV.txt';
  VR_NMARQLOG  := 'LOG_' || VR_NOME_BACA || '_' ||
                  TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '.txt';

  IF NOT GENE0001.FN_EXIS_DIRETORIO(VR_NMDIRETO) THEN
  
    -- Efetuar a cria��o do mesmo
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
  
    -- Adicionar permiss�o total na pasta
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
  -- em caso de cr�tica
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
