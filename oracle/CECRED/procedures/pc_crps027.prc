CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS027" (pr_cdcooper  IN  crapcop.cdcooper%TYPE           --> Cooperativa
                                     ,pr_flgresta  IN PLS_INTEGER     --> Flag padrão para utilização de restart
                                     ,pr_stprogra OUT PLS_INTEGER     --> Saída de termino da execução
                                     ,pr_infimsol OUT PLS_INTEGER     --> Saída de termino da solicitação
                                     ,pr_cdcritic OUT NUMBER          --> Código crítica
                                     ,pr_dscritic OUT VARCHAR2) IS    --> Descrição crítica
BEGIN
  /* ..........................................................................

   Programa: pc_crps027 (Antigo Fontes/crps027.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/92.                          Ultima atualizacao: 14/10/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Lista total de retorno a incorporar gerado no mes (27).

   Alteracoes: 05/07/94 - Alterado literal valor em cruzeiros para valor.

               09/09/94 - Alterado valor da moeda para 8 casas decimais
                          (Deborah).

               11/11/94 - Alterado para somar o campo vljursaq do crapsld
                          (Odair).

               10/03/95 - Alterado para substituir o valor da moeda fixa
                          utilizada nos calculos para a ser a do proximo
                          movimento (Odair).

               11/04/96 - Alterado para listar total de rendimento sobre poupan-
                          ca programada (Odair).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/05/98 - Comentado o calculo do rendimento de aplicacoes.
                          O valor esta guardado mes a mes no crapcot.vlrenrda.
                          (Deborah).

             15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

             12/06/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.

             06/09/2013 - Alterações para melhorar performance da execução em cadeia.

             14/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                          das criticas e chamadas a fimprg.p (Douglas Pagel)
  ............................................................................. */
  DECLARE
    /* Definição de PL Table */
    TYPE typ_reg_crapcot IS
      RECORD(qtjurmfx crapcot.qtjurmfx%TYPE
            ,vlrenrpp crapcot.vlrenrpp%TYPE);

    TYPE typ_tab_crapcot IS TABLE OF typ_reg_crapcot INDEX BY VARCHAR2(20);

    -- Definicao do tipo de registro para emprestimos
    TYPE typ_reg_crapepr IS
    RECORD (vljurmes crapepr.vljurmes%TYPE);    --conta/dv

    -- Definicao do tipo de tabela para emprestimos
    TYPE typ_tab_crapepr IS
      TABLE OF typ_reg_crapepr
      INDEX BY VARCHAR2(20);

    vr_rel_vltotjur  NUMBER(20,10) := 0;          --> Valor total de juros para relatório
    vr_rel_qttotjur  NUMBER(20,10) := 0;          --> Quantidade total de juros para relatório
    vr_rel_qtjurmfx  NUMBER(20,10) := 0;          --> Quantidade mensal juros para relatório
    vr_rel_qtrenpou  NUMBER(20,10) := 0;          --> Quantidade mensal de rendimento da poupança para relatório
    vr_vljuremp      NUMBER(20,10) := 0;          --> Valor total de juros para empréstimo
    vr_exc_erro      EXCEPTION;                   --> Controle de erros
    rw_crapdat       btch0001.cr_crapdat%ROWTYPE; --> Tipo para receber o fetch de dados
    vr_sai_loop      EXCEPTION;                   --> Controle de execução do LOOP
    vr_nom_dir       VARCHAR2(400);               --> Path do relatório
    vr_des_xml       CLOB;                        --> Buffer de dados para gerar XML de dados
    vr_tab_crapcot   typ_tab_crapcot;             --> Declaração da PL Table
    vr_tab_crapepr   typ_tab_crapepr;             --> Declaração da PL Table

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    /* Definições iniciais para a execução */
    vr_cdprogra      VARCHAR2(50) := 'CRPS027';   --> Nome do programa
    vr_nrcopias      NUMBER := 1;                 --> Número de cópias
    vr_nmformul      VARCHAR2(400) := '';         --> Nome do formulário

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca dados sobre moedas */
    CURSOR cr_crapmfx(pr_cdcooper IN crapmfx.cdcooper%TYPE       --> Cooperativa
                     ,pr_dtmvtopr IN crapmfx.dtmvtolt%TYPE) IS   --> Data de movimento
      SELECT cm.vlmoefix
      FROM crapmfx cm
      WHERE cm.cdcooper = pr_cdcooper
        AND cm.dtmvtolt = pr_dtmvtopr
        AND cm.tpmoefix = 2;
    rw_crapmfx cr_crapmfx%ROWTYPE;

    /* Busca dados sobre o saldo dos associados */
    CURSOR cr_crapsld(pr_cdcooper IN crapsld.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cs.nrdconta
            ,cs.vljurmes
            ,cs.vljuresp
            ,cs.vljursaq
      FROM crapsld cs
      WHERE cs.cdcooper = pr_cdcooper;
    rw_crapsld cr_crapsld%ROWTYPE;

    /* Busca dados sobre cadastro de cotas dos associados */
    CURSOR cr_crapcot(pr_cdcooper IN crapcot.cdcooper%TYPE) IS    --> Cooperativa
      SELECT ct.qtjurmfx
            ,ct.vlrenrpp
            ,ct.nrdconta
      FROM crapcot ct
      WHERE ct.cdcooper = pr_cdcooper;

    /* Busca dados sobre o cadastro de empréstimos dos associados */
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE, --> Cooperativa
                      pr_dtmvtolt IN DATE) IS
      SELECT cr.nrdconta
            ,sum(cr.vljurmes) vljurmes
      FROM crapepr cr
      WHERE cr.cdcooper = pr_cdcooper
        AND cr.vljurmes > 0
        AND ((vlsdeved = 0
        AND   to_char(dtultpag, 'MM') = to_char(pr_dtmvtolt,'MM')) -- Verifica se o mês de execução é igual ao mês do cadastro de empréstimo
         OR  vlsdeved <> 0)
       GROUP BY nrdconta;

    -- Procedure para escrever texto na variável CLOB do XML
    PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    END pc_xml_tag;

  BEGIN
    -- Código do programa
    vr_cdprogra := 'CRPS027';

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS027'
                              ,pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper);
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

    -- Buscar informações de moeda
    OPEN cr_crapmfx(pr_cdcooper, rw_crapdat.dtmvtopr);
    FETCH cr_crapmfx INTO rw_crapmfx;

    -- Verifica se a tupla retornou registros
    IF cr_crapmfx%NOTFOUND THEN
      CLOSE cr_crapmfx;

      -- Crítica do processo
      vr_cdcritic := 140;

      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapmfx;
    END IF;

    -- Carregar PL Table da CRAPCOT
    FOR rw_crapcot IN cr_crapcot(pr_cdcooper) LOOP
      vr_tab_crapcot(lpad(rw_crapcot.nrdconta, 20, '0')).qtjurmfx := rw_crapcot.qtjurmfx;
      vr_tab_crapcot(lpad(rw_crapcot.nrdconta, 20, '0')).vlrenrpp := rw_crapcot.vlrenrpp;
    END LOOP;

    -- Carregar PL Table da CRAPEPR
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper, rw_crapdat.dtmvtolt) LOOP
      vr_tab_crapepr(lpad(rw_crapepr.nrdconta, 20, '0')).vljurmes := rw_crapepr.vljurmes;
    END LOOP;

    -- Cadastro de saldos dos associados
    FOR rw_crapsld IN cr_crapsld(pr_cdcooper) LOOP
      -- Cadastro de cotas dos associados
      IF NOT vr_tab_crapcot.exists(lpad(rw_crapsld.nrdconta, 20, '0')) THEN
        -- Crítica do processo
        pr_cdcritic := 169;

        RAISE vr_exc_saida;
      END IF;

      -- Limpar valor por número de conta
      vr_vljuremp := 0;

      -- Acumula valor de juros do empréstimo
      IF vr_tab_crapepr.exists(lpad(rw_crapsld.nrdconta, 20, '0')) THEN
        vr_vljuremp := vr_vljuremp + vr_tab_crapepr(lpad(rw_crapsld.nrdconta, 20, '0')).vljurmes ;
      END IF;

      -- Acumula valores do processo por conta
        vr_rel_vltotjur := vr_rel_vltotjur + rw_crapsld.vljurmes + rw_crapsld.vljuresp + vr_vljuremp + rw_crapsld.vljursaq;
        vr_rel_qttotjur := vr_rel_qttotjur + ((rw_crapsld.vljurmes + rw_crapsld.vljuresp + vr_vljuremp + rw_crapsld.vljursaq) / rw_crapmfx.vlmoefix);
        vr_rel_qtjurmfx := vr_rel_qtjurmfx + vr_tab_crapcot(lpad(rw_crapsld.nrdconta, 20, '0')).qtjurmfx;
        vr_rel_qtrenpou := vr_rel_qtrenpou + vr_tab_crapcot(lpad(rw_crapsld.nrdconta, 20, '0')).vlrenrpp;
    END LOOP;

    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Inicilizar as informações do XML
    pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><saldos>' ||
               '<rel_vltotjur>' || to_char(apli0001.fn_round(vr_rel_vltotjur, 2), 'FM999G999G999G990D90') || '</rel_vltotjur>' ||
               '<rel_qttotjur>' || to_char(apli0001.fn_round(vr_rel_qttotjur, 4), 'FM999G999G999G990D9900') || '</rel_qttotjur>' ||
               '<rel_qtjurmfx>' || to_char(apli0001.fn_round(vr_rel_qtjurmfx, 4), 'FM999G999G999G990D9900') || '</rel_qtjurmfx>' ||
               '<rel_qtrenpou>' || to_char(apli0001.fn_round(vr_rel_qtrenpou, 2), 'FM999G999G999G990D90') || '</rel_qtrenpou>' ||
               '<vlmoefix>' || to_char(rw_crapmfx.vlmoefix, 'FM990D90000000') || '</vlmoefix></saldos>');

    -- Imprimir o relatório
    -- Efetuar chamada de geração do PDF do relatório
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_des_xml
                               ,pr_dsxmlnode => '/saldos'
                               ,pr_dsjasper  => 'crrl027.jasper'
                               ,pr_dsparams  => ''
                               ,pr_dsarqsaid => vr_nom_dir || '/crrl027.lst'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_des_erro  => vr_dscritic);

    -- Liberar dados do CLOB da memória
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      vr_cdcritic := 0;
      RAISE vr_exc_saida;
    END IF;

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
END PC_CRPS027;
/

