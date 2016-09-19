CREATE OR REPLACE PROCEDURE CECRED.pc_crps661 (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                              ,pr_stprogra  OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol  OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic  OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic  OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
/* .............................................................................
   Programa: pc_crps661 (Fontes/crps661.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Outubro/2013                     Ultima atualizacao: 24/06/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gera relatorio de emprestimos prefixados em atraso.

   Alteracoes: 26/11/2013 - Desconsiderar da tabela CRAPCYB valor a regulariazar zerado.
                            (Irlan)

               02/12/2013 - Conversão Progress >> PLSQL (Petter-Supero)

               21/01/2014 - Ajustada forma de emissao do relatorio >> PLSQL (Odirlei-AMcom)

               24/06/2014 - Adicionar totais para a quantidade de contratos, saldo devedor,
                            prestação e saldo a regularizar (Douglas - Chamado 158082)
                            
               10/06/2015 - Realizar ajustes no controle do tamanho do XML, para evitar o
                            estouro no tamanho do buffer. (Renato - Supero)
............................................................................ */

DECLARE
  ------------------------ ESTRUTURA PL TABLE ------------------------------
  -- Estrutura da PL Table
  TYPE typ_reg_cyber IS
    RECORD(cdcooper crapass.cdcooper%TYPE
          ,cdagenci crapass.cdagenci%TYPE
          ,nrdconta crapass.nrdconta%TYPE
          ,nmprimtl crapass.nmprimtl%TYPE
          ,nrtelefo craptfc.nrtelefo%TYPE
          ,nrctremp crapcyb.nrctremp%TYPE
          ,qtdiaatr crapcyb.qtdiaatr%TYPE
          ,vlsdeved crapcyb.vlsdeved%TYPE
          ,vlpreemp crapcyb.vlpreemp%TYPE
          ,vlpreapg crapcyb.vlpreapg%TYPE);
  TYPE typ_tab_cyber IS TABLE OF typ_reg_cyber INDEX BY VARCHAR2(100);

  -- Estrutura da PL Table para CRAPASS
  TYPE typ_reg_crapass IS
    RECORD(nrdconta crapass.nrdconta%TYPE
          ,cdagenci crapass.cdagenci%TYPE
          ,cdcooper crapass.cdcooper%TYPE
          ,nmprimtl crapass.nmprimtl%TYPE);
  TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(100);

  -- Estrutura da PL Table para CRAPTFC
  TYPE typ_reg_craptfc IS
    RECORD(nrdconta craptfc.nrdconta%TYPE
          ,tptelefo craptfc.tptelefo%TYPE
          ,nrtelefo craptfc.nrtelefo%TYPE);
  TYPE typ_tab_craptfc IS TABLE OF typ_reg_craptfc INDEX BY VARCHAR(100);

  -- Estrutura da PL Table para CRAPAGE
  TYPE typ_reg_crapage IS
    RECORD(cdagenci crapage.cdagenci%TYPE
          ,nmresage crapage.nmresage%TYPE);
  TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY VARCHAR2(100);

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS661';  --> Nome do relatório
  vr_nrtelefo     craptfc.nrtelefo%TYPE;                        --> Número tela
  vr_contador     PLS_INTEGER := 1;                             --> Contador de controle
  vr_contapl      PLS_INTEGER := 1;                             --> Contador para índice da PL Table
  vr_nmarquiv     VARCHAR2(4000);                               --> Nome do arquivo
  vr_rel_dsagenci VARCHAR2(400);                                --> Nome da agência
  vr_tab_cyber    typ_tab_cyber;                                --> Declaração de PL Table
  vr_tab_crapass  typ_tab_crapass;                              --> Declaração de PL Table
  vr_tab_craptfc  typ_tab_craptfc;                              --> Declaração de PL Table
  vr_tab_crapage  typ_tab_crapage;                              --> Declaração de PL Table
  vr_index        VARCHAR2(400);                                --> Índice genérico para PL Table
  vr_conta        PLS_INTEGER;                                  --> Contador padrão para PL Table
  vr_xml          CLOB;                                         --> CLOB para XML dedados
  vr_bxml         VARCHAR2(32767);                              --> Buffer para XML de dados
  vr_nom_dir      VARCHAR2(400);                                --> Diretório do relatório
  vr_nrcopias     PLS_INTEGER := 1;                             --> Número de impressões em cópia
  vr_nmformul     VARCHAR2(40) := '';                           --> Nome do formulário

  -- Totalizadores
  vr_qtd_ctratos   PLS_INTEGER;                                 --> Quantidade de Contratos
  vr_tot_saldo_dev NUMBER(25,2);                                --> Total de Saldo Devedor
  vr_tot_prestacao NUMBER(25,2);                                --> Total de Prestação
  vr_tot_saldo_reg NUMBER(25,2);                                --> Total de Saldo a Regularizar

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;                                      --> Controle de saída de erros
  vr_exc_fimprg EXCEPTION;                                      --> Controle para fim do procedimento
  vr_cdcritic   PLS_INTEGER;                                    --> Código da crítica
  vr_dscritic   VARCHAR2(4000);                                 --> Descrição da crítica

  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  -- Buscar dados de contratos que estao em cobranca no sistema CYBER
  CURSOR cr_cycer(pr_cdcooper crapcyb.cdcooper%TYPE) IS  --> Código da cooperativa
    SELECT cy.nrctremp
          ,cy.qtdiaatr
          ,cy.vlsdeved
          ,cy.vlpreemp
          ,cy.vlpreapg
          ,ce.cdcooper
          ,ce.nrdconta
    FROM crapcyb cy, crapepr ce
    WHERE cy.cdcooper = pr_cdcooper
      AND (cy.cdorigem = 2 OR cy.cdorigem = 3)
      AND cy.dtdbaixa IS NULL
      AND cy.vlpreapg > 0
      AND cy.flgpreju = 0
      AND ce.cdcooper = cy.cdcooper
      AND ce.nrdconta = cy.nrdconta
      AND ce.nrctremp = cy.nrctremp
      AND ce.tpemprst = 1
      AND ce.inliquid = 0;

    -- Buscar dados de associados
    CURSOR cr_crapass(pr_cdcooper crapcyb.cdcooper%TYPE) IS  --> Código da cooperativa
      SELECT ca.nrdconta
            ,ca.cdagenci
            ,ca.cdcooper
            ,ca.nmprimtl
      FROM crapass ca
      WHERE ca.cdcooper = pr_cdcooper;

    -- Buscar dados do cadastro de telefone dos associados titulares
    CURSOR cr_craptfc(pr_cdcooper craptfc.cdcooper%TYPE) IS  --> Código da cooperativa
      SELECT * FROM(
        SELECT cf.nrdconta
              ,cf.tptelefo
              ,cf.nrtelefo
              ,row_number() over(partition by CDCOOPER, NRDCONTA order by cf.tptelefo, CDCOOPER, NRDCONTA, IDSEQTTL, CDSEQTFC) nrseq
        FROM craptfc cf
        WHERE cf.cdcooper = pr_cdcooper
          AND cf.idseqttl = 1) TT
        WHERE TT.NRSEQ = 1 ;

    -- Buscar dados de cadastro dos PA´s
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE) IS  --> Código da cooperativa
      SELECT cg.cdagenci
            ,cg.nmresage
      FROM crapage cg
      WHERE cg.cdcooper = pr_cdcooper;

  BEGIN
    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => null);

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper, pr_nmsubdir => '/rl');

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;

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
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

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
    -- Carregar PL Table CRAPASS
    FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
      vr_tab_crapass(LPAD(rw_crapass.nrdconta, 20, '0')).nrdconta := rw_crapass.nrdconta;
      vr_tab_crapass(LPAD(rw_crapass.nrdconta, 20, '0')).cdagenci := rw_crapass.cdagenci;
      vr_tab_crapass(LPAD(rw_crapass.nrdconta, 20, '0')).cdcooper := rw_crapass.cdcooper;
      vr_tab_crapass(LPAD(rw_crapass.nrdconta, 20, '0')).nmprimtl := rw_crapass.nmprimtl;
    END LOOP;

    -- Carregar PL Table CRAPTFC
    vr_conta := 0;
    FOR rw_craptfc IN cr_craptfc(pr_cdcooper) LOOP
      -- Gerar índice

      vr_index :=  LPAD(rw_craptfc.nrdconta, 15, '0');
      vr_tab_craptfc(vr_index).nrdconta := rw_craptfc.nrdconta;
      vr_tab_craptfc(vr_index).tptelefo := rw_craptfc.tptelefo;
      vr_tab_craptfc(vr_index).nrtelefo := rw_craptfc.nrtelefo;
    END LOOP;

    -- Carregar PL Table CRAPAGE
    FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
      vr_tab_crapage(LPAD(rw_crapage.cdagenci, 10, '0')).cdagenci := rw_crapage.cdagenci;
      vr_tab_crapage(LPAD(rw_crapage.cdagenci, 10, '0')).nmresage := rw_crapage.nmresage;
    END LOOP;

    -- Contratos que estao em cobranca no sistema CYBER
    FOR rw_cycer IN cr_cycer(pr_cdcooper) LOOP

      -- Verifica se existe registro de associado
      IF NOT vr_tab_crapass.exists(LPAD(rw_cycer.nrdconta, 20, '0')) THEN
        vr_cdcritic := 9;
        RAISE vr_exc_fimprg;
      END IF;

      -- Inicializar variável
      vr_nrtelefo := 0;

      -- Verifica se existe registro de telefones
      IF vr_tab_craptfc.exists(LPAD(vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).nrdconta, 15, '0')) THEN
        vr_nrtelefo := vr_tab_craptfc(LPAD(vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).nrdconta, 15, '0')).nrtelefo;
      END IF;

      -- Gerar registro da PL Table de dados
      vr_index := LPAD(vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).cdcooper, 3, '0') ||
                  LPAD(vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).cdagenci, 5, '0') ||
                  LPAD(vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).nrdconta, 20, '0') ||
                  LPAD(vr_contapl, 25, '0');
      vr_tab_cyber(vr_index).cdcooper := vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).cdcooper;
      vr_tab_cyber(vr_index).cdagenci := vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).cdagenci;
      vr_tab_cyber(vr_index).nrdconta := vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).nrdconta;
      vr_tab_cyber(vr_index).nmprimtl := vr_tab_crapass(LPAD(rw_cycer.nrdconta, 20, '0')).nmprimtl;
      vr_tab_cyber(vr_index).nrtelefo := vr_nrtelefo;
      vr_tab_cyber(vr_index).nrctremp := rw_cycer.nrctremp;
      vr_tab_cyber(vr_index).qtdiaatr := rw_cycer.qtdiaatr;
      vr_tab_cyber(vr_index).vlsdeved := rw_cycer.vlsdeved;
      vr_tab_cyber(vr_index).vlpreemp := rw_cycer.vlpreemp;
      vr_tab_cyber(vr_index).vlpreapg := rw_cycer.vlpreapg;

      -- Gerar contador
      vr_contapl := vr_contapl + 1;
    END LOOP;

    -- Verificar se existem informações a serem geradas
    IF vr_tab_cyber.COUNT > 0 THEN

      -- Gerar dados para o relatório
      vr_index := vr_tab_cyber.first;
      LOOP

        -- Controla geração de relatório
        -- Deve gerar se for o ultimo registro ou a agencia mudou
        IF vr_index IS NULL OR
           ( vr_tab_cyber.prior(vr_index) IS NOT NULL AND
             vr_tab_cyber(vr_index).cdagenci <> vr_tab_cyber(vr_tab_cyber.prior(vr_index)).cdagenci) THEN
          -- A cada concatenação verificar o tamanho do variável, afim de evitar estouros de buffer
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
          -- Adicionar o totalizador com as informações de quantidade de contratos, saldo devedor, prestações e saldo a regularizar
          vr_bxml := vr_bxml || '<totais>';
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
          vr_bxml := vr_bxml || '  <qtd_contrato>' || vr_qtd_ctratos || '</qtd_contrato>';
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
          vr_bxml := vr_bxml || '  <saldo_dev>' || to_char(vr_tot_saldo_dev, 'FM999G999G999G999G990D00') || '</saldo_dev>';
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
          vr_bxml := vr_bxml || '  <prestacao>' || to_char(vr_tot_prestacao, 'FM999G999G999G999G990D00') || '</prestacao>';
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
          vr_bxml := vr_bxml || '  <saldo_reg>' || to_char(vr_tot_saldo_reg, 'FM999G999G999G999G990D00') || '</saldo_reg>';
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
          vr_bxml := vr_bxml || '</totais>';
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
          
          -- Fechar escrita do XML
          vr_bxml := vr_bxml || '</agencia></base>';
          gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => TRUE, pr_clob => vr_xml);

          -- Gerar relatório
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                     ,pr_cdprogra  => vr_cdprogra
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                     ,pr_dsxml     => vr_xml
                                     ,pr_dsxmlnode => '/base/agencia'
                                     ,pr_dsjasper  => 'crrl668.jasper'
                                     ,pr_dsparams  => ''
                                     ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarquiv
                                     ,pr_flg_gerar => 'N'
                                     ,pr_qtcoluna  => 132
                                     ,pr_sqcabrel  => 1
                                     ,pr_cdrelato  => '668' --> Codigo do relatorio, pois na tabela crapprg o valor está nulo
                                     ,pr_flg_impri => 'N'
                                     ,pr_nmformul  => vr_nmformul
                                     ,pr_nrcopias  => vr_nrcopias
                                     ,pr_dspathcop => NULL
                                     ,pr_dsmailcop => NULL
                                     ,pr_dsassmail => NULL
                                     ,pr_dscormail => NULL
                                     ,pr_flsemqueb => 'N'
                                     ,pr_des_erro  => pr_dscritic);

          --limpar variaveis
          vr_bxml := NULL;
          vr_qtd_ctratos := 0;
          vr_tot_saldo_dev := 0;
          vr_tot_prestacao := 0;
          vr_tot_saldo_reg := 0;

          -- Limpar XML
          dbms_lob.close(vr_xml);
          dbms_lob.freetemporary(vr_xml);

          -- Sair da iteração do LOOP se não houver mais index
          IF vr_index IS NULL THEN
            EXIT;
          END IF;

        END IF;

        -- Verifica se é o primeiro registro da agencia
        --se for o primeiro registro ou a agencia mudou, deve gerar as informações iniciais para o relatorio
        IF vr_tab_cyber.prior(vr_index) IS NULL OR vr_tab_cyber(vr_index).cdagenci <> vr_tab_cyber(vr_tab_cyber.prior(vr_index)).cdagenci THEN
          -- Gerar nodo de dados do PA

          -- Inicializar XML
          dbms_lob.createtemporary(vr_xml, TRUE);
          dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

          -- Início do XML
          vr_bxml := '<?xml version="1.0" encoding="utf-8"?><base>';

          -- Gerar nome do relatório
          vr_nmarquiv := 'crrl668_' || LPAD(vr_tab_cyber(vr_index).cdagenci, 3, '0') || '.lst';

          -- Vefiricar nome do PA
          IF vr_tab_crapage.exists(LPAD(vr_tab_cyber(vr_index).cdagenci, 10, '0')) THEN
            vr_rel_dsagenci := vr_tab_cyber(vr_index).cdagenci || ' - ' || vr_tab_crapage(LPAD(vr_tab_cyber(vr_index).cdagenci, 10, '0')).nmresage;
          ELSE
            vr_rel_dsagenci := ' - PA NAO CADASTRADO';
          END IF;

          -- Gerar nodo de dados do PA
          vr_bxml := vr_bxml || '<agencia><descricao>' || vr_rel_dsagenci || '</descricao>';
        END IF;

        -- Gerar corpo do XML
        vr_bxml := vr_bxml || '<correntista><nrdconta>' || to_char(vr_tab_cyber(vr_index).nrdconta, 'FM9999G999G9') || '</nrdconta>';
        vr_bxml := vr_bxml || '<nmprimtl>' || vr_tab_cyber(vr_index).nmprimtl || '</nmprimtl>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
        vr_bxml := vr_bxml || '<nrtelefo>' || vr_tab_cyber(vr_index).nrtelefo || '</nrtelefo>';
        vr_bxml := vr_bxml || '<nrctremp>' || to_char(vr_tab_cyber(vr_index).nrctremp, 'FM999G999G999G999') || '</nrctremp>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
        vr_bxml := vr_bxml || '<qtdiaatr>' || vr_tab_cyber(vr_index).qtdiaatr || '</qtdiaatr>';
        vr_bxml := vr_bxml || '<vlsdeved>' || to_char(vr_tab_cyber(vr_index).vlsdeved, 'FM999G999G999G999G990D00') || '</vlsdeved>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);
        vr_bxml := vr_bxml || '<vlpreemp>' || to_char(vr_tab_cyber(vr_index).vlpreemp, 'FM999G999G999G999G990D00') || '</vlpreemp>';
        vr_bxml := vr_bxml || '<vlpreapg>' || to_char(vr_tab_cyber(vr_index).vlpreapg, 'FM999G999G999G999G990D00') || '</vlpreapg></correntista>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_xml);

        -- Atualizamos os totalizadores
        vr_qtd_ctratos := NVL(vr_qtd_ctratos,0) + 1;
        vr_tot_saldo_dev := NVL(vr_tot_saldo_dev,0) + vr_tab_cyber(vr_index).vlsdeved;
        vr_tot_prestacao := NVL(vr_tot_prestacao,0) + vr_tab_cyber(vr_index).vlpreemp;
        vr_tot_saldo_reg := NVL(vr_tot_saldo_reg,0) + vr_tab_cyber(vr_index).vlpreapg;

        -- Buscar próximo índice
        vr_index := vr_tab_cyber.next(vr_index);

      END LOOP;


    END IF;

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
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );

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
END pc_crps661;
/

