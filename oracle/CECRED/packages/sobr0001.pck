CREATE OR REPLACE PACKAGE CECRED.sobr0001 AS
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
           vldeirrf NUMBER(17,2),
           percirrf NUMBER(8,2),
           vlcredit NUMBER(17,2),
           vlcretot NUMBER(17,2));
  TYPE typ_tab_crrl412 IS
    TABLE OF typ_reg_crrl412
    INDEX BY VARCHAR2(15);

  -- Emite relatorio detalhado dos creditos do retorno de sobras. (CRRL412)
  PROCEDURE pc_emite_detalhe_ret_sobras(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE   --> Programa chamador
                                       ,pr_tab_crrl412 typ_tab_crrl412         --> Temp-table com os dados para o relatorio
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada

  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_emite_retorno_sobras(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
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

  -- Emite relatorio detalhado dos creditos do retorno de sobras. (CRRL412)
  PROCEDURE pc_emite_detalhe_ret_sobras(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE   --> Programa chamador
                                       ,pr_tab_crrl412 typ_tab_crrl412         --> Temp-table com os dados para o relatorio
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* ..........................................................................

   Programa : pc_emite_detalhe_ret_sobras    Antigo: crps048_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/2005                      Ultima atualizacao: 16/05/2016

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Atende a solicitacao 30.
               Emite relatorio detalhado dos creditos do retorno de sobras
               (412).

   Alteracoes: 15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               23/02/2006 - Tratar sinal no campo de retorno do capital
                            (Edson).

               14/10/2008 - Adaptacao para desconto de titulos (David).

               02/04/2009 - Alterado LABEL da coluna "BASE JURO CAPITAL" para
                            "BASE CAPITAL" (Elton).

               16/02/2011 - Novo layout
                            - (dsc chq + dsc tit + epr) = OPER. CREDITOS
                            - IRRF e RETORNO + JUROS (Guilherme)

               22/03/2011 - Aumento das casas decimais para 8 dig (Guilherme).


               09/09/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               09/10/2013 - Tratamento para Imunidade Tributaria (Ze).

               29/10/2013 - Ajuste na instancia da BO 159 (Ze).

               27/01/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

               14/03/2014 - Converter arquivo ux2dos antes de enviar (Gabriel)

               09/11/2015 - Acrescentado sobras sobre tarifas pagas (Dionathan)

               08/12/2015 - Acrescentado percentual de IRRF (Dionathan)
               
               16/05/2016 - Removido o cursor da craptab e utilizado a chamada da 
                            TABE0001.fn_busca_dstextab que possui os tratamentos
                            para utilizacao do indice da tabela na procedure
                            pc_verifica_conta_capital (Douglas - Chamado 452286)
               
---------------------------------------------------------------------------------------------------------------*/

      -- Cursor de agencia
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis de XML
      vr_xml      CLOB;
      vr_xml_tot  CLOB;

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
      vr_pac_vlcredit NUMBER(17,2) :=0;
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
      vr_tot_vlcredit NUMBER(17,2) :=0;
      vr_tot_vlcretot NUMBER(17,2) :=0;


      -- variaveis utilizadas no relatorio
      vr_rel_dsagenci VARCHAR2(100);
      vr_dsprvdef     VARCHAR2(100);


      -- Percentuais impressos logo apos o PA
      vr_txdretor     NUMBER(17,10);
      vr_txjurcap     NUMBER(17,10);
      vr_txjurapl     NUMBER(17,10);
      vr_txjursdm     NUMBER(17,10);
      vr_txjurtar     NUMBER(17,10);

      -- Variaveis gerais
      vr_indice_412 VARCHAR2(15); -- Indice para a temp-table do parametro
      vr_dstextab   craptab.dstextab%TYPE; -- Retorno da rotina TABE0001.fn_busca_dstextab
      vr_nom_direto VARCHAR2(200); -- Local onde sera gravado o relatorio
      vr_nom_direto_copia VARCHAR2(200); -- Local onde sera gravado a copia do relatorio
      vr_dsextcop   VARCHAR2(03); -- Extensao do arquivo de copia
      vr_cdprogra    crapprg.cdprogra%TYPE; -- programa que esta sendo executado

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_destino   IN INTEGER,
                               pr_des_dados IN VARCHAR2) IS
        BEGIN
          IF pr_destino = 1 THEN
            --Escrever no arquivo CLOB
            dbms_lob.writeappend(vr_xml,length(pr_des_dados),pr_des_dados);
          ELSE
            dbms_lob.writeappend(vr_xml_tot,length(pr_des_dados),pr_des_dados);
          END IF;
        END pc_escreve_xml;

    BEGIN -- Principal

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

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      dbms_lob.createtemporary(vr_xml_tot, TRUE);
      dbms_lob.open(vr_xml_tot, dbms_lob.lob_readwrite);

      vr_cdprogra := pr_cdprogra;

      -- Busca os valores de juros da tabela de parametros
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXEICMIRET'
                                               ,pr_tpregist => 1);
      -- Se nao encontrou parametro cancela o programa
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 283;
        RAISE vr_exc_saida;
      END IF;
      
      vr_txdretor := SUBSTR(vr_dstextab,05,12);
      vr_txjurcap := SUBSTR(vr_dstextab,20,13);
      vr_txjurapl := SUBSTR(vr_dstextab,33,12);
      vr_txjursdm := SUBSTR(vr_dstextab,54,12);
      vr_txjurtar := SUBSTR(vr_dstextab,78,12);
      
      IF SUBSTR(vr_dstextab,18,1) = 1 THEN
        vr_dsprvdef := '*** CALCULO DEFINITIVO *** Lancamentos correspondentes realizados';
      ELSE
        vr_dsprvdef := '*** SOMENTE PREVIA ***';
      END IF;

      -- Escreve o cabecalho inicial do XML
      pc_escreve_xml(1,
                     '<?xml version="1.0" encoding="ISO-8859-1"?>'||chr(10)||
                     '<crrl412>');

      -- Escreve o nó do total
      pc_escreve_xml(2,
                     '<total>'||
                       '<dsprvdef>' || vr_dsprvdef                         || '</dsprvdef>' ||
                       '<txjurcap>' || to_char(vr_txjurcap,'FM990D00000000') || '%</txjurcap>' ||
                       '<txdretor>' || to_char(vr_txdretor,'FM990D00000000') || '%</txdretor>' ||
                       '<txjurapl>' || to_char(vr_txjurapl,'FM990D00000000') || '%</txjurapl>' ||
                       '<txjursdm>' || to_char(vr_txjursdm,'FM990D00000000') || '%</txjursdm>' ||
                       '<txjurtar>' || to_char(vr_txjurtar,'FM990D00000000') || '%</txjurtar>');

      -- Vai para o primeiro registro do temp-table
      vr_indice_412 := pr_tab_crrl412.first;

      -- Efetua a varredura do temp-table
      WHILE vr_indice_412 IS NOT NULL LOOP

        -- verifica se eh a primeira agencia
        IF vr_indice_412 = pr_tab_crrl412.first OR   -- Primeiro registro
           pr_tab_crrl412(vr_indice_412).cdagenci <> pr_tab_crrl412(pr_tab_crrl412.prior(vr_indice_412)).cdagenci THEN -- Agencia anterior diferente da atual

          -- Busca o nome da agencia
          OPEN cr_crapage(pr_tab_crrl412(vr_indice_412).cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            vr_rel_dsagenci := to_char(pr_tab_crrl412(vr_indice_412).cdagenci,'000') ||
                                 '-NAO CADASTRADO';
          ELSE
            vr_rel_dsagenci := to_char(pr_tab_crrl412(vr_indice_412).cdagenci,'000') || '-' ||
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
          vr_pac_vlcredit := 0;
          vr_pac_vlcretot := 0;

          -- Escreve o no de agencia e os percentuais da mesma
          pc_escreve_xml(1,
                         '<pa>'||
                           '<dsagenci>' || vr_rel_dsagenci                     || '</dsagenci>' ||
                           '<dsprvdef>' || vr_dsprvdef                         || '</dsprvdef>' ||
                           '<txjurcap>' || to_char(vr_txjurcap,'FM990D00000000') || '%</txjurcap>' ||
                           '<txdretor>' || to_char(vr_txdretor,'FM990D00000000') || '%</txdretor>' ||
                           '<txjurapl>' || to_char(vr_txjurapl,'FM990D00000000') || '%</txjurapl>' ||
                           '<txjursdm>' || to_char(vr_txjursdm,'FM990D00000000') || '%</txjursdm>' ||
                           '<txjurtar>' || to_char(vr_txjurtar,'FM990D00000000') || '%</txjurtar>');
        END IF;

        -- Escreve a linha de detalhe
        pc_escreve_xml(1,
                       '<detalhe>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(pr_tab_crrl412(vr_indice_412).nrdconta)    ||'</nrdconta>'||
                         '<nmprimtl>'||pr_tab_crrl412(vr_indice_412).nmprimtl                            ||'</nmprimtl>'||
                         '<vlmedcap>'||to_char(pr_tab_crrl412(vr_indice_412).vlmedcap,'FM999G999G990D00MI')||'</vlmedcap>'||
                         '<vlretcap>'||to_char(pr_tab_crrl412(vr_indice_412).vlretcap,'FM999G999G990D00MI')||'</vlretcap>'||
                         '<vlbasopc>'||to_char(pr_tab_crrl412(vr_indice_412).vlbasopc,'FM999G999G990D00MI')||'</vlbasopc>'||
                         '<vlretopc>'||to_char(pr_tab_crrl412(vr_indice_412).vlretopc,'FM999G999G990D00MI')||'</vlretopc>'||
                         '<vlbasapl>'||to_char(pr_tab_crrl412(vr_indice_412).vlbasapl,'FM999G999G990D00MI')||'</vlbasapl>'||
                         '<vlretapl>'||to_char(pr_tab_crrl412(vr_indice_412).vlretapl,'FM999G999G990D00MI')||'</vlretapl>'||
                         '<vlcredit>'||to_char(pr_tab_crrl412(vr_indice_412).vlcredit,'FM999G999G990D00MI')||'</vlcredit>'||
                         '<vlbassdm>'||to_char(pr_tab_crrl412(vr_indice_412).vlbassdm,'FM999G999G990D00MI')||'</vlbassdm>'||
                         '<vlretsdm>'||to_char(pr_tab_crrl412(vr_indice_412).vlretsdm,'FM999G999G990D00MI')||'</vlretsdm>'||
                         '<vldeirrf>'||to_char(pr_tab_crrl412(vr_indice_412).vldeirrf,'FM999G999G990D00MI')||'</vldeirrf>'||
                         '<percirrf>'||to_char(pr_tab_crrl412(vr_indice_412).percirrf,'FM999G999G990D00MI')||'</percirrf>'||
                         '<vlbastar>'||to_char(pr_tab_crrl412(vr_indice_412).vlbastar,'FM999G999G990D00MI')||'</vlbastar>'||
                         '<vlrettar>'||to_char(pr_tab_crrl412(vr_indice_412).vlrettar,'FM999G999G990D00MI')||'</vlrettar>'||
                         '<vlcretot>'||to_char(pr_tab_crrl412(vr_indice_412).vlcretot,'FM999G999G990D00MI')||'</vlcretot>'||
                       '</detalhe>');

        -- Acumula os valores para formar o total do PA
        vr_pac_qtassoci := vr_pac_qtassoci + 1;
        vr_pac_vlmedcap := vr_pac_vlmedcap + pr_tab_crrl412(vr_indice_412).vlmedcap;
        vr_pac_vlbascap := vr_pac_vlbascap + pr_tab_crrl412(vr_indice_412).vlbascap;
        vr_pac_vlretcap := vr_pac_vlretcap + pr_tab_crrl412(vr_indice_412).vlretcap;
        vr_pac_vlbasopc := vr_pac_vlbasopc + pr_tab_crrl412(vr_indice_412).vlbasopc;
        vr_pac_vlretopc := vr_pac_vlretopc + pr_tab_crrl412(vr_indice_412).vlretopc;
        vr_pac_vlbasapl := vr_pac_vlbasapl + pr_tab_crrl412(vr_indice_412).vlbasapl;
        vr_pac_vlretapl := vr_pac_vlretapl + pr_tab_crrl412(vr_indice_412).vlretapl;
        vr_pac_vlbassdm := vr_pac_vlbassdm + pr_tab_crrl412(vr_indice_412).vlbassdm;
        vr_pac_vlretsdm := vr_pac_vlretsdm + pr_tab_crrl412(vr_indice_412).vlretsdm;
        vr_pac_vldeirrf := vr_pac_vldeirrf + pr_tab_crrl412(vr_indice_412).vldeirrf;
        vr_pac_vlbastar := vr_pac_vlbastar + pr_tab_crrl412(vr_indice_412).vlbastar;
        vr_pac_vlrettar := vr_pac_vlrettar + pr_tab_crrl412(vr_indice_412).vlrettar;
        vr_pac_vlcredit := vr_pac_vlcredit + pr_tab_crrl412(vr_indice_412).vlcredit;
        vr_pac_vlcretot := vr_pac_vlcretot + pr_tab_crrl412(vr_indice_412).vlcretot;

        -- Verifica se eh o ultimo registro do PA
        IF vr_indice_412 = pr_tab_crrl412.last OR   -- Primeiro registro
           pr_tab_crrl412(vr_indice_412).cdagenci <> pr_tab_crrl412(pr_tab_crrl412.next(vr_indice_412)).cdagenci THEN -- Agencia anterior diferente da atual
          -- gera o total do PA
          pc_escreve_xml(1,'<pa_qtassoci>'||to_char(vr_pac_qtassoci,'FM999G999')         || '</pa_qtassoci>' ||
                           '<pa_vlmedcap>'||to_char(vr_pac_vlmedcap,'FM999G999G990D00MI')|| '</pa_vlmedcap>'||
                           '<pa_vlretcap>'||to_char(vr_pac_vlretcap,'FM999G999G990D00MI')|| '</pa_vlretcap>'||
                           '<pa_vlbasopc>'||to_char(vr_pac_vlbasopc,'FM999G999G990D00MI')|| '</pa_vlbasopc>'||
                           '<pa_vlretopc>'||to_char(vr_pac_vlretopc,'FM999G999G990D00MI')|| '</pa_vlretopc>'||
                           '<pa_vlbasapl>'||to_char(vr_pac_vlbasapl,'FM999G999G990D00MI')|| '</pa_vlbasapl>'||
                           '<pa_vlretapl>'||to_char(vr_pac_vlretapl,'FM999G999G990D00MI')|| '</pa_vlretapl>'||
                           '<pa_vlcredit>'||to_char(vr_pac_vlcredit,'FM999G999G990D00MI')|| '</pa_vlcredit>'||
                           '<pa_vlbassdm>'||to_char(vr_pac_vlbassdm,'FM999G999G990D00MI')|| '</pa_vlbassdm>'||
                           '<pa_vlretsdm>'||to_char(vr_pac_vlretsdm,'FM999G999G990D00MI')|| '</pa_vlretsdm>'||
                           '<pa_vldeirrf>'||to_char(vr_pac_vldeirrf,'FM999G999G990D00MI')|| '</pa_vldeirrf>'||
                           '<pa_vlbastar>'||to_char(vr_pac_vlbastar,'FM999G999G990D00MI')|| '</pa_vlbastar>'||
                           '<pa_vlrettar>'||to_char(vr_pac_vlrettar,'FM999G999G990D00MI')|| '</pa_vlrettar>'||
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
                           '<pa_vlbassdm>'||to_char(vr_pac_vlbassdm,'FM999G999G990D00MI')|| '</pa_vlbassdm>'||
                           '<pa_vlretsdm>'||to_char(vr_pac_vlretsdm,'FM999G999G990D00MI')|| '</pa_vlretsdm>'||
                           '<pa_vldeirrf>'||to_char(vr_pac_vldeirrf,'FM999G999G990D00MI')|| '</pa_vldeirrf>'||
                           '<pa_vlbastar>'||to_char(vr_pac_vlbastar,'FM999G999G990D00MI')|| '</pa_vlbastar>'||
                           '<pa_vlrettar>'||to_char(vr_pac_vlrettar,'FM999G999G990D00MI')|| '</pa_vlrettar>'||
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
          vr_tot_vlcredit := vr_tot_vlcredit + vr_pac_vlcredit;
          vr_tot_vlcretot := vr_tot_vlcretot + vr_pac_vlcretot;

        END IF;

        -- Vai para a proxima linha do temp-table
        vr_indice_412 := pr_tab_crrl412.next(vr_indice_412);
      END LOOP;

      -- Imprime o total geral
      pc_escreve_xml(2,'<tot_qtassoci>'||to_char(vr_tot_qtassoci,'FM999G999')         || '</tot_qtassoci>' ||
                       '<tot_vlmedcap>'||to_char(vr_tot_vlmedcap,'FM999G999G990D00MI')|| '</tot_vlmedcap>'||
                       '<tot_vlretcap>'||to_char(vr_tot_vlretcap,'FM999G999G990D00MI')|| '</tot_vlretcap>'||
                       '<tot_vlbasopc>'||to_char(vr_tot_vlbasopc,'FM999G999G990D00MI')|| '</tot_vlbasopc>'||
                       '<tot_vlretopc>'||to_char(vr_tot_vlretopc,'FM999G999G990D00MI')|| '</tot_vlretopc>'||
                       '<tot_vlbasapl>'||to_char(vr_tot_vlbasapl,'FM999G999G990D00MI')|| '</tot_vlbasapl>'||
                       '<tot_vlretapl>'||to_char(vr_tot_vlretapl,'FM999G999G990D00MI')|| '</tot_vlretapl>'||
                       '<tot_vlcredit>'||to_char(vr_tot_vlcredit,'FM999G999G990D00MI')|| '</tot_vlcredit>'||
                       '<tot_vlbassdm>'||to_char(vr_tot_vlbassdm,'FM999G999G990D00MI')|| '</tot_vlbassdm>'||
                       '<tot_vlretsdm>'||to_char(vr_tot_vlretsdm,'FM999G999G990D00MI')|| '</tot_vlretsdm>'||
                       '<tot_vldeirrf>'||to_char(vr_tot_vldeirrf,'FM999G999G990D00MI')|| '</tot_vldeirrf>'||
                       '<tot_vlbastar>'||to_char(vr_tot_vlbastar,'FM999G999G990D00MI')|| '</tot_vlbastar>'||
                       '<tot_vlrettar>'||to_char(vr_tot_vlrettar,'FM999G999G990D00MI')|| '</tot_vlrettar>'||
                       '<tot_vlcretot>'||to_char(vr_tot_vlcretot,'FM999G999G990D00MI')|| '</tot_vlcretot>'||
                     '</total>');

      -- Concatena o xml de totais no xml principal
      dbms_lob.append(dest_lob => vr_xml ,src_lob => vr_xml_tot);

      -- Fecha o nó principal
      pc_escreve_xml(1,'</crrl412>');


      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl'); --> Utilizaremos o contab

      -- Se for previa fazer copia do relatorio
      IF SUBSTR(vr_dstextab,18,1) <> 1 THEN
        -- Busca do diretorio base da cooperativa
        vr_nom_direto_copia := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /usr/coop
                                                    ,pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsubdir => 'contab'); --> Utilizaremos o contab
        vr_dsextcop := 'txt';
      END IF;
      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_cdrelato  => 412,                            --> Código do relatório
                                  pr_dsxml     => vr_xml,                         --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl412',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl412.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl412.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 234,                            --> Quantidade de colunas
                                  pr_nmformul  => '234dh',                        --> Nome do formulario
                                  pr_dspathcop => vr_nom_direto_copia,            --> Lista sep. por ';' de diretórios a copiar o relatório
                                  pr_fldoscop  => 'S',                            --> Flag para converter o arquivo gerado em DOS antes da cópia
                                  pr_dscmaxcop => '',                             --> Comando auxiliar para o comando ux2dos na cópia de diretório
                                  pr_dsextcop  => vr_dsextcop,                    --> Extensao do arquivo da copia
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;


      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Libera a memoria do clob vr_xml_567
      dbms_lob.close(vr_xml);
      dbms_lob.close(vr_xml_tot);


    EXCEPTION
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


  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_emite_retorno_sobras(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                   ,pr_cdprogra IN crapprg.cdprogra%TYPE   --> Programa chamador
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada


/* .............................................................................

   Programa: SOBR0001 (includes/crps048.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei - Precise
   Data    : Abril/2008                        Ultima atualizacao: 09/02/2015
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
      vr_ininccmi PLS_INTEGER;
      vr_increret PLS_INTEGER;
      vr_txdretor NUMBER(17,10);
      vr_txjurcap NUMBER(17,10);
      vr_txjurapl NUMBER(17,10);
      vr_txjursdm NUMBER(17,10);
      vr_txjurtar NUMBER(17,10);
      vr_indeschq PLS_INTEGER;
      vr_indemiti PLS_INTEGER; -- Identificador de eh para considerar demitidos
      vr_indestit PLS_INTEGER; -- Identificador se deve calcular descontos sobre titulos

      rl_txdretor NUMBER(17,8);
      rl_txretdsc NUMBER(17,8);
      rl_txrettit NUMBER(17,8);

      rl_dsprvdef VARCHAR2(50);
      vr_dtliminf DATE;
      vr_dtlimsup DATE;
      vr_dtinimes DATE;
      vr_dtfimmes DATE;
      vr_dtmvtolt DATE;
      vr_nom_direto VARCHAR2(500);       -- Diretorio da geracao dos arquivos
      vr_nom_direto_copia VARCHAR2(500); -- Diretorio da geracao da copia do arquivo CRRL043.lst
      vr_dtrefere DATE;
      vr_vlcmicot NUMBER(17,2);
      vr_flgdemit INTEGER;
      vr_nrdconta crapass.nrdconta%TYPE;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_qtraimfx crapcot.qtraimfx%TYPE;
      vr_vlrendim NUMBER(17,2) :=0;
      vr_vlretdsc NUMBER(17,2) :=0;
      vr_vlbasdsc NUMBER(17,2) :=0;
      vr_vlrettit NUMBER(17,2) :=0;
      vr_vlbastit NUMBER(17,2) :=0;
      vr_vlbasret NUMBER(17,2) :=0;
      vr_vlbasapl NUMBER(17,2) :=0;
      vr_vldretor NUMBER(17,2) :=0;
      vr_vltotcre NUMBER(17,2) :=0;
      vr_vljurapl NUMBER(17,2) :=0;
      vr_vlretdep NUMBER(17,2) :=0;
      vr_vltotjur NUMBER(17,2) :=0;
      vr_vlretcrd NUMBER(17,2) :=0; 
      vr_vlbassdm NUMBER(17,2) :=0;
      vr_vlbastar NUMBER(17,2) :=0;
      vr_vljurtar NUMBER(17,2) :=0;
      vr_vlbasjur NUMBER(17,2) :=0;
      vr_vljurcap NUMBER(17,2) :=0;
      vr_vlmedcap NUMBER(17,2) :=0;
      vr_vldeirrf NUMBER(17,2) :=0;
      vr_vljursdm NUMBER(17,2) :=0;
      vr_flgimune BOOLEAN;
      vr_vlcredit NUMBER(17,2) :=0;
      vr_vlcrecap NUMBER(17,2) :=0;
      vr_vlcretot NUMBER(17,2) :=0;
      vr_vlpvardc NUMBER(17,2) :=0;

      vr_execucao BOOLEAN := FALSE;

      tt_vlbasapl NUMBER(17,2) :=0;
      tt_vljurapl NUMBER(17,2) :=0;
      tt_vlbassdm NUMBER(17,2) :=0;
      tt_vlmedcap NUMBER(17,2) :=0;
      tt_vljursdm NUMBER(17,2) :=0;
      tt_vljurcap NUMBER(17,2) :=0;
      tt_vldeirrf NUMBER(17,2) :=0;
      tt_vlcmicot NUMBER(17,2) :=0;
      tt_qtassinc NUMBER(17,2) :=0;
      tt_qtraimfx NUMBER(17,2) :=0;
      tt_vlbasret NUMBER(17,2) :=0;
      tt_vldretor NUMBER(17,2) :=0;
      tt_vlbasdsc NUMBER(17,2) :=0;
      tt_vlretdsc NUMBER(17,2) :=0;
      tt_vlbastit NUMBER(17,2) :=0;
      tt_vlrettit NUMBER(17,2) :=0;
      tt_vlbastar NUMBER(17,2) :=0;
      tt_vljurtar NUMBER(17,2) :=0;
      tt_qtassret NUMBER(17,2) :=0;
      tt_qtassdsc NUMBER(17,2) :=0;
      tt_qtassapl NUMBER(17,2) :=0;
      tt_qtasstit NUMBER(17,2) :=0;
      tt_qtasssdm NUMBER(17,2) :=0;
      tt_qtasscap NUMBER(17,2) :=0;
      tt_qtasstar NUMBER(17,2) :=0;
      tt_vlcredit NUMBER(17,2) :=0;
      tt_vlcretot NUMBER(17,2) :=0;
      tt_qtcredit NUMBER(17,2) :=0;
      tt_qtretcrd NUMBER(17,2) :=0;
      tt_qtretdep NUMBER(17,2) :=0;
      tt_qtcrecap NUMBER(17,2) :=0;
      tt_qtcretot NUMBER(17,2) :=0;
      tt_dstipcre VARCHAR2(50);
      tt_dsdemiti VARCHAR2(03); -- Data da demissao
      vr_flg_ctamigra BOOLEAN; -- Identificador se a conta foi migrada
      vr_cdagenci crapass.cdagenci%TYPE := 1; -- Codigo da agencia
      vr_cdbccxlt craplot.cdbccxlt%TYPE := 100; -- Codigo do banco / caixa
      vr_nrdolote craplot.nrdolote%TYPE := 8005; -- Numero do lote
      vr_flgclote BOOLEAN := TRUE; -- Indicador de primeiro processo do lote
      vr_dsdestin VARCHAR2(500); -- Destinatarios do email quando for uma execucao previa

      -- Vetor para armazenar os dados para o relatorio CRRL412
      vr_tab_crrl412 typ_tab_crrl412;
      vr_indice_412  VARCHAR2(15);  -- agencia + conta

      -- Variaveis de retorno de erro
      vr_dsreturn  VARCHAR2(3);
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Variaveis de XML
      vr_xml      CLOB;

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

      -- Cursor com informacoes referentes a cotas e recursos
      CURSOR cr_crapcot(pr_nrdconta crapcor.nrdconta%TYPE) IS
        SELECT cdcooper,
               nrdconta,
               vlcmicot,
               qtraimfx,
               vlrearda,
               vlrearpp,
               vlpvardc,
               ROWID
          FROM crapcot
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = nvl(pr_nrdconta, nrdconta);
      rw_crapcot cr_crapcot%ROWTYPE;
      
      -- Cursor para buscar faixa de IRRF a ser cobrada
      CURSOR cr_fairrf(pr_inpessoa IN tbcotas_faixas_irrf.inpessoa%TYPE
                      ,pr_valor    IN tbcotas_faixas_irrf.vlfaixa_inicial%TYPE) IS
      SELECT fairrf.vlpercentual_irrf
            ,fairrf.vldeducao
        FROM tbcotas_faixas_irrf fairrf
       WHERE fairrf.inpessoa = pr_inpessoa
         AND pr_valor BETWEEN fairrf.vlfaixa_inicial AND fairrf.vlfaixa_final;
      rw_fairrf cr_fairrf%ROWTYPE;
      cr_fairrf_found BOOLEAN;
      
      -- Cursor com informações das tarifas pagas      
      CURSOR cr_tbcotas_tarifas_pagas(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT GREATEST(NVL(MAX(ctp.vlpagoanoant),0),0) vlbastar -- NVL(MAX(x),0) para forçar um registro zerado quando não houver dados, GREATEST(x,0) para trazer 0 quando for valor negativo
        FROM tbcotas_tarifas_pagas ctp
       WHERE ctp.cdcooper = pr_cdcooper
         AND ctp.nrdconta = pr_nrdconta;
       rw_tbcotas_tarifas_pagas cr_tbcotas_tarifas_pagas%ROWTYPE;

      -- Cursor sobre a tabela de associados
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT inpessoa,
               dtelimin,
               cdagenci,
               nmprimtl
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor de contas transferidas entre cooperativas
      CURSOR cr_craptco(pr_nrdconta craptco.nrdconta%TYPE,
                        pr_tpctatrf craptco.tpctatrf%TYPE,
                        pr_flgativo craptco.flgativo%TYPE,
                        pr_cdcopant craptco.cdcopant%TYPE) IS
        SELECT craptco.cdcooper
              ,craptco.nrdconta
          FROM craptco
         WHERE craptco.cdcooper = pr_cdcooper
           AND craptco.nrdconta = pr_nrdconta
           AND craptco.tpctatrf = pr_tpctatrf
           AND craptco.flgativo = pr_flgativo
           AND craptco.cdcopant = nvl(pr_cdcopant, craptco.cdcopant);

      rw_craptco cr_craptco%ROWTYPE;

      -- Cursor de dados de geracao do extrato do Imposto de Renda
      CURSOR cr_crapdir(pr_nrdconta crapdir.nrdconta%TYPE,
                        pr_dtmvtolt crapdir.dtmvtolt%TYPE) IS
        SELECT smposano##1 + smposano##2 + smposano##3 + smposano##4 +  smposano##5 +  smposano##6 +
               smposano##7 + smposano##8 + smposano##9 + smposano##10 + smposano##11 + smposano##12 smposano,
               vlcapmes##1 + vlcapmes##2 + vlcapmes##3 + vlcapmes##4 +  vlcapmes##5 +  vlcapmes##6 +
               vlcapmes##7 + vlcapmes##8 + vlcapmes##9 + vlcapmes##10 + vlcapmes##11 + vlcapmes##12 vlcapmes,
               dtdemiss, smposano##12, vlcapmes##12, vlrenrda##12, vlrenrpp_ir##12
          FROM crapdir
         WHERE crapdir.cdcooper = pr_cdcooper
           AND crapdir.nrdconta = pr_nrdconta
           AND crapdir.dtmvtolt = pr_dtmvtolt;
      rw_crapdir cr_crapdir%ROWTYPE;

      -- Cursor sobre os dados de lancamentos de cotas / capital
      CURSOR cr_craplct(pr_nrdconta craplct.nrdconta%TYPE,
                        pr_dtmvtolt craplct.dtmvtolt%TYPE) IS
        SELECT cdhistor,
               vllanmto
          FROM craplct
         WHERE craplct.cdcooper =  pr_cdcooper
           AND craplct.dtmvtolt >= pr_dtmvtolt
           AND craplct.nrdconta =  pr_nrdconta;
      rw_craplct cr_craplct%ROWTYPE;

      -- Cursor sobre a tabela de historicos do sistema
      CURSOR cr_craphis(pr_cdhistor craphis.cdhistor%TYPE) IS
        SELECT inhistor
          FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper
           AND craphis.cdhistor = pr_cdhistor;
      rw_craphis cr_craphis%ROWTYPE;

      -- cursor de lancamento de juros de desconto de cheques
      CURSOR cr_crapljd(pr_nrdconta crapass.nrdconta%TYPE,
                        pr_dtrefere_ini DATE,
                        pr_dtrefere_fim DATE) IS
        SELECT nvl(SUM(vldjuros),0)
          FROM crapljd
         WHERE crapljd.cdcooper = pr_cdcooper
           AND crapljd.nrdconta = pr_nrdconta
           AND crapljd.dtrefere > pr_dtrefere_ini
           AND crapljd.dtrefere < pr_dtrefere_fim;

      -- Cursor sobre o lancamento de juros de desconto de titulos
      CURSOR cr_crapljt(pr_nrdconta crapass.nrdconta%TYPE,
                        pr_dtrefere_ini DATE,
                        pr_dtrefere_fim DATE) IS
        SELECT nvl(SUM(vldjuros),0)
          FROM crapljt
          WHERE crapljt.cdcooper = pr_cdcooper
            AND crapljt.nrdconta = pr_nrdconta
            AND crapljt.dtrefere > pr_dtrefere_ini
            AND crapljt.dtrefere < pr_dtrefere_fim;

      -- Cursor sobre a tabela de lotes
      CURSOR cr_craplot(pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_cdbccxlt craplot.cdbccxlt%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT nrseqdig
          FROM craplot
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      -- Cursor sobre a tabela de Juros Empréstimos
      CURSOR cr_craplem(pr_cdcooper craplem.cdcooper%TYPE,
                        pr_nrdconta craplem.nrdconta%TYPE) IS

        SELECT craplem.vllanmto 
        FROM craplem
        WHERE craplem.cdcooper = pr_cdcooper
          AND craplem.nrdconta = pr_nrdconta
          AND craplem.dtmvtolt >= to_date('01/12/2014','dd/mm/RRRR')
          AND craplem.dtmvtolt <= to_date('31/12/2014','dd/mm/RRRR')
          AND craplem.cdhistor IN (98,1037,1038);

      rw_craplem cr_craplem%ROWTYPE;

      -- Cursor sobre a tabela de Lancamentos
      CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%TYPE,
                        pr_nrdconta craplcm.nrdconta%TYPE) IS

        SELECT craplcm.vllanmto  
        FROM craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
          AND craplcm.nrdconta = pr_nrdconta
          AND craplcm.dtmvtolt >= to_date('01/12/2014','dd/mm/RRRR')
          AND craplcm.dtmvtolt <= to_date('31/12/2014','dd/mm/RRRR')
          AND craplcm.cdhistor IN (37,38,57);

      rw_craplcm cr_craplcm%ROWTYPE;

      -- Cursor sobre a tabela de lancamentos de aplicacoes RDCA.
      CURSOR cr_craplap(pr_cdcooper craplap.cdcooper%TYPE,
                        pr_nrdconta craplap.nrdconta%TYPE) IS

        SELECT craplap.cdhistor, craplap.vllanmto
        FROM craplap 
        WHERE craplap.cdcooper = pr_cdcooper
          AND craplap.nrdconta = pr_nrdconta
          AND craplap.dtmvtolt >= to_date('01/12/2014','dd/mm/RRRR')
          AND craplap.dtmvtolt <= to_date('31/12/2014','dd/mm/RRRR')
          AND craplap.cdhistor IN (474,529,475,532,463,531);

      rw_craplap cr_craplap%ROWTYPE;

      -- Definicao do tipo de tabela para o processo definitivo. Eh a copia do arquivo CRRL048.DAT
      TYPE typ_reg_crrl048 IS
        RECORD(nrdconta crapass.nrdconta%TYPE,
               vlcmicot NUMBER(17,2),
               qtraimfx crapcot.qtraimfx%TYPE,
               vlbasret NUMBER(17,2),
               vldretor NUMBER(17,2),
               inpessoa NUMBER(17,2),
               vlbasjur NUMBER(17,2),
               vljurcap NUMBER(17,2),
               vlbasapl NUMBER(17,2),
               vljurapl NUMBER(17,2),
               vlretdsc NUMBER(17,2),
               vlrettit NUMBER(17,2),
               vldeirrf NUMBER(17,2),
               vlbassdm NUMBER(17,2),
               vljursdm NUMBER(17,2),
               vlretcrd NUMBER(17,2),
               vlretdep NUMBER(17,2),
               vlbastar NUMBER(17,2),
               vljurtar NUMBER(17,2));
      TYPE typ_tab_crrl048 IS
        TABLE OF typ_reg_crrl048
        INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados para o processo definitivo
      vr_tab_crrl048 typ_tab_crrl048;
      vr_indice PLS_INTEGER := 0;
      
      PROCEDURE pc_controle_critica IS
      BEGIN
        vr_dscritic := nvl(vr_dscritic,gene0001.fn_busca_critica(vr_cdcritic));
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END;

      -- Procedure para o caluclo de juros e desconto
      PROCEDURE pc_totaliza_juros_desconto(pr_nrdconta crapass.nrdconta%TYPE) IS
      BEGIN

        -- busca de desconto de cheques
        OPEN cr_crapljd(pr_nrdconta,
                        vr_dtliminf,
                        vr_dtlimsup);
        FETCH cr_crapljd INTO vr_vlbasdsc;
        CLOSE cr_crapljd;


        -- busca de juros de descontos de titulos
        OPEN cr_crapljt(pr_nrdconta,
                        vr_dtliminf,
                        vr_dtlimsup);
        FETCH cr_crapljt INTO vr_vlbastit;
        CLOSE cr_crapljt;
      END pc_totaliza_juros_desconto;

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_xml,length(pr_des_dados),pr_des_dados);
      END pc_escreve_xml;

      -- Calculo do retorno de sobras sobre todos os serviços utilizando como base a regra atual.
      PROCEDURE pc_totaliza_juros_migracao IS
      BEGIN
        
        -- busca de desconto de cheques
        OPEN cr_crapljd(rw_crapcot.nrdconta
                       ,vr_dtinimes
                       ,vr_dtfimmes);
        FETCH cr_crapljd INTO vr_vlbasdsc;
        CLOSE cr_crapljd;


        -- busca de juros de descontos de titulos
        OPEN cr_crapljt(rw_crapcot.nrdconta
                       ,vr_dtinimes
                       ,vr_dtfimmes);
        FETCH cr_crapljt INTO vr_vlbastit;
        CLOSE cr_crapljt;
        
        vr_qtraimfx := 0;

        -- Para juridico e fisico, sem data de eliminaçao e solicitado os demitidos
        IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
          -- Juros Empréstimos
          FOR rw_craplem IN cr_craplem(pr_cdcooper => rw_crapcot.cdcooper --> Código da Cooperativa
                                      ,pr_nrdconta => rw_crapcot.nrdconta)--> Número da Conta

            LOOP
              vr_qtraimfx := NVL(vr_qtraimfx,0) + ROUND((rw_craplem.vllanmto / rw_crapmfx.vlmoefix),4);
            END LOOP;

          -- Lancamentos  
          FOR rw_craplcm IN cr_craplcm(pr_cdcooper => rw_crapcot.cdcooper --> Código da Cooperativa
                                      ,pr_nrdconta => rw_crapcot.nrdconta)--> Número da Conta

            LOOP
              vr_qtraimfx := NVL(vr_qtraimfx,0) + ROUND((rw_craplcm.vllanmto / rw_crapmfx.vlmoefix),4);
            END LOOP;

          vr_vlpvardc := 0;

          -- Leitura de lancamentos de aplicacoes RDCA.
          FOR rw_craplap IN cr_craplap(pr_cdcooper => rw_crapcot.cdcooper --> Código da Cooperativa
                                      ,pr_nrdconta => rw_crapcot.nrdconta)--> Número da Conta

            LOOP
              IF rw_craplap.cdhistor IN (474,475,529,532) THEN 
                vr_vlpvardc := NVL(vr_vlpvardc,0) + rw_craplap.vllanmto;
              ELSIF rw_craplap.cdhistor IN (463,531) THEN 
                vr_vlpvardc := NVL(vr_vlpvardc,0) - rw_craplap.vllanmto;
              END IF;  
            END LOOP;
          
          -- Verifica  se valor de RDC e menor que zero
          IF vr_vlpvardc < 0 THEN 
            vr_vlpvardc := 0;
          END IF;
            
          -- Somar o rendimento total da captação
          vr_vlrendim := rw_crapdir.vlrenrda##12 + rw_crapdir.vlrenrpp_ir##12 + vr_vlpvardc;

          /*  Calcula retorno sobre o DESCONTO DE CHEQUES ................ */
          IF vr_indeschq = 1 THEN
            vr_vlretdsc := ROUND(vr_vlbasdsc * vr_txdretor,2);
          ELSE
            vr_vlretdsc := 0;
          END IF;

          /*  Calcula retorno sobre o DESCONTO DE TITULOS ................ */
          IF vr_indestit = 1   THEN
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
        IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
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

        IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
          /* Saldo medio c/c */
          vr_vlbassdm := rw_crapdir.smposano##12;
          /* Media capital */
          vr_vlbasjur := rw_crapdir.vlcapmes##12;

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
            vr_vljurcap := ROUND(vr_vlmedcap * vr_txjurcap,2);
            tt_vljurcap := tt_vljurcap + vr_vljurcap;
            
            /* Busca percentual de IRRF baseado na faixa do valor */
            cr_fairrf_found := TRUE;
            OPEN cr_fairrf(vr_inpessoa, vr_vljurcap);
            FETCH cr_fairrf
            INTO rw_fairrf;
            cr_fairrf_found := cr_fairrf%FOUND;
            CLOSE cr_fairrf;
            
            IF NOT cr_fairrf_found THEN
              vr_dscritic := 'Valor de juros sobre capital não se encaixa em nenhuma faixa de IRRF.' ||
                             ' Cooperativa: ' || pr_cdcooper || '. Conta: ' || vr_nrdconta || '. Tipo Pessoa: ' || vr_inpessoa || '. Valor: ' || vr_vljurcap;
              RAISE vr_exc_saida;
            END IF;
            
            vr_vldeirrf := GREATEST(TRUNC((vr_vljurcap * (rw_fairrf.vlpercentual_irrf/100)) - rw_fairrf.vldeducao, 2),0);
          ELSE
            vr_vlbasjur := 0;
            vr_vljurcap := 0;
            vr_vlmedcap := 0;
            vr_vldeirrf := 0;
          END IF;

          /* Verifica se conta eh Imunidade sobre IRRF */
          IF vr_vldeirrf > 0  THEN
            IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => vr_nrdconta,
                                                pr_dtmvtolt => vr_dtmvtolt,
                                                pr_flgrvvlr => FALSE,
                                                pr_cdinsenc => 6,
                                                pr_vlinsenc => 0,
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
            
          -- Carrega total de tarifas pagas no ano
          OPEN cr_tbcotas_tarifas_pagas(rw_crapcot.nrdconta);
          FETCH cr_tbcotas_tarifas_pagas INTO rw_tbcotas_tarifas_pagas;
          CLOSE cr_tbcotas_tarifas_pagas;
          
          IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
                
              vr_vlbastar := rw_tbcotas_tarifas_pagas.vlbastar;
              vr_vljurtar := ROUND(vr_vlbastar * vr_txjurtar,2);
              tt_vljurtar := tt_vljurtar + vr_vljurtar;

          END IF;
        END IF;
          
      END pc_totaliza_juros_migracao;

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
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      /*  Carrega tabela de execucao do programa .................................. */
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXEICMIRET'
                                               ,pr_tpregist => 1);
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 283;
        RAISE vr_exc_saida;
      END IF;

      -- busca os valores de acordo com a tabela de execucao do programa
      vr_inprvdef := SUBSTR(vr_dstextab,18,01);
      vr_ininccmi := SUBSTR(vr_dstextab,01,01);
      vr_increret := SUBSTR(vr_dstextab,03,01);
      
      vr_txdretor := SUBSTR(vr_dstextab,05,12) / 100;
      vr_txjurcap := SUBSTR(vr_dstextab,20,13) / 100;
      vr_txjurapl := SUBSTR(vr_dstextab,33,12) / 100;
      vr_txjursdm := SUBSTR(vr_dstextab,54,12) / 100;
      vr_txjurtar := SUBSTR(vr_dstextab,78,12) / 100;
      
      vr_indeschq := SUBSTR(vr_dstextab,46,01);
      vr_indemiti := SUBSTR(vr_dstextab,50,01);
      vr_indestit := SUBSTR(vr_dstextab,52,01);

      rl_txdretor := SUBSTR(vr_dstextab,05,12);
      rl_txretdsc := SUBSTR(vr_dstextab,05,12);
      rl_txrettit := SUBSTR(vr_dstextab,05,12);

      IF vr_inprvdef = 0 THEN
        rl_dsprvdef := '**** PROCESSO PREVIO ****';
      ELSE
        rl_dsprvdef := '** PROCESSO DEFINITIVO **';
      END IF;

      vr_ininccmi := 0;  /*  FORCA A NAO INCORPORACAO DO CMI  */

      IF vr_txdretor = 0  AND vr_increret = 1 THEN
        vr_cdcritic := 0;
        RAISE vr_exc_fimprg;
      END IF;

      vr_dtliminf := to_date('3112'||(to_char(rw_crapdat.dtmvtolt,'YYYY')-2),'DDMMYYYY'); -- Busca o ultimo dia do ano de dois anos atras
      vr_dtlimsup := trunc(rw_crapdat.dtmvtolt,'YYYY'); -- Pega o primeiro dia do ano

      vr_dtinimes := to_date('30112014','DDMMYYYY'); -- Busca o ultimo dia do ano anterior
      vr_dtfimmes := trunc(rw_crapdat.dtmvtolt,'YYYY'); -- Pega o primeiro dia do mes de janeiro do ano corrente

      /*  Carrega valor da moeda fixa do dia ...................................... */
      OPEN cr_crapmfx(vr_dtmvtolt);
      FETCH cr_crapmfx INTO rw_crapmfx;
      IF cr_crapmfx%NOTFOUND THEN
        CLOSE cr_crapmfx;
        vr_cdcritic := 140;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' UFIR';
        pc_controle_critica;
        RAISE vr_exc_saida;
      END IF;

      -- Busca o ultimo dia util do ano anterior
      vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                 pr_dtmvtolt => trunc(vr_dtmvtolt,'YYYY') - 1, -- busca a data de 31/12 do ano anterior
                                                 pr_tipo     => 'A'); -- Dia anterior


      vr_dtrefere := trunc(rw_crapdat.dtmvtolt,'MM'); -- Busca o primeiro dia da data de parametro


      /*  Le registro de capital e calcula retorno  */
      FOR rw_crapcot IN cr_crapcot(NULL) LOOP

        -- Busca os dados dos associados
        OPEN cr_crapass(rw_crapcot.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass; -- Fecha o cursor de associados
          vr_cdcritic := 251;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' CONTA = '||rw_crapcot.nrdconta;
          pc_controle_critica;
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass; -- Fecha o cursor de associados

        -- Verifica se existe dados do extrato de imposto de renda
        OPEN cr_crapdir(rw_crapcot.nrdconta, vr_dtmvtolt);
        FETCH cr_crapdir INTO rw_crapdir;
        IF cr_crapdir%NOTFOUND THEN
          CLOSE cr_crapdir;
          continue;
        END IF;
        CLOSE cr_crapdir;

        /*** Atualiza flag que indica se deve ser considerada conta ***/
        /*** demitida no calculo - vr_indemiti = 0 - NAO = 1 - SIM ***/
        IF vr_indemiti = 1                                    OR
          (vr_indemiti = 0 AND (rw_crapdir.dtdemiss IS NULL   OR
           to_char(rw_crapdir.dtdemiss,'YYYY') >= to_char(rw_crapdat.dtmvtolt,'YYYY') - 1))  THEN
          vr_flgdemit := 1;
        ELSE
          vr_flgdemit := 0;
        END IF;

        vr_nrdconta := rw_crapcot.nrdconta;
        
        -- Guardar tipo da pessoa
        vr_inpessoa := rw_crapass.inpessoa;

        vr_vlcmicot := rw_crapcot.vlcmicot;

        /* Desprezar as contas migradas para a cooperativa credimilsul pois
           o calculo das sobras destas contas sera feito na scrcred */
        IF pr_cdcooper = 13 AND to_char(vr_dtmvtolt,'YYYY') = 2014 THEN
          -- Abre o cursor de contas transferidas entre cooperativas
          OPEN cr_craptco(pr_nrdconta => rw_crapcot.nrdconta,
                          pr_tpctatrf => 1,
                          pr_flgativo => 1,
                          pr_cdcopant => 15);
          
          FETCH cr_craptco INTO rw_craptco;
          
          -- Verifica se encontrou registro
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco; -- Fecha o cursor de contas transferidas
            pc_totaliza_juros_migracao();
            vr_execucao := FALSE;
          ELSE
            CLOSE cr_craptco; -- Fecha o cursor de contas transferidas
            vr_execucao := TRUE;
          END IF;
        ELSE
          vr_execucao := TRUE;  
        END IF;
        
        IF vr_execucao THEN
            
          /****** CALCULO ANTIGO ******/
          pc_totaliza_juros_desconto(rw_crapcot.nrdconta);

          -- Para juridico e fisico, sem data de eliminaçao e solicitado os demitidos
          IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
            vr_qtraimfx := rw_crapcot.qtraimfx;
            vr_vlrendim := rw_crapcot.vlrearda + rw_crapcot.vlrearpp + rw_crapcot.vlpvardc;

            /*  Calcula retorno sobre o DESCONTO DE CHEQUES ................ */
            IF vr_indeschq = 1 THEN
              vr_vlretdsc := ROUND(vr_vlbasdsc * vr_txdretor,2);
            ELSE
              vr_vlretdsc := 0;
            END IF;

            /*  Calcula retorno sobre o DESCONTO DE TITULOS ................ */
            IF vr_indestit = 1   THEN
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
          IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
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

          IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
            /* Saldo medio c/c */
            vr_vlbassdm := vr_vlbassdm + rw_crapdir.smposano;
            /* Media capital */
            vr_vlbasjur := vr_vlbasjur + rw_crapdir.vlcapmes;

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
              
              vr_vljurcap := ROUND(vr_vlmedcap * vr_txjurcap,2);
              tt_vljurcap := tt_vljurcap + vr_vljurcap;
              
              /* Busca percentual de IRRF baseado na faixa do valor */
              cr_fairrf_found := TRUE;
              OPEN cr_fairrf(vr_inpessoa, vr_vljurcap);
              FETCH cr_fairrf
              INTO rw_fairrf;
              cr_fairrf_found := cr_fairrf%FOUND;
              CLOSE cr_fairrf;
              
              IF NOT cr_fairrf_found THEN
                vr_dscritic := 'Valor de juros sobre capital não se encaixa em nenhuma faixa de IRRF.' ||
                             ' Cooperativa: ' || pr_cdcooper || '. Conta: ' || vr_nrdconta || '. Tipo Pessoa: ' || vr_inpessoa || '. Valor: ' || vr_vljurcap;
                RAISE vr_exc_saida;
              END IF;
              
              vr_vldeirrf := GREATEST(TRUNC((vr_vljurcap * (rw_fairrf.vlpercentual_irrf/100)) - rw_fairrf.vldeducao, 2),0);
            ELSE
              vr_vlbasjur := 0;
              vr_vljurcap := 0;
              vr_vlmedcap := 0;
              vr_vldeirrf := 0;
            END IF;

            /* Verifica se conta eh Imunidade sobre IRRF */
            IF vr_vldeirrf > 0  THEN
              IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => vr_nrdconta,
                                                  pr_dtmvtolt => vr_dtmvtolt,
                                                  pr_flgrvvlr => FALSE,
                                                  pr_cdinsenc => 6,
                                                  pr_vlinsenc => 0,
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
            
            -- Carrega total de tarifas pagas no ano
            OPEN cr_tbcotas_tarifas_pagas(rw_crapcot.nrdconta);
            FETCH cr_tbcotas_tarifas_pagas INTO rw_tbcotas_tarifas_pagas;
            CLOSE cr_tbcotas_tarifas_pagas;
          
            IF vr_inpessoa IN (1,2) AND rw_crapass.dtelimin IS NULL AND vr_flgdemit = 1 THEN
                
                vr_vlbastar := rw_tbcotas_tarifas_pagas.vlbastar;
                vr_vljurtar := TRUNC(vr_vlbastar * vr_txjurtar,2);
                tt_vljurtar := tt_vljurtar + vr_vljurtar;
 
            END IF;
          END IF;
          /****** FIM CALCULO ANTIGO ******/ 
          
        END IF;

        IF vr_ininccmi = 1 THEN /*  Incorporacao da C.M.  */

          -- busca sobre os dados de lancamentos de cotas / capital
          FOR rw_craplct IN cr_craplct(pr_nrdconta => rw_crapcot.nrdconta,
                                       pr_dtmvtolt => vr_dtrefere) LOOP

            -- Busca sobre os dados de historicos do sistema
            OPEN cr_craphis(rw_craplct.cdhistor);
            FETCH cr_craphis INTO rw_craphis;
            IF cr_craphis%NOTFOUND THEN
              CLOSE cr_craphis;
              vr_cdcritic := 80;
              pc_controle_critica;
              RAISE vr_exc_saida;
            END IF;
            CLOSE cr_craphis;

            IF rw_craphis.inhistor = 7   THEN -- CREDITO TRANSFERENCIA CORRECAO MONETARIA INCORPOR.
              vr_vlcmicot := vr_vlcmicot + rw_craplct.vllanmto;
            ELSIF rw_craphis.inhistor IN (18,19) THEN --18=DEBITO (OU TRANSFERENCIA) CORRECAO MONETARIA INCORPORAR
                                                      --19=INCORPORACAO CORRECAO MONETARIA
              vr_vlcmicot := vr_vlcmicot - rw_craplct.vllanmto;
            END IF;

          END LOOP;  /*  Fim do LOOP --  Leitura do craplct  */
        END IF;
          
        /* Se houver incorporacao de correcao monetaria,
            verificar se deve creditar para as contas eliminadas */
        IF vr_ininccmi <> 1 THEN
          vr_vlcmicot := 0;
        end if;
      
        tt_vlcmicot := tt_vlcmicot + vr_vlcmicot;

        IF vr_vlcmicot > 0 THEN
          tt_qtassinc := tt_qtassinc + 1;
        END IF;

        -- efetua os acumuladores dos calculos
        tt_qtraimfx := tt_qtraimfx + vr_qtraimfx;
        tt_vlbasret := tt_vlbasret + vr_vlbasret;
        tt_vldretor := tt_vldretor + vr_vldretor;
        tt_vlbasdsc := tt_vlbasdsc + vr_vlbasdsc;
        tt_vlretdsc := tt_vlretdsc + vr_vlretdsc;
        tt_vlbastit := tt_vlbastit + vr_vlbastit;
        tt_vlrettit := tt_vlrettit + vr_vlrettit;
        tt_vlbastar := tt_vlbastar + vr_vlbastar;

        IF vr_vldretor > 0 THEN
          tt_qtassret := tt_qtassret + 1; -- Quantidade de associados com retorno
        END IF;

        IF vr_vlretdsc > 0 THEN
          tt_qtassdsc := tt_qtassdsc + 1; -- Quantidade de associados com retorno creditado
        END IF;

        IF vr_vlrettit > 0 THEN
          tt_qtasstit := tt_qtasstit + 1; -- Quantidade de associados com desconto de titulos
        END IF;

        -- QUANTIDADE DE LANCAMENTOS SOBRE OPERACOES DE CREDITO
        vr_vltotcre := vr_vldretor + vr_vlretdsc + vr_vlrettit;
        IF vr_vltotcre > 0 THEN
          tt_qtretcrd := tt_qtretcrd + 1; -- Quantidade de sobras calculadas sobre operacoes de credito
          tt_qtcredit := tt_qtcredit + 1;
        END IF;
        
        -- Armazena o valor total de retorno sobre operacoes de credito
        vr_vlretcrd := vr_vlretcrd + vr_vldretor + vr_vlretdsc + vr_vlrettit;

        IF vr_vljurapl > 0 THEN
          tt_qtassapl := tt_qtassapl + 1; -- Quantidade de associados com rendimento
        END IF;

        IF vr_vljursdm > 0 THEN
          tt_qtasssdm := tt_qtasssdm + 1; -- Quantidade de associados com saldo medio
        END IF;

        -- QUANTIDADE DE LANCAMENTOS SOBRE DEPOSITOS
        vr_vltotjur := vr_vljurapl + vr_vljursdm;
        IF vr_vltotjur > 0 THEN
          tt_qtretdep := tt_qtretdep + 1; -- Quantidade de sobras calculada sobre depositos (aplicacoes e saldo médio C/C) 
          tt_qtcredit := tt_qtcredit + 1;
        END IF;
        
        -- Armazena o valor total de retorno sobre depositos (aplicacoes e saldo médio C/C) 
        vr_vlretdep := vr_vlretdep + vr_vljurapl + vr_vljursdm;
        
        IF (vr_vljurcap + vr_vlbasjur) > 0 THEN
          tt_qtasscap := tt_qtasscap + 1; -- Quantidade de associados com juros ao capital
        END IF;
        
        -- QUANTIDADE DE LANCAMENTOS SOBRE TARIFAS PAGAS
        IF vr_vljurtar > 0 THEN
          tt_qtasstar := tt_qtasstar + 1; -- Quantidade de associados com tarifas pagas
          tt_qtcredit := tt_qtcredit + 1;
        END IF;

        vr_vlcredit := vr_vldretor + vr_vljurapl +
                       vr_vlretdsc + vr_vlrettit +
                       vr_vljursdm + vr_vljurtar; -- Calcula o valor do credito

        vr_vlcrecap := vr_vljurcap;

        tt_vlcredit := tt_vlcredit + vr_vlcredit; -- Acumula o Valor do credito

        vr_vlcretot := vr_vlcredit + vr_vljurcap; -- Valor total do credito

        tt_vlcretot := tt_vlcretot + vr_vlcredit + vr_vlcrecap; -- Valor total do credito

        /*IF vr_vlcredit > 0 THEN
          tt_qtcredit := tt_qtcredit + 1;
        END IF;*/

        IF vr_vlcrecap > 0 THEN
          tt_qtcrecap := tt_qtcrecap + 1;
        END IF;

        tt_qtcretot := tt_qtcredit + tt_qtcrecap;

        -- Se for processo definitivo, entao popula a temp-table
        IF vr_inprvdef = 1 THEN
          vr_indice := vr_indice + 1;
          vr_tab_crrl048(vr_indice).nrdconta := vr_nrdconta;
          vr_tab_crrl048(vr_indice).vlcmicot := vr_vlcmicot;
          vr_tab_crrl048(vr_indice).qtraimfx := vr_qtraimfx;
          vr_tab_crrl048(vr_indice).vlbasret := vr_vlbasret;
          vr_tab_crrl048(vr_indice).vldretor := vr_vldretor;
          vr_tab_crrl048(vr_indice).inpessoa := vr_inpessoa;
          vr_tab_crrl048(vr_indice).vlbasjur := vr_vlbasjur;
          vr_tab_crrl048(vr_indice).vljurcap := vr_vljurcap;
          vr_tab_crrl048(vr_indice).vlbasapl := vr_vlbasapl;
          vr_tab_crrl048(vr_indice).vljurapl := vr_vljurapl;
          vr_tab_crrl048(vr_indice).vlretdsc := vr_vlretdsc;
          vr_tab_crrl048(vr_indice).vlrettit := vr_vlrettit;
          vr_tab_crrl048(vr_indice).vldeirrf := vr_vldeirrf;
          vr_tab_crrl048(vr_indice).vlbassdm := vr_vlbassdm;
          vr_tab_crrl048(vr_indice).vljursdm := vr_vljursdm;
          vr_tab_crrl048(vr_indice).vlbastar := vr_vlbastar;
          vr_tab_crrl048(vr_indice).vljurtar := vr_vljurtar;
        END IF;

        -- Atualiza o registro abaixo para utilizacao no relatorio CRRL412
        -- Se todos os valores forem zeros, nao deve imprimir no relatorio
        IF vr_vlmedcap <> 0 OR
           vr_vlbasjur <> 0 OR
           vr_vljurcap <> 0 OR
           vr_vlbasret <> 0 OR
           vr_vldretor <> 0 OR
           vr_vlrendim <> 0 OR
           vr_vljurapl <> 0 OR
           vr_vlbassdm <> 0 OR
           vr_vljursdm <> 0 OR
           vr_vldeirrf <> 0 OR
           vr_vlcredit <> 0 OR
           vr_vlcretot <> 0 OR
           vr_vlbasdsc <> 0 OR
           vr_vlbastit <> 0 OR
           vr_vlretdsc <> 0 OR
           vr_vlrettit <> 0 THEN
          vr_indice_412 := lpad(rw_crapass.cdagenci,5,'0') || lpad(vr_nrdconta,10,'0');
          vr_tab_crrl412(vr_indice_412).cdagenci := rw_crapass.cdagenci;
          vr_tab_crrl412(vr_indice_412).nrdconta := vr_nrdconta;
          vr_tab_crrl412(vr_indice_412).nmprimtl := substr(rw_crapass.nmprimtl,1,30);
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
          vr_tab_crrl412(vr_indice_412).percirrf := rw_fairrf.vlpercentual_irrf;
          vr_tab_crrl412(vr_indice_412).vlbastar := vr_vlbastar;
          vr_tab_crrl412(vr_indice_412).vlrettar := vr_vljurtar;
          vr_tab_crrl412(vr_indice_412).vlcredit := vr_vlcredit;
          vr_tab_crrl412(vr_indice_412).vlcretot := vr_vlcretot;
        END IF;
      END LOOP; /*  Fim do LOOP --  Leitura do crapcot  */

      -------- Inicio do arquivo CRRL043.lst
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?>'||chr(10)||
                     '<crrl043>');

      tt_dstipcre := 'PESSOA FISICA/JURIDICA';

      IF vr_indemiti = 0 THEN -- Verifica se nao foi demitido
        tt_dsdemiti := 'NAO';
      ELSE
        tt_dsdemiti := 'SIM';
      END IF;

      -- Escreve a linha de total
      pc_escreve_xml('<vlbasret>'||to_char(tt_vlbasret,'999G999G999G990D00MI')      ||'</vlbasret>'||
                     '<txdretor>'||to_char(rl_txdretor,'fm9999999999990D00000000')||' %'||'</txdretor>'||
                     '<vldretor>'||to_char(tt_vldretor,'999G999G999G990D00MI')      ||'</vldretor>'||
                     '<vlretcrd>'||to_char(vr_vlretcrd,'999G999G999G990D00MI')      ||'</vlretcrd>'||                     
                     '<qtretcrd>'||to_char(tt_qtretcrd,'fm999999999G990')           ||'</qtretcrd>'||
                     '<vlretdep>'||to_char(vr_vlretdep,'999G999G999G990D00MI')      ||'</vlretdep>'||                     
                     '<qtretdep>'||to_char(tt_qtretdep,'fm999999999G990')           ||'</qtretdep>'||                     
                     '<qtassret>'||to_char(tt_qtassret,'fm999999999G990')           ||'</qtassret>'||
                     '<dsprvdef>'|| rl_dsprvdef                                     ||'</dsprvdef>'||
                     '<vljurcap>'||to_char(tt_vljurcap,'999G999G999G990D00MI')      ||'</vljurcap>'||
                     '<vlmedcap>'||to_char(tt_vlmedcap,'999G999G999G990D00MI')      ||'</vlmedcap>'||
                     '<txjurcap>'||to_char(vr_txjurcap*100,'fm999999990D00000000')      ||'</txjurcap>'||
                     '<txjurapl>'||to_char(vr_txjurapl*100,'fm999999990D00000000')||' %'||'</txjurapl>'||
                     '<vlcredit>'||to_char(tt_vlcredit,'999G999G999G990D00MI')      ||'</vlcredit>'||
                     '<qtcredit>'||to_char(tt_qtcredit,'fm999999999G990')           ||'</qtcredit>'||
                     '<vlbasapl>'||to_char(tt_vlbasapl,'999G999G999G990D00MI')      ||'</vlbasapl>'||
                     '<vljurapl>'||to_char(tt_vljurapl,'999G999G999G990D00MI')      ||'</vljurapl>'||
                     '<dstipcre>'|| tt_dstipcre                                     ||'</dstipcre>'||
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
                     '<qtasssdm>'||to_char(tt_qtasssdm,'fm999999999G990')           ||'</qtasssdm>'||
                     '<vlbassdm>'||to_char(tt_vlbassdm,'999G999G999G990D00MI')      ||'</vlbassdm>'||
                     '<txjursdm>'||to_char(vr_txjursdm*100,'fm999999990D00000000')||' %'||'</txjursdm>'||
                     '<vljursdm>'||to_char(tt_vljursdm,'999G999G999G990D00MI')      ||'</vljursdm>'||
                     '<vldeirrf>'||to_char(tt_vldeirrf,'999G999G999G990D00MI')      ||'</vldeirrf>'||
                     '<qtasstar>'||to_char(tt_qtasstar,'fm999999999G990')           ||'</qtasstar>'||
                     '<vlbastar>'||to_char(tt_vlbastar,'999G999G999G990D00MI')      ||'</vlbastar>'||
                     '<txjurtar>'||to_char(vr_txjurtar*100,'fm999999990D00000000')||' %'||'</txjurtar>'||
                     '<vljurtar>'||to_char(tt_vljurtar,'999G999G999G990D00MI')      ||'</vljurtar>'||
                     '<vlcretot>'||to_char(tt_vlcretot,'999G999G999G990D00MI')      ||'</vlcretot>'||
                     '<qtcretot>'||to_char(tt_qtcretot,'fm999999999G990')           ||'</qtcretot>'||
                   '</crrl043>');


      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl'); --> Utilizaremos o contab

      /* Copia crrl043 para rlnsv quando for previa e envia email */
      IF vr_inprvdef <> 1 THEN
        -- Busca do diretorio base da cooperativa
        vr_nom_direto_copia := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                    ,pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsubdir => 'rlnsv'); --> Utilizaremos o contab

        -- Buscar o parametro com os endereços de e-mail para envio
        vr_dsdestin := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'CRRL043_EMAIL');

      END IF;

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_cdrelato  => 43,                            --> Código do relatório
                                  pr_dsxml     => vr_xml,                         --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl043',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl043.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl043.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 80,                             --> Quantidade de colunas
                                  pr_nmformul  => '80col',                        --> Nome do formulario
                                  pr_dspathcop => vr_nom_direto_copia,            --> Lista sep. por ';' de diretórios a copiar o relatório
                                  pr_fldoscop  => 'S',                            --> Flag para converter o arquivo gerado em DOS antes da cópia
                                  pr_dscmaxcop => ' | tr -d "\032"',              --> Comando auxiliar para o comando ux2dos na cópia de diretório
                                  pr_fldosmail => 'S',                            --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                  pr_dsmailcop => vr_dsdestin,                    --> Lista sep. por ';' de emails para envio do relatório
                                  pr_dsassmail => 'Relatorio 043/510',            --> Assunto do e-mail que enviará o relatório
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Libera a memoria do clob
      dbms_lob.close(vr_xml);

      -- Se for processo definitivo
      IF vr_inprvdef = 1 THEN
        vr_indice := vr_tab_crrl048.first;
        -- Perceorre a tabela que foi populada para o relatorio CRRL048
        WHILE vr_indice IS NOT NULL LOOP
          vr_flg_ctamigra := FALSE;

          OPEN cr_crapcot(vr_tab_crrl048(vr_indice).nrdconta);
          FETCH cr_crapcot INTO rw_crapcot;
          IF cr_crapcot%NOTFOUND THEN
            CLOSE cr_crapcot;
            vr_cdcritic := 169;
            pc_controle_critica;
            RAISE vr_exc_saida;
          END IF;
          CLOSE cr_crapcot;


          /* Lancar nas contas migradas da ACREDI para VIACREDI */
          IF pr_cdcooper = 2  THEN
            OPEN cr_craptco(vr_tab_crrl048(vr_indice).nrdconta,1,1, NULL);
            FETCH cr_craptco INTO rw_craptco;
            IF cr_craptco%FOUND THEN
              vr_flg_ctamigra := TRUE;

              OPEN cr_craplot(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                              pr_cdagenci => vr_cdagenci,
                              pr_cdbccxlt => vr_cdbccxlt,
                              pr_nrdolote => vr_nrdolote);
              FETCH cr_craplot INTO rw_craplot;
              IF cr_craplot%NOTFOUND THEN
                -- Insere a capa de lote
                BEGIN
                  INSERT INTO craplot
                    (dtmvtolt,
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     tplotmov,
                     cdcooper)
                   VALUES
                    (rw_crapdat.dtmvtolt,
                     nvl(vr_cdagenci,0),
                     nvl(vr_cdbccxlt,0),
                     nvl(vr_nrdolote,0),
                     2,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    CLOSE cr_craplot;
                    vr_dscritic := 'Erro ao inserir na CRAPLOT: ' ||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                rw_craplot.nrseqdig := 0;
              END IF;
              CLOSE cr_craplot;

              /* Efetuar lancamentos referente as sobras na conta migrada */
              IF vr_ininccmi = 1 THEN         /*  Incorporacao da C.M.  */
                IF vr_tab_crrl048(vr_indice).vlcmicot > 0 THEN
                  BEGIN
                    -- Insere o lancamento de cotas / capital
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
                      (rw_crapdat.dtmvtolt,
                       nvl(vr_cdagenci,0),
                       nvl(vr_cdbccxlt,0),
                       nvl(vr_nrdolote,0),
                       nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                       80050066,
                       66,
                       nvl(vr_tab_crrl048(vr_indice).vlcmicot,0),
                       nvl(rw_craplot.nrseqdig,0) + 1,
                       pr_cdcooper);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir CRAPLCT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  -- Atualiza o valor das cotas na conta
                  BEGIN
                    UPDATE crapcot
                       SET vldcotas = nvl(vldcotas,0) + nvl(vr_tab_crrl048(vr_indice).vlcmicot,0)
                     WHERE ROWID = rw_crapcot.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar CRAPCOT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  -- Atualiza a capa do lote
                  BEGIN
                    UPDATE craplot
                       SET vlinfocr = nvl(vlinfocr,0) + nvl(vr_tab_crrl048(vr_indice).vlcmicot,0),
                           vlcompcr = nvl(vlcompcr,0) + nvl(vr_tab_crrl048(vr_indice).vlcmicot,0),
                           qtinfoln = nvl(qtinfoln,0) + 1,
                           qtcompln = nvl(qtcompln,0) + 1,
                           nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                     WHERE cdcooper = pr_cdcooper
                       AND dtmvtolt = rw_crapdat.dtmvtolt
                       AND cdagenci = vr_cdagenci
                       AND cdbccxlt = vr_cdbccxlt
                       AND nrdolote = vr_nrdolote;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar CRAPLOT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                END IF; -- vr_tab_crrl048(vr_indice).vlcmicot > 0
              END IF; -- vr_ininccmi = 1

              IF vr_increret = 1 THEN           /*  Credito do retorno  */
                /*  Soma retorno do capital sobre o retorno calculado */
                /*vr_tab_crrl048(vr_indice).vldretor := vr_tab_crrl048(vr_indice).vldretor +
                                                      vr_tab_crrl048(vr_indice).vljurapl +
                                                      vr_tab_crrl048(vr_indice).vlretdsc +
                                                      vr_tab_crrl048(vr_indice).vlrettit +
                                                      vr_tab_crrl048(vr_indice).vljursdm;*/

                /*  Soma sobras calculada sobre operacoes de credito */
                vr_tab_crrl048(vr_indice).vlretcrd := vr_tab_crrl048(vr_indice).vldretor +
                                                       vr_tab_crrl048(vr_indice).vlretdsc +
                                                       vr_tab_crrl048(vr_indice).vlrettit;

                /*  Soma sobras calculada sobre depositos (aplicacoes e saldo médio C/C) */
                vr_tab_crrl048(vr_indice).vlretdep := vr_tab_crrl048(vr_indice).vljurapl +                                         
                                                       vr_tab_crrl048(vr_indice).vljursdm;

                /* verifica se ha saldo de operacoes de credito */
                IF vr_tab_crrl048(vr_indice).vlretcrd > 0 THEN
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
                      (rw_crapdat.dtmvtolt,
                       nvl(vr_cdagenci,0),
                       nvl(vr_cdbccxlt,0),
                       nvl(vr_nrdolote,0),
                       nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                       80050064,
                       64,
                       nvl(vr_tab_crrl048(vr_indice).vlretcrd,0),
                       nvl(rw_craplot.nrseqdig,0) + 1,
                       pr_cdcooper);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no insert da CRAPLCT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  -- Atualiza o valor das cotas na conta
                  BEGIN
                    UPDATE crapcot
                       SET qtraimfx = 0,
                           vldcotas = nvl(vldcotas,0) + nvl(vr_tab_crrl048(vr_indice).vlretcrd,0)
                     WHERE ROWID = rw_crapcot.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no update da CRAPCOT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  -- Atualiza a capa do lote
                  BEGIN
                    UPDATE craplot
                       SET vlinfocr = nvl(vlinfocr,0) + nvl(vr_tab_crrl048(vr_indice).vlretcrd,0),
                           vlcompcr = nvl(vlcompcr,0) + nvl(vr_tab_crrl048(vr_indice).vlretcrd,0),
                           qtinfoln = nvl(qtinfoln,0) + 1,
                           qtcompln = nvl(qtcompln,0) + 1,
                           nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                     WHERE cdcooper = pr_cdcooper
                       AND dtmvtolt = rw_crapdat.dtmvtolt
                       AND cdagenci = vr_cdagenci
                       AND cdbccxlt = vr_cdbccxlt
                       AND nrdolote = vr_nrdolote;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no update da CRAPLOT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                END IF; -- vlretcrd > 0 
                
                /* verifica se ha saldo sobre depositos */
                IF vr_tab_crrl048(vr_indice).vlretdep > 0 THEN
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
                      (rw_crapdat.dtmvtolt,
                       nvl(vr_cdagenci,0),
                       nvl(vr_cdbccxlt,0),
                       nvl(vr_nrdolote,0),
                       nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                       80051801,
                       1801,
                       nvl(vr_tab_crrl048(vr_indice).vlretdep,0),
                       nvl(rw_craplot.nrseqdig,0) + 1,
                       pr_cdcooper);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no insert da CRAPLCT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  -- Atualiza o valor das cotas na conta
                  BEGIN
                    UPDATE crapcot
                       SET qtraimfx = 0,
                           vldcotas = nvl(vldcotas,0) + nvl(vr_tab_crrl048(vr_indice).vlretdep,0)
                     WHERE ROWID = rw_crapcot.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no update da CRAPCOT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  -- Atualiza a capa do lote
                  BEGIN
                    UPDATE craplot
                       SET vlinfocr = nvl(vlinfocr,0) + nvl(vr_tab_crrl048(vr_indice).vlretdep,0),
                           vlcompcr = nvl(vlcompcr,0) + nvl(vr_tab_crrl048(vr_indice).vlretdep,0),
                           qtinfoln = nvl(qtinfoln,0) + 1,
                           qtcompln = nvl(qtcompln,0) + 1,
                           nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                     WHERE cdcooper = pr_cdcooper
                       AND dtmvtolt = rw_crapdat.dtmvtolt
                       AND cdagenci = vr_cdagenci
                       AND cdbccxlt = vr_cdbccxlt
                       AND nrdolote = vr_nrdolote;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro no update da CRAPLOT: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                END IF; -- vlretdep > 0
                
              END IF;  -- vr_increret = 1

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
                    (rw_crapdat.dtmvtolt,
                     nvl(vr_cdagenci,0),
                     nvl(vr_cdbccxlt,0),
                     nvl(vr_nrdolote,0),
                     nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                     8005926,
                     926,
                     nvl(vr_tab_crrl048(vr_indice).vljurcap,0),
                     nvl(rw_craplot.nrseqdig,0) + 1,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro insert da CRAPLCT (1): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza o valor das cotas na conta
                BEGIN
                  UPDATE crapcot
                     SET vldcotas = nvl(vldcotas,0) + nvl(vr_tab_crrl048(vr_indice).vljurcap,0)
                   WHERE ROWID = rw_crapcot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza a capa do lote
                BEGIN
                  UPDATE craplot
                     SET vlinfocr = nvl(vlinfocr,0) + nvl(vr_tab_crrl048(vr_indice).vljurcap,0),
                         vlcompcr = nvl(vlcompcr,0) + nvl(vr_tab_crrl048(vr_indice).vljurcap,0),
                         qtinfoln = nvl(qtinfoln,0) + 1,
                         qtcompln = nvl(qtcompln,0) + 1,
                         nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                   WHERE cdcooper = pr_cdcooper
                     AND dtmvtolt = rw_crapdat.dtmvtolt
                     AND cdagenci = vr_cdagenci
                     AND cdbccxlt = vr_cdbccxlt
                     AND nrdolote = vr_nrdolote;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
              END IF;

              /* Verifica se conta eh Imunidade sobre IRRF */
              IF vr_tab_crrl048(vr_indice).vldeirrf > 0  THEN
                IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                                    pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta,
                                                    pr_dtmvtolt => vr_dtmvtolt,
                                                    pr_flgrvvlr => TRUE,
                                                    pr_cdinsenc => 6,
                                                    pr_vlinsenc => vr_tab_crrl048(vr_indice).vldeirrf,
                                                    pr_flgimune => vr_flgimune,
                                                    pr_dsreturn => vr_dsreturn,
                                                    pr_tab_erro => vr_tab_erro);
                IF vr_dsreturn = 'NOK' THEN -- Ocorreu erro
                  vr_cdcritic := vr_tab_erro(01).cdcritic;
                  vr_dscritic := vr_tab_erro(01).dscritic;
                  RAISE vr_exc_saida;
                END IF;
              END IF;

              /* IRRF sobre rendimentos capital */
              IF NOT vr_flgimune AND vr_tab_crrl048(vr_indice).vldeirrf > 0 THEN
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
                    (rw_crapdat.dtmvtolt,
                     nvl(vr_cdagenci,0),
                     nvl(vr_cdbccxlt,0),
                     nvl(vr_nrdolote,0),
                     nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                     8005922,
                     922,
                     nvl(vr_tab_crrl048(vr_indice).vldeirrf,0),
                     nvl(rw_craplot.nrseqdig,0) + 1,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro insert da CRAPLCT (2): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza o valor das cotas na conta
                BEGIN
                  UPDATE crapcot
                     SET vldcotas = nvl(vldcotas,0) - nvl(vr_tab_crrl048(vr_indice).vldeirrf,0)
                   WHERE ROWID = rw_crapcot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza a capa do lote
                BEGIN
                  UPDATE craplot
                     SET vlinfodb = nvl(vlinfodb,0) + nvl(vr_tab_crrl048(vr_indice).vldeirrf,0),
                         vlcompdb = nvl(vlcompdb,0) + nvl(vr_tab_crrl048(vr_indice).vldeirrf,0),
                         qtinfoln = nvl(qtinfoln,0) + 1,
                         qtcompln = nvl(qtcompln,0) + 1,
                         nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                   WHERE cdcooper = pr_cdcooper
                     AND dtmvtolt = rw_crapdat.dtmvtolt
                     AND cdagenci = vr_cdagenci
                     AND cdbccxlt = vr_cdbccxlt
                     AND nrdolote = vr_nrdolote;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
              END IF;
            END IF; -- cr_craptco%FOUND
            CLOSE cr_craptco;
          END IF; -- pr_cdcooper = 2

          -- Se a conta nao foi migrada (se nao entrou no if acima)
          IF NOT vr_flg_ctamigra THEN

            -- busca os dados da capa do lote
            OPEN cr_craplot(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                            pr_cdagenci => vr_cdagenci,
                            pr_cdbccxlt => vr_cdbccxlt,
                            pr_nrdolote => vr_nrdolote);
            FETCH cr_craplot INTO rw_craplot;

            IF vr_flgclote THEN
              vr_flgclote := FALSE;
              IF cr_craplot%FOUND THEN
                /* Nao fazer validacao de lote ja criado na VIACREDI,
                   pois o lote ja pode ter sido criado na ACREDI por
                   causa das contas migradas */
                /* O tratamento ainda esta fixo pois nao ha como
                   identificar se a cooperativa é migrada */
                IF pr_cdcooper <> 1  THEN
                  vr_cdcritic := 59;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' LOTE = ' ||to_char(vr_nrdolote,'000000');
                  pc_controle_critica;
                  RAISE vr_exc_saida;
                END IF;
              ELSE
                -- Insere a capa do lote
                BEGIN
                  INSERT INTO craplot
                    (dtmvtolt,
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     tplotmov,
                     cdcooper)
                  VALUES
                    (rw_crapdat.dtmvtolt,
                     nvl(vr_cdagenci,0),
                     nvl(vr_cdbccxlt,0),
                     nvl(vr_nrdolote,0),
                     2,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro insert da CRAPLOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                rw_craplot.nrseqdig := 0;
              END IF;
            END IF;
            CLOSE cr_craplot;

            IF vr_ininccmi = 1 THEN         /*  Incorporacao da C.M.  */
              IF vr_tab_crrl048(vr_indice).vlcmicot > 0 THEN
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
                    (rw_crapdat.dtmvtolt,
                     nvl(vr_cdagenci,0),
                     nvl(vr_cdbccxlt,0),
                     nvl(vr_nrdolote,0),
                     nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                     80050066,
                     66,
                     nvl(vr_tab_crrl048(vr_indice).vlcmicot,0),
                     nvl(rw_craplot.nrseqdig,0) + 1,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro insert da CRAPLCT (3): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza o valor das cotas na conta
                BEGIN
                  UPDATE crapcot
                     SET vldcotas = vldcotas + nvl(vr_tab_crrl048(vr_indice).vlcmicot,0)
                   WHERE ROWID = rw_crapcot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza a capa do lote
                BEGIN
                  UPDATE craplot
                     SET vlinfocr = vlinfocr + nvl(vr_tab_crrl048(vr_indice).vlcmicot,0),
                         vlcompcr = vlcompcr + nvl(vr_tab_crrl048(vr_indice).vlcmicot,0),
                         qtinfoln = qtinfoln + 1,
                         qtcompln = qtcompln + 1,
                         nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                   WHERE cdcooper = pr_cdcooper
                     AND dtmvtolt = rw_crapdat.dtmvtolt
                     AND cdagenci = vr_cdagenci
                     AND cdbccxlt = vr_cdbccxlt
                     AND nrdolote = vr_nrdolote;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
              END IF;
            END IF;

            IF vr_increret = 1 THEN           /*  Credito do retorno  */
              /*  Soma retorno do capital sobre o retorno calculado */
              /*vr_tab_crrl048(vr_indice).vldretor := vr_tab_crrl048(vr_indice).vldretor +
                                                    vr_tab_crrl048(vr_indice).vljurapl +
                                                    vr_tab_crrl048(vr_indice).vlretdsc +
                                                    vr_tab_crrl048(vr_indice).vlrettit +
                                                    vr_tab_crrl048(vr_indice).vljursdm;*/

              /*  Soma sobras calculada sobre operacoes de credito */
              vr_tab_crrl048(vr_indice).vlretcrd := vr_tab_crrl048(vr_indice).vldretor +
                                                     vr_tab_crrl048(vr_indice).vlretdsc +
                                                     vr_tab_crrl048(vr_indice).vlrettit;

              /*  Soma sobras calculada sobre depositos (aplicacoes e saldo médio C/C) */
              vr_tab_crrl048(vr_indice).vlretdep := vr_tab_crrl048(vr_indice).vljurapl +                                         
                                                     vr_tab_crrl048(vr_indice).vljursdm;

              IF vr_tab_crrl048(vr_indice).vlretcrd > 0 THEN
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
                    (rw_crapdat.dtmvtolt,
                     nvl(vr_cdagenci,0),
                     nvl(vr_cdbccxlt,0),
                     nvl(vr_nrdolote,0),
                     nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                     80050064,
                     64,
                     nvl(vr_tab_crrl048(vr_indice).vlretcrd,0),
                     rw_craplot.nrseqdig + 1,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro insert da CRAPLCT (4): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza o valor das cotas na conta
                BEGIN
                  UPDATE crapcot
                     SET qtraimfx = 0,
                         vldcotas = vldcotas + nvl(vr_tab_crrl048(vr_indice).vlretcrd,0)
                   WHERE ROWID = rw_crapcot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza a capa do lote
                BEGIN
                  UPDATE craplot
                     SET vlinfocr = vlinfocr + nvl(vr_tab_crrl048(vr_indice).vlretcrd,0),
                         vlcompcr = vlcompcr + nvl(vr_tab_crrl048(vr_indice).vlretcrd,0),
                         qtinfoln = qtinfoln + 1,
                         qtcompln = qtcompln + 1,
                         nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                   WHERE cdcooper = pr_cdcooper
                     AND dtmvtolt = rw_crapdat.dtmvtolt
                     AND cdagenci = vr_cdagenci
                     AND cdbccxlt = vr_cdbccxlt
                     AND nrdolote = vr_nrdolote;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
              END IF; -- vlretcrd > 0
              
              
              
              IF vr_tab_crrl048(vr_indice).vlretdep > 0 THEN
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
                    (rw_crapdat.dtmvtolt,
                     nvl(vr_cdagenci,0),
                     nvl(vr_cdbccxlt,0),
                     nvl(vr_nrdolote,0),
                     nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                     80051801,
                     1801,
                     nvl(vr_tab_crrl048(vr_indice).vlretdep,0),
                     rw_craplot.nrseqdig + 1,
                     pr_cdcooper);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro insert da CRAPLCT (4): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza o valor das cotas na conta
                BEGIN
                  UPDATE crapcot
                     SET qtraimfx = 0,
                         vldcotas = vldcotas + nvl(vr_tab_crrl048(vr_indice).vlretdep,0)
                   WHERE ROWID = rw_crapcot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualiza a capa do lote
                BEGIN
                  UPDATE craplot
                     SET vlinfocr = vlinfocr + nvl(vr_tab_crrl048(vr_indice).vlretdep,0),
                         vlcompcr = vlcompcr + nvl(vr_tab_crrl048(vr_indice).vlretdep,0),
                         qtinfoln = qtinfoln + 1,
                         qtcompln = qtcompln + 1,
                         nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                   WHERE cdcooper = pr_cdcooper
                     AND dtmvtolt = rw_crapdat.dtmvtolt
                     AND cdagenci = vr_cdagenci
                     AND cdbccxlt = vr_cdbccxlt
                     AND nrdolote = vr_nrdolote;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
              END IF; -- vlretdep > 0
              
              
              
              
              
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
                  (rw_crapdat.dtmvtolt,
                   nvl(vr_cdagenci,0),
                   nvl(vr_cdbccxlt,0),
                   nvl(vr_nrdolote,0),
                   nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                   8005926,
                   926,
                   nvl(vr_tab_crrl048(vr_indice).vljurcap,0),
                   nvl(rw_craplot.nrseqdig,0) + 1,
                   pr_cdcooper);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro insert da CRAPLCT (5): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualiza o valor das cotas na conta
              BEGIN
                UPDATE crapcot
                   SET vldcotas = vldcotas + nvl(vr_tab_crrl048(vr_indice).vljurcap,0)
                 WHERE ROWID = rw_crapcot.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualiza a capa do lote
              BEGIN
                UPDATE craplot
                   SET vlinfocr = vlinfocr + nvl(vr_tab_crrl048(vr_indice).vljurcap,0),
                       vlcompcr = vlcompcr + nvl(vr_tab_crrl048(vr_indice).vljurcap,0),
                       qtinfoln = qtinfoln + 1,
                       qtcompln = qtcompln + 1,
                       nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                 WHERE cdcooper = pr_cdcooper
                   AND dtmvtolt = rw_crapdat.dtmvtolt
                   AND cdagenci = vr_cdagenci
                   AND cdbccxlt = vr_cdbccxlt
                   AND nrdolote = vr_nrdolote;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
            END IF; -- vr_tab_crrl048(vr_indice).vljurcap > 0

            /* Verifica se a conta eh Imunidade sobre o IRRF  */
            IF vr_tab_crrl048(vr_indice).vldeirrf > 0 THEN
              IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => vr_tab_crrl048(vr_indice).nrdconta,
                                                  pr_dtmvtolt => vr_dtmvtolt,
                                                  pr_flgrvvlr => TRUE,
                                                  pr_cdinsenc => 6,
                                                  pr_vlinsenc => vr_tab_crrl048(vr_indice).vldeirrf,
                                                  pr_flgimune => vr_flgimune,
                                                  pr_dsreturn => vr_dsreturn,
                                                  pr_tab_erro => vr_tab_erro);
              IF vr_dsreturn = 'NOK' THEN -- Ocorreu erro
                vr_cdcritic := vr_tab_erro(01).cdcritic;
                vr_dscritic := vr_tab_erro(01).dscritic;
                RAISE vr_exc_saida;
              END IF;
            END IF; --vr_tab_crrl048(vr_indice).vldeirrf > 0

            /* -------IRRF sobre rendimentos capital------ */
            IF NOT vr_flgimune AND vr_tab_crrl048(vr_indice).vldeirrf > 0 THEN
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
                  (rw_crapdat.dtmvtolt,
                   nvl(vr_cdagenci,0),
                   nvl(vr_cdbccxlt,0),
                   nvl(vr_nrdolote,0),
                   nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                   8005922,
                   922,
                   nvl(vr_tab_crrl048(vr_indice).vldeirrf,0),
                   nvl(rw_craplot.nrseqdig,0) + 1,
                   pr_cdcooper);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro insert da CRAPLCT (6): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualiza o valor das cotas na conta
              BEGIN
                UPDATE crapcot
                   SET vldcotas = vldcotas - nvl(vr_tab_crrl048(vr_indice).vldeirrf,0)
                 WHERE ROWID = rw_crapcot.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualiza a capa do lote
              BEGIN
                UPDATE craplot
                   SET vlinfodb = vlinfodb + nvl(vr_tab_crrl048(vr_indice).vldeirrf,0),
                       vlcompdb = vlcompdb + nvl(vr_tab_crrl048(vr_indice).vldeirrf,0),
                       qtinfoln = qtinfoln + 1,
                       qtcompln = qtcompln + 1,
                       nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                 WHERE cdcooper = pr_cdcooper
                   AND dtmvtolt = rw_crapdat.dtmvtolt
                   AND cdagenci = vr_cdagenci
                   AND cdbccxlt = vr_cdbccxlt
                   AND nrdolote = vr_nrdolote;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
            END IF; --NOT aux_flgimune AND vr_tab_crrl048(vr_indice).vldeirrf > 0
            /* -----FIM IRRF sobre rendimentos capital---- */
          
            /* ---------------TARIFAS PAGAS--------------- */
             IF vr_tab_crrl048(vr_indice).vljurtar > 0  THEN
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
                  (rw_crapdat.dtmvtolt,
                   nvl(vr_cdagenci,0),
                   nvl(vr_cdbccxlt,0),
                   nvl(vr_nrdolote,0),
                   nvl(vr_tab_crrl048(vr_indice).nrdconta,0),
                   80051940,
                   1940,
                   nvl(vr_tab_crrl048(vr_indice).vljurtar,0),
                   nvl(rw_craplot.nrseqdig,0) + 1,
                   pr_cdcooper);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro insert da CRAPLCT (5): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualiza o valor das cotas na conta
              BEGIN
                UPDATE crapcot
                   SET vldcotas = vldcotas + nvl(vr_tab_crrl048(vr_indice).vljurtar,0)
                 WHERE ROWID = rw_crapcot.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro update da CRAPCOT: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualiza a capa do lote
              BEGIN
                UPDATE craplot
                   SET vlinfocr = vlinfocr + nvl(vr_tab_crrl048(vr_indice).vljurtar,0),
                       vlcompcr = vlcompcr + nvl(vr_tab_crrl048(vr_indice).vljurtar,0),
                       qtinfoln = qtinfoln + 1,
                       qtcompln = qtcompln + 1,
                       nrseqdig = nvl(rw_craplot.nrseqdig,0) + 1
                 WHERE cdcooper = pr_cdcooper
                   AND dtmvtolt = rw_crapdat.dtmvtolt
                   AND cdagenci = vr_cdagenci
                   AND cdbccxlt = vr_cdbccxlt
                   AND nrdolote = vr_nrdolote;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro update CRAPLOT: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
            END IF;
			      /* -------------FIM TARIFAS PAGAS------------- */
          
          END IF; --NOT vr_flg_ctamigra

          IF vr_tab_crrl048(vr_indice).inpessoa = 3 THEN
            -- Atualiza a quantidade de retorno a incorporar em moeda fixa para zeros
            BEGIN
              UPDATE crapcot
                 SET qtraimfx = 0
               WHERE ROWID = rw_crapcot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro update da CRAPCOT (moeda fixa): '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF; --vr_tab_crrl048(vr_indice).inpessoa = 3
          vr_indice := vr_tab_crrl048.next(vr_indice);
        END LOOP;
      END IF;
      
      -- Emite o relatorio CRRL412
      pc_emite_detalhe_ret_sobras(pr_cdcooper    => pr_cdcooper
                                 ,pr_cdprogra    => vr_cdprogra
                                 ,pr_tab_crrl412 => vr_tab_crrl412
                                 ,pr_cdcritic    => vr_cdcritic
                                 ,pr_dscritic    => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      
      -- Zera taxa de retorno apos o credito 
      BEGIN
        UPDATE craptab
           SET dstextab = '0 0 000,00000000 0 000,00000000 000,00000000 0   0 0 000,00000000 ' || SUBSTR(dstextab,67,10) || ' 000,00000000'
         WHERE cdcooper = pr_cdcooper
           AND UPPER(nmsistem) = 'CRED'
           AND UPPER(tptabela) = 'GENERI'
           AND cdempres = 0
           AND UPPER(cdacesso) = 'EXEICMIRET'
           AND tpregist = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao zerar taxa de retorno apos credito: '||sqlerrm;
      END;
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
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
		
  PROCEDURE pc_verifica_conta_capital (pr_cdcooper IN crapcop.cdcooper%TYPE		  --> Cód. cooperativa
			                                 ,pr_nrdconta IN craplct.nrdconta%TYPE     --> Número da conta
                                       ,pr_flgconsu OUT INTEGER                  --> Flag para indicar se encontrou lançamentos de cotas/capita
                                       ,pr_vltotsob OUT craplct.vllanmto%TYPE    --> Valor total de sobras
                                       ,pr_vlliqjur OUT craplct.vllanmto%TYPE    --> Valor liquido do crédito de juros sobre capital
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Cód. da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE)IS --> Descrição da crítica
			
	/* ..........................................................................

   Procedure : pc_verifica_conta_capital 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Fevereiro/2015                      Ultima atualizacao: 16/05/2016

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
	............................................................................. */
		
    -- Cursor de lançamento de cotas/capital
    CURSOR cr_craplct (pr_dtmvtocd crapdat.dtmvtocd%TYPE) IS
      SELECT craplct.cdhistor, 
             craplct.vllanmto
        FROM craplct
       WHERE craplct.cdcooper  = pr_cdcooper
         AND craplct.dtmvtolt >= TRUNC(pr_dtmvtocd,'YYYY')
         AND craplct.nrdconta  = pr_nrdconta
         AND craplct.cdagenci  = 1
         AND craplct.cdbccxlt  = 100
         AND craplct.nrdolote  = 8005
         AND craplct.cdhistor IN (64,926,1801,1940);
    rw_craplct cr_craplct%ROWTYPE;
    								
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    								
    vr_dtcomuni DATE; -- Data de comunicação 
    vr_dtmvtolt DATE; -- Data atual
    vr_dtmvtocd DATE; -- Data de movimento do cash dispenser
    vr_flgconsu INTEGER := 0; -- Flag de consulta de lançamentos de cotas/capital
    vr_vltotsob craplct.vllanmto%TYPE := 0; -- Valor total das sobras
    vr_vlliqjur craplct.vllanmto%TYPE := 0; -- Valor liquido do crédito de juros sobre capital
    				
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;				
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   crapcri.dscritic%TYPE;
					
    vr_dstextab   craptab.dstextab%TYPE;
					
    BEGIN
			
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
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
				vr_dtmvtocd := rw_crapdat.dtmvtocd;
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
            pr_cdcritic := 0;
	  		    pr_dscritic := 'Erro ao capturar data de comunicacao na rotina SOBR0001.pc_verifica_conta_capital ' || SQLERRM;    
            RETURN;
      END;
        
			/* Se a data atual for maior ou igual a data de comunicação e se
			   a data atual não passou 15 dias da data de comunicação */
			IF vr_dtmvtolt >= vr_dtcomuni AND
				 (vr_dtcomuni + 15) > vr_dtmvtolt THEN			   		     
				 
				 -- Percorre lançamentos de cotas
			   FOR rw_craplct IN cr_craplct(vr_dtmvtocd) LOOP
					  
				    -- Encontrou algum registro na consulta, atribui flag para true
				    vr_flgconsu := 1;
				    -- Somados valores referente ao retorno de sobras
						IF rw_craplct.cdhistor = 64 OR
               rw_craplct.cdhistor = 1801 OR
               rw_craplct.cdhistor = 1940 THEN
							 vr_vltotsob := vr_vltotsob + rw_craplct.vllanmto;
						END IF;            

						IF rw_craplct.cdhistor = 926 THEN /* Crédito Juros */
							 vr_vlliqjur := vr_vlliqjur + rw_craplct.vllanmto;
						END IF;
				 
				 END LOOP;
				 				 
			END IF;
			
			-- Alimenta parametros
			pr_flgconsu := vr_flgconsu;
			pr_vltotsob := NVL(vr_vltotsob,0);
			pr_vlliqjur := NVL(vr_vlliqjur,0);
			
			EXCEPTION
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

END sobr0001;
/
