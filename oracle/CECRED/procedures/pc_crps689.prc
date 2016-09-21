CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS689(pr_cdcooper  IN craptab.cdcooper%TYPE --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Crítica encontrada
                                      ,pr_dscritic OUT VARCHAR2)  IS         --> Texto de erro/critica encontrada

  /* ...........................................................................

     Programa: PC_CRPS689
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2014                     Ultima atualizacao: / /

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Importar arquivos REM para pagamento de titulos em lote
                 Solicitacao : XXX
                 Ordem do programa na solicitacao = XXX
                 Paralelo

     Observacoes:

     Alteracoes:
  ............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
         , crapcop.dsdircop
         , crapcop.nmrescop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;

  -- Buscar informações da cooperativa
  CURSOR cr_todas_coop IS
    SELECT crapcop.cdcooper
         , crapcop.dsdircop
         , crapcop.nmrescop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.flgativo = 1
       AND crapcop.cdcooper <> 3;

  -- Busca a data do movimento
  CURSOR cr_crapdat(p_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapdat.dtmvtolt
      FROM crapdat crapdat
     WHERE crapdat.cdcooper = p_cdcooper;

  -- REGISTROS
  rw_crapcop          cr_crapcop%ROWTYPE;
  rw_crapdat          cr_crapdat%ROWTYPE;

  -- TIPOS
  -- Tabela de memória para ordenar os arquivos
  TYPE typ_sortarq IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS689';
  -- Datas de movimento e controle
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  -- Retorno de Remessa
  vr_nrremess      craphpt.nrremret%TYPE;
  vr_nrremret      craphpt.nrremret%TYPE;
  -- Lista de arquivos
  vr_array_arquivo gene0002.typ_split;
  vr_sort_arquivos typ_sortarq;
  vr_list_arquivos VARCHAR2(10000);
  -- Variável para formar chaves para collections
  vr_dschave       VARCHAR2(100);
  -- Variáveis para leitura
  vr_arquivo       UTL_FILE.FILE_TYPE;
  vr_dslinha       VARCHAR2(32000);
  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  -- Diretório das cooperativas
  vr_dsdireto      VARCHAR2(200);
  -- Mascara para busca de arquivos
  vr_dsmascar      VARCHAR2(200);
  -- Numero da conta conforme o arq
  vr_nrdconta      crapass.nrdconta%TYPE;
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  vr_exc_proxcoop  EXCEPTION;

BEGIN

  /********** TRATAMENTOS INICIAIS **********/
  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS689',
                             pr_action => vr_cdprogra);

  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
     END IF;
  CLOSE cr_crapcop;

  -- Busca a data do movimento
  OPEN cr_crapdat(pr_cdcooper);
  FETCH cr_crapdat INTO rw_crapdat;
  CLOSE cr_crapdat;

  -- Buscar as datas do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
     -- Se não encontrar o registro de movimento
     IF btch0001.cr_crapdat%NOTFOUND THEN
        -- 001 - Sistema sem data de movimento.
        vr_cdcritic := 1;
        vr_dscritic := NULL;
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Log de crítica
        RAISE vr_exc_saida;
     END IF;
     -- Atualizar as variáveis referente a datas
     vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  CLOSE btch0001.cr_crapdat;

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1 -- Fixo
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se retornou algum erro
  IF vr_cdcritic <> 0 THEN -- Comentar para executar testes
    -- Gerar exceção
    vr_dscritic := NULL;
    -- Log de critica
    RAISE vr_exc_saida;
  END IF;

  -- Buscar diretórios de arquivos
  -- Padrão de todas as cooperativas

  FOR rw_crapcop IN cr_todas_coop LOOP

    BEGIN

      -- inicializar variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      pr_cdcritic := 0;
      pr_dscritic := NULL;

      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Coop
                                          ,pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nmsubdir => '/upload');

      -- Retorna a lista dos arquivos REM do diretório,
      -- conforme padrão "cdcooper.nrdconta.nome.REM" (Ex.: 001.329.arq_upload.REM)
      -- Ex.: --  vr_dsmascar      := '001.3696553.PGT%.REM';
      vr_dsmascar      := lpad(rw_crapcop.cdcooper,3,'0') ||'.%.PGT%.REM';

      vr_list_arquivos := NULL;

      -- Retorna a lista dos arquivos do diretório, conforme padrão *cdcooper*.*.rem
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                                ,pr_pesq     => vr_dsmascar
                                ,pr_listarq  => vr_list_arquivos
                                ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         vr_cdcritic := 0;
         RAISE vr_exc_proxcoop;
      END IF;

      -- Verifica se retornou arquivos
      IF vr_list_arquivos IS NOT NULL THEN
         -- Listar os arquivos em um array
         vr_array_arquivo := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos
                                                      ,pr_delimit => ',');
         -- Ordenar pelo nome do arquivo
         -- Percorrer todos os arquivos selecionados
         FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP
            -- Adicionar o arquivo nos array usando o nome como chave
            vr_sort_arquivos(vr_array_arquivo(ind)) := vr_array_arquivo(ind);
         END LOOP;
         -- Limpar o array de arquivos
         vr_array_arquivo.DELETE;
         -- Primeiro registro
         vr_dschave := vr_sort_arquivos.FIRST;
         -- Percorrer o array sort e incluir os arquivos no array de arquivos
         LOOP
            -- Criar a posição no array
            vr_array_arquivo.EXTEND;
            -- Acresce mais um registro no array
            vr_array_arquivo(vr_array_arquivo.COUNT) := vr_sort_arquivos(vr_dschave);
            --Sair quando o ultimo indice for processado
            EXIT WHEN vr_dschave = vr_sort_arquivos.LAST;
            -- Buscar o próximo registro
            vr_dschave := vr_sort_arquivos.NEXT(vr_dschave);
         END LOOP;
         -- Limpando os dados em memória
         vr_sort_arquivos.DELETE;
         vr_dschave := NULL;

      ELSE -- Nao retornou lista de arquivo
         -- Limpa as variáveis para não gerar crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao ha arquivos de remessa para serem importados';
          -- Vai para a proxima cooperativa
          RAISE vr_exc_proxcoop;
      END IF;

      -- Percorrer todos os arquivos encontrados na pasta
      FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP
         BEGIN
            -- Verifica o nrdconta que vem no nome do arquivo, salva na variavel
            vr_nrdconta := gene0002.fn_busca_entrada(2,vr_array_arquivo(ind),'.');

            -- Validar o arquivo da lista da Pasta - PGTA0001
            PGTA0001.pc_validar_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper           --> Codigo da cooperativa
                                       ,pr_nrdconta => gene0002.fn_mask(vr_nrdconta,'zzzzzzzzz9')  --> Numero Conta do cooperado
                                       ,pr_nrconven => 1                     --> Numero do Convenio
                                       ,pr_nmarquiv => vr_array_arquivo(ind) --> Nome do Arquivo
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data do Movimento
                                       ,pr_idorigem => 3                     --> Origem (1-Ayllos, 3-Internet, 7-FTP) --Está no Ayllos, mas o arquivo veio pelo Int.Banking
                                       ,pr_cdoperad => '996'                 --> Codigo Operador
                                       ,pr_nrremess => vr_nrremess
                                       ,pr_cdcritic => vr_cdcritic           --> Código do erro
                                       ,pr_dscritic => vr_dscritic);         --> Descricao do erro

            IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
               vr_dscritic :=  ' --> PAGTO TIT ARQUIVO[VALIDAR] - Arquivo:'
                               || vr_array_arquivo(ind) || ': '
                               || vr_dscritic ;
               RAISE vr_exc_saida; -- Passa para o proximo arquivo
            END IF;

            -- Processar o arquivo da lista da Pasta - PGTA0001
            PGTA0001.pc_processar_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper   --> Codigo da cooperativa
                                          ,pr_nrdconta => gene0002.fn_mask(vr_nrdconta,'zzzzzzzzz9')  --> Numero Conta do cooperado
                                          ,pr_nrconven => 1                     --> Numero do Convenio
                                          ,pr_nmarquiv => vr_array_arquivo(ind) --> Nome do Arquivo
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data do Movimento
                                          ,pr_idorigem => 3                     --> Origem (1-Ayllos, 3-Internet, 7-FTP) --Está no Ayllos, mas o arquivo veio pelo Int.Banking
                                          ,pr_cdoperad => '996'                 --> Codigo Operador
                                          ,pr_nrremess => vr_nrremess
                                          ,pr_nrremret => vr_nrremret           --> OUT - Nr retorno
                                          ,pr_cdcritic => vr_cdcritic           --> OUT Código do erro
                                          ,pr_dscritic => vr_dscritic);         --> OUT Descricao do erro

            IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
               vr_dscritic :=  ' --> PAGTO TIT ARQUIVO[PROCESSAR] - Arquivo:'
                               || vr_array_arquivo(ind) || ': '
                               || vr_dscritic;
               RAISE vr_exc_saida; -- Passa para o proximo arquivo
            END IF;

         COMMIT; -- O COMMIT ficou por Arquivo - Significa que deu sucesso no tratamento.

         EXCEPTION
            WHEN vr_exc_saida THEN
               -- Envio centralizado de log de erro
               PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_nrdconta => 0
                                             ,pr_nmarquiv => 'PC_CRPS689'
                                             ,pr_textolog => vr_dscritic
                                             ,pr_cdcritic => pr_cdcritic
                                             ,pr_dscritic => pr_dscritic);

               ROLLBACK; -- DESFAZ o que foi processado no ARQUIVO

               /****************************************/
               CONTINUE; -- PULAR PARA O PRÓXIMO ARQUIVO
               /****************************************/
            WHEN OTHERS THEN
               -- Define a mensagem de erro
               vr_dscritic := 'Erro ao ler o arquivo => '||vr_array_arquivo(ind)||'.'||chr(10)||SQLERRM;
               -- Envio centralizado de log de erro

               PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_nrdconta => 0
                                             ,pr_nmarquiv => 'PC_CRPS689'
                                             ,pr_textolog => vr_dscritic
                                             ,pr_cdcritic => pr_cdcritic
                                             ,pr_dscritic => pr_dscritic);

               ROLLBACK; -- DESFAZ o que foi processado no ARQUIVO

               /****************************************/
               CONTINUE; -- PULAR PARA O PRÓXIMO ARQUIVO
               /****************************************/
         END;
      END LOOP;

    EXCEPTION
       WHEN vr_exc_proxcoop THEN
          /* continua na proxima cooperativa */
          PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_nrdconta => 0
                                        ,pr_nmarquiv => 'PC_CRPS689'
                                        ,pr_textolog => vr_dscritic
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic);

          /********************************************/
          CONTINUE; -- PULAR PARA A PRÓXIMA COOPERATIVA
          /********************************************/

       WHEN OTHERS THEN
          RAISE vr_exc_fimprg;
    END;

  END LOOP;
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
EXCEPTION
   WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         -- Envio centralizado de log de erro
         PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_nrdconta => 0
                                       ,pr_nmarquiv => 'PC_CRPS689'
                                       ,pr_textolog => vr_dscritic
                                       ,pr_cdcritic => pr_cdcritic
                                       ,pr_dscritic => pr_dscritic);

         IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
         END IF;
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);
   WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure PC_CRPS689. Erro: '||SQLERRM;
      -- Envio centralizado de log de erro
      PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_nrdconta => 0
                                    ,pr_nmarquiv => 'PC_CRPS689'
                                    ,pr_textolog => pr_dscritic
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);

END PC_CRPS689;
/

