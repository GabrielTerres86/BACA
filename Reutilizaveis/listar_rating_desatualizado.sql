/* 
 * Baca para listar as contas que estão com o Rating desatualizado
 *
 * Autor: Douglas Quisinski
 *
 *  Alterações : 02/02/2017 - Desenvolvimento do baca (Douglas - Chamado 604096)
 *
 */
declare 
  -- Local para geracao do arquivo
  vr_dir_arq CONSTANT VARCHAR2(300) := '/micros/cecred/quisinski/rating';
  
  -- Indice da tabela de erros
  vr_idx_err INTEGER;
  
  -- Criacao do diretorio de arquivos
  vr_typ_saida VARCHAR2(100);
  vr_des_saida VARCHAR2(1000);
  
  -- Exception
  vr_erros EXCEPTION;
  vr_exec_saida EXCEPTION;
  
  -- Dados do Erro
  TYPE typ_rec_erro IS RECORD (dsorigem VARCHAR(100)
                              ,dserro   VARCHAR2(32000));
  -- Erros da Geração dos arquivos 
  TYPE typ_tberro IS TABLE OF typ_rec_erro INDEX BY PLS_INTEGER;
  vr_tberro typ_tberro;
  

  -- INICIO -> Verificação da existencia do diretório
  PROCEDURE pc_verifica_diretorio (pr_tberro IN OUT typ_tberro) IS
  BEGIN 
    -- Primeiro garantimos que o diretorio exista
    IF NOT gene0001.fn_exis_diretorio(vr_dir_arq) THEN
      -- Efetuar a criação do mesmo
      gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir '||vr_dir_arq||' 1> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_idx_err := pr_tberro.COUNT + 1;
        pr_tberro(vr_idx_err).dsorigem := 'CRIAR DIRETORIO ARQUIVO';
        pr_tberro(vr_idx_err).dserro   := 'Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;  
        RAISE vr_exec_saida;
      END IF;           
      
      -- Adicionar permissão total na pasta
      gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 '||vr_dir_arq||' 1> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_idx_err := pr_tberro.COUNT + 1;
        pr_tberro(vr_idx_err).dsorigem := 'PERMISSAO NO DIRETORIO';
        pr_tberro(vr_idx_err).dserro   := 'Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
        RAISE vr_exec_saida;
      END IF;           
    END IF;
  EXCEPTION
    -- Nao executa nada apenas sai da procedure
    WHEN vr_exec_saida THEN 
      NULL;
      
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'VERIFICACAO DO DIRETORIO (0)';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_verifica_diretorio;
  -- FIM -> Verificacao do diretorio
    
  
  -- INICIO -> Escrever linha no arquivo
  -- Criar o arquivo
  PROCEDURE pc_abre_arquivo(pr_nmarquivo   IN VARCHAR2
                           ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Tenta abrir o arquivo de log em modo append
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_dir_arq    --> Diretório do arquivo
                            ,pr_nmarquiv => pr_nmarquivo  --> Nome do arquivo
                            ,pr_tipabert => 'W'           --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => pr_ind_arqlog --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro); --> Descricao do erro
    IF vr_des_erro IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_abre_arquivo;
  
  -- Escrever no arquivo
  PROCEDURE pc_escreve_linha_arq(pr_nmarquivo   IN VARCHAR2
                                ,pr_texto_linha IN VARCHAR2
                                ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Adiciona a linha de log
    BEGIN
      gene0001.pc_escr_linha_arquivo(pr_ind_arqlog,pr_texto_linha);
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro
        vr_des_erro := 'Problema ao escrever no arquivo <' || vr_dir_arq || '/' || pr_nmarquivo || '>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_escreve_linha_arq;
  
  -- Fechar arquivo
  PROCEDURE pc_fechar_arquivo(pr_nmarquivo   IN VARCHAR2
                             ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Libera o arquivo
    BEGIN
      gene0001.pc_fecha_arquivo(pr_ind_arqlog);
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro
        vr_des_erro := 'Problema ao fechar o arquivo <' || vr_dir_arq || '/' || pr_nmarquivo || '>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_fechar_arquivo;
  -- FIM -> Escrever linha no arquivo

  -- INICIO -> Gerar os arquivos
  -- Gerar o arquivo de rating desatualizado
  PROCEDURE pc_gera_arq_rating(pr_cdcooper  IN INTEGER
                              ,pr_nmarquiv  IN VARCHAR2
                              ,pr_tberro    IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
    
    vr_vlutiliz  NUMBER;
    vr_nivrisco  VARCHAR2(10);
    vr_vlrisco   NUMBER;
    vr_diarating INTEGER;
    vr_contador  INTEGER;
    vr_dtrefere  DATE;
    vr_inusatab  BOOLEAN;

    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_exc_erro  EXCEPTION;

    vr_dstextab_bacen craptab.dstextab%TYPE;
    vr_dstextab_dias  craptab.dstextab%TYPE;
      
    --Selecionar informacoes da tabela generica
    CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE
                      ,pr_nmsistem IN craptab.nmsistem%TYPE
                      ,pr_tptabela IN craptab.tptabela%TYPE
                      ,pr_cdempres IN craptab.cdempres%TYPE
                      ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
      SELECT tab.tpregist
            ,tab.dstextab
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
         AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
         AND tab.cdempres = pr_cdempres
         AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso);

    CURSOR cr_dados (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_diasrating IN INTEGER) IS
      SELECT age.cdagenci || ' - ' || age.nmresage agencia
            ,ass.nrdconta conta
            ,ass.nmprimtl nome
            ,ass.nrcpfcgc
            ,nrc.nrctrrat contrato
            ,nrc.dtmvtolt ultimo_rating
            ,nrc.indrisco risco
            ,nrc.nrnotrat nota
            ,(nrc.dtmvtolt + pr_diasrating) vencer
        FROM crapnrc nrc, crapass ass, crapage age
       WHERE ass.cdcooper = nrc.cdcooper
         AND ass.nrdconta = nrc.nrdconta
         AND age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND nrc.cdcooper = pr_cdcooper
         AND nrc.insitrat = 2
         AND nrc.dtmvtolt < TRUNC(SYSDATE) - pr_diasrating 
         AND ass.inpessoa <> 3
         AND ass.dtdemiss IS NULL
       ORDER BY ass.cdagenci, ass.nrdconta, nrc.nrctrrat;
      
    TYPE typ_tab_nivrisco IS TABLE OF INTEGER          INDEX BY VARCHAR2(3);

    vr_tab_dsdrisco     RATI0001.typ_tab_dsdrisco;
    vr_tab_nivrisco     typ_tab_nivrisco;  
      
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  BEGIN
    -- Verificar se o diretório já foi criado
    pc_verifica_diretorio (pr_tberro => pr_tberro);
    
    -- Se tiver erro sai do programa  
    IF pr_tberro.COUNT > 0 THEN
      RAISE vr_exec_saida;
    END IF;
 
    -- Verifica se a cooperativa esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'DATA DO SISTEMA';
      pr_tberro(vr_idx_err).dserro   := gene0001.fn_busca_critica(pr_cdcritic => 1);
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Se tiver erro sai do programa  
    IF pr_tberro.COUNT > 0 THEN
      RAISE vr_exec_saida;
    END IF;

      
    --Popular variavel com valor risco bacen
    vr_dstextab_bacen:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'USUARI'
                                                  ,pr_cdempres => 11
                                                  ,pr_cdacesso => 'RISCOBACEN'
                                                  ,pr_tpregist => 0);
                                                    
    --Selecionar informacoes das taxas para calculo dias
    vr_dstextab_dias:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'TAXATABELA'
                                                 ,pr_tpregist => 0);

    --Se encontrou valor para os dias
    IF TRIM(vr_dstextab_dias) IS NULL THEN
      vr_inusatab:= FALSE;
    ELSE
      IF SUBSTR(vr_dstextab_dias,1,1) = '0' THEN
        vr_inusatab:= FALSE;
      ELSE
        vr_inusatab:= TRUE;
      END IF;
    END IF;
                                                    
          
    --selecionar informacoes do risco na tabela generica
    FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'GENERI'
                                 ,pr_cdempres => 0
                                 ,pr_cdacesso => 'PROVISAOCL') LOOP

      --Se for tipo registro 999
      IF rw_craptab.tpregist = 999 THEN  /* Vlr obrigatorio informar risco */
        --Atribuir valor do risco
        vr_vlrisco:= GENE0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,15,11));
        --Atribuir dia rating
        vr_diarating:= GENE0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,87,3));
      END IF;

      --Popular vetor memoria para uso na RATI0001.pc_obtem_risco
      vr_contador:= GENE0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,12,2));
      vr_tab_dsdrisco(vr_contador):= TRIM(SUBSTR(rw_craptab.dstextab,8,3));
      vr_tab_nivrisco(TRIM(SUBSTR(rw_craptab.dstextab,8,3))):= vr_contador;
        
      /** Alimentar variavel para nao ser preciso criar registro na PROVISAOCL **/
      vr_tab_dsdrisco(10):= 'H';
      vr_tab_nivrisco('H'):= 10;
      vr_tab_dsdrisco(0)  := 'A';
      vr_tab_nivrisco(' '):= 2;
    END LOOP;

    -- Abrir o arquivo
    pc_abre_arquivo(pr_nmarquivo  => pr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
  
    -- Cabecalho do arquivo
    vr_dstext_linha := 'PA;Conta;Nome;Contrato;Ult. Rating;Risco;Nota;Total Op. Credito;C. Risco;Vencer';
                         
    pc_escreve_linha_arq(pr_nmarquivo   => pr_nmarquiv
                        ,pr_texto_linha => vr_dstext_linha
                        ,pr_ind_arqlog  => vr_ind_arqlog);
                        
      
    FOR rw_dados IN cr_dados (pr_cdcooper   => pr_cdcooper
                             ,pr_diasrating => vr_diarating) LOOP
        
      vr_vlutiliz:= 0;
      vr_nivrisco:= ''; 

      --Executar rotina saldo_utiliza.p
      GENE0005.pc_saldo_utiliza (pr_cdcooper    => pr_cdcooper          --> Código da Cooperativa
                                ,pr_tpdecons    => 1                    --> Consulta pelo cpf/cnpj
                                ,pr_nrdconta    => NULL                 --> Numero da Conta do associado
                                ,pr_nrcpfcgc    => rw_dados.nrcpfcgc    --> Numero do cpf ou cgc do associado
                                ,pr_dsctrliq    => ' '                  --> Numero do contrato de liquidacao
                                ,pr_cdprogra    => 'CRPS405'            --> Código do programa chamador
                                ,pr_tab_crapdat => rw_crapdat           --> Tipo de registro de datas
                                ,pr_inusatab    => vr_inusatab          --> Indicador de utilização da tabela de juros
                                ,pr_vlutiliz    => vr_vlutiliz          --> Valor utilizado do credito
                                ,pr_cdcritic    => vr_cdcritic          --> Código de retorno da critica
                                ,pr_dscritic    => vr_dscritic);        --> Mensagem de erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Montar mensagem de critica
        vr_idx_err := pr_tberro.COUNT + 1;
        pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO RATING';
        pr_tberro(vr_idx_err).dserro   := 'GENE0005.pc_saldo_utiliza -> ' || 
                                          vr_cdcritic || ': ' || vr_dscritic || '(' ||
                                          replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                   dbms_utility.format_error_stack,'"', NULL) || ')';
        
        CONTINUE;
      END IF;

      --Obter risco
      RATI0001.pc_obtem_risco (pr_cdcooper       => pr_cdcooper        --Código da Cooperativa
                              ,pr_nrdconta       => rw_dados.conta     --Numero da Conta do Associado
                              ,pr_tab_dsdrisco   => vr_tab_dsdrisco    --Vetor com dados das provisoes
                              ,pr_dstextab_bacen => vr_dstextab_bacen  --Descricao da craptab do RISCOBACEN
                              ,pr_dtmvtolt       => rw_crapdat.dtmvtolt-- Data de Movimento
                              ,pr_nivrisco       => vr_nivrisco        --Nivel de Risco
                              ,pr_dtrefere       => vr_dtrefere        --Data de Referencia do Risco
                              ,pr_cdcritic       => vr_cdcritic        --Código da Critica de Erro
                              ,pr_dscritic       => vr_dscritic);      --Descricao do erro
                              
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Montar mensagem de critica
        vr_idx_err := pr_tberro.COUNT + 1;
        pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO RATING';
        pr_tberro(vr_idx_err).dserro   := 'RATI0001.pc_obtem_risco -> ' || 
                                          vr_cdcritic || ': ' || vr_dscritic || '(' ||
                                          replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                   dbms_utility.format_error_stack,'"', NULL) || ')';
        
        CONTINUE;
      END IF;
      
      --Se o nivel de risco nao for nulo
      IF TRIM(vr_nivrisco) IS NULL THEN
        CONTINUE;
      END IF;
                            
      vr_dstext_linha := rw_dados.agencia || ';' ||
                         GENE0002.fn_mask_conta(rw_dados.conta) || ';' ||
                         SUBSTR(rw_dados.nome,0,30) || ';' ||
                         TO_CHAR(rw_dados.contrato,'fm999g999g999') || ';' ||
                         TO_CHAR(rw_dados.ultimo_rating,'DD/MM/RRRR') || ';' ||
                         rw_dados.risco || ';' ||
                         TO_CHAR(rw_dados.nota,'fm999g999d00') || ';' ||
                         TO_CHAR(vr_vlutiliz,'fm999g999g999d00') || ';' ||
                         vr_nivrisco  || ';' ||
                         TO_CHAR(rw_dados.vencer,'DD/MM/RRRR');
                           
      pc_escreve_linha_arq(pr_nmarquivo   => pr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
    END LOOP;
      
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_nmarquivo  => pr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
  EXCEPTION
    -- Nao faz nada apenas sai do programa
    WHEN vr_exec_saida THEN
      NULL;
      
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'GERACAO DO ARQUIVO';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_gera_arq_rating;
  -- FIM -> Gerar os arquivos

-- BLOCO PRINCIPAL DO PROGRAMA  
BEGIN
  
  -- PARA GERAR AS INFORMAÇÕES ALTERAR APENAS ESTE TRECHO DO FONTE
  -- Gerar o arquivo de rating desatulizado
  pc_gera_arq_rating(pr_cdcooper => 1 -- Viacredi
                    ,pr_nmarquiv => 'rating_desatualizado_viacredi_' || to_char(SYSDATE,'RRRRMMDDSSSSS') || '.csv'
                    ,pr_tberro   => vr_tberro);
 
  -- Caso tenha acontecido algum erro durante a geracao dos arquivos precisamos corrigir
  IF vr_tberro.COUNT > 0 THEN
    RAISE vr_erros;
  END IF;
  
  -- Não altera nenhum dado
  ROLLBACK;
EXCEPTION
  WHEN vr_erros THEN
    dbms_output.put_line('Foram identificados erros durante a geração do arquivo de rating desatualizado.');
    dbms_output.put_line('Favor verificar!');
    
    FOR x IN vr_tberro.FIRST..vr_tberro.LAST LOOP
      dbms_output.put_line(vr_tberro(x).dsorigem || ' => ' || vr_tberro(x).dserro);
    END LOOP;
    -- Não altera nenhum dado    
    ROLLBACK;
  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro não tratado. Verifique: ' ||
                         REPLACE (dbms_utility.format_error_backtrace || ' - ' ||
                                  dbms_utility.format_error_stack,'"', NULL));
    -- Não altera nenhum dado    
    ROLLBACK;
END;
