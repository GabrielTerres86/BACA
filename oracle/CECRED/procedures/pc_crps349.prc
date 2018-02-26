CREATE OR REPLACE PROCEDURE CECRED.pc_crps349 (pr_cdcooper   IN crapcop.cdcooper%TYPE --> Coopeerativa
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag 0/1 para utilizar restart na chamada
                                              ,pr_cdagenci  IN PLS_INTEGER
                                              ,pr_idparale  IN PLS_INTEGER
                                              ,pr_stprogra  OUT PLS_INTEGER           --> Saída de termino da execução
                                              ,pr_infimsol  OUT PLS_INTEGER           --> Saída de termino da solicitação
                                              ,pr_cdcritic  OUT NUMBER                --> Código crítica
                                              ,pr_dscritic  OUT VARCHAR2) IS          --> Descrição crítica
BEGIN
/* ............................................................................

 Programa: pc_crps349                          Antigo fontes/crps349.p
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Fernando Hilgenstieler
 Data    : Agosto/2003.                    Ultima atualizacao: 26/02/2018

 Dados referentes ao programa:

 Frequencia: Diario (on-line)
 Objetivo  : Relatorio para acompanhamento dos valores aplicados
             e resgatados no mes.
             Solicitacao 02, ordem 7 e crrl294.

 Alteracoes:23/09/2003 - Colocar total no saldo (Margarete).

            22/04/2004 - Acrescentar mais uma via no rel. 294 (Eduardo)

            22/06/2004 - Tratar historico 145 (Margarete)

            21/09/2004 - Incluidos historicos 497/498/499/500/501(CI)(Mirtes)

            29/09/2004 - Gravacao de dados na tabela gninfpl do banco
                         generico, para relatorios gerenciais (Junior).

            09/11/2004 - Considerar Aplicacao proveniente da Conta de
                         Investimento(craplci = historico 491)(Mirtes)

            09/12/2004 - Incluir quantidade de aplicadores/resgates (Edson).

            15/08/2005 - Alterado para exibir tambem "Movimentos do dia nos
                         PACS" ao relatorio crrl294_99 (Diego).

            05/09/2005 - Retirado rotina para gravacao de dados dos relato-
                         rios gerenciais (Junior).

            08/09/2005 - Acerto no relatorio crrl294_99. (Ze).

            21/09/2005 - Modificado FIND FIRST para FIND na tabela
                         crapcop.cdcooper = glb_cdcooper (Diego).

            03/10/2005 - Alterado para imprimir apena uma copia para
                         CredCrea (Diego).

            30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).

            07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                         "fontes/iniprg.p" por causa da "glb_cdcooper"
                         (Evandro).

            17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

            17/05/2006 - Alterado numero de vias do relatorio crrl294_99
                         para Viacredi (Diego).

            14/11/2006 - Melhoria da performance (Evandro).

            01/08/2007 - Tratamento para aplicacoes RDC (David).

            19/11/2007 - Substituir chamada da include aplicacao.i pela
                         BO b1wgen0004.i. (Sidnei - Precise).

            24/03/2008 - Incluir historicos 478 e 530 (Magui).

            31/03/2008 - Retirado historico 387 da lista de historicos que
                         compoe o valor de credito (aplicado) das aplicacoes;
                       - Incluido historico 490 na leitura da craplci para
                         acrescentar valores no campo "Valor Resgatado" do
                         relatorio crrl294 (Elton).

            09/10/2009 - Alterado modo de somar o total das aplicacoes das
                         cooperativas (Elton).

            14/12/2010 - Alterada da ordem 8 para a ordem 49. Para ver
                         se perdemos menos tempo com crps414, pois as
                         aplicacoes ja estao em buffer (Magui).

            21/02/2011 - Usar temp-table para guardar as aplicacoes lidas
                         para nao calcular o saldo novamente quando
                         geracao total (Magui).

            20/05/2011 - Melhorar performance (Magui).

            10/08/2011 - Melhoria de performance (Evandro).

            03/01/2012 - Aumentado o format de zz,zz9 para zzz,zz9 (Tiago).

            01/02/2012 - Migrar para Oracle (Petter - Supero).

            29/10/2013 - Incluir chamada da procedure controla_imunidade
                         (Lucas R.)

            05/11/2013 - Tratamento para Imunidade Tributaria;
                       - Apresentar o resumo mensal por PAC no relatorio
                         gerencial. (Marcos-Supero)

            03/12/2013 - Ajuste nos nomes dos relatorios totalizadores de "99"
                         para "total" (Gabriel).

            22/01/2014 - Aumento de format do valor aplicado no relatorio de
                         MOVIMENTOS DO MES NOS PA'S. (Carlos)

            03/02/2014 - Alterado format do framef_Movimento_Dia campo
                         vlr. resgatado (Lucas R.)

            05/02/2014 - Correção de format "zz,zzz,zz9.99-" para
                        "zzz,zzz,zz9.99-" (Lucas).

            18/02/2014 - Manutenção 201402 e validação Nulls / Not Null  (Edison - AMcom)
            
            06/05/2014 - Alterado verificação de quebra de data de movimento(last-of) para 
                         utilizar a quebra acima(agencia) (Odirlei - AMcom)
												 
						18/09/2014 - Adicionado estrutura de aplicações de captação. (Reinert)
            
            26/11/2014 - Melhorias de Performance. Foi retirada a procedure interna que gerava o XML
                         para utilizar a gene0002.pc_escreve_xml (Alisson-AMcom)
                         
	       		06/02/2017 - Comentados dois IFs que determinavam se deveria ou nao somar os valores 
			                   totais de aplicacao e resgate do dia. Caso so houvesse um lancamento para o 
				       		       dia, o somatario nao estava sendo efetuado.
			                   Rafael (Mouts) - Chamado 581361
                   
            13/02/2018 - Projeto Ligeirinho. Rangel Decker AMcom. Alterado para paralelizar a execução deste relatorio.
            
            26/02/2018 - Remocao de hint no cursor da LCM e da LCI para melhoria de performance.
                         (Roberto - AMCOM / Fabricio - Cecred).
  ............................................................................. */
  DECLARE
    -- Tipo para totalização de valores (utilizados para criar totais dos relatórios)
    TYPE typ_reg_total IS
      RECORD(vr_vlaplica     NUMBER(20,8)             --> Valor aplicado
            ,vr_vlresgat     NUMBER(20,8)             --> Valor resgatado
            ,vr_vltotdia     NUMBER(20,8)             --> Valor saldo
            ,vr_qtaplica     NUMBER                   --> Quantidade de aplicação
            ,vr_qtresgat     NUMBER                   --> Quantidade de resgate
            ,vr_rel_vltotfxa NUMBER(20,8)             --> Valor total faixa
            ,vr_rel_vlfaixas NUMBER(20,8)             --> Valor faixas
            ,vr_rel_qtporfxa NUMBER                   --> Quantidade por faixa
            ,vr_dtmvtdia     DATE                     --> Datas de movimento
            ,vr_qttotfxa     NUMBER                   --> Quantidade total por faixa
            ,vr_vltotfxa     NUMBER(20,8));           --> Valor faixa totalizado

    TYPE typ_tab_total IS TABLE OF typ_reg_total INDEX BY PLS_INTEGER;
    vr_typ_total    typ_tab_total;
    
		-- PLTable para armazenar aplicações de captação		
		TYPE typ_reg_craprac IS
		  RECORD(vlsldtot    NUMBER(20,8)
			      ,qtaplica    NUMBER
						,nmprodut    crapcpc.nmprodut%TYPE);
						
    TYPE typ_tab_craprac IS TABLE OF typ_reg_craprac INDEX BY VARCHAR2(6);
		vr_tab_craprac       typ_tab_craprac;						
		vr_indice_craprac    VARCHAR2(6);
								
    TYPE typ_tab_tot_craprac IS TABLE OF typ_reg_craprac INDEX BY VARCHAR2(6);
		vr_tot_craprac       typ_tab_tot_craprac;										

    vr_cdprogra     VARCHAR2(100);                                                       --> Nome do programa
    vr_cdcritic     NUMBER;                                                              --> Descritivo da crítica
    vr_dscritic     VARCHAR2(400);                                                       --> Descritivo da crítica
    vr_lshistor     VARCHAR2(4000);                                                       --> Históricos base
    vr_lshisdeb     VARCHAR2(400) := '107,115,142,159,184,186,187,388,473,477,478,497,498,499,500,501,528,530,534'; --> Históricos para débito
    vr_lshiscre     VARCHAR2(400) := '106,114,145,160,177,263,472,527';                  --> Históricos para crédito
    vr_rel_vlaplica NUMBER(14,2) := 0;                                                   --> Valor aplicado
    vr_rel_vlresgat NUMBER(14,2) := 0;                                                   --> Valor resgatado
    vr_rel_vltotdia NUMBER(14,2) := 0;                                                   --> Valor do saldo
    vr_rel_vltotapl NUMBER(14,2) := 0;                                                   --> Valor total aplicado
    vr_rel_vltotres NUMBER(14,2) := 0;                                                   --> Valor total resgate
    vr_rel_vltotsld NUMBER(14,2) := 0;                                                   --> Valor total saldo
    vr_rel_qtdaplic NUMBER := 0;                                                         --> Quantidade aplicação
    vr_rel_qtresgat NUMBER := 0;                                                         --> Quantidade resgate
    vr_rel_qttotapl NUMBER := 0;                                                         --> Quantidade total aplicação
    vr_rel_qttotres NUMBER := 0;                                                         --> Quantidade total resgate
    vr_contadia     NUMBER := 0;                                                         --> Contagem de dias para índice
    vr_nmarqimp     VARCHAR2(20);                                                        --> Nome do arquivo gerado
    vr_flgfirst     BOOLEAN := false;                                                    --> Controle de iteração
    vr_dtmvtini     DATE;                                                                --> Data inicial do movimento
    vr_cdageant     NUMBER := 0;                                                         --> Código anterior da agência
    vr_contador     NUMBER := 0;                                                         --> Controle de contagem
    vr_qtfaixas     NUMBER := 0;                                                         --> Faixas de operação
    vr_cartaxas     gene0002.typ_split;                                                  --> Split de Taxas
    vr_qttotrdc     NUMBER := 0;                                                         --> Quantidade total RDC
    vr_qttotrii     NUMBER := 0;                                                         --> Totalização
    vr_vltotrdc     NUMBER(14,2) := 0;                                                   --> Valor total RDC
    vr_vltotrii     NUMBER(14,2) := 0;                                                   --> Valor total
    vr_tot_qtrdcpre NUMBER := 0;                                                         --> Quantidade total pré
    vr_tot_qtrdcpos NUMBER := 0;                                                         --> Quantidade total pós
    vr_tot_vlrdcpre NUMBER(14,2) := 0;                                                   --> Valor total pré
    vr_tot_vlrdcpos NUMBER(14,2) := 0;                                                   --> Valor total pós
    vr_vlsldrdc     NUMBER(25,8) := 0;                                                   --> Valor líquido
    rw_crapdat      btch0001.cr_crapdat%rowtype;                                         --> Tipo para retorno do cursor
    vr_aux_vllanmto craplcm.vllanmto%TYPE := 0;                                          --> Auxiliar para cálculo de valor movimento
    vr_aux_craplcm  craplcm.vllanmto%TYPE := 0;                                          --> Auxiliar para cálculo de valor
    vr_des_xml      CLOB;                                                                --> Variável para armazenar iteração dos dados para o XML
    vr_dstexto      VARCHAR2(32700) := NULL;                                                     --> Variavel para armazenar o texto para o CLOB
    vr_vltotass     NUMBER(14,2) := 0;                                                   --> Valor total da soma
    vr_nrcopias     NUMBER := 0;                                                         --> Número de cópias do relatório
    vr_nom_dir      VARCHAR2(400);                                                       --> Nome do diretório que será salvo os XML e PDF
    vr_idx_crap     VARCHAR2(30);                                                        --> Variável para armazenar o índice do vetor da CRAPLCM
    vr_cindex       NUMBER := 1;                                                         --> Variável sequenciadora para índice do vetor da CRAPLCM
    vr_dindex       DATE := to_date('01/01/9999', 'DD/MM/RRRR');                         --> Indexador de data da PL TABLE
    vr_aindex       NUMBER := 0;                                                         --> Indexador de agência da PL TABLE
    vr_dtinitax     DATE;                                                                --> Data incial para cálculo da taxa
    vr_dtfimtax     DATE;                                                                --> Data final para cálculo da taxa
    vr_sldaplic     craprda.vlsdrdca%TYPE := 0;                                          --> Variável para cálculo do saldo de aplicação
    vr_nrindex      NUMBER;                                                              --> Variável para controle do índice da PL Table (quebra por conta)
    vr_vlsdrdca     NUMBER := 0;                                                         --> Variável para o valor do RDCA
    vr_vldperda     NUMBER := 0;                                                         --> Variável para o valor calculado da perda
    vr_txaplica     NUMBER := 0;                                                         --> Taxa aplicada sob o empréstimo
    vr_rel_qtaplica NUMBER := 0;                                                         --> Quantidade de aplicação
    vr_rel_vlsdaplc NUMBER(14,2) := 0;                                                   --> Valor saldo da aplicação
    vr_rd2_vlsdrdca NUMBER := 0;                                                         --> Saldo da aplicação pós cálculo
    vr_rel_qtrdcaii NUMBER := 0;                                                         --> Quantidade RDCA
    vr_rel_vlsdrdii NUMBER(14,2) := 0;                                                   --> Valores de taxas
    vr_proximo      EXCEPTION;                                                           --> Exceção para controlar iteração de laço
    vr_rel_qtrdcpre NUMBER := 0;                                                         --> Quantidade pré
    vr_rel_vlrdcpre NUMBER(14,2) := 0;                                                   --> Valor pré
    vr_vlrdirrf     craplap.vllanmto%TYPE;                                               --> Valor de IR
    vr_perirrgt     NUMBER := 0;                                                         --> Cálculo do período
    vr_vlrentot     NUMBER := 0;                                                         --> Valor de rendimento total
    vr_rel_qtrdcpos NUMBER := 0;                                                         --> Quantidade pós
    vr_rel_vlrdcpos NUMBER := 0;                                                         --> Valor pós
    vr_inddata      DATE;                                                                --> Indexador de data para quebra
    vr_regis        NUMBER := 0;                                                         --> Armazena a quantidade de registros iterados
    vr_tpaplrdc     NUMBER := 0;                                                         --> Variável para armazenar valor da PL Table para uso futuro
    vr_nmformul     VARCHAR2(400) := '';                                                 --> Nome do formuário
    vr_qtdto60      NUMBER := 0;                                                         --> Quantidade total do RDCA60
    vr_vlrto60      NUMBER(20,2) := 0;                                                   --> Valor total do RDCA60
    vr_regisdtc     NUMBER := 0;                                                         --> Quantidade de registros da iteração do LOOP CRAPDTC
    vr_idxwapli     VARCHAR2(30);                                                        --> Variável para índice de iteração da waplic
    vr_pacctr       NUMBER := 0;                                                         --> Variável para controle do código corrente do PAC
    vr_vlsldapl     NUMBER(20,8);                                                        --> Variável para receber valor de DRCA30
    vr_exc_saida    EXCEPTION;                                                           --> Exceção (erros)
    vr_sldpresg_tmp craplap.vllanmto%TYPE;                                               --> Valor saldo de resgate
    vr_dup_vlsdrdca craplap.vllanmto%TYPE;                                               --> Acumulo do saldo da aplicacao RDCA    


    -- Variáveis utilizadas na chamada das procedures pc_posicao_saldo_aplicacao_pre/pos 
    vr_vlbascal NUMBER := 0;                                                             --> Base de Calculo
		vr_vlsldtot NUMBER := 0;                                                             --> Saldo Total
		vr_vlsldrgt NUMBER := 0;                                                             --> Saldo de Resgate
		vr_vlultren NUMBER := 0;                                                             --> Ultimo Rendimento
		vr_vlrevers NUMBER := 0;                                                             --> Valor de Reversão
		vr_percirrf NUMBER := 0;                                                             --> Percentual de IRRF
    
    -- Tipo para instanciar PL Table para armazenar registros selecionados da CRAPDTC
    TYPE typ_reg_crapdtc IS
      RECORD(tpaplrdc crapdtc.tpaplrdc%TYPE
            ,tpaplica crapdtc.tpaplica%TYPE);

    TYPE typ_tab_crapdtc IS TABLE OF typ_reg_crapdtc INDEX BY pls_integer;
    vr_tab_crapdtc typ_tab_crapdtc;

    -- Tipo para instanciar PL Table para armazenar registros selecionados da CRAPLCM
    TYPE typ_reg_crawlcm IS
      RECORD(cdagenci     crapass.cdagenci%TYPE
            ,dtmvtolt     craplcm.dtmvtolt%TYPE
            ,vlaplica     NUMBER
            ,vlresgat     NUMBER);

    -- Instancia e indexa o tipo da TEMP TABLE para liberar para uso
    TYPE typ_tab_crawlcm IS TABLE OF typ_reg_crawlcm INDEX BY VARCHAR2(30);
    vr_tab_crawlcm typ_tab_crawlcm;

    -- Tipo para instanciar TEMP TABLE para armazenar registros selecionados da CRAPLCM (registros diferentes do anterior)
    TYPE typ_reg_cratlcm IS
      RECORD(dtmvtolt DATE
            ,cdagenci crapass.cdagenci%TYPE
            ,vlaplica NUMBER(14,2)
            ,vlresgat NUMBER(14,2)
            ,vltotdia NUMBER(14,2)
            ,qtdaplic NUMBER
            ,qtresgat NUMBER
            ,vltotapl NUMBER(14,2)
            ,vltotres NUMBER(14,2)
            ,vltotsld NUMBER(14,2)
            ,qttotapl NUMBER
            ,qttotres NUMBER);

    -- Definicao do tipo de registro de associados
     TYPE typ_reg_crapass IS RECORD (cdagenci crapass.cdagenci%TYPE);

     -- Definicao do tipo de tabela de associados
     TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
     vr_tab_crapass  typ_tab_crapass;

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_cratlcm IS TABLE OF typ_reg_cratlcm INDEX BY VARCHAR2(30);
    vr_tab_cratlcm typ_tab_cratlcm;

    -- Tipo para instanciar PL TABLE para armazenar registros referente a saldo de aplicação
    TYPE typ_reg_waplica IS
      RECORD(cdcooper   craprda.cdcooper%TYPE
            ,cdageass   craprda.cdagenci%TYPE
            ,nrdconta   craprda.nrdconta%TYPE
            ,nrdcontant craprda.nrdconta%TYPE
            ,nraplica   craprda.nraplica%TYPE
            ,tpaplica   VARCHAR2(5)
            ,vlsdrdca   craprda.vlsdrdca%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_waplica IS TABLE OF typ_reg_waplica INDEX BY VARCHAR2(30);
    vr_tab_waplica typ_tab_waplica;

    -- Instancia TEMP TABLE referente a tabela CRAPERR
    vr_tab_craterr GENE0001.typ_tab_erro;

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS           --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Cadastro aplicações RDCA */
    CURSOR cr_craprda (pr_cdcooper IN craptab.cdcooper%TYPE
                      ,pr_cdageass IN craprda.cdageass%TYPE) IS          --> Código da cooperativa
      select cr.tpaplica
            ,cr.nrdconta
            ,cr.nraplica
            ,cr.cdageass
            ,count(1) over() registros
      FROM craprda cr,
           crapass ass
      WHERE cr.cdcooper = ass.cdcooper
        AND cr.nrdconta = ass.nrdconta
        AND cr.cdcooper = pr_cdcooper
        AND cr.insaqtot = 0
        AND cr.cdageass = pr_cdageass
        AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
      ORDER BY cr.cdageass, cr.nrdconta;
			
		-- Busca aplicações de captação
		CURSOR cr_craprac (pr_cdcooper IN craprac.cdcooper%TYPE      --> Cooperativa
		                  ,pr_cdagenci IN crapass.cdagenci%TYPE) IS	 --> PA
			SELECT craprac.nrdconta nrdconta
			      ,craprac.nraplica nraplica
						,craprac.qtdiacar qtdiacar
						,craprac.dtmvtolt dtmvtolt
						,craprac.txaplica txaplica
			      ,crapcpc.idtxfixa idtxfixa
						,crapcpc.cddindex cddindex
						,crapcpc.idtippro idtippro
						,crapcpc.nmprodut nmprodut						
						,crapass.cdagenci cdagenci
						,craprac.cdprodut cdprodut
			  FROM craprac
				    ,crapcpc
						,crapass
			 WHERE craprac.cdcooper = pr_cdcooper      AND
						 craprac.idsaqtot = 0                AND
						 crapass.cdcooper = craprac.cdcooper AND
						 crapass.nrdconta = craprac.nrdconta AND
						 crapass.cdagenci = pr_cdagenci      AND
             crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci) AND
						 craprac.cdprodut = crapcpc.cdprodut;

    /* Descrição dos tipos de captação oferecidos aos cooperados */
    CURSOR cr_crapdtc (pr_cdcooper IN crapdtc.cdcooper%TYPE) IS          --> Código cooperativa
      SELECT cc.tpaplrdc
            ,cc.tpaplica
      FROM crapdtc cc
      WHERE cc.cdcooper = pr_cdcooper
        AND cc.tpaplica = cc.tpaplica;

    /* Cursor genérico de parametrização */
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE               --> Código cooperativa
                     ,pr_nmsistem IN craptab.nmsistem%TYPE               --> Nome sistema
                     ,pr_tptabela IN craptab.tptabela%TYPE               --> Tipo tabela
                     ,pr_cdempres IN craptab.cdempres%TYPE               --> código empresa
                     ,pr_cdacesso IN craptab.cdacesso%TYPE               --> Código acesso
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS           --> Tipo de registro
      SELECT /*+ INDEX(tab CRAPTAB##CRAPTAB1)*/
             tab.dstextab
            ,tab.tpregist
            ,tab.ROWID
        FROM craptab tab
       WHERE tab.cdcooper        = pr_cdcooper
         AND upper(tab.nmsistem) = pr_nmsistem
         AND upper(tab.tptabela) = pr_tptabela
         AND tab.cdempres        = nvl(pr_cdempres,0)
         AND upper(tab.cdacesso) = pr_cdacesso
         AND tab.tpregist        = nvl(pr_tpregist,0);
    rw_craptab cr_craptab%ROWTYPE;

    /* Busca registros de lançamentos */
    CURSOR cr_craplcm (pr_cdcooper IN craptab.cdcooper%TYPE      --> Código da cooperativa
                      ,pr_dtmvtini IN craplcm.dtmvtolt%TYPE      --> Data movimento inicial
                      ,pr_dtmvtfim IN craplcm.dtmvtolt%TYPE      --> Data movimento final
                      ,pr_cdhistor IN VARCHAR2) IS               --> Listagem de códigos para histórico
      SELECT cm.dtmvtolt
            ,cm.cdhistor
            ,cm.vllanmto
            ,cm.nrdconta
      FROM craplcm cm,
           crapass ass
      WHERE cm.cdcooper = ass.cdcooper
        AND cm.nrdconta = ass.nrdconta
        AND cm.cdcooper = pr_cdcooper
        AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
        AND cm.dtmvtolt BETWEEN pr_dtmvtini AND pr_dtmvtfim
        AND ',' || pr_cdhistor || ',' LIKE ('%,' || cm.cdhistor || ',%');

    /* Busca cadastro de associados */
    CURSOR cr_crapass (pr_cdcooper IN craptab.cdcooper%TYPE) IS    --> Código da cooperativa
      SELECT cs.cdagenci
            ,cs.nrdconta
            ,cs.rowid
      FROM crapass cs
      WHERE cs.cdcooper = pr_cdcooper
        AND cs.cdagenci = decode(pr_cdagenci,0,cs.cdagenci,pr_cdagenci);

    /* Busca para popular TEMP TABLE */
    CURSOR cr_crapage (pr_cdcooper IN craptab.cdcooper%TYPE        --> Código da cooperativa
                      ,pr_insitage IN crapage.insitage%TYPE        --> Código inicial da tabela
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS    --> Código da agência
      SELECT nmresage
            ,cdagenci
      FROM crapage
      WHERE crapage.cdcooper = pr_cdcooper
        AND crapage.insitage = nvl(pr_insitage, crapage.insitage)
        AND crapage.cdagenci = nvl(pr_cdagenci, crapage.cdagenci);
    rw_crapage cr_crapage%rowtype;

    /* Busca movimento conta investimento */
    CURSOR cr_craplci (pr_cdcooper IN craptab.cdcooper%TYPE      --> Código da cooperativa
                      ,pr_dtmvtini IN craplci.dtmvtolt%TYPE      --> Data inicial do movimento
                      ,pr_dtmvtfim IN craplci.dtmvtolt%TYPE) IS  --> Data final do movimento
      SELECT ci.nrdconta
            ,ci.dtmvtolt
            ,ci.cdhistor
            ,ci.vllanmto
      FROM craplci ci,
           crapass ass
      WHERE ci.cdcooper = ass.cdcooper
        AND ci.nrdconta = ass.nrdconta
        AND ci.cdcooper = pr_cdcooper
        AND ci.dtmvtolt BETWEEN pr_dtmvtini AND pr_dtmvtfim
        AND ci.cdhistor in (490, 491)
        AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci);
				
		-- Busca cadastro de produtos de captação
		CURSOR cr_crapcpc IS
		  SELECT 
        (SELECT rtrim(sys.stragg(to_char(cdhsvrcc) || ','), ',') cdhsvrcc FROM (SELECT crapcpc.cdhsvrcc cdhsvrcc FROM crapcpc GROUP BY cdhsvrcc)) AS cdhsvrcc
       ,(SELECT rtrim(sys.stragg(to_char(cdhscacc) || ','), ',') cdhscacc FROM (SELECT crapcpc.cdhscacc cdhscacc FROM crapcpc GROUP BY cdhscacc)) AS cdhscacc
      FROM DUAL;
		rw_crapcpc cr_crapcpc%ROWTYPE;
    
    --Início - Projeto Ligeirinho 
    vr_jobname        VARCHAR2(500);
    vr_dsplsql        VARCHAR2(3000);
    vr_qtdjobs        NUMBER;
    vr_qterro         NUMBER;
    vr_idparale       NUMBER;
    vr_idlog_ini_ger  NUMBER;
    vr_idlog_ini_par  NUMBER;
    vr_tpexecucao     tbgen_prglog.tpexecucao%type;    
    --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole     tbgen_batch_controle.idcontrole%TYPE; 
    vr_dsinformacao   tbgen_batch_relatorio_wrk.dscritic%TYPE;
  
    --Cursor buscar a informação de todas as agências que o programa será executado.
    --Controlando também a re-execução de uma agência através do parametro pr_qterro
    CURSOR cr_crapagepar (pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_cdprogra IN tbgen_batch_controle.cdprogra%TYPE
                         ,pr_qterro   IN NUMBER) IS 
      select age.cdagenci 
        from crapage age 
       where age.cdcooper = pr_cdcooper
         and age.cdagenci = decode(pr_cdagenci,0,age.cdagenci,pr_cdagenci) 
         and (pr_qterro = 0 or 
             (pr_qterro > 0 and exists (select 1
                                          from tbgen_batch_controle
                                         where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                           and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                           and tbgen_batch_controle.tpagrupador = 1
                                           and tbgen_batch_controle.cdagrupador = age.cdagenci
                                           and tbgen_batch_controle.insituacao  = 1
                                           and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
      order by age.cdagenci asc; 
    
    --Fim - Projeto Ligeirinho
   
    -- Procedure para criar registros na TEMP TABLE na WAPLI
    PROCEDURE pc_cria_wapli(pr_cdcooper    IN craprda.cdcooper%TYPE
                           ,pr_cdageass    IN craprda.cdageass%TYPE
                           ,pr_nrdconta    IN craprda.nrdconta%TYPE
                           ,pr_nraplica    IN craprda.nraplica%TYPE
                           ,pr_tpaplica    IN VARCHAR2
                           ,pr_vlsdrdca    IN craprda.vlsdrdca%TYPE) IS
    BEGIN
      DECLARE
        vr_index  VARCHAR2(30);

      BEGIN
        vr_index := lpad(pr_cdageass, 8, '0') || lpad(pr_nrdconta, 12, '0') || lpad(pr_nraplica, 10, '0');

        vr_tab_waplica(vr_index).cdcooper := pr_cdcooper;
        vr_tab_waplica(vr_index).cdageass := pr_cdageass;
        vr_tab_waplica(vr_index).nrdconta := pr_nrdconta;
        vr_tab_waplica(vr_index).nraplica := pr_nraplica;
        vr_tab_waplica(vr_index).tpaplica := pr_tpaplica;
        vr_tab_waplica(vr_index).vlsdrdca := pr_vlsdrdca;
      END;
    END pc_cria_wapli;

    -- Procedure para criar registros na TEMP TABLE da CRAPLCM
    PROCEDURE pc_cria_cratlcm(pr_dtmvtolt    IN DATE
                             ,pr_cdagenci    IN crapass.cdagenci%TYPE
                             /* Totais por Dia */
                             ,pr_vlaplica    IN NUMBER
                             ,pr_vlresgat    IN NUMBER
                             ,pr_vltotdia    IN NUMBER
                             ,pr_qtdaplic    IN NUMBER
                             ,pr_qtresgat    IN NUMBER
                             /* Totais Mes */
                             ,pr_vltotapl    IN NUMBER
                             ,pr_vltotres    IN NUMBER
                             ,pr_vltotsld    IN NUMBER
                             ,pr_qttotapl    IN NUMBER
                             ,pr_qttotres    IN NUMBER) IS
    BEGIN
      DECLARE
        vr_index  NUMBER;

      BEGIN
        vr_index:= vr_tab_cratlcm.count() + 1;
        vr_tab_cratlcm(vr_index).dtmvtolt := pr_dtmvtolt;
        vr_tab_cratlcm(vr_index).cdagenci := pr_cdagenci;
        /* Total Dia */
        vr_tab_cratlcm(vr_index).vlaplica := pr_vlaplica;
        vr_tab_cratlcm(vr_index).vlresgat := pr_vlresgat;
        vr_tab_cratlcm(vr_index).vltotdia := pr_vltotdia;
        vr_tab_cratlcm(vr_index).qtdaplic := pr_qtdaplic;
        vr_tab_cratlcm(vr_index).qtresgat := pr_qtresgat;
        /* Total Mes */
        vr_tab_cratlcm(vr_index).vltotapl := pr_vltotapl;
        vr_tab_cratlcm(vr_index).vltotres := pr_vltotres;
        vr_tab_cratlcm(vr_index).vltotsld := pr_vltotsld;
        vr_tab_cratlcm(vr_index).qttotapl := pr_qttotapl;
        vr_tab_cratlcm(vr_index).qttotres := pr_qttotres;
      END;
    END pc_cria_cratlcm;

    -- Procedure para criar registros na TEM TABLE da CRAPLCM
    PROCEDURE pc_cria_crawlcm (pr_cdagenci       IN crapass.cdagenci%TYPE
                              ,pr_dtmvtolt       IN craplcm.dtmvtolt%TYPE
                              ,pr_vlaplica       IN NUMBER
                              ,pr_vlresgat       IN NUMBER) IS
    BEGIN
      DECLARE
        vr_index   VARCHAR2(30);

      BEGIN
        vr_index := lpad(pr_cdagenci, 4, '0') || lpad(to_char(pr_dtmvtolt, 'DDMMRRRR'), 10, '0') || lpad(to_char(vr_cindex), 16, '0');

        vr_cindex := vr_cindex + 1;

        vr_tab_crawlcm(vr_index).cdagenci := nvl(pr_cdagenci, 0);
        vr_tab_crawlcm(vr_index).dtmvtolt := pr_dtmvtolt;
        vr_tab_crawlcm(vr_index).vlaplica := nvl(pr_vlaplica, 0);
        vr_tab_crawlcm(vr_index).vlresgat := nvl(pr_vlresgat, 0);
      END;
    END pc_cria_crawlcm;
    
    
    PROCEDURE pc_insere_tab_wrk(pr_cdcooper     in tbgen_batch_relatorio_wrk.cdcooper%type 
                               ,pr_cdprogra     in tbgen_batch_relatorio_wrk.cdprograma%type
                               ,pr_dsrelatorio  in tbgen_batch_relatorio_wrk.dsrelatorio%type
                               ,pr_dtmvtolt     in tbgen_batch_relatorio_wrk.dtmvtolt%type
                               ,pr_dschave      in tbgen_batch_relatorio_wrk.dschave%type
                               ,pr_dsinformacao in tbgen_batch_relatorio_wrk.dscritic%type
                               ,pr_cdagenci     in tbgen_batch_relatorio_wrk.cdagenci%type
                               ,pr_dscritic    out varchar2) IS
      
    BEGIN
      
      begin
  
        insert into tbgen_batch_relatorio_wrk(cdcooper,
                                              cdprograma,
                                              dsrelatorio,
                                              dtmvtolt,
                                              dschave,
                                              dscritic,
                                              cdagenci)
                                       values(pr_cdcooper,
                                              pr_cdprogra,
                                              pr_dsrelatorio,
                                              pr_dtmvtolt,
                                              pr_dschave,
                                              pr_dsinformacao,
                                              pr_cdagenci);
      exception
        when others then
          pr_dscritic := 'Erro ao inserir tbgen_batch_relatorio_wrk: '||sqlerrm;            
      end;  
    
    END pc_insere_tab_wrk;
    
    
    PROCEDURE pc_gera_crrl294_total IS
     
      CURSOR cr_mov_dia IS
        SELECT tb.dscritic ds_xml
          FROM tbgen_batch_relatorio_wrk tb
         WHERE tb.cdcooper    = pr_cdcooper
           AND tb.cdprograma  = vr_cdprogra
           AND tb.dsrelatorio = 'MOVIMENTOS_DIA'
           AND tb.dtmvtolt    = rw_crapdat.dtmvtolt
        ORDER BY tb.cdagenci;
        
      CURSOR cr_mov_mes IS
        SELECT tb.dscritic ds_xml
          FROM tbgen_batch_relatorio_wrk tb
         WHERE tb.cdcooper    = pr_cdcooper
           AND tb.cdprograma  = vr_cdprogra
           AND tb.dsrelatorio = 'MOVIMENTOS_MES'
           AND tb.dtmvtolt    = rw_crapdat.dtmvtolt
        ORDER BY tb.cdagenci;    

      CURSOR cr_resumo_mes IS
        SELECT TO_DATE(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1),'MM/DD/RRRR') dtmvdia,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vlaplico,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))) vlresgte,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))) vltotadi,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,5)+1,instr(a.dscritic,';',1,6)-instr(a.dscritic,';',1,5)-1))) qtaplico,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,6)+1,instr(a.dscritic,';',1,7)-instr(a.dscritic,';',1,6)-1))) qtresgte           
          FROM tbgen_batch_relatorio_wrk a
         WHERE a.cdcooper    = pr_cdcooper
           AND a.cdprograma  = vr_cdprogra
           AND a.dsrelatorio = 'RESUMO_MES'
           AND a.dtmvtolt    = rw_crapdat.dtmvtolt
        GROUP BY TO_DATE(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1),'MM/DD/RRRR') 
        ORDER BY TO_DATE(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1),'MM/DD/RRRR') ;
        
      CURSOR cr_total_mes IS
        SELECT sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) qttotapl,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vltotapl,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))) qttotres,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))) vltotres,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,5)+1,instr(a.dscritic,';',1,6)-instr(a.dscritic,';',1,5)-1))) vltotsld           
          FROM tbgen_batch_relatorio_wrk a
         WHERE a.cdcooper    = pr_cdcooper
           AND a.cdprograma  = vr_cdprogra
           AND a.dsrelatorio = 'TOTAL_MES'
           AND a.dtmvtolt    = rw_crapdat.dtmvtolt;    
           
      CURSOR cr_rdca_rdca60 IS
        SELECT sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) qttotrdc,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vltotrdc,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))) qttotrii,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))) vltotrii          
          FROM tbgen_batch_relatorio_wrk a
         WHERE a.cdcooper    = pr_cdcooper
           AND a.cdprograma  = vr_cdprogra
           AND a.dsrelatorio = 'RDCA_RDCA60'
           AND a.dtmvtolt    = rw_crapdat.dtmvtolt;  
           
           
      CURSOR cr_faixa_rdca_ate IS
        SELECT TO_NUMBER(a.dschave) vlfaixas,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) qttotfxa,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vltotfxa          
          FROM tbgen_batch_relatorio_wrk a
         WHERE a.cdcooper    = pr_cdcooper
           AND a.cdprograma  = vr_cdprogra
           AND a.dsrelatorio = 'FAIXAS_RDCA'
           AND a.dtmvtolt    = rw_crapdat.dtmvtolt 
        GROUP BY TO_NUMBER(a.dschave)  
        ORDER BY TO_NUMBER(a.dschave);    
        
      CURSOR cr_faixa_rdca_acima IS
        SELECT sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) qttotfxa,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vltotfxa          
          FROM tbgen_batch_relatorio_wrk a
         WHERE a.cdcooper    = pr_cdcooper
           AND a.cdprograma  = vr_cdprogra
           AND a.dsrelatorio = 'FAIXA_ACIMA_DE'
           AND a.dtmvtolt    = rw_crapdat.dtmvtolt 
        GROUP BY TO_NUMBER(a.dschave)  
        ORDER BY TO_NUMBER(a.dschave);  
        
      CURSOR cr_totger_rdc IS
        SELECT sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) qtrdcpre,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vlrdcpre,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))) qtrdcpos,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))) vlrdcpos          
          FROM tbgen_batch_relatorio_wrk a
         WHERE a.cdcooper    = pr_cdcooper
           AND a.cdprograma  = vr_cdprogra
           AND a.dsrelatorio = 'TOTAL_GERAL_RDC'
           AND a.dtmvtolt    = rw_crapdat.dtmvtolt;  
     
      CURSOR cr_total_rac IS
        SELECT a.dschave faixa,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) qtaplica,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vlsldtot          
          FROM tbgen_batch_relatorio_wrk a
         WHERE a.cdcooper    = pr_cdcooper
           AND a.cdprograma  = vr_cdprogra
           AND a.dsrelatorio = 'TOTAL_GERAL_RAC'
           AND a.dtmvtolt    = rw_crapdat.dtmvtolt 
        GROUP BY a.dschave  
        ORDER BY a.dschave;                  

    BEGIN
      
      -- Iniciar processo para criar XML para agencia 99
      -- Nome do arquivo XML
      vr_nmarqimp := 'crrl294_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');
      
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      vr_dstexto := NULL;
          
      -- Inicializar a raiz do XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="UTF-8"?><base><pacs>');
      
      --Cria tags valores movimentos dia
      FOR rw_mov_dia in cr_mov_dia LOOP
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,rw_mov_dia.ds_xml);  
      END LOOP; 
      
      --Cria tags movimentos Mês
      FOR rw_mov_mes in cr_mov_mes LOOP
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,rw_mov_mes.ds_xml);  
      END LOOP;   
      
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</pacs><totalPacs>');
      
      --Cria tags do resumo do mes
      FOR rw_resumo_mes IN cr_resumo_mes LOOP
        
        -- Cria nodo filho no XML
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                   '<totalPac>
                      <dtmvdia>'  || to_char(rw_resumo_mes.dtmvdia, 'DD/MM/RR')              || '</dtmvdia>
                      <vlaplico>' || to_char(rw_resumo_mes.vlaplico, 'FM999G999G999G990D90') || '</vlaplico>
                      <vlresgte>' || to_char(rw_resumo_mes.vlresgte, 'FM999G999G999G990D90') || '</vlresgte>
                      <vltotadi>' || to_char(rw_resumo_mes.vltotadi, 'FM999G999G999G990D90') || '</vltotadi>
                      <qtaplico>' || to_char(rw_resumo_mes.qtaplico, 'FM999G999G999G990')    || '</qtaplico>
                      <qtresgte>' || to_char(rw_resumo_mes.qtresgte, 'FM999G999G999G990')    || '</qtresgte>
                    </totalPac>');  
      
      END LOOP;
      
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</totalPacs>');
      
      FOR rw_total_mes IN cr_total_mes LOOP
        
        -- Cria nodo filho no XML
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                      '<total99>
                        <qttotapl>' || to_char(rw_total_mes.qttotapl, 'FM999G999G999G990')    || '</qttotapl>
                        <vltotapl>' || to_char(rw_total_mes.vltotapl, 'FM999G999G999G990D90') || '</vltotapl>
                        <qttotres>' || to_char(rw_total_mes.qttotres, 'FM999G999G999G990')    || '</qttotres>
                        <vltotres>' || to_char(rw_total_mes.vltotres, 'FM999G999G999G990D90') || '</vltotres>
                        <vltotsld>' || to_char(rw_total_mes.vltotsld, 'FM999G999G999G990D90') || '</vltotsld>
                      </total99>'); 
                         
      END LOOP;  

      
      FOR rw_rdca_rdca60 IN cr_rdca_rdca60 LOOP
        
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                   '<totalGeral>
                      <faixa>RDCA</faixa>
                      <faixa1>RDCA60</faixa1>
                      <qttotrdc>' || to_char(rw_rdca_rdca60.qttotrdc, 'FM999G999G999G990MI')    || '</qttotrdc>
                      <vltotrdc>' || to_char(rw_rdca_rdca60.vltotrdc, 'FM999G999G999G990D90MI') || '</vltotrdc>
                      <qttotrii>' || to_char(rw_rdca_rdca60.qttotrii, 'FM999G999G999G990MI')    || '</qttotrii>
                      <vltotrii>' || to_char(rw_rdca_rdca60.vltotrii, 'FM999G999G999G990D90MI') || '</vltotrii>
                    </totalGeral>');
                    
      END LOOP;  
      
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<totais>');
      
      
      FOR rw_faixa_rdca_ate IN cr_faixa_rdca_ate LOOP
      
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                    '<totalAte>
                      <faixa>ATE:</faixa>
                      <vlfaixas>' || to_char(rw_faixa_rdca_ate.vlfaixas, 'FM999G999G999G990D90MI') || '</vlfaixas>
                      <qttotfxa>' || to_char(rw_faixa_rdca_ate.qttotfxa, 'FM999G999G999G990MI')    || '</qttotfxa>
                      <vltotfxa>' || to_char(rw_faixa_rdca_ate.vltotfxa, 'FM999G999G999G990D90MI') || '</vltotfxa>
                    </totalAte>');  
        
      END LOOP;  
      


      FOR rw_faixa_rdca_acima IN cr_faixa_rdca_acima LOOP  
       
        -- Cria nodo filho no XML (totalizador)
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                   '<totalAcima>
                      <faixa>ACIMA DE:</faixa>
                      <qttotfxa>' || to_char(rw_faixa_rdca_acima.qttotfxa, 'FM999G999G999G990MI')    || '</qttotfxa>
                      <vltotfxa>' || to_char(rw_faixa_rdca_acima.vltotfxa, 'FM999G999G999G990D90MI') || '</vltotfxa>
                    </totalAcima>');                

      END LOOP;
      
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</totais>');  
      
      FOR rw_totger_rdc IN cr_totger_rdc LOOP
            
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                   '<totalGeralRDC>
                      <faixa>RDCPRE</faixa>
                      <faixa1>RDCPOS</faixa1>
                      <qtrdcpre>' || to_char(rw_totger_rdc.qtrdcpre, 'FM999G999G999G990MI')    || '</qtrdcpre>
                      <vlrdcpre>' || to_char(rw_totger_rdc.vlrdcpre, 'FM999G999G999G990D90MI') || '</vlrdcpre>
                      <qtrdcpos>' || to_char(rw_totger_rdc.qtrdcpos, 'FM999G999G999G990MI')    || '</qtrdcpos>
                      <vlrdcpos>' || to_char(rw_totger_rdc.vlrdcpos, 'FM999G999G999G990D90MI') || '</vlrdcpos>
                    </totalGeralRDC>');
                           
      END LOOP;
      
      FOR rw_total_rac IN cr_total_rac LOOP
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<totalGeralRAC>
                      <faixa>'   || rw_total_rac.faixa                                       ||'</faixa>
                      <qtaplica>'|| to_char(rw_total_rac.qtaplica, 'FM999G999G999G990MI')    ||'</qtaplica>
                      <vlsldtot>'|| to_char(rw_total_rac.vlsldtot, 'FM999G999G999G990D90MI') ||'</vlsldtot>
                    </totalGeralRAC>');  
      END LOOP; 
      
      
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</base>',true);

                                      
        -- Gerar XML sobre o relatório por agência
        -- Efetuar chamada de geração do PDF do relatório
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_des_xml
                                   ,pr_dsxmlnode => '/base'
                                   ,pr_dsjasper  => 'crrl294_total.jasper'
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarqimp || '.lst'
                                   ,pr_flg_gerar => 'N'
                                   ,pr_qtcoluna  => 80
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

        -- Verifica se o processo de criar arquivo retornou erro
        IF trim(vr_dscritic) IS NOT NULL THEN
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;
          
        -- Liberar dados do CLOB da memória
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      
      
    END pc_gera_crrl294_total;        
    

  BEGIN
    
    -- Código do programa, padrão para agência e número de caixa
    vr_cdprogra := 'CRPS349';

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => NULL);

    --Apenas valida a cooperativa quando for o programa principal, paralelos não tem necessidade.
    IF pr_idparale = 0 THEN
      -- Verifica se a cooperativa esta cadastrada
      OPEN  cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar registros
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;

        -- Define a crítica
        pr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;
    END IF;

    --Selecionar informacoes das datas
    OPEN  btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;


    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1 -- Fixo
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Retornar log de erro
      RAISE vr_exc_saida;
    END IF;

    -- Projeto Ligeirinho - Início da alteração para executar o paralelismo  
    
    -- Projeto Ligeirinho 
    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := 0;
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper --> Código da coopertiva
                                                 ,pr_cdprogra => vr_cdprogra --> Código do programa
                                                 ); 
                                                 
    /* Paralelismo visando performance Rodar Somente no processo Noturno */
    if rw_crapdat.inproces  > 2 and
       vr_qtdjobs           > 0 and 
       pr_cdagenci          = 0 then 
    
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_id_paralelo;
      
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
         -- Levantar exceção
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
         RAISE vr_exc_saida;
      END IF;
    
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);
                      
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := 0;
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);  
                                                    
      -- Retorna todas as Agências para criação dos Jobs.
      for rw_crapage in cr_crapagepar (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_cdprogra => vr_cdprogra
                                      ,pr_qterro   => vr_qterro
                                      ) loop 
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
        vr_dsplsql := 'DECLARE' || chr(13) || --
                      '  wpr_stprogra NUMBER;' || chr(13) || --
                      '  wpr_infimsol NUMBER;' || chr(13) || --
                      '  wpr_cdcritic NUMBER;' || chr(13) || --
                      '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                      'BEGIN' || chr(13) || --         
                      '  pc_crps349( '|| pr_cdcooper             || ',' ||
                                         '0'                     || ',' ||
                                         rw_crapage.cdagenci     || ',' ||
                                         vr_idparale             || ',' ||
                                         ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' || chr(13) ||
                      'END;';
                        
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

      -- Verifica se algum job paralelo executou com erro
      vr_qterro := 0;
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);
      if vr_qterro > 0 then 
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        raise vr_exc_saida;
      end if;         
       
    else    
      
      --Classifica o tipo de execução de acordo com a informação no campo agência.    
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
                                      ,pr_dscritic    => vr_dscritic              
                                       );   
      -- Testar saida com erro
      if  vr_dscritic is not null then 
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;                                         
    
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par); 
    
                                               
      -- Consultar taxas de uso comum nas aplicações
      apli0001.pc_busca_faixa_ir_rdca(pr_cdcooper);

      -- Primeiro dia do mês informado
      vr_dtmvtini := trunc(rw_crapdat.dtmvtolt, 'mm');
      
      -- Buscar históricos dos produtos de captação
      OPEN cr_crapcpc;
      FETCH cr_crapcpc INTO rw_crapcpc;
      
      IF cr_crapcpc%FOUND THEN

        -- Concatena lista de históricos encontrados
        vr_lshisdeb := vr_lshisdeb || ',' || rw_crapcpc.cdhsvrcc;
        vr_lshiscre := vr_lshiscre || ',' || rw_crapcpc.cdhscacc;
        
      END IF;

      CLOSE cr_crapcpc;
      
      -- Atribui históricos de débito e crédito
      vr_lshistor := vr_lshisdeb || ',' || vr_lshiscre;

      -- Verificar qual cooperativa está conectada para definir número de cópias
      IF pr_cdcooper IN (6, 7, 1)  THEN
        vr_nrcopias := 1;
      ELSE
        vr_nrcopias := 3;
      END IF;

      -- Grava LOG de ocorrência inicial do cursor cr_craprpp
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Início - cursor cr_crapdtc. AGENCIA: '||pr_cdagenci,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 
                      
      -- Buscar tipo de captação oferecido aos correntistas
      FOR vr_crapdtc IN cr_crapdtc(pr_cdcooper) LOOP
        vr_regis := vr_regis + 1;

        vr_tab_crapdtc(vr_regis).tpaplica := vr_crapdtc.tpaplica;
        vr_tab_crapdtc(vr_regis).tpaplrdc := vr_crapdtc.tpaplrdc;
      END LOOP;
      
      -- Grava LOG de ocorrência inicial do cursor cr_craprpp
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - cursor cr_crapdtc. AGENCIA: '||pr_cdagenci,
                      PR_IDPRGLOG           => vr_idlog_ini_par);       

      -- Limpar a quantidade de registros processados
      vr_regis := 0;

      -- Data de fim e inicio da utilização da taxa de poupança.
      -- Utiliza-se essa data quando o rendimento da aplicação for menor que
      -- a poupança, a cooperativa opta por usar ou não.
      -- Buscar a descrição das faixas contido na craptab
      OPEN  cr_craptab(pr_cdcooper, 'CRED', 'USUARI', 11, 'MXRENDIPOS', 1);
      FETCH cr_craptab INTO rw_craptab;

      -- Se não encontrar registros
      IF cr_craptab%NOTFOUND THEN
        vr_dtinitax := to_date('01/01/9999', 'dd/mm/yyyy');
        vr_dtfimtax := to_date('01/01/9999', 'dd/mm/yyyy');
      ELSE
        vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1, rw_craptab.dstextab, ';'), 'DD/MM/YYYY');
        vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2, rw_craptab.dstextab, ';'), 'DD/MM/YYYY');
      END IF;

      -- Carrega informações da CRAPASS em PL TABLE (performance)
      FOR vr_crapass IN cr_crapass(pr_cdcooper) LOOP
        vr_tab_crapass(vr_crapass.nrdconta).cdagenci := vr_crapass.cdagenci;
      END LOOP;

      -- Inicializar vetor para totalização de valores mensais
      FOR idx IN 1..gene0002.fn_char_para_number(to_char(last_day(rw_crapdat.dtmvtolt), 'DD')) LOOP
        vr_typ_total(idx).vr_vlaplica := 0;
        vr_typ_total(idx).vr_vlresgat := 0;
        vr_typ_total(idx).vr_vltotdia := 0;
        vr_typ_total(idx).vr_qtaplica := 0;
        vr_typ_total(idx).vr_qtresgat := 0;
        vr_typ_total(idx).vr_rel_vltotfxa := 0;
        vr_typ_total(idx).vr_rel_vlfaixas := 0;
        vr_typ_total(idx).vr_rel_qtporfxa := 0;
        vr_typ_total(idx).vr_dtmvtdia := to_date(idx || to_char(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_typ_total(idx).vr_qttotfxa := 0;
        vr_typ_total(idx).vr_vltotfxa := 0;
      END LOOP;

      -- Verificar as faixas existentes para o RDCA60
      FOR vr_craptab IN btch0001.cr_craptab(pr_cdcooper, 'CRED', 'CONFIG', NULL, 'TXADIAPLIC', 3, NULL) LOOP
        -- Quebra string retornada da consulta pelo delimitador ';'
        vr_cartaxas := gene0002.fn_quebra_string(vr_craptab.dstextab, ';');

        -- Itera sobre o array para encontrar os valores e agregar para as variáveis
        -- Agrega valor do banco retornado com segmentação da string
        IF vr_cartaxas.count > 0 THEN
          FOR idx IN 1..vr_cartaxas.count LOOP
            vr_typ_total(idx).vr_rel_vlfaixas := gene0002.fn_busca_entrada(1, vr_cartaxas(idx), '#');
            vr_qtfaixas := vr_qtfaixas + 1;
          END LOOP;
        END IF;
      END LOOP;

      -- Novo método de gerar dados na PL Table
      FOR vr_craplcm IN cr_craplcm(pr_cdcooper, vr_dtmvtini, rw_crapdat.dtmvtolt, vr_lshistor) LOOP
        -- Verificar se o histórico buscado existe na base
        IF gene0002.fn_existe_valor(vr_lshisdeb, vr_craplcm.cdhistor, ',') = 'S' THEN
          vr_aux_vllanmto := 0;
          vr_aux_craplcm := vr_craplcm.vllanmto;
        ELSE
          vr_aux_vllanmto := vr_craplcm.vllanmto;
          vr_aux_craplcm := 0;
        END IF;

        -- Gravar dados na PL TABLE
        pc_cria_crawlcm (vr_tab_crapass(vr_craplcm.nrdconta).cdagenci
                        ,vr_craplcm.dtmvtolt
                        ,vr_aux_vllanmto
                        ,vr_aux_craplcm);

        -- Retornar dia da data
        vr_contadia := gene0002.fn_char_para_number(to_char(vr_craplcm.dtmvtolt, 'DD'));

        vr_typ_total(vr_contadia).vr_vlaplica := vr_typ_total(vr_contadia).vr_vlaplica + nvl(vr_aux_vllanmto, 0);
        vr_typ_total(vr_contadia).vr_vlresgat := vr_typ_total(vr_contadia).vr_vlresgat + nvl(vr_aux_craplcm, 0);

        IF vr_aux_vllanmto > 0 THEN
          vr_typ_total(vr_contadia).vr_qtaplica := vr_typ_total(vr_contadia).vr_qtaplica + 1;
        END IF;

        IF vr_aux_craplcm > 0 THEN
          vr_typ_total(vr_contadia).vr_qtresgat := vr_typ_total(vr_contadia).vr_qtresgat + 1;
        END IF;

        -- Inicializar variável caso necessário
        IF vr_inddata IS NULL THEN
          vr_inddata := vr_craplcm.dtmvtolt;
        END IF;

        -- Gravar dados de fechamento da última iteração da data
        --IF vr_craplcm.dtmvtolt = vr_inddata THEN
          vr_typ_total(vr_contadia).vr_dtmvtdia := vr_craplcm.dtmvtolt;
          vr_typ_total(vr_contadia).vr_vltotdia := vr_typ_total(vr_contadia).vr_vlaplica - vr_typ_total(vr_contadia).vr_vlresgat;
        --END IF;

        vr_inddata := vr_craplcm.dtmvtolt;
      END LOOP;

      vr_inddata := NULL;

      FOR vr_craplci IN cr_craplci(pr_cdcooper, vr_dtmvtini, rw_crapdat.dtmvtolt) LOOP
        -- Testa código de histórico para atribuir valores
        IF vr_craplci.cdhistor = 491 THEN
          vr_aux_vllanmto := vr_craplci.vllanmto;
          vr_aux_craplcm := 0;
        ELSIF vr_craplci.cdhistor = 490 THEN
          vr_aux_vllanmto := 0;
          vr_aux_craplcm := vr_craplci.vllanmto;
        END IF;

        -- Gravar dados na TEMP TABLE
        pc_cria_crawlcm (vr_tab_crapass(vr_craplci.nrdconta).cdagenci
                        ,vr_craplci.dtmvtolt
                        ,vr_aux_vllanmto
                        ,vr_aux_craplcm);

        -- Retornar dia da data
        vr_contadia := to_char(vr_craplci.dtmvtolt, 'DD');

        vr_typ_total(vr_contadia).vr_vlaplica := vr_typ_total(vr_contadia).vr_vlaplica + vr_aux_vllanmto;
        vr_typ_total(vr_contadia).vr_vlresgat := vr_typ_total(vr_contadia).vr_vlresgat + vr_aux_craplcm;

        IF vr_aux_vllanmto > 0 THEN
          vr_typ_total(vr_contadia).vr_qtaplica := vr_typ_total(vr_contadia).vr_qtaplica + 1;
        END IF;

        IF vr_aux_craplcm > 0 THEN
          vr_typ_total(vr_contadia).vr_qtresgat := vr_typ_total(vr_contadia).vr_qtresgat + 1;
        END IF;

        IF vr_inddata IS NULL THEN
          vr_inddata := vr_craplci.dtmvtolt;
        END IF;

        -- Atribui valores somente se for o último registro retornada para a data
        --IF vr_craplci.dtmvtolt = vr_inddata THEN
          vr_typ_total(vr_contadia).vr_dtmvtdia := vr_craplci.dtmvtolt;
          vr_typ_total(vr_contadia).vr_vltotdia := vr_typ_total(vr_contadia).vr_vlaplica - vr_typ_total(vr_contadia).vr_vlresgat;
        --END IF;

        vr_inddata := vr_craplci.dtmvtolt;
      END LOOP;

      -- Iterar sobre TEMP TABLE com os resultados
      -- Início do processo de criação dos arquivos XML
      IF vr_tab_crawlcm.count() > 0 THEN
        vr_idx_crap := vr_tab_crawlcm.first;

        LOOP
          -- Controle para acertar retorno NULL para diversos campos pelo próximo índice (último registro)
          BEGIN
            vr_dindex := vr_tab_crawlcm(nvl(vr_tab_crawlcm.next(vr_idx_crap), '0')).dtmvtolt;
            vr_aindex := vr_tab_crawlcm(nvl(vr_tab_crawlcm.next(vr_idx_crap), '0')).cdagenci;
          EXCEPTION
            WHEN no_data_found THEN
              vr_dindex := to_date('01/01/9999', 'DD/MM/RRRR');
              vr_aindex := 0;
          END;

          -- Controle para índice da PL Table ser nulo
          IF vr_idx_crap IS NOT NULL THEN
            vr_pacctr := vr_tab_crawlcm(nvl(vr_idx_crap, 0)).cdagenci;
          ELSE
            vr_pacctr := 0;
          END IF;

          IF nvl(vr_cdageant, 0) <> vr_pacctr AND nvl(vr_cdageant, 0) <> 0 THEN
            -- Zerar todas as posições do array dos dois campos específicados
            FOR inc IN 1..vr_typ_total.count() LOOP
              vr_typ_total(inc).vr_rel_qtporfxa := 0;
              vr_typ_total(inc).vr_rel_vltotfxa := 0;
            END LOOP;

            vr_contadia := 1;
            vr_flgfirst := FALSE;

            -- Fechar tag´s do XML para criar arquivo
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencia></agencias>',true);

            -- Gerar XML sobre o relatório por agência
            -- Efetuar chamada de geração do PDF do relatório
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                       ,pr_cdprogra  => vr_cdprogra
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                       ,pr_dsxml     => vr_des_xml
                                       ,pr_dsxmlnode => '/agencias/agencia'
                                       ,pr_dsjasper  => 'crrl294_n.jasper'
                                       ,pr_dsparams  => NULL
                                       ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarqimp || '.lst'
                                       ,pr_flg_gerar => 'N'
                                       ,pr_qtcoluna  => 80
                                       ,pr_sqcabrel  => 1
                                       ,pr_cdrelato  => NULL
                                       ,pr_flg_impri => 'N'
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
            vr_dstexto:= NULL;
            -- Verifica se o processo de criar arquivo retornou erro
            IF trim(vr_dscritic) IS NOT NULL THEN
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Controle de saída do LOOP
          EXIT WHEN vr_idx_crap IS NULL;
                  
          IF NOT vr_flgfirst THEN
            OPEN cr_crapage(pr_cdcooper, NULL, vr_pacctr);
            FETCH cr_crapage INTO rw_crapage;

            IF cr_crapage%notfound THEN
              CLOSE cr_crapage;

              -- Gerou crítica 15
              vr_cdcritic := 15;
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_crapage;

              -- Nome do arquivo XML
              vr_nmarqimp := 'crrl294_' || lpad(vr_pacctr, 3, '0');

              -- Inicializar o CLOB
              dbms_lob.createtemporary(vr_des_xml, TRUE);
              dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
              vr_dstexto:= NULL;
              
              -- Inicilizar as informações do XML
              gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><agencias>');

              -- Cria nodo do XML
              gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia><mensagem>PA: ' || lpad(vr_pacctr, 3, '0') || '   ' || rw_crapage.nmresage || '</mensagem>');

              vr_flgfirst := TRUE;
              vr_cdageant := vr_tab_crawlcm(vr_idx_crap).cdagenci;
            END IF;
          END IF;

          /* Cálculo dos valores */
          -- Valores de aplicação
          vr_rel_vlaplica := nvl(vr_rel_vlaplica, 0) + nvl(vr_tab_crawlcm(vr_idx_crap).vlaplica, 0);

          -- Quantidade de aplicação
          IF nvl(vr_tab_crawlcm(vr_idx_crap).vlaplica, 0) > 0 THEN
            vr_rel_qtdaplic := nvl(vr_rel_qtdaplic, 0) + 1;
          END IF;

          -- Valores de resgate
          vr_rel_vlresgat := nvl(vr_rel_vlresgat, 0) + nvl(vr_tab_crawlcm(vr_idx_crap).vlresgat, 0);

          -- Quantidade de regate
          IF nvl(vr_tab_crawlcm(vr_idx_crap).vlresgat, 0) > 0 THEN
            vr_rel_qtresgat := nvl(vr_rel_qtresgat, 0) + 1;
          END IF;

          -- Saldo diário
          vr_rel_vltotdia := nvl(vr_rel_vlaplica, 0) - nvl(vr_rel_vlresgat, 0);

          -- Quebra de valores por data para gerar XML de dados
          IF vr_tab_crawlcm(vr_idx_crap).dtmvtolt <> vr_dindex or 
             -- Simulando last-of da data, porém como o break contem tbm agencia, tbm deve ser verificado
             vr_tab_crawlcm(vr_idx_crap).cdagenci <> vr_aindex 
             THEN
            -- Atribuir valores e calculos
            vr_rel_vltotapl := nvl(vr_rel_vltotapl, 0) + nvl(vr_rel_vlaplica, 0);
            vr_rel_vltotres := nvl(vr_rel_vltotres, 0) + nvl(vr_rel_vlresgat, 0);
            vr_rel_vltotsld := nvl(vr_rel_vltotsld, 0) + nvl(vr_rel_vltotdia, 0);
            vr_rel_qttotapl := nvl(vr_rel_qttotapl, 0) + nvl(vr_rel_qtdaplic, 0);
            vr_rel_qttotres := nvl(vr_rel_qttotres, 0) + nvl(vr_rel_qtresgat, 0);

            -- Cria nodo filho no XML
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                        '<totalPorData>
                          <dataMvto>' || to_char(vr_tab_crawlcm(vr_idx_crap).dtmvtolt, 'DD/MM/RRRR') || '</dataMvto>
                          <vlraplica> ' || to_char(vr_rel_vlaplica, 'FM999G999G999G990D90') || '</vlraplica>
                          <vlrresgate>' || to_char(vr_rel_vlresgat, 'FM999G999G999G990D90') || '</vlrresgate>
                          <vtotaldia>' || to_char(vr_rel_vltotdia, 'FM999G999G999G990D90') || '</vtotaldia>
                          <qtaplica>' || to_char(vr_rel_qtdaplic, 'FM999G999G999G990') || '</qtaplica>
                          <qtresgate>' || to_char(vr_rel_qtresgat, 'FM999G999G999G990') || '</qtresgate>
                        </totalPorData>');

            -- Verifica se irá criar registros na PL TABLE da CRAPLCM
            IF vr_tab_crawlcm(vr_idx_crap).cdagenci <> vr_aindex AND vr_tab_crawlcm(vr_idx_crap).dtmvtolt = rw_crapdat.dtmvtolt THEN
              -- Criar o registro na pltable
              pc_cria_cratlcm(vr_tab_crawlcm(vr_idx_crap).dtmvtolt
                             ,vr_tab_crawlcm(vr_idx_crap).cdagenci
                             ,vr_rel_vlaplica
                             ,vr_rel_vlresgat
                             ,vr_rel_vltotdia
                             ,vr_rel_qtdaplic
                             ,vr_rel_qtresgat
                             ,vr_rel_vltotapl
                             ,vr_rel_vltotres
                             ,vr_rel_vltotsld
                             ,vr_rel_qttotapl
                             ,vr_rel_qttotres);
            END IF;

            -- Zerar valores de variáveis
            vr_rel_vlaplica := 0;
            vr_rel_vlresgat := 0;
            vr_rel_vltotdia := 0;
            vr_rel_qtdaplic := 0;
            vr_rel_qtresgat := 0;
          END IF;

          -- Quebra de valores por código de agência para gerar XML de dados
          IF vr_tab_crawlcm(vr_idx_crap).cdagenci <> vr_aindex THEN
            -- Cria nodo filho no XML
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                        '<totalAgencia>
                          <qtmovto>' || to_char(vr_rel_qttotapl, 'FM999G999G999G990') || '</qtmovto>
                          <vltoapli>' || to_char(vr_rel_vltotapl, 'FM999G999G999G990D90') || '</vltoapli>
                          <qttores>' || to_char(vr_rel_qttotres, 'FM999G999G999G990') || '</qttores>
                          <vltores>' || to_char(vr_rel_vltotres, 'FM999G999G999G990D90') || '</vltores>
                          <vltosld>' || to_char(vr_rel_vltotsld, 'FM999G999G999G990D90') || '</vltosld>
                        </totalAgencia>');

            -- Zerar valores de variáveis
            vr_rel_vltotapl := 0;
            vr_rel_vltotres := 0;
            vr_rel_vltotsld := 0;
            vr_rel_qttotapl := 0;
            vr_rel_qttotres := 0;
            vr_regis := 0;

            -- Executar procedure interna para cálculo do RDC PAC (gera_rdc_pac)
            -- Iterar sobre a PL TABLE para processar os resultados
            FOR vr_craprda IN cr_craprda(pr_cdcooper, vr_tab_crawlcm(vr_idx_crap).cdagenci) LOOP
              vr_regis := vr_regis + 1;

              BEGIN
                vr_sldaplic := 0;

                -- Verifica se o tipo de aplicação é 3
                IF vr_craprda.tpaplica = 3 THEN
                  apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper
                                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                       ,pr_inproces => rw_crapdat.inproces
                                                       ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                       ,pr_cdprogra => vr_cdprogra
                                                       ,pr_cdagenci => vr_craprda.cdageass
                                                       ,pr_nrdcaixa => 99 --> somente para gerar mensagem em caso de erro
                                                       ,pr_nrdconta => vr_craprda.nrdconta
                                                       ,pr_nraplica => vr_craprda.nraplica
                                                       ,pr_vlsdrdca => vr_vlsdrdca
                                                       ,pr_vlsldapl => vr_vlsldapl
                                                       ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                       ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                       ,pr_vldperda => vr_vldperda
                                                       ,pr_txaplica => vr_txaplica
                                                       ,pr_des_reto => vr_dscritic
                                                       ,pr_tab_erro => vr_tab_craterr);

                  -- Verificar se a rotina de cálculo cálculo do RDCA30 retornou erro
                  IF vr_dscritic = 'NOK' THEN
                    RAISE vr_exc_saida;
                  END IF;

                  -- Verifica se o retorno do cálculo do saldo RDCA30 é maior que zero
                  IF nvl(vr_vlsdrdca, 0) > 0 THEN
                    vr_rel_qtaplica := nvl(vr_rel_qtaplica, 0) + 1;
                    vr_rel_vlsdaplc := nvl(vr_rel_vlsdaplc, 0) + nvl(vr_vlsdrdca, 0);
                    vr_sldaplic := nvl(vr_vlsdrdca, 0);
                  END IF;
                ELSE
                  -- Verifica se o tipo de aplicação é 5
                  IF vr_craprda.tpaplica = 5 THEN
                    -- Procedure para executar cálculo de aniversário
                    apli0001.pc_calc_aniver_rdca2c(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                  ,pr_nrdconta => vr_craprda.nrdconta
                                                  ,pr_nraplica => vr_craprda.nraplica
                                                  ,pr_vlsdrdca => vr_rd2_vlsdrdca
                                                  ,pr_des_erro => vr_dscritic);

                    -- Verificar se a rotina de cálculo de aniversário retornou erro
                    IF trim(vr_dscritic) IS NOT NULL THEN
                      vr_cdcritic := 0;
                      RAISE vr_exc_saida;
                    END IF;

                    -- Se o valor do cálculo do aniversário for maior que zero atribui valores para variáveis
                    IF nvl(vr_rd2_vlsdrdca, 0) > 0 THEN
                      vr_rel_qtrdcaii := nvl(vr_rel_qtrdcaii, 0) + 1;
                      vr_rel_vlsdrdii := nvl(vr_rel_vlsdrdii, 0) + nvl(vr_rd2_vlsdrdca, 0);
                      vr_vltotass := nvl(vr_vltotass, 0) + nvl(vr_rd2_vlsdrdca, 0);
                      vr_sldaplic := nvl(vr_rd2_vlsdrdca, 0);
                    END IF;
                  ELSE
                    -- Verificar se a PL Table retornou registro e se retornou mais que um registro
                    BEGIN
                      -- Limpar variável para contagem de registros iterados
                      vr_regisdtc := 0;

                      FOR inx in 1..vr_tab_crapdtc.count() LOOP
                        IF vr_tab_crapdtc(inx).tpaplica = vr_craprda.tpaplica THEN
                          vr_regisdtc := vr_regisdtc + 1;

                          vr_tpaplrdc := vr_tab_crapdtc(inx).tpaplrdc;
                        END IF;
                      END LOOP;

                      IF vr_regisdtc > 1 THEN
                        RAISE vr_proximo;
                      END IF;
                    EXCEPTION
                      WHEN no_data_found THEN
                        RAISE vr_proximo;
                    END;

                    -- Limpar TEMP TABLE de erros
                    vr_tab_craterr.DELETE;

                    vr_vlsldrdc := 0;

                    -- Para RDCPRE
                    IF vr_tpaplrdc = 1 THEN
                      apli0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => vr_craprda.nrdconta
                                               ,pr_nraplica => vr_craprda.nraplica
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_dtiniper => NULL
                                               ,pr_dtfimper => NULL
                                               ,pr_txaplica => 0
                                               ,pr_flggrvir => FALSE
                                               ,pr_tab_crapdat => rw_crapdat
                                               ,pr_vlsdrdca => vr_vlsldrdc
                                               ,pr_vlrdirrf => vr_vlrdirrf
                                               ,pr_perirrgt => vr_perirrgt
                                               ,pr_des_reto => vr_dscritic
                                               ,pr_tab_erro => vr_tab_craterr);

                      -- Verificar se o cálculo retornou erro, se positivo vai para a próxima iteração
                      IF vr_dscritic = 'NOK' THEN
                        vr_cdcritic := 0;
                        RAISE vr_proximo;
                      END IF;

                      -- Verificar se o retorno do cáculo retornou maior que zero
                      IF nvl(vr_vlsldrdc, 0) > 0 THEN
                        vr_rel_qtrdcpre := vr_rel_qtrdcpre + 1;
                        vr_rel_vlrdcpre := vr_rel_vlrdcpre + nvl(vr_vlsldrdc, 0);
                        vr_sldaplic := nvl(vr_vlsldrdc, 0);
                      END IF;
                    ELSE
                      -- Para RDCPOS
                      IF vr_tpaplrdc = 2 THEN
                        apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                 ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                 ,pr_nrdconta => vr_craprda.nrdconta
                                                 ,pr_nraplica => vr_craprda.nraplica
                                                 ,pr_dtmvtpap => rw_crapdat.dtmvtolt
                                                 ,pr_dtcalsld => rw_crapdat.dtmvtolt
                                                 ,pr_flantven => FALSE
                                                 ,pr_flggrvir => FALSE
                                                 ,pr_dtinitax => vr_dtinitax
                                                 ,pr_dtfimtax => vr_dtfimtax
                                                 ,pr_vlsdrdca => vr_vlsldrdc
                                                 ,pr_vlrentot => vr_vlrentot
                                                 ,pr_vlrdirrf => vr_vlrdirrf
                                                 ,pr_perirrgt => vr_perirrgt
                                                 ,pr_des_reto => vr_dscritic
                                                 ,pr_tab_erro => vr_tab_craterr);

                        -- Verificar se o cálculo retornou erro, se positivo vai para a próxima iteração
                        IF vr_dscritic = 'NOK' THEN
                          RAISE vr_proximo;
                        END IF;

                        -- Se valor de retorno do cálculo for maior que zero atribui valores
                        IF nvl(vr_vlsldrdc, 0) > 0 THEN
                          vr_rel_qtrdcpos := nvl(vr_rel_qtrdcpos, 0) + 1;
                          vr_rel_vlrdcpos := nvl(vr_rel_vlrdcpos, 0) + nvl(vr_vlsldrdc, 0);
                          vr_sldaplic := nvl(vr_vlsldrdc, 0);
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;

                -- Se valor total for maior que zero executa regra com base na CRAPRDA
                IF nvl(vr_vltotass, 0) > 0 THEN
                  IF vr_craprda.nrdconta <> vr_nrindex AND vr_craprda.tpaplica = 5 THEN
                    -- Itera sobre a quantidade de faixas
                    FOR ind IN 1..vr_qtfaixas LOOP
                      IF ((vr_vltotass >= vr_typ_total(ind).vr_rel_vlfaixas) AND (vr_vltotass < vr_typ_total(ind).vr_rel_vlfaixas))
                          OR ((vr_vltotass >=  vr_typ_total(ind).vr_rel_vlfaixas) AND (ind = vr_qtfaixas)) THEN
                        vr_typ_total(ind).vr_rel_qtporfxa := nvl(vr_typ_total(ind).vr_rel_qtporfxa, 0) + 1;
                        vr_typ_total(ind).vr_rel_vltotfxa := nvl(vr_typ_total(ind).vr_rel_vltotfxa, 0) + nvl(vr_vltotass, 0);
                      END IF;
                    END LOOP;

                    -- Zera valor total
                    vr_vltotass := 0;
                  ELSE
                    -- Itera sobre a quantidade de faixas
                    FOR ind IN 1..vr_qtfaixas LOOP
                      IF ((vr_vltotass >= vr_typ_total(ind).vr_rel_vlfaixas) AND (vr_vltotass < vr_typ_total(ind + 1).vr_rel_vlfaixas))
                          OR ((vr_vltotass >= vr_typ_total(ind).vr_rel_vlfaixas) AND (ind = vr_qtfaixas)) THEN
                        vr_typ_total(ind).vr_rel_qtporfxa := nvl(vr_typ_total(ind).vr_rel_qtporfxa, 0) + 1;
                        vr_typ_total(ind).vr_rel_vltotfxa := nvl(vr_typ_total(ind).vr_rel_vltotfxa, 0) + nvl(vr_vltotass, 0);
                      END IF;
                    END LOOP;

                    -- Zera valor total
                    vr_vltotass := 0;
                  END IF;
                END IF;

                -- Se saldo de aplicação for maior que verifica PL TABLE de aplicações
                IF nvl(vr_sldaplic, 0) > 0 THEN
                  IF vr_tab_waplica.count() = 0 THEN
                    pc_cria_wapli(pr_cdcooper
                                 ,vr_craprda.cdageass
                                 ,vr_craprda.nrdconta
                                 ,vr_craprda.nraplica
                                 ,(to_char(vr_craprda.tpaplica) || '0')
                                 ,vr_sldaplic);
                  ELSE
                    IF NOT vr_tab_waplica.exists(lpad(vr_craprda.cdageass, 8, '0') || lpad(vr_craprda.nrdconta, 12, '0') || lpad(vr_craprda.nraplica, 10, '0')) THEN
                      pc_cria_wapli(pr_cdcooper
                                   ,vr_craprda.cdageass
                                   ,vr_craprda.nrdconta
                                   ,vr_craprda.nraplica
                                   ,(to_char(vr_craprda.tpaplica) || '0')
                                   ,vr_sldaplic);
                    END IF;
                  END IF;
                END IF;
              EXCEPTION
                WHEN vr_proximo THEN
                  -- Somente leva para a próxima iteração do laço
                  NULL;
              END;
            END LOOP;

            -- Para cada aplicação de captação
            FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper, 
                                         pr_cdagenci => vr_tab_crawlcm(vr_idx_crap).cdagenci) LOOP
              
              vr_vlbascal := 0;
              vr_indice_craprac := to_char(rw_craprac.idtippro) || to_char(rw_craprac.cdprodut, 'fm00000');
            
              IF rw_craprac.idtippro = 1 THEN -- Pré-fixada
                apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper,           -- Codigo da Cooperativa
                                                        pr_nrdconta => rw_craprac.nrdconta,   -- Nr. da conta
                                                        pr_nraplica => rw_craprac.nraplica,   -- Nr. da aplicação
                                                        pr_dtiniapl => rw_craprac.dtmvtolt,   -- Data de movimento
                                                        pr_txaplica => rw_craprac.txaplica,   -- Taxa da aplicação
                                                        pr_idtxfixa => rw_craprac.idtxfixa,   -- Taxa fixa (0-Nao / 1-Sim)
                                                        pr_cddindex => rw_craprac.cddindex,   -- Cód. do indexador
                                                        pr_qtdiacar => rw_craprac.qtdiacar,   -- Qtd. de dias de carência
                                                        pr_idgravir => 0,                     -- Imunidade tributária
                                                        pr_dtinical => rw_craprac.dtmvtolt,   -- Data Inicial Cálculo
                                                        pr_dtfimcal => rw_crapdat.dtmvtolt,   -- Data Final Cálculo
                                                        pr_idtipbas => 2,                     -- Tipo Base Cálculo – 1-Parcial/2-Total)
                                                        pr_vlbascal => vr_vlbascal,           -- Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                        pr_vlsldtot => vr_vlsldtot,           -- Saldo Total da Aplicação
                                                        pr_vlsldrgt => vr_vlsldrgt,           -- Saldo Total para Resgate
                                                        pr_vlultren => vr_vlultren,           -- Valor Último Rendimento
                                                        pr_vlrentot => vr_vlrentot,           -- Valor Rendimento Total
                                                        pr_vlrevers => vr_vlrevers,           -- Valor de Reversão
                                                        pr_vlrdirrf => vr_vlrdirrf,           -- Valor do IRRF
                                                        pr_percirrf => vr_percirrf,           -- Percentual do IRRF
                                                        pr_cdcritic => vr_cdcritic,           -- Código da crítica
                                                        pr_dscritic => vr_dscritic);          -- Descrição da crítica
                                              
                -- Se o saldo total da aplicação for maior que 0          
                IF nvl(vr_vlsldtot,0) > 0 THEN
                  
                  IF vr_tab_craprac.EXISTS(vr_indice_craprac) THEN
                    -- Incrementa registro de aplicação de captação na PLTable
                    vr_tab_craprac(vr_indice_craprac).vlsldtot := nvl(vr_tab_craprac(vr_indice_craprac).vlsldtot,0) + vr_vlsldtot;
                    vr_tab_craprac(vr_indice_craprac).qtaplica := nvl(vr_tab_craprac(vr_indice_craprac).qtaplica,0) + 1;
                    vr_tab_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                
                  ELSE
                    -- Cria registro de aplicações de captação na PLTable 
                    vr_tab_craprac(vr_indice_craprac).vlsldtot := vr_vlsldtot;
                    vr_tab_craprac(vr_indice_craprac).qtaplica := 1;
                    vr_tab_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                                
                  END IF;
                  
                  IF vr_tot_craprac.EXISTS(vr_indice_craprac) THEN
                    -- Incrementa registro de aplicação de captação total na PLTable
                    vr_tot_craprac(vr_indice_craprac).vlsldtot := nvl(vr_tot_craprac(vr_indice_craprac).vlsldtot,0) + vr_vlsldtot;
                    vr_tot_craprac(vr_indice_craprac).qtaplica := nvl(vr_tot_craprac(vr_indice_craprac).qtaplica,0) + 1;
                    vr_tot_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                
                  ELSE
                    -- Cria registro de aplicações de captação total na PLTable                   
                    vr_tot_craprac(vr_indice_craprac).vlsldtot := vr_vlsldtot;
                    vr_tot_craprac(vr_indice_craprac).qtaplica := 1;
                    vr_tot_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                
                  END IF;
                  
                  vr_sldaplic := nvl(vr_vlsldtot, 0);
                END IF;
              ELSIF rw_craprac.idtippro = 2 THEN -- Pós-fixada
    
                -- Consulta saldo de aplicacao pos
                apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper         -- Codigo da Cooperativa
                                                       ,pr_nrdconta => rw_craprac.nrdconta -- Conta do Cooperado
                                                       ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                                       ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                                       ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                                       ,pr_idtxfixa => rw_craprac.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                                       ,pr_cddindex => rw_craprac.cddindex -- Codigo de Indexador
                                                       ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                                       ,pr_idgravir => 0                   -- Imunidade Tributaria
                                                       ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                                       ,pr_dtfimcal => rw_crapdat.dtmvtolt -- Data de Fim do Calculo
                                                       ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                                       ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                                       ,pr_vlsldtot => vr_vlsldtot         -- Valor de Saldo Total
                                                       ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                                       ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                                       ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                                       ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                                       ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                                       ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                                       ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                                       ,pr_dscritic => vr_dscritic);       -- Descricao de Critica
                                                       
                IF nvl(vr_vlsldtot,0) > 0 THEN

                  IF vr_tab_craprac.EXISTS(vr_indice_craprac) THEN
                    -- Incrementa registro de aplicação de captação na PLTable
                    vr_tab_craprac(vr_indice_craprac).vlsldtot := nvl(vr_tab_craprac(vr_indice_craprac).vlsldtot,0) + vr_vlsldtot;
                    vr_tab_craprac(vr_indice_craprac).qtaplica := nvl(vr_tab_craprac(vr_indice_craprac).qtaplica,0) + 1;
                    vr_tab_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                
                  ELSE
                    -- Cria registro de aplicações de captação na PLTable                 
                    vr_tab_craprac(vr_indice_craprac).vlsldtot := vr_vlsldtot;
                    vr_tab_craprac(vr_indice_craprac).qtaplica := 1;
                    vr_tab_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                                
                  END IF;                
                  
                  IF vr_tot_craprac.EXISTS(vr_indice_craprac) THEN
                    -- Incrementa registro de aplicação de captação total na PLTable
                    vr_tot_craprac(vr_indice_craprac).vlsldtot := nvl(vr_tot_craprac(vr_indice_craprac).vlsldtot,0) + vr_vlsldtot;
                    vr_tot_craprac(vr_indice_craprac).qtaplica := nvl(vr_tot_craprac(vr_indice_craprac).qtaplica,0) + 1;
                    vr_tot_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                
                  ELSE
                    -- Cria registro de aplicações de captação total na PLTable                   
                    vr_tot_craprac(vr_indice_craprac).vlsldtot := vr_vlsldtot;
                    vr_tot_craprac(vr_indice_craprac).qtaplica := 1;
                    vr_tot_craprac(vr_indice_craprac).nmprodut := rw_craprac.nmprodut;                
                  END IF;

                  vr_sldaplic := nvl(vr_vlsldtot, 0);
                END IF;

              END IF;
              
              -- Se saldo de aplicação for maior que verifica PL TABLE de aplicações
              IF nvl(vr_sldaplic, 0) > 0 THEN
                IF vr_tab_waplica.count() = 0 THEN
                  pc_cria_wapli(pr_cdcooper
                               ,rw_craprac.cdagenci
                               ,rw_craprac.nrdconta
                               ,rw_craprac.nraplica
                               ,(to_char(rw_craprac.cdprodut) || '1')
                               ,vr_sldaplic);
                ELSE
                  IF NOT vr_tab_waplica.exists(lpad(rw_craprac.cdagenci, 8, '0') || lpad(rw_craprac.nrdconta, 12, '0') || lpad(rw_craprac.nraplica, 10, '0')) THEN
                    pc_cria_wapli(pr_cdcooper
                                 ,rw_craprac.cdagenci
                                 ,rw_craprac.nrdconta
                                 ,rw_craprac.nraplica
                                 ,(to_char(rw_craprac.cdprodut) || '1')
                                 ,vr_sldaplic);
                  END IF;
                END IF;
              END IF;

            END LOOP;
            
            -- Gravar valor total do RDCA60 para efetuar cálculo no final
            vr_qtdto60 := vr_rel_qtrdcaii;
            vr_vlrto60 := vr_rel_vlsdrdii;

            IF (vr_rel_qtaplica + vr_rel_qtrdcaii) <> 0 THEN
              -- Se o valor atual da iteração for diferente do último valor cria nodo no XML
              -- Exibe valores do RDCA e RDCA60
              gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                         '<totalGeral>
                            <faixa>RDCA</faixa>
                            <faixa1>RDCA60</faixa1>
                            <qtapli>' || to_char(nvl(vr_rel_qtaplica, '0'), 'FM999G999G999G990') || '</qtapli>
                            <qtdrca>' || to_char(nvl(vr_rel_qtrdcaii, '0'), 'FM999G999G999G990') || '</qtdrca>
                            <vlapli>' || to_char(nvl(vr_rel_vlsdaplc, '0'), 'FM999G999G999G990D90') || '</vlapli>
                            <vlalii>' || to_char(nvl(vr_rel_vlsdrdii, '0'), 'FM999G999G999G990D90') || '</vlalii>
                          </totalGeral>');
            END IF;
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<totais>');

            -- Zerar variáveis de totalização
            vr_rel_qtaplica := 0;
            vr_rel_qtrdcaii := 0;
            vr_rel_vlsdaplc := 0;
            vr_rel_vlsdrdii := 0;

            -- Itera de forma reversa para atribuir valores
            FOR cont IN 1..(vr_qtfaixas - 1) LOOP
              -- Verifica o valor das faixas e caso atenda a condição gera nodo no XML
              IF nvl(vr_typ_total(1).vr_rel_vlfaixas, 0) = 0 THEN
                -- Subtrai do total do RDCA60 para exibir total no final
                vr_qtdto60 := vr_qtdto60 - vr_typ_total(cont).vr_rel_qtporfxa;
                vr_vlrto60 := vr_vlrto60 - vr_typ_total(cont).vr_rel_vltotfxa;

                IF (vr_typ_total(cont).vr_rel_qtporfxa) <> 0 THEN
                  gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                             '<totalAte>
                                <faixa>ATE:</faixa>
                                <vlfaixa>' || to_char(nvl(vr_typ_total(cont + 1).vr_rel_vlfaixas, '0'), 'FM999G999G999G990D90') || '</vlfaixa>
                                <qtfaixa>' || to_char(nvl(vr_typ_total(cont).vr_rel_qtporfxa, '0'), 'FM999G999G999G990') || '</qtfaixa>
                                <vltofai>' || to_char(nvl(vr_typ_total(cont).vr_rel_vltotfxa, '0'), 'FM999G999G999G990D90') || '</vltofai>
                              </totalAte>');
                END IF;
              ELSE
                -- Subtrai do total do RDCA60 para exibir total no final
                vr_qtdto60 := vr_qtdto60 - vr_typ_total(cont).vr_rel_qtporfxa;
                vr_vlrto60 := vr_vlrto60 - vr_typ_total(cont).vr_rel_vltotfxa;

                IF (vr_typ_total(cont).vr_rel_qtporfxa) <> 0 THEN
                  gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                             '<totalAte>
                                <faixa>ATE:</faixa>
                                <vlfaixa>' || to_char(nvl(vr_typ_total(cont).vr_rel_vlfaixas, '0'), 'FM999G999G999G990D90') || '</vlfaixa>
                                <qtfaixa>' || to_char(nvl(vr_typ_total(cont).vr_rel_qtporfxa, '0'), 'FM999G999G999G990') || '</qtfaixa>
                                <vltofai>' || to_char(nvl(vr_typ_total(cont).vr_rel_vltotfxa, '0'), 'FM999G999G999G990D90') || '</vltofai>
                              </totalAte>');
                END IF;
              END IF;

              vr_contador := cont;
            END LOOP;

            IF vr_qtdto60 <> 0 THEN
              -- Gera nodo de totalização do XML
              gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                          '<dadosTotalAcima>
                            <faixa>ACIMA DE:</faixa>
                            <qtpofai>' || to_char(nvl(vr_qtdto60, '0'), 'FM999G999G999G990') || '</qtpofai>
                            <vltofax>' || to_char(nvl(vr_vlrto60, '0'), 'FM999G999G999G990D90') || '</vltofax>
                          </dadosTotalAcima>');
            END IF;
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</totais>');

            IF (vr_rel_qtrdcpre + vr_rel_qtrdcpos) <> 0 THEN
              -- Gera nodo de totalização gerao do XML
              gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                          '<totalGeralRDC>
                            <faixa>RDCPRE</faixa>
                            <faixa1>RDCPOS</faixa1>
                            <qtrdcpre>' || to_char(nvl(vr_rel_qtrdcpre, '0'), 'FM999G999G999G990') || '</qtrdcpre>
                            <vlrdcpre>' || to_char(nvl(vr_rel_vlrdcpre, '0'), 'FM999G999G999G990D90') || '</vlrdcpre>
                            <qtrdcpos>' || to_char(nvl(vr_rel_qtrdcpos, '0'), 'FM999G999G999G990') || '</qtrdcpos>
                            <vlrdcpos>' || to_char(nvl(vr_rel_vlrdcpos, '0'), 'FM999G999G999G990D90') || '</vlrdcpos>
                          </totalGeralRDC>');
            END IF;
          END IF;
        
          -- Atribui à chave o primeiro registro da vr_tab_craprac
          vr_indice_craprac := vr_tab_craprac.first;
          
          LOOP
            -- Sai do loop quando não houver mais registros a serem percorridos na vr_tab_craprac
            EXIT WHEN vr_indice_craprac IS NULL;
          
            IF vr_tab_craprac(vr_indice_craprac).vlsldtot <= 0 THEN
              vr_indice_craprac := vr_tab_craprac.next(vr_indice_craprac);
              CONTINUE;
            END IF;
            -- Escreve informações do produto no xml
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<totalGeralRAC>
                          <faixa>'   || vr_tab_craprac(vr_indice_craprac).nmprodut ||'</faixa>
                          <qtaplica>'|| to_char(vr_tab_craprac(vr_indice_craprac).qtaplica, 'FM999G999G999G990MI') ||'</qtaplica>
                          <vlsldtot>'|| to_char(vr_tab_craprac(vr_indice_craprac).vlsldtot, 'FM999G999G999G990D90MI') ||'</vlsldtot>
                        </totalGeralRAC>');
                          
            vr_indice_craprac := vr_tab_craprac.next(vr_indice_craprac);
            
          END LOOP;

          -- Limpa tabelas temporárias
          vr_tab_craprac.delete;
          
          -- Zerar variáveis de totalização
          vr_rel_qtrdcpre := 0;
          vr_rel_vlrdcpre := 0;
          vr_rel_qtrdcpos := 0;
          vr_rel_vlrdcpos := 0;

          -- Armazena código de agência anterior
          vr_cdageant := vr_tab_crawlcm(vr_idx_crap).cdagenci;

          -- Busca valor do próximo índice para controle
          vr_idx_crap := vr_tab_crawlcm.next(vr_idx_crap);
        END LOOP;
      END IF;

      -- Itera sobre o cursor CR_CRAPAGE para executar cálculo de RDC Total
      vr_idxwapli := vr_tab_waplica.first;

      -- Iterar sobre a PL TABLE com os resultados das aplicações
      LOOP
        EXIT WHEN vr_idxwapli IS NULL;

        -- Calcular o saldo da aplicação até a data do movimento
        IF vr_tab_waplica(vr_idxwapli).tpaplica = '30' THEN
          vr_qttotrdc := vr_qttotrdc + 1;
          vr_vltotrdc := vr_vltotrdc + vr_tab_waplica(vr_idxwapli).vlsdrdca;
        ELSIF vr_tab_waplica(vr_idxwapli).tpaplica = '50' THEN
          vr_vltotass := vr_vltotass + vr_tab_waplica(vr_idxwapli).vlsdrdca;
          vr_qttotrii := vr_qttotrii + 1;
          vr_vltotrii := vr_vltotrii + vr_tab_waplica(vr_idxwapli).vlsdrdca;
        ELSIF vr_tab_waplica(vr_idxwapli).tpaplica = '70' THEN /* Para RDCPRE */
          vr_tot_qtrdcpre := vr_tot_qtrdcpre + 1;
          vr_tot_vlrdcpre := vr_tot_vlrdcpre + vr_tab_waplica(vr_idxwapli).vlsdrdca;
        ELSIF vr_tab_waplica(vr_idxwapli).tpaplica = '80' THEN /* Para RDCPOS */
          vr_tot_qtrdcpos := vr_tot_qtrdcpos + 1;
          vr_tot_vlrdcpos := vr_tot_vlrdcpos + vr_tab_waplica(vr_idxwapli).vlsdrdca;  
        END IF;            

        -- Se a totalização for maior que zero executa regra para determinar nova conta na iteração
        IF vr_vltotass > 0 THEN
          FOR cont IN 1..vr_qtfaixas LOOP
            IF ((vr_vltotass >= vr_typ_total(cont).vr_rel_vlfaixas) AND (vr_vltotass < vr_typ_total(cont + 1).vr_rel_vlfaixas))
                OR ((vr_vltotass >= vr_typ_total(cont).vr_rel_vlfaixas) AND (cont = vr_qtfaixas))  THEN
              vr_typ_total(cont).vr_qttotfxa := vr_typ_total(cont).vr_qttotfxa + 1;
              vr_typ_total(cont).vr_vltotfxa := vr_typ_total(cont).vr_vltotfxa + vr_vltotass;
            END IF;
          END LOOP;

          vr_vltotass := 0;
        END IF;

        vr_idxwapli := vr_tab_waplica.next(vr_idxwapli);
      END LOOP;

      -- Zerar variáveis de sumarização
      vr_rel_vltotapl := 0;
      vr_rel_vltotres := 0;
      vr_rel_vltotsld := 0;
      vr_rel_qttotapl := 0;
      vr_rel_qttotres := 0;

      -- Verificar registros na PL TABLE CRATLCM para criar XML
      FOR idx IN 1..vr_tab_cratlcm.count() LOOP
        FOR vr_crapage IN cr_crapage(pr_cdcooper, NULL, vr_tab_cratlcm(idx).cdagenci) LOOP
          
          vr_dsinformacao := '<movtoDia>
                              <cdagencia>' || to_char(vr_tab_cratlcm(idx).cdagenci, 'FM999G999G999G990') || '</cdagencia>
                              <nmeres>' || vr_crapage.nmresage || '</nmeres>
                              <vlaplica>' || to_char(vr_tab_cratlcm(idx).vlaplica, 'FM999G999G999G990D90') || '</vlaplica>
                              <vlresgat>' || to_char(vr_tab_cratlcm(idx).vlresgat, 'FM999G999G999G990D90') || '</vlresgat>
                              <vltotdia>' || to_char(vr_tab_cratlcm(idx).vltotdia, 'FM999G999G999G990D90') || ' </vltotdia>
                              <qtdaplic>' || to_char(vr_tab_cratlcm(idx).qtdaplic, 'FM999G999G999G990') || '</qtdaplic>
                              <qtresgat>' || to_char(vr_tab_cratlcm(idx).qtresgat, 'FM999G999G999G990') || '</qtresgat>
                            </movtoDia>';
        
          -- Cria nodo filho no XML para Movto Dia
          pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                           ,pr_cdprogra     => vr_cdprogra
                           ,pr_dsrelatorio  => 'MOVIMENTOS_DIA'
                           ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                           ,pr_dschave      => null
                           ,pr_dsinformacao => vr_dsinformacao
                           ,pr_cdagenci     => vr_tab_cratlcm(idx).cdagenci
                           ,pr_dscritic     => vr_dscritic); 
                           
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;  
          END IF;         
          
          -- Cria nodo filho no XML para Movto Mês
          vr_dsinformacao := '<movtoMes>
                              <cdagencia>' || to_char(vr_tab_cratlcm(idx).cdagenci, 'FM999G999G999G990') || '</cdagencia>
                              <nmeres>' || vr_crapage.nmresage || '</nmeres>
                              <vlaplica>' || to_char(vr_tab_cratlcm(idx).vltotapl, 'FM999G999G999G990D90') || '</vlaplica>
                              <vlresgat>' || to_char(vr_tab_cratlcm(idx).vltotres, 'FM999G999G999G990D90') || '</vlresgat>
                              <vltotdia>' || to_char(vr_tab_cratlcm(idx).vltotsld, 'FM999G999G999G990D90') || ' </vltotdia>
                              <qtdaplic>' || to_char(vr_tab_cratlcm(idx).qttotapl, 'FM999G999G999G990') || '</qtdaplic>
                              <qtresgat>' || to_char(vr_tab_cratlcm(idx).qttotres, 'FM999G999G999G990') || '</qtresgat>
                            </movtoMes>';
                      
          -- Cria nodo filho no XML para Movto Dia
          pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                           ,pr_cdprogra     => vr_cdprogra
                           ,pr_dsrelatorio  => 'MOVIMENTOS_MES'
                           ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                           ,pr_dschave      => null
                           ,pr_dsinformacao => vr_dsinformacao
                           ,pr_cdagenci     => vr_tab_cratlcm(idx).cdagenci
                           ,pr_dscritic     => vr_dscritic); 
                           
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;  
          END IF;                        
                      
        END LOOP;
      END LOOP;

      -- Laço para iteração de dias do mês
      FOR cont IN 1..gene0002.fn_char_para_number(to_char(last_day(rw_crapdat.dtmvtolt), 'DD')) LOOP
        -- Verificar valores específicos para cada dia do mês
        IF vr_typ_total(cont).vr_vlaplica <> 0 OR vr_typ_total(cont).vr_vlresgat <> 0 OR vr_typ_total(cont).vr_vltotdia <> 0 THEN
                    
          pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                           ,pr_cdprogra     => vr_cdprogra
                           ,pr_dsrelatorio  => 'RESUMO_MES' 
                           ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                           ,pr_dschave      => cont                                  
                           ,pr_dsinformacao => ';'||vr_typ_total(cont).vr_dtmvtdia||';'||     
                                                    vr_typ_total(cont).vr_vlaplica||';'||
                                                    vr_typ_total(cont).vr_vlresgat||';'||
                                                    vr_typ_total(cont).vr_vltotdia||';'||
                                                    vr_typ_total(cont).vr_qtaplica||';'||
                                                    vr_typ_total(cont).vr_qtresgat||';'
                           ,pr_cdagenci     => pr_cdagenci
                           ,pr_dscritic     => vr_dscritic); 
                           
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;  
          END IF;                                     
          
          vr_rel_vltotapl := vr_rel_vltotapl + vr_typ_total(cont).vr_vlaplica;
          vr_rel_vltotres := vr_rel_vltotres + vr_typ_total(cont).vr_vlresgat;
          vr_rel_vltotsld := vr_rel_vltotsld + vr_typ_total(cont).vr_vltotdia;
          vr_rel_qttotapl := vr_rel_qttotapl + vr_typ_total(cont).vr_qtaplica;
          vr_rel_qttotres := vr_rel_qttotres + vr_typ_total(cont).vr_qtresgat;

        END IF;
      END LOOP;

      -- Cria nodo filho no XML
      pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                       ,pr_cdprogra     => vr_cdprogra
                       ,pr_dsrelatorio  => 'TOTAL_MES' 
                       ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                       ,pr_dschave      => NULL                                  
                       ,pr_dsinformacao => ';'||vr_rel_qttotapl||';'||     
                                                vr_rel_vltotapl||';'||
                                                vr_rel_qttotres||';'||
                                                vr_rel_vltotres||';'||
                                                vr_rel_vltotsld||';'
                       ,pr_cdagenci     => pr_cdagenci                                                
                       ,pr_dscritic     => vr_dscritic); 
                           
      IF vr_dscritic IS NOT NULL THEN
        raise vr_exc_saida;  
      END IF;  
                
      IF (vr_qttotrdc + vr_vltotrdc + vr_qttotrii + vr_vltotrii) <> 0 THEN
        -- Cria nodo filho no XML
        pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                         ,pr_cdprogra     => vr_cdprogra
                         ,pr_dsrelatorio  => 'RDCA_RDCA60' 
                         ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                         ,pr_dschave      => NULL                                  
                         ,pr_dsinformacao => ';'||vr_qttotrdc||';'||     
                                                  vr_vltotrdc||';'||
                                                  vr_qttotrii||';'||
                                                  vr_vltotrii||';'
                         ,pr_cdagenci     => pr_cdagenci
                         ,pr_dscritic     => vr_dscritic); 
                             
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_saida;  
        END IF;         

      END IF;

      -- Gravar valor total do RDCA60 para efetuar cálculo no final
      vr_qtdto60 := vr_qttotrii;
      vr_vlrto60 := vr_vltotrii;

      -- Iterar sobre a quantidade de faixas para selecionar totalização
      FOR cont IN 1..(vr_qtfaixas - 1) LOOP
        IF vr_typ_total(1).vr_rel_vlfaixas = 0 THEN
          -- Subtrai do total do RDCA60 para exibir total no final
          vr_qtdto60 := vr_qtdto60 - vr_typ_total(cont).vr_qttotfxa;
          vr_vlrto60 := vr_vlrto60 - vr_typ_total(cont).vr_vltotfxa;

          IF vr_typ_total(cont).vr_qttotfxa <> 0 THEN
            -- Cria nodo filho no XML
            pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                             ,pr_cdprogra     => vr_cdprogra
                             ,pr_dsrelatorio  => 'FAIXAS_RDCA' 
                             ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                             ,pr_dschave      => vr_typ_total(cont + 1).vr_rel_vlfaixas                                  
                             ,pr_dsinformacao => ';'||vr_typ_total(cont).vr_qttotfxa||';'||     
                                                      vr_typ_total(cont).vr_vltotfxa||';'
                             ,pr_cdagenci     => pr_cdagenci
                             ,pr_dscritic     => vr_dscritic); 
                                 
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;  
            END IF;                

          END IF;
        ELSE
          -- Subtrai do total do RDCA60 para exibir total no final
          vr_qtdto60 := vr_qtdto60 - vr_typ_total(cont).vr_qttotfxa;
          vr_vlrto60 := vr_vlrto60 - vr_typ_total(cont).vr_vltotfxa;

          IF vr_typ_total(cont).vr_qttotfxa <> 0 THEN
            -- Cria nodo filho no XML
            pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                             ,pr_cdprogra     => vr_cdprogra
                             ,pr_dsrelatorio  => 'FAIXAS_RDCA' 
                             ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                             ,pr_dschave      => vr_typ_total(cont).vr_rel_vlfaixas                                  
                             ,pr_dsinformacao => ';'||vr_typ_total(cont).vr_qttotfxa||';'||     
                                                      vr_typ_total(cont).vr_vltotfxa||';'
                             ,pr_cdagenci     => pr_cdagenci
                             ,pr_dscritic     => vr_dscritic); 
                                 
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;  
            END IF;  

          END IF;
        END IF;

        vr_contador := cont;
      END LOOP;

      IF vr_qtdto60 <> 0 THEN
        -- Cria nodo filho no XML (totalizador)
        pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                         ,pr_cdprogra     => vr_cdprogra
                         ,pr_dsrelatorio  => 'FAIXA_ACIMA_DE' 
                         ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                         ,pr_dschave      => NULL                                  
                         ,pr_dsinformacao => ';'||vr_qtdto60||';'||     
                                                  vr_vlrto60||';'
                         ,pr_cdagenci     => pr_cdagenci
                         ,pr_dscritic     => vr_dscritic); 
                             
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_saida;  
        END IF;            

      END IF;

      IF (vr_tot_qtrdcpre + vr_tot_vlrdcpre + vr_tot_qtrdcpos + vr_tot_vlrdcpos) <> 0 THEN
        -- Cria nodo filho no XML (totalizador)
        pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                         ,pr_cdprogra     => vr_cdprogra
                         ,pr_dsrelatorio  => 'TOTAL_GERAL_RDC' 
                         ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                         ,pr_dschave      => NULL                                  
                         ,pr_dsinformacao => ';'||vr_tot_qtrdcpre||';'||     
                                                  vr_tot_vlrdcpre||';'||
                                                  vr_tot_qtrdcpos||';'||
                                                  vr_tot_vlrdcpos||';'
                         ,pr_cdagenci     => pr_cdagenci
                         ,pr_dscritic     => vr_dscritic); 
                             
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_saida;  
        END IF;         
        
      END IF;
      
      vr_indice_craprac := vr_tot_craprac.first;
      
      LOOP
        -- Sai do loop quando não houver mais registros a serem percorridos na vr_tab_craprac
        EXIT WHEN vr_indice_craprac IS NULL;
          
        IF vr_tot_craprac(vr_indice_craprac).vlsldtot <= 0 THEN
          vr_indice_craprac := vr_tot_craprac.next(vr_indice_craprac);
          CONTINUE;
        END IF;
        -- Escreve informações do produto no xml
        pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                         ,pr_cdprogra     => vr_cdprogra
                         ,pr_dsrelatorio  => 'TOTAL_GERAL_RAC' 
                         ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                         ,pr_dschave      => vr_tot_craprac(vr_indice_craprac).nmprodut                                  
                         ,pr_dsinformacao => ';'||vr_tot_craprac(vr_indice_craprac).qtaplica||';'||     
                                                  vr_tot_craprac(vr_indice_craprac).vlsldtot||';'
                         ,pr_cdagenci     => pr_cdagenci                        
                         ,pr_dscritic     => vr_dscritic); 
                                 
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_saida;  
        END IF; 
                
        vr_indice_craprac := vr_tot_craprac.next(vr_indice_craprac);
            
      END LOOP;

      --Grava data fim para o JOB na tabela de LOG 
      pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 1);      
                      
    
    end if;
    
    
    -- Projeto Ligeirinho - Fim do paralelismo
    
    --Se for o programa principal - executado no batch
    if pr_idparale = 0 then
      
      --Gera relatório crrl294_999
      pc_gera_crrl294_total;
      
      begin                        
        --Limpa os registros da tabela de trabalho 
        delete from tbgen_batch_relatorio_wrk
          where cdcooper   = pr_cdcooper
            and cdprograma = 'CRPS349'
            and dtmvtolt   = rw_crapdat.dtmvtolt;    
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
          raise vr_exc_saida;            
      end;        
    
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
      
      if vr_idcontrole <> 0 then
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);
                                           
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if; 
                                                        
      end if;    
      
      if rw_crapdat.inproces > 2 and vr_qtdjobs > 0 then 
        --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger,
                        pr_flgsucesso => 1);                 
      end if;

      -- Salvar informacoes
      COMMIT;

    --Se for job chamado pelo programa do batch     
    else
      -- Atualiza finalização do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);  
                                             
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);  
    
      -- Salvar informacoes
      COMMIT;

    end if;
    
    
    
  EXCEPTION
    WHEN vr_exc_saida THEN
       -- Se foi retornado apenas código
       IF nvl(vr_cdcritic,0) > 0 AND trim(vr_dscritic) IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       -- Devolvemos código e critica encontradas
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;
       
       
      if pr_idparale <> 0 then 
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
     WHEN OTHERS THEN
       -- Efetuar retorno do erro não tratado
       pr_cdcritic := 0;
       pr_dscritic := SQLERRM;
       
      if pr_idparale <> 0 then 
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
END PC_CRPS349;
/
