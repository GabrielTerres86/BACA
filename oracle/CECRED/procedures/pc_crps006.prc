CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS006
                                       ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> C�digo da cooperativa
                                        ,pr_nrfolhas IN NUMBER
                                        ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                        ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                        ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> C�digo da cr�tica
                                        ,pr_dscritic OUT VARCHAR2) IS           --> Descri��o da cr�tica
  BEGIN
    /* ..........................................................................

    Programa: pc_crps006  (Fontes/crps006.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Deborah/Edson
    Data    : Novembro/91.                      Ultima atualizacao: 07/06/2016

    Dados referentes ao programa:

    Frequencia: Diario (Batch).
    Objetivo  : Atende a solicitacao 005.
               Listar o resumo dos lotes digitados no dia (11) e resumo dos
               pedidos de talonarios em atraso (80).

    Alteracoes: 20/06/94 - Alterado para gerar o resumo dos pedidos de talonarios
                          em atraso (Edson).

               30/11/94 - Alterado para tratar os tipos de lote 10 e 11
                          (Deborah).

               24/01/95 - Alterado o resumo do RDCA onde o total dos valores
                          aplicados passou a ser o saldo ate o ultimo movimento
                          (Deborah).

               29/05/95 - Alterado para nao listar o resumo dos lotes da Consu-
                          mo (Deborah).

               19/06/95 - Alterado para tratar os lotes tipo 12 de debito em
                          conta (Odair).

               29/03/96 - Alterado para tratar tipo de lote 14 (Odair).

               09/04/96 - Alterado para listar a quantidade e o total das
                          aplicacoes de poupanca programada (Odair).

               19/08/96 - Alterado para listar a quantidade e o total da
                          arrecadacao da TELESC (Edson).

               25/10/96 - Alterado para diminuir tamanho do codigo .r (Odair).

               03/12/96 - Alterado para tratar RDCA2 (Odair).

               20/12/96 - Alterado para tratar SEGURO (Edson).

               03/02/97 - Pegar resumos da poupanca programada da tabela
                          despesames tpregist = 2 (Odair).

               04/02/97 - Desmembrar para crps006_1.p devido ao
                          codigo do programa exceder 63K (Odair)

               09/04/97 - Alterado para gerar o pedido do resumo em 2 vias
                          (Deborah).

               16/04/97 - Alterado para tratar lotes tipo 16 e 17 (Odair)

               26/05/98 - Tratar milenio e V8 (Odair)

               12/06/98 - Listar pedidos de talonarios com 4 dias uteis de
                          atraso (Edson).

               18/09/98 - Alteracao no layout do relatorio (resumo de
                          arrecadacao, propostas e debitos de cartao) (Deborah)

               17/02/99 - Mostrar memoria contabil (Odair)

               18/02/99 - Nao tratar os lotes tipo 89 e 90 (Edson).

               02/07/99 - Nao tratar pedidos roubados (Odair).

               04/01/2000 - Nao gerar pedidos de impressao (Deborah).

               11/02/2000 - Gerar pedidos de impressao (Deborah).

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

               10/05/2001 - Nao tratar os lotes tipo 23 (Edson).

               13/05/2002 - Aumentar a tabela de historicos para 999
                            ocorrencias (Deborah).

               13/06/2003 - Nao tratar os tipos de lote 26 e 27 (Edson).

               03/10/2003 - Eliminado resumos finais, nao roda mais
                            fontes/crps006_1.p (Deborah).

               16/02/2004 - Desprezar tipo de lote 24(DOC) e 25(TED)(Mirtes).

               04/10/2004 - Tratar Tipo de Lote 29(CI)(Mirtes)

               22/11/2004 - Tratar Tipo de Lote 28(Corresp.Bancario)(Mirtes)

               18/04/2005 - Gerar arquivos por pac (Edson).

               14/07/2005 - Tratar Tipo de Lote 30(GPS)(Mirtes)

               03/10/2005 - Alterado para imprimir apenas uma copia do
                            relatorio 11 para CredCrea (Diego).

               11/11/2005 - Tratar Historico 459(Recebto INSS) (Mirtes)

               30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               31/03/2006 - Corrigir rotina de impressao do relatorio crrl011
                            (Junior).

               08/05/2006 - Disponibilizada impressao relatorio crrl011_99.lst
                            (Diego).

               26/05/2006 - Alterado para fimprimir apenas uma copia do
                            relatorio 11 para Viacredi (Elton).

               15/08/2006 - Incluido indice para leitura da tabela craplap e
                            craplcm (Diego).

               14/12/2006 - Prever lote tipo 32 (Evandro).

               21/08/2007 - Tratar lote tipo 9 (Aplicacoes RDC) (David).

               13/11/2007 - Tratar lote tipo 33 (Evandro).

               31/03/2008 - Tratar GPS-BANCOOB (Evandro).

               20/06/2008 - Inclu�do a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               03/10/2008 - Alterado para desconsiderar lotes : borderos de
                            desconto de titulos e limite de desconto de
                            titulo (Gabriel).

               15/01/2009 - Evitar estouro de campo Credito e Debito (Gabriel).
                          - Incluir coluna Tipo no rel 080 (Gabriel).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               22/01/2010 - Alterar FORMAT do campo rel_qtdiaatr (David).

               28/02/2012 - Nao abortar programa quando critica 62 (Diego).

               03/04/2012 - Ajuste no estouro de campo no f_lotes (Ze).

               06/09/2013 - Convers�o Progress >> Oracle PLSQL (Edison-AMcom)

               09/10/2013 - Alterado o tratamento das exce��es (Edison - AMcom)

               13/11/2013 - Alterado para gerar o resumo de historico do tipo 4(Emprestimo)
                            igual ao tipo 5, ou seja n�o agrupando tudo no hist 99 (Odirlei - AMcom)

               22/11/2013 - Corre��o na chamada a vr_exc_fimprg, a mesma s� deve
                            ser acionada em caso de sa�da para continua��o da cadeia,
                            e n�o em caso de problemas na execu��o (Marcos-Supero)

               21/01/2014 - Gerar pdf do crrl011 somente de PAC existentes na crapage
                            (Gabriel)
														
							 28/08/2014 - Adicionado tratamento para os lan�amentos de aplica��es 
							              de capta��o. (Reinert)
                            
               17/09/2015 - PRJ214 - Ajustes para considerarmos os lotes com tipo 
                            17, 20 e 24 pois ao liberarmos produtos novos o relat�rio
                            passou a n�o trazer lan�amentos ligados a hist�ricos dessa
                            natureza, gerando diferen�a na Contabiliza��o (249) - (Marcos-Supero)

               24/02/2016 - Ajustes para listar lancamentos com lote = a ZERO no relatorio
                            crrl011 (Jean Michel).

               07/06/2016 - Ajuste para incluir mais dois UNION na leitura da craplot
                            para considerar os lotes 10301, 6902 
                            (Adriano - SD 428923).
                            

    ............................................................................. */
    DECLARE
      TYPE typ_reg_craphis_res IS
      RECORD ( nrchave  VARCHAR2(30) -- lpad(cdhistor,5,'0')||c_tipo
              ,cdhistor craphis.cdhistor%TYPE
              ,c_tipo   VARCHAR2(15)
              ,dstipo   VARCHAR2(30)
              ,qtlancto NUMBER
              ,vllancto NUMBER);

      -- Definicao do tipo de tabela tempor�ria de hist�ricos
      TYPE typ_tab_craphis_res IS
        TABLE OF typ_reg_craphis_res
        INDEX BY VARCHAR2(30);

      -- Tabela tempor�ria de hist�ricos
      vr_tab_craphis_res typ_tab_craphis_res;

      ----------------------------------------------
      -- Definicao do tipo de registro de hist�ricos
      ----------------------------------------------
      TYPE typ_reg_craphis IS
      RECORD ( cdhistor craphis.cdhistor%TYPE
              ,dshistor craphis.dshistor%TYPE
              ,indebcre craphis.indebcre%TYPE
              ,nrctadeb craphis.nrctadeb%TYPE
              ,nrctacrd craphis.nrctacrd%TYPE
              ,cdhstctb craphis.cdhstctb%TYPE
              );
      -- Definicao do tipo de tabela de hist�ricos
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
        INDEX BY PLS_INTEGER;
      -- Definicao do vetor de memoria
      vr_tab_craphis  typ_tab_craphis;

      -- Array para guardar o split dos dados contidos na dstexttb
      vr_vet_dados gene0002.typ_split;

      -- Seleciona informa��es dos hist�ricos
      CURSOR cr_craphis ( pr_cdcooper IN craphis.cdcooper%TYPE) IS
        SELECT craphis.cdhistor
              ,craphis.dshistor
              ,craphis.indebcre
              ,craphis.nrctadeb
              ,craphis.nrctacrd
              ,craphis.cdhstctb
        FROM   craphis
        WHERE  craphis.cdcooper = pr_cdcooper
        ORDER BY craphis.cdhistor;

      -- Seleciona os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrdocnpj
              ,cop.cdufdcop
              ,cop.nmextcop
              ,cop.nrcpftit
              ,cop.nrtelvoz
              ,cop.nrcpfctr
              ,cop.nmctrcop
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.dscomple
              ,cop.nmbairro
              ,cop.nrcepend
              ,cop.nmcidade
              ,cop.cdcrdarr
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      -- registro da coopertiva
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Seleciona dados dos lotes de movimenta��o
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.nrseqdig
              ,craplot.qtcompln
              ,craplot.qtinfoln
              ,craplot.tplotmov
              ,craplot.vlcompcr
              ,craplot.vlcompdb
              ,craplot.vlinfodb
              ,craplot.vlinfocr
              ,craplot.dtmvtopg
              ,craplot.tpdmoeda
              ,craplot.cdoperad
              ,craplot.cdhistor
              ,craplot.cdbccxpg
              ,craplot.nrdcaixa
              ,craplot.cdopecxa
              ,COUNT(1) OVER (PARTITION BY craplot.cdagenci) qtdreg
              -- Para controle do FIRST-OF
              ,Row_Number() OVER (PARTITION BY craplot.cdagenci
                                  ORDER BY craplot.cdagenci) nrseqreg
        FROM  craplot
        WHERE craplot.cdcooper = pr_cdcooper
        AND   craplot.dtmvtolt = pr_dtmvtolt
      UNION
        SELECT pr_dtmvtolt
              ,NULL
              ,100
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,TRUNC(SYSDATE)
              ,0
              ,'0'
              ,0
              ,0
              ,0
              ,'0'
              ,1
              ,1
        FROM DUAL
      UNION
        SELECT pr_dtmvtolt
              ,NULL
              ,100
              ,10301
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,TRUNC(SYSDATE)
              ,0
              ,'0'
              ,0
              ,0
              ,0
              ,'0'
              ,1
              ,1
        FROM DUAL
      UNION
        SELECT pr_dtmvtolt
              ,NULL
              ,100
              ,6902 
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,0
              ,TRUNC(SYSDATE)
              ,0
              ,'0'
              ,0
              ,0
              ,0
              ,'0'
              ,1
              ,1
        FROM DUAL
     ORDER BY 2;

      CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE
                        ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT crapage.cdcooper
              ,crapage.nmresage
        FROM   crapage
        WHERE  crapage.cdcooper = pr_cdcooper
        AND    crapage.cdagenci = pr_cdagenci;
      -- registro da agencia
      rw_crapage cr_crapage%ROWTYPE;

      -- seleciona dados dos lan�amentos de dep�sitos a vista
      CURSOR cr_craplcm ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplcm.cdhistor
              ,craplcm.vllanmto
        FROM   craplcm
        WHERE  craplcm.cdcooper = pr_cdcooper
        AND    craplcm.dtmvtolt = pr_dtmvtolt
        AND    craplcm.cdagenci = NVL(pr_cdagenci,craplcm.cdagenci)
        AND    craplcm.cdbccxlt = pr_cdbccxlt
        AND    craplcm.nrdolote = pr_nrdolote
        ORDER BY craplcm.cdcooper
                ,craplcm.dtmvtolt
                ,craplcm.cdagenci
                ,craplcm.cdbccxlt
                ,craplcm.nrdolote
                ,craplcm.nrseqdig;

      -- Seleciona os lan�amentos de Cotas/capital
      CURSOR cr_craplct ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplct.cdhistor
              ,craplct.vllanmto
        FROM   craplct
        WHERE  craplct.cdcooper = pr_cdcooper
        AND    craplct.dtmvtolt = pr_dtmvtolt
        AND    craplct.cdagenci = pr_cdagenci
        AND    craplct.cdbccxlt = pr_cdbccxlt
        AND    craplct.nrdolote = pr_nrdolote;

      -- Seleciona os lan�amentos em emprestimos
      CURSOR cr_craplem ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplem.cdhistor
              ,craplem.vllanmto
        FROM   craplem
        WHERE  craplem.cdcooper = pr_cdcooper
        AND    craplem.dtmvtolt = pr_dtmvtolt
        AND    craplem.cdagenci = pr_cdagenci
        AND    craplem.cdbccxlt = pr_cdbccxlt
        AND    craplem.nrdolote = pr_nrdolote;

      -- Seleciona os lan�amentos de aplica��es RDCA
      CURSOR cr_craplap ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplap.cdhistor
              ,craplap.vllanmto
        FROM   craplap
        WHERE  craplap.cdcooper = pr_cdcooper
        AND    craplap.dtmvtolt = pr_dtmvtolt
        AND    craplap.cdagenci = pr_cdagenci
        AND    craplap.cdbccxlt = pr_cdbccxlt
        AND    craplap.nrdolote = pr_nrdolote
        ORDER BY craplap.cdcooper
               ,craplap.dtmvtolt
               ,craplap.cdagenci
               ,craplap.cdbccxlt
               ,craplap.nrdolote
               ,craplap.nrseqdig;

      -- Seleciona os lan�amentos de aplica��es de capta��o
      CURSOR cr_craplac ( pr_cdcooper IN craplac.cdcooper%TYPE
			                   ,pr_dtmvtolt IN craplac.dtmvtolt%TYPE
												 ,pr_cdagenci IN craplac.cdagenci%TYPE
												 ,pr_cdbccxlt IN craplac.cdbccxlt%TYPE
												 ,pr_nrdolote IN craplac.nrdolote%TYPE) IS
        SELECT lac.cdhistor
				      ,lac.vllanmto
				 FROM craplac lac
				WHERE lac.cdcooper = pr_cdcooper
				  AND lac.dtmvtolt = pr_dtmvtolt
					AND lac.cdagenci = pr_cdagenci
					AND lac.cdbccxlt = pr_cdbccxlt
					AND lac.nrdolote = pr_nrdolote
			  ORDER BY lac.cdcooper
				        ,lac.dtmvtolt
								,lac.cdagenci
								,lac.cdbccxlt
								,lac.nrdolote
								,lac.nrseqdig;

      -- Seleciona os lan�amentos de aplica��es em poupan�a
      CURSOR cr_craplpp ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplpp.cdhistor
              ,craplpp.vllanmto
        FROM   craplpp
        WHERE  craplpp.cdcooper = pr_cdcooper
        AND    craplpp.dtmvtolt = pr_dtmvtolt
        AND    craplpp.cdagenci = pr_cdagenci
        AND    craplpp.cdbccxlt = pr_cdbccxlt
        AND    craplpp.nrdolote = pr_nrdolote;

      -- Seleciona os movimentos correspondente banc�rio - Banco do Brasil
      CURSOR cr_crapcbb ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT crapcbb.cdhistor
              ,crapcbb.valorpag
              ,crapcbb.flgrgatv
        FROM   crapcbb
        WHERE  crapcbb.cdcooper = pr_cdcooper
        AND    crapcbb.dtmvtolt = pr_dtmvtolt
        AND    crapcbb.cdagenci = pr_cdagenci
        AND    crapcbb.cdbccxlt = pr_cdbccxlt
        AND    crapcbb.nrdolote = pr_nrdolote;

      -- Seleciona os lan�amentos da conta investimento
      CURSOR cr_craplci ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplci.cdhistor
              ,craplci.vllanmto
        FROM   craplci
        WHERE  craplci.cdcooper = pr_cdcooper
        AND    craplci.dtmvtolt = pr_dtmvtolt
        AND    craplci.cdagenci = pr_cdagenci
        AND    craplci.cdbccxlt = pr_cdbccxlt
        AND    craplci.nrdolote = pr_nrdolote;

      -- Seleciona os lan�amentos de guias da previd�ncia social
      CURSOR cr_craplgp ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplgp.vlrtotal
        FROM   craplgp
        WHERE  craplgp.cdcooper = pr_cdcooper
        AND    craplgp.dtmvtolt = pr_dtmvtolt
        AND    craplgp.cdagenci = pr_cdagenci
        AND    craplgp.cdbccxlt = pr_cdbccxlt
        AND    craplgp.nrdolote = pr_nrdolote;

      -- Seleciona os lan�amentos de conta sal�rio
      CURSOR cr_craplcs ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplcs.cdhistor
              ,craplcs.vllanmto
        FROM   craplcs
        WHERE  craplcs.cdcooper = pr_cdcooper
        AND    craplcs.dtmvtolt = pr_dtmvtolt
        AND    craplcs.nrdolote = pr_nrdolote;

      -- Seleciona os lan�amentos da conta investimento
      CURSOR cr_craplpi ( pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplpi.cdhistor
              ,craplpi.vlliqcre
        FROM   craplpi
        WHERE  craplpi.cdcooper = pr_cdcooper
        AND    craplpi.dtmvtolt = pr_dtmvtolt
        AND    craplpi.cdagenci = pr_cdagenci
        AND    craplpi.cdbccxlt = pr_cdbccxlt
        AND    craplpi.nrdolote = pr_nrdolote;

      -- Seleciona os pedidos de talon�rios
      CURSOR cr_crapped ( pr_cdcooper crapped.cdcooper%TYPE) IS
        SELECT crapped.nrpedido
               ,crapped.dtsolped
               ,crapped.nrinichq
               ,crapped.nrfinchq
               ,crapped.nrseqped
               ,crapped.nrdctabb
        FROM   crapped
        WHERE crapped.cdcooper = pr_cdcooper
        AND   crapped.dtrecped IS NULL;
          -- seleciona as folhas de cheques emitidas para o cooperado de
      -- conforme o n�mero do pedido de talon�rio
      CURSOR cr_crapfdc( pr_cdcooper IN crapped.cdcooper%TYPE
                        ,pr_nrpedido IN crapfdc.nrpedido%TYPE) IS
        SELECT crapfdc.tpforchq
               ,decode(crapfdc.tpforchq, 'TL', 'Talonario'
                                       , 'TB', 'Folhas TB'
                                       , 'FC', 'Form.Continuo'
                                       , 'A4',  'Form.Avulso A4'
                                       ,'Outros') dsformul
        FROM   crapfdc
        WHERE  crapfdc.cdcooper = pr_cdcooper
        AND    crapfdc.nrpedido = pr_nrpedido
        ORDER BY crapfdc.cdcooper
                ,crapfdc.nrpedido;

      -- registro de folhas de cheque
      rw_crapfdc cr_crapfdc%ROWTYPE;

      -- C�digo do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS006';

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(4000);

      -- Vari�veis de trabalho
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

      -- Vari�vel de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);

      -- variaveis de controle e totalizadores
      vr_agcompcr     NUMBER;
      vr_agcompdb     NUMBER;
      vr_agqtlote     NUMBER;
      vr_agcompln     NUMBER;
      vr_dsagenci		  VARCHAR2(200);
      vr_chhistor     VARCHAR2(30);
      vr_ind					VARCHAR2(30);
      vr_ctipo        VARCHAR2(15);
      vr_cdhistor     craphis.cdhistor%TYPE;
      vr_dshistor     VARCHAR2(60);
      vr_vlcompdb     NUMBER;
      vr_vlcompcr     NUMBER;
      vr_ttcompdb     NUMBER;
      vr_tgcompdb     NUMBER;
      vr_ttcompcr     NUMBER;
      vr_tgcompcr     NUMBER;
      vr_qttphist     NUMBER;
      vr_qttpgera     NUMBER;
      vr_lspedrou     craptab.dstextab%TYPE;
      vr_dtprevis     crapped.dtsolped%TYPE;
      vr_qtdiaatr     NUMBER;
      vr_nrinital     NUMBER;
      vr_nrfintal     NUMBER;
      vr_nprocess     BOOLEAN;
      vr_nmarqctb     VARCHAR2(100);
      vr_nrcopias     NUMBER;
      vr_nrdiautl     NUMBER;
      vr_nrposchq     NUMBER;
      vr_flgimpri     VARCHAR2(10);
      vr_inddados     BOOLEAN;

	    --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

      -- Procedure para alimentar a tbela tempor�ria do resumo por tipos de movimento
      PROCEDURE pc_alimenta_vr_tab_craphis_res( pr_cdhistor IN craphis.cdhistor%TYPE
                                               ,pr_vllanmto IN craplcm.vllanmto%TYPE
                                               ,pr_c_tipo   IN VARCHAR2
                                               ,pr_dstipo   IN VARCHAR2
                                               ,pr_flgconta IN BOOLEAN DEFAULT TRUE) IS
      BEGIN
        DECLARE
          -- chave da tabela tempor�ria
          vr_chhistor VARCHAR2(30);
          -- descri��o do tipo de movimento
          vr_dstpomov VARCHAR2(15);
        BEGIN
          -- montado o campo c_tipo
          vr_dstpomov := pr_c_tipo;
          
          -- Monta a chave para pesquisa
          vr_chhistor := vr_dstpomov||lpad(pr_cdhistor,5,'0');
          
          -- Se o tipo movimento e hist�rico n�o existirem na tabela tempor�ria, alimenta
          IF NOT(vr_tab_craphis_res.EXISTS(vr_chhistor)) THEN
            -- alimenta a tabela tempor�ria
            vr_tab_craphis_res(vr_chhistor).nrchave  := vr_chhistor;
            vr_tab_craphis_res(vr_chhistor).cdhistor := pr_cdhistor;
            vr_tab_craphis_res(vr_chhistor).c_tipo   := vr_dstpomov;
            vr_tab_craphis_res(vr_chhistor).dstipo   := pr_dstipo;
                        
          END IF;
          -- acumulando os valores e quantidades para cada chave da tabela tempor�ria
          vr_tab_craphis_res(vr_chhistor).vllancto := nvl(vr_tab_craphis_res(vr_chhistor).vllancto,0) + nvl(pr_vllanmto,0);
          -- atualiza a contagem de registros somente se o valor � maior que zero, pois quando � for�ado o
          -- registro do recebimento do INSS com valor zero, a quantidade n�o deve ser alterada.
          -- Existem lan�amentos com valor zerado. Ex.: 1030 - SAQ. CARTAO
          IF (nvl(pr_vllanmto,0) > 0 OR pr_cdhistor <> 459) AND pr_flgconta THEN  -- pr_flgconta � falso quando for apenas para incluir o registro
            vr_tab_craphis_res(vr_chhistor).qtlancto := nvl(vr_tab_craphis_res(vr_chhistor).qtlancto,0) + 1;
          END IF;
        END;
      END pc_alimenta_vr_tab_craphis_res;

    -- Inicio do procedimento
    BEGIN
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS006'
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
	    -- Verifica��o do calend�rio
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;      

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_cdcritic => vr_cdcritic);

      --Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Busca do diret�rio base da cooperativa e a subpasta de relat�rios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl

      -- Limpando as tabelas tempor�rias
      vr_tab_craphis_res.delete;
      vr_tab_craphis.delete;

      -- Carregando a tabela de hist�ricos da cooperativa
      FOR rw_craphis  IN cr_craphis (pr_cdcooper => pr_cdcooper)  LOOP
        vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).dshistor := rw_craphis.dshistor;
        vr_tab_craphis(rw_craphis.cdhistor).indebcre := rw_craphis.indebcre;
        vr_tab_craphis(rw_craphis.cdhistor).nrctadeb := rw_craphis.nrctadeb;
        vr_tab_craphis(rw_craphis.cdhistor).nrctacrd := rw_craphis.nrctacrd;
        vr_tab_craphis(rw_craphis.cdhistor).cdhstctb := rw_craphis.cdhstctb;
      END LOOP;

      -- guarda o nome de arquivo que ser� exibido no final do relat�rio de resumo crrl011_99.lst
      vr_nmarqctb := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'.dat';

      -- controlando o numero de c�pias que devem ser geradas
      IF pr_cdcooper IN (1,6,7) THEN
        vr_nrcopias := 1;
      ELSE
        vr_nrcopias := 2;
      END IF;

      --------------------------------------------------------
      -- LOTES POR AGENCIA (CRRL011)
      --------------------------------------------------------
      FOR rw_craplot IN cr_craplot( pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt)
      LOOP
        IF NVL(rw_craplot.nrdolote,0) > 0 THEN
          -- se � o primeiro registro da ag�ncia (FIRST-OF)
          IF rw_craplot.nrseqreg = 1 THEN
            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            -- Busca o nome abreviado da agencia na tabela de agencias
            OPEN cr_crapage( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => rw_craplot.cdagenci);
            FETCH cr_crapage INTO rw_crapage;

            -- Se encontrar a ag�ncia, utiliza o nome abreviado
            IF cr_crapage%FOUND THEN
              vr_dsagenci := rw_craplot.cdagenci||
                             ' - '||
                             rw_crapage.nmresage;
            -- se n�o encontrar preenche com "*"
            ELSE
              vr_dsagenci := lpad(rw_craplot.cdagenci,3,'0')||
                             ' - '||
                             '***************';
            END IF;
            CLOSE cr_crapage;

            -- Inicializando os totalizadores para cada ag�ncia
            vr_agcompdb := 0;
            vr_agcompcr := 0;
            vr_agcompln := 0;
            vr_agqtlote := 0;

            -------------------------------------------
            -- Iniciando a gera��o do XML
            -------------------------------------------
            pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl011>');

            ------------------------------------------
            -- Ativos - Inicio
            ------------------------------------------
            pc_escreve_xml('<agencia cdagencia="'||vr_dsagenci||'">');

          END IF; --IF rw_craplot.nrseqreg = 1 THEN

          -- totalizando as movimenta��es da ag�ncia
          vr_agcompdb := nvl(vr_agcompdb,0) + nvl(rw_craplot.vlcompdb,0);
          vr_agcompcr := nvl(vr_agcompcr,0) + nvl(rw_craplot.vlcompcr,0);
          vr_agcompln := nvl(vr_agcompln,0) + nvl(rw_craplot.qtcompln,0);
          vr_agqtlote := nvl(vr_agqtlote,0) + 1;

          -- gerando os detalhes no xml
          pc_escreve_xml('<lote><cdbccxlt>'||rw_craplot.cdbccxlt||'</cdbccxlt>'||
                         '<nrdolote>'||to_char(rw_craplot.nrdolote,'fm99G999G990')||'</nrdolote>'||
                         '<tplotmov>'||rw_craplot.tplotmov||'</tplotmov>'||
                         '<qtcompln>'||to_char(rw_craplot.qtcompln,'fm999G999G990')||'</qtcompln>'||
                         '<vlcompdb>'||to_char(rw_craplot.vlcompdb,'fm999G999G999G990D00')||'</vlcompdb>'||
                         '<vlcompcr>'||to_char(rw_craplot.vlcompcr,'fm999G999G999G990D00')||'</vlcompcr></lote>');

          -- Se � o �ltimo registro da ag�ncia (LAST-OF)
          IF rw_craplot.nrseqreg = rw_craplot.qtdreg THEN

            -- escreve os totais e finaliza o arquivo
            pc_escreve_xml('<agqtlote>'||to_char(vr_agqtlote,'fm999G999G990')||'</agqtlote>'||
                           '<agcompln>'||to_char(vr_agcompln,'fm999G999G990')||'</agcompln>'||
                           '<agcompdb>'||to_char(vr_agcompdb,'fm999G999G999G990D00')||'</agcompdb>'||
                           '<agcompcr>'||to_char(vr_agcompcr,'fm999G999G999G990D00')||'</agcompcr>'||
                           '</agencia></crrl011>');

            -- Verificar se encontra o PAC
            OPEN cr_crapage( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => rw_craplot.cdagenci);
            FETCH cr_crapage INTO rw_crapage;
            -- Se encontrar a ag�ncia, gerar o PDF
            IF cr_crapage%FOUND THEN
              vr_flgimpri := 'S';
            ELSE
              vr_flgimpri := 'N';
            END IF;

            CLOSE cr_crapage;

            -- Gerando o relat�rio
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                       ,pr_cdprogra  => vr_cdprogra
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                       ,pr_dsxml     => vr_des_xml
                                       ,pr_dsxmlnode => '/crrl011'
                                       ,pr_dsjasper  => 'crrl011.jasper'
                                       ,pr_dsparams  => ''
                                       ,pr_dsarqsaid => vr_path_arquivo || '/crrl011_'||lpad(rw_craplot.cdagenci,3,'0')||'.lst'
                                       ,pr_flg_gerar => 'N'
                                       ,pr_qtcoluna  => 132
                                       ,pr_sqcabrel  => 1
                                       ,pr_cdrelato  => NULL
                                       ,pr_flg_impri => vr_flgimpri
                                       ,pr_nmformul  => '132col'
                                       ,pr_nrcopias  => vr_nrcopias
                                       ,pr_dspathcop => NULL
                                       ,pr_dsmailcop => NULL
                                       ,pr_dsassmail => NULL
                                       ,pr_dscormail => NULL
                                       ,pr_des_erro  => vr_dscritic);

            -- Liberando a mem�ria alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

          END IF;
        END IF;

        -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
        pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 750
                                       ,pr_vllanmto => 0
                                       ,pr_c_tipo   => 'tbtplt13' 
                                       ,pr_dstipo   => 'CORRESP. BANCARIO'
                                       ,pr_flgconta => FALSE);
        
        -- verifica o codigo de credenciamento para arrecada��es da cooperativa
        IF rw_crapcop.cdcrdarr = 0 THEN
          vr_cdhistor := 458;
        ELSE
          vr_cdhistor := 582;
        END IF;
              
        -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
        pc_alimenta_vr_tab_craphis_res( pr_cdhistor => vr_cdhistor
                                       ,pr_vllanmto => 0
                                       ,pr_c_tipo   => 'tbtplt14' 
                                       ,pr_dstipo   => 'GUIA PREV.SOCIAL'
                                       ,pr_flgconta => FALSE);
        
        -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
        pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 459
                                       ,pr_vllanmto => 0
                                       ,pr_c_tipo   => 'tbtplt10' 
                                       ,pr_dstipo   => 'RECEBIMENTO INSS'
                                       ,pr_flgconta => FALSE);
        
        -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
        pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 580
                                       ,pr_vllanmto => 0
                                       ,pr_c_tipo   => 'tbtplt12' 
                                       ,pr_dstipo   => 'RECEB. INSS BANCOOB'
                                       ,pr_flgconta => FALSE);

        -- Se o tipo do lote estiver entre os tipos abaixo, vai para o pr�ximo registro
        IF rw_craplot.tplotmov IN (6,7,8,11,12,13,15,16,18,19,21,23,25,26,27,34,35,89,90) THEN
          CONTINUE;
        ELSE
          -- Avalia os tipos de movimento para totalizar pelos tipos de movimento e hist�ricos
          CASE rw_craplot.tplotmov
            WHEN 0 THEN -- LANCAMENTOS SEM LOTE
              -- Seleciona os lan�amentos de dep�sitos a vista
              FOR rw_craplcm IN cr_craplcm( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplcm.cdhistor
                                               ,pr_vllanmto => rw_craplcm.vllanmto
                                               ,pr_c_tipo   => 'tbtplt00'
                                               ,pr_dstipo   => 'LANC. SEM LOTE');
              END LOOP;

            WHEN 1 THEN -- DEPOSITO A VISTA
              -- Seleciona os lan�amentos de dep�sitos a vista
              FOR rw_craplcm IN cr_craplcm( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplcm.cdhistor
                                               ,pr_vllanmto => rw_craplcm.vllanmto
                                               ,pr_c_tipo   => 'tbtplt01'
                                               ,pr_dstipo   => 'DEP. A VISTA');
              END LOOP;

            WHEN 2 THEN -- Capital
              -- Seleciona os lan�amentos de cotas/capital
              FOR rw_craplct IN cr_craplct( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplct.cdhistor
                                               ,pr_vllanmto => rw_craplct.vllanmto
                                               ,pr_c_tipo   => 'tbtplt02'
                                               ,pr_dstipo   => 'COTAS/CAPITAL');
              END LOOP;

            WHEN 3 THEN -- Plano de Cotas
              -- Seleciona os lan�amentos de cotas/capital
              FOR rw_craplct IN cr_craplct( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplct.cdhistor
                                               ,pr_vllanmto => rw_craplct.vllanmto
                                               ,pr_c_tipo   => 'tbtplt02'
                                               ,pr_dstipo   => 'COTAS/CAPITAL');
              END LOOP;

            WHEN 4 THEN -- Contratos de Empr�stimo
              -- Seleciona os lan�amentos em empr�stimos
              FOR rw_craplem IN cr_craplem( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                -- Alterado para gerar o resumo de historico igual ao tipo 5, ou seja n�o agrupando tudo no hist 99
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplem.cdhistor
                                               ,pr_vllanmto => rw_craplem.vllanmto
                                               ,pr_c_tipo   => 'tbtplt04'
                                               ,pr_dstipo   => 'EMPRESTIMOS');
              END LOOP;

            WHEN 5 THEN -- Lan�amentos de Empr�stimo
              -- Seleciona os lan�amentos em empr�stimos
              FOR rw_craplem IN cr_craplem( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplem.cdhistor
                                               ,pr_vllanmto => rw_craplem.vllanmto
                                               ,pr_c_tipo   => 'tbtplt04'
                                               ,pr_dstipo   => 'EMPRESTIMOS');
              END LOOP;

            WHEN 9 THEN -- Aplica��es RDC
              -- Seleciona os lan�amentos de aplica��es RDCA
              FOR rw_craplap IN cr_craplap( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplap.cdhistor
                                               ,pr_vllanmto => rw_craplap.vllanmto
                                               ,pr_c_tipo   => 'tbtplt05'
                                               ,pr_dstipo   => 'APLICACOES RDC');
              END LOOP;
							
							-- Seleciona os lan�amentos de aplica��es de capta��o
							FOR rw_craplac IN cr_craplac( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplac.cdhistor
                                               ,pr_vllanmto => rw_craplac.vllanmto
                                               ,pr_c_tipo   => 'tbtplt05'
                                               ,pr_dstipo   => 'APLICACOES RDC');
              END LOOP;

            WHEN 10 THEN -- Aplica��es RDCA 30/60
              -- Seleciona os lan�amentos de aplica��es RDCA
              FOR rw_craplap IN cr_craplap( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplap.cdhistor
                                               ,pr_vllanmto => rw_craplap.vllanmto
                                               ,pr_c_tipo   => 'tbtplt07' 
                                               ,pr_dstipo   => 'APLICACOES RDCA');
              END LOOP;

            WHEN 14 THEN -- Poupan�a Programada
              -- Seleciona os lan�amentos de aplica��es RDCA
              FOR rw_craplpp IN cr_craplpp( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplpp.cdhistor
                                               ,pr_vllanmto => rw_craplpp.vllanmto
                                               ,pr_c_tipo   => 'tbtplt08' 
                                               ,pr_dstipo   => 'POUPANCA PROGRAMADA');
              END LOOP;
              
            WHEN 17 THEN -- Debitos de Cart�o de Cr�dito
              -- Seleciona os lan�amentos de dep�sitos a vista
              FOR rw_craplcm IN cr_craplcm( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplcm.cdhistor
                                               ,pr_vllanmto => rw_craplcm.vllanmto
                                               ,pr_c_tipo   => 'tbtplt01'
                                               ,pr_dstipo   => 'DEP. A VISTA');
              END LOOP;     

            WHEN 20 THEN -- Titulos
              -- Seleciona os lan�amentos de dep�sitos a vista
              FOR rw_craplcm IN cr_craplcm( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplcm.cdhistor
                                               ,pr_vllanmto => rw_craplcm.vllanmto
                                               ,pr_c_tipo   => 'tbtplt01'
                                               ,pr_dstipo   => 'DEP. A VISTA');
              END LOOP;
              
            WHEN 24 THEN -- DOC
              -- Seleciona os lan�amentos de dep�sitos a vista
              FOR rw_craplcm IN cr_craplcm( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplcm.cdhistor
                                               ,pr_vllanmto => rw_craplcm.vllanmto
                                               ,pr_c_tipo   => 'tbtplt01'
                                               ,pr_dstipo   => 'DEP. A VISTA');
              END LOOP;                                     

            WHEN 28 THEN -- Coban

              -- Flag de controle
              vr_inddados := FALSE;

              -- Seleciona os movimentos correspondente banc�rio - Banco do Brasil
              FOR rw_crapcbb IN cr_crapcbb( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- se o registro estiver ativo
                IF rw_crapcbb.flgrgatv = 1 THEN
                  -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                  pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 750
                                                 ,pr_vllanmto => rw_crapcbb.valorpag
                                                 ,pr_c_tipo   => 'tbtplt13' 
                                                 ,pr_dstipo   => 'CORRESP. BANCARIO');

                  -- Controle
                  vr_inddados := TRUE;
                END IF;
                
              END LOOP;
              
              -- Verifica se encontrou dados
              IF vr_inddados THEN
                -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 750
                                               ,pr_vllanmto => 0
                                               ,pr_c_tipo   => 'tbtplt13' 
                                               ,pr_dstipo   => 'CORRESP. BANCARIO');
              END IF;
              
            WHEN 29 THEN -- Conta Investimento
              -- Seleciona os lan�amentos da conta investimento
              FOR rw_craplci IN cr_craplci( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplci.cdhistor
                                               ,pr_vllanmto => rw_craplci.vllanmto
                                               ,pr_c_tipo   => 'tbtplt09' 
                                               ,pr_dstipo   => 'CONTA INVESTIMENTO');
              END LOOP;

            WHEN 30 THEN -- GPS
              -- verifica o codigo de credenciamento para arrecada��es da cooperativa
              IF rw_crapcop.cdcrdarr = 0 THEN
                vr_cdhistor := 458;
              ELSE
                vr_cdhistor := 582;
              END IF;
              
              -- Flag de controle
              vr_inddados := FALSE;
              
              -- Seleciona os lan�amentos de guias da previd�ncia social
              FOR rw_craplgp IN cr_craplgp( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => vr_cdhistor
                                               ,pr_vllanmto => rw_craplgp.vlrtotal
                                               ,pr_c_tipo   => 'tbtplt14' 
                                               ,pr_dstipo   => 'GUIA PREV.SOCIAL');

                -- Controle
                vr_inddados := TRUE;
              END LOOP;

              -- Verifica se encontrou dados
              IF vr_inddados THEN
                -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => vr_cdhistor
                                               ,pr_vllanmto => 0
                                               ,pr_c_tipo   => 'tbtplt14' 
                                               ,pr_dstipo   => 'GUIA PREV.SOCIAL');
              END IF;

            WHEN 31 THEN -- Recebimento INSS via Coban
              
              -- Flag de controle
              vr_inddados := FALSE;
              
              -- Seleciona os movimentos correspondente banc�rio - Banco do Brasil
              FOR rw_crapcbb IN cr_crapcbb( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 459
                                               ,pr_vllanmto => rw_crapcbb.valorpag
                                               ,pr_c_tipo   => 'tbtplt10' 
                                               ,pr_dstipo   => 'RECEBIMENTO INSS');

                -- Controle
                vr_inddados := TRUE;
              END LOOP;
              
              -- Verifica se encontrou dados
              IF vr_inddados THEN
                -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 459
                                               ,pr_vllanmto => 0
                                               ,pr_c_tipo   => 'tbtplt10' 
                                               ,pr_dstipo   => 'RECEBIMENTO INSS');
              END IF;
              
            WHEN 32 THEN -- Lan�amentos da CTASAL
              
              -- Seleciona os lan�amentos de conta sal�rio
              FOR rw_craplcs IN cr_craplcs( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => rw_craplcs.cdhistor
                                               ,pr_vllanmto => rw_craplcs.vllanmto
                                               ,pr_c_tipo   => 'tbtplt11' 
                                               ,pr_dstipo   => 'CONTA SALARIO');
              END LOOP;

            WHEN 33 THEN -- Benef�cios INSS Bancoob
              
              -- Flag de controle
              vr_inddados := FALSE;  
            
              -- Seleciona os lan�amentos da conta investimento
              FOR rw_craplpi IN cr_craplpi( pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote)
              LOOP
                -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 580
                                               ,pr_vllanmto => rw_craplpi.vlliqcre
                                               ,pr_c_tipo   => 'tbtplt12' 
                                               ,pr_dstipo   => 'RECEB. INSS BANCOOB');
                
                -- Controle
                vr_inddados := TRUE;
              END LOOP;
              
              -- Verifica se encontrou dados
              IF vr_inddados THEN
                -- Carrega as informa��es zeradas na tabela tempor�ria para gerar o resumo
                pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 580
                                               ,pr_vllanmto => 0
                                               ,pr_c_tipo   => 'tbtplt12' 
                                               ,pr_dstipo   => 'RECEB. INSS BANCOOB');
              END IF;
              
            -- Se o tipo de movimento n�om estiver no tratamento, gera erro e aborta a execu��o
            ELSE
              -- Escreve no log mas n�o aborta o processo
              vr_cdcritic := 62;
              vr_dscritic := nvl(gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic),' ')||
                             'Tipo de Lote: '||to_char(rw_craplot.tplotmov);
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic );
              vr_cdcritic := NULL;
              vr_dscritic := NULL;

          END CASE;

        END IF;
      END LOOP; -- FOR rw_craplot IN cr_craplot

      ---------------------------------------------------------------------------------------------------------
      -- For�ando o registro "Recebimento INSS" pois no progress imprime o registro mesmo quando est� zerado
      ---------------------------------------------------------------------------------------------------------
      -- Carrega e totaliza as informa��es na tabela tempor�ria para gerar o resumo
      pc_alimenta_vr_tab_craphis_res( pr_cdhistor => 459
                                     ,pr_vllanmto => 0
                                     ,pr_c_tipo   => 'tbtplt10' 
                                     ,pr_dstipo   => 'RECEBIMENTO INSS');


      --------------------------------------------------------
      -- RESUMO POR TIPO DE OPERA��O E HISTORICOS (CRRL011_99)
      --------------------------------------------------------
      -- Se retornar regisros, gera as informa��es do resumo por tipo de aplica��o e hist�rico
      IF vr_tab_craphis_res.count > 0 THEN

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Posiciona no primeiro registro da tabela
        vr_ind   := vr_tab_craphis_res.FIRST;
        vr_ctipo := vr_tab_craphis_res(vr_ind).c_tipo;

        -- gerando o cabe�alho do xml
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl011>'||
                       '<tipo id="'||vr_tab_craphis_res(vr_ind).c_tipo||'">');

        -- Inicia a leitura da tabela de mem�ria para gerar o resumo final
        LOOP
          -- Sair quando a chave atual for null (chegou no final)
          EXIT WHEN vr_ind IS NULL;

          -- verifica se � first-of
          IF vr_ctipo <> vr_tab_craphis_res(vr_ind).c_tipo THEN
            -- zera os acumuladores para que possam acumular o novo tipo
            vr_ttcompdb := 0;
            vr_ttcompcr := 0;
            vr_qttphist := 0;

            -- gerando novo detalhe por tipo
            pc_escreve_xml('</tipo><tipo id="'||vr_tab_craphis_res(vr_ind).c_tipo||'">');
          END IF;

          -- Busca a descri��o do hist�rico
          IF vr_tab_craphis.EXISTS(vr_tab_craphis_res(vr_ind).cdhistor) THEN
            vr_dshistor := vr_tab_craphis_res(vr_ind).cdhistor||' - '||vr_tab_craphis(vr_tab_craphis_res(vr_ind).cdhistor).dshistor;
          ELSE
            -- Se o hist�rico n�o existir, gera exce��o
            vr_cdcritic := 83;
            vr_dscritic := nvl(gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic),' ')||
                           to_char(vr_tab_craphis_res(vr_ind).cdhistor);
            RAISE vr_exc_saida;
          END IF;

          -- o hist�rico 580 � D�bito, por�m est� fixo como cr�dito no programa
          IF vr_tab_craphis_res(vr_ind).cdhistor = 580 THEN
            -- Acumula os cr�ditos
            vr_ttcompcr := nvl(vr_ttcompcr,0) + nvl(vr_tab_craphis_res(vr_ind).vllancto,0);
            vr_tgcompcr := nvl(vr_tgcompcr,0) + nvl(vr_tab_craphis_res(vr_ind).vllancto,0);
            vr_vlcompdb := NULL;
            vr_vlcompcr := vr_tab_craphis_res(vr_ind).vllancto;
          ELSE
            -- verifica se o movimento foi a d�bito ou a cr�dito
            IF vr_tab_craphis(vr_tab_craphis_res(vr_ind).cdhistor).indebcre = 'D' THEN
              -- Acumula os d�bitos
              vr_ttcompdb := nvl(vr_ttcompdb,0) + nvl(vr_tab_craphis_res(vr_ind).vllancto,0);
              vr_tgcompdb := nvl(vr_tgcompdb,0) + nvl(vr_tab_craphis_res(vr_ind).vllancto,0);
              vr_vlcompdb := vr_tab_craphis_res(vr_ind).vllancto;
              vr_vlcompcr := NULL;
            ELSE
              -- Acumula os cr�ditos
              vr_ttcompcr := nvl(vr_ttcompcr,0) + nvl(vr_tab_craphis_res(vr_ind).vllancto,0);
              vr_tgcompcr := nvl(vr_tgcompcr,0) + nvl(vr_tab_craphis_res(vr_ind).vllancto,0);
              vr_vlcompdb := NULL;
              vr_vlcompcr := vr_tab_craphis_res(vr_ind).vllancto;
            END IF;
          END IF;
          -- acumulando as quantidades de lan�amentos para totalizar no final do relat�rio
          vr_qttphist := nvl(vr_qttphist,0) + nvl(vr_tab_craphis_res(vr_ind).qtlancto,0);
          vr_qttpgera := nvl(vr_qttpgera,0) + nvl(vr_tab_craphis_res(vr_ind).qtlancto,0);

          -- Gerando o registro de detalhe
          pc_escreve_xml('<historico id="'||vr_tab_craphis_res(vr_ind).nrchave||'">'||
                           '<dstipomv>'||vr_tab_craphis_res(vr_ind).dstipo||'</dstipomv>'||
                           '<dshistor>'||vr_dshistor||'</dshistor>'||
                           '<qtlancto>'||to_char(nvl(vr_tab_craphis_res(vr_ind).qtlancto,0),'fm999G999G990')||'</qtlancto>'||
                           '<vlcompdb>'||to_char(vr_vlcompdb,'fm999G999G999G990D00')||'</vlcompdb>'||
                           '<vlcompcr>'||to_char(vr_vlcompcr,'fm999G999G999G990D00')||'</vlcompcr>'||
                           '<nrctadeb>'||vr_tab_craphis(vr_tab_craphis_res(vr_ind).cdhistor).nrctadeb||'</nrctadeb>'||
                           '<nrctacrd>'||vr_tab_craphis(vr_tab_craphis_res(vr_ind).cdhistor).nrctacrd||'</nrctacrd>'||
                           '<cdhstctb>'||vr_tab_craphis(vr_tab_craphis_res(vr_ind).cdhistor).cdhstctb||'</cdhstctb>'||
												   '<tipottcompdb>'||to_char(vr_ttcompdb,'fm999G999G999G990D00')||'</tipottcompdb>'||
                           '<tipottcompcr>'||to_char(vr_ttcompcr,'fm999G999G999G990D00')||'</tipottcompcr>'||
                           '<tipoqttphist>'||to_char(vr_qttphist,'fm999G999G999G990')||'</tipoqttphist>'||
                         '</historico>');
          
          -- Se for o 580
          IF vr_tab_craphis_res(vr_ind).cdhistor = 580 THEN
            -- Deve gerar mais uma linha zerada
            pc_escreve_xml('<historico id="'||vr_tab_craphis_res(vr_ind).nrchave||'">'||
                             '<dstipomv></dstipomv>'||
                             '<dshistor></dshistor>'||
                             '<qtlancto>'||to_char(0,'fm999G999G990')||'</qtlancto>'||
                             '<vlcompdb>'||to_char(0,'fm999G999G999G990D00')||'</vlcompdb>'||
                             '<vlcompcr>'||to_char(0,'fm999G999G999G990D00')||'</vlcompcr>'||
                             '<nrctadeb></nrctadeb>'||
                             '<nrctacrd></nrctacrd>'||
                             '<cdhstctb></cdhstctb>'||
                             '<tipottcompdb>'||to_char(0,'fm999G999G999G990D00')||'</tipottcompdb>'||
                             '<tipottcompcr>'||to_char(0,'fm999G999G999G990D00')||'</tipottcompcr>'||
                             '<tipoqttphist>'||to_char(0,'fm999G999G999G990')||'</tipoqttphist>'||
                           '</historico>');
          END IF;
          
          -- alimenta a vari�vel de controle do first-of
          vr_ctipo := vr_tab_craphis_res(vr_ind).c_tipo;

          -- Buscar o pr�ximo registro da tabela
          vr_ind := vr_tab_craphis_res.NEXT(vr_ind);

        END LOOP;

        -- Totalizando geral
        pc_escreve_xml('</tipo><crrl011ttcompdb>'||to_char(vr_tgcompdb,'fm999G999G999G990D00')||'</crrl011ttcompdb>'||
                       '<crrl011ttcompcr>'||to_char(vr_tgcompcr,'fm999G999G999G990D00')||'</crrl011ttcompcr>'||
                       '<crrl011qttphist>'||to_char(vr_qttpgera,'fm999G999G999G990')||'</crrl011qttphist>'||
                       '<crrl011nmarqctb>'||vr_nmarqctb||'</crrl011nmarqctb>'||
                       '</crrl011>');

        -- Gerando o relat�rio
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_des_xml
                                   ,pr_dsxmlnode => '/crrl011/tipo/historico'
                                   ,pr_dsjasper  => 'crrl011_total.jasper'
                                   ,pr_dsparams  => ''
                                   ,pr_dsarqsaid => vr_path_arquivo || '/crrl011_'
                                                    ||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst'
                                   ,pr_flg_gerar => 'N'
                                   ,pr_qtcoluna  => 132
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => NULL
                                   ,pr_flg_impri => 'S'
                                   ,pr_nmformul  => '132col'
                                   ,pr_nrcopias  => vr_nrcopias
                                   ,pr_dspathcop => NULL
                                   ,pr_dsmailcop => NULL
                                   ,pr_dsassmail => NULL
                                   ,pr_dscormail => NULL
                                   ,pr_des_erro  => vr_dscritic);

        -- Liberando a mem�ria alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

      END IF;

      --------------------------------------------------------
      -- RELACAO DOS PEDIDOS DE TALONARIO DE CHEQUES (CRRL080)
      --------------------------------------------------------
      -- Busca a lista de pedidos que n�o devem ser gerados
      vr_lspedrou := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'PEDROUBADO'
                                               ,pr_tpregist => 0);

      -- Efetua o split das informacoes contidas na dstextab separados por virgula
      vr_vet_dados := gene0002.fn_quebra_string(pr_string  => vr_lspedrou
                                           ,pr_delimit => ',');

      -- Inicializando o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- gera o cabe�alho do arquivo xml
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl080><pedidos>');

      -- relaciona todos os pedidos de talon�rios em aberto
      FOR rw_crapped IN cr_crapped(pr_cdcooper => pr_cdcooper)
      LOOP
        -- Indica se o pedido consta na lista de exce��es
        vr_nprocess := FALSE;

        -- Se h� dados no registro de mem�ria
        IF vr_vet_dados.count > 0 THEN
          -- Verifica se o pedido consta na lista que n�o deve ser processado
          FOR vr_split IN vr_vet_dados.first .. vr_vet_dados.count LOOP
            -- se consta na lista de exce��es, vai para o pr�ximo registro
            IF rw_crapped.nrpedido = vr_vet_dados(vr_split) THEN
              vr_nprocess := TRUE;
            END IF;
          END LOOP;
        END IF;

        -- se o pedido est� na lista, vai para o proximo registro do cursor
        IF vr_nprocess THEN
          CONTINUE;
        END IF;

        -- selecionando as folhas de cheque
        OPEN cr_crapfdc( pr_cdcooper => pr_cdcooper
                        ,pr_nrpedido => rw_crapped.nrpedido);
        FETCH cr_crapfdc INTO rw_crapfdc;
        -- Fechando o cursor de folhas de cheque
        CLOSE cr_crapfdc;

        -----------------------------------------------------------------
        -- script para retornar o 5 dia �til levando em conta a data de
        -- solicita��o do talonario
        -----------------------------------------------------------------
        vr_dtprevis := rw_crapped.dtsolped;
        vr_nrdiautl := 0;
        LOOP
          -- Sai quando atingir o 5 dia �til
          EXIT WHEN vr_nrdiautl = 5;

          -- Indo para o proximo dia
          vr_dtprevis := vr_dtprevis + 1;

          -- retorna o proximo dia �til
          vr_dtprevis := gene0005.fn_valida_dia_util( pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => vr_dtprevis);
          -- Armazenando a quantidade de dias uteis
          vr_nrdiautl := nvl(vr_nrdiautl,0) + 1;

        END LOOP;

        -- Se o dia �til � maior ou igual a data do movimento
        -- vai para o pr�ximo pedido
        IF vr_dtprevis >= rw_crapdat.dtmvtolt THEN
          CONTINUE;
        END IF;

        -- Quantidade de dias de atraso
        vr_qtdiaatr := rw_crapdat.dtmvtolt - vr_dtprevis;

        -- calcula o n�mero inicial do talon�rio
        CHEQ0001.pc_numtal( pr_nrfolhas => pr_nrfolhas
                            -- n�mero da primeira folha de cheque emitida nesse pedido
                            ,pr_nrcalcul => rw_crapped.nrinichq
                            ,pr_nrtalchq => vr_nrinital
                            ,pr_nrposchq => vr_nrposchq);

        -- calcula o n�mero final do talon�rio
        CHEQ0001.pc_numtal( pr_nrfolhas => pr_nrfolhas
                            -- n�mero da �ltima folha de cheque emitida nesse pedido
                           ,pr_nrcalcul => rw_crapped.nrfinchq
                           ,pr_nrtalchq => vr_nrfintal
                           ,pr_nrposchq => vr_nrposchq );

        -- Inicia o XML
        pc_escreve_xml('<pedido id="'||rw_crapped.nrpedido||'">'||
                         '<nrpedido>'||to_char(rw_crapped.nrpedido,'fm999G999G999G990')||'</nrpedido>'||
                         '<nrseqped>'||rw_crapped.nrseqped||'</nrseqped>'||
                         '<dtsolped>'||to_char(rw_crapped.dtsolped,'dd/mm/yyyy')||'</dtsolped>'||
                         '<dttransm>'||to_char(rw_crapped.dtsolped+1,'dd/mm/yyyy')||'</dttransm>'||
                         '<dtprevis>'||to_char(vr_dtprevis,'dd/mm/yyyy')||'</dtprevis>'||
                         '<qtdiaatr>'||trunc(vr_qtdiaatr)||'</qtdiaatr>'||
                         '<nrdctabb>'||rw_crapped.nrdctabb||'</nrdctabb>'||
                         '<nrinital>'||vr_nrinital||'</nrinital>'||
                         '<nrfintal>'||vr_nrfintal||'</nrfintal>'||
                         '<dsformul>'||rw_crapfdc.dsformul||'</dsformul></pedido>');


      END LOOP;
      -- finalizando o arquivo XML
      pc_escreve_xml('</pedidos></crrl080>');

      -- Gerando o relat�rio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_des_xml
                                 ,pr_dsxmlnode => '/crrl080/pedidos/pedido'
                                 ,pr_dsjasper  => 'crrl080.jasper'
                                 ,pr_dsparams  => ''
                                 ,pr_dsarqsaid => vr_path_arquivo || '/crrl080.lst'
                                 ,pr_flg_gerar => 'N'
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 2
                                 ,pr_cdrelato  => NULL
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => '132col'
                                 ,pr_nrcopias  => 1
                                 ,pr_dspathcop => NULL
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_des_erro  => vr_dscritic);

      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Comitando
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
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
        -- Efetuar commit pois gravaremos o que foi processo at� ent�o
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos c�digo e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END PC_CRPS006;
/
