CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS140(pr_cdcooper  IN NUMBER                --> Código da cooperativa
                                             ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo Agencia 
                                             ,pr_idparale  IN crappar.idparale%TYPE --> Indicador de processoparalelo
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT NUMBER                --> Código crítica
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Descrição crítica
/* ..........................................................................

   Programa: Pc_crps140 (antigo Fontes/crps140.p) 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/95                      Ultima atualizacao: 06/08/2018

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio 117 com os maiores aplicadores.
               Esse relatorio deve rodar sempre depois do mensal
               das aplicacoes e da poupanca programada.

   Alteracoes: 01/12/95 - Acerto no numero de vias (Deborah).

               11/04/96 - Incluir procedimentos poupanca programada (Odair).

               26/11/96 - Tratar RDCAII (Odair).

               26/12/97 - Alterado para calcular RDCA ate o dia do movimento
                          (Deborah).

               27/08/1999 - Tratar circular 2852 (Deborah).

               10/02/2000 - Gerar pedido de impressao (Deborah).

               01/04/2004 - Alteracao no FORMAT do numero sequencial (Julio)

               22/11/2004 - Gerar tambem relatorio com TODOS os aplicadores
                            (rl/crrl117_99.lst) (Evandro).

               06/12/2005 - Gerar relatorio dos 100 maiores aplicadores sem
                            quebras de paginas (crrl117.txt) e com envio
                            de email (Diego).

               03/02/2006 - Modificado nome relatorio(str_4), e alterado
                            para listar TODOS APLICADORES (Diego).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               08/11/2006 - Incluido PAC do associado no relatorio (Elton).

               30/11/2006 - Melhoria de performance (Evandro).

               10/04/2007 - Gerar arquivo com totais das operacoes por CPF
                            (David).

               30/05/2007 - Incluir USE-INDEX para melhorar a performace
                            (Ze/Evandro).

               13/07/2007 - Retirado envio de email. Alterado nome do arquivo
                            que e salvo na pasta 'rl/' crrl117 e sua extensao
                            para .lst (Guilherme).

               23/08/2007 - Incluir valores de aplicacoes RDC (David).

               29/10/2007 - Acerto nos valores de aplicacoes RDC (ZE).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i. (Sidnei - Precise).

               03/04/2008 - Alterado mascara do FORM do relatorio de aplicadores
                            por CPF para mostrar numeros negativos;
                          - Lista somente aplicadores com saldo das aplicacoes
                            maiores do que zero "0" nos relatorios (Elton).

               28/04/2008 - Acertado para que relatorio de aplicadores por CPF
                            gere saldo das aplicacoes do ultimo dia util do mes
                            anterior (Elton).

               01/09/2008 - Alteracao CDEMPRES (Kbase).

               06/01/2010 - Relatorio não irá mais listar os 100 maiores, e sim
                            os cooperados cujo valor das aplicacoes seja maior
                            que o parametrizado na TAB007 (Fernando).

               11/01/2011 - Definido o format "x(40)" nmprimtl (Kbase - Gilnei).

               21/01/2011 - Ajuste no layout de impressao devido a alteracao
                            do format da variavel aux_qtregist (Henrique).

               01/06/2011 - Instanciar a b1wgen0004 ao inicio do programa e
                            deletado ao final para ganho de performance
                            (Adriano).

               09/01/2012 - Melhorar desempenho (Gabriel).

               28/08/2012 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            (Diego).

               01/04/2013 - Conversão Progress >> PLSQL (Petter-Supero)

               25/07/2013 - Ajustes na chamada da fn_mask_cpf_cnpj para passar o
                            inpessoa (Marcos-Supero)

               11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel)

               16/09/2013 - Alterada coluna do FORM f_label de PAC para PA.
                            (Reinert)

               04/10/2013 - Adicionado parametro na chamada da procedure
                            saldo_rdc_pos. (Reinert)

               12/11/2013 - Remoção do parâmetro pr_flgimpri na chamada da
                            solicita_relato pois não havia no fonte original (Marcos-Supero)
                            
               18/12/2013 - Implementação das alterações de novembro (Petter - Supero).
               
               18/02/2014 - Alterado totalizador de PAs de 99 para 999. (Gabriel) 
               
               21/08/2014 - Adicionado tratamento para aplicações dos produtos de 
                            captação (craprac). (Reinert)

               07/12/2015 - Adicionado validacao para limpar o buffer da string de xml
                            quando montar as tags com os totais. (Douglas - Chamado 368794)
              
               15/05/2017 - Projeto Revitalização Sistemas - Andreatta (MOUTs)  
              
               15/07/2018 - Proj. 411.2, desconsiderar as Aplicações Programadas. (Cláudio - CIS Corporate)  

               08/08/2018 - Inclusão da Apl. Programada - Proj. 411.2 - CIS Corporate
              
............................................................................. */
BEGIN

  DECLARE
  
    --- ################################ Variáveis ################################# ----
  
    vr_qtregist            NUMBER;                         --> Quantidade de registros
    vr_vlsldapl            NUMBER(20,8) := 0;              --> Valor da aplicação
    vr_vlsldapl2           NUMBER(20,8) := 0;              --> Valor da aplicação
    vr_vlsldrdc            NUMBER(20,8) := 0;              --> Valor do RDC
    vr_vlsldrda            NUMBER(20,8) := 0;              --> Valor do RDCA
    vr_vlsdpoup            NUMBER(20,8) := 0;              --> Valor poupança
    vr_perirrgt            NUMBER(10,2) := 0;              --> Percentual de IRR
    vr_vlaplrdc            NUMBER(20,8) := 0;              --> Valor de aplicação RDC
    vr_vlslfrda            NUMBER(20,8) := 0;              --> Valor de fração RDA
    vr_vlslfrdc            NUMBER(20,8) := 0;              --> Valor de fração RDC
    vr_vlsfpoup            NUMBER(20,8) := 0;              --> Valor de fração poupança
    vr_cdempres            NUMBER;                         --> Código da empresa
    vr_tot_vlsldapl        NUMBER(20,8) := 0;              --> Valor total de aplicação
    vr_tot_vlsldrdc        NUMBER(20,8) := 0;              --> Valor total de RDC
    vr_tot_vlsdrdca        NUMBER(20,8) := 0;              --> Valor total de RDCA
    vr_tot_vlsdpoup        NUMBER(20,8) := 0;              --> Valor total de poupança
    
    -- Variaveis para o total de todos os aplicadores
    vr_tab_vlsdmadp        NUMBER(20,8);                   --> Valor total de mapeamento
    vr_nrcpfcgc            VARCHAR2(20);                   --> Número de CPF/CNPJ

    vr_dextabi             craptab.dstextab%type;          --> Parametro utilizado no cal. poupança
    vr_dstextab            craptab.dstextab%type;          --> Variabel utilizada para buscar parametro

    -- Variaveis RDCA para BO
    vr_vlrentot            NUMBER(20,8) := 0;              --> Valor de rendimento total
    vr_vldperda            NUMBER(20,8) := 0;              --> Valor da perda
    vr_vlsdrdca            NUMBER(20,8) := 0;              --> Valor saldo do RDCA
    vr_txaplica            NUMBER(20,8) := 0;              --> Taxa de aplicação
    vr_nrcopias            NUMBER;                         --> Número de cópias do relatório
    vr_nmformul            VARCHAR2(400);                  --> Nome do formulário
    vr_cdprogra            VARCHAR2(10);                   --> Nome do programa
    rw_crapdat             btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor genérico
    vr_clob1               CLOB;                           --> Variável para armazenar dadso do XML dos maiores aplicadores
    vr_char1               VARCHAR2(32767);                --> Variavel temporaria para dados do XML dos maiores aplicados
    vr_clob5               CLOB;                           --> Variável para armazenar dados do XML de relatório de CPF
    vr_char5               VARCHAR2(32767);                --> Variavel temporaria para dados do XML de relatório de CPF
    vr_nom_dir             VARCHAR2(400);                  --> Variável para armazenar o path do arquivo
    vr_proximo             EXCEPTION;                      --> Variável para controle de fluxo na iteração
    vr_rd2_vlsdrdca        NUMBER(20,8) := 0;              --> Valor de cálculo do RDCA
    vr_vlrdirrf            NUMBER(20,8) := 0;              --> Cálculo do valor de IRRF
    vr_dtinitax            DATE;                           --> Data início da taxa de poupança
    vr_dtfimtax            DATE;                           --> Data final da taxa de poupança
    vr_idxpl               VARCHAR2(50);                   --> Índice de PL Table
    vr_icxauto             NUMBER;                         --> Auto incremento para contador de índice
    vr_idxindc             VARCHAR2(20);                   --> Variável para armazenar índice de PL Table
    vr_iterar              EXCEPTION;                      --> Variável para controle de fluxo na iteração
    vr_rpp_vlsdrdpp        NUMBER(20,8) := 0;              --> Valor de poupança acumulado
    vr_idxcrapasss         VARCHAR2(15);                   --> Variável para armazenar índice de PL Table
    vr_pula                EXCEPTION;                      --> Variável para controlar iteração de LOOP
    vr_idxrda              VARCHAR2(25);                   --> Indexador da PL Table para dados de curosr
    vr_agendamento         VARCHAR2(1) := 'N';             --> Variável de controle para definir agendamento de relatório
    vr_nomarq              VARCHAR2(50) := '/crrl117';     --> Nome raiz do arquivo
    vr_sldpresg_tmp        craplap.vllanmto%TYPE;          --> Valor saldo de resgate
    vr_dup_vlsdrdca        craplap.vllanmto%TYPE;          --> Acumulo do saldo da aplicacao RDCA
    vr_indxpl              VARCHAR2(100);          --> Variável para armazenar índice da PL Table
    
    -- Variaveis usadas no retorno da procedure pc_posicao_saldo_aplicacao_pre/pos
    vr_vlsldtot NUMBER;      --> Saldo Total da Aplicação
    vr_vlultren NUMBER;      --> Valor Último Rendimento
    vr_vlsldrgt NUMBER;      --> Saldo Total para Resgate
    vr_vlrevers NUMBER;      --> Valor de Reversão
    vr_percirrf NUMBER;      --> Percentual do IRRF
    vr_vlbascal NUMBER := 0; --> Valor Base Cálculo

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    
    
    -- ID para o paralelismo
    vr_idparale      integer;
    -- Qtde parametrizada de Jobs
    vr_qtdjobs       number;
    -- Job name dos processos criados
    vr_jobname       varchar2(30);
    -- Bloco PLSQL para chamar a execução paralela do pc_crps750
    vr_dsplsql       varchar2(4000);
    
    -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;
    vr_idlog_ini_par tbgen_prglog.idprglog%type;
    vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
    vr_qterro        number := 0; 
    
    
    --- ################################ Tipos e Registros de memória ################################# ----
        
    --  
    TYPE typ_reg_vlsldtot IS RECORD (vlsldtot NUMBER);
    TYPE typ_tab_vlsldtot IS TABLE OF typ_reg_vlsldtot INDEX BY VARCHAR2(25);
    vr_tab_vlsldtot typ_tab_vlsldtot;
    
    -- PL Table para armazenar dados de cadastro de aplicações RDCA
    TYPE typ_reg_craprda IS
      RECORD(tpaplica  craprda.tpaplica%TYPE
            ,vlslfmes  craprda.vlslfmes%TYPE
            ,cdageass  craprda.cdageass%TYPE
            ,nrdconta  craprda.nrdconta%TYPE
            ,nraplica  craprda.nraplica%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craprda IS TABLE OF typ_reg_craprda INDEX BY VARCHAR2(25);
    vr_tab_craprda typ_tab_craprda;
    
    -- PL Table para armazenar dados de aplicações pessoa jurídica
    TYPE typ_reg_crapjur IS
      RECORD(cdempres  crapjur.cdempres%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY VARCHAR2(10);
    vr_tab_crapjur typ_tab_crapjur;

    -- PL Table para armazenar dados de aplicações pessoa física
    TYPE typ_reg_crapttl IS
      RECORD(cdempres  crapttl.cdempres%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY VARCHAR2(10);
    vr_tab_crapttl typ_tab_crapttl;

    -- PL Table para armazenar dados da iteração de arquivo temporário (.TMP)
    TYPE typ_reg_temp IS
      RECORD(nrdconta     crapass.nrdconta%TYPE
            ,cdagenci     crapass.cdagenci%TYPE
            ,inpessoa     crapass.inpessoa%TYPE
            ,nrcpfcgc     crapass.nrcpfcgc%TYPE
            ,nrmatric     crapass.nrmatric%TYPE
            ,nmprimtl     crapass.nmprimtl%TYPE
            ,vr_vlsldapl1 NUMBER(20,8)
            ,vr_vlsldrdc  NUMBER(20,8)
            ,vr_vlsldrda  NUMBER(20,8)
            ,vr_vlsdpoup  NUMBER(20,8)
            ,vr_vlsldapl2 NUMBER(20,8)
            ,vr_vlslfrdc  NUMBER(20,8)
            ,vr_vlslfrda  NUMBER(20,8)
            ,vr_vlsfpoup  NUMBER(20,8));

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_temp IS TABLE OF typ_reg_temp INDEX BY VARCHAR2(50);
    vr_tab_temp typ_tab_temp;

    -- PL Table para armazenar dados de poupança programada
    TYPE typ_reg_craprpp IS
      RECORD(nrdconta  craprpp.nrdconta%TYPE
            ,cdsitrpp  craprpp.cdsitrpp%TYPE
            ,cdprodut  craprpp.cdprodut%TYPE
            ,vlslfmes  craprpp.vlslfmes%TYPE
            ,rowid     VARCHAR2(50));

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craprpp IS TABLE OF typ_reg_craprpp INDEX BY VARCHAR2(20);
    vr_tab_craprpp typ_tab_craprpp;

    -- Instancia TEMP TABLE referente a tabela CRAPERR
    vr_tab_craterr GENE0001.typ_tab_erro;

    -- Pl Table para armazenar dados de tipos de aplicação
    TYPE typ_reg_crapdtc IS
      RECORD(tpaplica  crapdtc.tpaplica%TYPE
            ,tpaplrdc  crapdtc.tpaplrdc%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapdtc IS TABLE OF typ_reg_crapdtc INDEX BY PLS_INTEGER;
    vr_tab_crapdtc typ_tab_crapdtc;

    -- PL Table para gravar aplicadores
    TYPE typ_reg_aplicadores IS
      RECORD(nmprimtl  crapass.nmprimtl%TYPE
            ,nrcpfcgc  VARCHAR2(20)
            ,vlslfapl  NUMBER
            ,vlslfrda  NUMBER
            ,vlslfrdc  NUMBER
            ,vlsfpoup  NUMBER);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_aplicadores IS TABLE OF typ_reg_aplicadores INDEX BY VARCHAR2(30);
    vr_tab_aplicadores typ_tab_aplicadores;

    -- PL Table para gravar aplicadores com nova ordenação
    TYPE typ_reg_oaplicadores IS
      RECORD(nmprimtl  crapass.nmprimtl%TYPE
            ,nrcpfcgc  VARCHAR2(20)
            ,vlslfapl  NUMBER
            ,vlslfrda  NUMBER
            ,vlslfrdc  NUMBER
            ,vlsfpoup  NUMBER);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_oaplicadores IS TABLE OF typ_reg_oaplicadores INDEX BY VARCHAR2(95);
    vr_tab_oaplicadores typ_tab_oaplicadores;

    
    
    --- #################################### CURSORES ############################################## ----
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Lista das agências da Cooperativa
    CURSOR cr_crapage(pr_cdcooper in craprpp.cdcooper%type
                     ,pr_cdprogra in tbgen_batch_controle.cdprogra%type
                     ,pr_qterro   in number
                     ,pr_dtmvtolt in tbgen_batch_controle.dtmvtolt%type) IS
      select distinct crapass.cdagenci
        from crapass
       where crapass.cdcooper  = pr_cdcooper
         and crapass.dtelimin  IS NULL
         and crapass.inpessoa <> 3
         and (pr_qterro = 0 or
             (pr_qterro > 0 and exists (select 1
                                          from tbgen_batch_controle
                                         where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                           and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                           and tbgen_batch_controle.tpagrupador = 1
                                           and tbgen_batch_controle.cdagrupador = crapass.cdagenci
                                           and tbgen_batch_controle.insituacao  = 1
                                           and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))       
      order by crapass.cdagenci;       
    
    -- Buscar dados dos tipos de aplicação cadastradas
    CURSOR cr_crapdtc(pr_cdcooper IN craptab.cdcooper%TYPE) IS      --> Código da cooperativa
      SELECT ct.tpaplica
            ,ct.tpaplrdc
        FROM crapdtc ct
       WHERE ct.cdcooper = pr_cdcooper;

    -- Buscar dados do cadastro de poupança programada
    CURSOR cr_craprpp(pr_cdcooper IN craptab.cdcooper%TYPE    --> Código da cooperativa
                     ,pr_cdagenci in crapass.cdagenci%TYPE) IS --> Conta do Associado
      SELECT cp.nrdconta
            ,ass.cdagenci
            ,cp.cdsitrpp
            ,cp.vlslfmes
            ,cp.nrctrrpp
            ,cp.cdprodut
            ,cp.rowid
        FROM craprpp cp
            ,crapass ass    
       WHERE cp.cdcooper = ass.cdcooper 
         AND cp.nrdconta = ass.nrdconta
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
         AND cp.cdcooper = pr_cdcooper
       ORDER BY cp.nrdconta;
    
    -- Buscar dados do cadastro das aplicações RDCA
    CURSOR cr_craprda(pr_cdcooper IN craptab.cdcooper%TYPE     --> Código da cooperativa
                     ,pr_cdagenci in crapass.cdagenci%TYPE) IS --> Código da agencia
      SELECT cd.tpaplica
            ,cd.vlslfmes
            ,cd.cdageass
            ,cd.nrdconta
            ,cd.nraplica
            ,ass.cdagenci
        FROM craprda cd
            ,crapass ass
       WHERE cd.cdcooper = ass.cdcooper 
         AND cd.nrdconta = ass.nrdconta
         AND cd.cdcooper = pr_cdcooper
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
         AND cd.insaqtot = 0
       ORDER BY cd.nrdconta, cd.nraplica;
       
    -- Buscar as aplicações de captação
    CURSOR cr_craprac(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Código da cooperativa
                     ,pr_cdagenci in crapass.cdagenci%TYPE) IS --> Código da agencia
      SELECT rac.cdprodut
            ,rac.nrdconta
            ,rac.nraplica
            ,rac.txaplica
            ,rac.dtmvtolt
            ,rac.qtdiacar
            ,rac.vlslfmes
            ,cpc.idtippro
            ,cpc.cddindex
            ,cpc.idtxfixa
            ,ass.cdagenci
        FROM craprac rac
            ,crapcpc cpc
            ,crapass ass
       WHERE rac.cdprodut = cpc.cdprodut
         AND rac.cdcooper = ass.cdcooper 
         AND rac.nrdconta = ass.nrdconta
         AND rac.cdcooper = pr_cdcooper
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
         AND rac.nrctrrpp = 0          -- Apenas produtos não aplicação programada
         AND rac.idsaqtot = 0
       ORDER BY rac.nrdconta, rac.nraplica;
       
    -- Busca de dados dos associados
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE     --> Código da cooperativa
                     ,pr_cdagenci in crapass.cdagenci%TYPE) IS --> Código da agencia
      SELECT cs.cdagenci
            ,cs.nrdconta
            ,cs.inpessoa
            ,cs.nrcpfcgc
            ,cs.nrmatric
            ,cs.nmprimtl
        FROM crapass cs
       WHERE cs.cdcooper = pr_cdcooper
         AND cs.cdagenci = decode(pr_cdagenci,0,cs.cdagenci,pr_cdagenci)
         AND cs.dtelimin IS NULL
         AND cs.inpessoa <> 3
       ORDER BY cs.nrdconta;

    -- Buscar dados de aplicações pessoa física
    CURSOR cr_crapttl(pr_cdcooper IN craptab.cdcooper%TYPE --> Código da cooperativa
                     ,pr_cdagenci IN crapass.cdagenci%TYPE) IS --> Código da agencia
      SELECT cl.nrdconta
            ,cl.cdempres
        FROM crapttl cl
            ,crapass ass
       WHERE cl.cdcooper = ass.cdcooper
         AND cl.nrdconta = ass.nrdconta
         AND cl.cdcooper = pr_cdcooper
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
         AND cl.idseqttl = 1;

    -- Buscar dados de aplicações pessoa jurídica
    CURSOR cr_crapjur(pr_cdcooper IN craptab.cdcooper%TYPE --> Código da cooperativa
                     ,pr_cdagenci IN crapass.cdagenci%TYPE) IS --> Código da agencia
      SELECT cj.nrdconta
            ,cj.cdempres
        FROM crapjur cj
            ,crapass ass
       WHERE cj.cdcooper = ass.cdcooper
         AND cj.nrdconta = ass.nrdconta
         AND cj.cdcooper = pr_cdcooper
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci);
    
    -- Dados das tabela de trabalho
    cursor cr_relwork(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                     ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                     ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                     ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT nrdconta
            ,cdagenci
            ,gene0002.fn_busca_entrada(1,dscritic,';') inpessoa
            ,gene0002.fn_busca_entrada(2,dscritic,';') nrcpfcgc
            ,gene0002.fn_busca_entrada(3,dscritic,';') nrmatric
            ,gene0002.fn_busca_entrada(4,dscritic,';') nmprimtl
            ,gene0002.fn_busca_entrada(5,dscritic,';') vlsldapl
            ,gene0002.fn_busca_entrada(6,dscritic,';') vlsldrdc
            ,gene0002.fn_busca_entrada(7,dscritic,';') vlsldrda
            ,gene0002.fn_busca_entrada(8,dscritic,';') vlsdpoup
            ,gene0002.fn_busca_entrada(9,dscritic,';') vlsldapl2
            ,gene0002.fn_busca_entrada(10,dscritic,';') vlslfrdc
            ,gene0002.fn_busca_entrada(11,dscritic,';') vlslfrda
            ,gene0002.fn_busca_entrada(12,dscritic,';') vlsfpoup
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt 
       ORDER BY nrdconta,dschave;    
    
    --- ################################ SubRotinas ################################# ----
    
    -- Procedure para criar dados de aplicadores
    PROCEDURE pc_cria_aplicadores(pr_nrcpfcgc  IN VARCHAR2                   --> CPF/CNPJ
                                 ,pr_inpessoa  IN NUMBER                     --> Tipo pessoa
                                 ,pr_vlsldapl2 IN NUMBER                     --> Valor total de aplicação de aplicadores
                                 ,pr_vlslfrdc  IN NUMBER                     --> Valor de fração RDC
                                 ,pr_vlslfrda  IN NUMBER                     --> Valor de fração RDA
                                 ,pr_vlsfpoup  IN NUMBER                     --> Valor de fração poupança
                                 ,pr_nmprimtl  IN crapass.nmprimtl%TYPE      --> Nome impressão
                                 ,pr_des_erro  OUT VARCHAR2) AS              --> Variável para captura de erros
    BEGIN
      BEGIN
        -- Verifica se já existe registro na PL Table para o indice pesquisado para efetuar update/insert
        IF vr_tab_aplicadores.exists(lpad(pr_nrcpfcgc, 20, '0')) THEN
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfapl := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfapl + pr_vlsldapl2;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrdc := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrdc + pr_vlslfrdc;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrda := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrda + pr_vlslfrda;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlsfpoup := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlsfpoup + pr_vlsfpoup;
        ELSE
          -- Aplicar máscara CPF/CNPJ
          vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc,pr_inpessoa);

          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).nrcpfcgc := vr_nrcpfcgc;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).nmprimtl := pr_nmprimtl;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfapl := pr_vlsldapl2;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrdc := pr_vlslfrdc;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrda := pr_vlslfrda;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlsfpoup := pr_vlsfpoup;
        END IF;
      EXCEPTION
        WHEN others THEN
          pr_des_erro := 'Erro em pc_cria_aplicadores: ' || SQLERRM;
      END;
    END pc_cria_aplicadores;

    -- Procedure para reordenar e criar novo indexador para PL Table
    PROCEDURE pc_order_table (pr_des_erro  OUT VARCHAR2) AS      --> Variável para captura de erros
    BEGIN
      DECLARE
        vr_index    VARCHAR2(20);       --> Indice para PL Table que será reordenada
        vr_oindex   VARCHAR2(105);      --> Indice para a nova PL Table
        vr_count    NUMBER := 0;        --> Variável para incrementar o indexador

      BEGIN
        vr_index := vr_tab_aplicadores.first;

        -- Iteração desde o primeiro registro para reordenar com novo índice
        LOOP
          EXIT WHEN vr_index IS NULL;

          -- Criar novo indice para reordenamento
          vr_count := vr_count + 1;
          vr_oindex := lpad((vr_tab_aplicadores(vr_index).vlslfapl * 100), 35, '0') ||
                       lpad( vr_index , 20, '0');

          -- Cria registros na nova PL Table
          vr_tab_oaplicadores(vr_oindex).nrcpfcgc := vr_tab_aplicadores(vr_index).nrcpfcgc;
          vr_tab_oaplicadores(vr_oindex).nmprimtl := vr_tab_aplicadores(vr_index).nmprimtl;
          vr_tab_oaplicadores(vr_oindex).vlslfapl := vr_tab_aplicadores(vr_index).vlslfapl;
          vr_tab_oaplicadores(vr_oindex).vlslfrdc := vr_tab_aplicadores(vr_index).vlslfrdc;
          vr_tab_oaplicadores(vr_oindex).vlslfrda := vr_tab_aplicadores(vr_index).vlslfrda;
          vr_tab_oaplicadores(vr_oindex).vlsfpoup := vr_tab_aplicadores(vr_index).vlsfpoup;

          -- Busca o próximo índice
          vr_index := vr_tab_aplicadores.next(vr_index);
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro em pc_order_table: ' || SQLERRM;
      END;
    END pc_order_table;

    -- Procedure para inserir registros na Pl Table de registros temporários
    PROCEDURE pc_insere_temp(pr_tpinsert  number                 --> 2 - para PLTABLE e 1 - para Tabela Banco
                            ,pr_nrdconta  crapass.nrdconta%TYPE  --> Número da conta
                            ,pr_cdagenci  crapass.cdagenci%TYPE  --> Código da Agência
                            ,pr_inpessoa  crapass.inpessoa%TYPE  --> Tipo pessoa
                            ,pr_nrcpfcgc  crapass.nrcpfcgc%TYPE  --> CPF/CNPJ
                            ,pr_nrmatric  crapass.nrmatric%TYPE  --> Matricula
                            ,pr_nmprimtl  crapass.nmprimtl%TYPE  --> Nome
                            ,pr_vlsldapl1 IN NUMBER              --> Saldo da aplicação
                            ,pr_vlsldrdc  IN NUMBER              --> Saldo do RDC
                            ,pr_vlsldrda  IN NUMBER              --> Saldo do RDA
                            ,pr_vlsdpoup  IN NUMBER              --> Saldo poupança
                            ,pr_vlsldapl2 IN NUMBER              --> Saldo da aplicação
                            ,pr_vlslfrdc  IN NUMBER              --> Saldo da fração do RDC
                            ,pr_vlslfrda  IN NUMBER              --> Saldo da fração do RDA
                            ,pr_vlsfpoup  IN NUMBER              --> Saldo da fração da poupança
                            ,pr_des_erro  OUT VARCHAR2) AS       --> Mensagem de erro
    BEGIN
      DECLARE
        vr_index     VARCHAR2(50);
        vr_valor     NUMBER(20,2);

      BEGIN
        -- Cálculo do índice da PL Table
        IF pr_vlsldapl1 < 0 THEN
          vr_valor := pr_vlsldapl1 * -100;
        ELSE
          vr_valor := pr_vlsldapl1 * 100;
        END IF;

        vr_index := lpad(vr_valor, 35, '0') || lpad(999999999999999-pr_nrdconta , 15, '0');
        
        -- Caso pltable 
        IF pr_tpinsert = 2 THEN 
          vr_tab_temp(vr_index).nrdconta     := pr_nrdconta;
          vr_tab_temp(vr_index).cdagenci     := pr_cdagenci;
          vr_tab_temp(vr_index).inpessoa     := pr_inpessoa;
          vr_tab_temp(vr_index).nrcpfcgc     := pr_nrcpfcgc;
          vr_tab_temp(vr_index).nrmatric     := pr_nrmatric;
          vr_tab_temp(vr_index).nmprimtl     := pr_nmprimtl;
          vr_tab_temp(vr_index).vr_vlsldapl1 := pr_vlsldapl1;
          vr_tab_temp(vr_index).vr_vlsldrdc  := nvl(pr_vlsldrdc, 0);
          vr_tab_temp(vr_index).vr_vlsldrda  := pr_vlsldrda;
          vr_tab_temp(vr_index).vr_vlsdpoup  := pr_vlsdpoup;
          vr_tab_temp(vr_index).vr_vlsldapl2 := pr_vlsldapl2;
          vr_tab_temp(vr_index).vr_vlslfrdc  := pr_vlslfrdc;
          vr_tab_temp(vr_index).vr_vlslfrda  := pr_vlslfrda;
          vr_tab_temp(vr_index).vr_vlsfpoup  := pr_vlsfpoup;
        else
          insert into tbgen_batch_relatorio_wrk
                     (cdcooper
                     ,cdprograma
                     ,dsrelatorio
                     ,dtmvtolt
                     ,cdagenci
                     ,nrdconta
                     ,dschave
                     ,dscritic)
               values(pr_cdcooper
                     ,vr_cdprogra
                     ,'crrl117'
                     ,rw_crapdat.dtmvtolt
                     ,pr_cdagenci
                     ,pr_nrdconta
                     ,vr_index
                     -- Aproveitar dscritic para montar um registro genérico com o restante das informações
                     ,pr_inpessoa||';'||
                     pr_nrcpfcgc||';'||
                     pr_nrmatric||';'||
                     pr_nmprimtl||';'||
                     to_char(pr_vlsldapl1,'fm999g999g999g990d00')||';'||
                     to_char(nvl(pr_vlsldrdc, 0),'fm999g999g999g990d00')||';'||
                     to_char(pr_vlsldrda,'fm999g999g999g990d00')||';'||
                     to_char(pr_vlsdpoup,'fm999g999g999g990d00')||';'||
                     to_char(pr_vlsldapl2,'fm999g999g999g990d00')||';'||
                     to_char(pr_vlslfrdc,'fm999g999g999g990d00')||';'||
                     to_char(pr_vlslfrda,'fm999g999g999g990d00')||';'||
                     to_char(pr_vlsfpoup,'fm999g999g999g990d00')||';');
        end if;
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao executar pc_insere_temp: ' || SQLERRM;
      END;
    END pc_insere_temp;
    
  BEGIN
    
    --- ################################ Programa Principal ################################# ----
  
    EXECUTE IMMEDIATE 'Alter session set session_cached_cursors=200';

    -- Atribuição de valores iniciais da procedure
    vr_nrcopias := 2;
    vr_nmformul := '';
    vr_cdprogra := 'CRPS140';
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);
    
    -- Na execução principal
    if nvl(pr_idparale,0) = 0 then
      -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      vr_idlog_ini_ger := null;
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);
    end if;    

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar registros montar mensagem de critica
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      pr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
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

    -- Data de fim e inicio da utilização da taxa de poupança.
    -- Utiliza-se essa data quando o rendimento da aplicação for menor que
    -- a poupança, a cooperativa opta por usar ou não.
    -- Buscar a descrição das faixas contido na craptab    
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'MXRENDIPOS'
                                             ,pr_tpregist => 1);
    
    -- Se não encontrar registros
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dtinitax := to_date('01/01/9999', 'dd/mm/yyyy');
      vr_dtfimtax := to_date('01/01/9999', 'dd/mm/yyyy');
    ELSE
      vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1, vr_dstextab, ';'), 'DD/MM/YYYY');
      vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2, vr_dstextab, ';'), 'DD/MM/YYYY');
    END IF;

    -- Buscar informacoes para calculo de poupanca
    vr_dextabi := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'CONFIG'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'PERCIRAPLI'
                                             ,pr_tpregist => 0);

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Buscar dados das taxas
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'MAIORESDEP'
                                             ,pr_tpregist => 1);
    -- Se não encontrar 
    IF TRIM(vr_dstextab) IS NULL THEN 
      vr_tab_vlsdmadp := 10000;
    ELSE
      vr_tab_vlsdmadp := substr(vr_dstextab, 49, 15);
      IF vr_tab_vlsdmadp = 0 THEN
        vr_tab_vlsdmadp := 0.01;
      END IF;
    END IF;
      
    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --> Código da coopertiva
                                                 ,vr_cdprogra --> Código do programa
                                                 );
    
    /* Paralelismo visando performance Rodar Somente no processo Noturno */
    if rw_crapdat.inproces > 2 and vr_qtdjobs > 0 and pr_cdagenci  = 0 then  
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_ID_paralelo;
      
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
         -- Levantar exceção
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
         RAISE vr_exc_saida;
      END IF;
                                            
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                   ,pr_cdprogra    => vr_cdprogra
                                                   ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                   ,pr_tpagrupador => 1
                                                   ,pr_nrexecucao  => 1);     
                                            
      -- Retorna todas as agências da Cooperativa 
      for rw_crapage in cr_crapage (pr_cdcooper
                                   ,vr_cdprogra
                                   ,vr_qterro
                                   ,rw_crapdat.dtmvtolt) loop
                                            
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := vr_cdprogra ||'_'|| rw_crapage.cdagenci || '$';  
      
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => vr_dscritic);
                                  
        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;     
        
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'DECLARE' || chr(13) 
                   || '  wpr_stprogra NUMBER;' || chr(13) 
                   || '  wpr_infimsol NUMBER;' || chr(13) 
                   || '  wpr_cdcritic NUMBER;' || chr(13) 
                   || '  wpr_dscritic VARCHAR2(1500);' || chr(13) 
                   || 'BEGIN' || chr(13) 
                   || '  PC_CRPS140('|| pr_cdcooper 
                   || '            ,'|| rw_crapage.cdagenci 
                   || '            ,'|| vr_idparale 
                   || '            ,wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' 
                   || chr(13) 
                   || 'END;'; --  
         
         -- Faz a chamada ao programa paralelo atraves de JOB
         gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                               ,pr_cdprogra => vr_cdprogra  --> Código do programa
                               ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                               ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                               ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                               ,pr_jobname  => vr_jobname   --> Nome randomico criado
                               ,pr_des_erro => vr_dscritic);    
                               
         -- Testar saida com erro
         if vr_dscritic is not null then 
           -- Levantar exceçao
           raise vr_exc_saida;
         end if;

         -- Chama rotina que irá pausar este processo controlador
         -- caso tenhamos excedido a quantidade de JOBS em execuçao
         gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                     ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                     ,pr_des_erro => vr_dscritic);

         -- Testar saida com erro
         if  vr_dscritic is not null then 
           -- Levantar exceçao
           raise vr_exc_saida;
         end if;
         
      end loop;
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic);
                                  
      -- Testar saida com erro
      if  vr_dscritic is not null then 
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;    

      -- Verifica se algum job executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                   ,pr_cdprogra    => vr_cdprogra
                                                   ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                   ,pr_tpagrupador => 1
                                                   ,pr_nrexecucao  => 1);
      if vr_qterro > 0 then 
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        raise vr_exc_saida;
      end if;    
    else
      
      if pr_cdagenci <> 0 then
        vr_tpexecucao := 2;
      else
        vr_tpexecucao := 1;
      end if;    
      
      -- Grava controle de batch por agência
      gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                      ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                      ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                      ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                      ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                      ,pr_dscritic    => vr_dscritic);   
      -- Testar saida com erro
      if vr_dscritic is not null then 
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;    
      
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I'  
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci          
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => vr_tpexecucao    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par);      

      -- Carregar tipos de aplicação
      FOR vr_crapdtc IN cr_crapdtc(pr_cdcooper) LOOP
        vr_tab_crapdtc(vr_crapdtc.tpaplica).tpaplica := vr_crapdtc.tpaplica;
        vr_tab_crapdtc(vr_crapdtc.tpaplica).tpaplrdc := vr_crapdtc.tpaplrdc;
      END LOOP;

      -- Carregar Poupança Programada
      vr_icxauto := 0;
      FOR vr_craprpp IN cr_craprpp(pr_cdcooper,pr_cdagenci) LOOP
        vr_icxauto := vr_icxauto + 1;

        -- Criar registro de marcação de conta
        IF vr_icxauto = 1 THEN
          vr_tab_craprpp(lpad(vr_craprpp.nrdconta, 10, '0') || '0000000000').nrdconta := 99999;
        ELSE
          IF vr_craprpp.nrdconta <> vr_tab_craprpp(vr_idxindc).nrdconta THEN
            vr_tab_craprpp(lpad(vr_craprpp.nrdconta, 10, '0') || '0000000000').nrdconta := 99999;
          END IF;
        END IF;
        IF vr_craprpp.cdprodut > 0 THEN -- Nova aplicao
            vr_vlsldtot := 0;          
            apli0008.pc_calc_saldo_apl_prog (pr_cdcooper => pr_cdcooper
                                    ,pr_cdprogra => vr_cdprogra
                                    ,pr_cdoperad => '1'
                                    ,pr_nrdconta => vr_craprpp.nrdconta
                                    ,pr_idseqttl => 1
                                    ,pr_idorigem => 5
                                    ,pr_nrctrrpp => vr_craprpp.nrctrrpp
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_vlsdrdpp => vr_vlsldtot
                                    ,pr_des_erro => vr_dscritic);
            -- Se procedure retornou erro                                        
            IF vr_dscritic is not null THEN
              RAISE vr_exc_saida;
            END IF;
        ELSE
          vr_vlsldtot := vr_craprpp.vlslfmes;
        END IF;

        -- Criar índice
        vr_idxindc := lpad(vr_craprpp.nrdconta, 10, '0') || lpad(vr_icxauto, 10, '0');

        vr_tab_craprpp(vr_idxindc).nrdconta := vr_craprpp.nrdconta;
        vr_tab_craprpp(vr_idxindc).cdsitrpp := vr_craprpp.cdsitrpp;
        vr_tab_craprpp(vr_idxindc).vlslfmes := vr_vlsldtot;
        vr_tab_craprpp(vr_idxindc).cdprodut := vr_craprpp.cdprodut;
        vr_tab_craprpp(vr_idxindc).rowid := vr_craprpp.rowid;
      END LOOP;

      -- Carregar Aplicações (RDA)
      vr_icxauto := 0;
      FOR vr_craprda IN cr_craprda(pr_cdcooper,pr_cdagenci) LOOP
        vr_icxauto := vr_icxauto + 1;

        -- Criar registro de marcação de conta
        IF vr_icxauto = 1 THEN
          vr_tab_craprda(lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') || '0000000000').nrdconta := 99999;
        ELSE
          IF lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') <>
             lpad(vr_tab_craprda(vr_idxrda).nrdconta, 10, '0') || lpad(vr_tab_craprda(vr_idxrda).cdageass, 5, '0') THEN
            vr_tab_craprda(lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') || '0000000000').nrdconta := 99999;
          END IF;
        END IF;

        -- Criar índice
        vr_idxrda := lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') || lpad(vr_icxauto, 10, '0');

        vr_tab_craprda(vr_idxrda).nrdconta := vr_craprda.nrdconta;
        vr_tab_craprda(vr_idxrda).tpaplica := vr_craprda.tpaplica;
        vr_tab_craprda(vr_idxrda).vlslfmes := vr_craprda.vlslfmes;
        vr_tab_craprda(vr_idxrda).cdageass := vr_craprda.cdageass;
        vr_tab_craprda(vr_idxrda).nraplica := vr_craprda.nraplica;
      END LOOP;
      
      -- Carregar produtos de Captação
      FOR rw_craprac IN cr_craprac(pr_cdcooper,pr_cdagenci) LOOP
          
        IF rw_craprac.idtippro = 1 THEN -- Pré-fixada
          -- Calculo para obter saldo atualizado de aplicacao pre
          APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                                 ,pr_nrdconta => rw_craprac.nrdconta   --> Número da Conta
                                                 ,pr_nraplica => rw_craprac.nraplica   --> Número da Aplicação
                                                 ,pr_dtiniapl => rw_craprac.dtmvtolt   --> Data de Início da Aplicação
                                                 ,pr_txaplica => rw_craprac.txaplica   --> Taxa da Aplicação
                                                 ,pr_idtxfixa => rw_craprac.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
                                                 ,pr_cddindex => rw_craprac.cddindex   --> Código do Indexador
                                                 ,pr_qtdiacar => rw_craprac.qtdiacar   --> Dias de Carência
                                                 ,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                 ,pr_dtinical => rw_craprac.dtmvtolt   --> Data Inicial Cálculo
                                                 ,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
                                                 ,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                 ,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                 ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
                                                 ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
                                                 ,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
                                                 ,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
                                                 ,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
                                                 ,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
                                                 ,pr_percirrf => vr_percirrf           --> Percentual do IRRF
                                                 ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                                 ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
                                                                                                         
          -- Se procedure retornou erro                                        
          IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pre -> ' || vr_dscritic;
            -- Levanta exceção
            RAISE vr_exc_saida;
          END IF;
          
        ELSIF rw_craprac.idtippro = 2 THEN -- Pós-fixada
             
          APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                                ,pr_nrdconta => rw_craprac.nrdconta   --> Número da Conta
                                                ,pr_nraplica => rw_craprac.nraplica   --> Número da Aplicação
                                                ,pr_dtiniapl => rw_craprac.dtmvtolt   --> Data de Início da Aplicação
                                                ,pr_txaplica => rw_craprac.txaplica   --> Taxa da Aplicação
                                                ,pr_idtxfixa => rw_craprac.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
                                                ,pr_cddindex => rw_craprac.cddindex   --> Código do Indexador
                                                ,pr_qtdiacar => rw_craprac.qtdiacar   --> Dias de Carência
                                                ,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                ,pr_idaplpgm => 0                   --> Aplicação Programada  (0-Não/1-Sim)
                                                ,pr_dtinical => rw_craprac.dtmvtolt   --> Data Inicial Cálculo
                                                ,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
                                                ,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                ,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
                                                ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
                                                ,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
                                                ,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
                                                ,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
                                                ,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
                                                ,pr_percirrf => vr_percirrf           --> Percentual do IRRF
                                                ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                                ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
                                                      
          -- Se procedure retornou erro                                        
          IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pos ' 
                        || ' Conta '||rw_craprac.nrdconta||' Aplica '||rw_craprac.nraplica||'-> ' || vr_dscritic;
            -- Levanta exceção
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
        -- As aplicações de Captação serão armazenadas na mesma PLTable de Aplicações RDA
        IF vr_tab_craprda.exists(lpad(rw_craprac.nrdconta, 10, '0') || lpad(rw_craprac.cdagenci, 5, '0') || '0000000000') THEN
          vr_idxrda := vr_tab_craprda.next(lpad(rw_craprac.nrdconta, 10, '0') || lpad(rw_craprac.cdagenci, 5, '0') || '0000000000');
        ELSE
          vr_tab_craprda(lpad(rw_craprac.nrdconta, 10, '0') || lpad(rw_craprac.cdagenci, 5, '0') || '0000000000').nrdconta := 99999;
          vr_icxauto := 1;
          vr_idxrda:= NULL;
        END IF;            
        
        LOOP
          BEGIN
            EXIT WHEN vr_idxrda IS NULL;
        
            -- Controle para definir se o LOOP irá continuar a iteração (atribui NULL caso não continue)
            -- Verifica se o próximo registro é null (chegamos ao final da PL Table)
            IF vr_tab_craprda.next(vr_idxrda) IS NULL THEN
              vr_icxauto := TO_NUMBER(SUBSTR(vr_idxrda, -10, 10)) + 1;
              vr_idxrda := NULL;            
            ELSE
              -- Verifica se já existe proxima conta
              IF lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).nrdconta, 10, '0') ||
                 lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).cdageass, 5, '0') <>
                 lpad(rw_craprac.nrdconta, 10, '0') || lpad(rw_craprac.cdagenci, 5, '0') THEN
                vr_icxauto := TO_NUMBER(SUBSTR(vr_idxrda, -10, 10)) + 1;
                vr_idxrda := NULL;
              ELSE
                vr_idxrda := vr_tab_craprda.next(vr_idxrda);
              END IF;
            END IF;          
          END;
        END LOOP;
        
        -- Criar índice
        vr_idxrda := lpad(rw_craprac.nrdconta, 10, '0') || lpad(rw_craprac.cdagenci, 5, '0') || lpad(vr_icxauto, 10, '0');

        vr_tab_craprda(vr_idxrda).nrdconta := rw_craprac.nrdconta;
        vr_tab_craprda(vr_idxrda).tpaplica := rw_craprac.idtippro;
        vr_tab_craprda(vr_idxrda).vlslfmes := rw_craprac.vlslfmes;
        vr_tab_craprda(vr_idxrda).cdageass := rw_craprac.cdagenci;
        vr_tab_craprda(vr_idxrda).nraplica := rw_craprac.nraplica;
        vr_tab_vlsldtot(vr_idxrda).vlsldtot := vr_vlsldtot;
      
      END LOOP;

      -- Iterar sob os dados os associados
      FOR rw_crapass IN cr_crapass(pr_cdcooper,pr_cdagenci) LOOP
        vr_vlsldrdc := 0;
        vr_vlsldrda := 0;
        vr_vlsdpoup := 0;
        vr_vlslfrdc := 0;
        vr_vlslfrda := 0;
        vr_vlsfpoup := 0;

        -- Buscar dados de RDA
        -- Verificar se existe registros na PL Table
        IF vr_tab_craprda.exists(lpad(rw_crapass.nrdconta, 10, '0') || lpad(rw_crapass.cdagenci, 5, '0') || '0000000000') THEN
          vr_idxrda := vr_tab_craprda.next(lpad(rw_crapass.nrdconta, 10, '0') || lpad(rw_crapass.cdagenci, 5, '0') || '0000000000');
        ELSE
          vr_idxrda := null;
        END IF;

        LOOP
          BEGIN
            EXIT WHEN vr_idxrda IS NULL;

            IF vr_tab_craprda(vr_idxrda).tpaplica = 3 THEN
              -- Consultar cálculo de saldo
              apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_inproces => rw_crapdat.inproces
                                                   ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                   ,pr_cdprogra => vr_cdprogra
                                                   ,pr_cdagenci => vr_tab_craprda(vr_idxrda).cdageass
                                                   ,pr_nrdcaixa => 99 --> somente para gerar mensagem em caso de erro
                                                   ,pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta
                                                   ,pr_nraplica => vr_tab_craprda(vr_idxrda).nraplica
                                                   ,pr_vlsdrdca => vr_vlsdrdca
                                                   ,pr_vlsldapl => vr_vlsldapl
                                                   ,pr_vldperda => vr_vldperda
                                                   ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                   ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                   ,pr_txaplica => vr_txaplica
                                                   ,pr_des_reto => vr_dscritic
                                                   ,pr_tab_erro => vr_tab_craterr);

              -- Verifica se ocorreram erros na execução
              IF vr_dscritic = 'NOK' THEN
                vr_dscritic := 'Erro em apli0001.pc_consul_saldo_aplic_rdca30.';
                pr_cdcritic := 0;

                RAISE vr_exc_saida;
              END IF;

              -- Se os aldo RDCA retornar zero ou menor irá para a próxima iteração
              IF nvl(vr_vlsdrdca, 0) <= 0 THEN
                RAISE vr_proximo;
              END IF;

              -- Atribuir valores
              vr_vlsldrda := vr_vlsldrda + vr_vlsdrdca;
              vr_vlslfrda := vr_vlslfrda + vr_tab_craprda(vr_idxrda).vlslfmes;

            ELSIF vr_tab_craprda(vr_idxrda).tpaplica = 5 THEN
              -- Consultar dados de aniversário para RDCA
              apli0001.pc_calc_aniver_rdca2c(pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta
                                            ,pr_nraplica => vr_tab_craprda(vr_idxrda).nraplica
                                            ,pr_vlsdrdca => vr_rd2_vlsdrdca
                                            ,pr_des_erro => vr_dscritic);

              -- Verifica se ocorreram erros na execução
              IF vr_dscritic = 'NOK' THEN
                vr_dscritic := 'Erro em apli0001.pc_calc_aniver_rdca2c.';
                pr_cdcritic := 0;

                RAISE vr_exc_saida;
              END IF;

              -- Atribuir valores
              vr_vlsldrda := vr_vlsldrda + vr_rd2_vlsdrdca;
              vr_vlslfrda := vr_vlslfrda + vr_tab_craprda(vr_idxrda).vlslfmes;
            ELSE
              IF NOT(vr_tab_craprda(vr_idxrda).tpaplica = 1  OR
                     vr_tab_craprda(vr_idxrda).tpaplica = 2) THEN
                -- Se não existir registro gera crítica e aborta execução
                IF NOT vr_tab_crapdtc.exists(vr_tab_craprda(vr_idxrda).tpaplica) THEN
                  vr_cdcritic := 346;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);

                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||vr_cdprogra||' --> '||
                                                                vr_dscritic||'. '||' Conta/DV: '||
                                                                GENE0002.fn_mask_conta(pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta) ||
                                                                ' - Nr. aplicação: ' ||
                                                                GENE0002.fn_mask(pr_dsorigi => vr_tab_craprda(vr_idxrda).nraplica,pr_dsforma => 'zzz.zz9'));

                  RAISE vr_exc_saida;
                END IF;

                -- Limpar tabela de erros e variável
                vr_tab_craterr.delete;
                vr_vlaplrdc := 0;

                -- Para RDCPRE
                IF vr_tab_crapdtc(vr_tab_craprda(vr_idxrda).tpaplica).tpaplrdc = 1 THEN
                  apli0001.pc_saldo_rdc_pre(pr_cdcooper    => pr_cdcooper
                                           ,pr_nrdconta    => vr_tab_craprda(vr_idxrda).nrdconta
                                           ,pr_nraplica    => vr_tab_craprda(vr_idxrda).nraplica
                                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                           ,pr_dtiniper    => NULL
                                           ,pr_dtfimper    => NULL
                                           ,pr_txaplica    => 0
                                           ,pr_flggrvir    => FALSE
                                           ,pr_tab_crapdat => rw_crapdat
                                           ,pr_vlsdrdca    => vr_vlaplrdc
                                           ,pr_vlrdirrf    => vr_vlrdirrf
                                           ,pr_perirrgt    => vr_perirrgt
                                           ,pr_des_reto    => vr_dscritic
                                           ,pr_tab_erro    => vr_tab_craterr);

                  -- Caso encontre erros
                  IF vr_dscritic = 'NOK' THEN
                    vr_cdcritic := 0;
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                                  vr_dscritic || '. ' || vr_tab_craterr(vr_tab_craterr.FIRST).CDCRITIC ||
                                                                  ' - ' || vr_tab_craterr(vr_tab_craterr.FIRST).DSCRITIC);

                    RAISE vr_exc_saida;
                  END IF;
                -- Para RDCPOS
                ELSIF vr_tab_crapdtc(vr_tab_craprda(vr_idxrda).tpaplica).tpaplrdc = 2 THEN
                  apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                           ,pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta
                                           ,pr_nraplica => vr_tab_craprda(vr_idxrda).nraplica
                                           ,pr_dtmvtpap => rw_crapdat.dtmvtolt
                                           ,pr_dtcalsld => rw_crapdat.dtmvtolt
                                           ,pr_flantven => FALSE
                                           ,pr_flggrvir => FALSE
                                           ,pr_dtinitax => vr_dtinitax
                                           ,pr_dtfimtax => vr_dtfimtax
                                           ,pr_vlsdrdca => vr_vlaplrdc
                                           ,pr_vlrentot => vr_vlrentot
                                           ,pr_vlrdirrf => vr_vlrdirrf
                                           ,pr_perirrgt => vr_perirrgt
                                           ,pr_des_reto => vr_dscritic
                                           ,pr_tab_erro => vr_tab_craterr);

                  -- Verifica se ocorreram erros na execução
                  IF vr_dscritic = 'NOK' THEN
                    vr_cdcritic := 0;
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                                  vr_dscritic || '. ' || vr_tab_craterr(vr_tab_craterr.FIRST).CDCRITIC ||
                                                                  ' - ' || vr_tab_craterr(vr_tab_craterr.FIRST).DSCRITIC);

                    RAISE vr_exc_saida;
                  END IF;
                END IF;

                -- Atribuição de valores
                vr_vlsldrdc := nvl(vr_vlsldrdc, 0) + nvl(vr_vlaplrdc, 0);
                vr_vlslfrdc := vr_vlslfrdc + nvl(vr_tab_craprda(vr_idxrda).vlslfmes, 0);
              
              ELSE
                -- Atribuição de valores
                vr_vlsldrdc := nvl(vr_vlsldrdc, 0) + vr_tab_vlsldtot(vr_idxrda).vlsldtot;
                vr_vlslfrdc := vr_vlslfrdc + nvl(vr_tab_craprda(vr_idxrda).vlslfmes, 0);
              END IF;

            END IF;

            -- Controle para definir se o LOOP irá continuar a iteração (atribui NULL caso não continue)
            -- Verifica se o próximo registro é null (chegamos ao final da PL Table)
            IF vr_tab_craprda.next(vr_idxrda) IS NULL THEN
              vr_idxrda := NULL;
            ELSE
              -- Verifica se já existe proxima conta
              IF lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).nrdconta, 10, '0') ||
                   lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).cdageass, 5, '0') <>
                 lpad(rw_crapass.nrdconta, 10, '0') || lpad(rw_crapass.cdagenci, 5, '0') THEN
                vr_idxrda := NULL;
              ELSE
                vr_idxrda := vr_tab_craprda.next(vr_idxrda);
              END IF;
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN
              RAISE vr_exc_saida;
            WHEN vr_proximo THEN
              -- Controle para definir se o LOOP irá continuar a iteração (atribui NULL caso não continue)
              -- Verifica se o próximo registro é null (chegamos ao final da PL Table)
              IF vr_tab_craprda.next(vr_idxrda) IS NULL THEN
                vr_idxrda := NULL;
              ELSE
                -- Verifica se já existe proxima conta
                IF lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).nrdconta, 10, '0') ||
                     lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).cdageass, 5, '0') <>
                   lpad(rw_crapass.nrdconta, 10, '0') || lpad(rw_crapass.cdagenci, 5, '0') THEN
                  vr_idxrda := NULL;
                ELSE
                  vr_idxrda := vr_tab_craprda.next(vr_idxrda);
                END IF;
              END IF;
            WHEN others THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;

        -- Verificar se existe registros na PL Table
        IF vr_tab_craprpp.exists(lpad(rw_crapass.nrdconta, 10, '0') || '0000000000') THEN
          vr_idxindc := vr_tab_craprpp.next(lpad(rw_crapass.nrdconta, 10, '0') || '0000000000');
        ELSE
          vr_idxindc := null;
        END IF;

        -- Iterar sobre a PL Table
        LOOP
          BEGIN
            EXIT WHEN vr_idxindc IS NULL;

            -- Sempre irá testar o índice futuro para executar atribuição de dados pelo índice anterior
            IF vr_tab_craprpp(vr_idxindc).nrdconta = rw_crapass.nrdconta THEN
              -- Passa para o próximo registro
              IF vr_tab_craprpp(vr_idxindc).cdsitrpp = 5 THEN
                -- Buscar próximo índice
                vr_idxindc := vr_tab_craprpp.next(vr_idxindc);

                RAISE vr_iterar;
              END IF;

              -- Calcular o saldo até a data do movimento
              IF vr_tab_craprpp(vr_idxindc).cdprodut < 1 THEN
              	      vr_rpp_vlsdrdpp := vr_tab_craprpp(vr_idxindc).vlslfmes;
	          ELSE
                      apli0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper
                                               ,pr_dstextab  => vr_dextabi
                                               ,pr_cdprogra  => vr_cdprogra
                                               ,pr_inproces  => rw_crapdat.inproces
                                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                               ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                                               ,pr_rpp_rowid => vr_tab_craprpp(vr_idxindc).rowid
                                               ,pr_vlsdrdpp  => vr_rpp_vlsdrdpp
                                               ,pr_cdcritic  => vr_cdcritic
                                               ,pr_des_erro  => vr_dscritic);
              END IF;

              -- Se encontrar erros na execução
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                END IF;
                vr_dscritic := 'Conta '||vr_tab_craprpp(vr_idxindc).nrdconta||' Rowid Poup '||vr_tab_craprpp(vr_idxindc).rowid|| ' -> ' ||vr_dscritic;
                RAISE vr_exc_saida;
              END IF;

              -- Atribuir valores para as variáveis
              vr_vlsdpoup := vr_vlsdpoup + nvl(vr_rpp_vlsdrdpp, 0);
              vr_vlsfpoup := vr_vlsfpoup + nvl(vr_tab_craprpp(vr_idxindc).vlslfmes, 0);

              -- Buscar próximo índice
              vr_idxindc := vr_tab_craprpp.next(vr_idxindc);
            ELSE
              vr_idxindc := null;
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN
              RAISE vr_exc_saida;
            WHEN vr_iterar THEN
              NULL;
          END;
        END LOOP;

        -- Atribuir valores para as variáveis
        vr_vlsldapl := nvl(vr_vlsldrda, 0) + nvl(vr_vlsldrdc, 0) + nvl(vr_vlsdpoup, 0);
        vr_vlsldapl2 := nvl(vr_vlslfrda, 0) + nvl(vr_vlslfrdc, 0) + nvl(vr_vlsfpoup, 0);

        -- Criar registro na tabela de banco
        pc_insere_temp(pr_tpinsert  => 1
                      ,pr_nrdconta  => rw_crapass.nrdconta
                      ,pr_cdagenci  => rw_crapass.cdagenci
                      ,pr_inpessoa  => rw_crapass.inpessoa
                      ,pr_nrcpfcgc  => rw_crapass.nrcpfcgc
                      ,pr_nrmatric  => rw_crapass.nrmatric
                      ,pr_nmprimtl  => rw_crapass.nmprimtl
                      ,pr_vlsldapl1 => vr_vlsldapl
                      ,pr_vlsldrdc  => vr_vlsldrdc
                      ,pr_vlsldrda  => vr_vlsldrda
                      ,pr_vlsdpoup  => vr_vlsdpoup
                      ,pr_vlsldapl2 => vr_vlsldapl2
                      ,pr_vlslfrdc  => vr_vlslfrdc
                      ,pr_vlslfrda  => vr_vlslfrda
                      ,pr_vlsfpoup  => vr_vlsfpoup
                      ,pr_des_erro  => vr_dscritic);

        -- Se encontrar erros na execução
        IF vr_dscritic = 'NOK' THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Conta '||rw_crapass.nrdconta||' --> ' || vr_dscritic || '. ';
          RAISE vr_exc_saida;
        END IF;
      END LOOP;
      
      -- Grava data fim para o JOB na tabela de LOG 
      pc_log_programa(pr_dstiplog   => 'F'  
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci           
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par
                     ,pr_flgsucesso => 1);     
      
    END IF;

    -- Verificar se ocorreram críticas
    IF vr_cdcritic > 0 THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Se for o programa principal ou sem paralelismo
    if nvl(pr_idparale,0) = 0 then

      -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
      pc_log_programa(pr_dstiplog     => 'O'
                     ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                     ,pr_cdcooper     => pr_cdcooper
                     ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia => 4
                     ,pr_dsmensagem   => 'Inicio - Geração Relatórios.'
                     ,pr_idprglog     => vr_idlog_ini_ger); 
      
      -- Ler da tabela temporária as informações gravadas e converter para a pltable, a ser utilizada abaixo
      for rw_relwork in cr_relwork(pr_cdcooper    => pr_cdcooper
                                  ,pr_cdprograma  => vr_cdprogra
                                  ,pr_dsrelatorio => 'crrl117'
                                  ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) loop
        -- Gerar informação na pltable
        pc_insere_temp(pr_tpinsert  => 2 
                      ,pr_nrdconta  => rw_relwork.nrdconta
                      ,pr_cdagenci  => rw_relwork.cdagenci
                      ,pr_inpessoa  => rw_relwork.inpessoa
                      ,pr_nrcpfcgc  => rw_relwork.nrcpfcgc
                      ,pr_nrmatric  => rw_relwork.nrmatric
                      ,pr_nmprimtl  => rw_relwork.nmprimtl
                      ,pr_vlsldapl1 => to_number(rw_relwork.vlsldapl,'fm999g999g999g990d00')
                      ,pr_vlsldrdc  => to_number(rw_relwork.vlsldrdc,'fm999g999g999g990d00')
                      ,pr_vlsldrda  => to_number(rw_relwork.vlsldrda,'fm999g999g999g990d00')
                      ,pr_vlsdpoup  => to_number(rw_relwork.vlsdpoup,'fm999g999g999g990d00')
                      ,pr_vlsldapl2 => to_number(rw_relwork.vlsldapl2,'fm999g999g999g990d00')
                      ,pr_vlslfrdc  => to_number(rw_relwork.vlslfrdc,'fm999g999g999g990d00')
                      ,pr_vlslfrda  => to_number(rw_relwork.vlslfrda,'fm999g999g999g990d00')
                      ,pr_vlsfpoup  => to_number(rw_relwork.vlsfpoup,'fm999g999g999g990d00')
                      ,pr_des_erro  => vr_dscritic);

        -- Se encontrar erros na execução
        IF vr_dscritic = 'NOK' THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Conta '||rw_relwork.nrdconta||' --> ' || vr_dscritic || '. ';
          RAISE vr_exc_saida;
        END IF;
      end loop;
      
      -- Carregar titulares
      FOR vr_crapttl IN cr_crapttl(pr_cdcooper,pr_cdagenci) LOOP
        vr_tab_crapttl(lpad(vr_crapttl.nrdconta, 10, '0')).cdempres := vr_crapttl.cdempres;
      END LOOP;

      -- Carregar Pessoas Juridicas
      FOR vr_crapjur IN cr_crapjur(pr_cdcooper,pr_cdagenci) LOOP
        vr_tab_crapjur(lpad(vr_crapjur.nrdconta, 10, '0')).cdempres := vr_crapjur.cdempres;
      END LOOP;
      
      -- Especificar inicialização do XML
      -- Arquivo CRRL117
      dbms_lob.createtemporary(vr_clob1, TRUE);
      dbms_lob.open(vr_clob1, dbms_lob.lob_readwrite);    
      gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                             ,pr_texto_completo => vr_char1
                             ,pr_texto_novo     =>'<?xml version="1.0" encoding="utf-8"?><base>');

      -- Limpar quantidade de registros processados
      vr_qtregist := 0;

      -- Iterar sobre PL Table de registros temporários
      vr_idxpl := vr_tab_temp.last;

      LOOP
        BEGIN
          EXIT WHEN vr_idxpl IS NULL;

          -- Acumular quantidade de registros
          vr_qtregist := vr_qtregist + 1;

          -- Gerar id Associado
          vr_idxcrapasss := lpad(vr_tab_temp(vr_idxpl).nrdconta, 10, '0');

          -- Limpar valor da variável
          vr_cdempres := 0;

          -- Identifica se é pessoa jurídica ou física
          IF vr_tab_temp(vr_idxpl).inpessoa = 1 THEN
            -- Verifica se registro de pessoa física existe
            IF vr_tab_crapttl.exists(vr_idxcrapasss) THEN
              vr_cdempres := vr_tab_crapttl(vr_idxcrapasss).cdempres;
            END IF;
          ELSE
            -- Verifica se registro de pessoa jurídica existe
            IF vr_tab_crapjur.exists(vr_idxcrapasss) THEN
              vr_cdempres := vr_tab_crapjur(vr_idxcrapasss).cdempres;
            END IF;
          END IF;

          pc_cria_aplicadores(pr_nrcpfcgc  => vr_tab_temp(vr_idxpl).nrcpfcgc
                             ,pr_inpessoa  => vr_tab_temp(vr_idxpl).inpessoa
                             ,pr_vlsldapl2 => vr_tab_temp(vr_idxpl).vr_vlsldapl2
                             ,pr_vlslfrdc  => vr_tab_temp(vr_idxpl).vr_vlslfrdc
                             ,pr_vlslfrda  => vr_tab_temp(vr_idxpl).vr_vlslfrda
                             ,pr_vlsfpoup  => vr_tab_temp(vr_idxpl).vr_vlsfpoup
                             ,pr_nmprimtl  => vr_tab_temp(vr_idxpl).nmprimtl
                             ,pr_des_erro  => vr_dscritic);

          -- Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
          END IF;

          -- Pular caso valor atenda condição
          IF nvl(vr_tab_temp(vr_idxpl).vr_vlsldapl1, 0) <= 0 THEN
            RAISE vr_pula;
          END IF;

          -- Valida valores para ir para a proxima iteração do laço
          IF nvl(vr_tab_temp(vr_idxpl).vr_vlsldapl1, 0) < nvl(vr_tab_vlsdmadp, 0) THEN
            RAISE vr_pula;
          END IF;

          -- Gera dados para arquivo principal
          gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                 ,pr_texto_completo => vr_char1
                                 ,pr_texto_novo     =>'<dados cdagenci=''' || vr_tab_temp(vr_idxpl).cdagenci || '''>'
                                                    ||'<qtregist>'||to_char(vr_qtregist,'FM999G999G990')||'</qtregist>'
                                                    ||'<nrdconta>'||to_char(vr_tab_temp(vr_idxpl).nrdconta,'FM999999G999G0')||'</nrdconta>'
                                                    ||'<cdempres>'||vr_cdempres||'</cdempres>'
                                                    ||'<nrmatric>'||to_char(vr_tab_temp(vr_idxpl).nrmatric,'FM999G999G990')||'</nrmatric>'
                                                    ||'<nmprimtl>'||vr_tab_temp(vr_idxpl).nmprimtl||'</nmprimtl>');

          IF vr_tab_temp(vr_idxpl).vr_vlsldapl1 > 0 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsldapl>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsldapl1,'FM999G999G999G999G990D90')||'</vlsldapl>');
          ELSE
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsldapl> </vlsldapl>');
          END IF;

          IF vr_tab_temp(vr_idxpl).vr_vlsldrdc > 0 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsldrdc>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsldrdc,'FM999G999G999G999G990D90')||'</vlsldrdc>');
          ELSE
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsldrdc> </vlsldrdc>');          
          END IF;

          IF vr_tab_temp(vr_idxpl).vr_vlsldrda > 0 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsldrda>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsldrda,'FM999G999G999G999G990D90')||'</vlsldrda>');    
          ELSE
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsldrda> </vlsldrda>');          
          END IF;


          IF vr_tab_temp(vr_idxpl).vr_vlsdpoup > 0 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsdpoup>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsdpoup,'FM999G999G999G999G990D90')||'</vlsdpoup>');        
          ELSE
            gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                   ,pr_texto_completo => vr_char1
                                   ,pr_texto_novo     =>'<vlsdpoup> </vlsdpoup>');    
          END IF;
          
          gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                                 ,pr_texto_completo => vr_char1
                                 ,pr_texto_novo     =>'</dados>');

          -- Sumarização de valores
          vr_tot_vlsldapl := vr_tot_vlsldapl + nvl(vr_tab_temp(vr_idxpl).vr_vlsldapl1, 0);
          vr_tot_vlsldrdc := vr_tot_vlsldrdc + nvl(vr_tab_temp(vr_idxpl).vr_vlsldrdc, 0);
          vr_tot_vlsdrdca := vr_tot_vlsdrdca + nvl(vr_tab_temp(vr_idxpl).vr_vlsldrda, 0);
          vr_tot_vlsdpoup := vr_tot_vlsdpoup + nvl(vr_tab_temp(vr_idxpl).vr_vlsdpoup, 0);

          -- Localiza próximo registro
          vr_idxpl := vr_tab_temp.prior(vr_idxpl);
        EXCEPTION
          WHEN vr_pula THEN
            -- Localiza próximo registro
            vr_idxpl := vr_tab_temp.prior(vr_idxpl);
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro gerando XML STR_1: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP;
      
      -- Gerar dados da sumarização no arquivo principal
      gene0002.pc_escreve_xml(pr_xml            => vr_clob1
                             ,pr_texto_completo => vr_char1
                             ,pr_texto_novo     =>'<total><tot_vlsldapl>'||to_char(vr_tot_vlsldapl,'FM999G999G999G999G990D90')||'</tot_vlsldapl>'
                                                ||'<tot_vlsldrdc>'||to_char(vr_tot_vlsldrdc,'FM999G999G999G999G990D90')||'</tot_vlsldrdc>'
                                                ||'<tot_vlsdrdca>'||to_char(vr_tot_vlsdrdca,'FM999G999G999G999G990D90')||'</tot_vlsdrdca>'
                                                ||'<tot_vlsdpoup>'||to_char(vr_tot_vlsdpoup,'FM999G999G999G999G990D90')||'</tot_vlsdpoup></total></base>'
                             ,pr_fecha_xml      => TRUE);

      -- Criar arquivo princial com dados armazenados
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_clob1
                                 ,pr_dsxmlnode => '/base/dados'
                                 ,pr_dsjasper  => 'crrl117.jasper'
                                 ,pr_dsparams  => 'PR_QUEBRA##N'
                                 ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || '.lst'
                                 ,pr_flg_gerar => vr_agendamento
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
                                 ,pr_flsemqueb => 'N'
                                 ,pr_des_erro  => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro gerando arquivo ' || vr_nomarq || '.lst' || ': ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Criar arquivo igual ao anterior, somente para agendamento
      IF vr_agendamento = 'N' THEN
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_clob1
                                   ,pr_dsxmlnode => '/base/dados'
                                   ,pr_dsjasper  => 'crrl117.jasper'
                                   ,pr_dsparams  => 'PR_QUEBRA##N'
                                   ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || '_999.lst'
                                   ,pr_flg_gerar => vr_agendamento
                                   ,pr_qtcoluna  => 132
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => NULL
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => NULL
                                   ,pr_nrcopias  => NULL
                                   ,pr_dspathcop => NULL
                                   ,pr_dsmailcop => NULL
                                   ,pr_dsassmail => NULL
                                   ,pr_dscormail => NULL
                                   ,pr_flsemqueb => 'N'
                                   ,pr_des_erro  => vr_dscritic);

        -- Verifica se ocorreram erros
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro gerando arquivo ' || vr_nomarq || '_99.lst' || ': ' || vr_dscritic;
          RAISE vr_exc_saida;
       END IF;
      ELSE
        gene0001.pc_OScommand_Shell('cp ' || vr_nom_dir || vr_nomarq || '.lst '|| vr_nom_dir || vr_nomarq || '_99.lst');
      END IF;

      -- Criar arquivo totalização sem quebra com dados armazenados
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_clob1
                                 ,pr_dsxmlnode => '/base/dados'
                                 ,pr_dsjasper  => 'crrl117.jasper'
                                 ,pr_dsparams  => 'PR_QUEBRA##S'
                                 ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || rw_crapcop.dsdircop || '.lst'
                                 ,pr_flg_gerar => vr_agendamento
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_cdrelato  => NULL
                                 ,pr_flg_impri => 'N'
                                 ,pr_nmformul  => NULL
                                 ,pr_nrcopias  => NULL
                                 ,pr_dspathcop => NULL
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_flsemqueb => 'S'
                                 ,pr_des_erro  => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro gerando arquivo ' || vr_nomarq || rw_crapcop.dsdircop || '.lst' || ': ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Liberar dados do CLOB da memória
      dbms_lob.close(vr_clob1);
      dbms_lob.freetemporary(vr_clob1);

      -- Criar nova PL Table reordenada
      pc_order_table(vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        pr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;

      -- Gerar arquivo separado por CPF
      dbms_lob.createtemporary(vr_clob5, TRUE);
      dbms_lob.open(vr_clob5, dbms_lob.lob_readwrite);

      -- Inicilizar as informações do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob5
                             ,pr_texto_completo => vr_char5
                             ,pr_texto_novo     =>'<?xml version="1.0" encoding="utf-8"?><base>'); 

      -- Busca primeiro índice da PL Table
      vr_indxpl := vr_tab_oaplicadores.last;

      -- Iteração sob a PL Table
      LOOP
        EXIT WHEN vr_indxpl IS NULL;
        IF vr_tab_oaplicadores(vr_indxpl).vlslfapl > 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_clob5
                                 ,pr_texto_completo => vr_char5
                                 ,pr_texto_novo     =>'<dados coop=''' || lpad(pr_cdcooper, 4, '0') || '''>'
                                                    ||'<nome>'||substr(vr_tab_oaplicadores(vr_indxpl).nmprimtl,1,40)||'</nome>'
                                                    ||'<cpfcnpj>'||vr_tab_oaplicadores(vr_indxpl).nrcpfcgc||'</cpfcnpj>'
                                                    ||'<RDC>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlslfrdc,'FM999G999G999G990D00')||'</RDC>'
                                                    ||'<RDCA>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlslfrda,'FM999G999G999G990D00')||'</RDCA>'
                                                    ||'<poupprog>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlsfpoup,'FM999G999G999G990D00')||'</poupprog>'
                                                    ||'<totalapli>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlslfapl,'FM999G999G999G990D00')||'</totalapli></dados>');
        END IF;
        -- Busca o próximo registro
        vr_indxpl := vr_tab_oaplicadores.prior(vr_indxpl);
      END LOOP;
      
      -- Gerar dados da sumarização no arquivo principal
      gene0002.pc_escreve_xml(pr_xml            => vr_clob5
                             ,pr_texto_completo => vr_char5
                             ,pr_texto_novo     =>'</base>'
                             ,pr_fecha_xml      => TRUE);    

      -- Criar arquivo LST
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_clob5
                                 ,pr_dsxmlnode => '/base/dados'
                                 ,pr_dsjasper  => 'crrl117_dir_cpf.jasper'
                                 ,pr_dsparams  => NULL
                                 ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || rw_crapcop.dsdircop || '_CPF.lst'
                                 ,pr_flg_gerar => vr_agendamento
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_cdrelato  => NULL
                                 ,pr_flg_impri => 'N'
                                 ,pr_nmformul  => NULL
                                 ,pr_nrcopias  => NULL
                                 ,pr_dspathcop => NULL
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_flsemqueb => 'S'
                                 ,pr_des_erro  => vr_dscritic);

      -- Liberar dados do CLOB da memória
      dbms_lob.close(vr_clob5);
      dbms_lob.freetemporary(vr_clob5);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;
      
      -- Limpa os registros da tabela de trabalho 
      begin    
        delete from tbgen_batch_relatorio_wrk
         where cdcooper    = pr_cdcooper
           and cdprograma  = vr_cdprogra
           AND dsrelatorio = 'crrl117'
           and dtmvtolt    = rw_crapdat.dtmvtolt;    
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
          raise vr_exc_saida;            
      end;
      
      -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
      pc_log_programa(PR_DSTIPLOG           => 'O'
                     ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                     ,pr_cdcooper           => pr_cdcooper
                     ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia       => 4
                     ,pr_dsmensagem         => 'Fim - Geração Relatórios.'
                     ,PR_IDPRGLOG           => vr_idlog_ini_ger); 

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      
      -- Caso seja o controlador 
      if vr_idcontrole <> 0 then
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => vr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;                                       
      end if; 
 
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F'   
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 1); 
      -- Efetuar commit
      COMMIT;
    ELSE
      -- Atualiza finalização do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                         ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                         ,pr_dscritic     --pr_dscritic  OUT crapcri.dscritic%TYPE
                                         );  

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);  
    
      -- Salvar informacoes no banco de dados
      COMMIT;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      -- Na execução paralela
      IF nvl(pr_idparale,0) <> 0 THEN

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);                                     
        
        -- Grava LOG de erro com as críticas retornadas                           
        pc_log_programa(pr_dstiplog      => 'E', 
                        pr_cdprograma    => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper      => pr_cdcooper,
                        pr_tpexecucao    => vr_tpexecucao,
                        pr_tpocorrencia  => 3,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => pr_cdcritic,
                        pr_dsmensagem    => pr_dscritic,
                        pr_flgsucesso    => 0,
                        pr_idprglog      => vr_idlog_ini_par);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);                        
                                    
      ELSE
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
      END IF;
      END IF;
      
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
      -- Na execução paralela
      if nvl(pr_idparale,0) <> 0 then 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 
        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if;
      
      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS140;
/
