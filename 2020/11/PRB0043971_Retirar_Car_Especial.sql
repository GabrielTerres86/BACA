DECLARE

  VR_NOME_BACA  VARCHAR2(100);
  VR_NMARQLOG   VARCHAR2(100);
  VR_NMARQBKP   VARCHAR2(100);
  VR_IND_ARQLOG UTL_FILE.FILE_TYPE;
  VR_NMDIRETO   VARCHAR2(4000);
  VR_DSCRITIC   VARCHAR2(4000);
  VR_EXC_ERRO EXCEPTION;
  vr_des_erro         varchar2(4000);


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
  
    QT_REG_ALT INTEGER := 0; 
    FL_ALTERA BOOLEAN:= TRUE;    
    VR_STRING     VARCHAR2(1000):= '@#$&%¹²³ªº°*!?|€§‡‹Æµ“¿½¦©¨¡‰•¾£ƒ†™¢”';
    VR_STRING_ESP VARCHAR2(1000):= '                                     ';
  
    -- Subrotina para escrever texto na variável CLOB do XML
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
    -- 
    FOR RW_CRAPSAB IN 
        (
        SELECT * FROM CRAPSAB
         ) LOOP
    
      BEGIN
        FL_ALTERA:= FALSE;    
        --
        IF    gene0007.fn_caract_acento(RW_CRAPSAB.DSENDSAC, 1, VR_STRING, VR_STRING_ESP) <> RW_CRAPSAB.DSENDSAC THEN
          FL_ALTERA:= TRUE;  
          QT_REG_ALT := QT_REG_ALT + 1;
        ELSIF gene0007.fn_caract_acento(RW_CRAPSAB.NMDSACAD, 1, VR_STRING, VR_STRING_ESP) <>  RW_CRAPSAB.NMDSACAD THEN
          QT_REG_ALT := QT_REG_ALT + 1;         
          FL_ALTERA:= TRUE;            
        ELSIF gene0007.fn_caract_acento(RW_CRAPSAB.NMCIDSAC, 1, VR_STRING, VR_STRING_ESP) <>  RW_CRAPSAB.NMCIDSAC THEN
          QT_REG_ALT := QT_REG_ALT + 1;         
          FL_ALTERA:= TRUE;      
        ELSIF gene0007.fn_caract_acento(RW_CRAPSAB.NMBAISAC, 1, VR_STRING, VR_STRING_ESP) <>  RW_CRAPSAB.NMBAISAC THEN
          QT_REG_ALT := QT_REG_ALT + 1;         
          FL_ALTERA:= TRUE;            
        END IF;    
        
        IF FL_ALTERA THEN 
          UPDATE CRAPSAB
           SET CRAPSAB.DSENDSAC = TRIM(GENE0007.FN_CARACT_ACENTO(RW_CRAPSAB.DSENDSAC, 1, VR_STRING, VR_STRING_ESP))
              ,CRAPSAB.NMDSACAD = TRIM(GENE0007.FN_CARACT_ACENTO(RW_CRAPSAB.NMDSACAD, 1, VR_STRING, VR_STRING_ESP))
              ,CRAPSAB.NMCIDSAC = TRIM(GENE0007.FN_CARACT_ACENTO(RW_CRAPSAB.NMCIDSAC, 1, VR_STRING, VR_STRING_ESP))
              ,CRAPSAB.NMBAISAC = TRIM(GENE0007.FN_CARACT_ACENTO(RW_CRAPSAB.NMBAISAC, 1, VR_STRING, VR_STRING_ESP))           
          WHERE CRAPSAB.PROGRESS_RECID = RW_CRAPSAB.PROGRESS_RECID;
          --          
          PC_ESCREVE_XML('UPDATE CRAPSAB ' || 
                         'SET CRAPSAB.DSENDSAC = q''[' ||RW_CRAPSAB.DSENDSAC || ']'' ' ||
                         '   ,CRAPSAB.NMDSACAD = q''[' ||RW_CRAPSAB.NMDSACAD || ']'' ' ||          
                         '   ,CRAPSAB.NMCIDSAC = q''[' ||RW_CRAPSAB.NMCIDSAC || ']'' ' ||          
                         '   ,CRAPSAB.NMBAISAC = q''[' ||RW_CRAPSAB.NMBAISAC || ']'' ' ||                                                            
                         'WHERE CRAPSAB.PROGRESS_RECID = ''' ||
                         RW_CRAPSAB.PROGRESS_RECID || ''';' || CHR(10));    
        END IF; 
          
      
      EXCEPTION
        WHEN OTHERS THEN
          PR_DSCRITIC := 'Erro ao atualizar o registro de endereço ( ' ||
                         RW_CRAPSAB.PROGRESS_RECID || ' ):' || SQLERRM;
          RAISE VR_EXC_ERRO;
      END;
    
    END LOOP;
    
    COMMIT;  
    
    PC_ESCREVE_XML('COMMIT;');
    PC_ESCREVE_XML(' ', TRUE);    
    --
    gene0002.pc_clob_para_arquivo(pr_clob => VR_DES_XML, 
                                  pr_caminho => PR_DSDIRETO, 
                                  pr_arquivo => PR_NMARQBKP,  
                                  pr_des_erro => vr_des_erro);
    --
    IF vr_des_erro IS NOT NULL THEN
      RAISE VR_EXC_ERRO;
    END IF; 
    -- Liberando a memória alocada pro CLOB
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

  VR_NOME_BACA := 'BACA_SACADO_INV_PRB0043989';
--  VR_NMDIRETO  := '/progress/t0032120/micros'; -- Ambiente Individual
  VR_NMDIRETO  := '/micros/cpd/bacas/PRB0043989'; --Produção
  VR_NMARQBKP  := 'ROLLBACK_ENDERECOS_PRB0043989.txt';
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
