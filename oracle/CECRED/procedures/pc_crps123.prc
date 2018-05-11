CREATE OR REPLACE PROCEDURE CECRED.pc_crps123(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN
  /* ..........................................................................

   Programa: pc_crps123                                Antigo: Fontes/crps123.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                       Ultima atualizacao: 16/11/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 040.
               Efetuar os lancamentos automaticos no sistema.
               Emite relatorio 101.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

     Alteracoes: 31/08/95 - Alterado para fazer a consistencia se o associado foi
                            transferido de conta (Odair).

                 03/10/95 - Acerto na atualizacao da data do ultimo debito
                            (Deborah).

                 08/10/96 - Alterado layout do frame f_integracao (Edson).

                 09/04/97 - Alterado para permitir o debito de Telesc de faturas
                            canceladas apos a integracao (Deborah).

                 05/05/97 - Atualizar dtdebito  (Odair).

                 09/05/97 - Permitir lancamento de debitos de faturas Telesc
                            com autorizacao canceladas (Deborah).

                 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                 15/07/98 - Colocar cdbccxpg 11 para lote (Odair)

                 19/08/98 - Criar ndb para nao debitados de debitos automaticos
                            atraves do includes/gerandb.i (Odair)

                 28/08/98 - Mostrar no relatorio se esta em CL (Deborah).

                 09/11/98 - Tratar situacao em prejuizo (Deborah).

                 11/01/99 - Acerto no layout do relatorio (Deborah).

                 29/01/99 - Alimentar cdpesqbb com craplau.nrdcomto para tratar
                            debitos automaticos (CELESC,CASAN, etc).

                 04/10/1999 - Alteracoes no relatorio (Deborah).

                 30/10/1999 - Tratar cdrefere para telesc celular e
                              fixa como nrcrcard (Odair)

                 23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                              titular (Eduardo).

                 01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

                 29/03/2001 - Criar um lote para cada quebra de PAC ou Banco de
                              pagamento (Edson).

                 24/07/2001 - Acrescentar criticas 722 e 723 no relatorio
                              (Junior).

                 03/08/2001 - Alterado atualizacao do cdpesqbb (Margarete).

                 21/08/2001 - Tratar onze posicoes no numero do documento (Edson).

                 12/04/2002 - Atualizar os valores informados na capa do lote no
                              mesmo momento em que sao atualizados os valores
                              computados (Junior).

                 19/09/2003 - Quando histor 40 e cdbccxlt = 911 criar
                              craplcm.cdbccxlt = 100 (Margarete).

                 03/06/2004 - Incluido Critica 801 Prejuizo (Evandro)

                 09/06/2004 - Acessar banco Generico(Mirtes).

                 22/12/2004 - Atualizar deta do ultimo debito no crapatr mesmo
                              se o historico estiver bloqueado (Julio)

                 29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                              craprej e craplcm (Diego).

                 07/11/2005 - Tratamento para lancamento em duplicidade UNIMED
                              Hist. 509 (Julio)

                 10/12/2005 - Atualizar craprej.nrdctabb (Magui).

                 16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                 08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                             (Sidnei - Precise)

                 04/06/2008 - Campo dsorigem nas leituras da craplau (David)

                 14/07/2009 - incluido no for each a condição -
                              craplau.dsorigem <> "PG555" - Precise - paulo

                 19/10/2009 - Alteracao Codigo Historico (Kbase).

                 18/05/2010 - Incluido tratamento para historico 834 - TIM
                              conforme historico 288 (Elton)

                 21/02/2011 - Incluir cdpesqbb na criacao do craprej (Magui).

                 02/06/2011 - Desprezar craplau do TAA (Evandro).

                 05/07/2011 - Tratamento para Liberty - 993 (Elton).

                 03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                              craplau. (Fabricio)

                 03/10/2012 - Tratamento para migracao Alto Vale de historicos de
                              debito automatico (Elton).

                 30/11/2012 - Ajuste migracao Alto Vale (Elton).

                 19/07/2013 - Tratamento para o Bloqueio Judicial (Ze).

                 01/08/2013 - Tratamento com historicos de consorcio, cdhistor
                              1230, 1231, 1232, 1233, 1234 (Lucas R.).

                 04/11/2013 - Nova forma de chamar as agências, de PAC agora
                              a escrita será PA (Guilherme Gielow)

                 06/11/2013 - Ajustes migracao Acredi (Elton).

                 23/12/2013 - Conversão Progress >> PLSQL (Jean Michel).

                 06/01/2014 - Ajuste tratamento de consorcio: se for historicos
                              de consorcio nao faz assign (Carlos)

                 15/01/2014 - Inclusao de VALIDATE craplot, craprej e craplcm
                              (Carlos)

                 28/01/2014 - Incluir FIND crapcop (Lucas R.)

                 01/04/2014 - incluido nas consultas da craplau
                              craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
															
                 02/05/2014 - Incluir ajustes referentes ao debito automatico
                              Softdesk 144066 (Lucas R.)
                 
                 27/08/2014 - Débito Fácil : Tratamento para autorizações de débitos que
                              foram suspensas pelos usuários (Vanessa).
				 
                 30/10/2014 - Incluir variavel vr_gerandb para somente gerar craplcm se
                              se o crapndb de debito automatico não for criado (Lucas R./Elton)
                              
                 27/11/2014 - Condicao no cursor da craplau para nao pegar registros com
                              dsorigem = CAPTACAO (Tiago).
                              
                 14/01/2015 - Tratamento para nao gerar lcm quando historico for de debito
                              automatico e o cooperado nao possuir saldo em conta 
                              (agora para convenios nossos; desde que o convenio esteja setado
                               para nao debitar sem saldo).
                              (Chamado 229249 # PRJ Melhoria) - (Fabricio)
                              
                 16/01/2015 - Removido condicao da craplau que fazia com que buscasse apenas
                              registros onde a data de pagamento fosse maior ou igual a hoje.
                            - Retornado parametro flgbatch para 1 no valida_iniprg.
                              (Chamados 243623/243848) - (Fabricio)
															
								 10/02/2015 - Criação de mensagem de notificação no internetbank ao gerar
								              crítica de insuficiência de saldo para débito (Lunelli - SD. 229251)
                              
                 13/02/2015 - Adicionado cursor cr_gnconve. 
                              (Chamado 229249 # PRJ Melhoria) - (Fabricio)
                              
                 23/03/2015 - #262668 Correção de tratamento de erro de CONV0001.pc_gerandb e
                              retorno dos valores das variáveis auxiliares de crítica para as 
                              variáveis principais. A falta do retorno dos valores estava deixando
                              as variáveis de crítica desatualizadas (Carlos)
                              
                 25/03/2015 - Ajustes liberacao Marco/2015; zerado variavel auxiliar de critica
                              e tratado para mudar o insitlau para 3 sempre que gerar ndb.
                              (Fabrício)
															
                 30/03/2015 - Correção no formato de data das mensagens enviadas por      
                              crítica de insuficiência de saldo para débito (Lunelli - SD. 267208)
                              
                 31/03/2015 - (Chamado 270394) Inserir coluna "PA" no relatório crrl101
                              (Tiago Castro - RKAM).
								
                 16/04/2015 - Incluir validação para os históricos de consóricios, 1230, 1231, 
                              1232, 1233, 1234 validarem o saldo negativo. (Lucas Ranghetti #272181)
                            - Quando nao encontrar autorizacao de debito automatico cadastrada (453), 
                              deve gerar ndb para retornar a critica a empresa. 
                              (Chamado 275834) - (Fabricio)
                              
                 29/04/2015 - Passado para a procedure pc_solicita_relato o nome do formulario
                              do relatorio 101. (Fabricio)
															
								 04/05/2015 - Alterada regra para apenas atualizar a data do último débito
								              na tabela de autorizações (crapatr) quando houver sido criada craplcm
								              (Lucas Lunelli - SD 256257)
                 
                 28/09/2015 - incluido nas consultas da craplau
                              craplau.dsorigem <> "CAIXA" (Lombardi).
                              
                 17/11/2015 - Alterado para não processar os lançamentos futuros de debito automatico,
                              a primeira tentativa será feita pelos programas CRPS509 e CRPS642.
                                SD358495 e 358499 (Odirlei-AMcom)       
                                
                 22/04/2016 - Incluso tratamento para não debitar contas com ação judicial (Daniel)                     

                 20/05/2016 - Incluido nas consultas da craplau
                              craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)

                 02/03/2017 - Incluido nas consultas da craplau 
                              craplau.dsorigem <> "ADIOFJUROS" (Lucas Ranghetti M338.1)

         		 04/04/2017 - Ajuste para integracao de arquivos com layout na versao 5
				             (Jonata - RKAM M311).
                 
                 26/07/2017 - Inclusão na tabela de erros Oracle
                            - Padronização de logs
                            - Inclusão parâmetros nas mensagens
                            - Chamado 709894 (Ana Volles - Envolti)

                 02/08/2017 - Inclusão parâmetros nas mensagens de erro de insert e update
                            - Chamado 709894 (Ana Volles - Envolti)

                 21/09/2017 - Ajustado para não gravar nmarqlog, pois so gera a tbgen_prglog
                              (Ana - Envolti - Chamado 746134)
														   
                 18/10/2017 - Ajustar para não verificar mais os consorcios nesta rotina
                              e sim no crps663 (Lucas Ranghetti #739738) 

                 16/11/2017 - Incluída condição para não buscar registros com origem DOMICILIO na craplau
							  (Mauricio - Mouts)

  ............................................................................................*/
  
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- CÓDIGO DO PROGRAMA
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS123';

    -- TRATAMENTO DE ERROS
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;

    vr_cdcritic PLS_INTEGER := 0;
    vr_auxcdcri PLS_INTEGER := 0;

    vr_dscritic VARCHAR2(4000);
    vr_auxdscri VARCHAR2(4000);

    -- DIVERSAS
    vr_dsintegr VARCHAR2(50);
    vr_dsarquiv VARCHAR2(200) := '/rl/crrl101.lst';
    vr_nrdolot1 INTEGER;
    vr_nrdolot2 INTEGER;
    vr_nrdolote INTEGER;
    vr_cdcooper INTEGER;
    vr_cdcopmig INTEGER;
    vr_cdagenci INTEGER;
    vr_nrdconta INTEGER;
    vr_cdbccxlt INTEGER;
    vr_migracao INTEGER;
    vr_flagatr  INTEGER := 0;
    vr_craplot  INTEGER := 0;
    vr_ctamigra INTEGER := 0;
    vr_dsdmensg  VARCHAR2(1500);
    vr_nmconven  VARCHAR2(200);
    vr_flgentra INTEGER := 0;
    vr_glbcoop  INTEGER := pr_cdcooper;

    vr_nrdocmto DECIMAL(38,10);
    vr_nrcrcard craplau.nrcrcard%TYPE;

    vr_stsnrcal NUMBER;
    vr_clobxml  CLOB;

    vr_dsparame crapsol.dsparame%type;
    vr_dsdctitg craprej.nrdctitg%TYPE;
	  vr_gerandb NUMBER := 1; -- Gera crapndb

    vr_dsctajud crapprm.dsvlrprm%TYPE;

    --Chamado 709894
    vr_dsparam  varchar2(2000);
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;      

    ------------------------------- CURSORES ---------------------------------

    -- BUSCA DOS DADOS DA COOPERATIVA
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop, cop.nmextcop, cop.cdagesic
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; -- CODIGO DA COOPERATIVA
    rw_crapcop cr_crapcop%ROWTYPE;

    -- CURSOR GENÉRICO DE CALENDÁRIO
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- BUSCA DOS DADOS DE LOTES
    CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtopr IN crapdat.dtmvtopr%TYPE) IS
      SELECT lot.cdcooper,
             lot.cdagenci,
             lot.cdbccxlt,
             lot.dtmvtolt,
             lot.nrdolote,
             lot.qtcompln,
             lot.qtinfoln,
             lot.tplotmov,
             lot.vlcompcr,
             lot.vlcompdb,
             lot.vlinfocr,
             lot.vlinfodb,
             lot.nrseqdig,
             lot.progress_recid
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND lot.dtmvtolt = pr_dtmvtopr -- DATA DE MOVIMENTACAO
         AND lot.nrdolote > 6500        -- NUMERO DO LOTE
         AND lot.nrdolote < 6600        -- NUMERO DO LOTE
         AND lot.tplotmov = 1           -- TIPO DO LOTE

       ORDER BY lot.progress_recid DESC;

    rw_craplot cr_craplot%ROWTYPE;

    -- BUSCA LANCAMENTOS AUTOMATICOS
    CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtopr IN crapdat.dtmvtopr%TYPE) IS
      SELECT lau.cdagenci,
             lau.nrdconta,
             lau.cdbccxlt,
             lau.cdhistor,
             lau.nrcrcard,
             lau.nrdocmto,
						 lau.dscodbar,
						 lau.dtmvtopg,
             lau.vllanaut,
             lau.cdseqtel,
             lau.nrdctabb,
             lau.nrseqdig,
             lau.dtmvtolt,
             lau.nrdolote,
             lau.cdcritic,
             lau.cdempres,
             lau.rowid,
             lau.flgblqdb,
             lau.idlancto,            
             ROW_NUMBER() OVER(PARTITION BY lau.cdagenci,
                                            lau.cdbccxlt,
                                            lau.cdbccxpg,
                                            lau.cdhistor
                               ORDER BY lau.cdagenci,
                                        lau.cdbccxlt,
                                        lau.cdbccxpg,
                                        lau.cdhistor,
                                        lau.nrdocmto) AS seqlauto
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND lau.dtmvtopg <= pr_dtmvtopr -- DATA DE PAGAMENTO
         AND lau.insitlau = 1 -- SITUACAO DO LANCAMENTO
         AND lau.dsorigem NOT IN ('CAIXA'
                                 ,'INTERNET'
                                 ,'TAA'
                                 ,'PG555'
                                 ,'CARTAOBB'
                                 ,'BLOQJUD'
                                 ,'DAUT BANCOOB'
                                 ,'CAPTACAO'
                                 ,'DEBAUT'
                                 ,'TRMULTAJUROS'
                                 ,'ADIOFJUROS'
                                 ,'DOMICILIO') -- ORIGEM DA OPERACAO
         AND lau.cdhistor NOT IN( 1019,1230,1231,1232,1233,1234) --> 1019 será processado pelo crps642, consorcio no debcns
       ORDER BY lau.cdagenci
               ,lau.cdbccxlt
               ,lau.cdbccxpg
               ,lau.cdhistor
               ,lau.nrdocmto
               ,lau.progress_recid;
    rw_craplau cr_craplau%ROWTYPE;

    -- BUSCA LANCAMENTOS AUTOMATICOS
    CURSOR cr_craptco(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT tco.cdcooper, tco.nrdconta, tco.cdagenci
        FROM craptco tco
       WHERE tco.cdcopant = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND tco.nrctaant = pr_nrdconta -- NUMERO DA CONTA
         AND tco.flgativo = 1           -- INDICADOR DE PESQUISA ATIVA
         AND tco.tpctatrf = 1;          -- TIPO DE CONTA TRANSFERIDA (1=C/C, 2=CONTA SALARIO)

    rw_craptco cr_craptco%ROWTYPE;

    -- BUSCA HISTORICOS
    CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_cdhistor IN craphis.cdhistor%TYPE) IS

      SELECT his.dshistor
        FROM craphis his
       WHERE his.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND his.cdhistor = pr_cdhistor -- CODIGO DO HISTORICO
         AND (his.inautori = 1 OR       -- IND. P/AUTORIZACAO DE DEBITO
             his.cdhistor = 586)        -- SEGURO AUTO - MDS
       ORDER BY his.progress_recid DESC;

    rw_craphis cr_craphis%ROWTYPE;

    -- BUSCA ASSOCIADOS
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS

      SELECT ass.dtelimin,
             ass.cdsitdtl,
             ass.dtdemiss,
             ass.cdsitdct,
             ass.nrdconta,
             ass.cdcooper,
             ass.nrctacns,
             ass.cdagenci,
             ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND ass.nrdconta = pr_nrdconta; -- NUMERO DA CONTA

    rw_crapass cr_crapass%ROWTYPE;

    -- BUSCA TRANSFERENCIA OU DUPLICAO DE CONTA
    CURSOR cr_craptrf(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS

      SELECT trf.nrsconta
        FROM craptrf trf
       WHERE trf.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND trf.nrdconta = pr_nrdconta -- NUMERO DA CONTA
         AND trf.tptransa = 1           -- TIPO TRANSACAO
         AND trf.insittrs = 2           -- INDICADOR
       ORDER BY trf.progress_recid ASC;

    rw_craptrf cr_craptrf%ROWTYPE;

    -- BUSCA SALDOS DO ASSOCIADO EM DEPOSITOS A VISTA
    CURSOR cr_crapsld(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS

      SELECT sld.dtdsdclq, sld.qtddsdev, sld.vlsddisp
        FROM crapsld sld
       WHERE sld.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND sld.nrdconta = pr_nrdconta; -- NUMERO DA CONTA

    rw_crapsld cr_crapsld%ROWTYPE;

    -- BUSCA HISTORICOS
    CURSOR cr_craphis_I(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_cdhistor IN craphis.cdhistor%TYPE) IS

      SELECT his.cdhistor, his.indebcta, his.inautori
        FROM craphis his
       WHERE his.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND his.cdhistor = pr_cdhistor; -- CODIGO DO HISTORICO

    rw_craphis_I cr_craphis_I%ROWTYPE;

    -- BUSCA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
    CURSOR cr_crapatr(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE,
                      pr_cdhistor IN craphis.cdhistor%TYPE,
                      pr_nrcrcard IN craplau.nrcrcard%TYPE) IS

      SELECT atr.dtfimatr, atr.cdrefere, atr.dtultdeb, atr.rowid, atr.flgmaxdb, atr.vlrmaxdb
        FROM crapatr atr
       WHERE atr.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND atr.nrdconta = pr_nrdconta  -- NUMERO DA CONTA
         AND atr.cdhistor = pr_cdhistor  -- CODIGO DO HISTORICO
         AND atr.cdrefere = pr_nrcrcard; -- COD. REFERENCIA

    rw_crapatr cr_crapatr%ROWTYPE;

    -- BUSCA DADOS DE LANCAMENTOS
    CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtopr IN craplcm.dtmvtolt%TYPE,
                      pr_cdagenci IN craplcm.cdagenci%TYPE,
                      pr_cdbccxlt IN craplcm.cdbccxlt%TYPE,
                      pr_nrdolote IN craplcm.nrdolote%TYPE,
                      pr_nrdctabb IN craplcm.nrdctabb%TYPE,
                      pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS

      SELECT lcm.nrdolote
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND lcm.dtmvtolt = pr_dtmvtopr  -- DATA DE MOVIMENTACAO
         AND lcm.cdagenci = pr_cdagenci  -- CODIGO DO PA
         AND lcm.cdbccxlt = pr_cdbccxlt  -- BANCO/CAIXA
         AND lcm.nrdolote = pr_nrdolote  -- LOTE
         AND lcm.nrdctabb = pr_nrdctabb  -- CONTA BB
         AND lcm.nrdocmto = pr_nrdocmto; -- NUMERO DO DOCUMENTO

    rw_craplcm cr_craplcm%ROWTYPE;

    -- BUSCA DADOS DE EMPRÉSTIMOS
    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS

      SELECT epr.cdcooper, epr.nrdconta
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND epr.nrdconta = pr_nrdconta -- NUMERO DA CONTA
         AND epr.inprejuz = 1           -- IND. DO PREJUIZO
         AND epr.vlsdprej > 0;          -- VALOR DO PREJUIZO

    rw_crapepr cr_crapepr%ROWTYPE;
		
		--Selecionar titulares com senhas ativas 
		CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
										  ,pr_nrdconta IN crapsnh.nrdconta%TYPE
											,pr_cdsitsnh IN crapsnh.cdsitsnh%TYPE
											,pr_tpdsenha IN crapsnh.tpdsenha%TYPE) IS
			SELECT crapsnh.nrcpfcgc
						,crapsnh.cdcooper
						,crapsnh.nrdconta
						,crapsnh.idseqttl
			FROM crapsnh
			WHERE crapsnh.cdcooper = pr_cdcooper
			AND   crapsnh.nrdconta = pr_nrdconta
			AND   crapsnh.cdsitsnh = pr_cdsitsnh
			AND   crapsnh.tpdsenha = pr_tpdsenha;
		rw_crapsnh cr_crapsnh%ROWTYPE;
		
		--Selecionar informacoes do titular
		CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
											,pr_nrdconta IN crapttl.nrdconta%type
											,pr_idseqttl IN crapttl.idseqttl%type) IS
			SELECT crapttl.nmextttl
						,crapttl.nrcpfcgc
			FROM crapttl
			WHERE crapttl.cdcooper = pr_cdcooper
			AND   crapttl.nrdconta = pr_nrdconta
			AND   crapttl.idseqttl = pr_idseqttl;
		rw_crapttl cr_crapttl%ROWTYPE;
	
		--Selecionar Informacoes Convenios
		CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
											,pr_cdempcon IN crapcon.cdempcon%type
											,pr_cdsegmto IN crapcon.cdsegmto%type) IS
			SELECT crapcon.nmextcon
			FROM crapcon
			WHERE crapcon.cdcooper = pr_cdcooper
			AND   crapcon.cdempcon = pr_cdempcon
			AND   crapcon.cdsegmto = pr_cdsegmto;
		rw_crapcon cr_crapcon%ROWTYPE;	

    -- BUSCA DADOS DE CADASTROS REJEITADOS NA INTEGRAÇÃO
    CURSOR cr_craprej(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN craprej.dtmvtolt%TYPE,
                      pr_cdagenci IN craprej.cdagenci%TYPE,
                      pr_cdbccxlt IN craprej.cdbccxlt%TYPE,
                      pr_nrdolote IN craprej.nrdolote%TYPE) IS

      SELECT rej.cdcooper,
             rej.dtmvtolt,
             rej.cdagenci,
             rej.cdbccxlt,
             rej.nrdolote
        FROM craprej rej
       WHERE rej.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND rej.dtmvtolt = pr_dtmvtolt -- DATA DE MOVIMENTACAO
         AND rej.cdagenci = pr_cdagenci -- CODIGO DO PA
         AND rej.cdbccxlt = pr_cdbccxlt -- BANCO/CAIXA
         AND rej.nrdolote = pr_nrdolote -- NUMERO DO LOTE
         AND rej.dshistor = 'CONTROLE'  -- DESCRICAO DO HISTORICO
       ORDER BY rej.progress_recid ASC;

    rw_craprej cr_craprej%ROWTYPE;

    -- BUSCA REGISTRO REFERENTES A LOTES
    CURSOR cr_craplot_II(pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtmvtolt IN craprej.dtmvtolt%TYPE,
                         pr_cdagenci IN craprej.cdagenci%TYPE,
                         pr_cdbccxlt IN craprej.cdbccxlt%TYPE,
                         pr_nrdolote IN craprej.nrdolote%TYPE) IS

      SELECT lot.cdcooper,
             lot.dtmvtolt,
             lot.cdagenci,
             lot.cdbccxlt,
             lot.nrdolote,
             lot.qtcompln,
             lot.qtinfoln,
             lot.vlcompdb,
             lot.vlinfodb,
             lot.vlcompcr,
             lot.vlinfocr,
             lot.tplotmov,
             lot.nrseqdig,
             lot.cdbccxpg,
             lot.rowid
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND lot.dtmvtolt = pr_dtmvtolt  -- DATA DE MOVIMENTACAO
         AND lot.cdagenci = pr_cdagenci  -- CODIGO DO PA
         AND lot.cdbccxlt = pr_cdbccxlt  -- BANCO/CAIXA
         AND lot.nrdolote = pr_nrdolote; -- NUMERO DO LOTE

    rw_craplot_II cr_craplot_II%ROWTYPE;

    -- BUSCAR PARAMETRO DA SOLICITAÇÃO
    CURSOR cr_dsparame(pr_cdprogra  crapprg.cdprogra%TYPE) IS
      SELECT crapsol.dsparame
        FROM crapsol crapsol
           , crapprg crapprg
        WHERE crapsol.nrsolici = crapprg.nrsolici -- NUMERO DA SOLICITACAO
          AND crapsol.cdcooper = crapprg.cdcooper -- CODIGO DA COOPERATIVA
          AND crapprg.cdcooper = pr_cdcooper      -- CODIGO DA COOPERATIVA
          AND crapprg.cdprogra = pr_cdprogra      -- CODIGO DO PROGRAMA
          AND crapsol.insitsol = 1;               -- SITUACAO DA SOLICITACAO
          
    -- Buscar informacoes de convenios nossos; debito automatico (CECRED)
    CURSOR cr_gnconve (pr_cdhistor craphis.cdhistor%TYPE) IS
      SELECT gnconve.flgdbssd
        FROM gnconve
       WHERE gnconve.cdhisdeb = pr_cdhistor
         AND gnconve.flgativo = 1;
         
    rw_gnconve cr_gnconve%ROWTYPE;

    --------------- SUBROTINAS --------------------------

    -- SUBROTINA PARA ESCREVER TEXTO NA VARIÁVEL CLOB DO XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      -- ESCREVE DADOS NA VARIAVEL vr_clobxml QUE IRA CONTER OS DADOS DO XML
      dbms_lob.writeappend(vr_clobxml, length(pr_des_dados), pr_des_dados);
    END;
    
    -- Procedimento para retornar o nome do banco
    FUNCTION pc_busca_banco(pr_cdbccxpg craplau.cdbccxpg%type) return varchar2 is

      CURSOR cr_crapbcl is
       SELECT nmresbcc
          FROM crapbcl
         WHERE cdbccxlt = pr_cdbccxpg;
      rw_crapbcl cr_crapbcl%rowtype;

    BEGIN

      OPEN cr_crapbcl;
      FETCH cr_crapbcl
       INTO rw_crapbcl;
      IF cr_crapbcl%NOTFOUND THEN
        CLOSE cr_crapbcl;
        RETURN GENE0002.fn_mask(pr_cdbccxpg,'999')||'-NAO CAD.';
      ELSE
        CLOSE cr_crapbcl;
        RETURN rw_crapbcl.nmresbcc;
      END IF;
    END pc_busca_banco;

    PROCEDURE pc_gera_relatorio(pr_cdcooper IN INTEGER) IS

      /* .............................................................................
      Programa: pc_gera_relatorio
      Autor   : Jean Michel.
      Data    : 02/01/2014                     Ultima atualizacao:

      Dados referentes ao programa:

      Objetivo   : Procedure criada p/ gerar xml de relatório do programa pc_crps123.

      Parametros : pr_cdcooper => Codigo da cooperativa

      Premissa   :

      Alteracoes :

      .............................................................................*/

    BEGIN
      DECLARE

        vr_qtdifeln INTEGER;
        vr_vldifedb INTEGER;
        vr_vldifecr INTEGER;
        vr_dshistor VARCHAR2(50);

        -- CURSORES --

        -- BUSCA DADOS DE CADASTROS REJEITADOS NA INTEGRAÇÃO
        CURSOR cr_craprej(pr_cdcooper IN crapcop.cdcooper%TYPE) IS

          SELECT rej.cdcooper,
                 rej.dtmvtolt,
                 rej.cdagenci,
                 rej.cdbccxlt,
                 rej.nrdolote
            FROM craprej rej
           WHERE rej.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
             AND rej.cdpesqbb = 'CRPS123'   -- COD. PESQUISA BANCO
             AND rej.dshistor = 'CONTROLE'  -- DESCRICAO DO HISTORICO
             AND rej.tplotmov = 123         -- TIPO DO LOTE
           ORDER BY rej.dtmvtolt, rej.cdagenci, rej.cdbccxlt, rej.nrdolote;

        rw_craprej cr_craprej%ROWTYPE;

        -- BUSCA DADOS DE CADASTROS REJEITADOS NA INTEGRAÇÃO (BUSCA COM FILTROS DIFERENTE DA ACIMA)
        CURSOR cr_craprej_I(pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                            pr_cdagenci IN craplot.cdagenci%TYPE,
                            pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                            pr_nrdolote IN craplot.nrdolote%TYPE) IS

          SELECT rej.cdcooper
            FROM craprej rej
           WHERE rej.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
             AND rej.dtmvtolt = pr_dtmvtolt -- DATA DE MOVIMENTACAO
             AND rej.cdagenci = pr_cdagenci -- CODIGO DO PA
             AND rej.cdbccxlt = pr_cdbccxlt -- BANCO / CAIXA
             AND rej.nrdolote = pr_nrdolote -- NUMERO DO LOTE
             AND rej.tpintegr = 12          -- TIPO DE INTEGRACAO
           ORDER BY rej.progress_recid ASC;

        rw_craprej_I cr_craprej_I%ROWTYPE;

        -- BUSCA DADOS DE CADASTROS REJEITADOS NA INTEGRAÇÃO (BUSCA COM FILTROS DIFERENTE DA ACIMA)
        CURSOR cr_craprej_II(pr_cdcooper IN crapcop.cdcooper%TYPE,
                             pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                             pr_cdagenci IN craplot.cdagenci%TYPE,
                             pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                             pr_nrdolote IN craplot.nrdolote%TYPE) IS

          SELECT rej.cdcritic,
                 rej.cdcooper,
                 rej.cdhistor,
                 rej.nrdocmto,
                 rej.dtdaviso,
                 rej.nrdconta,
                 rej.vllanmto,
                 rej.nrseqdig,
                 rej.cdagenci
            FROM craprej rej
           WHERE rej.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
             AND rej.dtmvtolt = pr_dtmvtolt  -- DATA DE MOVIMENTACAO
             AND rej.cdagenci = pr_cdagenci  -- CODIGO DO PA
             AND rej.cdbccxlt = pr_cdbccxlt  -- BANCO / CAIXA
             AND rej.nrdolote = pr_nrdolote  -- NUMERO DO LOTE
             AND rej.tpintegr = 12           -- TIPO DE INTEGRACAO
           ORDER BY rej.dtmvtolt,
                    rej.cdagenci,
                    rej.cdbccxlt,
                    rej.nrdolote,
                    rej.tpintegr,
                    rej.nrseqdig;

        rw_craprej_II cr_craprej_II%ROWTYPE;

        -- BUSCA HISTORICOS
        CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_cdhistor IN craphis.cdhistor%TYPE) IS

          SELECT his.dshistor
            FROM craphis his
           WHERE his.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
             AND his.cdhistor = pr_cdhistor; -- CODIGO DO HISTORICO

        rw_craphis cr_craphis%ROWTYPE;
        
        CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
          SELECT ass.cdagenci,
                 ass.nmprimtl
          FROM   crapass ass
          WHERE  ass.cdcooper = pr_cdcooper
          AND    ass.nrdconta = pr_nrdconta;

        rw_crapass cr_crapass%ROWTYPE;
       -- busca nome do banco 
       CURSOR cr_crapbcl(pr_cdbccxpg IN crapbcl.cdbccxlt%TYPE) is
        SELECT nmresbcc
          FROM crapbcl
         WHERE cdbccxlt = pr_cdbccxpg;
       rw_crapbcl cr_crapbcl%rowtype;
       
       --Type para armazenar os totais de debito por agencia
       type typ_reg_tdebito is record ( cdagenci     crapass.cdagenci%TYPE,
                                        cdhistor     craplau.cdhistor%TYPE,
                                        dshistor     VARCHAR2(50),
                                        qtdebito     number,
                                        vldebito     number);

       type typ_tab_reg_tdebito is table of typ_reg_tdebito
                                index by varchar2(8); --Ag(3) + His(5)
                                
       --Type para armazenar os detalhes para exibicao no relatorio
        type typ_reg_det is record ( cdagenci     crapass.cdagenci%type,
                                     nrdconta     craplau.nrdconta%TYPE,                                     
                                     nmprimtl     crapass.nmprimtl%TYPE,
                                     cdhistor     craplau.cdhistor%TYPE,   
                                     dshistor     VARCHAR2(50),                             
                                     dtdaviso     craprej.dtdaviso%TYPE,
                                     nrdocmto     craplau.nrdocmto%TYPE,                                                                          
                                     nrseqlan     craplau.nrseqlan%TYPE,
                                     vllanaut     craplau.vllanaut%TYPE,
                                     dsobserv     varchar2(500)
                                     );

        type typ_tab_reg_det is table of typ_reg_det
                             index by varchar2(54); --Ag(3) + His(5) + Cta(8) + Ndoc(25)
       
        --Type para armazenar os valores por agencia, para exibicao no relatorio
       type typ_reg_ag is record ( cdagenci       crapass.cdagenci%type,
                                   dtdebito       date,
                                   cdbccxlt       craplau.cdbccxlt%type,
                                   dtmvtopg       VARCHAR2(10),
                                   vr_tab_det     typ_tab_reg_det,
                                   vr_tab_tdeb    typ_tab_reg_tdebito
                                 );
        
        type typ_tab_reg_ag is table of typ_reg_ag
                            index by varchar2(3); --Ag(3)
        vr_tab_ag      typ_tab_reg_ag;
        vr_tab_tot_ger typ_tab_reg_tdebito;
        
         -- Variavel para chaveamento (hash) da tabela de aplicacoes
        vr_des_chave_tdeb    varchar2(8);
        vr_des_chave_ag      varchar2(8);
        vr_des_chave_det     varchar2(54);
        
      BEGIN
        -- INICIALIZAR O CLOB (XML)
        dbms_lob.createtemporary(vr_clobxml, TRUE);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

        --Inclusão nome do módulo logado - Chamado 709894
        gene0001.pc_set_modulo(pr_module => 'PC_CRPS123'
                              ,pr_action => 'pc_gera_relatorio');

        -- INICIO DO ARQUIVO XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

        -- CONSULTA DE CADASTROS REJEITADOS NA INTEGRAÇÃO
        OPEN cr_craprej(pr_cdcooper => pr_cdcooper);
        LOOP
          FETCH cr_craprej
            INTO rw_craprej;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_craprej%NOTFOUND;

          -- CONSULTA DE LOTES
          OPEN cr_craplot_II(pr_cdcooper => rw_craprej.cdcooper,
                             pr_dtmvtolt => rw_craprej.dtmvtolt,
                             pr_cdagenci => rw_craprej.cdagenci,
                             pr_cdbccxlt => rw_craprej.cdbccxlt,
                             pr_nrdolote => rw_craprej.nrdolote);

          FETCH cr_craplot_II
            INTO rw_craplot_II;

          IF cr_craplot_II%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_craplot_II;

            -- MONTAR MENSAGEM DE CRITICA
            vr_cdcritic := 60;
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            --Chamado 709894
            vr_dsparam := 'Dtmvtolt='||rw_craprej.dtmvtolt
                        ||',Cdagenci='||rw_craprej.cdagenci
                        ||',Cdbccxlt='||rw_craprej.cdbccxlt
                        ||',Nrdolote='||rw_craprej.nrdolote;
            
            -- EFETUA RAISE POIS A CRITICA
            RAISE vr_exc_saida;
          ELSE
            -- FECHAR O CURSOR
            CLOSE cr_craplot_II;
          END IF;

          -- CONSULTA DE CADASTROS REJEITADOS
          OPEN cr_craprej_I(pr_cdcooper => rw_craplot_II.cdcooper,
                            pr_dtmvtolt => rw_craplot_II.dtmvtolt,
                            pr_cdagenci => rw_craplot_II.cdagenci,
                            pr_cdbccxlt => rw_craplot_II.cdbccxlt,
                            pr_nrdolote => rw_craplot_II.nrdolote);

          FETCH cr_craprej_I
            INTO rw_craprej_I;

          -- VERIFICA SE EXISTEM REGISTROS
          IF cr_craprej_I%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_craprej_I;
            -- CASO NAO ENCONTRE REGISTROS SEGUE PARA PROXIMO REGISTRO DA CRAPREJ
            CONTINUE;
          ELSE
            -- FECHAR O CURSOR
            CLOSE cr_craprej_I;
          END IF;

          vr_cdcritic := 0; -- CODIGO DE CRITICA
          vr_dsintegr := 'DEBITO EM CONTA'; -- DESCRICAO DA INTEGRACAO

          vr_qtdifeln := rw_craplot_II.qtcompln - rw_craplot_II.qtinfoln;
          vr_vldifedb := rw_craplot_II.vlcompdb - rw_craplot_II.vlinfodb;
          vr_vldifecr := rw_craplot_II.vlcompcr - rw_craplot_II.vlinfocr;

          -- VERIFICA SE É UMA CONTA MIGRADA
          IF pr_cdcooper <> vr_glbcoop THEN
            vr_dsintegr := vr_dsintegr || ' - CONTAS MIGRADAS';
          END IF;
          OPEN cr_crapbcl(rw_craplot_II.cdbccxlt);
          FETCH cr_crapbcl INTO rw_crapbcl;
          CLOSE cr_crapbcl;          

          -- BUSCA DADOS DE CADASTROS REJEITADOS NA INTEGRAÇÃO
          OPEN cr_craprej_II(pr_cdcooper => pr_cdcooper,
                             pr_dtmvtolt => rw_craplot_II.dtmvtolt,
                             pr_cdagenci => rw_craplot_II.cdagenci,
                             pr_cdbccxlt => rw_craplot_II.cdbccxlt,
                             pr_nrdolote => rw_craplot_II.nrdolote);

          LOOP
            FETCH cr_craprej_II
              INTO rw_craprej_II;

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_craprej_II%NOTFOUND;

            -- VERIFICA CODIGO DA CRITICA
            IF vr_cdcritic <> rw_craprej_II.cdcritic THEN
              vr_cdcritic := rw_craprej_II.cdcritic;

              -- BUSCA DESCRICAO DA CRITICA
              vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

              IF rw_craprej_II.cdcritic IN (454,609,722) THEN

                -- DESCRICAO DA CRITICA PARA RELATORIO
                vr_dscritic := '* ' || vr_dscritic;
              ELSIF rw_craprej_II.cdcritic = 723 THEN -- conta encerrada
                continue;
              END IF;

            END IF;

            -- CONSULTA DE HISTORICOS
            OPEN cr_craphis(pr_cdcooper => rw_craprej_II.cdcooper,
                            pr_cdhistor => rw_craprej_II.cdhistor);

            FETCH cr_craphis
              INTO rw_craphis;

            -- VERIFICA SE HISTORICO EXISTE
            IF cr_craphis%NOTFOUND THEN
              -- FECHAR O CURSOR
              CLOSE cr_craphis;
              vr_dshistor := gene0002.fn_mask(rw_craprej_II.cdhistor, '9999') || '-' || '**************';
            ELSE
              -- FECHAR O CURSOR
              CLOSE cr_craphis;
              vr_dshistor := gene0002.fn_mask(rw_craprej_II.cdhistor, '9999') || '-' || rw_craphis.dshistor;
            END IF;            
            OPEN cr_crapass(rw_craprej_II.cdcooper
                           ,rw_craprej_II.nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            CLOSE cr_crapass;
            
            vr_des_chave_ag := lpad(rw_crapass.cdagenci,3,0);  
            -- montar cabecalho          
            vr_tab_ag(vr_des_chave_ag).cdagenci := rw_crapass.cdagenci;
            vr_tab_ag(vr_des_chave_ag).dtdebito := rw_crapdat.dtmvtopr;
            vr_tab_ag(vr_des_chave_ag).cdbccxlt := rw_craplot_II.cdbccxlt;
            vr_tab_ag(vr_des_chave_ag).dtmvtopg := TO_CHAR(rw_craplot_II.dtmvtolt, 'dd/mm/yyyy');
          
            
            vr_des_chave_det := lpad(rw_crapass.cdagenci,3,0)||lpad(rw_craplot_II.cdbccxlt,5,0)||
                                lpad(rw_craprej_II.cdhistor,5,0)||lpad(to_char(rw_craplot_II.dtmvtolt,'RRRRMMDD'),8,0)||
                                lpad(rw_craplau.nrdconta,8,0)||lpad(rw_craprej_II.nrdocmto,25,0);
                          
            
            -- Armazenar detalhes
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdagenci := rw_crapass.cdagenci;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdhistor := rw_craprej_II.cdhistor;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dshistor := vr_dshistor;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdconta := rw_craprej_II.nrdconta;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dtdaviso := rw_craprej_II.dtdaviso;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nmprimtl := rw_crapass.nmprimtl;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrseqlan := rw_craprej_II.nrseqdig;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).vllanaut := rw_craprej_II.vllanmto;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdocmto := rw_craprej_II.nrdocmto;
            vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dsobserv := nvl(vr_dscritic,' ');
            
            -- Armazenar totais
            vr_des_chave_tdeb := lpad(rw_crapass.cdagenci,3,0)||lpad(rw_craprej_II.cdhistor,5,0);
            vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdagenci := rw_crapass.cdagenci;
            vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdhistor := rw_craprej_II.cdhistor;
            vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).dshistor := vr_dshistor;
            vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).qtdebito := nvl(vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).qtdebito,0)+ 1;
            vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).vldebito := nvl(vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).vldebito,0)+ rw_craprej_II.vllanmto;
            
          END LOOP; -- FINAL LOOP CRAPREJ_II
          CLOSE cr_craprej_II;

        END LOOP; -- FINAL LOOP CRAPREJ
  
        --Buscar agencias
        IF vr_tab_ag.count > 0 THEN
          vr_des_chave_ag := vr_tab_ag.FIRST;
          pc_escreve_xml('<agencia '||
                            ' ag_cdagenci="'||lpad(vr_tab_ag(vr_des_chave_ag).cdagenci,3,'0')||'"'||
                            ' dtdebito="'||to_char(vr_tab_ag(vr_des_chave_ag).dtdebito,'DD/MM/RRRR') ||'"'||
                            ' nmresbcc="'||pc_busca_banco(vr_tab_ag(vr_des_chave_ag).cdbccxlt) ||'"'||
                            ' dtmvtopg="'||vr_tab_ag(vr_des_chave_ag).dtmvtopg||'" >
                            ');
          LOOP
            -- Sair quando nao existir mais agencias
            exit when vr_des_chave_ag is null;            
            -- Montar xml com os detalhes
            IF vr_tab_ag(vr_des_chave_ag).vr_tab_det.count > 0 then
              vr_des_chave_det := vr_tab_ag(vr_des_chave_ag).vr_tab_det.FIRST;
              pc_escreve_xml('<detalhes>'); 
              LOOP
                -- Sair quando a chave atual for null (chegou no final)
                exit when vr_des_chave_det is null;
                -- montar xml das faturas por agencia
                pc_escreve_xml('<fatura>
                                    <fat_cdagenci>'||lpad(vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdagenci,3,'0')||'</fat_cdagenci>
                                    <cdhistor>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdhistor||'</cdhistor>
                                    <dshistor>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dshistor||'</dshistor>
                                    <dtdaviso>'||to_char(vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dtdaviso,'DD/MM/RRRR')||'</dtdaviso>
                                    <nrdconta>'||gene0002.fn_mask(vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdconta, 'z.zzz.zzz.z')||'</nrdconta>
                                    <nmprimtl>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nmprimtl||'</nmprimtl>
                                    <nrseqlan>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrseqlan||'</nrseqlan>
                                    <vllanaut>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).vllanaut||'</vllanaut>
                                    <nrdocmto>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdocmto||'</nrdocmto>
                                    <dsobserv>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dsobserv||'</dsobserv>
                                </fatura>');

                vr_des_chave_det := vr_tab_ag(vr_des_chave_ag).vr_tab_det.NEXT(vr_des_chave_det);
              END LOOP;--FIM DETALHES
              pc_escreve_xml('</detalhes>');
            END IF;                       
            -- Montar xml com os totais por agencia
            IF vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb.count > 0 then
              vr_des_chave_tdeb := vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb.FIRST;
              pc_escreve_xml('<total dtdebito="'||vr_tab_ag(vr_des_chave_ag).dtmvtopg ||'">');

              LOOP
                -- Sair quando a chave atual for null (chegou no final)
                exit when vr_des_chave_tdeb is null;
                -- monta xml total por historico
                pc_escreve_xml('<total_his>
                                    <tot_cdagenci>'||lpad(vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdagenci,3,'0')||'</tot_cdagenci>
                                    <cdhistor>'||vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdhistor||'</cdhistor>                                
                                    <dshistor>'||vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).dshistor||'</dshistor>                                
                                    <qtdebito>'||vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).qtdebito||'</qtdebito>
                                    <vldebito>'||vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).vldebito||'</vldebito>
                                </total_his>');

                vr_des_chave_tdeb := vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb.NEXT(vr_des_chave_tdeb);
              END LOOP;--FIM DETALHES
              pc_escreve_xml('</total>');
            END IF;
            IF vr_des_chave_ag = vr_tab_ag.LAST THEN -- se for ultima agencia, fechar tag
              pc_escreve_xml('</agencia>');
              vr_des_chave_ag := vr_tab_ag.NEXT(vr_des_chave_ag);
            -- se mudar o nro da agencia, fechar tag
            ELSIF vr_tab_ag(vr_des_chave_ag).cdagenci <> vr_tab_ag(vr_tab_ag.NEXT(vr_des_chave_ag)).cdagenci THEN 
              pc_escreve_xml('</agencia>');
              vr_des_chave_ag := vr_tab_ag.NEXT(vr_des_chave_ag);
              pc_escreve_xml('<agencia '||
                            ' ag_cdagenci="'||lpad(vr_tab_ag(vr_des_chave_ag).cdagenci,3,'0')||'"'||
                            ' dtdebito="'||to_char(vr_tab_ag(vr_des_chave_ag).dtdebito,'DD/MM/RRRR') ||'"'||
                            ' nmresbcc="'||pc_busca_banco(vr_tab_ag(vr_des_chave_ag).cdbccxlt) ||'"'||
                            ' dtmvtopg="'||vr_tab_ag(vr_des_chave_ag).dtmvtopg ||'" >
                            ');
            ELSE
              vr_des_chave_ag := vr_tab_ag.NEXT(vr_des_chave_ag);
            END IF;
          END LOOP;              
        END IF; 
        -- FECHA TAG PRINCIPAL DO ARQUIVO XML
        pc_escreve_xml('</raiz>');
        
        -- SOLICITACAO DO RELATORIO
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa
                                    pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                    pr_dsxml     => vr_clobxml,          --> Arquivo XML de dados
                                    pr_dsxmlnode => '/raiz',             --> Nó do XML para iteração
                                    pr_dsjasper  => 'crrl101.jasper',    --> Arquivo de layout do iReport
                                    pr_dsparams  => '',                  --> Array de parametros diversos
                                    pr_dsarqsaid => vr_dsarquiv,         --> Path/Nome do arquivo PDF gerado
                                    pr_flg_gerar => 'N',                 --> Gerar o arquivo na hora*
                                    pr_qtcoluna  => 234,                 --> Qtd colunas do relatório (80,132,234)
                                    pr_sqcabrel  => 1,                   --> Indicado de seq do cabrel
                                    pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)*
                                    pr_nmformul  => '234dh',             --> Nome do formulário para impressão
                                    pr_nrcopias  => 1,                   --> Qtd de cópias
                                    pr_flappend  => 'S',                 --> Indica que a solicitação irá incrementar o arquivo
                                    pr_des_erro  => vr_dscritic);        --> Saída com erro

        -- VERIFICA SE OCORREU UMA CRITICA
        IF vr_dscritic IS NOT NULL THEN
          --Chamado 709894
          vr_dsparam := 'Dtmvtolt='||rw_crapdat.dtmvtolt
                      ||',Dsarquiv='||vr_dsarquiv
                      ||',Cdprogra='||vr_cdprogra;
          RAISE vr_exc_saida;
        END IF;

        -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);

      END;

    END pc_gera_relatorio;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop;
    FETCH cr_crapcop
      INTO rw_crapcop;
    -- SE NÃO ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      -- FECHAR O CURSOR POIS HAVERÁ RAISE
      CLOSE cr_crapcop;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapcop;
    END IF;

    -- LEITURA DO CALENDÁRIO DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE btch0001.cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    
    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- SE A VARIAVEL DE ERRO É <> 0
    IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;

    vr_dsparame := NULL;

    -- BUSCAR A DATA DO PERIODO NO PARAMETRO
    OPEN  cr_dsparame(vr_cdprogra);
    FETCH cr_dsparame INTO vr_dsparame;
    CLOSE cr_dsparame;

    -- VERIFICA SE DEVE RODAR OU NAO
    IF INSTR(UPPER(vr_dsparame), vr_cdprogra) = 0 THEN
      --SE O PROGRAMA NÃO ESTIVER NO PARAMETRO, DEVE FINALIZAR O PROGRMA SEM GERAR OS RELATORIOS
      RAISE vr_exc_fimprg;
    END IF;

    -- ARQUIVO P/ GERACAO DO RELATORIO
    vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                         pr_cdcooper => pr_cdcooper) || vr_dsarquiv;
    
    -- ABRE O CURSOR DE LOTE E FAZ A ATRIBUICAO DO CODIGO DO LOTE CONSULTADO
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,          -- CODIGO DA COOPERATIVA
                    pr_dtmvtopr => rw_crapdat.dtmvtopr); -- DATA PROXIMO DIA UTIL

    FETCH cr_craplot
      INTO rw_craplot;

    -- SE NÃO ENCONTRAR
    IF cr_craplot%NOTFOUND THEN
      -- FECHAR O CURSOR
      CLOSE cr_craplot;
      -- CODIGO DE LOTE DEFAULT
      vr_nrdolot1 := 6500;
    ELSE
      -- FECHAR O CURSOR
      CLOSE cr_craplot;
      -- CODIGO DE LOTE DEFAULT
      vr_nrdolot1 := rw_craplot.nrdolote;
    END IF;

	  -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');

    -- ABRE O CURSOR REFERENTE AOS LANCAMENTOS AUTOMATICOS
    OPEN cr_craplau(pr_cdcooper => pr_cdcooper,          -- CODIGO DA COOPERATIVA
                    pr_dtmvtopr => rw_crapdat.dtmvtopr); -- DATA PROXIMO DIA UTIL

    LOOP
      FETCH cr_craplau
        INTO rw_craplau;

      -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
      EXIT WHEN cr_craplau%NOTFOUND;

      vr_flgentra := 0;
      vr_ctamigra := 0;
      vr_cdcritic := 0;
      vr_auxcdcri := 0;
      vr_nrdolote := vr_nrdolot1;
      vr_cdcooper := pr_cdcooper;
     vr_cdagenci := rw_craplau.cdagenci;
      vr_nrdconta := rw_craplau.nrdconta;

	    -- Condicao para verificar se permite incluir as linhas parametrizadas
      IF INSTR(',' || vr_dsctajud || ',',',' || vr_nrdconta || ',') > 0 THEN
        IF rw_craplau.cdhistor = 38 THEN
		      CONTINUE;        
		    END IF;
      END IF; 

      -- VERIFICA CODIGO DO BANCO / CAIXA
      IF rw_craplau.cdbccxlt = 911 THEN
        vr_cdbccxlt := 11;
      ELSE
        vr_cdbccxlt := rw_craplau.cdbccxlt;
      END IF;

      -- VERIFICA CODIGO DO BANCO / CAIXA
      IF rw_craplau.cdbccxlt = 911 AND rw_craplau.cdhistor = 40 THEN
        vr_cdbccxlt := 100;
      END IF;

      OPEN cr_craptco(pr_cdcooper => pr_cdcooper,          -- CODIGO DA COOPERATIVA
                      pr_nrdconta => rw_craplau.nrdconta); -- NUMERO DA CONTA

      FETCH cr_craptco
        INTO rw_craptco;

      -- SE NÃO ENCONTRAR
      IF cr_craptco%NOTFOUND THEN
        -- FECHAR O CURSOR
        CLOSE cr_craptco;
      ELSE
        -- FECHAR O CURSOR
        CLOSE cr_craptco;

        -- CURSOR DE HISTÓRICOS
        OPEN cr_craphis(pr_cdcooper => pr_cdcooper,          -- CODIGO DA COOPERATIVA
                        pr_cdhistor => rw_craplau.cdhistor); -- CODIGO DO HISTORICO
        FETCH cr_craphis
          INTO rw_craphis;

        -- SE NÃO ENCONTRAR
        IF cr_craphis%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_craphis;
        ELSE
          -- FECHAR O CURSOR
          CLOSE cr_craphis;

          -- VERIFICA LOTE
          IF vr_craplot = 0 THEN
            vr_nrdolot2 := 6500;
          ELSE
            vr_nrdolot2 := rw_craplot.nrdolote;
          END IF;

          vr_cdcooper := rw_craptco.cdcooper;
          vr_cdcopmig := rw_craptco.cdcooper;
          vr_nrdconta := rw_craptco.nrdconta;
          vr_cdagenci := rw_craptco.cdagenci;
          vr_ctamigra := 1;
          vr_migracao := 1;
          vr_nrdolote := vr_nrdolot2;

        END IF;

      END IF;

      -- FIRST-OF
      IF rw_craplau.seqlauto = 1 THEN
        vr_nrdolote := vr_nrdolote + 1;
      END IF;

      -- BUSCA REGISTRO REFERENTES A LOTES
      OPEN cr_craplot_II(pr_cdcooper => vr_cdcooper,
                         pr_dtmvtolt => rw_crapdat.dtmvtopr,
                         pr_cdagenci => vr_cdagenci,
                         pr_cdbccxlt => vr_cdbccxlt,
                         pr_nrdolote => vr_nrdolote);

      FETCH cr_craplot_II
        INTO rw_craplot_II;

      -- SE NÃO ENCONTRAR
      IF cr_craplot_II%NOTFOUND THEN
        -- FECHAR O CURSOR
        CLOSE cr_craplot_II;

        -- CASO NAO ENCONTRE O LOTE, INSERE
        BEGIN

          INSERT INTO craplot
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             cdbccxpg,
             tplotmov,
             nrseqdig,
             cdcooper)
          VALUES
            (rw_crapdat.dtmvtopr,
             vr_cdagenci,
             vr_cdbccxlt,
             vr_nrdolote,
             11,
             1,
             0,
             vr_cdcooper)
           RETURNING craplot.dtmvtolt,
                     craplot.cdagenci,
                     craplot.cdbccxlt,
                     craplot.nrdolote,
                     craplot.cdbccxpg,
                     craplot.tplotmov,
                     craplot.cdcooper,
                     craplot.nrseqdig,
                     craplot.rowid
           INTO      rw_craplot_II.dtmvtolt,
                     rw_craplot_II.cdagenci,
                     rw_craplot_II.cdbccxlt,
                     rw_craplot_II.nrdolote,
                     rw_craplot_II.cdbccxpg,
                     rw_craplot_II.tplotmov,
                     rw_craplot_II.cdcooper,
                     rw_craplot_II.nrseqdig,
                     rw_craplot_II.rowid;

          -- VERIFICA SE HOUVE PROBLEMA NA INSERCAO DE REGISTROS
        EXCEPTION
          WHEN OTHERS THEN
            -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
            vr_dscritic := 'Problema ao inserir na tabela CRAPLOT: ' || sqlerrm;
            --Chamado 709894
            vr_dsparam := 'Dtmvtolt='||rw_crapdat.dtmvtopr
                        ||',Cdagenci='||vr_cdagenci
                        ||',Cdbccxlt='||vr_cdbccxlt
                        ||',Nrdolote='||vr_nrdolote;
            RAISE vr_exc_saida;
        END;
      ELSE
        -- FECHAR O CURSOR
        CLOSE cr_craplot_II;
      END IF;

      -- VERIFICA SE É UMA CONTA MIGRADA
      IF vr_ctamigra = 1 THEN
        vr_nrdolot2 := vr_nrdolote;
      ELSE
        vr_nrdolot1 := vr_nrdolote;
      END IF;

      -- IRA FICAR EM LOOP ATE ENCONTRAR CRITICA
      LOOP
        -- CONSULTA DE COOPERADOS
        OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                        pr_nrdconta => vr_nrdconta);
        FETCH cr_crapass
          INTO rw_crapass;

        --Chamado 709894
        vr_dsparam := 'Nrdconta='||vr_nrdconta;

        -- SE NÃO ENCONTRAR
        IF cr_crapass%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_crapass;

          -- ATRIBUI O CODIGO DA CRITICA
          vr_cdcritic := 9;                                                     -- ASSOCIADO NAO CADASTRADO
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA

        -- VERIFICA DATA DE ELIMINACAO
        ELSIF rw_crapass.dtelimin IS NOT NULL THEN

          -- FECHAR O CURSOR
          CLOSE cr_crapass;

          -- ATRIBUI O CODIGO DA CRITICA
          vr_cdcritic := 410;                                                   -- ASSOCIADO EXCLUIDO
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA

        -- VERIFICA SITUACAO DO TITULAR
        ELSIF rw_crapass.cdsitdtl IN (5,6,7,8) THEN

          -- FECHAR O CURSOR
          CLOSE cr_crapass;

          -- ATRIBUI O CODIGO DA CRITICA
          vr_cdcritic := 695;                                                   -- ATENCAO! HOUVE PREJUIZO NESSA CONTA
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA

        -- SITUACAO DO TITULAR
        ELSIF rw_crapass.cdsitdtl IN (2,4,6,8) THEN

          -- FECHAR O CURSOR
          CLOSE cr_crapass;

          -- CONSULTA DE TRANSFERENCIAS E DUPLICACAO DE MATRICULAS
          OPEN cr_craptrf(pr_cdcooper => vr_cdcooper,          -- CODIGO DA COOPERATIVA
                          pr_nrdconta => rw_crapass.nrdconta); -- NUMERO DA CONTA

          FETCH cr_craptrf
            INTO rw_craptrf;

          -- SE NÃO ENCONTRAR
          IF cr_craptrf%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_craptrf;

            -- ATRIBUI O CODIGO DA CRITICA
            vr_cdcritic := 95;                                                    -- TITULAR DA CONTA BLOQUEADO
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
          ELSE
            vr_nrdconta := rw_craptrf.nrsconta; -- NUMERO DA CONTA
            CONTINUE;                           -- VAI PARA PROXIMO REGISTRO
          END IF;
        ELSE
          -- FECHAR O CURSOR
          CLOSE cr_crapass;
        END IF;

        -- SAI DO LOOP
        EXIT;

      END LOOP; -- FINAL DO LOOP

      -- LEITURA DE SALDO EM DEPOSITO AVISTA
      OPEN cr_crapsld(pr_cdcooper => vr_cdcooper,  -- CODIGO DA COOPERATIVA
                      pr_nrdconta => vr_nrdconta); -- NUMERO DA CONTA
      FETCH cr_crapsld
        INTO rw_crapsld;

      --Chamado 709894
      vr_dsparam := 'Nrdconta='||vr_nrdconta;

      -- SE NÃO ENCONTRAR
      IF cr_crapsld%NOTFOUND THEN

        -- FECHAR O CURSOR
        CLOSE cr_crapsld;

        -- ATRIBUI O CODIGO DA CRITICA
        vr_cdcritic := 10;                                                    -- ASSOCIADO SEM REGISTRO DE SALDO!!! - ERRO DO SISTEMA!!
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
      ELSE
        -- FECHAR O CURSOR
        CLOSE cr_crapsld;
      END IF;

      -- VERIFICA CRITICA
      IF vr_cdcritic = 0 THEN

        OPEN cr_craphis_I(pr_cdcooper => vr_cdcooper,          -- CODIGO DA COOPERATIVA
                          pr_cdhistor => rw_craplau.cdhistor); -- CODIGO DO HISTORICO
        FETCH cr_craphis_I
          INTO rw_craphis_I;

          --Chamado 709894
          vr_dsparam := 'Cdhistor='||rw_craplau.cdhistor;

        IF cr_craphis_I%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_craphis_I;

          -- ATRIBUI O CODIGO DA CRITICA
          vr_cdcritic := 83; -- HISTORICO DESCONHECIDO NO LANCAMENTO
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        ELSIF rw_craphis_I.indebcta <> 1 THEN
          -- FECHAR O CURSOR
          CLOSE cr_craphis_I;

          -- ATRIBUI O CODIGO DA CRITICA
          vr_cdcritic := 94;                                                    -- HISTORICO NAO PERMITIDO NESTE TIPO DE LOTE
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA        
        ELSE
          -- FECHA CURSOR
          CLOSE cr_craphis_I;
        END IF;

      END IF;

      -- ATRIBUICAO DE NUMERO DE DOCUMENTO
      vr_nrdocmto := rw_craplau.nrdocmto;

      -- TRATAMENTO DÉBITO FÁCIL
      IF vr_cdcritic = 0 AND rw_craplau.flgblqdb = 1 THEN

        -- GERAR REGISTROS NA CRAPNDB PARA DEVOLUCAO DE DEBITOS AUTOMATICOS
        CONV0001.pc_gerandb(pr_cdcooper => vr_cdcooper         -- CÓDIGO DA COOPERATIVA
                             ,pr_cdhistor => rw_craplau.cdhistor -- CÓDIGO DO HISTÓRICO
                             ,pr_nrdconta => rw_craplau.nrdconta -- NUMERO DA CONTA
                             ,pr_cdrefere => rw_crapatr.cdrefere -- CÓDIGO DE REFERÊNCIA
                             ,pr_vllanaut => rw_craplau.vllanaut -- VALOR LANCAMENTO
                             ,pr_cdseqtel => rw_craplau.cdseqtel -- CÓDIGO SEQUENCIAL
                             ,pr_nrdocmto => rw_craplau.nrdocmto -- NÚMERO DO DOCUMENTO
                             ,pr_cdagesic => rw_crapcop.cdagesic -- AGÊNCIA SICREDI
                             ,pr_nrctacns => rw_crapass.nrctacns -- CONTA DO CONSÓRCIO
                             ,pr_cdagenci => rw_crapass.cdagenci -- CODIGO DO PA
                             ,pr_cdempres => rw_craplau.cdempres -- CODIGO SICREDI
                             ,pr_idlancto => rw_craplau.idlancto -- CÓDIGO DO LANCAMENTO
                             ,pr_codcriti => vr_auxcdcri         -- CÓDIGO DO ERRO
                             ,pr_cdcritic => vr_cdcritic         -- CÓDIGO DO ERRO
                             ,pr_dscritic => vr_dscritic);       -- DESCRICAO DO ERRO

          -- VERIFICA SE HOUVE ERRO NA PROCEDURE PC_GERANDB
         IF vr_cdcritic > 0 THEN
          --Chamado 709894
          vr_dsparam := 'Cdhistor='||rw_craplau.cdhistor
                      ||',Nrdconta='||rw_craplau.nrdconta
                      ||',Cdrefere='||rw_crapatr.cdrefere
                      ||',Vllanaut='||rw_craplau.vllanaut
                      ||',Cdseqtel='||rw_craplau.cdseqtel
                      ||',Nrdocmto='||rw_craplau.nrdocmto
                      ||',Cdagesic='||rw_crapcop.cdagesic
                      ||',Nrctacns='||rw_crapass.nrctacns
                      ||',Cdempres='||rw_craplau.cdempres;
            RAISE vr_exc_saida;
         END IF;
        
        vr_cdcritic := 964;                                                   -- Lancamento bloqueado
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
        vr_flgentra := 0;      
      END IF;
      
      
      -- VERIFICA SE EXISTE CRITICA
      IF vr_cdcritic = 0 THEN

        LOOP
          -- CONSULTA DE LANCEMENTOS
          OPEN cr_craplcm(pr_cdcooper => vr_cdcooper,            -- CODIGO DA COOPERATIVA
                          pr_dtmvtopr => rw_crapdat.dtmvtopr,    -- DATA DE MOVIMENTACAO
                          pr_cdagenci => rw_craplot_II.cdagenci, -- CODIGO DO PA
                          pr_cdbccxlt => rw_craplot_II.cdbccxlt, -- BANCO / CAIXA
                          pr_nrdolote => rw_craplot_II.nrdolote, -- NUMERO DO LOTE
                          pr_nrdctabb => vr_nrdconta,            -- NUMERO DA CONTA
                          pr_nrdocmto => vr_nrdocmto);           -- NUMERO DO DOCUMENTO

          FETCH cr_craplcm
            INTO rw_craplcm;

          IF cr_craplcm%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_craplcm;
            -- SAI DO LOOP
            EXIT;
          ELSE
            -- FECHAR O CURSOR
            CLOSE cr_craplcm;
            -- PESQUISA DE DOCUMENTO INCREMENTADA CASO NÃO EXISTA REGISTROS
            vr_nrdocmto := vr_nrdocmto + 100000000;
            -- VAI PARA PROXIMO REGISTRO
            CONTINUE;
          END IF;
        END LOOP;

      END IF;
      
      vr_gerandb := 1;
      
      -- VERIFICA SE NAO OCORREU CRITICA E SE O COOPERADO FOI DEMITIDO
      IF vr_cdcritic = 0 AND rw_crapass.dtdemiss IS NOT NULL THEN

        vr_cdcritic := 454;                                                   -- COOPERADO FOI DEMITIDO
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
        vr_flgentra := 1;

      END IF;

      -- VERIFICA SE CRITICA NÃO EXISTE E DATA RISCO LIQ.
      IF vr_cdcritic = 0 AND rw_crapsld.dtdsdclq IS NOT NULL THEN

        vr_cdcritic := 609;                                                   -- CRLQ
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
        vr_flgentra := 1;

      END IF;

      -- VERIFICA SE CRITICA NÃO EXISTE E SITUACAO DA CONTA
      IF vr_cdcritic = 0 AND rw_crapass.cdsitdct IN (2,3,9) THEN

        vr_cdcritic := 723;                                                   -- CONTA ENCERRADA
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
        vr_flgentra := 1;

      END IF;

      -- VERIFICA SE CRITICA NÃO EXISTE E QTD. DIAS SALDO NEGATIVO
      IF (vr_cdcritic = 0 AND rw_crapsld.qtddsdev > 0) THEN

        vr_cdcritic := 722;                                                   -- SALDO NEGATIVO
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
          vr_flgentra := 1;

      END IF;

      -- VERIFICA SE EXISTE CRITICA
      IF vr_cdcritic = 0 THEN

        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,          -- CODIGO DA COOPERATIVA
                        pr_nrdconta => rw_craplau.nrdconta); -- NUMERO DA CONTA

        FETCH cr_crapepr
          INTO rw_crapepr;

        --Chamado 709894
        vr_dsparam := 'Nrdconta='||rw_craplau.nrdconta;

        IF cr_crapepr%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_crapepr;
        ELSE
          -- FECHAR O CURSOR
          CLOSE cr_crapepr;

          vr_cdcritic := 801;                                                   -- PREJ
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
          vr_flgentra := 1;

        END IF;
      END IF;

      -- VERIFICA SE EXISTE CRITICA
      IF vr_cdcritic > 0 THEN

        -- VARIAVEIS AUXILIARES DE ERRO, PARA NAO PERDER INFORMACAO ATE O MOMENTO
        vr_auxcdcri := vr_cdcritic;
        vr_auxdscri := vr_dscritic;

        -- ROTINA RESPONSÁVEL POR RETORNAR A CONTA INTEGRAÇÃO COM DÍGITO CONVERTIDO(FORMATA CONTA INTEGRAÇÃO)
        GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_craplau.nrdctabb,
                                       pr_dscalcul => vr_dsdctitg,
                                       pr_stsnrcal => vr_stsnrcal,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);

        -- VERIFICA SE HOUVE CRITICA NA FORMATACAO DA CONTA INTEGRACAO
        IF vr_cdcritic > 0 THEN
          RAISE vr_exc_saida;
        END IF;

        -- VARIAVEIS AUXILIARES DE ERRO
        vr_cdcritic := vr_auxcdcri;
        vr_dscritic := vr_auxdscri;

        BEGIN
          INSERT INTO craprej
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             cdhistor,
             nrdconta,
             nrdctabb,
             nrdctitg,
             nrseqdig,
             nrdocmto,
             vllanmto,
             dtdaviso,
             cdcritic,
             tpintegr,
             cdcooper)
          VALUES
            (rw_craplot_II.dtmvtolt,
             rw_craplot_II.cdagenci,
             rw_craplot_II.cdbccxlt,
             rw_craplot_II.nrdolote,
             rw_craplot_II.tplotmov,
             rw_craplau.cdhistor,
             vr_nrdconta,
             rw_craplau.nrdctabb,
             vr_dsdctitg,
             rw_craplau.nrseqdig,
             rw_craplau.nrdocmto,
             rw_craplau.vllanaut,
             rw_craplau.dtmvtolt, -- DATA ORIGINAL
             NVL(vr_cdcritic, 0),
             12,
             vr_cdcooper);

        -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPREJ: ' || sqlerrm;
            --Chamado 709894
            vr_dsparam := 'Dtmvtolt='||rw_craplot_II.dtmvtolt
                        ||',Cdagenci='||rw_craplot_II.cdagenci
                        ||',Cdbccxlt='||rw_craplot_II.cdbccxlt
                        ||',Nrdolote='||rw_craplot_II.nrdolote
                        ||',Tplotmov='||rw_craplot_II.tplotmov
                        ||',Cdhistor='||rw_craplau.cdhistor
                        ||',Nrdconta='||vr_nrdconta
                        ||',Nrdctabb='||rw_craplau.nrdctabb
                        ||',Dsdctitg='||vr_dsdctitg
                        ||',Nrseqdig='||rw_craplau.nrseqdig
                        ||',Nrdocmto='||rw_craplau.nrdocmto
                        ||',Vllanaut='||rw_craplau.vllanaut
                        ||',Dtdaviso='||rw_craplau.dtmvtolt;
            RAISE vr_exc_saida;
        END;

      ELSE
        vr_flgentra := 1;
      END IF;

      IF vr_flgentra = 1 AND vr_gerandb = 1 THEN

        BEGIN

          INSERT INTO craplcm
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdctabb,
             nrdctitg,
             nrdocmto,
             cdhistor,
             vllanmto,
             nrseqdig,
             cdcooper,
             cdpesqbb)
          VALUES
            (rw_craplot_II.dtmvtolt,
             rw_craplot_II.cdagenci,
             rw_craplot_II.cdbccxlt,
             rw_craplot_II.nrdolote,
             vr_nrdconta,
             rw_craplau.nrdctabb,
             gene0002.fn_mask(rw_craplau.nrdctabb, '99999999'),
             vr_nrdocmto,
             rw_craplau.cdhistor,
             rw_craplau.vllanaut,
             nvl(rw_craplot_II.nrseqdig,0) + 1,
             vr_cdcooper,
             'Lote ' || TO_CHAR(rw_craplau.dtmvtolt, 'dd') || '/' ||
             TO_CHAR(rw_craplau.dtmvtolt, 'mm') || '-' ||
             gene0002.fn_mask(vr_cdagenci, '999') || '-' ||
             gene0002.fn_mask(rw_craplau.cdbccxlt, '999') || '-' ||
             gene0002.fn_mask(rw_craplau.nrdolote, '999999') || '-' ||
             gene0002.fn_mask(rw_craplau.nrseqdig, '99999') || '-' ||
             rw_craplau.nrdocmto);

          -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPLCM: ' || sqlerrm;
            --Chamado 709894
            vr_dsparam := 'Dtmvtolt='||rw_craplot_II.dtmvtolt
                        ||',Cdagenci='||rw_craplot_II.cdagenci
                        ||',Cdbccxlt='||rw_craplot_II.cdbccxlt
                        ||',Nrdolote='||rw_craplot_II.nrdolote
                        ||',Cdhistor='||rw_craplau.cdhistor
                        ||',Nrdconta='||vr_nrdconta
                        ||',Nrdctabb='||rw_craplau.nrdctabb
                        ||',Nrseqdig='||rw_craplot_II.nrseqdig
                        ||',Nrdocmto='||vr_nrdocmto
                        ||',Vllanaut='||rw_craplau.vllanaut
                        ||',Dtdaviso='||rw_craplau.dtmvtolt;
            RAISE vr_exc_saida;
        END;

        -- ATUALIZACAO DE REGISTROS DE LOTES

        BEGIN
          UPDATE craplot
             SET qtcompln = nvl(qtcompln,0) + 1,
                 vlcompdb = nvl(vlcompdb,0) + nvl(rw_craplau.vllanaut,0),
                 qtinfoln = nvl(qtinfoln,0) + 1,
                 vlinfodb = nvl(vlinfodb,0) + nvl(rw_craplau.vllanaut,0),
                 nrseqdig = nvl(nrseqdig,0) + 1
           WHERE craplot.rowid = rw_craplot_II.rowid;

          -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLOT: ' || sqlerrm;
            --Chamado 709894
            vr_dsparam := 'Rowid='||rw_craplot_II.rowid;
            RAISE vr_exc_saida;
        END;

        -- VERIFICA SE CRITICA É REFERENTE A MIGRAÇÃO
        IF rw_craplau.cdcritic <> 951 THEN

          BEGIN
            UPDATE craplau
               SET craplau.cdcritic = NVL(vr_cdcritic, 0)
             WHERE craplau.rowid = rw_craplau.rowid;

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' || sqlerrm;
              --Chamado 709894
              vr_dsparam := 'Rowid='||rw_craplau.rowid;
              RAISE vr_exc_saida;
          END;
        END IF;

        -- VERIFICA NUMERO DO CARTAO
        IF NVL(rw_craplau.nrcrcard,0) = 0 THEN
          vr_nrcrcard := rw_craplot_II.nrdolote; --rw_craplcm.nrdolote;
        ELSE
          vr_nrcrcard := rw_craplau.nrcrcard;
        END IF;

        BEGIN

          -- ATUALIZA REGISTROS DE LANCAMENTOS AUTOMATICOS
          UPDATE craplau
             SET insitlau = 2,
                 nrcrcard = NVL(vr_nrcrcard, 0),
                 nrseqlan = rw_craplot_II.nrseqdig + 1,
                 dtdebito = rw_crapdat.dtmvtopr
           WHERE craplau.rowid = rw_craplau.rowid;

          -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' || sqlerrm;
            --Chamado 709894
            vr_dsparam := 'Rowid='||rw_craplau.rowid;
            RAISE vr_exc_saida;
        END;

      ELSE
        -- VERIFICA CODIGO DO HISTORICO
        IF rw_craplau.cdhistor NOT IN (1230,1231,1232,1233,1234,1019) AND
           rw_craphis_I.inautori <> 1 THEN

          -- VERIFICA NUMERO DO CARTAO
          IF NVL(rw_craplau.nrcrcard,0) = 0 THEN
            vr_nrcrcard := rw_craplot_II.nrdolote;
          ELSE
            vr_nrcrcard := rw_craplau.nrcrcard;
          END IF;

          BEGIN

            -- ATUALIZA REGISTROS DE LANCAMENTOS AUTOMATICOS
            UPDATE craplau
               SET insitlau = 3,
                   dtdebito = rw_crapdat.dtmvtopr,
                   nrcrcard = NVL(vr_nrcrcard, 0)
             WHERE craplau.rowid = rw_craplau.rowid;

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' || sqlerrm;
              --Chamado 709894
              vr_dsparam := 'Rowid='||rw_craplau.rowid;
              RAISE vr_exc_saida;
          END;

          -- VERIFICA SE CRITICA É REFERENTE A MIGRAÇÃO
          IF rw_craplau.cdcritic <> 951 THEN

            BEGIN

              UPDATE craplau
                 SET craplau.cdcritic = NVL(vr_cdcritic, 0)
               WHERE craplau.rowid = rw_craplau.rowid;

              -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' || sqlerrm;
                --Chamado 709894
                vr_dsparam := 'Rowid='||rw_craplau.rowid;
                RAISE vr_exc_saida;
            END;

          END IF;
        ELSE
          IF vr_cdcritic IN (447,453,964,967) THEN          
            BEGIN

              -- ATUALIZA REGISTROS DE LANCAMENTOS AUTOMATICOS
              UPDATE craplau
                 SET insitlau = 3,
                     dtdebito = rw_crapdat.dtmvtopr,
                     nrcrcard = NVL(vr_nrcrcard, 0)
               WHERE craplau.rowid = rw_craplau.rowid;

              -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' || sqlerrm;
                --Chamado 709894
                vr_dsparam := 'Rowid='||rw_craplau.rowid;
                RAISE vr_exc_saida;
            END;

            -- VERIFICA SE CRITICA É REFERENTE A MIGRAÇÃO
            IF rw_craplau.cdcritic <> 951 THEN

              BEGIN
                UPDATE craplau
                   SET craplau.cdcritic = NVL(vr_cdcritic, 0)
                 WHERE craplau.rowid = rw_craplau.rowid;

                -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' || sqlerrm;
                  --Chamado 709894
                  vr_dsparam := 'Rowid='||rw_craplau.rowid;
                  RAISE vr_exc_saida;
              END;
            END IF;          
          END IF;
        END IF;
      END IF;
      
      IF vr_flgentra = 1 THEN

        -- BUSCA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
        OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => vr_nrdconta,
                        pr_cdhistor => rw_craplau.cdhistor,
                        pr_nrcrcard => rw_craplau.nrdocmto);

        FETCH cr_crapatr
          INTO rw_crapatr;

        -- SE NAO ENCONTRAR REGISTROS
        IF cr_crapatr%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_crapatr;
          vr_flagatr := 0;
        ELSE
          -- FECHAR O CURSOR
          CLOSE cr_crapatr;
          vr_flagatr := 1;
        END IF;
      END IF;

      IF vr_flagatr  = 1 AND  -- Se encontrar Autorização de Débito
				 vr_flgentra = 1 AND  -- e se condição de criação da craplcm for atingida
				 vr_gerandb  = 1 THEN -- então atualiza data do último débito.
        -- VERIFICA DATA DO ULTIMO DEBITO
        IF NVL(to_char(rw_crapatr.dtultdeb,'MMYYYY'),'0') <> to_char(rw_crapdat.dtmvtopr,'MMYYYY') THEN

          BEGIN
            -- ATUALIZA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
            UPDATE crapatr
               SET dtultdeb = rw_crapdat.dtmvtopr -- ATUALIZA DATA DO ULTIMO DEBITO
             WHERE ROWID = rw_crapatr.rowid;

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao atualizar registro na tabela CRAPATR: ' || sqlerrm;
              --Chamado 709894
              vr_dsparam := 'Rowid='||rw_crapatr.rowid;
              RAISE vr_exc_saida;
          END;
        END IF;
      END IF;

      -- CONSULTA CADASTROS REJEITADOS NA INTEGRACAO
      OPEN cr_craprej(pr_cdcooper => vr_cdcooper,
                      pr_dtmvtolt => rw_craplot_II.dtmvtolt,
                      pr_cdagenci => rw_craplot_II.cdagenci,
                      pr_cdbccxlt => rw_craplot_II.cdbccxlt,
                      pr_nrdolote => rw_craplot_II.nrdolote);

      FETCH cr_craprej
        INTO rw_craprej;

      -- VERIFICA SE EXISTE REGISTRO
      IF cr_craprej%NOTFOUND THEN
        -- FECHAR O CURSOR
        CLOSE cr_craprej;

        BEGIN
          -- CRIACAO DO REGISTRO
          INSERT INTO craprej
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             cdpesqbb,
             dshistor,
             tplotmov,
             cdcooper)
          VALUES
            (rw_craplot_II.dtmvtolt,
             rw_craplot_II.cdagenci,
             rw_craplot_II.cdbccxlt,
             rw_craplot_II.nrdolote,
             'CRPS123',
             'CONTROLE',
             123,
             vr_cdcooper);

          -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPREJ: ' || sqlerrm;
            --Chamado 709894
            vr_dsparam := 'Dtmvtolt='||rw_craplot_II.dtmvtolt
                        ||',Cdagenci='||rw_craplot_II.cdagenci
                        ||',Cdbccxlt='||rw_craplot_II.cdbccxlt
                        ||',Nrdolote='||rw_craplot_II.nrdolote;
            RAISE vr_exc_saida;
        END;

      ELSE
        -- FECHAR O CURSOR
        CLOSE cr_craprej;
      END IF;

    END LOOP; -- FIM DA LEITURA DOS LANCAMENTOS AUTOMATICOS

    -- FUNCAO P/ CRIAR O RELATORIO DA INTEGRACAO
    pc_gera_relatorio(pr_cdcooper => pr_cdcooper);

    -- Incluir nome do módulo logado - Chamado 709894
    GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action =>  null); 

    -- SE HOUVE CONTAS MIGRADAS INCLUI AS CONTAS NO RELATORIO
    IF vr_migracao = 1 THEN

      pc_gera_relatorio(pr_cdcooper => vr_cdcopmig);

    END IF;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- SALVAR INFORMAÇÕES ATUALIZADAS
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN

      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      --Geração de log de erro - Chamado 709894
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' ||vr_dscritic ||
                                                   '. Cdcooper=' || pr_cdcooper ||
                             ','||vr_dsparam;

      --Geração de log de erro - Chamado 709894
      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => NULL,
                             pr_idprglog      => vr_idprglog);

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- EFETUAR COMMIT
     COMMIT;
    WHEN vr_exc_saida THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic||vr_dsparam;

      --Geração de log de erro - Chamado 709894
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' ||vr_dscritic ||
                             '. Cdcooper=' || pr_cdcooper ||
                             ','||vr_dsparam;

      --Geração de log de erro - Chamado 709894
      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => NULL,
                             pr_idprglog      => vr_idprglog);

      -- EFETUAR ROLLBACK
      ROLLBACK;
    WHEN OTHERS THEN
      -- EFETUAR RETORNO DO ERRO NÃO TRATADO
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      --Geração de log de erro - Chamado 709894
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' ||pr_dscritic ||
                             '. Cdcooper=' || pr_cdcooper ||
                             ' ,Flgresta=' || pr_flgresta ||
                             ' ,Stprogra=' || pr_stprogra ||
                             ' ,Infimsol=' || pr_infimsol ;

      --Geração de log de erro - Chamado 709894
      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => NULL,
                             pr_idprglog      => vr_idprglog);

      --Inclusão na tabela de erros Oracle - Chamado 709894
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => pr_dscritic );



      -- EFETUAR ROLLBACK
      ROLLBACK;
  END;

END pc_crps123;
/
