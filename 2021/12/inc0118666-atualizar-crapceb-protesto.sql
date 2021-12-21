DECLARE

  vr_NomeBaca          VARCHAR2(100);
  vr_NomeArquivoLog    VARCHAR2(100);
  vr_NomeArquivoBackup VARCHAR2(100);
  vr_UtlFileHandlerLog UTL_FILE.FILE_TYPE;
  vr_DiretorioBackup   VARCHAR2(4000);
  vr_DescricaoCritica  VARCHAR2(4000);
  vr_ExcecaoErro EXCEPTION;

  -- Criacao do diretorio de arquivos
  vr_typ_saida VARCHAR2(100);
  vr_des_saida VARCHAR2(1000);

  PROCEDURE atualizaRegistro(pr_DiretorioBackup   IN VARCHAR2 -- Diretorio onde vai gravar o backup
                            ,pr_NomeArquivoBackup IN VARCHAR2 -- Arquivo de bkp que restaura os campos alterados
                            ,pr_DescricaoCritica  OUT crapcri.dscritic%TYPE) IS
  
    vr_UtlFileHandlerBackup UTL_FILE.FILE_TYPE;
    vr_ExcecaoErro EXCEPTION;
  
    TYPE typ_reg_crapceb IS RECORD(
      progress_recid crapceb.progress_recid%TYPE,
      qtlimmip       crapceb.qtlimmip%TYPE,
      qtlimaxp       crapceb.qtlimaxp%TYPE);
  
    TYPE typ_tab_crapceb IS TABLE OF typ_reg_crapceb INDEX BY PLS_INTEGER;
    vr_tab_ceb typ_tab_crapceb;
  
    CURSOR cr_crapceb IS
      SELECT ceb.progress_recid
            ,ceb.qtlimmip
            ,ceb.qtlimaxp
        FROM crapceb ceb
       WHERE ceb.flprotes = 1
         AND ceb.insitceb = 1
         AND ceb.flgapihm = 0
         AND (ceb.qtlimmip, ceb.qtlimaxp) IN ((0, 0), (0, 5), (0, 15));
  
  BEGIN
  
    -- Criar arquivo de backup
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_DiretorioBackup --> Diretorio do arquivo
                            ,pr_nmarquiv => pr_NomeArquivoBackup --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_UtlFileHandlerBackup --> handle do arquivo aberto
                            ,pr_des_erro => pr_DescricaoCritica); --> erro
    IF pr_DescricaoCritica IS NOT NULL THEN
      RAISE vr_ExcecaoErro;
    END IF;
  
    -- Faz o loop dos convenios para criar a temp table e salvar o backup
    FOR rw_crapceb IN cr_crapceb LOOP
    
      -- Grava os dados originais no arquivo de backup
      gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerBackup
                                    ,'UPDATE crapceb ' || 'SET crapceb.qtlimmip = q''[' ||
                                     rw_crapceb.qtlimmip || ']'', crapceb.qtlimaxp = q''[' ||
                                     rw_crapceb.qtlimaxp || ']'' ' ||
                                     'WHERE crapceb.progress_recid = ''' ||
                                     rw_crapceb.progress_recid || ''';' || CHR(10));
    
      vr_tab_ceb(rw_crapceb.progress_recid).progress_recid := rw_crapceb.progress_recid;
      vr_tab_ceb(rw_crapceb.progress_recid).qtlimmip := rw_crapceb.qtlimmip;
      vr_tab_ceb(rw_crapceb.progress_recid).qtlimaxp := rw_crapceb.qtlimaxp;
    
    END LOOP;
  
    gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerBackup, 'COMMIT;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_UtlFileHandlerBackup); --> Handle do arquivo aberto;
  
    gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                  ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' - Arquivo de backup criado com sucesso');
  
    BEGIN
      FORALL idx IN INDICES OF vr_tab_ceb SAVE EXCEPTIONS
        UPDATE crapceb
           SET qtlimmip = 5
              ,qtlimaxp = 15
         WHERE progress_recid = vr_tab_ceb(idx).progress_recid;
    EXCEPTION
      WHEN OTHERS THEN
        pr_DescricaoCritica := 'Erro ao atualizar tabela crapceb. ' ||
                               SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_ExcecaoErro;
    END;
  
  EXCEPTION
    WHEN vr_ExcecaoErro THEN
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                    ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || pr_DescricaoCritica);
    WHEN OTHERS THEN
      sistema.excecaoInterna(pr_compleme => 'inc0118666');
      pr_DescricaoCritica := ' Problemas na atualizaRegistro - ' || SQLERRM;
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                    ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || pr_DescricaoCritica);
  END atualizaRegistro;

BEGIN

  vr_NomeBaca          := 'CRAPCEB_MIN_MAX_PROTESTO';
  vr_DiretorioBackup   := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                               ,pr_cdcooper => 0
                                               ,pr_nmsubdir => '') || 'cpd/bacas/inc0118666';
  vr_NomeArquivoBackup := 'ROLLBACK_MIN_MAX_PROTESTO' || '_' ||
                          TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '.txt';
  vr_NomeArquivoLog    := 'LOG_' || vr_NomeBaca || '_' || TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                          '.txt';

  IF NOT gene0001.fn_exis_diretorio(vr_DiretorioBackup) THEN
  
    -- Efetuar a criação do mesmo
    gene0001.pc_oscommand_shell(pr_des_comando => 'mkdir ' || vr_DiretorioBackup || ' 1> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);
  
    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_DescricaoCritica := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                             vr_des_saida;
      RAISE vr_ExcecaoErro;
    END IF;
  
    -- Adicionar permissão total na pasta
    gene0001.pc_oscommand_shell(pr_des_comando => 'chmod 777 ' || vr_DiretorioBackup ||
                                                  ' 1> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);
  
    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_DescricaoCritica := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                             vr_des_saida;
      RAISE vr_ExcecaoErro;
    END IF;
  
  END IF;

  /* ############# LOG ########################### */
  -- Criar arquivo de log
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_DiretorioBackup --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_NomeArquivoLog --> Nome do arquivo
                          ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_UtlFileHandlerLog --> handle do arquivo aberto
                          ,pr_des_erro => vr_DescricaoCritica); --> erro
  -- em caso de crítica
  IF vr_DescricaoCritica IS NOT NULL THEN
    RAISE vr_ExcecaoErro;
  END IF;

  gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || ' - Inicio Processo');
  gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Inicio atualizaRegistro ');

  atualizaRegistro(pr_DiretorioBackup   => vr_DiretorioBackup
                  ,pr_NomeArquivoBackup => vr_NomeArquivoBackup
                  ,pr_DescricaoCritica  => vr_DescricaoCritica);

  -- Se houve erro ao carregar o arquivo aborta
  IF vr_DescricaoCritica IS NOT NULL THEN
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                  ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' - Fim atualizaRegistro com ERRO ' || vr_DescricaoCritica);
    RAISE vr_ExcecaoErro;
  END IF;

  gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Fim Processo com sucesso');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_UtlFileHandlerLog); --> Handle do arquivo aberto;

  COMMIT;

EXCEPTION
  WHEN vr_ExcecaoErro THEN
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                  ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' - Fim Processo com erro: ' || vr_DescricaoCritica);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_UtlFileHandlerLog); --> Handle do arquivo aberto;
    ROLLBACK;
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_compleme => 'inc0118666');
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_UtlFileHandlerLog
                                  ,TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' - Fim Processo com erro: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_UtlFileHandlerLog); --> Handle do arquivo aberto;
    ROLLBACK;
END;
