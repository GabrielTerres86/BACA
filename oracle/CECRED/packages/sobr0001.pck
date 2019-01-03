CREATE OR REPLACE PACKAGE CECRED.sobr0001 AS
  
  -- Constantes dos lotes de lançamentos em capital
  vr_cdagenci CONSTANT crapass.cdagenci%TYPE := 1;    -- Codigo da agencia
  vr_cdbccxlt CONSTANT craplot.cdbccxlt%TYPE := 100;  -- Codigo do banco / caixa
  vr_nrdolote CONSTANT craplot.nrdolote%TYPE := 8005; -- Numero do lote
  
  -- Constantes dos históricos de lançamento em Cotas
  vr_cdhisopc_cot CONSTANT craphis.cdhistor%TYPE := 64;   /* Sobras sobre Operações de Crédito */
  vr_cdhisdep_cot CONSTANT craphis.cdhistor%TYPE := 1801; /* Sobras sobre Depósitos em Conta Quando unificado */
  vr_cdhisdpp_cot CONSTANT craphis.cdhistor%TYPE := 2173; /* Sobras sobre Depósito a Prazo */
  vr_cdhisdpa_cot CONSTANT craphis.cdhistor%TYPE := 2174; /* Sobras sobre Depósito a Vista */
  vr_cdhistar_cot CONSTANT craphis.cdhistor%TYPE := 1940; /* Sobras sobre Tarifas Pagas    */
  vr_cdhisaut_cot CONSTANT craphis.cdhistor%TYPE := 2172; /* Sobras sobre Auto Atendimento */
  
  vr_cdhisjur_cot CONSTANT craphis.cdhistor%TYPE := 926;  /* Juros sobre Capital */
  vr_cdhisirr_cot CONSTANT craphis.cdhistor%TYPE := 922;  /* IR Sobre Capital */
  
  vr_cdhiscot_dem_pf CONSTANT craphis.cdhistor%TYPE := 2079; -- CAPITAL DISPONIVEL PARA SAQUE CONTA ENCERRADA PF
  vr_cdhiscot_dem_pj CONSTANT craphis.cdhistor%TYPE := 2080; -- CAPITAL DISPONIVEL PARA SAQUE CONTA ENCERRADA PJ
 
  -- Constantes dos históricos de lançamento em Conta Corrente
  vr_cdhisopc_cta CONSTANT craphis.cdhistor%TYPE := 2178; /* Sobras sobre Operações de Crédito */
  vr_cdhisdep_cta CONSTANT craphis.cdhistor%TYPE := 2189; /* Sobras sobre Depósitos em Conta Quando unificado */
  vr_cdhisdpp_cta CONSTANT craphis.cdhistor%TYPE := 2175; /* Sobras sobre Depósito a Prazo */
  vr_cdhisdpa_cta CONSTANT craphis.cdhistor%TYPE := 2176; /* Sobras sobre Depósito a Vista */
  vr_cdhistar_cta CONSTANT craphis.cdhistor%TYPE := 2179; /* Sobras sobre Tarifas Pagas    */
  vr_cdhisaut_cta CONSTANT craphis.cdhistor%TYPE := 2177; /* Sobras sobre Auto Atendimento */ 

  vr_cdhiscta_dem_pf CONSTANT craphis.cdhistor%TYPE := 2061; -- DEBITO SALDO DEPOSITO CONTA ENCERRADA PF
  vr_cdhiscta_dem_pj CONSTANT craphis.cdhistor%TYPE := 2062; -- DEBITO SALDO DEPOSITO CONTA ENCERRADA PJ

  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_calculo_retorno_sobras(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE   --> Programa chamador
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada
																	 
  /* Procedure para verificar a data em que o cooperado deve ser informado sobre os créditos que 
	   recebeu na conta capital referente a juros sobre capital e retorno de sobras. */
  PROCEDURE pc_verifica_conta_capital (pr_cdcooper IN crapcop.cdcooper%TYPE		 --> Cód. cooperativa
		                                  ,pr_nrdconta IN craplct.nrdconta%TYPE    --> Número da conta		
																			,pr_flgconsu OUT INTEGER                 --> Flag para indicar se encontrou lançamentos de cotas/capital
																			,pr_vltotsob OUT craplct.vllanmto%TYPE	 --> Valor total de sobras
																			,pr_vlliqjur OUT craplct.vllanmto%TYPE   --> Valor liquido do crédito de juros sobre capital
																			,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Cód. da crítica
																			,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descrição da crítica

END sobr0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.sobr0001 AS

  -- Definicao do tipo de tabela para utilizacao no relatorio CRRL412. Eh a copia do arquivo CRRL048.CAL
  TYPE typ_reg_crrl412 IS
    RECORD(cdagenci crapass.cdagenci%TYPE,
           nrdconta crapass.nrdconta%TYPE,
           nmprimtl crapass.nmprimtl%TYPE,
           vlmedcap NUMBER(17,2),
           vlbascap NUMBER(17,2),
           vlretcap NUMBER(17,2),
           vlbasopc NUMBER(17,2),
           vlretopc NUMBER(17,2),
           vlbasapl NUMBER(17,2),
           vlretapl NUMBER(17,2),
           vlbassdm NUMBER(17,2),
           vlretsdm NUMBER(17,2),
           vlbastar NUMBER(17,2),
           vlrettar NUMBER(17,2),
           vlbasaut NUMBER(17),
           vlretaut NUMBER(17,2),           
           vldeirrf NUMBER(17,2),
           percirrf NUMBER(8,2),
           vlcredit NUMBER(17,2),
           vlcrecot NUMBER(17,2),
           vlcrecta NUMBER(17,2),
           vlcretot NUMBER(17,2));
  TYPE typ_tab_crrl412 IS
    TABLE OF typ_reg_crrl412
    INDEX BY VARCHAR2(15);

  -- Definicao do tipo de tabela para o processo definitivo. Eh a copia do arquivo CRRL048.DAT
  TYPE typ_reg_crrl048 IS
    RECORD(dsrowid  ROWID
          ,nrdconta crapass.nrdconta%TYPE
          ,inpessoa NUMBER(17,2)
          ,dtelimin crapass.dtelimin%TYPE

          ,flraimfx NUMBER(1)
          ,qtraimfx crapcot.qtraimfx%TYPE
          ,vldcotas crapcot.vldcotas%TYPE
																	 
          ,vljurcap NUMBER(17,2)
          ,vldeirrf NUMBER(17,2)

          ,vlretcrd NUMBER(17,2)
          ,vlretcrd_cot NUMBER(17,2)
          ,vlretcrd_cta NUMBER(17,2)

          ,vljurapl NUMBER(17,2)
          ,vljurapl_cot NUMBER(17,2)
          ,vljurapl_cta NUMBER(17,2)

          ,vljursdm NUMBER(17,2)
          ,vljursdm_cot NUMBER(17,2)
          ,vljursdm_cta NUMBER(17,2)

          ,vljurtar NUMBER(17,2)
          ,vljurtar_cot NUMBER(17,2)
          ,vljurtar_cta NUMBER(17,2)

          ,vljuraut NUMBER(17,2)
          ,vljuraut_cot NUMBER(17,2)
          ,vljuraut_cta NUMBER(17,2));
  TYPE typ_tab_crrl048 IS
    TABLE OF typ_reg_crrl048
      INDEX BY PLS_INTEGER;      

  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_calculo_retorno_sobras(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                   ,pr_cdprogra IN crapprg.cdprogra%TYPE   --> Programa chamador
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada


/* .............................................................................

   Programa: pc_calculo_retorno_sobras (includes/crps048.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei - Precise
   Data    : Abril/2008                        Ultima atualizacao: 04/09/2017
   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Calculo e credito do retorno de sobras e juros sobre o capital.
               Atende a solicitacao 030. Emite relatorio 43.
               Include criada com base no programa fontes/crps048 para permitir
               chamada on-line (crps510) e batch (crps048).

   /* ATENCAO: ESSE PROGRAMA SOMENTE CREDITA RETORNO SOBRE JUROS AO CAPITAL E
      ======== SOBRE RENDIMENTOS DE APLICACOES SE FOI PEDIDO CREDITO DE RETORNO
               SOBRE JUROS PAGOS */
   /*** Conteudo do campo
   tot_vlbasret = BASE DE JUROS SOBRE EMPRESTIMOS/CONTA-CORRENTE
   contem a somataria do campo crapcot.qtraimfx que e atualizado
   no anual crps011. No crps011 o campo crapcot.qtraimfx ganha o conteudo do
   campo crapcot.qtjurmfx. O campo crapcot.qtjurmfx e alimentado durante o ano
   atraves dos programas crps078 com historico 98, juros sobre emprestimos e
   atraves do crps008, com historicos 37,38 e 57
   **********************
   Alteracoes: 14/10/2008 - Adaptacao para desconto de titulos (David).

               05/02/2009 - Utilizar novo campo crapcot.vlpvardc para calculo
                            da base de rendimentos sobre aplicacoes (David).

               11/03/2009 - Acrescentar valor de retorno de desc.titulos no
                            total de retorno creditado (David).

               27/03/2009 - Copiar crrl043 para o diretorio rlnsv quando for o
                            calculo previo (David).

               15/02/2011 - Retirado do calculo o parametro increjur
                          - Novo layout do relatorio detalhado
                          - Incluso saldo medio c/c no calculo de retorno
                          - Retirado media capital do calculo de retorno
                          - Calcular rendimento de media capital a partir
                            do crapdir
                          - Lançar rendimento de capital separado das sobras
                            e lancar IRRF sobre o rendimento
                          - Incluido IRRF e RETORNO+JUROS no crap048.dat
                          - Utilizado dtdemiss da crapdir (Guilherme).

               11/03/2011 - Creditar as sobras nas contas migradas
                            O tratamento ainda esta fixo pois nao ha como
                            identificar a cooperativa migrada de uma forma
                            dinamica e performatica
                          - Desprezar as contas na cooperativa nova na hora
                            do calculo, pois o tratamento destas contas
                            sera feito na cooperativa antiga
                          - Aumento das casas decimais para 8 dig (Guilherme).

               23/01/2012 - Retirar controle de sobreposicao de PAC (David).

               02/04/2012 - Retirar leitura da tabela crapjsc (David).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               29/11/2012 - Migracao Alto Vale (David).

               03/09/2013 - Tratamento para Imunidade Tributaria (Ze).

               01/10/2013 - Migracao ACREDI (Diego).

               29/10/2013 - Ajuste na instancia da BO 159 (Ze).

               27/01/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

               12/03/2014 - Converter o arquivos ux2dos antes de enviar
                            (Gabriel)

               18/03/2014 - Separar o Credito de Juros e Retorno das Sobras (Ze)
               
               23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes 
                            de envia-lo por e-mail(Odirlei-AMcom) 
                            
               12/08/2014 - Correção para zerar taxa de retorno apos o credito
                            Correção do tamanho das variaveis de taxas pois estavam truncando valores
                            (Marcos-Supero)

               29/08/2014 - Incorporação Credimilsul - Scrcred (Jean Michel)             

               14/01/2015 - Ajustade no relatorio Resumo retorno sobras para listar 
                            os lançamentos segregados do retorno de sobras. 
                            (Carlos Rafael Tanholi - 243124)
														
							 09/02/2015 - Ajuste para manter a data informada na limpeza dos 
							              parametros utilizados para calcular o retorno de 
														sobras. (Reinert)
														
							 28/10/2015 - Adição do cálculo de sobras sobre tarifas pagas
                            (Dionathan)
														
							 08/12/2015 - Remoção do percentual fixo de IRRF para ler da tabela
                            TBCOTAS_FAIXAS_IRRF (Dionathan)
                            
               28/07/2016 - M360 - Inclusão das Sobras por Auto Atendimento
                                 - Fracionamento das distribuição entre CC e Cotas
                                 - Separação dos lançaemntos de DEP a Vista e a Prazo
                                 - Ajustes nos relatórios para os novos campos (Marcos-Supero)           

               14/12/2016 - Adicao de funcionalidade para carregar uma pltable com
                            contas que nao devem receber juros sobre o capital e nem
                            retorno de sobras. No momento, necessario devido a incorporacao
                            Transulcred -> Transpocred, posteriormente a estrutura podera 
                            ser utilizada para outros casos de contas proibidas. (Anderson)
                            
               23/03/2017 - Alterada chamada da procedure de imunidade tributária para
                            evitar nova leitura na crapass (Rodrigo)
                            
               04/09/2017 - Mudanca para calcular tambem no ultimo dia util do ano
                            M439 (Tiago/Thiago #635669). 
                            
               21/12/2017 - Alteracao para desconsiderar se o cooperado esta eliminado ou nao.
                            Adequar lancamentos para cooperados eliminados para voltar a lancar
                            o credito das sobras/juros. (Anderson SD820374).
               
               14/05/2018 - Ajustar para atualizar a sobras e capital para a situação 8
                            (Rafael - Mouts).
                            
               28/06/2018 - P450 Criação de procedure para efetuar lançamentos - LANC0001.PC_GERAR_LANCAMENTO_CONTA 
                           (Anderson Heckmann/AMcom) 
  
............................................................................. */

      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis gerais
      vr_dstextab craptab.dstextab%TYPE;
      vr_inprvdef PLS_INTEGER;
      vr_flultdia BOOLEAN;
      vr_anocalcu PLS_INTEGER;
      vr_vlretaux craplcm.vllanmto%TYPE;
      --vr_ininccmi PLS_INTEGER;
      vr_increret PLS_INTEGER;
      vr_txdretor NUMBER(17,10);
      vr_txjurcap NUMBER(17,10);
      vr_txjurapl NUMBER(17,10);
      vr_txjursdm NUMBER(17,10);
      vr_txjurtar NUMBER(17,10);
      vr_txjuraut NUMBER(17,10);
      vr_indivdep PLS_INTEGER;
      vr_perpfcot NUMBER(5,2);
      vr_perpjcot NUMBER(5,2);
      vr_indeschq PLS_INTEGER;
      vr_indemiti PLS_INTEGER; -- Identificador de eh para considerar demitidos
      vr_indestit PLS_INTEGER; -- Identificador se deve calcular descontos sobre titulos

      rl_txdretor NUMBER(17,8);
      rl_txretdsc NUMBER(17,8);
      rl_txrettit NUMBER(17,8);

      -- Códigos de operação
      vr_cdoperac_taa    NUMBER;
      vr_cdoperac_deb    NUMBER;
      vr_cdoperac_mobibk NUMBER;

      rl_dsprvdef VARCHAR2(50);
      vr_dtliminf DATE;
      vr_dtlimsup DATE;
      vr_dtmvtolt DATE;
      vr_dtmvtaan DATE;
      vr_nom_direto VARCHAR2(500);       -- Diretorio da geracao dos arquivos
      vr_nom_direto_copia_043 VARCHAR2(500); -- Diretorio da geracao da copia do arquivo CRRL043.lst
      vr_nom_direto_copia_412 VARCHAR2(500); -- Diretorio da geracao da copia do arquivo CRRL412.lst
      vr_dsextcop VARCHAR2(3);
      vr_flgdemit INTEGER;
      vr_qtraimfx crapcot.qtraimfx%TYPE;
      vr_vlrendim NUMBER(17,2) :=0;
      vr_vlretdsc NUMBER(17,2) :=0;
      vr_vlbasdsc NUMBER(17,2) :=0;
      vr_vlrettit NUMBER(17,2) :=0;
      vr_vlbastit NUMBER(17,2) :=0;
      vr_vlbasret NUMBER(17,2) :=0;
      vr_vlbasapl NUMBER(17,2) :=0;
      vr_vldretor NUMBER(17,2) :=0;
      vr_vljurapl NUMBER(17,2) :=0;
      tt_vlretdep NUMBER(17,2) :=0;
      tt_vlretcrd NUMBER(17,2) :=0; 
      vr_vlbassdm NUMBER(17,2) :=0;
      vr_vlbastar NUMBER(17,2) :=0;
      vr_vljurtar NUMBER(17,2) :=0;
      vr_vlbasaut NUMBER(17)   :=0;
      vr_vljuraut NUMBER(17,2) :=0;
      vr_vlbasjur NUMBER(17,2) :=0;
      vr_vljurcap NUMBER(17,2) :=0;
      aux_vljurcap NUMBER(17,2) :=0;
      vr_vlmedcap NUMBER(17,2) :=0;
      vr_vldeirrf NUMBER(17,2) :=0;
      aux_vldeirrf NUMBER(17,2) :=0;
      vr_vlprirrf tbcotas_faixas_irrf.vlpercentual_irrf%type;
      vr_vljursdm NUMBER(17,2) :=0;
      vr_flgimune BOOLEAN;
      vr_vlcredit NUMBER(17,2) :=0;
      vr_vlcrecot NUMBER(17,2) :=0;
      vr_vlcrecta NUMBER(17,2) :=0;
      vr_vlcrecot_tmp NUMBER(17,2) :=0;
      vr_vlcrecta_tmp NUMBER(17,2) :=0;
      vr_vlcretot NUMBER(17,2) :=0;
      tt_vlbasapl NUMBER(17,2) :=0;
      tt_vljurapl NUMBER(17,2) :=0;
      tt_vlbassdm NUMBER(17,2) :=0;
      tt_vlmedcap NUMBER(17,2) :=0;
      tt_vljursdm NUMBER(17,2) :=0;
      tt_vljurcap NUMBER(17,2) :=0;
      tt_vldeirrf NUMBER(17,2) :=0;
      tt_vlbasret NUMBER(17,2) :=0;
      tt_vldretor NUMBER(17,2) :=0;
      tt_vlbasdsc NUMBER(17,2) :=0;
      tt_vlretdsc NUMBER(17,2) :=0;
      tt_vlbastit NUMBER(17,2) :=0;
      tt_vlrettit NUMBER(17,2) :=0;
      tt_vlbastar NUMBER(17,2) :=0;
      tt_vljurtar NUMBER(17,2) :=0;
      tt_vlbasaut NUMBER(17)   :=0;
      tt_vljuraut NUMBER(17,2) :=0;
      tt_qtassret NUMBER(17,2) :=0;
      tt_qtassdsc NUMBER(17,2) :=0;
      tt_qtassapl NUMBER(17,2) :=0;
      tt_qtasstit NUMBER(17,2) :=0;
      tt_qtasssdm NUMBER(17,2) :=0;
      tt_qtasscap NUMBER(17,2) :=0;
      tt_qtasstar NUMBER(17,2) :=0;
      tt_qtassaut NUMBER(17,2) :=0;
      tt_vlcredit NUMBER(17,2) :=0;
      tt_vlcrecot NUMBER(17,2) :=0;
      tt_vlcrecta NUMBER(17,2) :=0;
      tt_vlcretot NUMBER(17,2) :=0;
      tt_qtcredit NUMBER(17,2) :=0;
      tt_qtretcrd NUMBER(17,2) :=0;
      tt_qtretdep NUMBER(17,2) :=0;
      tt_qtcrecap NUMBER(17,2) :=0;
      tt_dstipcre VARCHAR2(50);
      tt_dsdemiti VARCHAR2(03); -- Data da demissao
      tt_indivdep VARCHAR2(03); -- Depositos consolidados
      
      vr_dsdestin VARCHAR2(500); -- Destinatarios do email quando for uma execucao previa

      -- Vetor para armazenar os dados para o relatorio CRRL412
      vr_tab_crrl412 typ_tab_crrl412;
      vr_indice_412  VARCHAR2(15);  -- agencia + conta

      -- Variaveis de retorno de erro
      vr_dsreturn  VARCHAR2(3);
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Variaveis para os relatórios
      vr_xml      CLOB;
      vr_txt      VARCHAR2(32767);
      vr_xml_tot  CLOB;
      vr_txt_tot  VARCHAR2(32767);      

      -- Variaveis utilizada no total do PA do relatorio
      vr_pac_qtassoci PLS_INTEGER  :=0;
      vr_pac_vlmedcap NUMBER(17,2) :=0;
      vr_pac_vlbascap NUMBER(17,2) :=0;
      vr_pac_vlretcap NUMBER(17,2) :=0;
      vr_pac_vlbasopc NUMBER(17,2) :=0;
      vr_pac_vlretopc NUMBER(17,2) :=0;
      vr_pac_vlbasapl NUMBER(17,2) :=0;
      vr_pac_vlretapl NUMBER(17,2) :=0;
      vr_pac_vlbassdm NUMBER(17,2) :=0;
      vr_pac_vlretsdm NUMBER(17,2) :=0;
      vr_pac_vldeirrf NUMBER(17,2) :=0;
      vr_pac_vlbastar NUMBER(17,2) :=0;
      vr_pac_vlrettar NUMBER(17,2) :=0;
      vr_pac_vlbasaut NUMBER(17)   :=0;
      vr_pac_vlretaut NUMBER(17,2) :=0;
      vr_pac_vlcredit NUMBER(17,2) :=0;
      vr_pac_vlcrecot NUMBER(17,2) :=0;
      vr_pac_vlcrecta NUMBER(17,2) :=0;
      vr_pac_vlcretot NUMBER(17,2) :=0;

      -- Variaveis utilizada no total geral do relatorio
      vr_tot_qtassoci PLS_INTEGER  :=0;
      vr_tot_vlmedcap NUMBER(17,2) :=0;
      vr_tot_vlbascap NUMBER(17,2) :=0;
      vr_tot_vlretcap NUMBER(17,2) :=0;
      vr_tot_vlbasopc NUMBER(17,2) :=0;
      vr_tot_vlretopc NUMBER(17,2) :=0;
      vr_tot_vlbasapl NUMBER(17,2) :=0;
      vr_tot_vlretapl NUMBER(17,2) :=0;
      vr_tot_vlbassdm NUMBER(17,2) :=0;
      vr_tot_vlretsdm NUMBER(17,2) :=0;
      vr_tot_vldeirrf NUMBER(17,2) :=0;
      vr_tot_vlbastar NUMBER(17,2) :=0;
      vr_tot_vlrettar NUMBER(17,2) :=0;
      vr_tot_vlbasaut NUMBER(17)   :=0;
      vr_tot_vlretaut NUMBER(17,2) :=0;
      vr_tot_vlcredit NUMBER(17,2) :=0;
      vr_tot_vlcrecot NUMBER(17,2) :=0;
      vr_tot_vlcrecta NUMBER(17,2) :=0;
      vr_tot_vlcretot NUMBER(17,2) :=0;

      -- variaveis utilizadas no relatorio
      vr_rel_dsagenci VARCHAR2(100);

      vr_incrineg      INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;

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

      -- Valor da moeda
      CURSOR cr_crapmfx(pr_dtmvtolt crapmfx.dtmvtolt%TYPE) IS
        SELECT vlmoefix
          FROM crapmfx
         WHERE crapmfx.cdcooper = pr_cdcooper
           AND crapmfx.dtmvtolt = pr_dtmvtolt
           AND crapmfx.tpmoefix = 2;
      rw_crapmfx cr_crapmfx%ROWTYPE;

      -- Configuracao calculo
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT /*+index_asc (tab CRAPTAB##CRAPTAB1)*/
               tab.dstextab
          from craptab tab
         where tab.cdcooper = pr_cdcooper
           and upper(tab.nmsistem) = pr_nmsistem
           and upper(tab.tptabela) = pr_tptabela
           and tab.cdempres        = pr_cdempres
           and upper(tab.cdacesso) = pr_cdacesso
           and tab.tpregist        = pr_tpregist
         FOR UPDATE NOWAIT;

      -- Cursor e pltable para carga dos dados do associados
      CURSOR cr_crapass_carga(pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT nrdconta
              ,inpessoa
              ,dtelimin
              ,cdagenci
              ,substr(nmprimtl,1,22) nmprimtl
			        ,nrcpfcgc
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND EXISTS(SELECT 1 
                        FROM crapsld 
                       WHERE crapass.cdcooper = crapsld.cdcooper
                         AND crapass.nrdconta = crapsld.nrdconta);
      TYPE typ_tab_crapass 
        IS TABLE OF cr_crapass_carga%ROWTYPE 
          INDEX BY PLS_INTEGER;
      vr_tab_crapass typ_tab_crapass;    

      -- Cursor com informacoes referentes a cotas e recursos
      CURSOR cr_crapcot(pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT crapcot.cdcooper
              ,crapcot.nrdconta
              ,crapcot.qtraimfx
              ,crapcot.vldcotas
              ,crapcot.vlrearda
              ,crapcot.vlrearpp
              ,crapcot.vlpvardc
              ,crapcot.ROWID nrrowid
              ,crapdir.smposano##1 + crapdir.smposano##2 + crapdir.smposano##3 + crapdir.smposano##4 +  crapdir.smposano##5 +  crapdir.smposano##6 +
               crapdir.smposano##7 + crapdir.smposano##8 + crapdir.smposano##9 + crapdir.smposano##10 + crapdir.smposano##11 + crapdir.smposano##12 smposano
              ,crapdir.vlcapmes##1 + crapdir.vlcapmes##2 + crapdir.vlcapmes##3 + crapdir.vlcapmes##4 +  crapdir.vlcapmes##5 +  crapdir.vlcapmes##6 +
               crapdir.vlcapmes##7 + crapdir.vlcapmes##8 + crapdir.vlcapmes##9 + crapdir.vlcapmes##10 + crapdir.vlcapmes##11 + crapdir.vlcapmes##12 vlcapmes
              ,crapdir.dtdemiss
              ,crapdir.smposano##12
              ,crapdir.vlcapmes##12
              ,crapdir.vlrenrda##12
              ,crapdir.vlrenrpp_ir##12
          FROM crapcot
              ,crapdir 
         WHERE crapcot.cdcooper = pr_cdcooper
           AND crapdir.dtmvtolt = pr_dtmvtolt
           AND crapcot.cdcooper = crapdir.cdcooper
           AND crapcot.nrdconta = crapdir.nrdconta;
           
      -- Cursor com informacoes referentes a cotas e recursos
      CURSOR cr_crapcot2 IS
        SELECT crapcot.cdcooper
              ,crapcot.nrdconta
              ,crapcot.qtraimfx
              ,crapcot.vldcotas
              ,crapcot.vlrearda
              ,crapcot.vlrearpp
              ,crapcot.vlpvardc
              ,crapcot.ROWID nrrowid
              ,0 smposano
              ,crapcot.vlcapmes##1 + crapcot.vlcapmes##2 + crapcot.vlcapmes##3 + crapcot.vlcapmes##4 +  crapcot.vlcapmes##5 +  crapcot.vlcapmes##6 +
               crapcot.vlcapmes##7 + crapcot.vlcapmes##8 + crapcot.vlcapmes##9 + crapcot.vlcapmes##10 + crapcot.vlcapmes##11 + crapcot.vldcotas vlcapmes
              ,crapass.dtdemiss dtdemiss 
              ,0 smposano##12
              ,crapcot.vldcotas vlcapmes##12
              ,crapcot.vlrenrda##12
              ,crapcot.vlrenrpp_ir##12
          FROM crapcot,
               crapass
         WHERE crapcot.cdcooper = pr_cdcooper
           AND crapcot.cdcooper = crapass.cdcooper
           AND crapcot.nrdconta = crapass.nrdconta;
           
      /* Armazenar em PLTABLE com Bulk */     
      TYPE typ_tab_crapcot IS 
        TABLE OF cr_crapcot%ROWTYPE
          INDEX BY PLS_INTEGER;
      vr_tab_crapcot typ_tab_crapcot;
      
      -- Cursor para buscar faixa de IRRF a ser cobrada
      CURSOR cr_fairrf IS
      SELECT fairrf.inpessoa
            ,fairrf.vlfaixa_inicial
            ,fairrf.vlfaixa_final
            ,fairrf.vlpercentual_irrf
            ,fairrf.vldeducao
        FROM tbcotas_faixas_irrf fairrf
       ORDER BY fairrf.inpessoa
               ,fairrf.vlfaixa_inicial;
      -- Estruturas para armazenagem dos valores pagos em tarifas PF e PJ
      TYPE vr_reg_fairrf IS RECORD (vlfxinici NUMBER
                                   ,vlfxfinal NUMBER
                                   ,vlpercent NUMBER
                                   ,vldeducao NUMBER);
      TYPE vr_typ_fairrf IS TABLE OF vr_reg_fairrf INDEX BY PLS_INTEGER;
      vr_tab_fairrf_pf vr_typ_fairrf;
      vr_tab_fairrf_pj vr_typ_fairrf;
      vr_idx_faiirrf   PLS_INTEGER;
      
      -- Cursor com informações das tarifas pagas      
      CURSOR cr_tbcotas_tarifas_pagas IS
      SELECT nrdconta 
            ,GREATEST(ctp.vlpagoanoant,0) vlbastar -- GREATEST(x,0) para trazer 0 quando for valor negativo
        FROM tbcotas_tarifas_pagas ctp
       WHERE ctp.cdcooper = pr_cdcooper;
      -- Estrutura para armazenagem dos valores pagos em tarifas
      TYPE vr_typ_tarifa IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      vr_tab_tarifa vr_typ_tarifa;

      -- BUsca da quantidade de operações de auto atendimento do cooperador
      CURSOR cr_qtd_autoatendi(pr_dtrefere_ini DATE
                              ,pr_dtrefere_fim DATE) IS
        SELECT opd.nrdconta
              ,nvl(sum(opd.nrsequen),0) nrsequen
          FROM tbcc_operacoes_diarias opd
         WHERE opd.cdcooper = pr_cdcooper
           AND opd.dtoperacao > pr_dtrefere_ini
           AND opd.dtoperacao < pr_dtrefere_fim
           AND opd.cdoperacao IN(vr_cdoperac_taa,vr_cdoperac_deb,vr_cdoperac_mobibk)
         GROUP BY opd.nrdconta;
      -- Estrutura para armazenagem das quantidades de operacores autoatendimento
      TYPE vr_typ_autoate IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
      vr_tab_autoate vr_typ_autoate;

      -- cursor de lancamento de juros de desconto de cheques
      CURSOR cr_crapljd_carga(pr_dtrefere_ini DATE
                             ,pr_dtrefere_fim DATE) IS
        SELECT crapljd.nrdconta
              ,nvl(SUM(vldjuros),0) vldjuros
          FROM crapljd
         WHERE crapljd.cdcooper = pr_cdcooper
           AND crapljd.dtrefere > pr_dtrefere_ini
           AND crapljd.dtrefere < pr_dtrefere_fim
         GROUP BY crapljd.nrdconta;
      -- Estrutura para armazenagem dos valores de juros sobre desconto cheques
      TYPE vr_typ_cheques IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      vr_tab_cheques vr_typ_cheques;

      -- Cursor sobre o lancamento de juros de desconto de titulos
      CURSOR cr_crapljt_carga(pr_dtrefere_ini DATE
                             ,pr_dtrefere_fim DATE) IS
        SELECT crapljt.nrdconta
              ,nvl(SUM(vldjuros),0) vldjuros
          FROM crapljt
          WHERE crapljt.cdcooper = pr_cdcooper
            AND crapljt.dtrefere > pr_dtrefere_ini
           AND crapljt.dtrefere < pr_dtrefere_fim
         GROUP BY crapljt.nrdconta;
      -- Estrutura para armazenagem dos valores de juros sobre desconto titulos
      TYPE vr_typ_titulos IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      vr_tab_titulos vr_typ_titulos;

      -- Cursor sobre a tabela de lotes
      CURSOR cr_craplot(pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_cdbccxlt craplot.cdbccxlt%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT vlinfocr
              ,vlcompcr
              ,vlinfodb
              ,vlcompdb
              ,qtinfoln
              ,qtcompln
              ,nrseqdig
          FROM craplot
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      -- Cursor de agencia
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT gene0007.fn_caract_acento(nmresage) nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;

      -- Cursor de contas migradas
      CURSOR cr_craptco IS
        SELECT nrdconta -- Conta nova na cooperativa migrada.
          FROM craptco
         WHERE cdcooper = 9   --Transpocred
           and cdcopant = 17; --Transulcred
      rw_craptco cr_craptco%ROWTYPE;
      
      /* Estrutura para armazenagem de contas que nao devem receber retorno de sobras 
         e nem juros sobre o capital - Incorporacao Transulcred -> Transpocred */
      TYPE vr_typ_cta_proibidas IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      vr_tab_cta_proibidas vr_typ_cta_proibidas;
      --
      CURSOR cr_crapass (prc_cdcooper IN crapass.cdcooper%TYPE
                        ,prc_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdsitdct
          FROM crapass ass
         WHERE ass.cdcooper = prc_cdcooper
           AND ass.nrdconta = prc_nrdconta;
      -- Vetor para armazenar os dados para o processo definitivo
      vr_tab_crrl048 typ_tab_crrl048;
      vr_indice      PLS_INTEGER := 0;      
      vr_cdsitdct       crapass.cdsitdct%TYPE;      
      
      /* escrita no log centralizada */
      PROCEDURE pc_controle_critica IS
      BEGIN
        vr_dscritic := nvl(vr_dscritic,gene0001.fn_busca_critica(vr_cdcritic));
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END;

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_destino   IN INTEGER
                              ,pr_des_dados IN VARCHAR2
                              ,pr_flg_fecha IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        IF pr_destino = 1 THEN
          gene0002.pc_escreve_xml(pr_xml => vr_xml
                                 ,pr_texto_completo => vr_txt
                                 ,pr_texto_novo => pr_des_dados
                                 ,pr_fecha_xml => pr_flg_fecha);
          ELSE
          gene0002.pc_escreve_xml(pr_xml => vr_xml_tot
                                 ,pr_texto_completo => vr_txt_tot
                                 ,pr_texto_novo => pr_des_dados
                                 ,pr_fecha_xml => pr_flg_fecha);
          END IF;
      END pc_escreve_xml;

      /* Distribuir as cotas em Conta Capital e/ou CC conforme parametrização */
      PROCEDURE pc_distribui_cotas_cc(pr_vlretorn NUMBER
                                     ,pr_inpessoa NUMBER
                                     ,pr_vlretcot OUT NUMBER
                                     ,pr_vlretcta OUT NUMBER) IS
      BEGIN
        -- Verificar fracionamento das sobras para Cota e/ou C/C
        IF pr_inpessoa = 1 THEN                  
          -- Percentual PF
          pr_vlretcot := round(pr_vlretorn * vr_perpfcot,2);
          ELSE
          -- Percentual PJ
          pr_vlretcot := round(pr_vlretorn * vr_perpjcot,2);                   
          END IF;
        -- O restante (sobra do que será lançado em Cota) vai para C/C
        pr_vlretcta := pr_vlretorn - pr_vlretcot;
      END;         

      /* Busca da faixa e calculo do IR a pagar */
      PROCEDURE pc_calcula_irrf(pr_inpessoa IN crapass.inpessoa%TYPE
                               ,pr_vljurcap IN NUMBER
                               ,pr_vldeirrf OUT NUMBER
                               ,pr_vlprirrf OUT NUMBER) IS
        vr_regist vr_reg_fairrf;
        vr_existe BOOLEAN := FALSE;
      BEGIN
        -- Inicializar retorno
        pr_vldeirrf := 0;
        pr_vlprirrf := 0;
        -- Efetuar laço sob as pltables com faixa de IR conforme tipo de pessoa
        IF pr_inpessoa = 1 THEN
          -- Se existirem faixas cadastradas
          IF vr_tab_fairrf_pf.count() > 1 THEN
            -- Buscar na tab de faixas para PF
            FOR idx IN 1..vr_tab_fairrf_pf.count LOOP
              -- Se o valor se enquadra na faixa
              IF pr_vljurcap BETWEEN vr_tab_fairrf_pf(idx).vlfxinici AND vr_tab_fairrf_pf(idx).vlfxfinal THEN
                -- Copiar o registro atual
                vr_regist := vr_tab_fairrf_pf(idx);
                vr_existe := TRUE;
                -- Sair do loop
                EXIT;
        END IF;
            END LOOP;
          ELSE
            -- Se não há faixas não haverá aplicação de IR
            RETURN;
            END IF;
          ELSE
          -- Se existirem faixas cadastradas
          IF vr_tab_fairrf_pj.count() > 1 THEN
            -- Buscar na tab de faixas para PJ
            FOR idx IN 1..vr_tab_fairrf_pj.count LOOP
              -- Se o valor se enquadra na faixa
              IF pr_vljurcap BETWEEN vr_tab_fairrf_pj(idx).vlfxinici AND vr_tab_fairrf_pj(idx).vlfxfinal THEN
                -- Copiar o registro atual
                vr_regist := vr_tab_fairrf_pj(idx);
                vr_existe := TRUE;                
                -- Sair do loop
                EXIT;
            END IF;
            END LOOP;          
            ELSE
            -- Se não há faixas não haverá aplicação de IR
            RETURN;
            END IF;
          END IF;
        -- Se chegamos neste ponto existe faixa cadastrada para o tipo de pessoa solicitada
        -- Mas se não encontramos nenhuma faixa em que o valor se enquadra, devemos gerar erro
        IF NOT vr_existe THEN
          -- Usaremos o valor -1 para gerar erro
          pr_vldeirrf := -1;
          pr_vlprirrf := 0;
        ELSE
          -- Efetuaremos o calculo 
          pr_vldeirrf := GREATEST(TRUNC((pr_vljurcap * (vr_regist.vlpercent/100)) - vr_regist.vldeducao, 2),0);
          pr_vlprirrf := vr_regist.vlpercent;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_vldeirrf := -1;  -- Rotinas chamadoras tratarão -1 como retorno com erro
          pr_vlprirrf := 0;
      END;                  

      --busca e soma os valores dos lancamentos com historico especifico na CRAPLCT
      PROCEDURE pc_busca_soma_hist(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                  ,pr_nrdconta IN  crapass.nrdconta%TYPE
                                  ,pr_cdhistor IN  craphis.cdhistor%TYPE
                                  ,pr_vlrtotal OUT NUMBER
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS      
      
        vr_exc_erro EXCEPTION;
      
        CURSOR cr_craphis(pr_cdcooper craphis.cdcooper%TYPE
                         ,pr_cdhistor craphis.cdhistor%TYPE) IS
          SELECT *
            FROM craphis
           WHERE craphis.cdcooper = pr_cdcooper
             AND craphis.cdhistor = pr_cdhistor;
        rw_craphis cr_craphis%ROWTYPE;
             
        CURSOR cr_lanlct(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE
                         ,pr_cdhistor craphis.cdhistor%TYPE
                         ,pr_dtiniper crapdat.dtmvtolt%TYPE
                         ,pr_dtfimper crapdat.dtmvtolt%TYPE) IS
          SELECT NVL(SUM(craplct.vllanmto),0) vlrtotal
            FROM craplct
           WHERE craplct.cdcooper = pr_cdcooper
             AND craplct.nrdconta = pr_nrdconta
             AND craplct.cdhistor = pr_cdhistor
             AND craplct.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper;
        rw_lanlct cr_lanlct%ROWTYPE;     
        
        CURSOR cr_perdat(pr_cdcooper crapcop.cdcooper%TYPE) IS
          SELECT crapdat.dtmvtolt
            FROM crapdat
           WHERE crapdat.cdcooper = pr_cdcooper;
        rw_perdat cr_perdat%ROWTYPE;
        
      BEGIN
        pr_vlrtotal := 0;  
      
        OPEN cr_perdat(pr_cdcooper => pr_cdcooper);
        FETCH cr_perdat INTO rw_perdat;

        IF cr_perdat%NOTFOUND THEN
           CLOSE cr_perdat;
           pr_cdcritic := 0;
           pr_dscritic := 'Data da cooperativa nao encontrada.';
           RAISE vr_exc_erro;
        END IF;
        
        CLOSE cr_perdat;        
      
        OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                       ,pr_cdhistor => pr_cdhistor);
        FETCH cr_craphis INTO rw_craphis;
        
        IF cr_craphis%NOTFOUND THEN
           CLOSE cr_craphis;
           pr_cdcritic := 0;
           pr_dscritic := 'Historico nao encontrado.';
           RAISE vr_exc_erro;
        END IF;
        
        CLOSE cr_craphis;
        
        OPEN cr_lanlct(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_cdhistor => pr_cdhistor
                      ,pr_dtiniper => TO_DATE('0101'||TO_CHAR(rw_perdat.dtmvtolt,'RRRR'),'DDMMRRRR')   --Primeiro dia do ano
                      ,pr_dtfimper => TO_DATE('3112'||TO_CHAR(rw_perdat.dtmvtolt,'RRRR'),'DDMMRRRR')); --Ultimo dia do ano
        FETCH cr_lanlct INTO rw_lanlct;

        IF cr_lanlct%NOTFOUND THEN
           CLOSE cr_lanlct;
           pr_cdcritic := 0;
           pr_dscritic := 'Lancamentos nao encontrados.';
           RAISE vr_exc_erro;
        END IF;
        
        CLOSE cr_lanlct;
        
        
        pr_vlrtotal := rw_lanlct.vlrtotal;        
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina pc_busca_soma_hist, detalhes: '||SQLERRM;
          ROLLBACK;
      END pc_busca_soma_hist;      

      /* Procedure responsavel por lancar debito na conta corrente ou conta capital dos cooperados eliminados */
      PROCEDURE pc_efetua_lcto_coop_elimin(pr_cdcooper    IN tbcotas_devolucao.cdcooper%TYPE
                                          ,pr_nrdconta    IN tbcotas_devolucao.nrdconta%TYPE
                                          ,pr_inpessoa    IN crapass.inpessoa%TYPE
                                          ,pr_tpdevolucao IN tbcotas_devolucao.tpdevolucao%TYPE 
                                          ,pr_vlcapital   IN tbcotas_devolucao.vlcapital%TYPE
                                          ,pr_nrseqdig    IN craplot.nrseqdig%TYPE
                                          ,pr_cdcritic    OUT crapcri.cdcritic%TYPE
                                          ,pr_dscritic    OUT VARCHAR2) IS
          vr_cdhistor craphis.cdhistor%TYPE;
          vr_nrdocmto craplcm.nrdocmto%TYPE;
          vr_nrdocaux varchar2(10);
        BEGIN
          /* pr_tpdevolucao = [3 - Capital] [4 - Deposito a Vista] */
          IF pr_tpdevolucao = 3 /* Capital */ THEN
            vr_cdhistor := CASE WHEN pr_inpessoa = 1 THEN vr_cdhiscot_dem_pf ELSE vr_cdhiscot_dem_pj END;
            vr_nrdocaux := lpad(pr_nrseqdig,10,'0');
            vr_nrdocmto := '8005'||lpad(substr(vr_nrdocaux,length(vr_nrdocaux)-4,length(vr_nrdocaux)),5,'0'); --Em tela existe o limite de 9 caracteres
            BEGIN
              INSERT INTO craplct
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdconta,
                 nrdocmto,
                 cdhistor,
                 vllanmto,
                 nrseqdig,
                 cdcooper)
               VALUES
                (vr_dtmvtolt,
                 vr_cdagenci,
                 vr_cdbccxlt,
                 vr_nrdolote,
                 pr_nrdconta,
                 vr_nrdocmto,
                 vr_cdhistor,
                 pr_vlcapital,
                 pr_nrseqdig,
                 pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro insert da CRAPLCT: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          ELSIF pr_tpdevolucao = 4 /* Deposito a Vista */ THEN
            vr_cdhistor := CASE WHEN pr_inpessoa = 1 THEN vr_cdhiscta_dem_pf ELSE vr_cdhiscta_dem_pj END;
            vr_nrdocaux := lpad(pr_nrseqdig,10,'0');
            vr_nrdocmto := '8005'||lpad(substr(vr_nrdocaux,length(vr_nrdocaux)-4,length(vr_nrdocaux)),5,'0'); --Em tela existe o limite de 9 caracteres
            BEGIN

               LANC0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote                         
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdctabb => pr_nrdconta
                         ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta,'99999999')
                         ,pr_nrdocmto => vr_nrdocmto
                         ,pr_cdhistor => vr_cdhistor
                         ,pr_vllanmto => pr_vlcapital                         
                         ,pr_nrseqdig => rw_craplot.nrseqdig
                         ,pr_cdcooper => pr_cdcooper 
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

               IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
               END IF; 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro no insert da CRAPLCM: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
           ELSE
             vr_dscritic := 'Tipo de devolucao de cotas invalido. Valores possiveis (3,4) recebido '|| cast(pr_tpdevolucao as varchar)||'.';
             RAISE vr_exc_saida;
           END IF;
          
        EXCEPTION
         WHEN vr_exc_saida THEN
             IF vr_dscritic IS NULL THEN
                vr_dscritic := 'Erro ao inserir debito ref. a cooperado eliminado para a conta ( '||pr_nrdconta||' ). '||SQLERRM;
             END IF;
             pr_cdcritic := vr_cdcritic;
             pr_dscritic := vr_dscritic;
         WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao inserir debito ref. a cooperado eliminado para a conta ( '||pr_nrdconta||' ). '||SQLERRM;
        END pc_efetua_lcto_coop_elimin;
        
      PROCEDURE atualiza_tbcotas(pr_cdcooper    IN tbcotas_devolucao.cdcooper%TYPE
                                ,pr_nrdconta    IN tbcotas_devolucao.nrdconta%TYPE
                                ,pr_inpessoa    IN crapass.inpessoa%TYPE
                                ,pr_tpdevolucao IN tbcotas_devolucao.tpdevolucao%TYPE 
                                ,pr_vlcapital   IN tbcotas_devolucao.vlcapital%TYPE
                                ,pr_nrseqdig    IN craplot.nrseqdig%TYPE
                                ,pr_cdcritic    OUT crapcri.cdcritic%TYPE
                                ,pr_dscritic    OUT VARCHAR2) IS
        BEGIN
           pr_cdcritic := null;
           pr_dscritic := null;
           
           pc_efetua_lcto_coop_elimin(pr_cdcooper    => pr_cdcooper
                                     ,pr_nrdconta    => pr_nrdconta
                                     ,pr_inpessoa    => pr_inpessoa
                                     ,pr_tpdevolucao => pr_tpdevolucao
                                     ,pr_vlcapital   => pr_vlcapital
                                     ,pr_nrseqdig    => pr_nrseqdig
                                     ,pr_cdcritic    => pr_cdcritic
                                     ,pr_dscritic    => pr_dscritic);
          IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

           UPDATE tbcotas_devolucao
              SET vlcapital   = vlcapital + nvl(pr_vlcapital,0)
            WHERE cdcooper    = pr_cdcooper
              AND nrdconta    = pr_nrdconta
              AND tpdevolucao = pr_tpdevolucao; -- 3 CAPITAL e 4 DEPOSITO
           IF SQL%ROWCOUNT = 0 THEN
             INSERT INTO tbcotas_devolucao (cdcooper,
                                            nrdconta, 
                                            tpdevolucao,
                                            vlcapital)
                                    VALUES (pr_cdcooper
                                           ,pr_nrdconta
                                           ,pr_tpdevolucao -- 3 CAPITAL e 4 DEPOSITO
                                           ,nvl(pr_vlcapital,0)); 
           END IF;
        EXCEPTION
          WHEN vr_exc_saida THEN
             IF pr_dscritic IS NULL THEN
               pr_dscritic := 'Erro ao inserir devolucao de cotas para cooperado eliminado ( '||pr_nrdconta||' ). '||SQLERRM;
             END IF;
          WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao inserir na tabela tbcotas_devolucao para a conta ( '||pr_nrdconta||' ). '||SQLERRM;
        END atualiza_tbcotas;
        
    BEGIN -- Rotina principal

      -- Coloca como programa logado o programa chamador. Isso se faz necessario para a impressao do relatorio
      vr_cdprogra := pr_cdprogra;

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
        -- Guardar dia atual
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
        
        -- Verifica se eh o ultimo dia util
        IF vr_dtmvtolt = gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                     pr_dtmvtolt => TO_DATE('31/12'||TO_CHAR(vr_dtmvtolt,'RRRR'),'DD/MM/RRRR'), 
                                                     pr_tipo     => 'A',
                                                     pr_feriado   => true,
                                                     pr_excultdia => true) THEN
          -- Busca o ultimo dia util do ano anterior
          vr_dtmvtaan := vr_dtmvtolt;
          -- Montagem das datas para busca das informações
          vr_dtliminf := to_date('3112'||(to_char(vr_dtmvtolt,'YYYY')-1),'DDMMYYYY'); -- Busca o ultimo dia do ano de dois anos atras
          vr_dtlimsup := TO_DATE('0101'||(TO_CHAR(vr_dtmvtolt,'YYYY')+1),'DDMMYYYY'); -- Pega o primeiro dia do ano
          vr_flultdia := TRUE;
                                                     
        ELSE
          -- Busca o ultimo dia util do ano anterior
          vr_dtmvtaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                     pr_dtmvtolt => trunc(vr_dtmvtolt,'YYYY') - 1, -- busca a data de 31/12 do ano anterior
                                                     pr_tipo     => 'A',
                                                     pr_feriado   => true,
                                                     pr_excultdia => true); -- Dia anterior
          -- Montagem das datas para busca das informações
          vr_dtliminf := to_date('3112'||(to_char(vr_dtmvtolt,'YYYY')-2),'DDMMYYYY'); -- Busca o ultimo dia do ano de dois anos atras
          vr_dtlimsup := trunc(vr_dtmvtolt,'YYYY'); -- Pega o primeiro dia do ano
          vr_flultdia := FALSE;   
        END IF;
        
        -- Ano base do cálculo
        vr_anocalcu := extract(year from vr_dtmvtaan);

      END IF;

      /*  Carrega tabela de execucao do programa lockando o registro para evitar execuções paralelas */
      BEGIN 
        OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXEICMIRET'
                                               ,pr_tpregist => 1);
        FETCH cr_craptab
         INTO vr_dstextab;
        -- Se não encontrar      
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 283;
        RAISE vr_exc_saida;
      END IF;
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Propagar erro
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          -- propagar erro
          vr_dscritic := 'Tabela de execucao Lockada por outro processo! ';  
          RAISE vr_exc_saida;
      END;

      -- Busca os valores de acordo com a tabela de execucao do programa
      vr_inprvdef := SUBSTR(vr_dstextab,18,01);
      vr_increret := SUBSTR(vr_dstextab,03,01);
      
      vr_txdretor := SUBSTR(vr_dstextab,05,12) / 100;
      vr_txjurcap := SUBSTR(vr_dstextab,20,13) / 100;
      vr_txjurapl := SUBSTR(vr_dstextab,33,12) / 100;
      vr_txjursdm := SUBSTR(vr_dstextab,54,12) / 100;
      vr_txjurtar := SUBSTR(vr_dstextab,78,12) / 100;
      vr_txjuraut := SUBSTR(vr_dstextab,91,12) / 100;
      
      vr_perpfcot := SUBSTR(vr_dstextab,104,6) / 100;
      vr_perpjcot := SUBSTR(vr_dstextab,111,6) / 100;
      
      vr_indivdep := SUBSTR(vr_dstextab,118,1);
      
      vr_indeschq := SUBSTR(vr_dstextab,46,01);
      vr_indemiti := SUBSTR(vr_dstextab,50,01);
      vr_indestit := SUBSTR(vr_dstextab,52,01);

      rl_txdretor := SUBSTR(vr_dstextab,05,12);
      rl_txretdsc := SUBSTR(vr_dstextab,05,12);
      rl_txrettit := SUBSTR(vr_dstextab,05,12);

      -- Textos para relatorio
      IF vr_indemiti = 0 THEN 
        tt_dsdemiti := 'NAO';
      ELSE
        tt_dsdemiti := 'SIM';
      END IF;
      
      IF vr_indivdep = 0 THEN
        tt_indivdep := 'NAO';
      ELSE
        tt_indivdep := 'SIM';
      END IF;
      
      
      /* Controle de carga da pltable de cheques */
      -- Efetua loop na tabela e carrega pltable
      FOR rw_ljd IN cr_crapljd_carga(vr_dtliminf,vr_dtlimsup) LOOP
        vr_tab_cheques(rw_ljd.nrdconta) := rw_ljd.vldjuros;
      END LOOP;

      /* Controle de carga da pltable de titulos */
      -- Efetua loop na tabela e carrega pltable
      FOR rw_ljt IN cr_crapljt_carga(vr_dtliminf,vr_dtlimsup) LOOP
        vr_tab_titulos(rw_ljt.nrdconta) := rw_ljt.vldjuros;
      END LOOP;

      /* Controle de carga da pltable de tarifas pagas */
      IF vr_txjurtar > 0 THEN
        -- Efetua loop na tabela e carrega pltable
        FOR rw_tar IN cr_tbcotas_tarifas_pagas LOOP
          vr_tab_tarifa(rw_tar.nrdconta) := rw_tar.vlbastar;
        END LOOP;
      END IF;

      -- Busca do código das operações diarias de DEBAUT, PAGTO TAA e PAGTO Mobile e IBank
      vr_cdoperac_taa    := gene0001.fn_param_sistema('CRED',0,'CDOPERAC_PAGTO_TAA');
      vr_cdoperac_deb    := gene0001.fn_param_sistema('CRED',0,'CDOPERAC_PAGTO_DEBAUT');
      vr_cdoperac_mobibk := gene0001.fn_param_sistema('CRED',0,'CDOPERAC_PAGTO_MOBIBK');      

      /* Controle de carga da pltable de auto-atendimento */
      -- Efetua loop na tabela e carrega pltable
      FOR rw_aut IN cr_qtd_autoatendi(vr_dtliminf,vr_dtlimsup) LOOP
        vr_tab_autoate(rw_aut.nrdconta) := rw_aut.nrsequen;
      END LOOP;
      
      /* Carregar pltable das contas que NAO devem ter retorno de sobras e juros sobre o capital.
         Pode ser carregado sempre que houver necessidade de ignorar algumas contas. */
      vr_tab_cta_proibidas.delete;      
      /* Incorporacao Transulcred -> Transpocred e ano referencia = 2016 */
      IF (pr_cdcooper = 9) and (extract(year from vr_dtmvtaan) = 2016) THEN
        FOR rw_craptco IN cr_craptco LOOP
          vr_tab_cta_proibidas(rw_craptco.nrdconta) := rw_craptco.nrdconta;
        END LOOP;
      END IF;
      
      -- Se haverá calculo de Juros sobre capital
      IF vr_txjurcap > 0 THEN
        -- Cursor para buscar faixa de IRRF a ser cobrada
        FOR rw_ir IN cr_fairrf LOOP
          -- Gravar pltable conforme tipo de pessoa
          IF rw_ir.inpessoa = 1 THEN
            vr_idx_faiirrf := vr_tab_fairrf_pf.count+1;
            vr_tab_fairrf_pf(vr_idx_faiirrf).vlfxinici := rw_ir.vlfaixa_inicial;
            vr_tab_fairrf_pf(vr_idx_faiirrf).vlfxfinal := rw_ir.vlfaixa_final;
            vr_tab_fairrf_pf(vr_idx_faiirrf).vlpercent := rw_ir.vlpercentual_irrf;
            vr_tab_fairrf_pf(vr_idx_faiirrf).vldeducao := rw_ir.vldeducao;
          ELSE
            vr_idx_faiirrf := vr_tab_fairrf_pj.count+1;
            vr_tab_fairrf_pj(vr_idx_faiirrf).vlfxinici := rw_ir.vlfaixa_inicial;
            vr_tab_fairrf_pj(vr_idx_faiirrf).vlfxfinal := rw_ir.vlfaixa_final;
            vr_tab_fairrf_pj(vr_idx_faiirrf).vlpercent := rw_ir.vlpercentual_irrf;
            vr_tab_fairrf_pj(vr_idx_faiirrf).vldeducao := rw_ir.vldeducao;            
          END IF;
        END LOOP;
      END IF;
      
      -- Descricoes e copias conforme tipo de processo
      IF vr_inprvdef = 0 THEN
        rl_dsprvdef := '**** PROCESSO PREVIO ****';
        -- Busca do diretorio base da cooperativa
        vr_nom_direto_copia_043 := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                        ,pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsubdir => 'rlnsv'); --> Utilizaremos o contab

        -- Buscar o parametro com os endereços de e-mail para envio
        vr_dsdestin := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'CRRL043_EMAIL');
        
        -- Busca do diretorio base da cooperativa
        vr_nom_direto_copia_412 := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /usr/coop
                                                    ,pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsubdir => 'contab'); --> Utilizaremos o contab
        vr_dsextcop := 'txt';
        
      ELSE
        rl_dsprvdef := '** PROCESSO DEFINITIVO **';
        vr_nom_direto_copia_043 := NULL;
        vr_dsdestin             := NULL;
        vr_nom_direto_copia_412 := NULL;
        vr_dsextcop             := NULL;
      END IF;

      -- Busca do diretorio base da cooperativa para os relatorios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl'); --> Utilizaremos o contab

      -- Sair se não foi selecionado o processo completo
      IF vr_txdretor = 0 AND vr_increret = 1 THEN
        vr_cdcritic := 0;
        RAISE vr_exc_fimprg;
      END IF;

      --  Carrega valor da moeda fixa do dia
      OPEN cr_crapmfx(vr_dtmvtolt);
      FETCH cr_crapmfx INTO rw_crapmfx;
      IF cr_crapmfx%NOTFOUND THEN
        CLOSE cr_crapmfx;
        vr_cdcritic := 140;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' UFIR';
        pc_controle_critica;
        RAISE vr_exc_saida;
      END IF;

      -- Efetuar carga de pltable com as informações dos associados
      FOR rw_crapass_carga IN cr_crapass_carga(vr_dtmvtaan) LOOP
        vr_tab_crapass(rw_crapass_carga.nrdconta) := rw_crapass_carga;
      END LOOP;

      IF vr_flultdia = TRUE THEN
        OPEN cr_crapcot2;
      ELSE        
        -- Varredura das informações de Cotas dos Cooperados
        OPEN cr_crapcot(vr_dtmvtaan);
      END IF;
      
      LOOP 
        IF vr_flultdia = TRUE THEN
          FETCH cr_crapcot2 BULK COLLECT INTO vr_tab_crapcot LIMIT 2000; 
        ELSE 
          FETCH cr_crapcot BULK COLLECT INTO vr_tab_crapcot LIMIT 2000; 
        END IF;
        
        EXIT WHEN vr_tab_crapcot.count = 0;
        -- Leitura da porção lida em memória
        FOR idx IN 1 .. vr_tab_crapcot.COUNT LOOP  

          -- Verificar se a conta está na lista de contas proibidas
          IF vr_tab_cta_proibidas.exists(vr_tab_crapcot(idx).nrdconta) THEN
            CONTINUE;
          END IF;
          
          -- Garantir que haja o associado
          IF NOT vr_tab_crapass.exists(vr_tab_crapcot(idx).nrdconta) THEN
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' CONTA = '||vr_tab_crapcot(idx).nrdconta;
            pc_controle_critica;
            RAISE vr_exc_saida;
          END IF;

          /* 
           Alimenta a variavel 'vr_flgdemit' com [0 - NAO] [1 - SIM] indicando se deve considerar
           essa conta no credito de juros / retorno de sobras.
           
           A regra aqui eh o seguinte: Vamos considerar a conta caso:
           1 - Estiver marcado em interface para considerar demitidos; ou
           2 - Cooperado nao demitido ou demitido no ano de calculo
          */
          IF( /* Regra 1 */ 
             (vr_indemiti = 1) OR -- Flag 'Considera demitidos' da interface;
             
             (/* Regra 2 */
              vr_indemiti = 0 AND 
             (vr_tab_crapcot(idx).dtdemiss IS NULL OR to_char(vr_tab_crapcot(idx).dtdemiss,'YYYY') >= vr_anocalcu))
             
             )THEN
            vr_flgdemit := 1;
          ELSE
            vr_flgdemit := 0;
          END IF;

          -- Busca base de titulos e cheques
          IF vr_tab_titulos.exists(vr_tab_crapcot(idx).nrdconta) THEN
            vr_vlbastit := vr_tab_titulos(vr_tab_crapcot(idx).nrdconta);
          ELSE
            vr_vlbastit :=  0;
          END IF;
          IF vr_tab_cheques.exists(vr_tab_crapcot(idx).nrdconta) THEN
            vr_vlbasdsc := vr_tab_cheques(vr_tab_crapcot(idx).nrdconta);
          ELSE
            vr_vlbasdsc := 0;
          END IF;
        
          -- Para juridico e fisico e de acordo com a flag de demissao.
          IF vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa IN (1,2) AND vr_flgdemit = 1 THEN
            vr_qtraimfx := vr_tab_crapcot(idx).qtraimfx;
            vr_vlrendim := vr_tab_crapcot(idx).vlrearda + vr_tab_crapcot(idx).vlrearpp + vr_tab_crapcot(idx).vlpvardc;

            /*  Calcula retorno sobre o DESCONTO DE CHEQUES ................ */
            IF vr_indeschq = 1 THEN
              -- Calcula juros de desconto de cheque
              vr_vlretdsc := ROUND(vr_vlbasdsc * vr_txdretor,2);
            ELSE
              vr_vlretdsc := 0;
            END IF;

            /*  Calcula retorno sobre o DESCONTO DE TITULOS ................ */
            IF vr_indestit = 1   THEN
              -- Calcula juros de desconto de titulo
              vr_vlrettit := ROUND(vr_vlbastit * vr_txdretor,2);
            ELSE
              vr_vlrettit := 0;
            END IF;

          ELSE
             vr_qtraimfx := 0;
             vr_vlrendim := 0;
             vr_vlretdsc := 0;
             vr_vlbasdsc := 0;
             vr_vlrettit := 0;
             vr_vlbastit := 0;
          END IF;

          vr_vlbasret := ROUND(vr_qtraimfx * rw_crapmfx.vlmoefix,2);
          vr_vlbasapl := vr_vlrendim;
          tt_vlbasapl := tt_vlbasapl + vr_vlbasapl;

          /*  Calcula retorno sobre juros pagos de emprestimos/cc ........ */
          IF vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa IN (1,2) AND vr_flgdemit = 1 THEN
            IF vr_increret = 1   THEN
              vr_vldretor := ROUND(vr_vlbasret * vr_txdretor,2);
            ELSE
              vr_vldretor := 0;
            END IF;

            /*  Calcula retorno sobre as APLICACOES ........................ */
            IF vr_txjurapl > 0 THEN
              vr_vljurapl := ROUND(vr_vlbasapl * vr_txjurapl,2);
              tt_vljurapl := tt_vljurapl + vr_vljurapl;
            ELSE
              vr_vljurapl := 0;
            END IF;

          ELSE
            vr_vldretor := 0;
            vr_vljurapl := 0;
          END IF;

          /*  Calcula retorno sobre o SALDO MEDIO DE C/C.................. */
          /*  Novo calculo sobre a MEDIA DE CAPITAL....15/02/2011......... */
          vr_vlbassdm := 0;
          vr_vlbasjur := 0;
          vr_vljurcap := 0;
          vr_vlmedcap := 0;
          vr_vldeirrf := 0;

          IF vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa IN (1,2) AND vr_flgdemit = 1 THEN
            /* Saldo medio c/c */
            vr_vlbassdm := vr_vlbassdm + vr_tab_crapcot(idx).smposano;
            /* Media capital */
            vr_vlbasjur := vr_vlbasjur + vr_tab_crapcot(idx).vlcapmes;

            vr_vlbassdm := ROUND(vr_vlbassdm / 12,2);
            tt_vlbassdm := tt_vlbassdm + vr_vlbassdm;
            vr_vlmedcap := ROUND(vr_vlbasjur / 12,2);
            tt_vlmedcap := tt_vlmedcap + vr_vlmedcap;

            /* Saldo medio c/c */
            IF vr_txjursdm > 0 THEN
              vr_vljursdm := ROUND(vr_vlbassdm * vr_txjursdm,2);
              tt_vljursdm := tt_vljursdm + vr_vljursdm;
            ELSE
              vr_vljursdm := 0;
            END IF;

            /* Juros ao capital | IRRF s/ juros ao capita */
            IF vr_txjurcap > 0  THEN
              
              aux_vljurcap:= 0;
              aux_vldeirrf:= 0;              
              
              vr_vljurcap := ROUND(vr_vlmedcap * vr_txjurcap,2);
              
              --Buscar lancamentos 926[JUROS CAPITAL] e 922[IR JUROS CAP]
              pc_busca_soma_hist(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => vr_tab_crapcot(idx).nrdconta
                                ,pr_cdhistor => 926 --> JUROS CAPITAL
                                ,pr_vlrtotal => aux_vljurcap
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                 vr_dscritic := vr_dscritic || ' - Coop: ' || pr_cdcooper || ' - Conta: ' || vr_tab_crapcot(idx).nrdconta;
                 RAISE vr_exc_saida;
              END IF;
              
              tt_vljurcap := tt_vljurcap + vr_vljurcap;
              
              --Buscar lancamentos 926[JUROS CAPITAL] e 922[IR JUROS CAP]
              IF vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa = 1 THEN
                
                  pc_busca_soma_hist(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => vr_tab_crapcot(idx).nrdconta
                                    ,pr_cdhistor => 922 --> IR JUROS CAP
                                    ,pr_vlrtotal => aux_vldeirrf
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
                                    
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                     vr_dscritic := vr_dscritic || ' - Coop: ' || pr_cdcooper || ' - Conta: ' || vr_tab_crapcot(idx).nrdconta;
                     RAISE vr_exc_saida;
                  END IF;
                  
              END IF;
              
              aux_vljurcap := aux_vljurcap + vr_vljurcap;
              
              /* Busca percentual de IRRF baseado na faixa do valor */
              pc_calcula_irrf(vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                             ,aux_vljurcap
                             ,vr_vldeirrf
                             ,vr_vlprirrf);
              -- Quando o calculo retornar -1 é pq houve erro
              IF vr_vldeirrf = -1 THEN
                vr_dscritic := 'Valor de juros sobre capital não se encaixa em nenhuma faixa de IRRF.' ||
                             ' Cooperativa: ' || pr_cdcooper || '. Conta: ' || vr_tab_crapcot(idx).nrdconta || '. Tipo Pessoa: ' || vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa || '. Valor: ' || vr_vljurcap;
                RAISE vr_exc_saida;
              END IF;
              
              IF aux_vldeirrf > 0 THEN
                 vr_vldeirrf := vr_vldeirrf - aux_vldeirrf;
              END IF; 
              
              aux_vldeirrf := 0;
              aux_vljurcap := 0;
              
              
            ELSE
              vr_vlbasjur := 0;
              vr_vljurcap := 0;
              vr_vlmedcap := 0;
              vr_vldeirrf := 0;
            END IF;

            /* Verifica se conta eh Imunidade sobre IRRF */
            IF vr_vldeirrf > 0 THEN
              IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => vr_tab_crapcot(idx).nrdconta,
                                                  pr_dtmvtolt => vr_dtmvtolt,
                                                  pr_flgrvvlr => vr_inprvdef = 1, /* Se definitivo, já gravará */
                                                  pr_cdinsenc => 6,
                                                  pr_vlinsenc => vr_vldeirrf,
                                                  pr_inpessoa => vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa,
                                                  pr_nrcpfcgc => vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).nrcpfcgc,
                                                  pr_flgimune => vr_flgimune,
                                                  pr_dsreturn => vr_dsreturn,
                                                  pr_tab_erro => vr_tab_erro);
              IF vr_dsreturn = 'NOK' THEN -- Ocorreu erro
                vr_cdcritic := vr_tab_erro(01).cdcritic;
                vr_dscritic := vr_tab_erro(01).dscritic;
                RAISE vr_exc_saida;
              END IF;

              IF NOT vr_flgimune THEN
                tt_vldeirrf := tt_vldeirrf + vr_vldeirrf;
              ELSE
                vr_vldeirrf := 0;
              END IF;
            END IF;
          ELSE
            vr_vljursdm := 0;
            vr_vlbasjur := 0;
            vr_vljurcap := 0;
            vr_vlmedcap := 0;
            vr_vldeirrf := 0;
          END IF;
          
          /* Calcula retorno sobre TARIFAS PAGAS...........................*/
          vr_vlbastar := 0;
          vr_vljurtar := 0;
          
          IF vr_txjurtar > 0 THEN
            IF vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa IN (1,2) AND vr_flgdemit = 1 THEN
              -- Busca da quantidade de operações de auto atendimento se existir
              IF vr_tab_tarifa.exists(vr_tab_crapcot(idx).nrdconta) THEN
                vr_vlbastar := vr_tab_tarifa(vr_tab_crapcot(idx).nrdconta);
                vr_vljurtar := TRUNC(vr_vlbastar * vr_txjurtar,2);
                tt_vljurtar := tt_vljurtar + vr_vljurtar;
              ELSE
                vr_vlbastar := 0;
                vr_vljurtar := 0;
              END IF;
            END IF;
          END IF;

          /********* M360 - Calculo retorno sobre Auto Atendimento ****************/
          IF vr_tab_autoate.exists(vr_tab_crapcot(idx).nrdconta) THEN
            vr_vlbasaut := vr_tab_autoate(vr_tab_crapcot(idx).nrdconta);
          ELSE
            vr_vlbasaut := 0;
          END IF;
          vr_vljuraut := 0;
          -- Havendo taxa de juros a aplicar        
          IF vr_txjuraut > 0 THEN                    
            -- Acumular conforme teste de consideração de demitidos sim/não  
            IF vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa IN (1,2) AND vr_flgdemit = 1 THEN
              vr_vljuraut := ROUND(vr_vlbasaut * vr_txjuraut,2);
              tt_vljuraut := tt_vljuraut + vr_vljuraut;  
            END IF;
          END IF;
          /********* M360 - Calculo retorno sobre Auto Atendimento ****************/

          -- efetua os acumuladores dos calculos
          tt_vlbasret := tt_vlbasret + vr_vlbasret;
          tt_vldretor := tt_vldretor + vr_vldretor;
          tt_vlbasdsc := tt_vlbasdsc + vr_vlbasdsc;
          tt_vlretdsc := tt_vlretdsc + vr_vlretdsc;
          tt_vlbastit := tt_vlbastit + vr_vlbastit;
          tt_vlrettit := tt_vlrettit + vr_vlrettit;
          tt_vlbastar := tt_vlbastar + vr_vlbastar;
          tt_vlbasaut := tt_vlbasaut + vr_vlbasaut;
          
          -- Contagem de associados com retorno de Capital
          IF (vr_vljurcap + vr_vlbasjur) > 0 THEN
            tt_qtasscap := tt_qtasscap + 1; -- Quantidade de associados com juros ao capital
          END IF;
          
          IF vr_vljurcap > 0 THEN
            tt_qtcrecap := tt_qtcrecap + 1;
          END IF;

          -- Contagem de associados com sobras
          IF vr_vldretor > 0 THEN
            tt_qtassret := tt_qtassret + 1; -- Quantidade de associados com retorno
          END IF;

          IF vr_vlretdsc > 0 THEN
            tt_qtassdsc := tt_qtassdsc + 1; -- Quantidade de associados com retorno creditado
          END IF;

          IF vr_vlrettit > 0 THEN
            tt_qtasstit := tt_qtasstit + 1; -- Quantidade de associados com desconto de titulos
          END IF;

          -- Se houve lançamento de juros sobre as operações de credito
          IF vr_vldretor + vr_vlretdsc + vr_vlrettit > 0 THEN
            tt_qtretcrd := tt_qtretcrd + 1;
            tt_qtcredit := tt_qtcredit + 1;
          END IF;
        
          -- Armazena o valor total de retorno sobre operacoes de credito
          tt_vlretcrd := tt_vlretcrd + vr_vldretor + vr_vlretdsc + vr_vlrettit;
          

          -- Para os retornos de depositos unificados
          IF vr_indivdep = 1 THEN
            -- Se houve juros sobre aplicações
            IF vr_vljurapl > 0 THEN
              tt_qtassapl := tt_qtassapl + 1;
            END IF;

            -- Se houve juros sobre deposito a vista
            IF vr_vljursdm > 0 THEN
              tt_qtasssdm := tt_qtasssdm + 1;
            END IF;

            -- Se houve juros sobre aplicações + saldo medio
            IF vr_vljurapl + vr_vljursdm > 0 THEN
              tt_qtretdep := tt_qtretdep + 1;
              tt_qtcredit := tt_qtcredit + 1;
            END IF;
        
          ELSE  
            -- Se houve juros sobre aplicações 
            IF vr_vljurapl > 0 THEN
              tt_qtassapl := tt_qtassapl + 1;
              tt_qtretdep := tt_qtretdep + 1;
              tt_qtcredit := tt_qtcredit + 1;
            END IF;
        
            -- Se houve juros sobre deposito a vista
            IF vr_vljursdm > 0 THEN
              tt_qtasssdm := tt_qtasssdm + 1;
              tt_qtretdep := tt_qtretdep + 1;
              tt_qtcredit := tt_qtcredit + 1;
            END IF;
          END IF;  

          -- Armazena o valor total de retorno sobre depositos (aplicacoes e saldo médio C/C) 
          tt_vlretdep := tt_vlretdep + vr_vljurapl + vr_vljursdm;

          -- Se houve juros sobre Tarifas pagas
          IF vr_vljurtar > 0 THEN
            tt_qtasstar := tt_qtasstar + 1;            
            tt_qtcredit := tt_qtcredit + 1;
          END IF;

          -- Se houve juros sobre AutoAtendimento
          IF vr_vljuraut > 0 THEN
            tt_qtassaut := tt_qtassaut + 1;
            tt_qtcredit := tt_qtcredit + 1;
          END IF;

          -- Calcula o valor do Retorno total
          vr_vlcredit := vr_vldretor + vr_vlretdsc + vr_vlrettit
                       + vr_vljurapl + vr_vljursdm
                       + vr_vljurtar + vr_vljuraut; 

          -- Acumular total retorno geral, por Conta Capital e CC
          tt_vlcredit := tt_vlcredit + vr_vlcredit; 
          tt_vlcrecot := tt_vlcrecot + vr_vlcrecot; 
          tt_vlcrecta := tt_vlcrecta + vr_vlcrecta; 

          -- Calcula o valor do retorno total
          vr_vlcretot := vr_vlcredit + vr_vljurcap;

          -- Acumular valor do retorno total
          tt_vlcretot := tt_vlcretot + vr_vlcretot;

          -- Se for processo definitivo, entao popula a temp-table
          IF vr_inprvdef = 1 THEN
            
            -- Criação do índice
            vr_indice := vr_indice + 1;
            -- Copia das informações para as colunas
            vr_tab_crrl048(vr_indice).dsrowid := vr_tab_crapcot(idx).nrrowid;
            vr_tab_crrl048(vr_indice).nrdconta := vr_tab_crapcot(idx).nrdconta;
            vr_tab_crrl048(vr_indice).inpessoa := vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa;
            vr_tab_crrl048(vr_indice).dtelimin := vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).dtelimin;
            
            vr_tab_crrl048(vr_indice).flraimfx := 0;
            vr_tab_crrl048(vr_indice).qtraimfx := vr_qtraimfx;
            vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crapcot(idx).vldcotas;
            
            /* Juros e IR sobre Cotas */
            vr_tab_crrl048(vr_indice).vljurcap := vr_vljurcap;
            vr_tab_crrl048(vr_indice).vldeirrf := vr_vldeirrf;
            
            /* Efetuar a mesma divisão da Cotas e CC para que o relatório possua o mesmo arredondamento dos lançamentos */
            vr_vlcrecot := 0;
            vr_vlcrecta := 0;
            
            /* Operacoes de Credito */
            vr_tab_crrl048(vr_indice).vlretcrd := vr_vldretor + vr_vlretdsc + vr_vlrettit;
            pc_distribui_cotas_cc(vr_tab_crrl048(vr_indice).vlretcrd
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_tab_crrl048(vr_indice).vlretcrd_cot
                                 ,vr_tab_crrl048(vr_indice).vlretcrd_cta);            
            vr_vlcrecot := vr_vlcrecot + vr_tab_crrl048(vr_indice).vlretcrd_cot;
            vr_vlcrecta := vr_vlcrecta + vr_tab_crrl048(vr_indice).vlretcrd_cta;
            
            /* Aplicacoes */
            vr_tab_crrl048(vr_indice).vljurapl := vr_vljurapl;
            pc_distribui_cotas_cc(vr_tab_crrl048(vr_indice).vljurapl
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_tab_crrl048(vr_indice).vljurapl_cot
                                 ,vr_tab_crrl048(vr_indice).vljurapl_cta);
            vr_vlcrecot := vr_vlcrecot + vr_tab_crrl048(vr_indice).vljurapl_cot;
            vr_vlcrecta := vr_vlcrecta + vr_tab_crrl048(vr_indice).vljurapl_cta;
            
            /* Saldo Medio */
            vr_tab_crrl048(vr_indice).vljursdm := vr_vljursdm;
            pc_distribui_cotas_cc(vr_tab_crrl048(vr_indice).vljursdm
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_tab_crrl048(vr_indice).vljursdm_cot
                                 ,vr_tab_crrl048(vr_indice).vljursdm_cta);
            vr_vlcrecot := vr_vlcrecot + vr_tab_crrl048(vr_indice).vljursdm_cot;
            vr_vlcrecta := vr_vlcrecta + vr_tab_crrl048(vr_indice).vljursdm_cta;
            
            /* Tarifas aplicadas */
            vr_tab_crrl048(vr_indice).vljurtar := vr_vljurtar;
            pc_distribui_cotas_cc(vr_tab_crrl048(vr_indice).vljurtar
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_tab_crrl048(vr_indice).vljurtar_cot
                                 ,vr_tab_crrl048(vr_indice).vljurtar_cta);
            vr_vlcrecot := vr_vlcrecot + vr_tab_crrl048(vr_indice).vljurtar_cot;
            vr_vlcrecta := vr_vlcrecta + vr_tab_crrl048(vr_indice).vljurtar_cta;
            
            /* Auto Atendimento */
            vr_tab_crrl048(vr_indice).vljuraut := vr_vljuraut;
            pc_distribui_cotas_cc(vr_tab_crrl048(vr_indice).vljuraut
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_tab_crrl048(vr_indice).vljuraut_cot
                                 ,vr_tab_crrl048(vr_indice).vljuraut_cta);
            vr_vlcrecot := vr_vlcrecot + vr_tab_crrl048(vr_indice).vljuraut_cot;
            vr_vlcrecta := vr_vlcrecta + vr_tab_crrl048(vr_indice).vljuraut_cta;

          ELSE
            /* Efetuar a mesma divisão da Cotas e CC para que o relatório possua o mesmo arredondamento dos lançamentos */
            vr_vlcrecot := 0;
            vr_vlcrecta := 0;
                        
            -- Segregar valor conforme distribuição Conta Capital e/ou CC             
                                 
            /* Operacoes de Credito */
            pc_distribui_cotas_cc(vr_vldretor + vr_vlretdsc + vr_vlrettit
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_vlcrecot_tmp
                                 ,vr_vlcrecta_tmp); 
            vr_vlcrecot := vr_vlcrecot + vr_vlcrecot_tmp;
            vr_vlcrecta := vr_vlcrecta + vr_vlcrecta_tmp;
            
            /* Aplicacoes */
            pc_distribui_cotas_cc(vr_vljurapl
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_vlcrecot_tmp
                                 ,vr_vlcrecta_tmp);
            vr_vlcrecot := vr_vlcrecot + vr_vlcrecot_tmp;
            vr_vlcrecta := vr_vlcrecta + vr_vlcrecta_tmp;
            
            /* Saldo Medio */
            pc_distribui_cotas_cc(vr_vljursdm
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_vlcrecot_tmp
                                 ,vr_vlcrecta_tmp);
            vr_vlcrecot := vr_vlcrecot + vr_vlcrecot_tmp;
            vr_vlcrecta := vr_vlcrecta + vr_vlcrecta_tmp;
            
            /* Tarifas aplicadas */
            pc_distribui_cotas_cc(vr_vljurtar
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_vlcrecot_tmp
                                 ,vr_vlcrecta_tmp);
            vr_vlcrecot := vr_vlcrecot + vr_vlcrecot_tmp;
            vr_vlcrecta := vr_vlcrecta + vr_vlcrecta_tmp;
            
            /* Auto Atendimento */
            pc_distribui_cotas_cc(vr_vljuraut
                                 ,vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).inpessoa
                                 ,vr_vlcrecot_tmp
                                 ,vr_vlcrecta_tmp);                     
            vr_vlcrecot := vr_vlcrecot + vr_vlcrecot_tmp;
            vr_vlcrecta := vr_vlcrecta + vr_vlcrecta_tmp;
            
          END IF;

          -- Atualiza o registro abaixo para utilizacao no relatorio CRRL412
          -- Se todos os valores forem zeros, nao deve imprimir no relatorio
          IF vr_vlcretot + vr_vlmedcap + vr_vlbasjur + vr_vlbasret + vr_vlrendim
           + vr_vlbassdm + vr_vldeirrf + vr_vlbastar + vr_vlbasaut > 0  THEN
            -- Criação do registro
            vr_indice_412 := lpad(vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).cdagenci,5,'0') || lpad(vr_tab_crapcot(idx).nrdconta,10,'0');
            -- Copia das informações para as colunas
            vr_tab_crrl412(vr_indice_412).cdagenci := vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).cdagenci;
            vr_tab_crrl412(vr_indice_412).nrdconta := vr_tab_crapcot(idx).nrdconta;
            vr_tab_crrl412(vr_indice_412).nmprimtl := substr(vr_tab_crapass(vr_tab_crapcot(idx).nrdconta).nmprimtl,1,30);
            vr_tab_crrl412(vr_indice_412).vlmedcap := vr_vlmedcap;
            vr_tab_crrl412(vr_indice_412).vlbascap := vr_vlbasjur;
            vr_tab_crrl412(vr_indice_412).vlretcap := vr_vljurcap;
            vr_tab_crrl412(vr_indice_412).vlbasopc := vr_vlbasret + vr_vlbasdsc + vr_vlbastit;
            vr_tab_crrl412(vr_indice_412).vlretopc := vr_vldretor + vr_vlretdsc + vr_vlrettit;
            vr_tab_crrl412(vr_indice_412).vlbasapl := vr_vlrendim;
            vr_tab_crrl412(vr_indice_412).vlretapl := vr_vljurapl;
            vr_tab_crrl412(vr_indice_412).vlbassdm := vr_vlbassdm;
            vr_tab_crrl412(vr_indice_412).vlretsdm := vr_vljursdm;
            vr_tab_crrl412(vr_indice_412).vldeirrf := vr_vldeirrf;
            vr_tab_crrl412(vr_indice_412).percirrf := vr_vlprirrf;
            vr_tab_crrl412(vr_indice_412).vlbastar := vr_vlbastar;
            vr_tab_crrl412(vr_indice_412).vlrettar := vr_vljurtar;
            vr_tab_crrl412(vr_indice_412).vlbasaut := vr_vlbasaut;
            vr_tab_crrl412(vr_indice_412).vlretaut := vr_vljuraut;
            vr_tab_crrl412(vr_indice_412).vlcredit := vr_vlcredit;
            vr_tab_crrl412(vr_indice_412).vlcrecot := vr_vlcrecot;
            vr_tab_crrl412(vr_indice_412).vlcrecta := vr_vlcrecta;
            vr_tab_crrl412(vr_indice_412).vlcretot := vr_vlcretot;
          END IF;
        END LOOP;/* Fim do LOOP -- leitura da pltabe vr_tab_crapcot */ 
      END LOOP; /*  Fim do LOOP --  Leitura do crapcot  */

      IF cr_crapcot%ISOPEN THEN
        CLOSE cr_crapcot;      
      END IF;        

      IF cr_crapcot2%ISOPEN THEN
        CLOSE cr_crapcot2;
      END IF;        

      -- Se for processo definitivo e existirem informações na pltable      
      IF vr_inprvdef = 1 AND vr_tab_crrl048.count > 0 THEN 
        -- busca os dados da capa do lote
        OPEN cr_craplot(pr_dtmvtolt => vr_dtmvtolt,
                        pr_cdagenci => vr_cdagenci,
                        pr_cdbccxlt => vr_cdbccxlt,
                        pr_nrdolote => vr_nrdolote);
        FETCH cr_craplot INTO rw_craplot;
        -- Não pode existir
        IF cr_craplot%FOUND THEN
          CLOSE cr_craplot;
          -- Não pode ter existido lançamento na cooperativa no mesmo dia
          vr_cdcritic := 59;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' LOTE = ' ||to_char(vr_nrdolote,'000000');
          pc_controle_critica;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_craplot;
          -- Iniciar variaveis para gravação posterior de lote
          rw_craplot.vlinfocr := 0;
          rw_craplot.vlcompcr := 0;
          rw_craplot.vlinfodb := 0;
          rw_craplot.vlcompdb := 0;
          rw_craplot.qtinfoln := 0;
          rw_craplot.qtcompln := 0;
          rw_craplot.nrseqdig := 0;
        END IF;

        -- Perceorre a tabela que foi populada para o processo definitivo
        vr_indice := vr_tab_crrl048.first;
        WHILE vr_indice IS NOT NULL LOOP
          vr_cdsitdct := 0;
          FOR rw_crapass IN cr_crapass (pr_cdcooper,
                                        vr_tab_crrl048(vr_indice).nrdconta) LOOP
            vr_cdsitdct := rw_crapass.cdsitdct;
          END LOOP;
          /*  Credito do retorno  */
          IF vr_increret = 1 THEN           

            /*  Sobras sobre Operações de Crédito */
            IF vr_tab_crrl048(vr_indice).vlretcrd > 0 THEN

              /* Operacores de credito integralizadas */  
              vr_tab_crrl048(vr_indice).qtraimfx := 0;
              vr_tab_crrl048(vr_indice).flraimfx := 1; -- Deve atualizar

              -- Insere dados na tabela de lancamentos de cota / capital
              IF vr_tab_crrl048(vr_indice).vlretcrd_cot > 0 THEN              
                BEGIN
                  INSERT INTO craplct
                    (dtmvtolt,
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     nrdconta,
                     nrdocmto,
                     cdhistor,
                     vllanmto,
                     nrseqdig,
                     cdcooper)
                   VALUES
                    (vr_dtmvtolt,
                     vr_cdagenci,
                     vr_cdbccxlt,
                     vr_nrdolote,
                     vr_tab_crrl048(vr_indice).nrdconta,
                     8005||vr_cdhisopc_cot,
                     vr_cdhisopc_cot,
                     vr_tab_crrl048(vr_indice).vlretcrd_cot,
                     rw_craplot.nrseqdig + 1,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro insert da CRAPLCT (4): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                -- Incrementar sequencia no lote e quantidades
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                
                /* Se for cooperado eliminado - vamos lancar debitar o lancamento e mover para a tabela de devolucao de cotas/cc */
                IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                    vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  
                  atualiza_tbcotas(pr_cdcooper
                                  ,vr_tab_crrl048(vr_indice).nrdconta
                                  ,vr_tab_crrl048(vr_indice).inpessoa
                                  ,3
                                  ,vr_tab_crrl048(vr_indice).vlretcrd_cot
                                  ,rw_craplot.nrseqdig
                                  ,vr_cdcritic
                                  ,vr_dscritic);
                  IF vr_cdcritic IS NOT NULL THEN
                    RAISE vr_exc_saida;
                  END IF;
                ELSE
                  -- Atualiza o valor das cotas na conta
                  vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas + vr_tab_crrl048(vr_indice).vlretcrd_cot;
                END IF;
              END IF;

              -- Lançamento em C/C  
              IF vr_tab_crrl048(vr_indice).vlretcrd_cta > 0 THEN
                BEGIN
            
                      LANC0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote                         
                         ,pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctabb => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctitg => gene0002.fn_mask(vr_tab_crrl048(vr_indice).nrdconta,'99999999')
                         ,pr_nrdocmto => 8005||vr_cdhisopc_cta
                         ,pr_cdhistor => vr_cdhisopc_cta
                         ,pr_vllanmto => vr_tab_crrl048(vr_indice).vlretcrd_cta                         
                         ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                         ,pr_cdcooper => pr_cdcooper 
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                          RAISE vr_exc_saida;
                      END IF;   
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no insert da CRAPLCM: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                
                  /* Se for cooperado eliminado - vamos lancar debitar o lancamento e mover para a tabela de devolucao de cotas/cc */
                  IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                    vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                    -- Incrementar sequencia no lote e quantidades
                    rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                    rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                    rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                    
                    atualiza_tbcotas(pr_cdcooper
                                    ,vr_tab_crrl048(vr_indice).nrdconta
                                    ,vr_tab_crrl048(vr_indice).inpessoa
                                    ,4
                                    ,vr_tab_crrl048(vr_indice).vlretcrd_cta
                                    ,rw_craplot.nrseqdig
                                    ,vr_cdcritic
                                    ,vr_dscritic);
                    IF vr_cdcritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;
                  END IF;
              END IF; -- Lançamento em C/C  
              -- Atualizar informações do lote  
              rw_craplot.vlinfocr := rw_craplot.vlinfocr + vr_tab_crrl048(vr_indice).vlretcrd;
              rw_craplot.vlcompcr := rw_craplot.vlcompcr + vr_tab_crrl048(vr_indice).vlretcrd;
              IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL THEN
                rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_tab_crrl048(vr_indice).vlretcrd;
                rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_tab_crrl048(vr_indice).vlretcrd;
              END IF;
            END IF; -- vlretcrd > 0

            /* Se foi solicitado o retorno das sobras sobre depósitos unificada */ 
            IF vr_indivdep = 1 THEN
              /* Haverá um único lançamento */
              /* verifica se ha saldo sobre depositos a vista */
              IF vr_tab_crrl048(vr_indice).vljursdm + vr_tab_crrl048(vr_indice).vljurapl > 0 THEN

                /* Operacores de credito integralizadas */  
                vr_tab_crrl048(vr_indice).qtraimfx := 0;
                vr_tab_crrl048(vr_indice).flraimfx := 1; -- Deve atualizar

                  -- Insere dados na tabela de lancamentos de cota / capital
                IF vr_tab_crrl048(vr_indice).vljursdm_cot + vr_tab_crrl048(vr_indice).vljurapl_cot > 0 THEN
                  BEGIN
                    INSERT INTO craplct
                      (dtmvtolt,
                       cdagenci,
                       cdbccxlt,
                       nrdolote,
                       nrdconta,
                       nrdocmto,
                       cdhistor,
                       vllanmto,
                       nrseqdig,
                       cdcooper)
                    VALUES
                      (vr_dtmvtolt,
                       vr_cdagenci,
                       vr_cdbccxlt,
                       vr_nrdolote,
                       vr_tab_crrl048(vr_indice).nrdconta,
                       8005||vr_cdhisdep_cot,
                       vr_cdhisdep_cot,
                       vr_tab_crrl048(vr_indice).vljursdm_cot + vr_tab_crrl048(vr_indice).vljurapl_cot,
                       rw_craplot.nrseqdig + 1,
                       pr_cdcooper);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no insert da CRAPLCT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  
                  /* Se for cooperado eliminado - vamos lancar debitar o lancamento e mover para a tabela de devolucao de cotas/cc */
                  IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                    vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                    -- Incrementar sequencia no lote e quantidades
                    rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                    rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                    rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  
                    atualiza_tbcotas(pr_cdcooper
                                    ,vr_tab_crrl048(vr_indice).nrdconta
                                    ,vr_tab_crrl048(vr_indice).inpessoa
                                    ,3
                                    ,vr_tab_crrl048(vr_indice).vljursdm_cot + vr_tab_crrl048(vr_indice).vljurapl_cot
                                    ,rw_craplot.nrseqdig
                                    ,vr_cdcritic
                                    ,vr_dscritic);
                    IF vr_cdcritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;
                  ELSE
                    -- Atualiza o valor das cotas na conta
                    vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas + vr_tab_crrl048(vr_indice).vljursdm_cot + vr_tab_crrl048(vr_indice).vljurapl_cot;  
                  END IF;
                END IF;

                -- Lançamento em C/C  
                IF vr_tab_crrl048(vr_indice).vljursdm_cta + vr_tab_crrl048(vr_indice).vljurapl_cta > 0 THEN
                  BEGIN
  
                     LANC0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote                         
                         ,pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctabb => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctitg => gene0002.fn_mask(vr_tab_crrl048(vr_indice).nrdconta,'99999999')
                         ,pr_nrdocmto => 8005||vr_cdhisdep_cta
                         ,pr_cdhistor => vr_cdhisdep_cta
                         ,pr_vllanmto => vr_tab_crrl048(vr_indice).vljursdm_cta + vr_tab_crrl048(vr_indice).vljurapl_cta                         
                         ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                         ,pr_cdcooper => pr_cdcooper 
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                          RAISE vr_exc_saida;
                      END IF;  
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no insert da CRAPLCM: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  
                  /* Se for cooperado eliminado - vamos lancar debitar o lancamento e mover para a tabela de devolucao de cotas/cc */
                  IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                    vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                    -- Incrementar sequencia no lote e quantidades
                    rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                    rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                    rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  
                    atualiza_tbcotas(pr_cdcooper
                                    ,vr_tab_crrl048(vr_indice).nrdconta
                                    ,vr_tab_crrl048(vr_indice).inpessoa
                                    ,4
                                    ,vr_tab_crrl048(vr_indice).vljursdm_cta + vr_tab_crrl048(vr_indice).vljurapl_cta
                                    ,rw_craplot.nrseqdig
                                    ,vr_cdcritic
                                    ,vr_dscritic);
                    IF vr_cdcritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;
                  END IF;
                  
                END IF;
                -- Atualizar informações do lote  
                rw_craplot.vlinfocr := rw_craplot.vlinfocr + vr_tab_crrl048(vr_indice).vljursdm + vr_tab_crrl048(vr_indice).vljurapl;
                rw_craplot.vlcompcr := rw_craplot.vlcompcr + vr_tab_crrl048(vr_indice).vljursdm + vr_tab_crrl048(vr_indice).vljurapl;
                IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL THEN
                  rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_tab_crrl048(vr_indice).vljursdm + vr_tab_crrl048(vr_indice).vljurapl;
                  rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_tab_crrl048(vr_indice).vljursdm + vr_tab_crrl048(vr_indice).vljurapl;
                END IF;
              END IF; -- vljursdm + vljurapl > 0
                
            ELSE   
              /* verifica se ha saldo sobre depositos a vista */
              IF vr_tab_crrl048(vr_indice).vljursdm > 0 THEN

                /* Operacores de credito integralizadas */  
                vr_tab_crrl048(vr_indice).qtraimfx := 0;
                vr_tab_crrl048(vr_indice).flraimfx := 1; -- Deve atualizar
                  
                -- Insere dados na tabela de lancamentos de cota / capital
                IF vr_tab_crrl048(vr_indice).vljursdm_cot > 0 THEN
                BEGIN
                  INSERT INTO craplct
                    (dtmvtolt,
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     nrdconta,
                     nrdocmto,
                     cdhistor,
                     vllanmto,
                     nrseqdig,
                     cdcooper)
                  VALUES
                      (vr_dtmvtolt,
                       vr_cdagenci,
                       vr_cdbccxlt,
                       vr_nrdolote,
                       vr_tab_crrl048(vr_indice).nrdconta,
                       8005||vr_cdhisdpa_cot,
                       vr_cdhisdpa_cot,
                       vr_tab_crrl048(vr_indice).vljursdm_cot,
                       rw_craplot.nrseqdig + 1,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                      vr_dscritic := 'Erro no insert da CRAPLCT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                -- Incrementar sequencia no lote e quantidades
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  
                /* Se for cooperado eliminado - vamos lancar debitar o lancamento e mover para a tabela de devolucao de cotas/cc */
                IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                    vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;  
                
                  atualiza_tbcotas(pr_cdcooper
                                  ,vr_tab_crrl048(vr_indice).nrdconta
                                  ,vr_tab_crrl048(vr_indice).inpessoa
                                  ,3
                                  ,vr_tab_crrl048(vr_indice).vljursdm_cot
                                  ,rw_craplot.nrseqdig
                                  ,vr_cdcritic
                                  ,vr_dscritic);
                  IF vr_cdcritic IS NOT NULL THEN
                    RAISE vr_exc_saida;
                  END IF;
                ELSE
                  -- Atualiza o valor das cotas na conta
                  vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas + vr_tab_crrl048(vr_indice).vljursdm_cot;
                END IF;
              END IF;

                -- Lançamento em C/C  
                IF vr_tab_crrl048(vr_indice).vljursdm_cta > 0 THEN
                  BEGIN
              
                      LANC0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote                         
                         ,pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctabb => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctitg => gene0002.fn_mask(vr_tab_crrl048(vr_indice).nrdconta,'99999999')
                         ,pr_nrdocmto => 8005||vr_cdhisdpa_cta
                         ,pr_cdhistor => vr_cdhisdpa_cta
                         ,pr_vllanmto => vr_tab_crrl048(vr_indice).vljursdm_cta
                         ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                         ,pr_cdcooper => pr_cdcooper 
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                          RAISE vr_exc_saida;
                      END IF;    
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no insert da CRAPLCM: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  
                  /* Se for cooperado eliminado - vamos lancar debitar o lancamento e mover para a tabela de devolucao de cotas/cc */
                  IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                    vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                    -- Incrementar sequencia no lote e quantidades
                    rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                    rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                    rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                    
                    atualiza_tbcotas(pr_cdcooper
                                    ,vr_tab_crrl048(vr_indice).nrdconta
                                    ,vr_tab_crrl048(vr_indice).inpessoa
                                    ,4
                                    ,vr_tab_crrl048(vr_indice).vljursdm_cta
                                    ,rw_craplot.nrseqdig
                                    ,vr_cdcritic
                                    ,vr_dscritic);
                    IF vr_cdcritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;
                  END IF;
                END IF;
                -- Atualizar informações do lote  
                rw_craplot.vlinfocr := rw_craplot.vlinfocr + vr_tab_crrl048(vr_indice).vljursdm;
                rw_craplot.vlcompcr := rw_craplot.vlcompcr + vr_tab_crrl048(vr_indice).vljursdm;
                IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL THEN
                  rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_tab_crrl048(vr_indice).vljursdm;
                  rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_tab_crrl048(vr_indice).vljursdm;
                END IF;
              END IF; -- vljursdm > 0

              /* verifica se ha saldo sobre depositos de aplicações */
              IF vr_tab_crrl048(vr_indice).vljurapl > 0 THEN

                /* Operacores de credito integralizadas */  
                vr_tab_crrl048(vr_indice).qtraimfx := 0;
                vr_tab_crrl048(vr_indice).flraimfx := 1; -- Deve atualizar

                -- Insere dados na tabela de lancamentos de cota / capital
                IF vr_tab_crrl048(vr_indice).vljurapl_cot > 0 THEN
                  BEGIN
                      INSERT INTO craplct
                      (dtmvtolt,
                       cdagenci,
                       cdbccxlt,
                       nrdolote,
                       nrdconta,
                       nrdocmto,
                       cdhistor,
                       vllanmto,
                       nrseqdig,
                       cdcooper)
                    VALUES
                        (vr_dtmvtolt,
                         vr_cdagenci,
                         vr_cdbccxlt,
                         vr_nrdolote,
                         vr_tab_crrl048(vr_indice).nrdconta,
                         8005||vr_cdhisdpp_cot,
                         vr_cdhisdpp_cot,
                         vr_tab_crrl048(vr_indice).vljurapl_cot,
                         rw_craplot.nrseqdig + 1,
                       pr_cdcooper);
                  EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Erro no insert da CRAPLCT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                    
                  IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                    vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                    -- Incrementar sequencia no lote e quantidades
                    rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                    rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                    rw_craplot.qtcompln := rw_craplot.qtcompln + 1;  
                    
                    atualiza_tbcotas(pr_cdcooper
                                    ,vr_tab_crrl048(vr_indice).nrdconta
                                    ,vr_tab_crrl048(vr_indice).inpessoa
                                    ,3
                                    ,vr_tab_crrl048(vr_indice).vljurapl_cot
                                    ,rw_craplot.nrseqdig
                                    ,vr_cdcritic
                                    ,vr_dscritic);
                    IF vr_cdcritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;
                  ELSE
                    -- Atualiza o valor das cotas na conta
                    vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas + vr_tab_crrl048(vr_indice).vljurapl_cot;
                  END IF;
                END IF;

                -- Lançamento em C/C  
                IF vr_tab_crrl048(vr_indice).vljurapl_cta > 0 THEN
                  BEGIN
              
                     LANC0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote                         
                         ,pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctabb => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctitg => gene0002.fn_mask(vr_tab_crrl048(vr_indice).nrdconta,'99999999')
                         ,pr_nrdocmto => 8005||vr_cdhisdpp_cta
                         ,pr_cdhistor => vr_cdhisdpp_cta
                         ,pr_vllanmto => vr_tab_crrl048(vr_indice).vljurapl_cta
                         ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                         ,pr_cdcooper => pr_cdcooper 
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                          RAISE vr_exc_saida;
                      END IF;  
                  EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Erro no insert da CRAPLCM: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  -- Incrementar sequencia no lote e quantidades
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                    
                  IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                     vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                    -- Incrementar sequencia no lote e quantidades
                    rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                    rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                    rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                      
                    atualiza_tbcotas(pr_cdcooper
                                    ,vr_tab_crrl048(vr_indice).nrdconta
                                    ,vr_tab_crrl048(vr_indice).inpessoa
                                    ,4
                                    ,vr_tab_crrl048(vr_indice).vljurapl_cta
                                    ,rw_craplot.nrseqdig
                                    ,vr_cdcritic
                                    ,vr_dscritic);
                    IF vr_cdcritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;
                  END IF;                              
                END IF;
                -- Atualizar informações do lote  
                rw_craplot.vlinfocr := rw_craplot.vlinfocr + vr_tab_crrl048(vr_indice).vljurapl;
                rw_craplot.vlcompcr := rw_craplot.vlcompcr + vr_tab_crrl048(vr_indice).vljurapl;
                IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL THEN
                  rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_tab_crrl048(vr_indice).vljurapl;
                  rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_tab_crrl048(vr_indice).vljurapl;
                END IF;
              END IF; -- vljurapl > 0
            END IF;

          END IF; --vr_increret = 1

          /* Juros ao capital */
          IF vr_tab_crrl048(vr_indice).vljurcap > 0  THEN
            -- Insere dados na tabela de lancamentos de cota / capital
            BEGIN
              INSERT INTO craplct
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdconta,
                 nrdocmto,
                 cdhistor,
                 vllanmto,
                 nrseqdig,
                 cdcooper)
              VALUES
                (vr_dtmvtolt,
                 vr_cdagenci,
                 vr_cdbccxlt,
                 vr_nrdolote,
                 vr_tab_crrl048(vr_indice).nrdconta,
                 8005||lpad(vr_cdhisjur_cot,4,'0'),
                 lpad(vr_cdhisjur_cot,4,'0'),
                 vr_tab_crrl048(vr_indice).vljurcap,
                 rw_craplot.nrseqdig + 1,
                 pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro insert da CRAPLCT (5): '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            -- Atualizar informações do lote  
            rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
            rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
            rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                
            -- Atualiza o valor das cotas na conta
            vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas + vr_tab_crrl048(vr_indice).vljurcap;
            
            rw_craplot.vlinfocr := rw_craplot.vlinfocr + vr_tab_crrl048(vr_indice).vljurcap;
            rw_craplot.vlcompcr := rw_craplot.vlcompcr + vr_tab_crrl048(vr_indice).vljurcap;
            
          END IF; -- vr_tab_crrl048(vr_indice).vljurcap > 0
              
          -------IRRF sobre rendimentos capital------
          IF vr_tab_crrl048(vr_indice).vldeirrf > 0 THEN
              
            BEGIN
              INSERT INTO craplct
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdconta,
                 nrdocmto,
                 cdhistor,
                 vllanmto,
                 nrseqdig,
                 cdcooper)
              VALUES
                (vr_dtmvtolt,
                 vr_cdagenci,
                 vr_cdbccxlt,
                 vr_nrdolote,
                 vr_tab_crrl048(vr_indice).nrdconta,
                 8005||lpad(vr_cdhisirr_cot,4,'0'),
                 lpad(vr_cdhisirr_cot,4,'0'),
                 vr_tab_crrl048(vr_indice).vldeirrf,
                 rw_craplot.nrseqdig + 1,
                 pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                   vr_dscritic := 'Erro insert da CRAPLCT (6): '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            -- Atualizar informações do lote  
            rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
            rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
            rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                
            -- Atualiza o valor das cotas na conta
            vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas - vr_tab_crrl048(vr_indice).vldeirrf;  
            
            rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_tab_crrl048(vr_indice).vldeirrf;
            rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_tab_crrl048(vr_indice).vldeirrf;
            
          END IF;  --vr_tab_crrl048(vr_indice).vldeirrf > 0
          
          /* Se teve juros ao capital e a conta esta eliminada, vamos zerar o saldo de cotas e 
             criar o registro na tabela de devolucao de cotas */
          IF vr_tab_crrl048(vr_indice).vljurcap > 0 AND
            (vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
             vr_cdsitdct = 8) THEN -- Para quando estiver com situação 8 atualizar cotas
             
            -- Atualizar informações do lote  
            rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
            rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
            rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
            
            /* Valor para lancamento */
            vr_vlretaux := vr_tab_crrl048(vr_indice).vljurcap - nvl(vr_tab_crrl048(vr_indice).vldeirrf,0);
                
            atualiza_tbcotas(pr_cdcooper
                            ,vr_tab_crrl048(vr_indice).nrdconta
                            ,vr_tab_crrl048(vr_indice).inpessoa
                            ,3
                            ,vr_vlretaux
                            ,rw_craplot.nrseqdig
                            ,vr_cdcritic
                            ,vr_dscritic);
            IF vr_cdcritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            
            -- Atualiza o valor das cotas na conta
            vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas - vr_vlretaux;
            
            rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_vlretaux;
            rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_vlretaux;
          END IF;
              
          /* ---------------TARIFAS PAGAS--------------- */
          IF vr_tab_crrl048(vr_indice).vljurtar > 0  THEN

              -- Insere dados na tabela de lancamentos de cota / capital
            IF vr_tab_crrl048(vr_indice).vljurtar_cot > 0 THEN
              BEGIN
                INSERT INTO craplct
                  (dtmvtolt,
                   cdagenci,
                   cdbccxlt,
                   nrdolote,
                   nrdconta,
                   nrdocmto,
                   cdhistor,
                   vllanmto,
                   nrseqdig,
                   cdcooper)
                VALUES
                  (vr_dtmvtolt,
                   vr_cdagenci,
                   vr_cdbccxlt,
                   vr_nrdolote,
                   vr_tab_crrl048(vr_indice).nrdconta,
                   8005||vr_cdhistar_cot,
                   vr_cdhistar_cot,
                   vr_tab_crrl048(vr_indice).vljurtar_cot,
                   rw_craplot.nrseqdig + 1,
                   pr_cdcooper);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro insert da CRAPLCT (5): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Incrementar sequencia no lote e quantidades
              rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
              rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
              rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
              
              IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                 vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                -- Incrementar sequencia no lote e quantidades
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
              
                atualiza_tbcotas(pr_cdcooper
                                ,vr_tab_crrl048(vr_indice).nrdconta
                                ,vr_tab_crrl048(vr_indice).inpessoa
                                ,3
                                ,vr_tab_crrl048(vr_indice).vljurtar_cot
                                ,rw_craplot.nrseqdig
                                ,vr_cdcritic
                                ,vr_dscritic);
                IF vr_cdcritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              ELSE
                -- Atualiza o valor das cotas na conta
                vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas + vr_tab_crrl048(vr_indice).vljurtar_cot;  
              END IF;
            END IF;  

            -- Lançamento em C/C  
            IF vr_tab_crrl048(vr_indice).vljurtar_cta > 0 THEN
              BEGIN
             
                 LANC0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote                         
                         ,pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctabb => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctitg => gene0002.fn_mask(vr_tab_crrl048(vr_indice).nrdconta,'99999999')
                         ,pr_nrdocmto => 8005||vr_cdhistar_cta
                         ,pr_cdhistor => vr_cdhistar_cta
                         ,pr_vllanmto => vr_tab_crrl048(vr_indice).vljurtar_cta
                         ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                         ,pr_cdcooper => pr_cdcooper 
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                          RAISE vr_exc_saida;
                      END IF;    
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro no insert da CRAPLCM: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Incrementar sequencia no lote e quantidades
              rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
              rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
              rw_craplot.qtcompln := rw_craplot.qtcompln + 1;  
              
              IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                 vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                -- Incrementar sequencia no lote e quantidades
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                rw_craplot.qtcompln := rw_craplot.qtcompln + 1;  
                
                atualiza_tbcotas(pr_cdcooper
                                ,vr_tab_crrl048(vr_indice).nrdconta
                                ,vr_tab_crrl048(vr_indice).inpessoa
                                ,4
                                ,vr_tab_crrl048(vr_indice).vljurtar_cta
                                ,rw_craplot.nrseqdig
                                ,vr_cdcritic
                                ,vr_dscritic);
                IF vr_cdcritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              END IF;              
            END IF;
            -- Atualizar informações do lote  
            rw_craplot.vlinfocr := rw_craplot.vlinfocr + vr_tab_crrl048(vr_indice).vljurtar;
            rw_craplot.vlcompcr := rw_craplot.vlcompcr + vr_tab_crrl048(vr_indice).vljurtar;
            IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL THEN
              rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_tab_crrl048(vr_indice).vljurtar;
              rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_tab_crrl048(vr_indice).vljurtar;
            END IF;
          END IF;
          /* -------------FIM TARIFAS PAGAS------------- */

          /* ---------------AUTO ATENDIMENTO--------------- */
          IF vr_tab_crrl048(vr_indice).vljuraut > 0  THEN

            -- Insere dados na tabela de lancamentos de cota / capital
            IF vr_tab_crrl048(vr_indice).vljuraut_cot > 0 THEN  
              -- Insere dados na tabela de lancamentos de cota / capital
              BEGIN
                INSERT INTO craplct
                  (dtmvtolt,
                   cdagenci,
                   cdbccxlt,
                   nrdolote,
                   nrdconta,
                   nrdocmto,
                   cdhistor,
                   vllanmto,
                   nrseqdig,
                   cdcooper)
                VALUES
                  (vr_dtmvtolt,
                   vr_cdagenci,
                   vr_cdbccxlt,
                   vr_nrdolote,
                   vr_tab_crrl048(vr_indice).nrdconta,
                   8005||vr_cdhisaut_cot,
                   vr_cdhisaut_cot,
                   vr_tab_crrl048(vr_indice).vljuraut_cot,
                   rw_craplot.nrseqdig + 1,
                   pr_cdcooper);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro insert da CRAPLCT (6): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Incrementar sequencia no lote e quantidades
              rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
              rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
              rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
              
              IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                 vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                -- Incrementar sequencia no lote e quantidades
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                
                atualiza_tbcotas(pr_cdcooper
                                ,vr_tab_crrl048(vr_indice).nrdconta
                                ,vr_tab_crrl048(vr_indice).inpessoa
                                ,3
                                ,vr_tab_crrl048(vr_indice).vljuraut_cot
                                ,rw_craplot.nrseqdig
                                ,vr_cdcritic
                                ,vr_dscritic);
                IF vr_cdcritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              ELSE
                -- Atualiza o valor das cotas na conta
                vr_tab_crrl048(vr_indice).vldcotas := vr_tab_crrl048(vr_indice).vldcotas + vr_tab_crrl048(vr_indice).vljuraut_cot;  
              END IF;
            END IF;  
          
            -- Lançamento em C/C  
            IF vr_tab_crrl048(vr_indice).vljuraut_cta > 0 THEN
              BEGIN
         
                 LANC0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => vr_dtmvtolt
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_cdbccxlt => vr_cdbccxlt
                         ,pr_nrdolote => vr_nrdolote                         
                         ,pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctabb => vr_tab_crrl048(vr_indice).nrdconta
                         ,pr_nrdctitg => gene0002.fn_mask(vr_tab_crrl048(vr_indice).nrdconta,'99999999')
                         ,pr_nrdocmto => 8005||vr_cdhisaut_cta
                         ,pr_cdhistor => vr_cdhisaut_cta
                         ,pr_vllanmto => vr_tab_crrl048(vr_indice).vljuraut_cta
                         ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                         ,pr_cdcooper => pr_cdcooper 
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                          RAISE vr_exc_saida;
                      END IF;   
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro no insert da CRAPLCM: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Incrementar sequencia no lote e quantidades
              rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
              rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
              rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
              
              IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL OR
                 vr_cdsitdct = 8 THEN -- Para quando estiver com situação 8 atualizar cotas
                -- Incrementar sequencia no lote e quantidades
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;                
                rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
              
                atualiza_tbcotas(pr_cdcooper
                                ,vr_tab_crrl048(vr_indice).nrdconta
                                ,vr_tab_crrl048(vr_indice).inpessoa
                                ,4
                                ,vr_tab_crrl048(vr_indice).vljuraut_cta
                                ,rw_craplot.nrseqdig
                                ,vr_cdcritic
                                ,vr_dscritic);
                IF vr_cdcritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              END IF;              
            END IF;
            
            rw_craplot.vlinfocr := rw_craplot.vlinfocr + vr_tab_crrl048(vr_indice).vljuraut;
            rw_craplot.vlcompcr := rw_craplot.vlcompcr + vr_tab_crrl048(vr_indice).vljuraut;
            IF vr_tab_crrl048(vr_indice).dtelimin IS NOT NULL THEN
              rw_craplot.vlinfodb := rw_craplot.vlinfodb + vr_tab_crrl048(vr_indice).vljuraut;
              rw_craplot.vlcompdb := rw_craplot.vlcompdb + vr_tab_crrl048(vr_indice).vljuraut;
            END IF;
          END IF;
          /* -------------FIM AUTO ATENDIMENTO------------- */
          
          -- Não há retorno para outros tipos de pessoa
          IF vr_tab_crrl048(vr_indice).inpessoa = 3 THEN
            -- Atualiza a quantidade de retorno a incorporar em moeda fixa para zeros
            vr_tab_crrl048(vr_indice).qtraimfx := 0;
            vr_tab_crrl048(vr_indice).flraimfx := 1; -- Deve atualizar
          END IF; --vr_tab_crrl048(vr_indice).inpessoa = 3

          -- Enfim, fazemos a atualização da CRAPCOT
          BEGIN
            UPDATE crapcot
           SET qtraimfx = decode(vr_tab_crrl048(vr_indice).flraimfx,1,vr_tab_crrl048(vr_indice).qtraimfx,qtraimfx)
              ,vldcotas = vr_tab_crrl048(vr_indice).vldcotas
         WHERE ROWID = vr_tab_crrl048(vr_indice).dsRowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Busca do próximo registro
          vr_indice := vr_tab_crrl048.next(vr_indice);
        END LOOP;
        
        -- Se há informações para gravação do lote
        IF rw_craplot.nrseqdig > 0 THEN
          -- Insere a capa do lote
          BEGIN
            INSERT INTO craplot (dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,cdcooper
                                ,vlinfocr
                                ,vlcompcr
                                ,vlinfodb
                                ,vlcompdb
                                ,qtinfoln
                                ,qtcompln
                                ,nrseqdig)
                         VALUES (vr_dtmvtolt
                                ,vr_cdagenci
                                ,vr_cdbccxlt
                                ,vr_nrdolote
                                ,2
                                ,pr_cdcooper
                                ,rw_craplot.vlinfocr
                                ,rw_craplot.vlcompcr
                                ,rw_craplot.vlinfodb
                                ,rw_craplot.vlcompdb
                                ,rw_craplot.qtinfoln
                                ,rw_craplot.qtcompln
                                ,rw_craplot.nrseqdig);
          EXCEPTION
            WHEN OTHERS THEN
          vr_dscritic := 'Erro insert da CRAPLOT: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
      END IF; -- IF vr_inprvdef = 1 AND vr_tab_crrl048.count > 0 THEN 
      
      ----------- Emissão dos relatórios --------
      
      -------- Inicio do arquivo CRRL043.lst
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      gene0002.pc_escreve_xml(pr_xml => vr_xml
                             ,pr_texto_completo => vr_txt
                             ,pr_texto_novo => '<?xml version="1.0" encoding="ISO-8859-1"?>'||chr(10)||'<crrl043>');

      -- Escreve a linha de total
      gene0002.pc_escreve_xml(pr_xml => vr_xml
                             ,pr_texto_completo => vr_txt
                             ,pr_texto_novo => '<vlbasret>'||to_char(tt_vlbasret,'999G999G999G990D00MI')      ||'</vlbasret>'||
                                               '<txdretor>'||to_char(rl_txdretor,'fm9999999999990D00000000')||' %'||'</txdretor>'||
                                               '<vldretor>'||to_char(tt_vldretor,'999G999G999G990D00MI')      ||'</vldretor>'||
                                               '<vlretcrd>'||to_char(tt_vlretcrd,'999G999G999G990D00MI')      ||'</vlretcrd>'||                     
                                               '<qtretcrd>'||to_char(tt_qtretcrd,'fm999999999G990')           ||'</qtretcrd>'||
                                               '<vlretdep>'||to_char(tt_vlretdep,'999G999G999G990D00MI')      ||'</vlretdep>'||                     
                                               '<qtretdep>'||to_char(tt_qtretdep,'fm999999999G990')           ||'</qtretdep>'||                     
                                               '<qtassret>'||to_char(tt_qtassret,'fm999999999G990')           ||'</qtassret>'||
                                               '<dsprvdef>'|| rl_dsprvdef                                     ||'</dsprvdef>'||
                                               
                                               '<vljurcap>'||to_char(tt_vljurcap,'999G999G999G990D00MI')      ||'</vljurcap>'||
                                               '<vlmedcap>'||to_char(tt_vlmedcap,'999G999G999G990D00MI')      ||'</vlmedcap>'||
                                               '<txjurcap>'||to_char(vr_txjurcap*100,'fm999999990D00000000')      ||'</txjurcap>'||
                                               '<txjurapl>'||to_char(vr_txjurapl*100,'fm999999990D00000000')||' %'||'</txjurapl>'||
                                               '<vlcredit>'||to_char(tt_vlcredit,'999G999G999G990D00MI')      ||'</vlcredit>'||
                                               '<vlcrecot>'||to_char(tt_vlcrecot,'999G999G999G990D00MI')      ||'</vlcrecot>'||
                                               '<vlcrecta>'||to_char(tt_vlcrecta,'999G999G999G990D00MI')      ||'</vlcrecta>'||                                                                                              
                                               '<qtcredit>'||to_char(tt_qtcredit,'fm999999999G990')           ||'</qtcredit>'||
                                               '<vlbasapl>'||to_char(tt_vlbasapl,'999G999G999G990D00MI')      ||'</vlbasapl>'||
                                               '<vljurapl>'||to_char(tt_vljurapl,'999G999G999G990D00MI')      ||'</vljurapl>'||
                                               '<dstipcre>'|| tt_dstipcre                                     ||'</dstipcre>'||
                                               '<percotpj>'||to_char(vr_perpjcot*100,'990D00MI')      ||'</percotpj>'||
                                               '<perctapj>'||to_char(100-vr_perpjcot*100,'990D00MI')      ||'</perctapj>'||
                                               '<percotpf>'||to_char(vr_perpfcot*100,'990D00MI')      ||'</percotpf>'||
                                               '<perctapf>'||to_char(100-vr_perpfcot*100,'990D00MI')      ||'</perctapf>'||
                                               '<vlbasdsc>'||to_char(tt_vlbasdsc,'999G999G999G990D00MI')      ||'</vlbasdsc>'||
                                               '<vlretdsc>'||to_char(tt_vlretdsc,'999G999G999G990D00MI')      ||'</vlretdsc>'||
                                               '<qtassdsc>'||to_char(tt_qtassdsc,'fm999999999G990')           ||'</qtassdsc>'||
                                               '<vlbastit>'||to_char(tt_vlbastit,'999G999G999G990D00MI')      ||'</vlbastit>'||
                                               '<vlrettit>'||to_char(tt_vlrettit,'999G999G999G990D00MI')      ||'</vlrettit>'||
                                               '<qtasstit>'||to_char(tt_qtasstit,'fm999999999G990')           ||'</qtasstit>'||
                                               '<qtassapl>'||to_char(tt_qtassapl,'fm999999999G990')           ||'</qtassapl>'||
                                               '<qtasscap>'||to_char(tt_qtasscap,'fm999999999G990')           ||'</qtasscap>'||
                                               '<txretdsc>'||to_char(rl_txretdsc,'fm9999999999990D00000000')||' %'||'</txretdsc>'||
                                               '<txrettit>'||to_char(rl_txrettit,'fm9999999999990D00000000')||' %'||'</txrettit>'||
                                               '<dsdemiti>'|| tt_dsdemiti                                     ||'</dsdemiti>'||
                                               '<dsdepcon>'|| tt_indivdep                                     ||'</dsdepcon>'||
                                               '<qtasssdm>'||to_char(tt_qtasssdm,'fm999999999G990')           ||'</qtasssdm>'||
                                               '<vlbassdm>'||to_char(tt_vlbassdm,'999G999G999G990D00MI')      ||'</vlbassdm>'||
                                               '<txjursdm>'||to_char(vr_txjursdm*100,'fm999999990D00000000')||' %'||'</txjursdm>'||
                                               '<vljursdm>'||to_char(tt_vljursdm,'999G999G999G990D00MI')      ||'</vljursdm>'||
                                               '<vldeirrf>'||to_char(tt_vldeirrf,'999G999G999G990D00MI')      ||'</vldeirrf>'||
                                               '<qtasstar>'||to_char(tt_qtasstar,'fm999999999G990')           ||'</qtasstar>'||
                                               '<vlbastar>'||to_char(tt_vlbastar,'999G999G999G990D00MI')      ||'</vlbastar>'||
                                               '<txjurtar>'||to_char(vr_txjurtar*100,'fm999999990D00000000')||' %'||'</txjurtar>'||
                                               '<vljurtar>'||to_char(tt_vljurtar,'999G999G999G990D00MI')      ||'</vljurtar>'||
                                               '<qtassaut>'||to_char(tt_qtassaut,'fm999999999G990')           ||'</qtassaut>'||
                                               '<vlbasaut>'||to_char(tt_vlbasaut,'999G999G999G990MI')      ||'</vlbasaut>'||
                                               '<txjuraut>'||to_char(vr_txjuraut*100,'fm999999990D00000000')||' %'||'</txjuraut>'||
                                               '<vljuraut>'||to_char(tt_vljuraut,'999G999G999G990D00MI')      ||'</vljuraut>'||
                                               '<vlcretot>'||to_char(tt_vlcretot,'999G999G999G990D00MI')      ||'</vlcretot>'||
                                               '<qtcretot>'||to_char(tt_qtcredit + tt_qtcrecap,'fm999999999G990')           ||'</qtcretot>'||
                                             '</crrl043>'
                                             ,pr_fecha_xml => TRUE);
          
      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => vr_dtmvtolt,            --> Data do movimento atual
                                  pr_cdrelato  => 43,                            --> Código do relatório
                                  pr_dsxml     => vr_xml,                         --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl043',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl043.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl043.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 80,                             --> Quantidade de colunas
                                  pr_nmformul  => '80col',                        --> Nome do formulario
                                  pr_dspathcop => vr_nom_direto_copia_043,            --> Lista sep. por ';' de diretórios a copiar o relatório
                                  pr_fldoscop  => 'S',                            --> Flag para converter o arquivo gerado em DOS antes da cópia
                                  pr_dscmaxcop => ' | tr -d "\032"',              --> Comando auxiliar para o comando ux2dos na cópia de diretório
                                  pr_fldosmail => 'S',                            --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                  pr_dsmailcop => vr_dsdestin,                    --> Lista sep. por ';' de emails para envio do relatório
                                  pr_dsassmail => 'Relatorio 043/510',            --> Assunto do e-mail que enviará o relatório
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      -- Libera a memoria do clob
      dbms_lob.close(vr_xml);

      IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
      END IF;

      
      ------ Inicializar o CLOB CRRL412 -----------
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      dbms_lob.createtemporary(vr_xml_tot, TRUE);
      dbms_lob.open(vr_xml_tot, dbms_lob.lob_readwrite);

      -- Escreve o cabecalho inicial do XML
      pc_escreve_xml(1,
                     '<?xml version="1.0" encoding="ISO-8859-1"?>'||chr(10)||
                     '<crrl412>');

      -- Escreve o nó do total
      pc_escreve_xml(2,
                     '<total>'||
                       '<dsprvdef>' || rl_dsprvdef                         || '</dsprvdef>' ||
                       '<dsdemiti>' || tt_dsdemiti                         || '</dsdemiti>'||
                       '<txjurcap>' || to_char(vr_txjurcap*100,'FM990D00000000') || '%</txjurcap>' ||
                       '<txdretor>' || to_char(vr_txdretor*100,'FM990D00000000') || '%</txdretor>' ||
                       '<txjurapl>' || to_char(vr_txjurapl*100,'FM990D00000000') || '%</txjurapl>' ||
                       '<txjursdm>' || to_char(vr_txjursdm*100,'FM990D00000000') || '%</txjursdm>' ||
                       '<txjurtar>' || to_char(vr_txjurtar*100,'FM990D00000000') || '%</txjurtar>' ||
                       '<txjuraut>' || to_char(vr_txjuraut*100,'FM990D00000000') || '%</txjuraut>');

      -- Vai para o primeiro registro do temp-table
      vr_indice_412 := vr_tab_crrl412.first;

      -- Efetua a varredura do temp-table
      WHILE vr_indice_412 IS NOT NULL LOOP

        -- verifica se eh a primeira agencia
        IF vr_indice_412 = vr_tab_crrl412.first OR   -- Primeiro registro
           vr_tab_crrl412(vr_indice_412).cdagenci <> vr_tab_crrl412(vr_tab_crrl412.prior(vr_indice_412)).cdagenci THEN -- Agencia anterior diferente da atual

          -- Busca o nome da agencia
          OPEN cr_crapage(vr_tab_crrl412(vr_indice_412).cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            vr_rel_dsagenci := to_char(vr_tab_crrl412(vr_indice_412).cdagenci,'000') ||
                                 '-NAO CADASTRADO';
          ELSE
            vr_rel_dsagenci := to_char(vr_tab_crrl412(vr_indice_412).cdagenci,'000') || '-' ||
                                 rw_crapage.nmresage;
          END IF;
          CLOSE cr_crapage;

          -- Inicializa as variaveis de totais
          vr_pac_qtassoci := 0;
          vr_pac_vlmedcap := 0;
          vr_pac_vlbascap := 0;
          vr_pac_vlretcap := 0;
          vr_pac_vlbasopc := 0;
          vr_pac_vlretopc := 0;
          vr_pac_vlbasapl := 0;
          vr_pac_vlretapl := 0;
          vr_pac_vlbassdm := 0;
          vr_pac_vlretsdm := 0;
          vr_pac_vldeirrf := 0;
          vr_pac_vlbastar := 0;
          vr_pac_vlrettar := 0;
          vr_pac_vlbasaut := 0;
          vr_pac_vlretaut := 0;          
          vr_pac_vlcredit := 0;
          vr_pac_vlcrecot := 0;
          vr_pac_vlcrecta := 0;
          vr_pac_vlcretot := 0;

          -- Escreve o no de agencia e os percentuais da mesma
          pc_escreve_xml(1,
                         '<pa>'||
                           '<dsagenci>' || vr_rel_dsagenci                     || '</dsagenci>' ||
                           '<dsprvdef>' || rl_dsprvdef                         || '</dsprvdef>');
        END IF;

        -- Escreve a linha de detalhe
        pc_escreve_xml(1,
                       '<detalhe>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_crrl412(vr_indice_412).nrdconta)    ||'</nrdconta>'||
                         '<nmprimtl>'||vr_tab_crrl412(vr_indice_412).nmprimtl                            ||'</nmprimtl>'||
                         '<vlmedcap>'||to_char(vr_tab_crrl412(vr_indice_412).vlmedcap,'FM999G999G990D00MI')||'</vlmedcap>'||
                         '<vlretcap>'||to_char(vr_tab_crrl412(vr_indice_412).vlretcap,'FM999G999G990D00MI')||'</vlretcap>'||
                         '<vlbasopc>'||to_char(vr_tab_crrl412(vr_indice_412).vlbasopc,'FM999G999G990D00MI')||'</vlbasopc>'||
                         '<vlretopc>'||to_char(vr_tab_crrl412(vr_indice_412).vlretopc,'FM999G999G990D00MI')||'</vlretopc>'||
                         '<vlbasapl>'||to_char(vr_tab_crrl412(vr_indice_412).vlbasapl,'FM999G999G990D00MI')||'</vlbasapl>'||
                         '<vlretapl>'||to_char(vr_tab_crrl412(vr_indice_412).vlretapl,'FM999G999G990D00MI')||'</vlretapl>'||
                         '<vlcredit>'||to_char(vr_tab_crrl412(vr_indice_412).vlcredit,'FM999G999G990D00MI')||'</vlcredit>'||
                         '<vlcrecot>'||to_char(vr_tab_crrl412(vr_indice_412).vlcrecot,'FM999G999G990D00MI')||'</vlcrecot>'||
                         '<vlcrecta>'||to_char(vr_tab_crrl412(vr_indice_412).vlcrecta,'FM999G999G990D00MI')||'</vlcrecta>'||
                         '<vlbassdm>'||to_char(vr_tab_crrl412(vr_indice_412).vlbassdm,'FM999G999G990D00MI')||'</vlbassdm>'||
                         '<vlretsdm>'||to_char(vr_tab_crrl412(vr_indice_412).vlretsdm,'FM999G999G990D00MI')||'</vlretsdm>'||
                         '<vldeirrf>'||to_char(vr_tab_crrl412(vr_indice_412).vldeirrf,'FM999G999G990D00MI')||'</vldeirrf>'||
                         '<percirrf>'||to_char(vr_tab_crrl412(vr_indice_412).percirrf,'FM999G999G990D00MI')||'</percirrf>'||
                         '<vlbastar>'||to_char(vr_tab_crrl412(vr_indice_412).vlbastar,'FM999G999G990D00MI')||'</vlbastar>'||
                         '<vlrettar>'||to_char(vr_tab_crrl412(vr_indice_412).vlrettar,'FM999G999G990D00MI')||'</vlrettar>'||
                         '<vlcretot>'||to_char(vr_tab_crrl412(vr_indice_412).vlcretot,'FM999G999G990D00MI')||'</vlcretot>'||
                         '<vlbasaut>'||to_char(vr_tab_crrl412(vr_indice_412).vlbasaut,'FM999G999G990MI')||'</vlbasaut>'||
                         '<vlretaut>'||to_char(vr_tab_crrl412(vr_indice_412).vlretaut,'FM999G999G990D00MI')||'</vlretaut>'||                         
                       '</detalhe>');

        -- Acumula os valores para formar o total do PA
        vr_pac_qtassoci := vr_pac_qtassoci + 1;
        vr_pac_vlmedcap := vr_pac_vlmedcap + vr_tab_crrl412(vr_indice_412).vlmedcap;
        vr_pac_vlbascap := vr_pac_vlbascap + vr_tab_crrl412(vr_indice_412).vlbascap;
        vr_pac_vlretcap := vr_pac_vlretcap + vr_tab_crrl412(vr_indice_412).vlretcap;
        vr_pac_vlbasopc := vr_pac_vlbasopc + vr_tab_crrl412(vr_indice_412).vlbasopc;
        vr_pac_vlretopc := vr_pac_vlretopc + vr_tab_crrl412(vr_indice_412).vlretopc;
        vr_pac_vlbasapl := vr_pac_vlbasapl + vr_tab_crrl412(vr_indice_412).vlbasapl;
        vr_pac_vlretapl := vr_pac_vlretapl + vr_tab_crrl412(vr_indice_412).vlretapl;
        vr_pac_vlbassdm := vr_pac_vlbassdm + vr_tab_crrl412(vr_indice_412).vlbassdm;
        vr_pac_vlretsdm := vr_pac_vlretsdm + vr_tab_crrl412(vr_indice_412).vlretsdm;
        vr_pac_vldeirrf := vr_pac_vldeirrf + vr_tab_crrl412(vr_indice_412).vldeirrf;
        vr_pac_vlbastar := vr_pac_vlbastar + vr_tab_crrl412(vr_indice_412).vlbastar;
        vr_pac_vlrettar := vr_pac_vlrettar + vr_tab_crrl412(vr_indice_412).vlrettar;
        vr_pac_vlbasaut := vr_pac_vlbasaut + vr_tab_crrl412(vr_indice_412).vlbasaut;
        vr_pac_vlretaut := vr_pac_vlretaut + vr_tab_crrl412(vr_indice_412).vlretaut;
        vr_pac_vlcredit := vr_pac_vlcredit + vr_tab_crrl412(vr_indice_412).vlcredit;
        vr_pac_vlcrecot := vr_pac_vlcrecot + vr_tab_crrl412(vr_indice_412).vlcrecot;
        vr_pac_vlcrecta := vr_pac_vlcrecta + vr_tab_crrl412(vr_indice_412).vlcrecta;
        vr_pac_vlcretot := vr_pac_vlcretot + vr_tab_crrl412(vr_indice_412).vlcretot;

        -- Verifica se eh o ultimo registro do PA
        IF vr_indice_412 = vr_tab_crrl412.last OR   -- Primeiro registro
           vr_tab_crrl412(vr_indice_412).cdagenci <> vr_tab_crrl412(vr_tab_crrl412.next(vr_indice_412)).cdagenci THEN -- Agencia anterior diferente da atual
          -- gera o total do PA
          pc_escreve_xml(1,'<pa_qtassoci>'||to_char(vr_pac_qtassoci,'FM999G999')         || '</pa_qtassoci>' ||
                           '<pa_vlmedcap>'||to_char(vr_pac_vlmedcap,'FM999G999G990D00MI')|| '</pa_vlmedcap>'||
                           '<pa_vlretcap>'||to_char(vr_pac_vlretcap,'FM999G999G990D00MI')|| '</pa_vlretcap>'||
                           '<pa_vlbasopc>'||to_char(vr_pac_vlbasopc,'FM999G999G990D00MI')|| '</pa_vlbasopc>'||
                           '<pa_vlretopc>'||to_char(vr_pac_vlretopc,'FM999G999G990D00MI')|| '</pa_vlretopc>'||
                           '<pa_vlbasapl>'||to_char(vr_pac_vlbasapl,'FM999G999G990D00MI')|| '</pa_vlbasapl>'||
                           '<pa_vlretapl>'||to_char(vr_pac_vlretapl,'FM999G999G990D00MI')|| '</pa_vlretapl>'||
                           '<pa_vlcredit>'||to_char(vr_pac_vlcredit,'FM999G999G990D00MI')|| '</pa_vlcredit>'||
                           '<pa_vlcrecot>'||to_char(vr_pac_vlcrecot,'FM999G999G990D00MI')|| '</pa_vlcrecot>'||
                           '<pa_vlcrecta>'||to_char(vr_pac_vlcrecta,'FM999G999G990D00MI')|| '</pa_vlcrecta>'||
                           '<pa_vlbassdm>'||to_char(vr_pac_vlbassdm,'FM999G999G990D00MI')|| '</pa_vlbassdm>'||
                           '<pa_vlretsdm>'||to_char(vr_pac_vlretsdm,'FM999G999G990D00MI')|| '</pa_vlretsdm>'||
                           '<pa_vldeirrf>'||to_char(vr_pac_vldeirrf,'FM999G999G990D00MI')|| '</pa_vldeirrf>'||
                           '<pa_vlbastar>'||to_char(vr_pac_vlbastar,'FM999G999G990D00MI')|| '</pa_vlbastar>'||
                           '<pa_vlrettar>'||to_char(vr_pac_vlrettar,'FM999G999G990D00MI')|| '</pa_vlrettar>'||
                           '<pa_vlbasaut>'||to_char(vr_pac_vlbasaut,'FM999G999G990MI')|| '</pa_vlbasaut>'||
                           '<pa_vlretaut>'||to_char(vr_pac_vlretaut,'FM999G999G990D00MI')|| '</pa_vlretaut>'||
                           '<pa_vlcretot>'||to_char(vr_pac_vlcretot,'FM999G999G990D00MI')|| '</pa_vlcretot>'||
                         '</pa>');

          -- gera o resumo com os totais do PA no final do relatorio
          pc_escreve_xml(2,
                         '<pa>'||
                           '<pa_dsagenci>'|| vr_rel_dsagenci                           || '</pa_dsagenci>' ||
                           '<pa_qtassoci>'||to_char(vr_pac_qtassoci,'FM999G999')         || '</pa_qtassoci>' ||
                           '<pa_vlmedcap>'||to_char(vr_pac_vlmedcap,'FM999G999G990D00MI')|| '</pa_vlmedcap>'||
                           '<pa_vlretcap>'||to_char(vr_pac_vlretcap,'FM999G999G990D00MI')|| '</pa_vlretcap>'||
                           '<pa_vlbasopc>'||to_char(vr_pac_vlbasopc,'FM999G999G990D00MI')|| '</pa_vlbasopc>'||
                           '<pa_vlretopc>'||to_char(vr_pac_vlretopc,'FM999G999G990D00MI')|| '</pa_vlretopc>'||
                           '<pa_vlbasapl>'||to_char(vr_pac_vlbasapl,'FM999G999G990D00MI')|| '</pa_vlbasapl>'||
                           '<pa_vlretapl>'||to_char(vr_pac_vlretapl,'FM999G999G990D00MI')|| '</pa_vlretapl>'||
                           '<pa_vlcredit>'||to_char(vr_pac_vlcredit,'FM999G999G990D00MI')|| '</pa_vlcredit>'||
                           '<pa_vlcrecot>'||to_char(vr_pac_vlcrecot,'FM999G999G990D00MI')|| '</pa_vlcrecot>'||
                           '<pa_vlcrecta>'||to_char(vr_pac_vlcrecta,'FM999G999G990D00MI')|| '</pa_vlcrecta>'||
                           '<pa_vlbassdm>'||to_char(vr_pac_vlbassdm,'FM999G999G990D00MI')|| '</pa_vlbassdm>'||
                           '<pa_vlretsdm>'||to_char(vr_pac_vlretsdm,'FM999G999G990D00MI')|| '</pa_vlretsdm>'||
                           '<pa_vldeirrf>'||to_char(vr_pac_vldeirrf,'FM999G999G990D00MI')|| '</pa_vldeirrf>'||
                           '<pa_vlbastar>'||to_char(vr_pac_vlbastar,'FM999G999G990D00MI')|| '</pa_vlbastar>'||
                           '<pa_vlrettar>'||to_char(vr_pac_vlrettar,'FM999G999G990D00MI')|| '</pa_vlrettar>'||
                           '<pa_vlbasaut>'||to_char(vr_pac_vlbasaut,'FM999G999G990MI')|| '</pa_vlbasaut>'||
                           '<pa_vlretaut>'||to_char(vr_pac_vlretaut,'FM999G999G990D00MI')|| '</pa_vlretaut>'||
                           '<pa_vlcretot>'||to_char(vr_pac_vlcretot,'FM999G999G990D00MI')|| '</pa_vlcretot>'||
                         '</pa>');

          -- Acumula os valores para formar o total geral
          vr_tot_qtassoci := vr_tot_qtassoci + vr_pac_qtassoci;
          vr_tot_vlmedcap := vr_tot_vlmedcap + vr_pac_vlmedcap;
          vr_tot_vlbascap := vr_tot_vlbascap + vr_pac_vlbascap;
          vr_tot_vlretcap := vr_tot_vlretcap + vr_pac_vlretcap;
          vr_tot_vlbasopc := vr_tot_vlbasopc + vr_pac_vlbasopc;
          vr_tot_vlretopc := vr_tot_vlretopc + vr_pac_vlretopc;
          vr_tot_vlbasapl := vr_tot_vlbasapl + vr_pac_vlbasapl;
          vr_tot_vlretapl := vr_tot_vlretapl + vr_pac_vlretapl;
          vr_tot_vlbassdm := vr_tot_vlbassdm + vr_pac_vlbassdm;
          vr_tot_vlretsdm := vr_tot_vlretsdm + vr_pac_vlretsdm;
          vr_tot_vldeirrf := vr_tot_vldeirrf + vr_pac_vldeirrf;
          vr_tot_vlbastar := vr_tot_vlbastar + vr_pac_vlbastar;
          vr_tot_vlrettar := vr_tot_vlrettar + vr_pac_vlrettar;
          vr_tot_vlbasaut := vr_tot_vlbasaut + vr_pac_vlbasaut;
          vr_tot_vlretaut := vr_tot_vlretaut + vr_pac_vlretaut;
          vr_tot_vlcredit := vr_tot_vlcredit + vr_pac_vlcredit;
          vr_tot_vlcrecot := vr_tot_vlcrecot + vr_pac_vlcrecot;
          vr_tot_vlcrecta := vr_tot_vlcrecta + vr_pac_vlcrecta;
          vr_tot_vlcretot := vr_tot_vlcretot + vr_pac_vlcretot;

        END IF;

        -- Vai para a proxima linha do temp-table
        vr_indice_412 := vr_tab_crrl412.next(vr_indice_412);
        END LOOP;
      
      -- Copiar blob pendente
      pc_escreve_xml(1,'',TRUE);

      -- Imprime o total geral
      pc_escreve_xml(2,'<tot_qtassoci>'||to_char(vr_tot_qtassoci,'FM999G999')         || '</tot_qtassoci>' ||
                       '<tot_vlmedcap>'||to_char(vr_tot_vlmedcap,'FM999G999G990D00MI')|| '</tot_vlmedcap>'||
                       '<tot_vlretcap>'||to_char(vr_tot_vlretcap,'FM999G999G990D00MI')|| '</tot_vlretcap>'||
                       '<tot_vlbasopc>'||to_char(vr_tot_vlbasopc,'FM999G999G990D00MI')|| '</tot_vlbasopc>'||
                       '<tot_vlretopc>'||to_char(vr_tot_vlretopc,'FM999G999G990D00MI')|| '</tot_vlretopc>'||
                       '<tot_vlbasapl>'||to_char(vr_tot_vlbasapl,'FM999G999G990D00MI')|| '</tot_vlbasapl>'||
                       '<tot_vlretapl>'||to_char(vr_tot_vlretapl,'FM999G999G990D00MI')|| '</tot_vlretapl>'||
                       '<tot_vlcredit>'||to_char(vr_tot_vlcredit,'FM999G999G990D00MI')|| '</tot_vlcredit>'||
                       '<tot_vlcrecot>'||to_char(vr_tot_vlcrecot,'FM999G999G990D00MI')|| '</tot_vlcrecot>'||
                       '<tot_vlcrecta>'||to_char(vr_tot_vlcrecta,'FM999G999G990D00MI')|| '</tot_vlcrecta>'||
                       '<tot_vlbassdm>'||to_char(vr_tot_vlbassdm,'FM999G999G990D00MI')|| '</tot_vlbassdm>'||
                       '<tot_vlretsdm>'||to_char(vr_tot_vlretsdm,'FM999G999G990D00MI')|| '</tot_vlretsdm>'||
                       '<tot_vldeirrf>'||to_char(vr_tot_vldeirrf,'FM999G999G990D00MI')|| '</tot_vldeirrf>'||
                       '<tot_vlbastar>'||to_char(vr_tot_vlbastar,'FM999G999G990D00MI')|| '</tot_vlbastar>'||
                       '<tot_vlrettar>'||to_char(vr_tot_vlrettar,'FM999G999G990D00MI')|| '</tot_vlrettar>'||
                       '<tot_vlbasaut>'||to_char(vr_tot_vlbasaut,'FM999G999G990MI')|| '</tot_vlbasaut>'||
                       '<tot_vlretaut>'||to_char(vr_tot_vlretaut,'FM999G999G990D00MI')|| '</tot_vlretaut>'||
                       '<tot_vlcretot>'||to_char(vr_tot_vlcretot,'FM999G999G990D00MI')|| '</tot_vlcretot>'||
                     '</total>'
                     ,TRUE);

      -- Concatena o xml de totais no xml principal
      dbms_lob.append(dest_lob => vr_xml ,src_lob => vr_xml_tot);

      -- Fecha o nó principal
      pc_escreve_xml(1,'</crrl412>',TRUE);


      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => pr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => vr_dtmvtolt,                    --> Data do movimento atual
                                  pr_cdrelato  => 412,                            --> Código do relatório
                                  pr_dsxml     => vr_xml,                         --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl412',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl412.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl412.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 234,                            --> Quantidade de colunas
                                  pr_nmformul  => '234dh',                        --> Nome do formulario
                                  pr_dspathcop => vr_nom_direto_copia_412,            --> Lista sep. por ';' de diretórios a copiar o relatório
                                  pr_fldoscop  => 'S',                            --> Flag para converter o arquivo gerado em DOS antes da cópia
                                  pr_dscmaxcop => '',                             --> Comando auxiliar para o comando ux2dos na cópia de diretório
                                  pr_dsextcop  => vr_dsextcop,                    --> Extensao do arquivo da copia
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      -- Libera a memoria do clob
      dbms_lob.close(vr_xml);
      dbms_lob.close(vr_xml_tot);   
      
      -- Direcionar para tratamento de exceção
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Zera taxa de retorno apos o credito 
      BEGIN
        UPDATE craptab
           SET dstextab = '0 0 000,00000000 0 000,00000000 000,00000000 0   0 0 000,00000000 ' || SUBSTR(dstextab,67,10) || ' 000,00000000 000,00000000 000,00 000,00 1'
         WHERE CURRENT OF cr_craptab;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao zerar taxa de retorno apos credito: '||sqlerrm;
          RAISE vr_exc_saida;
      END;
      
      -- Commit necessario porque esta procedure é chamada via Dataserver Progress
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
        -- Commit necessario porque esta procedure é chamada via Dataserver Progress
        COMMIT; 

      WHEN vr_exc_saida THEN
        -- fechar cursores abertos
        IF cr_crapcot%ISOPEN THEN
          CLOSE cr_crapcot;
        END IF;
        IF cr_crapcot2%ISOPEN THEN
          CLOSE cr_crapcot2;
        END IF;        
        IF cr_craptab%ISOPEN THEN
          CLOSE cr_craptab;
        END IF;        
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
        -- fechar cursores abertos
        IF cr_crapcot%ISOPEN THEN
          CLOSE cr_crapcot;
        END IF;
        IF cr_crapcot2%ISOPEN THEN
          CLOSE cr_crapcot2;
        END IF;
        IF cr_craptab%ISOPEN THEN
          CLOSE cr_craptab;
        END IF;        
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END pc_calculo_retorno_sobras;
		
  /* Resumo das informações cota capital */  
  PROCEDURE pc_verifica_conta_capital (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Cód. cooperativa
			                                 ,pr_nrdconta IN craplct.nrdconta%TYPE     --> Número da conta
                                       ,pr_flgconsu OUT INTEGER                  --> Flag para indicar se encontrou lançamentos de cotas/capita
                                       ,pr_vltotsob OUT craplct.vllanmto%TYPE    --> Valor total de sobras
                                       ,pr_vlliqjur OUT craplct.vllanmto%TYPE    --> Valor liquido do crédito de juros sobre capital
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Cód. da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE)IS --> Descrição da crítica
  BEGIN    
	/* ..........................................................................

   Procedure : pc_verifica_conta_capital 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
     Data    : Fevereiro/2015                      Ultima atualizacao: 03/08/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
	 
   Objetivo  : Procedure para verificar a data em que o cooperado deve ser 
	             informado sobre os créditos que recebeu na conta capital 
							 referente a juros sobre capital e retorno de sobras.
							 
	 Alterações: 05/02/2015 - Alterado para mostrar o valor bruto do crédito de juros 
	                          sobre capital, ao invés de líquido. (Reinert)
                            
               02/03/2015 - Ajuste para caso houver erro na conversao da data
                            de comunicacao nao gere rollback, apenas aborte o
                            programa com os valores nulos. Ajustos feitos para
                            finalizar a solicitação do chamado 396732. (Kelvin)
                            
                16/05/2016 - Removido o cursor da craptab e utilizado a chamada da 
                             TABE0001.fn_busca_dstextab que possui os tratamentos
                             para utilizacao do indice da tabela
                             (Douglas - Chamado 452286)
                              
                 03/08/2016 - Busca dos lançamentos de Sobra em CC e novos historicos
                              (Marcos-Supero)             
                              
                 15/03/2017 - Ajuste para que a flag flgconsu retorne para o InternetBanking
                              contendo o identificador da forma como o retorno de sobras ocorreu (Anderson).
                              
	............................................................................. */
  DECLARE  
		
    -- Cursor de lançamento de cotas/capital
    CURSOR cr_craplct (pr_dtmvtocd crapdat.dtmvtocd%TYPE) IS
      SELECT sum(decode(craplct.cdhistor,vr_cdhisjur_cot,craplct.vllanmto,0)) vlliqjur
            ,sum(decode(craplct.cdhistor,vr_cdhisjur_cot,0,craplct.vllanmto)) vltotsob
        FROM craplct
       WHERE craplct.cdcooper  = pr_cdcooper
         AND craplct.dtmvtolt >= TRUNC(pr_dtmvtocd,'YYYY')
         AND craplct.nrdconta  = pr_nrdconta
         AND craplct.cdagenci  = vr_cdagenci
         AND craplct.cdbccxlt  = vr_cdbccxlt
         AND craplct.nrdolote  = vr_nrdolote
         AND craplct.cdhistor IN (vr_cdhisopc_cot,vr_cdhisdep_cot,vr_cdhisdpp_cot,vr_cdhisdpa_cot,vr_cdhistar_cot,vr_cdhisaut_cot,vr_cdhisjur_cot);
    rw_craplct cr_craplct%ROWTYPE;
    								
    -- Cursor de lançamento de cotas em CC
    CURSOR cr_craplcm (pr_dtmvtocd crapdat.dtmvtocd%TYPE) IS
      SELECT sum(craplcm.vllanmto) vltotsob
        FROM craplcm
       WHERE craplcm.cdcooper  = pr_cdcooper
         AND craplcm.dtmvtolt >= TRUNC(pr_dtmvtocd,'YYYY')
         AND craplcm.nrdconta  = pr_nrdconta
         AND craplcm.cdagenci  = vr_cdagenci
         AND craplcm.cdbccxlt  = vr_cdbccxlt
         AND craplcm.nrdolote  = vr_nrdolote
         AND craplcm.cdhistor IN (vr_cdhisopc_cta,vr_cdhisdep_cta,vr_cdhisdpp_cta,vr_cdhisdpa_cta,vr_cdhistar_cta,vr_cdhisaut_cta);
    rw_craplcm cr_craplcm%ROWTYPE;
                     
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    vr_dtcomuni DATE; -- Data de comunicação 
    				
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;				
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   crapcri.dscritic%TYPE;
					
    -- Busca na CRAPTAB      
    vr_dstextab   craptab.dstextab%TYPE;
					
    -- Identificam se houve credito de retorno de sobras em cotas e/ou conta corrente
    vr_retcotas   boolean;
    vr_retccorr   boolean;
					
    BEGIN
			
    -- Iniciar variaveis de retorno
    pr_flgconsu := 0; -- Flag de consulta de lançamentos de cotas/capital
    pr_vltotsob := 0; -- Valor total das sobras
    pr_vlliqjur := 0; -- Valor liquido do crédito de juros sobre capital
      vr_retcotas := false;
      vr_retccorr := false;
      
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
			
      -- Busca os valores de juros da tabela de parametros
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXEICMIRET'
                                               ,pr_tpregist => 1);
      -- Se nao encontrou parametro cancela o programa
      IF TRIM(vr_dstextab) IS NULL THEN
				 vr_cdcritic := 0;
         vr_dscritic := 'Tabela de parametrizacao nao encontrada';
				 RAISE vr_exc_saida;
      END IF;				
			
		  BEGIN
        -- Captura data de comunicação a partir do resultado da consulta
		vr_dtcomuni := to_date(SUBSTR(vr_dstextab,67,10), 'dd/mm/rrrr');  
        EXCEPTION
          WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao capturar data de comunicacao: ' || SQLERRM;    
        RAISE vr_exc_saida;
      END;
        
    /* Enviar a comunicação até 15 dias após a data parametrizada */
    IF rw_crapdat.dtmvtolt BETWEEN vr_dtcomuni AND (vr_dtcomuni + gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTDIAS_BANNER_SOBRAS')) THEN
      -- Busca lançamentos de cotas
      OPEN cr_craplct(rw_crapdat.dtmvtocd);
      FETCH cr_craplct
       INTO rw_craplct;
      -- Se encontrar
      IF cr_craplct%FOUND THEN
        CLOSE cr_craplct;
        -- Copiar aos parâmetros de saída
        pr_vlliqjur := nvl(rw_craplct.vlliqjur,0);
        pr_vltotsob := nvl(rw_craplct.vltotsob,0);
          IF nvl(rw_craplct.vltotsob,0) > 0 THEN
            vr_retcotas := true;
          END IF;
      ELSE
        CLOSE cr_craplct;
      END IF;  
       -- Busca lançamentos de cotas em CC
      OPEN cr_craplcm(rw_crapdat.dtmvtocd);
      FETCH cr_craplcm
       INTO rw_craplcm;
      -- Se encontrar
      IF cr_craplcm%FOUND THEN
        CLOSE cr_craplcm;
        -- Copiar aos parâmetros de saída
        pr_vltotsob := pr_vltotsob + nvl(rw_craplcm.vltotsob,0);
          IF nvl(rw_craplcm.vltotsob,0) > 0 THEN
            vr_retccorr := true;
          END IF;
      ELSE
        CLOSE cr_craplcm;
						END IF;            
        
        /* Carrega o pr_flgconsu de acordo com a forma que as sobras foram creditadas:
           1 - Credito em cotas capital
           2 - Credito em Conta Corrente
           3 - Credito em cotas capital e conta corrente 
           Obs. Caso tenha sido realizado apenas o credito de juros, para o IB basta que flgconsu seja > 0 */
      IF pr_vlliqjur + pr_vltotsob > 0 THEN
          IF vr_retcotas THEN
            IF vr_retccorr THEN
              pr_flgconsu := 3;
            ELSE
        pr_flgconsu := 1;
						END IF;
          ELSE
            pr_flgconsu := 2;
          END IF;
        END IF;
        
			END IF;
			
			EXCEPTION
			  WHEN vr_exc_saida THEN
					-- Se foi retornado apenas código
					IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
						-- Buscar a descrição
						vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
					END IF;
					-- Devolvemos código e critica encontradas das variaveis locais
					pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := 'SOBR0001.pc_verifica_conta_capital --> '|| vr_dscritic;
					-- Efetuar rollback
					ROLLBACK;
      
				WHEN OTHERS THEN
					-- Efetuar retorno do erro não tratado
					pr_cdcritic := 0;
      pr_dscritic :=  'SOBR0001.pc_verifica_conta_capital --> '||sqlerrm;
					-- Efetuar rollback
					ROLLBACK;			
    END;
  END pc_verifica_conta_capital;

END sobr0001;
/
