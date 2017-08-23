/*..............................................................................

   Programa: b1wgen0195.p
   Autora  : Odirlei Busana - AMcom.
   Data    : 09/03/2016                        Ultima atualizacao: 02/05/2017

   Dados referentes ao programa:

   Objetivo  : BO - Rotinas para envio de informacoes para a Esteira de Credito

   Alteracoes: 02/05/2017 - Ajustes PRJ337 - Motor de Credito (Odirlei-Amcom)

 ..............................................................................*/

/*................................ DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0002tt.i  }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }  

DEF VAR h-b1wgen0002  AS HANDLE                                        NO-UNDO.


/*............................ PROCEDURES EXTERNAS ...........................*/

/******************************************************************************/
/**           Procedure para verificar regras da esteira                     **/
/******************************************************************************/
PROCEDURE verifica_regras_esteira:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpenvest AS CHAR							NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_regras_esteira
    aux_handproc = PROC-HANDLE
       (INPUT par_cdcooper,   /* pr_cdcooper */
        INPUT par_nrdconta,   /* pr_nrdconta */
        INPUT par_nrctremp,   /* pr_nrctremp*/
        INPUT par_tpenvest,   /* pr_tpenvest*/
        OUTPUT 0,             /* pr_cdcritic */
        OUTPUT ""             /* pr_dscritic */
        ).

    CLOSE STORED-PROCEDURE pc_verifica_regras_esteira WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

          ASSIGN par_cdcritic = 0
           par_cdcritic = pc_verifica_regras_esteira.pr_cdcritic
                          WHEN pc_verifica_regras_esteira.pr_cdcritic <> ?
           par_dscritic = ""
           par_dscritic = pc_verifica_regras_esteira.pr_dscritic
                          WHEN pc_verifica_regras_esteira.pr_dscritic <> ?.    
                          
   IF par_cdcritic > 0 OR 
      par_dscritic <> "" THEN                       
   DO:
     RETURN "NOK".
   END.
   
   RETURN "OK".    
    
END.    

PROCEDURE gerar_proposta_pdf:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.  
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_recidepr          AS INTE                           NO-UNDO.    
    DEF VAR aux_flgentrv          AS LOGI                           NO-UNDO.      
    DEF VAR aux_nmarqimp          AS CHAR                           NO-UNDO.    
    DEF VAR aux_nmarqpdf          AS CHAR                           NO-UNDO.   
    DEF VAR aux_flcontes          AS CHAR                           NO-UNDO.  

    /* Buscar emprestimo */
    FIND FIRST crawepr
      WHERE crawepr.cdcooper = par_cdcooper
        AND crawepr.nrdconta = par_nrdconta
        AND crawepr.nrctremp = par_nrctremp
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE crawepr THEN    
      ASSIGN aux_recidepr = RECID(crawepr).
   
   
    /* Gerar impressao do contrato */  
    IF  VALID-HANDLE(h-b1wgen0002)  THEN
        DELETE PROCEDURE h-b1wgen0002.

    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT
        SET h-b1wgen0002.

    IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
        DO:
            ASSIGN par_dscritic = "Handle invalido para BO " +
                                  "b1wgen0002.".

            RETURN "NOK". 
        END.       
    
    /* chamar rotina responsave por gerar proposta */
    RUN gera-impressao-empr IN h-b1wgen0002  
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT 9, /* ESTEIRA par_idorigem,*/
                              INPUT par_nrdconta,
                              INPUT 1,            /*par_idseqttl,*/
                              INPUT par_dtmvtolt,
                              INPUT par_dtmvtopr,
                              INPUT FALSE,
                              INPUT aux_recidepr,
                              INPUT 3,           /* Proposta par_idimpres */
                              INPUT false,
                              INPUT 0,
                              INPUT false,       /*flgemail*/
                              INPUT par_dsiduser,
                              INPUT par_dtmvtolt,/*par_dtcalcul*/
                              INPUT 1,           /*par_inproces,*/
                              INPUT 0,           /*par_promsini,*/
                              INPUT "ATENDA",    /*par_cdprogra*/
                              INPUT FALSE,       /*par_flgentra,*/
                             OUTPUT aux_flgentrv,
                             OUTPUT aux_nmarqimp,
                             OUTPUT aux_nmarqpdf,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0002.
                    ASSIGN par_dscritic = tt-erro.dscritic.
                    RETURN "NOK".
                END.
            ELSE
            DO:
                DELETE PROCEDURE h-b1wgen0002.
                ASSIGN par_dscritic = "Nao foi possivel gerar impressao " + 
                                      "da proposta do contrato.".
                RETURN "NOK".
            END.
        END.

    DELETE PROCEDURE h-b1wgen0002.
    
    ASSIGN par_nmarqpdf = aux_nmarqpdf.
    RETURN "OK". 

END.


/******************************************************************************/
/**           Procedure para incluir ou alterar propasta na esteira          **/
/******************************************************************************/
PROCEDURE Enviar_proposta_esteira:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.  
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp_novo AS INTE                      NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flreiflx AS INTE                           NO-UNDO.
    /* Tipo de envio dos dados para a Esteira 
       I - inclusao Proposta
       D - Derivacao Proposta
       A - Alteracao Proposta
       N - Alterar Numero Proposta
       C - Cancelar Proposta
       E - Efetivar Proposta */
    DEF  INPUT PARAM par_tpenvest AS CHAR                           NO-UNDO.  
    
    DEF OUTPUT PARAM par_dsmensag AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_recidepr          AS INTE                           NO-UNDO.    
    DEF VAR aux_flgentrv          AS LOGI                           NO-UNDO.      
    DEF VAR aux_nmarqimp          AS CHAR                           NO-UNDO.    
    DEF VAR aux_nmarqpdf          AS CHAR                           NO-UNDO.   
    DEF VAR aux_flcontes          AS CHAR                           NO-UNDO.   
    
    /* Caso a proposta j� tenha sido enviada para a Esteira iremos considerar uma Alteracao. 
       Caso a proposta tenho sido reprovada pelo Motor, iremos considerar envio pois ela
       ainda nao foi a Esteira  */
       
    IF par_tpenvest = "I" THEN
      DO:
          FIND FIRST crawepr 
          WHERE crawepr.cdcooper = par_cdcooper
            AND crawepr.nrdconta = par_nrdconta
            AND crawepr.nrctremp = par_nrctremp
          NO-LOCK NO-ERROR.

		  IF AVAIL crawepr AND crawepr.dtenvest <> ? then
                  ASSIGN par_tpenvest = "A".  
    END.
        
    /***** Verificar se a Esteira esta em contigencia *****/
    RUN verifica_regras_esteira
             ( INPUT par_cdcooper,
               INPUT par_nrdconta,
               INPUT par_nrctremp,
               INPUT par_tpenvest,
              OUTPUT par_cdcritic,
              OUTPUT par_dscritic).
   
    IF par_cdcritic > 0 OR 
       par_dscritic <> "" THEN                       
    DO:       
       RETURN "NOK".
    END.
    
    
    /* Gerar impressao da proposta em PDF para as opcoes abaixo*/
    IF CAN-DO("I,A,D,E",par_tpenvest) THEN
    DO:
        RUN gerar_proposta_pdf(
                     INPUT par_cdcooper
                    ,INPUT par_cdagenci 
                    ,INPUT par_nrdcaixa 
                    ,INPUT par_nmdatela
                    ,INPUT par_cdoperad    
                    ,INPUT par_idorigem
                    ,INPUT par_nrdconta  
                    ,INPUT par_dtmvtolt
                    ,INPUT par_dtmvtopr
                    ,INPUT par_nrctremp
                    ,INPUT par_dsiduser                                       
                   ,OUTPUT aux_nmarqpdf
                   ,OUTPUT par_cdcritic
                   ,OUTPUT par_dscritic).
      IF par_cdcritic > 0 OR 
         par_dscritic <> "" THEN                       
      DO:              
       RETURN "NOK".
      END.      
      
      IF aux_nmarqpdf = ""  THEN
      DO:
        par_dscritic = "Nao foi possivel gerar impressao da proposta " + 
                       "para Analise de Credito.".
        RETURN "NOK".
      END.
    END.
      
    /***** INCLUIR/DERIVAR PROPOSTA *****/ 
    IF CAN-DO("I,D",par_tpenvest) THEN
      DO:
        
        /* Chamar rotina de inclusao da proposta na Esteira*/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_incluir_proposta_est aux_handproc = PROC-HANDLE
           (INPUT par_cdcooper,   /* pr_cdcooper */
            INPUT par_cdagenci,   /* pr_cdagenci */ 
            INPUT par_cdoperad,   /* pr_cdoperad */
            INPUT par_idorigem,   /* pr_cdorigem */
            INPUT par_nrdconta,   /* pr_nrdconta */
            INPUT par_nrctremp,   /* pr_nrctremp */
            INPUT par_dtmvtolt,   /* pr_dtmvtolt */
            INPUT aux_nmarqpdf,   /* pr_nmarquiv */
            OUTPUT "",            /* pr_dsmensag */
            OUTPUT 0,             /* pr_cdcritic */
            OUTPUT ""             /* pr_dscritic */
            ).        

        CLOSE STORED-PROCEDURE pc_incluir_proposta_est WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN par_dsmensag = ""
               par_dsmensag = pc_incluir_proposta_est.pr_dsmensag
                              WHEN pc_incluir_proposta_est.pr_dsmensag <> ?
        
               par_cdcritic = 0
               par_cdcritic = pc_incluir_proposta_est.pr_cdcritic
                              WHEN pc_incluir_proposta_est.pr_cdcritic <> ?
               par_dscritic = ""
               par_dscritic = pc_incluir_proposta_est.pr_dscritic
                              WHEN pc_incluir_proposta_est.pr_dscritic <> ?.    
      END.
    ELSE
    
    /***** ALTERAR PROPOSTA *****/ 
    IF par_tpenvest = "A" THEN
      DO:
        /* Chamar rotina de alteracao da proposta na Esteira*/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_alterar_proposta_est aux_handproc = PROC-HANDLE
           (INPUT par_cdcooper,   /* pr_cdcooper */
            INPUT par_cdagenci,   /* pr_cdagenci */ 
            INPUT par_cdoperad,   /* pr_cdoperad */
            INPUT par_idorigem,   /* pr_cdorigem */
            INPUT par_nrdconta,   /* pr_nrdconta */
            INPUT par_nrctremp,   /* pr_nrctremp */
            INPUT par_dtmvtolt,   /* pr_dtmvtolt */
            INPUT par_flreiflx,   /* pr_flreiflx */
            INPUT aux_nmarqpdf,   /* pr_nmarquiv */
            OUTPUT 0,             /* pr_cdcritic */
            OUTPUT ""             /* pr_dscritic */
            ).        

        CLOSE STORED-PROCEDURE pc_alterar_proposta_est WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

 
        ASSIGN par_dsmensag = "Proposta Enviada para Esteira com Sucesso."
               
               par_cdcritic = 0
               par_cdcritic = pc_alterar_proposta_est.pr_cdcritic
                              WHEN pc_alterar_proposta_est.pr_cdcritic <> ?
               par_dscritic = ""
               par_dscritic = pc_alterar_proposta_est.pr_dscritic
                              WHEN pc_alterar_proposta_est.pr_dscritic <> ?.  
      END.
      
    ELSE
    
    /***** ALTERAR NUMERO PROPOSTA *****/ 
    IF par_tpenvest = "N" THEN
      DO:
        /* Chamar rotina de alteracao do numero da proposta na Esteira*/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_alter_numproposta_est aux_handproc = PROC-HANDLE
           (INPUT par_cdcooper,   /* pr_cdcooper */
            INPUT par_cdagenci,   /* pr_cdagenci */ 
            INPUT par_cdoperad,   /* pr_cdoperad */
            INPUT par_idorigem,   /* pr_cdorigem */
            INPUT par_nrdconta,   /* pr_nrdconta */
            INPUT par_nrctremp,   /* pr_nrctremp */
            INPUT par_nrctremp_novo, /* pr_nrctremp_novo */
            INPUT par_dtmvtolt,   /* pr_dtmvtolt */
            OUTPUT 0,             /* pr_cdcritic */
            OUTPUT ""             /* pr_dscritic */
            ).        

        CLOSE STORED-PROCEDURE pc_alter_numproposta_est 
              WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN par_cdcritic = 0
               par_cdcritic = pc_alter_numproposta_est.pr_cdcritic
                              WHEN pc_alter_numproposta_est.pr_cdcritic <> ?
               par_dscritic = ""
               par_dscritic = pc_alter_numproposta_est.pr_dscritic
                              WHEN pc_alter_numproposta_est.pr_dscritic <> ?.  
      END.  
    
    ELSE    
    /***** CANCELAR PROPOSTA *****/ 
    IF par_tpenvest = "C" THEN
      DO:
        /* Chamar rotina de cancelamento da proposta na Esteira*/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_cancelar_proposta_est aux_handproc = PROC-HANDLE
           (INPUT par_cdcooper,   /* pr_cdcooper */
            INPUT par_cdagenci,   /* pr_cdagenci */ 
            INPUT par_cdoperad,   /* pr_cdoperad */
            INPUT par_idorigem,   /* pr_cdorigem */
            INPUT par_nrdconta,   /* pr_nrdconta */
            INPUT par_nrctremp,   /* pr_nrctremp */
            INPUT par_dtmvtolt,   /* pr_dtmvtolt */
            OUTPUT 0,             /* pr_cdcritic */
            OUTPUT ""             /* pr_dscritic */
            ).        

        CLOSE STORED-PROCEDURE pc_cancelar_proposta_est WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN par_cdcritic = 0
               par_cdcritic = pc_cancelar_proposta_est.pr_cdcritic
                              WHEN pc_cancelar_proposta_est.pr_cdcritic <> ?
               par_dscritic = ""
               par_dscritic = pc_cancelar_proposta_est.pr_dscritic
                              WHEN pc_cancelar_proposta_est.pr_dscritic <> ?.  
      END.
    
    ELSE    
    /***** EFETIVAR PROPOSTA *****/ 
    IF par_tpenvest = "E" THEN
      DO:
        /* Chamar rotina de efetivacao da proposta na Esteira*/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_efetivar_proposta_est aux_handproc = PROC-HANDLE
           (INPUT par_cdcooper,   /* pr_cdcooper */
            INPUT par_cdagenci,   /* pr_cdagenci */ 
            INPUT par_cdoperad,   /* pr_cdoperad */
            INPUT par_idorigem,   /* pr_cdorigem */
            INPUT par_nrdconta,   /* pr_nrdconta */
            INPUT par_nrctremp,   /* pr_nrctremp */
            INPUT par_dtmvtolt,   /* pr_dtmvtolt */
            INPUT aux_nmarqpdf,   /* pr_nmarquiv */
            OUTPUT 0,             /* pr_cdcritic */
            OUTPUT ""             /* pr_dscritic */
            ).        

        CLOSE STORED-PROCEDURE pc_efetivar_proposta_est WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN par_cdcritic = 0
               par_cdcritic = pc_efetivar_proposta_est.pr_cdcritic
                              WHEN pc_efetivar_proposta_est.pr_cdcritic <> ?
               par_dscritic = ""
               par_dscritic = pc_efetivar_proposta_est.pr_dscritic
                              WHEN pc_efetivar_proposta_est.pr_dscritic <> ?.  
      END.
    
    /* Remover arquivo pdf que foi gerado */
    IF aux_nmarqpdf <> "" THEN
    DO:
      UNIX SILENT VALUE("rm " + aux_nmarqpdf + " 2>/dev/null").
    END.

    /* Verifica se retornou critica */
    IF par_cdcritic >= 0 AND par_dscritic <> "" THEN                       
    DO:
       RETURN "NOK".
    END.
    
    RETURN "OK".
    
END.


 
