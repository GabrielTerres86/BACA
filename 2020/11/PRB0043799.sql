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
  
    NOVO_nmpessoa_contato VARCHAR2(60);
    NOVO_dsbem VARCHAR2(58);
    CN_REGEXSTR CONSTANT VARCHAR2(200) := '[ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\.\,\/\:\(\)\;\=\\+\°\º\ª\*\_\>\<\$\#\"\!\@\%\{\}\?\&\-]';
  
    CURSOR CR_nmpessoa_contato IS
      SELECT C.*
        FROM TBCADAST_PESSOA_TELEFONE C
       WHERE REGEXP_LIKE( nmpessoa_contato , CN_REGEXSTR);

  
    CURSOR CR_dsbem IS
      SELECT C.*
        FROM TBCADAST_PESSOA_BEM C
       WHERE REGEXP_LIKE( dsbem, CN_REGEXSTR);


  
  BEGIN
  
    -- Inicializar o CLOB
    VR_DES_XML := NULL;
    VR_TEXTO_COMPLETO := NULL;
  
    -- Faz o loop dos endereços com caracteres invalidos
    FOR RW_nmpessoa_contato IN CR_nmpessoa_contato LOOP
    
           
      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,'UPDATE TBCADAST_PESSOA_TELEFONE ' || 'SET TBCADAST_PESSOA_TELEFONE.nmpessoa_contato = q''[' ||
                   RW_nmpessoa_contato.nmpessoa_contato || ']'' ' ||
                   'WHERE TBCADAST_PESSOA_TELEFONE.idpessoa = ''' || RW_nmpessoa_contato.idpessoa || '''
                      AND TBCADAST_PESSOA_TELEFONE.nrseq_telefone = ''' || RW_nmpessoa_contato.nrseq_telefone || ''';' || CHR(10));           
           
      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                     'COMMIT;');         
           
    
      -- Update para atualizar o endereço
      BEGIN
      
        -- Remove caracteres especiais do campo RW_nmpessoa_contato.nmpessoa_contato
        NOVO_nmpessoa_contato := RW_nmpessoa_contato.nmpessoa_contato;
        NOVO_nmpessoa_contato := REGEXP_REPLACE(NOVO_nmpessoa_contato, 'Ã§{1,}', 'ç');
        NOVO_nmpessoa_contato := REGEXP_REPLACE(NOVO_nmpessoa_contato, CN_REGEXSTR, '');
        NOVO_nmpessoa_contato := TRIM(NOVO_nmpessoa_contato);
      
        IF NOVO_nmpessoa_contato = '' THEN
          NOVO_nmpessoa_contato := '-';
        END IF;
      
        UPDATE TBCADAST_PESSOA_TELEFONE
           SET TBCADAST_PESSOA_TELEFONE.nmpessoa_contato = NOVO_nmpessoa_contato -- Saida somente com caracteres validos
         WHERE TBCADAST_PESSOA_TELEFONE.idpessoa = RW_nmpessoa_contato.idpessoa
           and TBCADAST_PESSOA_TELEFONE.nrseq_telefone = RW_nmpessoa_contato.nrseq_telefone;
      
      EXCEPTION
        WHEN OTHERS THEN
          PR_DSCRITIC := 'Erro ao atualizar o registro de TELEFONE ( ' ||
                         RW_nmpessoa_contato.idpessoa || ' ):' || SQLERRM;
          RAISE VR_EXC_ERRO;
      END;
    
    END LOOP;
  
    -- Faz o loop dos endereços com caracteres invalidos
    FOR RW_dsbem IN CR_dsbem LOOP
    

      GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,'UPDATE TBCADAST_PESSOA_BEM ' || 'SET TBCADAST_PESSOA_BEM.dsbem = q''[' ||
                  RW_dsbem.dsbem || ']'' ' ||
                  'WHERE TBCADAST_PESSOA_BEM.idpessoa = ''' || RW_dsbem.idpessoa || '''
                     AND TBCADAST_PESSOA_BEM.nrseq_bem = ''' || RW_dsbem.nrseq_bem || ''';' || CHR(10));

      BEGIN
      
        -- Remove caracteres especiais do campo RW_dsbem.dsbem
        NOVO_dsbem := RW_dsbem.dsbem;
        NOVO_dsbem := REGEXP_REPLACE(NOVO_dsbem, 'Ã§{1,}', 'ç');
        NOVO_dsbem := REGEXP_REPLACE(NOVO_dsbem, CN_REGEXSTR, '');
        NOVO_dsbem := REGEXP_REPLACE(NOVO_dsbem, ' {2,}', ' ');
        NOVO_dsbem := TRIM(NOVO_dsbem);
      
        IF NOVO_dsbem = '' THEN
          NOVO_dsbem := '-';
        END IF;
      
        UPDATE TBCADAST_PESSOA_BEM
           SET TBCADAST_PESSOA_BEM.dsbem = NOVO_dsbem -- Saida somente com caracteres validos
         WHERE TBCADAST_PESSOA_BEM.idpessoa = RW_dsbem.idpessoa
           AND TBCADAST_PESSOA_BEM.nrseq_bem = RW_dsbem.nrseq_bem;
      
      EXCEPTION
        WHEN OTHERS THEN
          PR_DSCRITIC := 'Erro ao atualizar o registro de bem ( ' ||
                         RW_dsbem.idpessoa || ' ):' || SQLERRM;
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

  VR_NOME_BACA := 'BACA_cadast_INV';
  VR_NMDIRETO  := '/micros/cpd/bacas/PRB0043799';
  --VR_NMDIRETO  := '/micros/cpd/bacas';
  VR_NMARQBKP  := 'ROLLBACK_cadast_INV.txt';
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
    --null;
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
