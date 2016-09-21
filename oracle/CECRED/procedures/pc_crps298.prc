CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS298" (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: pc_crps298 (Antigo Fontes/crps298.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Eduardo.
       Data    : Novembro/2000.                    Ultima atualizacao: 11/10/2013

       Dados referentes ao programa:

       Frequencia: Mensal (Batch - Background).
       Objetivo  : Atende a solicitacao 004 (mensal - relatorios)
                   Relatorio : 250 (132 colunas)
                   Ordem do programa na solicitacao : 3
                   Emite: relatorio geral do capital.

       Alteracoes: 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   09/04/2008 - Alterado formato da variável "rel_qtprepag" de
                                "zzzz" para "zzz9"
                              - Kbase IT Solutions - Paulo Ricardo Maciel.

                   04/08/2008 - Alterado format do vldcotas para nao estourar
                                (Gabriel).

                   30/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   22/05/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                                das criticas e chamadas a fimprg.p (Douglas Pagel)

    ............................................................................ */

    DECLARE

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca das empresas em titulares de conta
      CURSOR cr_crapttl IS
        SELECT nrdconta
              ,cdempres
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND idseqttl = 1; --> Somente titulares

      -- Busca das empresas no cadastro de pessoas juridicas
      CURSOR cr_crapjur IS
        SELECT nrdconta
              ,cdempres
          FROM crapjur
         WHERE cdcooper = pr_cdcooper;

      -- Busca do registro de cotas
      CURSOR cr_crapcot IS
        SELECT nrdconta
              ,vldcotas
          FROM crapcot
         WHERE cdcooper = pr_cdcooper;

      -- Busca do registro de planos
      CURSOR cr_crappla IS
        SELECT nrdconta
              ,nrctrpla
              ,dtinipla
              ,vlprepla
              ,qtprepag
              ,nvl(to_char(dtdpagto,'dd'),0) dtdpagto
              ,decode(flgpagto,1,'F','C') flgpagto
          FROM crappla
         WHERE cdcooper = pr_cdcooper
           AND tpdplano = 1 --> Tipo do plano
           AND cdsitpla = 1;--> Situação ativa

      -- Busca dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT nrdconta
              ,cdagenci
              ,nrmatric
              ,nmprimtl
              ,dtadmiss
          FROM crapass
         WHERE cdcooper = pr_cdcooper;

      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT nmextage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      vr_nmextage crapage.nmextage%TYPE;

      ------------------- TIPOS E TABELAS DE MEMÓRIA -----------------------

      -- Tipo para busca da empresa tanto de pessoa física quanto juridica
      -- Obs. A chave é o número da conta
      TYPE typ_tab_empresa IS
        TABLE OF crapjur.cdempres%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_empresa typ_tab_empresa;

      -- Tipo para armazenar as informações de cotas do associado
      -- Obs. A chave é o número da conta
      TYPE typ_tab_cotas IS
        TABLE OF crapcot.vldcotas%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_cotas typ_tab_cotas;

      -- Definição de temp table para armazenar as informações
      -- de registro dos planos por conta
      -- Obs: A chave é a conta do associados e somente o primeiro
      --      registro de plano por conta será armazenado
      TYPE typ_reg_planos IS
        RECORD(nrctrpla crappla.nrctrpla%TYPE
              ,dtinipla crappla.dtinipla%TYPE
              ,vlprepla crappla.vlprepla%TYPE
              ,qtprepag crappla.qtprepag%TYPE
              ,dtdpagto NUMBER(2)
              ,flgpagto CHAR(1));
      TYPE typ_tab_planos IS
        TABLE OF typ_reg_planos
          INDEX BY PLS_INTEGER;
      vr_tab_planos typ_tab_planos;

      -- Definição de tipo para armazenar o resumo geral por agência
      -- Chave composta pelo código da agência
      TYPE typ_reg_resumo IS
        RECORD(nmextage crapage.nmextage%TYPE
              ,qtdsocio NUMBER
              ,qtdplano NUMBER
              ,vltotpla NUMBER
              ,vldcotas NUMBER);
      TYPE typ_tab_resumo IS
        TABLE OF typ_reg_resumo
          INDEX BY PLS_INTEGER;
      vr_tab_resumo typ_tab_resumo;

      ----------------------------- VARIAVEIS ------------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS298';
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis para os XMLs e relatórios
      vr_clobxml    CLOB;                   -- Clob para conter o XML de dados
      vr_nom_direto VARCHAR2(200);          -- Diretório para gravação do arquivo
      vr_cdempres   crapjur.cdempres%TYPE;  -- Código da empresa
      vr_vldcotas   crapcot.vldcotas%TYPE;  -- Valor das cotas
      vr_vlprepla   crappla.vlprepla%TYPE;  -- Valor de prestação plano

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_clobxml, length(pr_desdados),pr_desdados);
      END;

    BEGIN
      -- Incluir nome do módulo logado
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
      -- Carregar PLTABLE de titulares de conta
      FOR rw_crapttl IN cr_crapttl LOOP
        vr_tab_empresa(rw_crapttl.nrdconta) := rw_crapttl.cdempres;
      END LOOP;
      -- Carregar PLTABLE de empresas
      FOR rw_crapjur IN cr_crapjur LOOP
        vr_tab_empresa(rw_crapjur.nrdconta) := rw_crapjur.cdempres;
      END LOOP;
      -- Carregar PLTABLE do registro de cotas
      FOR rw_crapcot IN cr_crapcot LOOP
        vr_tab_cotas(rw_crapcot.nrdconta) := rw_crapcot.vldcotas;
      END LOOP;

      -- Busca do registro de planos para a conta
      FOR rw_crappla IN cr_crappla LOOP
        -- Somente inserir se não existir algum plano para a conta
        IF NOT vr_tab_planos.EXISTS(rw_crappla.nrdconta) THEN
          -- Criar o registro para a conta
          vr_tab_planos(rw_crappla.nrdconta).nrctrpla := rw_crappla.nrctrpla;
          vr_tab_planos(rw_crappla.nrdconta).dtinipla := rw_crappla.dtinipla;
          vr_tab_planos(rw_crappla.nrdconta).vlprepla := rw_crappla.vlprepla;
          vr_tab_planos(rw_crappla.nrdconta).qtprepag := rw_crappla.qtprepag;
          vr_tab_planos(rw_crappla.nrdconta).dtdpagto := rw_crappla.dtdpagto;
          vr_tab_planos(rw_crappla.nrdconta).flgpagto := rw_crappla.flgpagto;
        END IF;
      END LOOP;
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><associ>');
      -- Busca de todos os associados da cooperativa
      FOR rw_crapass IN cr_crapass LOOP
        -- Se o associado não possuir registro de cotas
        IF NOT vr_tab_cotas.EXISTS(rw_crapass.nrdconta) THEN
          -- Gerar crítica 169 e sair do processo
          vr_cdcritic := 169;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' Conta '||rw_crapass.nrdconta;
          RAISE vr_exc_saida;
        END IF;
        -- Se ainda não existe o resumo para a agencia atual
        IF NOT vr_tab_resumo.EXISTS(rw_crapass.cdagenci) THEN
          -- Busca o nome da agencia
          OPEN cr_crapage(rw_crapass.cdagenci);
          FETCH cr_crapage
           INTO vr_nmextage;
          CLOSE cr_crapage;
          -- Inicializar o vetor com o nome e os totalizadores zeradores
          vr_tab_resumo(rw_crapass.cdagenci).nmextage := vr_nmextage;
          vr_tab_resumo(rw_crapass.cdagenci).qtdsocio := 0;
          vr_tab_resumo(rw_crapass.cdagenci).qtdplano := 0;
          vr_tab_resumo(rw_crapass.cdagenci).vltotpla := 0;
          vr_tab_resumo(rw_crapass.cdagenci).vldcotas := 0;
        END IF;
        -- Somente continuar se existir registro de plano para a conta ou valor de cota
        IF vr_tab_planos.EXISTS(rw_crapass.nrdconta) OR vr_tab_cotas(rw_crapass.nrdconta) > 0 THEN
          -- Se encontrou plano
          IF vr_tab_planos.EXISTS(rw_crapass.nrdconta) THEN
            -- Incrementar totalizador de planos
            vr_tab_resumo(rw_crapass.cdagenci).qtdplano := vr_tab_resumo(rw_crapass.cdagenci).qtdplano + 1;
          ELSE
            -- Criar o registro com as informações zeradas pois
            -- dessa forma não precisamos testar se o registro existe
            -- antes de envia-lo ao XML
            vr_tab_planos(rw_crapass.nrdconta).nrctrpla := null;
            vr_tab_planos(rw_crapass.nrdconta).dtinipla := null;
            vr_tab_planos(rw_crapass.nrdconta).vlprepla := null;
            vr_tab_planos(rw_crapass.nrdconta).qtprepag := 0;
            vr_tab_planos(rw_crapass.nrdconta).dtdpagto := null;
            vr_tab_planos(rw_crapass.nrdconta).flgpagto := null;
          END IF;
          -- Se existir a conta no vetor das empresas por conta
          IF vr_tab_empresa.EXISTS(rw_crapass.nrdconta) THEN
            -- Copiar o código da empresa a partir do vetor
            vr_cdempres := vr_tab_empresa(rw_crapass.nrdconta);
          ELSE
            -- Enviar empresa em branco
            vr_cdempres :=  null;
          END IF;
          -- Somente enviar as cotas e valor da prestação quando estes forem superiores a zero
          IF vr_tab_cotas(rw_crapass.nrdconta) > 0 THEN
            vr_vldcotas := vr_tab_cotas(rw_crapass.nrdconta);
          ELSE
            vr_vldcotas := NULL;
          END IF;
          IF vr_tab_planos(rw_crapass.nrdconta).vlprepla > 0 THEN
            vr_vlprepla := vr_tab_planos(rw_crapass.nrdconta).vlprepla;
          ELSE
            vr_vlprepla := NULL;
          END IF;
          -- Criar o registro do associado no relatório
          pc_escreve_xml('<nrdconta id="'||LTRIM(gene0002.fn_mask_conta(rw_crapass.nrdconta))||'">'
                       ||  '<cdagenci>'||rw_crapass.cdagenci||'</cdagenci>'
                       ||  '<cdempres>'||vr_cdempres||'</cdempres>'
                       ||  '<nrmatric>'||to_char(rw_crapass.nrmatric,'fm999g990')||'</nrmatric>'
                       ||  '<nmprimtl>'||substr(rw_crapass.nmprimtl,1,29)||'</nmprimtl>'
                       ||  '<dtadmiss>'||to_char(rw_crapass.dtadmiss,'dd/mm/rrrr')||'</dtadmiss>'
                       ||  '<vldcotas>'||to_char(vr_vldcotas,'fm999g999g999g990d00')||'</vldcotas>'
                       ||  '<nrctrpla>'||to_char(vr_tab_planos(rw_crapass.nrdconta).nrctrpla,'fm999g990')||'</nrctrpla>'
                       ||  '<dtinipla>'||to_char(vr_tab_planos(rw_crapass.nrdconta).dtinipla,'dd/mm/rrrr')||'</dtinipla>'
                       ||  '<vlprepla>'||to_char(vr_vlprepla,'fm999g999g999g990d00')||'</vlprepla>'
                       ||  '<qtprepag>'||to_char(nvl(vr_tab_planos(rw_crapass.nrdconta).qtprepag,0),'fm9990')||'</qtprepag>'
                       ||  '<flgpagto>'||vr_tab_planos(rw_crapass.nrdconta).flgpagto||'</flgpagto>'
                       ||  '<dtdpagto>'||to_char(vr_tab_planos(rw_crapass.nrdconta).dtdpagto,'fm9990')||'</dtdpagto>'
                       ||'</nrdconta>');
          -- Acumular os totalizadores por agência
          vr_tab_resumo(rw_crapass.cdagenci).qtdsocio := vr_tab_resumo(rw_crapass.cdagenci).qtdsocio + 1;
          vr_tab_resumo(rw_crapass.cdagenci).vltotpla := vr_tab_resumo(rw_crapass.cdagenci).vltotpla + NVL(vr_vlprepla,0);
          vr_tab_resumo(rw_crapass.cdagenci).vldcotas := vr_tab_resumo(rw_crapass.cdagenci).vldcotas + NVL(vr_tab_cotas(rw_crapass.nrdconta),0);
        END IF;
      END LOOP;
      -- Fechar tag dos associados e iniciar a de resumos
      pc_escreve_xml('</associ><resumo_pac>');
      -- Varrer o vetor de resumo por agência para enviá-lo ao XML
      FOR vr_cdagenci IN vr_tab_resumo.FIRST..vr_tab_resumo.LAST LOOP
        -- Se existir nesta posição e existirem sócios
        IF vr_tab_resumo.EXISTS(vr_cdagenci) AND vr_tab_resumo(vr_cdagenci).qtdsocio > 0 THEN
          -- Adicionar o nó resumo ao XML
          pc_escreve_xml('<pac id="'||LPAD(vr_cdagenci,3,' ')||'">'
                       ||'  <nmresage>'||vr_tab_resumo(vr_cdagenci).nmextage||'</nmresage>'
                       ||'  <qtdsocio>'||to_char(vr_tab_resumo(vr_cdagenci).qtdsocio,'fm999g999g999g990')||'</qtdsocio>'
                       ||'  <qtdplano>'||to_char(vr_tab_resumo(vr_cdagenci).qtdplano,'fm999g999g999g990')||'</qtdplano>'
                       ||'  <vltotpla>'||to_char(vr_tab_resumo(vr_cdagenci).vltotpla,'fm999g999g999g990d00')||'</vltotpla>'
                       ||'  <vldcotas>'||to_char(vr_tab_resumo(vr_cdagenci).vldcotas,'fm999g999g999g990d00')||'</vldcotas>'
                       ||'</pac>');
        END IF;
      END LOOP;
      -- Finalizar o nó resumo_pac e raiz
      pc_escreve_xml('</resumo_pac></raiz>');
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl
      -- Submeter o relatório 250
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                              --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl250.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl250.lst'        --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132dm'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar commit
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
  END pc_crps298;
/

