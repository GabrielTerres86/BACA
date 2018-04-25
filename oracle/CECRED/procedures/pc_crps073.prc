CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps073 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* .............................................................................

   Programa: pc_crps073 (Fontes/crps073.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/93.                        Ultima atualizacao: 09/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 039
               Emitir resumo dos historicos por agencia (62) e resumo geral
               da compensacao das contas convenio (79).

   Alteracoes: 09/06/94 - Alterado para emitir um resumo por conta convenio do
                          Banco do Brasil com a quantidade e valor compensado
                          no mes de referencia (Edson).

               28/09/94 - Na selecao dos lancamentos foi substuido o cdpesqbb
                          pelo nrdolote (Edson).

               04/11/94 - Alterado para incluir  a  leitura  do  craplct  e  do
                          craplem acumulando na tabela e listando de historicos
                          e listar os totais de lancamento (Odair).

               07/12/95 - Dar o mesmo tratento do tipo de conta 5 para o tipo de
                          conta 6 (Odair).

               12/11/97 - Na leitura de lotes de compensacao (faixa 7000), sele-
                          cionar apenas hist. 50,56,59 e retirar faixa dos
                          7000 do lote (Odair)

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               11/09/98 - Tratar tipo de conta 7 (Deborah).

               07/07/99 - Listar total de contas BANCOOB (Odair)

               31/08/99 - Mostrar cheques devolvidos por Convenio (Odair)

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               21/07/2000 - Tratar historico 358 (Deborah).

               05/07/2001 - Duas vias no relatorio (Deborah).

               05/03/2002 - Incluir indice de devolucao do Banco do Brasil,
                            Bancoob e total no relatorio 79 (Junior).

               23/05/2002 - incluir indice de devolucao por PAC (Deborah).

               27/03/2003 - Adicionar alinea 156 (Junior).

               11/04/2003 - Adicionar Caixa Economica - Concredi (Ze Eduardo).

               22/11/2004 - Incluido TOTAIS ao final do Resumo das devolucoes
                            por PAC (Evandro).

               24/11/2004 - Tirada a flag de fim de solicitacao glb_infimsol
                            (Evandro).

               17/02/2005 - Incluidos tipos de conta Integracao(12/13/14/15)
                                                           (Mirtes).

               15/03/2005 - Na listagem por PAC, alterado para exibir se houver
                            qualquer valor (Evandro).

               07/06/2005 - Incluidos tipos de conta Integracao(17/18)(Mirtes)

               10/08/2005 - Efetuado acerto calculo(campo tot_perceger)(Mirtes)

               14/09/2005 - Efetuado acerto calculo(campo tot_percbbra)(Diego).

               23/12/2005 - Tratamento para Conta Integracao (Ze).

               24/01/2006 - Listar conta integracao (Edson).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               21/02/2006 - Alterado para imprimir 1 via(crrl079) (Diego).

               24/09/2007 - Acertado calculo dos campos tot_percbcob e
                            tot_perccaix referente a porcentagem de devolucao
                            dos cheques do bancoob e da caixa (Elton).

               14/11/2007 - Substituidas algumas variaveis EXTENT por campos
                            em TEMP-TABLE (Diego).

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).

               15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).
                          - Aumentado formato dos totais dos historicos
                            (Gabriel).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               30/07/2010 - Alteracao do relat Dev. Efetuada por Alinea de CEF
                            para Cecred e inclusao do Resumo Mensal Compensacao
                            para Cecred. (Guilherme/Supero)

               13/09/2010 - Acerto no Relatorio (Ze).

               15/09/2010 - Incluir o cdcooper no for each do ass
                            para melhorar o desempenho (Gabriel).

               30/05/2011 - Incluir o historico 573 (Ze).

               08/06/2011 - Acerto nas devolucoes por alinea (Magui).

               12/09/2012 - Incluir o historico 521 (Ze).

               15/08/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               10/03/2014 - Conversao Progress -> Oracle - Andrino (RKAM)

               09/02/2015 - Ajustando contador para 999 para considerar
                            os PA's com 3 digitos - SD 251855.
                            (Andre Santos - SUPERO)

               05/03/2018 - Alterada a verificação para identificar o calculo do acumulador de
                            correntista ou de conta salário atraves da modalidade do tipo de conta.
                            PRJ366 (Lombardi).

............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS073';

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

      -- Cursor para busca dos historicos de lancamentos
      CURSOR cr_craphis IS
        SELECT cdhistor,
               dshistor,
               indebcre
          FROM craphis
         WHERE cdcooper = pr_cdcooper;

      -- Cursor para busca dos tipos de conta
      CURSOR cr_tipcta IS
        SELECT inpessoa
              ,cdtipo_conta cdtipcta
              ,cdmodalidade_tipo cdmodali
          FROM tbcc_tipo_conta;

      -- Cursor sobre os dados dos associados
      CURSOR cr_crapass IS
        SELECT cdagenci,
               nrdconta,
               cdtipcta,
               inpessoa,
               nrdctitg,
               row_number() over(partition by cdagenci order by cdagenci) regagenci,
               count(1)     over(partition by cdagenci order by cdagenci) qtdagenci
          FROM crapass
         WHERE cdcooper = pr_cdcooper
         ORDER BY cdagenci,
                  nrdconta;

      -- Cursor sobre o cadastro de agencia
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;

      -- Busca os lancamentos de deposito a vista
      CURSOR cr_craplcm(pr_nrdconta craplcm.nrdconta%TYPE,
                        pr_dtliminf DATE,
                        pr_dtlimsup DATE) IS
        SELECT cdhistor,
               vllanmto,
               nrdctabb,
               cdbanchq,
               cdpesqbb
          FROM craplcm
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtmvtolt > pr_dtliminf
           AND dtmvtolt < pr_dtlimsup
         ORDER BY nrdconta, dtmvtolt, cdhistor, nrdocmto;

      -- Busca os lancamentos de cotas / capital
      CURSOR cr_craplct(pr_nrdconta craplcm.nrdconta%TYPE,
                        pr_dtliminf DATE,
                        pr_dtlimsup DATE) IS
        SELECT cdhistor,
               vllanmto
          FROM craplct
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtmvtolt > pr_dtliminf
           AND dtmvtolt < pr_dtlimsup;

      -- Busca os lancamentos em emprestimos
      CURSOR cr_craplem(pr_nrdconta craplcm.nrdconta%TYPE,
                        pr_dtliminf DATE,
                        pr_dtlimsup DATE) IS
        SELECT cdhistor,
               vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtmvtolt > pr_dtliminf
           AND dtmvtolt < pr_dtlimsup;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- Definicao do tipo de tabela para os historicos de lancamentos
      TYPE typ_reg_craphis IS
        RECORD(cdhistor craphis.cdhistor%TYPE,
               dshistor VARCHAR2(60),
               indebcre craphis.indebcre%TYPE);
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
        INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados para o processo definitivo
      vr_tab_craphis typ_tab_craphis;

      -- Definicao do tipo de tabela para os tipos de conta
      TYPE typ_reg_tipcta IS
        RECORD(cdmodali tbcc_tipo_conta.cdmodalidade_tipo%TYPE);        
      TYPE typ_tab_tipcta_2 IS
        TABLE OF typ_reg_tipcta
        INDEX BY PLS_INTEGER;        
       TYPE typ_tab_tipcta IS
        TABLE OF typ_tab_tipcta_2
        INDEX BY PLS_INTEGER;          
      -- Vetor para armazenar os dados para o processo definitivo
      vr_tab_tipcta typ_tab_tipcta;
      
      -- Substituidas variaveis por campos na Temp-Table
      TYPE typ_reg_extent IS
        RECORD(cdhistor     craphis.cdhistor%TYPE,
               tab_qtlancom PLS_INTEGER,
               tab_vllancom NUMBER(17,2),
               age_qtlancto PLS_INTEGER,
               age_vlcompdb NUMBER(17,2),
               age_vlcompcr NUMBER(17,2),
               ger_qtlancto PLS_INTEGER,
               ger_vlcompdb NUMBER(17,2),
               ger_vlcompcr NUMBER(17,2));
      TYPE typ_tab_extent IS
        TABLE OF typ_reg_extent
        INDEX BY PLS_INTEGER;
      vr_tab_extent typ_tab_extent;

      -- Tipo para as variaveis de quantidade inteiras
      TYPE typ_inteiro IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;

      -- Tipo para as variaveis de valores
      TYPE typ_valores IS TABLE OF NUMBER(17,2) INDEX BY BINARY_INTEGER;


      ------------------------------- VARIAVEIS -------------------------------
      vr_texto_completo VARCHAR2(32600);         --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml    CLOB;                        --> XML do relatorio
      vr_nom_direto VARCHAR2(100);               --> Nome do diretorio para a geracao do arquivo de saida
      vr_lscontas    VARCHAR2(4000);             --> tabela com as contas convenio do Banco do Brasil
      vr_lscontas4   VARCHAR2(4000);             --> tabela com as contas convenio INTEGRACAO do Banco do Brasil
      vr_dtliminf    DATE;                       --> Data limite inferior da referencia
      vr_dtlimsup    DATE;                       --> Data limite superior da referencia
      vr_nrindice    PLS_INTEGER;                --> Indice para busca das contas
      vr_dsdctitg    VARCHAR2(10);               --> Numero da conta de integracao
      vr_stsnrcal    INTEGER;                    --> Indicador de digito valido
      vr_ind         PLS_INTEGER;                --> Indice para a temp-table vr_tab_craphis
      vr_ind_aux     PLS_INTEGER;                --> Indice para a temp_table vr_tab_lscontas
      vr_qtlancbb    PLS_INTEGER;                --> Quantidade compensada do Banco do Brasil
      vr_qtlancbc    PLS_INTEGER;                --> Quantidade compensada do Bacoob
      vr_qtlancrd    PLS_INTEGER;                --> Quantidade compensada da Cecred
      vr_pcbrasil    NUMBER(6,2);                --> Percentual do indide de devolucao do Banco do Brasil
      vr_pcbancob    NUMBER(6,2);                --> Percentual do indide de devolucao do Bancoob
      vr_pccecred    NUMBER(6,2);                --> Percentual do indide de devolucao da Cecred
      vr_pcdevolu    NUMBER(6,2);                --> Percentual do indide de devolucao total
      vr_flginfor    BOOLEAN := FALSE;           --> Flag de existencia de dados de historico por agencia


      -- Variaveis do relatorio
      vr_rel_nmmesref  VARCHAR2(50);             --> Mes por extenso e ano de referencia
      vr_rel_dsagenci  VARCHAR2(100);            --> Codigo e nome da agencia
      vr_rel_qtbancob  PLS_INTEGER;              --> Quantidade de lancamentos do Bancoob
      vr_rel_vlbancob  NUMBER(17,2);             --> Total compensando do Bancoob
      vr_rel_qtcecred  PLS_INTEGER;              --> Quantidade de lancamentos da Cecred
      vr_rel_vlcecred  NUMBER(17,2);             --> Total compensando da Cecred
      vr_rel_nrdctabb  VARCHAR2(10);             --> Numero da conta integracao
      vr_rel_qtlancom  PLS_INTEGER;              --> Quantidade de lancamentos
      vr_rel_vllancom  NUMBER(17,2);             --> Total compensado
      vr_rel_vlmedcom  NUMBER(17,2);             --> Valor medio compensado
      vr_age_pcbrasil  NUMBER(06,2);             --> Percentual de devolucao do Banco do Brasil
      vr_age_pcbancob  NUMBER(06,2);             --> Percentual de devolucao do Bancoob
      vr_age_pccecred  NUMBER(06,2);             --> Percentual de devolucao da Cecred


      -- Variaveis totalizadoras
      vr_age_qtcorren  PLS_INTEGER;              --> Total de correntistas na agencia
      vr_age_qtchqsal  PLS_INTEGER;              --> Total de cheques salarios na agencia
      vr_age_qtassoci  PLS_INTEGER;              --> Total de associados
      vr_tot_qtlancto  PLS_INTEGER;              --> Quantidade de lancamentos
      vr_tot_vlcompdb  NUMBER(17,2);             --> Valor total de debito
      vr_tot_vlcompcr  NUMBER(17,2);             --> Valor total de credito
      vr_ger_qtcorren  PLS_INTEGER;              --> Quantidade de correntistas
      vr_ger_qtchqsal  PLS_INTEGER;              --> Quantidade de contas do tipo cheque-salario
      vr_ger_qtassoci  PLS_INTEGER;              --> Quantidade de associados
      vr_tot_vlmedcom  NUMBER(17,2);             --> Valor medio compensado
      vr_tot_qtdevolu  PLS_INTEGER;              --> Quantidade total de devolucao
      vr_tot_vldevolu  PLS_INTEGER;              --> Valor total de devolucao
      vr_tot_compbbra  PLS_INTEGER;              --> Quantidade total compensada do Banco do Brasil
      vr_tot_compbcob  PLS_INTEGER;              --> Quantidade total compensada do Bancoob
      vr_tot_compccrd  PLS_INTEGER;              --> Quantidade total compensada da Cecred
      vr_tot_compeger  PLS_INTEGER;              --> Quantidade total compensada
      vr_tot_devobbra  PLS_INTEGER;              --> Quantidade total devolvida do Banco do Brasil
      vr_tot_devobcob  PLS_INTEGER;              --> Quantidade total devolvida do Bancoob
      vr_tot_devoccrd  PLS_INTEGER;              --> Quantidade total devolvida da Cecred
      vr_tot_devolger  PLS_INTEGER;              --> Quantidade total devolvida
      vr_tot_percbbra  NUMBER(6,2);              --> Pencentual total de devolucao do Banco do Brasil
      vr_tot_percbcob  NUMBER(6,2);              --> Pencentual total de devolucao do Bancoob
      vr_tot_percccrd  NUMBER(6,2);              --> Pencentual total de devolucao da Cecred
      vr_tot_perceger  NUMBER(6,2);              --> Pencentual total de devolucao
      vr_tot_qtcompen  PLS_INTEGER;              --> Quantidade total compensada
      vr_tot_pcdevolu  NUMBER(06,2);             --> Percentual de devolucao geral

      -- Variaveis com vetores
      vr_dev_vlbancob typ_valores;               --> Valor compensando do Bancoob por Alinea
      vr_dev_qtbancob typ_inteiro;               --> Quantidade compensanda do Bancoob por Alinea
      vr_dev_vlbrasil typ_valores;               --> Valor compensando do Banco do Brasil por Alinea
      vr_dev_qtbrasil typ_inteiro;               --> Quantidade compensanda do Banco do Brasil por Alinea
      vr_dev_vlcecred typ_valores;               --> Valor compensando da Cecred por Alinea
      vr_dev_qtcecred typ_inteiro;               --> Quantidade compensanda da Cecred por Alinea
      vr_age_vlbancob typ_valores;               --> Valor compensando do Bancoob
      vr_age_qtbancob typ_inteiro;               --> Quantidade devolvida do Bancoob por PA
      vr_age_vlbrasil typ_valores;               --> Valor compensando do Banco do Brasil
      vr_age_qtbrasil typ_inteiro;               --> Quantidade devolvida do Banco do Brasil  por PA
      vr_age_vlcecred typ_valores;               --> Valor compensando da Cecred
      vr_age_qtcecred typ_inteiro;               --> Quantidade devolvida da Cecred  por PA
      vr_cmp_qtlancbb typ_inteiro;               --> Quantidade compensada do Banco do Brasil por PA
      vr_cmp_qtlancbc typ_inteiro;               --> Quantidade compensada do Bacoob por PA
      vr_cmp_qtlancrd typ_inteiro;               --> Quantidade compensada da Cecred por PA
      vr_tab_lscontas gene0002.typ_split;        --> Tabela com as contas convenio do Banco do Brasil
      vr_tab_lscontas4 gene0002.typ_split;       --> Tabela com as contas convenio INTEGRACAO do Banco do Brasil





      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

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
      /*  Le tabela com as contas convenio do Banco do Brasil  */
      vr_lscontas := gene0005.fn_busca_conta_centralizadora(pr_cdcooper => pr_cdcooper,
                                                                  pr_tpregist => 0);
      IF vr_lscontas IS NULL THEN
        vr_cdcritic := 393;
        RAISE vr_exc_saida;
      END IF;
      -- Joga as contas em uma temp-table
      vr_tab_lscontas := gene0002.fn_quebra_string(vr_lscontas,',');

      /*  Le tabela com as contas convenio INTEGRACAO do Banco do Brasil  */
      vr_lscontas4 := gene0005.fn_busca_conta_centralizadora(pr_cdcooper => pr_cdcooper,
                                                             pr_tpregist => 4);
      IF vr_lscontas4 IS NULL THEN
        vr_cdcritic := 393;
        RAISE vr_exc_saida;
      END IF;
      -- Joga as contas em uma temp-table
      vr_tab_lscontas4 := gene0002.fn_quebra_string(vr_lscontas4,',');


      /*  Carrega tabela de historicos  */
      FOR rw_craphis IN cr_craphis LOOP
        vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).dshistor := to_char(rw_craphis.cdhistor,'fm0000')||
                                                        ' - ' || rw_craphis.dshistor;
        vr_tab_craphis(rw_craphis.cdhistor).indebcre := rw_craphis.indebcre;
      END LOOP; /*  Fim do LOOP -- Carga da tabela de historicos  */

      /*  Carrega tabela de tipos de conta  */
      FOR rw_tipcta IN cr_tipcta LOOP
        vr_tab_tipcta(rw_tipcta.inpessoa)(rw_tipcta.cdtipcta).cdmodali := rw_tipcta.cdmodali;
      END LOOP; /*  Fim do LOOP -- Carga da tabela de tipos de conta  */
      
      -- Inicializa com zeros os vetores
      FOR ind IN 1..1000 LOOP
        vr_dev_vlbancob(ind) := 0;
        vr_dev_qtbancob(ind) := 0;
        vr_dev_vlbrasil(ind) := 0;
        vr_dev_qtbrasil(ind) := 0;
        vr_dev_vlcecred(ind) := 0;
        vr_dev_qtcecred(ind) := 0;
        vr_age_vlbancob(ind) := 0;
        vr_age_qtbancob(ind) := 0;
        vr_age_vlbrasil(ind) := 0;
        vr_age_qtbrasil(ind) := 0;
        vr_age_vlcecred(ind) := 0;
        vr_age_qtcecred(ind) := 0;
        vr_cmp_qtlancbb(ind) := 0;
        vr_cmp_qtlancbc(ind) := 0;
        vr_cmp_qtlancrd(ind) := 0;
      END LOOP;


      -- Data limite inferior. Sera o ultimo dia de dois meses anteriores ao movimento atual.
      vr_dtliminf := rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt,'DD');
      vr_dtliminf := vr_dtliminf - to_char(vr_dtliminf,'DD');

      -- Data limite superior. Sera o primeiro dia do mes da data do movimento atual
      vr_dtlimsup := trunc(rw_crapdat.dtmvtolt,'MM');

      vr_rel_nmmesref := trim(upper(to_char(vr_dtliminf+1,'Month','nls_date_language =''brazilian portuguese'''))) || '/'||
                      to_char(vr_dtliminf + 1,'YYYY'); -- Mes em portugues / Ano da data de referencia

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                          '<?xml version="1.0" encoding="utf-8"?><crrl062>'||
                            '<nmmesref>'||vr_rel_nmmesref||'</nmmesref>');

      -- Efetua um loop sobre os associados
      FOR rw_crapass IN cr_crapass LOOP

        -- Se for o primeiro registro da agencia
        IF rw_crapass.regagenci = 1 THEN
          -- busca o nome da agencia
          OPEN cr_crapage(rw_crapass.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            vr_rel_dsagenci := to_char(rw_crapass.cdagenci,'000') || ' - ' || lpad('*',15,'*');
          ELSE
            vr_rel_dsagenci := to_char(rw_crapass.cdagenci,'fm000') || ' - ' || rw_crapage.nmresage;
          END IF;
          -- Fecha o cursor de agencias
          CLOSE cr_crapage;

          -- Abre o no do XML de agencia
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
               '<pa>'||
                 '<dsagenci>'||vr_rel_dsagenci||'</dsagenci>');

          -- Zera os totalizadores
          vr_age_qtcorren := 0;
          vr_age_qtchqsal := 0;
          vr_age_qtassoci := 0;
          vr_tot_qtlancto := 0;
          vr_tot_vlcompdb := 0;
          vr_tot_vlcompcr := 0;
        END IF; -- Final do primeiro registro da agencia

        -- Efetua o acumulador de correntista ou de conta salario
        IF vr_tab_tipcta(rw_crapass.inpessoa)(rw_crapass.cdtipcta).cdmodali = 1 THEN -- se o associado eh um correntista
          vr_age_qtcorren := nvl(vr_age_qtcorren,0) + 1;
          vr_ger_qtcorren := nvl(vr_ger_qtcorren,0) + 1;
        ELSIF vr_tab_tipcta(rw_crapass.inpessoa)(rw_crapass.cdtipcta).cdmodali IN (2,3) THEN -- Se for do tipo cheque salario
          vr_age_qtchqsal := nvl(vr_age_qtchqsal,0) + 1;
          vr_ger_qtchqsal := nvl(vr_ger_qtchqsal,0) + 1;
        END IF;

        -- Acumula o total de associados
        vr_age_qtassoci := nvl(vr_age_qtassoci,0) + 1;
        vr_ger_qtassoci := nvl(vr_ger_qtassoci,0) + 1;

        -- Efetua um loop sobre os lancamentos de deposito a vista
        FOR rw_craplcm IN cr_craplcm(rw_crapass.nrdconta, vr_dtliminf, vr_dtlimsup) LOOP

          -- Se nao existir o historico na temp-table, cria o registro de historico
          vr_tab_extent(rw_craplcm.cdhistor).cdhistor := rw_craplcm.cdhistor;

          -- De acordo com o tipo de lancamento, acumula nas variaveis totalizadoras
          IF vr_tab_craphis(rw_craplcm.cdhistor).indebcre = 'D'   THEN -- Se for Debito
            vr_tab_extent(rw_craplcm.cdhistor).age_vlcompdb := nvl(vr_tab_extent(rw_craplcm.cdhistor).age_vlcompdb,0) +
                                                               rw_craplcm.vllanmto;
            vr_tab_extent(rw_craplcm.cdhistor).ger_vlcompdb := nvl(vr_tab_extent(rw_craplcm.cdhistor).ger_vlcompdb,0) +
                                                               rw_craplcm.vllanmto;
            vr_tot_vlcompdb := vr_tot_vlcompdb + rw_craplcm.vllanmto;
          ELSIF vr_tab_craphis(rw_craplcm.cdhistor).indebcre = 'C'   THEN -- Se for de credito
            vr_tab_extent(rw_craplcm.cdhistor).age_vlcompcr := nvl(vr_tab_extent(rw_craplcm.cdhistor).age_vlcompcr,0) +
                                                               rw_craplcm.vllanmto;
            vr_tab_extent(rw_craplcm.cdhistor).ger_vlcompcr := nvl(vr_tab_extent(rw_craplcm.cdhistor).ger_vlcompcr,0) +
                                                               rw_craplcm.vllanmto;
            vr_tot_vlcompcr := vr_tot_vlcompcr + rw_craplcm.vllanmto;
          ELSE -- Se nao for debito nem credito vai para o proximo registro
            continue;
          END IF;

          -- Acumula no total dos lancamentos
          vr_tab_extent(rw_craplcm.cdhistor).age_qtlancto := nvl(vr_tab_extent(rw_craplcm.cdhistor).age_qtlancto,0) + 1;
          vr_tab_extent(rw_craplcm.cdhistor).ger_qtlancto := nvl(vr_tab_extent(rw_craplcm.cdhistor).ger_qtlancto,0) + 1;
          vr_tot_qtlancto := vr_tot_qtlancto + 1;

          /*  Acumula dados para o resumo das contas convenio  */
          vr_nrindice := 0;
          vr_ind_aux  := vr_tab_lscontas.first;
          -- Percorre a temp-table de contas para verificar se a conta do lancamento esta inserida na mesma
          WHILE vr_ind_aux IS NOT NULL LOOP
            IF vr_tab_lscontas(vr_ind_aux) = rw_craplcm.nrdctabb THEN
              vr_nrindice := vr_ind_aux;
              EXIT;
            END IF;
            -- Vai para o proximo registro
            vr_ind_aux := vr_tab_lscontas.next(vr_ind_aux);
          END LOOP;

          IF vr_nrindice = 0 THEN
            -- retorna a conta integracão com digito convertido
            gene0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_craplcm.nrdctabb,
                                           pr_dscalcul => vr_dsdctitg,
                                           pr_stsnrcal => vr_stsnrcal,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
            -- Verifica se ocorreu erro na execucao
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Verifica se a conta integracao do usuario eh igual a calculada pela rotina acima
            IF rw_crapass.nrdctitg = vr_dsdctitg THEN
              vr_ind_aux := vr_tab_lscontas.first;
              -- Percorre a temp-table de contas para verificar se a conta do lancamento esta inserida na mesma
              WHILE vr_ind_aux IS NOT NULL LOOP
                IF vr_tab_lscontas(vr_ind_aux) = vr_tab_lscontas4(1) THEN
                  vr_nrindice := vr_ind_aux;
                  EXIT;
                END IF;
                -- Vai para o proximo registro
                vr_ind_aux := vr_tab_lscontas.next(vr_ind_aux);
              END LOOP;

              IF vr_nrindice = 0 THEN
                vr_nrindice := 9999;
              END IF;
            END IF;
          END IF;

          /*  Banco do Brasil */
          IF vr_nrindice > 0        AND  /* Bco Brasil */
            (rw_craplcm.cdhistor = 50   OR -- CHEQUE COMP.
             rw_craplcm.cdhistor = 56   OR -- CHQ.SAL.COMP
             rw_craplcm.cdhistor = 59   OR -- CHQ.TRF.COMP.
             (rw_craplcm.cdhistor = 521  AND -- CHEQUE
              rw_craplcm.cdbanchq = 1))  THEN -- Banco do Brasil

            -- Cria o indice como um historico
            vr_tab_extent(vr_nrindice).cdhistor := vr_nrindice;

            -- Acumula os valores
            vr_tab_extent(vr_nrindice).tab_qtlancom := nvl(vr_tab_extent(vr_nrindice).tab_qtlancom,0) + 1;
            vr_tab_extent(vr_nrindice).tab_vllancom := nvl(vr_tab_extent(vr_nrindice).tab_vllancom,0) +
                                                       rw_craplcm.vllanmto;
            vr_cmp_qtlancbb(rw_crapass.cdagenci) := vr_cmp_qtlancbb(rw_crapass.cdagenci) + 1;
          END IF;

          /*  bancoob  */
          IF rw_craplcm.cdhistor = 313  OR --CHEQUE COMP.
             rw_craplcm.cdhistor = 358  OR  --CHQ.SAL.COMP
            (rw_craplcm.cdhistor = 521  AND -- Cheque
             rw_craplcm.cdbanchq = 756) THEN -- Bancoob
            vr_rel_qtbancob := nvl(vr_rel_qtbancob,0) + 1;
            vr_rel_vlbancob := nvl(vr_rel_vlbancob,0) + rw_craplcm.vllanmto;
            vr_cmp_qtlancbc(rw_crapass.cdagenci) := vr_cmp_qtlancbc(rw_crapass.cdagenci) + 1;
          END IF;

          /*  Cecred  */
          IF rw_craplcm.cdhistor = 572  OR -- CHQ.TRF.COMP.
             rw_craplcm.cdhistor = 524  OR -- CHEQUE COMP.
            (rw_craplcm.cdhistor = 521  AND -- Cheque
             rw_craplcm.cdbanchq = 85)  THEN
            vr_rel_qtcecred := nvl(vr_rel_qtcecred,0) + 1;
            vr_rel_vlcecred := nvl(vr_rel_vlcecred,0) + rw_craplcm.vllanmto;
            vr_cmp_qtlancrd(rw_crapass.cdagenci) := vr_cmp_qtlancrd(rw_crapass.cdagenci) + 1;
          END IF;

          /* estatistica de cheques devolvidos por alinea */
          IF rw_craplcm.cdhistor IN (47,156,191,338,573) THEN
            IF rw_craplcm.cdbanchq = 756 THEN /* BANCOOB */
              vr_dev_vlbancob(rw_craplcm.cdpesqbb) := vr_dev_vlbancob(rw_craplcm.cdpesqbb) +
                                                      rw_craplcm.vllanmto;
              vr_age_vlbancob(rw_crapass.cdagenci) := vr_age_vlbancob(rw_crapass.cdagenci) +
                                                      rw_craplcm.vllanmto;
              vr_dev_qtbancob(rw_craplcm.cdpesqbb) := vr_dev_qtbancob(rw_craplcm.cdpesqbb) + 1;
              vr_age_qtbancob(rw_crapass.cdagenci) := vr_age_qtbancob(rw_crapass.cdagenci) + 1;
              vr_dev_vlbancob(100) := vr_dev_vlbancob(100) + rw_craplcm.vllanmto;
              vr_dev_qtbancob(100) := vr_dev_qtbancob(100) + 1;
            ELSIF rw_craplcm.cdbanchq = 85 THEN  /* CECRED */
              vr_dev_vlcecred(rw_craplcm.cdpesqbb) := vr_dev_vlcecred(rw_craplcm.cdpesqbb) + rw_craplcm.vllanmto;
              vr_age_vlcecred(rw_crapass.cdagenci) := vr_age_vlcecred(rw_crapass.cdagenci) + rw_craplcm.vllanmto;
              vr_dev_qtcecred(rw_craplcm.cdpesqbb) := vr_dev_qtcecred(rw_craplcm.cdpesqbb) + 1;
              vr_age_qtcecred(rw_crapass.cdagenci) := vr_age_qtcecred(rw_crapass.cdagenci) + 1;
              vr_dev_vlcecred(100) := vr_dev_vlcecred(100) + rw_craplcm.vllanmto;
              vr_dev_qtcecred(100) := vr_dev_qtcecred(100) + 1;
            ELSE /* BB */
              -- Ignorar registro com cdpesqbb NULL, devido a problemas no processamento do dia 02/05/2014 (Renato - Supero)
              IF TRIM(rw_craplcm.cdpesqbb) IS NOT NULL THEN
                vr_dev_vlbrasil(rw_craplcm.cdpesqbb) := vr_dev_vlbrasil(rw_craplcm.cdpesqbb) + rw_craplcm.vllanmto;
                vr_age_vlbrasil(rw_crapass.cdagenci) := vr_age_vlbrasil(rw_crapass.cdagenci) + rw_craplcm.vllanmto;
                vr_dev_qtbrasil(rw_craplcm.cdpesqbb) := vr_dev_qtbrasil(rw_craplcm.cdpesqbb) + 1;
                vr_age_qtbrasil(rw_crapass.cdagenci) := vr_age_qtbrasil(rw_crapass.cdagenci) + 1;
              END IF;
              vr_dev_vlbrasil(100) := vr_dev_vlbrasil(100) + rw_craplcm.vllanmto;
              vr_dev_qtbrasil(100) := vr_dev_qtbrasil(100) + 1;
            END IF;
          END IF; --estatistica de cheques devolvidos por alinea
        END LOOP;  /*  Fim do LOOP -- Leitura dos lancamentos  */

        -- Leitura dos lancamentos de cotas / capital
        FOR rw_craplct IN cr_craplct(rw_crapass.nrdconta, vr_dtliminf, vr_dtlimsup) LOOP

          -- Se nao existir o historico na temp-table, cria o registro de historico
          vr_tab_extent(rw_craplct.cdhistor).cdhistor := rw_craplct.cdhistor;

          -- De acordo com o tipo de lancamento, acumula nas variaveis totalizadoras
          IF vr_tab_craphis(rw_craplct.cdhistor).indebcre = 'D' THEN -- Se for um lancamento de Debito
            vr_tab_extent(rw_craplct.cdhistor).age_vlcompdb := nvl(vr_tab_extent(rw_craplct.cdhistor).age_vlcompdb,0) +
                                                               rw_craplct.vllanmto;
            vr_tab_extent(rw_craplct.cdhistor).ger_vlcompdb := nvl(vr_tab_extent(rw_craplct.cdhistor).ger_vlcompdb,0) +
                                                               rw_craplct.vllanmto;
            vr_tot_vlcompdb := vr_tot_vlcompdb + rw_craplct.vllanmto;
          ELSIF vr_tab_craphis(rw_craplct.cdhistor).indebcre = 'C' THEN -- Se for um lancamento de Credito
            vr_tab_extent(rw_craplct.cdhistor).age_vlcompcr := nvl(vr_tab_extent(rw_craplct.cdhistor).age_vlcompcr,0) +
                                                              rw_craplct.vllanmto;
            vr_tab_extent(rw_craplct.cdhistor).ger_vlcompcr := nvl(vr_tab_extent(rw_craplct.cdhistor).ger_vlcompcr,0) +
                                                              rw_craplct.vllanmto;
            vr_tot_vlcompcr := vr_tot_vlcompcr + rw_craplct.vllanmto;
          ELSE  -- Se nao for debito nem credito vai para o proximo registro
            continue;
          END IF;

          -- Acumula no total dos lancamentos
          vr_tab_extent(rw_craplct.cdhistor).age_qtlancto := nvl(vr_tab_extent(rw_craplct.cdhistor).age_qtlancto,0) + 1;
          vr_tab_extent(rw_craplct.cdhistor).ger_qtlancto := nvl(vr_tab_extent(rw_craplct.cdhistor).ger_qtlancto,0) + 1;
          vr_tot_qtlancto := vr_tot_qtlancto + 1;

        END LOOP;  /* Fim do LOOP craplct */

        -- Leitura dos lancamentos em emprestimos
        FOR rw_craplem IN cr_craplem(rw_crapass.nrdconta, vr_dtliminf, vr_dtlimsup) LOOP

          -- Se nao existir o historico na temp-table, cria o registro de historico
          vr_tab_extent(rw_craplem.cdhistor).cdhistor := rw_craplem.cdhistor;

          -- De acordo com o tipo de lancamento, acumula nas variaveis totalizadoras
          IF vr_tab_craphis(rw_craplem.cdhistor).indebcre = 'D' THEN -- Se for um lancamento de Debito
            vr_tab_extent(rw_craplem.cdhistor).age_vlcompdb := nvl(vr_tab_extent(rw_craplem.cdhistor).age_vlcompdb,0) +
                                                               rw_craplem.vllanmto;
            vr_tab_extent(rw_craplem.cdhistor).ger_vlcompdb := nvl(vr_tab_extent(rw_craplem.cdhistor).ger_vlcompdb,0) +
                                                               rw_craplem.vllanmto;
            vr_tot_vlcompdb := vr_tot_vlcompdb + rw_craplem.vllanmto;
          ELSIF vr_tab_craphis(rw_craplem.cdhistor).indebcre = 'C' THEN -- Se for um lancamento de Credito
            vr_tab_extent(rw_craplem.cdhistor).age_vlcompcr := nvl(vr_tab_extent(rw_craplem.cdhistor).age_vlcompcr,0) +
                                                              rw_craplem.vllanmto;
            vr_tab_extent(rw_craplem.cdhistor).ger_vlcompcr := nvl(vr_tab_extent(rw_craplem.cdhistor).ger_vlcompcr,0) +
                                                              rw_craplem.vllanmto;
            vr_tot_vlcompcr := vr_tot_vlcompcr + rw_craplem.vllanmto;
          ELSE  -- Se nao for debito nem credito vai para o proximo registro
            continue;
          END IF;

          -- Acumula no total dos lancamentos
          vr_tab_extent(rw_craplem.cdhistor).age_qtlancto := nvl(vr_tab_extent(rw_craplem.cdhistor).age_qtlancto,0) + 1;
          vr_tab_extent(rw_craplem.cdhistor).ger_qtlancto := nvl(vr_tab_extent(rw_craplem.cdhistor).ger_qtlancto,0) + 1;
          vr_tot_qtlancto := vr_tot_qtlancto + 1;

        END LOOP;  /* Fim do LOOP craplem */


        -- Se for o ultimo registro da agencia
        IF rw_crapass.regagenci = rw_crapass.qtdagenci THEN

          -- Inicializa variavel de existencia de informacoes
          vr_flginfor := FALSE;

          -- Busca o primeiro registro da tabela de historico
          vr_ind := vr_tab_craphis.first;

          -- Efetua um loop sobre a tabela de historico
          WHILE vr_ind IS NOT NULL LOOP

            -- Se nao existir o historico na tabela extent vai para o proximo registro
            IF NOT vr_tab_extent.exists(vr_ind) THEN
              vr_ind := vr_tab_craphis.next(vr_ind);
              continue;
            END IF;

            -- Se nao possuir lancamentos vai para o proximo registro
            IF nvl(vr_tab_extent(vr_ind).age_qtlancto,0) = 0 THEN
              vr_ind := vr_tab_craphis.next(vr_ind);
              continue;
            END IF;

            -- Atualiza flag de existencia de dados
            vr_flginfor := TRUE;

            -- Escreve a linha de detalhe
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
               '<historico>'||
                 '<dshistor>'||substr(vr_tab_craphis(vr_ind).dshistor,1,21)       	             ||'</dshistor>'||
                 '<indebcre>'||vr_tab_craphis(vr_ind).indebcre                                   ||'</indebcre>'||
                 '<qtlancto>'||to_char(vr_tab_extent(vr_ind).age_qtlancto,'fm999G999G990')       ||'</qtlancto>'||
                 '<vlcompdb>'||to_char(vr_tab_extent(vr_ind).age_vlcompdb,'fm999G999G999G990D00')||'</vlcompdb>'||
                 '<vlcompcr>'||to_char(vr_tab_extent(vr_ind).age_vlcompcr,'fm999G999G999G990D00')||'</vlcompcr>'||
               '</historico>');

            -- Zera as variaveis de totais
            vr_tab_extent(vr_ind).age_qtlancto := 0;
            vr_tab_extent(vr_ind).age_vlcompdb := NULL;
            vr_tab_extent(vr_ind).age_vlcompcr := NULL;

            -- Vai para o proximo historico
            vr_ind := vr_tab_craphis.next(vr_ind);

          END LOOP; /*  Fim do LOOP da VR_TAB_HISTORICO  */

          -- Se nao existir registro, gera o no vazio para o Ireport
          IF NOT vr_flginfor THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
               '<historico></historico>');
          END IF;

          -- Escreve os totais
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                   '<tot_qtlancto>'||to_char(vr_tot_qtlancto,'fm999G999G990')       ||'</tot_qtlancto>'||
                   '<tot_vlcompdb>'||to_char(vr_tot_vlcompdb,'fm999G999G999G990D00')||'</tot_vlcompdb>'||
                   '<tot_vlcompcr>'||to_char(vr_tot_vlcompcr,'fm999G999G999G990D00')||'</tot_vlcompcr>'||
                   '<age_qtcorren>'||to_char(vr_age_qtcorren,'fm999G999G990')       ||'</age_qtcorren>'||
                   '<age_qtchqsal>'||to_char(vr_age_qtchqsal,'fm999G999G990')       ||'</age_qtchqsal>'||
                   '<age_qtassoci>'||to_char(vr_age_qtassoci,'fm999G999G990')       ||'</age_qtassoci>'||
                '</pa>');
        END IF; -- Ultima linha do PA

      END LOOP; --crapass

      -- Nome da agencia, com o total geral
      vr_rel_dsagenci := 'T O T A L   G E R A L';
      -- Zera as variaveis de totais
      vr_tot_qtlancto := 0;
      vr_tot_vlcompdb := 0;
      vr_tot_vlcompcr := 0;

      -- Abre o no de agencia para o total geral
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
           '<pa>'||
             '<dsagenci>'||vr_rel_dsagenci||'</dsagenci>');

      -- Busca o primeiro registro da tabela de historico
      vr_ind := vr_tab_craphis.first;

      -- Efetua um loop sobre a tabela de historico
      WHILE vr_ind IS NOT NULL LOOP

        -- Se nao existir o historico na tabela extent vai para o proximo registro
        IF NOT vr_tab_extent.exists(vr_ind) THEN
          vr_ind := vr_tab_craphis.next(vr_ind);
          continue;
        END IF;

        -- Se nao possuir lancamentos vai para o proximo registro
        IF vr_tab_extent(vr_ind).ger_qtlancto = 0 THEN
          vr_ind := vr_tab_craphis.next(vr_ind);
          continue;
        END IF;

        -- Escreve a linha de detalhe
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
           '<historico>'||
             '<dshistor>'||substr(vr_tab_craphis(vr_ind).dshistor,1,21)        	             ||'</dshistor>'||
             '<indebcre>'||vr_tab_craphis(vr_ind).indebcre                                   ||'</indebcre>'||
             '<qtlancto>'||to_char(vr_tab_extent(vr_ind).ger_qtlancto,'fm999G999G990')       ||'</qtlancto>'||
             '<vlcompdb>'||to_char(vr_tab_extent(vr_ind).ger_vlcompdb,'fm999G999G999G990D00')||'</vlcompdb>'||
             '<vlcompcr>'||to_char(vr_tab_extent(vr_ind).ger_vlcompcr,'fm999G999G999G990D00')||'</vlcompcr>'||
           '</historico>');

        -- Zera as variaveis de totais
        vr_tot_qtlancto := vr_tot_qtlancto + nvl(vr_tab_extent(vr_ind).ger_qtlancto,0);
        vr_tot_vlcompdb := vr_tot_vlcompdb + nvl(vr_tab_extent(vr_ind).ger_vlcompdb,0);
        vr_tot_vlcompcr := vr_tot_vlcompcr + nvl(vr_tab_extent(vr_ind).ger_vlcompcr,0);

        -- Vai para o proximo historico
        vr_ind := vr_tab_craphis.next(vr_ind);

      END LOOP; /*  Fim do LOOP da VR_TAB_HISTORICO  */

      -- Escreve os totais
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
               '<tot_qtlancto>'||to_char(vr_tot_qtlancto,'fm999G999G990')       ||'</tot_qtlancto>'||
               '<tot_vlcompdb>'||to_char(vr_tot_vlcompdb,'fm999G999G999G990D00')||'</tot_vlcompdb>'||
               '<tot_vlcompcr>'||to_char(vr_tot_vlcompcr,'fm999G999G999G990D00')||'</tot_vlcompcr>'||
               '<age_qtcorren>'||to_char(vr_ger_qtcorren,'fm999G999G990')       ||'</age_qtcorren>'||
               '<age_qtchqsal>'||to_char(vr_ger_qtchqsal,'fm999G999G990')       ||'</age_qtchqsal>'||
               '<age_qtassoci>'||to_char(vr_ger_qtassoci,'fm999G999G990')       ||'</age_qtassoci>'||
            '</pa>');


      -- Finaliza o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</crrl062>',TRUE);

      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl062/pa/historico',        --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl062.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl062.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_nmformul  => 'crrl062.lst132dm',             --> Nome do formulario
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 2,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro

      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;


      /*  Emite resumo com os dados das contas convenio  */

      -- Inicializar o CLOB
      vr_des_xml := null;
      vr_texto_completo := NULL;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                          '<?xml version="1.0" encoding="utf-8"?><crrl079>'||
                            '<nmmesref>'||vr_rel_nmmesref||'</nmmesref>'||
                            '<compensacao><lancamentos><ordem>1</ordem>');

      -- Zera as variaveis de totais
      vr_tot_qtlancto := 0;
      vr_tot_vlcompdb := 0;
      vr_flginfor     := FALSE;

      -- Busca o primeiro registro da tabela de historico
      vr_ind := vr_tab_extent.first;

      -- Efetua um loop sobre a tabela de historico
      WHILE vr_ind IS NOT NULL LOOP

        -- Se nao possuir lancamentos vai para o proximo registro
        IF NOT vr_tab_extent.exists(vr_ind) OR nvl(vr_tab_extent(vr_ind).tab_qtlancom,0) = 0 THEN
          vr_ind := vr_tab_craphis.next(vr_ind);
          continue;
        END IF;

        -- Se o historico for diferente do totalizador
        IF vr_ind <> 999 THEN
          vr_rel_nrdctabb := gene0002.fn_busca_entrada(vr_ind, vr_lscontas,',');
        END IF;

        -- Acumula as variaveis de totais
        vr_rel_qtlancom := vr_tab_extent(vr_ind).tab_qtlancom;
        vr_rel_vllancom := vr_tab_extent(vr_ind).tab_vllancom;
        vr_tot_qtlancto := vr_tot_qtlancto + vr_rel_qtlancom;
        vr_tot_vlcompdb := vr_tot_vlcompdb + vr_rel_vllancom;

        -- Efetua a validacao para nao dar erro de divisao por zeros
        IF vr_rel_qtlancom > 0 THEN
          vr_rel_vlmedcom := ROUND(vr_rel_vllancom / vr_rel_qtlancom,2);
        ELSE
          vr_rel_vlmedcom := 0;
        END IF;

        -- Informa que teve informacoes
        vr_flginfor := TRUE;

        -- Se nao for totalizador
        IF vr_nrindice <> 999 THEN
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<linha>'||
                  '<nrdctabb>'||gene0002.fn_mask_conta(vr_rel_nrdctabb)        ||'</nrdctabb>'||
                  '<qtlancom>'||to_char(vr_rel_qtlancom,'fm999G999G990')       ||'</qtlancom>'||
                  '<vllancom>'||to_char(vr_rel_vllancom,'fm999G999G999G990D00')||'</vllancom>'||
                  '<vlmedcom>'||to_char(vr_rel_vlmedcom,'fm999G999G999G990D00')||'</vlmedcom>'||
                '</linha>');
        ELSE
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<linha>'||
                  '<nrdctabb>CONTA DIV</nrdctabb>'||
                  '<qtlancom>'||to_char(vr_rel_qtlancom,'fm999G999G990')       ||'</qtlancom>'||
                  '<vllancom>'||to_char(vr_rel_vllancom,'fm999G999G999G990D00')||'</vllancom>'||
                  '<vlmedcom>'||to_char(vr_rel_vlmedcom,'fm999G999G999G990D00')||'</vlmedcom>'||
                '</linha>');
        END IF;

        -- Vai para o proximo historico
        vr_ind := vr_tab_extent.next(vr_ind);

      END LOOP; /*  Fim do LOOP da VR_TAB_HISTORICO  */

      -- Verifica se existiu informacoes. Em caso negativo gera apenas o no vazio
      IF NOT vr_flginfor THEN
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<linha></linha>');
      end if;
      -- Verifica se possui lancamentos para nao ocorrer divisao por zeros
      IF vr_tot_qtlancto > 0 THEN
        vr_tot_vlmedcom := ROUND(vr_tot_vlcompdb / vr_tot_qtlancto,2);
      ELSE
        vr_tot_vlmedcom := 0;
      END IF;

      -- Escreve a linha de totais dos lancamentos
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<qtlancto>'||to_char(nvl(vr_tot_qtlancto,0),'fm999G999G990')       ||'</qtlancto>'||
            '<vlcompdb>'||to_char(nvl(vr_tot_vlcompdb,0),'fm999G999G999G990D00')||'</vlcompdb>'||
            '<vlmedcom>'||to_char(nvl(vr_tot_vlmedcom,0),'fm999G999G999G990D00')||'</vlmedcom>'||
          '</lancamentos>');

      vr_qtlancbb := vr_tot_qtlancto;


      /********* EXIBICAO RESUMO BANCOOB *******/
      vr_rel_qtlancom := vr_rel_qtbancob;
      vr_rel_vllancom := vr_rel_vlbancob;
      -- Verifica se possui lancamentos para nao ocorrer divisao por zeros
      IF vr_rel_qtlancom > 0 THEN
        vr_rel_vlmedcom := ROUND(vr_rel_vllancom / vr_rel_qtlancom,2);
      ELSE
        vr_rel_vlmedcom := 0;
      END IF;
      vr_tot_vlmedcom := vr_rel_vlmedcom;
      vr_tot_qtlancto := vr_rel_qtlancom;
      vr_tot_vlcompdb := vr_rel_vllancom;

      -- Imprimie a linha de compensacao para o BANCOOB
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
          '<lancamentos>'||
            '<ordem>2</ordem>'||
            '<linha>'||
              '<nrdctabb>BANCOOB</nrdctabb>'||
              '<qtlancom>'||to_char(nvl(vr_rel_qtlancom,0),'fm999G999G990')       ||'</qtlancom>'||
              '<vllancom>'||to_char(nvl(vr_rel_vllancom,0),'fm999G999G999G990D00')||'</vllancom>'||
              '<vlmedcom>'||to_char(nvl(vr_rel_vlmedcom,0),'fm999G999G999G990D00')||'</vlmedcom>'||
            '</linha>'||
            '<qtlancto>'||to_char(nvl(vr_tot_qtlancto,0),'fm999G999G990')       ||'</qtlancto>'||
            '<vlcompdb>'||to_char(nvl(vr_tot_vlcompdb,0),'fm999G999G999G990D00')||'</vlcompdb>'||
            '<vlmedcom>'||to_char(nvl(vr_tot_vlmedcom,0),'fm999G999G999G990D00')||'</vlmedcom>'||
          '</lancamentos>');

      vr_qtlancbc := vr_tot_qtlancto;
      /********* FIM EXIBICAO RESUMO BANCOOB *******/


      /********* EXIBICAO RESUMO CECRED *******/
      vr_rel_qtlancom := vr_rel_qtcecred;
      vr_rel_vllancom := vr_rel_vlcecred; /* Valores pelo cdhistor */
      -- Verifica se possui lancamentos para nao ocorrer divisao por zeros
      IF vr_rel_qtlancom > 0 THEN
        vr_rel_vlmedcom := ROUND(vr_rel_vllancom / vr_rel_qtlancom,2);
      ELSE
        vr_rel_vlmedcom := 0;
      END IF;
      vr_tot_vlmedcom := vr_rel_vlmedcom;
      vr_tot_qtlancto := vr_rel_qtlancom;
      vr_tot_vlcompdb := vr_rel_vllancom;

      -- Imprimie a linha de compensacao para a CECRED
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
          '<lancamentos>'||
            '<ordem>3</ordem>'||
            '<linha>'||
              '<nrdctabb>CECRED</nrdctabb>'||
              '<qtlancom>'||to_char(nvl(vr_rel_qtlancom,0),'fm999G999G990')       ||'</qtlancom>'||
              '<vllancom>'||to_char(nvl(vr_rel_vllancom,0),'fm999G999G999G990D00')||'</vllancom>'||
              '<vlmedcom>'||to_char(nvl(vr_rel_vlmedcom,0),'fm999G999G999G990D00')||'</vlmedcom>'||
            '</linha>'||
            '<qtlancto>'||to_char(nvl(vr_tot_qtlancto,0),'fm999G999G990')       ||'</qtlancto>'||
            '<vlcompdb>'||to_char(nvl(vr_tot_vlcompdb,0),'fm999G999G999G990D00')||'</vlcompdb>'||
            '<vlmedcom>'||to_char(nvl(vr_tot_vlmedcom,0),'fm999G999G999G990D00')||'</vlmedcom>'||
          '</lancamentos>'||
        '</compensacao>'||
        '<alinea>'); -- Aproveita o comando para abrir o no de alinea

      vr_qtlancrd := vr_tot_qtlancto;
      /********* FIM EXIBICAO RESUMO CECRED *******/

      -- Inicializa variavel de existencia de informacoes
      vr_flginfor := FALSE;

      /* Resumo das devolucoes por alinea */
      FOR vr_ind IN 1..1000 LOOP
        -- Se todos os valores forem zerados, entao pula para o proximo registro
        IF vr_dev_qtbrasil(vr_ind) = 0 AND
           vr_dev_qtbancob(vr_ind) = 0 AND
           vr_dev_qtcecred(vr_ind) = 0 THEN
          continue;
        END IF;

        -- Calcula o valor e o total de devolucao
        vr_tot_qtdevolu := vr_dev_qtbrasil(vr_ind) +
                           vr_dev_qtbancob(vr_ind) +
                           vr_dev_qtcecred(vr_ind);
        vr_tot_vldevolu := vr_dev_vlbrasil(vr_ind) +
                           vr_dev_vlbancob(vr_ind) +
                           vr_dev_vlcecred(vr_ind);

        -- Informa que existe informacoes
        vr_flginfor := FALSE;

        -- Se for totalizador, nao imprime o alinea
        IF vr_ind = 100 THEN
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<linha>'||
                  '<alinea></alinea>');
        ELSE
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<linha>'||
                  '<alinea>'||vr_ind||'</alinea>');
        END IF;

        -- Imprime as informacoes da alinea
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '<qtbrasil>'||to_char(vr_dev_qtbrasil(vr_ind),'fm999G999G990')       ||'</qtbrasil>'||
              '<vlbrasil>'||to_char(vr_dev_vlbrasil(vr_ind),'fm999G999G999G990D00')||'</vlbrasil>'||
              '<qtbancob>'||to_char(vr_dev_qtbancob(vr_ind),'fm999G999G990')       ||'</qtbancob>'||
              '<vlbancob>'||to_char(vr_dev_vlbancob(vr_ind),'fm999G999G999G990D00')||'</vlbancob>'||
              '<qtcecred>'||to_char(vr_dev_qtcecred(vr_ind),'fm999G999G990')       ||'</qtcecred>'||
              '<vlcecred>'||to_char(vr_dev_vlcecred(vr_ind),'fm999G999G999G990D00')||'</vlcecred>'||
              '<qtdevolu>'||to_char(vr_tot_qtdevolu,'fm999G999G990')               ||'</qtdevolu>'||
              '<vldevolu>'||to_char(vr_tot_vldevolu,'fm999G999G999G990D00')        ||'</vldevolu>'||
            '</linha>');
      END LOOP; -- Final do loop de alinea

      -- Verifica se possui lancamentos para o Banco do Brasil para nao ocorrer divisao por zeros
      IF vr_qtlancbb > 0 THEN
        vr_pcbrasil := ROUND((vr_dev_qtbrasil(100) * 100) / vr_qtlancbb,2);
      ELSE
        vr_pcbrasil := 0;
      END IF;

      -- Verifica se possui lancamentos para o Bancoob para nao ocorrer divisao por zeros
      IF vr_qtlancbc > 0 THEN
        vr_pcbancob := ROUND((vr_dev_qtbancob(100) * 100) / vr_qtlancbc,2);
      ELSE
        vr_pcbancob := 0;
      END IF;

      -- Verifica se possui lancamentos para a Cecred para nao ocorrer divisao por zeros
      IF vr_qtlancrd > 0 THEN
        vr_pccecred := ROUND((vr_dev_qtcecred(100) * 100) / vr_qtlancrd,2);
      ELSE
        vr_pccecred := 0;
      END IF;

      -- Verifica se possui lancamentos de devolucao para nao ocorrer divisao por zeros
      IF vr_qtlancbb > 0 OR vr_qtlancbc > 0 OR vr_qtlancrd > 0 THEN
        vr_pcdevolu := ROUND((vr_tot_qtdevolu * 100) / (vr_qtlancbb + vr_qtlancbc + vr_qtlancrd),2);
      ELSE
        vr_pcdevolu := 0;
      END IF;

      -- Se nao existir registro, gera o no vazio para o Ireport
      IF NOT vr_flginfor THEN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
           '<linha></linha>');
      END IF;

      -- Imprime as porcentagens e fecha o no de alinea e abre o no de PA
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
           '<pcbrasil>'||to_char(nvl(vr_pcbrasil,0),'fm990D00')||'</pcbrasil>'||
           '<pcbancob>'||to_char(nvl(vr_pcbancob,0),'fm990D00')||'</pcbancob>'||
           '<pccecred>'||to_char(nvl(vr_pccecred,0),'fm990D00')||'</pccecred>'||
           '<pcdevolu>'||to_char(nvl(vr_pcdevolu,0),'fm990D00')||'</pcdevolu>'||
         '</alinea>'||
         '<pa>');

      /* zerar os totais */
      vr_tot_compbbra := 0;
      vr_tot_compbcob := 0;
      vr_tot_compccrd := 0;
      vr_tot_compeger := 0;
      vr_tot_devobbra := 0;
      vr_tot_devobcob := 0;
      vr_tot_devoccrd := 0;
      vr_tot_devolger := 0;
      vr_tot_percbbra := 0;
      vr_tot_percbcob := 0;
      vr_tot_percccrd := 0;
      vr_tot_perceger := 0;

      -- Efetua o loop para gerar o resumo por PA de devolucoes
      FOR vr_ind IN 1..1000 LOOP

        /* se nao houver cheques emitidos e devolvidos */
        IF vr_age_qtbrasil(vr_ind) = 0 AND
           vr_age_qtbancob(vr_ind) = 0 AND
           vr_age_qtcecred(vr_ind) = 0 AND
           vr_cmp_qtlancbb(vr_ind) = 0 AND
           vr_cmp_qtlancbc(vr_ind) = 0 AND
           vr_cmp_qtlancrd(vr_ind) = 0 THEN
          continue;
        END IF;

        -- Calcula os valores totais de compensacao e devolucao
        vr_tot_qtcompen := vr_cmp_qtlancbb(vr_ind) +
                           vr_cmp_qtlancbc(vr_ind) +
                           vr_cmp_qtlancrd(vr_ind);
        vr_tot_qtdevolu := vr_age_qtbrasil(vr_ind) +
                           vr_age_qtbancob(vr_ind) +
                           vr_age_qtcecred(vr_ind);

        -- Verifica se possui lancamentos para o Banco do Brasil para nao ocorrer divisao por zeros
        IF vr_cmp_qtlancbb(vr_ind) > 0 THEN
          vr_age_pcbrasil := ROUND((vr_age_qtbrasil(vr_ind) * 100) /
                                    vr_cmp_qtlancbb(vr_ind),2);
        ELSE
          vr_age_pcbrasil := 0;
        END IF;

        -- Verifica se possui lancamentos para o Bancoob para nao ocorrer divisao por zeros
        IF vr_cmp_qtlancbc(vr_ind) > 0 THEN
          vr_age_pcbancob := ROUND((vr_age_qtbancob(vr_ind) * 100) /
                                    vr_cmp_qtlancbc(vr_ind),2);
        ELSE
          vr_age_pcbancob := 0;
        END IF;

        -- Verifica se possui lancamentos para a Cecred para nao ocorrer divisao por zeros
        IF vr_cmp_qtlancrd(vr_ind) > 0 THEN
          vr_age_pccecred := ROUND((vr_age_qtcecred(vr_ind) * 100) /
                                    vr_cmp_qtlancrd(vr_ind),2);
        ELSE
          vr_age_pccecred := 0;
        END IF;

        -- Verifica se possui lancamentos para nao ocorrer divisao por zeros
        IF vr_cmp_qtlancbb(vr_ind) > 0 OR vr_cmp_qtlancbc(vr_ind) > 0 OR vr_cmp_qtlancrd(vr_ind) > 0 THEN
          vr_tot_pcdevolu := ROUND((vr_tot_qtdevolu * 100) /
                                    (vr_cmp_qtlancbb(vr_ind) +
                                     vr_cmp_qtlancbc(vr_ind) +
                                     vr_cmp_qtlancrd(vr_ind)),2);
        ELSE
          vr_tot_pcdevolu := 0;
        END IF;

        /* compensados */
        vr_tot_compbbra := vr_tot_compbbra + vr_cmp_qtlancbb(vr_ind);
        vr_tot_compbcob := vr_tot_compbcob + vr_cmp_qtlancbc(vr_ind);
        vr_tot_compccrd := vr_tot_compccrd + vr_cmp_qtlancrd(vr_ind);
        vr_tot_compeger := vr_tot_compeger + vr_tot_qtcompen;

        /* devolvidos */
        vr_tot_devobbra := vr_tot_devobbra + vr_age_qtbrasil(vr_ind);
        vr_tot_devobcob := vr_tot_devobcob + vr_age_qtbancob(vr_ind);
        vr_tot_devoccrd := vr_tot_devoccrd + vr_age_qtcecred(vr_ind);
        vr_tot_devolger := vr_tot_devolger + vr_tot_qtdevolu;

        /* percentual */
        vr_tot_percbbra := vr_tot_percbbra + vr_age_pcbrasil;
        vr_tot_percbcob := vr_tot_percbcob + vr_age_pcbancob;
        vr_tot_percccrd := vr_tot_percccrd + vr_age_pccecred;
        vr_tot_perceger := vr_tot_perceger + vr_tot_pcdevolu;


        -- Imprime as informacoes da alinea por PA
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<linha>'||
              '<pa>'      ||vr_ind                                                 ||'</pa>'||
              '<qtlancbb>'||to_char(vr_cmp_qtlancbb(vr_ind),'fm999G999G990')       ||'</qtlancbb>'||
              '<qtbrasil>'||to_char(vr_age_qtbrasil(vr_ind),'fm999G999G990')       ||'</qtbrasil>'||
              '<pcbrasil>'||to_char(vr_age_pcbrasil,'fm990D00')                    ||'</pcbrasil>'||
              '<qtlancbc>'||to_char(vr_cmp_qtlancbc(vr_ind),'fm999G999G990')       ||'</qtlancbc>'||
              '<qtbancob>'||to_char(vr_age_qtbancob(vr_ind),'fm999G999G990')       ||'</qtbancob>'||
              '<pcbancob>'||to_char(vr_age_pcbancob,'fm990D00')                    ||'</pcbancob>'||
              '<qtlancrd>'||to_char(vr_cmp_qtlancrd(vr_ind),'fm999G999G990')       ||'</qtlancrd>'||
              '<qtcecred>'||to_char(vr_age_qtcecred(vr_ind),'fm999G999G990')       ||'</qtcecred>'||
              '<pccecred>'||to_char(vr_age_pccecred,'fm990D00')                    ||'</pccecred>'||
              '<qtcompen>'||to_char(vr_tot_qtcompen,'fm999G999G990')               ||'</qtcompen>'||
              '<qtdevolu>'||to_char(vr_tot_qtdevolu,'fm999G999G990')               ||'</qtdevolu>'||
              '<pcdevolu>'||to_char(vr_tot_pcdevolu,'fm990D00')                    ||'</pcdevolu>'||
            '</linha>');
      END LOOP; -- Loop de resumo por PA de devolucoes

      /* totais */
      IF vr_tot_compeger <> 0 THEN
        vr_tot_perceger := (vr_tot_devolger / vr_tot_compeger) * 100;
      ELSE
        vr_tot_perceger := 0;
      END IF;

      /** Banco do Brasil **/
      IF vr_tot_compbbra <> 0 THEN
        vr_tot_percbbra := (vr_tot_devobbra / vr_tot_compbbra) * 100;
      ELSE
        vr_tot_percbbra := 0;
      END IF;

      /** Bancoob **/
      IF vr_tot_compbcob <> 0 THEN
        vr_tot_percbcob := (vr_tot_devobcob / vr_tot_compbcob) * 100;
      ELSE
        vr_tot_percbcob := 0;
      END IF;

      /** Cecred **/
      IF vr_tot_compccrd <> 0 THEN
        vr_tot_percccrd := (vr_tot_devoccrd / vr_tot_compccrd) * 100;
      ELSE
        vr_tot_percccrd := 0;
      END IF;

      -- Imprime as informacoes totais do PA e fecha todos os nós
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
          '<linha>'||
            '<pa>TOTAIS</pa>'||
            '<qtlancbb>'||to_char(vr_tot_compbbra,'fm999G999G990')               ||'</qtlancbb>'||
            '<qtbrasil>'||to_char(vr_tot_devobbra,'fm999G999G990')               ||'</qtbrasil>'||
            '<pcbrasil>'||to_char(vr_tot_percbbra,'fm990D00')                    ||'</pcbrasil>'||
            '<qtlancbc>'||to_char(vr_tot_compbcob,'fm999G999G990')               ||'</qtlancbc>'||
            '<qtbancob>'||to_char(vr_tot_devobcob,'fm999G999G990')               ||'</qtbancob>'||
            '<pcbancob>'||to_char(vr_tot_percbcob,'fm990D00')                    ||'</pcbancob>'||
            '<qtlancrd>'||to_char(vr_tot_compccrd,'fm999G999G990')               ||'</qtlancrd>'||
            '<qtcecred>'||to_char(vr_tot_devoccrd,'fm999G999G990')               ||'</qtcecred>'||
            '<pccecred>'||to_char(vr_tot_percccrd,'fm990D00')                    ||'</pccecred>'||
            '<qtcompen>'||to_char(vr_tot_compeger,'fm999G999G990')               ||'</qtcompen>'||
            '<qtdevolu>'||to_char(vr_tot_devolger,'fm999G999G990')               ||'</qtdevolu>'||
            '<pcdevolu>'||to_char(vr_tot_perceger,'fm990D00')                    ||'</pcdevolu>'||
          '</linha>'||
        '</pa>'||
      '</crrl079>',TRUE);

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl079',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl079.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl079.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_sqcabrel  => 2,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro

      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
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

  END pc_crps073;
/

