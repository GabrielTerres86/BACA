CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps393 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps393 (Fontes/crps393.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Evandro
       Data    : Junho/2004                     Ultima atualizacao: 01/12/2016

       Dados referentes ao programa:

       Frequencia: Mensal
       Objetivo  : Atende a solicitacao 101.
                   Emite um relatorio (listagem) de CPF nao consultados (352).

       Alteracoes: 10/10/2005 - Alterado para gerar arquivos separadamente por PAC,
                                acrescentados campos TTL. e SITUACAO (Diego).

                   17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   14/07/2006 - Inclusao do campo Data de Consulta CPF (Elton).

                   17/08/2006 - Nao estava jogando todos para a impressora(Magui).

                   23/05/2007 - Incluido infimsol = true(Guilherme)

                   09/09/2013 - Nova forma de chamar as agências, de PAC agora
                                a escrita será PA (André Euzébio - Supero).

                   12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                                (Reinert)
                   16/01/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM)

                   01/12/2016 - Modificado a mensagem de PA NAO CADASTRADO na variavel
                                vr_nmresage para '- PA NAO CADAS.' pois estourava
                                o limite do campo abortando o programa (Tiago/Elton)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS393';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);


      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      CURSOR cr_crapass IS -- busca associados com cpf/cgc pendente/cancelado
        SELECT cdagenci,
               nrdconta,
               nmprimtl,
               dtcnscpf,
               inpessoa,
               nrcpfcgc,
               cdsitcpf
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.dtdemiss IS NULL
        AND    crapass.cdsitcpf <> 1  -- situacao CPG/CGC 2=Pendente ou 3=Cancelado
        ORDER  BY crapass.cdagenci,
                  crapass.nrdconta;

        -- busca dados dos PAs
      CURSOR cr_crapage(pr_cdagenci IN NUMBER) IS
        SELECT nmresage
        FROM   crapage
        WHERE  crapage.cdcooper = pr_cdcooper
        AND    crapage.cdagenci = pr_cdagenci;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_reg_relato IS
        RECORD ( cdagenci crapass.cdagenci%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,nrcpfcgc varchar2(18)--crapass.nrcpfcgc%TYPE
                ,dssitcpf VARCHAR2(12)
                ,dtcnscpf crapass.dtcnscpf%TYPE
                );
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
          INDEX BY VARCHAR2(97); --> 05 PA + 10 conta + 18 nrcpfcgc
      vr_tab_relato typ_tab_relato;
      vr_des_chave  VARCHAR2(97);
      ------------------------------- VARIAVEIS -------------------------------

      vr_dssitcpf    VARCHAR2(12);
      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;   -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquiv
      vr_nmresage    crapage.nmresage%TYPE;
      vr_nmarqim     VARCHAR2(25);

      --------------------------- SUBROTINAS INTERNAS --------------------------
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;
      --------------- VALIDACOES INICIAIS -----------------

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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      FOR crapass IN cr_crapass
      LOOP
        EXIT WHEN cr_crapass%NOTFOUND;
        -- popula tmp_table
        vr_des_chave := lpad(crapass.cdagenci,5,'0')||lpad(crapass.nrdconta,10,'0')||lpad(crapass.nrcpfcgc,18,'0');
        vr_tab_relato(vr_des_chave).cdagenci := crapass.cdagenci;
        vr_tab_relato(vr_des_chave).nrdconta := crapass.nrdconta;
        vr_tab_relato(vr_des_chave).nmprimtl := crapass.nmprimtl;
        vr_tab_relato(vr_des_chave).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(to_char(crapass.nrcpfcgc), crapass.inpessoa);
        vr_tab_relato(vr_des_chave).dtcnscpf := crapass.dtcnscpf;

        IF crapass.cdsitcpf = 0 THEN -- verifica status cpf/cgc
          vr_dssitcpf := 'Sem Consulta';
        ELSIF crapass.cdsitcpf = 2   THEN
          vr_dssitcpf := 'Pendente';
        ELSIF crapass.cdsitcpf = 3   THEN
          vr_dssitcpf := 'Cancelado';
        ELSIF crapass.cdsitcpf = 4   THEN
          vr_dssitcpf := 'Irregular';
        ELSIF crapass.cdsitcpf = 5   THEN
          vr_dssitcpf := 'Suspenso';
        ELSE
          vr_dssitcpf := null;
        END IF;
        vr_tab_relato(vr_des_chave).dssitcpf := vr_dssitcpf;
      END LOOP;

      -- Com a tabela do relatorio povoada, iremos varre-la para gerar o xml de base ao relatorio
      vr_des_chave := vr_tab_relato.first;
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
      --varre tmp_table
      WHILE vr_des_chave IS NOT NULL LOOP
        -- No primeiro ou ao mudar o PA
        IF vr_des_chave = vr_tab_relato.first OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).cdagenci THEN
          -- Gerar a tag do PA
          OPEN cr_crapage(vr_tab_relato(vr_des_chave).cdagenci);
          FETCH cr_crapage INTO vr_nmresage;
          CLOSE cr_crapage;
          IF vr_nmresage IS NULL THEN
            vr_nmresage := '- PA NAO CADAS.';
          END IF;
          vr_nmarqim := '/crrl352_'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3, '0')||'.lst';
          pc_escreve_clob(vr_clobxml,'<pac cdagenci="'||vr_tab_relato(vr_des_chave).cdagenci||'" nmresage="'||vr_nmresage||'">');
        END IF;
        --monta xml
        pc_escreve_clob(vr_clobxml, '<conta>'
                                  ||'  <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_relato(vr_des_chave).nrdconta))||'</nrdconta>'
                                  ||'   <ttl>'||rpad(1, 4, ' ')||'</ttl>'
                                  ||'   <titular>'||substr(vr_tab_relato(vr_des_chave).nmprimtl,1,40)||'</titular>'
                                  ||'   <nrcpfcgc>'||vr_tab_relato(vr_des_chave).nrcpfcgc||'</nrcpfcgc>'
                                  ||'   <dtcnscpf>'||to_char(vr_tab_relato(vr_des_chave).dtcnscpf,'dd/mm/yyyy')||'</dtcnscpf>'
                                  ||'   <situacao>'||vr_tab_relato(vr_des_chave).dssitcpf||'</situacao>'
                                  ||'</conta>');

        -- ultimo registro ou mudar o PA, fecha tag e gera relatorio
        IF vr_des_chave = vr_tab_relato.last OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdagenci THEN
          -- Gerar a tag do PA
          pc_escreve_clob(vr_clobxml,'</pac>');
          -- Encerrar tag raiz
          pc_escreve_clob(vr_clobxml,'</raiz>');

          --busca diretorio padrao da cooperativa
          vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'rl');

          -- Solicitando o relatório para o PA atual
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/raiz/pac/conta'    --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl352.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||vr_nmarqim            --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 3                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_des_erro  => vr_dscritic);                       --> Saída com erro

          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_saida;
          END IF;
          -- Fechando CLOB do PA atual
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml);
          -- Abrindo novamente para iniciar o CLOB do próximo PA
          dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
        END IF;
        -- Buscar o proximo
        vr_des_chave := vr_tab_relato.NEXT(vr_des_chave);

      END LOOP;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
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
        -- Devolvemos código e critica encontradas das variaveis locais
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

  END pc_crps393;
