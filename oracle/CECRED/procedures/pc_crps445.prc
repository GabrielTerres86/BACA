CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS445 (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                                ,pr_cdagenci  IN PLS_INTEGER DEFAULT 0  --> Código da agência, utilizado no paralelismo
                                                ,pr_idparale  IN PLS_INTEGER DEFAULT 0  --> Identificador do job executando em paralelo.
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic OUT VARCHAR2) AS
/*.............................................................................

   Programa: PC_CRPS445                      Antigo: Fontes/crps445.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004.                     Ultima atualizacao: 12/02/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Gerar planilha Operacoes de Credito -  Utilizado no CORVU
               Solicitacao 2 - Ordem 37.

   Alteracoes: 03/05/2005 - Substituir planilha(arquivo texto) por tabela
                            CRAPSDV(Mirtes)
               25/05/2005 - Retirada gravacao arq.texto(Mirtes)
               24/02/2006 - Incluidos dados Aplicacao/Poupanca(Mirtes)
               23/05/2006 - Incluidos totais aplicacoes/operacoes de credito
                            (Mirtes)
               19/06/2006 - Ajustes nas leituras para deixa-los mais perfoma-
                            tico (Edson).
               21/06/2006 - Retirada eliminacao de registro da tabela crapsdv
                            (David).
               25/08/2006 - Incluido na tabela crapsdv o campo cdlcremp (Elton).

               27/11/2006 - Melhoria da performance (Evandro).

               25/06/2007 - Atualicao de novos atributos da tabela crapsda para
                            utilizacao no corvus (Sidnei - Precise):
                            - vltotpar, vlopcdia, qtdevolu, vltotren,
                              vlavaliz e vlavlatr

               09/08/2007 - Efetuar tratamento para aplicacoes RDC (David).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise).

               10/12/2007 - Melhorias de Performance (crapfdc, crapneg)(Julio).

               31/03/2008 - Colocado em comentario a Transacao de Aplicacoes e
                            a Transacao de Poupanca Programada (Guilherme).

               16/09/2008 - Alterada chave de acesso a tabela crapldc
                            (Gabriel).
                          - Adaptacao para desconto de titulos (David).

               05/05/2009 - Ajustes na leitura de desconto de titulo(Guilherme)

               18/06/2009 - Ajuste para considerar todos os rendimentos
                            do titular da conta (Gabriel).

               29/07/2009 - Alimentar campos crapsdv.dtpropos e crapsdv.dtefetiv
                            (Diego).

               11/11/2009 - Atribuir Zero para variavel aux_tot_vllimtit e
                            incluir os campos vllimtit e vldestit na atribuicao
                            de valores na tabela CRAPSCD (Guilherme/Precise)

               05/03/2010 - Passado valores para os campos novos da crapsdv
                            quando o tipo de saldo devedor for emprestimo
                            (crapsdv.tpdsaldo = 1) (Elton).

               24/03/2010 - Retirado delete da tabela crapscd;
                          - Somente utiliza contas menores que 230.000.0
                            (Elton).

               07/05/2010 - Inserido a soma de cheques em custodia por data de
                            liberacao (Irlan).

               10/06/2010 - Tratamento para pagamento feito atraves de TAA
                            (Elton).

               20/05/2011 - Melhorar performance (Magui).

               04/07/2011 - Alterado para executar em paralelo utilizando a
                            estrutura da crappar separando por cada PAC
                            (Evandro).

               10/08/2011 - Limpar e incluir PID no log da execucao paralela
                            (Evandro).

               14/11/2011 - Aumentada a quantidade de processos paralelos
                            (Evandro).

               27/03/2013 - Migrar para Oracle (Petter - Supero).

               16/05/2013 - Finalização e validação programa (Alisson - AMcom).

               06/11/2013 - Tratamento para Imunidade Tributaria (Marcos-Supero).

               04/09/2014 - Adicionado tratamento para os produtos de captação.
                            (Reinert)

               14/11/2014 - Melhorias de Performance (Alisson - AMcom)
                            Foi modificada a forma de atualização da tabela crapscd
                            para que não ocorra insert/update dentro do loop e sim
                            num único comando forall com Merge.

               29/10/2015 - Ajustes para melhoria de performace (Tiago Castro - RKAM)

               04/01/2015 - Melhoria na performance do cursor cr_crapfdc_carga
                            (Andrino - RKAM)
               
               03/05/2016 - Melhoria na performance do programa, incluidos hints de 
                            busca nos cursores cr_crawepr e cr_crapfdc_carga.
                            Ajustado numero de linhas processadas por vez, de 10000
                            para 30000, nao deve gerar problemas de memoria pois foi
                            ampliada a memoria da maquina.
                            (Heitor - RKAM)
                            
               12/02/2018 - Melhorias no programa para que possibilite a
                            execução do mesmo com paralelismo (Projeto Ligeirinho).
                            (Jonatas - AMCOM)                            
              
        18/03/2019 - Remover calculos de aplicações e consumir valores prontos
                            da tabela intermediária. (Petter Rafael - Envolti) 
............................................................................. */

/******************************************************************************
    Para restart eh necessario eliminar as tabelas crapscd e crapsdv e
    rodar novamente
******************************************************************************/
BEGIN
  DECLARE
    -- Tipo para instanciar PL TABLE para armazenar registros referentes as aplicação cadastradas
    TYPE typ_reg_crapdtc IS
      RECORD(tpaplrdc  crapdtc.tpaplrdc%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapdtc IS TABLE OF typ_reg_crapdtc INDEX BY VARCHAR2(3);
    vr_tab_crapdtc typ_tab_crapdtc;

    -- Tipo para instanciar PL TABLE para armazenar registros referentes aos saldos
    TYPE typ_reg_crapsdv IS
      RECORD(cdcooper crapsdv.cdcooper%TYPE
            ,nrdconta crapsdv.nrdconta%TYPE
            ,tpdsaldo crapsdv.tpdsaldo%TYPE
            ,nrctrato crapsdv.nrctrato%TYPE
            ,vldsaldo crapsdv.vldsaldo%TYPE
            ,dtmvtolt crapsdv.dtmvtolt%TYPE
            ,dsdlinha crapsdv.dsdlinha%TYPE
            ,dsfinali crapsdv.dsfinali%TYPE
            ,cdlcremp crapsdv.cdlcremp%TYPE
            ,dtpropos crapsdv.dtpropos%TYPE
            ,dtefetiv crapsdv.dtefetiv%TYPE
            ,inprejuz crapsdv.inprejuz%TYPE
            ,qtpreemp crapsdv.qtpreemp%TYPE
            ,vlemprst crapsdv.vlemprst%TYPE
            ,cdfinemp crapsdv.cdfinemp%TYPE
            ,dtdpagto crapsdv.dtdpagto%TYPE
            ,cdageepr crapsdv.cdageepr%TYPE
            ,flgareal crapsdv.flgareal%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapsdv IS TABLE OF typ_reg_crapsdv INDEX BY PLS_INTEGER;
    vr_tab_crapsdv typ_tab_crapsdv;

   -- Tabela para armazenar cálculo prévio para aplicações
    TYPE typ_reg_calc_aplicacao IS 
      RECORD(VLSALDO_BRUTO     TBCAPT_SALDO_APLICA.VLSALDO_BRUTO%TYPE
            ,VLSALDO_CONCILIA  TBCAPT_SALDO_APLICA.VLSALDO_CONCILIA%TYPE
            ,CDCOOPER          TBCAPT_SALDO_APLICA.CDCOOPER%TYPE
            ,NRDCONTA          TBCAPT_SALDO_APLICA.NRDCONTA%TYPE);
            
    -- Instancia de tabela de cálculo prévio para aplicações
    TYPE typ_tab_calc_aplicacao IS TABLE OF typ_reg_calc_aplicacao INDEX BY VARCHAR2(50);
    vr_tab_calc_aplicacao typ_tab_calc_aplicacao;

    -- Tipo para instanciar PL TABLE para 10000 evitando estouro no forall
    TYPE typ_reg_crapsdv2 IS
      RECORD(cdcooper crapsdv.cdcooper%TYPE
            ,nrdconta crapsdv.nrdconta%TYPE
            ,tpdsaldo crapsdv.tpdsaldo%TYPE
            ,nrctrato crapsdv.nrctrato%TYPE
            ,vldsaldo crapsdv.vldsaldo%TYPE
            ,dtmvtolt crapsdv.dtmvtolt%TYPE
            ,dsdlinha crapsdv.dsdlinha%TYPE
            ,dsfinali crapsdv.dsfinali%TYPE
            ,cdlcremp crapsdv.cdlcremp%TYPE
            ,dtpropos crapsdv.dtpropos%TYPE
            ,dtefetiv crapsdv.dtefetiv%TYPE
            ,inprejuz crapsdv.inprejuz%TYPE
            ,qtpreemp crapsdv.qtpreemp%TYPE
            ,vlemprst crapsdv.vlemprst%TYPE
            ,cdfinemp crapsdv.cdfinemp%TYPE
            ,dtdpagto crapsdv.dtdpagto%TYPE
            ,cdageepr crapsdv.cdageepr%TYPE
            ,flgareal crapsdv.flgareal%TYPE);

    TYPE typ_tab_crapsdv2 IS TABLE OF typ_reg_crapsdv2 INDEX BY PLS_INTEGER;
    vr_tab_crapsdv2 typ_tab_crapsdv2;

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crappla IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_crappla typ_tab_crappla;

    -- Tipo para instanciar PL TABLE para armazenar registros referentes as linhas de desconto

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapldc IS TABLE OF crapldc.dsdlinha%TYPE INDEX BY VARCHAR2(10);
    vr_tab_crapldc typ_tab_crapldc;


    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapcst IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_crapcst typ_tab_crapcst;
    vr_tab_craprpp typ_tab_crapcst;


    -- Instancia TEMP TABLE referente a tabela CRAPERR
    vr_tab_craterr GENE0001.typ_tab_erro;


    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craptdb IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_craptdb typ_tab_craptdb;

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapfdc IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
    vr_tab_crapfdc typ_tab_crapfdc;



    -- Tipo para instanciar PL TABLE para armazenar registros referentes aos cheques contidos no bordero de descontos de cheques
    TYPE typ_reg_crapcdb IS
      RECORD(vlcheque  NUMBER(20,8)
            ,nrctrlim  crapcdb.nrctrlim%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapcdb IS TABLE OF typ_reg_crapcdb INDEX BY PLS_INTEGER;
    vr_tab_crapcdb typ_tab_crapcdb;

    -- Tipo para instanciar PL TABLE para armazenar registros referentes aos contratos de limite de crédito
    TYPE typ_reg_craplim IS
      RECORD(nrdconta   craplim.nrdconta%TYPE
            ,vllimite   craplim.vllimite%TYPE
            ,nrctrlim   craplim.nrctrlim%TYPE
            ,dtpropos   craplim.dtpropos%TYPE
            ,tpctrlim   craplim.tpctrlim%TYPE
            ,insitlim   craplim.insitlim%TYPE
            ,dtinivig   craplim.dtinivig%TYPE
            ,cddlinha   craplim.cddlinha%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craplim IS TABLE OF typ_reg_craplim INDEX BY VARCHAR2(15);
    TYPE typ_tab_craplim2 IS TABLE OF typ_reg_craplim INDEX BY VARCHAR2(25);
    vr_tab_craplim  typ_tab_craplim;
    vr_tab_craplim2 typ_tab_craplim2;

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crawepr IS TABLE OF DATE INDEX BY VARCHAR2(20);
    vr_tab_crawepr typ_tab_crawepr;

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapfin IS TABLE OF crapfin.dsfinemp%TYPE INDEX BY PLS_INTEGER;
    vr_tab_crapfin typ_tab_crapfin;

    -- Tipo para instanciar PL TABLE para armazenar registros referentes a cadastro das linhas de crédito
    TYPE typ_reg_craplcr IS
      RECORD(cdlcremp   craplcr.cdlcremp%TYPE
            ,tpctrato   craplcr.tpctrato%TYPE
            ,dsoperac   craplcr.dsoperac%TYPE
            ,dslcremp   craplcr.dslcremp%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craplcr IS TABLE OF typ_reg_craplcr INDEX BY PLS_INTEGER;
    vr_tab_craplcr typ_tab_craplcr;


    -- Tipo para instanciar PL TABLE para armazenar registros referente a depósito a vista
    TYPE typ_reg_crapsld IS
      RECORD(nrdconta   crapsld.nrdconta%TYPE
            ,vlsdchsl   crapsld.vlsdchsl%TYPE
            ,vlsddisp   crapsld.vlsddisp%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapsld IS TABLE OF typ_reg_crapsld INDEX BY PLS_INTEGER;
    vr_tab_crapsld typ_tab_crapsld;


    -- Tipo para instanciar PL TABLE para armazenar registros referentes ao saldo diário dos associados
    TYPE typ_reg_crapsda IS
      RECORD(nrdconta  crapsda.nrdconta%TYPE
            ,vlavlatr  crapsda.vlavlatr%TYPE
            ,vlavaliz  crapsda.vlavaliz%TYPE
            ,dtmvtolt  crapsda.dtmvtolt%TYPE
            ,vlsddisp  crapsda.vlsddisp%TYPE
            ,vlsdchsl  crapsda.vlsdchsl%TYPE
            ,vlsdbloq  crapsda.vlsdbloq%TYPE
            ,vlsdblpr  crapsda.vlsdblpr%TYPE
            ,vlsdblfp  crapsda.vlsdblfp%TYPE
            ,vlsdindi  crapsda.vlsdindi%TYPE
            ,vllimcre  crapsda.vllimcre%TYPE);

    TYPE typ_reg_crapsda2 IS
      RECORD (cdcooper crapsda.cdcooper%TYPE
             ,nrdconta crapsda.nrdconta%TYPE
             ,dtmvtolt crapsda.dtmvtolt%TYPE
             ,vlsdeved crapsda.vlsdeved%TYPE
             ,vldeschq crapsda.vldeschq%TYPE
             ,vldestit crapsda.vldestit%TYPE
             ,vllimutl crapsda.vllimutl%TYPE
             ,vladdutl crapsda.vladdutl%TYPE
             ,vlsdrdca crapsda.vlsdrdca%TYPE
             ,vlsdrdpp crapsda.vlsdrdpp%TYPE
             ,vllimdsc crapsda.vllimdsc%TYPE
             ,vllimtit crapsda.vllimtit%TYPE
             ,vlprepla crapsda.vlprepla%TYPE
             ,vlprerpp crapsda.vlprerpp%TYPE
             ,vlcrdsal crapsda.vlcrdsal%TYPE
             ,qtchqliq crapsda.qtchqliq%TYPE
             ,qtchqass crapsda.qtchqass%TYPE
             ,vltotpar crapsda.vltotpar%TYPE
             ,vlopcdia crapsda.vlopcdia%TYPE
             ,qtdevolu crapsda.qtdevolu%TYPE
             ,vltotren crapsda.vltotren%TYPE
             ,vlsrdc30 crapsda.vlsrdc30%TYPE
             ,vlsrdc60 crapsda.vlsrdc60%TYPE
             ,vlsrdcpr crapsda.vlsrdcpr%TYPE
             ,vlsrdcpo crapsda.vlsrdcpo%TYPE
             ,vlsdempr crapsda.vlsdempr%TYPE
             ,vlsdfina crapsda.vlsdfina%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapsda IS TABLE OF typ_reg_crapsda INDEX BY PLS_INTEGER;
    TYPE typ_tab_crapsda2 IS TABLE OF typ_reg_crapsda2 INDEX BY BINARY_INTEGER;

    vr_tab_crapsda typ_tab_crapsda;
    vr_tab_crapsda2 typ_tab_crapsda2;

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapneg IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_crapneg typ_tab_crapneg;

    -- Instancia e indexa o tipo da PL TABLE para os titulares
    vr_tab_crapttl typ_tab_crapneg;

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca dados das contas dos associados
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE) IS        --> Código da cooperativa
      SELECT cs.nrdconta
      FROM crapass cs
      WHERE cs.cdcooper = pr_cdcooper;

    -- Busca dados das contas dos associados
    CURSOR cr_crapass_1(pr_cdcooper IN craptab.cdcooper%TYPE) IS       --> Código da cooperativa
      SELECT crapass.nrdconta
            ,crapass.vllimcre
            ,crapass.cdagenci
            ,crapass.inpessoa
            ,crapass.nrcpfcgc
      FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.dtelimin IS NULL        
        AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

    -- Buscar dados dos associados para depósito a vista
    -- Projeto Ligeirinho - Foi incluida a tabela CRAPASS ao cursor
    -- para executarmos o processo por agência.
    CURSOR cr_crapsld(pr_cdcooper IN craptab.cdcooper%TYPE) IS    --> Código da cooperativa
      SELECT sld.nrdconta
            ,sld.vlsdchsl
            ,sld.vlsddisp
      FROM crapsld sld
          ,crapass ass
      WHERE sld.cdcooper = ass.cdcooper 
        AND sld.nrdconta = ass.nrdconta
        AND sld.cdcooper = pr_cdcooper
        AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci); 

    -- Buscar dados de cadastro de empréstimos
    CURSOR cr_crapepr(pr_cdcooper IN craptab.cdcooper%TYPE--> Código da cooperativa
                      ) IS    
      select epr.nrdconta,
             epr.inliquid,
             epr.inprejuz,
             epr.vlsdprej,
             epr.vlsdeved,
             epr.nrctremp,
             epr.cdfinemp,
             epr.cdlcremp,
             epr.dtmvtolt,
             epr.qtpreemp,
             epr.vlemprst,
             epr.dtdpagto,
             epr.cdagenci,
             epr.vlpreemp,
             epr.vlsdevat
        from crapepr epr
            ,crapass ass 
       where epr.cdcooper = ass.cdcooper 
         AND epr.nrdconta = ass.nrdconta
         AND epr.cdcooper = pr_cdcooper 
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
         /*Buscar os que não estao liquidados ou
           os que estao liquidados porem ainda com prejuizo */
         AND ( epr.inliquid = 0 OR
              (epr.inliquid = 1 AND
               epr.inprejuz = 1 AND
               epr.vlsdprej > 0 ));
    rw_crapepr cr_crapepr%ROWTYPE;

    TYPE typ_rec_crapepr IS TABLE OF cr_crapepr%ROWTYPE
       INDEX BY PLS_INTEGER;
    vr_tab_crapepr_carga typ_rec_crapepr;

    TYPE typ_tab_crapepr IS TABLE OF typ_rec_crapepr
       INDEX BY PLS_INTEGER; --nrdconta
    vr_tab_crapepr typ_tab_crapepr;

    -- Buscar dados cadastro auxiliar dos emprétimos
    CURSOR cr_crawepr(pr_cdcooper IN craptab.cdcooper%TYPE--> Código da cooperativa
                      ) IS                           
      SELECT cp.nrdconta
            ,cp.nrctremp
            ,cp.dtmvtolt
      FROM crawepr cp
          ,crapass ass 
      WHERE cp.cdcooper = ass.cdcooper 
        AND cp.nrdconta = ass.nrdconta
        AND cp.cdcooper = pr_cdcooper
        AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci);   
    -- type para utilizacao no bulk collect
    TYPE typ_tab_crawepr_carga IS TABLE OF cr_crawepr%ROWTYPE index by pls_integer;
    r_crawepr typ_tab_crawepr_carga;

    -- Buscar dados do cadastro das linhas de crédito
    CURSOR cr_craplcr(pr_cdcooper IN craptab.cdcooper%TYPE) IS    --> Código da cooperativa
      SELECT cr.cdlcremp
            ,cr.tpctrato
            ,cr.dsoperac
            ,cr.dslcremp
      FROM craplcr cr
      WHERE cr.cdcooper = pr_cdcooper;

    -- Buscar dados do cadastro de finalidades
    CURSOR cr_crapfin(pr_cdcooper IN craptab.cdcooper%TYPE) IS    --> Código da cooperativa
      SELECT cn.cdfinemp
            ,cn.dsfinemp
      FROM crapfin cn
      WHERE cn.cdcooper = pr_cdcooper;

    -- Buscar dados sobre titulos contidos no bordero de descontos de titulos
    CURSOR cr_craptdb(pr_cdcooper IN craptab.cdcooper%TYPE       --> Código da cooperativa
                     ,pr_nrdconta IN craptdb.nrdconta%TYPE       --> Código da conta
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS   --> Data de execução do movimento
      SELECT /*+ index (craptdb craptdb##craptdb6) */
             ct.cdbandoc
            ,ct.nrdctabb
            ,ct.nrcnvcob
            ,ct.nrdconta
            ,ct.nrdocmto
            ,ct.insittit
            ,ct.vltitulo
            ,ct.nrctrlim
            ,ct.dtvencto
            ,ct.dtdpagto
            ,ct.rowid
      FROM craptdb ct
      WHERE ct.cdcooper =  pr_cdcooper
      AND   ct.nrdconta =  pr_nrdconta
        AND ( (ct.insittit = 4 AND ct.dtvencto >= pr_dtmvtolt)
               OR(ct.insittit = 2 AND ct.dtdpagto = pr_dtmvtolt) );
    rw_craptdb cr_craptdb%ROWTYPE;

    -- Buscar dados sobre titulos contidos no bordero de descontos de titulos
    CURSOR cr_craptdb_conta (pr_cdcooper IN craptab.cdcooper%TYPE       --> Código da cooperativa
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS   --> Data de execução do movimento
      SELECT craptdb.nrdconta
      FROM craptdb craptdb
          ,crapass 
      WHERE craptdb.cdcooper =  pr_cdcooper
        AND craptdb.cdcooper = crapass.cdcooper
        AND craptdb.nrdconta = crapass.nrdconta
        AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
        AND ( (craptdb.insittit = 4 AND craptdb.dtvencto >= pr_dtmvtolt)
               OR(craptdb.insittit = 2 AND craptdb.dtdpagto = pr_dtmvtolt) );

    -- Buscar dados dos contratos de limite de crédito
    CURSOR cr_craplim(pr_cdcooper IN craptab.cdcooper%TYPE--> Código da cooperativa
                      ) IS    
      SELECT ci.nrdconta
            ,ci.vllimite
            ,ci.nrctrlim
            ,ci.dtpropos
            ,ci.tpctrlim
            ,ci.insitlim
            ,ci.dtinivig
            ,ci.cddlinha
            ,Row_Number() OVER (PARTITION BY ci.nrdconta,ci.tpctrlim,ci.insitlim
                                ORDER BY ci.nrdconta,ci.tpctrlim,ci.insitlim,ci.progress_recid ASC) seqreg
      FROM craplim ci
            ,crapass ass 
        WHERE ci.cdcooper = ass.cdcooper 
          AND ci.nrdconta = ass.nrdconta 
          AND ci.cdcooper = pr_cdcooper
          AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci);    

    -- Buscar dados cheques contidos no bordero de descontos de cheques
    CURSOR cr_crapcdb(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_insitchq IN crapcdb.insitchq%TYPE
                     ,pr_dtlibera IN crapcdb.dtlibera%TYPE
                     ) IS
      SELECT crapcdb.nrdconta
            ,crapcdb.nrctrlim
            ,crapcdb.dtlibera
            ,Sum(Nvl(crapcdb.vlcheque,0)) vlcheque
      FROM crapcdb crapcdb
            ,crapass
       WHERE crapass.cdcooper = crapcdb.cdcooper
         AND crapass.nrdconta = crapcdb.nrdconta
         AND crapcdb.cdcooper = pr_cdcooper
        AND crapcdb.insitchq = pr_insitchq
        AND crapcdb.dtlibera > pr_dtlibera
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
      GROUP BY crapcdb.nrdconta,crapcdb.nrctrlim,crapcdb.dtlibera
      ORDER BY crapcdb.dtlibera;

    -- Buscar dados da custória de cheques
    CURSOR cr_crapcst(pr_cdcooper  IN crapcob.cdcooper%TYPE         --> Código da cooperativa
                     ,pr_dtlibera  IN crapcst.dtmvtolt%TYPE         --> Data do movimento
                     ,pr_nrdconta  IN crapcst.nrdconta%TYPE) IS     --> Conta Corrente
      SELECT /*+ index (crapcst crapcst##crapcst2) */ crapcst.nrdconta
            ,crapcst.dtlibera
            ,crapcst.vlcheque
            ,Count(*)     OVER (PARTITION BY crapcst.nrdconta,crapcst.dtlibera) totreg
            ,Row_Number() OVER (PARTITION BY crapcst.nrdconta,crapcst.dtlibera ORDER BY crapcst.dtlibera ASC) seqreg
      FROM crapcst crapcst
      WHERE crapcst.cdcooper = pr_cdcooper
         AND crapcst.nrdconta = pr_nrdconta
         AND crapcst.dtlibera >= pr_dtlibera
         AND crapcst.dtdevolu IS NULL;
    rw_crapcst cr_crapcst%ROWTYPE;

    -- Buscar dados da custória de cheques
    CURSOR cr_crapcst_conta(pr_cdcooper  IN crapcob.cdcooper%TYPE         --> Código da cooperativa
                           ,pr_dtlibera  IN crapcst.dtmvtolt%TYPE         --> Data do movimento         
                           ) IS     
      SELECT crapcst.nrdconta
      FROM crapcst crapcst
            ,crapass 
       WHERE crapass.cdcooper = crapcst.cdcooper
         AND crapass.nrdconta = crapcst.nrdconta
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         AND crapcst.cdcooper = pr_cdcooper
         AND crapcst.dtlibera >= pr_dtlibera
         AND crapcst.dtdevolu IS NULL;

    -- Buscar dados saldo diário dos associados
    CURSOR cr_crapsda(pr_cdcooper IN craptab.cdcooper%TYPE--> Código da cooperativa
                     ,pr_dtmvtolt IN crapsda.dtmvtolt%TYPE--> Data do movimento
                     ) IS    
      SELECT crapsda.nrdconta
            ,crapsda.vlavlatr
            ,crapsda.vlavaliz
            ,crapsda.dtmvtolt
            ,crapsda.vlsddisp
            ,crapsda.vlsdchsl
            ,crapsda.vlsdbloq
            ,crapsda.vlsdblpr
            ,crapsda.vlsdblfp
            ,crapsda.vlsdindi
            ,crapsda.vllimcre
      FROM crapsda crapsda
          ,crapass ass
      WHERE crapsda.cdcooper = ass.cdcooper 
        AND crapsda.nrdconta = ass.nrdconta
        AND crapsda.cdcooper = pr_cdcooper
        AND ass.cdagenci     = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)    
        AND crapsda.dtmvtolt = pr_dtmvtolt;

    -- Buscar dados saldo diário dos associados para atualização de valores referentes aos avlistas
    CURSOR cr_crapsda_aval(pr_cdcooper IN craptab.cdcooper%TYPE--> Código da cooperativa
                          ,pr_dtmvtolt IN crapsda.dtmvtolt%TYPE--> Data do movimento
                          ,pr_nrdconta IN crapsda.nrdconta%TYPE--> Numero da conta
                     ) IS    
      SELECT crapsda.nrdconta
            ,crapsda.vlavlatr
            ,crapsda.vlavaliz
         FROM crapsda crapsda
      WHERE crapsda.cdcooper = pr_cdcooper
        AND crapsda.dtmvtolt = pr_dtmvtolt
        AND crapsda.nrdconta = pr_nrdconta;        

    -- Buscar dados do cadastro das linhas de desconto
    CURSOR cr_crapldc (pr_cdcooper IN craptab.cdcooper%TYPE) IS       --> Código da cooperativa
      SELECT cc.cddlinha
            ,cc.dsdlinha
            ,cc.tpdescto
      FROM crapldc cc
      WHERE cc.cdcooper = pr_cdcooper;

    -- Buscar dados dos planos de capitalização
    CURSOR cr_crappla(pr_cdcooper IN crappla.cdcooper%TYPE--> Código da cooperativa
                      ) IS      
      SELECT pla.nrdconta
            ,pla.vlprepla
      FROM crappla pla
          ,crapass ass 
      WHERE pla.cdcooper = ass.cdcooper 
        AND pla.nrdconta = ass.nrdconta
        AND pla.cdcooper = pr_cdcooper
        AND pla.tpdplano = 1
        AND pla.cdsitpla = 1
        AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci);

    -- Buscar dados do cadastro dos bloquetos de cobrança
    CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                      ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                      ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                      ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                      ,pr_nrdconta IN crapcob.nrdconta%TYPE
                      ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
      SELECT crapcob.indpagto
            ,crapcob.cdbandoc
            ,crapcob.nrdctabb
            ,crapcob.nrcnvcob
            ,crapcob.nrdconta
            ,crapcob.nrdocmto
            ,count(1) over(partition by crapcob.cdbandoc,crapcob.nrdctabb,crapcob.nrcnvcob,crapcob.nrdconta,crapcob.nrdocmto) qtdreg
      FROM crapcob crapcob
      WHERE crapcob.cdcooper = pr_cdcooper
      AND   crapcob.cdbandoc = pr_cdbandoc
      AND   crapcob.nrdctabb = pr_nrdctabb
      AND   crapcob.nrcnvcob = pr_nrcnvcob
      AND   crapcob.nrdconta = pr_nrdconta
      AND   crapcob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;

    -- Buscar dados dos tipos de aplicação cadastradas
    CURSOR cr_crapdtc(pr_cdcooper  IN crapcob.cdcooper%TYPE) IS     --> Código da cooperativa
      SELECT ct.tpaplrdc
            ,ct.tpaplica
      FROM crapdtc ct
      WHERE ct.cdcooper = pr_cdcooper;

    -- Buscar dados do saldo devedor atualizado
    CURSOR cr_crapsdv(pr_cdcooper IN craptab.cdcooper%TYPE         --> Código da cooperativa
                     ,pr_nrctaavd IN crapavl.nrctaavd%TYPE         --> Número do avalista
                     ,pr_dtmvtolt IN crapsda.dtmvtolt%TYPE         --> Data de movimento
                      ) IS

      SELECT cv.vldsaldo
            ,cv.cdcooper
            ,cv.nrdconta
            ,cv.nrctrato
       FROM crapsdv cv,
            crapavl cl
      WHERE cv.cdcooper = cl.cdcooper
        AND cv.nrdconta = cl.nrctaavd
        AND cv.nrctrato = cl.nrctravd
        AND cl.cdcooper = pr_cdcooper
        AND cl.nrdconta = pr_nrctaavd
        AND cv.dtmvtolt = pr_dtmvtolt;

    -- Buscar dados de emprestimos
    CURSOR cr_crapepre(pr_cdcooper IN craptab.cdcooper%TYPE         --> Código da cooperativa
                      ,pr_nrdconta IN crapsdv.nrdconta%TYPE         --> Número da conta
                      ,pr_nrctrato IN crapsdv.nrctrato%TYPE         --> Número do contrato
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS     --> Data do movimento atual
      SELECT crapepr.inprejuz
            ,crapepr.qtmesdec
            ,crapepr.qtprecal
            ,crapepr.dtdpagto
            ,crapepr.vlpreemp
      FROM crapepr crapepr
      WHERE crapepr.cdcooper = pr_cdcooper
        AND crapepr.nrdconta = pr_nrdconta
        AND crapepr.nrctremp = pr_nrctrato
        AND crapepr.inprejuz <> 1
        AND (crapepr.qtmesdec - crapepr.qtprecal) > 1
        AND to_char(pr_dtmvtolt, 'MM') <> to_char(crapepr.dtdpagto, 'MM');

    -- Buscar dados de devoluções
    CURSOR cr_crapneg(pr_cdcooper IN craplim.cdcooper%TYPE       --> Código da cooperativa
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE       --> Data do movimento
                     ) IS   --> Código da agência
      SELECT crapneg.nrdconta
            ,Count(*) conta
      FROM crapneg crapneg
          ,crapass crapass 
      WHERE crapneg.cdcooper  = crapass.cdcooper 
        AND crapneg.nrdconta  = crapass.nrdconta 
        AND crapneg.cdcooper  = pr_cdcooper
        AND crapass.cdagenci  = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
        AND crapneg.dtiniest >= pr_dtmvtolt - 180 /* Ultimos 6 meses */
      GROUP BY crapneg.nrdconta;

   -- Buscar cálculo prévio de aplicações
    CURSOR CR_TBCAPT_SALDO_APLICA(pr_cooper IN TBCAPT_SALDO_APLICA.cdcooper%TYPE) IS
      SELECT LPAD(CDCOOPER, 5, '0') CDCOOPER_IDX
            ,TO_CHAR(DTMVTOLT, 'DDMMRRRR') DTMVTOLT_IDX
            ,LPAD(NRDCONTA, 10, '0') NRDCONTA_IDX
            ,LPAD(NRAPLICA, 10, '0') NRAPLICA_IDX
            ,VLSALDO_BRUTO
            ,VLSALDO_CONCILIA
            ,CDCOOPER
            ,NRDCONTA
      FROM TBCAPT_SALDO_APLICA
      WHERE CDCOOPER = pr_cooper;
    
    -- type para utilizacao no bulk collect
    TYPE typ_tab_crapneg_carga IS TABLE OF cr_crapneg%ROWTYPE index by pls_integer;
    r_crapneg typ_tab_crapneg_carga;

    -- Buscar dados do cadastro das aplicações RDCA
    CURSOR cr_craprda(pr_cdcooper  IN crapcob.cdcooper%TYPE--> Código da cooperativa
                      ) IS    
        SELECT  rda.tpaplica
               ,rda.cdageass
               ,rda.nrdconta
               ,rda.nraplica
               ,rda.dtmvtolt
         FROM craprda rda
             ,crapass ass 
         WHERE rda.cdcooper = ass.cdcooper 
           AND rda.nrdconta = ass.nrdconta 
           AND rda.cdcooper = pr_cdcooper
           AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
           AND rda.insaqtot = 0;

    rw_craprda cr_craprda%ROWTYPE;

    TYPE typ_rec_craprda IS TABLE OF cr_craprda%ROWTYPE
      INDEX BY PLS_INTEGER;
    vr_tab_craprda_carga typ_rec_craprda;

    TYPE typ_tab_craprda IS TABLE OF typ_rec_craprda
      INDEX BY VARCHAR2(20); --cdagencia + nrdconta
    vr_tab_craprda typ_tab_craprda;

    -- Buscar dados de aplicações pessoa física
    CURSOR cr_crapttl(pr_cdcooper IN craplim.cdcooper%TYPE) IS       --> Código da cooperativa
      SELECT crapttl.nrdconta
            ,Nvl(Sum(Nvl(crapttl.vlsalari,0) +
             Nvl(crapttl.vldrendi##1,0) +
             Nvl(crapttl.vldrendi##2,0) +
             Nvl(crapttl.vldrendi##3,0) +
             Nvl(crapttl.vldrendi##4,0) +
             Nvl(crapttl.vldrendi##5,0) +
             Nvl(crapttl.vldrendi##6,0)),0) vlsalari
      FROM crapttl crapttl
            ,crapass
       WHERE crapttl.cdcooper  = crapass.cdcooper 
         AND crapttl.nrdconta  = crapass.nrdconta 
         AND crapttl.cdcooper = pr_cdcooper
         AND crapass.cdagenci  = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
      GROUP BY crapttl.nrdconta;

    -- Buscar dados das folhas de cheques
    CURSOR cr_crapfdc_carga (pr_cdcooper IN crapfdc.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapfdc.nrdconta
             ,crapfdc.incheque
             ,Count(1) quantidade
      FROM crapfdc crapfdc
            ,crapass
       WHERE crapfdc.cdcooper = crapass.cdcooper 
         AND crapfdc.nrdconta = crapass.nrdconta 
         AND crapfdc.cdcooper = pr_cdcooper
        AND crapfdc.incheque in (0,2)
        AND crapfdc.dtretchq IS NOT NULL
        AND (crapfdc.dtliqchq IS NULL OR crapfdc.dtliqchq >= pr_dtmvtolt)
         AND crapass.cdagenci  = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)        
      GROUP BY crapfdc.nrdconta,crapfdc.incheque;

    -- Buscar dados das folhas de cheques
    CURSOR cr_crapfdc_carga_5 (pr_cdcooper IN crapfdc.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapfdc.nrdconta
             ,crapfdc.incheque
             ,Count(1) quantidade
      FROM crapfdc crapfdc
            ,crapass      
       WHERE crapfdc.cdcooper = crapass.cdcooper 
         AND crapfdc.nrdconta = crapass.nrdconta 
         AND crapfdc.cdcooper = pr_cdcooper
        AND crapfdc.incheque = 5
        AND crapfdc.dtliqchq = pr_dtmvtolt
         AND crapass.cdagenci  = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)          
      GROUP BY crapfdc.nrdconta,crapfdc.incheque;

    -- type para utilizacao no bulk collect
    TYPE typ_tab_crapfdc_carga IS TABLE OF cr_crapfdc_carga%ROWTYPE index by pls_integer;
    r_crapfdc typ_tab_crapfdc_carga;

    --Selecionar as contas que possuem RPP
    CURSOR cr_craprpp_conta (pr_cdcooper IN craprpp.cdcooper%TYPE) IS
      SELECT craprpp.nrdconta
      FROM craprpp
            ,crapass  
       WHERE craprpp.cdcooper = crapass.cdcooper 
         AND craprpp.nrdconta = crapass.nrdconta 
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)         
         AND craprpp.cdcooper = pr_cdcooper;


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
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE; 
  
    --Cursor buscar a informação de todas as agências que o programa será executado.
    --Controlando também a re-execução de uma agência através do parametro pr_qterro
    CURSOR cr_crapage (pr_cdcooper IN crapass.cdcooper%TYPE
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


    -- Constantes da procedure crps445
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS445';  --> Nome do programa

    -- Variaveis locais da procedure crps445
    vr_exc_erro     EXCEPTION;                           --> Variável para exceção personalizada
    vr_cdcritic     VARCHAR2(400);                       --> Variável para armazenzar mensagens de crítica
    vr_dscritic     VARCHAR2(4000);                      --> Variável para armazenzar mensagens de crítica
    vr_dstextab     craptab.dstextab%TYPE;               --> Variavel para armazenar mensagem tabela generica
    vr_percirtab    craptab.dstextab%TYPE;               --> Variavel para armazenar mensagem tabela generica IR
    vr_dstextab_tx  craptab.dstextab%TYPE;               --> Variavel para armazenar mensagem tabela generica Taxa
    rw_crapdat      btch0001.cr_crapdat%ROWTYPE;         --> Buffer do cursor cr_crapdat (BTCH0001)
    vr_vlsldapl     NUMBER;                              --> Variável para armazenar valor de retorno de RDCA30
    vr_inusatab     BOOLEAN;                             --> Indicador taxa para rotina saldo_epr.p

    -- Alteração para execução simultanea
    vr_idxcrapepr         VARCHAR2(50) := 0;             --> Indexador de PL Table
    vr_icscdb             NUMBER;                        --> Variável para o indexador da Pl Table CRAPCDB
    vr_vlcheque           NUMBER(20,8) := 0;             --> Variável para a soma total dos cheques
    vr_idxctrl            NUMBER;                        --> Variável para controle de execução de PL Table
    vr_idxcon             NUMBER := 0;                   --> Variável para armazenar índice para PL Table
    vr_idxctrla           NUMBER;                        --> Variável para controle de execução de PL Table
    vr_idxcona            NUMBER := 0;                   --> Variável para armazenar índice para PL Table
    vr_dtinitax           DATE;                          --> Data início da taxa de poupança
    vr_dtfimtax           DATE;                          --> Data final da taxa de poupança
    idx                   NUMBER;
    vr_sldpresg_tmp       craplap.vllanmto%TYPE;         --> Valor saldo de resgate
    vr_dup_vlsdrdca       craplap.vllanmto%TYPE;         --> Acumulo do saldo da aplicacao RDCA

    -- Variáveis de retorno da procedure pc_busca_saldo_aplicacoes
    vr_vlsldtot  NUMBER;
    vr_vlsldrgt  NUMBER;

    --Indices para tabelas memoria
    vr_index_craplim  VARCHAR2(15);
    vr_index_craplim2 VARCHAR2(25);
    vr_index_crawepr  VARCHAR2(20);
    vr_index_crapfdc  VARCHAR2(15);
    vr_index_crapldc  VARCHAR2(10);
    vr_index_crapsdv  INTEGER;
    vr_index_crapsdv2 INTEGER;
    vr_index_crapsda2 NUMBER;
    vr_index_crapepr  PLS_INTEGER;
    vr_index_rdacta   VARCHAR2(20);
    vr_index_rda      PLS_INTEGER;
  vr_index_calc     PLS_INTEGER;
							 
    
    -- Retornar a existência do registro na Temp Table de cálculo antecipado
    FUNCTION fn_exists_tab_calc_aplicacao(vr_idx IN PLS_INTEGER) RETURN BOOLEAN IS
    BEGIN
      RETURN vr_tab_calc_aplicacao.exists(vr_idx);
    END;
    
    -- Carregar valores de saldo bruto e saldo liquido do cálculo antecipado
    PROCEDURE pc_carr_calc_aplicacao(pr_index_calc IN VARCHAR2
                                    ,pr_vlsrdca    OUT NUMBER
                                    ,pr_sldpresg   OUT NUMBER) IS
    BEGIN
      pr_vlsrdca := vr_tab_calc_aplicacao(pr_index_calc).VLSALDO_BRUTO;
      pr_sldpresg := vr_tab_calc_aplicacao(pr_index_calc).VLSALDO_CONCILIA;
    END;

    --Procedure para limpar os dados das tabelas de memoria
    PROCEDURE pc_limpa_tabela IS
    BEGIN
      --Tabelas de memoria para melhora performance
      vr_tab_crapdtc.DELETE;
      vr_tab_crappla.DELETE;
      vr_tab_crapldc.DELETE;
      vr_tab_craterr.DELETE;
      vr_tab_craplim.DELETE;
      vr_tab_craplim2.DELETE;
      vr_tab_crawepr.DELETE;
      vr_tab_crapfin.DELETE;
      vr_tab_craplcr.DELETE;
      vr_tab_crapsld.DELETE;
      vr_tab_crapsda.DELETE;
      vr_tab_crapneg.DELETE;
      vr_tab_crapcdb.DELETE;
      vr_tab_crapttl.DELETE;
      vr_tab_crapcst.DELETE;
      vr_tab_craptdb.DELETE;
      vr_tab_crapfdc.DELETE;
      vr_tab_craprpp.DELETE;
      vr_tab_craprda.DELETE;
      vr_tab_crapsdv.DELETE;
      vr_tab_crapsda2.DELETE;
    vr_tab_calc_aplicacao.delete;
  
      --vr_tab_crapscd.DELETE;
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
        vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps005.pc_limpa_tabela. '||sqlerrm;
        --Sair do programa
        RAISE vr_exc_erro;
    END;

    PROCEDURE PC_CRPS445_1(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_des_erro OUT VARCHAR2) AS
    /*.............................................................................

    Programa: PC_CRPS445_1                    Antigo: Fontes/crps445_1.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Evandro
    Data    : Julho/2011.                     Ultima atualizacao: 03/02/2014

    Dados referentes ao programa: Fonte extraido e adaptado para execucao em
                                  paralelo. Fonte original crps445.p.

    Frequencia: Sempre que for chamado.
    Objetivo  : Gerar planilha Operacoes de Credito -  Utilizado no CORVU
                Solicitacao 2 - Ordem 37.

    Alteracoes: 10/08/2011 - Retirado LOG de inicio de execucao, ficou no
                             programa principal (Evandro).

                13/09/2011 - Incluida informacoes para novos campos da tabela
                             crapsda (Elton).

                10/02/2012 - Utilizar variavel glb_flgresta para nao efetuar
                             controle de restart (David).

                16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

                30/10/2013 - Incluir chamada da procedure controla_imunidade
                             (Lucas R.)

                05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                            (Lucas R.)

                18/12/2013 - Removido linha crapscd.dscpfcgc = crapass.dscpfcgc
                            (Lucas R.)

                03/02/2014 - Remover a chamada da procedure "saldo_epr.p".
                            (James)
    .............................................................................*/

     BEGIN
       DECLARE
         vr_vlsdeved_limite_conta    NUMBER(20,8);                  --> Limite da conta
         vr_descricao_linha          VARCHAR2(400);                 --> Descrição da ocorrência por linha
         vr_descricao_finalidade     VARCHAR2(400);                 --> Descrição da finalidade por ocorrência
         vr_vlbloque                 NUMBER(20,8);                  --> Descritivo para bloqueio
         vr_nrctrato                 crapsdv.nrctrato%TYPE;         --> Número de contrato
         vr_tpdsaldo                 crapsdv.tpdsaldo%TYPE;         --> Tipo do saldo
         vr_cdlcremp                 crapsdv.cdlcremp%TYPE;         --> Documento empresa
         vr_tot_vlemprst             NUMBER(20,8);                  --> Valor total de emprestimo
         vr_tot_vldeschq             NUMBER(20,8);                  --> Valor total de sumarização
         vr_tot_vldestit             NUMBER(20,8);                  --> Valor total de títulos
         vr_tot_vllimutl             NUMBER(20,8);                  --> Valor total de uso
         vr_tot_vldclutl             NUMBER(20,8);                  --> Valor total de utilização
         vr_tot_vlsdrdca             NUMBER(20,8);                  --> Valor total do RDCA
         vr_tot_vlsdrdpp             NUMBER(20,8);                  --> Valor total de saldo RDPP
         vr_tot_vllimdsc             NUMBER(20,8);                  --> Valor total de IMD
         vr_tot_vllimtit             NUMBER(20,8);                  --> Valor total do limite
         vr_tot_vlprepla             NUMBER(20,8);                  --> Valor total do pre
         vr_tot_vlprerpp             NUMBER(20,8);                  --> Valor total do pre
         vr_tot_vlcrdsal             NUMBER(20,8);                  --> Valor total do RDSA
         vr_tot_qtchqliq             NUMBER;                        --> Valor total da quantidade de liquidação
         vr_tot_qtchqass             NUMBER;                        --> Valor total da quantidade por agência
         vr_tot_vltotpar             NUMBER(20,8);                  --> Valor total das parcelas
         vr_tot_vlopcdia             NUMBER(20,8);                  --> Valor total diário
         vr_tot_qtdevolu             NUMBER(20,8);                  --> Valor total de devolução
         vr_tot_vltotren             NUMBER(20,8);                  --> Valor total
         vr_tot_vlcheque             NUMBER(20,8);                  --> Valor total de cheques
         vr_vlsldrdc                 NUMBER(20,8);                  --> Valor do RDC
         vr_perirrgt                 NUMBER(15,2);                  --> Valor do período
         vr_vlrentot                 NUMBER(20,8);                  --> Valor total de rendimento
         vr_vldperda                 NUMBER(20,8);                  --> Valor da perda
         vr_vlsdrdca                 NUMBER(20,8);                  --> Valor do RDCA
         vr_txaplica                 NUMBER(20,8);                  --> Valor da taxa aplicada
         vr_vlsrdc30                 NUMBER(20,8);                  --> Valor do RDC30
          vr_vlsrdc60                 NUMBER(20,8);                  --> Valor do RDC60
         vr_vlsrdcpr                 NUMBER(20,8);                  --> Valor do RDC período
         vr_vlsrdcpo                 NUMBER(20,8);                  --> Valor do RDC
         vr_vlsdempr                 NUMBER(20,8);                  --> Valor do emprestimo
         vr_vlsdfina                 NUMBER(20,8);                  --> Valor do financiamento
         vr_dtpropos                 DATE;                          --> Data da proposta
         vr_dtefetiv                 DATE;                          --> Data efetivação
         vr_inprejuz                 crapsdv.inprejuz%TYPE;         --> Indicador do prejuizo
         vr_qtpreemp                 crapsdv.qtpreemp%TYPE;         --> Quantidade de emprestimo
         vr_vlemprst                 crapsdv.vlemprst%TYPE;         --> Valor do emprestimo
         vr_cdfinemp                 crapsdv.cdfinemp%TYPE;         --> Finalidade
         vr_dtdpagto                 crapsdv.dtdpagto%TYPE;         --> Data de pagamento
         vr_cdageepr                 crapsdv.cdageepr%TYPE;         --> Código da agência emprestimo
         vr_flgareal                 crapsdv.flgareal%TYPE;         --> Garantia real
         vr_dataano                  VARCHAR2(2);                   --> String com data e ano
         vr_vlsdeved                 NUMBER(20,8);                  --> Valor de saldo devedor
         vr_idxcraw                  VARCHAR2(20);                  --> Índice da tabela CRAWEPR
         vr_flagidx                  BOOLEAN;                       --> Flag para controle de acesso aos dados de PL Table
         vr_rd2_vlsdrdca             NUMBER(20,8);                  --> Valor de retorno do cálculo do RDCA2
         vr_sldpresg                 NUMBER(20,8);                  --> Valor disponível para resgate
         vr_dscritic                 VARCHAR2(400);                 --> Variável para armazenar a descrição da crítica
         vr_vlrdirrf                 NUMBER(20,8);                  --> Valor de retorno do cálculo do IRRF
         vr_rpp_vlsdrdpp             craprpp.vlsdrdpp%type := 0;    --> Valor do saldo da poupança programada
         vr_nrdconta                 crapass.nrdconta%TYPE;         --> Número da conta

         -- Variaveis de Excecao
         vr_continua                 EXCEPTION;                     --> Variável para controle da próxima iteração do LOOP
         vr_exc_erro                 EXCEPTION;                     --> Controle de exceção
         vr_proximo                  EXCEPTION;                     --> Controle de iteração do cursor
         vr_exc_pula                 EXCEPTION;                     --> Controle de iteração do cursor
         vr_exc_proxepr              EXCEPTION;                     --> Controle de iteração do cursor crapepr


         -- Busca registros de aplicações de captação
         CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
                          ,pr_cdagenci IN crapass.cdagenci%TYPE
                          ,pr_nrdconta IN craprac.nrdconta%TYPE) IS
           SELECT craprac.nraplica nraplica
                 ,craprac.cdprodut cdprodut
                 ,craprac.idblqrgt idblqrgt
                 ,crapcpc.idtippro idtippro
             FROM craprac
                 ,crapass
                 ,crapcpc
            WHERE craprac.cdcooper = pr_cdcooper
              AND craprac.nrdconta = pr_nrdconta
              AND crapass.cdagenci = pr_cdagenci
              AND crapass.cdcooper = craprac.cdcooper
              AND crapass.nrdconta = craprac.nrdconta
              AND crapcpc.cdprodut = craprac.cdprodut
              AND crapcpc.indplano = 0;                          -- Apenas Aplicações nâo programadas

         -- Buscar dados do cadastro de poupança programada
         CURSOR cr_craprpp(pr_cdcooper  IN crapcob.cdcooper%TYPE         --> Código da cooperativa
                          ,pr_nrdconta  IN craprpp.nrdconta%TYPE) IS     --> Número da conta
           SELECT ca.cdsitrpp
                 ,ca.vlprerpp
                 ,ca.nrctrrpp
                 ,ca.dtmvtolt
                 ,ca.rowid
           FROM craprpp ca
           WHERE ca.cdcooper = pr_cdcooper
             AND ca.nrdconta = pr_nrdconta;
--             AND ca.cdsitrpp <> 5; -- diferente vencida
         rw_craprpp cr_craprpp%rowtype;

         -- Procedure para inserir dados na tabela CRAPSDV
         PROCEDURE pc_atualiza_crapsdv(pr_cdcooper IN crapsdv.cdcooper%TYPE      --> Código da cooperativa
                                      ,pr_nrdconta IN crapsdv.nrdconta%TYPE      --> Número da conta
                                      ,pr_tpdsaldo IN crapsdv.tpdsaldo%TYPE      --> Tipo do saldo
                                      ,pr_nrctrato IN crapsdv.nrctrato%TYPE      --> Número do contrato
                                      ,pr_vldsaldo IN crapsdv.vldsaldo%TYPE      --> Valor do saldo
                                      ,pr_dtmvtolt IN crapsdv.dtmvtolt%TYPE      --> Data do movimento
                                      ,pr_dsdlinha IN crapsdv.dsdlinha%TYPE      --> Descrição da linha
                                      ,pr_dsfinali IN crapsdv.dsfinali%TYPE      --> Descrição finalidade
                                      ,pr_cdlcremp IN crapsdv.cdlcremp%TYPE      --> Lucro empresa
                                      ,pr_dtpropos IN crapsdv.dtpropos%TYPE      --> Data proposta
                                      ,pr_dtefetiv IN crapsdv.dtefetiv%TYPE      --> Data efetivação
                                      ,pr_inprejuz IN crapsdv.inprejuz%TYPE      --> Imposto previsto
                                      ,pr_qtpreemp IN crapsdv.qtpreemp%TYPE      --> Qunatidade de emprestimo
                                      ,pr_vlemprst IN crapsdv.vlemprst%TYPE      --> Valor empréstimo
                                      ,pr_cdfinemp IN crapsdv.cdfinemp%TYPE      --> Código financiamento
                                      ,pr_dtdpagto IN crapsdv.dtdpagto%TYPE      --> Data do pagamento
                                      ,pr_cdageepr IN crapsdv.cdageepr%TYPE      --> Código agência empregada
                                      ,pr_flgareal IN crapsdv.flgareal%TYPE      --> Controle do processo
                                      ,pr_des_erro OUT VARCHAR2) IS              --> Saída de erro
         BEGIN
           --Inicializar retorno erro
           pr_des_erro:= NULL;

           --Inserir na tabela de memoria para posterior uso pelo forall
           vr_index_crapsdv:= Nvl(vr_index_crapsdv,0) + 1;
           vr_tab_crapsdv(vr_index_crapsdv).cdcooper:= pr_cdcooper;
           vr_tab_crapsdv(vr_index_crapsdv).nrdconta:= pr_nrdconta;
           vr_tab_crapsdv(vr_index_crapsdv).tpdsaldo:= pr_tpdsaldo;
           vr_tab_crapsdv(vr_index_crapsdv).nrctrato:= pr_nrctrato;
           vr_tab_crapsdv(vr_index_crapsdv).vldsaldo:= pr_vldsaldo;
           vr_tab_crapsdv(vr_index_crapsdv).dtmvtolt:= pr_dtmvtolt;
           vr_tab_crapsdv(vr_index_crapsdv).dsdlinha:= pr_dsdlinha;
           vr_tab_crapsdv(vr_index_crapsdv).dsfinali:= pr_dsfinali;
           vr_tab_crapsdv(vr_index_crapsdv).cdlcremp:= pr_cdlcremp;
           vr_tab_crapsdv(vr_index_crapsdv).dtpropos:= pr_dtpropos;
           vr_tab_crapsdv(vr_index_crapsdv).dtefetiv:= pr_dtefetiv;
           vr_tab_crapsdv(vr_index_crapsdv).inprejuz:= pr_inprejuz;
           vr_tab_crapsdv(vr_index_crapsdv).qtpreemp:= pr_qtpreemp;
           vr_tab_crapsdv(vr_index_crapsdv).vlemprst:= pr_vlemprst;
           vr_tab_crapsdv(vr_index_crapsdv).cdfinemp:= pr_cdfinemp;
           vr_tab_crapsdv(vr_index_crapsdv).dtdpagto:= pr_dtdpagto;
           vr_tab_crapsdv(vr_index_crapsdv).cdageepr:= pr_cdageepr;
           vr_tab_crapsdv(vr_index_crapsdv).flgareal:= pr_flgareal;

         END;


         -- Procedure para executar processo para saldo maior que zero
         PROCEDURE pc_proc_saldo(pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                ,pr_tpctrlim  IN craplim.tpctrlim%TYPE      --> Tipo do contrato
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Número da conta
                                ,pr_nrctrlim  IN craplim.nrctrlim%TYPE      --> Numero do contrato
                                ,pr_des_erro  OUT VARCHAR2) IS              --> Erros do processo
         BEGIN
           DECLARE
             vr_des_erro      VARCHAR2(1000); --> Mensagem de erro
             vr_finaliza      EXCEPTION;      --> Controle de execução
           BEGIN

             --Inicializa retorno erro
             pr_des_erro:= NULL;

             --Montar indice para acesso tabela memória
             vr_index_craplim2:= lpad(pr_nrdconta, 10, '0') ||
                                 lpad(pr_tpctrlim, 05, '0') ||
                                 LPad(pr_nrctrlim, 10, '0');

             -- Verificar se existe registro especificado
             IF NOT vr_tab_craplim2.EXISTS(vr_index_craplim2) THEN
               vr_descricao_linha := '';
             ELSE
               -- Verifica se foram retornados registros
               vr_index_crapldc:= lpad(vr_tab_craplim2(vr_index_craplim2).cddlinha,5,'0') ||
                                  lpad(pr_tpctrlim,5,'0');
               IF vr_tab_crapldc.exists(vr_index_crapldc) THEN
                 vr_descricao_linha := vr_tab_crapldc(vr_index_crapldc);
                 vr_cdlcremp := vr_tab_craplim2(vr_index_craplim2).cddlinha;
               END IF;
               --Determinar a data da proposta
               vr_dtpropos := vr_tab_craplim2(vr_index_craplim2).dtpropos;
               --Determinar a data da efetivação
               vr_dtefetiv := vr_tab_craplim2(vr_index_craplim2).dtinivig;
             END IF;

             -- Desconto de cheques
             vr_tpdsaldo := pr_tpctrlim;
             vr_descricao_finalidade := ' ';

             -- Executar bloco de instruções para gravar em tabela
             pc_atualiza_crapsdv(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_tpdsaldo => vr_tpdsaldo
                                ,pr_nrctrato => pr_nrctrlim
                                ,pr_vldsaldo => vr_vlsdeved
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_dsdlinha => vr_descricao_linha
                                ,pr_dsfinali => vr_descricao_finalidade
                                ,pr_cdlcremp => vr_cdlcremp
                                ,pr_dtpropos => vr_dtpropos
                                ,pr_dtefetiv => vr_dtefetiv
                                ,pr_inprejuz => vr_inprejuz
                                ,pr_qtpreemp => vr_qtpreemp
                                ,pr_vlemprst => vr_vlemprst
                                ,pr_cdfinemp => vr_cdfinemp
                                ,pr_dtdpagto => vr_dtdpagto
                                ,pr_cdageepr => vr_cdageepr
                                ,pr_flgareal => vr_flgareal
                                ,pr_des_erro => vr_des_erro);

             -- Verifica se ocorreu erro na gravação
             IF vr_des_erro IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_finaliza;
             END IF;

             --> Realiza cálculo do saldo devedor
             IF pr_tpctrlim = 2 THEN
               vr_tot_vldeschq := Nvl(vr_tot_vldeschq,0) + Nvl(vr_vlsdeved,0);
             ELSIF pr_tpctrlim = 3 THEN
               vr_tot_vldestit := Nvl(vr_tot_vldestit,0) + Nvl(vr_vlsdeved,0);
             END IF;
           EXCEPTION
             WHEN vr_finaliza THEN
               pr_des_erro := vr_des_erro;
             WHEN others THEN
               pr_des_erro := 'Erro em pc_proc_saldo: ' || sqlerrm;
           END;
         END;

         -- Procedure para atualizar SDA
         PROCEDURE pc_atualiza_crapsda(pr_cdcooper IN craplim.cdcooper%TYPE              --> Código da cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da conta
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE              --> Data do movimento
                                      ,pr_inpessoa IN crapass.inpessoa%TYPE              --> Definição de pessoa
                                      ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE              --> Número de CPF/CNPJ
                                      ,pr_tot_vlemprst IN number
                                      ,pr_tot_vldeschq IN number
                                      ,pr_tot_vldestit IN number
                                      ,pr_tot_vllimutl IN number
                                      ,pr_tot_vldclutl IN number
                                      ,pr_tot_vlsdrdca IN number
                                      ,pr_tot_vlsdrdpp IN number
                                      ,pr_tot_vllimdsc IN number
                                      ,pr_tot_vllimtit IN number
                                      ,pr_tot_vlprepla IN number
                                      ,pr_tot_vlprerpp IN number
                                      ,pr_tot_vlcrdsal IN number
                                      ,pr_tot_qtchqliq IN number
                                      ,pr_tot_qtchqass IN number
                                      ,pr_tot_vltotpar IN number
                                      ,pr_tot_vlopcdia IN number
                                      ,pr_tot_qtdevolu IN number
                                      ,pr_tot_vltotren IN number
                                      ,pr_vlsrdc30     IN number
                                      ,pr_vlsrdc60     IN number
                                      ,pr_vlsrdcpr     IN number
                                      ,pr_vlsrdcpo     IN number
                                      ,pr_vlsdempr     IN number
                                      ,pr_vlsdfina     IN number
                                      ,pr_des_erro OUT VARCHAR2) IS                      --> Retorno de erro
         BEGIN
           DECLARE

             vr_exc_pula    EXCEPTION;         --> Controle de saída para a próxima iteração do LOOP
             rw_crapsda2    crapsda%ROWTYPE;   --> Tipo de registro da tabela

           BEGIN

             --Inicializar variavel de erro
             pr_des_erro:= NULL;

             -- Buscar planos de capitalização
             IF vr_tab_crappla.exists(pr_nrdconta) THEN
               vr_tot_vlprepla := vr_tab_crappla(pr_nrdconta);
             END IF;

             --Montar Indice para acessar tabela folha de cheques
             vr_index_crapfdc:= LPad(pr_nrdconta,10,'0')||LPad(5,5,'0');
             IF vr_tab_crapfdc.EXISTS(vr_index_crapfdc) THEN
               vr_tot_qtchqliq := nvl(vr_tot_qtchqliq, 0) + vr_tab_crapfdc(vr_index_crapfdc);
             END IF;

             --Montar Indice para acessar tabela folha de cheques
             vr_index_crapfdc:= LPad(pr_nrdconta,10,'0')||LPad(0,5,'0');
             IF vr_tab_crapfdc.EXISTS(vr_index_crapfdc) THEN
               vr_tot_qtchqass := nvl(vr_tot_qtchqass, 0) + vr_tab_crapfdc(vr_index_crapfdc);
             END IF;

             --Montar Indice para acessar tabela folha de cheques
             vr_index_crapfdc:= LPad(pr_nrdconta,10,'0')||LPad(2,5,'0');
             IF vr_tab_crapfdc.EXISTS(vr_index_crapfdc) THEN
               vr_tot_qtchqass := nvl(vr_tot_qtchqass, 0) + vr_tab_crapfdc(vr_index_crapfdc);
             END IF;

             -- Pesquisar registros de devoluções
             IF vr_tab_crapneg.EXISTS(pr_nrdconta) THEN
               vr_tot_qtdevolu := vr_tot_qtdevolu + vr_tab_crapneg(pr_nrdconta);
             END IF;

             -- Total de rendimentos do titular - pessoa fisica
             IF pr_inpessoa = 1 THEN
               --Verificar no vetor de memoria a soma dos salarios
               IF vr_tab_crapttl.EXISTS(pr_nrdconta) THEN
                 --Acumular total de rendimentos
                 vr_tot_vltotren := nvl(vr_tot_vltotren, 0) + Nvl(vr_tab_crapttl(pr_nrdconta),0);
               END IF;
             END IF;

             --Se Encontrou registro
             IF vr_tab_crapsda.EXISTS(pr_nrdconta) THEN

               --Montar indice para tabela
               vr_index_crapsda2:= Nvl(vr_index_crapsda2,0) + 1;
               vr_tab_crapsda2(vr_index_crapsda2).cdcooper:= pr_cdcooper;
               vr_tab_crapsda2(vr_index_crapsda2).nrdconta:= pr_nrdconta;
               vr_tab_crapsda2(vr_index_crapsda2).dtmvtolt:= pr_dtmvtolt;
               vr_tab_crapsda2(vr_index_crapsda2).vlsdeved:= Nvl(pr_tot_vlemprst,0);
               vr_tab_crapsda2(vr_index_crapsda2).vldeschq:= Nvl(pr_tot_vldeschq,0);
               vr_tab_crapsda2(vr_index_crapsda2).vldestit:= Nvl(pr_tot_vldestit,0);
               vr_tab_crapsda2(vr_index_crapsda2).vllimutl:= Nvl(pr_tot_vllimutl,0);
               vr_tab_crapsda2(vr_index_crapsda2).vladdutl:= Nvl(pr_tot_vldclutl,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsdrdca:= Nvl(pr_tot_vlsdrdca,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsdrdpp:= Nvl(pr_tot_vlsdrdpp,0);
               vr_tab_crapsda2(vr_index_crapsda2).vllimdsc:= Nvl(pr_tot_vllimdsc,0);
               vr_tab_crapsda2(vr_index_crapsda2).vllimtit:= Nvl(pr_tot_vllimtit,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlprepla:= Nvl(pr_tot_vlprepla,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlprerpp:= Nvl(pr_tot_vlprerpp,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlcrdsal:= Nvl(pr_tot_vlcrdsal,0);
               vr_tab_crapsda2(vr_index_crapsda2).qtchqliq:= Nvl(pr_tot_qtchqliq,0);
               vr_tab_crapsda2(vr_index_crapsda2).qtchqass:= Nvl(pr_tot_qtchqass,0);
               vr_tab_crapsda2(vr_index_crapsda2).vltotpar:= Nvl(pr_tot_vltotpar,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlopcdia:= Nvl(pr_tot_vlopcdia,0);
               vr_tab_crapsda2(vr_index_crapsda2).qtdevolu:= Nvl(pr_tot_qtdevolu,0);
               vr_tab_crapsda2(vr_index_crapsda2).vltotren:= Nvl(pr_tot_vltotren,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsrdc30:= Nvl(pr_vlsrdc30,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsrdc60:= Nvl(pr_vlsrdc60,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsrdcpr:= Nvl(pr_vlsrdcpr,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsrdcpo:= Nvl(pr_vlsrdcpo,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsdempr:= Nvl(pr_vlsdempr,0);
               vr_tab_crapsda2(vr_index_crapsda2).vlsdfina:= Nvl(pr_vlsdfina,0);


               rw_crapsda2.vlsddisp:= Nvl(vr_tab_crapsda(pr_nrdconta).vlsddisp,0);
               rw_crapsda2.vlsdchsl:= Nvl(vr_tab_crapsda(pr_nrdconta).vlsdchsl,0);
               rw_crapsda2.vlsdbloq:= Nvl(vr_tab_crapsda(pr_nrdconta).vlsdbloq,0);
               rw_crapsda2.vlsdblpr:= Nvl(vr_tab_crapsda(pr_nrdconta).vlsdblpr,0);
               rw_crapsda2.vlsdblfp:= Nvl(vr_tab_crapsda(pr_nrdconta).vlsdblfp,0);
               rw_crapsda2.vlsdindi:= Nvl(vr_tab_crapsda(pr_nrdconta).vlsdindi,0);
               rw_crapsda2.vllimcre:= Nvl(vr_tab_crapsda(pr_nrdconta).vllimcre,0);

               rw_crapsda2.vlsdeved:= Nvl(pr_tot_vlemprst,0);
               rw_crapsda2.vldeschq:= Nvl(pr_tot_vldeschq,0);
               rw_crapsda2.vllimutl:= Nvl(pr_tot_vllimutl,0);
               rw_crapsda2.vladdutl:= Nvl(pr_tot_vldclutl,0);
               rw_crapsda2.vlsdrdca:= Nvl(pr_tot_vlsdrdca,0);
               rw_crapsda2.vlsdrdpp:= Nvl(pr_tot_vlsdrdpp,0);
               rw_crapsda2.vllimdsc:= Nvl(pr_tot_vllimdsc,0);
               rw_crapsda2.vllimtit:= Nvl(pr_tot_vllimtit,0);
               rw_crapsda2.vldestit:= Nvl(pr_tot_vldestit,0);
               rw_crapsda2.vlprepla:= Nvl(pr_tot_vlprepla,0);
               rw_crapsda2.vlprerpp:= Nvl(pr_tot_vlprerpp,0);
               rw_crapsda2.vlcrdsal:= Nvl(pr_tot_vlcrdsal,0);
               rw_crapsda2.qtchqliq:= Nvl(pr_tot_qtchqliq,0);
               rw_crapsda2.qtchqass:= Nvl(pr_tot_qtchqass,0);

             END IF;

           EXCEPTION
             WHEN vr_exc_erro THEN
               --Retonar mensagem de erro
               pr_des_erro:= vr_dscritic;

             WHEN others THEN
               --Retonar mensagem de erro
               pr_des_erro:= 'Erro na rotina crps445.pc_atualiza_crapsda. '||sqlerrm;
           END;
         END; --pc_atualiza_crapsda

       -------------------------------------
       -- Inicio processamento PC_CRPS445_1
       -------------------------------------
       BEGIN

         -- Alterar module acrescentando action
         GENE0001.pc_informa_acesso(pr_module  => 'PC_'||vr_cdprogra
                                    ,pr_action => 'PC_CRPS445_1');

         -- Limpar erros anteriores
         vr_dscritic := '';

         vr_idxcrapepr := 0;
         vr_icscdb := 0;
         vr_vlcheque := 0;


         -- Busca dados das contas dos associados
         FOR rw_crapass IN cr_crapass_1(pr_cdcooper => pr_cdcooper) LOOP

           --Limpar Variaveis
           vr_tot_vlemprst := 0;
           vr_tot_vldeschq := 0;
           vr_tot_vldestit := 0;
           vr_tot_vllimutl := 0;
           vr_tot_vldclutl := 0;
           vr_tot_vlsdrdca := 0;
           vr_tot_vlsdrdpp := 0;
           vr_tot_vllimdsc := 0;
           vr_tot_vllimtit := 0;
           vr_tot_vlprepla := 0;
           vr_tot_vlprerpp := 0;
           vr_tot_vlcrdsal := 0;
           vr_tot_qtchqliq := 0;
           vr_tot_qtchqass := 0;
           vr_tot_vltotpar := 0;
           vr_tot_vlopcdia := 0;
           vr_tot_qtdevolu := 0;
           vr_tot_vltotren := 0;
           vr_vlsdfina := 0;
           vr_vlsdempr := 0;
           vr_vlsrdc30 := 0;
           vr_vlsrdc60 := 0;
           vr_vlsrdcpr := 0;
           vr_vlsrdcpo := 0;

           BEGIN
             -- Testar se conta existe na PL Table, se não existir vai para a próxima iteração
             IF NOT vr_tab_crapsld.EXISTS(rw_crapass.nrdconta) THEN
               RAISE vr_proximo;
             END IF;

             --Selecionar informacoes dos emprestimos
             IF vr_tab_crapepr.exists(rw_crapass.nrdconta) THEN
               FOR idx IN nvl(vr_tab_crapepr(rw_crapass.nrdconta).first,0)..nvl(vr_tab_crapepr(rw_crapass.nrdconta).last,-1) LOOP
                 rw_crapepr := vr_tab_crapepr(rw_crapass.nrdconta)(idx);

                 BEGIN

                   -- Teste com valores para determinar se vai para a próxima iteração
                   IF rw_crapepr.inliquid = 1 THEN  --Ja liquidado
                     --Em prejuizo
                     IF rw_crapepr.inprejuz = 1 THEN
                       --Valor do saldo do prejuizo negativo
                       IF rw_crapepr.vlsdprej <= 0 THEN
                         --Levantar Excecao
                         RAISE vr_exc_proxepr;
                       END IF;
                     ELSE
                       --Levantar Excecao
                       RAISE vr_exc_proxepr;
                     END IF;
                   END IF;

                   -- Limpando dados das variáveis
                   vr_vlsdeved := 0;
                   vr_dtpropos := NULL;
                   vr_dtefetiv := NULL;
                   vr_inprejuz := 0;
                   vr_qtpreemp := 0;
                   vr_vlemprst := 0;
                   vr_cdfinemp := 0;
                   vr_dtdpagto := NULL;
                   vr_cdageepr := 0;
                   vr_flgareal := 0;

                   -- Verifica mensal para saldo gerado pelo 78
                   IF to_number(to_char(rw_crapdat.dtmvtolt, 'MM')) <> to_number(to_char(rw_crapdat.dtmvtopr, 'MM')) THEN
                     vr_vlsdeved := rw_crapepr.vlsdeved;
                   ELSE
                     -- Saldo calculado pelo crps616.p/crps665.p
                     if rw_crapepr.inliquid = 0 then
                        vr_vlsdeved := rw_crapepr.vlsdevat;
                     else
                        vr_vlsdeved := 0;
                     end if;

  /*                   --Executar rotina calculo saldo emprestimos
                     EMPR0001.pc_calc_saldo_epr(pr_cdcooper => pr_cdcooper
                                               ,pr_rw_crapdat => rw_crapdat
                                               ,pr_cdprogra => vr_cdprogra
                                               ,pr_nrdconta => rw_crapepr.nrdconta
                                               ,pr_nrctremp => rw_crapepr.nrctremp
                                               ,pr_inusatab => vr_inusatab
                                               ,pr_vlsdeved => vr_vlsdeved
                                               ,pr_qtprecal => vr_qtprecal_retorno
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_des_erro => vr_dscritic);
                     --Se ocorreu erro
                     IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
                       vr_vlsdeved := 0;
                     END IF;*/
                   END IF;

                   -- Valida a incidencia de juros e o saldo devedor
                   IF rw_crapepr.inprejuz = 0 AND vr_vlsdeved <= 0 THEN
                     RAISE vr_exc_proxepr;
                   ELSE
                     IF rw_crapepr.inprejuz = 1 THEN
                       vr_vlsdeved := 0;
                     END IF;
                   END IF;

                   vr_descricao_linha := ' ';

                   -- Verifica se existe registros na PL Table para determinar descrição da linha
                   IF vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
                     vr_descricao_linha := vr_tab_craplcr(rw_crapepr.cdlcremp).dslcremp;
                   END IF;

                   vr_descricao_finalidade := ' ';
                   -- Verificar se existe finalidade
                   IF vr_tab_crapfin.EXISTS(rw_crapepr.cdfinemp) THEN
                     vr_descricao_finalidade := vr_tab_crapfin(rw_crapepr.cdfinemp);
                   END IF;

                   -- Verifica se existe registro na tabela auxiliar de empréstimos
                   vr_idxcraw := lpad(rw_crapepr.nrdconta, 10, '0') || lpad(rw_crapepr.nrctremp, 10, '0');

                   IF vr_tab_crawepr.EXISTS(vr_idxcraw) THEN
                     vr_dtpropos := vr_tab_crawepr(vr_idxcraw);
                   END IF;

                   -- Atribuição de valores
                   vr_tpdsaldo := 1;
                   vr_nrctrato := rw_crapepr.nrctremp;
                   vr_cdlcremp := rw_crapepr.cdlcremp;
                   vr_dtefetiv := rw_crapepr.dtmvtolt;
                   vr_inprejuz := rw_crapepr.inprejuz;
                   vr_qtpreemp := rw_crapepr.qtpreemp;
                   vr_vlemprst := rw_crapepr.vlemprst;
                   vr_cdfinemp := rw_crapepr.cdfinemp;
                   vr_dtdpagto := rw_crapepr.dtdpagto;
                   vr_cdageepr := rw_crapepr.cdagenci;

                   -- Valida se é alienação ou hipotéca
                   IF vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) AND
                     vr_tab_craplcr(rw_crapepr.cdlcremp).tpctrato IN (2, 3) THEN
                     vr_flgareal := 1;
                   END IF;

                   -- Executar bloco de instruções para gravar em tabela
                   pc_atualiza_crapsdv(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_tpdsaldo => vr_tpdsaldo
                                      ,pr_nrctrato => vr_nrctrato
                                      ,pr_vldsaldo => vr_vlsdeved
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dsdlinha => vr_descricao_linha
                                      ,pr_dsfinali => vr_descricao_finalidade
                                      ,pr_cdlcremp => vr_cdlcremp
                                      ,pr_dtpropos => vr_dtpropos
                                      ,pr_dtefetiv => vr_dtefetiv
                                      ,pr_inprejuz => vr_inprejuz
                                      ,pr_qtpreemp => vr_qtpreemp
                                      ,pr_vlemprst => vr_vlemprst
                                      ,pr_cdfinemp => vr_cdfinemp
                                      ,pr_dtdpagto => vr_dtdpagto
                                      ,pr_cdageepr => vr_cdageepr
                                      ,pr_flgareal => vr_flgareal
                                      ,pr_des_erro => vr_dscritic);

                   -- Verifica se ocorreram erros
                   IF vr_dscritic IS NOT NULL THEN
                     RAISE vr_exc_erro;
                   END IF;

                   -- Valida se é empréstimo ou financiamento
                   IF vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
                     --Uso do trim se faz necessário para retirar espacos em branco
                     IF Trim(vr_tab_craplcr(rw_crapepr.cdlcremp).dsoperac) = 'EMPRESTIMO' THEN
                       --Acumular saldo emprestimo
                       vr_vlsdempr := Nvl(vr_vlsdempr,0) + Nvl(vr_vlsdeved,0);
                     ELSE
                       --Acumular saldo Financiamento
                       vr_vlsdfina := Nvl(vr_vlsdfina,0) + Nvl(vr_vlsdeved,0);
                     END IF;
                   END IF;

                   -- Atribuição de valor total emprestimos
                   vr_tot_vlemprst := Nvl(vr_tot_vlemprst,0) + Nvl(vr_vlsdeved,0);

                   -- Total de prestacoes em aberto
                   vr_tot_vltotpar := Nvl(vr_tot_vltotpar,0) + Nvl(rw_crapepr.vlpreemp,0);
                   -- Total de operacoes contratadas no dia
                   IF rw_crapdat.dtmvtolt = rw_crapepr.dtmvtolt THEN
                     vr_tot_vlopcdia := Nvl(vr_tot_vlopcdia,0) + Nvl(rw_crapepr.vlemprst,0);
                   END IF;

                 EXCEPTION
                   WHEN vr_exc_erro THEN
                     pr_des_erro:= vr_dscritic;
                     --levantar Excecao
                     RAISE vr_exc_erro;
                   WHEN vr_exc_proxepr THEN
                     --Pular o registro
                     NULL;
                 END;
               END LOOP;
             END IF;

             /* DESCONTO DE CHEQUES */

             -- Limpar valores das variáveis envolvidas
             vr_vlsdeved := 0;
             vr_nrctrato := 0;
             vr_cdlcremp := 0;
             vr_dtpropos := NULL;
             vr_dtefetiv := NULL;
             vr_inprejuz := 0;
             vr_qtpreemp := 0;
             vr_vlemprst := 0;
             vr_cdfinemp := 0;
             vr_dtdpagto := NULL;
             vr_cdageepr := 0;
             vr_flgareal := 0;

             --Montar indice para encontrar limite
             vr_index_craplim := lpad(rw_crapass.nrdconta, 10, '0')||lpad(2, 5, '0');

             --Verificar se existe limite
             IF vr_tab_craplim.EXISTS(vr_index_craplim) THEN
               vr_tot_vllimdsc := vr_tab_craplim(vr_index_craplim).vllimite;
               vr_nrctrato := vr_tab_craplim(vr_index_craplim).nrctrlim;
               -- Total de operações contratadas no dia
               IF rw_crapdat.dtmvtolt = vr_tab_craplim(vr_index_craplim).dtpropos THEN
                 vr_tot_vlopcdia := Nvl(vr_tot_vlopcdia,0) + vr_tab_craplim(vr_index_craplim).vllimite;
               END IF;
               vr_flagidx:= TRUE;
             ELSE
               vr_flagidx:= FALSE;
             END IF;

             --Selecionar informacoes cheques contidos no bordero desconto cheques
             IF vr_tab_crapcdb.EXISTS(rw_crapass.nrdconta) THEN
               --Acumular saldo devedor
               vr_vlsdeved := Nvl(vr_vlsdeved,0) + Nvl(vr_tab_crapcdb(rw_crapass.nrdconta).vlcheque,0);
               IF vr_flagidx = FALSE THEN
                 vr_nrctrato := vr_tab_crapcdb(rw_crapass.nrdconta).nrctrlim;
               END IF;
             END IF;

             -- Validar se a soma dos cheques for maior que zero
             IF vr_vlsdeved > 0 THEN
               pc_proc_saldo (pr_cdcooper => pr_cdcooper
                             ,pr_tpctrlim => 2
                             ,pr_nrdconta => rw_crapass.nrdconta
                             ,pr_nrctrlim => vr_nrctrato
                             ,pr_des_erro => vr_dscritic);

               -- Se ocorreram erros
               IF vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro;
               END IF;
             END IF;

             /*  DESCONTO DE TITULOS */

             -- Limpar variáveis
             vr_vlsdeved := 0;
             vr_nrctrato := 0;
             vr_cdlcremp := 0;
             vr_dtpropos := NULL;
             vr_dtefetiv := NULL;

             --Montar indice para encontrar limite
             vr_index_craplim := lpad(rw_crapass.nrdconta, 10, '0')||lpad(3, 5, '0');

             --Verificar se existe limite
             IF vr_tab_craplim.EXISTS(vr_index_craplim) THEN
               vr_tot_vllimtit := vr_tab_craplim(vr_index_craplim).vllimite;
               vr_nrctrato := vr_tab_craplim(vr_index_craplim).nrctrlim;
               vr_flagidx:= TRUE;
             ELSE
               vr_flagidx:= FALSE;
             END IF;

             --Verificar se é uma das contas que possui tdb
             IF vr_tab_craptdb.EXISTS(rw_crapass.nrdconta) THEN
               --Selecionar informacoes dos descontos de titulos
               FOR rw_craptdb IN cr_craptdb (pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapass.nrdconta
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                 BEGIN
                   --Verificar bordero de cobranca
                   OPEN cr_crapcob(pr_cdcooper => pr_cdcooper
                                  ,pr_cdbandoc => rw_craptdb.cdbandoc
                                  ,pr_nrdctabb => rw_craptdb.nrdctabb
                                  ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                  ,pr_nrdconta => rw_craptdb.nrdconta
                                  ,pr_nrdocmto => rw_craptdb.nrdocmto);

                   --Posicionar no primeiro registro
                   FETCH cr_crapcob INTO rw_crapcob;
                   --Se Encontrou registro
                   IF cr_crapcob%FOUND THEN
                     --Se encontrou mais 1 registro
                     IF rw_crapcob.qtdreg > 1 THEN
                       -- Mensagem de aviso sobre a não localização ou localização duplicada de registros
                       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra ||
                                                                  ' --> Titulo em desconto nao encontrado no crapcob. ' ||
                                                                  'ROWID(craptdb): ' || rw_craptdb.rowid);
                       --Fechar cursor
                       CLOSE cr_crapcob;
                       --Levantar Excecao
                       RAISE vr_exc_pula;
                     END IF;
                   ELSE
                     -- Mensagem de aviso sobre a não localização ou localização duplicada de registros
                     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                               ,pr_ind_tipo_log => 2 -- Erro tratato
                                               ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra ||
                                                                 ' --> Titulo em desconto nao encontrado no crapcob. ' ||
                                                                 'ROWID(craptdb): ' || rw_craptdb.rowid);
                     --Fechar Cursor
                     CLOSE cr_crapcob;
                     --Levantar Excecao
                     RAISE vr_exc_pula;
                   END IF;
                   --Fechar Cursor
                   IF cr_crapcob%ISOPEN THEN
                     CLOSE cr_crapcob;
                   END IF;

                   -- Se foi pago via CAIXA, InternetBank ou TAA despreza, pois já esta pago, o dinheiro
                   -- já entrou para a cooperativa
                   IF rw_craptdb.insittit = 2 AND rw_crapcob.indpagto IN (1,3,4) THEN
                     --Pular registro
                     RAISE vr_exc_pula;
                   END IF;

                   --Acumular saldo devedor titulo
                   vr_vlsdeved := Nvl(vr_vlsdeved,0) + Nvl(rw_craptdb.vltitulo,0);

                   -- Se não encontrou registros de limite
                   IF vr_flagidx = FALSE THEN
                     vr_nrctrato := rw_craptdb.nrctrlim;
                   END IF;

                 EXCEPTION
                   WHEN vr_exc_erro THEN
                     pr_des_erro:= vr_dscritic;
                     --levantar Excecao
                     RAISE vr_exc_erro;
                   WHEN vr_exc_pula THEN
                     -- Irá apenas passar para a próxima iteração do laço
                     NULL;
                   WHEN others THEN
                     vr_dscritic := 'Erro: ' || sqlerrm;
                     RAISE vr_exc_erro;
                 END;
               END LOOP;  --rw_craptdb
             END IF;

             -- Total de operações contratadas no dia
             IF vr_flagidx THEN
               IF rw_crapdat.dtmvtolt = vr_tab_craplim(vr_index_craplim).dtpropos THEN
                 vr_tot_vlopcdia := Nvl(vr_tot_vlopcdia,0) + vr_tab_craplim(vr_index_craplim).vllimite;
               END IF;
             END IF;

             -- Verifica se valor de saldo é maior que zero
             IF vr_vlsdeved > 0 THEN
               pc_proc_saldo(pr_cdcooper => pr_cdcooper
                            ,pr_tpctrlim => 3
                            ,pr_nrdconta => rw_crapass.nrdconta
                            ,pr_nrctrlim => vr_nrctrato
                            ,pr_des_erro => vr_dscritic);
               -- Se ocorreram erros
               IF vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro;
               END IF;
             END IF;

             /* LIMITE DE CREDITO */

             --Valor bloqueado recebe valor saldo disponivel + valor cheque salario
             vr_vlbloque := vr_tab_crapsld(rw_crapass.nrdconta).vlsdchsl + vr_tab_crapsld(rw_crapass.nrdconta).vlsddisp;
             vr_dtpropos := NULL;
             vr_dtefetiv := NULL;

             --Valor bloqueado for negativo
             IF vr_vlbloque < 0 THEN

               --Montar indice para encontrar limite
               vr_index_craplim := lpad(rw_crapass.nrdconta, 10, '0')||lpad(1, 5, '0');

               --Verificar se existe limite
               IF vr_tab_craplim.EXISTS(vr_index_craplim) THEN
                 IF (vr_vlbloque * -1) > vr_tab_craplim(vr_index_craplim).vllimite THEN
                   vr_vlsdeved := vr_tab_craplim(vr_index_craplim).vllimite;
                 ELSE
                   vr_vlsdeved := vr_vlbloque * -1;
                 END IF;

                 -- Atribuição de valores para as variáveis
                 vr_descricao_linha := 'LIMITE DE CREDITO';
                 vr_tpdsaldo := 6;
                 vr_nrctrato := vr_tab_craplim(vr_index_craplim).nrctrlim;
                 vr_descricao_finalidade := ' ';
                 vr_cdlcremp := 0;
                 vr_dtpropos := vr_tab_craplim(vr_index_craplim).dtpropos;
                 vr_dtefetiv := vr_tab_craplim(vr_index_craplim).dtinivig;

                 -- Executar bloco de instruções para gravar em tabela
                 pc_atualiza_crapsdv(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_tpdsaldo => vr_tpdsaldo
                                    ,pr_nrctrato => vr_nrctrato
                                    ,pr_vldsaldo => vr_vlsdeved
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dsdlinha => vr_descricao_linha
                                    ,pr_dsfinali => vr_descricao_finalidade
                                    ,pr_cdlcremp => vr_cdlcremp
                                    ,pr_dtpropos => vr_dtpropos
                                    ,pr_dtefetiv => vr_dtefetiv
                                    ,pr_inprejuz => vr_inprejuz
                                    ,pr_qtpreemp => vr_qtpreemp
                                    ,pr_vlemprst => vr_vlemprst
                                    ,pr_cdfinemp => vr_cdfinemp
                                    ,pr_dtdpagto => vr_dtdpagto
                                    ,pr_cdageepr => vr_cdageepr
                                    ,pr_flgareal => vr_flgareal
                                    ,pr_des_erro => vr_dscritic);

                 -- Se ocorrer erro
                 IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_erro;
                 END IF;

                 --Acumular valor total limite utilizado
                 vr_tot_vllimutl := Nvl(vr_tot_vllimutl,0) + Nvl(vr_vlsdeved,0);

                 -- Total de operacoes contratadas no dia */
                 IF rw_crapdat.dtmvtolt = vr_tab_craplim(vr_index_craplim).dtpropos THEN
                   vr_tot_vlopcdia := Nvl(vr_tot_vlopcdia,0) + vr_tab_craplim(vr_index_craplim).vllimite;
                 END IF;

                 vr_flagidx:= TRUE;
               ELSE
                 vr_flagidx:= FALSE;
               END IF;
             END IF;

             /* ADIANTAMENTO A DEPOSITANTES */

             vr_vlsdeved := 0;
             vr_vlsdeved_limite_conta := 0;
             vr_dtpropos := NULL;
             vr_dtefetiv := NULL;

             --Se tiver limite
             IF rw_crapass.vllimcre > 0 THEN
               vr_vlsdeved_limite_conta := Nvl(vr_vlsdeved_limite_conta,0) + rw_crapass.vllimcre;
             END IF;

             -- Valor do bloqueio é o saldo disponivel + cheque salario
             vr_vlbloque := vr_tab_crapsld(rw_crapass.nrdconta).vlsddisp +
                            vr_tab_crapsld(rw_crapass.nrdconta).vlsdchsl;

             -- Verifica se o valor bloqueado é menor do que zero
             IF vr_vlbloque < 0 THEN
               IF (vr_vlbloque * -1) > vr_vlsdeved_limite_conta THEN
                 vr_vlsdeved := (vr_vlbloque * -1) - vr_vlsdeved_limite_conta;
               ELSE
                 vr_vlsdeved := 0;
               END IF;

               -- Verifica se o valor do saldo devedor é maior do que zero
               IF vr_vlsdeved > 0 THEN
                 vr_descricao_linha := 'ADIANTAMENTO A DEPOSITANTES';
                 vr_tpdsaldo := 5;
                 vr_nrctrato := rw_crapass.nrdconta;
                 vr_descricao_finalidade := ' ';
                 vr_cdlcremp := 0;

                 -- Executar bloco de instruções para gravar em tabela
                 pc_atualiza_crapsdv(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_tpdsaldo => vr_tpdsaldo
                                    ,pr_nrctrato => vr_nrctrato
                                    ,pr_vldsaldo => vr_vlsdeved
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dsdlinha => vr_descricao_linha
                                    ,pr_dsfinali => vr_descricao_finalidade
                                    ,pr_cdlcremp => vr_cdlcremp
                                    ,pr_dtpropos => vr_dtpropos
                                    ,pr_dtefetiv => vr_dtefetiv
                                    ,pr_inprejuz => vr_inprejuz
                                    ,pr_qtpreemp => vr_qtpreemp
                                    ,pr_vlemprst => vr_vlemprst
                                    ,pr_cdfinemp => vr_cdfinemp
                                    ,pr_dtdpagto => vr_dtdpagto
                                    ,pr_cdageepr => vr_cdageepr
                                    ,pr_flgareal => vr_flgareal
                                    ,pr_des_erro => vr_dscritic);

                 -- Se ocorrer erro
                 IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_erro;
                 END IF;

                 --Acumular valor adiantamento
                 vr_tot_vldclutl := Nvl(vr_tot_vldclutl,0) + vr_vlsdeved;
               END IF;
             END IF;

             vr_index_rdacta := lpad(rw_crapass.cdagenci, 10, '0')||
                                lpad(rw_crapass.nrdconta, 10, '0');

             IF vr_tab_craprda.exists(vr_index_rdacta) THEN
        -- Criar indice de busca pelo registro do calculo antecipado
               vr_index_calc := lpad(pr_cdcooper, 5, '0') ||
                                TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR') ||
                                lpad(rw_craprda.nrdconta, 10, '0') ||
                                lpad(rw_craprda.nraplica, 10, '0');
                    
                --Selecionar rendimentos das aplicacoes
               FOR idx IN nvl(vr_tab_craprda(vr_index_rdacta).first,0)..nvl(vr_tab_craprda(vr_index_rdacta).last,-1) LOOP
                 rw_craprda := vr_tab_craprda(vr_index_rdacta)(idx);
                 --Zerar variaveis
                 vr_vlsdrdca:= 0;
                 vr_vlsdeved:= 0;
                 vr_vlsldrdc:= 0;
                 vr_rd2_vlsdrdca:= 0;

                 BEGIN
                   IF rw_craprda.tpaplica = 3 THEN
                     -- Validar se o cálculo antecipado existe
                     IF NOT fn_exists_tab_calc_aplicacao(vr_index_calc) THEN
                       RAISE vr_continua;
                     END IF;                     
                                      
                     -- Carregar resultado do calculo antecipado
                     pc_carr_calc_aplicacao(pr_index_calc => vr_index_calc                         
                                           ,pr_vlsrdca    => vr_vlsdrdca                 
                                           ,pr_sldpresg   => vr_sldpresg_tmp);

                     -- Se o saldo RDCA for zero vai para o próximo registro
                     IF vr_vlsdrdca <= 0 THEN
                       RAISE vr_continua;
                     END IF;

                     -- Atribuição de valores para as variáveis
                     vr_descricao_linha := 'APLICACAO RDCA';
                     vr_vlsdeved := vr_vlsdrdca;
                     vr_vlsrdc30 := Nvl(vr_vlsrdc30,0) + Nvl(vr_vlsdrdca,0);
                   ELSIF rw_craprda.tpaplica = 5 THEN
                     -- Validar se o cálculo antecipado existe
                     IF NOT fn_exists_tab_calc_aplicacao(vr_index_calc) THEN
                       RAISE vr_continua;
                     END IF;

                     -- Carregar resultado do calculo antecipado
                     pc_carr_calc_aplicacao(pr_index_calc => vr_index_calc                       
                                           ,pr_vlsrdca    => vr_rd2_vlsdrdca
                                           ,pr_sldpresg   => vr_sldpresg);

                     -- Se o valor do RDCA estiver zerado vai para a próxima iteração do LOOP
                     IF vr_rd2_vlsdrdca <= 0 THEN
                       RAISE vr_continua;
                     END IF;

                     -- Atribuição de valores para as variáveis
                     vr_descricao_linha := 'APLICACAO RDCA60';
                     vr_vlsdeved := vr_rd2_vlsdrdca;
                     vr_vlsrdc60 := Nvl(vr_vlsrdc60,0) + Nvl(vr_rd2_vlsdrdca,0);
                   ELSE
                     -- Valida se retornou algum valor, gera crítica caso necessário
                     IF NOT vr_tab_crapdtc.exists(lpad(rw_craprda.tpaplica, 3, '0')) THEN
                       vr_cdcritic := 346;
                       vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                                     vr_dscritic || '. ' ||
                                                                     ' Conta/DV: ' || GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) ||
                                                                     ' - Nr. aplicação: ' || GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9'));
                     END IF;

                     -- Limpar valores
                     vr_tab_craterr.DELETE;
                     vr_vlsldrdc := 0;

                     -- Para RDCPRE
                     IF vr_tab_crapdtc(lpad(rw_craprda.tpaplica, 3, '0')).tpaplrdc = 1 THEN
                       vr_descricao_linha := 'APLICACAO RDCPRE';

                       -- Validar se o cálculo antecipado existe
                       IF NOT fn_exists_tab_calc_aplicacao(vr_index_calc) THEN
                         RAISE vr_continua;
                       END IF;
                     
                       -- Carregar resultado do calculo antecipado
                       pc_carr_calc_aplicacao(pr_index_calc => vr_index_calc
                                             ,pr_vlsrdca    => vr_vlsldrdc
                                             ,pr_sldpresg   => vr_sldpresg);

                       IF vr_vlsldrdc > 0 THEN
                         vr_vlsrdcpr := Nvl(vr_vlsrdcpr,0) + Nvl(vr_vlsldrdc,0);
                       END IF;
                     ELSIF vr_tab_crapdtc(lpad(rw_craprda.tpaplica, 3, '0')).tpaplrdc = 2 THEN -- RDCPOS
                       vr_descricao_linha := 'APLICACAO RDCPOS';

                       -- Validar se o cálculo antecipado existe
                       IF NOT fn_exists_tab_calc_aplicacao(vr_index_calc) THEN
                         RAISE vr_continua;
                       END IF;
                       
                       -- Carregar resultado do calculo antecipado
                       pc_carr_calc_aplicacao(pr_index_calc => vr_index_calc
                                             ,pr_vlsrdca    => vr_vlsldrdc
                                             ,pr_sldpresg   => vr_vlrentot);

                       IF vr_vlsldrdc > 0 THEN
                         vr_vlsrdcpo := Nvl(vr_vlsrdcpo,0) + Nvl(vr_vlsldrdc,0);
                       END IF;
                     END IF;

                     -- Caso valor seja menor ou igual a zero vai para a próxima iteração do LOOP
                     IF vr_vlsldrdc <= 0 THEN
                       RAISE vr_continua;
                     END IF;
                     --Valor saldo devedor recebe valor calculado rotina
                     vr_vlsdeved:= Nvl(vr_vlsldrdc,0);
                   END IF;

                   vr_tpdsaldo := 7;
                   vr_nrctrato := rw_craprda.nraplica;
                   vr_cdlcremp := 0;
                   vr_descricao_finalidade := ' ';
                   vr_tot_vlsdrdca := Nvl(vr_tot_vlsdrdca,0) + Nvl(vr_vlsdeved,0);
                   vr_dtpropos := rw_craprda.dtmvtolt;
                   vr_dtefetiv := rw_craprda.dtmvtolt;

                   -- Executar bloco de instruções para gravar em tabela
                   pc_atualiza_crapsdv(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_tpdsaldo => vr_tpdsaldo
                                      ,pr_nrctrato => vr_nrctrato
                                      ,pr_vldsaldo => vr_vlsdeved
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dsdlinha => vr_descricao_linha
                                      ,pr_dsfinali => vr_descricao_finalidade
                                      ,pr_cdlcremp => vr_cdlcremp
                                      ,pr_dtpropos => vr_dtpropos
                                      ,pr_dtefetiv => vr_dtefetiv
                                      ,pr_inprejuz => vr_inprejuz
                                      ,pr_qtpreemp => vr_qtpreemp
                                      ,pr_vlemprst => vr_vlemprst
                                      ,pr_cdfinemp => vr_cdfinemp
                                      ,pr_dtdpagto => vr_dtdpagto
                                      ,pr_cdageepr => vr_cdageepr
                                      ,pr_flgareal => vr_flgareal
                                      ,pr_des_erro => vr_dscritic);

                   -- Se ocorrer erro
                   IF vr_dscritic IS NOT NULL THEN
                     RAISE vr_exc_erro;
                   END IF;
                 EXCEPTION
                   WHEN vr_exc_erro THEN
                     pr_des_erro:= vr_dscritic;
                     --levantar Excecao
                     RAISE vr_exc_erro;
                   WHEN vr_continua THEN
                     -- Somente para passar para a próxima iteração do cursor
                     NULL;
                   WHEN others THEN
                     vr_dscritic := 'Erro ao processar loop craprda: ' || sqlerrm;
                     RAISE vr_exc_erro;
                 END;

               END LOOP;  --rw_craprda
             END IF;

             FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => rw_crapass.cdagenci
                                         ,pr_nrdconta => rw_crapass.nrdconta) LOOP
				-- Criar indice de busca pelo registro do calculo antecipado
               vr_index_calc := lpad(pr_cdcooper, 5, '0') ||
                                     TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR') ||
                                     lpad(rw_crapass.nrdconta, 10, '0') ||
                                     lpad(rw_craprac.nraplica, 10, '0');
                                     
               -- Validar se o cálculo antecipado existe
               IF NOT fn_exists_tab_calc_aplicacao(vr_index_calc) THEN
                 RAISE vr_exc_pula;
               END IF;                      
               
               -- Carregar resultado do calculo antecipado
               pc_carr_calc_aplicacao(pr_index_calc => vr_index_calc																 
                                     ,pr_vlsrdca    => vr_vlsldtot
                                     ,pr_sldpresg   => vr_vlsldrgt);

               IF rw_craprac.idtippro = 1 THEN  -- Pré
                    vr_vlsrdcpr := NVL(vr_vlsrdcpr, 0) + vr_vlsldtot;
                 ELSIF rw_craprac.idtippro = 2 THEN -- Pós
                    vr_vlsrdcpo := NVL(vr_vlsrdcpo,0) + vr_vlsldtot;
                 END IF;
             END LOOP;

             /* POUPANCA PROGRAMADA */
             IF vr_tab_craprpp.EXISTS(rw_crapass.nrdconta) THEN
               -- Busca registros para poupança programada
              FOR rw_craprpp IN cr_craprpp(pr_cdcooper => pr_cdcooper, pr_nrdconta => rw_crapass.nrdconta) LOOP
                 BEGIN
                   IF rw_craprpp.cdsitrpp = 1 THEN
                     vr_tot_vlprerpp := Nvl(vr_tot_vlprerpp,0) + rw_craprpp.vlprerpp;
                   END IF;

                 -- Criar indice de busca pelo registro do calculo antecipado
                   vr_index_calc := lpad(pr_cdcooper, 5, '0') ||					  
                                         TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR') ||
                                         lpad(rw_crapass.nrdconta, 10, '0') ||
                                         lpad(rw_craprpp.nrctrrpp, 10, '0');

                   -- Validar se o cálculo antecipado existe
                   IF NOT fn_exists_tab_calc_aplicacao(vr_index_calc) THEN
                     RAISE vr_exc_pula;
                   END IF;

                   -- Carregar resultado do calculo antecipado
                   pc_carr_calc_aplicacao(pr_index_calc => vr_index_calc
                                         ,pr_vlsrdca    => vr_ppbruto
                                         ,pr_sldpresg   => vr_rpp_vlsdrdpp);

                   -- Se o valor do saldo for menor ou igual a zero passa para a próxima iteração do laço
                   IF vr_rpp_vlsdrdpp <= 0 THEN
                     --Pular para proximo registro
                     RAISE vr_exc_pula;
                   END IF;

                   vr_vlsdeved := vr_rpp_vlsdrdpp;
                   vr_descricao_linha := 'POUPANCA PROGRAMADA';
                   vr_tpdsaldo := 8;
                   vr_nrctrato := rw_craprpp.nrctrrpp;
                   vr_descricao_finalidade := ' ';
                   vr_cdlcremp := 0;
                   vr_dtpropos := rw_craprpp.dtmvtolt;
                   vr_dtefetiv := rw_craprpp.dtmvtolt;

                   -- Executar bloco de instruções para gravar em tabela
                   pc_atualiza_crapsdv(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_tpdsaldo => vr_tpdsaldo
                                      ,pr_nrctrato => vr_nrctrato
                                      ,pr_vldsaldo => vr_vlsdeved
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dsdlinha => vr_descricao_linha
                                      ,pr_dsfinali => vr_descricao_finalidade
                                      ,pr_cdlcremp => vr_cdlcremp
                                      ,pr_dtpropos => vr_dtpropos
                                      ,pr_dtefetiv => vr_dtefetiv
                                      ,pr_inprejuz => vr_inprejuz
                                      ,pr_qtpreemp => vr_qtpreemp
                                      ,pr_vlemprst => vr_vlemprst
                                      ,pr_cdfinemp => vr_cdfinemp
                                      ,pr_dtdpagto => vr_dtdpagto
                                      ,pr_cdageepr => vr_cdageepr
                                      ,pr_flgareal => vr_flgareal
                                      ,pr_des_erro => vr_dscritic);

                   -- Se ocorrer erro
                   IF vr_dscritic IS NOT NULL THEN
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                   END IF;

                   vr_tot_vlsdrdpp := Nvl(vr_tot_vlsdrdpp,0) + vr_vlsdeved;
                 EXCEPTION
                   WHEN vr_exc_erro THEN
                     pr_des_erro:= vr_dscritic;
                     --levantar Excecao
                     RAISE vr_exc_erro;
                   WHEN vr_exc_pula THEN
                     NULL;
                   WHEN OTHERS THEN
                     vr_dscritic:= 'Erro ao processar loop craprpp. '||SQLERRM;
                     RAISE vr_exc_erro;
                 END;
               END LOOP; --rw_craprpp
             END IF;

             -- Atualizar SDA
             pc_atualiza_crapsda(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_crapass.nrdconta
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_inpessoa => rw_crapass.inpessoa
                                ,pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                ,pr_tot_vlemprst => vr_tot_vlemprst
                                ,pr_tot_vldeschq => vr_tot_vldeschq
                                ,pr_tot_vldestit => vr_tot_vldestit
                                ,pr_tot_vllimutl => vr_tot_vllimutl
                                ,pr_tot_vldclutl => vr_tot_vldclutl
                                ,pr_tot_vlsdrdca => vr_tot_vlsdrdca
                                ,pr_tot_vlsdrdpp => vr_tot_vlsdrdpp
                                ,pr_tot_vllimdsc => vr_tot_vllimdsc
                                ,pr_tot_vllimtit => vr_tot_vllimtit
                                ,pr_tot_vlprepla => vr_tot_vlprepla
                                ,pr_tot_vlprerpp => vr_tot_vlprerpp
                                ,pr_tot_vlcrdsal => vr_tot_vlcrdsal
                                ,pr_tot_qtchqliq => vr_tot_qtchqliq
                                ,pr_tot_qtchqass => vr_tot_qtchqass
                                ,pr_tot_vltotpar => vr_tot_vltotpar
                                ,pr_tot_vlopcdia => vr_tot_vlopcdia
                                ,pr_tot_qtdevolu => vr_tot_qtdevolu
                                ,pr_tot_vltotren => vr_tot_vltotren
                                ,pr_vlsrdc30     => vr_vlsrdc30
                                ,pr_vlsrdc60     => vr_vlsrdc60
                                ,pr_vlsrdcpr     => vr_vlsrdcpr
                                ,pr_vlsrdcpo     => vr_vlsrdcpo
                                ,pr_vlsdempr     => vr_vlsdempr
                                ,pr_vlsdfina     => vr_vlsdfina
                                ,pr_des_erro     => vr_dscritic);

             --Se ocorreu erro
             IF vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_erro;
             END IF;

             --Limpar Variaveis
             vr_tot_vlemprst := 0;
             vr_tot_vldeschq := 0;
             vr_tot_vldestit := 0;
             vr_tot_vllimutl := 0;
             vr_tot_vldclutl := 0;
             vr_tot_vlsdrdca := 0;
             vr_tot_vlsdrdpp := 0;
             vr_tot_vllimdsc := 0;
             vr_tot_vllimtit := 0;
             vr_tot_vlprepla := 0;
             vr_tot_vlprerpp := 0;
             vr_tot_vlcrdsal := 0;
             vr_tot_qtchqliq := 0;
             vr_tot_qtchqass := 0;
             vr_tot_vltotpar := 0;
             vr_tot_vlopcdia := 0;
             vr_tot_qtdevolu := 0;
             vr_tot_vltotren := 0;
             vr_vlsdfina := 0;
             vr_vlsdempr := 0;
             vr_vlsrdc30 := 0;
             vr_vlsrdc60 := 0;
             vr_vlsrdcpr := 0;
             vr_vlsrdcpo := 0;

             /*  CUSTODIA */
             vr_tot_vlcheque := 0;

             --Verificar se é uma conta que possui custodia de cheques
             IF vr_tab_crapcst.EXISTS(rw_crapass.nrdconta) THEN
               --Selecionar informacoes de custodia de cheques
               FOR rw_crapcst IN cr_crapcst (pr_cdcooper => pr_cdcooper
                                            ,pr_dtlibera => rw_crapdat.dtmvtolt
                                            ,pr_nrdconta => rw_crapass.nrdconta) LOOP

                 -- Sumarizar valor de cheques
                 vr_tot_vlcheque := Nvl(vr_tot_vlcheque,0) + rw_crapcst.vlcheque;

                 --verificar se é o ultimo registro da data
                 IF rw_crapcst.seqreg = rw_crapcst.totreg THEN

                   vr_dataano := to_char(rw_crapcst.dtlibera, 'RR');
                   vr_nrdconta := rw_crapass.nrdconta;
                   vr_tpdsaldo := 9;
                   vr_nrctrato := to_number(to_char(rw_crapcst.dtlibera, 'RRMMDD'));
                   vr_vlsdeved := vr_tot_vlcheque;
                   vr_descricao_linha := 'CUSTODIA';
                   vr_descricao_finalidade := ' ';
                   vr_cdlcremp := 0;
                   vr_dtpropos := NULL;
                   vr_dtefetiv := rw_crapcst.dtlibera;
                   vr_inprejuz := 0;
                   vr_qtpreemp := 0;
                   vr_vlemprst := 0;
                   vr_cdfinemp := 0;
                   vr_dtdpagto := NULL;
                   vr_cdageepr := 0;
                   vr_flgareal := 0;

                   -- Executar bloco de instruções para gravar em tabela
                   pc_atualiza_crapsdv(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_tpdsaldo => vr_tpdsaldo
                                      ,pr_nrctrato => vr_nrctrato
                                      ,pr_vldsaldo => vr_vlsdeved
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dsdlinha => vr_descricao_linha
                                      ,pr_dsfinali => vr_descricao_finalidade
                                      ,pr_cdlcremp => vr_cdlcremp
                                      ,pr_dtpropos => vr_dtpropos
                                      ,pr_dtefetiv => vr_dtefetiv
                                      ,pr_inprejuz => vr_inprejuz
                                      ,pr_qtpreemp => vr_qtpreemp
                                      ,pr_vlemprst => vr_vlemprst
                                      ,pr_cdfinemp => vr_cdfinemp
                                      ,pr_dtdpagto => vr_dtdpagto
                                      ,pr_cdageepr => vr_cdageepr
                                      ,pr_flgareal => vr_flgareal
                                      ,pr_des_erro => vr_dscritic);
                   -- Se ocorrer erro
                   IF vr_dscritic IS NOT NULL THEN
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                   END IF;

                   -- Zerar valores sumarizados de cheques
                   vr_tot_vlcheque := 0;
                 END IF;
               END LOOP; --cr_crapcst
             END IF;
           EXCEPTION
             WHEN vr_exc_erro THEN
               pr_des_erro:= vr_dscritic;
               --levantar Excecao
               RAISE vr_exc_erro;
             WHEN vr_proximo THEN
               -- Somente para passar para a próxima iteração do cursor
               NULL;
             WHEN others THEN
               vr_dscritic := 'Erro processando cursor crapass. ' || sqlerrm;
               RAISE vr_exc_erro;
           END;
         END LOOP; --cr_crapass

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro := vr_dscritic;
         WHEN others THEN
           pr_des_erro := 'Erro: ' || vr_dscritic || ' - ' || sqlerrm;
       END;
     END PC_CRPS445_1;

     PROCEDURE PC_CRPS445_2(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_des_erro OUT VARCHAR2) AS
     /*.............................................................................

     Programa: PC_CRPS445_2                    Antigo: Fontes/crps445_2.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Evandro
     Data    : Julho/2011.                     Ultima atualizacao: 10/02/2012

     Dados referentes ao programa: Fonte extraido e adaptado para execucao em
                                   paralelo. Fonte original crps445.p.

     Frequencia: Sempre que for chamado.
     Objetivo  : Gerar planilha Operacoes de Credito -  Utilizado no CORVU
                 Solicitacao 2 - Ordem 37.

     Alteracoes: 10/08/2011 - Retirado LOG de inicio de execucao, ficou no
                              programa principal (Evandro).

                 10/02/2012 - Utilizar variavel glb_flgresta para nao efetuar
                              controle de restart (David).

     ............................................................................. */

     BEGIN
       DECLARE
         vr_tot_vlavaliz    NUMBER(20,8);                  --> valor total realizado
         vr_tot_vlavlatr    NUMBER(20,8);                  --> valor total calculado
         vr_proximo         EXCEPTION;                     --> Variável para controle de interrupção da iteração do LOOP

       BEGIN

         -- Alterar module acrescentando action
         GENE0001.pc_informa_acesso(pr_module  => 'PC_'||vr_cdprogra
                                    ,pr_action => 'PC_CRPS445_2');

         --Inicializar variavel erro
         vr_dscritic:= NULL;

         --Zerar variaveis
         vr_idxctrl := 0;
         vr_idxcon := 0;
         vr_idxctrla := 0;
         vr_idxcona := 0;

         -- Busca dados das contas dos associados
         FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP

           -- Verificar se o registro marcador existe
           --IF vr_tab_crapsda.exists(rw_crapass.nrdconta) THEN
           FOR rw_crapsda IN cr_crapsda_aval(pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_nrdconta => rw_crapass.nrdconta) LOOP
             -- Zerar valores de variáveis
             vr_tot_vlavaliz := 0;
             vr_tot_vlavlatr := 0;

             --Selecionar informacoes dos avalistas e informacoes dos saldos devedores dos emprestimos
             FOR rw_crapsdv IN cr_crapsdv (pr_cdcooper => pr_cdcooper
                                          ,pr_nrctaavd => rw_crapass.nrdconta
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt/*vr_tab_crapsda(rw_crapass.nrdconta).dtmvtolt*/) LOOP
               
                
               --Acumular total avalista
               vr_tot_vlavaliz := Nvl(vr_tot_vlavaliz,0) + rw_crapsdv.vldsaldo;
               -- Localizar dados de emprétimos
               FOR rw_crapepr IN cr_crapepre(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapsdv.nrdconta
                                            ,pr_nrctrato => rw_crapsdv.nrctrato
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                 BEGIN
                   -- Desconsiderar contratos em prejuízo
                   IF rw_crapepr.inprejuz = 1 THEN
                     RAISE vr_proximo;
                   END IF;

                   -- Verificar se empréstimo esta atrasado
                   IF (rw_crapepr.qtmesdec - rw_crapepr.qtprecal) <= 1 THEN
                     RAISE vr_proximo;
                   END IF;

                   -- Desconsiderar se pagto vai ocorrer no mês
                   IF to_char(rw_crapdat.dtmvtolt, 'MM') = to_char(rw_crapepr.dtdpagto, 'MM') THEN
                     RAISE vr_proximo;
                   END IF;

                   vr_tot_vlavlatr := vr_tot_vlavlatr + TRUNC(rw_crapepr.vlpreemp * (rw_crapepr.qtmesdec - rw_crapepr.qtprecal), 2);
                 EXCEPTION
                   WHEN vr_proximo THEN
                   -- Somente vai para a próxima iteração do LOOP
                   NULL;
                 END;
               END LOOP;  --rw_crapepr
             END LOOP; --rw_crapsdv

             -- Atualizar tabela SDA
             IF (vr_tot_vlavlatr <> 0) OR (vr_tot_vlavaliz <> 0) THEN
               BEGIN
                 UPDATE crapsda SET crapsda.vlavlatr = vr_tot_vlavlatr
                                   ,crapsda.vlavaliz = vr_tot_vlavaliz
                 WHERE crapsda.cdcooper = pr_cdcooper
                   AND crapsda.nrdconta = rw_crapass.nrdconta
                   AND crapsda.dtmvtolt = rw_crapdat.dtmvtolt/*vr_tab_crapsda(rw_crapass.nrdconta).dtmvtolt*/;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic:= 'Erro ao atualizar tabela crapsda. Rotina: pc_crps445_2. '||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             END IF;
           END LOOP;--END IF;  --vr_tab_crapsda.exists
         END LOOP; --rw_crapass
       EXCEPTION
         WHEN vr_exc_erro THEN
           --Retornar mensagem erro
           pr_des_erro:= vr_dscritic;
         WHEN others THEN
           --Retornar mensagem erro
           pr_des_erro:= 'Erro processando rotina crps445.pc_crps445_2. '||sqlerrm;
       END;
     END PC_CRPS445_2;

     -- Subprocedure para execução das SubRotinas
     PROCEDURE pc_sub_rotinas(pr_des_erro OUT VARCHAR2) IS       --> Erros no processo
     BEGIN
       DECLARE
         vr_exe_erro     EXCEPTION;                    --> Variável para controle de exceção
         vr_erros        EXCEPTION;                    --> Variável para controle de exceção
         vr_cont         INTEGER;
       BEGIN
         -- Alterar module acrescentando action
         GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                    ,pr_action => 'pc_sub_rotinas');
         --Inicializar mensagem erro
         pr_des_erro:= NULL;
    
    -- Carga de temporary table
         FOR rw_TBCAPT_SALDO_APLICA IN CR_TBCAPT_SALDO_APLICA(pr_cdcooper) LOOP
           vr_index_calc := rw_TBCAPT_SALDO_APLICA.Cdcooper_Idx || 
                            rw_TBCAPT_SALDO_APLICA.Dtmvtolt_Idx ||
                            rw_TBCAPT_SALDO_APLICA.Nrdconta_Idx ||
                            rw_TBCAPT_SALDO_APLICA.Nraplica_Idx;
         
           vr_tab_calc_aplicacao(vr_index_calc).VLSALDO_BRUTO := rw_TBCAPT_SALDO_APLICA.VLSALDO_BRUTO;
           vr_tab_calc_aplicacao(vr_index_calc).VLSALDO_CONCILIA := rw_TBCAPT_SALDO_APLICA.VLSALDO_CONCILIA;
           vr_tab_calc_aplicacao(vr_index_calc).CDCOOPER := rw_TBCAPT_SALDO_APLICA.CDCOOPER;
           vr_tab_calc_aplicacao(vr_index_calc).NRDCONTA := rw_TBCAPT_SALDO_APLICA.NRDCONTA;
         END LOOP;
    

         -- Executa processo do programa 1
         pc_crps445_1 (pr_cdcooper => pr_cdcooper
                      ,pr_des_erro => vr_dscritic);

     -- Remover temporary table após utilização
         vr_tab_calc_aplicacao.delete;
     
         -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
         GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                    ,pr_action => 'pc_sub_rotinas');

         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_erro;
         END IF;
         vr_index_crapsdv := vr_tab_crapsdv.first; --primeiro registro

        --varre pl/table
        WHILE vr_index_crapsdv IS NOT NULL LOOP
           vr_index_crapsdv2:= Nvl(vr_index_crapsdv2,0) + 1;
           vr_tab_crapsdv2(vr_index_crapsdv2).cdcooper:= vr_tab_crapsdv(vr_index_crapsdv).cdcooper;
           vr_tab_crapsdv2(vr_index_crapsdv2).nrdconta:= vr_tab_crapsdv(vr_index_crapsdv).nrdconta;
           vr_tab_crapsdv2(vr_index_crapsdv2).tpdsaldo:= vr_tab_crapsdv(vr_index_crapsdv).tpdsaldo;
           vr_tab_crapsdv2(vr_index_crapsdv2).nrctrato:= vr_tab_crapsdv(vr_index_crapsdv).nrctrato;
           vr_tab_crapsdv2(vr_index_crapsdv2).vldsaldo:= vr_tab_crapsdv(vr_index_crapsdv).vldsaldo;
           vr_tab_crapsdv2(vr_index_crapsdv2).dtmvtolt:= vr_tab_crapsdv(vr_index_crapsdv).dtmvtolt;
           vr_tab_crapsdv2(vr_index_crapsdv2).dsdlinha:= vr_tab_crapsdv(vr_index_crapsdv).dsdlinha;
           vr_tab_crapsdv2(vr_index_crapsdv2).dsfinali:= vr_tab_crapsdv(vr_index_crapsdv).dsfinali;
           vr_tab_crapsdv2(vr_index_crapsdv2).cdlcremp:= vr_tab_crapsdv(vr_index_crapsdv).cdlcremp;
           vr_tab_crapsdv2(vr_index_crapsdv2).dtpropos:= vr_tab_crapsdv(vr_index_crapsdv).dtpropos;
           vr_tab_crapsdv2(vr_index_crapsdv2).dtefetiv:= vr_tab_crapsdv(vr_index_crapsdv).dtefetiv;
           vr_tab_crapsdv2(vr_index_crapsdv2).inprejuz:= vr_tab_crapsdv(vr_index_crapsdv).inprejuz;
           vr_tab_crapsdv2(vr_index_crapsdv2).qtpreemp:= vr_tab_crapsdv(vr_index_crapsdv).qtpreemp;
           vr_tab_crapsdv2(vr_index_crapsdv2).vlemprst:= vr_tab_crapsdv(vr_index_crapsdv).vlemprst;
           vr_tab_crapsdv2(vr_index_crapsdv2).cdfinemp:= vr_tab_crapsdv(vr_index_crapsdv).cdfinemp;
           vr_tab_crapsdv2(vr_index_crapsdv2).dtdpagto:= vr_tab_crapsdv(vr_index_crapsdv).dtdpagto;
           vr_tab_crapsdv2(vr_index_crapsdv2).cdageepr:= vr_tab_crapsdv(vr_index_crapsdv).cdageepr;
           vr_tab_crapsdv2(vr_index_crapsdv2).flgareal:= vr_tab_crapsdv(vr_index_crapsdv).flgareal;
           vr_cont := nvl(vr_cont,0) +1; -- contador para auxiliar na perfomance
           
           IF vr_cont = 30000 THEN -- a cada 30000 registros, eh atualizado a crapsdv
             vr_cont := 0; -- zera contador
             vr_index_crapsdv2 :=0; --zera indice auxiliar

             --Atualizar informacoes da crapsdv
             BEGIN
               FORALL idx IN INDICES OF vr_tab_crapsdv2 SAVE EXCEPTIONS
                 INSERT INTO crapsdv (cdcooper
                                    ,nrdconta
                                    ,tpdsaldo
                                    ,nrctrato
                                    ,vldsaldo
                                    ,dtmvtolt
                                    ,dsdlinha
                                    ,dsfinali
                                    ,cdlcremp
                                    ,dtpropos
                                    ,dtefetiv
                                    ,inprejuz
                                    ,qtpreemp
                                    ,vlemprst
                                    ,cdfinemp
                                    ,dtdpagto
                                    ,cdageepr
                                    ,flgareal)
                   VALUES          (vr_tab_crapsdv2(idx).cdcooper
                                   ,vr_tab_crapsdv2(idx).nrdconta
                                   ,vr_tab_crapsdv2(idx).tpdsaldo
                                   ,vr_tab_crapsdv2(idx).nrctrato
                                   ,vr_tab_crapsdv2(idx).vldsaldo
                                   ,vr_tab_crapsdv2(idx).dtmvtolt
                                   ,vr_tab_crapsdv2(idx).dsdlinha
                                   ,vr_tab_crapsdv2(idx).dsfinali
                                   ,vr_tab_crapsdv2(idx).cdlcremp
                                   ,vr_tab_crapsdv2(idx).dtpropos
                                   ,vr_tab_crapsdv2(idx).dtefetiv
                                   ,vr_tab_crapsdv2(idx).inprejuz
                                   ,vr_tab_crapsdv2(idx).qtpreemp
                                   ,vr_tab_crapsdv2(idx).vlemprst
                                   ,vr_tab_crapsdv2(idx).cdfinemp
                                   ,vr_tab_crapsdv2(idx).dtdpagto
                                   ,vr_tab_crapsdv2(idx).cdageepr
                                   ,vr_tab_crapsdv2(idx).flgareal);
             EXCEPTION
                 WHEN others THEN
                 -- Gerar erro
                   vr_dscritic := 'Erro ao inserir na tabela crapsdv. '||
                                  SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
                  RAISE vr_exc_erro;
             END;
             vr_tab_crapsdv2.delete; -- limpa dados da tabela auxiliar
           END IF; -- if a cada 10000
           vr_index_crapsdv := vr_tab_crapsdv.NEXT(vr_index_crapsdv);--proximo registro
         END LOOP; -- loop crpsdv2
         IF vr_index_crapsdv2 IS NOT NULL THEN -- insere as linhas restantes < 10000
          BEGIN
               FORALL idx IN INDICES OF vr_tab_crapsdv2 SAVE EXCEPTIONS
                 INSERT INTO crapsdv (cdcooper
                                    ,nrdconta
                                    ,tpdsaldo
                                    ,nrctrato
                                    ,vldsaldo
                                    ,dtmvtolt
                                    ,dsdlinha
                                    ,dsfinali
                                    ,cdlcremp
                                    ,dtpropos
                                    ,dtefetiv
                                    ,inprejuz
                                    ,qtpreemp
                                    ,vlemprst
                                    ,cdfinemp
                                    ,dtdpagto
                                    ,cdageepr
                                    ,flgareal)
                   VALUES          (vr_tab_crapsdv2(idx).cdcooper
                                   ,vr_tab_crapsdv2(idx).nrdconta
                                   ,vr_tab_crapsdv2(idx).tpdsaldo
                                   ,vr_tab_crapsdv2(idx).nrctrato
                                   ,vr_tab_crapsdv2(idx).vldsaldo
                                   ,vr_tab_crapsdv2(idx).dtmvtolt
                                   ,vr_tab_crapsdv2(idx).dsdlinha
                                   ,vr_tab_crapsdv2(idx).dsfinali
                                   ,vr_tab_crapsdv2(idx).cdlcremp
                                   ,vr_tab_crapsdv2(idx).dtpropos
                                   ,vr_tab_crapsdv2(idx).dtefetiv
                                   ,vr_tab_crapsdv2(idx).inprejuz
                                   ,vr_tab_crapsdv2(idx).qtpreemp
                                   ,vr_tab_crapsdv2(idx).vlemprst
                                   ,vr_tab_crapsdv2(idx).cdfinemp
                                   ,vr_tab_crapsdv2(idx).dtdpagto
                                   ,vr_tab_crapsdv2(idx).cdageepr
                                   ,vr_tab_crapsdv2(idx).flgareal);
             EXCEPTION
                 WHEN others THEN
                 -- Gerar erro
                   vr_dscritic := 'Erro ao inserir na tabela crapsdv. '||
                                  SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
                  RAISE vr_exc_erro;
             END;
             vr_tab_crapsdv2.delete; -- limpa dados da tabela auxiliar
         END IF;

         vr_tab_crapsdv2.delete; --limpa dados da tabela auxiliar
         vr_tab_crapsdv.delete; -- limpa dados da tabela principal

         -- Executa processo do programa 2 apenas se não for job paralelo
         IF pr_idparale = 0 THEN
         pc_crps445_2 (pr_cdcooper => pr_cdcooper
                      ,pr_des_erro => vr_dscritic);
         END IF;

         -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
         GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                    ,pr_action => 'pc_sub_rotinas');
         --Se ocorreu erro
         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_erro;
         END IF;

       EXCEPTION
         WHEN vr_exc_erro THEN
           --Retornar erro
           pr_des_erro:= vr_dscritic;
         WHEN others THEN
           pr_des_erro := 'Erro ao processar rotina pc_sub_rotinas: ' || sqlerrm;
       END;
     END pc_sub_rotinas;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps445
     ---------------------------------------
  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    --Apenas valida a cooperativa quando for o programa principal, paralelos não tem necessidade.
    IF pr_idparale = 0 THEN
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar registros montar mensagem de critica
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      --Buscar mensagem de erro
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapcop;
    END IF;
    END IF;

    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

    -- Caso retorno crítica busca a descrição
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    --Selecionar informacoes das taxas para a tabela generica
    vr_dstextab_tx:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);

    --Se nao encontrou parametro
    IF vr_dstextab_tx IS NULL THEN
      vr_inusatab:= FALSE;
    ELSE
      --Se o valor da posicao 1 = 0
      IF SubStr(vr_dstextab_tx,1,1) = '0' THEN
        vr_inusatab:= FALSE;
      ELSE
        vr_inusatab:= TRUE;
      END IF;
    END IF;

    -- Data de fim e inicio da utilização da taxa de poupança.
    -- Utiliza-se essa data quando o rendimento da aplicação for menor que
    -- a poupança, a cooperativa opta por usar ou não.
    -- Buscar a descrição das faixas contido na craptab
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
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
      vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1, vr_dstextab, ';'), 'DD/MM/YYYY');
      vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2, vr_dstextab, ';'), 'DD/MM/YYYY');
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

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
         RAISE vr_exc_erro;
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
      for rw_crapage in cr_crapage (pr_cdcooper => pr_cdcooper
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
          raise vr_exc_erro;
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
                      '  pc_crps445( '|| pr_cdcooper             || ',' ||
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
           raise vr_exc_erro;
        end if;
          
        -- Chama rotina que irá pausar este processo controlador
        -- caso tenhamos excedido a quantidade de JOBS em execuçao
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                    ,pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_erro;
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
        raise vr_exc_erro;
      end if; 

      -- Grava LOG de ocorrência inicial do cursor cr_craprpp
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Início - pc_crps445_2',
                      PR_IDPRGLOG           => vr_idlog_ini_ger); 
      
      -- Executa processo do programa 2 - Para atualizar valores referente avalistas
      pc_crps445_2 (pr_cdcooper => pr_cdcooper
                   ,pr_des_erro => vr_dscritic);     
                   
      -- Grava LOG de ocorrência inicial do cursor cr_craprpp
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - pc_crps445_2',
                      PR_IDPRGLOG           => vr_idlog_ini_ger);                                                      
      
      --Realiza commit para manter dados mesmo que algum job Falhe
      commit;                          

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
        raise vr_exc_erro;
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
        raise vr_exc_erro;
      end if;                                         
    
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par); 
                        
    --Zerar tabela de memoria auxiliar
    pc_limpa_tabela;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapsld. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 
        
    -- Carregar PL Table com dados da tabela CRAPSLD
        FOR rw_crapsld IN cr_crapsld(pr_cdcooper => pr_cdcooper/*
                                    ,pr_cdagenci => rw_crapage_par.cdagenci*/
                                     ) LOOP
      vr_tab_crapsld(rw_crapsld.nrdconta).nrdconta := rw_crapsld.nrdconta;
      vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := rw_crapsld.vlsdchsl;
      vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapsld. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_craplcr. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    -- Carregar PL Table com dados da tabela CRAPLCR
    FOR vr_craplcr IN cr_craplcr(pr_cdcooper) LOOP
      vr_tab_craplcr(vr_craplcr.cdlcremp).cdlcremp := vr_craplcr.cdlcremp;
      vr_tab_craplcr(vr_craplcr.cdlcremp).tpctrato := vr_craplcr.tpctrato;
      vr_tab_craplcr(vr_craplcr.cdlcremp).dsoperac := vr_craplcr.dsoperac;
      vr_tab_craplcr(vr_craplcr.cdlcremp).dslcremp := vr_craplcr.dslcremp;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_craplcr. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapfin. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    -- Carregar PL Table com dados da tabela CRAPFIN
    FOR rw_crapfin IN cr_crapfin(pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapfin(rw_crapfin.cdfinemp):= rw_crapfin.dsfinemp;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapfin. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);         

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapldc. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    -- Carregar PL Table com dados da tabela CRAPLDC
    FOR rw_crapldc IN cr_crapldc(pr_cdcooper) LOOP
      --Montar indice para a tabela de memoria
      vr_index_crapldc:= lpad(rw_crapldc.cddlinha,5,'0')||lpad(rw_crapldc.tpdescto,5,'0');
      --Gravar dados na tabela memoria
      vr_tab_crapldc(vr_index_crapldc):= rw_crapldc.dsdlinha;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapldc. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 
                        
        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crappla. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);                                 

    -- Carregar PL Table com dados da tabela CRAPPLA
        FOR rw_crappla IN cr_crappla(pr_cdcooper => pr_cdcooper/*
                                    ,pr_cdagenci => rw_crapage_par.cdagenci*/) LOOP
      IF NOT vr_tab_crappla.EXISTS(rw_crappla.nrdconta) THEN
        vr_tab_crappla(rw_crappla.nrdconta):= rw_crappla.vlprepla;
      END IF;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crappla. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapepr. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

     -- Carregar PL Table com dados da tabela CRAPEPR
        OPEN cr_crapepr (pr_cdcooper => pr_cdcooper/*
                        ,pr_cdagenci => rw_crapage_par.cdagenci*/);
    LOOP
      FETCH cr_crapepr BULK COLLECT INTO vr_tab_crapepr_carga  LIMIT 100000;
      EXIT WHEN vr_tab_crapepr_carga.COUNT = 0;

      FOR idx IN vr_tab_crapepr_carga.first..vr_tab_crapepr_carga.last LOOP
        --Montar indice para tabela memoria
        IF vr_tab_crapepr.exists(vr_tab_crapepr_carga(idx).nrdconta) THEN
          vr_index_crapepr := vr_tab_crapepr(vr_tab_crapepr_carga(idx).nrdconta).count;
        ELSE
          -- caso o indice por conta ainda nao exista, inicializar com zero
          vr_index_crapepr := 0;
        END IF;
        vr_tab_crapepr(vr_tab_crapepr_carga(idx).nrdconta)(vr_index_crapepr):= vr_tab_crapepr_carga(idx);
      END LOOP;
    END LOOP;
    CLOSE cr_crapepr;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapepr. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    vr_tab_crapepr_carga.delete; -- limpa dados do bulk ja armazenado em outra pl table

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_craprda. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    -- Carregar PL Table com dados da tabela CRAPRDA
        OPEN cr_craprda (pr_cdcooper => pr_cdcooper/*
                        ,pr_cdagenci => rw_crapage_par.cdagenci*/);
    LOOP
      FETCH cr_craprda BULK COLLECT INTO vr_tab_craprda_carga  LIMIT 100000;
      EXIT WHEN vr_tab_craprda_carga.COUNT = 0;

      FOR idx IN vr_tab_craprda_carga.first..vr_tab_craprda_carga.last LOOP
        --Montar indice para tabela memoria
        vr_index_rdacta:= lpad(vr_tab_craprda_carga(idx).cdageass, 10, '0')||
                          lpad(vr_tab_craprda_carga(idx).nrdconta, 10, '0');

        IF vr_tab_craprda.exists(vr_index_rdacta) THEN
          vr_index_rda := vr_tab_craprda(vr_index_rdacta).count;
        ELSE
          -- caso o indice por conta ainda nao exista, inicializar com zero
          vr_index_rda := 0;
        END IF;
        vr_tab_craprda(vr_index_rdacta)(vr_index_rda):= vr_tab_craprda_carga(idx);
      END LOOP;

    END LOOP;
    CLOSE cr_craprda;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_craprda. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

    vr_tab_craprda_carga.delete; -- limpa dados do bulk ja armazenado em outra pl table


        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crawepr. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

    -- Carregar PL Table com dados da tabela CRAWEPR
        OPEN cr_crawepr (pr_cdcooper => pr_cdcooper/*
                        ,pr_cdagenci => rw_crapage_par.cdagenci*/);
    LOOP
      FETCH cr_crawepr BULK COLLECT INTO r_crawepr /* LIMIT 100000*/;
      EXIT WHEN r_crawepr.COUNT = 0;

      FOR idx IN r_crawepr.first..r_crawepr.last LOOP
        --Montar indice para tabela memoria
        vr_index_crawepr:= lpad(r_crawepr(idx).nrdconta, 10, '0') || lpad(r_crawepr(idx).nrctremp, 10, '0');
        vr_tab_crawepr(vr_index_crawepr):= r_crawepr(idx).dtmvtolt;
      END LOOP;

    END LOOP;
    CLOSE cr_crawepr;
    r_crawepr.delete; -- limpa dados do bulk ja armazenado em outra pl table

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crawepr. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_craplim. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

    --Carregar PL table com dados da tabela CRAPLIM
        FOR rw_craplim IN cr_craplim(pr_cdcooper => pr_cdcooper/*
                                    ,pr_cdagenci => rw_crapage_par.cdagenci*/) LOOP

      vr_index_craplim := lpad(rw_craplim.nrdconta, 10, '0') ||
                          lpad(rw_craplim.tpctrlim, 5, '0');
      --Inserir somente o FIRST
      IF rw_craplim.seqreg = 1 AND rw_craplim.insitlim = 2 THEN
        vr_tab_craplim(vr_index_craplim).nrdconta := rw_craplim.nrdconta;
        vr_tab_craplim(vr_index_craplim).vllimite := rw_craplim.vllimite;
        vr_tab_craplim(vr_index_craplim).nrctrlim := rw_craplim.nrctrlim;
        vr_tab_craplim(vr_index_craplim).dtpropos := rw_craplim.dtpropos;
        vr_tab_craplim(vr_index_craplim).tpctrlim := rw_craplim.tpctrlim;
        vr_tab_craplim(vr_index_craplim).insitlim := rw_craplim.insitlim;
        vr_tab_craplim(vr_index_craplim).dtinivig := rw_craplim.dtinivig;
        vr_tab_craplim(vr_index_craplim).cddlinha := rw_craplim.cddlinha;
      END IF;

      vr_index_craplim2:= lpad(rw_craplim.nrdconta, 10, '0') ||
                          lpad(rw_craplim.tpctrlim, 05, '0') ||
                          LPad(rw_craplim.nrctrlim, 10, '0');

      vr_tab_craplim2(vr_index_craplim2).nrdconta := rw_craplim.nrdconta;
      vr_tab_craplim2(vr_index_craplim2).vllimite := rw_craplim.vllimite;
      vr_tab_craplim2(vr_index_craplim2).nrctrlim := rw_craplim.nrctrlim;
      vr_tab_craplim2(vr_index_craplim2).dtpropos := rw_craplim.dtpropos;
      vr_tab_craplim2(vr_index_craplim2).tpctrlim := rw_craplim.tpctrlim;
      vr_tab_craplim2(vr_index_craplim2).insitlim := rw_craplim.insitlim;
      vr_tab_craplim2(vr_index_craplim2).dtinivig := rw_craplim.dtinivig;
      vr_tab_craplim2(vr_index_craplim2).cddlinha := rw_craplim.cddlinha;

    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_craplim. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);
                        
        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapsda. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);                        

    -- Carregar PL Table com dados da tabela CRAPSDA
    FOR rw_crapsda IN cr_crapsda (pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt/*
                                     ,pr_cdagenci => rw_crapage_par.cdagenci*/) LOOP
      vr_tab_crapsda(rw_crapsda.nrdconta).nrdconta:= rw_crapsda.nrdconta;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlavlatr:= rw_crapsda.vlavlatr;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlavaliz:= rw_crapsda.vlavaliz;
      vr_tab_crapsda(rw_crapsda.nrdconta).dtmvtolt:= rw_crapsda.dtmvtolt;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlsddisp:= rw_crapsda.vlsddisp;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlsdchsl:= rw_crapsda.vlsdchsl;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlsdbloq:= rw_crapsda.vlsdbloq;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlsdblpr:= rw_crapsda.vlsdblpr;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlsdblfp:= rw_crapsda.vlsdblfp;
      vr_tab_crapsda(rw_crapsda.nrdconta).vlsdindi:= rw_crapsda.vlsdindi;
      vr_tab_crapsda(rw_crapsda.nrdconta).vllimcre:= rw_crapsda.vllimcre;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapsda. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapdtc. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    -- Carregar PL Table com dados da tabela CRAPDTC
    FOR vr_crapdtc IN cr_crapdtc(pr_cdcooper) LOOP
      vr_tab_crapdtc(lpad(vr_crapdtc.tpaplica, 3, '0')).tpaplrdc := vr_crapdtc.tpaplrdc;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapdtc. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapneg. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    -- Carregar PL table com dados da tabela CRAPNEG
    OPEN cr_crapneg (pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt/*
                        ,pr_cdagenci => rw_crapage_par.cdagenci*/);
    LOOP

      FETCH cr_crapneg BULK COLLECT INTO r_crapneg;
      EXIT WHEN r_crapneg.COUNT = 0;

      FOR idx IN r_crapneg.first..r_crapneg.last LOOP
        vr_tab_crapneg(r_crapneg(idx).nrdconta):= r_crapneg(idx).conta;
      END LOOP;

    END LOOP;
    CLOSE cr_crapneg;
    r_crapneg.delete; -- limpa dados do bulk ja armazenado em outra pl table

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapneg. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 


        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapcdb. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    --Carregar tabela memoria com dados da tabela CRAPCDB
    FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => pr_cdcooper
                                 ,pr_insitchq => 2
                                     ,pr_dtlibera => rw_crapdat.dtmvtolt/*
                                     ,pr_cdagenci => rw_crapage_par.cdagenci*/) LOOP
      --Se ja existir entao soma valor cheque
      IF vr_tab_crapcdb.EXISTS(rw_crapcdb.nrdconta) THEN
        vr_tab_crapcdb(rw_crapcdb.nrdconta).nrctrlim:= rw_crapcdb.nrctrlim;
        vr_tab_crapcdb(rw_crapcdb.nrdconta).vlcheque:= vr_tab_crapcdb(rw_crapcdb.nrdconta).vlcheque + rw_crapcdb.vlcheque;
      ELSE
        vr_tab_crapcdb(rw_crapcdb.nrdconta).nrctrlim:= rw_crapcdb.nrctrlim;
        vr_tab_crapcdb(rw_crapcdb.nrdconta).vlcheque:= rw_crapcdb.vlcheque;
      END IF;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapcdb. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapttl. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

        --Carregar tabela memoria com dados da tabela CRAPTTL
        FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper/*
                                    ,pr_cdagenci => rw_crapage_par.cdagenci*/) LOOP
      vr_tab_crapttl(rw_crapttl.nrdconta):= rw_crapttl.vlsalari;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapttl. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);         

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapcst_conta. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    --Carregar tabela memoria com dados da tabela CRAPCDB
    FOR rw_crapcst_conta IN cr_crapcst_conta(pr_cdcooper => pr_cdcooper
                                                ,pr_dtlibera => rw_crapdat.dtmvtolt/*
                                                ,pr_cdagenci => rw_crapage_par.cdagenci*/) LOOP
          vr_tab_crapcst(rw_crapcst_conta.nrdconta) := 0;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapcst_conta. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);   
                        
        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_craptdb_conta. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);                              

    --Carregar tabela memoria com dados da tabela CRAPTDB
    FOR rw_craptdb IN cr_craptdb_conta (pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt/*
                                           ,pr_cdagenci => rw_crapage_par.cdagenci*/) LOOP
          vr_tab_craptdb(rw_craptdb.nrdconta) := 0;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_craptdb_conta. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 
                        
        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapfdc_carga. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);                               

    --Carregar tabela memoria com dados da tabela CRAPFDC
    OPEN cr_crapfdc_carga (pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    LOOP
      FETCH cr_crapfdc_carga BULK COLLECT INTO r_crapfdc LIMIT 50000;
      EXIT WHEN r_crapfdc.COUNT = 0;

      FOR idx IN r_crapfdc.first..r_crapfdc.last LOOP
        vr_index_crapfdc:= LPad(r_crapfdc(idx).nrdconta,10,'0')||LPad(r_crapfdc(idx).incheque,5,'0');
        vr_tab_crapfdc(vr_index_crapfdc):= r_crapfdc(idx).quantidade;
      END LOOP;

    END LOOP;
    CLOSE cr_crapfdc_carga;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapfdc_carga. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);  

    r_crapfdc.delete; -- limpa dados do bulk ja armazenado em outra pl table

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapfdc_carga_5. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);  

    --Carregar tabela memoria com dados da tabela CRAPFDC incheque 5
    OPEN cr_crapfdc_carga_5 (pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    LOOP
      FETCH cr_crapfdc_carga_5 BULK COLLECT INTO r_crapfdc LIMIT 50000;
      EXIT WHEN r_crapfdc.COUNT = 0;

      FOR idx IN r_crapfdc.first..r_crapfdc.last LOOP
        vr_index_crapfdc:= LPad(r_crapfdc(idx).nrdconta,10,'0')||LPad(r_crapfdc(idx).incheque,5,'0');
        vr_tab_crapfdc(vr_index_crapfdc):= r_crapfdc(idx).quantidade;
      END LOOP;

    END LOOP;
    CLOSE cr_crapfdc_carga_5;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_crapfdc_carga_5. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);         

    r_crapfdc.delete; -- limpa dados do bulk ja armazenado em outra pl table

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_craprpp. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    --Carregar tabela memoria com dados da tabela CRAPRPP
    FOR rw_craprpp IN cr_craprpp_conta (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craprpp(rw_craprpp.nrdconta):= 0;
    END LOOP;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - cursor cr_craprpp. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);         

    --Selecionar o percentual de IR para calculo poupanca
    vr_percirtab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'CONFIG'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'PERCIRAPLI'
                                             ,pr_tpregist => 0);

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - procedure pc_sub_rotinas. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

    -- Executar programas
    pc_sub_rotinas(pr_des_erro => vr_dscritic);

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - procedure pc_sub_rotinas. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 


    -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    -- Levantar exceção no caso de erros no processo paralelo
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - update crapsda. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 

      --Atualizar informacoes da tabela crapsda
      BEGIN

        FORALL idx IN INDICES OF vr_tab_crapsda2 SAVE EXCEPTIONS
          UPDATE crapsda crapsda
          SET crapsda.vlsdeved = vr_tab_crapsda2(idx).vlsdeved
             ,crapsda.vldeschq = vr_tab_crapsda2(idx).vldeschq
             ,crapsda.vldestit = vr_tab_crapsda2(idx).vldestit
             ,crapsda.vllimutl = vr_tab_crapsda2(idx).vllimutl
             ,crapsda.vladdutl = vr_tab_crapsda2(idx).vladdutl
             ,crapsda.vlsdrdca = vr_tab_crapsda2(idx).vlsdrdca
             ,crapsda.vlsdrdpp = vr_tab_crapsda2(idx).vlsdrdpp
             ,crapsda.vllimdsc = vr_tab_crapsda2(idx).vllimdsc
             ,crapsda.vllimtit = vr_tab_crapsda2(idx).vllimtit
             ,crapsda.vlprepla = vr_tab_crapsda2(idx).vlprepla
             ,crapsda.vlprerpp = vr_tab_crapsda2(idx).vlprerpp
             ,crapsda.vlcrdsal = vr_tab_crapsda2(idx).vlcrdsal
             ,crapsda.qtchqliq = vr_tab_crapsda2(idx).qtchqliq
             ,crapsda.qtchqass = vr_tab_crapsda2(idx).qtchqass
             ,crapsda.vltotpar = vr_tab_crapsda2(idx).vltotpar
             ,crapsda.vlopcdia = vr_tab_crapsda2(idx).vlopcdia
             ,crapsda.qtdevolu = vr_tab_crapsda2(idx).qtdevolu
             ,crapsda.vltotren = vr_tab_crapsda2(idx).vltotren
             ,crapsda.vlsrdc30 = vr_tab_crapsda2(idx).vlsrdc30
             ,crapsda.vlsrdc60 = vr_tab_crapsda2(idx).vlsrdc60
             ,crapsda.vlsrdcpr = vr_tab_crapsda2(idx).vlsrdcpr
             ,crapsda.vlsrdcpo = vr_tab_crapsda2(idx).vlsrdcpo
             ,crapsda.vlsdempr = vr_tab_crapsda2(idx).vlsdempr
             ,crapsda.vlsdfina = vr_tab_crapsda2(idx).vlsdfina
          WHERE crapsda.cdcooper = vr_tab_crapsda2(idx).cdcooper
          AND   crapsda.nrdconta = vr_tab_crapsda2(idx).nrdconta
          AND   crapsda.dtmvtolt = vr_tab_crapsda2(idx).dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro
          vr_dscritic := 'Erro ao inserir na tabela crapsda. '||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_erro;
      END;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - update crapsda. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 
                        
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
          raise vr_exc_erro;
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

    --Zerar tabela de memoria auxiliar
    pc_limpa_tabela;


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

      --Zerar tabela de memoria auxiliar
      pc_limpa_tabela;
    end if;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      --Zerar tabela de memoria auxiliar
      pc_limpa_tabela;

      if pr_idparale <> 0 then 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||'pr_dscritic:'||pr_dscritic,
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      --Zerar tabela de memoria auxiliar
      pc_limpa_tabela;

      if pr_idparale <> 0 then 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||'pr_dscritic:'||pr_dscritic,
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
END PC_CRPS445;