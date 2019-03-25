CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS518" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

  /* .............................................................................

   Programa: pc_crps518                        Antigo: fontes/crps518.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Gabriel
    Data    : Outubro/2008                   Ultima Atualizacao: 06/07/2017

    Dados referente ao programa:

    Frequencia: Diario.

    Objetivo  : Emitir a listagem de titulos descontados no dia, borderos
                ativos e detalhamento dos titulos em desconto.
                Solicitacao: 2
                Ordem:       18

    Alteracoes: 18/12/2008 - Incluido o saldo contabil no relatorio 495
                             conforme a tela TITCTO - opcao S, a pedido da
                             contabilidade (Evandro).

                05/01/2009 - Alterado formato de campos para evitar estouros
                             (Gabriel)
                           - Corrigida contabilizacao do valor a apropriar
                             relatorio 495 - deve ser considerado o valor
                             total, inclusive o valor de abatimento (Evandro).

                06/02/2009 - Correcao na contabilizacao da alteracao do Evandro
                             deve-se utilizar o ultimo dia util do mes na busca
                             do crapljt pois os juros sao gravados no ultimo
                             dia do mes e nao no ultimo dia util do mes
                           - Utilizar a contabilizacao da correcao acima(pelo
                             Evandro) tambem no 494
                           - Utilizar quebra no 494 pelo pac do associado e nao
                             pelo bordero, pois o cooperado pode mudar de pac
                             (Guilherme).

               26/03/2009 - Na opcao "S" na baixa sem pagamentos, ignorar
                            os titulos de final de semana na segunda-feira
                            (Guilherme).

               01/04/2009 - Tratar titulos em Desconto pagos via internet como
                            CAIXA cob.indpagto = 3 cob.indpagto = 1
                            Tarefa 23393
                          - Nao considerar titulos que foram pagos pela COMPE na
                            data atual em RISCO pois somente serao lancados na
                            contabilidade com D+1
                          - Alterado de exclusivo para paralelo
                            (Guilherme/Evandro)

               21/05/2009 - Considerar em risco titulos que vencem em
                            glb_dtmvtolt (Guilherme).

               09/07/2009 - Acerto no display de totais de contratos ativos
                            pessoa juridica + pessoa fisica(Guilherme).

               09/09/2009 - Nao considerar a data de vencimento nos titulos em
                            aberto porque a liquidacao esta rodando antes no
                            processo batch (Evandro).

               10/06/2010 - Tratamento para pagamento feito atraves de TAA
                            (Elton).

               06/07/2011 - Realizado correcao para pegar o craplim correto
                            (Adriano).

               15/08/2012 - Alteração no layout do relatorio 494, 495 ref.
                            a tit. desc. da cob. registrada (David Kruger).

               30/10/2012 - Ajuste na rotina de Saldo de Títulos. Considerar
                            pagtos pela compe 085 em D-0 (Rafael).

               13/02/2013 - Ajuste nas mensagens da proc_batch ref. a titulos
                            nao encontrados na crapcob (Rafael).

               05/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               02/10/2013 - Ajustes na atribuição da variavel vr_dsinfo, para enviar
                            espaço ao invés de null, pois isso gera erro no ireports
                            (Marcos-Supero)

               03/12/2013 - Nao considerar titulos descontados 085 pagos
                            via compe na composição da carteira de desconto
                            de titulos (Gabriel).
                            
               22/03/2017 - Segregar informações de saldo de desconto de cheques em PF e PJ
                            Projeto 307 Automatização Arquivos Contábeis Ayllos (Jonatas - Supero)

               05/07/2017 - #707221 Forçando o index craplim##craplim1 no cursor 
                            cr_craplim_2 (Carlos)

               19/08/2018 - Incluso tratativa para efetuar apenas leitura de 
                            titulos descontados e liberados (GFT) 
                            
               31/10/2018 - Adicionado na impressão do rel 494 tratativa do valor do titulo conforme a versão 
                            do produto do borderô, e quando for a nova versão somar o valor de apropriação de
                            juros de mora (Paulo Penteado GFT)
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps518 */

       --Definicao do tipo de registro para tabela memoria crrl493.
       TYPE typ_reg_crrl493 IS
         RECORD (cdagenci crapbdt.cdagenci%TYPE
                ,nrdconta crapbdt.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,nrctrlim crapbdt.nrctrlim%TYPE
                ,nrborder crapbdt.nrborder%TYPE
                ,totitulo NUMBER
                ,totvlbru NUMBER
                ,totvlliq NUMBER
                ,totvljur NUMBER
                ,vlrmedio NUMBER);

       --Definicao do tipo de registro para tabela memoria saldo.
       TYPE typ_reg_saldo IS
         RECORD (nrdconta craptdb.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,dtvencto craptdb.dtvencto%TYPE
                ,dtlibbdt craptdb.dtlibbdt%TYPE
                ,nrborder craptdb.nrborder%TYPE
                ,nrcnvcob craptdb.nrcnvcob%TYPE
                ,vlliquid craptdb.vlliquid%TYPE
                ,vltitulo craptdb.vltitulo%TYPE
                ,vldjuros craptdb.vlliquid%TYPE
                ,dsdoccop crapcob.dsdoccop%TYPE
                ,nrboleto crapcob.nrdocmto%TYPE
                ,nmdsacad crapsab.nmdsacad%TYPE
                ,nrinssac crapsab.nrinssac%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,cdcooper crapcop.cdcooper%TYPE
                ,insittit craptdb.insittit%TYPE
                ,cdbandoc craptdb.cdbandoc%TYPE
                ,nrdctabb craptdb.nrdctabb%TYPE
                ,flgregis crapcob.flgregis%TYPE
                ,inpessoa crapass.inpessoa%TYPE);

       --Definicao do tipo de tabela crapsab
       TYPE typ_reg_crapsab IS
         RECORD (nmdsacad crapsab.nmdsacad%TYPE
                ,nrinssac crapsab.nrinssac%TYPE);

       --Definicao do tipo de tabela para limites
       TYPE typ_reg_limite IS
         RECORD (inpessoa INTEGER
                ,cdagenci INTEGER
                ,qtdutili NUMBER
                ,vlrutili NUMBER
                ,qtnaouti NUMBER
                ,vlrnaout NUMBER);
                
       -- Pl Table para resumo de valores totais de desconto de títulos por agência - crrl494
       TYPE typ_tot_dsc_tit IS
         RECORD(vllimite NUMBER(20,2)
               ,vlbrutor NUMBER(20,2)
               ,vlbrutos NUMBER(20,2)
               ,vlapropr NUMBER(20,2)
               ,vlaprops NUMBER(20,2)
               ,totsldis NUMBER(20,2));
        
       -- Pl Table para resumo de valores totais de desconto cheque por agência - crrl494
       TYPE typ_tot_dsc_tit_pf_pj IS
         RECORD(vllimite_pf NUMBER(20,2)
               ,vlbrutor_pf NUMBER(20,2)
               ,vlbrutos_pf NUMBER(20,2)
               ,vlapropr_pf NUMBER(20,2)
               ,vlaprops_pf NUMBER(20,2)
               ,totsldis_pf NUMBER(20,2)
               ,vllimite_pj NUMBER(20,2)
               ,vlbrutor_pj NUMBER(20,2)
               ,vlbrutos_pj NUMBER(20,2)
               ,vlapropr_pj NUMBER(20,2)
               ,vlaprops_pj NUMBER(20,2)
               ,totsldis_pj NUMBER(20,2));


       --Definicao dos tipos de tabelas de memoria
       TYPE typ_tab_crrl493 IS TABLE OF typ_reg_crrl493 INDEX BY VARCHAR2(40);
       TYPE typ_tab_saldo   IS TABLE OF typ_reg_saldo   INDEX BY VARCHAR2(100);
       TYPE typ_tab_vencto  IS TABLE OF typ_reg_saldo   INDEX BY VARCHAR2(73);
       TYPE typ_tab_crapsab IS TABLE OF typ_reg_crapsab INDEX BY VARCHAR2(35);
       TYPE typ_tab_craplim IS TABLE OF NUMBER          INDEX BY PLS_INTEGER;
       TYPE typ_tab_limite  IS TABLE OF typ_reg_limite  INDEX BY VARCHAR2(11);
       TYPE typ_tab_tot_dsc_tit_pf_pj IS TABLE OF typ_tot_dsc_tit_pf_pj INDEX BY BINARY_INTEGER;           
       TYPE typ_tab_tot_dsc_tit IS TABLE OF typ_tot_dsc_tit INDEX BY BINARY_INTEGER;       

       --Definicao das tabelas de memoria
       vr_tab_crrl493           typ_tab_crrl493;
       vr_tab_saldo             typ_tab_saldo;
       vr_tab_vencto            typ_tab_vencto;
       vr_tab_crapsab           typ_tab_crapsab;
       vr_tab_craplim           typ_tab_craplim;
       vr_tab_limite            typ_tab_limite;
       vr_tab_tot_dsc_tit       typ_tab_tot_dsc_tit; 
       vr_tab_tot_dsc_tit_pf_pj typ_tab_tot_dsc_tit_pf_pj;          

       --Cursores da rotina crps518

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
               ,cop.vlmaxleg
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Selecionar informacoes da agencia
       CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE
                         ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
         SELECT  crapage.cdagenci
                ,crapage.nmresage
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper
         AND   crapage.cdagenci = pr_cdagenci;
       rw_crapage cr_crapage%ROWTYPE;

       --Selecionar os borderos de titulos
       CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                         ,pr_dtlibbdt IN crapbdt.dtlibbdt%TYPE) IS
         SELECT crapbdt.nrdconta
               ,crapbdt.nrborder
               ,crapbdt.cdagenci
               ,crapbdt.nrctrlim
               ,crapass.nmprimtl
         FROM  crapass,
               crapbdt crapbdt
         WHERE crapbdt.cdcooper = pr_cdcooper
         AND   crapbdt.dtlibbdt = pr_dtlibbdt
         AND   crapass.cdcooper = crapbdt.cdcooper
         AND   crapass.nrdconta = crapbdt.nrdconta;

       --Selecionar os borderos de titulos para relatorio crrl494
       CURSOR cr_crapbdt_494 (pr_cdcooper IN crapbdt.cdcooper%TYPE) IS
         SELECT crapbdt.nrdconta
               ,crapbdt.nrborder
               ,crapbdt.cdagenci
               ,crapbdt.nrctrlim
               ,crapbdt.flverbor
         FROM crapbdt crapbdt
         WHERE crapbdt.cdcooper = pr_cdcooper
         AND   crapbdt.insitbdt IN (3,4); /* Liberado Ou Liquidado */

       --Selecionar os titulos do bordero
       CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE
                         ,pr_nrdconta IN craptdb.nrdconta%TYPE
                         ,pr_nrborder IN craptdb.nrborder%TYPE) IS
         SELECT craptdb.vltitulo
               ,craptdb.vlliquid
               ,craptdb.rowid
         FROM craptdb craptdb
         WHERE craptdb.cdcooper = pr_cdcooper
         AND   craptdb.nrdconta = pr_nrdconta
         AND   craptdb.nrborder = pr_nrborder
         AND   craptdb.dtlibbdt is not null;

       --Selecionar os titulos do bordero para relatorio crrl494
       CURSOR cr_craptdb_494 (pr_cdcooper IN craptdb.cdcooper%TYPE
                             ,pr_nrdconta IN craptdb.nrdconta%TYPE
                             ,pr_nrborder IN craptdb.nrborder%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
         SELECT craptdb.vltitulo
               ,craptdb.vlliquid
               ,craptdb.cdbandoc
               ,craptdb.nrdctabb
               ,craptdb.nrcnvcob
               ,craptdb.nrdconta
               ,craptdb.nrdocmto
               ,craptdb.insittit
               ,craptdb.nrinssac
               ,craptdb.dtvencto
               ,craptdb.dtlibbdt
               ,craptdb.nrborder
               ,craptdb.vlsldtit + (craptdb.vlmratit - craptdb.vlpagmra) vltitmra
               ,crapass.cdagenci
               ,crapass.nmprimtl
               ,crapass.inpessoa
               ,craptdb.rowid
         FROM   crapass
               ,craptdb craptdb
         WHERE ((craptdb.cdcooper = pr_cdcooper
         AND   craptdb.nrdconta = pr_nrdconta
         AND   craptdb.nrborder = pr_nrborder
         AND   craptdb.insittit = 4)
         OR
               (craptdb.cdcooper = pr_cdcooper
         AND   craptdb.nrdconta = pr_nrdconta
         AND   craptdb.nrborder = pr_nrborder
         AND   craptdb.insittit = 2
         AND   craptdb.dtdpagto = pr_dtmvtolt))
         AND   crapass.cdcooper = craptdb.cdcooper
         AND   crapass.nrdconta = craptdb.nrdconta;

       --Selecionar informacoes de cobranca
       CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
         SELECT crapcob.indpagto
               ,crapcob.dsdoccop
               ,crapcob.nrdocmto
               ,crapcob.flgregis
               ,crapcob.cdbandoc
         FROM crapcob crapcob
         WHERE crapcob.cdcooper = pr_cdcooper
         AND   crapcob.cdbandoc = pr_cdbandoc
         AND   crapcob.nrdctabb = pr_nrdctabb
         AND   crapcob.nrcnvcob = pr_nrcnvcob
         AND   crapcob.nrdconta = pr_nrdconta
         AND   crapcob.nrdocmto = pr_nrdocmto;
       rw_crapcob cr_crapcob%ROWTYPE;


       --Selecionar informacoes dos sacados
       CURSOR cr_crapsab (pr_cdcooper IN crapsab.cdcooper%TYPE) IS
         SELECT crapsab.nrdconta
               ,crapsab.nrinssac
               ,crapsab.nmdsacad
         FROM crapsab crapsab
         WHERE crapsab.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos limites da conta
       CURSOR cr_craplim (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT  craplim.nrdconta
                ,craplim.vllimite
         FROM craplim craplim
         WHERE craplim.cdcooper = pr_cdcooper
         AND   craplim.tpctrlim = 3
         AND   craplim.insitlim = 2;

       --Variaveis Locais

       vr_flgproces    BOOLEAN;

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     VARCHAR2(10);
       vr_cdcritic     INTEGER;

       --Variavel usada para montar o indice da tabela de memoria
      vr_index_crrl493 VARCHAR2(40);
      vr_index_crapsab VARCHAR2(35);
      vr_index_saldo   VARCHAR2(100);
      vr_index_vencto  VARCHAR2(73);

       --Variaveis para bordero
       vr_bor_totitulo INTEGER;
       vr_bor_totvlbru NUMBER;
       vr_bor_totvlliq NUMBER;
       vr_bor_totvljur NUMBER;
       vr_bor_vlrmedio NUMBER;
       vr_vltitulo     craptdb.vltitulo%TYPE;

       --Variaveis para saldo
       vr_nmdsacad crapsab.nmdsacad%TYPE;
       vr_nrinssac crapsab.nrinssac%TYPE;

       -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;

       --Variaveis para retorno de erro
       vr_des_erro       VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_erro  EXCEPTION;
       vr_exc_fim   EXCEPTION;
       vr_exc_pula  EXCEPTION;


       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crrl493.DELETE;
         vr_tab_saldo.DELETE;
         vr_tab_crapsab.DELETE;
         vr_tab_craplim.DELETE;
         vr_tab_vencto.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_des_erro:= 'Erro ao limpar tabelas de memória. Rotina pc_crps518.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;

       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

       --Geração do relatório crrl493
       PROCEDURE pc_imprime_crrl493 (pr_des_erro OUT VARCHAR2) IS


          --Variavel de Exceção
         vr_exc_erro EXCEPTION;

         --Variaveis de arquivo
         vr_dsinfo       VARCHAR2(100);
         vr_nom_direto   VARCHAR2(100);
         vr_nom_arquivo  VARCHAR2(100);

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= NULL;

         -- Busca do diretório base da cooperativa para PDF
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl493>');
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl493';

         --Verificar se o vetor possui registros
         IF vr_tab_crrl493.Count > 0 THEN
           --Informar que possui titulos
           vr_dsinfo:= ' ';
         ELSE
           --Informar que nao possui titulos
           vr_dsinfo:= '*** NENHUM BORDERO DE DESCONTO DE TITULOS FOI LIBERADO NESSE DIA ***';
         END IF;
         --Acessar primeiro registro da tabela de memoria crrl493
         vr_index_crrl493:= vr_tab_crrl493.FIRST;
         WHILE vr_index_crrl493 IS NOT NULL  LOOP

           --Montar tag da conta para arquivo XML
           pc_escreve_xml
               ('<bordero>
                  <cdagenci>'||vr_tab_crrl493(vr_index_crrl493).cdagenci||'</cdagenci>
                  <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_crrl493(vr_index_crrl493).nrdconta)||'</nrdconta>
                  <nmprimtl>'||vr_tab_crrl493(vr_index_crrl493).nmprimtl||'</nmprimtl>
                  <nrctrlim>'||To_Char(vr_tab_crrl493(vr_index_crrl493).nrctrlim,'fm9g999g999')||'</nrctrlim>
                  <nrborder>'||To_Char(vr_tab_crrl493(vr_index_crrl493).nrborder,'fm9g999g999')||'</nrborder>
                  <totitulo>'||vr_tab_crrl493(vr_index_crrl493).totitulo||'</totitulo>
                  <totvlbru>'||To_Char(vr_tab_crrl493(vr_index_crrl493).totvlbru,'fm999g999g999d00')||'</totvlbru>
                  <totvlliq>'||To_Char(vr_tab_crrl493(vr_index_crrl493).totvlliq,'fm999g999g999d00')||'</totvlliq>
                  <totvljur>'||To_Char(vr_tab_crrl493(vr_index_crrl493).totvljur,'fm999g999g999d00')||'</totvljur>
                  <vlrmedio>'||To_Char(vr_tab_crrl493(vr_index_crrl493).vlrmedio,'fm999g999g999d00')||'</vlrmedio>
               </bordero>');

           --Encontrar o proximo registro da tabela de memoria
           vr_index_crrl493:= vr_tab_crrl493.NEXT(vr_index_crrl493);
         END LOOP;

         -- Finalizar o agrupador do relatório
         pc_escreve_xml('</crrl493>');

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl493/bordero' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl493.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => 'PR_DSINFO##'||vr_dsinfo     --> Enviar como parâmetro apenas o titulo
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> Gerar o arquivo na hora
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro
         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl493. '||sqlerrm;
       END;


       --Geração do relatório crrl494
       PROCEDURE pc_imprime_crrl494 (pr_des_erro OUT VARCHAR2) IS

         /* Cursores Locais */

         --Selecionar todas as agencias
         CURSOR cr_crapage_2 (pr_cdcooper IN crapage.cdcooper%TYPE) IS
           SELECT  crapage.cdagenci
                  ,crapage.nmresage
           FROM crapage crapage
           WHERE crapage.cdcooper = pr_cdcooper;

         --Selecionar todos os associados da agencia
         CURSOR cr_crapass_2 (pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
           SELECT crapass.nrdconta
                 ,crapass.inpessoa
           FROM crapass crapass
           WHERE crapass.cdcooper = pr_cdcooper
           AND   crapass.cdagenci = pr_cdagenci;

         --Selecionar informacoes do primeiro limite
         CURSOR cr_craplim_2 (pr_cdcooper IN craplim.cdcooper%TYPE
                             ,pr_nrdconta IN craplim.nrdconta%TYPE) IS
           SELECT /*+ index (craplim CRAPLIM##CRAPLIM1) */ craplim.vllimite
           FROM craplim craplim
           WHERE craplim.cdcooper = pr_cdcooper
           AND   craplim.nrdconta = pr_nrdconta
           AND   craplim.tpctrlim = 3
           AND   craplim.insitlim = 2
           ORDER BY craplim.progress_recid ASC;
         rw_craplim_2 cr_craplim_2%ROWTYPE;

         --Selecionar informacoes dos titulos do bordero
         CURSOR cr_craptdb_2 (pr_cdcooper IN craptdb.cdcooper%TYPE
                             ,pr_nrdconta IN craptdb.nrdconta%TYPE) IS
           SELECT craptdb.cdcooper
           FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
           AND   craptdb.nrdconta = pr_nrdconta
           AND   craptdb.insittit = 4
           ORDER BY craptdb.progress_recid ASC;
         rw_craptdb_2 cr_craptdb_2%ROWTYPE;

         --Selecionar informacoes dos juros titulos
         CURSOR cr_crapljt (pr_cdcooper IN crapljt.cdcooper%TYPE
                           ,pr_nrdconta IN crapljt.nrdconta%TYPE
                           ,pr_nrborder IN crapljt.nrborder%TYPE
                           ,pr_dtrefere IN crapljt.dtrefere%TYPE
                           ,pr_cdbandoc IN crapljt.cdbandoc%TYPE
                           ,pr_nrdctabb IN crapljt.nrdctabb%TYPE
                           ,pr_nrcnvcob IN crapljt.nrcnvcob%TYPE
                           ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
           SELECT  crapljt.vldjuros
                  ,crapljt.vlrestit
           FROM crapljt crapljt
           WHERE crapljt.cdcooper = pr_cdcooper
           AND   crapljt.nrdconta = pr_nrdconta
           AND   crapljt.nrborder = pr_nrborder
           AND   crapljt.dtrefere > pr_dtrefere
           AND   crapljt.cdbandoc = pr_cdbandoc
           AND   crapljt.nrdctabb = pr_nrdctabb
           AND   crapljt.nrcnvcob = pr_nrcnvcob
           AND   crapljt.nrdocmto = pr_nrdocmto;


         --Variaveis Locais
         vr_lim_totborde INTEGER:= 0;
         vr_lim_totitulo INTEGER:= 0;
         vr_lim_vlbrutor NUMBER:= 0;
         vr_lim_titsemrg INTEGER:= 0;
         vr_lim_vlbrutos NUMBER:= 0;
         vr_lim_vlapropr NUMBER:= 0;
         vr_lim_vlaprops NUMBER:= 0;
         vr_lim_totsldis NUMBER:= 0;
         vr_vllimite     NUMBER:= 0;
         vr_fis_qtdutili INTEGER:= 0;
         vr_fis_vlrutili NUMBER:= 0;
         vr_jur_qtdutili INTEGER:= 0;
         vr_jur_vlrutili NUMBER:= 0;
         vr_fis_qtnaouti INTEGER:= 0;
         vr_fis_vlrnaout NUMBER:= 0;
         vr_jur_qtnaouti INTEGER:= 0;
         vr_jur_vlrnaout NUMBER:= 0;
         vr_dtrefere     DATE;
         vr_dspessoa     VARCHAR2(2);

         --Variaveis para indices
         vr_index_limite VARCHAR2(11);
          --Variavel de Exceção
         vr_exc_erro EXCEPTION;

         --Variaveis de arquivo
         vr_nom_direto   VARCHAR2(100);
         vr_nom_arquivo  VARCHAR2(100);

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= NULL;

         -- Busca do diretório base da cooperativa para PDF
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl494><agencias>');
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl494';

         --Acessar primeiro registro da tabela de memoria crrl493
         vr_index_saldo:= vr_tab_saldo.FIRST;
         WHILE vr_index_saldo IS NOT NULL  LOOP

           --Se o registro for valido
           IF vr_tab_saldo(vr_index_saldo).flgregis = 1 THEN
             vr_lim_totitulo:= Nvl(vr_lim_totitulo,0) + 1;
             vr_lim_vlbrutor:= Nvl(vr_lim_vlbrutor,0) + vr_tab_saldo(vr_index_saldo).vltitulo;
           ELSE
             vr_lim_titsemrg:= Nvl(vr_lim_titsemrg,0) + 1;
             vr_lim_vlbrutos:= Nvl(vr_lim_vlbrutos,0) + vr_tab_saldo(vr_index_saldo).vltitulo;
           END IF;

           --Se deve apropriar juros
           IF vr_tab_saldo(vr_index_saldo).insittit = 4  THEN
             --Determinar o ultimo dia do mes corrente
             vr_dtrefere:= Last_Day(rw_crapdat.dtmvtolt);
             --Selecionar Lancamentos de Juros de desconto de titulo
             FOR rw_crapljt IN cr_crapljt (pr_cdcooper => vr_tab_saldo(vr_index_saldo).cdcooper
                                          ,pr_nrdconta => vr_tab_saldo(vr_index_saldo).nrdconta
                                          ,pr_nrborder => vr_tab_saldo(vr_index_saldo).nrborder
                                          ,pr_dtrefere => vr_dtrefere
                                          ,pr_cdbandoc => vr_tab_saldo(vr_index_saldo).cdbandoc
                                          ,pr_nrdctabb => vr_tab_saldo(vr_index_saldo).nrdctabb
                                          ,pr_nrcnvcob => vr_tab_saldo(vr_index_saldo).nrcnvcob
                                          ,pr_nrdocmto => vr_tab_saldo(vr_index_saldo).nrboleto) LOOP
               --Se o registro for valido
               IF vr_tab_saldo(vr_index_saldo).flgregis = 1 THEN
                 --Acumular valor limite apropriar
                 vr_lim_vlapropr:= Nvl(vr_lim_vlapropr,0) +
                                   Nvl(rw_crapljt.vldjuros,0) +
                                   Nvl(rw_crapljt.vlrestit,0);
               ELSE
                 --Acumular valor limite apropriar sem
                 vr_lim_vlaprops:= Nvl(vr_lim_vlaprops,0) +
                                   Nvl(rw_crapljt.vldjuros,0) +
                                   Nvl(rw_crapljt.vlrestit,0);
               END IF;
               --Atualizar valor dos juros
               vr_tab_saldo(vr_index_saldo).vldjuros:= vr_tab_saldo(vr_index_saldo).vldjuros +
                                                       Nvl(rw_crapljt.vldjuros,0) +
                                                       Nvl(rw_crapljt.vlrestit,0);

             END LOOP;
           END IF;

           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_index_saldo = vr_tab_saldo.FIRST OR
              vr_tab_saldo(vr_index_saldo).cdagenci <> vr_tab_saldo(vr_tab_saldo.PRIOR(vr_index_saldo)).cdagenci THEN

              --Selecionar informacoes das agencias
              OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => vr_tab_saldo(vr_index_saldo).cdagenci);
              FETCH cr_crapage INTO rw_crapage;
              CLOSE cr_crapage;
              -- Adicionar o nó da agências
              pc_escreve_xml('<agencia cdagenci="'||rw_crapage.cdagenci||'" nmresage="'||rw_crapage.nmresage||'">');
           END IF;

           -- Se estivermos processando o ultimo registro do vetor ou mudou a bordero
           IF vr_index_saldo = vr_tab_saldo.LAST OR
              vr_tab_saldo(vr_index_saldo).nrborder <> vr_tab_saldo(vr_tab_saldo.NEXT(vr_index_saldo)).nrborder THEN
             --Incrementar bordero
             vr_lim_totborde:= Nvl(vr_lim_totborde,0) + 1;  /* Borderos por limite */
           END IF;
           -- Se estivermos processando o ultimo registro do vetor ou mudou a conta
           IF vr_index_saldo = vr_tab_saldo.LAST OR
              vr_tab_saldo(vr_index_saldo).nrdconta <> vr_tab_saldo(vr_tab_saldo.NEXT(vr_index_saldo)).nrdconta THEN
             --Buscar o limite da conta
             IF vr_tab_craplim.EXISTS(vr_tab_saldo(vr_index_saldo).nrdconta) THEN
               vr_lim_totsldis:= Nvl(vr_tab_craplim(vr_tab_saldo(vr_index_saldo).nrdconta),0) -
                                 Nvl(vr_lim_vlbrutor,0) -
                                 Nvl(vr_lim_vlbrutos,0);
               vr_vllimite:= vr_tab_craplim(vr_tab_saldo(vr_index_saldo).nrdconta);
             ELSE
               vr_vllimite:= 0;
             END IF;
             
             IF vr_tab_saldo(vr_index_saldo).inpessoa = 1 then
               vr_dspessoa := 'PF';
             ELSE
               vr_dspessoa := 'PJ';
             END IF;

             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<conta>
                  <cdagenci>'||vr_tab_saldo(vr_index_saldo).cdagenci||'</cdagenci>
                  <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_saldo(vr_index_saldo).nrdconta)||'</nrdconta>
                  <nmprimtl>'||vr_tab_saldo(vr_index_saldo).nmprimtl||'</nmprimtl>
                  <inpessoa>'||vr_dspessoa||'</inpessoa>                  
                  <totitulo>'||To_Char(vr_lim_totitulo,'fm999g999')||'</totitulo>
                  <titsemrg>'||To_Char(vr_lim_titsemrg,'fm999g999')||'</titsemrg>
                  <totborde>'||To_Char(vr_lim_totborde,'fm999g999')||'</totborde>
                  <vllimite>'||To_Char(vr_vllimite,'fm999g999g999d00')||'</vllimite>
                  <vlbrutor>'||To_Char(vr_lim_vlbrutor,'fm999g999g999d00')||'</vlbrutor>
                  <vlbrutos>'||To_Char(vr_lim_vlbrutos,'fm999g999g999d00')||'</vlbrutos>
                  <vlapropr>'||To_Char(vr_lim_vlapropr,'fm999g999g999d00')||'</vlapropr>
                  <vlaprops>'||To_Char(vr_lim_vlaprops,'fm999g999g999d00')||'</vlaprops>
                  <totsldis>'||To_Char(vr_lim_totsldis,'fm999g999g999d00')||'</totsldis>
               </conta>');
               
               
             --Sumarizar valores desconto cheques por agencia
             IF NOT vr_tab_tot_dsc_tit.exists(vr_tab_saldo(vr_index_saldo).cdagenci) THEN
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite := NVL(vr_vllimite,0); 
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor := NVL(vr_lim_vlbrutor,0); 
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos := NVL(vr_lim_vlbrutos,0); 
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr := NVL(vr_lim_vlapropr,0);
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops := NVL(vr_lim_vlaprops,0);               
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis := NVL(vr_lim_totsldis,0);                              
             ELSE
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite := vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite + NVL(vr_vllimite,0); 
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor := vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor + NVL(vr_lim_vlbrutor,0); 
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos := vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos + NVL(vr_lim_vlbrutos,0); 
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr := vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr + NVL(vr_lim_vlapropr,0);
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops := vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops + NVL(vr_lim_vlaprops,0);               
               vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis := vr_tab_tot_dsc_tit(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis + NVL(vr_lim_totsldis,0);   
             END IF;                                        

              
             --Sumarizar valores desconto cheques por agencia e tipo de pessoa
             IF NOT vr_tab_tot_dsc_tit_pf_pj.exists(vr_tab_saldo(vr_index_saldo).cdagenci) THEN
               IF vr_tab_saldo(vr_index_saldo).inpessoa = 1 then
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pf := NVL(vr_vllimite,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pf := NVL(vr_lim_vlbrutor,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pf := NVL(vr_lim_vlbrutos,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pf := NVL(vr_lim_vlapropr,0);
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pf := NVL(vr_lim_vlaprops,0);               
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pf := NVL(vr_lim_totsldis,0);                              
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pj := 0; 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pj := 0; 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pj := 0; 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pj := 0;
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pj := 0;               
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pj := 0;                              
               ELSE
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pj := NVL(vr_vllimite,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pj := NVL(vr_lim_vlbrutor,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pj := NVL(vr_lim_vlbrutos,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pj := NVL(vr_lim_vlapropr,0);
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pj := NVL(vr_lim_vlaprops,0);               
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pj := NVL(vr_lim_totsldis,0);                              
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pf := 0; 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pf := 0; 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pf := 0; 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pf := 0;
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pf := 0;               
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pf := 0;                                          
               END IF; 
              
             ELSE
                  
               IF vr_tab_saldo(vr_index_saldo).inpessoa = 1 then
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pf := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pf + NVL(vr_vllimite,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pf := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pf + NVL(vr_lim_vlbrutor,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pf := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pf + NVL(vr_lim_vlbrutos,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pf := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pf + NVL(vr_lim_vlapropr,0);
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pf := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pf + NVL(vr_lim_vlaprops,0);               
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pf := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pf + NVL(vr_lim_totsldis,0);                              
               ELSE
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pj := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vllimite_pj + NVL(vr_vllimite,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pj := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutor_pj + NVL(vr_lim_vlbrutor,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pj := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlbrutos_pj + NVL(vr_lim_vlbrutos,0); 
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pj := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlapropr_pj + NVL(vr_lim_vlapropr,0);
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pj := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).vlaprops_pj + NVL(vr_lim_vlaprops,0);               
                 vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pj := vr_tab_tot_dsc_tit_pf_pj(vr_tab_saldo(vr_index_saldo).cdagenci).totsldis_pj + NVL(vr_lim_totsldis,0); 
               END IF;                   
              
             END IF;
             

             --Zerar Variaveis
             vr_lim_totborde:= 0;
             vr_lim_totitulo:= 0;
             vr_lim_titsemrg:= 0;
             vr_lim_vlbrutor:= 0;
             vr_lim_vlbrutos:= 0;
             vr_lim_vlapropr:= 0;
             vr_lim_vlaprops:= 0;
             vr_lim_totsldis:= 0;
           END IF;

           --Se for o ultimo registro ou mudou a agencia
           IF vr_index_saldo = vr_tab_saldo.LAST OR
              vr_tab_saldo(vr_index_saldo).cdagenci <> vr_tab_saldo(vr_tab_saldo.NEXT(vr_index_saldo)).cdagenci THEN
             --Finalizar tag contas e agencia
             pc_escreve_xml('</agencia>');
           END IF;

           --Encontrar o proximo registro da tabela de memoria
           vr_index_saldo:= vr_tab_saldo.NEXT(vr_index_saldo);
         END LOOP;

         -- Finalizar o agrupador das agencias
         pc_escreve_xml('</agencias>');

         /* Limites Utilizados e Nao Utilizados */

         --Limpar tabela de memoria
         vr_tab_limite.DELETE;
         --Selecionar todas as agencias
         FOR rw_crapage IN cr_crapage_2 (pr_cdcooper => pr_cdcooper) LOOP
           --Selecionar todos os associados
           FOR rw_crapass IN cr_crapass_2 (pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => rw_crapage.cdagenci) LOOP
             --Selecionar primeiro limite
             OPEN cr_craplim_2 (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta);
             --Posicionar no primeiro registro
             FETCH cr_craplim_2 INTO rw_craplim_2;
             --Se Encontrou
             IF cr_craplim_2%FOUND THEN
               /* Titulo pendente */
               OPEN cr_craptdb_2 (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapass.nrdconta);
               --Posicionar no primeiro registro
               FETCH cr_craptdb_2 INTO rw_craptdb_2;
               --Se Encontrou
               IF cr_craptdb_2%FOUND THEN
                 --Se for pessoa fisica
                 IF rw_crapass.inpessoa = 1 THEN
                   --Incrementar qtd utilizada pessoa fisica
                   vr_fis_qtdutili:= Nvl(vr_fis_qtdutili,0) + 1;
                   --Acumular valor utilizado pessoa fisica
                   vr_fis_vlrutili:= Nvl(vr_fis_vlrutili,0) + Nvl(rw_craplim_2.vllimite,0);
                 ELSE
                   --Incrementar qtd utilizada pessoa juridica
                   vr_jur_qtdutili:= Nvl(vr_jur_qtdutili,0) + 1;
                   --Acumular valor utilizado pessoa juridica
                   vr_jur_vlrutili:= Nvl(vr_jur_vlrutili,0) + Nvl(rw_craplim_2.vllimite,0);
                 END IF;
               ELSE
                 --Se for pessoa fisica
                 IF rw_crapass.inpessoa = 1 THEN
                   --Incrementar qtd nao utilizada pessoa fisica
                   vr_fis_qtnaouti:= Nvl(vr_fis_qtnaouti,0) + 1;
                   --Acumular valor nao utilizado pessoa fisica
                   vr_fis_vlrnaout:= Nvl(vr_fis_vlrnaout,0) + Nvl(rw_craplim_2.vllimite,0);
                 ELSE
                   --Incrementar qtd nao utilizada pessoa juridica
                   vr_jur_qtnaouti:= Nvl(vr_jur_qtnaouti,0) + 1;
                   --Acumular valor nao utilizado pessoa juridica
                   vr_jur_vlrnaout:= Nvl(vr_jur_vlrnaout,0) + Nvl(rw_craplim_2.vllimite,0);
                 END IF;
               END IF;
               --Fechar Cursor
               CLOSE cr_craptdb_2;
             END IF;
             --Fechar Cursor
             CLOSE cr_craplim_2;
           END LOOP; --rw_crapass

           --Popular tabela auxiliar limite para total geral
           vr_index_limite:= '0'||LPad(rw_crapage.cdagenci,10,'0');
           vr_tab_limite(vr_index_limite).inpessoa:= 0;
           vr_tab_limite(vr_index_limite).cdagenci:= rw_crapage.cdagenci;
           vr_tab_limite(vr_index_limite).qtdutili:= (Nvl(vr_jur_qtdutili,0) + Nvl(vr_fis_qtdutili,0));
           vr_tab_limite(vr_index_limite).vlrutili:= (Nvl(vr_jur_vlrutili,0) + Nvl(vr_fis_vlrutili,0));
           vr_tab_limite(vr_index_limite).qtnaouti:= (Nvl(vr_jur_qtnaouti,0) + Nvl(vr_fis_qtnaouti,0));
           vr_tab_limite(vr_index_limite).vlrnaout:= (Nvl(vr_jur_vlrnaout,0) + Nvl(vr_fis_vlrnaout,0));

           --Popular tabela auxiliar limite para pessoa fisica
           vr_index_limite:= '1'||LPad(rw_crapage.cdagenci,10,'0');
           vr_tab_limite(vr_index_limite).inpessoa:= 1;
           vr_tab_limite(vr_index_limite).cdagenci:= rw_crapage.cdagenci;
           vr_tab_limite(vr_index_limite).qtdutili:= Nvl(vr_fis_qtdutili,0);
           vr_tab_limite(vr_index_limite).vlrutili:= Nvl(vr_fis_vlrutili,0);
           vr_tab_limite(vr_index_limite).qtnaouti:= Nvl(vr_fis_qtnaouti,0);
           vr_tab_limite(vr_index_limite).vlrnaout:= Nvl(vr_fis_vlrnaout,0);

           --Popular tabela auxiliar limite para pessoa juridica
           vr_index_limite:= '2'||LPad(rw_crapage.cdagenci,10,'0');
           vr_tab_limite(vr_index_limite).inpessoa:= 2;
           vr_tab_limite(vr_index_limite).cdagenci:= rw_crapage.cdagenci;
           vr_tab_limite(vr_index_limite).qtdutili:= Nvl(vr_jur_qtdutili,0);
           vr_tab_limite(vr_index_limite).vlrutili:= Nvl(vr_jur_vlrutili,0);
           vr_tab_limite(vr_index_limite).qtnaouti:= Nvl(vr_jur_qtnaouti,0);
           vr_tab_limite(vr_index_limite).vlrnaout:= Nvl(vr_jur_vlrnaout,0);

           --Zerar variaveis para acumular na nova agencia
           vr_fis_qtdutili:= 0;
           vr_fis_vlrutili:= 0;
           vr_fis_qtnaouti:= 0;
           vr_fis_vlrnaout:= 0;
           vr_jur_qtdutili:= 0;
           vr_jur_vlrutili:= 0;
           vr_jur_qtnaouti:= 0;
           vr_jur_vlrnaout:= 0;

         END LOOP; --rw_crapage
         
         
         --Quadro de resumo de desconto de títulos
         pc_escreve_xml('<resumo_dsc_tit>');
         --Resumo total por agencia de desconto de títulos
         vr_index_limite := null;    
         vr_index_limite := vr_tab_tot_dsc_tit.first;
         LOOP
            
           EXIT WHEN vr_index_limite IS NULL;
           
           IF (vr_tab_tot_dsc_tit(vr_index_limite).vllimite + vr_tab_tot_dsc_tit(vr_index_limite).vlbrutor + 
              vr_tab_tot_dsc_tit(vr_index_limite).vlbrutos + vr_tab_tot_dsc_tit(vr_index_limite).vlapropr +
              vr_tab_tot_dsc_tit(vr_index_limite).vlaprops + vr_tab_tot_dsc_tit(vr_index_limite).totsldis) <> 0 THEN

             pc_escreve_xml('<total_geral>'
                          ||  '<res_cdagenci>'||vr_index_limite||'</res_cdagenci>'
                          ||  '<res_vllimite>'||to_char(vr_tab_tot_dsc_tit(vr_index_limite).vllimite, 'FM999G999G999G990D00')||'</res_vllimite>'
                          ||  '<res_vlbrutor>'||to_char(vr_tab_tot_dsc_tit(vr_index_limite).vlbrutor, 'FM999G999G999G990D00')||'</res_vlbrutor>'
                          ||  '<res_vlbrutos>'||to_char(vr_tab_tot_dsc_tit(vr_index_limite).vlbrutos, 'FM999G999G999G990D00')||'</res_vlbrutos>'
                          ||  '<res_vlapropr>'||to_char(vr_tab_tot_dsc_tit(vr_index_limite).vlapropr, 'FM999G999G999G990D00')||'</res_vlapropr>'                                                                                                                                       
                          ||  '<res_vlaprops>'||to_char(vr_tab_tot_dsc_tit(vr_index_limite).vlaprops, 'FM999G999G999G990D00')||'</res_vlaprops>'                                                                                                                                       
                          ||  '<res_totsldis>'||to_char(vr_tab_tot_dsc_tit(vr_index_limite).totsldis, 'FM999G999G999G990D00')||'</res_totsldis>'                                                                                                                                                                                       
                          ||'</total_geral>');  
           END IF;  
              
           vr_index_limite := vr_tab_tot_dsc_tit.NEXT(vr_index_limite);
              
         END LOOP;
          
         --Resumo por tipo de pessoa e agencia de desconto de títulos
         FOR indpes in 1..2 LOOP
           vr_index_limite := null;
           vr_index_limite := vr_tab_tot_dsc_tit_pf_pj.first;
           LOOP
              
             EXIT WHEN vr_index_limite IS NULL;
              
             
             IF indpes = 1 THEN

               IF (vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vllimite_pf + vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutor_pf + 
                  vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutos_pf + vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlapropr_pf +
                  vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlaprops_pf + vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).totsldis_pf) <> 0 THEN

                
                 pc_escreve_xml('<total_pf>'
                              ||  '<res_cdagenci_pf>'||vr_index_limite||'</res_cdagenci_pf>'
                              ||  '<res_vllimite_pf>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vllimite_pf, 'FM999G999G999G990D00')||'</res_vllimite_pf>'
                              ||  '<res_vlbrutor_pf>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutor_pf, 'FM999G999G999G990D00')||'</res_vlbrutor_pf>'
                              ||  '<res_vlbrutos_pf>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutos_pf, 'FM999G999G999G990D00')||'</res_vlbrutos_pf>'
                              ||  '<res_vlapropr_pf>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlapropr_pf, 'FM999G999G999G990D00')||'</res_vlapropr_pf>'                                                                                                                                       
                              ||  '<res_vlaprops_pf>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlaprops_pf, 'FM999G999G999G990D00')||'</res_vlaprops_pf>'                                                                                                                                       
                              ||  '<res_totsldis_pf>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).totsldis_pf, 'FM999G999G999G990D00')||'</res_totsldis_pf>'                                                                                                                                                                                       
                              ||'</total_pf>');  
               END IF; 
             ELSE
             
               IF (vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vllimite_pj + vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutor_pj + 
                  vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutos_pj + vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlapropr_pj +
                  vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlaprops_pj + vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).totsldis_pj) <> 0 THEN
               
             
                 pc_escreve_xml('<total_pj>'
                              ||  '<res_cdagenci_pj>'||vr_index_limite||'</res_cdagenci_pj>'
                              ||  '<res_vllimite_pj>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vllimite_pj, 'FM999G999G999G990D00')||'</res_vllimite_pj>'
                              ||  '<res_vlbrutor_pj>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutor_pj, 'FM999G999G999G990D00')||'</res_vlbrutor_pj>'
                              ||  '<res_vlbrutos_pj>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlbrutos_pj, 'FM999G999G999G990D00')||'</res_vlbrutos_pj>'
                              ||  '<res_vlapropr_pj>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlapropr_pj, 'FM999G999G999G990D00')||'</res_vlapropr_pj>'                                                                                                                                       
                              ||  '<res_vlaprops_pj>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).vlaprops_pj, 'FM999G999G999G990D00')||'</res_vlaprops_pj>'                                                                                                                                       
                              ||  '<res_totsldis_pj>'||to_char(vr_tab_tot_dsc_tit_pf_pj(vr_index_limite).totsldis_pj, 'FM999G999G999G990D00')||'</res_totsldis_pj>'                                                                                                                                                                                       
                              ||'</total_pj>');            
               END IF;
             END IF; 

              
             vr_index_limite := vr_tab_tot_dsc_tit_pf_pj.NEXT(vr_index_limite);
                
           END LOOP;
         END LOOP;
          
         pc_escreve_xml('</resumo_dsc_tit>');
         
         

         -- Inicializar o agrupador utilizam
         pc_escreve_xml('<utilizam>');

         vr_index_limite:= vr_tab_limite.FIRST;
         WHILE vr_index_limite IS NOT NULL LOOP
           --Somente pegar o inpessoa=0 (todos)
           IF vr_tab_limite(vr_index_limite).inpessoa = 0 THEN
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<pac>
                  <cdagenci>'||vr_tab_limite(vr_index_limite).cdagenci||'</cdagenci>
                  <qtdutili>'||To_Char(vr_tab_limite(vr_index_limite).qtdutili,'fm999g999')||'</qtdutili>
                  <qtnaouti>'||To_Char(vr_tab_limite(vr_index_limite).qtnaouti,'fm999g999')||'</qtnaouti>
                  <vlrutili>'||To_Char(vr_tab_limite(vr_index_limite).vlrutili,'fm999g999g999d00')||'</vlrutili>
                  <vlrnaout>'||To_Char(vr_tab_limite(vr_index_limite).vlrnaout,'fm999g999g999d00')||'</vlrnaout>
               </pac>');
           END IF;

           --Encontrar o proximo registro da tabela de memoria
           vr_index_limite:= vr_tab_limite.NEXT(vr_index_limite);
         END LOOP;

         pc_escreve_xml('</utilizam><utilizam_pf>');

         vr_index_limite:= vr_tab_limite.FIRST;
         WHILE vr_index_limite IS NOT NULL LOOP
           --Somente pegar o inpessoa=1 (fisica)
           IF vr_tab_limite(vr_index_limite).inpessoa = 1 THEN
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<pac_pf>
                  <cdagenci>'||vr_tab_limite(vr_index_limite).cdagenci||'</cdagenci>
                  <qtdutili>'||To_Char(vr_tab_limite(vr_index_limite).qtdutili,'fm999g999')||'</qtdutili>
                  <qtnaouti>'||To_Char(vr_tab_limite(vr_index_limite).qtnaouti,'fm999g999')||'</qtnaouti>
                  <vlrutili>'||To_Char(vr_tab_limite(vr_index_limite).vlrutili,'fm999g999g999d00')||'</vlrutili>
                  <vlrnaout>'||To_Char(vr_tab_limite(vr_index_limite).vlrnaout,'fm999g999g999d00')||'</vlrnaout>
               </pac_pf>');
           END IF;

           --Encontrar o proximo registro da tabela de memoria
           vr_index_limite:= vr_tab_limite.NEXT(vr_index_limite);
         END LOOP;

         -- Finalizar o agrupador utilizam pf e inicia utilizam pj
         pc_escreve_xml('</utilizam_pf><utilizam_pj>');

         vr_index_limite:= vr_tab_limite.FIRST;
         WHILE vr_index_limite IS NOT NULL LOOP
           --Somente pegar o inpessoa=2 (juridica)
           IF vr_tab_limite(vr_index_limite).inpessoa = 2 THEN
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<pac_pj>
                  <cdagenci>'||vr_tab_limite(vr_index_limite).cdagenci||'</cdagenci>
                  <qtdutili>'||To_Char(vr_tab_limite(vr_index_limite).qtdutili,'fm999g999')||'</qtdutili>
                  <qtnaouti>'||To_Char(vr_tab_limite(vr_index_limite).qtnaouti,'fm999g999')||'</qtnaouti>
                  <vlrutili>'||To_Char(vr_tab_limite(vr_index_limite).vlrutili,'fm999g999g999d00')||'</vlrutili>
                  <vlrnaout>'||To_Char(vr_tab_limite(vr_index_limite).vlrnaout,'fm999g999g999d00')||'</vlrnaout>
               </pac_pj>');
           END IF;

           --Encontrar o proximo registro da tabela de memoria
           vr_index_limite:= vr_tab_limite.NEXT(vr_index_limite);
         END LOOP;

         -- Finalizar o agrupador utilizam_pj e o do relatorio
         pc_escreve_xml('</utilizam_pj></crrl494>');
         
         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl494' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl494.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => 'PR_DATA##'||To_Char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')     --> Enviar como parâmetro apenas a data
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 234                 --> 234 colunas
                                    ,pr_sqcabrel  => 2                  --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '234dh'            --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> Gerar o arquivo na hora
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro
         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl494. '||sqlerrm;
       END;

       --Função para retornar o ultimo dia util anterior
       FUNCTION fn_dia_util_anterior (pr_data DATE) RETURN DATE IS
       BEGIN

         /* Pega o ultimo dia util anterior ao parametro */
         RETURN(gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                           ,pr_dtmvtolt => pr_data-1   --> Data do movimento
                                           ,pr_tipo     => 'A'));      --> Tipo de busca (P = próximo, A = anterior)
       EXCEPTION
         WHEN OTHERS THEN
           vr_des_erro:= 'Erro ao calcular data. Rotina crps518.pc_imprime_crrl495.fn_dia_util_anterior '||sqlerrm;
           RAISE vr_exc_erro;
       END;

       --Função para retonar a data de referencia
       FUNCTION fn_calcula_data (pr_data DATE) RETURN DATE IS
         --Variaveis Locais
         vr_dtutiant  DATE;
         vr_dtutiant2 DATE;
       BEGIN
         /* Pega o ultimo dia util anterior */
         vr_dtutiant:= fn_dia_util_anterior(pr_data);
         /* Pega o ultimo dia util anterior da data acima */
         vr_dtutiant2:= fn_dia_util_anterior(vr_dtutiant);
         /* Se teve fim de semana ou feriado */
         IF vr_dtutiant - vr_dtutiant2 > 1 THEN
           RETURN(vr_dtutiant2);
         ELSE
           RETURN(vr_dtutiant);
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           vr_des_erro:= 'Erro ao calcular data. Rotina crps518.pc_imprime_crrl495.fn_calcula_data '||sqlerrm;
           RAISE vr_exc_erro;
       END;


       --Geração do relatório crrl495
       PROCEDURE pc_imprime_crrl495 (pr_des_erro OUT VARCHAR2) IS

         --Cursores Locais

         --Selecionar informacoes dos titulos descontados
         CURSOR cr_craptdb_3 (pr_cdcooper IN craptdb.cdcooper%TYPE
                             ,pr_insittit IN craptdb.insittit%TYPE
                             ,pr_dtresgat IN craptdb.dtresgat%TYPE) IS
           SELECT Nvl(craptdb.vltitulo,0) vltitulo
           FROM craptdb craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
           AND   craptdb.insittit = pr_insittit
           AND   craptdb.dtresgat = pr_dtresgat;

         --Selecionar informacoes dos titulos descontados
         CURSOR cr_craptdb_4 (pr_cdcooper IN craptdb.cdcooper%TYPE
                             ,pr_insittit IN craptdb.insittit%TYPE
                             ,pr_dtrefere IN craptdb.dtvencto%TYPE
                             ,pr_dtmvtolt IN craptdb.dtvencto%TYPE) IS
           SELECT craptdb.vltitulo
                 ,craptdb.dtvencto
           FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
           AND   craptdb.dtvencto >= pr_dtrefere
           AND   craptdb.dtvencto < pr_dtmvtolt
           AND   craptdb.insittit = pr_insittit;

         --Selecionar informacoes dos titulos descontados
         CURSOR cr_craptdb_5 (pr_cdcooper IN craptdb.cdcooper%TYPE
                             ,pr_insittit IN craptdb.insittit%TYPE
                             ,pr_dtpagini IN craptdb.dtdpagto%TYPE
                             ,pr_dtpagfim IN craptdb.dtdpagto%TYPE) IS
           SELECT craptdb.vltitulo
                 ,craptdb.dtvencto
                 ,craptdb.cdcooper
                 ,craptdb.cdbandoc
                 ,craptdb.nrdctabb
                 ,craptdb.nrcnvcob
                 ,craptdb.nrdconta
                 ,craptdb.nrdocmto
                 ,craptdb.rowid
           FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
           AND   craptdb.dtdpagto >  pr_dtpagini
           AND   craptdb.dtdpagto <= pr_dtpagfim
           AND   craptdb.insittit = pr_insittit;

         --Selecionar informacoes dos titulos descontados
         CURSOR cr_craptdb_6 (pr_cdcooper IN craptdb.cdcooper%TYPE
                             ,pr_dtlibbdt IN craptdb.dtlibbdt%TYPE) IS
           SELECT Nvl(craptdb.vltitulo,0) vltitulo
           FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
           AND   craptdb.dtlibbdt = pr_dtlibbdt;

         --Selecionar informacoes dos titulos descontados
         CURSOR cr_craptdb_7 (pr_cdcooper IN craptdb.cdcooper%TYPE) IS
           SELECT craptdb.vltitulo
                 ,craptdb.dtvencto
                 ,craptdb.cdcooper
                 ,craptdb.cdbandoc
                 ,craptdb.nrdctabb
                 ,craptdb.nrcnvcob
                 ,craptdb.nrdconta
                 ,craptdb.nrdocmto
                 ,craptdb.dtlibbdt
                 ,craptdb.dtresgat
                 ,craptdb.insittit
                 ,craptdb.dtdpagto
                 ,craptdb.rowid
           FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper;

         --Selecionar informacoes de cobranca
         CURSOR cr_crapcob_2 (pr_cdcooper IN crapcob.cdcooper%TYPE
                             ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                             ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                             ,pr_nrdconta IN crapcob.nrdconta%TYPE
                             ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
           SELECT crapcob.indpagto
                 ,crapcob.dsdoccop
                 ,crapcob.nrdocmto
                 ,crapcob.flgregis
                 ,crapcob.cdbandoc
           FROM crapcob crapcob
           WHERE crapcob.cdcooper = pr_cdcooper
           AND   crapcob.cdbandoc = pr_cdbandoc
           AND   crapcob.nrdctabb = pr_nrdctabb
           AND   crapcob.nrcnvcob = pr_nrcnvcob
           AND   crapcob.nrdconta = pr_nrdconta
           AND   crapcob.nrdocmto = pr_nrdocmto;
         rw_crapcob_2 cr_crapcob_2%ROWTYPE;


         --Variaveis locais
         vr_dsregis      VARCHAR2(20);
         vr_qttitulo_com INTEGER:= 0;
         vr_qttitulo_sem INTEGER:= 0;
         vr_res_qtderesg INTEGER:= 0;
         vr_res_qtvencid INTEGER:= 0;
         vr_res_qttitulo INTEGER:= 0;
         vr_qtd_liberado INTEGER:= 0;
         vr_qtd_saldo    INTEGER:= 0;
         vr_qtd_pgdepois INTEGER:= 0;
         vr_qtd_rgdepois INTEGER:= 0;
         vr_diffdias     INTEGER:= 0;
         vr_qtd_bxdepois INTEGER:= 0;
         vr_vldjuros_com NUMBER:= 0;
         vr_vldjuros_sem NUMBER:= 0;
         vr_vltitulo_com NUMBER:= 0;
         vr_vltitulo_sem NUMBER:= 0;
         vr_res_vlderesg NUMBER:= 0;
         vr_res_vlvencid NUMBER:= 0;
         vr_res_vltitulo NUMBER:= 0;
         vr_res_qtsldant NUMBER:= 0;
         vr_res_qtcredit NUMBER:= 0;
         vr_res_vlsldant NUMBER:= 0;
         vr_res_vlcredit NUMBER:= 0;
         vr_vlr_liberado NUMBER:= 0;
         vr_vlr_saldo    NUMBER:= 0;
         vr_vlr_pgdepois NUMBER:= 0;
         vr_vlr_rgdepois NUMBER:= 0;
         vr_vlr_bxdepois NUMBER:= 0;
         vr_flgproces    BOOLEAN;
         vr_dtrefere     DATE;
         vr_dtmvtoan     DATE;

          --Variavel de Exceção
         vr_exc_erro EXCEPTION;

         --Variaveis de arquivo
         vr_nom_direto   VARCHAR2(100);
         vr_nom_arquivo  VARCHAR2(100);

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= NULL;

         -- Busca do diretório base da cooperativa para PDF
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl495>');
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl495';

         --Acessar primeiro registro da tabela de memoria crrl493
         vr_index_vencto:= vr_tab_vencto.FIRST;
         WHILE vr_index_vencto IS NOT NULL  LOOP

           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_index_vencto = vr_tab_vencto.FIRST OR
              vr_tab_vencto(vr_index_vencto).cdagenci <> vr_tab_vencto(vr_tab_vencto.PRIOR(vr_index_vencto)).cdagenci THEN

              --Selecionar informacoes das agencias
              OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => vr_tab_vencto(vr_index_vencto).cdagenci);
              FETCH cr_crapage INTO rw_crapage;
              CLOSE cr_crapage;
              -- Adicionar o nó da agências
              pc_escreve_xml('<agencia cdagenci="'||rw_crapage.cdagenci||'" nmresage="'||rw_crapage.nmresage||'">');
           END IF;

           -- Se estivermos processando o primeiro registro do vetor ou mudou a conta do associado
           IF vr_index_vencto = vr_tab_vencto.FIRST OR
              vr_tab_vencto(vr_index_vencto).nrdconta <> vr_tab_vencto(vr_tab_vencto.PRIOR(vr_index_vencto)).nrdconta THEN

              -- Adicionar o nó da conta
              pc_escreve_xml('<conta nrdconta="'||GENE0002.fn_mask_conta(vr_tab_vencto(vr_index_vencto).nrdconta)||
                                  '" nmprimtl="'||vr_tab_vencto(vr_index_vencto).nmprimtl||'">');
           END IF;

           --Determinar se é registrada ou nao
           IF vr_tab_vencto(vr_index_vencto).flgregis = 1 THEN
             vr_dsregis:= 'Registrada';
             vr_vldjuros_com:= vr_tab_vencto(vr_index_vencto).vldjuros;
             vr_vldjuros_sem:= 0;
             vr_vltitulo_com:= vr_tab_vencto(vr_index_vencto).vltitulo;
             vr_vltitulo_sem:= 0;
             vr_qttitulo_com:= 1;
             vr_qttitulo_sem:= 0;
           ELSE
             vr_dsregis:= 'Sem Registro';
             vr_vldjuros_com:= 0;
             vr_vldjuros_sem:= vr_tab_vencto(vr_index_vencto).vldjuros;
             vr_vltitulo_com:= 0;
             vr_vltitulo_sem:= vr_tab_vencto(vr_index_vencto).vltitulo;
             vr_qttitulo_com:= 0;
             vr_qttitulo_sem:= 1;
           END IF;

           --Montar tag da conta para arquivo XML
           pc_escreve_xml
               ('<vencto>
                  <dtvencto>'||To_Char(vr_tab_vencto(vr_index_vencto).dtvencto,'DD/MM/YY')||'</dtvencto>
                  <dtlibbdt>'||To_Char(vr_tab_vencto(vr_index_vencto).dtlibbdt,'DD/MM/YY')||'</dtlibbdt>
                  <nrborder>'||To_Char(vr_tab_vencto(vr_index_vencto).nrborder,'fm9g999g999')||'</nrborder>
                  <nrcnvcob>'||To_Char(vr_tab_vencto(vr_index_vencto).nrcnvcob,'fm999g999g999')||'</nrcnvcob>
                  <nrboleto>'||GENE0002.fn_mask_conta(vr_tab_vencto(vr_index_vencto).nrboleto)||'</nrboleto>
                  <dsdoccop>'||vr_tab_vencto(vr_index_vencto).dsdoccop||'</dsdoccop>
                  <flgregis>'||vr_dsregis||'</flgregis>
                  <nmdsacad>'||GENE0007.fn_caract_controle(vr_tab_vencto(vr_index_vencto).nmdsacad)||'</nmdsacad>
                  <vlliquid>'||To_Char(vr_tab_vencto(vr_index_vencto).vlliquid,'fm999g999g999d00')||'</vlliquid>
                  <vltitulo>'||To_Char(vr_tab_vencto(vr_index_vencto).vltitulo,'fm999g999g999d00')||'</vltitulo>
                  <vldjuros>'||To_Char(vr_tab_vencto(vr_index_vencto).vldjuros,'fm999g999g999d00')||'</vldjuros>
                  <nrinssac>'||vr_tab_vencto(vr_index_vencto).nrinssac||'</nrinssac>
                  <qttitulo_com>'||vr_qttitulo_com||'</qttitulo_com>
                  <qttitulo_sem>'||vr_qttitulo_sem||'</qttitulo_sem>
                  <vltitulo_com>'||To_Char(vr_vltitulo_com,'fm999g999g999d00')||'</vltitulo_com>
                  <vltitulo_sem>'||To_Char(vr_vltitulo_sem,'fm999g999g999d00')||'</vltitulo_sem>
                  <vldjuros_com>'||To_Char(vr_vldjuros_com,'fm999g999g999d00')||'</vldjuros_com>
                  <vldjuros_sem>'||To_Char(vr_vldjuros_sem,'fm999g999g999d00')||'</vldjuros_sem>
               </vencto>');


           --Se for ultimo registro do vetor ou ultimo da conta
           IF vr_index_vencto = vr_tab_vencto.LAST OR
              vr_tab_vencto(vr_index_vencto).nrdconta <> vr_tab_vencto(vr_tab_vencto.NEXT(vr_index_vencto)).nrdconta THEN
             -- Finalizar o agrupador da agencia
             pc_escreve_xml('</conta>');
           END IF;

           --Se for ultimo registro do vetor ou ultimo da agencia
           IF vr_index_vencto = vr_tab_vencto.LAST OR
              vr_tab_vencto(vr_index_vencto).cdagenci <> vr_tab_vencto(vr_tab_vencto.NEXT(vr_index_vencto)).cdagenci THEN
             -- Finalizar o agrupador da agencia
             pc_escreve_xml('</agencia>');
           END IF;
           --Encontrar o proximo registro da tabela de memoria
           vr_index_vencto:= vr_tab_vencto.NEXT(vr_index_vencto);
         END LOOP;

         /* Saldo contabil */

         /* Resgatados no dia */
         --Zerar valores resgatados
         vr_res_qtderesg:= 0;
         vr_res_vlderesg:= 0;
         FOR rw_craptdb IN cr_craptdb_3 (pr_cdcooper => pr_cdcooper
                                        ,pr_insittit => 1
                                        ,pr_dtresgat => rw_crapdat.dtmvtolt) LOOP
           --Diminuir a quantidade resgatada
           vr_res_qtderesg:= vr_res_qtderesg - 1;
           vr_res_vlderesg:= vr_res_vlderesg - rw_craptdb.vltitulo;
         END LOOP;

         --Data de referencia
         vr_dtrefere:= fn_calcula_data(rw_crapdat.dtmvtolt);
         --Movimento anterior
         vr_dtmvtoan:= fn_dia_util_anterior(rw_crapdat.dtmvtolt);

         /* Baixados sem pagamento no dia */
         --Zerar variaveis
         vr_res_qtvencid:= 0;
         vr_res_vlvencid:= 0;
         FOR rw_craptdb IN cr_craptdb_4 (pr_cdcooper => pr_cdcooper
                                        ,pr_insittit => 3
                                        ,pr_dtrefere => vr_dtrefere
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
           --Marcar flag pra processar registro
           vr_flgproces:= TRUE;
           /* No caso de fim de semana e feriado, nao pega os titulos
              que ja foram pegos no dia anterior a ontem */
           IF Trunc(vr_dtrefere) <> Trunc(vr_dtmvtoan)  AND
              Trunc(rw_craptdb.dtvencto) = Trunc(vr_dtrefere) THEN
             --marcar flag para nao processar
             vr_flgproces:= FALSE;
           END IF;

           /* Nao contabilizar os titulos que vencem no final de semana
              na segunda-feira pois soh serao debitados na terca */
           IF To_Number(To_Char(rw_craptdb.dtvencto,'D')) IN (1,7) AND
              To_Number(To_Char(rw_crapdat.dtmvtolt,'D')) = 2 THEN
             --marcar flag para nao processar
             vr_flgproces:= FALSE;
           END IF;

           --Se for para processar
           IF vr_flgproces THEN
             --Diminuir quantidade vencida
             vr_res_qtvencid:= vr_res_qtvencid - 1;
             --Diminuir valor vencido
             vr_res_vlvencid:= vr_res_vlvencid - rw_craptdb.vltitulo;
           END IF;
         END LOOP;

         /* Pagos pelo SACADO - via COMPE... */

         --Data de referencia
         vr_dtrefere:= fn_dia_util_anterior(vr_dtmvtoan);

         --Selecionar informacoes dos titulos
         FOR rw_craptdb IN cr_craptdb_5 (pr_cdcooper => pr_cdcooper
                                        ,pr_insittit => 2
                                        ,pr_dtpagini => vr_dtrefere
                                        ,pr_dtpagfim => vr_dtmvtoan) LOOP
           --marcar flag para processar registro
           vr_flgproces:= TRUE;
           --Selecionar informacoes de cobranca
           OPEN cr_crapcob_2 (pr_cdcooper => rw_craptdb.cdcooper
                             ,pr_cdbandoc => rw_craptdb.cdbandoc
                             ,pr_nrdctabb => rw_craptdb.nrdctabb
                             ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                             ,pr_nrdconta => rw_craptdb.nrdconta
                             ,pr_nrdocmto => rw_craptdb.nrdocmto);
           --Posicionar no primeiro registro
           FETCH cr_crapcob_2 INTO rw_crapcob_2;
           --Se nao encontrou
           IF cr_crapcob_2%NOTFOUND THEN
             vr_des_erro:= 'Titulo em desconto nao encontrado na crapcob = '||rw_craptdb.rowid;
             --Escrever mensagem no log
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_des_erro );
             --Não processar registro
             vr_flgproces:= FALSE;
           END IF;
           --Fechar Cursor
           CLOSE cr_crapcob_2;

           --Se for para processar
           IF vr_flgproces THEN
             /* Pago pela COMPE */
             /* apenas para titulos do BB */
             IF  rw_crapcob_2.indpagto = 0 AND rw_crapcob_2.cdbandoc = 1 THEN
               --Diminuir a quantidade de vencidos
               vr_res_qtvencid:= vr_res_qtvencid-1;
               --Diminuir valor titulos
               vr_res_vlvencid:= vr_res_vlvencid - rw_craptdb.vltitulo;
             END IF;
           END IF;
         END LOOP;

         /* Pagos pelo SACADO - via CAIXA... */
         --Selecionar informacoes dos titulos
         FOR rw_craptdb IN cr_craptdb_5 (pr_cdcooper => pr_cdcooper
                                        ,pr_insittit => 2
                                        ,pr_dtpagini => vr_dtmvtoan
                                        ,pr_dtpagfim => rw_crapdat.dtmvtolt) LOOP
           --Marcar flag para processar registro
           vr_flgproces:= TRUE;
           --Selecionar informacoes de cobranca
           OPEN cr_crapcob_2 (pr_cdcooper => rw_craptdb.cdcooper
                             ,pr_cdbandoc => rw_craptdb.cdbandoc
                             ,pr_nrdctabb => rw_craptdb.nrdctabb
                             ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                             ,pr_nrdconta => rw_craptdb.nrdconta
                             ,pr_nrdocmto => rw_craptdb.nrdocmto);
           --Posicionar no primeiro registro
           FETCH cr_crapcob_2 INTO rw_crapcob_2;
           --Se nao encontrou
           IF cr_crapcob_2%NOTFOUND THEN
             vr_des_erro:= 'Titulo em desconto nao encontrado na crapcob = '||rw_craptdb.rowid;
             --Escrever mensagem no log
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_des_erro );
             --Não processar registro
             vr_flgproces:= FALSE;
           END IF;
           --Fechar Cursor
           CLOSE cr_crapcob_2;

           --Se for para processar
           IF vr_flgproces THEN
             /* Pago pelo CAIXA, InternetBank ou TAA, e compe 085 */
             IF  rw_crapcob_2.indpagto IN (1,3,4) OR
                 (rw_crapcob_2.indpagto = 0 AND rw_crapcob_2.cdbandoc = 85) THEN
               --Diminuir a quantidade de vencidos
               vr_res_qtvencid:= vr_res_qtvencid-1;
               --Diminuir valor titulos
               vr_res_vlvencid:= vr_res_vlvencid - rw_craptdb.vltitulo;
             END IF;
           END IF;
         END LOOP;

         /* Recebidos no dia */
         --Selecionar informacoes dos titulos
         FOR rw_craptdb IN cr_craptdb_6 (pr_cdcooper => pr_cdcooper
                                        ,pr_dtlibbdt => rw_crapdat.dtmvtolt) LOOP
           --Aumentar a quantidade de titulos
           vr_res_qttitulo:= vr_res_qttitulo + 1;
           --Aumentar o valor dos titulos
           vr_res_vltitulo:= vr_res_vltitulo + rw_craptdb.vltitulo;
         END LOOP;

         /* Saldo Anterior */

         --Zerar Variaveis
         vr_vlr_liberado:= 0;
         vr_qtd_liberado:= 0;
         vr_vlr_saldo:= 0;
         vr_qtd_saldo:= 0;
         vr_vlr_pgdepois:= 0;
         vr_qtd_pgdepois:= 0;
         vr_vlr_rgdepois:= 0;
         vr_qtd_rgdepois:= 0;
         vr_diffdias:= 0;
         vr_vlr_bxdepois:= 0;
         vr_qtd_bxdepois:= 0;
         --Selecionar informacoes dos titulos
         FOR rw_craptdb IN cr_craptdb_7 (pr_cdcooper => pr_cdcooper) LOOP
           BEGIN
             --Data liberacao >= Data Movimento
             IF rw_craptdb.dtlibbdt >= rw_crapdat.dtmvtolt  THEN
               --Incrementa quantidade e valor liberado
               vr_qtd_liberado:= vr_qtd_liberado + 1;
               vr_vlr_liberado:= vr_vlr_liberado + rw_craptdb.vltitulo;
             END IF;
             --Se o titulo estiver liberado
             IF rw_craptdb.insittit = 4  THEN
               --Incrementar a quantidade e valor do saldo
               vr_qtd_saldo:= vr_qtd_saldo + 1;
               vr_vlr_saldo:= vr_vlr_saldo + rw_craptdb.vltitulo;
             END IF;
             --Selecionar informacoes de cobranca
             OPEN cr_crapcob_2 (pr_cdcooper => rw_craptdb.cdcooper
                               ,pr_cdbandoc => rw_craptdb.cdbandoc
                               ,pr_nrdctabb => rw_craptdb.nrdctabb
                               ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                               ,pr_nrdconta => rw_craptdb.nrdconta
                               ,pr_nrdocmto => rw_craptdb.nrdocmto);
             --Posicionar no primeiro registro
             FETCH cr_crapcob_2 INTO rw_crapcob_2;
             --Se nao encontrou
             IF cr_crapcob_2%NOTFOUND THEN
               --Fechar Cursor
               CLOSE cr_crapcob_2;
               vr_des_erro:= 'Titulo em desconto nao encontrado na crapcob = '||rw_craptdb.rowid;
               --Escrever mensagem no log
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_des_erro );
               --Não processar registro
               RAISE vr_exc_pula;
             END IF;
             --Fechar Cursor
             CLOSE cr_crapcob_2;

             /* D + 1 para titulos pagos via COMPE apenas para titulos BB */
             IF rw_crapcob_2.indpagto = 0 AND rw_crapcob_2.cdbandoc = 1 THEN
               --Se data pagamento > data util anterior
               IF rw_craptdb.dtdpagto >= vr_dtmvtoan THEN
                 --Incrementar quantidade e valor pago depois
                 vr_qtd_pgdepois:= vr_qtd_pgdepois + 1;
                 vr_vlr_pgdepois:= vr_vlr_pgdepois + rw_craptdb.vltitulo;
                 --Pular para proximo registro
                 RAISE vr_exc_pula;
               END IF;
             ELSE
               --Se data pagamento > data movimento
               IF rw_craptdb.dtdpagto >= rw_crapdat.dtmvtolt THEN
                 --Incrementar quantidade e valor pago depois
                 vr_qtd_pgdepois:= vr_qtd_pgdepois + 1;
                 vr_vlr_pgdepois:= vr_vlr_pgdepois + rw_craptdb.vltitulo;
                 --Pular para proximo registro
                 RAISE vr_exc_pula;
               END IF;
             END IF;
             -- Data resgate >= Data movimento
             IF rw_craptdb.dtresgat >= rw_crapdat.dtmvtolt THEN
               --Incrementar quantidade e valor resgatados depois
               vr_qtd_rgdepois:= vr_qtd_rgdepois + 1;
               vr_vlr_rgdepois:= vr_vlr_rgdepois + rw_craptdb.vltitulo;
               --Pular para proximo registro
               RAISE vr_exc_pula;
             END IF;

             --Diferenca dias recebe movimento anterior menos data vencimento
             vr_diffdias:= vr_dtmvtoan - rw_craptdb.dtvencto;

             /* Quando a pessoa informa um dia que for terca feira
                contabilizar os baixados sem pagamento do final de semana
                passado na terca feira */
             IF To_Number(To_Char(rw_craptdb.dtvencto,'D')) IN (1,7) AND
                To_Number(To_Char(vr_dtmvtoan,'D')) = 2 AND
                rw_craptdb.insittit  = 3 AND
                vr_diffdias IN (1,2,3) THEN
               --Incrementar quantidade e valor baixados depois
               vr_qtd_bxdepois:= vr_qtd_bxdepois + 1;
               vr_vlr_bxdepois:= vr_vlr_bxdepois + rw_craptdb.vltitulo;
               --Pular para proximo registro
               RAISE vr_exc_pula;
             END IF;
             --Titulo Baixado e vencimento maior igual util anterior
             IF rw_craptdb.insittit  = 3 AND rw_craptdb.dtvencto >= vr_dtmvtoan THEN
               --Incrementar quantidade e valor baixados depois
               vr_qtd_bxdepois:= vr_qtd_bxdepois + 1;
               vr_vlr_bxdepois:= vr_vlr_bxdepois + rw_craptdb.vltitulo;
             END IF;
           EXCEPTION
             WHEN vr_exc_pula THEN
               NULL;
             WHEN OTHERS THEN
               RAISE vr_exc_erro;
           END;
         END LOOP;

         --Montar variaveis para relatorio

         --Quantidade saldo anterior
         vr_res_qtsldant:= (Nvl(vr_qtd_pgdepois,0) + Nvl(vr_qtd_rgdepois,0) + Nvl(vr_qtd_bxdepois,0)) +
                           (Nvl(vr_qtd_saldo,0) - Nvl(vr_qtd_liberado,0));
         --Quantidade credito
         vr_res_qtcredit:= Nvl(vr_res_qtsldant,0) + Nvl(vr_res_qtvencid,0) + Nvl(vr_res_qttitulo,0) + Nvl(vr_res_qtderesg,0);
         --Valor saldo anterior
         vr_res_vlsldant:= (Nvl(vr_vlr_pgdepois,0) + Nvl(vr_vlr_rgdepois,0) + Nvl(vr_vlr_bxdepois,0)) +
                           (Nvl(vr_vlr_saldo,0) - Nvl(vr_vlr_liberado,0));
         --Valor credito
         vr_res_vlcredit:= Nvl(vr_res_vlsldant,0) + Nvl(vr_res_vlvencid,0) + Nvl(vr_res_vltitulo,0) + Nvl(vr_res_vlderesg,0);

         -- Inicia o agrupador dos totais para contabilidade
         pc_escreve_xml('<totais>');

         --Montar tag da conta para arquivo XML
         pc_escreve_xml
            (' <tf_dtmvtolt>'||To_Char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'</tf_dtmvtolt>
               <tf_qtsldant>'||To_Char(vr_res_qtsldant,'fm999g999g999')||'</tf_qtsldant>
               <tf_vlsldant>'||To_Char(vr_res_vlsldant,'fm999g999g990d00')||'</tf_vlsldant>
               <tf_qttitulo>'||To_Char(vr_res_qttitulo,'fm999g999g999')||'</tf_qttitulo>
               <tf_vltitulo>'||To_Char(vr_res_vltitulo,'fm999g999g990d00')||'</tf_vltitulo>
               <tf_qtvencid>'||To_Char(vr_res_qtvencid,'fm999g999g999')||'</tf_qtvencid>
               <tf_vlvencid>'||To_Char(vr_res_vlvencid,'fm999g999g990d00')||'</tf_vlvencid>
               <tf_qtderesg>'||To_Char(vr_res_qtderesg,'fm999g999g999')||'</tf_qtderesg>
               <tf_vlderesg>'||To_Char(vr_res_vlderesg,'fm999g999g990d00')||'</tf_vlderesg>
               <tf_qtcredit>'||To_Char(vr_res_qtcredit,'fm999g999g999')||'</tf_qtcredit>
               <tf_vlcredit>'||To_Char(vr_res_vlcredit,'fm999g999g990d00')||'</tf_vlcredit>
            ');

         -- Finalizar o agrupador de totais e do relatório
         pc_escreve_xml('</totais></crrl495>');

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl495/agencia/conta/vencto' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl495.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => 'PR_DATA##'||To_Char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')  --> Data do movimento
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 234                 --> 234 colunas
                                    ,pr_sqcabrel  => 3                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '234dh'             --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> Gerar o arquivo na hora
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro

         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl495. '||sqlerrm;
       END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps518
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS518';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS518'
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Sair do programa
         RAISE vr_exc_erro;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar tabela de memoria de Sacados Cobranca
       FOR rw_crapsab IN cr_crapsab (pr_cdcooper => pr_cdcooper) LOOP
         --Montar indice para a tabela temporaria
         vr_index_crapsab:= LPad(rw_crapsab.nrdconta,10,'0')||LPad(rw_crapsab.nrinssac,25,'0');
         vr_tab_crapsab(vr_index_crapsab).nmdsacad:= rw_crapsab.nmdsacad;
         vr_tab_crapsab(vr_index_crapsab).nrinssac:= rw_crapsab.nrinssac;
       END LOOP;

       --Carregar tabela memoria de Limites das Contas
       FOR rw_craplim IN cr_craplim (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craplim(rw_craplim.nrdconta):= rw_craplim.vllimite;
       END LOOP;

       /* Borderos liberados na data de atual Rel493 */
       FOR rw_crapbdt IN cr_crapbdt (pr_cdcooper => pr_cdcooper
                                    ,pr_dtlibbdt => rw_crapdat.dtmvtolt) LOOP

         --Zerar Variaveis para somar titulos
         vr_bor_totitulo:= 0;
         vr_bor_totvlbru:= 0;
         vr_bor_totvlliq:= 0;
         vr_bor_totvljur:= 0;
         vr_bor_vlrmedio:= 0;

         /* Titulos do bordero */
         FOR rw_craptdb IN cr_craptdb (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapbdt.nrdconta
                                      ,pr_nrborder => rw_crapbdt.nrborder) LOOP

           --Incrementar borderos
           vr_bor_totitulo:= Nvl(vr_bor_totitulo,0) + 1;
           --Acumular valor bruto
           vr_bor_totvlbru:= Nvl(vr_bor_totvlbru,0) + rw_craptdb.vltitulo;
           --Acumular valor liquido
           vr_bor_totvlliq:= Nvl(vr_bor_totvlliq,0) + rw_craptdb.vlliquid;
           --Acumular valor juros do bordero
           vr_bor_totvljur:= Nvl(vr_bor_totvljur,0) + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
         END LOOP; --rw_craptdb

         --Calcular a media dos borderos
         IF Nvl(vr_bor_totitulo,0) > 0 THEN
           vr_bor_vlrmedio:= Nvl(vr_bor_totvlbru,0) / Nvl(vr_bor_totitulo,0);
         END IF;

         --Atualizar tabela memória para gerar relatório
         vr_index_crrl493:= LPad(rw_crapbdt.cdagenci,10,'0')||
                            LPad(rw_crapbdt.nrdconta,10,'0')||
                            LPad(rw_crapbdt.nrctrlim,10,'0')||
                            LPad(rw_crapbdt.nrborder,10,'0');
         vr_tab_crrl493(vr_index_crrl493).cdagenci:= rw_crapbdt.cdagenci;
         vr_tab_crrl493(vr_index_crrl493).nrdconta:= rw_crapbdt.nrdconta;
         vr_tab_crrl493(vr_index_crrl493).nmprimtl:= rw_crapbdt.nmprimtl;
         vr_tab_crrl493(vr_index_crrl493).nrctrlim:= rw_crapbdt.nrctrlim;
         vr_tab_crrl493(vr_index_crrl493).nrborder:= rw_crapbdt.nrborder;
         vr_tab_crrl493(vr_index_crrl493).totitulo:= vr_bor_totitulo;
         vr_tab_crrl493(vr_index_crrl493).totvlbru:= vr_bor_totvlbru;
         vr_tab_crrl493(vr_index_crrl493).totvlliq:= vr_bor_totvlliq;
         vr_tab_crrl493(vr_index_crrl493).totvljur:= vr_bor_totvljur;
         vr_tab_crrl493(vr_index_crrl493).vlrmedio:= vr_bor_vlrmedio;

       END LOOP; --rw_crapbdt

       --Executar relatório crrl493
       pc_imprime_crrl493 (pr_des_erro => vr_des_erro);
       --Se retornou erro
       IF vr_des_erro IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_erro;
       END IF;

       /* Se for ultimo dia do mes, cria relatorios rel494, rel495 */
       IF To_Number(To_Char(rw_crapdat.dtmvtolt,'YYYYMM')) =
          To_Number(To_Char(rw_crapdat.dtmvtopr,'YYYYMM')) THEN
         --Sair do programa
         RAISE vr_exc_fim;
       END IF;

       /* Relatorio desconto de titulos Rel494 */
       FOR rw_crapbdt IN cr_crapbdt_494 (pr_cdcooper => pr_cdcooper) LOOP

         /* Titulos do bordero */
         FOR rw_craptdb IN cr_craptdb_494 (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapbdt.nrdconta
                                          ,pr_nrborder => rw_crapbdt.nrborder
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

           --Inicializar flag processa registro
           vr_flgproces:= TRUE;
           --Verificar se o titulo existe
           OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                           ,pr_cdbandoc => rw_craptdb.cdbandoc
                           ,pr_nrdctabb => rw_craptdb.nrdctabb
                           ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                           ,pr_nrdconta => rw_craptdb.nrdconta
                           ,pr_nrdocmto => rw_craptdb.nrdocmto);
           --Posicionar no primeiro registro
           FETCH cr_crapcob INTO rw_crapcob;
           --Se nao encontrou
           IF cr_crapcob%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapcob;
             vr_des_erro:= 'Titulo em desconto nao encontrado na crapcob = '||rw_craptdb.rowid;
             --Escrever mensagem no log
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_des_erro );
             --Não processar registro
             vr_flgproces:= FALSE;
           END IF;
           --Fechar Cursor
           CLOSE cr_crapcob;

           /*  Se foi pago via CAIXA, InternetBank ou TAA ou compe 085
               Despreza, pois ja esta pago, o dinheiro ja entrou para a cooperativa */
           IF rw_craptdb.insittit = 2  AND
             (rw_crapcob.indpagto IN (1,3,4) OR (rw_crapcob.indpagto = 0 AND rw_crapcob.cdbandoc = 085)) THEN
             --Marcar para nao processar
             vr_flgproces:= FALSE;
           END IF;

           --Se deve processar registro
           IF vr_flgproces THEN

             --Se existir sacado
             vr_index_crapsab:= LPad(rw_craptdb.nrdconta,10,'0')||LPad(rw_craptdb.nrinssac,25,'0');
             IF vr_tab_crapsab.EXISTS(vr_index_crapsab) THEN
               vr_nmdsacad:= vr_tab_crapsab(vr_index_crapsab).nmdsacad;
               vr_nrinssac:= vr_tab_crapsab(vr_index_crapsab).nrinssac;
             ELSE
               vr_nmdsacad:= NULL;
               vr_nrinssac:= NULL;
             END IF;
             
             IF rw_crapbdt.flverbor = 0 THEN
               vr_vltitulo := rw_craptdb.vltitulo;
             ELSE
               vr_vltitulo := rw_craptdb.vltitmra;
             END IF;

             --Atualizar tabela memória para gerar relatório 495
             vr_index_saldo:= LPad(rw_craptdb.cdagenci,10,'0')||
                              LPad(rw_craptdb.nrdconta,10,'0')||
                              LPad(rw_craptdb.nrborder,10,'0')||
                              LPad(rw_craptdb.nrdocmto,10,'0')||
                              LPad(vr_nrinssac,25,'0')||
                              LPAD(vr_tab_saldo.COUNT(),10,0);

             --Inserir tabela memoria de saldo
             vr_tab_saldo(vr_index_saldo).nrdconta:= rw_craptdb.nrdconta;
             vr_tab_saldo(vr_index_saldo).nmprimtl:= rw_craptdb.nmprimtl;
             vr_tab_saldo(vr_index_saldo).dtvencto:= rw_craptdb.dtvencto;
             vr_tab_saldo(vr_index_saldo).dtlibbdt:= rw_craptdb.dtlibbdt;
             vr_tab_saldo(vr_index_saldo).nrborder:= rw_craptdb.nrborder;
             vr_tab_saldo(vr_index_saldo).nrcnvcob:= rw_craptdb.nrcnvcob;
             vr_tab_saldo(vr_index_saldo).vlliquid:= rw_craptdb.vlliquid;
             vr_tab_saldo(vr_index_saldo).vltitulo:= vr_vltitulo;
             vr_tab_saldo(vr_index_saldo).vldjuros:= 0;
             vr_tab_saldo(vr_index_saldo).dsdoccop:= rw_crapcob.dsdoccop;
             vr_tab_saldo(vr_index_saldo).nrboleto:= rw_crapcob.nrdocmto;
             vr_tab_saldo(vr_index_saldo).nmdsacad:= vr_nmdsacad;
             vr_tab_saldo(vr_index_saldo).nrinssac:= vr_nrinssac;
             vr_tab_saldo(vr_index_saldo).cdagenci:= rw_craptdb.cdagenci;
             vr_tab_saldo(vr_index_saldo).cdcooper:= pr_cdcooper;
             vr_tab_saldo(vr_index_saldo).insittit:= rw_craptdb.insittit;
             vr_tab_saldo(vr_index_saldo).cdbandoc:= rw_craptdb.cdbandoc;
             vr_tab_saldo(vr_index_saldo).nrdctabb:= rw_craptdb.nrdctabb;
             vr_tab_saldo(vr_index_saldo).flgregis:= rw_crapcob.flgregis;
             vr_tab_saldo(vr_index_saldo).inpessoa:= rw_craptdb.inpessoa;
           END IF;
         END LOOP; --rw_craptdb_494
       END LOOP; --rw_crapbdt_494

       --Executar relatório crrl494
       pc_imprime_crrl494 (pr_des_erro => vr_des_erro);
       --Se retornou erro
       IF vr_des_erro IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_erro;
       END IF;

       --Reordenar o vetor vr_tab_saldo por vencimento para relatorio crrl495
       vr_index_saldo:= vr_tab_saldo.FIRST;
       WHILE vr_index_saldo IS NOT NULL LOOP
         --Montar o novo indice usando agencia + conta + vencto + bordero + titulo + cpf
         vr_index_vencto:= LPad(vr_tab_saldo(vr_index_saldo).cdagenci,10,'0')||
                           LPad(vr_tab_saldo(vr_index_saldo).nrdconta,10,'0')||
                           To_Char(vr_tab_saldo(vr_index_saldo).dtvencto,'YYYYMMDD')||
                           LPad(vr_tab_saldo(vr_index_saldo).nrborder,10,'0')||
                           LPad(vr_tab_saldo(vr_index_saldo).nrboleto,10,'0')||
                           LPad(vr_tab_saldo(vr_index_saldo).nrinssac,25,'0');
         --Atribuir o valor da tabela saldo para a vencto com novo indice montado
         vr_tab_vencto(vr_index_vencto):= vr_tab_saldo(vr_index_saldo);
         --Encontrar proximo registro vetor
         vr_index_saldo:= vr_tab_saldo.NEXT(vr_index_saldo);
       END LOOP;

       --Executar relatório crrl495
       pc_imprime_crrl495 (pr_des_erro => vr_des_erro);
       --Se retornou erro
       IF vr_des_erro IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_erro;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       --Salvar informacoes no banco de dados
       COMMIT;
     EXCEPTION
      WHEN vr_exc_fim THEN
        -- Se foi retornado apenas código
        IF nvl(vr_cdcritic,0) > 0 AND vr_des_erro IS NULL THEN
          -- Buscar a descrição
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF nvl(vr_cdcritic,0) > 0 OR vr_des_erro IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_des_erro );
        END IF;
        --Zerar tabela de memoria auxiliar
        pc_limpa_tabela;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
          -- Buscar a descrição
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        --Zerar tabela de memoria auxiliar
        pc_limpa_tabela;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_des_erro;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        --Zerar tabela de memoria auxiliar
        pc_limpa_tabela;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
   END pc_crps518;
/
