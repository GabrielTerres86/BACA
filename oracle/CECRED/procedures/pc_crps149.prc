CREATE OR REPLACE PROCEDURE CECRED.pc_crps149(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                             ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS149 (Antigo Fontes/crps149.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96.                       Ultima atualizacao: 31/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de taxa de contrato de emprestimo.

   Alteracoes: 26/08/96 - Alterado para nao gerar aviso para os associados que
                          tenham tipo de conta igual a 5 ou 6 (Edson).

               05/11/96 - Alterado para creditar o valor do novo emprestimo e
                          debitar as liquidacoes de contratos antigos na conta-
                          corrente (Edson).

               19/11/96 - Alterado para descontar o valor provisionado no
                          cheque salario na liquidacao do emprestimo (Edson).

               28/05/97 - Alterado para verificar se deve ou nao cobrar
                          tarifa e se deve creditar o valor liquido em uma
                          conta especial (Edson).

               26/06/97 - Nao emitir aviso de debito da taxa de empr. (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               16/03/98 - Mudanca do historico 108 para 282 (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               11/08/98 - Alterado para incluir a secao para extrato no 
                          craprej (Edson).
                          
               10/09/98 - Tratar tipo de conta 7 (Deborah).

               19/01/1999 - Cobranca do IOF (Deborah).

               02/06/1999 - Tratar CPMF (Deborah).
                            O programa nao fara mais a transferencia para a
                            conta administrativa e nem o debito na conta
                            original, portanto, nao se faz necessario cal-
                            cular o CPMF para encontrar o valor do liquido do
                            emprestimo. Ainda assim, foi alterado para ficar 
                            compativel com a nova edicao no CPMF. 

               01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner). 
               
               06/08/2001 - Tratar prejuizo de conta corrente (Margarete).

               20/12/2002 - Tratar linhas de credito com tarifa especial.
                            Implementado valor de isencao na tabela (Deborah).
                            
               08/01/2003 - Alterar pesquisa de taxas de emprestimo, devido a
                            inclusao de nova faixa (Junior).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).

               11/06/2004 - Se credito for bloqueado, parte referente a 
                            liquidacao (SALDO + CPMF) devera ser  feita com
                            novo historido(Liberado)(Mirtes)
     
               28/06/2004 - Prever Liquidacao com valor Emprestimo Parcial
                            (Mirtes)

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, craprej, craplem e crapdpb (Diego).
                            
               10/12/2005 - Atualizar craprej.nrdctitg (Magui).             
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               23/02/2006 - Tratar linha de credito que NAO tem credito em
                            conta-corrente do Associado (Edson).
               08/03/2006 - Incluida cooperativa 1 (linha de credito que nao
                            tem credito em conta corrente(Mirtes).
                            
               17/03/2006 - Atualizada atribuicao da flag aux_flgcrcta
                            (Diego).
                
               17/04/2006 - Inclusao de mais duas faixas para cobranca de 
                            tarifa de emprestimo. (Julio).

               29/05/2006 - Desabilitado o trecho de codigo que faz referencia
                            a tabela crapfol (Julio)
                            
               24/01/2007 - Se "aux_flgcrcta = false", entao nao gerar craprej
                            para contratos de emprestimos liquidados (Julio)
                            
               20/04/2007 - Baixar avisos pendentes, quando houver liquidacao
                            de emprestimos vinculados a folha (Julio).
                            
               03/01/2008 - Cobranca de IOF a partir de 03/01/2008 (Magui).
               
               12/02/2008 - Nao cobrar IOF na linha 900 - Desc.Chq.Vencido 
                            (Guilherme).
                            
               19/02/2008 - Nao cobrar IOF na linha 100 - Desc.Chq.Vencido 
                            (Guilherme).             
               
               02/04/2008 - Colocar no craplcm.nrdocmto a soma do numero do
                            documento e sequencial de lote para os historicos
                            161, 18 e 622 para nao causar duplicacao de
                            registros (Evandro).
                            
               30/09/2008 - Cada historico com seu lote (Magui).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               27/08/2009 - Incluido tratamento na critica 484, de modo que 
                            nao pare o processo (Diego).

               26/03/2010 - Desativar RATING quando for liquidado
                            o emprestimo (Gabriel).
                            
               13/05/2010 - Nao cobrar IOF na linha de credito 800 (Elton).
               
               15/09/2010 - Alterado historico 161 para 891. Demanda Auditoria 
                            BACEN (Guilherme).
                            
               16/03/2011 - Realizado correcao no calculo do IOF (Adriano).
               
               06/03/2012 - Ajustando para o novo empréstimo (Oscar). 
               
               19/03/2012 - Declarado as variaveis necessarias para uso da 
                            include lelem.i (Tiago).
                            
               02/04/2012 - Usar o novo campo dtlibera (Oscar).             
               
               23/05/2012 - Tarifar IOF de acordo com parametro da LCREDI.
                            (Irlan).
                            
               14/06/2012 - Ajustar tarifa de contrato (Gabriel) 
               
               09/07/2013 - Alteracao cobranca tarifa emprestimo/financiamento
                            e inclusao rotina para cobranca tarifa avaliacao de
                            bens em garantia, projeto Tarifas (Daniel)
                            
               03/09/2013 - Tratamento para Imunidade Tributaria (Ze).               
               
               05/09/2013 - Chamada da procedure 
                            carrega_dados_tarifa_emprestimo ao inves da
                            carrega_dados_tarifa_vigente levando em 
                            cosideracao as particularidades da chamada de
                            cada uma delas, fazendo o devido ajuste (Tiago).
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               05/11/2013 - Incluido o parametro cdpactra na chamada da 
                            procedure efetua_liquidacao_empr (Adriano).
                            
               27/11/2013 - Retirado comentarios referente tarifacao Ok (Daniel).             
               
               16/01/2014 - Inclusao de VALIDATE craplot, craplcm, craprej, 
                            craplem, crapdpb (Carlos)
                            
               19/02/2014 - Ajustado o lancamento do historico 282, para nao 
                            cobrar juros de mora e multa.  (James)
                            
               24/02/2014 - Ajuste no calculo da variavel aux_vlsderel (James)
               
               25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                           posicoes (Tiago/Gielow SD137074).

               16/06/2014 - Implementacao da rotina de envio de e-mail 
                            para tarifas@cecred.coop.br de LOG's do tipo: 
                            "Erro Faixa Valor Coop.! Tar: 129 Fvl: 131 Lcr: 562"
                            (Carlos Rafael SD159931).
                            
               23/07/2014 - Incluir parametro par_nrseqava na chamada da 
                            procedure efetua_liquidacao_empr. (James)
                            
               28/07/2014 - Ajuste para quando ocorrer erro, nao abortar o 
                            programa. (James)
                            
               11/09/2014 - Ajuste para nao ocorrer o credito em conta
                            quando a origem for TAA e InternetBank. (James)
                            
               07/10/2014 - Ajuste para gravar o valor da tarifa e IOF na
                            crapepr. (James)

               02/12/2014 - Inclusao da chamada do solicita_baixa_automatica
                            (Guilherme/SUPERO)
               
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
  
               19/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
  
               25/06/2015 - Realizado ajuste no fonte para atualizar o campo nrseqdig
                            após insert na craplcm. (Renato Darosci - Supero )
                            
               02/07/2015 - Ajuste no insert da craplcm hist 322 na formação do campo cdpesqbb
                            devido a outros programas lerem essa informação (Odirlei-AMcom)
                            
               05/08/2015 - Inclusao de tratamento para não realizar lancamento de credito da operacao 
                            e debito da tarifa de IOF em conta corrente nas operacoes de portabilidade.
                            Projeto de Portabilidade(Lombardi)
                            
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)
                                                        
               31/08/2015 - Inclusao de tratamento na tarifa de avaliação de garantia do caso 
                            de bem Móvel (Automóvel, moto e caminhão),para que a procedure 
                            'pc_cria_lan_auto_tarifa' seja chamada para cada bem alienado.
                            Projeto de Tarifas-218(Lombardi)
             
               16/05/2016 - Alteracao para chamar a nova pc_leitura_lem_car. (Jaison/James)

               06/03/2017 - Regra para gerar lançamento do histórico 622 deve ser a mesma
                            utilizada para gerar o lançamento do histórico 2.(AJFink-SD#622251)

               29/03/2017 - Estava sendo utilizado variavel rw_craplot.dtmvtolt indevidamente
                            na abertura do cursor cr_craplot.(AJFink-SD#641111)

               01/04/2017 - Ajuste no calculo do IOF. (James)             
               
               07/04/2017 - Ajuste no calculo do IOF para empréstimos do tipo TR ( Renato Darosci )
               
               10/05/2017 - Inclusao do produto Pos-Fixado. Passagem do codigo da Finalidade. 
                            (Jaison/James - PRJ298)

	           04/02/2018 - Ajuste na procedure para buscar o saldo atualizado para o produto pos-fixado. (James)

               14/12/2017 - Novo cálculo IOF e financiamento de IOF no valor do empréstimo.
                            Projeto 410 - RF 14 a 18 (Diogo - MoutS)
                            
               12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)                            

               21/11/2017 - Remover o lançamento da tarifa de alienação nas propostas de CDC,
                            Prj. 402 (Jean Michel)

               20/12/2017 - Criar lançamento de valor de repasse para o Lojista de forma automática,
                            criar fluxo contábil para os lançamentos de empréstimos e conta corrente,
                            Prj. 402 (Jean Michel).

               19/10/2018 - P442 - Inclusão de OUTROS VEICULOS em comentario (Marcos-Envolti)
               
               31/10/2018 - PJ450 RF04 - Gravando saldo refinanciado na crapepr através da 
                            RISC0004.pc_gravar_saldo_refinanciamento (Douglas Pagel/AMcom)

               26/04/2019 - PJ450 - Inclusão do Saldo CC no Risco Melhora (Mário/AMcom)

  ............................................................................. */
  
  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.nrctactl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Cursor Genérico de Calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
  -- Cursor Associado
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.inpessoa,
           ass.nrdconta,
           ass.cdsecext,
           ass.cdagenci,
           ass.cdtipsfx
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;  
  
  -- Cursor Emprestimos
  CURSOR cr_crabepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                     pr_dtmvtolt IN crapepr.dtmvtolt%TYPE,
                     pr_nrctares IN crapepr.nrdconta%TYPE) IS
    SELECT epr.cdcooper
          ,epr.cdfinemp
          ,epr.cdlcremp  
          ,epr.nrdconta
          ,epr.tpemprst
          ,epr.vlemprst
          ,epr.vlpreemp
          ,epr.nrctremp
          ,epr.dtdpagto
          ,epr.qtpreemp
          ,epr.rowid
          ,epr.nrdolote
          ,epr.cdbccxlt
          ,epr.dtmvtolt
          ,epr.idfiniof		  
          ,epr.vltarifa
          ,epr.vltariof
          ,epr.vliofepr
          ,epr.vliofadc
          ,DECODE(EMPR0001.fn_tipo_finalidade(pr_cdcooper => epr.cdcooper
                                             ,pr_cdfinemp => epr.cdfinemp),3,1,0) AS inlcrcdc
       FROM crapepr epr 
      WHERE epr.cdcooper = pr_cdcooper 
        AND epr.dtmvtolt = pr_dtmvtolt
        AND epr.inprejuz <> 1
        AND epr.cdorigem NOT IN (3,4)
        AND epr.nrdconta > pr_nrctares
        ORDER BY epr.nrdconta,epr.tpemprst,epr.nrctremp;

  -- Cursor de Emprestimos
  CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE,
                    pr_nrdconta IN crawepr.nrdconta%TYPE,
                    pr_nrctremp IN crawepr.nrctremp%TYPE) IS
    SELECT wepr.cdcooper
          ,wepr.qtdialib
          ,wepr.tpemprst
          ,wepr.nrctremp
          ,wepr.dtlibera
          ,wepr.dtcarenc
          ,wepr.idcarenc
          ,wepr.nrctrliq##1
          ,wepr.nrctrliq##2
          ,wepr.nrctrliq##3
          ,wepr.nrctrliq##4
          ,wepr.nrctrliq##5
          ,wepr.nrctrliq##6
          ,wepr.nrctrliq##7
          ,wepr.nrctrliq##8
          ,wepr.nrctrliq##9
          ,wepr.nrctrliq##10
          ,wepr.rowid
          ,wepr.idquapro
          ,wepr.nrliquid
      FROM crawepr wepr
     WHERE wepr.cdcooper = pr_cdcooper
       AND wepr.nrdconta = pr_nrdconta
       AND wepr.nrctremp = pr_nrctremp;
  rw_crawepr  cr_crawepr%ROWTYPE;    
  rw_crawepr1 cr_crawepr%ROWTYPE;    
  
  -- Cursor Cadastro de titulares da conta
  CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                   ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
    SELECT ttl.cdcooper
          ,ttl.nrdconta
          ,ttl.cdempres
          ,ttl.cdturnos
     FROM crapttl ttl
    WHERE ttl.cdcooper = pr_cdcooper
      AND ttl.nrdconta = pr_nrdconta
      AND ttl.idseqttl = 1;
  rw_crapttl cr_crapttl%ROWTYPE;
  
  -- Cursor Cadastro de pessoas juridicas
  CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                    ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
    SELECT jur.cdempres, jur.tpregtrb, jur.natjurid
      FROM crapjur jur
     WHERE jur.cdcooper = pr_cdcooper
       AND jur.nrdconta = pr_nrdconta;
  rw_crapjur cr_crapjur%ROWTYPE;   
   
  -- Cursor de portabilidade
  CURSOR cr_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapcop.nrdconta%TYPE
                         ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
  SELECT nrunico_portabilidade
        ,flgerro_efetivacao
    FROM tbepr_portabilidade
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND nrctremp = pr_nrctremp;
  rw_portabilidade cr_portabilidade%ROWTYPE; 
  
  -- Cursor Capa do Lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
  SELECT lot.dtmvtolt
        ,lot.cdagenci
        ,lot.cdbccxlt
        ,lot.nrdolote
        ,NVL(lot.nrseqdig,0) nrseqdig
        ,lot.cdcooper
        ,lot.tplotmov
        ,lot.vlinfodb
        ,lot.vlcompdb
        ,lot.qtinfoln
        ,lot.qtcompln
        ,lot.cdoperad
        ,lot.tpdmoeda
        ,lot.rowid
    FROM craplot lot
   WHERE lot.cdcooper = pr_cdcooper
     AND lot.dtmvtolt = pr_dtmvtolt
     AND lot.cdagenci = pr_cdagenci
     AND lot.cdbccxlt = pr_cdbccxlt
     AND lot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;  
  
  -- Cursor Linhas de Credito
  CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE) IS
    SELECT lcr.cdlcremp
          ,lcr.flgtarif
          ,lcr.nrctacre
          ,lcr.vltrfesp
          ,lcr.flgcrcta
          ,lcr.flgtaiof
          ,lcr.cdusolcr
          ,lcr.tpctrato
          ,lcr.txdiaria
          ,lcr.dsoperac
      FROM craplcr lcr
     WHERE lcr.cdcooper = pr_cdcooper;
     
  -- Cursor Informacoes das Cotas
  CURSOR cr_crapcot(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT cot.rowid
      FROM crapcot cot
     WHERE cot.cdcooper = pr_cdcooper
       AND cot.nrdconta = pr_nrdconta;
  rw_crapcot cr_crapcot%ROWTYPE; 
  
  -- Cursor Cadastro de Emprestimos 
  CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                     pr_nrdconta IN crapepr.nrdconta%TYPE,
                     pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT epr.inliquid
          ,epr.tpemprst
          ,epr.cdlcremp
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdeved
          ,epr.vljuracu
          ,epr.dtultpag
          ,epr.qtprepag
          ,epr.flgpagto
          ,epr.txjuremp
          ,epr.cdcooper
          ,epr.cdagenci
          ,epr.dtmvtolt
          ,epr.vlpreemp
          ,epr.dtdpagto
          ,epr.qttolatr
          ,crawepr.txmensal
          ,crawepr.dtdpagto dtprivencto
          ,epr.vlsprojt
          ,epr.vlemprst
          ,epr.ROWID
          ,crawepr.idfiniof
       FROM crapepr epr 
       JOIN crawepr
         ON crawepr.cdcooper = epr.cdcooper
        AND crawepr.nrdconta = epr.nrdconta
        AND crawepr.nrctremp = epr.nrctremp
      WHERE epr.cdcooper = pr_cdcooper
        AND epr.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp
      ORDER BY epr.CDCOOPER, epr.NRDCONTA, epr.NRCTREMP;
  rw_crapepr cr_crapepr%ROWTYPE; 
  
  -- Cursor do Cadastro dos Avisos de Debito em Conta Corrente.
  CURSOR cr_crapavs(pr_cdcooper IN crapavs.cdcooper%TYPE,
                    pr_nrdconta IN crapavs.nrdconta%TYPE,
                    pr_nrctremp IN crapavs.nrdocmto%TYPE) IS
    SELECT avs.rowid
          ,avs.vldebito
          ,avs.vllanmto
      FROM crapavs avs
     WHERE avs.cdcooper = pr_cdcooper    
       AND avs.nrdconta = pr_nrdconta
       AND avs.nrdocmto = pr_nrctremp
       AND avs.cdhistor = 108             
       AND avs.tpdaviso = 1               
       AND avs.insitavs = 0   
    ORDER BY avs.dtrefere;               

    --Selecionar Detalhes Emprestimo
    CURSOR cr_crawepr_carga(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN crappep.dtvencto%TYPE) IS
      SELECT crawepr.cdcooper
            ,crawepr.nrdconta
            ,crawepr.nrctremp
            ,crawepr.dtlibera
            ,crawepr.tpemprst
        FROM crawepr
            ,crapepr
       WHERE crawepr.cdcooper = crapepr.cdcooper
         AND crawepr.nrdconta = crapepr.nrdconta
         AND crawepr.nrctremp = crapepr.nrctremp
         AND crapepr.cdcooper = pr_cdcooper
         AND crapepr.dtmvtolt = pr_dtmvtolt
         AND crapepr.inprejuz <> 1
         AND crapepr.cdorigem NOT IN (3,4);
         
    /* Cursor genérico e padrão para busca da craptab */
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
    SELECT tab.dstextab,
           tab.tpregist
      FROM craptab tab
     WHERE tab.cdcooper        = pr_cdcooper
       AND upper(tab.nmsistem) = pr_nmsistem
       AND upper(tab.tptabela) = pr_tptabela
       AND tab.cdempres        = pr_cdempres
       AND upper(tab.cdacesso) = pr_cdacesso;
       
    CURSOR cr_crapbpr (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapepr.nrdconta%TYPE
                      ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT *
        FROM crapbpr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND tpctrpro = 90
         AND nrctrpro = pr_nrctremp
         AND flgalien = 1; -- TRUE;
    --rw_crapbpr cr_crapbpr%ROWTYPE;

    -- Busca os dados da carencia
    CURSOR cr_carencia IS
      SELECT param.idcarencia,
             param.qtddias
        FROM tbepr_posfix_param_carencia param
       WHERE param.idparametro = 1;

     
    -- Cursor para bens do empréstimo  
    CURSOR cr_crapbpr_iof(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT dscatbem
    FROM crapbpr 
    WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND nrctrpro = pr_nrctremp
          AND (dscatbem = 'APARTAMENTO' OR 
               dscatbem = 'CASA' OR 
               dscatbem = 'MOTO')
    ORDER BY dscatbem;
   rw_crapbpr_iof cr_crapbpr_iof%ROWTYPE;

    CURSOR cr_rapassecdc_compartilhado(pr_dtmvtolt IN crapepr.dtmvtolt%TYPE) IS
    SELECT epr.cdcooper -- proponente
          ,epr.nrdconta -- proponente
          ,epr.cdlcremp 
          ,epr.tpemprst 
          ,epr.vlemprst 
          ,epr.vlpreemp 
          ,tce.vlrepasse -- valor_repasse
          ,epr.nrctremp 
          ,epr.dtdpagto 
          ,epr.qtpreemp 
          ,epr.rowid 
          ,epr.nrdolote 
          ,epr.cdbccxlt 
          ,epr.dtmvtolt 
          ,epr.idfiniof 
          ,tcc.cdcooper cdcoploj -- lojista
          ,tcc.nrdconta nrdccloj -- lojista
      FROM crapepr epr 
          ,tbepr_cdc_emprestimo tce
          ,tbsite_cooperado_cdc tcc 
     WHERE epr.dtmvtolt = pr_dtmvtolt 
       AND epr.inprejuz != 1
       AND epr.cdorigem NOT IN(3,4) 
       AND DECODE(EMPR0001.fn_tipo_finalidade(pr_cdcooper => epr.cdcooper, pr_cdfinemp => epr.cdfinemp),3,1,0)=1 -- somente CDC
       AND epr.cdcooper=tce.cdcooper
       AND epr.nrdconta=tce.nrdconta
       AND epr.nrctremp=tce.nrctremp
       AND tce.idcooperado_cdc=tcc.idcooperado_cdc -- somente quando tiver lojista
       AND epr.cdcooper!=tcc.cdcooper
    ORDER BY epr.cdcooper, epr.nrdconta, epr.nrctremp; -- somente CDC compartilhado
    rw_rapassecdc_compartilhado cr_rapassecdc_compartilhado%ROWTYPE;

  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS149';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  vr_dsreturn VARCHAR2(4000);
  vr_des_reto VARCHAR2(3);
  vr_index_pos PLS_INTEGER;
  
  --Tipo da tabela de saldos
  vr_indsaldo BINARY_INTEGER;
  vr_tab_saldo EXTR0001.typ_tab_saldos;

  --tabela de Memoria dos detalhes de emprestimo
  vr_tab_crawepr EMPR0001.typ_tab_crawepr;
  -- Tabela Temporaria
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_tab_carencia CADA0001.typ_tab_number;
  
  --Tabelas de Memoria para Pagamentos das Parcelas Emprestimo
  vr_tab_pgto_parcel  EMPR0001.typ_tab_pgto_parcel;
  vr_tab_calculado    EMPR0001.typ_tab_calculado;
	vr_tab_calculado2   EMPR0011.typ_tab_calculado;
  vr_tab_parcelas_pos EMPR0011.typ_tab_parcelas;
  
  -- Rowid de retorno lançamento de tarifa
  vr_rowid    ROWID;
  
  vr_contador NUMBER := 0;
 
  -- Variaveis Tarifa
  vr_vltottar NUMBER := 0;
  vr_vlpreclc NUMBER := 0; -- Parcela calcula
  vr_vliofaux NUMBER := 0;
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_cdhisest craphis.cdhistor%TYPE;
  vr_dstextab craptab.dstextab%TYPE;
  vr_dtdivulg DATE;
  vr_dtvigenc DATE;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  vr_vlrtarif crapfco.vltarifa%TYPE;
  vr_cdbattar VARCHAR2(100) := ' ';
  vr_cdhistmp craphis.cdhistor%TYPE;
  vr_cdfvltmp crapfco.cdfvlcop%TYPE;
  vr_qtdias_carencia tbepr_posfix_param_carencia.qtddias%TYPE;
  vr_dsbemgar varchar2(1000);
  vr_vltrfgar number := 0;
  vr_cdhisgar craphis.cdhistor%TYPE;
  vr_cdfvlgar crapfco.cdfvlcop%TYPE;
  vr_cdhislcm craphis.cdhistor%TYPE;
  
  
  -- Variaveis Envio de Email
  vr_nmrescop    VARCHAR2(100);
  vr_des_corpo   VARCHAR2(1000);
  vr_des_destino VARCHAR2(1000);
  
  vr_diapagto VARCHAR2(2);
  vr_tab_indpagto NUMBER := 0;
  vr_tab_dtcalcul DATE;
  
  vr_valor_total NUMBER := 0;
  vr_totliqui NUMBER := 0;
  vr_vlrsaldo NUMBER := 0;
  vr_vlmultip NUMBER := 0;
  vr_vlemprst NUMBER := 0;
  vr_dtultdia DATE;
  vr_dtliblan DATE;
  
  vr_valor_creditado NUMBER := 0;
  
  vr_flgimune PLS_INTEGER;
  vr_tab_inusatab BOOLEAN;
  
  -- Codigo da Empresa
  vr_cdempres crapttl.cdempres%TYPE := 0;
  
  --Verifica se é portabilidade
  vr_portabilidade BOOLEAN := FALSE;
  
  --Flag para tarifas moveis diferente de carro, moto ou caminhao ou outros veiculos
  vr_flgoutrosbens BOOLEAN;
  
  -- Variaveis Auxiliares Linha de Credito
  vr_flgtarif craplcr.flgtarif%TYPE;
  vr_nrctacre craplcr.nrctacre%TYPE;
  vr_vltrfesp craplcr.vltrfesp%TYPE;
  vr_flgcrcta craplcr.flgcrcta%TYPE;
  vr_flgtaiof craplcr.flgtaiof%TYPE;
  
  -- Variaveis Auxiliares Emprestimo
  vr_nrdconta crapepr.nrdconta%TYPE;
  vr_nrctremp crapepr.nrctremp%TYPE;
  vr_vlsdeved crapepr.vlsdeved%TYPE;
  vr_vljuracu crapepr.vljuracu%TYPE;
  vr_dtultpag crapepr.dtultpag%TYPE;
  vr_inliquid crapepr.inliquid%TYPE;
  vr_qtprepag crapepr.qtprepag%TYPE;
  vr_inliqemp crapepr.inliquid%TYPE;
  vr_qtmesdec crapepr.qtmesdec%TYPE;
  vr_vlpreapg crapepr.vlpreemp%TYPE;
  
  vr_vlsderel NUMBER;
  vr_dtcalcul DATE;
  vr_txdjuros NUMBER := 0;
  vr_dtrefere DATE;
  vr_vldescto NUMBER := 0;
  vr_valor    NUMBER := 0;
  vr_ant_vlsdeved NUMBER := 0;
  vr_vlavsdeb NUMBER := 0;
  vr_inusatab BOOLEAN := FALSE;
  vr_crapass  BOOLEAN := FALSE;
  
  vr_vlsaldo_refinanciado NUMBER := 0;
  
  vr_qtprecal crapepr.qtprecal%TYPE;
  vr_vljurmes NUMBER := 0;
  vr_vlprepag NUMBER := 0;
  vr_cdhismul INTEGER;
  vr_vldmulta NUMBER;
  vr_cdhismor INTEGER;
  vr_vljumora NUMBER;
  
  vr_tab_price EMPR0011.typ_tab_price;

  -- Calculo Conta Integração
  vr_dsdctitg VARCHAR2(8);
  vr_stsnrcal NUMBER;
  
  -- Variaveis auxiliares para criação crapavs
  vr_avs_vldebito NUMBER := 0;
  vr_avs_vlestdif NUMBER := 0;
  vr_avs_insitavs NUMBER := 0;
  
  -- Variaveis de Controle de Restart
  vr_nrctares INTEGER:= 0;
  vr_inrestar INTEGER:= 0;
  vr_dsrestar crapres.dsrestar%TYPE;
  
  -- Variaveis de Indece
  vr_index_calculado   PLS_INTEGER;
  vr_index_crawepr     VARCHAR2(30);
  
  -- Indicador de Liquidação
  --vr_inliquid INTEGER:= 0;
  
  -- Variaveis do CPMF
  vr_dtinipmf	DATE;
  vr_dtfimpmf	DATE;
  vr_dtiniabo	DATE;
  vr_txrdcpmf	NUMBER;
  vr_indabono	NUMBER;
  vr_sem_cpmf CHAR := ' ';
  vr_txcpmfcc NUMBER := 0;
  vr_vldacpmf NUMBER := 0;
  
  --IOF
  vr_qtdiaiof NUMBER := 0;
  vr_vltaxa_iof_atraso NUMBER := 0;
  vr_vliofpri NUMBER := 0;
  vr_vliofadi NUMBER := 0;
  vr_vliofcpl NUMBER := 0;
  vr_vliofpri_tmp NUMBER := 0;
  vr_vliofadi_tmp NUMBER := 0;
  vr_vltaxa_iof_principal NUMBER := 0;
  vr_dscatbem VARCHAR2(200);
  vr_dsctrliq VARCHAR2(1000) := '';
  
  -- Tabela temporaria Linhas de Credito
  TYPE typ_reg_craplcr IS
   RECORD(flgtarif craplcr.flgtarif%TYPE
         ,nrctacre craplcr.nrctacre%TYPE
         ,vltrfesp craplcr.vltrfesp%TYPE
         ,flgcrcta craplcr.flgcrcta%TYPE
         ,flgtaiof craplcr.flgtaiof%TYPE
         ,cdusolcr craplcr.cdusolcr%TYPE
         ,tpctrato craplcr.tpctrato%TYPE
         ,txdiaria craplcr.txdiaria%TYPE
         ,dsoperac craplcr.dsoperac%TYPE);
  TYPE typ_tab_craplcr IS
    TABLE OF typ_reg_craplcr
      INDEX BY PLS_INTEGER;
  -- Vetor para armazenar linhas de credito
  vr_tab_craplcr typ_tab_craplcr;
  
  -- Tabela temporaria Contratos Liquidados
  TYPE typ_tab_nrctrliq IS TABLE OF crawepr.nrctrliq##1%TYPE INDEX BY PLS_INTEGER;
  vr_tab_nrctrliq typ_tab_nrctrliq;
  
  -- Tabela de Memoria para Dia do pagamento por empresa na craptab
  TYPE typ_tab_diadopagto IS TABLE OF craptab.dstextab%TYPE INDEX BY PLS_INTEGER;
  vr_tab_diadopagto typ_tab_diadopagto;
  
  -- Tabela de Memoria para controle Lotes
  vr_tab_craplot typ_tab_nrctrliq;
  
  --Criar os Lotes usados pelo Programa 
  PROCEDURE pc_cria_lote (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE
                         ,pr_des_reto OUT VARCHAR2
                         ,pr_dscritic OUT VARCHAR) IS
  BEGIN
    DECLARE                        
      vr_exc_erro EXCEPTION;
      vr_dscritic VARCHAR2(4000);
    BEGIN
      --Controle para verificar se ja inseriu o lote
      IF pr_nrdolote = 8456 AND NOT vr_tab_craplot.EXISTS(pr_nrdolote) THEN
        
        --Marcar que ja processou esse lote
        vr_tab_craplot(pr_nrdolote):= 0;
        
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8456);
        FETCH cr_craplot INTO rw_craplot;
          
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;
            
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot 
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig)
            VALUES  
               (pr_dtmvtolt
               ,1
               ,100
               ,8456
               ,1
               ,pr_cdcooper
               ,0);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8456). '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_erro;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;
      END IF;

      --Controle para verificar se ja inseriu o lote
      IF pr_nrdolote = 10026 AND NOT vr_tab_craplot.EXISTS(pr_nrdolote) THEN
        
        --Marcar que ja processou esse lote
        vr_tab_craplot(pr_nrdolote):= 0;

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10026);
        FETCH cr_craplot INTO rw_craplot;
            
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;
              
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig)
            VALUES  
               (pr_dtmvtolt
               ,1
               ,100
               ,10026
               ,1
               ,pr_cdcooper
               ,0);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (10026). '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_erro;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF; 
      END IF;
      
      --Controle para verificar se ja inseriu o lote
      IF pr_nrdolote = 8453 AND NOT vr_tab_craplot.EXISTS(pr_nrdolote) THEN
        
        --Marcar que ja processou esse lote
        vr_tab_craplot(pr_nrdolote):= 0;

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8453);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;
              
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig
               ,cdoperad
               ,tpdmoeda)
            VALUES  
               (pr_dtmvtolt
               ,1
               ,100
               ,8453
               ,5
               ,pr_cdcooper
               ,0
               ,'1'
               ,1);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8453). '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_erro;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;
      END IF;

      --Controle para verificar se ja inseriu o lote
      IF pr_nrdolote = 10027 AND NOT vr_tab_craplot.EXISTS(pr_nrdolote) THEN
        
        --Marcar que ja processou esse lote
        vr_tab_craplot(pr_nrdolote):= 0;

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10027);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;
            
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig)
            VALUES  
               (pr_dtmvtolt
               ,1
               ,100
               ,10027
               ,1
               ,pr_cdcooper
               ,0);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (10027). '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_erro;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;
      END IF;

      --Controle para verificar se ja inseriu o lote
      IF pr_nrdolote = 10025 AND NOT vr_tab_craplot.EXISTS(pr_nrdolote) THEN
        
        --Marcar que ja processou esse lote
        vr_tab_craplot(pr_nrdolote):= 0;
      
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10025);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;
            
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig)
            VALUES  
               (pr_dtmvtolt
               ,1
               ,100
               ,10025
               ,1
               ,pr_cdcooper
               ,0);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (10025). '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_erro;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF; 
      END IF;
      --Controle para verificar se ja inseriu o lote
      IF pr_nrdolote = 650008 AND NOT vr_tab_craplot.EXISTS(pr_nrdolote) THEN
        
        --Marcar que ja processou esse lote
        vr_tab_craplot(pr_nrdolote):= 0;
      
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 650008);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;
            
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig)
            VALUES  
               (pr_dtmvtolt
               ,1
               ,100
               ,650008
               ,1
               ,pr_cdcooper
               ,0);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (650008). '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_erro;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF; 
      END IF;

      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro ao criar lotes. '||sqlerrm;
    END;                         
  END pc_cria_lote;                         

BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
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
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;                          
    
  -- Leitura do calendário da cooperativa
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
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
  
  -- Tratamento e retorno de valores de restart
  BTCH0001.pc_valida_restart(pr_cdcooper => pr_cdcooper
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_flgresta => pr_flgresta
                            ,pr_nrctares => vr_nrctares
                            ,pr_dsrestar => vr_dsrestar
                            ,pr_inrestar => vr_inrestar
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_des_erro => vr_dscritic);
  --Se ocrreu erro na validacao do restart
  IF vr_dscritic IS NOT NULL THEN
   --Levantar Excecao
   RAISE vr_exc_saida;
  END IF;
  
  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  -- Procedimento padrão de busca de informações de CPMF { includes/cpmf.i } 
  gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                        ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                        ,pr_dtinipmf  => vr_dtinipmf
                        ,pr_dtfimpmf  => vr_dtfimpmf
                        ,pr_txcpmfcc  => vr_txcpmfcc
                        ,pr_txrdcpmf  => vr_txrdcpmf
                        ,pr_indabono  => vr_indabono
                        ,pr_dtiniabo  => vr_dtiniabo
                        ,pr_cdcritic  => vr_cdcritic
                        ,pr_dscritic  => vr_dscritic);
  -- Se retornou erro
  IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
    -- Gerar raise
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;
  
  --Carga Linhas Credito
  FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper) LOOP
    vr_tab_craplcr(rw_craplcr.cdlcremp).flgtarif := rw_craplcr.flgtarif;  
    vr_tab_craplcr(rw_craplcr.cdlcremp).nrctacre := rw_craplcr.nrctacre;
    vr_tab_craplcr(rw_craplcr.cdlcremp).vltrfesp := rw_craplcr.vltrfesp;
    vr_tab_craplcr(rw_craplcr.cdlcremp).flgcrcta := rw_craplcr.flgcrcta;
    vr_tab_craplcr(rw_craplcr.cdlcremp).flgtaiof := rw_craplcr.flgtaiof;
    vr_tab_craplcr(rw_craplcr.cdlcremp).cdusolcr := rw_craplcr.cdusolcr;
    vr_tab_craplcr(rw_craplcr.cdlcremp).tpctrato := rw_craplcr.tpctrato;
    vr_tab_craplcr(rw_craplcr.cdlcremp).txdiaria := rw_craplcr.txdiaria;
    vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
  END LOOP;  

  --Carregar Tabela crawepr
  FOR rw_crawepr IN cr_crawepr_carga(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
    --Montar Indice
    vr_index_crawepr := lpad(rw_crawepr.cdcooper, 10, '0') ||
                        lpad(rw_crawepr.nrdconta, 10, '0') ||
                        lpad(rw_crawepr.nrctremp, 10, '0');
    vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr.dtlibera;
    vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr.tpemprst;
  END LOOP;

  -- Carregar tabela dias de pagamento por empresa da craptab
  FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                              ,pr_nmsistem => 'CRED'
                              ,pr_tptabela => 'GENERI'
                              ,pr_cdempres => 00
                              ,pr_cdacesso => 'DIADOPAGTO') LOOP
    vr_tab_diadopagto(rw_craptab.tpregist):= rw_craptab.dstextab;
  END LOOP;  
        
  -- Carregar tabela de carencia
  FOR rw_carencia IN cr_carencia LOOP
    vr_tab_carencia(rw_carencia.idcarencia):= rw_carencia.qtddias;
  END LOOP;

  --Busca as tarifas
  vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                          ,pr_nmsistem => 'CRED'
                                          ,pr_tptabela => 'USUARI'
                                          ,pr_cdempres => 11
                                          ,pr_cdacesso => 'TAXATABELA'
                                          ,pr_tpregist => 0  );
  -- Se nao encontrar
  IF vr_dstextab IS NULL THEN
    vr_tab_inusatab := FALSE; 
  ELSE
    IF SUBSTR(vr_dstextab,1,1) = '0' THEN
      vr_tab_inusatab := FALSE;
    ELSE  
      vr_tab_inusatab := TRUE;
    END IF;  
  END IF;
              
  -- Busca Ultimo Dia do Mês
  vr_dtultdia := LAST_DAY(rw_crapdat.dtmvtolt); 
   
  --Buscar parametro email tarifas@cecred.coop.br
  vr_des_destino:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'EMAIL_TARIF');
  --Se nao encontrou
  IF vr_des_destino IS NULL THEN
    vr_dscritic:= 'Nao foi encontrado email padrao para as tarifas.';
    --Levantar Excecao
    RAISE vr_exc_saida;
  END IF;  
  
  --Limpar tabela lote
  vr_tab_craplot.DELETE;
  
  --Ler Emprestimos      
  FOR rw_crabepr IN cr_crabepr(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                               pr_nrctares => vr_nrctares) LOOP
    
    -- Limpa Variaveis de Critica                           
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    -- Valor do Emprestimo menos Vlr. Liquido
    vr_valor_total := 0;
    vr_totliqui := 0;
    -- Valor do Emprestimo.
    vr_vlrsaldo := rw_crabepr.vlemprst;
    
    -- Leitura da proposta do emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => rw_crabepr.nrdconta
                   ,pr_nrctremp => rw_crabepr.nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Se nao encontrou proposta
    IF cr_crawepr%NOTFOUND THEN
      vr_cdcritic:= 535; -- 535 - Proposta Não Encontrada.
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic) ||
                    gene0002.fn_mask(rw_crabepr.nrdconta,'zzzz.zzz.9');
      -- Fechar Cursor
      CLOSE cr_crawepr;
      
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);
      
      --Sair do programa
      RAISE vr_exc_saida;
    END IF;
    -- Fechar Cursor
    CLOSE cr_crawepr;
    /*P438 - Incluir a tratativa para PP*/
    -- Se for PP e Pos-Fixado
    IF rw_crawepr.tpemprst IN (1,2) THEN

      -- Se NAO for Refinanciamento
      IF NVL(rw_crawepr.nrctrliq##1, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##2, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##3, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##4, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##5, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##6, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##7, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##8, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##9, 0) = 0 AND
         NVL(rw_crawepr.nrctrliq##10,0) = 0 AND 
         NVL(rw_crawepr.nrliquid,0) = 0 THEN
         CONTINUE; -- Proximo registro
      END IF;

    END IF;

    --Selecionar Associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => rw_crabepr.nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    vr_crapass:= cr_crapass%FOUND;
    CLOSE cr_crapass;                
    
    -- Nao encontrou cooperado
    IF NOT vr_crapass THEN
      vr_cdcritic:= 9; -- 009 - Associado nao cadastrado.
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic) || ' - ' ||
                    gene0002.fn_mask(rw_crabepr.nrdconta,'zzzz.zzz.9');
      
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);
      
      
      -- Finaliza Execução do Programa
      RAISE vr_exc_saida;
    ELSE
      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica 
        --Buscar Titular
        OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_crabepr.nrdconta);
        FETCH cr_crapttl INTO rw_crapttl;
        
        -- Se nao encontrar
        IF cr_crapttl%NOTFOUND THEN
          vr_cdempres:= NULL;
        ELSE  
          vr_cdempres := rw_crapttl.cdempres;
        END IF;
        -- Fecha Cursor
        CLOSE cr_crapttl;
      ELSE
        -- Pessoa Juridica
        OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_crabepr.nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        -- Se nao encontrar
        IF cr_crapjur%NOTFOUND THEN
          vr_cdempres := NULL;
        ELSE  
          vr_cdempres := rw_crapjur.cdempres;
        END IF;
        -- Fecha Cursor
        CLOSE cr_crapjur;
      END IF;
    END IF;      
    
    --Consulta o registro na tabela de portabilidade
    OPEN cr_portabilidade(pr_cdcooper => rw_crabepr.cdcooper
                               ,pr_nrdconta => rw_crabepr.nrdconta
                               ,pr_nrctremp => rw_crabepr.nrctremp);
    FETCH cr_portabilidade INTO rw_portabilidade;
    vr_portabilidade := cr_portabilidade%FOUND;
    CLOSE cr_portabilidade;
            
    -- Leitura dos dados da linha de credito utilizada
    IF vr_tab_craplcr.EXISTS(rw_crabepr.cdlcremp) THEN
      vr_flgtarif := vr_tab_craplcr(rw_crabepr.cdlcremp).flgtarif;
      vr_nrctacre := vr_tab_craplcr(rw_crabepr.cdlcremp).nrctacre;
      vr_vltrfesp := vr_tab_craplcr(rw_crabepr.cdlcremp).vltrfesp;
      IF vr_portabilidade = FALSE THEN
      vr_flgcrcta := vr_tab_craplcr(rw_crabepr.cdlcremp).flgcrcta;
      vr_flgtaiof := vr_tab_craplcr(rw_crabepr.cdlcremp).flgtaiof;      
    ELSE
        vr_flgcrcta := 0;
        vr_flgtaiof := 0;
      END IF;
    ELSE
      vr_dscritic:= 'Linha de Credito nao Cadastrada' || ' - ' ||
                    gene0002.fn_mask(rw_crabepr.nrdconta,'zzzz.zzz.9');
      
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);
      
      -- Finaliza Execução do Programa
      RAISE vr_exc_saida;
    END IF;
          
    -- Limpa Variaveis de Tarifa     
    vr_vlrtarif:= 0;
    vr_vltrfesp:= 0;
    
    /* Projeto 410 - Chamada da PC_CALCULA_TARIFA - Jean (Mout´S) */
     vr_dsbemgar := '';
      -- Percorrer todos os bens da Proposta de Emprestimo
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_crabepr.nrdconta
                                  ,pr_nrctremp => rw_crabepr.nrctremp) LOOP
        vr_dsbemgar := vr_dsbemgar || '|' || rw_crapbpr.dscatbem;
      END LOOP;
    
    tari0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper , 
                               pr_nrdconta => rw_crabepr.nrdconta, 
                               pr_cdlcremp => rw_crabepr.cdlcremp, 
                               pr_vlemprst => rw_crabepr.vlemprst, 
                               pr_cdusolcr => vr_tab_craplcr(rw_crabepr.cdlcremp).cdusolcr, 
                               pr_tpctrato => vr_tab_craplcr(rw_crabepr.cdlcremp).tpctrato, 
                               pr_dsbemgar => vr_dsbemgar, 
                               pr_cdprogra => 'CRPS149', 
                               pr_flgemail => 'N', 
                               pr_tpemprst => rw_crabepr.tpemprst,
                               pr_idfiniof => rw_crabepr.idfiniof,
                               pr_vlrtarif => vr_vlrtarif, 
                               pr_vltrfesp => vr_vltrfesp, 
                               pr_vltrfgar => vr_vltrfgar, 
                               pr_cdhistor => vr_cdhistor, 
                               pr_cdfvlcop => vr_cdfvlcop, 
                               pr_cdhisgar => vr_cdhisgar, 
                               pr_cdfvlgar => vr_cdfvlgar, 
                               pr_cdcritic => vr_cdcritic, 
                               pr_dscritic => vr_dscritic);
                                             
   if vr_dscritic is not null then
          vr_cdcritic:= 0;
      vr_dscritic:= 'Erro no calculo da tarifa. ';
   end if;
    
    -- Total Tarifa a ser Cobrado
    vr_vltottar := NVL(vr_vlrtarif,0) + NVL(vr_vltrfesp,0);
    --Total da Tarifa
    IF vr_vltottar > 0 
    AND rw_crabepr.idfiniof = 0 THEN -- so lanca tarifas nas LCM se não financia IOF
      
      -- Criar Lançamento automatico tarifa
      TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                      , pr_nrdconta     => rw_crabepr.nrdconta
                                      , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                      , pr_cdhistor     => vr_cdhistor
                                      , pr_vllanaut     => vr_vltottar
                                      , pr_cdoperad     => '1'
                                      , pr_cdagenci     => 1
                                      , pr_cdbccxlt     => 100
                                      , pr_nrdolote     => 8452
                                      , pr_tpdolote     => 1
                                      , pr_nrdocmto     => rw_crabepr.nrctremp
                                      , pr_nrdctabb     => rw_crabepr.nrdconta
                                      , pr_nrdctitg     => gene0002.fn_mask(rw_crabepr.nrdconta,'99999999')
                                      , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crabepr.nrctremp)
                                      , pr_cdbanchq     => 0
                                      , pr_cdagechq     => 0
                                      , pr_nrctachq     => 0
                                      , pr_flgaviso     => FALSE
                                      , pr_tpdaviso     => 0
                                      , pr_cdfvlcop     => vr_cdfvlcop
                                      , pr_inproces     => rw_crapdat.inproces
                                      , pr_rowid_craplat=> vr_rowid
                                      , pr_tab_erro     => vr_tab_erro
                                      , pr_cdcritic     => vr_cdcritic
                                      , pr_dscritic     => vr_dscritic);
      --Se ocorreu erro
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic:= vr_tab_erro(1).cdcritic;
          vr_dscritic:= vr_tab_erro(1).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro no lancamento tarifa adtivo. Conta: ';
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '||
                                                      gene0002.fn_mask_conta(rw_crabepr.nrdconta)||'- '
                                                   || vr_dscritic );
        -- Limpa valores das variaveis de critica
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;                                           
      END IF;
    END IF;  -- Fim Cobranca da tarifa de emprestimo
    
    -- Lancamento das tarifas de garantia
    IF rw_crabepr.idfiniof = 0 AND 
       vr_vltrfgar > 0 then
              TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                              ,pr_nrdconta      => rw_crabepr.nrdconta
                                              ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                      ,pr_cdhistor      => vr_cdhisgar
                                      ,pr_vllanaut      => vr_vltrfgar
                                              ,pr_cdoperad      => '1'
                                              ,pr_cdagenci      => 1
                                              ,pr_cdbccxlt      => 100
                                              ,pr_nrdolote      => 8452
                                              ,pr_tpdolote      => 1
                                              ,pr_nrdocmto      => rw_crabepr.nrctremp
                                              ,pr_nrdctabb      => rw_crabepr.nrdconta
                                              ,pr_nrdctitg      => gene0002.fn_mask(rw_crabepr.nrdconta,'99999999')
                                              ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(rw_crabepr.nrctremp)
                                              ,pr_cdbanchq      => 0
                                              ,pr_cdagechq      => 0
                                              ,pr_nrctachq      => 0
                                              ,pr_flgaviso      => FALSE
                                              ,pr_tpdaviso      => 0
                                      ,pr_cdfvlcop      => vr_cdfvlgar
                                              ,pr_inproces      => rw_crapdat.inproces
                                              ,pr_rowid_craplat => vr_rowid
                                              ,pr_tab_erro      => vr_tab_erro
                                              ,pr_cdcritic      => vr_cdcritic
                                              ,pr_dscritic      => vr_dscritic
                                              );
          
        -- Se ocorreu erro
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro no lancamento tarifa adtivo.';
          END IF;
          --Concatenar Conta e tarifa
          vr_dscritic:= vr_dscritic ||'Conta: '||gene0002.fn_mask_conta(rw_crabepr.nrdconta)||'- '||vr_cdbattar;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
          -- Limpa valores das variaveis de critica
          vr_cdcritic:= 0;
          vr_dscritic:= NULL;                                           
                
        END IF;
      END IF;
  
    -- Projeto 410 - SM1 - Se financia IOF, cria lançamento na LEM correspondente à  tarifa 
    -- Na rotina b1wgen0084
    
    -- PRJ410 
    -- Se financia valor  
    IF rw_crabepr.idfiniof = 1 THEN
      --> diminuir valor iof e valor tarifa
      vr_vlemprst := rw_crabepr.vlemprst - nvl(rw_crabepr.vltarifa,0) - nvl(rw_crabepr.vliofepr,0);
    ELSE
      -- caso nao financia IOF e tarifa, deve gerar credito do valor total
      vr_vlemprst := rw_crabepr.vlemprst;
    END IF;
  
    
    -- Credita valor do emprestimo (Se não Bloqueado)
    IF (rw_crawepr.qtdialib <= 0  AND rw_crawepr.tpemprst = 0) OR
       (rw_crawepr.dtlibera = rw_crapdat.dtmvtolt AND rw_crawepr.tpemprst IN (1,2)) THEN
        
      IF vr_flgcrcta = 1 THEN -- TRUE
        
        --Criar os Lotes usados pelo Programa 
        pc_cria_lote (pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_nrdolote => 8456
                     ,pr_des_reto => vr_des_erro
                     ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          -- Finaliza Execução do Programa
          RAISE vr_exc_saida;
        END IF;

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8456);
        FETCH cr_craplot INTO rw_craplot;
        -- Apenas Fecha Cursor
        CLOSE cr_craplot;
        
        --Inserir Lancamento
        BEGIN
          INSERT INTO craplcm
             (cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdctabb
             ,nrdctitg
             ,nrdocmto
             ,cdhistor
             ,nrseqdig
             ,cdpesqbb
             ,vllanmto)
          VALUES  
             (pr_cdcooper
             ,rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,rw_crabepr.nrdconta
             ,rw_crabepr.nrdconta
             ,GENE0002.fn_mask(rw_crabepr.nrdconta,'99999999')
             ,GENE0002.fn_mask(rw_crabepr.nrctremp || TO_CHAR(sysdate,'SSSSS') || (nvl(rw_craplot.nrseqdig,0) + 1),'999999999999999') -- rw_crabepr.nrctremp
             ,15 -- CR.EMPRESTIMO
             ,nvl(rw_craplot.nrseqdig,0) + 1
             ,GENE0002.fn_mask(rw_crabepr.nrctremp,'99999999')
             ,vr_vlemprst);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplcm (15) . ' || SQLERRM;
           --Sair do programa
           RAISE vr_exc_saida;
        END;
          
        --Atualizar capa do Lote
        BEGIN
          UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_vlemprst
                            ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_vlemprst
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END;                   
        
        -- Data Liberação                      
        vr_dtliblan := rw_crapdat.dtmvtolt;   
      END IF;
    ELSE
      IF (rw_crawepr.tpemprst = 0) THEN
        
        vr_contador := 1;
        vr_dtliblan := rw_crapdat.dtmvtolt;

        -- Calcula a data de liberacao
        WHILE vr_contador <= rw_crawepr.qtdialib LOOP
          --Incrementar Data Liberacao
          vr_dtliblan := vr_dtliblan + 1;
          -- Verificar se é feriado ou sabado ou domingo
          -- Data diferente = feriado ou final de semana
          IF gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                         pr_dtmvtolt => vr_dtliblan) <> vr_dtliblan THEN
            NULL;
          ELSE
            vr_contador := vr_contador + 1;
          END IF;
        END LOOP;
      ELSE
        IF (rw_crawepr.tpemprst = 1) THEN
          -- Data Liberação
          vr_dtliblan := rw_crawepr.dtlibera;
        END IF;
      END IF;
    END IF;
    
    IF vr_flgcrcta = 1 THEN -- TRUE
      BEGIN
         /*  Registro do contrato efetuado  */
         INSERT INTO craprej
            (nrdconta
            ,nraplica
            ,cdagenci
            ,nrdolote
            ,nrdctabb
            ,nrdctitg
            ,dtmvtolt
            ,cdpesqbb
            ,nrseqdig
            ,cdcooper)
         VALUES
            (rw_crabepr.nrdconta
            ,rw_crabepr.nrctremp
            ,rw_crapass.cdagenci
            ,rw_crapass.cdsecext
            ,0
            ,' '
            ,vr_dtliblan
            ,'CRPS173_EPR'
            ,1
            ,pr_cdcooper);    
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao inserir craprej. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_saida;
      END;                       
    END IF;
        
    --  Leitura do dia do pagamento da empres
    IF NOT vr_tab_diadopagto.EXISTS(vr_cdempres) THEN                                        
      --Codigo Erro                                      
      vr_cdcritic := 55; 
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic || ' CRED-GENERI-00-DIADOPAGTO-' ||
                                                    vr_cdempres );
                                                    
      --Sair do programa
      RAISE vr_exc_saida;                                             
    ELSE
      --Recuperar valor na tabela 
      vr_dstextab:= vr_tab_diadopagto(vr_cdempres);
      
      IF rw_crapass.cdtipsfx IN (1,3,4) THEN
        vr_diapagto := SUBSTR(vr_dstextab,4,2); -- Mensal
      ELSE
        vr_diapagto := SUBSTR(vr_dstextab,7,2); -- Horis. 
      END IF;     

      vr_tab_indpagto := to_number(SUBSTR(vr_dstextab,14,1));

      --  Verifica se a data do pagamento da empresa cai num dia util
      vr_tab_dtcalcul := to_date( vr_diapagto || '/' ||
                                  to_char(rw_crapdat.dtmvtolt,'MM') || '/' ||
                                  to_char(rw_crapdat.dtmvtolt,'YYYY') , 'DD/MM/YYYY');
    END IF;
              
    -- Proximo dia util
    vr_tab_dtcalcul:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                  pr_dtmvtolt => vr_tab_dtcalcul);
    --Dia do Pagamento
    vr_diapagto := to_number(to_char(vr_tab_dtcalcul,'DD'));                                              
            
    --Zerar Valor Creditado                
    vr_valor_creditado := 0;
    
    --Popular Emprestimos
    vr_tab_nrctrliq(1):=  NVL(rw_crawepr.nrctrliq##1,0);
    vr_tab_nrctrliq(2):=  NVL(rw_crawepr.nrctrliq##2,0);
    vr_tab_nrctrliq(3):=  NVL(rw_crawepr.nrctrliq##3,0);
    vr_tab_nrctrliq(4):=  NVL(rw_crawepr.nrctrliq##4,0);
    vr_tab_nrctrliq(5):=  NVL(rw_crawepr.nrctrliq##5,0);
    vr_tab_nrctrliq(6):=  NVL(rw_crawepr.nrctrliq##6,0);
    vr_tab_nrctrliq(7):=  NVL(rw_crawepr.nrctrliq##7,0);
    vr_tab_nrctrliq(8):=  NVL(rw_crawepr.nrctrliq##8,0);
    vr_tab_nrctrliq(9):=  NVL(rw_crawepr.nrctrliq##9,0);
    vr_tab_nrctrliq(10):= NVL(rw_crawepr.nrctrliq##10,0);
    
    vr_vlsaldo_refinanciado := 0;
    
    FOR vr_contador IN 1..10 LOOP
      
      IF vr_tab_nrctrliq(vr_contador) > 0 THEN
        
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_crabepr.nrdconta  
                       ,pr_nrctremp => vr_tab_nrctrliq(vr_contador));          
        FETCH cr_crapepr INTO rw_crapepr;
        
        IF cr_crapepr%NOTFOUND THEN
          
          -- Fecha Cursor
          CLOSE cr_crapepr;
          
          vr_cdcritic := 484; -- 484 - Contrato nao encontrado.
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
            
          -- Gera Log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro Tratado
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                        ' -' || vr_cdprogra || ' --> '  ||
                                                        vr_dscritic ||
                                                        ' Conta ' || gene0002.fn_mask_conta(rw_crabepr.nrdconta) ||
                                                        ' Contrato emprestimo ' || to_char(rw_crabepr.nrctremp) ||
                                                        ' Contrato a liquidar ' || to_char(vr_tab_nrctrliq(vr_contador)));
          --Zerar o Contrato
          vr_tab_nrctrliq(vr_contador):= 0;
          
          BEGIN
            --Atualizar Emprestimo
            UPDATE crawepr SET crawepr.nrctrliq##1  = vr_tab_nrctrliq(1)
                              ,crawepr.nrctrliq##2  = vr_tab_nrctrliq(2)
                              ,crawepr.nrctrliq##3  = vr_tab_nrctrliq(3)
                              ,crawepr.nrctrliq##4  = vr_tab_nrctrliq(4)
                              ,crawepr.nrctrliq##5  = vr_tab_nrctrliq(5)
                              ,crawepr.nrctrliq##6  = vr_tab_nrctrliq(6)
                              ,crawepr.nrctrliq##7  = vr_tab_nrctrliq(7)
                              ,crawepr.nrctrliq##8  = vr_tab_nrctrliq(8)
                              ,crawepr.nrctrliq##9  = vr_tab_nrctrliq(9)
                              ,crawepr.nrctrliq##10 = vr_tab_nrctrliq(10)
            WHERE crawepr.ROWID = rw_crawepr.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela crawepr. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END;                                           
          -- Proximo Registro
          CONTINUE;
        ELSE
          -- Fecha Cursor
          CLOSE cr_crapepr;
        END IF;
        
        -- Contrato Liquidado
        IF rw_crapepr.inliquid = 1 THEN
          CONTINUE;
        END IF;
        
        --Atribuir valores para variaveis
        vr_nrdconta := rw_crapepr.nrdconta;
        vr_nrctremp := rw_crapepr.nrctremp;
        vr_vlsdeved := rw_crapepr.vlsdeved;
        vr_vlsderel := vr_vlsdeved;
        vr_vljuracu := rw_crapepr.vljuracu;
        vr_dtultpag := rw_crapepr.dtultpag;
        vr_inliquid := rw_crapepr.inliquid;
        vr_qtprepag := rw_crapepr.qtprepag;
        vr_dtcalcul := NULL;
        
        IF rw_crapepr.tpemprst = 0 THEN  -- Somente Emprestimo Antigo
          IF vr_tab_inusatab  THEN
            
            IF vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
              vr_txdjuros := vr_tab_craplcr(rw_crabepr.cdlcremp).txdiaria;
            ELSE
              vr_cdcritic := 363; -- 363 - Linha nao cadastrada.
              vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
            
              -- Gera Log
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro Tratado
                                         pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                            ' -' || vr_cdprogra || ' --> '  ||
                                                            vr_dscritic ||
                                                            ' Linha: ' || to_char(rw_crapepr.cdlcremp));
              --Sair do programa
              RAISE vr_exc_saida;  
            END IF;         
          ELSE
            --Valor dos Juros
            vr_txdjuros := rw_crapepr.txjuremp;
          END IF;  
          
          -- Leitura de pagamentos de empréstimos { includes/lelem.i } 
          EMPR0001.pc_leitura_lem_car(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_nrdconta => rw_crapepr.nrdconta
                                 ,pr_nrctremp => rw_crapepr.nrctremp
                                 ,pr_dtcalcul => vr_dtcalcul
                                 ,pr_diapagto => vr_diapagto
                                 ,pr_txdjuros => vr_txdjuros
                                 ,pr_qtprecal => vr_qtprecal
                                 ,pr_qtprepag => vr_qtprepag
                                 ,pr_vlprepag => vr_vlprepag
                                 ,pr_vljurmes => vr_vljurmes
                                 ,pr_vljuracu => vr_vljuracu
                                 ,pr_vlsdeved => vr_vlsdeved
                                 ,pr_dtultpag => vr_dtultpag
                                     ,pr_qtmesdec => vr_qtmesdec
                                     ,pr_vlpreapg => vr_vlpreapg
                                 ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
          
          -- Verifica se ocorreram erros
          IF NVL(vr_dscritic, 0) <> 0 THEN
            
            -- Descricao da Critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            
            -- Gera Log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                          ' - Conta =  ' || TO_CHAR(rw_crapepr.nrdconta, 'FM9999G999G9') ||
                                                          ' - Contrato = ' || TO_CHAR(rw_crapepr.nrctremp, 'FM99G999G999'));
            
            -- Aborta a execucao do programa
            RAISE vr_exc_saida;
          END IF;
                        
          -- Saldo Devedor Acumulado
          vr_vlsderel := vr_vlsdeved;
          
        ELSIF rw_crapepr.tpemprst = 1 THEN -- Price Pre-Fixado
          
          -- Limpar tabelas de Memorias de Pagamentos de parcelas
          vr_tab_pgto_parcel.DELETE;
          vr_tab_calculado.DELETE;
          
          --Buscar pagamentos Parcela
          EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper        => rw_crapepr.cdcooper 
                                         ,pr_cdagenci        => rw_crapepr.cdagenci 
                                         ,pr_nrdcaixa        => 0 
                                         ,pr_cdoperad        => '1' 
                                         ,pr_nmdatela        => 'CRPS149' 
                                         ,pr_idorigem        => 1 -- Ayllos 
                                         ,pr_nrdconta        => rw_crapepr.nrdconta 
                                         ,pr_idseqttl        => 1 -- Seq titula
                                         ,pr_dtmvtolt        => rw_crapdat.dtmvtolt 
                                         ,pr_flgerlog        => 'S' 
                                         ,pr_nrctremp        => rw_crapepr.nrctremp 
                                         ,pr_dtmvtoan        => rw_crapdat.dtmvtoan 
                                         ,pr_nrparepr        => 0  /* Todas */
                                         ,pr_des_reto        => vr_des_erro -- Retorno OK / NOK
                                         ,pr_tab_erro        => vr_tab_erro -- Tabela com possíves erros
                                         ,pr_tab_pgto_parcel => vr_tab_pgto_parcel -- Tabela com registros de pagamentos
                                         ,pr_tab_calculado   => vr_tab_calculado); -- Tabela com totais calculados
          --Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            -- Se tem erro
            IF vr_tab_erro.count > 0 THEN
              vr_cdcritic := 0;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate
                                                                   ,'hh24:mi:ss') ||
                                                            ' - ' || vr_cdprogra ||
                                                            ' --> ' || vr_dscritic);
              
              --Sair do programa
              RAISE vr_exc_saida;
            
            END IF;
          END IF;
          
          --Se nao retornou dados pagamento
          IF vr_tab_pgto_parcel.COUNT = 0 THEN
            --Erro
            vr_cdcritic := 0;
            vr_dscritic := 'Pagamentos de parcelas nao enviados';
            -- Gera Log
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro Tratado
                                       pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                          ' -' || vr_cdprogra || ' --> '  ||
                                                          vr_dscritic ||
                                                          ' Conta ' || gene0002.fn_mask_conta(rw_crabepr.nrdconta) ||
                                                          ' Contrato ' || to_char(rw_crabepr.nrctremp));
            --Sair do programa
            RAISE vr_exc_saida;  
          END IF;
          
          --Se nao encontrou Saldo Calculado
          IF vr_tab_calculado.COUNT = 0 THEN
            vr_vlsdeved := 0;
            vr_vlsderel := 0;
          ELSE   
            --Buscar Primeiro indice
            vr_index_calculado:= vr_tab_calculado.FIRST;
            vr_vlsdeved := NVL(vr_tab_calculado(vr_index_calculado).vlsdeved, 0);
            vr_vlsderel := NVL(vr_tab_calculado(vr_index_calculado).vlsderel, 0);
          END IF;            
          
        ELSIF rw_crapepr.tpemprst = 2 THEN -- Pos-Fixado

          -- Inicializa
          vr_vlsdeved := 0;
          vr_vlsderel := 0;

          -- Busca as parcelas para pagamento
          EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => rw_crapepr.cdcooper
										  ,pr_cdprogra => vr_cdprogra
                                          ,pr_flgbatch => TRUE
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                          ,pr_nrdconta => rw_crapepr.nrdconta
                                          ,pr_nrctremp => rw_crapepr.nrctremp
                                          ,pr_dtefetiv => rw_crapepr.dtmvtolt
                                          ,pr_cdlcremp => rw_crapepr.cdlcremp
                                          ,pr_vlemprst => rw_crapepr.vlemprst
                                          ,pr_txmensal => rw_crapepr.txmensal
                                          ,pr_dtdpagto => rw_crapepr.dtprivencto
                                          ,pr_vlsprojt => rw_crapepr.vlsprojt
                                          ,pr_qttolatr => rw_crapepr.qttolatr
                                          ,pr_tab_parcelas => vr_tab_parcelas_pos
																					,pr_tab_calculado => vr_tab_calculado2
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            -- Gera Log
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic ||
                                                          ' - Conta =  ' || TO_CHAR(rw_crapepr.nrdconta, 'FM9999G999G9') ||
                                                          ' - Contrato = ' || TO_CHAR(rw_crapepr.nrctremp, 'FM99G999G999'));
            RAISE vr_exc_saida;
          END IF;
          
          -- Carregar as variveis de retorno
          vr_index_pos := vr_tab_parcelas_pos.FIRST;
          WHILE vr_index_pos IS NOT NULL LOOP
            -- Saldo para relatorios
            vr_vlsderel := vr_vlsderel + vr_tab_parcelas_pos(vr_index_pos).vlatupar;
            -- Saldo devedor total do emprestimo
            vr_vlsdeved := vr_vlsdeved + vr_tab_parcelas_pos(vr_index_pos).vlatrpag;
            -- Proximo indice
            vr_index_pos := vr_tab_parcelas_pos.NEXT(vr_index_pos);
          END LOOP;

        END IF;
          
        --Saldo Devedor Negativo
        IF nvl(vr_vlsdeved,0) <= 0 THEN
          -- proximo Registro
          CONTINUE;
        END IF;  
          
        --  Verifica se deve deixar saldo provisionado no chq. sal 
        IF vr_tab_indpagto = 0 THEN
          vr_dtrefere := vr_dtultdia - to_number(to_char(vr_dtultdia,'DD'));
        ELSE
          vr_dtrefere := vr_dtultdia;
        END IF;     

        --Valor do Desconto
        vr_vldescto := 0;
        vr_ant_vlsdeved := vr_vlsdeved; 

        --Criar os Lotes usados pelo Programa 
        pc_cria_lote (pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_nrdolote => 10026
                     ,pr_des_reto => vr_des_erro
                     ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          -- Finaliza Execução do Programa
          RAISE vr_exc_saida;
        END IF;
          
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10026);
        FETCH cr_craplot INTO rw_craplot;
        -- Apenas Fecha Cursor
        CLOSE cr_craplot;
          
        --IF  rw_crawepr.qtdialib > 0 THEN SD#622251
        IF (rw_crawepr.qtdialib > 0 AND rw_crawepr.tpemprst = 0) OR 
           (rw_crawepr.dtlibera > rw_crapdat.dtmvtolt AND rw_crawepr.tpemprst = 1) THEN

          -- Gera Credito Liq.Emprestimo + CPMF
          -- Calcula cpmf saldo devedor

          -- Creditar apenas no valor do emprestimo(se menor que saldo devedor)
          IF nvl(vr_vlsdeved,0) <= nvl(vr_vlemprst,0) THEN

            vr_vldacpmf:= ROUND(vr_vlsdeved  * vr_txcpmfcc,2);
            vr_valor:= nvl(vr_vlsdeved,0) + nvl(vr_vldacpmf,0);
          ELSE
            vr_valor:= vr_vlemprst;
          END IF;
              
          --Valor Sem CPMF
          vr_sem_cpmf:= ' ';

          -- Creditar valor emprestimo se menor que parcela     
          IF (nvl(vr_valor,0) + nvl(vr_valor_creditado,0)) > nvl(vr_vlemprst,0) THEN
            vr_sem_cpmf:= 'X';
            vr_valor:= nvl(vr_vlemprst,0) - nvl(vr_valor_creditado,0);
          END IF;
          --Valor Creditado                  
          vr_valor_creditado := nvl(vr_valor_creditado,0) + nvl(vr_valor,0);
               
          IF nvl(vr_valor,0) > 0 THEN
            BEGIN
              --Inserir Lancamento
              INSERT INTO craplcm
                 (dtmvtolt
                 ,cdagenci
                 ,cdbccxlt
                 ,nrdolote
                 ,nrdconta
                 ,nrdctabb
                 ,nrdctitg
                 ,nrdocmto
                 ,cdhistor
                 ,nrseqdig
                 ,cdcooper
                 ,cdpesqbb
                 ,vllanmto)
              VALUES
                 (rw_craplot.dtmvtolt
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,rw_crapepr.nrdconta
                 ,rw_crapepr.nrdconta
                 ,rw_crapepr.nrdconta
                 ,rw_crabepr.nrctremp + nvl(rw_craplot.nrseqdig,0) + 1
                 ,622 -- CR.EMPRESTIMO
                 ,nvl(rw_craplot.nrseqdig,0) + 1
                 ,pr_cdcooper
                 ,GENE0002.fn_mask(rw_crabepr.nrctremp,'99999999') || vr_sem_cpmf
                 ,vr_valor);
            EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na tabela craplcm (622) . ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
            END;  
          
            --Atualizar capa do Lote
            BEGIN
              UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_valor
                                ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_valor
                                ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
              WHERE craplot.ROWID = rw_craplot.ROWID
              RETURNING craplot.qtinfoln
                      , craplot.qtcompln
                      , craplot.nrseqdig
                   INTO rw_craplot.qtinfoln
                      , rw_craplot.qtcompln
                      , rw_craplot.nrseqdig;                   
              
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
                --Sair do programa
                RAISE vr_exc_saida;
            END;  

            -- Calcula Valor de Emprestimo (Liquidacoes + CPMF)  
            vr_valor_total := nvl(vr_valor_total,0) + nvl(vr_valor,0);
                           
          END IF; -- Fim vr_valor > 0 
        END IF; -- rw_crawepr.qtdialib > 0
          
        --Acumula o valor refinanciado para gravar na crapepr
        IF rw_crawepr.idquapro in(2,3,4) THEN
           vr_vlsaldo_refinanciado := vr_vlsaldo_refinanciado + vr_vlsderel;
        END IF;  
        -- Gera Debito Emprestimo(Saldo Devedor)
        BEGIN
          INSERT INTO craplcm
             (dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdctabb
             ,nrdctitg
             ,nrdocmto
             ,cdhistor
             ,nrseqdig
             ,cdpesqbb
             ,vllanmto
             ,cdcooper)
          VALUES
             (rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,rw_crapepr.nrdconta
             ,rw_crapepr.nrdconta
             ,GENE0002.fn_mask(rw_crapepr.nrdconta,'99999999')
             ,GENE0002.fn_mask(rw_crapepr.nrctremp || TO_CHAR(sysdate,'SSSSS') || (nvl(rw_craplot.nrseqdig,0) + 1),'999999999999999') --GENE0002.fn_mask(rw_crapepr.nrctremp,'99999999')
             ,282 -- DB.EMPRESTIMO
             ,nvl(rw_craplot.nrseqdig,0) + 1
             ,GENE0002.fn_mask(rw_crabepr.nrctremp,'99999999')
             ,vr_vlsderel
             ,pr_cdcooper);
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplcm (282) . ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
        END; 
            
        --Diminuir saldo
        vr_vlrsaldo := nvl(vr_vlrsaldo,0) - nvl(vr_vlsdeved,0);
        --Acumular Total Liquido
        vr_totliqui := nvl(vr_totliqui,0) + nvl(vr_vlsderel,0);
        
        --Atualizar capa do Lote
        BEGIN
          UPDATE craplot SET craplot.vlinfodb = nvl(craplot.vlinfodb,0) + vr_vlsderel
                            ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + vr_vlsderel
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END;
          
        -- Formata conta integracão com digito convertido (Antiga fontes/digbbx.p)
        gene0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_crapepr.nrctremp,
                                       pr_dscalcul => vr_dsdctitg,
                                       pr_stsnrcal => vr_stsnrcal,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);
                                                      
        IF vr_flgcrcta = 1 THEN -- TRUE
          
          BEGIN
            --  Registro das liquidacoes
            INSERT INTO craprej
               (nrdconta
               ,nraplica
               ,cdagenci
               ,nrdolote
               ,nrdctabb
               ,nrdctitg
               ,dtmvtolt
               ,cdhistor
               ,vllanmto
               ,cdpesqbb
               ,nrseqdig
               ,cdcooper)
            VALUES
               (rw_crabepr.nrdconta 
               ,rw_crabepr.nrctremp
               ,rw_crapass.cdagenci
               ,rw_crapass.cdsecext
               ,rw_crapepr.nrctremp
               ,vr_dsdctitg
               ,rw_crapepr.dtmvtolt
               ,rw_crapepr.cdlcremp
               ,vr_vlsdeved
               ,'CRPS173_EPR'
               ,2
               ,pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na tabela craprej. '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END;
        ELSE
          vr_dscritic := 'ATENCAO: Emprestimo liquidado com linha de credito indevida!' ||
                         'Conta: ' || to_char(rw_crapepr.nrdconta) || 
                         ' Contrato: ' || to_char(rw_crapepr.nrctremp);
      
          -- Gera Log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro Tratado
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                        ' -' || vr_cdprogra || ' --> '  ||
                                                        vr_dscritic);
        END IF;
          

        --Criar os Lotes usados pelo Programa 
        pc_cria_lote (pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_nrdolote => 8453
                     ,pr_des_reto => vr_des_erro
                     ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          -- Finaliza Execução do Programa
          RAISE vr_exc_saida;
        END IF;

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8453);
        FETCH cr_craplot INTO rw_craplot;
        -- Apenas Fecha Cursor
        CLOSE cr_craplot;
        
        IF rw_crapepr.tpemprst = 0 THEN  -- Somente emprestimo antigo
          
          BEGIN
            INSERT INTO craplem
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,nrdconta
               ,nrdocmto
               ,cdhistor
               ,nrseqdig
               ,nrctremp
               ,txjurepr
               ,vlpreemp
               ,vllanmto
               ,dtpagemp
               ,cdcooper)
            VALUES
               (rw_craplot.dtmvtolt
               ,rw_craplot.cdagenci
               ,rw_craplot.cdbccxlt
               ,rw_craplot.nrdolote
               ,rw_crapepr.nrdconta
               ,nvl(rw_craplot.nrseqdig,0) + 1
               ,095
               ,nvl(rw_craplot.nrseqdig,0) + 1
               ,rw_crapepr.nrctremp
               ,vr_txdjuros
               ,rw_crapepr.vlpreemp
               ,vr_vlsdeved
               ,vr_tab_dtcalcul
               ,pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na tabela craplem (095). '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END;  
          
          --Atualizar capa do Lote
          BEGIN
            UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_vlsdeved
                              ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_vlsdeved
                              ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                              ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                              ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
            WHERE craplot.ROWID = rw_craplot.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END; 

          -- Caso pagamento seja menor que data atual
          IF rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt THEN

            -- Procedure para lancar Multa e Juros de Mora para o TR
            EMPR0009.pc_efetiva_pag_atraso_tr(pr_cdcooper => pr_cdcooper
                                             ,pr_cdagenci => rw_crapepr.cdagenci
                                             ,pr_nrdcaixa => 0
                                             ,pr_cdoperad => '1'
                                             ,pr_nmdatela => vr_cdprogra
                                             ,pr_idorigem => 1
                                             ,pr_nrdconta => rw_crapepr.nrdconta
                                             ,pr_nrctremp => rw_crapepr.nrctremp
                                             ,pr_vlpreapg => vr_vlpreapg
                                             ,pr_qtmesdec => vr_qtmesdec
                                             ,pr_qtprecal => vr_qtprecal
                                             ,pr_vlpagpar => vr_vlpreapg
                                             ,pr_cdhismul => vr_cdhismul
                                             ,pr_vldmulta => vr_vldmulta
                                             ,pr_cdhismor => vr_cdhismor
                                             ,pr_vljumora => vr_vljumora
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
            -- Se houve retorno de erro
            IF vr_dscritic IS NOT NULL THEN
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic );
              -- Reseta variaveis
              vr_cdcritic := 0;
              vr_dscritic := NULL;
            END IF;

          END IF;

          -- Indicador de liquidacao do emprestimo.
          IF nvl(vr_ant_vlsdeved,0) > nvl(vr_vlsdeved,0) THEN 
            vr_inliqemp := 0;
          ELSE 
            vr_inliqemp := 1;
          END IF;  
          
          -- Atualiza o Indicador de Liquidacao do Emprestimo.
          BEGIN
            UPDATE crapepr SET crapepr.dtultpag = rw_crapdat.dtmvtolt
                              ,crapepr.txjuremp = vr_txdjuros
                              ,crapepr.inliquid = vr_inliqemp
            WHERE crapepr.ROWID = rw_crapepr.ROWID
            RETURNING crapepr.dtultpag,
                      crapepr.txjuremp,
                      crapepr.inliquid
            INTO rw_crapepr.dtultpag,
                 rw_crapepr.txjuremp,
                 rw_crapepr.inliquid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualiza a tabela crapepr. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END;
                                                        
          IF rw_crapepr.inliquid = 1 THEN -- Liquidado
            
            -- Desativar o Rating associado a esta operaçao
            rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                       ,pr_cdagenci   => 0                   --> Código da agência
                                       ,pr_nrdcaixa   => 0                   --> Número do caixa
                                       ,pr_cdoperad   => '1'                 --> Código do operador
                                       ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                       ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                       ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                       ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                       ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                       ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                       ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                       ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                       ,pr_nmdatela   => 'CRPS149'           --> Nome datela conectada
                                       ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                       ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                       ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros

            --------------------------------------------------------------------
            ----- Na versão progress não testava se retornou erro aqui...  ----
            --------------------------------------------------------------------
            IF vr_des_reto = 'NOK' THEN
              --Se tem erro na tabela 
              IF vr_tab_erro.COUNT = 0 THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro na rati0001.pc_desativa_rating.';
              ELSE
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              END IF;    
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
              
            --Solicitar a Baixa do gravame
            GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                                 ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                                 ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                                 ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                                 ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                                 ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                                 ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica
            
            --------------------------------------------------------------------
            ----- Na versão progress não testava se retornou erro aqui...  ----
            --------------------------------------------------------------------
            IF vr_des_reto = 'NOK' THEN
              --Se tem erro na tabela 
              IF vr_tab_erro.COUNT > 0 THEN
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              END IF;    
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
          END IF;
          /*
          -- 1 - Para debitar no dia da Folha
          -- 0 - Para debitar em C/C
          */
          IF rw_crapepr.flgpagto = 1 THEN -- TRUE
            --Valor Aviso Debito
            vr_vlavsdeb := vr_vlsdeved; -- rw_craplem.vllanmto
            IF nvl(vr_vlavsdeb,0) > 0 THEN
              --Selecionar Avisos
              FOR rw_crapavs IN cr_crapavs(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapepr.nrdconta
                                          ,pr_nrctremp => rw_crapepr.nrctremp) LOOP
                                          
                IF rw_crapepr.inliquid = 1 THEN     
                  vr_avs_vldebito := nvl(rw_crapavs.vllanmto,0);
                ELSE
                  IF (nvl(rw_crapavs.vldebito,0) + nvl(vr_vlavsdeb,0)) <= nvl(rw_crapavs.vllanmto,0) THEN
                    vr_avs_vldebito := nvl(rw_crapavs.vldebito,0) + nvl(vr_vlavsdeb,0);
                    vr_vlavsdeb := 0;   
                  ELSE
                    vr_vlavsdeb := nvl(vr_vlavsdeb,0) + (nvl(rw_crapavs.vldebito,0) - nvl(rw_crapavs.vllanmto,0));
                    vr_avs_vldebito := nvl(rw_crapavs.vllanmto,0);
                  END IF;         
                END IF;
                --Valor Diferenca                 
                vr_avs_vlestdif := nvl(vr_avs_vldebito,0) - nvl(rw_crapavs.vllanmto,0);
                                                                 
                IF nvl(vr_avs_vldebito,0) < nvl(rw_crapavs.vllanmto,0) THEN
                  vr_avs_insitavs := 0;
                ELSE
                  vr_avs_insitavs := 1;
                END IF;
                
                --Atualizar aviso
                BEGIN
                  UPDATE crapavs SET crapavs.vldebito = vr_avs_vldebito
                                    ,crapavs.vlestdif = vr_avs_vlestdif
                                    ,crapavs.insitavs = vr_avs_insitavs
                  WHERE crapavs.ROWID = rw_crapavs.ROWID; 
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualiza a tabela crapavs. ' || SQLERRM;
                    --Sair do programa
                    RAISE vr_exc_saida;                    
                END;      
              END LOOP; --rw_crapavs
            END IF; --nvl(vr_vlavsdeb,0) > 0
          END IF; --rw_crapepr.flgpagto = 1             

        ELSIF rw_crapepr.tpemprst = 1 THEN  -- Price Pre-Fixado

          /* Verificar se o contrato que esta sendo liquidado está na tabela temporaria */
          --Montar Indice acesso
          vr_index_crawepr := lpad(rw_crapepr.cdcooper, 10,'0') ||
                              lpad(rw_crapepr.nrdconta, 10,'0') ||
                              lpad(rw_crapepr.nrctremp, 10,'0');
          IF NOT vr_tab_crawepr.EXISTS(vr_index_crawepr) THEN
            -- Leitura da proposta do emprestimo
            OPEN cr_crawepr(pr_cdcooper => rw_crapepr.cdcooper
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_nrctremp => rw_crapepr.nrctremp);
            FETCH cr_crawepr INTO rw_crawepr1;
              
            -- Se nao encontrou proposta
            IF cr_crawepr%NOTFOUND THEN
              vr_cdcritic:= 535; -- 535 - Proposta Não Encontrada.
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic) ||
                            gene0002.fn_mask(rw_crapepr.nrdconta,'zzzz.zzz.9') ||
                            gene0002.fn_mask(rw_crapepr.nrctremp,'zzz.zzz.zz9');
              -- Fechar Cursor
              CLOSE cr_crawepr;
              -- Gera Log
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro Tratado
                                         pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                            ' -' || vr_cdprogra || ' --> '  ||
                                                            vr_dscritic);
                
              --Sair do programa
              RAISE vr_exc_saida;
            END IF;
            -- Fechar Cursor
            CLOSE cr_crawepr; 
            --Popular tabela com informacoes encontradas                   
            vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr1.dtlibera;
            vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr1.tpemprst;
          END IF;  
    
          --Efetuar a Liquidacao do Emprestimo
          empr0001.pc_efetua_liquidacao_empr(pr_cdcooper => rw_crapepr.cdcooper --> Cooperativa conectada
                                            ,pr_cdagenci => 0                   --> Código da agência
                                            ,pr_nrdcaixa => 0                   --> Número do caixa
                                            ,pr_cdoperad => '1'                 --> Código do Operador
                                            ,pr_nmdatela => vr_cdprogra         --> Nome da tela
                                            ,pr_idorigem => 1                   --> Id do módulo de sistema
                                            ,pr_cdpactra => rw_crapepr.cdagenci --> P.A. da transação
                                            ,pr_nrdconta => rw_crapepr.nrdconta --> Número da conta
                                            ,pr_idseqttl => 1                   --> Seq titular
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                            ,pr_flgerlog => 'S'                 --> Indicador S/N para geração de log
                                            ,pr_nrctremp => rw_crapepr.nrctremp --> Número do contrato de empréstimo
                                            ,pr_dtmvtoan => rw_crapdat.dtmvtoan --> Data Movimento Anterior
                                            ,pr_ehprcbat => 'S'                 --> Indicador Processo Batch (S/N)
                                            ,pr_tab_pgto_parcel => vr_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                            ,pr_tab_crawepr => vr_tab_crawepr   --> Tabela com Contas e Contratos
                                            ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                            ,pr_des_erro => vr_des_erro         --> Retorno OK / NOK
                                            ,pr_tab_erro => vr_tab_erro);       --> Tabela de Erros
                                       
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Se possui erro na tabela
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_dscritic := 'Erro na liquidacao';
            END IF;    
            --Concatenar conta e contrato
            vr_dscritic := vr_dscritic ||
                           ' Conta: '||gene0002.fn_mask_conta(rw_crapepr.nrdconta)||
                           ' Contrato: '||gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9');
            --Sair do programa
            RAISE vr_exc_saida;
          END IF;

        ELSIF rw_crapepr.tpemprst = 2 THEN  -- Pos-Fixado

          -- Limpa PLTable
          vr_tab_price.DELETE;
          
          -- Carregar as variveis de retorno
          vr_index_pos := vr_tab_parcelas_pos.FIRST;
          WHILE vr_index_pos IS NOT NULL LOOP
            -- Chama pagamento da parcela
            EMPR0011.pc_gera_pagto_pos(pr_cdcooper  => rw_crapepr.cdcooper
									  ,pr_cdprogra => vr_cdprogra
                                      ,pr_dtcalcul  => rw_crapdat.dtmvtolt
                                      ,pr_nrdconta  => rw_crapepr.nrdconta
                                      ,pr_nrctremp  => rw_crapepr.nrctremp
                                      ,pr_nrparepr  => vr_tab_parcelas_pos(vr_index_pos).nrparepr
                                      ,pr_vlpagpar  => vr_tab_parcelas_pos(vr_index_pos).vlatrpag
                                      ,pr_idseqttl  => 1
                                      ,pr_cdagenci  => rw_crapepr.cdagenci
                                      ,pr_cdpactra  => rw_crapepr.cdagenci
                                      ,pr_nrdcaixa  => 0
                                      ,pr_cdoperad  => '1'
                                      ,pr_nrseqava  => 0
                                      ,pr_idorigem  => 7 -- BATCH
                                      ,pr_nmdatela  => vr_cdprogra
                                      ,pr_tab_price => vr_tab_price
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);
            -- Se houve erro
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            -- Proximo index
            vr_index_pos := vr_tab_parcelas_pos.NEXT(vr_index_pos);
          END LOOP;

        END IF;
      END IF; -- Fim vr_tab_crawepr(vr_contador).nrctrliq > 0
    END LOOP; -- vr_contador 1..10
    
    -- PJ450 - Obtem saldo do dia (Mário-AMcom)
    IF NVL(rw_crawepr.nrliquid,0) > 0 THEN
    
      --Limpar tabela erros e saldos
      vr_tab_erro.DELETE;
      vr_tab_saldo.DELETE;

      --> Verifica se possui saldo para fazer a operacao 
      EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => rw_crabepr.cdcooper
                                  ,pr_rw_crapdat => rw_crapdat
                                  ,pr_cdagenci   => rw_crapass.cdagenci
                                  ,pr_nrdcaixa   => 0
                                  ,pr_cdoperad   => '1'
                                  ,pr_nrdconta   => rw_crabepr.nrdconta
                                  ,pr_vllimcre   => 0
                                  ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan,I-dtvmtolt)
                                  ,pr_flgcrass   => FALSE
                                  ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                  ,pr_des_reto   => vr_dscritic
                                  ,pr_tab_sald   => vr_tab_saldo
                                  ,pr_tab_erro   => vr_tab_erro);

      --Se ocorreu erro
      IF vr_dscritic = 'NOK' THEN
        vr_dscritic := NULL;
      ELSE
        --Verificar o saldo retornado
        IF vr_tab_saldo.Count = 0 THEN
          --Desconsidera o saldo
          NULL;
        ELSE
          -- Posiciona no primeiro registro da tabela temporária
          vr_indsaldo := vr_tab_saldo.first;
        
          --Se o saldo nao for suficiente
          IF nvl(vr_tab_saldo(vr_indsaldo).vlsddisp,0) <= 0 THEN
            vr_vlsaldo_refinanciado := vr_vlemprst;
          ELSE
            IF vr_vlemprst >= nvl(vr_tab_saldo(vr_indsaldo).vlsddisp,0) then
              vr_vlsaldo_refinanciado :=  vr_vlemprst - nvl(vr_tab_saldo(vr_indsaldo).vlsddisp,0);
            ELSE
              vr_vlsaldo_refinanciado :=  0;
            END IF;
		  END IF;
        END IF;
        vr_dscritic := NULL;
      END IF;
    END IF;

    -- Chama a rotina que grava o valor refinanciado na crapepr
    IF vr_vlsaldo_refinanciado > 0 THEN
       RISC0004.pc_gravar_saldo_refin(pr_cdcooper             => pr_cdcooper
                                     ,pr_nrdconta             => rw_crabepr.nrdconta
                                     ,pr_nrctremp             => rw_crabepr.nrctremp
                                     ,pr_devedor_calculado    => vr_vlsaldo_refinanciado
                                     ,pr_dscritic             => vr_dscritic);
       
       IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
       END IF;                              
    END IF;
    
    IF (rw_crawepr.qtdialib > 0 AND rw_crawepr.tpemprst = 0) OR 
       (rw_crawepr.dtlibera > rw_crapdat.dtmvtolt AND rw_crawepr.tpemprst = 1) THEN
        
      -- Credita Valor do Emprestimo(opcao Liquidacoes)                
      -- Gera Credito Emprestimo - (Liq.Emprestimo + CPMF)

      vr_valor_total := nvl(vr_vlemprst,0) - nvl(vr_valor_total,0);
            
      --Se possui valor total
      IF vr_valor_total > 0 THEN 

        --Criar os Lotes usados pelo Programa 
        pc_cria_lote (pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_nrdolote => 10027
                     ,pr_des_reto => vr_des_erro
                     ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          -- Finaliza Execução do Programa
          RAISE vr_exc_saida;
        END IF;
        
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --SD#641111
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10027);
        FETCH cr_craplot INTO rw_craplot;
        -- Apenas Fecha Cursor
        CLOSE cr_craplot;
        
        BEGIN
          --Inserir Lancamento
          INSERT INTO craplcm
             (cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdctabb
             ,nrdctitg
             ,nrdocmto
             ,cdhistor
             ,nrseqdig
             ,cdpesqbb
             ,vllanmto)
          VALUES  
             (pr_cdcooper
             ,rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,rw_crabepr.nrdconta
             ,rw_crabepr.nrdconta
             ,GENE0002.FN_MASK(rw_crabepr.nrdconta,'99999999')
             ,rw_crabepr.nrctremp
             ,2 -- Credito Bloqueado de Emprestimo
             ,nvl(rw_craplot.nrseqdig,0) + 1
             ,GENE0002.FN_MASK(rw_crabepr.nrdconta,'99999999')
             ,vr_valor_total);
        EXCEPTION
        WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir na tabela craplcm (2). '||SQLERRM;
         --Sair do programa
         RAISE vr_exc_saida;
        END;
          
        --Atualizar capa do Lote
        BEGIN
          UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_valor_total
                            ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_valor_total
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END;   

        BEGIN
          --Depositos Bloqueados
          INSERT INTO crapdpb
             (nrdconta
             ,dtliblan
             ,cdhistor
             ,nrdocmto
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,vllanmto
             ,inlibera
             ,cdcooper)
          VALUES  
             (rw_crabepr.nrdconta
             ,vr_dtliblan
             ,2
             ,rw_crabepr.nrctremp
             ,rw_crapdat.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,vr_valor_total
             ,1
             ,pr_cdcooper);
        EXCEPTION
        WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir na tabela crapdpb. '||SQLERRM;
         --Sair do programa
         RAISE vr_exc_saida;
        END;
      END IF; --vr_valor_total > 0
    END IF;

    vr_vliofaux := 0;
    
    /*  Cobranca do IOF de emprestimo  */
    IF vr_flgtaiof = 1 AND 
       --> Caso o iof não seja financiado junto com o emprestimo
       rw_crabepr.idfiniof = 0 THEN -- TRUE
      
      -- Valor do empréstimo
      --vr_vlemprst := vr_vlemprst;
    
      -- Se o tipo do empréstimo for TR e for empréstimo de refinanciamento, deve
      -- passar como valor para a rotina de IOF, o valor do emprestimo decrementando 
      -- o valor de refinanciado
      IF NVL(vr_totliqui,0) > 0 AND rw_crabepr.tpemprst = 0 THEN
        vr_vlemprst := GREATEST(rw_crabepr.vlemprst - vr_totliqui, 0);
      END IF;
    
      vr_qtdias_carencia := 0; -- Inicializa

      --Novo cálculo do IOF
      vr_qtdiaiof := rw_crabepr.dtdpagto - rw_crapdat.dtmvtolt;
      
      /* Busca o tipo de bem, para usar no cálculo da isenção (somente APARTAMENTO, CASA e MOTO). Pega somente o primeiro (já está ordenado), 
      pois se for "APARTAMENTO" ou "CASA", zera todos os valores de IOF (principal, adicional e complementar). Já se for "MOTO", 
      zera apenas IOF princial e complementar */
      /*OPEN cr_crapbpr_iof(pr_cdcooper => pr_cdcooper, pr_nrdconta => rw_crabepr.nrdconta, pr_nrctremp => rw_crabepr.nrctremp);
      FETCH cr_crapbpr_iof INTO rw_crapbpr_iof;
            
      vr_dscatbem := NULL;
      IF cr_crapbpr_iof%FOUND THEN
        vr_dscatbem := rw_crapbpr_iof.dscatbem || '|';
      END IF;
      CLOSE cr_crapbpr_iof;*/
      
      -- Se for Pos-Fixado e existir carencia
      IF rw_crabepr.tpemprst = 2 AND vr_tab_carencia.EXISTS(rw_crawepr.idcarenc) THEN
        vr_qtdias_carencia := vr_tab_carencia(rw_crawepr.idcarenc);
      END IF;
    
     /* TIOF0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper                  
                                 ,pr_nrdconta => rw_crabepr.nrdconta          
                                 ,pr_nrctremp => rw_crabepr.nrctremp    
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt          
                                 ,pr_inpessoa => rw_crapass.inpessoa          
                                 ,pr_cdfinemp => rw_crabepr.cdfinemp
                                 ,pr_cdlcremp => rw_crabepr.cdlcremp          
                                 ,pr_qtpreemp => rw_crabepr.qtpreemp          
                                 ,pr_vlpreemp => rw_crabepr.vlpreemp          
                                 ,pr_vlemprst => vr_vlemprst                  
                                 ,pr_dtdpagto => rw_crabepr.dtdpagto          
                                 ,pr_dtlibera => rw_crapdat.dtmvtolt          
                                 ,pr_tpemprst => rw_crabepr.tpemprst          
                                 ,pr_dtcarenc        => rw_crawepr.dtcarenc
                                 ,pr_qtdias_carencia => vr_qtdias_carencia
                                 ,pr_idgravar        => 'N'
                                 ,pr_vlpreclc => vr_vlpreclc
                                 ,pr_valoriof => vr_vliofaux                  
                                 ,pr_vliofpri => vr_vliofpri_tmp
                                 ,pr_vliofadi => vr_vliofadi_tmp
                                 ,pr_dscatbem => vr_dscatbem
                                 ,pr_idfiniof => rw_crabepr.idfiniof
                                 ,pr_flgimune => vr_flgimune
                                 ,pr_dscritic => vr_dscritic);                
                                                                             
      IF vr_dscritic IS NOT NULL THEN                                        
        RAISE vr_exc_saida;
      END IF;
      */
      
      vr_vliofaux     := nvl(rw_crabepr.vliofepr,0);
      vr_vliofadi_tmp := nvl(rw_crabepr.vliofadc,0);
      vr_vliofpri_tmp := vr_vliofaux - vr_vliofadi_tmp;
      
      -- compõe histórico
      
      if  rw_crabepr.idfiniof = 0 -- Não Financia IOF
      and rw_crabepr.tpemprst = 0 then --  Emprestimo TR
          vr_cdhistor := 2310;
      end if;
      
      if  rw_crabepr.idfiniof = 0 -- Não Financia IOF
      and rw_crabepr.tpemprst = 1 then --  Emprestimo PP
          if vr_tab_craplcr(rw_crabepr.cdlcremp).dsoperac = 'FINANCIAMENTO' then
             vr_cdhistor := 2309;
          else
             vr_cdhistor := 2308;
          end if;        
      end if;
      
      if  rw_crabepr.idfiniof = 0  -- Não Financia IOF
      and rw_crabepr.tpemprst = 2 then --  Emprestimo Pós
          if vr_tab_craplcr(rw_crabepr.cdlcremp).dsoperac = 'FINANCIAMENTO' then
             vr_cdhistor := 2538;
          else
             vr_cdhistor := 2537;
          end if;        
      end if;
      
      if nvl(vr_cdhistor,0) = 0 then
         vr_cdhistor := 322; -- assume o antigo histórico.
      end if;
      
      --  Cobranca do IOF de emprestimo
      IF vr_flgtaiof = 1 AND vr_vliofaux > 0 THEN
         
        --Criar os Lotes usados pelo Programa 
        pc_cria_lote (pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_nrdolote => 10025
                     ,pr_des_reto => vr_des_erro
                     ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          -- Finaliza Execução do Programa
          RAISE vr_exc_saida;
        END IF;
      
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10025);
        FETCH cr_craplot INTO rw_craplot;
        -- Apenas Fecha Cursor
        CLOSE cr_craplot;
        
        --Tem Saldo
        IF nvl(vr_vlrsaldo,0) > 0  THEN
          BEGIN
            --Inserir Lancamento          
            INSERT INTO craplcm
               (cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,nrdconta
               ,nrdctabb
               ,nrdctitg
               ,nrdocmto
               ,cdhistor
               ,nrseqdig
               ,cdpesqbb
               ,vllanmto)
            VALUES  
               (pr_cdcooper
               ,rw_craplot.dtmvtolt
               ,rw_craplot.cdagenci
               ,rw_craplot.cdbccxlt
               ,rw_craplot.nrdolote
               ,rw_crabepr.nrdconta
               ,rw_crabepr.nrdconta
               ,GENE0002.FN_MASK(rw_crabepr.nrdconta,'99999999')
               ,GENE0002.fn_mask(rw_crabepr.nrctremp || TO_CHAR(sysdate,'SSSSS') || (nvl(rw_craplot.nrseqdig,0) + 1),'999999999999999') --, rw_crabepr.nrctremp
               ,vr_cdhistor --322 -- IOF Sobre Emprestimo.
               ,nvl(rw_craplot.nrseqdig,0) + 1
                -- controlar para que mantenha 14 posicoes para cada valor devido a 
                -- outros programas lerem esse valor(crps501)
               ,lpad(to_char(vr_vlrsaldo        ,'fm999g999g990d00'),14,' ') ||
                lpad(to_char(rw_crabepr.vlemprst,'fm999g999g990d00'),14,' ') || 
                lpad(to_char(vr_totliqui        ,'fm999g999g990d00'),14,' ')
               ,vr_vliofaux);
          EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplcm (322). ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
          END;
           
          --Atualizar capa do Lote
          BEGIN
            UPDATE craplot SET craplot.vlinfodb = nvl(craplot.vlinfodb,0) + vr_vliofaux
                              ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + vr_vliofaux
                              ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                              ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                              ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
            WHERE craplot.ROWID = rw_craplot.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END; 
          
          -- Projeto 410 - Insere IOF na tabela de controle
          TIOF0001.pc_insere_iof(pr_cdcooper => pr_cdcooper
                               , pr_nrdconta => rw_crabepr.nrdconta
                               , pr_dtmvtolt => rw_crapdat.dtmvtolt
                               , pr_tpproduto => 1
                               , pr_nrcontrato => rw_crabepr.nrctremp
                               , pr_idlautom => NULL
                               , pr_dtmvtolt_lcm => rw_craplot.dtmvtolt
                               , pr_cdagenci_lcm => rw_craplot.cdagenci
                               , pr_cdbccxlt_lcm => rw_craplot.cdbccxlt
                               , pr_nrdolote_lcm => rw_craplot.nrdolote
                               , pr_nrseqdig_lcm => nvl(rw_craplot.nrseqdig,0) + 1
                               , pr_vliofpri => vr_vliofpri_tmp
                               , pr_vliofadi => vr_vliofadi_tmp
                               , pr_vliofcpl => 0
                               , pr_flgimune => vr_flgimune
                               , pr_cdcritic => vr_cdcritic
                               , pr_dscritic => vr_dscritic);
                               
           if vr_dscritic is not null then
              vr_dscritic := 'Erro ao atualiza tabela de controle IOF. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
           end if; 
           
          -- Atualiza IOF pago e base de calculo no crapcot
          OPEN cr_crapcot(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crabepr.nrdconta);
          FETCH cr_crapcot INTO rw_crapcot;
          
          -- Se não encontrou
          IF cr_crapcot%NOTFOUND THEN
            
            -- Fecha Cursor
            CLOSE cr_crapcot;
            
            vr_cdcritic := 169; -- 169 - Associado sem registro de cotas!!! - Erro do sistema!!!!
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      
            -- Gera Log
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro Tratado
                                       pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                          ' -' || vr_cdprogra || ' --> '  ||
                                                          vr_dscritic);
            --Sair do programa
            RAISE vr_exc_saida;  
          ELSE
             -- Fecha Cursor
            CLOSE cr_crapcot;
            
            -- Atualiza cota 
          BEGIN
              UPDATE crapcot SET crapcot.vliofepr = nvl(crapcot.vliofepr,0) + nvl(vr_vliofaux,0)
                                ,crapcot.vlbsiepr = nvl(crapcot.vlbsiepr,0) + nvl(vr_vlrsaldo,0)
              WHERE crapcot.ROWID = rw_crapcot.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualiza tabela crapcot. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_saida;
          END;         
          END IF;
        END IF;
        
      --> caso não cobrou IOF pois é imune, mas possui valor principal ou adicional
      ELSIF vr_flgimune = 1 AND
            ( vr_vliofpri_tmp > 0 OR 
              vr_vliofadi_tmp > 0) THEN
              
        -- Projeto 410 - Insere IOF na tabela de controle
        TIOF0001.pc_insere_iof(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => rw_crabepr.nrdconta
                             , pr_dtmvtolt => rw_crapdat.dtmvtolt
                             , pr_tpproduto => 1
                             , pr_nrcontrato => rw_crabepr.nrctremp
                             , pr_idlautom => NULL
                             , pr_dtmvtolt_lcm => NULL
                             , pr_cdagenci_lcm => NULL
                             , pr_cdbccxlt_lcm => NULL
                             , pr_nrdolote_lcm => NULL
                             , pr_nrseqdig_lcm => NULL
                             , pr_vliofpri => vr_vliofpri_tmp
                             , pr_vliofadi => vr_vliofadi_tmp
                             , pr_vliofcpl => 0
                             , pr_flgimune => vr_flgimune
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);
                               
         if vr_dscritic is not null then
            vr_dscritic := 'Erro ao atualiza tabela de controle IOF. ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
         end if; 
      
      END IF;
    --> caso financia IOF deve adicionar valor na crapcot  
    ELSIF rw_crabepr.idfiniof = 1 AND 
          rw_crabepr.vliofepr > 0 THEN
                  
          -- Atualiza IOF pago e base de calculo no crapcot
          OPEN cr_crapcot(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crabepr.nrdconta);
          FETCH cr_crapcot INTO rw_crapcot;
          
          -- Se não encontrou
          IF cr_crapcot%NOTFOUND THEN
            
            -- Fecha Cursor
            CLOSE cr_crapcot;
            
            vr_cdcritic := 169; -- 169 - Associado sem registro de cotas!!! - Erro do sistema!!!!
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      
            -- Gera Log
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro Tratado
                                       pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                          ' -' || vr_cdprogra || ' --> '  ||
                                                          vr_dscritic);
            --Sair do programa
            RAISE vr_exc_saida;  
          ELSE
             -- Fecha Cursor
            CLOSE cr_crapcot;
            
            -- Atualiza cota 
            BEGIN
          UPDATE crapcot SET crapcot.vliofepr = nvl(crapcot.vliofepr,0) + nvl(rw_crabepr.vliofepr,0)
                                ,crapcot.vlbsiepr = nvl(crapcot.vlbsiepr,0) + nvl(vr_vlrsaldo,0)
              WHERE crapcot.ROWID = rw_crapcot.ROWID;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualiza tabela crapcot. ' || SQLERRM;
                --Sair do programa
                RAISE vr_exc_saida;
            END;  
          END IF;
    END IF;
    
    --Atualizar restart (somente se existir)
    IF vr_inrestar > 0 THEN
      BEGIN

        UPDATE crapres 
           SET crapres.nrdconta = rw_crabepr.nrdconta
              ,crapres.dsrestar = to_char(rw_crabepr.dtmvtolt,'DD/MM/YYYY')          || ' ' ||
                                  GENE0002.fn_mask(rw_crapass.cdagenci,'999')        || ' ' ||
                                  GENE0002.fn_mask(rw_crabepr.cdbccxlt,'999')        || ' ' ||
                                  GENE0002.fn_mask(rw_crabepr.nrdolote,'999999')     || ' ' ||
                                  GENE0002.fn_mask(rw_crabepr.nrctremp,'99999999')
         WHERE crapres.cdcooper = pr_cdcooper
           AND  upper(crapres.cdprogra) = vr_cdprogra;

        --Se nao atualizou nada
        IF SQL%ROWCOUNT = 0 THEN
           --Buscar mensagem de erro da critica
           vr_cdcritic := 151; -- 151 - Registro de restart nao encontrado.
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           --Sair do programa
           RAISE vr_exc_saida;
         END IF;

      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar tabela crapres. '||SQLERRM;
        --Sair do programa
        RAISE vr_exc_saida;
      END;
      -- Salva Registro processado
      COMMIT;
      
    END IF;    
  END LOOP; --  Fim do FOR EACH e da transacao

  -- CDC Prj. 402
  IF pr_cdcooper = 3 THEN
    FOR rw_rapassecdc_compartilhado IN cr_rapassecdc_compartilhado(pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      
      --Criar os Lotes usados pelo Programa 
      pc_cria_lote (pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_nrdolote => 650008
                   ,pr_des_reto => vr_des_erro
                   ,pr_dscritic => vr_dscritic);

      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        -- Finaliza Execução do Programa
        RAISE vr_exc_saida;
      END IF;

      -- CRÉDITO
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 650008);

      FETCH cr_craplot INTO rw_craplot;
      -- Apenas Fecha Cursor
      CLOSE cr_craplot;
         
      -- criar lançamento para a coopeartiva do lojista    
      OPEN cr_crapcop(pr_cdcooper => rw_rapassecdc_compartilhado.cdcoploj);
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
   
      --Inserir Lancamento
      BEGIN
        INSERT INTO craplcm
           (cdcooper
           ,dtmvtolt
           ,cdagenci
           ,cdbccxlt
           ,nrdolote
           ,nrdconta
           ,nrdctabb
           ,nrdctitg
           ,nrdocmto
           ,cdhistor
           ,nrseqdig
           ,cdpesqbb
           ,vllanmto)
        VALUES  
           (pr_cdcooper
           ,rw_craplot.dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,rw_crapcop.nrctactl
           ,rw_crapcop.nrctactl
           ,GENE0002.fn_mask(rw_crapcop.nrctactl,'99999999')
           ,rw_rapassecdc_compartilhado.nrctremp
           ,2736 -- CREDITO CDC
           ,nvl(rw_craplot.nrseqdig,0) + 1
           ,GENE0002.fn_mask(rw_rapassecdc_compartilhado.nrctremp,'99999999')
           ,rw_rapassecdc_compartilhado.vlrepasse);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplcm (CDC) . ' || SQLERRM;
         --Sair do programa
         RAISE vr_exc_saida;
      END;
        
      --Atualizar capa do Lote
      BEGIN
        -- Atualiza o lote
        UPDATE craplot lot
           SET lot.qtcompln = lot.qtcompln + 1
              ,lot.vlcompcr = lot.vlcompcr + rw_rapassecdc_compartilhado.vlrepasse
              ,lot.nrseqdig = lot.nrseqdig + 1
              ,lot.vlinfocr = lot.vlinfocr + rw_rapassecdc_compartilhado.vlrepasse
              ,lot.qtinfoln = lot.qtinfoln + 1
         WHERE lot.rowid = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela craplot(CDC). ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;
        
      -- DÉBITO 
      OPEN cr_crapcop(pr_cdcooper => rw_rapassecdc_compartilhado.cdcooper);
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
   
      -- DEBITO
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 650008);

      FETCH cr_craplot INTO rw_craplot;
      -- Apenas Fecha Cursor
      CLOSE cr_craplot;
   
      --Inserir Lancamento
      BEGIN
        INSERT INTO craplcm
           (cdcooper
           ,dtmvtolt
           ,cdagenci
           ,cdbccxlt
           ,nrdolote
           ,nrdconta
           ,nrdctabb
           ,nrdctitg
           ,nrdocmto
           ,cdhistor
           ,nrseqdig
           ,cdpesqbb
           ,vllanmto)
        VALUES  
           (pr_cdcooper
           ,rw_craplot.dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,rw_crapcop.nrctactl
           ,rw_crapcop.nrctactl
           ,GENE0002.fn_mask(rw_crapcop.nrctactl,'99999999')
           ,rw_rapassecdc_compartilhado.nrctremp
           ,2737 -- DEBITO CDC
           ,NVL(rw_craplot.nrseqdig,0) + 1
           ,GENE0002.fn_mask(rw_rapassecdc_compartilhado.nrctremp,'99999999')
           ,rw_rapassecdc_compartilhado.vlrepasse);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplcm (CDC) . ' || SQLERRM;
         --Sair do programa
         RAISE vr_exc_saida;
      END;
            
      --Atualizar capa do Lote
      BEGIN
        -- Atualiza o lote
        
        UPDATE craplot lot
           SET lot.qtcompln = lot.qtcompln + 1
              ,lot.vlcompdb = lot.vlcompdb + rw_rapassecdc_compartilhado.vlrepasse
              ,lot.nrseqdig = lot.nrseqdig + 1
              ,lot.vlinfodb = lot.vlinfodb + rw_rapassecdc_compartilhado.vlrepasse
              ,lot.qtinfoln = lot.qtinfoln + 1
         WHERE lot.rowid = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela craplot(CDC). ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;

    END LOOP; -- fim do loop cr_rapassecdc_compartilhado
  END IF; -- if cooperativa 3 cecred

  -- Processo OK, devemos chamar a fimprg
  BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca Descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(sysdate, 'hh24:mi:ss') || ' -' || 
                                                    vr_cdprogra || ' --> ' || vr_dscritic);
    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;
    
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps149;
/