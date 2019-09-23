/*.............................................................................

   Programa: b1wgen0039.p
   Autor   : Gabriel
   Data    : Maio/2009                  Ultima Atualizacao: 07/03/2017

   Dados referentes ao programa:

   Objetivo  : BO referente a consulta da opcao de RELACIONAMENTO na tela
               ATENDA que contem informacoes dos eventos do PROGRID.
 
   Nota      : Devera estar conectado ao PROGRID e GENERICO para complilar.
               (PROGRID - /usr/coop/cecred/progrid/arquivos/progrid.db)
              
   Alteracoes: 19/08/2009 - Permitir inscricoes no mesmo dia do evento 
                            (Gabriel)

               24/08/2009 - Trazer lista de pessoas ja relacionadas da conta 
                            no evento especificado (inscricoes-da-conta),
                            Considerar eventos da Assembleia.
                            Melhorar indices (Gabriel).
                        
                          - Padronizacao da BO (Gabriel).
                        
               24/09/2009 - Nova padronizacao da BO (Gabriel).
               
               23/10/2009 - Melhor estruturacao da procedure 
                            grau-parentesco (Gabriel).   
                            
               13/05/2010 - Gravar a data e o operador quando a situacao
                            da inscricao mudar (Gabriel).         
                            
               04/06/2010 - Ordenar os eventos em andamento pela data.
                            Implementar controle sobre as datas do questionario. 
                            Trazer na pre-inscricao se o evento é
                            exclusivo a cooperados (Gabriel)
                            
               01/11/2010 - Incluido o campo crapass.dtcadqst na procedure
                            grava-data-questionario p/ data de digitacao da 
                            devolucao do questionario (Vitor)
                            
               07/02/2011 - Alterar a procedure que trata dos historicos
                            para tambem tratar impressao deles (Gabriel).    
                            
               04/05/2011 - Alterado a procedure que trata de gravar a data
                            do questionario para gravar a data de digitacao.
                            Esta. Somente quando, for informado a data de 
                            devolucao do questionario (Adriano).
                            
               26/09/2012 - Tratamento para exibir historico de eventos
                            participados antes da migração de Coop (Lucas).
                            
               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).
                         
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).   
                             
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               03/08/2015 - Ajuste para retirar o caminho absoluto na
                            chamada dos fontes 
                            (Adriano - SD 314469)   
                            
               11/02/2016 - Adicionado FIELDS no for each da crapidp.
                            Na procedure obtem-historico adicionado condicao para
                            ignorar eventos cancelados na listagem (Lucas Ranghetti #395793)
                            
               17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)
                
               28/06/2016 - Alterado rotina grava-nova-situacao para quando for alterado a situaçao
                            para excluido, chamar a rotina para excluir o registro.
                            PRJ229 - Melhorias OQS (Odirlei-AMcom).
                            
               07/03/2018 - Alterado obtem-detalhe-evento para exibir o nome do facilitador
                            em eventos assembleares, SD840422 (Jean Michel).
														
               13/08/2019 - Vincular inscricao de pessoa juridica com socio
                            Gabriel Marcos (Mouts) - P484.2
                            
..............................................................................*/

{ sistema/generico/includes/b1wgen0039tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i    }
{ sistema/generico/includes/gera_log.i     }
{ sistema/ayllos/includes/var_online.i NEW }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmesref AS CHAR                                           NO-UNDO.

/****************************PROCEDURES EXTERNAS*******************************/

/*****************************************************************************
Trazer a quantidade de eventos pendentes e confirmados do cooperado.
Tambem traz a quantidade de eventos em andamento do seu PAC e de quantos
eventos o coop ja participou.(DADOS DA TELA PRINCIPAL, RELACIONAMENTOS - ATENDA)
******************************************************************************/

PROCEDURE obtem-quantidade-eventos:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtanoage AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.  
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-qtdade-eventos.

 
    DEF  VAR    aux_cdagenci       AS INTE                           NO-UNDO.
    DEF  VAR    aux_qtpenden       AS INTE                           NO-UNDO.
    DEF  VAR    aux_qtconfir       AS INTE                           NO-UNDO.
    DEF  VAR    aux_qtandame       AS INTE                           NO-UNDO.
    DEF  VAR    aux_qthispar       AS INTE                           NO-UNDO.
    DEF  VAR    aux_nrctaant       AS INTE                           NO-UNDO.
    DEF  VAR    aux_cdcopant       AS INTE                           NO-UNDO.
   

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-qtdade-eventos.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar dados de eventos do PROGRID".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9.
    
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
         
             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
             RETURN "NOK".
             
         END.

    FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                       craptco.nrdconta = par_nrdconta AND
                       craptco.tpctatrf <> 3
                       NO-LOCK NO-ERROR NO-WAIT.

    IF AVAIL craptco THEN
        ASSIGN aux_cdcopant = craptco.cdcopant
               aux_nrctaant = craptco.nrctaant.
    ELSE
        ASSIGN aux_cdcopant = par_cdcooper
               aux_nrctaant = par_nrdconta.

    /* Agrupamento de PACS, usado para aqueles PAC que dependem e usam a
       agenda de outros  - idevento = 1 - PROGRID */
   
    RUN obtem-agrupador (INPUT  1,
                         INPUT  par_cdcooper,
                         INPUT  par_dtanoage,
                         INPUT  crapass.cdagenci,
                         OUTPUT aux_cdagenci).    
         
    /* Eventos em aberto do PAC do associado */
    FOR EACH crapadp WHERE ((crapadp.cdcooper = par_cdcooper       AND
                             crapadp.dtanoage = par_dtanoage       AND
                             crapadp.cdagenci = aux_cdagenci       AND
                             crapadp.idevento = 1)   OR
                            
                            (crapadp.cdcooper = par_cdcooper       AND
                             crapadp.dtanoage = par_dtanoage       AND
                             crapadp.cdagenci = crapass.cdagenci   AND
                             crapadp.idevento = 2)  OR
                                           
                             /* Assembleia */
                            (crapadp.cdcooper = par_cdcooper       AND
                             crapadp.dtanoage = par_dtanoage       AND
                             crapadp.cdagenci = 0                  AND
                             crapadp.idevento = 2))                AND
         
                       CAN-DO("1,3,4,6",STRING(crapadp.idstaeve)) NO-LOCK,
         
        FIRST crapedp WHERE crapedp.cdcooper = par_cdcooper       AND
                            crapedp.dtanoage = crapadp.dtanoage   AND
                            crapedp.cdevento = crapadp.cdevento   AND
                            crapedp.idevento = crapadp.idevento   NO-LOCK:

        IF   crapadp.dtinieve < par_dtmvtolt  THEN 
             NEXT.

        IF   crapadp.nrmeseve < MONTH(par_dtmvtolt)  THEN
             NEXT.
                
        /* Eventos em andamento */ 
        ASSIGN aux_qtandame = aux_qtandame + 1.
         

        /* Inscricoes do evento dos titulares da conta ou familiares */
        FOR EACH crapidp FIELDS(crapidp.idstains) 
                         WHERE crapidp.cdcooper = par_cdcooper       AND
                               crapidp.nrdconta = par_nrdconta       AND
                               crapidp.idevento = crapadp.idevento   AND
                               crapidp.dtanoage = crapadp.dtanoage   AND
                               crapidp.cdagenci = crapadp.cdagenci   AND
                               crapidp.cdevento = crapadp.cdevento   AND
                               crapidp.nrseqeve = crapadp.nrseqdig   NO-LOCK
                               USE-INDEX crapidp6:
            
            CASE crapidp.idstains:
            
               WHEN   1   THEN   aux_qtpenden = aux_qtpenden + 1. /*Pendente*/
               WHEN   2   THEN   aux_qtconfir = aux_qtconfir + 1. /*Confirm.*/
                            
            END CASE.
         
        END.
         
    END.

        
    /* Historico - Quantidade de eventos ja inscritos pelo cooperado */
    FOR EACH crapidp FIELDS(crapidp.cdcooper crapidp.idevento crapidp.dtanoage
                            crapidp.cdagenci crapidp.cdevento crapidp.nrseqeve) 
                     WHERE (crapidp.cdcooper = par_cdcooper   AND
                            crapidp.nrdconta = par_nrdconta)  OR
                           (crapidp.cdcooper = aux_cdcopant   AND
                            crapidp.nrdconta = aux_nrctaant)  NO-LOCK:
    
        FIND crapadp WHERE crapadp.cdcooper = crapidp.cdcooper   AND
                           crapadp.idevento = crapidp.idevento   AND
                           crapadp.dtanoage = crapidp.dtanoage   AND
                           crapadp.cdagenci = crapidp.cdagenci   AND
                           crapadp.cdevento = crapidp.cdevento   AND
                           crapadp.nrseqdig = crapidp.nrseqeve   
                           NO-LOCK NO-ERROR.
    
        IF   NOT AVAILABLE crapadp   THEN
             NEXT.
             
        IF   crapadp.dtinieve = ?    THEN
             NEXT.

        IF   crapadp.dtfineve >= par_dtmvtolt   THEN
             NEXT.

        aux_qthispar = aux_qthispar + 1.
        
    END.
    
    CREATE tt-qtdade-eventos. 
    ASSIGN tt-qtdade-eventos.qtpenden = aux_qtpenden
           tt-qtdade-eventos.qtconfir = aux_qtconfir
           tt-qtdade-eventos.qtandame = aux_qtandame
           tt-qtdade-eventos.qthispar = aux_qthispar
           tt-qtdade-eventos.dtinique = crapass.dtentqst 
           tt-qtdade-eventos.dtfimque = crapass.dtdevqst
           tt-qtdade-eventos.dtcadqst = crapass.dtcadqst.
    

    IF   par_flgerlog   THEN
         DO:
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT "",
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT TRUE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
         END.
    
    RETURN "OK".

END PROCEDURE.


/**************************************************************************** 
Procedure que traz a lista de todos os eventos em andamento do PAC do associado
*****************************************************************************/

PROCEDURE obtem-eventos-andamento:

    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.   
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtanoage AS INTE                           NO-UNDO. 
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-eventos-andamento.

    DEF  VAR    aux_cdagenci       AS INTE                           NO-UNDO.
    DEF  VAR    aux_qtpenden       AS INTE                           NO-UNDO.
    DEF  VAR    aux_qtconfir       AS INTE                           NO-UNDO.
    DEF  VAR    aux_dtinieve       AS CHAR                           NO-UNDO.
    DEF  VAR    aux_dtfineve       AS CHAR                           NO-UNDO.
    DEF  VAR    aux_dsobserv       AS CHAR                           NO-UNDO.
    DEF  VAR    aux_dsobserv2      AS CHAR                           NO-UNDO.
    DEF  VAR    aux_dsrestri       AS CHAR                           NO-UNDO.
    DEF  VAR    aux_dsexclus       AS CHAR                           NO-UNDO. 
    DEF  VAR    aux_qthispar       AS INTE                           NO-UNDO.
    DEF  VAR    aux_cdagenci2      AS INTE                           NO-UNDO. /*Voto por Grupo */
    
    DEF BUFFER crabadp FOR crapadp.
    

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-eventos-andamento.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar lista de eventos em andamento do PA"
    
           aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," +
                          "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.


    IF   NOT AVAILABLE crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9.
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
         
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".
         END.

    /* Buscar PA associado a pessoa*/
    DO:
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_retorna_pa_pessoa
                         aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT par_cdcooper,      /* Cooperativa */
                   INPUT crapass.nrcpfcgc,      /* Número do cpf/cgc */
                   OUTPUT 0,                   
                   OUTPUT 0,
                   OUTPUT "").
         
    CLOSE STORED-PROC pc_retorna_pa_pessoa 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
    ASSIGN aux_cdcritic     = pc_retorna_pa_pessoa.pr_cdcritic
                             WHEN pc_retorna_pa_pessoa.pr_cdcritic <> ?
           aux_dscritic     = pc_retorna_pa_pessoa.pr_dscritic
                             WHEN pc_retorna_pa_pessoa.pr_dscritic <> ?
           aux_cdagenci2    = pc_retorna_pa_pessoa.pr_cdagenci
                             WHEN pc_retorna_pa_pessoa.pr_cdagenci <> ?.
    END.

    /* Agrupamento de PACS, usado para aqueles PAC que dependem e usam a
       agenda de outros  - idevento = 1 - PROGRID */
    RUN obtem-agrupador (INPUT  1,
                         INPUT  par_cdcooper,
                         INPUT  par_dtanoage,
                         INPUT  crapass.cdagenci,
                         OUTPUT aux_cdagenci).    
    
    /* Eventos abertos para inscricao do PAC*/
    
    FOR EACH crapadp WHERE ((crapadp.cdcooper = par_cdcooper       AND
                             crapadp.cdagenci = aux_cdagenci       AND
                             crapadp.dtanoage = par_dtanoage       AND
                             crapadp.idevento = 1)   OR
                               
                             /* Eventos sem Grupo */  
                            (crapadp.cdcooper = par_cdcooper       AND
                             crapadp.cdagenci = crapass.cdagenci   AND
                             crapadp.dtanoage = par_dtanoage       AND
                             crapadp.nmdgrupo = " "                AND
                             crapadp.idevento = 2)   OR 

                             /* Eventos com Grupo */                               
                            (crapadp.cdcooper = par_cdcooper       AND
                             crapadp.cdagenci = aux_cdagenci2      AND
                             crapadp.dtanoage = par_dtanoage       AND
                             crapadp.nmdgrupo <> " "               AND                             
                             crapadp.idevento = 2)   OR 
                              
                              /* Assembleia */
                            (crapadp.cdcooper = par_cdcooper       AND
                             crapadp.cdagenci = 0                  AND 
                             crapadp.dtanoage = par_dtanoage       AND
                             crapadp.idevento = 2))                AND
                            
                     CAN-DO("1,3,4,6",STRING(crapadp.idstaeve))   NO-LOCK,
                                       
        FIRST crapedp WHERE crapedp.cdcooper = par_cdcooper       AND
                            crapedp.dtanoage = par_dtanoage       AND
                            crapedp.idevento = crapadp.idevento   AND
                            crapedp.cdevento = crapadp.cdevento   
							NO-LOCK
                            BREAK BY crapadp.nrmeseve
                                     BY crapadp.dtinieve:
                
        
        IF   crapadp.dtinieve < par_dtmvtolt  THEN
             NEXT.
                      
        IF   crapadp.nrmeseve < MONTH(par_dtmvtolt)  THEN
             NEXT.

        ASSIGN aux_qtpenden  = 0  
               aux_qtconfir  = 0 
               aux_dsobserv  = ""
               aux_dsobserv2 = ""
               aux_dsrestri  = "".

        IF   crapedp.nridamin > 0   THEN
             DO:
                 aux_dsrestri = STRING(crapedp.nridamin) + " ANOS/".
             END.
        ELSE
             DO:
                 aux_dsrestri = "SEM RESTRICAO DE IDADE/".
             END.
    
        IF   crapedp.flgcompr  THEN
             DO:
                 aux_dsrestri = aux_dsrestri + "TERMO DE COMPROMISSO/".
             END.
         
        /* Exclusiva para cooperados/Para familiares de coop/Aberto a Comun. */
        RUN obtem-tipo-participacao(INPUT crapedp.tppartic,
                                    OUTPUT aux_dsexclus).
                
        aux_dsrestri = aux_dsrestri + aux_dsexclus.
        
        /* Pre-Inscricoes e inscricoes confirmadas do evento no PAC */
        FOR EACH crapidp WHERE crapidp.cdcooper = par_cdcooper       AND
                               crapidp.idevento = crapadp.idevento   AND
                               crapidp.dtanoage = crapadp.dtanoage   AND
                               crapidp.cdagenci = crapadp.cdagenci   AND
                               crapidp.cdevento = crapadp.cdevento   AND
                               crapidp.nrseqeve = crapadp.nrseqdig   NO-LOCK
                               USE-INDEX crapidp1:
                               
            IF   crapidp.idstains <> 5   THEN    /* Pre-inscrito */
                 aux_qtpenden = aux_qtpenden + 1.   
                
            IF   crapidp.idstains = 2   THEN     /* Confirmado   */
                 aux_qtconfir = aux_qtconfir + 1.  
        
        END.
        

        /* Verificar situacao do cooperado ou familiares em relacao ao evento */
        
        /* Pegar se tiver sempre algum pendente */
        FOR EACH crapidp WHERE crapidp.cdcooper = crapadp.cdcooper   AND
                               crapidp.cdagenci = crapadp.cdagenci   AND
                               crapidp.nrdconta = par_nrdconta       AND
                               crapidp.idevento = crapadp.idevento   AND
                               crapidp.dtanoage = crapadp.dtanoage   AND
                               crapidp.cdevento = crapadp.cdevento   AND
                               crapidp.nrseqeve = crapadp.nrseqdig   NO-LOCK
                               USE-INDEX crapidp6:
            
            IF   crapidp.idstains = 2   THEN    
                 NEXT.
                        
            CASE crapidp.idstains:
                                                  
                WHEN   1   THEN   aux_dsobserv2 = "P".
                WHEN   3   THEN   aux_dsobserv2 = "D".
                WHEN   4   THEN   aux_dsobserv2 = "R".
                WHEN   5   THEN   aux_dsobserv2 = "E".
             
            END CASE.

            aux_dsobserv = IF   aux_dsobserv = ""  THEN
                                aux_dsobserv2  
                           ELSE
                                aux_dsobserv + "/" + aux_dsobserv2.    
                                
        END.


        FOR EACH crapidp WHERE crapidp.cdcooper = crapadp.cdcooper  AND
                               crapidp.cdagenci = crapadp.cdagenci  AND
                               crapidp.nrdconta = par_nrdconta      AND
                               crapidp.idevento = crapadp.idevento  AND
                               crapidp.dtanoage = crapadp.dtanoage  AND
                               crapidp.cdevento = crapadp.cdevento  AND
                               crapidp.nrseqeve = crapadp.nrseqdig  AND
                               crapidp.idstains = 2                 NO-LOCK
                               USE-INDEX crapidp6:

            aux_dsobserv = IF   aux_dsobserv = ""  THEN
                                "C"
                           ELSE
                                aux_dsobserv + "/C" .
        END.

              /* Se nao tem pre-inscricao verifica historico de participacao */
        IF   aux_dsobserv = ""   THEN
             DO:          
                 FIND FIRST crapidp WHERE 
                            crapidp.cdcooper = par_cdcooper       AND
                            crapidp.nrdconta = par_nrdconta       AND
                            crapidp.idevento = crapadp.idevento   AND
                            crapidp.cdevento = crapadp.cdevento 
                            USE-INDEX crapidp6 NO-LOCK NO-ERROR.

                 IF   AVAIL crapidp   THEN
                      DO:
                          FIND crabadp WHERE 
                               crabadp.cdcooper = crapidp.cdcooper   AND
                               crabadp.idevento = crapidp.idevento   AND
                               crabadp.dtanoage = crapidp.dtanoage   AND
                               crabadp.cdagenci = crapidp.cdagenci   AND
                               crabadp.cdevento = crapidp.cdevento   AND
                               crabadp.nrseqdig = crapidp.nrseqeve
                               NO-LOCK NO-ERROR.
                               
                          IF   AVAILABLE crabadp   THEN
                               DO:
                                   /* Se ja aconteceu */
                                   IF   crabadp.dtinieve <> ?             AND
                                        crabadp.dtfineve < par_dtmvtolt   THEN
                                        DO:
                                            aux_dsobserv = "H".
                                        END.
                               END.
                      END.
             END.

        /* Se o evento em questao nao tiver data marcada, atribuir o mes */
        ASSIGN aux_dtinieve = IF   crapadp.dtinieve <> ?   THEN
                                   STRING(crapadp.dtinieve)
                              ELSE
                                   ENTRY(crapadp.nrmeseve,aux_dsmesref)
               aux_dtfineve = IF   crapadp.dtfineve <> ?   THEN
                                   STRING(crapadp.dtfineve)
                              ELSE
                                   ENTRY(crapadp.nrmeseve,aux_dsmesref).
                                           
        CREATE tt-eventos-andamento.
        ASSIGN tt-eventos-andamento.cdevento = crapedp.cdevento
               tt-eventos-andamento.idevento = crapedp.idevento
               tt-eventos-andamento.nmevento = crapedp.nmevento
               tt-eventos-andamento.qtmaxtur = crapedp.qtmaxtur
               tt-eventos-andamento.qtpenden = aux_qtpenden
               tt-eventos-andamento.qtconfir = aux_qtconfir
               tt-eventos-andamento.dtinieve = aux_dtinieve
               tt-eventos-andamento.dtfineve = aux_dtfineve
               tt-eventos-andamento.nrmeseve = crapadp.nrmeseve 
               tt-eventos-andamento.dsobserv = aux_dsobserv
               tt-eventos-andamento.nridamin = crapedp.nridamin
               tt-eventos-andamento.flgcompr = crapedp.flgcompr
               tt-eventos-andamento.dsrestri = aux_dsrestri
               tt-eventos-andamento.rowidedp = ROWID(crapedp)
               tt-eventos-andamento.rowidadp = ROWID(crapadp)
               tt-eventos-andamento.nmdgrupo = crapadp.nmdgrupo.

    END.
    
    /* RESTRICOES -  par_dsobserv ==>  C - Confirmadas / P - Pendentes */
    /*               par_dsobserv ==>  EM BRANCO - Todos os eventos    */

    IF   par_dsobserv <> ""   THEN
         DO:
             /* Filtra os eventos dependendo de par_dsobserv */
             
             RUN filtra-eventos (INPUT par_dsobserv,
                                 INPUT-OUTPUT TABLE tt-eventos-andamento).
         
         END.

    IF   par_flgerlog   THEN
         DO:
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT "",
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT TRUE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
         END.
            
    RETURN "OK".

END PROCEDURE.


/***************************************************************************
Procedure para trazer o grau de parentesco                                                                            
****************************************************************************/

PROCEDURE grau-parentesco:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.  
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdgraupr AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT  PARAM TABLE FOR tt-grau-parentesco.


    DEF VAR           aux_dsgraupr AS CHAR                           NO-UNDO.
    DEF VAR           aux_contador AS INTE                           NO-UNDO.


    EMPTY TEMP-TABLE tt-grau-parentesco.

    DO WHILE TRUE:
    
       FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                          craptab.nmsistem = "CRED"        AND
                          craptab.tptabela = "GENERI"      AND
                          craptab.cdempres = 0             AND
                          craptab.cdacesso = "VINCULOTTL"  AND
                          craptab.tpregist = 0             NO-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE craptab   THEN
            DO:
                aux_cdcritic = 55.
                LEAVE.
            END.
   
       IF   par_cdgraupr <> 0   THEN /* Grau de parentesco especifico */
            DO:  
                CREATE tt-grau-parentesco.
                ASSIGN tt-grau-parentesco.cdgraupr = par_cdgraupr.

                ASSIGN aux_dsgraupr = ENTRY(LOOKUP(STRING(par_cdgraupr),
       
                                      craptab.dstextab) - 1,craptab.dstextab) NO-ERROR.
                    
                IF   ERROR-STATUS:ERROR   THEN
                     DO:
                         ASSIGN tt-grau-parentesco.dsgraupr = "NÃO ENCONTRADO".                               
                     END. 
                ELSE
                     DO:
                         ASSIGN tt-grau-parentesco.dsgraupr = aux_dsgraupr.             
                     END.
            END.
       ELSE                   /* Lista dos grau de parentesco */
            DO:
                DO aux_contador = 1 TO NUM-ENTRIES(craptab.dstextab):

                   CREATE tt-grau-parentesco.
                   ASSIGN tt-grau-parentesco.cdgraupr = 
                            INT(ENTRY(aux_contador + 1,craptab.dstextab))
                       
                          tt-grau-parentesco.dsgraupr = 
                            ENTRY(aux_contador,craptab.dstextab) 
                   
                          aux_contador = aux_contador + 1.

                END.      

            END.

       LEAVE.

    END.  /* Fim do DO WHILE TRUE */

    IF   aux_dscritic <> ""  OR
         aux_cdcritic <> 0   THEN
         RETURN "NOK".   
                  
    IF   par_flgerlog   THEN
         DO:
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT "",
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT TRUE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
         END.

    RETURN "OK".

END PROCEDURE.


/***************************************************************************
Procedure que traz os dados do cooperado que esta fazendo a pre-inscricao.
****************************************************************************/

PROCEDURE pre-inscricao:


    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.  
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_rowidadp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-info-cooperado.
    DEF  OUTPUT PARAM TABLE FOR tt-grau-parentesco.
    DEF  OUTPUT PARAM TABLE FOR tt-inscricoes-conta.
    DEF  OUTPUT PARAM par_flgcoope AS LOGI                           NO-UNDO.

    DEF  VAR    aux_dsdemail       AS CHAR                           NO-UNDO.
        

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-info-cooperado.
    EMPTY TEMP-TABLE tt-inscricoes-conta.
    

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar dados para a pre-inscricao do cooperado".
               
    
    FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                           crapttl.nrdconta = par_nrdconta   NO-LOCK:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.
        
         
        /* Pega primeiro e-mail do titular da conta que achar */
        FIND FIRST crapcem WHERE crapcem.cdcooper = crapttl.cdcooper   AND
                                 crapcem.nrdconta = crapttl.nrdconta   AND
                                 crapcem.idseqttl = crapttl.idseqttl
                                 NO-LOCK NO-ERROR.
    
        IF   AVAILABLE crapcem   THEN
             ASSIGN aux_dsdemail = crapcem.dsdemail.
        ELSE
             ASSIGN aux_dsdemail = "".

        /* Telefone residencial */
        FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper   AND  
                                 craptfc.nrdconta = crapttl.nrdconta   AND
                                 craptfc.idseqttl = crapttl.idseqttl   AND
                                 craptfc.tptelefo = 1     
                                 NO-LOCK NO-ERROR.
                                     
        /* Telefone comercial */
        IF   NOT AVAILABLE craptfc   THEN
             FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper   AND
                                      craptfc.nrdconta = crapttl.nrdconta   AND
                                      craptfc.idseqttl = crapttl.idseqttl   AND
                                      craptfc.tptelefo = 3 
                                      NO-LOCK NO-ERROR.
    
        /* Telefone celular */
        IF   NOT AVAILABLE craptfc    THEN                       
             FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper   AND
                                      craptfc.nrdconta = crapttl.nrdconta   AND
                                      craptfc.idseqttl = crapttl.idseqttl   AND
                                      craptfc.tptelefo = 2
                                      NO-LOCK NO-ERROR.
 
        CREATE tt-info-cooperado.
        ASSIGN tt-info-cooperado.idseqttl = crapttl.idseqttl
               tt-info-cooperado.cdgraupr = 9  /* Nenhum */
               tt-info-cooperado.dsgraupr = "NENHUM"
               tt-info-cooperado.dsdemail = aux_dsdemail
               tt-info-cooperado.nminseve = crapttl.nmextttl.
        
        IF   AVAILABLE craptfc   THEN
             ASSIGN tt-info-cooperado.nrdddins = craptfc.nrdddtfc
                    tt-info-cooperado.nrtelefo = craptfc.nrtelefo.

    END.
    
    IF   NOT TEMP-TABLE tt-info-cooperado:HAS-RECORDS   THEN  /* P. juridica */
         DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                crapass.nrdconta = par_nrdconta   
                                NO-LOCK NO-ERROR.
                               
             /* Pega primeiro e-mail do titular da conta que achar */
             FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper   AND
                                      crapcem.nrdconta = par_nrdconta   AND
                                      crapcem.idseqttl = 1
                                      NO-LOCK NO-ERROR.
    
             IF   AVAILABLE crapcem   THEN
                  ASSIGN aux_dsdemail = crapcem.dsdemail.

             FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper   AND
                                      craptfc.nrdconta = par_nrdconta   AND
                                      craptfc.idseqttl = 1       
                                      NO-LOCK NO-ERROR.       
         
             CREATE tt-info-cooperado.
             ASSIGN tt-info-cooperado.idseqttl = 1
                    tt-info-cooperado.cdgraupr = 9
                    tt-info-cooperado.dsgraupr = "NENHUM" 
                    tt-info-cooperado.dsdemail = aux_dsdemail
                    tt-info-cooperado.nminseve = crapass.nmprimtl.

             IF   AVAILABLE craptfc   THEN
                  ASSIGN tt-info-cooperado.nrdddins = craptfc.nrdddtfc
                         tt-info-cooperado.nrtelefo = craptfc.nrtelefo.

         END.

    /* Trazer a lista de grau de parentesco */
    RUN grau-parentesco (INPUT  par_cdcooper,
                         INPUT  0,
                         INPUT  0,
                         INPUT  par_cdoperad,
                         INPUT  par_dtmvtolt,
                         INPUT  par_nrdconta,
                         INPUT  0, /* TODOS */
                         INPUT  par_idseqttl,
                         INPUT  par_idorigem,
                         INPUT  par_nmdatela,
                         INPUT  par_flgerlog,
                         OUTPUT TABLE tt-grau-parentesco).

    /* Verifica e traz registros se ja existe inscricao para esta conta */
    RUN inscricoes-da-conta(INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_rowidadp,
                            INPUT 1,
                            INPUT 1,
                            INPUT par_nmdatela,
                            INPUT FALSE,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-inscricoes-conta).

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".

         END.     

    DO WHILE TRUE:

        FIND crapadp WHERE ROWID(crapadp) = par_rowidadp NO-LOCK NO-ERROR.
    

        IF   NOT AVAIL crapadp   THEN
             DO:
                 aux_dscritic = "Registro da agenda de evento não encontrado". 
                 LEAVE.
             END.
             
        FIND crapedp WHERE crapedp.cdcooper = crapadp.cdcooper   AND
                           crapedp.idevento = crapadp.idevento   AND
                           crapedp.cdevento = crapadp.cdevento   AND
                           crapedp.dtanoage = crapadp.dtanoage   
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapedp   THEN
             DO:
                 aux_dscritic = "Registro do evento não encontrado".
                 LEAVE.
             END.

        /* Se eh evento exclusivo a cooperado */
        par_flgcoope = (crapedp.tppartic = 2).

        LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_dscritic <> ""   OR
         aux_cdcritic <> 0    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
         
             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
             RETURN "NOK".             
         END.
    
    IF   par_flgerlog   THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                             OUTPUT aux_nrdrowid).
         
    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************
Traz a lista de pessoas ja relacionadas com a conta especificada ao evento em
questao , familiares, conjuge , etc....
*****************************************************************************/ 

PROCEDURE inscricoes-da-conta:


    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_rowidadp AS ROWID                          NO-UNDO.

    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-inscricoes-conta.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-inscricoes-conta.

    FIND crapadp WHERE ROWID (crapadp) = par_rowidadp NO-LOCK NO-ERROR.
    

    IF   NOT AVAILABLE crapadp   THEN
         DO:
             aux_dscritic = "Registro da agenda de evento não encontrado".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
         
         END.
        
        
    /* Independente de o PAC em que aconteceu a inscricao */
        
    FOR EACH crapidp WHERE crapidp.cdcooper = par_cdcooper       AND
                           crapidp.nrdconta = par_nrdconta       AND
                           crapidp.dtanoage = crapadp.dtanoage   AND
                           crapidp.idevento = crapadp.idevento   AND
                           crapidp.cdevento = crapadp.cdevento   NO-LOCK
                           USE-INDEX crapidp6:
                           
             /* Assembleia */               
        IF   crapadp.cdagenci = 0   THEN
             FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                                crapage.cdagenci = crapidp.cdageins
                                NO-LOCK NO-ERROR.
        ELSE     
             FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                                crapage.cdagenci = crapidp.cdagenci 
                                NO-LOCK NO-ERROR.
             
        CREATE tt-inscricoes-conta.
        ASSIGN tt-inscricoes-conta.nminseve = crapidp.nminseve
               tt-inscricoes-conta.dtmvtolt = IF   crapidp.dtpreins = ?  THEN
                                                   "NÃO DEFINIDO"
                                              ELSE
                                                   STRING(crapidp.dtpreins,
                                                                  "99/99/9999")
               tt-inscricoes-conta.cdagenci = IF   AVAIL crapage   THEN
                                                   crapage.cdagenci
                                              ELSE
                                                   0
               tt-inscricoes-conta.nmresage = IF   AVAILABLE crapage     THEN
                                                   crapage.nmresage
                                              ELSE
                                                   "NÃO CADASTRADO".
    END.

    
    IF   par_flgerlog   THEN
         DO:
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT "",
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT TRUE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
         END.
    
    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************
Gravar na crapidp a pre-inscricao ao evento selecionado.
*****************************************************************************/

PROCEDURE grava-pre-inscricao:


    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_rowidedp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_rowidadp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_tpinseve AS LOGI                           NO-UNDO.
    DEF  INPUT  PARAM par_cdgraupr AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dsobserv AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgdispe AS LOGI                           NO-UNDO.
    DEF  INPUT  PARAM par_nminseve AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdddins AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrtelefo AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    
        
    DEF  VAR    retorno-erro       AS CHAR                           NO-UNDO.
    DEF  VAR    aux_nrdrowid       AS CHAR                           NO-UNDO. 
    
    DEF  VAR    h-b1wgen0009       AS HANDLE                         NO-UNDO.   


    EMPTY TEMP-TABLE tt-crapidp.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Criar a pre-inscricao para o evento".


    DO WHILE TRUE:

        IF   par_dsdemail = ""   AND 
             (par_nrdddins = 0   OR 
              par_nrtelefo = 0)  THEN
             DO:
                 aux_dscritic = "O campo de e-mail e/ou telefone devem ser prenchido.".
                 LEAVE.
             END.

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                aux_cdcritic = 9.
                LEAVE.
            END.
           
       FIND crapadp WHERE ROWID (crapadp) = par_rowidadp NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapadp   THEN
            DO:
                aux_dscritic = "Registro da agenda de evento não encontrado".
                LEAVE.
            END.
            
       FIND crapedp WHERE ROWID (crapedp) = par_rowidedp NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapedp   THEN
            DO:
                aux_dscritic = "Registro do evento não encontrado".
                LEAVE.
            END.

       CREATE tt-crapidp.

            /* Assembleia */
       IF   crapedp.tpevento = 7 THEN
            DO:
                ASSIGN tt-crapidp.cdagenci = 0
                       tt-crapidp.cdageins = crapass.cdagenci.
            END.
       ELSE 
            DO:
                ASSIGN tt-crapidp.cdagenci = crapadp.cdagenci
                       tt-crapidp.cdageins = crapadp.cdagenci.
            END.

        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */


       ASSIGN tt-crapidp.cdcooper = crapadp.cdcooper
              tt-crapidp.cdevento = crapadp.cdevento
              tt-crapidp.cdgraupr = par_cdgraupr
              tt-crapidp.cdoperad = par_cdoperad
              tt-crapidp.dsdemail = par_dsdemail
              tt-crapidp.dsobsins = par_dsobserv
              tt-crapidp.dtanoage = YEAR(par_dtmvtolt)
              tt-crapidp.flgdispe = par_flgdispe 
              tt-crapidp.dtconins = IF   tt-crapidp.flgdispe  THEN
                                         par_dtmvtolt 
                                    ELSE
                                         ?
              tt-crapidp.dtemcert = ?
              tt-crapidp.dtpreins = par_dtmvtolt
              tt-crapidp.flginsin = NO
              tt-crapidp.idevento = crapadp.idevento
              tt-crapidp.idseqttl = par_idseqttl
              tt-crapidp.idstains = IF   tt-crapidp.flgdispe  THEN
                                         2  /* Confirmada */
                                    ELSE
                                         1   /* Pendente */
              tt-crapidp.nminseve = par_nminseve
              tt-crapidp.nrdconta = par_nrdconta
              tt-crapidp.nrdddins = par_nrdddins
              tt-crapidp.nrseqdig = 0 
              tt-crapidp.nrseqeve = crapadp.nrseqdig
              tt-crapidp.nrtelins = par_nrtelefo
              tt-crapidp.qtfaleve = 0    
              /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
              tt-crapidp.cdopeori = par_cdoperad
              tt-crapidp.cdageori = par_cdagenci
              tt-crapidp.dtinsori = TODAY
              tt-crapidp.nrcpfcgc = par_nrcpfcgc
              /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
              tt-crapidp.tpinseve = IF   par_tpinseve   THEN 
                                         1  /* Propria */
                                    ELSE 
                                         2. /* Outra Pessoa */
           
       RUN sistema/progrid/web/dbo/b1wpgd0009.p 
                                       PERSISTEN SET h-b1wgen0009.
    
       RUN inclui-registro IN h-b1wgen0009 (INPUT TABLE tt-crapidp,
                                           OUTPUT retorno-erro,
                                           OUTPUT aux_nrdrowid).
       DELETE PROCEDURE h-b1wgen0009.

       IF   RETURN-VALUE <> "OK"   THEN
            DO:
                ASSIGN aux_dscritic = retorno-erro.
                LEAVE.
            END.
             
       LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF  par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
             RETURN "NOK".
         
         END.   

    ASSIGN par_nrdrowid = TO-ROWID (aux_nrdrowid).
    
    IF   par_flgerlog   THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                             OUTPUT aux_nrdrowid).         
    RETURN "OK".
    
END PROCEDURE.


/****************************************************************************
Procedure que traz a lista das inscricoes do evento selecionado. (Do cooperado
ou dos seus familiares, conjuge, etc ...)
*****************************************************************************/

PROCEDURE situacao-inscricao:


    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO. 
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_rowidedp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_rowidadp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-situacao-inscricao.
   
    
    DEF  VAR          aux_dsstaeve AS CHAR                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-situacao-inscricao.
    

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar a situacao da pre-inscricao do cooperado".
    
    
    FIND crapedp WHERE ROWID (crapedp) = par_rowidedp NO-LOCK NO-ERROR.
    
    FIND crapadp WHERE ROWID (crapadp) = par_rowidadp NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapedp   OR
         NOT AVAILABLE crapadp   THEN
         DO:
             IF   NOT AVAILABLE crapedp   THEN
                  aux_dscritic = "Registro do evento não encontrado".
             ELSE
                  aux_dscritic = "Registro da agenda do evento não encontrado".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
       
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
         
         END.
    
    /* Para cada inscricao da conta do evento selecionado */
   
    /* Independente de o PAC em que aconteceu a inscricao */
    
    FOR EACH crapidp  WHERE crapidp.cdcooper = par_cdcooper       AND
                            crapidp.nrdconta = par_nrdconta       AND
                            crapidp.idevento = crapadp.idevento   AND
                            crapidp.dtanoage = crapadp.dtanoage   AND
                            crapidp.cdevento = crapadp.cdevento   AND
                            crapidp.nrseqeve = crapadp.nrseqdig   NO-LOCK
                            USE-INDEX crapidp6:
        
        /* Descricao do status da inscricao */
        RUN obtem-situacao-inscricao(INPUT  crapidp.idstains,
                                     OUTPUT aux_dsstaeve). 

        CREATE tt-situacao-inscricao.
        ASSIGN tt-situacao-inscricao.rowididp = ROWID(crapidp)
               tt-situacao-inscricao.nmevento = crapedp.nmevento
               tt-situacao-inscricao.dtinieve = crapadp.dtinieve
               tt-situacao-inscricao.nminseve = crapidp.nminseve
               tt-situacao-inscricao.dsstaeve = aux_dsstaeve 
               tt-situacao-inscricao.dtconins = crapidp.dtconins
               tt-situacao-inscricao.flginsin = crapidp.flginsin.

    END.
    
    IF   par_flgerlog   THEN
         DO:
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT "",
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT TRUE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
         END.

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
Gravar na crapidp a nova situacao da inscricao ao evento selecionado.
****************************************************************************/

PROCEDURE grava-nova-situacao:


    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_rowididp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_opcaosit AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHARA                          NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT  PARAM TABLE FOR tt-erro.    
    
    DEF  VAR    h-b1wgen0009       AS HANDLE                         NO-UNDO.
    DEF  VAR    aux_idstains       AS INTE                           NO-UNDO.
    DEF  VAR    aux_retorno-erro   AS CHAR                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapidp.
    
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF par_opcaosit = 4 THEN "Excluir pre-inscricao do evento"
                          ELSE "Alterar a situacao da pre-inscricao do evento".
    

    RUN sistema/progrid/web/dbo/b1wpgd0009.p 
        PERSISTENT SET h-b1wgen0009.
        
    IF   NOT VALID-HANDLE (h-b1wgen0009)  THEN
         DO:
             ASSIGN aux_dscritic = "Handle invalido para h-b1wgen0009".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
         
         END.
    
    FIND crapidp WHERE ROWID (crapidp) = par_rowididp NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapidp   THEN
         DO:
             ASSIGN aux_dscritic = "Registro da inscricao não foi encontrado.".
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
         
         END.
         
    IF   par_opcaosit = 4   THEN  /* Excluido */
         aux_idstains = 5.
    ELSE 
    IF   par_opcaosit = 5   THEN
         aux_idstains = 4.        /* Excedente */
    ELSE
         aux_idstains = par_opcaosit.    

    CREATE tt-crapidp.

    BUFFER-COPY crapidp TO tt-crapidp.

    ASSIGN tt-crapidp.idstains = aux_idstains  
           tt-crapidp.dtaltera = par_dtmvtolt
           tt-crapidp.cdopinsc = par_cdoperad
           tt-crapidp.dtconins = IF   tt-crapidp.idstains = 1   THEN
                                      ? 
                                 ELSE
                                      par_dtmvtolt.  

    /* Se for situacao excluir, deve excluir o registro e
      nao apenas mudar a situaçao */
    IF par_opcaosit = 4   THEN  /* Excluir */
      DO:
        RUN exclui-registro IN h-b1wgen0009 (INPUT TABLE tt-crapidp,
                                             OUTPUT aux_retorno-erro).
                                             
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).                                     
      END.
    ELSE
      DO:
    RUN altera-registro IN h-b1wgen0009 (INPUT TABLE tt-crapidp,
                                         OUTPUT aux_retorno-erro).
      END.
    
    DELETE PROCEDURE h-b1wgen0009.

    IF   aux_retorno-erro <> ""   THEN
         DO:
             ASSIGN aux_dscritic = aux_retorno-erro.
              
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
              
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".
         
         END.
         
    RETURN "OK".

END PROCEDURE.


/****************************************************************************** 
Criar arquivo com o termo de compromisso do coooperado com o evento.
******************************************************************************/

PROCEDURE termo-de-compromisso:

    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_rowididp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_rowidedp AS ROWID                          NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-termo.
    
    
    DEF  VAR          aux_vldebito AS DECI                           NO-UNDO.   
    DEF  VAR          aux_dsdebito AS CHAR EXTENT 99                 NO-UNDO.
    DEF  VAR          aux_dsdtexto AS CHAR                           NO-UNDO.
    DEF  VAR          aux_dspacdat AS CHAR                           NO-UNDO.

    DEF  VAR          h-b1wgen9999 AS HANDLE                         NO-UNDO.
  
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-termo.
    
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Impressao do termo de compromisso"
           
           aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," +
                          "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".
    
    /* Utilizar para a procedure valor-extenso */
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    /* Dados cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    /* Inscricao */
    FIND crapidp WHERE ROWID (crapidp)  = par_rowididp NO-LOCK NO-ERROR.
 
    /* Evento */
    FIND crapedp WHERE ROWID (crapedp)  = par_rowidedp NO-LOCK NO-ERROR.
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta  
                       NO-LOCK NO-ERROR.

    IF   crapass.inpessoa = 1  THEN
         FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                            crapttl.nrdconta = par_nrdconta       AND
                            crapttl.idseqttl = crapidp.idseqttl
                            NO-LOCK NO-ERROR.


    IF   NOT AVAILABLE crapidp   OR   NOT AVAILABLE crapedp   OR
     
         NOT AVAILABLE crapcop   OR   NOT VALID-HANDLE (h-b1wgen9999) THEN
         DO:
             IF   NOT AVAILABLE crapidp   THEN
                  aux_dscritic = "Registro da inscricao não foi encontrado".
             ELSE
             IF   NOT AVAILABLE crapedp   THEN
                  aux_dscritic = "Registro do evento não foi encontrado".
             ELSE
             IF   NOT AVAILABLE crapcop    THEN
                  aux_cdcritic = 794.
             ELSE
                  aux_dscritic = "Handle invalido para a BO b1wgen9999".
             
                  
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
         
         END.
    
    /* Custo de evento */
    FIND crapcdp WHERE crapcdp.idevento = crapidp.idevento   AND
                       crapcdp.cdcooper = crapidp.cdcooper   AND
                       crapcdp.cdagenci = crapidp.cdagenci   AND
                       crapcdp.dtanoage = crapidp.dtanoage   AND
                       crapcdp.tpcuseve = 4                  AND
                       crapcdp.cdevento = crapidp.cdevento   AND
                       crapcdp.cdcuseve = 1                  NO-LOCK NO-ERROR.

    /* Nome do PAC */
    FIND crapage WHERE crapage.cdcooper = crapidp.cdcooper   AND
                       crapage.cdagenci = crapidp.cdagenci   NO-LOCK NO-ERROR.


    IF   NOT AVAILABLE crapcdp   OR   NOT AVAILABLE crapage   THEN
         DO:
             IF   NOT AVAILABLE crapcdp   THEN
                  aux_dscritic = "Registro de custo do evento não encontrado".
             ELSE
                  aux_cdcritic = 15.
                  
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog   THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".
             
         END.
    
    ASSIGN aux_vldebito = ((crapcdp.prdescon * crapcdp.vlcuseve) / 100) /
                          crapedp.qtmaxtur
                          
           aux_dspacdat = CAPS(crapage.nmresage) + ", "             + 
                          STRING(DAY(par_dtmvtolt),"z9")  + " de "  +
                          ENTRY(MONTH(par_dtmvtolt),aux_dsmesref)   + " de " + 
                          STRING(YEAR(par_dtmvtolt),"zzz9") + ".".

    RUN valor-extenso IN h-b1wgen9999 (INPUT  aux_vldebito, 
                                       INPUT 70, 
                                       INPUT 0, 
                                       INPUT "M",
                                       OUTPUT aux_dsdebito[1], 
                                       OUTPUT aux_dsdebito[2]). 
    DELETE PROCEDURE h-b1wgen9999. 

    CREATE tt-termo.
    ASSIGN tt-termo.nmextttl = IF   AVAILABLE crapttl   THEN
                                    CAPS(TRIM(crapttl.nmextttl))
                               ELSE
                                    crapass.nmprimtl
           tt-termo.tpinseve = crapidp.tpinseve 
           tt-termo.nminseve = CAPS(TRIM(crapidp.nminseve))
           tt-termo.nmevento = CAPS(TRIM(crapedp.nmevento))
           tt-termo.nmrescop = CAPS(TRIM(crapcop.nmrescop))
           tt-termo.nmextcop = CAPS(TRIM(crapcop.nmextcop))
           tt-termo.prfreque = crapedp.prfreque
           tt-termo.vldebito = aux_vldebito
           tt-termo.dsdebito = aux_dsdebito[1]
           tt-termo.prdescon = crapcdp.prdescon
           tt-termo.nrdconta = crapass.nrdconta
           tt-termo.dspacdat = aux_dspacdat.
    
    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".
    
END PROCEDURE.


/****************************************************************************
Procedure que traz os detalhes do evento selecionado.
****************************************************************************/

PROCEDURE obtem-detalhe-evento:

  DEF INPUT PARAM par_cdcooper AS INTE  NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE  NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE  NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR  NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE  NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE  NO-UNDO.
  DEF INPUT PARAM par_dtanoage AS INTE  NO-UNDO.
  DEF INPUT PARAM par_rowidedp AS ROWID NO-UNDO.
  DEF INPUT PARAM par_rowidadp AS ROWID NO-UNDO.
  DEF INPUT PARAM par_idseqttl AS INTE  NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE  NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR  NO-UNDO.
  DEF INPUT PARAM par_flgerlog AS LOGI  NO-UNDO.

  DEF OUTPUT PARAM TABLE FOR tt-erro.
  DEF OUTPUT PARAM TABLE FOR tt-detalhe-evento.
    
  DEF VAR aux_contador AS INTE           NO-UNDO.
  DEF VAR aux_nmfacili AS CHAR           NO-UNDO. 
  DEF VAR aux_dsconteu AS CHAR EXTENT 99 NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.
  EMPTY TEMP-TABLE tt-detalhe-evento.    

  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
         aux_dstransa = "Mostrar os detalhes do evento"
         aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," +
                        "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".

  /* Registro da tabela de cooperados */
  FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

  /* Encontra evento selecionado */
  FIND crapedp WHERE ROWID (crapedp) = par_rowidedp NO-LOCK NO-ERROR.

  /* Encontrar a agenda do evento selecionado */
  FIND crapadp WHERE ROWID (crapadp) = par_rowidadp NO-LOCK NO-ERROR.
                      
  IF NOT AVAILABLE crapadp OR NOT AVAILABLE crapcop OR NOT AVAILABLE crapedp THEN
    DO:
      IF NOT AVAILABLE crapadp   THEN
        aux_dscritic = "Registro da agenda do evento não foi encontrado".
      ELSE
        IF NOT AVAILABLE crapcop THEN
          aux_cdcritic = 651. 
        ELSE     
          aux_dscritic = "Registro do evento não foi encontrado".

      RUN gera_erro (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT 1,            /** Sequencia **/
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
             
      IF par_flgerlog   THEN
        RUN proc_gerar_log(INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT aux_dscritic,
                           INPUT aux_dsorigem,
                           INPUT aux_dstransa,
                           INPUT FALSE,
                           INPUT par_idseqttl,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                          OUTPUT aux_nrdrowid).
      RETURN "NOK".
    END.

  IF crapadp.idevento = 1 THEN /* PROGRID */
    DO:
      FIND FIRST crapldp WHERE crapldp.cdcooper = crapadp.cdcooper   
                           AND crapldp.idevento = 1                  
                           AND crapldp.cdagenci = crapadp.cdagenci   
                           AND crapldp.nrseqdig = crapadp.cdlocali NO-LOCK NO-ERROR.

      /* Custo do evento */
      FIND FIRST crapcdp WHERE crapcdp.cdcooper = crapadp.cdcooper  
                           AND crapcdp.idevento = crapadp.idevento   
                           AND crapcdp.cdevento = crapadp.cdevento   
                           AND crapcdp.cdagenci = crapadp.cdagenci   
                           AND crapcdp.dtanoage = par_dtanoage NO-LOCK NO-ERROR.

      IF AVAILABLE crapcdp THEN
        DO:
          /* Fornecedor do evento */
          FIND gnapfdp WHERE gnapfdp.cdcooper = 0               
                         AND gnapfdp.idevento = crapadp.idevento
                         AND gnapfdp.nrcpfcgc = crapcdp.nrcpfcgc NO-LOCK NO-ERROR.

          /* Cadastro de Propostas para eventos do Progrid */
          FIND gnappdp WHERE gnappdp.cdcooper = 0               
                         AND gnappdp.idevento = crapcdp.idevento
                         AND gnappdp.nrcpfcgc = crapcdp.nrcpfcgc
                         AND gnappdp.nrpropos = crapcdp.nrpropos NO-LOCK NO-ERROR.
                 
          IF AVAILABLE gnappdp THEN
            DO:
              /* Quebra o conteudo do curso em linhas */
              DO aux_contador = 1 TO NUM-ENTRIES(gnappdp.dsconteu,";"):
      
                ASSIGN aux_dsconteu[aux_contador] = ENTRY(aux_contador,gnappdp.dsconteu,";") NO-ERROR.
                                       
                /* Comecar com asterisco  */
                ASSIGN aux_dsconteu[aux_contador] = REPLACE (aux_dsconteu[aux_contador],KEYFUNCTION(149),"* ").
                
              END. /* AVAILABLE gnappdp */
                          
              FIND FIRST gnfacep WHERE gnfacep.cdcooper = 0
                                   AND gnfacep.idevento = gnappdp.idevento 
                                   AND gnfacep.nrcpfcgc = gnappdp.nrcpfcgc
                                   AND gnfacep.nrpropos = gnappdp.nrpropos NO-LOCK NO-ERROR.

              IF AVAILABLE gnfacep THEN
                DO:
                  FIND gnapfep WHERE gnapfep.cdcooper = 0   
                                 AND gnapfep.nrcpfcgc = gnfacep.nrcpfcgc
                                 AND gnapfep.cdfacili = gnfacep.cdfacili
                                 AND gnapfep.idevento = gnfacep.idevento NO-LOCK NO-ERROR.
                                    
                  IF AVAILABLE gnapfep THEN
                    ASSIGN aux_nmfacili = gnapfep.nmfacili.

                END. /* AVAILABLE gnfacep */
          
          END. /* AVAILABLE gnappdp */
        END. /* AVAILABLE crapcdp */
    END. /* FIM PROGRID */
  ELSE IF crapadp.idevento = 2 THEN /* ASSEMBLEIAS */
    DO:
      /* LOCAL */
      FIND FIRST crapldp WHERE crapldp.cdcooper = crapadp.cdcooper
                           AND crapldp.idevento = 1 /* IDEVENTO é sempre 1 para locais */
                           AND crapldp.nrseqdig = crapadp.cdlocali NO-LOCK NO-ERROR NO-WAIT.
                           
      /* FACILITADOR */                     
      FIND FIRST crapfea WHERE crapfea.cdcooper = crapadp.cdcooper
                           AND crapfea.nrseqfea = crapadp.nrseqfea
                           AND crapfea.idsitfea = 1 NO-LOCK NO-ERROR NO-WAIT.
                                   
      IF AVAILABLE crapfea THEN
        DO:
          ASSIGN aux_nmfacili = crapfea.nmfacili.
        END.                                   
                                   
    END. /* FIM ASSEMBLEIAS */
      
  CREATE tt-detalhe-evento.
  ASSIGN tt-detalhe-evento.nmevento = crapedp.nmevento
         tt-detalhe-evento.dshroeve = crapadp.dshroeve WHEN crapadp.dshroeve <> ""
         tt-detalhe-evento.dslocali = crapldp.dslocali WHEN AVAIL crapldp
         tt-detalhe-evento.nmfacili = aux_nmfacili WHEN aux_nmfacili <> ""
         tt-detalhe-evento.dtinieve = IF crapadp.dtinieve = ? THEN ENTRY(crapadp.nrmeseve,aux_dsmesref) ELSE STRING(crapadp.dtinieve,"99/99/9999")
         tt-detalhe-evento.dtfineve = IF crapadp.dtfineve = ? THEN ENTRY(crapadp.nrmeseve,aux_dsmesref) ELSE STRING(crapadp.dtfineve,"99/99/9999").
                                         
  /* Alimenta o campo fornecedor - Quando ASSEMBLEIA o fornecedor eh a propria cooperativa */

  IF AVAILABLE gnapfdp THEN
    ASSIGN tt-detalhe-evento.nmfornec = gnapfdp.nmfornec.
  ELSE IF crapadp.cdagenci = 0 OR crapadp.cdevento = 4 THEN     
    ASSIGN tt-detalhe-evento.nmfornec = crapcop.nmextcop. 

  /* Conteudo do curso */
  DO aux_contador = 1 TO 99:

    IF aux_dsconteu[aux_contador] = ""  THEN
      LEAVE.     

    ASSIGN tt-detalhe-evento.dsconteu[aux_contador] = aux_dsconteu[aux_contador].
 
  END.
           
  IF par_flgerlog  THEN
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).
  RETURN "OK".

END PROCEDURE.


/*****************************************************************************
Trazer todos os eventos de um periodo especifico ou de todos os anos
na qual o cooperado tem uma situacao relacionada a ele.
*****************************************************************************/

PROCEDURE lista-eventos:


    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_inianoev AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_finanoev AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT  PARAM TABLE FOR tt-lista-eventos.

    DEF  VAR    aux_nrctaant       AS INTE                           NO-UNDO.
    DEF  VAR    aux_cdcopant       AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-lista-eventos.

    FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                       craptco.nrdconta = par_nrdconta AND
                       craptco.tpctatrf <> 3
                       NO-LOCK NO-ERROR NO-WAIT.

    IF AVAIL craptco THEN
        ASSIGN aux_cdcopant = craptco.cdcopant
               aux_nrctaant = craptco.nrctaant.
    ELSE
        ASSIGN aux_cdcopant = par_cdcooper
               aux_nrctaant = par_nrdconta.


    /* Para todas as inscricoes do cooperado */
    FOR EACH crapidp FIELDS (crapidp.cdcooper crapidp.idevento crapidp.dtanoage
                             crapidp.cdagenci crapidp.cdevento crapidp.nrseqeve)
                      WHERE (crapidp.cdcooper = par_cdcooper   AND
                            crapidp.nrdconta = par_nrdconta ) OR
                           (crapidp.cdcooper = aux_cdcopant   AND
                            crapidp.nrdconta = aux_nrctaant ) NO-LOCK,
        FIRST crapadp WHERE crapadp.cdcooper = crapidp.cdcooper   AND
                            crapadp.idevento = crapidp.idevento   AND
                            crapadp.dtanoage = crapidp.dtanoage   AND
                            crapadp.cdagenci = crapidp.cdagenci   AND
                            crapadp.cdevento = crapidp.cdevento   AND
                            crapadp.nrseqdig = crapidp.nrseqeve   NO-LOCK,
        FIRST crapedp WHERE crapedp.cdcooper = crapadp.cdcooper   AND
                            crapedp.idevento = crapadp.idevento   AND
                            crapedp.cdevento = crapadp.cdevento   AND
                            crapedp.dtanoage = crapadp.dtanoage   NO-LOCK
                            BY crapedp.nmevento:

        /* Segundo periodo selecionado */
        IF   par_inianoev > 0   AND   par_finanoev > 0  THEN
             DO:
                 IF   crapadp.dtanoage < par_inianoev   OR
                      crapadp.dtanoage > par_finanoev   THEN
                      NEXT.
             END.
        
        /* Se nao tem data marcada */
        IF   crapadp.dtinieve = ?    THEN
            NEXT.
             

        /* Se ainda nao encerrou ... proximo */
        IF   crapadp.dtfineve >= par_dtmvtolt    THEN
            NEXT.

        /* Soh uma vez cada evento */
        IF   CAN-FIND (tt-lista-eventos WHERE 
                       tt-lista-eventos.idevento = crapadp.idevento   AND
                       tt-lista-eventos.cdevento = crapadp.cdevento)  THEN
                        NEXT.

        CREATE tt-lista-eventos.
        ASSIGN tt-lista-eventos.nmevento = crapedp.nmevento
               tt-lista-eventos.idevento = crapedp.idevento
               tt-lista-eventos.cdevento = crapedp.cdevento.   


    END.
    
    RETURN "OK".
    
END PROCEDURE.



/****************************************************************************
Procedure que traz a lista do historico da participacao do evento selecionado
do cooperado ou seus familiares, conjuge, etc ...
*****************************************************************************/

PROCEDURE obtem-historico:


    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_inipesqu AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_finpesqu AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idevento AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdevento AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_tpimpres AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT  PARAM TABLE FOR tt-historico-evento.
    DEF OUTPUT  PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF OUTPUT  PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    /* Flag Compareceu */
    DEF  VAR          aux_flgfrequ AS LOGI                           NO-UNDO.
    DEF  VAR          aux_dsstains AS CHAR                           NO-UNDO.
    DEF  VAR          aux_nmevento AS CHAR INIT "Todos os eventos."  NO-UNDO.
    DEF  VAR          aux_nrctaant AS INTE                           NO-UNDO.
    DEF  VAR          aux_cdcopant AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-historico-evento.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar historico de participacao do cooperado".

    FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                       craptco.nrdconta = par_nrdconta AND
                       craptco.tpctatrf <> 3
                       NO-LOCK NO-ERROR NO-WAIT.

    IF AVAIL craptco THEN
        ASSIGN aux_cdcopant = craptco.cdcopant
               aux_nrctaant = craptco.nrctaant.
    ELSE
        ASSIGN aux_cdcopant = par_cdcooper
               aux_nrctaant = par_nrdconta.

    FOR EACH crapidp FIELDS(crapidp.cdcooper crapidp.idevento crapidp.cdevento
                            crapidp.dtanoage crapidp.cdagenci crapidp.nrseqeve
                            crapidp.idstains crapidp.qtfaleve crapidp.nrdconta
                            crapidp.nminseve)
                     WHERE (crapidp.cdcooper = par_cdcooper   AND
                            crapidp.nrdconta = par_nrdconta)  OR
                           (crapidp.cdcooper = aux_cdcopant   AND  
                            crapidp.nrdconta = aux_nrctaant)  NO-LOCK,
        FIRST crapadp WHERE crapadp.cdcooper = crapidp.cdcooper   AND
                            crapadp.idevento = crapidp.idevento   AND
                            crapadp.cdevento = crapidp.cdevento   AND
                            crapadp.dtanoage = crapidp.dtanoage   AND
                            crapadp.cdagenci = crapidp.cdagenci   AND
                            crapadp.nrseqdig = crapidp.nrseqeve   NO-LOCK,
        FIRST crapedp WHERE crapedp.cdcooper = crapadp.cdcooper   AND
                            crapedp.idevento = crapadp.idevento   AND
                            crapedp.cdevento = crapadp.cdevento   AND   
                            crapedp.dtanoage = crapadp.dtanoage   NO-LOCK
                            BY crapedp.nmevento
                               BY crapidp.nminseve
                                   BY crapadp.dtinieve:

        /* Nao iniciou */
        IF   crapadp.dtinieve = ?   THEN
             NEXT.
             
        /* Nao terminou */
        IF   crapadp.dtfineve >= par_dtmvtolt   THEN
             NEXT.

        /* Cancelado - Nao devera listar */
        IF  crapadp.idstaeve = 2 THEN
            NEXT.

        IF   par_idevento > 0   AND   par_cdevento > 0   THEN
             DO:
                 IF   crapadp.cdevento <> par_cdevento   OR
                      crapadp.idevento <> par_idevento   THEN
                      NEXT.

                 /* Nome do evento */
                 ASSIGN aux_nmevento = crapedp.nmevento.
             END.
    
        IF   par_inipesqu > 0   AND   par_finpesqu > 0   THEN
             DO:
                 IF   crapadp.dtanoage < par_inipesqu    OR
                      crapadp.dtanoage > par_finpesqu    THEN
                      NEXT.
             END.

        IF   crapidp.idstains = 2   AND     /* Se confirmou e faltou */
             crapidp.qtfaleve > 0   THEN     /* pelo menos um dia ... */
             DO:
                 RUN verifica-frequencia(INPUT crapidp.qtfaleve,
                                         INPUT crapadp.qtdiaeve,
                                         INPUT crapedp.prfreque,
                                        OUTPUT aux_flgfrequ).

                 aux_dsstains = IF   aux_flgfrequ   THEN
                                     "Freq.Insufic"
                                ELSE
                                     "Compareceu".
             END.
        ELSE
        IF   crapidp.idstains = 2   THEN   /* Confirmou e participou */
             DO:
                 aux_dsstains = "Compareceu".
             END.
        ELSE                                        /* Nao confirmou ... */
             DO:
                 RUN obtem-situacao-inscricao(INPUT crapidp.idstains,
                                             OUTPUT aux_dsstains).
             END.

        /* Se a conta já pertenceu à outra Coop. e tem eventos para listar */
        IF  aux_cdcopant <> par_cdcooper    AND
            crapidp.cdcooper = aux_cdcopant AND
            crapidp.nrdconta = aux_nrctaant THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = aux_cdcopant
                                          NO-LOCK NO-ERROR NO-WAIT.

                CREATE tt-historico-evento.
                ASSIGN tt-historico-evento.nminseve = crapidp.nminseve
                       tt-historico-evento.nmevento = STRING(crapedp.nmevento +
                                                      " (" + CAPS(crapcop.nmrescop)
                                                      + ")")
                       tt-historico-evento.dtinieve = crapadp.dtinieve
                       tt-historico-evento.dtfineve = crapadp.dtfineve
                       tt-historico-evento.dsstains = aux_dsstains.

                NEXT.

            END.
             
        CREATE tt-historico-evento.
        ASSIGN tt-historico-evento.nminseve = crapidp.nminseve
               tt-historico-evento.nmevento = crapedp.nmevento
               tt-historico-evento.dtinieve = crapadp.dtinieve
               tt-historico-evento.dtfineve = crapadp.dtfineve
               tt-historico-evento.dsstains = aux_dsstains.

    END.
    
    IF   par_tpimpres = "I"   THEN  /* Impressao */
         DO:
             RUN imprime-historico (INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_idorigem,
                                    INPUT par_inipesqu,
                                    INPUT par_finpesqu,
                                    INPUT aux_nmevento,
                                    INPUT TABLE tt-historico-evento,
                                   OUTPUT par_nmarquiv,
                                   OUTPUT par_nmarqpdf).                
         END.

    IF   par_flgerlog   THEN
         DO:
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT "",
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT TRUE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
         END.
    
    RETURN "OK".
    
END PROCEDURE.


PROCEDURE imprime-historico:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_inipesqu AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_finpesqu AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmevento AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-historico-evento. 
    DEF OUTPUT PARAM par_nmarquiv  AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf  AS CHAR                           NO-UNDO.
                                                                     
    DEF  VAR          aux_dsperiod AS CHAR                           NO-UNDO.
    DEF  VAR          aux_nmendter AS CHAR                           NO-UNDO.
    DEF  VAR          aux_server   AS CHAR                           NO-UNDO.
    DEF  VAR          aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF  VAR          h-b1wgen0024 AS HANDLE                         NO-UNDO.
    


    FORM tt-historico-evento.nminseve COLUMN-LABEL "Nome inscrito" FORMAT "x(50)"
         tt-historico-evento.nmevento COLUMN-LABEL "Nome evento"   FORMAT "x(43)"
         tt-historico-evento.dsstains COLUMN-LABEL "Situacao"      FORMAT "x(12)"
         tt-historico-evento.dtinieve COLUMN-LABEL "Inicio"        FORMAT "99/99/9999"
         tt-historico-evento.dtfineve COLUMN-LABEL "Fim"           FORMAT "99/99/9999"
         WITH  WIDTH 132 DOWN FRAME f_historico. 


    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.

    INPUT THROUGH basename `hostname -s` NO-ECHO.
    IMPORT UNFORMATTED aux_server.
    INPUT CLOSE.
    
    aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                          aux_nmendter.
             
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
            
    ASSIGN par_nmarquiv = "/usr/coop/" + TRIM(crapcop.dsdircop) +    
                          "/rl/" + aux_nmendter + STRING(TIME) + ".ex".

    OUTPUT STREAM str_1 TO VALUE (par_nmarquiv) PAGE-SIZE 84 PAGED.

    /* Cdempres = 11 , Relatorio 590 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "590" "132" }

    /* Verificar periodo de consulta */
    IF   par_inipesqu = 0   THEN
         IF   par_finpesqu = 0   THEN
              aux_dsperiod = "Todo o periodo.".
         ELSE
              aux_dsperiod = "Ate o ano de " + STRING (par_finpesqu) + ".".
    ELSE                        
         IF   par_finpesqu = 0   THEN
              aux_dsperiod =
                           "A partir do ano de " + STRING (par_inipesqu) + ".".
         ELSE
              aux_dsperiod = "A partir do ano de " + STRING (par_inipesqu) + 
                           " ate o ano de "      + STRING (par_finpesqu) + ".".   

    RUN fontes/substitui_caracter.p 
                (INPUT-OUTPUT par_nmevento).  

    DISPLAY STREAM str_1 "Periodo de consulta:"
                         aux_dsperiod FORMAT "x(50)"
                         SKIP
                         WITH SIDE-LABEL NO-LABEL FRAME f_periodo.
           
    DISPLAY STREAM str_1 "             Evento:"
                         par_nmevento FORMAT "x(50)"
                         SKIP(1)
                         WITH SIDE-LABEL NO-LABEL FRAME f_evento.

    FOR EACH tt-historico-evento NO-LOCK:
                          
        RUN fontes/substitui_caracter.p 
                (INPUT-OUTPUT tt-historico-evento.nminseve).

        RUN fontes/substitui_caracter.p 
                (INPUT-OUTPUT tt-historico-evento.nmevento).

        RUN fontes/substitui_caracter.p
                (INPUT-OUTPUT tt-historico-evento.dsstains).
               
        DISPLAY STREAM str_1 tt-historico-evento WITH FRAME f_historico.

        DOWN WITH FRAME f_historico.
    END.

    OUTPUT STREAM str_1 CLOSE.

    /* Se for do Ayllos Web , criar o PDF e copiar para o servidor */
    IF   par_idorigem = 5   THEN 
         DO:
             aux_nmarqpdf = REPLACE(par_nmarquiv,".ex",".pdf").

             RUN sistema/generico/procedures/b1wgen0024.p 
                  PERSISTENT SET h-b1wgen0024.

             /* Gerar o PDF */
             RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarquiv,
                                                     INPUT aux_nmarqpdf).

             DELETE PROCEDURE h-b1wgen0024.

             /* Copiar para o servidor */
             UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                '/temp/" 2>/dev/null').

             /* Remover arquivos nao mais necessarios */
             UNIX SILENT VALUE ("rm " + par_nmarquiv + "* 2>/dev/null").
             UNIX SILENT VALUE ("rm " + aux_nmarqpdf + "* 2>/dev/null").
                                                      
             /* Nome do PDF para devolver como parametro */
             par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/"). 

         END.
         
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
Gravar datas de entrega/devolucao do questionario do cooperado na crapass
*****************************************************************************/

PROCEDURE grava-data-questionario:

    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtinique AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtfimque AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT  PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.    

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gravar datas de entrega/devolucao do questionario".
    
    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta 
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
       IF   NOT AVAILABLE crapass   THEN
            DO:
                IF   LOCKED crapass   THEN
                     DO:
                         aux_cdcritic = 77.
                         LEAVE.
                     END.
                ELSE   
                     DO:
                         aux_cdcritic = 9.
                         LEAVE.
                     END.
            END.

       FIND FIRST crapdat WHERE crapdat.cdcoope = par_cdcooper NO-LOCK NO-ERROR.
          
       /* Se Data de entrega do questionario em branco */
       IF   par_dtinique = ?  THEN
            DO:
                aux_cdcritic = 13.
                LEAVE.
            END.

       IF   par_dtinique > crapdat.dtmvtolt   THEN
            DO:
                aux_dscritic = 
                    "Data de entrega não pode ser maior que a data atual.".
                LEAVE.
            END.

       /* Se data de devolucao do questionaro prenchida */
       IF   par_dtfimque <> ?  THEN
            DO:
                IF   par_dtfimque > crapdat.dtmvtolt   THEN
                     DO:
                         aux_dscritic = 
                    "Data de devoluçao não pode ser maior que a data atual.".
                         LEAVE.
                     END.

                IF   par_dtinique > par_dtfimque   THEN
                     DO:
                         aux_dscritic = 
                    "Data de entrega não pode ser maior que a data da devolucao.".
                         LEAVE.

                     END.

            END.

       ASSIGN crapass.dtentqst = par_dtinique
              crapass.dtdevqst = par_dtfimque.

       IF crapass.dtcadqst <> ?  THEN
           LEAVE.
       ELSE
          IF crapass.dtdevqst <> ? THEN
             ASSIGN crapass.dtcadqst = par_dtmvtolt.

       LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
                           
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid).
             RETURN "NOK".

         END.

    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
                               PROCEDURES INTERNAS
******************************************************************************/


/******************************************************************************
Filtra os eventos em andamento dependendo se a inscricao estiver como
par_dsobserv ==>  C - Confirmada ou P - Pendente
******************************************************************************/

PROCEDURE filtra-eventos:

    DEF  INPUT PARAM par_dsobserv AS CHAR                            NO-UNDO.
    DEF  INPUT-OUTPUT PARAM TABLE FOR tt-eventos-andamento.
    

    /* Se a inscricao for diferente do que par_dsobserv remove */
     
    FOR EACH tt-eventos-andamento WHERE NOT tt-eventos-andamento.dsobserv 
         
                        MATCHES "*" + par_dsobserv + "*" EXCLUSIVE-LOCK:
             
        DELETE  tt-eventos-andamento.
             
    END.         

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
Traz o PAC agrupador do pac em questao. 
******************************************************************************/

PROCEDURE obtem-agrupador:

    DEF  INPUT PARAM par_idevento AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtanoage AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
 
    DEF OUTPUT PARAM par_cdageagr AS INTE                            NO-UNDO.
    
    FIND crapagp WHERE crapagp.idevento = par_idevento   AND
                       crapagp.cdcooper = par_cdcooper   AND
                       crapagp.dtanoage = par_dtanoage   AND
                       crapagp.cdagenci = par_cdagenci   NO-LOCK NO-ERROR.
                       
    /* Usa o agrupador */
    ASSIGN par_cdageagr = IF   AVAILABLE crapagp   THEN
                               crapagp.cdageagr
                          ELSE
                               par_cdagenci.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
Procedure para trazer a situacao da inscricao ao evento do cooperado.
******************************************************************************/

PROCEDURE obtem-situacao-inscricao:

    
    DEF  INPUT PARAM par_idstains AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_dsstains AS CHAR                            NO-UNDO.


    FIND craptab WHERE craptab.cdcooper = 0               AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "CONFIG"        AND
                       craptab.cdempres = 0               AND
                       craptab.cdacesso = "PGSTINSCRI"    AND
                       craptab.tpregist = 0               NO-LOCK NO-ERROR.


    ASSIGN par_dsstains = IF   AVAILABLE craptab   THEN
                               ENTRY(LOOKUP(STRING(par_idstains),
                                      craptab.dstextab) - 1,craptab.dstextab)
                          ELSE
                               "".

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************
Obtem o tipo de participacao do evento, se eh exclusivo a cooperados, limitado
por conta, aberto a comunidade ...
******************************************************************************/

PROCEDURE obtem-tipo-participacao:


    DEF  INPUT PARAM par_tppartic AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_dspartic AS CHAR                            NO-UNDO.


    FIND craptab WHERE craptab.cdcooper = 0              AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "CONFIG"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "PGTPPARTIC"   AND
                       craptab.tpregist = 0              NO-LOCK NO-ERROR.

    ASSIGN par_dspartic = IF   AVAILABLE craptab   THEN
                               ENTRY(LOOKUP(STRING(par_tppartic),
                                   craptab.dstextab) - 1,craptab.dstextab)
                          ELSE
                               "".
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************
 Traz flag pra verificar se a frequencia no evento foi suficiente 
 Quando TRUE Desaprovado Senao Aprovado
******************************************************************************/

PROCEDURE verifica-frequencia:

    DEF  INPUT PARAM par_qtfaleve AS INTE                            NO-UNDO.  
    DEF  INPUT PARAM par_qtdiaeve AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_prfreque AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_flgfrequ AS LOGI                            NO-UNDO.
    
    par_flgfrequ = ((par_qtfaleve * 100) / par_qtdiaeve) > (100 - par_prfreque).

    RETURN "OK".

END PROCEDURE.


/*...........................................................................*/