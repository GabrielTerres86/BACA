CREATE OR REPLACE PROCEDURE CECRED.
            PC_CRPS400(pr_cdcooper IN crapcop.cdcooper%type   --> Codigo da cooperativa
                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                      ,pr_cdcritic OUT crapcri.cdcritic%type  --> Codigo de critica
                      ,pr_dscritic OUT VARCHAR2)              --> Descricao de critica
AS
  BEGIN
    /* .........................................................................

    Programa: PC_CRPS400 (Antigo Fontes/crps400.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Ze Eduardo
    Data    : Novembro/04.                    Ultima atualizacao: 11/12/2013

    Dados referentes ao programa:

    Frequencia: MENSAL (tambem executado nos script PROCESSO e PROCDIA)
    Objetivo  : Guardar relatorios mensal para a auditoria

    Alteracoes: 23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               01/09/2006 - Acerto no nome do diretorio. (Ze).

               23/05/2007 - Eliminada a atribuicao TRUE de glb_infimsol pois
                            nao e o ultimo programa da cadeia (Guilherme).

               19/06/2008 - Copiar arquivo compactado para o diretorio salvar
                            (Diego).

               02/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl"
                           (Vitor).

               22/06/2011 - Desprezar crrl227 e crrl354 do 1 dia mes (Magui).

               18/09/2013 - Conversao Progress -> PL/SQL (Douglas Pagel).

               10/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel)

               11/12/2013 - Verificar se os relatorios foram criados (Marcos-Supero).

    ......................................................................... */
    DECLARE
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS400';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- CURSORES --

      -- Cursor para validação da cooperativa
      cursor cr_crapcop is
        SELECT nmrescop, dsdircop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;

      -- Cursor para listagem dos relatorios
      cursor cr_craprel is
        SELECT craprel.cdrelato               -- Codigo do relatorio.
          FROM craprel                        -- Cadastro de Relatorios do Sistema
         WHERE craprel.cdcooper = pr_cdcooper
           AND craprel.indaudit = 1;          -- Indicador para a auditoria (0=Nao ou 1=Auditoria).

      -- Rowtype para validacao da data
      rw_crapdat btch0001.cr_crapdat%rowtype;

      -- FIM CURSORES --

      -- VARIAVEIS --
      vr_dircoop varchar2(300);           -- Diretorio da cooperativa
      vr_diraudi crapprm.dsvlrprm%type;   -- Diretorio para auditoria
      vr_nmrelato varchar2(100);          -- Nome para pesquisa do relatorio
      vr_nmarquiv varchar2(100);          -- Nome do arquivo encontrado
      vr_des_comando varchar2(500);       -- Comando Unix
      vr_des_saida VARCHAR2(4000);        -- Retorno do comando executado
      vr_vet_arquivos gene0002.typ_split; -- Vetor para receber a quebra do retorno do comando no Unix
      vr_nmarqzip varchar2(200);          -- Nome do arquivo compactado
      vr_flg_gerou boolean := false;      -- Flag se gerou arquivos
      vr_typ_saida varchar2(3);           -- Tipo de retorno do comando executado
      -- FIM VARIAVEIS --
    BEGIN
      -- Informa acesso
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Inicio da Regra de Negocio

      -- Enviar Log informando o aguardo do término dos relatórios
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                ,pr_ind_tipo_log => 1 --Apenas log            --> Nivel criticidade do log
                                ,pr_des_log => to_char(sysdate, 'hh24:mi:ss')
                                              || ' - '
                                              || vr_cdprogra
                                              || ' --> Aguardar geracao dos relatorios.');

      -- Se o processo de geração dos relatórios ainda está em execução:
      WHILE btch0001.fn_procrel_exec(pr_cdcooper) LOOP
        -- Aguardar 20 segundos
        sys.dbms_lock.sleep(20);
      END LOOP;

      -- Após o término, então continua com o processo normalmente.
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                ,pr_ind_tipo_log => 1 --Apenas log            --> Nivel criticidade do log
                                ,pr_des_log => to_char(sysdate, 'hh24:mi:ss')
                                              || ' - '
                                              || vr_cdprogra
                                              || ' --> Os relatorios foram gerados.');

      -- Busca diretorio da cooperativa
      vr_dircoop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Diretório COOP
                                         ,pr_cdcooper => pr_cdcooper);

      -- Busca diretorio de auditoria
      vr_diraudi := GENE0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_AUDITORIA');

      -- Valida diretorio de auditoria
      if vr_diraudi is null then
        vr_dscritic := 'Não há parametro cadastrado na crapprm para ROOT_AUDITORIA.';
        raise vr_exc_saida;
      end if;

      -- Listagem dos relatorios do sistema
      FOR rw_craprel IN cr_craprel LOOP

        -- Monta nome do relatorio para pesquisa
        -- Como no arquivo compactado final só vão arquivos crrl*.lst,
        -- aqui já é feito o filtro para não haver I/O desnecessário, ao contrário do progress
        vr_nmrelato := 'crrl' || to_char(rw_craprel.cdrelato,'fm000') || '*.lst';

        -- Monta comando da pesquisa para executar no Unix
        vr_des_comando := 'ls ' || vr_dircoop || '/rl/' || vr_nmrelato || ' 2> /dev/null';

        -- Executa comando da pesquisa
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_des_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_des_saida);

        -- Valida o retorno da pesquisa
        if vr_des_saida is not null then
          -- Quebra string de retorno a cada arquivo e coloca os dados em um vetor
          vr_vet_arquivos := gene0002.fn_quebra_string(pr_string  => vr_des_saida
                                                      ,pr_delimit => vr_dircoop);

          -- Valida vetor com patch dos arquivos encontrados na pesquisa
          if vr_vet_arquivos is not null then
            -- Percorre vetor com arquivos
            for vr_chave in 1..vr_vet_arquivos.count loop
              -- Se não existir o indice no vetor, passa adiante
              if not vr_vet_arquivos.exists(vr_chave) then
                continue;
              end if;
              -- Se não for troca de mes, os relatorios 6,7,30,89,108,124,227,234 e 354
              -- não devem entrar na auditoria
              if to_char(rw_crapdat.dtmvtolt, 'mm') = to_char(rw_crapdat.dtmvtopr, 'mm') AND
                rw_craprel.cdrelato in (6,7,30,89,108,124,227,234,354) then
                -- Passa para proximo relatorio
                continue;
              end if;

              -- Valida conteudo do vetor na posicao da chave
              if vr_vet_arquivos(vr_chave) is not null then
                -- Monta somente nome do arquivo para destino da cópia na pasta de auditoria
                vr_nmarquiv := substr(vr_vet_arquivos(vr_chave), Instr(vr_vet_arquivos(vr_chave), '/rl/', 1,1) + 4, 100);

                -- Monta comando para copia do arquivo convertendo para DOS
                vr_des_comando := 'ux2dos ' || vr_dircoop || vr_vet_arquivos(vr_chave) || ' > '|| vr_diraudi || rw_crapcop.dsdircop || '/' || vr_nmarquiv;

                -- Executa comando para copiar o arquivo para o diretorio de auditoria
                gene0001.pc_OScommand(pr_typ_comando => 'S'
                                     ,pr_des_comando => vr_des_comando
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_des_saida);

                -- Informa que houve arquivo
                vr_flg_gerou := true;
              end if;   -- Fim validacao de conteudo na posicao da chave do vetor
            end loop; -- Fim do vetor
          end if;   -- Fim da validacao do vetor
        end if;   -- Fim da validacao do retorno do comando
      end loop; -- Fim da craprel

      -- Se encontrou arquivos nas pesquisas
      if vr_flg_gerou then
        -- Monta nome do arquivo compactado
        -- Verificacao quanto a mudanca de mes
        if to_char(rw_crapdat.dtmvtolt, 'mm') = to_char(rw_crapdat.dtmvtopr, 'mm') then
          vr_nmarqzip := 'audit' || to_char(rw_crapdat.dtmvtoan, 'yyyy') || to_char(rw_crapdat.dtmvtoan, 'mm') || '.zip';
        else -- Se for troca de mes
          vr_nmarqzip := 'audit' || to_char(rw_crapdat.dtmvtolt, 'yyyy') || to_char(rw_crapdat.dtmvtolt, 'mm') || '.zip';
        end if;
        -- Completa caminho do arquivo
        vr_nmarqzip := vr_diraudi || rw_crapcop.dsdircop || '/' || vr_nmarqzip;

        -- Monta comando para permissoes no arquivo zip
        vr_des_comando := 'chmod 666 ' || vr_nmarqzip || ' 2> /dev/null';

        -- Executa comando para permissoes no arquivo zip
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_des_comando);

        -- Buscar os arquivos que serão inseridos no arquivo compactado
        -- Arquivos crrl*.lst da pasta de auditoria da cooperativa
        -- Monta comando da pesquisa para executar no Unix
        vr_des_comando := 'ls ' || vr_diraudi || rw_crapcop.dsdircop || '/' || 'crrl*.lst ';

        -- Executa comando da pesquisa
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_des_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_des_saida);

        -- Passa o retorno da pesquisa para o procedimento alimentar arquivo zip
        gene0002.pc_zipcecred(pr_cdcooper => pr_cdcooper  --> Cooperativa conectada
                             ,pr_tpfuncao => 'A' -- Função a ser executada pela rotina
                             ,pr_dsorigem => vr_diraudi || rw_crapcop.dsdircop || '/' || 'crrl*.lst' -->Lista de arquivos a zipar (sep. p/ espaço)
                             ,pr_dsdestin => vr_nmarqzip --> Arquivo final .zip
                             ,pr_dspasswd => null  --> Password a incluir
                             ,pr_des_erro => pr_dscritic);

        -- Copia o arquivo compactado para o diretorio salvar da cooperativa
        -- Monta comando para copia
        vr_des_comando := 'cp ' || vr_nmarqzip || ' ' || vr_dircoop || 'salvar';

        -- Executa comando para copia do arquivo
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_des_comando);

        -- Apaga arquivos crrl* na pasta de auditoria da cooperativa.
        -- Monta comando para deletar
        vr_des_comando := 'rm ' || vr_diraudi || rw_crapcop.dsdircop || '/crrl*';

        -- Executa comando para deletar arquivos
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_des_comando);

        -- Gera log informando sucesso
        btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                  ,pr_ind_tipo_log => 2 --Tratado               --> Nivel criticidade do log
                                  ,pr_des_log => to_char(sysdate, 'hh24:mi:ss')
                                                || ' - '
                                                || vr_cdprogra
                                                || ' --> '
                                                || gene0001.fn_busca_critica(pr_cdcritic => 807));                --> Descrição do log em si

      else -- Se nao encontrou arquivos para auditoria
        -- Gera log informando sem arquivos
        btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                  ,pr_ind_tipo_log => 2 --Tratado               --> Nivel criticidade do log
                                  ,pr_des_log => to_char(sysdate, 'hh24:mi:ss')
                                                || ' - '
                                                || vr_cdprogra
                                                || ' --> '
                                                || gene0001.fn_busca_critica(pr_cdcritic => 182));                --> Descrição do log em si
      end if; -- Fim se encontrou arquivos

      -- Fim da Regra de Negocio

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizada
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
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
        -- Efetuar commit
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
    END;
  END PC_CRPS400;
/

