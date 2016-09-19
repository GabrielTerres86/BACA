CREATE OR REPLACE PROCEDURE CECRED.pc_crps478(pr_cdcooper  in crapcop.cdcooper%type,  --> Cooperativa
                                       pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                                       pr_stprogra out pls_integer,            --> Saída de termino da execução
                                       pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                                       pr_cdcritic out number,                 --> Código crítica
                                       pr_dscritic out varchar2) IS            --> Descrição crítica
/* ..........................................................................

   Programa: pc_crps478 (Antigo Fontes/crps478.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Maio/2007                     Ultima atualizacao: 06/11/2014

   Dados referentes ao programa:

   Frequencia : Diario.
   Objetivo   : Calcular o saldo das aplicacoes RDCPRE e RDCPOS com resgate
            programado e efetuar os creditos em conta.
            Emite relatorio 453. Solicitacao 1 e ordem 21.

   Observacoes: -> Usar os historicos adequados para rdc pre e pos
                -> Sair dinheiro do craplap = histor 475
                -> Da conta investimento para o craplcm = 478
                -> Estorno da provisao, se rdc pre histor = 463 e se for
                   pos = 531
                -> Nao tem abono de cpmf
                -> Nao tem ajuste de IR
                -> O campo craprda.vlsdrdca sera sempre o valor atual da
                   aplicacao
                ** Observacoes RDCPRE **
                -> No rdc pre e necessario calcular o quanto de provisao foi
                   gerada ate a data para fazer os estornos das mesmas quando
                   de resgate.
                -> O estorno deve ser proporcional ao que se esta resgatando
                ** Observacoes RDCPOS **
                -> Usar o fontes/saldo_rgt_rdc_pos para descobrir quanto rendeu
                   o valor que esta sendo solicitado para resgate.
                -> fazer um lancamento no craplap.cdhistor = 533 para lancar o
                   rendimento calculado no saldo_rgt_rdc.
                -> fazer um lancamento no craplap.cdhistor = 534 para lancar o
                    IRRF a ser recolhido calculado no saldo_rgt_rdc.
                -> fazer um lancamento no craplap.cdhistor = 531 para estornar
                   a provisao ja calculada, usando o mesmo valor do rendimento.
                -> os lancamentos na conta investimento continuam os mesmos.

   Alteracoes : 21/09/2007 - Desmembrar em dois, um rodando com olt e outro
                             com opr, para resolver o mensal (Magui).

                24/09/2007 - Utilizar craprda.qtdiauti para carencia nas
                             aplicacoes RDC (David).

                03/10/2007 - Quando resgate total do rdcpos nao estava jogando
                             o valor correto na conta corrente (Magui).

                05/10/2007 - Trabalhar com 4 casas na provisao (Magui).

                26/10/2007 - Corrigir lancamento zerado no RDCPOS (Magui).

                16/01/2008 - Ajustes, resgate negativo (Magui).

                06/02/2008 - Melhorar critica 913, valor saque permitido(Magui)

                07/02/2008 - Acerto na data de geracao dos lotes (Magui).

                20/02/2008 - Quando dois resgates parciais para a mesma
                             conta e aplicacao nao enxergava saldo (Magui).

                26/02/2008 - Quando resgatava o principal calculado o proximo
                             resgate nao calculava certo (Magui).

                11/04/2008 - Zerar vlslfmes quando saque total (Magui).

                25/04/2008 - Corrigir atualizacao do lote (Magui).

                28/05/2008 - Corrigir lote no log de erro (Magui).

                28/08/2008 - Acertar leitura last craplap (Magui).

                15/04/2009 - Quando dois resgates parciais no mesmo dia rdcpos
                             na carencia nao estava zerando a aplicacao e dei-
                             xava uma saldo no vlsltxmx e vlsltxmm (Magui).

                01/06/2009 - Ao gerar craplcm colocar o numero da aplicacao
                             que esta sendo resgatada no campo nrdocmto.
                             Caso o craplcm exista (mais de um resgate para a
                             aplicacao no dia) adicionar o numero 9 na frente
                             do numero da aplicacao (Fernando).

                04/01/2010 - Retirar mensagem de saldo maior final maior
                             que R$ 1,00 (Magui).

                26/11/2010 - Retirar da sol 1 ordem 39 e colocar na sol 82
                             ordem 78. E na Cecred na sol 82 ordem 81 (Magui).

                01/07/2011 - Realizado controle no numero do documento na
                             geracao do lancamento de resgate (Adriano).

                28/07/2011 - Onde chamava a procedure cria_craprej com undo da
                             trans_1, alterado a chamada para cria_w_craprej;
                             pois, estava perdendo criticas gravadas na craprej.
                             (Fabricio).

                20/12/2012 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.

                16/08/2013 - Ajustes de acordo com a pc_crps495 (Daniel - Supero)

                16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

                02/10/2014 - Correção SD1800078 - resgates minimos com rendimentos errôneos
                             (Marcos-Supero)

                22/10/2014 - Ajutes de problema gerado devido correção no SD1800078 - quando
                             em carência a segunda chamada da pc_saldo_rgt_rdc_pos deve ocorrer
                             (Marcos-Supero)

                06/11/2014 - Ajustes de performance (Alisson - AMcom)

   .............................................................................*/
  -- Variáveis do escopo do programa
  vr_cdhistor   NUMBER;                      --> Código do histórico
  vr_vlresgat   NUMBER(10,2);                --> Valor resgate
  vr_saldorda   NUMBER(10,2);                --> Saldo dia
  vr_contapli   NUMBER;                      --> Conta aplicação
  vr_dtrefere   craplap.dtrefere%TYPE;       --> Data de referencia
  vr_txaplmes   craplap.txaplmes%TYPE;       --> Taxa mês
  vr_txaplica   craplap.txaplica%TYPE;       --> Taxa aplicada
  vr_nrdocmto   craplap.nrdocmto%TYPE;       --> Número do documento
  vr_nraplica   VARCHAR2(2000);              --> Número da aplicação
  vr_nraplfun   VARCHAR2(2000);              --> Número da aplicação corrente
  vr_vllanmto   craplap.vllanmto%TYPE;       --> Valor lançamento
  vr_vlrdirrf   craplap.vllanmto%TYPE;       --> Valor IRRF
  vr_vlrenrgt   craplap.vllanmto%TYPE;       --> Rendimento total a ser pago quando resgate total
  vr_sldpresg   craplap.vllanmto%TYPE;       --> Valor do resgate total sem irrf ou o solicitado
  vr_vlestprv   craplap.vllanmto%TYPE;       --> Valor previsto
  vr_dtiniper   DATE;                        --> Data início do período
  vr_dtfimper   DATE;                        --> Data final do período
  vr_vlsldrdc   craprda.vlsdrdca%TYPE;       --> Valor movimento (cálculo)
  vr_vlrenapl   craprda.vlsdrdca%TYPE;       --> Saldo RDCA

  /* Variáveis utilizadas para cálcular resgate mínimo */
  vr_vllan531   craprda.vlsdrdca%TYPE;
  vr_vllan529   craprda.vlsdrdca%TYPE;
  vr_vllan532   craprda.vlsdrdca%TYPE;
  vr_vllan533   craprda.vlsdrdca%TYPE;
  vr_vllan534   craprda.vlsdrdca%TYPE;
  /* Fim */

  vr_vlrendmm   craplap.vlrendmm%TYPE;       --> Valor Rendimento
  vr_vlrnmmrg   craplap.vlrendmm%TYPE;       --> Rendimento aplicação na taxa mínima
  vr_rdulmtmm   craplap.vlrendmm%TYPE;       --> Rendimento até a data de resgate
  vr_perirrgt   NUMBER(10,2);                --> Percentual de aliquota para calculo do IRRF
  vr_vlrvtfim   craplap.vllanmto%TYPE;       --> Quantia provisão reverter para zerar a aplicação
  vr_vlbasrgt   craplap.vllanmto%TYPE;       --> Valor real do resgate
  vr_vlrrgtot   craplap.vllanmto%TYPE;       --> Resgate para zerar a aplicação
  vr_vlirftot   craplap.vllanmto%TYPE;       --> IRRF para finalizar a aplicacao
  vr_txapllap   craplap.txaplica%TYPE;       --> Taxa aplicada
  vr_dtmvtolt   craprda.dtmvtolt%TYPE;       --> Valor total de movimento
  vr_vlajtfim   NUMBER(10,2);                --> Valor lançamento do extrato
  vr_cdhistorc  craplcm.cdhistor%TYPE;       --> Código histórico de controle
  vr_vlsolrgt   craplap.vllanmto%TYPE;       --> Valor lançamento
  vr_regexist   BOOLEAN;                     --> Variável para controle de impressão
  vr_atxaplmes  craplap.txaplmes%TYPE;       --> Auxiliar para controle no insert da CRAPLAP
  vr_acdhistor  NUMBER;                      --> Auxiliar para controle no insert da CRAPLAP
  vr_controle   EXCEPTION;                   --> Controle de fluxo via exceção
  vr_lastextr   NUMBER;                      --> Número de registros do extrato
  vr_nom_dir    VARCHAR2(200);               --> Variável para armazenar o path do XML
  vr_nom_arq    VARCHAR2(200);               --> Variável para armazenar o nome do XML
  vr_mensag     VARCHAR2(2000);              --> Variável para armazenar a mensagem para relatório
  vr_cdprogra   VARCHAR2(100);               --> Nome do programa
  vr_des_reto   VARCHAR2(3);                 --> Saída do método de cálculo de rendimentos
  vr_tab_erro   gene0001.typ_tab_erro;       --> Tabela com erros da gene0001.pc_gera_erro
  vr_dtinitax   DATE;                        --> Data inicial do período da taxa
  vr_dtfimtax   DATE;                        --> Data final do período da taxa
  vr_xmlclob    CLOB;                        --> Arquivo CLOB para o XML
  vr_bfclob     VARCHAR2(32767);             --> Variável para fazer bufferização dos dados para CLOB
  vr_dstextab   craptab.dstextab%type;       --> Variavel para receber texto do parametro
  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  -- Definição de tipo e inicialização com valores
  TYPE vr_typ_ctrdocmt IS VARRAY(9) OF VARCHAR2(1);
  vr_ctrdocmt vr_typ_ctrdocmt := vr_typ_ctrdocmt('1','2','3','4','5','6','7','8','9');

  vr_typ_tab_extr_rdc apli0001.typ_tab_extr_rdc;      --> Definição de TEMP TABLE para armazenar extrato

  -- Tabela temporária para armazenar dados para relatório de saída
  TYPE typ_reg_craprej IS
  RECORD(dtmvtolt craprej.dtmvtolt%TYPE
        ,nrdconta craprej.nrdconta%TYPE
        ,nraplica craprej.nraplica%TYPE
        ,dtdaviso craprej.dtdaviso%TYPE
        ,vldaviso craprej.vldaviso%TYPE
        ,vlsdapli craprej.vlsdapli%TYPE
        ,vllanmto craprej.vllanmto%TYPE
        ,cdcritic craprej.cdcritic%TYPE);

  TYPE typ_tab_craprej IS
    TABLE OF typ_reg_craprej
    INDEX BY binary_integer;
  vr_tab_craprej typ_tab_craprej;

  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Tabela de Memoria para guardar aplicacoes bloqueadas para resgate
  TYPE typ_tab_craptab IS TABLE OF PLS_INTEGER INDEX BY varchar2(20);
  vr_tab_craptab typ_tab_craptab;
  vr_index_craptab varchar2(20);

  -- Tabela de Memoria para controle de lotes
  TYPE typ_tab_craplot IS TABLE OF BOOLEAN INDEX BY PLS_INTEGER;
  vr_tab_craplot typ_tab_craplot;

  -- Cadastro dos lançamentos de resgate solicitados
  -- Força o uso do índice craplrg4 conforme especificado no Progress
  CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE           --> Código cooperativa
                    ,pr_dtmvtolt IN craplrg.dtresgat%TYPE) IS       --> Data movimento atual

    SELECT /*+ INDEX(cg CRAPLRG##CRAPLRG4) */
           cg.tpaplica,
           cg.tpresgat,
           cg.vllanmto,
           cg.nrdconta,
           cg.nraplica,
           cg.dtmvtolt,
           cg.flgcreci,
           cg.dtresgat,
           cg.rowid
    FROM craplrg cg
    WHERE cg.cdcooper  = pr_cdcooper
      AND cg.dtresgat <= pr_dtmvtolt
      AND cg.inresgat  = 0
      AND cg.tpresgat in (1, 2)
    ORDER BY cg.cdcooper
           , cg.dtresgat DESC
           , cg.inresgat
           , cg.nrdocmto;
  rw_craplrg cr_craplrg%ROWTYPE;

  -- Cadastro de tabelas genéricas
  CURSOR cr_craptab (pr_cdcooper  IN crapdat.cdcooper%TYPE          --> Código da cooperativa
                    ,pr_nmsistem  IN craptab.nmsistem%TYPE          --> Tipo do sistema
                    ,pr_tptabela  IN craptab.tptabela%TYPE          --> Tipo da tabela
                    ,pr_cdempres  IN craptab.cdempres%TYPE) IS      --> Código empresa
    SELECT upper(ct.cdacesso) cdacesso
          ,substr(ct.dstextab,1,7) dstextab
    FROM craptab ct
    WHERE ct.cdcooper = pr_cdcooper
      AND upper(ct.nmsistem) = upper(pr_nmsistem)
      AND upper(ct.tptabela) = upper(pr_tptabela)
      AND ct.cdempres = pr_cdempres;

  -- Descrição dos tipos de captação oferecidos aos cooperados
  CURSOR cr_crapdtc (pr_cdcooper IN crapdtc.cdcooper%TYPE           --> Código cooperativa
                    ,pr_tpaplica IN crapdtc.tpaplica%TYPE) IS       --> Taxa aplicação
    SELECT cc.tpaplrdc
          ,cc.vlminapl
    FROM crapdtc cc
    WHERE cc.cdcooper = pr_cdcooper
      AND cc.tpaplica = pr_tpaplica
      AND cc.tpaplrdc IN (1,2);
  rw_crapdtc cr_crapdtc%ROWTYPE;

  -- Cadastro aplicações RDCA
  CURSOR cr_craprda (pr_cdcooper IN crapdtc.cdcooper%TYPE           --> Código cooperativa
                    ,pr_nrdconta IN craplrg.nrdconta%TYPE           --> Número de conta
                    ,pr_nraplica IN craplrg.nraplica%TYPE) IS       --> Número de aplicação
    SELECT /*+ INDEX(cd CRAPRDA##CRAPRDA2) */
           cd.insaqtot
          ,cd.vlsdrdca
          ,cd.nrdconta
          ,cd.nraplica
          ,cd.dtmvtolt
          ,cd.dtfimper
          ,cd.qtdiauti
          ,cd.dtatslmm
          ,cd.vlrgtacu
          ,cd.vlsltxmm
          ,cd.dtatslmx
          ,cd.vlsltxmx
          ,cd.cdcooper
          ,cd.inaniver
          ,cd.incalmes
          ,cd.vlslfmes
          ,cd.dtsdfmes
          ,cd.flgctain
          ,cd.ROWID
          ,count(1) over() retorno
    FROM craprda cd
    WHERE cd.cdcooper = pr_cdcooper
      AND cd.nrdconta = pr_nrdconta
      AND cd.nraplica = pr_nraplica;
  rw_craprda cr_craprda%ROWTYPE;

  -- Lançamento de aplicações RDCA
  CURSOR cr_craplap (pr_cdcooper IN crapdtc.cdcooper%TYPE       --> Código cooperativa
                    ,pr_nrdconta IN craprda.nrdconta%TYPE       --> Número de conta
                    ,pr_nraplica IN craprda.nraplica%TYPE       --> Número de aplicação
                    ,pr_dtmvtolt IN craprda.dtmvtolt%TYPE) IS   --> Data movimento atual
    SELECT cl.txaplica
          ,cl.txaplmes
          ,cl.cdhistor
          ,cl.vllanmto
          ,cl.vlpvlrgt
          ,cl.rowid
    FROM craplap cl
    WHERE cl.cdcooper = pr_cdcooper
      AND cl.nrdconta = pr_nrdconta
      AND cl.nraplica = pr_nraplica
      AND cl.dtmvtolt = pr_dtmvtolt;
  rw_craplap cr_craplap%ROWTYPE;

  -- Capas de lote
  CURSOR cr_craplot (pr_cdcooper  IN craplrg.cdcooper%TYPE      --> Código cooperativa
                    ,pr_dtmvtolt  IN craplrg.dtresgat%TYPE      --> Data movimento atual
                    ,pr_cdagenci  IN craplap.cdagenci%TYPE      --> código agência
                    ,pr_cdbccxlt  IN craplap.cdbccxlt%TYPE      --> Código caixa/banco
                    ,pr_nrdolote  IN craplap.nrdolote%TYPE) IS  --> Número do lote
    SELECT co.dtmvtolt
          ,co.cdagenci
          ,co.cdbccxlt
          ,co.nrdolote
          ,co.nrseqdig
          ,co.vlinfodb
          ,co.vlcompdb
          ,co.tplotmov
          ,co.qtinfoln
          ,co.qtcompln
          ,co.vlinfocr
          ,co.vlcompcr
          ,co.ROWID
    FROM craplot co
    WHERE co.cdcooper = pr_cdcooper
      AND co.dtmvtolt = pr_dtmvtolt
      AND co.cdagenci = pr_cdagenci
      AND co.cdbccxlt = pr_cdbccxlt
      AND co.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;
  rw_craplot_10111 cr_craplot%ROWTYPE;
  rw_craplot_10112 cr_craplot%ROWTYPE;
  rw_craplot_10113 cr_craplot%ROWTYPE;
  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nrtelura
    FROM crapcop cop
    WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cadastro de lançamentos de aplicações RDCA
  CURSOR cr_craplaplast (pr_cdcooper   IN craplrg.cdcooper%TYPE      --> Codigo cooperativa
                        ,pr_nrdconta   IN craplrg.nrdconta%TYPE      --> Número de conta
                        ,pr_nraplica   IN craplrg.nraplica%TYPE      --> Número de aplicação
                        ,pr_dtmvtolt   IN craplap.dtmvtolt%TYPE      --> Data de movimento atual
                        ,pr_vlresgat   IN craplap.vllanmto%TYPE) IS  --> Valor resgate
    SELECT /*+ INDEX(cp craplap##craplap5) */
           cp.dtmvtolt
          ,cp.cdagenci
          ,cp.cdbccxlt
          ,cp.nrdolote
          ,cp.vllanmto
          ,cp.rowid
    FROM craplap cp
    WHERE cp.cdcooper = pr_cdcooper
      AND cp.nrdconta = pr_nrdconta
      AND cp.nraplica = pr_nraplica
      AND cp.dtmvtolt = pr_dtmvtolt
      AND cp.cdhistor = 534
      AND cp.vllanmto = pr_vlresgat
      AND ROWNUM = 1
    ORDER BY cp.progress_recid DESC;
  rw_craplaplast cr_craplaplast%rowtype;

  -- Lançamentos de depósitos a vista
  CURSOR cr_craplcm (pr_cdcooper   IN craplrg.cdcooper%TYPE        --> Código cooperativa
                    ,pr_dtmvtolt   IN craplot.dtmvtolt%TYPE        --> Data movimento atual
                    ,pr_cdagenci   IN craplot.cdagenci%TYPE        --> Código agencia
                    ,pr_cdbccxlt   IN craplot.cdbccxlt%TYPE        --> Código caixa/banco
                    ,pr_nrdolote   IN craplot.nrdolote%TYPE        --> Número de lote
                    ,pr_nrdconta   IN craprda.nrdconta%TYPE        --> Número de conta
                    ,pr_nraplica   IN craplrg.nraplica%TYPE) IS    --> Número de aplicação
    SELECT cm.ROWID
          ,cm.nrseqdig
          ,count(1) over() retorno
    FROM craplcm cm
    WHERE cm.cdcooper = pr_cdcooper
      AND cm.dtmvtolt = pr_dtmvtolt
      AND cm.cdagenci = pr_cdagenci
      AND cm.cdbccxlt = pr_cdbccxlt
      AND cm.nrdolote = pr_nrdolote
      AND cm.nrdctabb = pr_nrdconta
      AND cm.nrdocmto = gene0002.fn_char_para_number(pr_nraplica);
  rw_craplcm cr_craplcm%rowtype;

  -- Cadastro de rejeitados na integração - D23
  CURSOR cr_craprej (pr_cdcooper   IN craplrg.cdcooper%TYPE        --> Código cooperativa
                    ,pr_dtmvtolt   IN craplot.dtmvtolt%TYPE) IS    --> Data movimento atual
    SELECT cj.ROWID,
           cj.cdcritic,
           cj.nrdconta,
           cj.nraplica,
           cj.dtdaviso,
           cj.vldaviso,
           cj.vlsdapli,
           cj.vllanmto
      FROM craprej cj
     WHERE cj.cdcooper = pr_cdcooper
       AND cj.dtmvtolt = pr_dtmvtolt
       AND cj.cdagenci = 478
       AND cj.cdbccxlt = 478
       AND cj.nrdolote = 478
       AND cj.tpintegr = 478
     ORDER BY cj.dtmvtolt,
              cj.cdagenci,
              cj.cdbccxlt,
              cj.nrdolote,
              cj.nrdconta,
              cj.nraplica;

  /* Procedure para criar registros na tabela CRAPREJ */
  PROCEDURE pc_cria_craprej (pr_cdcooper  IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta  IN craplrg.nrdconta%TYPE
                            ,pr_nraplica  IN craplrg.nraplica%TYPE
                            ,pr_dtmvtolt  IN craplrg.dtmvtolt%TYPE
                            ,pr_vllanmto  IN craplrg.vllanmto%TYPE
                            ,pr_saldorda  IN NUMBER
                            ,pr_vlresgat  IN NUMBER
                            ,pr_cdcritic  IN OUT NUMBER
                            ,pr_gdtmvtol  IN crapdat.dtmvtolt%TYPE
                            ,pr_des_erro  IN OUT VARCHAR2) IS
  -- Inicia sessão autonoma para o processo de INSERT na tabela
  -- PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO craprej(dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,nrdconta
                       ,nraplica
                       ,dtdaviso
                       ,vldaviso
                       ,vlsdapli
                       ,vllanmto
                       ,cdcritic
                       ,tpintegr
                       ,cdcooper)
     VALUES(pr_gdtmvtol
           ,478
           ,478
           ,478
           ,pr_nrdconta
           ,pr_nraplica
           ,pr_dtmvtolt
           ,pr_vllanmto
           ,pr_saldorda
           ,pr_vlresgat
           ,pr_cdcritic
           ,478
           ,pr_cdcooper);

    EXCEPTION
      WHEN others THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro na sub-procedure pc_cria_craprej. ' || sqlerrm;
    END pc_cria_craprej;

  /* Procedure para criar registros na TEMP TABLE que irá alimentar relatório no final do processo */
  PROCEDURE pc_cria_wcraprej (pr_dtmvtolt      IN DATE
                             ,pr_nrdconta      IN craplrg.nrdconta%TYPE
                             ,pr_nraplica      IN craplrg.nraplica%TYPE
                             ,pr_aviso         IN craplrg.dtmvtolt%TYPE
                             ,pr_vldaviso      IN craplrg.vllanmto%TYPE
                             ,pr_saldorda      IN vr_saldorda%TYPE
                             ,pr_vlresgat      IN vr_vlresgat%TYPE
                             ,pr_cdcritic      IN NUMBER
                             ,pr_tab_craprej   IN OUT NOCOPY vr_tab_craprej%TYPE) IS
    vr_craprej    NUMBER;
  BEGIN
    vr_craprej := pr_tab_craprej.count() + 1;
    pr_tab_craprej(vr_craprej).dtmvtolt := pr_dtmvtolt;
    pr_tab_craprej(vr_craprej).nrdconta := pr_nrdconta;
    pr_tab_craprej(vr_craprej).nraplica := pr_nraplica;
    pr_tab_craprej(vr_craprej).dtdaviso := pr_aviso;
    pr_tab_craprej(vr_craprej).vldaviso := pr_vldaviso;
    pr_tab_craprej(vr_craprej).vlsdapli := pr_saldorda;
    pr_tab_craprej(vr_craprej).vllanmto := pr_vlresgat;
    pr_tab_craprej(vr_craprej).cdcritic := pr_cdcritic;
  END pc_cria_wcraprej;

  -- Procedure para escrever texto na variável CLOB do XML
  PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2                --> String que será adicionada ao CLOB
                      ,pr_clob      IN OUT NOCOPY CLOB) IS     --> CLOB que irá receber a string
  BEGIN
    dbms_lob.writeappend(pr_clob, length(pr_des_dados), pr_des_dados);
  END pc_xml_tag;

  -- Procedure para limpar o buffer da variável e imprimir seu conteúdo para o CLOB
  PROCEDURE pc_limpa_buffer(pr_buffer  IN OUT NOCOPY VARCHAR2   --> Variável com o conteúdo de buffer
                           ,pr_str     IN OUT NOCOPY CLOB) AS   --> Variável CLOB que irá receber o buffer
  BEGIN
    IF LENGTH(pr_buffer) >= 31500 THEN
      pc_xml_tag(pr_buffer, pr_str);
      pr_buffer := '';
    END IF;
  END pc_limpa_buffer;

  -- Procedure para finalizar a execução do buffer e imprimir seu conteúdo no CLOB
  PROCEDURE pc_final_buffer(pr_buffer  IN OUT NOCOPY VARCHAR2   --> Variável com o conteúdo de buffer
                           ,pr_str     IN OUT NOCOPY CLOB) AS   --> Variável CLOB que irá receber o buffer
  BEGIN
    pc_xml_tag(pr_buffer, pr_str);
    pr_buffer := '';
  END pc_final_buffer;

  -- Procedure para criar e selecionar lotes 10111, 10112 e 10113
  PROCEDURE pc_carrega_lote (pr_nrdolote IN craplot.nrdolote%type  --Numero do Lote
                            ,pr_des_reto OUT varchar2) IS          --Retorno OK/NOK
    rw_craplot_aux cr_craplot%rowtype;
  BEGIN
    -- Se ainda nao processou o lote
    IF NOT vr_tab_craplot(pr_nrdolote) THEN

      OPEN cr_craplot(pr_cdcooper, rw_crapdat.dtmvtolt, 1, 100, pr_nrdolote);
      FETCH cr_craplot INTO rw_craplot_aux;
      -- Se não existir registro vai cria-lo
      IF cr_craplot%notfound THEN
        CLOSE cr_craplot;
        BEGIN
          INSERT INTO craplot
             (dtmvtolt,
              cdagenci,
              cdbccxlt,
              nrdolote,
              tplotmov,
              cdcooper,
              nrseqdig)
          VALUES(rw_crapdat.dtmvtolt,
              1,
              100,
              pr_nrdolote,
              29,
              pr_cdcooper,
              0)
          RETURNING rowid,
                dtmvtolt,
                cdagenci,
                cdbccxlt,
                nrdolote,
                nrseqdig
          INTO rw_craplot_aux.rowid,
               rw_craplot_aux.dtmvtolt,
               rw_craplot_aux.cdagenci,
               rw_craplot_aux.cdbccxlt,
               rw_craplot_aux.nrdolote,
               rw_craplot_aux.nrseqdig;
        EXCEPTION
          WHEN others THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir em CRAPLOT. ' || sqlerrm;
            raise vr_exc_saida;
        END;
      ELSE
        CLOSE cr_craplot;
      END IF;

      --Atribuir valor selecionado/inserido para registro correto
      CASE pr_nrdolote
        WHEN 10111 THEN
          rw_craplot_10111:= rw_craplot_aux;
        WHEN 10112 THEN
          rw_craplot_10112:= rw_craplot_aux;
        WHEN 10113 THEN
          rw_craplot_10113:= rw_craplot_aux;
      END CASE;

      -- Mudar controle para true
      vr_tab_craplot(pr_nrdolote):= true;
    END IF;
    --Retorno OK
    pr_des_reto:= 'OK';
  EXCEPTION
    when others then
      pr_des_reto:= 'NOK';
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina pc_carrega_lote. '||sqlerrm;
      raise vr_exc_saida;
  END;

  /* Procedure para gerar consistência de dados para lançamento na CRAPLCI */
  PROCEDURE pc_gera_lancamentos_craplci(pr_flgctain  IN craprda.flgctain%TYPE
                                       ,pr_flgcreci  IN craplrg.flgcreci%TYPE
                                       ,pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_dtmvtolt  IN DATE
                                       ,pr_nrdconta  IN craprda.nrdconta%TYPE
                                       ,pr_tpaplrdc  IN crapdtc.tpaplrdc%TYPE
                                       ,pr_vlresgat  IN vr_vlresgat%TYPE
                                       ,pr_des_erro  IN OUT VARCHAR2
                                       ,pr_cdcritic  IN OUT NUMBER) IS
    vr_cdhistor  NUMBER;
    vr_des_reto  VARCHAR2(3);

    -- Saldos da conta investimento
    CURSOR cr_crapsli (pr_cdcooper  IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta  IN craprda.nrdconta%TYPE
                      ,pr_dtmvtolt  IN DATE) IS
      SELECT ci.ROWID
            ,count(1) over() retorno
      FROM crapsli ci
      WHERE ci.cdcooper  = pr_cdcooper
        AND ci.nrdconta  = pr_nrdconta
        AND to_char(ci.dtrefere, 'RRRRMM') = to_char(pr_dtmvtolt, 'RRRRMM');
    rw_crapsli cr_crapsli%rowtype;

  BEGIN
    IF pr_flgctain = 1 AND pr_flgcreci = 0 THEN
      -- Gera lançamentos Conta Investimento - Débito Transferência

      IF pr_tpaplrdc = 1 THEN
        vr_cdhistor := 477;
      ELSE
        vr_cdhistor := 534;
      END IF;

      -- Encontrar o lote 10111
      pc_carrega_lote (pr_nrdolote => 10111
                      ,pr_des_reto => vr_des_reto);
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        raise vr_exc_saida;
      END IF;


      -- Gera lançamento de Conta Investimento
      BEGIN
        INSERT INTO craplci(dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nrdocmto
                           ,cdhistor
                           ,vllanmto
                           ,nrseqdig
                           ,cdcooper)
          VALUES(rw_craplot_10111.dtmvtolt
                ,rw_craplot_10111.cdagenci
                ,rw_craplot_10111.cdbccxlt
                ,rw_craplot_10111.nrdolote
                ,pr_nrdconta
                ,nvl(rw_craplot_10111.nrseqdig,0) + 1
                ,vr_cdhistor
                ,pr_vlresgat
                ,nvl(rw_craplot_10111.nrseqdig,0) + 1
                ,pr_cdcooper);
      EXCEPTION
        WHEN others THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro ao inserir em CRAPLCI. ' || sqlerrm;
      END;

      -- Atualiza tabela CRAPLOT
      BEGIN
        UPDATE craplot ct
           SET ct.qtinfoln = ct.qtinfoln + 1,
               ct.qtcompln = ct.qtcompln + 1,
               ct.vlinfodb = ct.vlinfodb + pr_vlresgat,
               ct.vlcompdb = ct.vlcompdb + pr_vlresgat,
               ct.nrseqdig = nvl(rw_craplot_10111.nrseqdig,0) + 1
         WHERE ct.rowid = rw_craplot_10111.rowid
        RETURNING nrseqdig INTO rw_craplot_10111.nrseqdig;
      EXCEPTION
        WHEN others THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro ao atualizar CRAPLOT (10111). ' || sqlerrm;
      END;

      -- Encontrar o lote 10112
      pc_carrega_lote (pr_nrdolote => 10112
                      ,pr_des_reto => vr_des_reto);
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        raise vr_exc_saida;
      END IF;

      -- Gera lançamento de Conta Investimento
      BEGIN
        INSERT INTO craplci(dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nrdocmto
                           ,cdhistor
                           ,vllanmto
                           ,nrseqdig
                           ,cdcooper)
          VALUES(rw_craplot_10112.dtmvtolt
                ,rw_craplot_10112.cdagenci
                ,rw_craplot_10112.cdbccxlt
                ,rw_craplot_10112.nrdolote
                ,pr_nrdconta
                ,nvl(rw_craplot_10112.nrseqdig,0) + 1
                ,489
                ,pr_vlresgat
                ,nvl(rw_craplot_10112.nrseqdig,0) + 1
                ,pr_cdcooper);
      EXCEPTION
        WHEN others THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro ao inserir em CRAPLCI. ' || sqlerrm;
      END;

      -- Atualiza tabela CRAPLOT
      BEGIN
      UPDATE craplot ct
         SET ct.qtinfoln = ct.qtinfoln + 1,
             ct.qtcompln = ct.qtcompln + 1,
             ct.vlinfocr = ct.vlinfocr + pr_vlresgat,
             ct.vlcompcr = ct.vlcompcr + pr_vlresgat,
             ct.nrseqdig = nvl(rw_craplot_10112.nrseqdig,0) + 1
       WHERE ct.rowid = rw_craplot_10112.rowid
      RETURNING nrseqdig INTO rw_craplot_10112.nrseqdig;
      EXCEPTION
        WHEN others THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro ao atualizar em CRAPLOT (10112). ' || sqlerrm;
      END;
    END IF;

    IF pr_flgcreci = 1 THEN

      -- Encontrar o lote 10113
      pc_carrega_lote (pr_nrdolote => 10113
                      ,pr_des_reto => vr_des_reto);
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        raise vr_exc_saida;
      END IF;

      -- Gera lançamento de Conta Investimento
      BEGIN
        INSERT INTO craplci(dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nrdocmto
                           ,cdhistor
                           ,vllanmto
                           ,nrseqdig
                           ,cdcooper)
          VALUES(rw_craplot_10113.dtmvtolt
                ,rw_craplot_10113.cdagenci
                ,rw_craplot_10113.cdbccxlt
                ,rw_craplot_10113.nrdolote
                ,pr_nrdconta
                ,nvl(rw_craplot_10113.nrseqdig,0) + 1
                ,490
                ,pr_vlresgat
                ,nvl(rw_craplot_10113.nrseqdig,0) + 1
                ,pr_cdcooper);
      EXCEPTION
        WHEN others THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro ao inserir em CRAPLCI. ' || sqlerrm;
      END;

      -- Atualiza tabela CRAPLOT
      BEGIN
        UPDATE craplot ct
         SET ct.qtinfoln = ct.qtinfoln + 1,
             ct.qtcompln = ct.qtcompln + 1,
             ct.vlinfocr = ct.vlinfocr + pr_vlresgat,
             ct.vlcompcr = ct.vlcompcr + pr_vlresgat,
             ct.nrseqdig = nvl(rw_craplot_10113.nrseqdig,0) + 1
       WHERE ct.rowid = rw_craplot_10113.rowid
      RETURNING nrseqdig INTO rw_craplot_10113.nrseqdig;
      EXCEPTION
        WHEN others THEN
          pr_cdcritic := 0;
          pr_des_erro := 'Erro ao atualizar CRAPLOT (10113). ' || sqlerrm;
      END;

      -- Atualizar Saldo Conta Investimento
      OPEN cr_crapsli(pr_cdcooper, pr_nrdconta, pr_dtmvtolt);
      FETCH cr_crapsli INTO rw_crapsli;

      -- Se não encontrar registro vai cria-lo.
      -- Se encontrar vai atualizar o registro
      IF cr_crapsli%notfound OR rw_crapsli.retorno > 1 THEN
        CLOSE cr_crapsli;

        -- Calcular data de referência
        vr_dtrefere := last_day(pr_dtmvtolt);

        BEGIN
          INSERT INTO crapsli(dtrefere,
                              nrdconta,
                              cdcooper,
                              vlsddisp)
            VALUES(vr_dtrefere,
                   pr_nrdconta,
                   pr_cdcooper,
                   pr_vlresgat);
        EXCEPTION
          WHEN others THEN
            pr_cdcritic := 0;
            pr_des_erro := 'Erro ao inserir em CRAPSLI. ' || sqlerrm;
        END;
      ELSE
        CLOSE cr_crapsli;

        BEGIN
          UPDATE crapsli ci
          SET ci.vlsddisp = ci.vlsddisp + pr_vlresgat
          WHERE ci.rowid = rw_crapsli.rowid;
        EXCEPTION
          WHEN others THEN
            pr_cdcritic := 0;
            pr_des_erro := 'Erro ao atualizar CRAPSLI. ' || sqlerrm;
        END;
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Problemas na Rotina pc_gera_lancamentos_craplci ' || pr_cdcooper || '. Erro: ' || sqlerrm;
  END;

BEGIN
  -- Código do programa
  vr_cdprogra := 'CRPS478';

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS478'
                            ,pr_action => NULL);

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      raise vr_exc_saida;
    end if;
  -- Apenas fechar o cursor
  CLOSE cr_crapcop;

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;

  -- Consultar taxas de uso comum nas aplicações
  apli0001.pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);

  --Selecionar informacoes das datas
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
  --Posicionar no proximo registro
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  --Fechar Cursor
  CLOSE btch0001.cr_crapdat;

  -- Data de fim e inicio da utilização da taxa de poupança.
  -- Utiliza-se essa data quando o rendimento da aplicação for menor que
  -- a poupança, a cooperativa opta por usar ou não.
  -- Buscar a descrição das faixas contido na craptab
  vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'USUARI'
                                           ,pr_cdempres => 11
                                           ,pr_cdacesso => 'MXRENDIPOS'
                                           ,pr_tpregist => 1);
  -- Se não encontrar registros
  IF vr_dstextab IS NULL THEN
    vr_dtinitax := to_date('01/01/9999', 'dd/mm/yyyy');
    vr_dtfimtax := to_date('01/01/9999', 'dd/mm/yyyy');
  ELSE
    vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab, ';'), 'DD/MM/YYYY');
    vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab, ';'), 'DD/MM/YYYY');
  END IF;

  -- Carregar Contas Bloqueadas para resgate
  FOR rw_craptab IN cr_craptab (pr_cdcooper  => pr_cdcooper          --> Código da cooperativa
                               ,pr_nmsistem  => 'CRED'               --> Tipo do sistema
                               ,pr_tptabela  => 'BLQRGT'             --> Tipo da tabela
                               ,pr_cdempres  => 0) LOOP              --> Código empresa
    -- Montar Indice para contas bloqueadas
    vr_index_craptab:= lpad(to_char(rw_craptab.cdacesso), 10, '0')||
                       lpad(to_char(rw_craptab.dstextab), 7, '0');
    vr_tab_craptab(vr_index_craptab):= 0;
  END LOOP;

  -- Marcar Lotes 10111, 10112 e 10113
  FOR idx IN 10111..10113 LOOP
    vr_tab_craplot(idx):= FALSE;
  END LOOP;

  vr_regexist := FALSE;

  -- Iterar sobre os resultados do cursor
  FOR rw_craplrg IN cr_craplrg(pr_cdcooper, rw_crapdat.dtmvtolt) LOOP

    -- Savepoint para criar ponto de salvamento e desfazer iteração do laço
    SAVEPOINT initFor;
    BEGIN
      -- Busca dos tipos de captação oferecidas aos cooperados
      OPEN cr_crapdtc(pr_cdcooper, rw_craplrg.tpaplica);
      FETCH cr_crapdtc INTO rw_crapdtc;
      -- Se não encontrar informação, descarta o registro
      if cr_crapdtc%notfound then
        close cr_crapdtc;
        continue;
      end if;
      CLOSE cr_crapdtc;
    EXCEPTION
      WHEN others THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Problema ao consultar tabela CRAPDTC. ' || sqlerrm;
        RAISE;
    END;

    -- Atribuição de valores iniciais para as variáveis.
    vr_cdcritic := 0;
    vr_vlresgat := 0;
    vr_saldorda := 0;
    vr_vllan531 := 0;
    vr_vllan529 := 0;
    vr_vllan532 := 0;
    vr_vllan533 := 0;
    vr_vllan534 := 0;
    vr_vlrendmm := 0;
    vr_vlrvtfim := 0;
    vr_vlrnmmrg := 0;
    vr_rdulmtmm := 0;
    vr_vlbasrgt := 0;
    vr_vlsolrgt := 0;
    vr_contapli := 9;

    -- Testar cursor e fecha caso esteja aberto.
    IF btch0001.cr_craptab%isopen THEN
      CLOSE btch0001.cr_craptab;
    END IF;

    --Testa se a aplicação está disponível para saque
    -- Busca parâmetros de inicialização
    vr_index_craptab:= lpad(to_char(rw_craplrg.nrdconta), 10, '0')||
                       lpad(to_char(rw_craplrg.nraplica), 7, '0');
    if vr_tab_craptab.EXISTS(vr_index_craptab) then
      vr_cdcritic := 640;
      -- Cria entrada na tabela
      -- Iniciar LOG de execução
      pc_cria_craprej (pr_cdcooper  => pr_cdcooper
                      ,pr_nrdconta  => rw_craplrg.nrdconta
                      ,pr_nraplica  => rw_craplrg.nraplica
                      ,pr_dtmvtolt  => rw_craplrg.dtmvtolt
                      ,pr_vllanmto  => rw_craplrg.vllanmto
                      ,pr_saldorda  => vr_saldorda
                      ,pr_vlresgat  => vr_vlresgat
                      ,pr_cdcritic  => vr_cdcritic
                      ,pr_gdtmvtol  => rw_crapdat.dtmvtolt
                      ,pr_des_erro  => vr_dscritic);
      IF vr_dscritic NOT IN ('OK') THEN
        -- Desvia para a exceção para interromper o programa com o erro retornado pela procedure
        raise vr_exc_saida;
      END IF;

      continue;
    end if;

    -- Busca aplicações RDCA
    OPEN cr_craprda(pr_cdcooper, rw_craplrg.nrdconta, rw_craplrg.nraplica);
    FETCH cr_craprda INTO rw_craprda;

    -- Caso não encontre registro ou se encontrar mais que um regristro gera crítica 426.
    -- Caso encontre registro inicia sequencia de testes para gerar críticas diferenciadas
    IF cr_craprda%NOTFOUND OR rw_craprda.retorno > 1 THEN
      vr_cdcritic := 426;
      CLOSE cr_craprda;
    ELSE
      IF rw_craprda.insaqtot = 1 THEN
        vr_cdcritic := 428;
      ELSIF rw_craprda.vlsdrdca < 0 THEN
        vr_cdcritic := 269;
      ELSIF rw_craplrg.tpresgat = 1
          AND rw_crapdtc.tpaplrdc = 1
          AND (rw_craprda.vlsdrdca - rw_craplrg.vllanmto) < rw_crapdtc.vlminapl THEN
        vr_cdcritic := 913;
      END IF;
      CLOSE cr_craprda;
    END IF;

    -- Caso tenha gerado alguma crítica no processo acima grava dados na tabela
    IF vr_cdcritic > 0 THEN
      pc_cria_craprej (pr_cdcooper  => pr_cdcooper
                      ,pr_nrdconta  => rw_craplrg.nrdconta
                      ,pr_nraplica  => rw_craplrg.nraplica
                      ,pr_dtmvtolt  => rw_craplrg.dtmvtolt
                      ,pr_vllanmto  => rw_craplrg.vllanmto
                      ,pr_saldorda  => vr_saldorda
                      ,pr_vlresgat  => vr_vlresgat
                      ,pr_cdcritic  => vr_cdcritic
                      ,pr_gdtmvtol  => rw_crapdat.dtmvtolt
                      ,pr_des_erro  => vr_dscritic);

      IF vr_dscritic NOT IN ('OK') THEN
        vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                       ' - Faltam dados na execução pc_cria_craprej.';
        RAISE vr_exc_saida;
      END IF;

      continue;
    END IF;

    -- Busca lançamentos de aplicações RDCA
    OPEN cr_craplap(pr_cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, rw_craprda.dtmvtolt);
    FETCH cr_craplap INTO rw_craplap;

    -- Se não encontrar registros gera crítica e grava em tabela
    IF cr_craplap%NOTFOUND THEN
      vr_cdcritic := 90;
      CLOSE cr_craplap;

      pc_cria_craprej (pr_cdcooper  => pr_cdcooper
                      ,pr_nrdconta  => rw_craplrg.nrdconta
                      ,pr_nraplica  => rw_craplrg.nraplica
                      ,pr_dtmvtolt  => rw_craplrg.dtmvtolt
                      ,pr_vllanmto  => rw_craplrg.vllanmto
                      ,pr_saldorda  => vr_saldorda
                      ,pr_vlresgat  => vr_vlresgat
                      ,pr_cdcritic  => vr_cdcritic
                      ,pr_gdtmvtol  => rw_crapdat.dtmvtolt
                      ,pr_des_erro  => vr_dscritic);

      IF vr_dscritic NOT IN ('OK') THEN
        vr_cdcritic := 0;
        vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                       ' - Faltam dados na execução pc_cria_craprej.';
        RAISE vr_exc_saida;
      END IF;

      continue;
    ELSE
      CLOSE cr_craplap;
    END IF;

    -- Atribui valores de taxas
    vr_txaplica := rw_craplap.txaplica;
    vr_txaplmes := rw_craplap.txaplmes;

    -- Teste e carrega valores nas variáveis
    IF rw_craplrg.tpresgat = 1 THEN
      vr_vlresgat := rw_craplrg.vllanmto;
    ELSE
      vr_vlresgat := rw_craprda.vlsdrdca;
    END IF;

    -- Carrega valor de saldo
    vr_saldorda := rw_craprda.vlsdrdca;

    -- Gerar lançamento do resgate
    OPEN cr_craplot (pr_cdcooper, rw_crapdat.dtmvtolt, 1, 100, 8479);
    FETCH cr_craplot INTO rw_craplot;

    -- Se não existir registros faz insert na tabela CRAPLOT
    -- Caso exista registro faz o update
    IF cr_craplot%NOTFOUND THEN
      CLOSE cr_craplot;

      BEGIN
        INSERT INTO craplot(dtmvtolt,
                            cdagenci,
                            cdbccxlt,
                            nrdolote,
                            tplotmov,
                            cdcooper,
                            nrseqdig)
        VALUES(rw_crapdat.dtmvtolt,
               1,
               100,
               8479,
               9,
               pr_cdcooper,
               0)
        RETURNING cdagenci, dtmvtolt, cdbccxlt, nrdolote, tplotmov, rowid, nrseqdig
             INTO rw_craplot.cdagenci,
                  rw_craplot.dtmvtolt,
                  rw_craplot.cdbccxlt,
                  rw_craplot.nrdolote,
                  rw_craplot.tplotmov,
                  rw_craplot.rowid,
                  rw_craplot.nrseqdig;
      EXCEPTION
        WHEN others THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Problema ao inserir na tabela CRAPLOT. ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
    ELSE
      CLOSE cr_craplot;
    END IF;

    -- Teste valor e faz atribuição de variáveis
    BEGIN
      IF rw_crapdtc.tpaplrdc = 1 THEN
        vr_atxaplmes := 0;
        vr_acdhistor := 477;
        vr_vllan534 := 0;
      ELSE
        vr_atxaplmes := vr_txaplmes;
        vr_acdhistor := 534;
        vr_vllan534 := vr_vlresgat;
      END IF;

      -- Inserindo dados na tabela CRAPLAP
      INSERT INTO craplap(dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,nrdconta
                         ,nraplica
                         ,nrdocmto
                         ,txaplica
                         ,txaplmes
                         ,cdhistor
                         ,nrseqdig
                         ,dtrefere
                         ,vllanmto
                         ,cdcooper)
        VALUES(rw_craplot.dtmvtolt
              ,rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt
              ,rw_craplot.nrdolote
              ,rw_craprda.nrdconta
              ,rw_craprda.nraplica
              ,rw_craplot.nrseqdig + 1
              ,vr_atxaplmes
              ,vr_atxaplmes
              ,vr_acdhistor
              ,rw_craplot.nrseqdig + 1
              ,rw_craprda.dtfimper
              ,vr_vlresgat
              ,pr_cdcooper) RETURNING ROWID INTO rw_craplap.rowid;
    EXCEPTION
      WHEN others THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Problema ao inserir na tabela CRAPLAP. ' || sqlerrm;
        RAISE vr_exc_saida;
    END;

    -- Atualizar CRAPLOT
    BEGIN
      UPDATE craplot co
      SET co.vlinfodb = co.vlinfodb + vr_vlresgat
         ,co.vlcompdb = co.vlcompdb + vr_vlresgat
         ,co.qtinfoln = co.qtinfoln + 1
         ,co.qtcompln = co.qtcompln + 1
         ,co.nrseqdig = co.nrseqdig + 1
      WHERE co.ROWID = rw_craplot.ROWID
       RETURNING co.vlinfodb, co.vlcompdb, co.qtinfoln, co.qtcompln, co.nrseqdig
        INTO rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.qtinfoln, rw_craplot.qtcompln, rw_craplot.nrseqdig;
    EXCEPTION
      WHEN others THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar CRAPLOT. ' || sqlerrm;
        RAISE vr_exc_saida;
    END;

    -- Teste e em caso TRUE executa a procedure de ajuste de provisão para RDC PRE
    IF rw_crapdtc.tpaplrdc = 1 THEN
      -- Calculo do ajuste da provisao a estornar nos casos de resgate antes do vencimento.
      -- Caso a procedure tenha retornado erro gera log e levanta a exceção
      apli0001.pc_ajuste_provisao_rdc_pre (pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => 1
                                          ,pr_nrdcaixa => 999
                                          ,pr_nrctaapl => rw_craprda.nrdconta
                                          ,pr_nraplres => rw_craprda.nraplica
                                          ,pr_vllanmto => vr_vlresgat
                                          ,pr_vlestprv => vr_vlestprv
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tab_erro => vr_tab_erro);

      IF vr_des_reto = 'NOK' THEN
        vr_cdcritic := 0;
        vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' - ' || vr_cdprogra || ' --> ' || vr_tab_erro(vr_tab_erro.first).dscritic ||
                       ' - Faltam dados na execução PC_AJUSTE_PROVISAO_RDC_PRE' ||
                       GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) || ' ' ||
                       GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9');
        RAISE vr_exc_saida;
      END IF;

      -- Teste e agrega valores para as variáveis
      IF vr_vlestprv > 0 THEN
        vr_cdhistor := 463;
        vr_dtrefere := rw_craprda.dtfimper;
        vr_txapllap := vr_txaplica;
        vr_vllanmto := vr_vlestprv;
        vr_nrdocmto := rw_craplot.nrseqdig + 1;

        -- Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS para débito
        apli0001.pc_gera_craplap_rdc (pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                     ,pr_cdagenci => rw_craplot.cdagenci
                                     ,pr_nrdcaixa => 999
                                     ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                     ,pr_nrdolote => rw_craplot.nrdolote
                                     ,pr_nrdconta => rw_craprda.nrdconta
                                     ,pr_nraplica => rw_craprda.nraplica
                                     ,pr_nrdocmto => vr_nrdocmto
                                     ,pr_txapllap => vr_txapllap
                                     ,pr_cdhistor => vr_cdhistor
                                     ,pr_nrseqdig => rw_craplot.nrseqdig
                                     ,pr_vllanmto => vr_vllanmto
                                     ,pr_dtrefere => vr_dtrefere
                                     ,pr_vlrendmm => vr_vlrendmm
                                     ,pr_tipodrdb => 'D'
                                     ,pr_rowidlot => rw_craplot.ROWID
                                     ,pr_rowidlap => rw_craplap.ROWID
                                     ,pr_vlinfodb => rw_craplot.vlinfodb
                                     ,pr_vlcompdb => rw_craplot.vlcompdb
                                     ,pr_qtinfoln => rw_craplot.qtinfoln
                                     ,pr_qtcompln => rw_craplot.qtcompln
                                     ,pr_vlinfocr => rw_craplot.vlinfocr
                                     ,pr_vlcompcr => rw_craplot.vlcompcr
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro);

        IF vr_des_reto NOT IN ('OK') THEN
          vr_cdcritic := 0;
          vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdprogra || ' - ' || vr_tab_erro(vr_tab_erro.count).dscritic;

          RAISE vr_exc_saida;
        END IF;
      END IF;
    ELSIF rw_crapdtc.tpaplrdc = 2 THEN
      -- Verifica se aplicacao esta em carência e não permite vários saques
      -- parciais no mesmo dia deixando a aplicação zerada durante a carência.
      IF (rw_craplrg.dtmvtolt - rw_craprda.dtmvtolt) < rw_craprda.qtdiauti
         AND rw_craplrg.vllanmto <> 0
         AND rw_craprda.vlsdrdca - rw_craplrg.vllanmto <= 0 THEN
        vr_cdcritic := 913;

        -- Desfazer as transações pendentes de COMMIT
        ROLLBACK TO SAVEPOINT initFor;

        -- Cria registro na TEMP TABLE para emissão de relatório de saída
        pc_cria_craprej (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_craplrg.nrdconta,
                         pr_nraplica => rw_craplrg.nraplica,
                         pr_dtmvtolt => rw_craplrg.dtmvtolt,
                         pr_vllanmto => rw_craplrg.vllanmto,
                         pr_saldorda => vr_saldorda,
                         pr_vlresgat => vr_vlresgat,
                         pr_cdcritic => vr_cdcritic,
                         pr_gdtmvtol => rw_crapdat.dtmvtolt,
                         pr_des_erro => vr_dscritic);

        IF vr_dscritic NOT IN ('OK') THEN
          RAISE vr_exc_saida;
        END IF;

        -- Passar para o próximo registro do loop na craplrg
        continue;
      END IF;

      -- Incluido nova rotina de calculo de saldo para o caso de haver
      -- dois resgates parciais para o mesmo dia
      apli0001.pc_saldo_rgt_rdc_pos (pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => 1
                                    ,pr_nrdcaixa => 999
                                    ,pr_nrctaapl => rw_craprda.nrdconta
                                    ,pr_nraplres => rw_craprda.nraplica
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dtaplrgt => rw_crapdat.dtmvtolt
                                    ,pr_vlsdorgt => 0
                                    ,pr_flggrvir => FALSE
                                    ,pr_dtinitax => vr_dtinitax
                                    ,pr_dtfimtax => vr_dtfimtax
                                    ,pr_vlsddrgt => vr_sldpresg
                                    ,pr_vlrenrgt => vr_vlrenrgt
                                    ,pr_vlrdirrf => vr_vlrdirrf
                                    ,pr_perirrgt => vr_perirrgt
                                    ,pr_vlrgttot => vr_vlrrgtot
                                    ,pr_vlirftot => vr_vlirftot
                                    ,pr_vlrendmm => vr_vlrendmm
                                    ,pr_vlrvtfim => vr_vlrvtfim
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);

      -- Gera raise e levanta exceção, caso a variável de erro retorne 'NOK'
      IF vr_des_reto = 'NOK' THEN
        vr_cdcritic := 0;
        vr_dscritic := TO_CHAR(SYSDATE,'HH24:MI:SS') ||
                       ' - ' || vr_cdprogra || ' --> ' || vr_tab_erro(vr_tab_erro.count).dscritic ||
                       ' - Faltam dados na execução PC_SALDO_RGT_RDC_POS.' ||
                       GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) || ' ' ||
                       GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9');
        RAISE vr_exc_saida;
      END IF;

      -- Compara valor calculado pela procedure com valor retornado do banco
      IF vr_vlrrgtot < rw_craplrg.vllanmto THEN
        vr_cdcritic := 717;
        vr_saldorda := vr_vlrrgtot;

        -- Cria registro na TEMP TABLE para emissão de relatório de saída
        -- e retorna para o início
        pc_cria_wcraprej (pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_nrdconta => rw_craplrg.nrdconta
                         ,pr_nraplica => rw_craplrg.nraplica
                         ,pr_aviso    => rw_craplrg.dtmvtolt
                         ,pr_vldaviso => rw_craplrg.vllanmto
                         ,pr_saldorda => vr_saldorda
                         ,pr_vlresgat => vr_vlresgat
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_tab_craprej => vr_tab_craprej);

        ROLLBACK TO SAVEPOINT initFor;
        continue;
      END IF;
      -- Se solicitado o resgate total
      IF rw_craplrg.vllanmto = 0 THEN
        -- Resgataremos o saldo total da aplicação
        vr_vlsolrgt := vr_vlrrgtot;
      ELSE
        -- Resgataremos o valor solicitado
        vr_vlsolrgt := rw_craplrg.vllanmto;
      END IF;

      -- Calcular o valor real a ser resgatado quando não esta na carência.
      IF rw_crapdat.dtmvtolt - rw_craprda.dtmvtolt < rw_craprda.qtdiauti THEN
        vr_vlbasrgt := rw_craplrg.vllanmto;
      ELSE
        -- Executa procedure para calcular quanto o que esta sendo resgatado representa do total.
        apli0001.pc_valor_original_resgatado(pr_cdcooper => pr_cdcooper
                                            ,pr_cdagenci => 1
                                            ,pr_nrdcaixa => 999
                                            ,pr_nrctaapl => rw_craprda.nrdconta
                                            ,pr_nraplres => rw_craprda.nraplica
                                            ,pr_dtaplrgt => rw_crapdat.dtmvtolt
                                            ,pr_vlsdrdca => vr_vlsolrgt
                                            ,pr_perirrgt => vr_perirrgt
                                            ,pr_dtinitax => vr_dtinitax
                                            ,pr_dtfimtax => vr_dtfimtax
                                            ,pr_vlbasrgt => vr_vlbasrgt
                                            ,pr_des_reto => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);

        -- Gera raise e levanta exceção, caso a variável de erro retorne 'OK'
        IF vr_des_reto = 'NOK' THEN
          vr_cdcritic := 0;
          vr_dscritic := TO_CHAR(SYSDATE,'HH24:MI:SS') ||
                         ' - ' || vr_cdprogra || ' --> ' || vr_tab_erro(vr_tab_erro.count).dscritic ||
                         ' - Faltam dados na execução PC_VALOR_ORIGINAL_RESGATADO.' ||
                         GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) || ' ' ||
                         GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9');
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Update do registro na CRAPLAP
      -- gravando o valor base para o resgate
      BEGIN
        UPDATE craplap cp
        SET cp.vlpvlrgt = vr_vlbasrgt
        WHERE cp.ROWID = rw_craplap.ROWID
         RETURNING cp.vlpvlrgt
          INTO rw_craplap.vlpvlrgt;
      EXCEPTION
        WHEN others THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPLAP. ' || sqlerrm;
          RAISE vr_exc_saida;
      END;

      -- Somente verificar rendimentos, provisão, reversão e irrf no caso do valor
      -- do resgate após o calculo do valor original para resgate estar diferente de zero
      -- OU
      -- Se for uma aplicação em carência
      -- Obs: Isto corrige o problema de resgates baixos onde o calculo
      --      do valor original resgatado estava zerando o valor a resgatar
      --      fazendo as rotinas abaixo considerar o resgate como total
      IF vr_vlbasrgt > 0 OR rw_crapdat.dtmvtolt - rw_craprda.dtmvtolt < rw_craprda.qtdiauti THEN
        -- Executa procedure para calculo do saldo das aplicacoes RDC POS para resgate com IRPF.
        apli0001.pc_saldo_rgt_rdc_pos (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => 1
                                      ,pr_nrdcaixa => 999
                                      ,pr_nrctaapl => rw_craprda.nrdconta
                                      ,pr_nraplres => rw_craprda.nraplica
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dtaplrgt => rw_crapdat.dtmvtolt
                                      ,pr_vlsdorgt => vr_vlbasrgt
                                      ,pr_flggrvir => FALSE
                                      ,pr_dtinitax => vr_dtinitax
                                      ,pr_dtfimtax => vr_dtfimtax
                                      ,pr_vlsddrgt => vr_sldpresg
                                      ,pr_vlrenrgt => vr_vlrenrgt
                                      ,pr_vlrdirrf => vr_vlrdirrf
                                      ,pr_perirrgt => vr_perirrgt
                                      ,pr_vlrgttot => vr_vlrrgtot
                                      ,pr_vlirftot => vr_vlirftot
                                      ,pr_vlrendmm => vr_vlrendmm
                                      ,pr_vlrvtfim => vr_vlrvtfim
                                      ,pr_des_reto => vr_des_reto
                                      ,pr_tab_erro => vr_tab_erro);
        -- Gera raise e levanta exceção, caso a variável de erro retorne 'NOK'
        IF vr_des_reto = 'NOK' THEN
          vr_cdcritic := 0;
          vr_dscritic := TO_CHAR(SYSDATE,'HH24:MI:SS') ||
                         ' - ' || vr_cdprogra || ' --> ' || vr_tab_erro(vr_tab_erro.count).dscritic ||
                         ' - Faltam dados na execução PC_SALDO_RGT_RDC_POS. ' ||
                         GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) || ' ' ||
                         GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9');
          RAISE vr_exc_saida;
        END IF;
      ELSE
        -- Limpar variáveis pois não será calculado rendimento
        -- quando o valor base estiver zerado
        vr_sldpresg := 0;
        vr_vlrenrgt := 0;
        vr_vlrdirrf := 0;
        vr_perirrgt := 0;
        vr_vlrrgtot := 0;
        vr_vlirftot := 0;
        vr_vlrendmm := 0;
        vr_vlrvtfim := 0;
      END IF;

      -- Resgate total
      -- Atualizar valores na CRAPLAP e CRAPLOT
      IF rw_craplrg.tpresgat = 2 THEN
        vr_vllan534 := vr_vlsolrgt;

        -- Atualiza CRAPLAP
        BEGIN
          UPDATE craplap cl
          SET cl.vllanmto = vr_vlsolrgt
          WHERE cl.ROWID = rw_craplap.ROWID
           RETURNING cl.vllanmto
            INTO rw_craplap.vllanmto;
        EXCEPTION
          WHEN others THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar CRAPLAP. ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

        -- Atualiza os campos da CRAPLOT retornando os novos resultados para o RESULTSET
        BEGIN
          UPDATE craplot co
          SET co.vlinfodb = co.vlinfodb - vr_vlresgat + vr_vlsolrgt
             ,co.vlcompdb = co.vlcompdb - vr_vlresgat + vr_vlsolrgt
          WHERE co.ROWID = rw_craplot.ROWID
           RETURNING co.vlinfodb, co.vlcompdb
            INTO rw_craplot.vlinfodb, rw_craplot.vlcompdb;
        EXCEPTION
          WHEN others THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar CRAPLOT. ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

        vr_vlresgat := vr_vlsolrgt;
      END IF;

      -- Rendimento
      IF vr_vlrenrgt > 0 THEN
        vr_cdhistor := 532;
        vr_vllanmto := vr_vlrenrgt;
        vr_vllan532 := vr_vllanmto;
        vr_dtrefere := rw_craprda.dtfimper;
        vr_txapllap := vr_txaplmes;
        vr_nrdocmto := rw_craplot.nrseqdig + 1;

        -- Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS para crédito
        apli0001.pc_gera_craplap_rdc (pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                     ,pr_cdagenci => rw_craplot.cdagenci
                                     ,pr_nrdcaixa => 999
                                     ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                     ,pr_nrdolote => rw_craplot.nrdolote
                                     ,pr_nrdconta => rw_craprda.nrdconta
                                     ,pr_nraplica => rw_craprda.nraplica
                                     ,pr_nrdocmto => vr_nrdocmto
                                     ,pr_txapllap => vr_txapllap
                                     ,pr_cdhistor => vr_cdhistor
                                     ,pr_nrseqdig => rw_craplot.nrseqdig
                                     ,pr_vllanmto => vr_vllanmto
                                     ,pr_dtrefere => vr_dtrefere
                                     ,pr_vlrendmm => vr_vlrendmm
                                     ,pr_tipodrdb => 'C'
                                     ,pr_rowidlot => rw_craplot.ROWID
                                     ,pr_rowidlap => rw_craplap.ROWID
                                     ,pr_vlinfodb => rw_craplot.vlinfodb
                                     ,pr_vlcompdb => rw_craplot.vlcompdb
                                     ,pr_qtinfoln => rw_craplot.qtinfoln
                                     ,pr_qtcompln => rw_craplot.qtcompln
                                     ,pr_vlinfocr => rw_craplot.vlinfocr
                                     ,pr_vlcompcr => rw_craplot.vlcompcr
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro);

        IF vr_des_reto NOT IN ('OK') THEN
          vr_cdcritic := 0;
          vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdprogra || ' - ' || vr_tab_erro(vr_tab_erro.count).dscritic;

          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- IRRF
      IF vr_vlrdirrf > 0 THEN
        vr_cdhistor := 533;
        vr_vllanmto := vr_vlrdirrf;
        vr_vllan533 := vr_vllanmto;
        vr_txapllap := vr_perirrgt;
        vr_nrdocmto := rw_craplot.nrseqdig + 1;

        -- Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS para débito
        apli0001.pc_gera_craplap_rdc (pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                     ,pr_cdagenci => rw_craplot.cdagenci
                                     ,pr_nrdcaixa => 999
                                     ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                     ,pr_nrdolote => rw_craplot.nrdolote
                                     ,pr_nrdconta => rw_craprda.nrdconta
                                     ,pr_nraplica => rw_craprda.nraplica
                                     ,pr_nrdocmto => vr_nrdocmto
                                     ,pr_txapllap => vr_txapllap
                                     ,pr_cdhistor => vr_cdhistor
                                     ,pr_nrseqdig => rw_craplot.nrseqdig
                                     ,pr_vllanmto => vr_vllanmto
                                     ,pr_dtrefere => vr_dtrefere
                                     ,pr_vlrendmm => vr_vlrendmm
                                     ,pr_tipodrdb => 'D'
                                     ,pr_rowidlot => rw_craplot.ROWID
                                     ,pr_rowidlap => rw_craplap.ROWID
                                     ,pr_vlinfodb => rw_craplot.vlinfodb
                                     ,pr_vlcompdb => rw_craplot.vlcompdb
                                     ,pr_qtinfoln => rw_craplot.qtinfoln
                                     ,pr_qtcompln => rw_craplot.qtcompln
                                     ,pr_vlinfocr => rw_craplot.vlinfocr
                                     ,pr_vlcompcr => rw_craplot.vlcompcr
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro);

        IF vr_des_reto NOT IN ('OK') THEN
          vr_cdcritic := 0;
          vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdprogra || ' - ' || vr_tab_erro(vr_tab_erro.count).dscritic;

          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Ajustes para resgate antecipado
      IF to_char(rw_craprda.dtmvtolt, 'YYYYMM') != to_char(rw_crapdat.dtmvtolt, 'YYYYMM') THEN

        vr_dtiniper := rw_craprda.dtatslmm;
        vr_dtfimper := rw_crapdat.dtmvtolt;
        vr_dtrefere := rw_craprda.dtfimper;

        -- Calcular a provisão a taxa mínima para o caso de resgates antes do vencimento
        apli0001.pc_provisao_rdc_pos(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => 1
                                    ,pr_nrdcaixa => 999
                                    ,pr_nrctaapl => rw_craprda.nrdconta
                                    ,pr_nraplres => rw_craprda.nraplica
                                    ,pr_dtiniper => vr_dtiniper
                                    ,pr_dtfimper => vr_dtfimper
                                    ,pr_dtinitax => vr_dtinitax
                                    ,pr_dtfimtax => vr_dtfimtax
                                    ,pr_flantven => TRUE
                                    ,pr_vlsdrdca => vr_vlsldrdc
                                    ,pr_vlrentot => vr_vllanmto
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);

        -- Gera raise e levanta exceção, caso a variável de erro retorne 'NOK'
        IF vr_des_reto = 'NOK' THEN
          vr_cdcritic := 0;
          vr_dscritic := TO_CHAR(SYSDATE,'HH24:MI:SS') ||
                         ' - ' || vr_cdprogra || ' --> ' || vr_tab_erro(vr_tab_erro.count).dscritic ||
                         ' - Faltam dados na execução PC_PROVISAO_RDC_POS. ' ||
                         GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) || ' ' ||
                         GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9');
          RAISE vr_exc_saida;
        END IF;

        vr_vlrendmm := vr_vllanmto;

        -- Calcular pela taxa máxima
        apli0001.pc_provisao_rdc_pos(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => 1
                                    ,pr_nrdcaixa => 999
                                    ,pr_nrctaapl => rw_craprda.nrdconta
                                    ,pr_nraplres => rw_craprda.nraplica
                                    ,pr_dtiniper => vr_dtiniper
                                    ,pr_dtfimper => vr_dtfimper
                                    ,pr_dtinitax => vr_dtinitax
                                    ,pr_dtfimtax => vr_dtfimtax
                                    ,pr_flantven => FALSE
                                    ,pr_vlsdrdca => vr_vlsldrdc
                                    ,pr_vlrentot => vr_vllanmto
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        -- Provisão até resgate
        IF vr_vllanmto != 0 THEN
          vr_cdhistor := 529;
          vr_vllan529 := vr_vllanmto;
          vr_vlrvtfim := vr_vlrvtfim + vr_vllanmto;
          vr_txapllap := vr_txaplica;
          vr_nrdocmto := rw_craplot.nrseqdig + 1;

          -- Gerar lançamento de crédito
          apli0001.pc_gera_craplap_rdc (pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                       ,pr_cdagenci => rw_craplot.cdagenci
                                       ,pr_nrdcaixa => 999
                                       ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                       ,pr_nrdolote => rw_craplot.nrdolote
                                       ,pr_nrdconta => rw_craprda.nrdconta
                                       ,pr_nraplica => rw_craprda.nraplica
                                       ,pr_nrdocmto => vr_nrdocmto
                                       ,pr_txapllap => vr_txapllap
                                       ,pr_cdhistor => vr_cdhistor
                                       ,pr_nrseqdig => rw_craplot.nrseqdig
                                       ,pr_vllanmto => vr_vllanmto
                                       ,pr_dtrefere => vr_dtrefere
                                       ,pr_vlrendmm => vr_vlrendmm
                                       ,pr_tipodrdb => 'C'
                                       ,pr_rowidlot => rw_craplot.ROWID
                                       ,pr_rowidlap => rw_craplap.ROWID
                                       ,pr_vlinfodb => rw_craplot.vlinfodb
                                       ,pr_vlcompdb => rw_craplot.vlcompdb
                                       ,pr_qtinfoln => rw_craplot.qtinfoln
                                       ,pr_qtcompln => rw_craplot.qtcompln
                                       ,pr_vlinfocr => rw_craplot.vlinfocr
                                       ,pr_vlcompcr => rw_craplot.vlcompcr
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);

          -- Verifica se ocorreram erros
          IF vr_des_reto NOT IN ('OK') THEN
            vr_cdcritic := 0;
            vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdprogra || ' - ' || vr_tab_erro(vr_tab_erro.count).dscritic;

            RAISE vr_exc_saida;
          END IF;
        END IF;
      END IF;

      vr_vlsldrdc := rw_craprda.vlsdrdca - vr_vlresgat;

      -- Não é resgate total
      IF rw_craplrg.tpresgat <> 2 AND
         to_char(rw_crapdat.dtmvtolt, 'RRRRMM') != to_char(rw_craprda.dtmvtolt, 'RRRRMM') THEN
        vr_dtmvtolt := rw_crapdat.dtmvtolt;

        -- Quanto o que foi resgatado rendeu até a data para retirar da provisão a taxa minima
        -- para corrigir o campo craplap.vlrendmm preciso guardar o quanto rendeu a aplicacão a
        -- taxa minima do última atualização ate a data do resgate.
        vr_rdulmtmm := vr_vlrendmm;

        apli0001.pc_rendi_apl_pos_com_resgate (pr_cdcooper => pr_cdcooper
                                              ,pr_cdagenci => 1
                                              ,pr_nrdcaixa => 999
                                              ,pr_nrctaapl => rw_craprda.nrdconta
                                              ,pr_nraplres => rw_craprda.nraplica
                                              ,pr_dtaplrgt => rw_crapdat.dtmvtolt /* Data resgate */
                                              ,pr_dtinitax => vr_dtinitax
                                              ,pr_dtfimtax => vr_dtfimtax
                                              ,pr_vlsdrdca => vr_vlbasrgt
                                              ,pr_flantven => TRUE /* Taxa mínima */
                                              ,pr_vlrenrgt => vr_vlrendmm
                                              ,pr_des_reto => vr_des_reto
                                              ,pr_tab_erro => vr_tab_erro);

        apli0001.pc_rendi_apl_pos_com_resgate (pr_cdcooper => pr_cdcooper
                                              ,pr_cdagenci => 1
                                              ,pr_nrdcaixa => 999
                                              ,pr_nrctaapl => rw_craprda.nrdconta
                                              ,pr_nraplres => rw_craprda.nraplica
                                              ,pr_dtaplrgt => rw_crapdat.dtmvtolt /* Data resgate */
                                              ,pr_dtinitax => vr_dtinitax
                                              ,pr_dtfimtax => vr_dtfimtax
                                              ,pr_vlsdrdca => vr_vlbasrgt
                                              ,pr_flantven => FALSE /* Taxa máxima */
                                              ,pr_vlrenrgt => vr_vlrenapl
                                              ,pr_des_reto => vr_des_reto
                                              ,pr_tab_erro => vr_tab_erro);

        -- Quando gera o CRAPLAP com 531 que e reversão do que já foi
        -- provisionado preciso tirar também o quanto do minimo já foi
        -- provisionado usando aux_vlrendmm
        IF vr_vlrenapl != 0 THEN
          vr_cdhistor := 531; /* prov. ate resgate */
          vr_vllanmto := vr_vlrenapl;
          vr_vllan531 := vr_vllanmto;
          vr_txapllap := vr_txaplica;
          vr_nrdocmto := rw_craplot.nrseqdig + 1;

          -- Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS para débito
          apli0001.pc_gera_craplap_rdc (pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                       ,pr_cdagenci => rw_craplot.cdagenci
                                       ,pr_nrdcaixa => 999
                                       ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                       ,pr_nrdolote => rw_craplot.nrdolote
                                       ,pr_nrdconta => rw_craprda.nrdconta
                                       ,pr_nraplica => rw_craprda.nraplica
                                       ,pr_nrdocmto => vr_nrdocmto
                                       ,pr_txapllap => vr_txapllap
                                       ,pr_cdhistor => vr_cdhistor
                                       ,pr_nrseqdig => rw_craplot.nrseqdig
                                       ,pr_vllanmto => vr_vllanmto
                                       ,pr_dtrefere => vr_dtrefere
                                       ,pr_vlrendmm => vr_vlrendmm
                                       ,pr_tipodrdb => 'D'
                                       ,pr_rowidlot => rw_craplot.ROWID
                                       ,pr_rowidlap => rw_craplap.ROWID
                                       ,pr_vlinfodb => rw_craplot.vlinfodb
                                       ,pr_vlcompdb => rw_craplot.vlcompdb
                                       ,pr_qtinfoln => rw_craplot.qtinfoln
                                       ,pr_qtcompln => rw_craplot.qtcompln
                                       ,pr_vlinfocr => rw_craplot.vlinfocr
                                       ,pr_vlcompcr => rw_craplot.vlcompcr
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);

          -- Verifica se ocorreram erros
          IF vr_des_reto NOT IN ('OK') THEN
            vr_cdcritic := 0;
            vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdprogra || ' - ' || vr_tab_erro(vr_tab_erro.count).dscritic;

            RAISE vr_exc_saida;
          END IF;

          -- Preciso para calcular o quanto tirar do campo
          -- craprda.vlrendmm do quanto rendeu a aplicação do último
          -- calculo a taxa minina aux_rdulmtmm e o quanto rendeu o que
          -- está sendo resgatado a taxa minima aux_vlrnmmrg.
          vr_vlrnmmrg := vr_vlrendmm;
        END IF;
      ELSE
        IF vr_vlrvtfim > 0 THEN
          vr_cdhistor := 531;
          vr_vllan531 := vr_vlrvtfim;
          vr_vllanmto := vr_vlrvtfim;
          vr_dtrefere := rw_craprda.dtfimper;
          vr_txapllap := vr_txaplica;
          vr_nrdocmto := rw_craplot.nrseqdig + 1;

          -- Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS para débito
          apli0001.pc_gera_craplap_rdc (pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                       ,pr_cdagenci => rw_craplot.cdagenci
                                       ,pr_nrdcaixa => 999
                                       ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                       ,pr_nrdolote => rw_craplot.nrdolote
                                       ,pr_nrdconta => rw_craprda.nrdconta
                                       ,pr_nraplica => rw_craprda.nraplica
                                       ,pr_nrdocmto => vr_nrdocmto
                                       ,pr_txapllap => vr_txapllap
                                       ,pr_cdhistor => vr_cdhistor
                                       ,pr_nrseqdig => rw_craplot.nrseqdig
                                       ,pr_vllanmto => vr_vllanmto
                                       ,pr_dtrefere => vr_dtrefere
                                       ,pr_vlrendmm => vr_vlrendmm
                                       ,pr_tipodrdb => 'D'
                                       ,pr_rowidlot => rw_craplot.ROWID
                                       ,pr_rowidlap => rw_craplap.ROWID
                                       ,pr_vlinfodb => rw_craplot.vlinfodb
                                       ,pr_vlcompdb => rw_craplot.vlcompdb
                                       ,pr_qtinfoln => rw_craplot.qtinfoln
                                       ,pr_qtcompln => rw_craplot.qtcompln
                                       ,pr_vlinfocr => rw_craplot.vlinfocr
                                       ,pr_vlcompcr => rw_craplot.vlcompcr
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);

          IF vr_des_reto NOT IN ('OK') THEN
            vr_cdcritic := 0;
            vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdprogra || ' - ' || vr_tab_erro(vr_tab_erro.count).dscritic;

            RAISE vr_exc_saida;
          END IF;
        END IF;
      END IF;
    END IF;

    -- Tratar atualização da aplicação
    BEGIN
      IF vr_vllan534 != 0 THEN
        UPDATE craprda cp
        SET cp.vlrgtacu = cp.vlrgtacu + vr_vllan534
        WHERE cp.rowid = rw_craprda.ROWID
         RETURNING cp.vlrgtacu INTO rw_craprda.vlrgtacu;
      ELSE
        UPDATE craprda cp
        SET cp.vlrgtacu = cp.vlrgtacu + vr_vlresgat
        WHERE cp.rowid = rw_craprda.ROWID
         RETURNING cp.vlrgtacu INTO rw_craprda.vlrgtacu;
      END IF;

      IF rw_crapdtc.tpaplrdc = 1 THEN
        UPDATE craprda cd
        SET cd.vlsdrdca = cd.vlsdrdca - vr_vlresgat
        WHERE cd.rowid = rw_craprda.ROWID
         RETURNING cd.vlsdrdca INTO rw_craprda.vlsdrdca;
      ELSE
        UPDATE craprda cd
        SET cd.vlsdrdca = cd.vlsdrdca - vr_vlbasrgt
        WHERE cd.ROWID = rw_craprda.ROWID
         RETURNING cd.vlsdrdca INTO rw_craprda.vlsdrdca;
      END IF;
    EXCEPTION
      WHEN others THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar CRAPRDA. ' || sqlerrm;
        RAISE vr_exc_saida;
    END;

    -- Atualizar CRAPLRG
    BEGIN
      UPDATE craplrg cg
      SET cg.inresgat = 1
      WHERE cg.rowid = rw_craplrg.rowid;
    EXCEPTION
      WHEN others THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar CRAPLRG. ' || sqlerrm;
        RAISE vr_exc_saida;
    END;

    vr_regexist := TRUE;
    vr_cdcritic := 434;

    -- Resgate total
    IF nvl(vr_vllan534, 0) != 0 AND rw_craplrg.tpresgat != 2 THEN
      -- Quando a aplicação rendeu a taxa minima do último
      -- movimento até a data do resgate.
      vr_vllanmto := 0;
      vr_vlsldrdc := 0;

      -- Não passou nenhum mensal ainda
      IF to_char(rw_crapdat.dtmvtolt, 'RRRRMM') = to_char(rw_craprda.dtmvtolt, 'RRRRMM') THEN
        vr_dtmvtolt := rw_craprda.dtmvtolt;
      END IF;

      -- Quando passou a carência da aplicação o rendimento deve
      -- ficar fazendo parte do saldo, ele tem direito a isso
      IF vr_vllan532 != 0 THEN
        vr_vlrnmmrg := 0;
      END IF;

      BEGIN
        UPDATE craprda ca
           SET ca.vlsltxmm = ca.vlsltxmm + nvl(vr_rdulmtmm, 0) - nvl(vr_vllan534, 0) - nvl(vr_vllan533, 0) - nvl(vr_vlrnmmrg, 0),
               ca.dtatslmm = vr_dtmvtolt,
               ca.vlsltxmx = ca.vlsltxmx - nvl(vr_vllan531, 0) + nvl(vr_vllan529, 0) + nvl(vr_vllan532, 0) - nvl(vr_vllan533, 0) - nvl(vr_vllan534, 0),
               ca.dtatslmx = vr_dtmvtolt
        WHERE ca.rowid = rw_craprda.rowid
        RETURNING ca.vlsltxmm, ca.dtatslmm, ca.vlsltxmx, ca.dtatslmx
        INTO rw_craprda.vlsltxmm, rw_craprda.dtatslmm, rw_craprda.vlsltxmx, rw_craprda.dtatslmx;
      EXCEPTION
        WHEN others THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPRDA. ' || sqlerrm;
          RAISE vr_exc_saida;
      END;

      -- O saldo a taxa minima não pode ser maior que a máxima
      IF rw_craprda.vlsltxmm > rw_craprda.vlsltxmx THEN
        BEGIN
          UPDATE craprda ca
             SET ca.vlsltxmm = ca.vlsltxmx
           WHERE ca.rowid = rw_craprda.rowid
           RETURNING ca.vlsltxmm
                INTO rw_craprda.vlsltxmm;
        EXCEPTION
          WHEN others THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar taxa mínima na CRAPRDA. ' || sqlerrm;
            RAISE vr_exc_saida;
        END;
      END IF;
    END IF;

    IF nvl(vr_vlresgat, 0) > 0 THEN
      -- Conferência do saldo a ser resgatado para não haver sobras.
      -- Pelo motivo que as provisões são calculadas com 4 casas mais
      -- no extrato são mostradas só duas no RDCPOS.

      -- PÓS-FIXADA / RESGATE TOTAL
      IF rw_crapdtc.tpaplrdc = 2 AND rw_craplrg.vllanmto = 0 THEN
        -- Gerar extrato RDC
        apli0001.pc_extrato_rdc (pr_cdcooper         => rw_craprda.cdcooper
                                ,pr_cdagenci         => 1
                                ,pr_nrdcaixa         => 999
                                ,pr_nrctaapl         => rw_craprda.nrdconta
                                ,pr_nraplres         => rw_craprda.nraplica
                                ,pr_dtiniper         => NULL
                                ,pr_dtfimper         => NULL
                                ,pr_typ_tab_extr_rdc => vr_typ_tab_extr_rdc
                                ,pr_des_reto         => vr_des_reto
                                ,pr_tab_erro         => vr_tab_erro);

        -- Gera raise e levanta exceção, caso a variável de erro retorne 'NOK'
        IF vr_des_reto = 'NOK' THEN
          vr_cdcritic := 0;
          vr_dscritic := TO_CHAR(SYSDATE,'HH24:MI:SS') ||
                         ' - ' || vr_cdprogra || ' --> ' || vr_tab_erro(vr_tab_erro.count).dscritic ||
                         ' - Faltam dados na execução PC_RESGATE_RDC. ' ||
                         GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) || ' ' ||
                         GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9');
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se TEMP TABLE contém valores
        IF vr_typ_tab_extr_rdc.count() > 0 THEN
          vr_vlajtfim := 0;
          vr_lastextr := vr_typ_tab_extr_rdc.count();

          -- Busca pelo último registro da TEMP TABLE
          IF vr_typ_tab_extr_rdc(vr_lastextr).vlsdlsap != 0
             AND vr_typ_tab_extr_rdc(vr_lastextr).vlsdlsap != vr_vlresgat THEN
            -- Busca registro de aplicações RDCA pelo último registro
            OPEN cr_craplaplast(pr_cdcooper, rw_craplrg.nrdconta, rw_craplrg.nraplica, rw_crapdat.dtmvtolt, vr_vlresgat);
            FETCH cr_craplaplast INTO rw_craplaplast;

            -- Atribui valores
            vr_vlajtfim := vr_typ_tab_extr_rdc(vr_lastextr).vlsdlsap;
            vr_vlresgat := vr_vlresgat + vr_typ_tab_extr_rdc(vr_lastextr).vlsdlsap;

            -- Testa se encontrou registros
            IF cr_craplaplast%found THEN
              CLOSE cr_craplaplast;

              -- Buscando capa de lote
              OPEN cr_craplot(pr_cdcooper
                             ,rw_craplaplast.dtmvtolt
                             ,rw_craplaplast.cdagenci
                             ,rw_craplaplast.cdbccxlt
                             ,rw_craplaplast.nrdolote);
              FETCH cr_craplot INTO rw_craplot;

              -- Atualizar dados na tabela CRAPLOT
              BEGIN
                UPDATE craplot cl
                SET cl.vlinfodb = cl.vlinfodb - rw_craplaplast.vllanmto + vr_vlresgat
                   ,cl.vlcompdb = cl.vlcompdb - rw_craplaplast.vllanmto + vr_vlresgat
                WHERE cl.ROWID = rw_craplot.ROWID
                RETURNING cl.vlinfodb, cl.vlcompdb
                INTO rw_craplot.vlinfodb, rw_craplot.vlcompdb;
              EXCEPTION
                WHEN others THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar CRAPLOT. ' || sqlerrm;
                  RAISE vr_exc_saida;
              END;

              CLOSE cr_craplot;

              -- Atualizar dados na tabela CRAPLAP
              BEGIN
               UPDATE craplap cp
               SET cp.vllanmto = vr_vlresgat
               WHERE cp.ROWID = rw_craplaplast.ROWID
               RETURNING cp.vllanmto INTO rw_craplaplast.vllanmto;
              EXCEPTION
                WHEN others THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar CRAPLAP. ' || sqlerrm;
                  RAISE vr_exc_saida;
              END;
            ELSE
              CLOSE cr_craplaplast;
            END IF;
          END IF;
        END IF;
      END IF;

      -- Resgate Conta Corrente
      IF rw_craplrg.flgcreci = 0 THEN
        IF vr_vlresgat < 0 THEN
          vr_cdcritic := 717;

          -- Cria registro na TEMP TABLE para emissão de relatório de saída
          pc_cria_craprej (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_craplrg.nrdconta,
                           pr_nraplica => rw_craplrg.nraplica,
                           pr_dtmvtolt => rw_craplrg.dtmvtolt,
                           pr_vllanmto => rw_craplrg.vllanmto,
                           pr_saldorda => vr_saldorda,
                           pr_vlresgat => vr_vlresgat,
                           pr_cdcritic => vr_cdcritic,
                           pr_gdtmvtol => rw_crapdat.dtmvtolt,
                           pr_des_erro => vr_dscritic);
          --
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratato
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '
                                                        || 'Resgate negativo '
                                                        || to_char(rw_craplrg.nrdconta, 'fm9999G999G9') || ' '
                                                        || to_char(rw_craplrg.nraplica, 'fm999G999') || ' '
                                                        || to_char(vr_vlresgat, 'fm999G990D00s')
                                                         );

          -- Desfazer as transações pendentes da iteração
          ROLLBACK TO SAVEPOINT initFor;
          continue;
        END IF;

        -- Testa se cursor já está aberto
        IF cr_craplot%isopen THEN
          CLOSE cr_craplot;
        END IF;

        -- Gera lancamento no conta-corrente
        OPEN cr_craplot(pr_cdcooper, rw_crapdat.dtmvtolt, 1, 100, 8478);
        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se encontrou registros.
        -- Se não tiver encontrado insere na tabela CRAPLOT.
        IF cr_craplot%notfound THEN
          CLOSE cr_craplot;
          BEGIN
            -- Envio centralizado de log de erro
            INSERT INTO craplot(dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,cdcooper)
              VALUES(rw_crapdat.dtmvtolt
                    ,1
                    ,100
                    ,8478
                    ,1
                    ,pr_cdcooper)
            RETURNING cdagenci, dtmvtolt, cdbccxlt, nrdolote, tplotmov, rowid, nrseqdig
                 INTO rw_craplot.cdagenci,
                      rw_craplot.dtmvtolt,
                      rw_craplot.cdbccxlt,
                      rw_craplot.nrdolote,
                      rw_craplot.tplotmov,
                      rw_craplot.rowid,
                      rw_craplot.nrseqdig;
          EXCEPTION
            WHEN others THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir em CRAPLOT. ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
        ELSE
          CLOSE cr_craplot;
        END IF;

        -- Atribui valores
        vr_nraplica := rw_craprda.nraplica;
        vr_nraplfun := rw_craprda.nraplica;

        loop
          -- Busca registros dos lançamentos
          OPEN cr_craplcm(pr_cdcooper
                         ,rw_craplot.dtmvtolt
                         ,rw_craplot.cdagenci
                         ,rw_craplot.cdbccxlt
                         ,rw_craplot.nrdolote
                         ,rw_craprda.nrdconta
                         ,vr_nraplica);
          FETCH cr_craplcm INTO rw_craplcm;

          -- Verifica se foram encontrados registros.
          -- Se não encontrar insere registro na tabela CRAPLCM e atualiza tabela CRAPLOT.
          -- Se encontrar, gera um novo número de aplicação e repete a busca.
          IF cr_craplcm%NOTFOUND OR rw_craplcm.retorno > 1 THEN
            CLOSE cr_craplcm;

            IF rw_crapdtc.tpaplrdc = 1 THEN
              vr_cdhistorc := 478;
            ELSE
              vr_cdhistorc := 530;
            END IF;

            BEGIN
              UPDATE craplot cl
              SET cl.qtinfoln = cl.qtinfoln + 1
                 ,cl.qtcompln = cl.qtcompln + 1
                 ,cl.vlinfocr = cl.vlinfocr + vr_vlresgat
                 ,cl.vlcompcr = cl.vlcompcr + vr_vlresgat
                 ,cl.nrseqdig = nvl(rw_craplot.nrseqdig, 0) + 1
              WHERE cl.ROWID = rw_craplot.ROWID
              RETURNING cl.qtinfoln, cl.qtcompln, cl.vlinfocr, cl.vlcompcr, cl.nrseqdig
              INTO rw_craplot.qtinfoln, rw_craplot.qtcompln, rw_craplot.vlinfocr, rw_craplot.vlcompcr, rw_craplot.nrseqdig;
            EXCEPTION
              WHEN others THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar CRAPLOT. ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            BEGIN
              INSERT INTO craplcm(dtmvtolt
                                 ,dtrefere
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdctabb
                                 ,nrdctitg
                                 ,nrdocmto
                                 ,cdcooper
                                 ,cdhistor
                                 ,vllanmto
                                 ,nrseqdig
                                 ,cdcoptfn)      --> adicionado somente para resolver consistência do Oracle, não existe no Progress.
                VALUES(rw_craplot.dtmvtolt
                      ,rw_craprda.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craprda.nrdconta
                      ,rw_craprda.nrdconta
                      ,gene0002.fn_mask(rw_craprda.nrdconta, '99999999')
                      ,gene0002.fn_char_para_number(vr_nraplica)
                      ,pr_cdcooper
                      ,vr_cdhistorc
                      ,vr_vlresgat
                      ,rw_craplot.nrseqdig
                      ,0);
            EXCEPTION
              WHEN others THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir  CRAPLCM. ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
            -- Sai do loop
            exit;
          ELSE
            CLOSE cr_craplcm;
            -- Modifica o nraplica para buscar novamente e encontrar um nrdocmto vazio na craplcm
            BEGIN
              vr_nraplica := vr_ctrdocmt(vr_contapli) + vr_nraplica;
            EXCEPTION
              WHEN others THEN
                IF gene0002.fn_numerico(vr_nraplica) = FALSE THEN
                  vr_contapli := vr_contapli - 1;
                  vr_nraplica := vr_ctrdocmt(vr_contapli) + vr_nraplfun;
                END IF;
            END;
            -- Volta ao início do loop para fazer nova busca na craplcm
            continue;
          END IF;
        end loop;
      END IF;

      -- Gerar consistência de dados para lançamento na CRAPLCI
      pc_gera_lancamentos_craplci(pr_flgctain => rw_craprda.flgctain
                                 ,pr_flgcreci => rw_craplrg.flgcreci
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_nrdconta => rw_craprda.nrdconta
                                 ,pr_tpaplrdc => rw_crapdtc.tpaplrdc
                                 ,pr_vlresgat => vr_vlresgat
                                 ,pr_des_erro => vr_dscritic
                                 ,pr_cdcritic => vr_cdcritic);

      IF vr_dscritic NOT IN ('OK') THEN
        vr_cdcritic := 0;
        vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') ||
                       ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                       ' - Faltam dados na execução pc_gera_lancamentos_craplci';

        RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Valida para atualizar a tabela CRAPRDA
    IF rw_craplrg.vllanmto = 0 THEN
      BEGIN
        UPDATE craprda cp
        SET cp.inaniver = 1
           ,cp.insaqtot = 1
           ,cp.incalmes = 1
           ,cp.vlsdrdca = 0
           ,cp.vlsltxmx = 0
           ,cp.vlsltxmm = 0
           ,cp.vlslfmes = 0
           ,cp.dtsdfmes = NULL
        WHERE cp.rowid = rw_craprda.rowid;
      EXCEPTION
        WHEN others THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPRDA. ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
    END IF;

    -- Cria entrada na tabela
    pc_cria_craprej (pr_cdcooper  => pr_cdcooper
                    ,pr_nrdconta  => rw_craplrg.nrdconta
                    ,pr_nraplica  => rw_craplrg.nraplica
                    ,pr_dtmvtolt  => rw_craplrg.dtmvtolt
                    ,pr_vllanmto  => rw_craplrg.vllanmto
                    ,pr_saldorda  => vr_saldorda
                    ,pr_vlresgat  => vr_vlresgat
                    ,pr_cdcritic  => vr_cdcritic
                    ,pr_gdtmvtol  => rw_crapdat.dtmvtolt
                    ,pr_des_erro  => vr_dscritic);

    IF vr_dscritic NOT IN ('OK') THEN
      vr_cdcritic := 0;
      vr_dscritic := TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                     ' - Faltam dados na execução pc_cria_craprej.';

      RAISE vr_exc_saida;
    END IF;
  END LOOP;

  -- Zerar resultado de críticas
  vr_cdcritic := 0;

  -- Iterar sobre TEMP TABLE para gerar registros de erros
  BEGIN
    FORALL idx IN 1..vr_tab_craprej.count() SAVE EXCEPTIONS
      INSERT INTO craprej(dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,nrdconta
                         ,nraplica
                         ,dtdaviso
                         ,vldaviso
                         ,vlsdapli
                         ,vllanmto
                         ,cdcritic
                         ,tpintegr
                         ,cdcooper)
        VALUES(vr_tab_craprej(idx).dtmvtolt
              ,478
              ,478
              ,478
              ,vr_tab_craprej(idx).nrdconta
              ,vr_tab_craprej(idx).nraplica
              ,vr_tab_craprej(idx).dtdaviso
              ,vr_tab_craprej(idx).vldaviso
              ,vr_tab_craprej(idx).vlsdapli
              ,vr_tab_craprej(idx).vllanmto
              ,vr_tab_craprej(idx).cdcritic
              ,478
              ,pr_cdcooper);
  EXCEPTION
    WHEN others THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao inserir em CRAPREJ. ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
      RAISE vr_exc_saida;
  END;

  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_xmlclob, TRUE);
  dbms_lob.open(vr_xmlclob, dbms_lob.lob_readwrite);

  vr_bfclob := '<?xml version="1.0" encoding="utf-8"?>';

  -- Criar arquivo conforme padrão
  IF vr_regexist THEN
    -- Busca lote
    -- Testa se cursor já está aberto
    IF cr_craplot%isopen THEN
      CLOSE cr_craplot;
    END IF;

    OPEN cr_craplot(pr_cdcooper, rw_crapdat.dtmvtolt, 1, 100, 8479);
    FETCH cr_craplot INTO rw_craplot;

    -- Se não localizar registro gera críticia
    IF cr_craplot%notfound THEN
      CLOSE cr_craplot;

      vr_cdcritic := 60;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplot;
    END IF;

    -- Gerar informações de cabeçalho (LOTE)
    vr_mensag := 'DATA: ' || to_char(rw_craplot.dtmvtolt, 'dd/mm/yyyy') ||
                 ' AGENCIA: ' || lpad(rw_craplot.cdagenci, 3, ' ') ||
                 '   BANCO/CAIXA: ' || rpad(rw_craplot.cdbccxlt, 5, ' ') ||
                 ' LOTE: ' || lpad(to_char(rw_craplot.nrdolote, 'FM999G999G999'), 7, ' ') ||
                 ' TIPO: ' || lpad(rw_craplot.tplotmov, 2, '0');
  ELSE
    -- Gerar informações de cabeçalho (LOTE)
    vr_mensag := '*** NENHUM RESGATE EFETUADO ***';
  END IF;
  vr_bfclob := vr_bfclob||'<resgates mensagem="'||vr_mensag||'" >';

  -- Busca informação de rejeitados
  FOR vr_craprej IN cr_craprej(pr_cdcooper, rw_crapdat.dtmvtolt) LOOP
    -- Validação de crítica do processo vrs crítica do banco de dados
    IF nvl(vr_cdcritic, 0) != nvl(vr_craprej.cdcritic, 0) THEN
      vr_cdcritic := vr_craprej.cdcritic;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Gerar nó para informações do resgate (RESGATE)
    vr_bfclob := vr_bfclob || '<resgate conta="' || to_char(vr_craprej.nrdconta, 'FM999999G999G9') || '">'||
                                '<aplicacao>' || to_char(vr_craprej.nraplica, 'FM999G999G999G999') || '</aplicacao>'||
                                '<aviso>' || to_char(vr_craprej.dtdaviso, 'dd/mm/yyyy') || '</aviso>'||
                                '<vlrresgate>' || to_char(vr_craprej.vldaviso, 'FM999G999G999G990D90') || '</vlrresgate>'||
                                '<vlrsaldo>' || to_char(vr_craprej.vlsdapli, 'FM999G999G999G990D90') || '</vlrsaldo>'||
                                '<vlrcredito>' || to_char(vr_craprej.vllanmto, 'FM999G999G999G990D90') || '</vlrcredito>'||
                                '<critica>' || vr_dscritic || '</critica>'||
                              '</resgate>';
    pc_limpa_buffer(pr_buffer => vr_bfclob, pr_str => vr_xmlclob);
  END LOOP;

  -- Limpar crítica utilizada para gerar XML
  vr_cdcritic := 0;

  -- Finaliza construção do XML
  vr_bfclob := vr_bfclob || '</resgates>';
  pc_final_buffer(pr_buffer => vr_bfclob, pr_str => vr_xmlclob);

  -- Capturar o path do arquivo
  vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                     ,pr_cdcooper => pr_cdcooper
                                     ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

  -- Definir nome padrão do arquivo
  vr_nom_arq := 'crrl453';

  -- Efetuar chamada de geração do PDF do relatório
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_xmlclob,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/resgates/resgate', --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl453.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,
                              pr_dsarqsaid => vr_nom_dir||'/'||vr_nom_arq||'.lst', --> Arquivo final
                              pr_flg_gerar => 'S',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'S',    --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => NULL,   --> Nome do formulário para impressão
                              pr_nrcopias  => 1,      --> Número de cópias para impressão
                              pr_des_erro  => vr_dscritic);        --> Saída com erro
  -- Testar se houve erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;

  -- Liberar dados do CLOB da memória
  dbms_lob.close(vr_xmlclob);
  dbms_lob.freetemporary(vr_xmlclob);

  -- TRANS_2: Limpar registros da tabela CRAPREJ
  BEGIN
    DELETE craprej cj
    WHERE cj.cdcooper = pr_cdcooper
    AND cj.dtmvtolt = rw_crapdat.dtmvtolt
    AND cj.cdagenci = 478
    AND cj.cdbccxlt = 478
    AND cj.nrdolote = 478
    AND cj.tpintegr = 478;
  EXCEPTION
    WHEN others THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao excluir CRAPREJ. ' || sqlerrm;
      RAISE vr_exc_saida;
  END;

  -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  -- Efetuar commit pois gravaremos o que foi processo até então
  COMMIT;

EXCEPTION
  when vr_exc_fimprg then
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
END pc_crps478;
/

