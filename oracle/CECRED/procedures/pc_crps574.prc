CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS574 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_nmtelant  IN craptel.nmdatela%TYPE
                                       ,pr_flgresta  IN PLS_INTEGER
                                       ,pr_stprogra OUT PLS_INTEGER
                                       ,pr_infimsol OUT PLS_INTEGER
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2) AS

/* .............................................................................

   Programa: PC_CRPS574                        Antigo: Fontes/crps574.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Julho/2010.                       Ultima atualizacao: 10/10/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos DDA - ABBC

   Alteracoes: 04/08/2010 - Ajuste no Programa (Ze).

               16/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).

               13/10/2010 - Inclusao do chave gncptit3, melhora no desempenho
                            (Ze).

               14/02/2011 - Tratamento caso o arquivo estiver vazio (Ze).

               20/09/2013 - Conversao Progress => Oracle (Gabriel).

               10/10/2013 - Ajuste para controle de criticas (Gabriel).

               24/04/2014 - Revalidação - Conversao Progress => Oracle (Alisson - AMcom).

............................................................................. */

  -- Variaveis de uso no programa
  vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS574';  -- Codigo do presente programa
  vr_dtauxili         VARCHAR2(50);                -- Data para validacao do arquivo
  vr_dtproces         DATE;                        -- Data para a leitura da gncptit
  vr_flgerros         BOOLEAN;                     -- Flag erros
  vr_dstextab         VARCHAR2(100);               -- Descricao da tabela CRAPTAB

  --Variaveis Para Interacao com Unix
  vr_nmarquiv         VARCHAR2(100);               -- Arquivos da ABBC
  vr_comando          VARCHAR2(1000);              -- Descricao do comando para Unix
  vr_typ_saida        VARCHAR2(100);               -- Tipo de saida
  vr_listadir         VARCHAR2(1000);              -- Lista de Arquivos
  vr_setlinha         VARCHAR2(1000);              -- Linha Importada do Arquivo
  vr_input_file       utl_file.file_type;          -- Handle para leitura de arquivo
  vr_vet_arquivos     gene0002.typ_split;          -- Array de arquivos

  --Variaveis Para os Diretorios
  vr_dsdireto_abbc    VARCHAR2(100);               -- Diretorio /integra da cooperativa
  vr_dsdireto_salvar  VARCHAR2(100);               -- Diretorio do salvar

  --Variaveis de Critica
  vr_cdcritic         crapcri.cdcritic%TYPE;       -- Codigo de critica
  vr_dscritic         VARCHAR2(2000);              -- Descricao de critica

  --Variaveis de Excecao
  vr_exc_saida        EXCEPTION;                   -- Tratamento de excecao parando a cadeia
  vr_exc_fimprg       EXCEPTION;                   -- Tratamento de excecao sem parar a cadeia
  vr_exc_prox_arq     EXCEPTION;                   -- Tratamento de excecao para proximo arquivo
  vr_exc_prox_linha   EXCEPTION;                   -- Tratamento de excecao para proxima linha
  vr_exc_fim_loop     EXCEPTION;                   -- Tratamento de excecao para sair loop das linhas

  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Dados da cooperativa
  rw_crapcop cr_crapcop%ROWTYPE;

  --  Cursor que verifica o cod barras na gncptit para localizar cdcooper
  CURSOR cr_gncptit (pr_dtmvtolt gncptit.dtmvtolt%TYPE
                    ,pr_dscodbar gncptit.dscodbar%TYPE) IS
    SELECT gncptit.cdcooper
          ,gncptit.cdagectl
      FROM gncptit gncptit
     WHERE gncptit.dtmvtolt        = pr_dtmvtolt
       AND UPPER(gncptit.dscodbar) = pr_dscodbar
     ORDER BY gncptit.dtmvtolt
             ,upper(gncptit.dscodbar)
             ,gncptit.progress_recid desc;

  -- Dados dos Titulos
  rw_gncptit cr_gncptit%ROWTYPE;

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  -- Se cooperativa nao encontrada, gera critica para o log
  IF  cr_crapcop%notfound   THEN
    vr_cdcritic := 651;
    CLOSE cr_crapcop;
    RAISE vr_exc_saida;
  END IF;
  --Fechar Cursor
  CLOSE cr_crapcop;

  -- Obter dados da data da cooperativa
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  -- Se nao exisitir a data da cooperativa, obter critica e jogar para o log
  IF  btch0001.cr_crapdat%notfound  THEN
    vr_cdcritic := 1;
    CLOSE btch0001.cr_crapdat;
    RAISE vr_exc_saida;
  END IF;
  --Fechar Cursor
  CLOSE btch0001.cr_crapdat;

  -- Realizar as validacoes do iniprg
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se possui critica, buscar a descricao e jogar ao log
  IF  vr_cdcritic <> 0  THEN
    RAISE vr_exc_saida;
  END IF;

  -- Leitura do indicador de uso da tabela de taxa de juros
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'EXECUTAABBC'
                                           ,pr_tpregist => 0);

  IF  vr_dstextab IS NULL OR vr_dstextab <> 'SIM' THEN
    --Sair do Programa
    RAISE vr_exc_fimprg;
  END IF;

  -- Obter diretorio abbc da cooperativa logada
  vr_dsdireto_abbc := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'abbc');

  -- Obter o diretorio do salvar
  vr_dsdireto_salvar:= gene0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'salvar');

  -- Monta o nome do arquivo
  vr_nmarquiv:= 'COB68000.085';

  /* Quando voltar a funcionar deve-se usar a atribuição abaixo */
  --vr_nmarquiv:= 'COB68%.085';

  -- Listar arquivos
  gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto_abbc
                            ,pr_pesq     => vr_nmarquiv
                            ,pr_listarq  => vr_listadir
                            ,pr_des_erro => vr_dscritic);

  --Separar os arquivos de retorno em um Array
  vr_vet_arquivos := gene0002.fn_quebra_string(pr_string  => vr_listadir
                                              ,pr_delimit => ',');

  -- Se o Array nao contem elementos, gerar critica 182
  IF vr_vet_arquivos.COUNT = 0 THEN
    vr_cdcritic := 182;
    -- Sair do programa sem erro
    RAISE vr_exc_fimprg;
  END IF;

   -- Se a tela anterior foi COMPEFORA, utilizar a data do movimento anterior
  IF  pr_nmtelant = 'COMPEFORA'  THEN
    vr_dtauxili := to_char(rw_crapdat.dtmvtoan,'YYYYMMDD');
  ELSE
    -- Senao utilizar a data atual
    vr_dtauxili := to_char(rw_crapdat.dtmvtolt,'YYYYMMDD');
  END IF;

  -- Percorrer os arquivos importados
  FOR vr_pos IN 1..vr_vet_arquivos.COUNT LOOP

    BEGIN
      -- Desconsiderar elemento null
      IF  vr_vet_arquivos(vr_pos) IS NULL  THEN
        --Proximo Arquivo
        RAISE vr_exc_prox_arq;
      END IF;

      -- Montar o nome do arquivo
      vr_nmarquiv:= vr_vet_arquivos(vr_pos);

      --Montar Comando para verificar linha do arquivo
      vr_comando:= 'tail -1 ' || vr_dsdireto_abbc ||'/'|| vr_nmarquiv  || ' 2> /dev/null';

      -- Verificar se o arquivo esta completo - inicio
      gene0001.pc_OScommand_Shell(pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_setlinha);

      -- Se Ocorreu erro
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'Erro ao executar comando unix. '||vr_setlinha;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      -- Se o comeco da linha nao for 9COB680, criticar e ir para proximo arquivo
      IF substr(vr_setlinha,1,7) <> '9COB680' THEN

        -- Gerar critica de identificacao invalida
        vr_cdcritic := 258;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        vr_dscritic := vr_dscritic ||' - Arquivo: '||vr_dsdireto_abbc||'/'|| vr_nmarquiv;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        --Proximo Arquivo
        RAISE vr_exc_prox_arq;
      END IF;

      -- Abrir o arquivo para leitura
      gene0001.pc_abre_arquivo (pr_nmdireto => vr_dsdireto_abbc --> Diretorio do Arquivo
                               ,pr_nmarquiv => vr_nmarquiv      --> Nome do arquivo
                               ,pr_tipabert => 'R'              --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file    --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);    --> Descricao do erro

      -- Se retornou erro
      IF  vr_dscritic IS NOT NULL  THEN
        --Sair com Erro
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se o arquivo esta aberto
      IF utl_file.IS_OPEN(vr_input_file) THEN

        -- Marcar sem Erros
        vr_flgerros:= FALSE;

        BEGIN
          -- Le os dados do arquivo e coloca na variavel vr_setlinha
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            --Chegou ao final do arquivo
            RAISE vr_exc_prox_arq;
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao ler arquivo. '||sqlerrm;
            RAISE vr_exc_saida;
        END;

        /* Verificar o header do Arquivo - Primeira Linha */

        --Inicializar erro
        vr_cdcritic:= 0;

        IF substr(vr_setlinha,2,6) <> 'COB680' THEN  -- Se arquivo nao for COB680, critica
           vr_cdcritic := 181;
        ELSIF substr(vr_setlinha,19,8) <> vr_dtauxili THEN  -- Se nao for a data atual ou anterior dependendo da chamada do programa, criticar
          vr_cdcritic := 13;
        END IF;

        -- Se tem alguma critica
        IF vr_cdcritic <> 0 THEN

          -- Buscar a descricao da critica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          -- Concatenar o nome do arquivo
          vr_dscritic := vr_dscritic ||' - Arquivo: '||vr_dsdireto_abbc||'/'|| vr_nmarquiv;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
          --Proximo Arquivo
          RAISE vr_exc_prox_arq;
        END IF;

        -- Loop para leitura das demais linhas do arquivo
        LOOP
          BEGIN
            --Criar savepoint
            SAVEPOINT save_trans;

            BEGIN
              -- Le os dados do arquivo e coloca na variavel vr_setlinha
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto lido
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                --Chegou ao final do arquivo
                RAISE vr_exc_fim_loop;
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao ler arquivo. '||sqlerrm;
                RAISE vr_exc_saida;
            END;

            /* Trailer - Se encontrar essa seq., terminou o arquivo */
            IF SUBSTR(vr_setlinha,1,7) = '9COB680' THEN
              --Final do Arquivo
              RAISE vr_exc_fim_loop;
            END IF;

            -- Data para a busca da gncptit
            vr_dtproces:=  to_date(substr(vr_setlinha,13,8),'YYYYMMDD');

            -- Cursor da gncptit
            OPEN cr_gncptit (pr_dtmvtolt => vr_dtproces
                            ,pr_dscodbar => substr(vr_setlinha,27,44));
            -- Obter cooperativa e agencia
            FETCH cr_gncptit INTO rw_gncptit;
            --  Verifica se jah existem informacoes importadas
            IF  cr_gncptit%NOTFOUND  THEN
              -- Fechar o cursor
              CLOSE cr_gncptit;
              --Marcar Ocorreu Erro
              vr_flgerros := TRUE;
              --Proxima Linha
              RAISE vr_exc_prox_linha;
            ELSE
              -- Fechar o cursor
              CLOSE cr_gncptit;

              BEGIN
                -- Criacao da tabela Generica - gnrcdda
                INSERT INTO gnrcdda
                   (cdcooper
                   ,dtmvtolt
                   ,cdagectl
                   ,dscodbar
                   ,dtproces
                   ,cdparsac
                   ,cdparced
                   ,cdtipdoc
                   ,dsidcdda)
                VALUES
                   (rw_gncptit.cdcooper
                   ,rw_crapdat.dtmvtolt
                   ,rw_gncptit.cdagectl
                   ,substr(vr_setlinha,27,44)
                   ,vr_dtproces
                   ,to_number(substr(vr_setlinha,21,3))
                   ,to_number(substr(vr_setlinha,24,3))
                   ,to_number(substr(vr_setlinha,2,3))
                   ,to_number(substr(vr_setlinha,71,17)));

              -- Tratamento de erro para a insercao na gnrcdda
              EXCEPTION
                WHEN OTHERS THEN
                  --Ignorar Erro e ir para proxima linha
                  RAISE vr_exc_prox_linha;
              END;
            END IF;
          EXCEPTION
            WHEN vr_exc_prox_linha THEN
              --Desfazer transacao
              ROLLBACK to save_trans;
            WHEN vr_exc_fim_loop THEN
              --Sair do Loop
              EXIT;
          END; --
        END LOOP; -- Fim da leitura linha a linha do arquivo

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

        --Montar Copia para o diretorio salvar
        vr_comando:= 'mv ' ||vr_dsdireto_abbc ||'/'|| vr_nmarquiv || ' ' ||
                     vr_dsdireto_salvar || '/'|| vr_vet_arquivos(vr_pos) || '_' ||  vr_dtauxili;

        -- Mover para o diretorio salvar
        gene0001.pc_OScommand_Shell(pr_des_comando => vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_setlinha);

        -- Se Ocorreu erro
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao executar comando unix. '||vr_setlinha;
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

        -- Obter critica dependendo a leitura do arquivo
        IF NOT vr_flgerros  THEN
          vr_cdcritic := 190;
        ELSE
          vr_cdcritic := 191;
        END IF;
        --Buscar Mensagem erro
        vr_dscritic := gene0001.fn_busca_critica (pr_cdcritic => vr_cdcritic);
        -- Concatenar o nome do arquivo
        vr_dscritic := vr_dscritic ||' - Arquivo: '|| vr_dsdireto_abbc ||'/'|| vr_nmarquiv;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );

      END IF; -- Fim da verificação se o arquivo esta aberto
    EXCEPTION
      WHEN vr_exc_prox_arq THEN
        -- Verifica se o arquivo esta aberto
        IF utl_file.IS_OPEN(vr_input_file) THEN
          -- Fechar o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        END IF;
    END;
  END LOOP; -- Fim da leitura de todos os arquivos

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --Salvar Informacoes
  COMMIT;

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
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;

  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;

END PC_CRPS574;
/

