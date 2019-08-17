declare 
  -- Local variables here
  i integer;
  pr_stprogra INTEGER;
  pr_infimsol INTEGER;
  pr_cdcritic INTEGER;
  pr_dscritic VARCHAR2(4000);

  --Retirar do crps594 loop que gera as informações de protesto e o arquivo do cooperado.
  --Já foram gerados no processo normal da madrugada.
  
  --Retirar loop de log das tarifas, pois pode gerar registros indevidos quando executado fora de hora.

  -- Test statements here
  
  PROCEDURE pc_crps594 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_nmtelant  IN VARCHAR2               --> Nome da tela chamadora 
                                              ,pr_cdoperad  IN crapope.cdoperad%type  --> codigo do operador
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padr¿o para utiliza¿¿o de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa¿da de termino da execu¿¿o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa¿da de termino da solicita¿¿o
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps594                        Antigo: Fontes/crps594.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme/Supero
       Data    : Abril/2011                        Ultima atualizacao: 08/12/2017

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atende a solicitacao 5.(Exclusivo)
                   Integrar arquivos do BANCO BRASIL de COBRANCA.
                   Emite relatorio ....

       Alteracao : 27/06/2011 - Utilizado a glb_dtmvtolt como base para todas as
                                procedures deste fonte. Tratado para nao gerar
                                critica caso seja 'COMPEFORA'. (Fabricio)

                   19/07/2011 - Removido campo CNPJ do relatorio analitico e
                                adicionado o campo BCO/AGE. Feito tratamento para
                                listar os motivos para cada ocorrencia.
                                Desmembrado a coluna OUTROS D/C em OUTROS DEB. e
                                OUTROS CRED. (Fabricio)

                   27/07/2011 - Alterado o valor da variavel glb_nmformul para
                                "234dh". (Fabricio)
                              - Passado como parametro dtmvtopr para os lanctos
                                na conta do cooperado (Rafael).

                   16/08/2011 - Utilizado replace nas rotinas que precisam
                                converter o nr da conta para numerico (Rafael).

                   22/08/2011 - Alterado a coluna "Boleto" para "Nosso Num" e a
                                coluna "Doc Coop" para "N Docto" (Adriano).

                   25/08/2011 - No create do cratarq estava faltando glb_cdcooper
                              - Alterado tamanho do frame f_cab e posi¿¿es dos
                                campos (Rafael).

                   13/09/2011 - Utilizado dtmvtopr no lancto das tarifas qdo
                                utilizado grava-retorno
                              - Ajuste no relatorio crrl594 (Rafael).

                   03/10/2011 - Utilizado dtocorre e dtdcredi ao lancar tarifa
                                ao cooperado para fins contabeis. (Rafael).

                   18/10/2011 - Ajustes na rotina principal a fim de evitar
                                erros na cadeia. (Rafael).
                              - Ajustes no relatorio crrl594. (Rafael).

                   31/10/2011 - Nao tratar ent rejeitada e motivos 39,00,60
                                (Rafael).

                   15/12/2011 - Utilizar convenio do header do arquivo pela
                                variavel vr_nrconven. (Rafael).
                              - Incluido rotina de inst de protesto para titulos
                                que estao com o indiaprt = 0. (Rafael).

                   23/12/2011 - Altera¿¿es para incluir o campo "Tarifa COOP" no
                                relat¿rio 594. (Lucas)

                   26/01/2012 - Antes de protestar automaticamente, verificar se
                                n¿o h¿ instru¿¿es de baixa ou susta¿¿o. (Rafael)

                   16/02/2012 - Adequar o COMPEFORA ao gravar a data do retorno
                                referente a contabilidade. (Rafael)

                   08/08/2012 - Ajuste na rotina de liquidacao de titulos
                                descontados da cob. registrada. (Rafael)

                   13/12/2012 - Tratamento para titulos das contas migradas
                                (Viacredi -> Alto Vale). Alimentado tabela crapafi
                                para acerto financeiro entre as singulares,
                                por parte da Cecred. (Fabricio)

                   11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                                consulta da craptco (Tiago).

                   23/04/2013 - Adicionar critica 940 no relatorio 594 quando
                                titulos pagos a menor. (Rafael)
                              - Alterado na procedure cria_rejeitados, a atribuicao
                                do campo craprej.nrdocmto; de: = vr_nrdocmto
                                para: = pr_tab_regimp(vr_indregimp).nrdocmto. (Fabricio)

                   13/05/2013 - Tratamento para titulos com entrada confirmada
                                indevida - critica 955. (Rafael)

                   04/06/2013 - Ignorar processamento de ent.rejeitada com
                                motivos "00","39","60" ou "". (Rafael)

                   19/06/2013 - Ajuste nos lanctos de Acerto Financeiro entre
                                contas migradas BB. (Rafael)

                   30/07/2013 - Incluso processo de log com base nas informacoes
                                da tabela crapcol. (Daniel)

                   08/08/2013 - Retirado leitura da crapcct na procedure
                                "efetiva_atualizacoes_compensacao" e incluso
                                processo busca tarifa utilizando rotina b1wgen0153.
                                (Daniel)

                   25/09/2013 - Incluso tratamento para assumir historico 969 caso
                                nao encontre historico de tarifa. Incluso tratamento
                                para busca historico de ocorrencia 28 (Daniel).

                   26/09/2013 - Incluso parametro tt-lat-consolidada nas chamadas de
                                instrucoes da b1wgen0088 e incluso processo de
                                lancamento de tarifas consolidadas (Daniel).

                   11/10/2013 - Incluido parametro cdprogra para as procedures da
                                b1wgen0153 que carregam dados de tarifa(Tiago).

                   21/10/2013 - Incluido novo parametro na chamada da procedure
                                inst-protestar  ref. ao nro do arq remessa (Rafael).

                   11/11/2013 - Nova forma de chamar as ag¿ncias, de PAC agora
                                a escrita ser¿ PA (Guilherme Gielow)

                   09/12/2013 - Adicionado "VALIDATE <tabela>" apos o create de
                                registros nas tabelas. (Rafael).

                   18/12/2013 - Tratamento para convenios migrados para todas
                                as cooperativas. (Rafael)

                   05/03/2014 - Convers¿o Progress -> Oracle (Alisson-AMcom)
                   
                   31/10/2014 - Ajuste para quando for registro de entrada confirmada,
                                apos gerar crapret verificar se cobran¿a 85 j¿ foi baixada
                                e gerar instru¿ao de baixa do boleto de protesto.(SD 197217 Odirlei-AMcom)
                   
                   05/11/2014 - Projeto 198-Viacon - Incorporacao Concredi e 
                                Credimilsul (Odirlei-AMcom)
                            
                   28/11/2014 - Ajustado leitura para verificar se boleto original
                                do boleto protestado ja foi liquidado(Odirlei-Amcom) 
                                
                   19/12/2014 - Retirar tratamento para gerar lan¿amentos na crapafi referente 
                                os lan¿amentos de contas incorporadas, n¿o ¿ necessario pois 
                                n¿o existe a cooperativa antiga para realizar ajuste financeiro
                                (SD236521 - Odirlei/AMcom)             
                   
                   30/12/2014 - Retirada a critica de entrada n¿o confirmada ao gerar
                                a inst-protestar, visto que ja gera essa informa¿¿o em relatorio.
                                SD 237716(Odirlei-AMcom)
                            
                   23/01/2015 - Revalidacao do Programa. Foi ajustado o case que possuia somente 
                                uma clausula when.
                                (Alisson - AMcom)         
                      
                   07/05/2015 - Adicionado o valor default FALSE para o campo incoptco da 
                                vr_tab_regimp (Douglas - Chamado 266731)
                                
                   11/01/2016 - Alterado procedures da package PAGA0001 para a COBR0007
                                  - pc_inst_protestar
                                  - pc_inst_sustar_baixar
                                (Douglas - Importacao de Arquivos CNAB)
                                
                   15/02/2016 - Inclusao do parametro conta na chamada da
                                TARI0001.pc_carrega_dados_tarifa_cobr. (Jaison/Marcos)

                   08/03/2016 - Incluido na procedure pc_gera_relatorio_594, no raise vr_exc_erro  
                                Quando ocorre critica o procedimento deve efetuar uma cópia do arquivo 
                                para o diretório integra com o nome “err+nome do arquivo”. 
                                (RKAM Gisele Campos Neves  -  Chamado 407291)

                   19/07/2016 - Retirado log da escrita de registros da Crapcol (Daniel - Cecred) 
              
                   02/02/2017 - Enviar e-mail com base no registro criado na crapprm 
                                'CRPS594_EMAIL_COMPBB' (Lucas Ranghetti #556489)

                   02/10/2017 - Inclusão do módulo e ação logado no oracle 
                              - Inclusão da chamada de procedure em exception others
                              - Colocado logs no padrão
                              - Algumas mensagens estavam sendo gravadas em duplicidade, via corpo de programa
                                e pltable na exception do bloco principal. Alteração para gravar apenas 1 vez.
                              - Ajustes na rotina pc_efetiva_atualiz_compensacao: tratamento retorno procedures,
                                retirada raise em algumas situações, cfe Cechet, inclusão parâmetros msgs insert
                                e update.
                                (Ana - Envolti - Chamado 743443)

                   18/10/2017 - Alteração em relação ao padrão pc_set_modulo:
                              - Setar o parâmetro pr_module = CRPS594.nome_procedures e pr_action = NULL
                                (Ana - Envolti - Chamado 743443)

                   08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                                (SD#791193 - AJFink)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- C¿digo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS594';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_cdcritic2  PLS_INTEGER;
      vr_dscritic2  VARCHAR2(4000);
      vr_flgarqui   BOOLEAN := TRUE;
      vr_conteudo   VARCHAR2(1000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%type) IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor gen¿rico de calend¿rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- seleciona dados dos cooperados
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.cdsitdtl
              ,crapass.cdcooper
              ,crapass.inpessoa
              ,crapass.cdagenci
              ,crapass.ROWID
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Buscar parametros do cadastro de cobranca
      CURSOR cr_crapcco (pr_cdcooper crapcop.cdcooper%type,
                         pr_cddbanco crapban.cdbccxlt%type,
                         pr_nrconven crapcco.nrconven%type,
                         pr_flgregis crapcco.flgregis%type) IS
        SELECT crapcco.nmarquiv,
               crapcco.cdbccxlt,
               crapcco.nrdolote,
               crapcco.cdhistor,
               crapcco.vlrtarif,
               crapcco.cdtarhis,
               crapcco.cdagenci,
               crapcco.nrconven,
               crapcco.dsorgarq,
               crapcco.cdcooper
          FROM crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.cddbanco = pr_cddbanco
           AND crapcco.nrconven = pr_nrconven
           AND crapcco.flgregis = pr_flgregis;
      rw_crapcco cr_crapcco%rowtype;
      
      -- Buscar parametros do cadastro de cobranca
      CURSOR cr_crapcco_nome (pr_cdcooper crapcop.cdcooper%type,
                              pr_cddbanco crapban.cdbccxlt%type,
                              pr_flgregis crapcco.flgregis%type) IS
        SELECT crapcco.nmarquiv,
               crapcco.cdbccxlt,
               crapcco.nrdolote,
               crapcco.cdhistor,
               crapcco.vlrtarif,
               crapcco.cdtarhis,
               crapcco.cdagenci,
               crapcco.nrconven,
               crapcco.dsorgarq,
               crapcco.cdcooper
          FROM crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.cddbanco = pr_cddbanco
           AND crapcco.flgregis = pr_flgregis;
      
      -- Buscar parametros do cadastro de cobranca filtrando por origem arquivo
      CURSOR cr_crapcco_arq (pr_cdcooper crapcop.cdcooper%type,
                             pr_cddbanco crapban.cdbccxlt%type,
                             pr_dsorgarq crapcco.dsorgarq%type,
                             pr_flgregis crapcco.flgregis%type) IS
        SELECT cdcooper,
               nrconven
          FROM crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.cddbanco = pr_cddbanco
           AND crapcco.dsorgarq = pr_dsorgarq
           AND crapcco.flgregis = pr_flgregis;
                       
                        
      -- Cursor para retornar os dados dos bloquetos de cobranca
      CURSOR cr_crapcob ( pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE                         
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE) IS
        SELECT crapcob.nrdconta
              ,crapcob.nrcnvcob
              ,crapcob.dtretcob
              ,crapcob.incobran
              ,crapcob.dtdpagto
              ,crapcob.vldpagto
              ,crapcob.indpagto
              ,crapcob.cdbanpag
              ,crapcob.cdagepag
              ,crapcob.vltarifa
              ,crapcob.nrctremp
              ,crapcob.cdbandoc
              ,crapcob.nrdctabb
              ,crapcob.nrdocmto
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.vlabatim
              ,crapcob.cdmensag
              ,crapcob.vldescto
              ,crapcob.tpdmulta
              ,crapcob.vlrmulta
              ,crapcob.tpjurmor
              ,crapcob.vljurdia
              ,crapcob.cdcooper
              ,crapcob.cdtitprt
              ,crapcob.nrinssac
              ,crapcob.rowid
        FROM   crapcob
        WHERE  crapcob.cdcooper = pr_cdcooper
        AND    crapcob.cdbandoc = pr_cdbandoc
        AND    crapcob.nrdctabb = pr_nrdctabb
        AND    crapcob.nrcnvcob = pr_nrcnvcob
        AND    crapcob.nrdocmto = pr_nrdocmto
        AND    crapcob.nrdconta = pr_nrdconta
        ORDER BY crapcob.progress_recid;
      rw_crapcob  cr_crapcob%ROWTYPE;

      -- Cursor para retornar os dados dos bloquetos de cobranca
      CURSOR cr_crapcob_2 ( pr_cdcooper IN crapcob.cdcooper%TYPE
                           ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                           ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                           ,pr_nrdctabb IN crapcob.nrdctabb%TYPE                         
                           ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                           ,pr_nrdconta IN crapcob.nrdconta%TYPE) IS
        SELECT crapcob.nrdconta
              ,crapcob.nrcnvcob
              ,crapcob.dtretcob
              ,crapcob.incobran
              ,crapcob.dtdpagto
              ,crapcob.vldpagto
              ,crapcob.indpagto
              ,crapcob.cdbanpag
              ,crapcob.cdagepag
              ,crapcob.vltarifa
              ,crapcob.nrctremp
              ,crapcob.cdbandoc
              ,crapcob.nrdctabb
              ,crapcob.nrdocmto
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.vlabatim
              ,crapcob.cdmensag
              ,crapcob.vldescto
              ,crapcob.tpdmulta
              ,crapcob.vlrmulta
              ,crapcob.tpjurmor
              ,crapcob.vljurdia
              ,crapcob.cdcooper
              ,crapcob.cdtitprt
              ,crapcob.nrinssac
              ,crapcob.rowid
        FROM   crapcob
        WHERE  crapcob.cdcooper = pr_cdcooper
        AND    crapcob.cdbandoc = pr_cdbandoc
        AND    crapcob.nrdctabb = pr_nrdctabb
        AND    crapcob.nrcnvcob = pr_nrcnvcob
        AND    crapcob.nrdocmto = pr_nrdocmto
        AND    crapcob.nrdconta = pr_nrdconta
        AND    TRIM(crapcob.cdtitprt) IS NOT NULL
        ORDER BY crapcob.progress_recid;
      

      -- Cursor para retornar os dados dos bloquetos de cobranca
      CURSOR cr_crapcob_85 ( pr_cdcooper IN crapcob.cdcooper%TYPE
                            ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                            ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                            ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                            ,pr_nrdconta IN crapcob.nrdconta%TYPE
                            ,pr_incobran IN crapcob.incobran%TYPE) IS
        SELECT crapcob.nrdconta
              ,crapcob.nrcnvcob
              ,crapcob.dtretcob
              ,crapcob.incobran
              ,crapcob.dtdpagto
              ,crapcob.vldpagto
              ,crapcob.indpagto
              ,crapcob.cdbanpag
              ,crapcob.cdagepag
              ,crapcob.vltarifa
              ,crapcob.nrctremp
              ,crapcob.cdbandoc
              ,crapcob.nrdctabb
              ,crapcob.nrdocmto
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.vlabatim
              ,crapcob.cdmensag
              ,crapcob.vldescto
              ,crapcob.tpdmulta
              ,crapcob.vlrmulta
              ,crapcob.tpjurmor
              ,crapcob.vljurdia
              ,crapcob.cdcooper
              ,crapcob.cdtitprt
              ,crapcob.nrinssac
              ,crapcob.rowid
        FROM   crapcob
        WHERE  crapcob.cdcooper = pr_cdcooper
        AND    crapcob.cdbandoc = pr_cdbandoc
        AND    crapcob.nrcnvcob = pr_nrcnvcob
        AND    crapcob.nrdocmto = pr_nrdocmto
        AND    crapcob.nrdconta = pr_nrdconta
        AND    crapcob.incobran = pr_incobran
        ORDER BY crapcob.progress_recid;
      rw_crapcob_85  cr_crapcob_85%ROWTYPE;
      
      -- Cursor para retornar os dados dos bloquetos de cobranca
      CURSOR cr_crapcob_rowid ( pr_rowid IN rowid ) IS
        SELECT crapcob.nrdconta
              ,crapcob.nrcnvcob
              ,crapcob.dtretcob
              ,crapcob.incobran
              ,crapcob.dtdpagto
              ,crapcob.vldpagto
              ,crapcob.indpagto
              ,crapcob.cdbanpag
              ,crapcob.cdagepag
              ,crapcob.vltarifa
              ,crapcob.nrctremp
              ,crapcob.cdbandoc
              ,crapcob.nrdctabb
              ,crapcob.nrdocmto
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.vlabatim
              ,crapcob.cdmensag
              ,crapcob.vldescto
              ,crapcob.tpdmulta
              ,crapcob.vlrmulta
              ,crapcob.tpjurmor
              ,crapcob.vljurdia
              ,crapcob.cdcooper
              ,crapcob.cdtitprt
              ,crapcob.nrinssac
              ,crapcob.rowid
        FROM   crapcob
        WHERE  crapcob.rowid = pr_rowid;
      
      /* Ler todos os titulos em aberto */
      /* com o prazo de protesto vencido */
      CURSOR cr_crapceb ( pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrconven IN crapceb.nrconven%TYPE
                         ,pr_dtmvtolt IN crapcob.dtvencto%TYPE) IS   
        SELECT crapcob.cdcooper,
               crapcob.nrdconta,
               crapcob.nrcnvcob,
               crapcob.nrdocmto,
               crapcob.cdtpinsc,
               crapcob.rowid
          FROM crapceb crapceb,
               crapcob crapcob
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrconven = pr_nrconven
           AND crapcob.cdcooper = crapceb.cdcooper 
           AND crapcob.nrcnvcob = crapceb.nrconven 
           AND crapcob.nrdconta = crapceb.nrdconta 
           AND (crapcob.dtvencto + crapcob.qtdiaprt) <= pr_dtmvtolt
           AND crapcob.incobran = 0 /* aberto */
           AND crapcob.indiaprt = 0 /* dias corridos c/ problema */
           AND crapcob.insitcrt = 0 /* s/ situacao de cartorio */
           AND crapcob.flgdprot = 1; /*TRUE*/
      
      -- Buscar Movimento de Remessa de Titulos Bancarios
      CURSOR cr_craprem ( pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS 
        SELECT 1
          FROM craprem
         WHERE craprem.cdcooper = pr_cdcooper
           AND craprem.nrdconta = pr_nrdconta
           AND craprem.nrcnvcob = pr_nrcnvcob
           AND craprem.nrdocmto = pr_nrdocmto
           AND craprem.cdocorre IN (2,10,11)
         ORDER BY craprem.progress_recid ;
      rw_craprem cr_craprem%rowtype;    
      
      --Buscar Log dos Boletos
      CURSOR cr_crapcol (pr_cdcooper crapcol.cdcooper%type,
                         pr_datailog crapcol.dtaltera%type,
                         pr_horailog crapcol.hrtransa%type,
                         pr_dataflog crapcol.dtaltera%type,
                         pr_horaflog crapcol.hrtransa%type ) IS
        SELECT dslogtit 
          FROM crapcol
         WHERE crapcol.cdcooper = pr_cdcooper
           AND crapcol.cdoperad = 'TARIFA'
           AND crapcol.dtaltera >= pr_datailog
           AND crapcol.hrtransa >= pr_horailog
           AND crapcol.dtaltera <= pr_dataflog
           AND crapcol.hrtransa <= pr_horaflog;
      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      
      -- Tipo de registro para armazenar as informa¿¿es dos arquivos
      -- que serao processados
      TYPE typ_reg_cratarq IS RECORD
        (flgmarca BOOLEAN
        ,cdcooper INTEGER
        ,nmarquiv VARCHAR2(100)
        ,nrsequen INTEGER
        ,nmquoter VARCHAR2(100)
        ,nrseqdig INTEGER
        ,vllanmto NUMBER
        ,cdagenci INTEGER /* PAC */
        ,cdbccxlt INTEGER /* Banco/Caixa */
        ,nrdolote INTEGER /* Numero do Lote */
        ,tplotmov INTEGER /* Tipo do Lote */
        ,nroconve INTEGER /* Numero do Convenio */
        ,qtregrec INTEGER /* Qtde de boletos recebidos */
        ,qtregicd INTEGER /* Qtde de boletos integrados COM desconto */
        ,qtregisd INTEGER /* Qtde de boletos integrados SEM desconto */
        ,qtregrej INTEGER /* Qtde de boletos rejeitados */
        ,vlregrec NUMBER /* Vlr dos boletos recebidos */
        ,vlregicd NUMBER /* Vlr dos boletos integrados COM desconto */
        ,vlregisd NUMBER /* Vlr dos boletos integrados SEM desconto */
        ,vlregrej NUMBER /* Vlr dos boletos rejeitados */
        ,vltarifa NUMBER /* Vlr total das tarifas dos boletos */
        ,cdhistor INTEGER /* Historico do lancamento do valor do titulo */
        ,cdtarhis INTEGER /* Historico do lancamento da tarifa do titulo */
        ,vlrtarif NUMBER /* Valor da tarifa por boleto cfme. convenio */
        ,qtdmigra INTEGER /* Qtd de titulos migrados - Alto Vale */
        ,vlrmigra NUMBER /* Vlr dos titulos migrados - Alto Vale */
        );

      TYPE typ_tab_cratarq IS
        TABLE OF typ_reg_cratarq
        INDEX BY VARCHAR2(100);
      vr_tab_cratarq typ_tab_cratarq;   
      
      -- Tipo de registro dos registros importados dos arquivos - boletos
      TYPE typ_reg_detalhe IS
        RECORD(  cdcooper crapcop.cdcooper%TYPE
                ,codbanco crapcob.cdbandoc%TYPE
                ,nrcnvcob crapcob.nrcnvcob%TYPE
                ,cdagenci craprej.cdagenci%TYPE
                ,nrremret NUMBER
                ,nrdctabb crapcob.nrdctabb%TYPE
                ,nrdocmto crapcob.nrdocmto%TYPE
                ,vllanmto craplcm.vllanmto%TYPE
                ,vlrtarif craplcm.vllanmto%TYPE
                ,dtpagto  craplcm.dtmvtolt%TYPE
                ,nrctares craprej.nrdconta%TYPE
                ,nrseqdig craprej.nrseqdig%TYPE
                ,nrdolote craprej.nrdolote%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,dsdoccop VARCHAR(20)
                ,dsmotivo VARCHAR2(100)
                ,vltarifa NUMBER
                ,dtvencto DATE
                ,nrnosnum NUMBER
                ,dtdpagto DATE
                ,nrdocnpj NUMBER
                ,codmoeda NUMBER(1)
                ,identifi VARCHAR(20)
                ,codcarte NUMBER(9)
                ,juros    craplcm.vllanmto%TYPE
                ,vlabatim craplcm.vllanmto%TYPE
                ,incnvaut BOOLEAN
                ,vloutdes NUMBER
                ,dsorgarq VARCHAR2(100)
                ,nrcnvceb INTEGER
                ,vldescto NUMBER
                ,vljurmul NUMBER
                ,vlrpagto NUMBER
                ,vlliquid NUMBER
                ,vloutcre NUMBER
                ,dtdcredi DATE
                ,cdpesqbb craprej.cdpesqbb%TYPE
                ,cdbanpag crapcob.cdbanpag%TYPE
                ,cdagepag crapcob.cdagepag%TYPE                
                ,inarqcbr crapceb.inarqcbr%TYPE
                ,dtdgerac DATE
                ,dtocorre DATE
                ,flpagchq BOOLEAN
                ,dcmc7chq VARCHAR2(100)
                ,dscheque VARCHAR2(100)
                ,cdocorre INTEGER
                ,cdbancor NUMBER
                ,vldpagto craplcm.vllanmto%TYPE
                ,vltarbco NUMBER
                ,cdhistor INTEGER
                ,cdfvlcop INTEGER
                ,first_of BOOLEAN
                ,last_of  BOOLEAN
                -- 16012014
                ,incoptco BOOLEAN DEFAULT FALSE
                ,nrctaant craptco.nrctaant%TYPE
                ,cdcopant craptco.cdcopant%TYPE
                ,nmarquiv VARCHAR2(100)
                );

      TYPE typ_tab_regimp IS
        TABLE OF typ_reg_detalhe
        INDEX BY VARCHAR2(100); --nmarq  
        
      vr_tab_regimp typ_tab_regimp;
      
      -- Tipo de registro dos registros de trailers do lote
      TYPE typ_reg_trailer IS
        RECORD( cdcooper crapcco.cdcooper%type,
                nmarquiv VARCHAR2(100),
                qtreglot NUMBER,
                qttitcsi NUMBER,
                vltitcsi craplcm.vllanmto%type,
                qttitcvi NUMBER,
                vltitcvi craplcm.vllanmto%type,
                qttitcca NUMBER,
                vltitcca craplcm.vllanmto%type,
                qttitcde NUMBER,
                vltitcde craplcm.vllanmto%type);
                
      TYPE typ_tab_trailer IS
        TABLE OF typ_reg_trailer
        INDEX BY VARCHAR2(100); -- cdcooper(5) + nmarquiv
      vr_tab_trailer typ_tab_trailer;
      
      -- Tipo de registro para armazenar os titulos rejeitados
      TYPE typ_reg_cratrej IS
        RECORD(  cdagenci craprej.cdagenci%TYPE
                ,cdbccxlt craprej.cdbccxlt%TYPE
                ,cdcritic craprej.cdcritic%TYPE
                ,cdempres craprej.cdempres%TYPE
                ,dtmvtolt craprej.dtmvtolt%TYPE
                ,nrdconta craprej.nrdconta%TYPE
                ,nrdolote craprej.nrdolote%TYPE
                ,tpintegr craprej.tpintegr%TYPE
                ,cdhistor craprej.cdhistor%TYPE
                ,vllanmto craprej.vllanmto%TYPE
                ,tplotmov craprej.tplotmov%TYPE
                ,cdpesqbb craprej.cdpesqbb%TYPE
                ,dshistor craprej.dshistor%TYPE
                ,nrseqdig craprej.nrseqdig%TYPE
                ,nrdocmto craprej.nrdocmto%TYPE
                ,nrdctabb craprej.nrdctabb%TYPE
                ,indebcre craprej.indebcre%TYPE
                ,dtrefere craprej.dtrefere%TYPE
                ,vlsdapli craprej.vlsdapli%TYPE
                ,dtdaviso craprej.dtdaviso%TYPE
                ,vldaviso craprej.vldaviso%TYPE
                ,nraplica craprej.nraplica%TYPE
                ,cdcooper craprej.cdcooper%TYPE
                ,nrdctitg craprej.nrdctitg%TYPE
                ,progress_recid NUMBER
                ,nmarquiv VARCHAR2(500)
               );

      TYPE typ_tab_cratrej IS
        TABLE OF typ_reg_cratrej
        INDEX BY VARCHAR2(100);
      vr_tab_cratrej typ_tab_cratrej;  
      
      -- Tipo dos detalhes dos registro para contas migradas
      TYPE typ_detalhe_migracao IS
        RECORD( nrdctabb crapcob.nrdctabb%TYPE
               ,cdcopdst INTEGER
               ,nrctadst crapcob.nrdconta%TYPE
               ,cdagedst crapcco.cdagenci%TYPE
               ,cdhistor craplcm.cdhistor%TYPE
               ,vllanmto craplcm.vllanmto%TYPE
               ,vlrtarif craplcm.vllanmto%TYPE
               ,dsorgarq crapcco.dsorgarq%TYPE
               ,nroconve crapcob.nrcnvcob%TYPE
               ,nmrescop crapcop.nmrescop%TYPE
               ,qttitmig INTEGER
               ,nmarquiv VARCHAR2(100)
               );

      --Tipo de Tabela para migracao
      TYPE typ_tab_migracao IS
        TABLE OF typ_detalhe_migracao
        INDEX BY VARCHAR2(100);
      
      vr_tab_migracao typ_tab_migracao;
      
      -- Type para armazenar os dados para o relatorio crrl594
      TYPE typ_rec_relatorio IS
        RECORD( cdocorre integer,
                dsocorre VARCHAR2(100),
                qtdregis INTEGER,
                vltotreg NUMBER,
                vltotdes NUMBER,
                vltotjur NUMBER,
                vloutdeb NUMBER,
                vloutcre NUMBER,
                vltotpag NUMBER,
                vltottar NUMBER,
                nmarquiv VARCHAR2(100),
                tottaras NUMBER);
      TYPE typ_tab_detrel IS
        TABLE OF typ_rec_relatorio
        INDEX BY VARCHAR2(100); -- nmarq
      
      vr_tab_relatorio typ_tab_detrel;
            
      -- Type para armazenar os dados para o relatorio analitico crrl594
      TYPE typ_rec_relanalitico IS
        RECORD(  cdocorre INTEGER
                ,dsocorre varchar2(100)
                ,cdagenci craprej.cdagenci%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,nrdocmto crapcob.nrdocmto%TYPE
                ,dstitdsc VARCHAR2(100)
                ,dsdoccop VARCHAR2(100)
                ,dtvencto DATE
                ,vllanmto craplcm.vllanmto%TYPE
                ,vldesaba craplcm.vllanmto%TYPE
                ,vljurmul craplcm.vllanmto%TYPE
                ,vloutdeb craplcm.vllanmto%TYPE
                ,vloutcre craplcm.vllanmto%TYPE
                ,vlrpagto craplcm.vllanmto%TYPE
                ,bancoage VARCHAR2(100)
                ,vltarifa craplcm.vllanmto%TYPE
                ,dsmotivo VARCHAR2(100)
                ,nmarquiv VARCHAR2(100)
                ,nrnosnum crapcob.nrnosnum%TYPE
                ,vltarass crapret.vltarass%TYPE);
      
      TYPE typ_tab_detalhe_analitico IS
        TABLE OF typ_rec_relanalitico
        INDEX BY VARCHAR2(100); -- cdocorre(10) + cdagenci(5) + nrdconta(10) + nrdocmto(10)
      
      vr_tab_rel_analitico typ_tab_detalhe_analitico;
      
      vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
      vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
      vr_tab_arq_cobranca    PAGA0001.typ_tab_arq_cobranca;
      
      ------------------------------- VARIAVEIS -------------------------------
      vr_datailog     DATE;
      vr_horailog     NUMBER;
      vr_dataflog     DATE;
      vr_horaflog     NUMBER;
      vr_dtauxcmp     DATE;
      vr_dir_cooper   VARCHAR2(200); -- Diretorio da cooperativa
      vr_dir_compbb   VARCHAR2(200); -- Diretorio dos arquivos
      vr_dir_salvar   VARCHAR2(200); -- Diretorio para salvar
      vr_dir_integra  VARCHAR2(200); -- Diretorio integrados
      vr_dir_rl       VARCHAR2(200); -- Diretorio Relatorios
      vr_nmarqdeb     VARCHAR2(200); -- Nome do arq de debito
      vr_des_erro     VARCHAR2(100);  -- Indicador de erro
      vr_tab_erro     GENE0001.typ_tab_erro;      
      vr_diacredi     NUMBER;
      vr_mescredi     NUMBER;
      vr_nrsequen     INTEGER;
      -- variaveis de controle de comandos shell
      vr_comando      VARCHAR2(500);
      vr_listadir     VARCHAR2(4000);
      vr_typ_saida    VARCHAR2(1000);
      vr_indregimp    VARCHAR2(100);
      vr_indregtrl    VARCHAR2(100);
      vr_indcratrej   VARCHAR2(100);
      -- variaveis para os Indices das temp-tables
      vr_index_cratarq  varchar2(100);  
      vr_index_reg      varchar2(100); 
      vr_index_trailer  varchar2(100); 
      vr_index_migracao varchar2(100);  
      vr_index_relato   VARCHAR2(100);
      vr_index_analit   VARCHAR2(100);
             
      --Tabela para receber arquivos lidos no unix
      vr_tab_arquivo  gene0002.typ_split;
      
      --Variaveis de Arquivo
      vr_des_xml        CLOB;
      vr_input_file     utl_file.file_type;
      vr_setlinha       VARCHAR2(298);
      vr_arqimpor       VARCHAR2(4000);
      vr_nmarqaux       VARCHAR2(4000);
       vr_texto_completo VARCHAR2(32600);
      
      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- Gera log em tabelas
      PROCEDURE pc_gera_log(pr_cdcooper   IN crapcop.cdcooper%type DEFAULT 3  --Cooperativa
                           ,pr_dstiplog   IN VARCHAR2                         -- Tipo de Log
                           ,pr_dscritic   IN VARCHAR2 DEFAULT NULL            -- Descrição do Log
                           ,pr_tpocorrencia IN VARCHAR2 dEFAULT 4             -- Tipo de Ocorrência
                                      )
      IS
      -----------------------------------------------------------------------------------------------------------
      --
      --  Programa : pc_gera_log
      --  Sistema  : Rotina para gravar logs em tabelas
      --  Sigla    : CRED
      --  Autor    : Ana Lúcia E. Volles - Envolti
      --  Data     : Outubro/2017           Ultima atualizacao: 02/10/2017
      --  Chamado  : 743443
      --
      -- Dados referentes ao programa:
      --
      -- Frequencia: Rotina executada em qualquer frequencia.
      -- Objetivo  : Controla gravação de log em tabelas.
      --
      -- Alteracoes:  
      --             
      ------------------------------------------------------------------------------------------------------------   
        vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
        vr_tpocorrencia       tbgen_prglog_ocorrencia.tpocorrencia%type;
        --
      BEGIN         
        --> Controlar geração de log de execução dos jobs                                
        CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                               pr_cdprograma    => vr_cdprogra, 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 2, --job
                               pr_tpocorrencia  => pr_tpocorrencia,
                               pr_cdcriticidade => 0, --baixa
                               pr_dsmensagem    => pr_dscritic,                             
                               pr_idprglog      => vr_idprglog,
                               pr_nmarqlog      => NULL);
      EXCEPTION
        WHEN OTHERS THEN
          --Inclusão na tabela de erros Oracle - Chamado 743443
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
      END pc_gera_log;
      --    
      
      --Verificar vencimento titulo
      PROCEDURE pc_verifica_vencimento_titulo (pr_dtvencto      IN crapcob.dtvencto%TYPE        --Data Vencimento
                                              ,pr_crapdat       IN btch0001.cr_crapdat%ROWTYPE  --Data movimento
                                              ,pr_critica_data  OUT BOOLEAN                     --Critica na validacao
                                              ,pr_cdcritic      OUT INTEGER                     --Codigo da Critica
                                              ,pr_dscritic      OUT VARCHAR2) IS                --Descricao do erro     
      BEGIN
        DECLARE
          vr_dtdiautil DATE;
        BEGIN
          -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_verifica_vencimento_titulo', pr_action => NULL);

          --Inicializar Variaveis Erro
          pr_cdcritic:= NULL;
          pr_dscritic:= NULL;
          
          --Inicializar Retorno
          pr_critica_data:= FALSE;
          
          /** Pagamento no dia **/
          IF pr_dtvencto > pr_crapdat.dtmvtocd  OR  pr_crapdat.dtmvtoan < pr_dtvencto THEN
            RETURN;
          END IF;  
          
          --Inicializar Retorno
          pr_critica_data:= TRUE;
            
          /** Tratamento para permitir pagamento no primeiro dia util do **/
          /** ano de titulos vencidos no ultimo dia util do ano anterior **/
          
          IF to_number(to_char(pr_crapdat.dtmvtoan,'YYYY')) <> to_number(to_char(pr_crapdat.dtmvtocd,'YYYY')) THEN
            --Dia Util
            vr_dtdiautil:= to_date('3112'||to_char(pr_crapdat.dtmvtoan,'YYYY'),'DDMMYYYY');
            /** Se dia 31/12 for segunda-feira obtem data do sabado **/
            /** para aceitar vencidos do ultimo final de semana     **/
            IF to_number(to_char(vr_dtdiautil,'D')) IN (1,2) THEN
              --Dia Util
              vr_dtdiautil:= to_date('2912'||to_char(pr_crapdat.dtmvtoan,'YYYY'),'DDMMYYYY');
            ELSIF to_number(to_char(vr_dtdiautil,'D')) = 7 THEN  
              --Dia Util
              vr_dtdiautil:= to_date('3012'||to_char(pr_crapdat.dtmvtoan,'YYYY'),'DDMMYYYY');
            END IF;
            /** Verifica se pode aceitar o titulo vencido **/
            IF  pr_dtvencto >= vr_dtdiautil THEN 
               --Nao Criticar
               pr_critica_data:= FALSE; 
            END IF;  
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic:= 0;
            pr_dscritic:= 'Erro na rotina pc_verifica_vencimento_titulo: '||sqlerrm;

            --Inclusão na tabela de erros Oracle - Chamado 743443
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        END;    
      END pc_verifica_vencimento_titulo;                                          
                                              
      -- Buscar o parametro do nome dos arquivos a serem processados
      PROCEDURE pc_busca_nome_arquivos (pr_cdcooper IN crapcop.cdcooper%type,   -- codigo da cooperativa
                                        pr_cdagenci IN crapage.cdagenci%type,   -- codigo da agencia
                                        pr_nrdcaixa IN craplot.nrdcaixa%type,   -- Numero de caixa
                                        pr_cddbanco IN crapban.cdbccxlt%type,   -- codigo do banco                                        
                                        pr_nmarqdeb OUT VARCHAR2,              -- Nome do arq de debito
                                        pr_des_erro OUT VARCHAR2,              -- Indicador de erro
                                        pr_tab_erro OUT GENE0001.typ_tab_erro) is -- Tabela contendo os erros
  
      BEGIN           
        -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_busca_nome_arquivos', pr_action => NULL);

        -- Ler parametros do cadastro de cobranca
        FOR rw_crapcco IN cr_crapcco_nome(pr_cdcooper => pr_cdcooper,
                                          pr_cddbanco => pr_cddbanco,
                                          pr_flgregis => 1 /* true*/ )LOOP
            
          IF trim(pr_nmarqdeb) is null THEN
            IF trim(rw_crapcco.nmarquiv) is null THEN
              continue;
            ELSE              
              pr_nmarqdeb := TRIM(rw_crapcco.nmarquiv)||'*';            
            END IF;
          ELSE
            --Se ja localizou 1, pode sair do loop
            exit;
          END IF;  
        END LOOP; --fim cr_crapcco

        --Verificar se nao localizou nome de arquivo
        IF TRIM(pr_nmarqdeb) is null THEN
          vr_nrsequen := NVL(vr_nrsequen,0) + 1;
          vr_dscritic := null;
          --gravar temp de erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 938,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
          -- retornar NOK
          pr_des_erro:= 'NOK';
          RETURN;
        END IF;  
        
        pr_des_erro:= 'OK';
      EXCEPTION  
        WHEN OTHERS THEN
          vr_nrsequen := NVL(vr_nrsequen,0) + 1;
          vr_dscritic := 'Erro na rotina pc_busca_nome_arquivos: '||SQLErrm;

          --Inclusão na tabela de erros Oracle - Chamado 743443
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
          pr_des_erro:= 'NOK';
      END pc_busca_nome_arquivos;
        
      
      /* Insere na tabela de rejeitados */
      PROCEDURE pc_cria_rejeitados( pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                   ,pr_cdcritic IN INTEGER                -- Codigo da critica
                                   ,pr_nrdconta IN INTEGER                -- Numero da conta
                                   ,pr_nrdctitg IN VARCHAR2               -- Numero da conta de integracao com o Banco do Brasil
                                   ,pr_nrdctabb IN INTEGER                -- Numero da conta no BB
                                   ,pr_dshistor IN VARCHAR2               -- Descricao do historico
                                   ,pr_nmarquiv IN VARCHAR2               -- Nome do arquivo
                                   ,pr_nrdocmto IN craprej.nrdocmto%TYPE  -- N¿mero do documento
                                   ,pr_vllanmto IN NUMBER                 -- Valor do lancamento
                                   ,pr_cdocorre IN INTEGER                -- codigo da ocorrencia
                                   -- parametros da pr_tab_regimp
                                   ,pr_nrseqdig IN craprej.nrseqdig%TYPE  -- Digito da sequencia
                                   ,pr_codbanco IN crapcob.cdbandoc%TYPE  -- Codigo do banco
                                   ,pr_cdagenci IN craprej.cdagenci%TYPE  -- Codigo da agencia
                                   ,pr_nrdolote IN craprej.nrdolote%TYPE  -- Numero do lote
                                   ,pr_cdpesqbb IN craprej.cdpesqbb%TYPE  -- Codigo de pesquisa do lancamento no banco do Brasil
                                   ,pr_tab_cratrej IN OUT typ_tab_cratrej -- Tabela de rejeitados
                                   ,pr_qtregrej IN OUT NUMBER             -- Acumulador da quantidade de boletos rejeitados
                                   ,pr_vlregrej IN OUT NUMBER             -- Acumulador do valor dos boletos rejeitados
                                   ,pr_dscritic OUT VARCHAR2 ) IS -- Descricao da critica
      BEGIN
      /*************************************************************************
          Objetivo: Criar registros dos boletos rejeitados na importacao dos
                    arquivos da compensacao
      *************************************************************************/
        DECLARE
          
          -- Buscar Ocorrencias Bancarias
          CURSOR cr_crapoco (pr_cdcooper crapoco.cdcooper%type,
                             pr_cdocorre crapoco.cdocorre%type) IS
            SELECT dsocorre
              FROM crapoco
             WHERE crapoco.cdcooper = pr_cdcooper
               AND crapoco.cddbanco = 1
               AND crapoco.cdocorre = pr_cdocorre
               AND crapoco.tpocorre = 2
             ORDER BY crapoco.progress_recid asc; -- FIRST-OF
          rw_crapoco cr_crapoco%rowtype;
          
          CURSOR cr_crapmot (pr_cdcooper crapmot.cdcooper%type,
                             pr_cdocorre crapmot.cdocorre%type,
                             pr_cdmotivo crapmot.cdmotivo%type) IS
            SELECT dsmotivo
              FROM crapmot
             WHERE crapmot.cdcooper = pr_cdcooper
               AND crapmot.cddbanco = 1
               AND crapmot.cdocorre = pr_cdocorre
               AND crapmot.tpocorre = 2
               AND crapmot.cdmotivo = pr_cdmotivo
             ORDER BY crapmot.progress_recid asc; -- FIRST-OF
          rw_crapmot cr_crapmot%rowtype;
          
          vr_seqcratrej INTEGER;
          vr_cdmotivo   varchar2(2);
          vr_cdposini   INTEGER:= 1;
          vr_dsmotivo   VARCHAR2(100);
          vr_exc_erro   EXCEPTION;
        BEGIN
          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_cria_rejeitados', pr_action => NULL);

          -- Se o codigo da critica for nulo e a descri¿¿o do historico n¿o
          IF nvl(pr_cdcritic,0) = 0 AND trim(pr_dshistor) is not null THEN
            -- Varrer o dshistor com os motivos
            FOR vr_contador in 1..5 LOOP
              vr_cdmotivo := TRIM(SUBSTR(pr_dshistor,vr_cdposini, 2));
              vr_cdposini := nvl(vr_cdposini,1) + 2;
              
              -- Se o motivo for nulo, pular para o proximo
              IF trim(vr_cdmotivo) is null THEN 
                continue;
              END IF;                                 
              
              -- Buscar Ocorrencias Bancarias
              OPEN cr_crapoco (pr_cdcooper => pr_cdcooper,
                               pr_cdocorre => pr_cdocorre);
              FETCH cr_crapoco INTO rw_crapoco;
              --Fechar Cursor                
              CLOSE cr_crapoco;
              
              /* buscar os motivos da ocorrencia */
              OPEN cr_crapmot (pr_cdcooper => pr_cdcooper,
                               pr_cdocorre => pr_cdocorre,
                               pr_cdmotivo => vr_cdmotivo);
              FETCH cr_crapmot INTO rw_crapmot;
              IF cr_crapmot%NOTFOUND THEN
                vr_dsmotivo := gene0002.fn_mask(pr_cdocorre,'99') ||'-'|| 
                               vr_cdmotivo || 'MOTIVO NAO CADASTRADO';
              ELSE
                IF trim(rw_crapmot.dsmotivo) is not null THEN
                  vr_dsmotivo := rw_crapoco.dsocorre ||' - '|| rw_crapmot.dsmotivo;
                ELSE
                  vr_dsmotivo := rw_crapoco.dsocorre;
                END IF;    
              END IF;
              --Fechar Cursor      
              CLOSE cr_crapmot;
              
              -- inserindo na tabela de rejei¿¿o
              BEGIN
                -- Sequencial para formar a chave da temp-table
                vr_seqcratrej := pr_tab_cratrej.count()+1;
                -- chave da temp-table utiliza o nome do arquivco e a conta pq o relat¿rio ¿ ordenado por arquivo e conta
                vr_indcratrej := RPad(pr_nmarquiv,50,'#')||LPad(pr_nrdconta,10,'0')||LPad(vr_seqcratrej,5,'0');  

                INSERT INTO craprej
                  (dtrefere
                  ,cdagenci
                  ,cdbccxlt
                  ,cdcritic
                  ,cdempres
                  ,dtmvtolt
                  ,nrdconta
                  ,nrdolote
                  ,tpintegr
                  ,cdhistor
                  ,vllanmto
                  ,tplotmov
                  ,cdpesqbb
                  ,dshistor
                  ,nrseqdig
                  ,nrdocmto
                  ,nrdctabb
                  ,indebcre
                  ,vlsdapli
                  ,dtdaviso
                  ,vldaviso
                  ,nraplica
                  ,cdcooper
                  ,nrdctitg)
                VALUES  
                  ( SUBSTR(pr_nmarquiv,15,06) -- dtrefere
                  , nvl(pr_cdagenci,0)        -- cdagenci
                  , nvl(pr_codbanco,0)        -- cdbccxlt
                  , 0                         -- cdcritic
                  , 0                         -- cdempres
                  , rw_crapdat.dtmvtolt       -- dtmvtolt
                  , nvl(pr_nrdconta,0)        -- nrdconta
                  , nvl(pr_nrdolote,0)        -- nrdolote
                  , 0                         -- tpintegr
                  , 0                         -- cdhistor
                  , nvl(pr_vllanmto,0)        -- vllanmto
                  , 0                         -- tplotmov
                  , nvl(pr_cdpesqbb,' ')      -- cdpesqbb
                  , '('||gene0002.fn_mask(pr_cdocorre,'99')||'/'
                       ||TRIM(SUBSTR(pr_dshistor,1,8))    ||')'
                       ||' - '|| UPPER(vr_dsmotivo)       -- dshistor
                  , nvl(pr_nrseqdig,0)        -- nrseqdig
                  , nvl(pr_nrdocmto,0)        -- nrdocmto
                  , nvl(pr_nrdctabb,0)        -- nrdctabb
                  , ' '                       -- indebcre
                  , 0                         -- vlsdapli
                  , NULL                      -- dtdaviso
                  , 0                         -- vldaviso
                  , 0                         -- nraplica
                  , nvl(pr_cdcooper,0)        -- cdcooper
                  , nvl(pr_nrdctitg,' '))     -- nrdctitg
                 returning   craprej.dtrefere, 
                             craprej.nrdconta,
                             craprej.nrdctitg, 
                             craprej.nrdctabb, 
                             craprej.nrdocmto, 
                             craprej.vllanmto, 
                             craprej.nrseqdig, 
                             craprej.cdbccxlt, 
                             craprej.cdagenci, 
                             craprej.nrdolote, 
                             craprej.cdcritic, 
                             craprej.cdcooper, 
                             craprej.cdpesqbb, 
                             craprej.dshistor,
                             craprej.dtmvtolt
                     into    pr_tab_cratrej(vr_indcratrej).dtrefere, 
                             pr_tab_cratrej(vr_indcratrej).nrdconta, 
                             pr_tab_cratrej(vr_indcratrej).nrdctitg, 
                             pr_tab_cratrej(vr_indcratrej).nrdctabb, 
                             pr_tab_cratrej(vr_indcratrej).nrdocmto, 
                             pr_tab_cratrej(vr_indcratrej).vllanmto, 
                             pr_tab_cratrej(vr_indcratrej).nrseqdig, 
                             pr_tab_cratrej(vr_indcratrej).cdbccxlt, 
                             pr_tab_cratrej(vr_indcratrej).cdagenci, 
                             pr_tab_cratrej(vr_indcratrej).nrdolote, 
                             pr_tab_cratrej(vr_indcratrej).cdcritic, 
                             pr_tab_cratrej(vr_indcratrej).cdcooper, 
                             pr_tab_cratrej(vr_indcratrej).cdpesqbb, 
                             pr_tab_cratrej(vr_indcratrej).dshistor,
                             pr_tab_cratrej(vr_indcratrej).dtmvtolt;    

                 pr_tab_cratrej(vr_indcratrej).nmarquiv := pr_nmarquiv;       
                 pr_qtregrej := nvl(pr_qtregrej,0) + 1;
                 pr_vlregrej := nvl(pr_vlregrej,0) + nvl(pr_vllanmto,0);        
                        
              EXCEPTION
                WHEN OTHERS THEN
                  -- gera critica e aborta a execucao do programa
                  pr_dscritic := 'Erro ao inserir na tabela craprej na rotina pc_cria_rejeitados: '||SQLERRM;
                  -- retorna para o programa chamador da rotina
                  RAISE vr_exc_erro;
              END;
            END LOOP;  
          
          ELSE
            
            -- Sequencial para formar a chave da temp-table
            vr_seqcratrej := pr_tab_cratrej.count()+1;
            -- chave da temp-table utiliza o nome do arquivco e a conta pq o relat¿rio ¿ ordenado por arquivo e conta
            vr_indcratrej := RPad(pr_nmarquiv,50,'#')||LPad(pr_nrdconta,10,'0')||LPad(vr_seqcratrej,5,'0');

            -- inserindo na tabela de rejei¿¿o
            BEGIN
              INSERT INTO craprej
                 (dtrefere
                 ,cdagenci
                 ,cdbccxlt
                 ,cdcritic
                 ,cdempres
                 ,dtmvtolt
                 ,nrdconta
                 ,nrdolote
                 ,tpintegr
                 ,cdhistor
                 ,vllanmto
                 ,tplotmov
                 ,cdpesqbb
                 ,dshistor
                 ,nrseqdig
                 ,nrdocmto
                 ,nrdctabb
                 ,indebcre
                 ,vlsdapli
                 ,dtdaviso
                 ,vldaviso
                 ,nraplica
                 ,cdcooper
                 ,nrdctitg)
              VALUES  
                 ( SUBSTR(pr_nmarquiv,15,06) -- dtrefere
                 , nvl(pr_cdagenci,0)        -- cdagenci
                 , nvl(pr_codbanco,0)        -- cdbccxlt
                 , pr_cdcritic               -- cdcritic
                 , 0                         -- cdempres
                 , rw_crapdat.dtmvtolt       -- dtmvtolt
                 , nvl(pr_nrdconta,0)        -- nrdconta
                 , nvl(pr_nrdolote,0)        -- nrdolote
                 , 0                         -- tpintegr
                 , 0                         -- cdhistor
                 , nvl(pr_vllanmto,0)        -- vllanmto
                 , 0                         -- tplotmov
                 , nvl(pr_cdpesqbb,' ')      -- cdpesqbb
                 , '('||gene0002.fn_mask(pr_cdocorre,'99')||'/'
                      ||TRIM(SUBSTR(pr_dshistor,1,8))    ||')'  -- dshistor
                 , nvl(pr_nrseqdig,0)        -- nrseqdig
                 , nvl(pr_nrdocmto,0)        -- nrdocmto
                 , nvl(pr_nrdctabb,0)        -- nrdctabb
                 , ' '                       -- indebcre
                 , 0                         -- vlsdapli
                 , NULL                      -- dtdaviso
                 , 0                         -- vldaviso
                 , 0                         -- nraplica
                 , nvl(pr_cdcooper,0)        -- cdcooper
                 , nvl(pr_nrdctitg,' '))     -- nrdctitg
                 returning   craprej.dtrefere, 
                             craprej.nrdconta, 
                             craprej.nrdctitg, 
                             craprej.nrdctabb, 
                             craprej.nrdocmto, 
                             craprej.vllanmto, 
                             craprej.nrseqdig, 
                             craprej.cdbccxlt, 
                             craprej.cdagenci, 
                             craprej.nrdolote, 
                             craprej.cdcritic, 
                             craprej.cdcooper, 
                             craprej.cdpesqbb, 
                             craprej.dshistor,
                             craprej.dtmvtolt
                     into    pr_tab_cratrej(vr_indcratrej).dtrefere, 
                             pr_tab_cratrej(vr_indcratrej).nrdconta, 
                             pr_tab_cratrej(vr_indcratrej).nrdctitg, 
                             pr_tab_cratrej(vr_indcratrej).nrdctabb, 
                             pr_tab_cratrej(vr_indcratrej).nrdocmto, 
                             pr_tab_cratrej(vr_indcratrej).vllanmto, 
                             pr_tab_cratrej(vr_indcratrej).nrseqdig, 
                             pr_tab_cratrej(vr_indcratrej).cdbccxlt, 
                             pr_tab_cratrej(vr_indcratrej).cdagenci, 
                             pr_tab_cratrej(vr_indcratrej).nrdolote, 
                             pr_tab_cratrej(vr_indcratrej).cdcritic, 
                             pr_tab_cratrej(vr_indcratrej).cdcooper, 
                             pr_tab_cratrej(vr_indcratrej).cdpesqbb, 
                             pr_tab_cratrej(vr_indcratrej).dshistor,
                             pr_tab_cratrej(vr_indcratrej).dtmvtolt;    

               pr_tab_cratrej(vr_indcratrej).nmarquiv := pr_nmarquiv;                        
               pr_qtregrej := nvl(pr_qtregrej,0) + 1;
               pr_vlregrej := nvl(pr_vlregrej,0) + nvl(pr_vllanmto,0);        
                        
            EXCEPTION
              WHEN OTHERS THEN
                -- gera critica e aborta a execucao do programa
                pr_dscritic := 'Erro ao inserir na tabela craprej na rotina pc_cria_rejeitados: '||SQLERRM;
                -- retorna para o programa chamador da rotina
                RAISE vr_exc_erro;
            END; 
          END IF;                           
        EXCEPTION
          WHEN vr_exc_erro THEN
            NULL;  
        END;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro na rotina pc_cria_rejeitados: '||SQLErrm;  

          --Inclusão na tabela de erros Oracle - Chamado 743443
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          
      END pc_cria_rejeitados; /* fim cria_rejeitados */
      
      /* Armazena dados para o relatorio crrl594 */
      PROCEDURE pc_cria_relatorio_594 ( pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                       ,pr_cdbandoc    IN crapcob.cdbandoc%TYPE  -- Codigo do banco
                                       ,pr_nrdconta    IN crapcob.nrdconta%type  -- Numero da conta do associado
                                       ,pr_nrcnvcob    IN crapcob.nrcnvcob%type  -- Numero do convenio de cobranca
                                       ,pr_nrdocmto    IN crapcob.nrdocmto%type  -- Numero do documento
                                       ,pr_nrdctabb    IN crapcob.nrdctabb%type  -- Numero da conta base no banco
                                       ,pr_cdbanpag    IN crapcob.cdbanpag%type  -- Codigo Banco Pagamento
                                       ,pr_cdagepag    IN crapcob.cdagepag%type  -- Codigo Agencia Pagamento
                                       ,pr_tab_regimp  IN typ_tab_regimp         -- Tabela dos registros procesados (boletos)  
                                       ,pr_qtregrec    IN OUT INTEGER            -- Quantidade Registros Recebidos
                                       ,pr_vlregrec    IN OUT NUMBER             -- Valor Registros Recebidos
                                       ,pr_qtregicd    IN OUT INTEGER            -- Quantidade Registros Integrados Desconto
                                       ,pr_vlregicd    IN OUT NUMBER             -- Valor Registros Integrados Desconto
                                       ,pr_cdcritic    OUT INTEGER               -- Codigo da critica
                                       ,pr_dscritic    OUT VARCHAR2 ) IS         -- Descricao da critica
      
        -- Buscar cadastro de ocorrencia
        CURSOR cr_crapoco ( pr_cdcooper crapcop.cdcooper%type,
                            pr_cdbandoc crapoco.cddbanco%type,
                            pr_cdocorre crapoco.cdocorre%TYPE) IS
          SELECT dsocorre
            FROM crapoco crapoco
           WHERE crapoco.cdcooper = pr_cdcooper
             AND crapoco.cddbanco = pr_cdbandoc
             AND crapoco.cdocorre = pr_cdocorre
             AND crapoco.tpocorre = 2 /* Retorno */
           ORDER BY crapoco.progress_recid;
        rw_crapoco cr_crapoco%rowtype;
        
        -- Buscar Movimento de Retorno de Titulos Bancarios
        CURSOR cr_crapret ( pr_cdcooper crapcop.cdcooper%type,
                            pr_nrcnvcob crapret.nrcnvcob%type,
                            pr_nrdconta crapret.nrdconta%type,
                            pr_nrdocmto crapret.nrdocmto%type,
                            pr_nrremret crapret.nrremret%type,
                            pr_nrseqdig crapret.nrseqreg%TYPE) IS
          SELECT nrdconta,
                 cdcooper,
                 vltitulo,
                 vldescto,
                 vlabatim,
                 vljurmul,
                 vloutdes,
                 vloutcre,
                 vlrpagto,
                 vltarcus,
                 vltarass,
                 cdocorre
            FROM crapret
           WHERE crapret.cdcooper = pr_cdcooper
             AND crapret.nrcnvcob = pr_nrcnvcob
             AND crapret.nrdconta = pr_nrdconta
             AND crapret.nrdocmto = pr_nrdocmto
             AND crapret.nrremret = pr_nrremret
             AND crapret.nrseqreg = pr_nrseqdig
           ORDER BY crapret.progress_recid;
        rw_crapret cr_crapret%rowtype;
        
        -- Buscar Titulos contidos do Bordero de desconto de titulos
        CURSOR cr_craptdb (pr_cdcooper craptdb.cdcooper%type,
                           pr_nrdconta craptdb.nrdconta%type,
                           pr_nrcnvcob craptdb.nrcnvcob%type,
                           pr_nrdocmto craptdb.nrdocmto%type,
                           pr_nrdctabb craptdb.nrdctabb%type,
                           pr_cdbandoc craptdb.cdbandoc%type) IS 
          SELECT 1
            FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
             AND craptdb.nrdconta = pr_nrdconta
             AND craptdb.nrcnvcob = pr_nrcnvcob
             AND craptdb.nrdocmto = pr_nrdocmto
             AND craptdb.nrdctabb = pr_nrdctabb
             AND craptdb.cdbandoc = pr_cdbandoc
             AND craptdb.insittit = 4; /* liberado */
        
        rw_craptdb cr_craptdb%rowtype;
        vr_dstitdsc VARCHAR2(100);
       
       
      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_cria_relatorio_594', pr_action => NULL);
       
        -- localizar index da temptable, existe apenas um registro por vez
        vr_index_reg:= pr_tab_regimp.first;

        --Se Encontrou
        IF vr_index_reg IS NOT NULL THEN
          -- Buscar dados da ocorrencia
          OPEN cr_crapoco ( pr_cdcooper => pr_cdcooper ,
                            pr_cdbandoc => pr_cdbandoc,
                            pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre);
          FETCH cr_crapoco INTO rw_crapoco;                  
          /* A BO89 ja validou se crapOCO existe. Se chegou, existe */
          CLOSE cr_crapoco;                  
        
 
          -- Buscar Movimento de Retorno de Titulos Bancarios 
          OPEN cr_crapret( pr_cdcooper => pr_cdcooper,
                           pr_nrcnvcob => pr_tab_regimp(vr_index_reg).nrcnvcob,
                           pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta,
                           pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto,
                           pr_nrremret => pr_tab_regimp(vr_index_reg).nrremret,
                           pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig);
          FETCH cr_crapret INTO rw_crapret;
          --Fechar Cursor                       
          ClOSE cr_crapret;


          --Selecionar dados Associado
          OPEN cr_crapass(pr_cdcooper => rw_crapret.cdcooper
                         ,pr_nrdconta => rw_crapret.nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          --Fechar Cursor  
          CLOSE cr_crapass;
                    
          --Montar Indice da Ocorrencia
          vr_index_relato := rpad(pr_tab_regimp(vr_index_reg).nmarquiv,55,'#')||
                             lpad(pr_tab_regimp(vr_index_reg).cdocorre,10,'0');
          
          --Se nao existir indice no relatorio
          IF NOT vr_tab_relatorio.EXISTS(vr_index_relato) THEN
            vr_tab_relatorio(vr_index_relato).cdocorre := pr_tab_regimp(vr_index_reg).cdocorre;
            vr_tab_relatorio(vr_index_relato).dsocorre := rw_crapoco.dsocorre;
            vr_tab_relatorio(vr_index_relato).qtdregis := 1;
            vr_tab_relatorio(vr_index_relato).vltotreg := nvl(rw_crapret.vltitulo,0);
            vr_tab_relatorio(vr_index_relato).vltotdes := nvl(rw_crapret.vldescto,0) + nvl(rw_crapret.vlabatim,0);
            vr_tab_relatorio(vr_index_relato).vltotjur := nvl(rw_crapret.vljurmul,0);
            vr_tab_relatorio(vr_index_relato).vloutdeb := nvl(rw_crapret.vloutdes,0);
            vr_tab_relatorio(vr_index_relato).vloutcre := nvl(rw_crapret.vloutcre,0);
            vr_tab_relatorio(vr_index_relato).vltotpag := nvl(rw_crapret.vlrpagto,0);
            vr_tab_relatorio(vr_index_relato).vltottar := nvl(rw_crapret.vltarcus,0);
            vr_tab_relatorio(vr_index_relato).nmarquiv := pr_tab_regimp(vr_index_reg).nmarquiv;
          ELSE
            vr_tab_relatorio(vr_index_relato).qtdregis := nvl(vr_tab_relatorio(vr_index_relato).qtdregis,0) + 1;
            vr_tab_relatorio(vr_index_relato).vltotreg := nvl(vr_tab_relatorio(vr_index_relato).vltotreg,0) + nvl(rw_crapret.vltitulo,0);
            vr_tab_relatorio(vr_index_relato).vltotdes := nvl(vr_tab_relatorio(vr_index_relato).vltotdes,0) + nvl(rw_crapret.vldescto,0) + nvl(rw_crapret.vlabatim,0);
            vr_tab_relatorio(vr_index_relato).vltotjur := nvl(vr_tab_relatorio(vr_index_relato).vltotjur,0) + nvl(rw_crapret.vljurmul,0);
            vr_tab_relatorio(vr_index_relato).vloutdeb := nvl(vr_tab_relatorio(vr_index_relato).vloutdeb,0) + nvl(rw_crapret.vloutdes,0);
            vr_tab_relatorio(vr_index_relato).vloutcre := nvl(vr_tab_relatorio(vr_index_relato).vloutcre,0) + nvl(rw_crapret.vloutcre,0);
            vr_tab_relatorio(vr_index_relato).vltotpag := nvl(vr_tab_relatorio(vr_index_relato).vltotpag,0) + nvl(rw_crapret.vlrpagto,0);
            vr_tab_relatorio(vr_index_relato).vltottar := nvl(vr_tab_relatorio(vr_index_relato).vltottar,0) + nvl(rw_crapret.vltarcus,0);
            vr_tab_relatorio(vr_index_relato).tottaras := nvl(vr_tab_relatorio(vr_index_relato).tottaras,0) + nvl(rw_crapret.vltarass,0); 
          END IF;
              
          vr_dstitdsc := null;
          
          IF rw_crapret.cdocorre IN (6,17) THEN   /* liquidacao e liquidacao apos baixa */ 
            /* totais de registros integrados */
            pr_qtregrec := nvl(pr_qtregrec,0) + 1;
            pr_vlregrec := nvl(pr_vlregrec,0) + rw_crapret.vlrpagto;
            
            /* busca por titulo descontado liberado */
            OPEN cr_craptdb (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrcnvcob => pr_nrcnvcob,
                             pr_nrdocmto => pr_nrdocmto,
                             pr_nrdctabb => pr_nrdctabb,
                             pr_cdbandoc => pr_cdbandoc);
            FETCH cr_craptdb INTO rw_craptdb;
            /* totais de registros integrados c/ desconto */
            IF cr_craptdb%FOUND THEN  
              pr_qtregicd := nvl(pr_qtregicd,0) + 1;
              pr_vlregicd := nvl(pr_vlregicd,0) + rw_crapret.vlrpagto;
              vr_dstitdsc := 'TD';
            END IF;  
            --Fechar Cursor
            CLOSE cr_craptdb;           
          END IF;                 
          
          -- Definir chave do relatorio
          vr_index_analit :=  rpad(pr_tab_regimp(vr_index_reg).nmarquiv,55,'#')||
                              lpad(pr_tab_regimp(vr_index_reg).cdocorre,10,'0')||
                              lpad(rw_crapass.cdagenci,5,'0')||  
                              lpad(pr_tab_regimp(vr_index_reg).nrdconta,10,'0')|| 
                              lpad(pr_tab_regimp(vr_index_reg).nrdocmto,10,'0')||
                              substr(pr_tab_regimp(vr_index_reg).dsmotivo,1,2)||
                              lpad(vr_tab_rel_analitico.count+1,8,'0');
          -- popular temptable
          vr_tab_rel_analitico(vr_index_analit).cdocorre:= pr_tab_regimp(vr_index_reg).cdocorre;
          vr_tab_rel_analitico(vr_index_analit).dsocorre:= rw_crapoco.dsocorre;
          vr_tab_rel_analitico(vr_index_analit).cdagenci:= rw_crapass.cdagenci;
          vr_tab_rel_analitico(vr_index_analit).nrdconta:= pr_tab_regimp(vr_index_reg).nrdconta;
          vr_tab_rel_analitico(vr_index_analit).nrdocmto:= pr_tab_regimp(vr_index_reg).nrdocmto;
          vr_tab_rel_analitico(vr_index_analit).dstitdsc:= vr_dstitdsc;
          vr_tab_rel_analitico(vr_index_analit).dsdoccop:= pr_tab_regimp(vr_index_reg).dsdoccop;
          vr_tab_rel_analitico(vr_index_analit).dtvencto:= pr_tab_regimp(vr_index_reg).dtvencto;
          vr_tab_rel_analitico(vr_index_analit).vllanmto:= rw_crapret.vltitulo;
          vr_tab_rel_analitico(vr_index_analit).vldesaba:= rw_crapret.vldescto + rw_crapret.vlabatim;
          vr_tab_rel_analitico(vr_index_analit).vljurmul:= rw_crapret.vljurmul;
          vr_tab_rel_analitico(vr_index_analit).vloutdeb:= rw_crapret.vloutdes;
          vr_tab_rel_analitico(vr_index_analit).vloutcre:= rw_crapret.vloutcre;
          vr_tab_rel_analitico(vr_index_analit).vlrpagto:= rw_crapret.vlrpagto;
          vr_tab_rel_analitico(vr_index_analit).bancoage:= pr_cdbanpag||'/'||pr_cdagepag;
          vr_tab_rel_analitico(vr_index_analit).vltarifa:= rw_crapret.vltarcus;
          vr_tab_rel_analitico(vr_index_analit).dsmotivo:= pr_tab_regimp(vr_index_reg).dsmotivo;
          vr_tab_rel_analitico(vr_index_analit).nmarquiv:= pr_tab_regimp(vr_index_reg).nmarquiv;
          vr_tab_rel_analitico(vr_index_analit).nrnosnum:= pr_tab_regimp(vr_index_reg).nrnosnum;
          vr_tab_rel_analitico(vr_index_analit).vltarass:= rw_crapret.vltarass;
        END IF;        
      EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_cria_relatorio_594: '||sqlerrm;  

           --Inclusão na tabela de erros Oracle - Chamado 743443
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             

           --Levantar Excecao
           RAISE vr_exc_saida;
      END pc_cria_relatorio_594;                               
      
      /*--------------------------  Processa arquivos  -------------------------*/
      PROCEDURE pc_processa_arq_compensacao (  pr_cdcooper    IN crapcop.cdcooper%TYPE     -- Codigo da cooperativa
                                              ,pr_cdagenci    IN INTEGER                   -- Codigo da agencia
                                              ,pr_nrdcaixa    IN INTEGER                   -- N¿mero do caixa
                                              ,pr_crapdat     IN BTCH0001.cr_crapdat%rowtype -- Data do movimento
                                              ,pr_tab_cratarq IN OUT typ_tab_cratarq    -- Tabela dos arquivos q ser¿o processados
                                              ,pr_tab_trailer IN OUT typ_tab_trailer    -- Tabela com os trailers dos lotes
                                              ,pr_tab_regimp  OUT typ_tab_regimp        -- Tabela dos registros procesados (boletos)
                                              ,pr_cdcritic    OUT INTEGER               -- Codigo Erro
                                              ,pr_dscritic    OUT VARCHAR2              -- Descricao Erro
                                              ,pr_tab_erro    OUT gene0001.typ_tab_erro -- Tabela de erros
                                              ) IS 
      
      
      /*************************************************************************
          Objetivo...: Processar os arquivos de compensacao selecionados
          Observacoes: Temp-tables de retorno:
                       - pr_tab_regimp(vr_indregimp): Registros importados - boletos
      *************************************************************************/ 
        ----------------------> CURSORES <------------------------  
        -- Cursor para selecionar os parametros do cadastro de cobranca
        CURSOR cr_crapcco_arq ( pr_cdcooper IN crapcco.cdcooper%TYPE
                               ,pr_nrconven IN crapcco.nrconven%TYPE) IS
          SELECT crapcco.cdcooper
          FROM   crapcco
          WHERE  crapcco.cdcooper = pr_cdcooper
          AND    crapcco.nrconven = pr_nrconven;        
        rw_crapcco_arq cr_crapcco_arq%ROWTYPE;  
        
        -- Cursor para selecionar os parametros do cadastro de cobranca
        -- de determinado conv¿nio que n¿o seja da cooperativa logada
        CURSOR cr_crapcco_dif( pr_cdcooper IN crapcco.cdcooper%TYPE
                              ,pr_nrconven IN crapcco.nrconven%TYPE) IS
          SELECT crapcco.cdcooper
                ,COUNT(*) OVER() qtde_reg
          FROM   crapcco
          WHERE  crapcco.cdcooper <> pr_cdcooper
          AND    crapcco.nrconven = pr_nrconven;
        rw_crapcco_dif cr_crapcco_dif%ROWTYPE;
        
        -- Informacoes de contas transferidas entre cooperativas
        CURSOR cr_craptco_arq (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrctaant IN craptco.nrctaant%TYPE
                              ,pr_cdcopant IN craptco.cdcopant%TYPE) IS
          SELECT craptco.nrdconta
                 ,craptco.nrctaant
                 ,craptco.cdcopant
                 ,COUNT(*) OVER() qtde_reg
          FROM   craptco
          WHERE  craptco.cdcooper = pr_cdcooper
          AND    craptco.nrctaant = pr_nrctaant
          AND    craptco.cdcopant = pr_cdcopant
          AND    craptco.flgativo = 1;
        rw_craptco_arq cr_craptco_arq%ROWTYPE;
        
        -- Selecionar controle retorno titulos bancarios
        CURSOR cr_crapcre (pr_cdcooper IN crapcre.cdcooper%type
                          ,pr_nrcnvcob IN crapcre.nrcnvcob%type
                          ,pr_nrremret IN crapcre.nrremret%type
                          ,pr_intipmvt IN crapcre.intipmvt%type) IS
          SELECT crapcre.nrremret,
                 crapcre.nrcnvcob,
                 crapcre.cdcooper
            FROM crapcre
           WHERE crapcre.cdcooper = pr_cdcooper
             AND crapcre.nrcnvcob = pr_nrcnvcob
             AND crapcre.intipmvt = pr_intipmvt
             AND crapcre.nrremret = pr_nrremret
           ORDER BY crapcre.progress_recid;
        rw_crapcre cr_crapcre%ROWTYPE;
        
        -- Cadastro de emissao de bloquetos pelo convenio cecred
        -- e numero do convenio do Banco do Brasil
        CURSOR cr_crapceb ( pr_cdcooper IN crapcob.cdcooper%TYPE
                           ,pr_nrconven IN crapceb.nrconven%TYPE
                           ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE) IS
          SELECT crapceb.nrdconta
          FROM   crapceb
          WHERE  crapceb.cdcooper = pr_cdcooper
          AND    crapceb.nrcnvceb = pr_nrcnvceb
          AND    crapceb.nrconven = pr_nrconven
          ORDER BY progress_recid asc; --Find First
        rw_crapceb cr_crapceb%ROWTYPE;
                
        
        ---------------------> Variaveis Excecao <-----------------------  
        vr_exc_erro       EXCEPTION;
        vr_exc_prox_arq   EXCEPTION;
        vr_exc_prox_linha EXCEPTION;
        
        ---------------------> Variaveis <-----------------------          
        vr_dcmc7chq  VARCHAR2(100);
        vr_qtregrec  number := 0;
        vr_contaarq  number := 0;
        vr_vllanmto  number := 0;
        vr_nmarquiv  VARCHAR2(100);         
        --Variaveis de dados do arquivo
        vr_cdbancbb  NUMBER;
        vr_cdagedbb  NUMBER;
        vr_nrdctabb  NUMBER;
        vr_nrconven  NUMBER;
        vr_nrdocnpj  NUMBER;
        vr_cdremret  NUMBER;
        vr_nrremret  NUMBER;
        vr_loteserv  NUMBER;
        vr_nrctares  VARCHAR2(100);
        vr_cdbccxlt  crapcco.cdbccxlt%type;
        vr_nrdolote  crapcco.nrdolote%type;
        vr_cdhistor  crapcco.cdhistor%type;
        vr_vltarifa  crapcco.vlrtarif%type;
        vr_cdtarhis  crapcco.cdtarhis%type;
        vr_cdagenci  crapcco.cdagenci%type;
        vr_inarqcbr  NUMBER;
        vr_nrcnvceb  NUMBER; 
        vr_nrdconta  NUMBER;
        vr_nrdocmto  NUMBER;
        vr_incnvaut  BOOLEAN;
        vr_dtdgerac  DATE;
        vr_dtmvtolt  DATE;
        vr_dsorgarq  crapcco.dsorgarq%type;
        vr_cdocorr_carga INTEGER;
        
      BEGIN
        -- Inclusão do módulo e ao logado - Chamado 743443 - 02/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_processa_arq_compensacao', pr_action => NULL);

        -- Inicializar retorno erro
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
          
        -- limpando as tabelas tempor¿ria
        pr_tab_regimp.delete;
        pr_tab_erro.delete;
        
        -- Posicionando no primeiro registro da tabela de arquivos
        vr_index_cratarq := pr_tab_cratarq.first;
        -- Iniciando o loop na temp-table
        WHILE vr_index_cratarq IS NOT NULL LOOP
          --Controle de Fluxo proximo arquivo
          BEGIN
            -- Inicializando os acumuladores
            vr_cdcritic := 0;
            vr_qtregrec := 0;
            vr_contaarq := 0;
            vr_vllanmto := 0;

            --Abrir o arquivo lido e percorrer as linhas do mesmo
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_dir_compbb  --> Diretorio do arquivo
                                    ,pr_nmarquiv => pr_tab_cratarq(vr_index_cratarq).nmarquiv --> Nome do arquivo
                                    ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic);  --> Erro

            -- Verifica se ocorreram problemas na abertura do arquivo
            IF trim(vr_dscritic) IS NOT NULL THEN
              
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            
            -- Le os dados do arquivo e coloca na variavel vr_setlinha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
                                        
                                        
            /*---- CRITICAR HEADER ------------*/
            IF substr(vr_setlinha,8,1) = '0' THEN  /* Header do Arquivo */                            
              vr_cdbancbb  := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1 , 3));
              vr_cdagedbb  := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,53, 5));
              vr_nrdctabb  := gene0002.fn_char_para_number(SUBSTR(REPLACE(vr_setlinha,'X','0'),59,13));
              vr_nrconven  := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,33, 9));
              vr_nrdocnpj  := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,19,14));
              vr_cdremret  := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,143,1));
              vr_nrremret  := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,158,6));

              /* Verifica se o arquivo = Retorno (2) */
              IF vr_cdremret <> 2 THEN
                /* Arquivo nao eh do tipo retorno */
                vr_cdcritic := 181;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                -- Padronização de logs - Chamado 743443 - 02/10/2017
                pc_gera_log(pr_cdcooper   => pr_cdcooper,
                            pr_dstiplog   => 'E',
                            pr_dscritic   =>  vr_dscritic,
                            pr_tpocorrencia => 2);  --Erro Tratado

              END IF;
              
              --Verificar se existe parametro de cobran¿a para o convenio
              OPEN cr_crapcco_arq ( pr_cdcooper => pr_cdcooper
                                   ,pr_nrconven => vr_nrconven);
              FETCH cr_crapcco_arq INTO rw_crapcco_arq;
              -- Senao existir, somente grava log
              IF cr_crapcco_arq%NOTFOUND THEN
                vr_cdcritic := 938;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                vr_dscritic := vr_dscritic||' Conven:'||vr_nrconven||', Cooper:'||pr_cdcooper;

                -- Padronização de logs - Chamado 743443 - 02/10/2017
                pc_gera_log(pr_cdcooper   => pr_cdcooper,
                            pr_dstiplog   => 'E',
                            pr_dscritic   =>  vr_dscritic,
                            pr_tpocorrencia => 2);  --Erro Tratado
              END IF;
              --Fechar Cursor
              CLOSE cr_crapcco_arq;
              
              -- Buscar parametros de cobranca ativo do convenio
              OPEN cr_crapcco(pr_cdcooper => pr_cdcooper,
                              pr_nrconven => vr_nrconven,
                              pr_cddbanco => 1,
                              pr_flgregis => 1 /* true*/ );
              FETCH cr_crapcco INTO rw_crapcco;
              --Se nao encontrou                
              IF cr_crapcco%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapcco; 
                /* Convenio nao cadastrado ou ativo  */
                vr_cdcritic := 938;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                vr_dscritic := vr_dscritic||' Conven:'||vr_nrconven||', Cooper:'||pr_cdcooper||', Banco:1';

                -- Padronização de logs - Chamado 743443 - 02/10/2017
                pc_gera_log(pr_cdcooper   => pr_cdcooper,
                            pr_dstiplog   => 'E',
                            pr_dscritic   =>  vr_dscritic,
                            pr_tpocorrencia => 2);  --Erro Tratado
              ELSE
                --Fechar Cursor
                CLOSE cr_crapcco;

                vr_cdbccxlt := rw_crapcco.cdbccxlt;
                vr_nrdolote := rw_crapcco.nrdolote;
                vr_cdhistor := rw_crapcco.cdhistor;
                vr_vltarifa := rw_crapcco.vlrtarif;
                vr_cdtarhis := rw_crapcco.cdtarhis;
                vr_cdagenci := rw_crapcco.cdagenci;
                vr_nrconven := rw_crapcco.nrconven;
               
                --Inicializar Variaveis
                vr_vllanmto := 0;
                vr_contaarq := 1;
                vr_qtregrec := 0;
                vr_incnvaut := FALSE;
                vr_dtdgerac := TO_DATE(SUBSTR(vr_setlinha,144,8),'DDMMRRRR');
                vr_dtmvtolt := vr_dtdgerac;
                
                IF pr_nmtelant <> 'COMPEFORA' THEN
                  --Verificar Data Processamento
                  IF vr_dtmvtolt <> pr_crapdat.dtmvtolt THEN
                    /* Data invalida no arquivo */
                    vr_cdcritic := 789;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                    vr_dscritic := vr_dscritic ||' Data:'||pr_crapdat.dtmvtolt||', Data Arq:'||vr_dtmvtolt;
                    -- Padronização de logs - Chamado 743443 - 02/10/2017
                    pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                pr_dstiplog   => 'E',
                                pr_dscritic   =>  vr_dscritic,
                                pr_tpocorrencia => 2);  --Erro Tratado
                  END IF;
                END IF;    

                IF SUBSTR(vr_setlinha,4,5) <> '00000' THEN
                  vr_cdcritic := 468; /* Tipo de Registro Errado */
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  vr_dscritic := vr_dscritic||' 4a posição:'||SUBSTR(vr_setlinha,4,5);
                  -- Padronização de logs - Chamado 743443 - 02/10/2017
                  pc_gera_log(pr_cdcooper   => pr_cdcooper,
                              pr_dstiplog   => 'E',
                              pr_dscritic   => vr_dscritic,
                              pr_tpocorrencia => 2);  --Erro Tratado
                END IF;  
                --Descricao do Arquivo
                vr_dsorgarq := rw_crapcco.dsorgarq;
              END IF;
            ELSE  
              vr_cdcritic := 468; /* Tipo de Registro Errado */
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              vr_dscritic := vr_dscritic||' 8a posição:'||substr(vr_setlinha,8,1);
              -- Padronização de logs - Chamado 743443 - 02/10/2017
              pc_gera_log(pr_cdcooper   => pr_cdcooper,
                          pr_dstiplog   => 'E',
                          pr_dscritic   =>  vr_dscritic,
                          pr_tpocorrencia => 2);  --Erro Tratado
            END IF; -- Fim substr(vr_setlinha,8,1) = '0'
            
            /** Se houver critica, grava no arquivo log e passa para o proximo arq. **/
            IF vr_cdcritic <> 0 THEN
              --Fechar Arquivo
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

              -- Gerando o nome do arquivo de erro
              vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_index_cratarq).nmarquiv,1,29);

              -- Comando para copiar o arquivo para a pasta salvar
              vr_comando:= 'cp '||vr_dir_compbb||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' '||vr_dir_salvar||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
                -- retornando ao programa chamador
                raise vr_exc_erro;
              END IF;

              -- Comando para mover o arquivo
              vr_comando:= 'mv '||vr_dir_compbb||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' '||
                                  vr_dir_integra||'/'||vr_nmarquiv||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                -- gera excecao e sai da execucao
                vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
                -- retornando ao programa chamador
                raise vr_exc_erro;
              END IF;

              -- Busca a descricao da critica
              vr_dscritic := 'Houveram criticas na Importacao - 1 - integra/'||vr_nmarquiv;

              -- Padronização de logs - Chamado 743443 - 02/10/2017
              pc_gera_log(pr_cdcooper   => pr_cdcooper,
                          pr_dstiplog   => 'E',
                          pr_dscritic   =>  vr_dscritic,
                          pr_tpocorrencia => 2);  --Erro Tratado

              -- Limpando o codigo da critica
              vr_cdcritic := 0;
              --Proximo Arquivo
              RAISE vr_exc_prox_arq;
            END IF;

            /*-------- TRATAMENTO DOS DADOS - LINHA A LINHA ---------*/
            WHILE TRUE LOOP
              --Controle de Fluxo 
              BEGIN
                BEGIN
                  -- Le os dados do arquivo e coloca na variavel vr_setlinha
                  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                              ,pr_des_text => vr_setlinha); --> Texto lido
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    --se deu erro de no_data_found ¿ pq n¿o tem mais linhas no arquivo, sair do loop
                    raise vr_exc_prox_arq; /* Proximo Arquivo */                   
                END;                            

                IF SUBSTR(vr_setlinha,8,1) = '9' THEN  /* Trailer do Arquivo */
                  --Incrementar Contador Arquivo
                  vr_contaarq := nvl(vr_contaarq,0) + 1;
                  IF SUBSTR(vr_setlinha,4,5) <> '99999'  THEN
                      
                    vr_cdcritic := 468; /* Tipo de Registro Errado */
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                    vr_dscritic := vr_dscritic||'Trailler: 4a posição:'||SUBSTR(vr_setlinha,4,5)
                                   ||', Lote:'||to_char(vr_loteserv)||', Arq:'||vr_nmarquiv;

                    --Incrementar Sequencia                   
                    vr_nrsequen := NVL(vr_nrsequen,0)+ 1;                  
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_nrdcaixa => pr_nrdcaixa,
                                          pr_nrsequen => vr_nrsequen,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic,
                                          pr_tab_erro => pr_tab_erro);
                                    
                    RAISE vr_exc_prox_arq; /* Proximo Arquivo */
                  END IF; 
                  RAISE vr_exc_prox_arq; /* Proximo Arquivo */
                   
                ELSIF SUBSTR(vr_setlinha,8,1) = '1' THEN  /* HEADER do Lote */
                  IF SUBSTR(vr_setlinha,9,1) = 'T' THEN
                    --Incrementar Contador arquivo
                    vr_contaarq := nvl(vr_contaarq,0) + 1; 
                    --Lote Servidor
                    vr_loteserv := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4));
                    --Incrementar Sequencial
                    vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                    /* Confirmar (Convenio Header = Convenio Header Lote) */
                    IF gene0002.fn_char_para_number(SUBSTR(vr_setlinha,34,9)) <> vr_nrconven THEN
                      vr_cdcritic := 474;  /* Convenio Invalido */
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                      vr_dscritic := vr_dscritic
                                     ||' Convenio:'||vr_nrconven||', Convenio Arq:'||SUBSTR(vr_setlinha,34,9)
                                     ||', Lote:'||to_char(vr_loteserv)||', Arq:'||vr_nmarquiv;

                      --Incrementar Sequencia                   
                      vr_nrsequen := NVL(vr_nrsequen,0)+ 1;                  
                      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                            pr_cdagenci => pr_cdagenci,
                                            pr_nrdcaixa => pr_nrdcaixa,
                                            pr_nrsequen => vr_nrsequen,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic,
                                            pr_tab_erro => pr_tab_erro);
                                    
                      RAISE vr_exc_prox_arq; /* Proximo Arquivo */
                    END IF;  
                    
                    /* Confirmar (Nr Conta Header = Nr Conta Header Lote) */
                    IF gene0002.fn_char_para_number(SUBSTR(REPLACE(vr_setlinha,'X','0'),60,13)) <> vr_nrdctabb THEN
                      vr_cdcritic := 127;  /* Conta Errada */
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                      vr_dscritic := vr_dscritic
                                     ||' Conta:'||vr_nrdctabb||', Conta Arq:'||SUBSTR(REPLACE(vr_setlinha,'X','0'),60,13)
                                     ||', Lote:'||to_char(vr_loteserv)||', Arq:'||vr_nmarquiv;

                      --Incrementar Sequencia                   
                      vr_nrsequen := NVL(vr_nrsequen,0)+ 1;                  
                      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                            pr_cdagenci => pr_cdagenci,
                                            pr_nrdcaixa => pr_nrdcaixa,
                                            pr_nrsequen => vr_nrsequen,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic,
                                            pr_tab_erro => pr_tab_erro);
                                    
                      RAISE vr_exc_prox_arq; /* Proximo Arquivo */
                    END IF;
                    
                    /* Confirma se arqv. nao foi processado anteriormente */
                    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                                    ,pr_nrcnvcob => rw_crapcco.nrconven
                                    ,pr_intipmvt => 2 /* retorno */
                                    ,pr_nrremret => vr_nrremret);
                    --Posicionar no proximo registro
                    FETCH cr_crapcre INTO rw_crapcre;
                    --Se nao encontrar
                    IF cr_crapcre%FOUND THEN
                      --Fechar Cursor
                      CLOSE cr_crapcre;
                      vr_cdcritic := 59;  /* Lote já existe */
                      --Buscar Mensagem de Critica
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                      vr_dscritic := vr_dscritic||' Convenio:'||rw_crapcco.nrconven||', Remret:'||vr_nrremret;

                      -- Inclusão do módulo e ao logado - Chamado 743443 - 02/10/2017
                      GENE0001.pc_set_modulo(pr_module => 'PC_' || UPPER(vr_cdprogra), pr_action => 'pc_processa_arq_compensacao');
                      vr_nrsequen := nvl(vr_nrsequen,0) + 1;
                      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                            pr_cdagenci => pr_cdagenci,
                                            pr_nrdcaixa => pr_nrdcaixa,
                                            pr_nrsequen => vr_nrsequen,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic,
                                            pr_tab_erro => pr_tab_erro);

                      RAISE vr_exc_prox_arq; /* Arq.Retorno ja foi processado - Favor verificar */
                    ELSE 
                      --Somente Fechar Cursor
                      CLOSE cr_crapcre;
                    END IF;
                  END IF; -- SUBSTR(vr_setlinha,9,1) = 'T'  
                
                ELSIF  SUBSTR(vr_setlinha,8,1)  = '3' AND SUBSTR(vr_setlinha,14,1) = 'T' THEN   /* Registro Detalhe T */
                       
                  --Incrementar Contador Arquivos     
                  vr_contaarq := nvl(vr_contaarq,0) + 1;
                  
                  /** Verifica se Banco e Lote iguais ao Header **/
                  IF vr_cdbancbb <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3)) OR
                     vr_loteserv <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4)) THEN 
                    
                    vr_cdcritic := 58;  /* Nro Lote Errado */
                    --Buscar Mensagem de Critica
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                    vr_dscritic := vr_dscritic||' Detalhe T: Lote:'||to_char(vr_loteserv)||', Lote Arq:'||SUBSTR(vr_setlinha,4,4)
                                   ||', Banco:'||vr_cdbancbb||', Banco Arq:'||SUBSTR(vr_setlinha,1,3)
                                   ||', Arq:'||vr_nmarquiv;

                    vr_nrsequen := nvl(vr_nrsequen,0) + 1;
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_nrdcaixa => pr_nrdcaixa,
                                          pr_nrsequen => vr_nrsequen,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic,
                                          pr_tab_erro => pr_tab_erro);
                                    
                    RAISE vr_exc_prox_arq; /* Proximo Arquivo */
                  END IF;
                  
                  /** Buscar a Ocorrencia **/
                  vr_cdocorr_carga:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,16,2));
                  
                  /** Quando for Ocorr 17, nao vem valor no 106-130 **/
                  IF vr_cdocorr_carga = 17 THEN
                    --Numero Convenio
                    vr_nrcnvceb:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,45,4));
                    
                    -- verificando os parametros de cobranca
                    OPEN cr_crapceb( pr_cdcooper => pr_cdcooper                                
                                    ,pr_nrconven => vr_nrconven
                                    ,pr_nrcnvceb => vr_nrcnvceb);
                    FETCH cr_crapceb INTO rw_crapceb;

                    -- se encontrar atribui o numero da conta
                    IF cr_crapceb%FOUND THEN
                      vr_nrdconta:= rw_crapceb.nrdconta;
                      vr_nrdocmto:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,49,6));
                    END IF;
                    -- fecha o cursor
                    CLOSE cr_crapceb;
                  ELSE
                    vr_nrdconta:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,113,8));
                    vr_nrdocmto:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,121,9));
                  END IF; /* Fim do IF = 17 */
                  
                  --Montar Indice Registro Ordenado por Arquivo + Conta + Convenio + Ocorrencia + Sequencial
                  vr_index_reg := rpad(vr_index_cratarq,55,'#')||
                                  lpad(vr_nrdconta,10,'0')||
                                  lpad(vr_nrconven,10,'0')||
                                  lpad(pr_tab_regimp.count+1,10,'0');
                  
                  --Alimentando a tabela auxiliar 
                  pr_tab_regimp(vr_index_reg).codbanco:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3));
                  pr_tab_regimp(vr_index_reg).cdcooper:= pr_cdcooper;
                  pr_tab_regimp(vr_index_reg).cdagenci:= vr_cdagenci;
                  pr_tab_regimp(vr_index_reg).nrcnvcob:= vr_nrconven;
                  pr_tab_regimp(vr_index_reg).nrdconta:= vr_nrdconta;
                  pr_tab_regimp(vr_index_reg).nrdocmto:= vr_nrdocmto;
                  pr_tab_regimp(vr_index_reg).nrremret:= vr_nrremret;
                  pr_tab_regimp(vr_index_reg).dsdoccop:= SUBSTR(vr_setlinha,59,15);
                  pr_tab_regimp(vr_index_reg).cdocorre:= vr_cdocorr_carga;
                  pr_tab_regimp(vr_index_reg).dsmotivo:= TRIM(SUBSTR(vr_setlinha,214,10));
                  pr_tab_regimp(vr_index_reg).vllanmto:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,82,15)) / 100);
                  pr_tab_regimp(vr_index_reg).vltarifa:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,199,15)) / 100);
                  pr_tab_regimp(vr_index_reg).cdbanpag:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,97,3));
                  pr_tab_regimp(vr_index_reg).cdagepag:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,100,5));
                  /* Nosso numero - documento completo */
                  pr_tab_regimp(vr_index_reg).nrnosnum:= SUBSTR(vr_setlinha,38,20);
                  pr_tab_regimp(vr_index_reg).cdpesqbb:= SUBSTR(vr_setlinha,38,20);
                  pr_tab_regimp(vr_index_reg).nrdctabb:= vr_nrdctabb;
                  pr_tab_regimp(vr_index_reg).nrseqdig:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,9,5));
                  pr_tab_regimp(vr_index_reg).dtdpagto:= null;
                  pr_tab_regimp(vr_index_reg).nrdolote:= vr_loteserv ;/* Header Lote */
                  vr_vllanmto:= nvl(vr_vllanmto,0) + nvl(pr_tab_regimp(vr_index_reg).vllanmto,0);                               
                  pr_tab_regimp(vr_index_reg).nrcnvceb:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,45,4));
                  vr_nrctares:= null;
                  pr_tab_regimp(vr_index_reg).nrctares:= null;
                  pr_tab_regimp(vr_index_reg).nmarquiv:= pr_tab_cratarq(vr_index_cratarq).nmarquiv;
                  pr_tab_regimp(vr_index_reg).dtdgerac:= vr_dtdgerac;
                  pr_tab_regimp(vr_index_reg).dsorgarq:= vr_dsorgarq;
                  
                  IF TRIM(vr_dsorgarq) IN ('MIGRACAO','INCORPORACAO') THEN 
                    -- verifica se possui convenio migrado de outra
                    OPEN cr_crapcco_dif( pr_cdcooper => pr_cdcooper
                                        ,pr_nrconven => vr_nrconven);
                    FETCH cr_crapcco_dif INTO rw_crapcco_dif;

                    -- so processa se possuir um ¿nico convenio de migracao
                    IF cr_crapcco_dif%FOUND AND Nvl(rw_crapcco_dif.qtde_reg,0) = 1 THEN  
                      -- verifica os convenios migrados
                      OPEN cr_craptco_arq(pr_cdcooper => pr_cdcooper
                                         ,pr_nrctaant => pr_tab_regimp(vr_index_reg).nrdconta
                                         ,pr_cdcopant => rw_crapcco_dif.cdcooper);
                      FETCH cr_craptco_arq INTO rw_craptco_arq;

                      -- so processa se encontrar um unico registro na tabela
                      -- atualiza os valores na temp-table
                      IF cr_craptco_arq%FOUND AND Nvl(rw_craptco_arq.qtde_reg,0) = 1 THEN
                        pr_tab_regimp(vr_index_reg).nrdconta := rw_craptco_arq.nrdconta;
                        pr_tab_regimp(vr_index_reg).nrctaant := rw_craptco_arq.nrctaant;
                        pr_tab_regimp(vr_index_reg).cdcopant := rw_craptco_arq.cdcopant;
                        pr_tab_regimp(vr_index_reg).incoptco := TRUE;
                      END IF;
                      --Fechar Cursor
                      CLOSE cr_craptco_arq;
                    END IF;
                    --Fechar Cursor
                    CLOSE cr_crapcco_dif;  
                  END IF; -- Fim vr_dsorgarq = 'MIGRACAO' 
                  
                  --Inicializar Variaveis
                  vr_nrdconta := 0;
                  vr_nrdocmto := 0;
                  vr_nrcnvceb := 0;
                  vr_inarqcbr := 0;
                  
                  -- Cadastro de bloquetos de cobran¿a pelo documento
                  OPEN cr_crapcob ( pr_cdcooper => pr_cdcooper 
                                   ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                   ,pr_nrcnvcob => pr_tab_regimp(vr_index_reg).nrcnvcob
                                   ,pr_nrdctabb => pr_tab_regimp(vr_index_reg).nrdctabb
                                   ,pr_cdbandoc => pr_tab_regimp(vr_index_reg).codbanco
                                   ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto);
                  FETCH cr_crapcob INTO rw_crapcob;
                  --se encontrar registro
                  IF cr_crapcob%FOUND THEN
                    pr_tab_regimp(vr_index_reg).dtvencto := rw_crapcob.dtvencto;
                    pr_tab_regimp(vr_index_reg).nrdocnpj := rw_crapcob.nrinssac;
                    --Fechar Cursor
                    CLOSE cr_crapcob;
                  ELSE
                    --Fechar Cursor
                    CLOSE cr_crapcob;
                    IF TRIM(pr_tab_regimp(vr_index_reg).dsorgarq) IN ('MIGRACAO','INCORPORACAO') THEN                                      
                      -- ir para a proxima linha
                      RAISE vr_exc_prox_linha;                  
                    END IF;                    
                  END IF;    
                    
                ELSIF SUBSTR(vr_setlinha,8,1)  = '3' AND  SUBSTR(vr_setlinha,14,1) = 'U' THEN   /* Registro Detalhe U */
                     
                  --Incrementar Contador Arquivos    
                  vr_contaarq := nvl(vr_contaarq,0) + 1;
                      
                  IF vr_cdbancbb <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3)) OR
                     vr_loteserv <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4)) THEN 
                    
                    vr_cdcritic := 58;  /* Nro Lote Errado */                
                    --Buscar Mensagem de Critica
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                    vr_dscritic := vr_dscritic||' Detalhe U: Lote:'||to_char(vr_loteserv)||', Lote Arq:'||gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4))
                                   ||', Banco:'||vr_cdbancbb||', Banco Arq:'||gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3))
                                   ||', Arq:'||vr_nmarquiv;

                    vr_nrsequen := nvl(vr_nrsequen,0) + 1;
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_nrdcaixa => pr_nrdcaixa,
                                          pr_nrsequen => vr_nrsequen,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic,
                                          pr_tab_erro => pr_tab_erro);
                                    
                    RAISE vr_exc_prox_arq; /* Proximo Arquivo */    
                  END IF;  
                  
                  /* pr_tab_regimp(vr_indarq).detalhe(vr_indregimp).existe pois  obrigatorio Detalhe "T" antes */
                  pr_tab_regimp(vr_index_reg).vldescto:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,33 ,15)) / 100);
                  pr_tab_regimp(vr_index_reg).vlabatim:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,48 ,15)) / 100);
                  pr_tab_regimp(vr_index_reg).vljurmul:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,18 ,15)) / 100);
                  pr_tab_regimp(vr_index_reg).vlrpagto:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,78 ,15)) / 100);
                  pr_tab_regimp(vr_index_reg).vlliquid:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,93 ,15)) / 100);
                  pr_tab_regimp(vr_index_reg).vloutdes:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,108,15)) / 100);
                  pr_tab_regimp(vr_index_reg).vloutcre:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,123,15)) / 100);
                  pr_tab_regimp(vr_index_reg).dtdpagto:= pr_crapdat.dtmvtolt;
                  pr_tab_regimp(vr_index_reg).dtocorre:= to_date(SUBSTR(vr_setlinha,138,8),'DDMMRRRR');
                  pr_tab_regimp(vr_index_reg).cdbancor:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,211,3));
                  --Dia e Mes do Credito
                  vr_diacredi:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,146,2));
                  vr_mescredi:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,148,2));
                  
                  IF vr_diacredi = 0 OR vr_mescredi = 0 THEN
                    pr_tab_regimp(vr_index_reg).dtdcredi := NULL;
                  ELSE
                    pr_tab_regimp(vr_index_reg).dtdcredi := to_date(SUBSTR(vr_setlinha,146,8),'DDMMRRRR');
                  END IF;                   
                  
                ELSIF SUBSTR(vr_setlinha,8,1)  = '3' AND SUBSTR(vr_setlinha,14,1) = 'Y' THEN   /* Registro Detalhe Y */
                                    
                  --Incrementar Contador Arquivos
                  vr_contaarq := nvl(vr_contaarq,0) + 1;
                      
                  IF vr_cdbancbb <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3)) OR
                     vr_loteserv <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4)) THEN  
                   
                    vr_cdcritic := 58;  /* Nro Lote Errado */                
                    --Buscar Mensagem de Critica
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                    vr_dscritic := vr_dscritic||' Detalhe Y: Lote:'||to_char(vr_loteserv)||', Lote Arq:'||gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4))
                                   ||', Banco:'||vr_cdbancbb||', Banco Arq:'||gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3))
                                   ||', Arq:'||vr_nmarquiv;

                    vr_nrsequen := nvl(vr_nrsequen,0) + 1;
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_nrdcaixa => pr_nrdcaixa,
                                          pr_nrsequen => vr_nrsequen,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic,
                                          pr_tab_erro => pr_tab_erro);
                                     
                    RAISE vr_exc_prox_arq; /* Proximo Arquivo */
                  END IF;   
                  
                  --Documento Cheque
                  vr_dcmc7chq := 'Compe:' || TRIM(SUBSTR(vr_setlinha,20,3))  ||' '||
                                 'Banco:' || TRIM(SUBSTR(vr_setlinha,23,3))  ||' '||
                                 'Ag.:'   || TRIM(SUBSTR(vr_setlinha,26,4))  ||' '||
                                 'Cta.:'  || TRIM(SUBSTR(vr_setlinha,31,10)) ||' '||
                                 'Cheque:'|| TRIM(SUBSTR(vr_setlinha,42,6));
                  
                  /* Criar Log Cobranca */
                  PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                               ,pr_cdoperad => pr_cdoperad        --Operador
                                               ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                               ,pr_dsmensag => vr_dcmc7chq        --Descricao Mensagem
                                               ,pr_des_erro => vr_des_erro        --Indicador erro
                                               ,pr_dscritic => vr_dscritic);      --Descricao erro
                  --Se ocorreu erro
                  IF vr_des_erro = 'NOK' THEN
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                  END IF;
                                               
                ELSIF  SUBSTR(vr_setlinha,8,1) = '5' THEN    /* Trailer  Lote */
                  
                  --Incrementar Contador Arquivo
                  vr_contaarq := nvl(vr_contaarq,0) + 1;

                  IF vr_cdbancbb <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3)) OR
                     vr_loteserv <> gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4)) THEN 
                  
                    vr_cdcritic := 58;  /* Nro Lote Errado */                
                    --Buscar Mensagem de Critica
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                    vr_dscritic := vr_dscritic||' Trailler: Lote:'||to_char(vr_loteserv)||', Lote Arq:'||gene0002.fn_char_para_number(SUBSTR(vr_setlinha,4,4))
                                   ||', Banco:'||vr_cdbancbb||', Banco Arq:'||gene0002.fn_char_para_number(SUBSTR(vr_setlinha,1,3))
                                   ||', Arq:'||vr_nmarquiv;
                    
                    vr_nrsequen := nvl(vr_nrsequen,0) + 1;
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_nrdcaixa => pr_nrdcaixa,
                                          pr_nrsequen => vr_nrsequen,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic,
                                          pr_tab_erro => pr_tab_erro);
                                     
                    RAISE vr_exc_prox_arq; /* Proximo Arquivo */  
                  END IF;
                  
                  --Montar Indice Trailer
                  vr_index_trailer := lpad(pr_cdcooper,5,'0')||pr_tab_cratarq(vr_index_cratarq).nmarquiv;
                  --Popular Informacoes do Trailer
                  pr_tab_trailer(vr_index_trailer).cdcooper:= pr_cdcooper;
                  pr_tab_trailer(vr_index_trailer).nmarquiv:= pr_tab_cratarq(vr_index_cratarq).nmarquiv;
                  pr_tab_trailer(vr_index_trailer).qtreglot:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,18,6));
                  pr_tab_trailer(vr_index_trailer).qttitcsi:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,24,6));
                  pr_tab_trailer(vr_index_trailer).vltitcsi:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,30,17))/ 100);
                  pr_tab_trailer(vr_index_trailer).qttitcvi:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,47,6));
                  pr_tab_trailer(vr_index_trailer).vltitcvi:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,53,17))/ 100);
                  pr_tab_trailer(vr_index_trailer).qttitcca:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,70,6));
                  pr_tab_trailer(vr_index_trailer).vltitcca:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,76,17))/ 100);
                  pr_tab_trailer(vr_index_trailer).qttitcde:= gene0002.fn_char_para_number(SUBSTR(vr_setlinha,93,6));
                  pr_tab_trailer(vr_index_trailer).vltitcde:= (gene0002.fn_char_para_number(SUBSTR(vr_setlinha,99,17))/ 100);
                     
                END IF; --Fim SUBSTR(vr_setlinha,8,1)
              EXCEPTION
                 WHEN vr_exc_erro THEN
                   --Sair do programa
                   RAISE vr_exc_saida;               
                 WHEN vr_exc_prox_linha THEN  
                   NULL;
                 WHEN vr_exc_prox_arq THEN 
                  --Verificar se arquivo esta aberto
                  IF utl_file.is_open(vr_input_file) THEN
                    --Fechar Arquivo
                    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
                  END IF;
                  --Sair do loop 
                  EXIT;
              END;
            END LOOP; -- Fim While  
              
            --Verificar se arquivo est¿ aberto
            IF utl_file.is_open(vr_input_file) THEN
              --Fechar Arquivo
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
            END IF;              
            
            --se localizou alguma critica
            IF vr_cdcritic <> 0 THEN
              --Incrementar Sequencial
              vr_nrsequen := nvl(vr_nrsequen,0) + 1;

              -- limpar temptable
              pr_tab_regimp.delete;
              pr_tab_trailer.delete;
              
              -- Gerando o nome do arquivo de erro
              vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_index_cratarq).nmarquiv,1,29);

              -- Comando para copiar o arquivo para a pasta salvar
              vr_comando:= 'cp '||vr_dir_compbb||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' '||vr_dir_salvar||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
               -- retornando ao programa chamador
               RAISE vr_exc_erro;
              END IF;

              -- Comando para mover o arquivo
              vr_comando:= 'mv '||vr_dir_compbb||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' '||
                                  vr_dir_integra||'/'||vr_nmarquiv||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                -- gera excecao e sai da execucao
                vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
                -- retornando ao programa chamador
                RAISE vr_exc_erro;
              END IF;

              -- Busca a descricao da critica
              vr_dscritic := 'Houveram criticas na Importacao - 2 - integra/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv;

              -- Escrevendo a critica no log
              GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                    pr_cdagenci => pr_cdagenci,
                                    pr_nrdcaixa => pr_nrdcaixa,
                                    pr_nrsequen => vr_nrsequen,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic,
                                    pr_tab_erro => pr_tab_erro);

              -- Limpando o codigo da critica
              vr_cdcritic := 0;
              --Proximo Arquivo
              RAISE vr_exc_prox_arq;
            END IF;  
            
            -- Atualiza a temp-table dos arquivos
            pr_tab_cratarq(vr_index_cratarq).cdagenci:= vr_cdagenci;
            pr_tab_cratarq(vr_index_cratarq).cdbccxlt:= vr_cdbccxlt;
            pr_tab_cratarq(vr_index_cratarq).nrdolote:= vr_nrdolote;
            pr_tab_cratarq(vr_index_cratarq).tplotmov:= 1;
            pr_tab_cratarq(vr_index_cratarq).nroconve:= vr_nrconven;
            pr_tab_cratarq(vr_index_cratarq).nrseqdig:= vr_contaarq;
            pr_tab_cratarq(vr_index_cratarq).vllanmto:= vr_vllanmto;
            pr_tab_cratarq(vr_index_cratarq).cdhistor:= vr_cdhistor;
            pr_tab_cratarq(vr_index_cratarq).cdtarhis:= vr_cdtarhis;
            pr_tab_cratarq(vr_index_cratarq).vltarifa:= vr_vltarifa;

            -- Vai para o proximo arquivo
            vr_index_cratarq := pr_tab_cratarq.NEXT(vr_index_cratarq);
          EXCEPTION
            WHEN vr_exc_prox_arq THEN
              -- Vai para o proximo arquivo
              vr_index_cratarq:= pr_tab_cratarq.NEXT(vr_index_cratarq);
          END;                               
        END LOOP; -- Fim Loop vr_ind IS NOT NULL
      EXCEPTION  
        WHEN vr_exc_erro then
          --Montar mensagem
          pr_cdcritic:= vr_cdcritic;
          pr_dscritic:= vr_dscritic;            
        WHEN OTHERS THEN
          --Montar mensagem
          pr_cdcritic:= 0;
          pr_dscritic:= 'Erro na rotina pc_processa_arq_compensacao: '||sqlerrm;            

          --Inclusão na tabela de erros Oracle - Chamado 743443
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          
      END pc_processa_arq_compensacao;  
      
      /*Efetivar as atualizacoes com base na importacao dos arquivos*/
      PROCEDURE pc_efetiva_atualiz_compensacao (  pr_cdcooper    IN crapcop.cdcooper%TYPE       -- Codigo da cooperativa
                                                 ,pr_crapdat     IN btch0001.cr_crapdat%rowtype -- Registro da crapdat
                                                 ,pr_cdprogra    IN crapprg.cdprogra%TYPE       -- Codigo do programa
                                                 ,pr_tab_regimp  IN OUT typ_tab_regimp          -- Tabela dos titulos processados
                                                 ,pr_tab_cratarq IN OUT typ_tab_cratarq         -- Tabela dos arquivos
                                                 ,pr_tab_cratrej IN OUT typ_tab_cratrej         -- Tabela dos titulos rejeitados
                                                 ,pr_tab_erro    OUT gene0001.typ_tab_erro      -- Tabela de erros
                                                 ,pr_dscritic    OUT VARCHAR2                   -- Descricao do Erro
                                                 ,pr_des_erro    OUT VARCHAR2) IS               -- Indicador de critica
      
      /*************************************************************************
          Objetivo...: Efetivar as atualizacoes com base na importacao dos
                       arquivos
          Temp-tables: tt-regimp: Boletos importados para atualizacoes na base
                       cratarq : Arquivos a serem movidos/eliminados
      *************************************************************************/
        
        ----------------------> CURSORES <------------------------  
        
        -- Selecionar controle retorno titulos bancarios
        CURSOR cr_crapcre (pr_cdcooper IN crapcre.cdcooper%type
                          ,pr_nrcnvcob IN crapcre.nrcnvcob%type
                          ,pr_nrremret IN crapcre.nrremret%type
                          ,pr_intipmvt IN crapcre.intipmvt%type) IS
          SELECT crapcre.nrremret,
                 crapcre.nrcnvcob,
                 crapcre.cdcooper,
                 crapcre.rowid
            FROM crapcre
           WHERE crapcre.cdcooper = pr_cdcooper
             AND crapcre.nrcnvcob = pr_nrcnvcob
             AND crapcre.intipmvt = pr_intipmvt
             AND crapcre.nrremret = pr_nrremret
           ORDER BY crapcre.progress_recid;
        rw_crapcre cr_crapcre%ROWTYPE;
        
        -- Selecionar controle retorno titulos bancarios
        CURSOR cr_crapcre_data (pr_cdcooper IN crapcre.cdcooper%type
                               ,pr_nrcnvcob IN crapcre.nrcnvcob%type
                               ,pr_dtmvtolt IN crapcre.dtmvtolt%type
                               ,pr_nrremret IN crapcre.nrremret%type
                               ,pr_intipmvt IN crapcre.intipmvt%type) IS
          SELECT crapcre.nrremret,
                 crapcre.nrcnvcob,
                 crapcre.cdcooper,
                 crapcre.rowid
            FROM crapcre
           WHERE crapcre.cdcooper = pr_cdcooper
             AND crapcre.nrcnvcob = pr_nrcnvcob
             AND crapcre.dtmvtolt = pr_dtmvtolt
             AND crapcre.intipmvt = pr_intipmvt
             AND crapcre.nrremret = pr_nrremret
           ORDER BY crapcre.progress_recid;

        -- Cursor para selecionar os parametros do cadastro de cobranca
        -- de determinado conv¿nio que n¿o seja da cooperativa logada
        CURSOR cr_crapcco_dif( pr_cdcooper IN crapcco.cdcooper%TYPE
                              ,pr_nrconven IN crapcco.nrconven%TYPE) IS
          SELECT crapcco.cdcooper
                ,COUNT(*) OVER() qtde_reg
          FROM   crapcco
          WHERE  crapcco.cdcooper <> pr_cdcooper
          AND    crapcco.nrconven = pr_nrconven
          AND    crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO');
        rw_crapcco_dif cr_crapcco_dif%ROWTYPE;
        
        -- Informacoes de contas transferidas entre cooperativas
        CURSOR cr_craptco_arq(pr_cdcopant IN craptco.cdcopant%TYPE
                             ,pr_nrctaant IN craptco.nrctaant%TYPE
                             ,pr_cdcooper IN crapcop.cdcooper%TYPE
                             ) IS
          SELECT  craptco.nrdconta
                 ,craptco.cdagenci
                 ,craptco.nrctaant
                 ,craptco.cdcopant
                 ,craptco.cdcooper
                 ,COUNT(*) OVER() qtde_reg
          FROM   craptco
          WHERE  craptco.cdcopant = pr_cdcopant
          AND    craptco.nrctaant = pr_nrctaant
          AND    craptco.cdcooper = pr_cdcooper
          AND    craptco.tpctatrf <> 3
          AND    craptco.flgativo = 1;
        rw_craptco_arq cr_craptco_arq%ROWTYPE;
        
        -- Informacoes de contas transferidas entre cooperativas
        CURSOR cr_craptco_arq2 (pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta IN craptco.nrctaant%TYPE
                               ,pr_cdcopant IN craptco.cdcopant%TYPE
                               ) IS
          SELECT  craptco.nrdconta
                 ,craptco.cdagenci
                 ,craptco.nrctaant
                 ,craptco.cdcopant
                 ,craptco.cdcooper
                 ,COUNT(*) OVER() qtde_reg
          FROM   craptco
          WHERE  craptco.cdcooper = pr_cdcooper
          AND    craptco.nrdconta = pr_nrdconta
          AND    craptco.cdcopant = pr_cdcopant
          AND    craptco.tpctatrf <> 3
          AND    craptco.flgativo = 1;

        -- Buscar Acerto Financeiro BB entre cooperativas.
        CURSOR cr_crapafi (pr_cdcooper crapafi.cdcooper%type,
                           pr_nrdctabb crapafi.nrdctabb%type,
                           pr_dtmvtolt crapafi.dtmvtolt%type,
                           pr_cdcopdst crapafi.cdcopdst%type,
                           pr_nrctadst crapafi.nrctadst%type,
                           pr_cdhistor crapafi.cdhistor%type) IS 
          SELECT crapafi.rowid 
            FROM crapafi crapafi
           WHERE crapafi.cdcooper = pr_cdcooper
             AND crapafi.nrdctabb = pr_nrdctabb
             AND crapafi.dtmvtolt = pr_dtmvtolt
             AND crapafi.cdcopdst = pr_cdcopdst
             AND crapafi.nrctadst = pr_nrctadst
             AND crapafi.cdhistor = pr_cdhistor;
        rw_crapafi cr_crapafi%rowtype;
        
        ---------------------> Variaveis Excecao <-----------------------  
        
        vr_exc_erro     EXCEPTION;        
        vr_exc_prox     EXCEPTION;  
        vr_exc_prox_arq EXCEPTION;  
        vr_exc_prox_det EXCEPTION;     
        
        ---------------------> Variaveis <-----------------------     
        rw_crapcop_efet cr_crapcop%ROWTYPE;
        vr_index_desc   varchar2(20);
        vr_index_titulo varchar2(20);
        vc_qtdmigra     NUMBER := 0;
        vr_vlrmigra     NUMBER := 0;
        vr_qtregrec     NUMBER := 0;
        vr_vlregrec     NUMBER := 0;
        vr_qtregrej     NUMBER := 0;
        vr_vlregrej     NUMBER := 0;
        vr_qtregicd     NUMBER := 0;
        vr_vlregicd     NUMBER := 0;
        vr_qtregisd     NUMBER := 0;
        vr_vlregisd     NUMBER := 0;
        vr_nrretcoo     NUMBER := 0;
        vr_vllanmto     NUMBER;
        vr_vlcompcr     NUMBER;
        vr_cdpesqbb     VARCHAR2(100);
        vr_flagtco      BOOLEAN;
        vr_inpessoa     crapass.inpessoa%type;
        vr_cdhistor     craphis.cdhistor%type;
        vr_cdtarhis     craphis.cdhistor%type;
        vr_cdhisest     INTEGER;
        vr_dtdivulg     DATE;
        vr_dtvigenc     DATE;
        vr_cdfvlcop     INTEGER; 
        vr_dsmotivo     varchar2(200);
        vr_vltarifa     NUMBER;
        vr_vlrjuros     NUMBER;
        vr_vlrmulta     NUMBER;
        vr_vldescto     NUMBER;
        vr_vlabatim     NUMBER;
        vr_vlfatura     NUMBER;
        vr_crapcob      BOOLEAN;
        vr_flgvenci     BOOLEAN;
        vr_craptco_arq  BOOLEAN;
        vr_cdocorre     NUMBER;
        vr_dtmvtaux     DATE;
        vr_dtmovnto     DATE;
        vr_index_erro   INTEGER;
        vr_qtdmigra     NUMBER;
        vr_achou        BOOLEAN;
        vr_cdhisafi     crapafi.cdhisafi%TYPE;
        vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
        vr_tab_descontar       PAGA0001.typ_tab_titulos;
        vr_tab_titulos         PAGA0001.typ_tab_titulos;
        vr_tab_erro2           GENE0001.typ_tab_erro;
        vr_tab_regimp_rel      typ_tab_regimp;
        
      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);
        
        --Inicializar retorno
        pr_des_erro:= 'OK';
        pr_dscritic:= NULL;
        
        -- Limpar tempTable
        pr_tab_erro.delete;
        vr_tab_lcm_consolidada.delete;  

        BEGIN

          --Limpar tabela migracao
          vr_tab_migracao.DELETE;
          
          /*--- Efetuando as Atualizacoes ---*/
          
          -- posicionando no primeiro registro da temp-table
          vr_index_cratarq := pr_tab_cratarq.first;
          -- Iniciando o loop e processamento do arquivo

          WHILE vr_index_cratarq IS NOT NULL LOOP

            --Controlar desvio fluxo para proximo arquivo
            BEGIN  
              --Limpar tabela lancamentos consolidada
              vr_tab_lcm_consolidada.delete;  
              
              -- Inicializar as variaveis
              vc_qtdmigra := 0;
              vr_vlrmigra := 0;
              vr_qtregrec := 0;
              vr_vlregrec := 0;
              vr_qtregrej := 0;
              vr_vlregrej := 0;
              vr_qtregicd := 0;
              vr_vlregicd := 0;
              vr_qtregisd := 0;
              vr_vlregisd := 0;
              
              --Indicar se encontrou ou nao boleto
              vr_achou:= FALSE;
              
              --Buscar indices
              vr_index_reg:= pr_tab_regimp.FIRST;
              --Percorrer todos os registros

              WHILE vr_index_reg IS NOT NULL LOOP 
                --Somente a primeira ocorrencia de cada arquivo
                IF pr_tab_regimp(vr_index_reg).nmarquiv = pr_tab_cratarq(vr_index_cratarq).nmarquiv THEN
                  --Marcar que achou registro para esse arquivo
                  vr_achou:= TRUE;

                  /* Confirma se arqv. n¿o foi processado anteriormente */
                  OPEN cr_crapcre_data (pr_cdcooper => pr_cdcooper
                                       ,pr_nrcnvcob => pr_tab_regimp(vr_index_reg).nrcnvcob
                                       ,pr_dtmvtolt => pr_tab_regimp(vr_index_reg).dtdgerac
                                       ,pr_intipmvt => 2 /* retorno */
                                       ,pr_nrremret => pr_tab_regimp(vr_index_reg).nrremret);
                  --Posicionar no proximo registro
                  FETCH cr_crapcre_data INTO rw_crapcre;
                  --Se nao encontrar
                  IF cr_crapcre_data%NOTFOUND THEN
                    --Somente Fechar Cursor
                    CLOSE cr_crapcre_data;
                    /* Cada arquivo = Uma remessa */
                    BEGIN
                      INSERT INTO crapcre
                         (crapcre.cdcooper,
                          crapcre.nrcnvcob,
                          crapcre.dtmvtolt,
                          crapcre.nrremret,
                          crapcre.intipmvt,
                          crapcre.nmarquiv,
                          crapcre.flgproce,
                          crapcre.cdoperad,
                          crapcre.dtaltera,
                          crapcre.hrtranin)
                      VALUES 
                         (pr_cdcooper,                                                -- cdcooper
                          nvl(pr_tab_regimp(vr_index_reg).nrcnvcob,0),                -- nrcnvcob
                          pr_tab_regimp(vr_index_reg).dtdgerac,                       -- dtmvtolt
                          nvl(pr_tab_regimp(vr_index_reg).nrremret,0),                -- nrremret
                          2,                                                          -- intipmvt  /* retorno */
                          'compbb/'||nvl(pr_tab_cratarq(vr_index_cratarq).nmarquiv,' '),         -- nmarquiv
                          0,                                                          -- flgproce 0 = FALSE
                          nvl(pr_cdoperad,' '),                                       -- cdoperad
                          pr_crapdat.dtmvtolt,                                        -- dtaltera
                          gene0002.fn_busca_time)                                     -- hrtranin 
                      RETURNING crapcre.rowid
                               ,crapcre.nrremret
                      INTO rw_crapcre.rowid
                          ,rw_crapcre.nrremret;                        
                    EXCEPTION
                      WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapcre: cdcooper:'||pr_cdcooper
                                         ||', nrcnvcob:'||nvl(pr_tab_regimp(vr_index_reg).nrcnvcob,0)
                                         ||', dtmvtolt:'||pr_tab_regimp(vr_index_reg).dtdgerac
                                         ||', nrremret:'||nvl(pr_tab_regimp(vr_index_reg).nrremret,0)
                                         ||', intipmvt:2'
                                         ||', nmarquiv:'||'compbb/'||nvl(pr_tab_cratarq(vr_index_cratarq).nmarquiv,' ')
                                         ||', flgproce:0'
                                         ||', cdoperad:'||nvl(pr_cdoperad,' ')
                                         ||', dtaltera:'||pr_crapdat.dtmvtolt
                                         ||', hrtranin:'||gene0002.fn_busca_time||'. '||SQLErrm;
                        raise vr_exc_erro;
                    END;  
                  ELSE 
                    --Fechar Cursor
                    CLOSE cr_crapcre_data;
                  END IF;
                  --Sair do Loop pois s¿ deve processar para o primeiro que encontrar
                  EXIT;
                END IF;  
                --Buscar Proximo indice
                vr_index_reg:= pr_tab_regimp.NEXT(vr_index_reg);
              END LOOP;
              
              --Se nao encontrou boleto para o arquivo vai para proximo
              IF NOT vr_achou THEN
                --Proximo Arquivo
                RAISE vr_exc_prox_arq;
              END IF;  
                                     
              --Posicionar Novamente no primeiro registro 
              vr_index_reg:= pr_tab_regimp.FIRST;
                
              --Percorrer todos os registros do arquivo
              WHILE vr_index_reg IS NOT NULL LOOP 
                --Mesmo Arquivo
                IF pr_tab_regimp(vr_index_reg).nmarquiv = pr_tab_cratarq(vr_index_cratarq).nmarquiv THEN
    
                  --Controle de fluxo para pulo de linha
                  BEGIN  
                    
                    --Inicializar Controle Critica                  
                    vr_cdcritic := 0;
                    --Somar Juros e Diminuir Abatimento do valor do Lancamento
                    vr_vllanmto := nvl(pr_tab_regimp(vr_index_reg).vllanmto,0) + 
                                   nvl(pr_tab_regimp(vr_index_reg).vljurmul,0) - 
                                   nvl(pr_tab_regimp(vr_index_reg).vlabatim,0);
                    vr_vlcompcr := nvl(vr_vlcompcr,0) + nvl(pr_tab_regimp(vr_index_reg).vllanmto,0);
                    vr_cdpesqbb := gene0002.fn_mask(pr_tab_regimp(vr_index_reg).nrcnvcob,'99999999');
                    vr_flagtco  := FALSE;
                  
                    --Limpar registro tco
                    rw_craptco_arq:= NULL;
                    
                    IF NOT pr_tab_regimp(vr_index_reg).incoptco OR 
                       pr_tab_regimp(vr_index_reg).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                    
                      IF NOT pr_tab_regimp(vr_index_reg).incoptco THEN
                        -- verifica se possui convenio migrado ou incoporado de outra
                        OPEN cr_crapcco_dif( pr_cdcooper => pr_cdcooper
                                            ,pr_nrconven => pr_tab_regimp(vr_index_reg).nrcnvcob);
                        FETCH cr_crapcco_dif INTO rw_crapcco_dif;
                        -- s¿ processa se possuir um ¿nico convenio de migracao
                        IF cr_crapcco_dif%FOUND AND Nvl(rw_crapcco_dif.qtde_reg,0) = 1 THEN  
                          -- verifica os convenios migrados
                          OPEN cr_craptco_arq(pr_cdcopant => pr_cdcooper
                                             ,pr_nrctaant => pr_tab_regimp(vr_index_reg).nrdconta
                                             ,pr_cdcooper => rw_crapcco_dif.cdcooper);
                          FETCH cr_craptco_arq INTO rw_craptco_arq;
                          --Verificar se retornou registro
                          vr_craptco_arq:= cr_craptco_arq%FOUND;
                          --Fechar Cursor
                          CLOSE cr_craptco_arq;
                        END IF;
                        --Fechar Cursor
                        CLOSE cr_crapcco_dif;
                      ELSE
                        -- verifica os convenios migrados
                        OPEN cr_craptco_arq2 (pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                             ,pr_cdcopant => pr_tab_regimp(vr_index_reg).cdcopant);
                        FETCH cr_craptco_arq2 INTO rw_craptco_arq;
                        --Verificar se retornou registro
                        vr_craptco_arq:= cr_craptco_arq2%FOUND;
                        --Fechar Cursor
                        CLOSE cr_craptco_arq2;                  
                      END IF;              
                      
                      -- so processa se possuir um ¿nica tranferencia
                      IF vr_craptco_arq AND Nvl(rw_craptco_arq.qtde_reg,0) = 1 THEN 
                        IF  NOT pr_tab_regimp(vr_index_reg).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN 

                          -- cria os rejeitados
                          pc_cria_rejeitados ( pr_cdcooper => pr_cdcooper
                                              ,pr_cdcritic => 951 /* conta migrada */
                                              ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                              ,pr_nrdctitg => ' '
                                              ,pr_nrdctabb => pr_tab_regimp(vr_index_reg).nrdctabb
                                              ,pr_dshistor => pr_tab_regimp(vr_index_reg).dsmotivo
                                              ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre
                                              ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto  -- N¿mero do documento
                                              ,pr_vllanmto => nvl(vr_vllanmto,0)                    -- Valor do lancamento
                                              -- parametros da tab_regimp
                                              ,pr_nmarquiv => pr_tab_regimp(vr_index_reg).nmarquiv
                                              ,pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig
                                              ,pr_codbanco => pr_tab_regimp(vr_index_reg).codbanco
                                              ,pr_cdagenci => pr_tab_regimp(vr_index_reg).cdagenci
                                              ,pr_nrdolote => pr_tab_regimp(vr_index_reg).nrdolote
                                              ,pr_cdpesqbb => pr_tab_regimp(vr_index_reg).cdpesqbb
                                              ,pr_tab_cratrej => pr_tab_cratrej
                                              ,pr_qtregrej    => vr_qtregrej
                                              ,pr_vlregrej    => vr_vlregrej
                                              ,pr_dscritic    => vr_dscritic);
                          -- Tratando a critica
                          IF trim(vr_dscritic) IS NOT NULL THEN
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;

                          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);
                        END IF;
                        
                        /* Assume como padrao pessoa juridica*/
                        vr_inpessoa:= 2;
                        
                        --Selecionar dados Associado
                        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta);
                        FETCH cr_crapass INTO rw_crapass;
                        --Se nao Encontrou
                        IF cr_crapass%FOUND THEN
                          vr_inpessoa:= rw_crapass.inpessoa; 
                        END IF;
                        --Fechar Cursor  
                        CLOSE cr_crapass;
                        
                        --Zerar valor tarifa
                        vr_vltarifa := 0;
                        vr_cdhistor := 0;

                        IF pr_tab_regimp(vr_index_reg).cdocorre <> 28 THEN
                          vr_dsmotivo:= ' ';
                        ELSE
                          vr_dsmotivo:= pr_tab_regimp(vr_index_reg).dsmotivo;
                        END IF;

                        /* Busca informacoes tarifa */
                        TARI0001.pc_carrega_dados_tarifa_cobr (pr_cdcooper  => pr_cdcooper        -- Codigo Cooperativa
                                                              ,pr_nrdconta  => pr_tab_regimp(vr_index_reg).nrdconta --Numero Conta
                                                              ,pr_nrconven  => pr_tab_regimp(vr_index_reg).nrcnvcob --Numero Convenio
                                                              ,pr_dsincide  => 'RET'              -- Descricao Incidencia
                                                              ,pr_cdocorre  => pr_tab_regimp(vr_index_reg).cdocorre --Codigo Ocorrencia
                                                              ,pr_cdmotivo  => vr_dsmotivo        -- Codigo Motivo
                                                              ,pr_inpessoa  => vr_inpessoa        -- Tipo Pessoa
                                                              ,pr_vllanmto  => 1                  -- Valor Lancamento
                                                              ,pr_cdprogra  => pr_cdprogra        -- Nome Programa
                                                              ,pr_flaputar  => 1                  --Apurar
                                                               ,pr_cdhistor  => vr_cdhistor        -- Codigo Historico
                                                              ,pr_cdhisest  => vr_cdhisest        -- Historico Estorno
                                                              ,pr_vltarifa  => vr_vltarifa        -- Valor Tarifa
                                                              ,pr_dtdivulg  => vr_dtdivulg        -- Data Divulgacao
                                                              ,pr_dtvigenc  => vr_dtvigenc        -- Data Vigencia
                                                              ,pr_cdfvlcop  => vr_cdfvlcop        -- Codigo Cooperativa
                                                              ,pr_cdcritic  => pr_cdcritic        -- Codigo Critica
                                                              ,pr_dscritic  => vr_dscritic);      -- Descricao Critica
                        -- se retornar erro
                        IF trim(vr_dscritic) IS NOT NULL THEN
                          vr_cdhistor := 969; /* Tarifa Custa */
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  'Adotado Historico 969 - RET - '
                                                          || pr_tab_regimp(vr_index_reg).nrcnvcob|| ' - '
                                                          || pr_tab_regimp(vr_index_reg).cdocorre|| ' - '
                                                          || vr_dsmotivo,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          -- limpa a variavel de critica
                          vr_dscritic := ' '; 
                          pr_tab_erro.delete; 
                        END IF; --Fim trim(pr_dscritic) IS NOT NULL      
                        
                        IF pr_tab_regimp(vr_index_reg).cdocorre IN (6,17) THEN
                          vr_cdtarhis := vr_cdhistor;
                            /* Nao sofre alteracao. */
                        ELSE
                          vr_cdtarhis := vr_cdhistor;
                          vr_vllanmto := 0;
                        END IF;
                        
                        -- Somente gerar tt-migracao se nao for convenio de              --
                        -- incorporacao, pois estes nao precisam gerar crapafi SD236521  -- 
                        IF  pr_tab_regimp(vr_index_reg).dsorgarq NOT IN ('INCORPORACAO') THEN 
                        
                          -- criando o indice da temp-table
                          vr_index_migracao:= rpad(pr_tab_regimp(vr_index_reg).nmarquiv,55,'#')||
                                              lpad(rw_craptco_arq.nrdconta,10,'0')||
                                              lpad(vr_cdtarhis,10,'0');
                          
                          -- Verifica se existe o registro de conta e convenio na tabela temporaria
                          IF vr_tab_migracao.exists(vr_index_migracao) THEN
                            -- Atualiza o registro
                            vr_tab_migracao(vr_index_migracao).vllanmto := nvl(vr_tab_migracao(vr_index_migracao).vllanmto,0) + nvl(vr_vllanmto,0);
                            vr_tab_migracao(vr_index_migracao).vlrtarif := nvl(vr_tab_migracao(vr_index_migracao).vlrtarif,0) + 
                                                                           nvl(pr_tab_regimp(vr_index_reg).vltarifa,0) +
                                                                           nvl(pr_tab_regimp(vr_index_reg).vloutdes,0);
                            vr_tab_migracao(vr_index_migracao).qttitmig := nvl(vr_tab_migracao(vr_index_migracao).qttitmig,0) + 1;
                          ELSE  
                            -- se n¿o ¿ convenio proveniente de migracao ele busca da cooperativa
                            -- normal, sen¿o ele buscada cooperativa anterior
                            IF  NOT pr_tab_regimp(vr_index_reg).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                              -- busca informa¿¿es da cooperativa
                              OPEN cr_crapcop(pr_cdcooper => rw_craptco_arq.cdcooper);
                              FETCH cr_crapcop INTO rw_crapcop_efet;
                              CLOSE cr_crapcop;
                            ELSE
                              -- busca informa¿¿es da cooperativa
                              OPEN cr_crapcop(pr_cdcooper => rw_craptco_arq.cdcopant);
                              FETCH cr_crapcop INTO rw_crapcop_efet;
                              CLOSE cr_crapcop;
                            END IF;  

                            -- cria um novo registro
                            vr_tab_migracao(vr_index_migracao).nrdctabb:= pr_tab_regimp(vr_index_reg).nrdctabb;
                            vr_tab_migracao(vr_index_migracao).cdcopdst:= rw_crapcop_efet.cdcooper;
                            vr_tab_migracao(vr_index_migracao).nmrescop:= rw_crapcop_efet.nmrescop;
                            vr_tab_migracao(vr_index_migracao).nrctadst:= rw_craptco_arq.nrdconta;
                            vr_tab_migracao(vr_index_migracao).cdagedst:= rw_craptco_arq.cdagenci;
                            vr_tab_migracao(vr_index_migracao).cdhistor:= vr_cdtarhis;
                            vr_tab_migracao(vr_index_migracao).vllanmto:= nvl(vr_vllanmto,0);
                            vr_tab_migracao(vr_index_migracao).vlrtarif:= nvl(pr_tab_regimp(vr_index_reg).vltarifa,0) + 
                                                                          nvl(pr_tab_regimp(vr_index_reg).vloutdes,0);                    
                            vr_tab_migracao(vr_index_migracao).dsorgarq:= pr_tab_regimp(vr_index_reg).dsorgarq;
                            vr_tab_migracao(vr_index_migracao).nroconve:= pr_tab_regimp(vr_index_reg).nrcnvcob;                    
                            vr_tab_migracao(vr_index_migracao).qttitmig:= 1;
                            vr_tab_migracao(vr_index_migracao).nmarquiv:= pr_tab_cratarq(vr_index_cratarq).nmarquiv;

                          END IF;--IF vr_tab_migracaocob.exists(vr_index_migracao) THEN
                        END IF;
                        --Possui tco
                        vr_flagtco:= TRUE;
                      END IF;
                    END IF; -- Fim NOT incoptco OR dsorgarq = 'MIGRACAO' 
                    
                    IF NOT vr_flagtco OR pr_tab_regimp(vr_index_reg).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                      -- Buscando informacoes de cobranca
                      OPEN cr_crapcob( pr_cdcooper => pr_cdcooper
                                      ,pr_nrcnvcob => pr_tab_regimp(vr_index_reg).nrcnvcob
                                      ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                      ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto
                                      ,pr_cdbandoc => pr_tab_regimp(vr_index_reg).codbanco
                                      ,pr_nrdctabb => pr_tab_regimp(vr_index_reg).nrdctabb                                
                                      );
                      FETCH cr_crapcob INTO rw_crapcob;
                      -- Se n¿o localizar 
                      IF cr_crapcob%NOTFOUND  THEN 
                        --Fechar Cursor
                        CLOSE cr_crapcob; 
                        IF pr_tab_regimp(vr_index_reg).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN 
                          -- Proximo registro
                          RAISE vr_exc_prox_det;
                        END IF;

                        -- cria os rejeitados
                        pc_cria_rejeitados ( pr_cdcooper => pr_cdcooper
                                            ,pr_cdcritic => 592 
                                            ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                            ,pr_nrdctitg => ' '
                                            ,pr_nrdctabb => 0
                                            ,pr_dshistor => pr_tab_regimp(vr_index_reg).dsmotivo
                                            ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre
                                            ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto  -- N¿mero do documento
                                            ,pr_vllanmto => nvl(vr_vllanmto,0)                    -- Valor do lancamento
                                            -- parametros da tab_regimp
                                            ,pr_nmarquiv => pr_tab_regimp(vr_index_reg).nmarquiv
                                            ,pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig
                                            ,pr_codbanco => pr_tab_regimp(vr_index_reg).codbanco
                                            ,pr_cdagenci => pr_tab_regimp(vr_index_reg).cdagenci
                                            ,pr_nrdolote => pr_tab_regimp(vr_index_reg).nrdolote
                                            ,pr_cdpesqbb => pr_tab_regimp(vr_index_reg).cdpesqbb
                                            ,pr_tab_cratrej => pr_tab_cratrej
                                            ,pr_qtregrej    => vr_qtregrej
                                            ,pr_vlregrej    => vr_vlregrej
                                            ,pr_dscritic    => vr_dscritic);
                        -- Tratando a critica
                        IF trim(vr_dscritic) IS NOT NULL THEN
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                        END IF;

                        -- Proximo registro
                        RAISE vr_exc_prox_det;
                        -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);

                      ELSE
                        --Fechar Cursor
                        CLOSE cr_crapcob;  
                      END IF; -- Fim cr_crapcob%NOTFOUND
                      
                      -- Tratamento para utilizar o case 
                      IF pr_tab_regimp(vr_index_reg).cdocorre in (12,13,14,19,20) THEN
                        vr_cdocorre := 9999;
                      ELSE
                        vr_cdocorre := pr_tab_regimp(vr_index_reg).cdocorre;   
                      END IF;  

                      /* Titulo Existe - Efetuar processamento */
                      CASE vr_cdocorre
                        WHEN 2 THEN --Entrada Confirmada
                          
                          /* Gerar registro de Retorno = 02 - Entrada Confirmada */
                          PAGA0002.pc_ent_confirmada( pr_cdcooper => pr_cdcooper                                -- Codigo da cooperativa
                                                     ,pr_idtabcob => rw_crapcob.rowid                           -- Rowid da Cobranca
                                                     ,pr_nrnosnum => pr_tab_regimp(vr_index_reg).nrnosnum       -- Nosso Numero
                                                     ,pr_cdbcocob => pr_tab_regimp(vr_index_reg).cdbanpag       -- Codigo banco cobran¿a
                                                     ,pr_cdagecob => pr_tab_regimp(vr_index_reg).cdagepag       -- Codigo Agencia cobranca
                                                     ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre       -- Codigo Ocorrencia
                                                     ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo       -- Descricao Motivo
                                                     ,pr_crapdat  => pr_crapdat                                 -- Data movimento
                                                     ,pr_cdoperad => pr_cdoperad                                -- Codigo Operador    
                                                     ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada          -- Tabela lancamentos consolidada
                                                     ,pr_ret_nrremret => vr_nrretcoo                            -- Numero Remessa Retorno Cooperado
                                                     ,pr_cdcritic     => vr_cdcritic                            -- Codigo da critica
                                                     ,pr_dscritic     => vr_dscritic);                          -- Descricao critica
                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado

                            -- cria os rejeitados
                            pc_cria_rejeitados(  pr_cdcooper => pr_cdcooper
                                                ,pr_cdcritic => vr_cdcritic 
                                                ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                                ,pr_nrdctitg => ' '
                                                ,pr_nrdctabb => 0
                                                ,pr_dshistor => pr_tab_regimp(vr_index_reg).dsmotivo
                                                ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre
                                                ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto  -- N¿mero do documento
                                                ,pr_vllanmto => nvl(vr_vllanmto,0)                    -- Valor do lancamento
                                                -- parametros da tab_regimp
                                                ,pr_nmarquiv => pr_tab_regimp(vr_index_reg).nmarquiv
                                                ,pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig
                                                ,pr_codbanco => pr_tab_regimp(vr_index_reg).codbanco
                                                ,pr_cdagenci => pr_tab_regimp(vr_index_reg).cdagenci
                                                ,pr_nrdolote => pr_tab_regimp(vr_index_reg).nrdolote
                                                ,pr_cdpesqbb => pr_tab_regimp(vr_index_reg).cdpesqbb
                                                ,pr_tab_cratrej => pr_tab_cratrej
                                                ,pr_qtregrej    => vr_qtregrej
                                                ,pr_vlregrej    => vr_vlregrej
                                                ,pr_dscritic    => vr_dscritic);
                              -- Tratando a critica
                              IF trim(vr_dscritic) IS NOT NULL THEN
                                -- Padronização de logs - Chamado 743443 - 02/10/2017
                                pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                            pr_dstiplog   => 'E',
                                            pr_dscritic   => vr_dscritic,
                                            pr_tpocorrencia => 2);  --Erro Tratado
                              END IF;
                              -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                              GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);

                          END IF;     
                                           
                        WHEN 3 THEN         --Entrada Rejeitada
                          
                          /* nao tratar entrada rejeitada e motivos 39,00,60 ou "" */
                          IF SUBSTR(pr_tab_regimp(vr_index_reg).dsmotivo,1,2) in ('60','00','39') OR 
                             TRIM(pr_tab_regimp(vr_index_reg).dsmotivo) is null THEN 
                            -- Proximo registro
                            RAISE vr_exc_prox_det;
                          END IF;
                          
                          /* Gerar registro de Retorno = 03 - Entrada Rejeitada */
                          PAGA0002.pc_ent_rejeitada ( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                     ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                               
                                                     ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                     ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                     ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                     ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador                                                   
                                                     ,pr_ret_nrremret => vr_nrretcoo                      -- Numero remetente
                                                     ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                     ,pr_dscritic => vr_dscritic);                        -- Descricao critica

                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;

                          -- cria os rejeitados
                          pc_cria_rejeitados ( pr_cdcooper => pr_cdcooper
                                              ,pr_cdcritic => 0 
                                              ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                              ,pr_nrdctitg => ' '
                                              ,pr_nrdctabb => 0
                                              ,pr_dshistor => pr_tab_regimp(vr_index_reg).dsmotivo
                                              ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre
                                              ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto  -- N¿mero do documento
                                              ,pr_vllanmto => nvl(vr_vllanmto,0)                    -- Valor do lancamento
                                              -- parametros da tab_regimp
                                              ,pr_nmarquiv => pr_tab_regimp(vr_index_reg).nmarquiv
                                              ,pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig
                                              ,pr_codbanco => pr_tab_regimp(vr_index_reg).codbanco
                                              ,pr_cdagenci => pr_tab_regimp(vr_index_reg).cdagenci
                                              ,pr_nrdolote => pr_tab_regimp(vr_index_reg).nrdolote
                                              ,pr_cdpesqbb => pr_tab_regimp(vr_index_reg).cdpesqbb
                                              ,pr_tab_cratrej => pr_tab_cratrej
                                              ,pr_qtregrej    => vr_qtregrej
                                              ,pr_vlregrej    => vr_vlregrej
                                              ,pr_dscritic    => vr_dscritic);
                          -- Tratando a critica
                          IF trim(vr_dscritic) IS NOT NULL THEN
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;                    
                          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);
                      
                        WHEN 6 THEN --Liquidacao
                          
                          /* variaveis de calculo cobranca registrada */ 
                          vr_vlrjuros:= 0;
                          vr_vlrmulta:= 0;
                          vr_vldescto:= 0;
                          vr_vlabatim:= rw_crapcob.vlabatim;
                          vr_vlfatura:= rw_crapcob.vltitulo;  
                          
                          /* Procedure para verificar vencimento titulo */
                          pc_verifica_vencimento_titulo (pr_dtvencto      => rw_crapcob.dtvencto    --Data Vencimento
                                                        ,pr_crapdat       => pr_crapdat             --Data movimento
                                                        ,pr_critica_data  => vr_flgvenci            --Critica na validacao
                                                        ,pr_cdcritic      => vr_cdcritic            --Codigo da Critica
                                                        ,pr_dscritic      => vr_dscritic);          --Descricao do erro
                          --Se ocorreu erro
                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;
                          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);

                          /* calculo de abatimento deve ser antes da aplicacao de juros e multa */
                          IF nvl(vr_vlabatim,0) > 0 THEN
                            vr_vlfatura := nvl(vr_vlfatura,0) - nvl(vr_vlabatim,0);
                          END IF;
                          
                          /* trata o desconto */
                          /* se concede apos o vencimento */
                          IF rw_crapcob.cdmensag = 2  THEN
                            vr_vldescto:= rw_crapcob.vldescto;
                            vr_vlfatura:= nvl(vr_vlfatura,0) - nvl(vr_vldescto,0);  
                          END IF;
                          
                          /* verifica se o titulo esta vencido */
                          IF vr_flgvenci THEN  
                            /* MULTA PARA ATRASO */
                            IF rw_crapcob.tpdmulta = 1  THEN /* Valor */
                              vr_vlrmulta:= rw_crapcob.vlrmulta;
                              vr_vlfatura:= nvl(vr_vlfatura,0) + nvl(vr_vlrmulta,0);
                            ELSIF rw_crapcob.tpdmulta = 2  THEN /* % de multa do valor  do boleto */
                              vr_vlrmulta:= (nvl(rw_crapcob.vlrmulta,0) * nvl(vr_vlfatura,0)) / 100;
                              vr_vlfatura:= nvl(vr_vlfatura,0) + nvl(vr_vlrmulta,0);
                            END IF;  
                            
                            /* MORA PARA ATRASO */
                            IF rw_crapcob.tpjurmor = 1 THEN /* dias */
                              vr_vlrjuros:= nvl(rw_crapcob.vljurdia,0) * (pr_tab_regimp(vr_index_reg).dtdgerac - rw_crapcob.dtvencto);
                              --Somar Juros na fatura
                              vr_vlfatura:= nvl(vr_vlfatura,0) + nvl(vr_vlrjuros,0);
                            ELSIF rw_crapcob.tpjurmor = 2 THEN /* mes */
                              vr_vlrjuros:= (nvl(rw_crapcob.vltitulo,0) * ((nvl(rw_crapcob.vljurdia,0) / 100) / 30) * 
                                                 (pr_tab_regimp(vr_index_reg).dtdgerac - rw_crapcob.dtvencto));
                              --Somar juros na fatura                   
                              vr_vlfatura:= nvl(vr_vlfatura,0) + nvl(vr_vlrjuros,0);
                            END IF;
                              
                          ELSE
                            /* se concede apos vencto, ja calculou */
                            IF rw_crapcob.cdmensag <> 2  THEN
                              vr_vldescto:= rw_crapcob.vldescto;
                              --Diminuir o desconto da fatura
                              vr_vlfatura:= nvl(vr_vlfatura,0) - nvl(vr_vldescto,0);
                            END IF;           
                          END IF;

                          /* se pagou valor menor do que deveria, joga critica no log */
                          IF apli0001.fn_round(pr_tab_regimp(vr_index_reg).vlrpagto,2) < apli0001.fn_round(vr_vlfatura,2) THEN
                            -- cria os rejeitados
                            pc_cria_rejeitados ( pr_cdcooper => pr_cdcooper
                                                ,pr_cdcritic => 940 
                                                ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                                ,pr_nrdctitg => ' '
                                                ,pr_nrdctabb => pr_tab_regimp(vr_index_reg).nrdctabb
                                                ,pr_dshistor => ' '
                                                ,pr_cdocorre => 0
                                                ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto  -- N¿mero do documento
                                                ,pr_vllanmto => nvl(vr_vllanmto,0)                    -- Valor do lancamento
                                                -- parametros da tab_regimp
                                                ,pr_nmarquiv => pr_tab_regimp(vr_index_reg).nmarquiv
                                                ,pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig
                                                ,pr_codbanco => pr_tab_regimp(vr_index_reg).codbanco
                                                ,pr_cdagenci => pr_tab_regimp(vr_index_reg).cdagenci
                                                ,pr_nrdolote => pr_tab_regimp(vr_index_reg).nrdolote
                                                ,pr_cdpesqbb => pr_tab_regimp(vr_index_reg).cdpesqbb
                                                ,pr_tab_cratrej => pr_tab_cratrej
                                                ,pr_qtregrej    => vr_qtregrej
                                                ,pr_vlregrej    => vr_vlregrej
                                                ,pr_dscritic    => vr_dscritic);
                            -- Tratando a critica
                            IF trim(vr_dscritic) IS NOT NULL THEN
                              -- Padronização de logs - Chamado 743443 - 02/10/2017
                              pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                          pr_dstiplog   => 'E',
                                          pr_dscritic   =>  vr_dscritic,
                                          pr_tpocorrencia => 2);  --Erro Tratado
                            END IF;  
                            -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                            GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);

                          END IF;
                          
                          --Processar liquidacao
                          PAGA0001.pc_processa_liquidacao (pr_idtabcob     => rw_crapcob.rowid                        --Rowid da Cobranca
                                                          ,pr_nrnosnum     => pr_tab_regimp(vr_index_reg).nrnosnum    --Nosso Numero
                                                          ,pr_cdbanpag     => pr_tab_regimp(vr_index_reg).cdbanpag    --Codigo banco pagamento
                                                          ,pr_cdagepag     => pr_tab_regimp(vr_index_reg).cdagepag    --Codigo Agencia pagamento
                                                          ,pr_vltitulo     => pr_tab_regimp(vr_index_reg).vllanmto    --Valor do titulo
                                                          ,pr_vlliquid     => pr_tab_regimp(vr_index_reg).vlliquid    --Valor Liquidacao
                                                          ,pr_vlrpagto     => pr_tab_regimp(vr_index_reg).vlrpagto    --Valor pagamento
                                                          ,pr_vlabatim     => pr_tab_regimp(vr_index_reg).vlabatim    --Valor abatimento
                                                          ,pr_vldescto     => pr_tab_regimp(vr_index_reg).vldescto    --Valor desconto
                                                          ,pr_vlrjuros     => pr_tab_regimp(vr_index_reg).vljurmul    --Valor juros
                                                          ,pr_vloutdeb     => pr_tab_regimp(vr_index_reg).vloutdes    --Valor saida debito
                                                          ,pr_vloutcre     => pr_tab_regimp(vr_index_reg).vloutcre    --Valor saida credito
                                                          ,pr_dtocorre     => pr_tab_regimp(vr_index_reg).dtocorre    --Data Ocorrencia
                                                          ,pr_dtcredit     => pr_tab_regimp(vr_index_reg).dtdcredi    --Data Credito
                                                          ,pr_cdocorre     => pr_tab_regimp(vr_index_reg).cdocorre    --Codigo Ocorrencia
                                                          ,pr_dsmotivo     => pr_tab_regimp(vr_index_reg).dsmotivo    --Descricao Motivo
                                                          ,pr_dtmvtolt     => pr_crapdat.dtmvtolt                     --Data movimento
                                                          ,pr_cdoperad     => pr_cdoperad                             --Codigo Operador
                                                          ,pr_indpagto     => 0                                       --Indicador pagamento /* 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA */
                                                          ,pr_ret_nrremret => vr_nrretcoo                             --Numero remetente
                                                          ,pr_cdcritic     => vr_cdcritic                             --Codigo Critica
                                                          ,pr_dscritic     => vr_dscritic                             --Descricao Critica
                                                          ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada           --Tabela lancamentos consolidada
                                                          ,pr_tab_descontar       => vr_tab_descontar);               --Tabela de titulos
                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;

                          IF pr_nmtelant <> 'COMPEFORA' THEN
                            --Data Credito maior proximo dia util 
                            IF pr_tab_regimp(vr_index_reg).dtdcredi > pr_crapdat.dtmvtopr THEN
                            
                              /* credito liberado pelo BB em atraso */
                              vr_cdcritic:= 939;
                              vr_dsmotivo := gene0001.fn_busca_critica(vr_cdcritic); 
                              PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                                           ,pr_cdoperad => pr_cdoperad        --Operador
                                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
                                                           ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
                                                           ,pr_des_erro => vr_des_erro        --Indicador erro
                                                           ,pr_dscritic => vr_dscritic);      --Descricao erro
                              --Se ocorreu erro
                              IF vr_des_erro = 'NOK' THEN
                                IF trim(vr_dscritic) IS NOT NULL THEN
                                  -- Padronização de logs - Chamado 743443 - 02/10/2017
                                  pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                              pr_dstiplog   => 'E',
                                              pr_dscritic   =>  vr_dscritic,
                                              pr_tpocorrencia => 2);  --Erro Tratado
                                END IF;
                              END IF;
                              --zerar critica
                              vr_cdcritic:= 0;   
                            END IF;
                          END IF;   
                           
                        WHEN 9 THEN         --Baixa
                          
                          /* Gerar registro de Retorno = 09 - Baixa */
                          PAGA0002.pc_proc_baixa( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                 ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                           
                                                 ,pr_cdbanpag => pr_tab_regimp(vr_index_reg).cdbanpag -- Codigo banco cobran¿a
                                                 ,pr_cdagepag => pr_tab_regimp(vr_index_reg).cdagepag -- Codigo Agencia cobranca
                                                 ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data Ocorrencia
                                                 ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                 ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                 ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                 ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador    
                                                 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Tabela lancamentos consolidada
                                                 ,pr_ret_nrremret => vr_nrretcoo                      -- Numero remetente
                                                 ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                 ,pr_dscritic => vr_dscritic);                        -- Descricao critica

                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;
                          
                        -- cdocorre in (12,13,14,19,20)                                        
                        WHEN 9999  THEN
    
                         /* Gerar registro de Retorno = 12, 13, 14, 19, 20 */
                          PAGA0002.pc_proc_conf_instrucao ( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                           ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                               
                                                           ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data de Ocorrencia
                                                           ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                           ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                           ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                           ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador                                                   
                                                           ,pr_ret_nrremret => vr_nrretcoo                      -- Numero Remessa Retorno Cooperado
                                                           ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Temptable dos lanamentos
                                                           ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                           ,pr_dscritic => vr_dscritic);                        -- Descricao critica
                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;
                         
                        WHEN 17 THEN    --Liquidacao Apos Baixa ou Liquidacao Titulo Nao Registrado
                          
                          --Processar Liquidacao apos baixa
                          PAGA0001.pc_proc_liquid_apos_baixa ( pr_idtabcob     => rw_crapcob.rowid                        --Rowid da Cobranca
                                                              ,pr_nrnosnum     => pr_tab_regimp(vr_index_reg).nrnosnum    --Nosso Numero
                                                              ,pr_cdbanpag     => pr_tab_regimp(vr_index_reg).cdbanpag    --Codigo banco pagamento
                                                              ,pr_cdagepag     => pr_tab_regimp(vr_index_reg).cdagepag    --Codigo Agencia pagamento
                                                              ,pr_vltitulo     => pr_tab_regimp(vr_index_reg).vllanmto    --Valor do titulo
                                                              ,pr_vlliquid     => pr_tab_regimp(vr_index_reg).vlliquid    --Valor Liquidacao
                                                              ,pr_vlrpagto     => pr_tab_regimp(vr_index_reg).vlrpagto    --Valor pagamento
                                                              ,pr_vlabatim     => pr_tab_regimp(vr_index_reg).vlabatim    --Valor abatimento
                                                              ,pr_vldescto     => pr_tab_regimp(vr_index_reg).vldescto    --Valor desconto
                                                              ,pr_vlrjuros     => pr_tab_regimp(vr_index_reg).vljurmul    --Valor juros
                                                              ,pr_vloutdeb     => pr_tab_regimp(vr_index_reg).vloutdes    --Valor saida debito
                                                              ,pr_vloutcre     => pr_tab_regimp(vr_index_reg).vloutcre    --Valor saida credito
                                                              ,pr_dtocorre     => pr_tab_regimp(vr_index_reg).dtocorre    --Data Ocorrencia
                                                              ,pr_dtcredit     => pr_tab_regimp(vr_index_reg).dtdcredi    --Data Credito
                                                              ,pr_cdocorre     => pr_tab_regimp(vr_index_reg).cdocorre    --Codigo Ocorrencia
                                                              ,pr_dsmotivo     => pr_tab_regimp(vr_index_reg).dsmotivo    --Descricao Motivo
                                                              ,pr_dtmvtolt     => pr_crapdat.dtmvtolt                     --Data movimento
                                                              ,pr_cdoperad     => pr_cdoperad                             --Codigo Operador
                                                              ,pr_indpagto     => 0                                       --Indicador pagamento /* 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA */
                                                              ,pr_ret_nrremret => vr_nrretcoo                             --Numero remetente
                                                              ,pr_cdcritic     => vr_cdcritic                             --Codigo Critica
                                                              ,pr_dscritic     => vr_dscritic                             --Descricao Critica
                                                              ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada);         --Tabela lancamentos consolidada  

                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;
                      
                          IF pr_nmtelant <> 'COMPEFORA' AND
                             pr_tab_regimp(vr_index_reg).dtdcredi > pr_crapdat.dtmvtopr THEN
                              
                            /* credito liberado pelo BB em atraso */
                            vr_dscritic:= 939;
                            vr_dsmotivo := gene0001.fn_busca_critica(vr_dscritic); 
                            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid    --ROWID da Cobranca
                                                         ,pr_cdoperad => pr_cdoperad         --Operador
                                                         ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data movimento
                                                         ,pr_dsmensag => vr_dsmotivo         --Descricao Mensagem
                                                         ,pr_des_erro => vr_des_erro         --Indicador erro
                                                         ,pr_dscritic => vr_dscritic);       --Descricao erro
                            --Se ocorreu erro
                            IF vr_des_erro = 'NOK' THEN
                              IF trim(vr_dscritic) IS NOT NULL THEN
                                -- Padronização de logs - Chamado 743443 - 02/10/2017
                                pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                            pr_dstiplog   => 'E',
                                            pr_dscritic   =>  vr_dscritic,
                                            pr_tpocorrencia => 2);  --Erro Tratado
                              END IF;
                            END IF;  
                            --Zerar Critica
                            vr_dscritic:= 0; 
                          END IF;
                        
                        WHEN 23 THEN      --Remessa a Cartorio
                          
                          /* Gerar registro de Retorno = 23 - Remessa a cart¿rio */
                          PAGA0002.pc_proc_remessa_cartorio ( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                             ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                               
                                                             ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data de Ocorrencia
                                                             ,pr_vltarifa => pr_tab_regimp(vr_index_reg).vltarifa -- Valor da tarifa
                                                             ,pr_cdhistor => 972                                  -- Codigo do historico
                                                             ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                             ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                             ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                             ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador                                                   
                                                             ,pr_ret_nrremret => vr_nrretcoo                      -- Numero Remessa Retorno Cooperado
                                                             ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Temptable dos lanamentos
                                                             ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                             ,pr_dscritic => vr_dscritic);                        -- Descricao critica  

                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;
                        
                        WHEN 24 THEN    --Retirada de Cartorio e MAnutencao em Carteira
                          
                          /* Gerar registro de Retorno = 24 - Retirada de cart¿rio e manuten¿¿o em carteira */
                          PAGA0002.pc_proc_retirada_cartorio( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                             ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                               
                                                             ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data de Ocorrencia
                                                             ,pr_vltarifa => pr_tab_regimp(vr_index_reg).vltarifa -- Valor da tarifa
                                                             ,pr_cdhistor => 972                                  -- Codigo do historico
                                                             ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                             ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                             ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                             ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador                                                   
                                                             ,pr_ret_nrremret => vr_nrretcoo                      -- Numero Remessa Retorno Cooperado
                                                             ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Temptable dos lanamentos
                                                             ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                             ,pr_dscritic => vr_dscritic);                        -- Descricao da critica

                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;
                      
                        WHEN 25 THEN    --Protestado e Baixado
                          
                          /* Gerar registro de Retorno = 25 - Protestado e Baixado */
                          PAGA0002.pc_proc_protestado ( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                       ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                               
                                                       ,pr_cdbanpag => pr_tab_regimp(vr_index_reg).cdbanpag -- codigo do banco de pagamento
                                                       ,pr_cdagepag => pr_tab_regimp(vr_index_reg).cdagepag -- codigo da agencia de pagamento
                                                       ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data de Ocorrencia
                                                       ,pr_vltarifa => pr_tab_regimp(vr_index_reg).vltarifa -- Valor da tarifa
                                                       ,pr_cdhistor => 972                                  -- Codigo do historico
                                                       ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                       ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                       ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                       ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador                                                   
                                                       ,pr_ret_nrremret => vr_nrretcoo                      -- Numero remetente
                                                       ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Temptable dos lanamentos
                                                       ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                       ,pr_dscritic => vr_dscritic);                        -- Descricao da Critica

                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;
                                                                           
                        WHEN 26 THEN    --Instrucao Rejeitada
                          
                          /* Procedure para gerar motivos de ocorrencia  */
                          PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => rw_crapcob.rowid                      --Rowid da cobranca
                                                           ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre  --Codigo Ocorrencia
                                                           ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo  --Descricao Motivo
                                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt                   --Data Movimentacao
                                                           ,pr_cdoperad => pr_cdoperad                           --Codigo Operador
                                                           ,pr_cdcritic => vr_cdcritic                           --Codigo Critica
                                                           ,pr_dscritic => vr_dscritic);                         --Descricao Critica
                            
                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;

                          -- cria os rejeitados
                          pc_cria_rejeitados ( pr_cdcooper => pr_cdcooper
                                              ,pr_cdcritic => 0 
                                              ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                              ,pr_nrdctitg => ' '
                                              ,pr_nrdctabb => 0
                                              ,pr_dshistor => pr_tab_regimp(vr_index_reg).dsmotivo
                                              ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre
                                              ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto  -- N¿mero do documento
                                              ,pr_vllanmto => nvl(vr_vllanmto,0)                    -- Valor do lancamento
                                              -- parametros da tab_regimp
                                              ,pr_nmarquiv => pr_tab_regimp(vr_index_reg).nmarquiv
                                              ,pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig
                                              ,pr_codbanco => pr_tab_regimp(vr_index_reg).codbanco
                                              ,pr_cdagenci => pr_tab_regimp(vr_index_reg).cdagenci
                                              ,pr_nrdolote => pr_tab_regimp(vr_index_reg).nrdolote
                                              ,pr_cdpesqbb => pr_tab_regimp(vr_index_reg).cdpesqbb
                                              ,pr_tab_cratrej => pr_tab_cratrej
                                              ,pr_qtregrej    => vr_qtregrej
                                              ,pr_vlregrej    => vr_vlregrej
                                              ,pr_dscritic    => vr_dscritic);
                          -- Tratando a critica
                          IF trim(vr_dscritic) IS NOT NULL THEN
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF; 
                          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);

                        WHEN 28 THEN    --Debito de Tarifas/Custas

                          /* Gerar registro de Retorno = 28 - Debito de tarifas/custas */
                          PAGA0002.pc_proc_deb_tarifas_custas ( pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                               ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                               
                                                               ,pr_cdbanpag => pr_tab_regimp(vr_index_reg).cdbanpag -- codigo do banco de pagamento
                                                               ,pr_cdagepag => pr_tab_regimp(vr_index_reg).cdagepag -- codigo da agencia de pagamento
                                                               ,pr_vloutcre => pr_tab_regimp(vr_index_reg).vloutcre -- Valor credito
                                                               ,pr_vloutdeb => pr_tab_regimp(vr_index_reg).vloutdes -- Valor debito
                                                               ,pr_vltarifa => pr_tab_regimp(vr_index_reg).vltarifa -- Valor da tarifa                                       
                                                               ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data de Ocorrencia
                                                               ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                               ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                               ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                               ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador                                                   
                                                               ,pr_ret_nrremret => vr_nrretcoo                      -- Numero Remessa Retorno Cooperado
                                                               ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Temptable dos lanamentos
                                                               ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                               ,pr_dscritic => vr_dscritic);                        -- Descricao da critica

                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;

                        ELSE
                          
                          /* Gerar registro de Retorno = Retorno Qualquer */
                          PAGA0002.pc_proc_retorno_qualquer (pr_cdcooper => pr_cdcooper                          -- Codigo da cooperativa
                                                            ,pr_idtabcob => rw_crapcob.rowid                     -- Rowid da Cobranca                                               
                                                            ,pr_dtocorre => pr_tab_regimp(vr_index_reg).dtocorre -- Data de Ocorrencia
                                                            ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre -- Codigo Ocorrencia
                                                            ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo -- Descricao Motivo
                                                            ,pr_crapdat  => pr_crapdat                           -- Data movimento
                                                            ,pr_cdoperad => pr_cdoperad                          -- Codigo Operador                                                   
                                                            ,pr_ret_nrremret => vr_nrretcoo                      -- Numero remetente
                                                            ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada    -- Temptable dos lanamentos
                                                            ,pr_cdcritic => vr_cdcritic                          -- Codigo da critica
                                                            ,pr_dscritic => vr_dscritic);                        -- Descricao da critica
                          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                            -- Buscar a descricao
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                            -- Padronização de logs - Chamado 743443 - 02/10/2017
                            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                        pr_dstiplog   => 'E',
                                        pr_dscritic   =>  vr_dscritic,
                                        pr_tpocorrencia => 2);  --Erro Tratado
                          END IF;

                      END CASE;      

                      /* Havendo retorno de critica, cria rejeitados */
                      IF nvl(vr_cdcritic,0) > 0 or TRIM(vr_dscritic) IS NOT NULL THEN

                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                        -- Padronização de logs - Chamado 743443 - 02/10/2017
                        pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                    pr_dstiplog   => 'E',
                                    pr_dscritic   =>  pr_tab_regimp(vr_index_reg).nmarquiv ||' --> Ocorr: '
                                                      || pr_tab_regimp(vr_index_reg).cdocorre
                                                      || ' --> '|| vr_dscritic  ||' Conta: '
                                                      ||pr_tab_regimp(vr_index_reg).nrdconta,
                                    pr_tpocorrencia => 2);  --Erro Tratado

                        -- cria os rejeitados
                        pc_cria_rejeitados ( pr_cdcooper => pr_cdcooper
                                            ,pr_cdcritic => vr_cdcritic 
                                            ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                            ,pr_nrdctitg => ' '
                                            ,pr_nrdctabb => 0
                                            ,pr_dshistor => pr_tab_regimp(vr_index_reg).dsmotivo
                                            ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre
                                            ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto  
                                            ,pr_vllanmto => nvl(vr_vllanmto,0)
                                            -- parametros da tab_regimp
                                            ,pr_nmarquiv => pr_tab_regimp(vr_index_reg).nmarquiv
                                            ,pr_nrseqdig => pr_tab_regimp(vr_index_reg).nrseqdig
                                            ,pr_codbanco => pr_tab_regimp(vr_index_reg).codbanco
                                            ,pr_cdagenci => pr_tab_regimp(vr_index_reg).cdagenci
                                            ,pr_nrdolote => pr_tab_regimp(vr_index_reg).nrdolote
                                            ,pr_cdpesqbb => pr_tab_regimp(vr_index_reg).cdpesqbb
                                            ,pr_tab_cratrej => pr_tab_cratrej
                                            ,pr_qtregrej    => vr_qtregrej
                                            ,pr_vlregrej    => vr_vlregrej
                                            ,pr_dscritic    => vr_dscritic);
                        -- Tratando a critica
                        IF trim(vr_dscritic) IS NOT NULL THEN
                          -- Padronização de logs - Chamado 743443 - 02/10/2017
                          pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                      pr_dstiplog   => 'E',
                                      pr_dscritic   =>  vr_dscritic,
                                      pr_tpocorrencia => 2);  --Erro Tratado
                        END IF; 
                        -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);
                        
                        -- Proximo registro
                        RAISE vr_exc_prox_det;
                      END IF;                    

                      --Data Movimento
                      IF pr_nmtelant <> 'COMPEFORA' THEN
                        IF pr_tab_regimp(vr_index_reg).cdocorre <> 6 THEN
                          vr_dtmovnto:= pr_tab_regimp(vr_index_reg).dtocorre;
                        ELSE
                          vr_dtmovnto:= pr_tab_regimp(vr_index_reg).dtdcredi;
                        END IF;    
                      ELSE
                        vr_dtmovnto:= pr_crapdat.dtmvtolt;
                      END IF;  
                        
                      --Gravar retorno
                      PAGA0001.pc_grava_retorno (pr_cdcooper => pr_cdcooper                            --Codigo Cooperativa
                                                ,pr_nrcnvcob => pr_tab_regimp(vr_index_reg).nrcnvcob   --Numero Convenio Cobranca
                                                ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta   --Numero da Conta
                                                ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto   --Numero documento
                                                ,pr_nrnosnum => pr_tab_regimp(vr_index_reg).nrnosnum   --Nosso Numero
                                                ,pr_cdocorre => pr_tab_regimp(vr_index_reg).cdocorre   --Codigo Ocorrencia
                                                ,pr_dsmotivo => pr_tab_regimp(vr_index_reg).dsmotivo   --Descricao Motivo
                                                ,pr_nrremret => rw_crapcre.nrremret                    --Numero remessa retorno
                                                ,pr_nrseqreg => pr_tab_regimp(vr_index_reg).nrseqdig   --Sequencial do registro
                                                ,pr_cdbcorec => pr_tab_regimp(vr_index_reg).cdbanpag   --Codigo banco recebedor
                                                ,pr_cdagerec => pr_tab_regimp(vr_index_reg).cdagepag   --Codigo Agencia recebedora
                                                ,pr_cdbcocor => pr_tab_regimp(vr_index_reg).cdbancor   --Codigo Banco
                                                ,pr_nrretcoo => vr_nrretcoo                            --Numero retorno cooperativa
                                                ,pr_dtcredit => pr_tab_regimp(vr_index_reg).dtdcredi   --Data Credito
                                                ,pr_flcredit => TRUE
                                                ,pr_vlabatim => pr_tab_regimp(vr_index_reg).vlabatim   --Valor abatimentos
                                                ,pr_vldescto => pr_tab_regimp(vr_index_reg).vldescto   --Valor descontos
                                                ,pr_vljurmul => pr_tab_regimp(vr_index_reg).vljurmul   --Valor Juros
                                                ,pr_vloutcre => pr_tab_regimp(vr_index_reg).vloutcre   --Valor saida credito
                                                ,pr_vloutdes => pr_tab_regimp(vr_index_reg).vloutdes   --Valor saida debito
                                                ,pr_vlrliqui => pr_tab_regimp(vr_index_reg).vlliquid   --Valor liquidacao
                                                ,pr_vlrpagto => pr_tab_regimp(vr_index_reg).vlrpagto   --Valor Pagamento
                                                ,pr_vltarifa => pr_tab_regimp(vr_index_reg).vltarifa   --Valor tarifa
                                                ,pr_vltitulo => pr_tab_regimp(vr_index_reg).vllanmto   --Valor titulo
                                                ,pr_cdoperad => pr_cdoperad                            --Codigo operador
                                                ,pr_dtmvtolt => vr_dtmovnto                            --Data Movimento
                                                ,pr_dtocorre => pr_crapdat.dtmvtolt                    --Data Ocorrencia
                                                ,pr_cdcritic => vr_cdcritic                            --Codigo erro
                                                ,pr_dscritic => vr_dscritic);                          --Descricao erro
                      --Se Ocorreu erro
                      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                        -- Buscar a descricao
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                        -- Padronização de logs - Chamado 743443 - 02/10/2017
                        pc_gera_log(pr_cdcooper   => pr_cdcooper,
                                    pr_dstiplog   => 'E',
                                    pr_dscritic   =>  vr_dscritic,
                                    pr_tpocorrencia => 2);  --Erro Tratado
                      END IF;
                    END IF; -- Fim  NOT vr_flagtco OR tt-regimp.dsorgarq = "MIGRACAO" 

                    --Se for migracao              
                    IF NOT vr_flagtco OR pr_tab_regimp(vr_index_reg).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                      -- Limpar tem-table de reg para o relatorio
                      vr_tab_regimp_rel.delete;
                      -- atribuir registro atual
                      vr_tab_regimp_rel(vr_index_reg):= pr_tab_regimp(vr_index_reg);

                         
                      --Buscar novamente a crapcob pois algumas informacoes da cobranca foram alteradas
                      --dentro das procedures acima
                      open cr_crapcob_rowid (pr_rowid => rw_crapcob.rowid);
                      fetch cr_crapcob_rowid into rw_crapcob;
                      close cr_crapcob_rowid;
                      
                      /* Armazena dados para o relatorio crrl594 */
                      pc_cria_relatorio_594 ( pr_cdcooper   => pr_cdcooper          -- Codigo da cooperativa
                                             ,pr_cdbandoc   => rw_crapcob.cdbandoc  -- Codigo do banco
                                             ,pr_nrdconta   => rw_crapcob.nrdconta  -- Numero da conta do associado
                                             ,pr_nrcnvcob   => rw_crapcob.nrcnvcob  -- Numero do convenio de cobranca
                                             ,pr_nrdocmto   => rw_crapcob.nrdocmto  -- Numero do documento
                                             ,pr_nrdctabb   => rw_crapcob.nrdctabb  -- Numero da conta bas
                                             ,pr_cdbanpag   => rw_crapcob.cdbanpag  -- Codigo Banco Pagamento
                                             ,pr_cdagepag   => rw_crapcob.cdagepag  -- Codigo Agencia Pagamento
                                             ,pr_tab_regimp => vr_tab_regimp_rel    -- Tabela dos registros procesados (boletos)
                                             ,pr_qtregrec   => vr_qtregrec          -- Quantidade Registros Recebidos
                                             ,pr_vlregrec   => vr_vlregrec          -- Valor Registros Recebidos
                                             ,pr_qtregicd   => vr_qtregicd          -- Quantidade Registros Integrados Desconto
                                             ,pr_vlregicd   => vr_vlregicd          -- Valor Registros Integrados Desconto                                   
                                             ,pr_cdcritic   => vr_cdcritic          -- Codigo da critica
                                             ,pr_dscritic   => vr_dscritic );       -- Descricao da critica
                      --Se ocorreu erro
                      IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
                        --Levantar Excecao
                        RAISE vr_exc_erro;
                      END IF;  
                      -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                      GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_efetiva_atualiz_compensacao', pr_action => NULL);

                    END IF;
                    
                    /* se for ocorrencia de entrada confirmada 
                       de um boleto de protesto, deve verificar 
                       se o boleto original 85 j¿ foi liquidado.
                       Tratamento incluido somente apos a grava-retorno pois
                       a rotina inst-sustar-baixar precisa das informa¿¿es 
                       geradas por ela (crapret). Odirlei(AMcom) */
                    IF pr_tab_regimp(vr_index_reg).cdocorre = 2 AND
                       pr_tab_regimp(vr_index_reg).dsorgarq = 'PROTESTO' AND
                       pr_tab_regimp(vr_index_reg).codbanco = 001  THEN
                       
                      /* Buscar informacoes do bolteto de cobranca de protesto */ 
                      OPEN cr_crapcob_2( pr_cdcooper => pr_cdcooper
                                        ,pr_nrcnvcob => pr_tab_regimp(vr_index_reg).nrcnvcob
                                        ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta
                                        ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto
                                        ,pr_cdbandoc => pr_tab_regimp(vr_index_reg).codbanco
                                        ,pr_nrdctabb => pr_tab_regimp(vr_index_reg).nrdctabb);
                      FETCH cr_crapcob_2 INTO rw_crapcob;
                      vr_crapcob:= cr_crapcob_2%FOUND;
                      CLOSE cr_crapcob_2;
                      
                      --Se Encontrou
                      IF vr_crapcob THEN 
                        /* Verificar se bolteto de cobranca original 
                           ja esta baixado ou pago */
                        OPEN cr_crapcob_85 ( pr_cdcooper => gene0002.fn_busca_entrada(1,rw_crapcob.cdtitprt,';') 
                                            ,pr_nrcnvcob => gene0002.fn_busca_entrada(3,rw_crapcob.cdtitprt,';') 
                                            ,pr_nrdconta => gene0002.fn_busca_entrada(2,rw_crapcob.cdtitprt,';') 
                                            ,pr_nrdocmto => gene0002.fn_busca_entrada(4,rw_crapcob.cdtitprt,';')
                                            ,pr_cdbandoc => 85
                                            ,pr_incobran => 5);
                        FETCH cr_crapcob_85 INTO rw_crapcob_85;
                        vr_crapcob:= cr_crapcob_85%FOUND;
                        CLOSE cr_crapcob_85;
                                      
                        /* Verificar se no intervalo de tempo em que foi enviado o
                           boleto, o sistema recebeu a liquida¿¿o do boleto 085 */
                        IF vr_crapcob THEN      
                          /* Sustar a baixa */
                          COBR0007.pc_inst_sustar_baixar (pr_cdcooper => pr_tab_regimp(vr_index_reg).cdcooper    --Codigo Cooperativa
                                                         ,pr_nrdconta => pr_tab_regimp(vr_index_reg).nrdconta    --Numero da Conta
                                                         ,pr_nrcnvcob => pr_tab_regimp(vr_index_reg).nrcnvcob    --Numero Convenio
                                                         ,pr_nrdocmto => pr_tab_regimp(vr_index_reg).nrdocmto    --Numero Documento
                                                         ,pr_dtmvtolt => rw_crapdat.dtmvtopr    --Data pagamento
                                                         ,pr_cdoperad => 1                      --Operador
                                                         ,pr_nrremass => 0                      --Numero Remessa
                                                         ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                                         ,pr_cdcritic => vr_cdcritic2
                                                         ,pr_dscritic => vr_dscritic2);

                          --Se ocorreu erro
                          IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
                              NULL;
                          END IF;
                        END IF;
                      END IF;
                    END IF;
                  EXCEPTION
                    WHEN vr_exc_prox_det THEN
                      --Vai para Proximo Registro Detalhe logo abaixo
                      NULL;
                  END;     
                END IF; --Mesmo Arquivo
                
                --Proximo Registro Detalhe
                vr_index_reg:= pr_tab_regimp.NEXT(vr_index_reg);                                            
              END LOOP; --Fim loop registros   
              
              --Montar a data
              IF pr_nmtelant <> 'COMPEFORA' THEN
                vr_dtauxcmp:= rw_crapdat.dtmvtopr;
              ELSE 
                vr_dtauxcmp:= rw_crapdat.dtmvtolt; 
              END IF;

              /** Realiza os Lancamentos na conta do cooperado */
              PAGA0001.pc_realiza_lancto_cooperado ( pr_cdcooper => pr_cdcooper                                 --Codigo Cooperativa
                                                    ,pr_dtmvtolt => vr_dtauxcmp                                 --Data Movimento
                                                    ,pr_cdagenci => pr_tab_cratarq(vr_index_cratarq).cdagenci   --Codigo Agencia
                                                    ,pr_cdbccxlt => pr_tab_cratarq(vr_index_cratarq).cdbccxlt   --Codigo banco caixa
                                                    ,pr_nrdolote => pr_tab_cratarq(vr_index_cratarq).nrdolote   --Numero do Lote
                                                    ,pr_cdpesqbb => vr_cdpesqbb                                 --Codigo Pesquisa
                                                    ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada           --Tabela lancamentos consolidada
                                                    ,pr_cdcritic => vr_cdcritic                                 --Codigo erro
                                                    ,pr_dscritic => vr_dscritic);                               --Descricao Critica
              --Se ocorreu erro
              IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- Buscar a descricao
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic,vr_dscritic);
                -- Padronização de logs - Chamado 743443 - 02/10/2017
                pc_gera_log(pr_cdcooper   => pr_cdcooper,
                            pr_dstiplog   => 'E',
                            pr_dscritic   =>  vr_dscritic,
                            pr_tpocorrencia => 2);  --Erro Tratado
              END IF;
                  
              /* realiza liquidacao dos titulos descontados (se houver) */
              --Montar indice para acesso a tabela descontar
              vr_index_desc:= vr_tab_descontar.FIRST;
              WHILE vr_index_desc IS NOT NULL LOOP

                --Adicionar na tabela de titulo os descontados
                vr_index_titulo:= lpad(vr_tab_descontar(vr_index_desc).nrdconta,10,'0')||lpad(vr_tab_titulos.count+1,10,'0');
                vr_tab_titulos(vr_index_titulo):= vr_tab_descontar(vr_index_desc);

                --Se for ultimo registro da conta
                IF vr_index_desc = vr_tab_descontar.LAST OR
                  (vr_tab_descontar(vr_index_desc).nrdconta <> vr_tab_descontar(vr_tab_descontar.NEXT(vr_index_desc)).nrdconta) THEN
                  --Limpar tabela erro
                  vr_tab_erro2.DELETE;
                  --Verificar nome da tela
                  IF pr_nmtelant <> 'COMPEFORA' THEN
                    vr_dtmvtaux:= rw_crapdat.dtmvtopr;
                  ELSE
                    vr_dtmvtaux:= rw_crapdat.dtmvtolt;
                  END IF;

                  --Efetuar a baixa do titulo
                  DSCT0001.pc_efetua_baixa_titulo (pr_cdcooper    => pr_cdcooper         --Codigo Cooperativa
                                                  ,pr_cdagenci    => 0                   --Codigo Agencia
                                                  ,pr_nrdcaixa    => 0                   --Numero Caixa
                                                  ,pr_cdoperad    => 0                   --Codigo operador
                                                  ,pr_dtmvtolt    => vr_dtmvtaux         --Data Movimento
                                                  ,pr_idorigem    => 1  /*AYLLOS*/       --Identificador Origem pagamento
                                                  ,pr_nrdconta    => vr_tab_descontar(vr_index_desc).nrdconta         --Numero da conta
                                                  ,pr_indbaixa    => 1                   --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                                  ,pr_dtintegr    => vr_dtmvtaux         -- Data de integração do pagamento
                                                  ,pr_tab_titulos => vr_tab_titulos      --Titulos a serem baixados
                                                  ,pr_cdcritic    => vr_cdcritic         --Codigo Critica
                                                  ,pr_dscritic    => vr_dscritic         --Descricao Critica
                                                  ,pr_tab_erro    => vr_tab_erro2);      --Tabela erros
                  --Se ocorreu erro
                  IF vr_tab_erro2.Count > 0 THEN
                    FOR idx IN vr_tab_erro2.FIRST..vr_tab_erro2.LAST LOOP
                      --Buscar proxima sequencia de erro
                      vr_index_erro:= vr_tab_erro.COUNT+1;
                      vr_tab_erro(vr_index_erro):= vr_tab_erro2(idx);
                    END LOOP;
                  END IF;

                  --Limpar tabela titulos
                  vr_tab_titulos.DELETE;
                END IF;
                --Proximo registro da tabela descontados
                vr_index_desc:= vr_tab_descontar.NEXT(vr_index_desc);
              END LOOP; --vr_tab_descontar
              
              /* Atualiza CRAPCRE com infos do Trailer */
              vr_indregtrl:= lpad(pr_cdcooper,5,'0')||pr_tab_cratarq(vr_index_cratarq).nmarquiv;
              
              IF vr_tab_trailer.exists(vr_indregtrl) THEN
                BEGIN
                  UPDATE crapcre 
                     SET crapcre.qtreglot = vr_tab_trailer(vr_indregtrl).qtreglot,
                         crapcre.qttitcsi = vr_tab_trailer(vr_indregtrl).qttitcsi,
                         crapcre.vltitcsi = vr_tab_trailer(vr_indregtrl).vltitcsi,
                         crapcre.qttitcvi = vr_tab_trailer(vr_indregtrl).qttitcvi,
                         crapcre.vltitcvi = vr_tab_trailer(vr_indregtrl).vltitcvi,
                         crapcre.qttitcca = vr_tab_trailer(vr_indregtrl).qttitcca,
                         crapcre.vltitcca = vr_tab_trailer(vr_indregtrl).vltitcca,
                         crapcre.qttitcde = vr_tab_trailer(vr_indregtrl).qttitcde,
                         crapcre.vltitcde = vr_tab_trailer(vr_indregtrl).vltitcde,
                         crapcre.flgproce = 1, --TRUE
                         crapcre.hrtranfi = GENE0002.fn_busca_time
                   WHERE crapcre.rowid  = rw_crapcre.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar crapcre: qtreglot:'||vr_tab_trailer(vr_indregtrl).qtreglot
                                   ||', qttitcsi:'||vr_tab_trailer(vr_indregtrl).qttitcsi
                                   ||', vltitcsi:'||vr_tab_trailer(vr_indregtrl).vltitcsi
                                   ||', qttitcvi:'||vr_tab_trailer(vr_indregtrl).qttitcvi
                                   ||', vltitcvi:'||vr_tab_trailer(vr_indregtrl).vltitcvi
                                   ||', qttitcca:'||vr_tab_trailer(vr_indregtrl).qttitcca
                                   ||', vltitcca:'||vr_tab_trailer(vr_indregtrl).vltitcca
                                   ||', qttitcde:'||vr_tab_trailer(vr_indregtrl).qttitcde
                                   ||', vltitcde:'||vr_tab_trailer(vr_indregtrl).vltitcde||', flgproce:1'
                                   ||', hrtranfi:'||GENE0002.fn_busca_time
                                   ||', com rowid:'||rw_crapcre.rowid||'. '||SQLErrm;
                    RAISE vr_exc_erro;
                END;  
              END IF;  
              
              --Verificar se Existe tabela Migracao
              vr_index_migracao:= vr_tab_migracao.FIRST;

              -- Varrer contas migradas
              WHILE vr_index_migracao IS NOT NULL LOOP
                --Verificar se ¿ o mesmo arquivo 
                IF vr_tab_migracao(vr_index_migracao).nmarquiv = pr_tab_cratarq(vr_index_cratarq).nmarquiv THEN
                  -- Se valor de lancamento for maior que zero
                  IF nvl(vr_tab_migracao(vr_index_migracao).vllanmto,0) > 0 THEN

                    -- Buscar Acerto Financeiro BB entre cooperativas.  
                    OPEN cr_crapafi (pr_cdcooper => pr_cdcooper,
                                     pr_nrdctabb => vr_tab_migracao(vr_index_migracao).nrdctabb,
                                     pr_dtmvtolt => pr_crapdat.dtmvtolt,
                                     pr_cdcopdst => vr_tab_migracao(vr_index_migracao).cdcopdst,
                                     pr_nrctadst => vr_tab_migracao(vr_index_migracao).nrctadst,
                                     pr_cdhistor => (CASE 
                                                       WHEN NOT vr_tab_migracao(vr_index_migracao).dsorgarq IN ('MIGRACAO') THEN
                                                         971
                                                       ELSE
                                                         1133
                                                     END));
                    FETCH cr_crapafi INTO rw_crapafi;
                    IF cr_crapafi%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_crapafi;
                    
                      -- Se n¿o encontrou, deve inserir o acerto financeiro
                      BEGIN
                        CASE vr_tab_migracao(vr_index_migracao).dsorgarq
                          WHEN 'MIGRACAO' THEN 
                            vr_cdhisafi := 1124; /* Cred Cobr. Migracao */
                          ELSE 
                            vr_cdhisafi := 1123; /*Debito Cobranca Origem */
                        END CASE;
                     
                        INSERT INTO crapafi
                          ( crapafi.cdcooper
                           ,crapafi.nrdctabb 
                           ,crapafi.dtmvtolt 
                           ,crapafi.dtlanmto 
                           ,crapafi.cdcopdst 
                           ,crapafi.cdagedst 
                           ,crapafi.nrctadst 
                           ,crapafi.cdhistor
                           ,crapafi.cdhisafi 
                           ,crapafi.vllanmto 
                           ,crapafi.flprcctl )
                        VALUES ( pr_cdcooper                            -- crapafi.cdcooper
                           ,vr_tab_migracao(vr_index_migracao).nrdctabb -- crapafi.nrdctabb 
                           ,pr_crapdat.dtmvtolt                         -- crapafi.dtmvtolt 
                           ,pr_crapdat.dtmvtopr                         -- crapafi.dtlanmto 
                           ,vr_tab_migracao(vr_index_migracao).cdcopdst -- crapafi.cdcopdst 
                           ,vr_tab_migracao(vr_index_migracao).cdagedst -- crapafi.cdagedst 
                           ,vr_tab_migracao(vr_index_migracao).nrctadst -- crapafi.nrctadst 
                           ,(CASE 
                               WHEN NOT vr_tab_migracao(vr_index_migracao).dsorgarq IN ('MIGRACAO') THEN
                                  971
                               ELSE
                                  1133
                               END) -- crapafi.cdhistor
                           ,vr_cdhisafi
                           ,vr_tab_migracao(vr_index_migracao).vllanmto -- crapafi.vllanmto 
                           ,0 /*FALSE */);                              -- crapafi.flprcctl 
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapafi: cdcooper:'||pr_cdcooper
                                         ||', nrdctabb:'||vr_tab_migracao(vr_index_migracao).nrdctabb
                                         ||', dtmvtolt:'||pr_crapdat.dtmvtolt
                                         ||', dtlanmto:'||pr_crapdat.dtmvtopr
                                         ||', cdcopdst:'||vr_tab_migracao(vr_index_migracao).cdcopdst
                                         ||', cdagedst:'||vr_tab_migracao(vr_index_migracao).cdagedst
                                         ||', nrctadst:'||vr_tab_migracao(vr_index_migracao).nrctadst
                                         ||', dsorgarq:'||vr_tab_migracao(vr_index_migracao).dsorgarq
                                         ||', cdhistor:971 ou 1133'
                                         ||', cdhisafi:'||vr_cdhisafi
                                         ||', vllanmto:'||vr_tab_migracao(vr_index_migracao).vllanmto
                                         ||', flprcctl:0'||'. '||SQLErrm;
                          RAISE vr_exc_erro;
                      END;
                    ELSE  
                      --Fechar Cursor
                      CLOSE cr_crapafi;
                      -- Se encontrou, deve apenas adicionar valor do lancamento
                      BEGIN
                        UPDATE crapafi
                           SET crapafi.vllanmto = nvl(crapafi.vllanmto,0) + nvl(vr_tab_migracao(vr_index_migracao).vllanmto,0)
                         WHERE crapafi.rowid = rw_crapafi.rowid;                          
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao atualizar crapafi: vllanmto:'||nvl(vr_tab_migracao(vr_index_migracao).vllanmto,0)
                                         ||', com rowid:'||rw_crapafi.rowid||'. '||SQLErrm;
                          RAISE vr_exc_erro;
                      END;
                    END IF;                      
                  
                  END IF; -- Fim vllanmto > 0
                
                  -- Se valor de lancamento for maior que zero
                  IF nvl(vr_tab_migracao(vr_index_migracao).vlrtarif,0) > 0 THEN
                    
                    CASE vr_tab_migracao(vr_index_migracao).dsorgarq 
                       WHEN 'MIGRACAO' THEN 
                         vr_cdhisafi := 1125; /* Deb. Tar. Migracao */
                       ELSE
                         vr_cdhisafi := 1126; /*Debito Tarifa Migrado */    
                    END CASE;
                       
                    -- Buscar Acerto Financeiro BB entre cooperativas.  
                    OPEN cr_crapafi (pr_cdcooper => pr_cdcooper,
                                     pr_nrdctabb => vr_tab_migracao(vr_index_migracao).nrdctabb,
                                     pr_dtmvtolt => pr_crapdat.dtmvtolt,
                                     pr_cdcopdst => vr_tab_migracao(vr_index_migracao).cdcopdst,
                                     pr_nrctadst => vr_tab_migracao(vr_index_migracao).nrctadst,
                                     pr_cdhistor => vr_tab_migracao(vr_index_migracao).cdhistor);
                    FETCH cr_crapafi INTO rw_crapafi;
                    IF cr_crapafi%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_crapafi;
                      -- Se n¿o encontrou, deve inserir o acerto financeiro
                      BEGIN
                        INSERT INTO crapafi
                           ( crapafi.cdcooper
                            ,crapafi.nrdctabb 
                            ,crapafi.dtmvtolt 
                            ,crapafi.dtlanmto 
                            ,crapafi.cdcopdst 
                            ,crapafi.cdagedst 
                            ,crapafi.nrctadst 
                            ,crapafi.cdhistor
                            ,crapafi.cdhisafi 
                            ,crapafi.vllanmto 
                            ,crapafi.flprcctl )
                         VALUES 
                           ( pr_cdcooper                                 -- crapafi.cdcooper
                            ,vr_tab_migracao(vr_index_migracao).nrdctabb -- crapafi.nrdctabb 
                            ,pr_crapdat.dtmvtolt                         -- crapafi.dtmvtolt 
                            ,pr_crapdat.dtmvtopr                         -- crapafi.dtlanmto 
                            ,vr_tab_migracao(vr_index_migracao).cdcopdst -- crapafi.cdcopdst 
                            ,vr_tab_migracao(vr_index_migracao).cdagedst -- crapafi.cdagedst 
                            ,vr_tab_migracao(vr_index_migracao).nrctadst -- crapafi.nrctadst 
                            ,vr_tab_migracao(vr_index_migracao).cdhistor -- crapafi.cdhistor
                            ,vr_cdhisafi
                            ,vr_tab_migracao(vr_index_migracao).vlrtarif -- crapafi.vllanmto 
                            ,0 /*FALSE */);                              --crapafi.flprcctl 
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapafi: cdcooper:'||pr_cdcooper
                                         ||', nrdctabb:'||vr_tab_migracao(vr_index_migracao).nrdctabb
                                         ||', dtmvtolt:'||pr_crapdat.dtmvtolt
                                         ||', dtlanmto:'||pr_crapdat.dtmvtopr
                                         ||', cdcopdst:'||vr_tab_migracao(vr_index_migracao).cdcopdst
                                         ||', cdagedst:'||vr_tab_migracao(vr_index_migracao).cdagedst
                                         ||', nrctadst:'||vr_tab_migracao(vr_index_migracao).nrctadst
                                         ||', cdhistor:'||vr_tab_migracao(vr_index_migracao).cdhistor
                                         ||', cdhisafi:'||vr_cdhisafi
                                         ||', vlrtarif:'||vr_tab_migracao(vr_index_migracao).vlrtarif
                                         ||', flprcctl:0'||'. '||SQLErrm;
                          RAISE vr_exc_erro;
                      END;
                    ELSE  
                      --Fechar Cursor
                      CLOSE cr_crapafi;
                      -- Se encontrou, deve apenas adicionar valor do lancamento
                      BEGIN
                        UPDATE crapafi
                           SET crapafi.vllanmto = nvl(crapafi.vllanmto,0) + nvl(vr_tab_migracao(vr_index_migracao).vlrtarif,0)
                         WHERE crapafi.rowid = rw_crapafi.rowid;                          
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao atualizar crapafi: vlrtarif:'||nvl(vr_tab_migracao(vr_index_migracao).vlrtarif,0)
                                         ||', com rowid:'||rw_crapafi.rowid||'. '||SQLErrm;
                          RAISE vr_exc_erro;
                      END;
                    END IF;  
                              
                  END IF; -- Fim vlrtarif > 0 
                
                  IF nvl(vr_tab_migracao(vr_index_migracao).vllanmto,0) > 0 OR 
                     nvl(vr_tab_migracao(vr_index_migracao).vlrtarif,0) > 0 THEN
                    vr_qtdmigra := nvl(vr_qtdmigra,0) + 1;
                    vr_vlrmigra := nvl(vr_vlrmigra,0) + nvl(vr_tab_migracao(vr_index_migracao).vllanmto,0);
                  END IF;
                END IF;  --Mesmo Arquivo
                --Proximo Registro
                vr_index_migracao:= vr_tab_migracao.NEXT(vr_index_migracao);    
              END LOOP;  

              /* Totais do Arquivo */
              BEGIN
                INSERT INTO craprej
                   (craprej.dtrefere,
                    craprej.nrdconta, 
                    craprej.nrseqdig,
                    craprej.vllanmto,
                    craprej.cdcooper,
                    craprej.dtmvtolt )
                VALUES
                   (SUBSTR(pr_tab_cratarq(vr_index_cratarq).nmarquiv,15,06) -- craprej.dtrefere  
                   ,999999999                                               -- craprej.nrdconta  
                   ,pr_tab_cratarq(vr_index_cratarq).nrseqdig               -- craprej.nrseqdig  
                   ,pr_tab_cratarq(vr_index_cratarq).vllanmto               -- craprej.vllanmto  
                   ,pr_cdcooper                                             -- craprej.cdcooper    
                   ,rw_crapdat.dtmvtolt);                                   -- craprej.dtmvtolt            
              EXCEPTION
                WHEN others THEN
                  vr_dscritic := 'Erro ao inserir craprej: dtrefere:'||SUBSTR(pr_tab_cratarq(vr_index_cratarq).nmarquiv,15,06)
                                 ||', nrdconta:999999999'
                                 ||', nrseqdig:'||pr_tab_cratarq(vr_index_cratarq).nrseqdig
                                 ||', vllanmto:'||pr_tab_cratarq(vr_index_cratarq).vllanmto
                                 ||', cdcooper:'||pr_cdcooper
                                 ||', dtmvtolt:'||rw_crapdat.dtmvtolt||'. '||SQLErrm;
                  RAISE vr_exc_erro;
              END; 
              
              --Quantidade e Valor sem desconto (recebido menos com desconto)
              vr_qtregisd := nvl(vr_qtregrec,0) - nvl(vr_qtregicd,0);
              vr_vlregisd := nvl(vr_vlregrec,0) - nvl(vr_vlregicd,0);
              
              pr_tab_cratarq(vr_index_cratarq).qtregicd := nvl(vr_qtregicd,0);  /* OK */
              pr_tab_cratarq(vr_index_cratarq).vlregicd := nvl(vr_vlregicd,0);  /* OK */
              pr_tab_cratarq(vr_index_cratarq).qtregrec := nvl(vr_qtregrec,0);  /* OK */
              pr_tab_cratarq(vr_index_cratarq).vlregrec := nvl(vr_vlregrec,0);  /* OK */
              pr_tab_cratarq(vr_index_cratarq).qtregrej := nvl(vr_qtregrej,0);  /* OK */
              pr_tab_cratarq(vr_index_cratarq).vlregrej := nvl(vr_vlregrej,0);  /* OK */
              pr_tab_cratarq(vr_index_cratarq).qtregisd := nvl(vr_qtregisd,0);
              pr_tab_cratarq(vr_index_cratarq).vlregisd := nvl(vr_vlregisd,0);
              pr_tab_cratarq(vr_index_cratarq).vltarifa := 0; -- vr_vlcompdb /*no progress variavel ¿ apenas criada*/
              pr_tab_cratarq(vr_index_cratarq).qtdmigra := nvl(vr_qtdmigra,0);
              pr_tab_cratarq(vr_index_cratarq).vlrmigra := nvl(vr_vlrmigra,0);
               
              --Proximo Registro
              vr_index_cratarq:= pr_tab_cratarq.NEXT(vr_index_cratarq);       
            EXCEPTION
              WHEN vr_exc_prox_arq THEN
                --Buscar Proximo arquivo
                vr_index_cratarq:= pr_tab_cratarq.NEXT(vr_index_cratarq);
            END;      
          END LOOP; -- Fim Loop pr_tab_cratarq
          
          -- Se ja existem erros, retornar ao programa chamador
          IF pr_tab_erro.count > 0 THEN
            pr_des_erro:= 'NOK'; 
            RETURN;
          END IF;
          
          -- posicionando no primeiro registro da temp-table
          vr_index_cratarq := pr_tab_cratarq.first;
          -- Iniciando o loop e processamento do arquivo
          WHILE vr_index_cratarq IS NOT NULL LOOP
            
            --Verificar se o arquivo existe
            IF GENE0001.fn_exis_arquivo(pr_caminho => vr_dir_compbb||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv) THEN
              -- Comando para mover o arquivo
              vr_comando:= 'mv '||vr_dir_compbb||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' '||
                                  vr_dir_salvar||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                   ,pr_des_comando => vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                -- gera excecao e sai da execucao
                vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
                -- retornando ao programa chamador
                RAISE vr_exc_erro;
              END IF;  
            END IF; 
            --Encontrar proximo registro
            vr_index_cratarq := pr_tab_cratarq.NEXT(vr_index_cratarq);             
          END LOOP;                 
        END;  
        --Final com Sucesso
        pr_des_erro := 'OK';        
      EXCEPTION  
        WHEN vr_exc_erro then
          pr_des_erro := 'NOK';
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_des_erro := 'NOK';
          pr_dscritic := 'Erro na rotina pc_efetiva_atualiz_compensacao: '||SQLErrm;

          --Inclusão na tabela de erros Oracle - Chamado 743443
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          
      END pc_efetiva_atualiz_compensacao;  
      
      
      /*Buscar Lista de Motivos*/
      FUNCTION fn_busca_lista_motivo (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                     ,pr_cddbanco IN crapmot.cddbanco%TYPE --Codigo Banco
                                     ,pr_cdocorre IN crapmot.cdocorre%TYPE --Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2) RETURN VARCHAR2 IS --Descricao dos motivos
      BEGIN
        DECLARE
          --Selecionar os motivos da ocorrencia
          CURSOR cr_crapmot (pr_cdcooper IN crapmot.cdcooper%type
                            ,pr_cddbanco IN crapmot.cddbanco%type
                            ,pr_cdocorre IN crapmot.cdocorre%type
                            ,pr_tpocorre IN crapmot.tpocorre%type /* Mot. do retorno */
                            ,pr_cdmotivo IN crapmot.cdmotivo%type) IS
            SELECT crapmot.dsmotivo
            FROM crapmot
            WHERE crapmot.cdcooper = pr_cdcooper
            AND   crapmot.cddbanco = pr_cddbanco
            AND   crapmot.cdocorre = pr_cdocorre
            AND   crapmot.tpocorre = pr_tpocorre /* Mot. do retorno */
            AND   crapmot.cdmotivo = pr_cdmotivo
            ORDER BY crapmot.progress_recid ASC;
      rw_crapmot cr_crapmot%ROWTYPE;
          
          --Variaveis Locais
          vr_indice   INTEGER:= 1;
          vr_dsmotrel VARCHAR2(1000):= NULL;
          vr_dsfinal  VARCHAR2(1000):= NULL;
          vr_cdmotivo crapmot.cdmotivo%TYPE;

        BEGIN
          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.fn_busca_lista_motivo', pr_action => NULL);

          --Percorrer a String de motivos
          WHILE vr_indice < LENGTH(TRIM(NVL(pr_dsmotivo,' '))) LOOP
            --Extrair o codigo do motivo da string
            vr_cdmotivo:= TRIM(SUBSTR(pr_dsmotivo, vr_indice, 2));
            /* buscar os motivos da ocorrencia */
            OPEN cr_crapmot (pr_cdcooper => pr_cdcooper
                            ,pr_cddbanco => pr_cddbanco
                            ,pr_cdocorre => pr_cdocorre
                            ,pr_tpocorre => 2 /* Mot. do retorno */
                            ,pr_cdmotivo => vr_cdmotivo);
            --Posicionar no proximo registro
            FETCH cr_crapmot INTO rw_crapmot;
            --Se nao encontrar
            IF cr_crapmot%FOUND THEN
              --Se possui descricao
              IF TRIM(rw_crapmot.dsmotivo) IS NOT NULL THEN
                --Concatenar Codigo + Descricao
                vr_dsmotrel:= vr_cdmotivo||' - '||rw_crapmot.dsmotivo;
                --Concatenar string final
                vr_dsfinal:= vr_dsfinal ||vr_dsmotrel||',';
              END IF;
            ELSIF vr_indice = 1 AND cr_crapmot%NOTFOUND THEN 
              --Retornar com o mesmo valor de entrada
              vr_dsfinal:= vr_cdmotivo||','; 
            END IF;  
            --Fechar Cursor
            CLOSE cr_crapmot;
            --Incrementar indice
            vr_indice:= vr_indice + 2;
          END LOOP;
          --Retornar descricao 
          RETURN(vr_dsfinal); 
        EXCEPTION    
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na rotina fn_busca_lista_motivo: '||SQLErrm;

            --Inclusão na tabela de erros Oracle - Chamado 743443
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             

            RAISE vr_exc_saida;
        END;    
      END fn_busca_lista_motivo;  
        
      /*gerar relatorio crrl594 - - Acompanhamento da integracao dos boletos por convenio*/
      PROCEDURE pc_gera_relatorio_594 (pr_cdcooper          IN crapcop.cdcooper%TYPE   -- codigo da cooperativa
                                      ,pr_dtmvtolt          IN crapdat.dtmvtolt%TYPE   -- Data Movimento
                                      ,pr_tab_cratarq       IN typ_tab_cratarq         -- Tabela dos arquivos processados                                   
                                      ,pr_tab_cratrej       IN typ_tab_cratrej         -- Tabela Rejeitados
                                      ,pr_tab_relatorio     IN typ_tab_detrel          -- Tabela Relatorio
                                      ,pr_tab_rel_analitico IN typ_tab_detalhe_analitico   -- Tabela Relatorio
                                      ,pr_tab_migracao      IN typ_tab_migracao        -- Tabela Migrados
                                      ,pr_cdcritic          OUT INTEGER                -- Codigo da critica
                                      ,pr_dscritic          OUT VARCHAR2) IS           -- Descricao da critica
      BEGIN
        DECLARE
          --Selecionar Convenio
          CURSOR cr_crapcco (pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrconven IN crapcco.nrconven%TYPE) IS
            SELECT crapcco.dsorgarq 
            FROM crapcco
            WHERE crapcco.cdcooper = pr_cdcooper
            AND   crapcco.nrconven = pr_nrconven;               
          rw_crapcco cr_crapcco%ROWTYPE;
          
          --Tabela para descricoes dos motivos
          vr_tab_motivo GENE0002.typ_split;
          --Indice de Motivos
          vr_index_motivo VARCHAR2(32767);
          --Variaveis Locais
          vr_contador INTEGER;
          vr_flgrejei BOOLEAN;
          vr_dtmvtopr DATE;
          vr_nmarqimp VARCHAR2(200);
          vr_dshistor VARCHAR2(200);
          vr_dsmotrel VARCHAR2(2000);
          vr_dsparams VARCHAR2(1000);
          vr_tem_migracao VARCHAR2(1);
          --Variaveis Locais para Relatorio Migrados
          vr_qtdmigra INTEGER:= 0;
          vr_vlrmigra NUMBER:= 0;
          vr_vltarifa NUMBER:= 0;
          vr_nmarquiv VARCHAR2(1000);
          --Variaveis de Erro
          vr_cdcritic INTEGER;
          vr_dscritic VARCHAR2(4000);
          --Tabela de Memoria auxiliar
          vr_tab_migracao_aux typ_tab_migracao;
          --Excecoes
          vr_exc_erro EXCEPTION;

        BEGIN
          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_gera_relatorio_594', pr_action => NULL);

          --Inicializar Variaveis retorno erro
          pr_cdcritic:= NULL;
          pr_dscritic:= NULL;
          
          --Inicializar Contador
          vr_contador:= 1;
          
          --Percorrer Arquivos
          vr_index_cratarq:= pr_tab_cratarq.FIRST;

          WHILE vr_index_cratarq IS NOT NULL LOOP

            --Selecionar Convenio
            OPEN cr_crapcco (pr_cdcooper => pr_tab_cratarq(vr_index_cratarq).cdcooper
                            ,pr_nrconven => pr_tab_cratarq(vr_index_cratarq).nroconve);
            FETCH cr_crapcco INTO rw_crapcco;
            --Se Nao encontrou entao sai
            IF cr_crapcco%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapcco;
              
              -- Gerando o nome do arquivo de erro
              vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_index_cratarq).nmarquiv,1,29);

              -- Comando para mover o arquivo para a pasta integra
              vr_comando:= 'mv '||vr_dir_salvar||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' '||vr_dir_integra||'/'||vr_nmarquiv||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);
                        
              IF trim(vr_dscritic) IS NOT NULL THEN
                -- Padronização de logs - Chamado 743443 - 02/10/2017
                pc_gera_log(pr_cdcooper   => pr_cdcooper,
                            pr_dstiplog   => 'E',
                            pr_dscritic   => vr_dscritic,
                            pr_tpocorrencia => 2);  --Erro Tratado
                vr_dscritic := NULL;
              END IF;
                                    
              --Proximo Arquivo
              vr_index_cratarq:= pr_tab_cratarq.NEXT(vr_index_cratarq); 
              CONTINUE;                     
              
            END IF;  
            --Fechar Cursor
            CLOSE cr_crapcco;
            
            --Inicializar Clob
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            --Nome Arquivo Impressao
            vr_nmarqimp:= 'crrl594_'|| gene0002.fn_mask(pr_tab_cratarq(vr_index_cratarq).nroconve,'9999999')||
                          '_script'||trim(to_char(sysdate,'ddmmyyyy'))||'_'|| gene0002.fn_mask(vr_contador,'99')||'.lst';
            --Incrementar Contador
            vr_contador:= nvl(vr_contador,0) + 1;
          
            --Inicializar Variaveis
            vr_flgrejei:= FALSE;
            vr_dtmvtopr:= pr_dtmvtolt;  
            
            --Verificar se existem migraoes
            IF nvl(pr_tab_cratarq(vr_index_cratarq).qtdmigra,0) > 0 THEN
              vr_tem_migracao:= 'S';
            ELSE
              vr_tem_migracao:= 'N';
            END IF;
                
            --Criar tag xml do totalizador
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
               '<?xml version="1.0" encoding="utf-8"?><crrl594 migracoes="'||vr_tem_migracao||'"><arquivo>');
          
            --Montar Parametros para relat¿rio
            vr_dsparams:=  'PR_NMARQUIV##compbb/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||'@@'||
                           'PR_DTMVTOPR##'||to_char(vr_dtmvtopr,'DD/MM/YYYY')||'@@'||
                           'PR_CDAGENCI##'||pr_tab_cratarq(vr_index_cratarq).cdagenci||'@@'||
                           'PR_CDBCCXLT##'||pr_tab_cratarq(vr_index_cratarq).cdbccxlt||'@@'||
                           'PR_NRDOLOTE##'||to_char(pr_tab_cratarq(vr_index_cratarq).nrdolote,'fm999g990')||'@@'||
                           'PR_TPLOTMOV##'||to_char(pr_tab_cratarq(vr_index_cratarq).tplotmov,'fm00')||'@@'||
                           'PR_NROCONVE##'||to_char(pr_tab_cratarq(vr_index_cratarq).nroconve,'fm00000000')||'@@'||
                           'PR_DSORGARQ##'||' - '||rw_crapcco.dsorgarq||'@@'||
                           'PR_QTREGREC##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).qtregrec,0),'fm999g990')||'@@'||
                           'PR_QTREGICD##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).qtregicd,0),'fm999g990')||'@@'||
                           'PR_QTREGISD##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).qtregisd,0),'fm999g990')||'@@'||
                           'PR_QTREGREJ##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).qtregrej,0),'fm999g990')||'@@'||                                                                           
                           'PR_VLREGREC##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).vlregrec,0),'fm9999g999g990d00')||'@@'||
                           'PR_VLREGICD##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).vlregicd,0),'fm9999g999g990d00')||'@@'||
                           'PR_VLREGISD##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).vlregisd,0),'fm9999g999g990d00')||'@@'||
                           'PR_VLREGREJ##'||to_char(nvl(pr_tab_cratarq(vr_index_cratarq).vlregrej,0),'fm9999g999g990d00');
                           
            --Listar Rejeitados
            vr_indcratrej:= pr_tab_cratrej.FIRST;
            WHILE vr_indcratrej IS NOT NULL LOOP

              
              --Verificar se eh do mesmo arquivo
              IF pr_tab_cratrej(vr_indcratrej).nmarquiv = pr_tab_cratarq(vr_index_cratarq).nmarquiv THEN
                
                --Encontrou rejeitados
                vr_flgrejei:= TRUE;
                --Codigo Critica
                vr_cdcritic:= pr_tab_cratrej(vr_indcratrej).cdcritic;
                
                --Se nao tem erro
                IF nvl(vr_cdcritic,0) = 0 THEN
                  vr_dscritic:= pr_tab_cratrej(vr_indcratrej).dshistor;
                ELSE
                  --Buscar Critica
                  vr_dscritic:= pr_tab_cratrej(vr_indcratrej).dshistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
                END IF;
                
                /** Boleto pago c/ cheque **/
                IF pr_tab_cratrej(vr_indcratrej).cdcritic = 922  AND 
                   trim(pr_tab_cratrej(vr_indcratrej).dshistor) IS NOT NULL  THEN
                  --Montar Historico
                  vr_dshistor:= pr_tab_cratrej(vr_indcratrej).dshistor;  
                ELSE
                  vr_dshistor:= NULL;   
                END IF;
                --Escrever registro no XML   
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                  '<conta>
                    <nrseqdig>'||to_char(pr_tab_cratrej(vr_indcratrej).nrseqdig,'fm999g990')||'</nrseqdig>
                    <nrdconta>'||to_char(pr_tab_cratrej(vr_indcratrej).nrdconta,'fm9g999g999g9')||'</nrdconta>
                    <nrdocmto>'||to_char(pr_tab_cratrej(vr_indcratrej).nrdocmto,'fm999g999g990')||'</nrdocmto>
                    <cdpesqbb>'||substr(pr_tab_cratrej(vr_indcratrej).cdpesqbb,1,20)||'</cdpesqbb>
                    <vllanmto>'||To_Char(pr_tab_cratrej(vr_indcratrej).vllanmto,'fm999999g990d00')||'</vllanmto>
                    <cdbccxlt>'||pr_tab_cratrej(vr_indcratrej).cdbccxlt||'</cdbccxlt>
                    <cdagenci>'||pr_tab_cratrej(vr_indcratrej).cdagenci||'</cdagenci>
                    <dscritic>'||substr(vr_dscritic,1,54)||'</dscritic>
                    <dshistor>'||vr_dshistor||'</dshistor>
                   </conta>');
              END IF;     
              --Proximo Registro
              vr_indcratrej:= pr_tab_cratrej.NEXT(vr_indcratrej);
            END LOOP;  
            
            --Fechar tag xml
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</arquivo><sintetico>');
            
            /*** Relatorio Sintetico ***/
            vr_index_relato:= pr_tab_relatorio.FIRST;
           
            --Enquanto existir Ocorrencia    
            WHILE vr_index_relato IS NOT NULL LOOP
              
              --Verificar se ¿ do mesmo arquivo
              IF pr_tab_relatorio(vr_index_relato).nmarquiv = pr_tab_cratarq(vr_index_cratarq).nmarquiv THEN

                --Escrever registro no XML   
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                  '<det_sintetico>
                    <cdocorre>'||to_char(pr_tab_relatorio(vr_index_relato).cdocorre,'fm90')||'</cdocorre>
                    <dsocorre>'||substr(pr_tab_relatorio(vr_index_relato).dsocorre,1,30)||'</dsocorre>
                    <qtdregis>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).qtdregis,0),'fm9990')||'</qtdregis>
                    <vltotreg>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).vltotreg,0),'fm999g999g990d00')||'</vltotreg>
                    <vltotdes>'||To_Char(nvl(pr_tab_relatorio(vr_index_relato).vltotdes,0),'fm999999g990d00')||'</vltotdes>
                    <vltotjur>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).vltotjur,0),'fm999g999g990d00')||'</vltotjur>
                    <vloutdeb>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).vloutdeb,0),'fm999g999g990d00')||'</vloutdeb>
                    <vloutcre>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).vloutcre,0),'fm999g999g990d00')||'</vloutcre>
                    <vltotpag>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).vltotpag,0),'fm999g999g990d00')||'</vltotpag>
                    <vltottar>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).vltottar,0),'fm999g999g990d00')||'</vltottar>
                    <tottaras>'||to_char(nvl(pr_tab_relatorio(vr_index_relato).tottaras,0),'fm999g999g990d00')||'</tottaras>                    
                   </det_sintetico>');
              END IF;     
              --Proximo Registro
              vr_index_relato:= pr_tab_relatorio.NEXT(vr_index_relato);
            END LOOP;  
              
            --Fechar tag xml sintetico
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</sintetico><analitico>');
          
            /*** Relatorio Analitico ***/
             vr_index_analit:= pr_tab_rel_analitico.FIRST;
             
            --Enquanto existir Analistico    
            WHILE vr_index_analit IS NOT NULL LOOP
              
              --Verificar se ¿ do mesmo arquivo
              IF pr_tab_rel_analitico(vr_index_analit).nmarquiv = pr_tab_cratarq(vr_index_cratarq).nmarquiv THEN

                --Buscar Lista Motivos
                vr_dsmotrel:= fn_busca_lista_motivo (pr_cdcooper => pr_cdcooper                       --Codigo Cooperativa
                                                    ,pr_cddbanco => pr_tab_cratarq(vr_index_cratarq).cdbccxlt --Codigo Banco
                                                    ,pr_cdocorre => pr_tab_rel_analitico(vr_index_analit).cdocorre --Codigo Ocorrencia
                                                    ,pr_dsmotivo => pr_tab_rel_analitico(vr_index_analit).dsmotivo);

                -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
                GENE0001.pc_set_modulo(pr_module => 'PC_CRPS594.pc_gera_relatorio_594', pr_action => NULL);

                --Colocar as descricoes na tabela de memoria
                vr_tab_motivo:= gene0002.fn_quebra_string(pr_string => vr_dsmotrel); 
                  
                --Montar TAGs de Motivos
                IF vr_tab_motivo.COUNT > 0 THEN
                  
                  --Primeiro Motivo
                  vr_index_motivo:= vr_tab_motivo.FIRST;
                  
                  WHILE vr_index_motivo IS NOT NULL LOOP
                    --Primeiro registro mostra todas as informacoes
                    IF vr_index_motivo = vr_tab_motivo.FIRST THEN
                      --Escrever registro no XML   
                      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                        '<det_analitico>
                          <cdocorre>'||to_char(pr_tab_rel_analitico(vr_index_analit).cdocorre,'fm90')||'</cdocorre>
                          <dsocorre>'||substr(pr_tab_rel_analitico(vr_index_analit).dsocorre,1,30)||'</dsocorre>
                          <cdagenci>'||to_char(pr_tab_rel_analitico(vr_index_analit).cdagenci,'fm990')||'</cdagenci>
                          <nrdconta>'||GENE0002.fn_mask_conta(pr_tab_rel_analitico(vr_index_analit).nrdconta)||'</nrdconta>
                          <nrdocmto>'||to_char(pr_tab_rel_analitico(vr_index_analit).nrdocmto,'fm999g999g990')||'</nrdocmto>
                          <nrnosnum>'||substr(pr_tab_rel_analitico(vr_index_analit).nrnosnum,1,20)||'</nrnosnum>
                          <dstitdsc>'||substr(pr_tab_rel_analitico(vr_index_analit).dstitdsc,1,2)||'</dstitdsc>
                          <dsdoccop>'||substr(pr_tab_rel_analitico(vr_index_analit).dsdoccop,1,15)||'</dsdoccop>
                          <dtvencto>'||to_char(pr_tab_rel_analitico(vr_index_analit).dtvencto,'DD/MM/RR')||'</dtvencto>
                          <vllanmto>'||to_char(pr_tab_rel_analitico(vr_index_analit).vllanmto,'fm999g999g990d00')||'</vllanmto>
                          <vldesaba>'||to_char(pr_tab_rel_analitico(vr_index_analit).vldesaba,'fm999g999g990d00')||'</vldesaba>
                          <vljurmul>'||to_char(pr_tab_rel_analitico(vr_index_analit).vljurmul,'fm999g999g990d00')||'</vljurmul>
                          <vloutdeb>'||to_char(pr_tab_rel_analitico(vr_index_analit).vloutdeb,'fm999g999g990d00')||'</vloutdeb>
                          <vloutcre>'||to_char(pr_tab_rel_analitico(vr_index_analit).vloutcre,'fm999g999g990d00')||'</vloutcre>                    
                          <vlrpagto>'||to_char(pr_tab_rel_analitico(vr_index_analit).vlrpagto,'fm999g999g990d00')||'</vlrpagto>                    
                          <bancoage>'||pr_tab_rel_analitico(vr_index_analit).bancoage||'</bancoage>                    
                          <vltarifa>'||to_char(pr_tab_rel_analitico(vr_index_analit).vltarifa,'fm999g999g990d00')||'</vltarifa>                                        
                          <vltarass>'||to_char(pr_tab_rel_analitico(vr_index_analit).vltarass,'fm999g999g990d00')||'</vltarass>
                          <motivo>'||vr_tab_motivo(vr_index_motivo)||'</motivo>
                          <contar>1</contar></det_analitico>');                                        
                    ELSIF trim(vr_tab_motivo(vr_index_motivo)) IS NOT NULL THEN
                      --Escrever registro no XML   
                      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                        '<det_analitico>
                          <cdocorre>'||to_char(pr_tab_rel_analitico(vr_index_analit).cdocorre,'fm90')||'</cdocorre>
                          <dsocorre>'||substr(pr_tab_rel_analitico(vr_index_analit).dsocorre,1,30)||'</dsocorre>
                          <cdagenci></cdagenci>
                          <nrdconta></nrdconta>
                          <nrdocmto></nrdocmto>
                          <nrnosnum></nrnosnum>
                          <dstitdsc></dstitdsc>
                          <dsdoccop></dsdoccop>
                          <dtvencto></dtvencto>
                          <vllanmto></vllanmto>
                          <vldesaba></vldesaba>
                          <vljurmul></vljurmul>
                          <vloutdeb></vloutdeb>
                          <vloutcre></vloutcre>                    
                          <vlrpagto></vlrpagto>                    
                          <bancoage></bancoage>                    
                          <vltarifa></vltarifa>                                        
                          <vltarass></vltarass>
                          <motivo>'||vr_tab_motivo(vr_index_motivo)||'</motivo><contar>0</contar></det_analitico>');                                        
                    END IF;
                    --Proximo Motivo
                    vr_index_motivo:= vr_tab_motivo.NEXT(vr_index_motivo);      
                  END LOOP;  
                ELSE
                  --Escrever registro no XML   
                  gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                    '<det_analitico>
                      <cdocorre>'||to_char(pr_tab_rel_analitico(vr_index_analit).cdocorre,'fm90')||'</cdocorre>
                      <dsocorre>'||substr(pr_tab_rel_analitico(vr_index_analit).dsocorre,1,30)||'</dsocorre>
                      <cdagenci>'||to_char(pr_tab_rel_analitico(vr_index_analit).cdagenci,'fm990')||'</cdagenci>
                      <nrdconta>'||GENE0002.fn_mask_conta(pr_tab_rel_analitico(vr_index_analit).nrdconta)||'</nrdconta>
                      <nrdocmto>'||to_char(pr_tab_rel_analitico(vr_index_analit).nrdocmto,'fm999g999g990')||'</nrdocmto>
                      <nrnosnum>'||substr(pr_tab_rel_analitico(vr_index_analit).nrnosnum,1,20)||'</nrnosnum>
                      <dstitdsc>'||substr(pr_tab_rel_analitico(vr_index_analit).dstitdsc,1,2)||'</dstitdsc>
                      <dsdoccop>'||substr(pr_tab_rel_analitico(vr_index_analit).dsdoccop,1,15)||'</dsdoccop>
                      <dtvencto>'||to_char(pr_tab_rel_analitico(vr_index_analit).dtvencto,'DD/MM/RR')||'</dtvencto>
                      <vllanmto>'||to_char(pr_tab_rel_analitico(vr_index_analit).vllanmto,'fm999g999g990d00')||'</vllanmto>
                      <vldesaba>'||to_char(pr_tab_rel_analitico(vr_index_analit).vldesaba,'fm999g999g990d00')||'</vldesaba>
                      <vljurmul>'||to_char(pr_tab_rel_analitico(vr_index_analit).vljurmul,'fm999g999g990d00')||'</vljurmul>
                      <vloutdeb>'||to_char(pr_tab_rel_analitico(vr_index_analit).vloutdeb,'fm999g999g990d00')||'</vloutdeb>
                      <vloutcre>'||to_char(pr_tab_rel_analitico(vr_index_analit).vloutcre,'fm999g999g990d00')||'</vloutcre>                    
                      <vlrpagto>'||to_char(pr_tab_rel_analitico(vr_index_analit).vlrpagto,'fm999g999g990d00')||'</vlrpagto>                    
                      <bancoage>'||pr_tab_rel_analitico(vr_index_analit).bancoage||'</bancoage>                    
                      <vltarifa>'||to_char(pr_tab_rel_analitico(vr_index_analit).vltarifa,'fm999g999g990d00')||'</vltarifa>                                        
                      <vltarass>'||to_char(pr_tab_rel_analitico(vr_index_analit).vltarass,'fm999g999g990d00')||'</vltarass>
                      <motivo></motivo><contar>1</contar></det_analitico>');                                        
                END IF;  
              END IF;     
              --Proximo Registro
              vr_index_analit:= pr_tab_rel_analitico.NEXT(vr_index_analit);
            END LOOP;  
            
            --Fechar tag analitico xml
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</analitico><migracoes>');

            --Houve Migracao
            IF nvl(pr_tab_cratarq(vr_index_cratarq).qtdmigra,0) > 0 THEN
              
              --Deixar somente as migracoes do arquivo processado na tabela temporaria
              vr_tab_migracao_aux.DELETE;
              
              --Encontrar primeira migracao
              vr_index_migracao:= pr_tab_migracao.FIRST;
              --Percorrer migracoes
              WHILE vr_index_migracao IS NOT NULL LOOP 
                --Verificar se ¿ mesmo arquivo
                IF pr_tab_migracao(vr_index_migracao).nmarquiv = pr_tab_cratarq(vr_index_cratarq).nmarquiv THEN
                  vr_tab_migracao_aux(vr_index_migracao):= pr_tab_migracao(vr_index_migracao); 
                END IF;
                --Proximo Registro
                vr_index_migracao:= pr_tab_migracao.NEXT(vr_index_migracao);  
              END LOOP;  
              
              --Encontrar primeira migracao
              vr_index_migracao:= vr_tab_migracao_aux.FIRST;
              
              --Percorrer migracoes
              WHILE vr_index_migracao IS NOT NULL LOOP 
                
                --FIRST-OF
                IF vr_index_migracao = vr_tab_migracao_aux.FIRST OR
                  vr_tab_migracao_aux(vr_index_migracao).cdcopdst <> 
                  vr_tab_migracao_aux(vr_tab_migracao_aux.PRIOR(vr_index_migracao)).cdcopdst THEN
                  --Zerar variaveis
                  vr_qtdmigra:= 0;
                  vr_vlrmigra:= 0;
                  vr_vltarifa:= 0;
                END IF;   
              
                --Acumular migracoes
                vr_qtdmigra:= nvl(vr_qtdmigra,0) + nvl(vr_tab_migracao_aux(vr_index_migracao).qttitmig,0);
                vr_vlrmigra:= nvl(vr_vlrmigra,0) + nvl(vr_tab_migracao_aux(vr_index_migracao).vllanmto,0);
                vr_vltarifa:= nvl(vr_vltarifa,0) + nvl(vr_tab_migracao_aux(vr_index_migracao).vlrtarif,0);
                
                --LAST-OF
                IF vr_index_migracao = vr_tab_migracao_aux.LAST  OR
                   vr_tab_migracao_aux(vr_index_migracao).cdcopdst <> vr_tab_migracao_aux(vr_tab_migracao_aux.NEXT(vr_index_migracao)).cdcopdst THEN
                  --Escrever registro no XML   
                  gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                    '<migracao>
                      <nmrescop>'||vr_tab_migracao_aux(vr_index_migracao).nmrescop||'</nmrescop>
                      <qtdmigra>'||to_char(vr_qtdmigra,'fm999g990')||'</qtdmigra>
                      <vlrmigra>'||to_char(vr_vlrmigra,'fm9999g999g990d00')||'</vlrmigra>
                      <vltarifa>'||to_char(vr_vltarifa,'fm999g999g990d00')||'</vltarifa>
                     </migracao>'); 
                END IF;
              
                --Proximo Registro
                vr_index_migracao:= vr_tab_migracao_aux.NEXT(vr_index_migracao);
              END LOOP;  
            END IF;

            --Fechar tag migracoes e relatorio
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</migracoes></crrl594>',TRUE);
              
            --Se teve rejeitados
            IF vr_flgrejei THEN
              vr_dscritic:= gene0001.fn_busca_critica(191); 
            ELSE 
              vr_dscritic:= gene0001.fn_busca_critica(190);
            END IF;

            -- Padronização de logs - Chamado 743443 - 02/10/2017
            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                        pr_dstiplog   => 'E',
                        pr_dscritic   => vr_dscritic|| ' compbb/'|| pr_tab_cratarq(vr_index_cratarq).nmarquiv,
                        pr_tpocorrencia => 4);  --Mensagem

            --Solicitar geracao do arquivo por agencia
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                       ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl594'          --> N¿ base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl594.jasper'    --> Arquivo de layout do iReport
                                       ,pr_dsparams  => vr_dsparams         --> Parametros do Relatorio
                                       ,pr_dsarqsaid => vr_dir_rl ||'/'|| vr_nmarqimp --> Arquivo final
                                       ,pr_qtcoluna  => 234                 --> 234 colunas
                                       ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                       ,pr_flg_impri => 'S'                 --> Chamar a impress¿o (Imprim.p)
                                       ,pr_nmformul  => '234dh'             --> Nome do formul¿rio para impress¿o
                                       ,pr_nrcopias  => 1                   --> N¿mero de c¿pias
                                       ,pr_flg_gerar => 'N'                 --> gerar PDF
                                       ,pr_des_erro  => vr_dscritic);       --> Sa¿da com erro
                                      
            --Se ocorreu erro
            IF TRIM(vr_dscritic) IS NOT NULL THEN

              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            --Finalizar Clob
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml); 
              
            --Proximo Arquivo
            vr_index_cratarq:= pr_tab_cratarq.NEXT(vr_index_cratarq);
          END LOOP; -- pr_tab_cratarq   
        EXCEPTION
          WHEN vr_exc_erro THEN
            pr_cdcritic:= vr_cdcritic;
            pr_dscritic:= vr_dscritic;  

            -- Gerando o nome do arquivo de erro
            vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_index_cratarq).nmarquiv,1,29);

            -- Comando para mover o arquivo para a pasta integra
            vr_comando:= 'mv '||vr_dir_salvar||'/'||pr_tab_cratarq(vr_index_cratarq).nmarquiv||' '||vr_dir_integra||'/'||vr_nmarquiv||' 2> /dev/null';

            --Executar o comando no unix
            GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_dscritic;
            END IF;
          WHEN OTHERS THEN
            pr_cdcritic:= 0;
            pr_dscritic:= 'Erro na rotina pc_gera_relatorio_594: '||SQLErrm;          

            --Inclusão na tabela de erros Oracle - Chamado 743443
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        END;  
        
      END pc_gera_relatorio_594; /* fim cria_rejeitados */  
      
      
     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS594
     ---------------------------------------

    BEGIN

      -- Incluir nome do m¿dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      vr_tab_erro.delete;
                              
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se nao encontrar
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

      --Data e Hora inicial do processamento
      vr_datailog := trunc(SYSDATE);
      vr_horailog := gene0002.fn_busca_time;

      -- Validacoes iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro eh <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      
      -- Busca o diretorio da cooperativa conectada
      vr_dir_cooper:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => NULL);
      -- Setando os diretorios auxiliares
      vr_dir_integra := vr_dir_cooper||'/integra';
      vr_dir_salvar  := vr_dir_cooper||'/salvar';
      vr_dir_compbb  := vr_dir_cooper||'/compbb';
      vr_dir_rl      := vr_dir_cooper||'/rl';

      /*-------------  Busca nome dos arquivos a serem processados  --------------*/
      pc_busca_nome_arquivos (pr_cdcooper => pr_cdcooper,   -- codigo da cooperativa
                              pr_cdagenci => 0,             -- codigo da agencia
                              pr_nrdcaixa => 0,             -- Numero de caixa
                              pr_cddbanco => 1,             -- codigo do banco                              
                              pr_nmarqdeb  => vr_nmarqdeb,  -- Nome do arq de debito
                              pr_des_erro  => vr_des_erro,  -- Indicador de erro
                              pr_tab_erro  => vr_tab_erro); -- Tabela contendo os erros

      IF vr_des_erro = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        END IF;
        --Se possui arquivo, mas ocorreu algum erro diferente, grava tabela de erros
        IF trim(vr_nmarqdeb) IS NOT NULL THEN     /*  Nao existe convenio cadastrado  */
          -- Padronização de logs - Chamado 743443 - 02/10/2017
          pc_gera_log(pr_cdcooper   => pr_cdcooper,
                      pr_dstiplog   => 'E',
                      pr_dscritic   => vr_dscritic,
                      pr_tpocorrencia => 2);  --Erro Tratado
        END IF;
      END IF;  

      IF trim(vr_nmarqdeb) IS NULL THEN     /*  Nao existe convenio cadastrado  */
        --Sair sem erro
        RAISE vr_exc_fimprg;
      END IF;  
      
      -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
      
      --Substituir o asterisco por percent na string de filtro
      vr_nmarqdeb:= replace(vr_nmarqdeb,'*','%');

      --Buscar a lista de arquivos do diretorio
      gene0001.pc_lista_arquivos(pr_path     => vr_dir_compbb, 
                                 pr_pesq     => vr_nmarqdeb, 
                                 pr_listarq  => vr_listadir, 
                                 pr_des_erro => vr_dscritic);

      -- se ocorrer erro ao recuperar lista de arquivos registra no log
      IF trim(vr_dscritic) IS NOT NULL THEN
          -- Padronização de logs - Chamado 743443 - 02/10/2017
          pc_gera_log(pr_cdcooper   => pr_cdcooper,
                      pr_dstiplog   => 'E',
                      pr_dscritic   => vr_dscritic,
                      pr_tpocorrencia => 2);  --Erro Tratado
      END IF;

      /* Nao existem arquivos para serem importados */
      IF trim(vr_listadir) IS NULL THEN
        -- Sem arquivos para processar
        vr_flgarqui := FALSE; 
        -- Nao ha arquivo da COMPBB para integrar.
        vr_cdcritic := 258;   
        -- Finaliza o programa mantendo o processamento da cadeia
        RAISE vr_exc_fimprg;
      END IF;                           
      
      -- Limpando a tabela que possui a lista de arquivos que devem ser processados
      vr_tab_cratarq.delete;

      --Carregar a lista de arquivos na temp table
      vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listadir);

      -- Se retornou informacoes na temp table
      IF vr_tab_arquivo.count() > 0 THEN
        -- carrega informacoes na cratqrq
        FOR vr_ind IN 1..vr_tab_arquivo.count LOOP
          --Se Existir Arquivo
          IF vr_tab_arquivo.EXISTS(vr_ind) THEN
            -- Monta a chave da temp-table
            --vr_chave:= lpad(pr_cdcooper,5,'0')||rpad(vr_tab_arquivo(vr_ind),55,'#')||lpad(vr_ind,10,'0');
            vr_index_cratarq:= vr_tab_arquivo(vr_ind);   
            -- carrega a temp-table com a lista de arquivos que devems er processados
            vr_tab_cratarq(vr_index_cratarq).cdcooper := pr_cdcooper;
            vr_tab_cratarq(vr_index_cratarq).nmarquiv := vr_tab_arquivo(vr_ind);
            vr_tab_cratarq(vr_index_cratarq).nrsequen := vr_ind;
            vr_tab_cratarq(vr_index_cratarq).nmquoter := vr_tab_arquivo(vr_ind)||'.q';
          END IF;  
        END LOOP;
      -- Se nao possuir aquivos, sai do programa
      ELSE
        -- Sem arquivos para processar
        vr_flgarqui := FALSE; 
        -- Nao ha arquivo da COMPBB para integrar.
        vr_cdcritic := 258;   
        -- Finaliza o programa mantendo o processamento da cadeia
        RAISE vr_exc_fimprg;
      END IF;


      /*--------------------------  Processa arquivos  -------------------------*/
      pc_processa_arq_compensacao (  pr_cdcooper    => pr_cdcooper     -- Codigo da cooperativa
                                    ,pr_cdagenci    => 0               -- Codigo da agencia
                                    ,pr_nrdcaixa    => 0               -- Numero do caixa
                                    ,pr_crapdat     => rw_crapdat      -- Data do movimento
                                    ,pr_tab_cratarq => vr_tab_cratarq  -- Tabela dos arquivos q serao processados
                                    ,pr_tab_trailer => vr_tab_trailer  -- Tabela com os trailers dos lotes
                                    ,pr_tab_regimp  => vr_tab_regimp   -- Tabela dos registros procesados (boletos) 
                                    ,pr_cdcritic    => vr_cdcritic     -- Codigo Erro
                                    ,pr_dscritic    => vr_dscritic     -- Descricao Erro                                             
                                    ,pr_tab_erro    => vr_tab_erro     -- Tabela de erros
                                    );
      -- Se retornou erro, exibir logs e abortar
      IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL OR vr_tab_erro.count > 0 THEN
        --Se tabela erros possui informacao
        IF vr_tab_erro.count > 0 THEN
          FOR vr_idx in vr_tab_erro.first..vr_tab_erro.last LOOP
            -- Padronização de logs - Chamado 743443 - 02/10/2017
            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                        pr_dstiplog   => 'E',
                        pr_dscritic   => vr_tab_erro(vr_idx).dscritic,
                        pr_tpocorrencia => 2);  --Erro Tratado

           END LOOP;
        ELSE
          IF trim(vr_dscritic) IS NOT NULL THEN
            -- Padronização de logs - Chamado 743443 - 02/10/2017
            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                        pr_dstiplog   => 'E',
                        pr_dscritic   => vr_dscritic,
                        pr_tpocorrencia => 2);  --Erro Tratado
          END IF;
        END IF; 
        --Sair   
        RAISE vr_exc_saida;   
      END IF;                                 
      -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
      
      /*------------  Processa informacoes dos arquivos - atualizacoes ------------*/
      vr_arqimpor := null;                              
      
      -- variavel auxiliar para controle de break by
      vr_nmarqaux:= 'X';

      -- Posicionando no primeiro registro da tabela
      vr_indregimp := vr_tab_regimp.FIRST;
      -- Iniciando o loop na temp-table
      WHILE vr_indregimp IS NOT NULL LOOP

        -- se eh FIRST-OF(nmarquiv)
        IF vr_nmarqaux <> vr_tab_regimp(vr_indregimp).nmarquiv THEN
          IF trim(vr_arqimpor) IS NULL THEN
            vr_arqimpor:= 'compbb/'||vr_tab_regimp(vr_indregimp).nmarquiv;
          ELSE
            vr_arqimpor:= vr_arqimpor || ',' || 'compbb/'||vr_tab_regimp(vr_indregimp).nmarquiv;
          END IF;
        END IF;
        -- armazena o nome do arquivo
        vr_nmarqaux:= vr_tab_regimp(vr_indregimp).nmarquiv;

        -- proximo registro da temp-table
        vr_indregimp:= vr_tab_regimp.NEXT(vr_indregimp);
      END LOOP;

      --Escrever Integracao no Log
      vr_cdcritic := 219;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      -- Padronização de logs - Chamado 743443 - 02/10/2017
      pc_gera_log(pr_cdcooper   => pr_cdcooper,
                  pr_dstiplog   => 'E',
                  pr_dscritic   => vr_dscritic ||' --> '|| vr_arqimpor,
                  pr_tpocorrencia => 4);  --Mensagem

      vr_cdcritic := NULL;
      /* Efetivar as atualizacoes com base na importacao dos arquivos */
      pc_efetiva_atualiz_compensacao ( pr_cdcooper => pr_cdcooper       -- Codigo da cooperativa
                                      ,pr_crapdat  => rw_crapdat        -- Registro da crapdat
                                      ,pr_cdprogra => vr_cdprogra       -- Codigo do programa
                                      ,pr_tab_regimp  => vr_tab_regimp  -- Tabela dos titulos processados
                                      ,pr_tab_cratarq => vr_tab_cratarq -- Tabela dos arquivos
                                      ,pr_tab_cratrej => vr_tab_cratrej -- Tabela dos titulos rejeitados
                                      ,pr_tab_erro    => vr_tab_erro    -- Tabela de erros
                                      ,pr_dscritic    => vr_dscritic    -- Descricao do Erro
                                      ,pr_des_erro    => vr_des_erro);  -- Descricao da critica
                                                 
      -- Se retornou erro, exibir logs e abortar
      IF vr_des_erro = 'NOK' THEN 
        --Se possui erro na tabela
        IF vr_tab_erro.count > 0 THEN
          --Todos os erros
          FOR vr_idx in vr_tab_erro.first..vr_tab_erro.last LOOP
            -- Padronização de logs - Chamado 743443 - 02/10/2017
            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                        pr_dstiplog   => 'E',
                        pr_dscritic   => vr_tab_erro(vr_idx).dscritic,
                        pr_tpocorrencia => 2);  --Erro Tratado
          END LOOP;  
          --Sair
          RAISE vr_exc_saida;
        ELSE
          IF trim(vr_dscritic) IS NOT NULL THEN
            -- Padronização de logs - Chamado 743443 - 02/10/2017
            pc_gera_log(pr_cdcooper   => pr_cdcooper,
                        pr_dstiplog   => 'E',
                        pr_dscritic   => vr_dscritic,
                        pr_tpocorrencia => 2);  --Erro Tratado
          END IF;
          --Sair
          RAISE vr_exc_saida;  
        END IF;  
      END IF;
      -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
    
                              
      
      /*-------------------------  Processo de geracao tarifas ------------------------- */
      -- Padronização de logs - Chamado 743443 - 02/10/2017
      pc_gera_log(pr_cdcooper   => pr_cdcooper,
                  pr_dstiplog   => 'E',
                  pr_dscritic   => 'Inicio Processo Lancamento Tarifas',
                  pr_tpocorrencia => 4);  --Mensagem

      PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper  => pr_cdcooper          --Codigo Cooperativa
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --Data pagamento
                                           ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                           ,pr_cdcritic  => vr_cdcritic          --Codigo da Critica
                                           ,pr_dscritic  => vr_dscritic);
      -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

      -- Padronização de logs - Chamado 743443 - 02/10/2017
      pc_gera_log(pr_cdcooper   => pr_cdcooper,
                  pr_dstiplog   => 'E',
                  pr_dscritic   => 'Fim Processo Lancamento Tarifas',
                  pr_tpocorrencia => 4);  --Erro Tratado

      /*-------------------------  Gera Relatorios Finais ----------------------*/

      -- Padronização de logs - Chamado 743443 - 02/10/2017
      pc_gera_log(pr_cdcooper   => pr_cdcooper,
                  pr_dstiplog   => 'E',
                  pr_dscritic   =>  'Inicio Processo Geracao Relatorio 594',
                  pr_tpocorrencia => 4);  --Mensagem

      /*************************************************************************
        Objetivo: Geracao dos relatorios 594 - Acompanhamento da integracao
                  dos boletos por convenio
       *************************************************************************/
      pc_gera_relatorio_594 (pr_cdcooper      => pr_cdcooper         -- Codigo da cooperativa
                            ,pr_dtmvtolt      => rw_crapdat.dtmvtolt -- Data Movimento
                            ,pr_tab_cratarq   => vr_tab_cratarq      -- Tabela dos arquivos processados                                   
                            ,pr_tab_cratrej   => vr_tab_cratrej      -- Tabela Rejeitados
                            ,pr_tab_relatorio => vr_tab_relatorio    -- Tabela Relatorios
                            ,pr_tab_rel_analitico => vr_tab_rel_analitico -- Tabela Relatorio Analitico
                            ,pr_tab_migracao  => vr_tab_migracao     -- Tabela Migrados
                            ,pr_cdcritic      => vr_cdcritic         -- Codigo da critica
                            ,pr_dscritic      => vr_dscritic);       -- Descricao da critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Sair
        RAISE vr_exc_saida; 
      END IF;
      -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

      -- Padronização de logs - Chamado 743443 - 02/10/2017
      pc_gera_log(pr_cdcooper   => pr_cdcooper,
                  pr_dstiplog   => 'E',
                  pr_dscritic   =>  'Fim Processo Geracao Relatorio 594',
                  pr_tpocorrencia => 4);  --Mensagem

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informacaes atualizadas
      COMMIT;
      npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS594_1');
      
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar a descricao
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Padronização de logs - Chamado 743443 - 02/10/2017
        pc_gera_log(pr_cdcooper   => pr_cdcooper,
                    pr_dstiplog   => 'E',
                    pr_dscritic   => vr_dscritic,
                    pr_tpocorrencia => 2);  --Erro Tratado

        -- Se nao encontrou nenhum arquivo para processar deve continuar o processo 
        -- apenas alertando ao pessoal
        IF NOT vr_flgarqui THEN
          -- Enviar email para sistemas afim de avisar que o processo rodou sem COMPBB
          vr_conteudo := 'ATENCAO!!<br><br> Voce esta recebendo este e-mail pois o programa ' 
                      || vr_cdprogra || ' acusou critica ' || vr_dscritic 
                      || '<br><br>COOPERATIVA: ' || pr_cdcooper || ' - ' 
                      || rw_crapcop.nmrescop || '.<br>Data: ' || to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr') 
                      || '<br>Hora: ' || to_char(SYSDATE,'HH:MI:SS') 
                      || '<br><br>Arquivo <b>ied242</b> nao foi recebido!';
          -- Solicitar envio do email 
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'PC_'||vr_cdprogra
                                    ,pr_des_destino     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS594_EMAIL_COMPBB')
                                    ,pr_des_assunto     => 'Processo da Cooperativa ' ||pr_cdcooper || ' sem COMPE BB'
                                    ,pr_des_corpo       => vr_conteudo
                                    ,pr_des_anexo       => NULL
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          -- Inclusão do módulo e ação logado - Chamado 743443 - 02/10/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
        END IF;                                                    
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
        npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS594_2');

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar a descricao
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos codigo e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Efetuar rollback
        ROLLBACK;
        npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS594_3');

      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        --Inclusão na tabela de erros Oracle - Chamado 743443
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Efetuar rollback
        ROLLBACK;
        npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS594_4');

    END;

  END pc_crps594;

BEGIN  
  --
  for r0001 in (
                select cop.cdcooper
                      ,cop.nmrescop
                from crapcop cop
                where cop.cdcooper in (1,2,5,6,7,11,12,13,14,16)
               )
  loop
    --
    pc_crps594(pr_cdcooper => r0001.cdcooper
             , pr_nmtelant => 'COMPEFORA'
             , pr_cdoperad => '1'
             , pr_flgresta => 0
             , pr_stprogra => pr_stprogra
             , pr_infimsol => pr_infimsol
             , pr_cdcritic => pr_cdcritic
             , pr_dscritic => pr_dscritic);
    --
    dbms_output.put_line('-----------------------------------');
    dbms_output.put_line(r0001.cdcooper||' - '||r0001.nmrescop);
    dbms_output.put_line('pr_stprogra = ' || pr_stprogra);
    dbms_output.put_line('pr_infimsol = ' || pr_infimsol);  
    dbms_output.put_line('pr_cdcritic = ' || pr_cdcritic);  
    dbms_output.put_line('pr_dscritic = ' || pr_dscritic);
    --
  end loop;
  --
end;
