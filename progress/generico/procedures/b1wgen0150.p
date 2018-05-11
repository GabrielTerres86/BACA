/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0150.p
    Autor   : Lucas Lunelli
    Data    : Janeiro/2013                Ultima Atualizacao: 04/11/2013
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela ADMISS
                 
    Alteracoes: 04/10/2013 - Alterado para nao utilizar o telefone pela tabela
                             crapass. (Reinert)
                04/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)          
                            
                22/01/2014 - Ajuste para se adequar Ayllos Web (Daniel).   

.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0150tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.


/*****************************************************************************
  Consulta dados da tela ADMISS      
******************************************************************************/
PROCEDURE consulta-admiss:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  OUTPUT PARAM par_qtassmes AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_qtadmmes AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_qtdslmes AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_vlcapini AS DECI                           NO-UNDO.
    DEF  OUTPUT PARAM par_nrmatric AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_qtparcap AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_vlcapsub AS DECI                           NO-UNDO.
    DEF  OUTPUT PARAM par_flgabcap AS LOGI                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dtdemiss          AS DATE                           NO-UNDO.

    DEF VAR aux_cdcritic           AS INTE                           NO-UNDO.
    DEF VAR aux_dscritic           AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapmat WHERE crapmat.cdcooper = par_cdcooper
                                            NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapmat THEN
        DO:
            ASSIGN aux_cdcritic = 194.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".
        END.

    ASSIGN  aux_dtdemiss = par_dtmvtolt - DAY(par_dtmvtolt) + 1
            par_qtdslmes = 0.

    FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.dtdemiss >= aux_dtdemiss
                           NO-LOCK:

        ASSIGN par_qtdslmes = par_qtdslmes + 1.

    END.

    ASSIGN par_qtassmes = crapmat.qtassmes
           par_qtadmmes = crapmat.qtdesmes /* Readmitidos */
           par_vlcapini = crapmat.vlcapini
           par_nrmatric = crapmat.nrmatric
           par_vlcapsub = crapmat.vlcapsub
           par_qtparcap = crapmat.qtparcap
           par_flgabcap = crapmat.flgabcap.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Altera dados da tela ADMISS        
******************************************************************************/
PROCEDURE altera-admiss:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT  PARAM par_vlcapini AS DECI                           NO-UNDO.
    DEF  INPUT  PARAM par_vlcapsub AS DECI                           NO-UNDO.
    DEF  INPUT  PARAM par_qtparcap AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_flgabcap AS LOGI                           NO-UNDO.

    DEF OUTPUT  PARAM TABLE FOR tt-erro.

    DEF  VAR aux_contador AS INT                                     NO-UNDO.

    DEF VAR aux_cdcritic  AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic  AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Validações */
    DO WHILE TRUE:

        IF  par_cdcooper <> 9  THEN
            DO:
                IF  par_vlcapini = 0                     OR
                    par_vlcapini > par_vlcapsub          OR
                   (par_vlcapini / par_vlcapsub) < 0.5   THEN
                    DO: 
                        ASSIGN aux_cdcritic = 197.
                        LEAVE.
                    END.
            END.

        IF  par_qtparcap > 12   THEN
            DO:
                ASSIGN aux_dscritic = "Parcelamento do capital " +
                                      "errado (Ate 12x).".
                LEAVE.
            END.

        IF  par_vlcapsub <> par_vlcapini   AND
            par_qtparcap = 0               THEN
            DO: /*
                ASSIGN aux_dscritic = "Parcelamento do capital " +
                                      "deve ser informado.". */
                ASSIGN aux_dscritic = "Quantidade maxima de parcelamento mensal " +
                                      "deve ser informado.".
                LEAVE.
            END.
        ELSE
        IF  par_vlcapsub = par_vlcapini THEN DO:
            ASSIGN par_qtparcap = 0.
        END.

        LEAVE.

    END.

    IF  aux_cdcritic <> 0  OR
        aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
        
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO TRANSACTION:
        
        DO  aux_contador = 1 TO 10:

            FIND FIRST crapmat WHERE crapmat.cdcooper = par_cdcooper
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapmat THEN
                IF  LOCKED crapmat    THEN
                    DO:
                        ASSIGN aux_cdcritic = 73.

                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 194.
                        LEAVE.
                    END.

            LEAVE.

        END.

        IF  aux_cdcritic <> 0  OR
            aux_dscritic <> "" THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /* Sequencia */  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
          
                RETURN "NOK".
            END.

        ASSIGN crapmat.vlcapini = par_vlcapini
               crapmat.vlcapsub = par_vlcapsub
               crapmat.qtparcap = par_qtparcap
               crapmat.flgabcap = par_flgabcap.

    END.  /*  Fim da transacao  */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Lista admissões de um PAC na tela ADMISS
******************************************************************************/
PROCEDURE lista-admiss-pac:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_numdopac AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_qtadmmes AS INTE                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-admiss.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nrregist          AS INT.

    EMPTY TEMP-TABLE tt-admiss.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN par_qtadmmes = 0
           aux_nrregist = par_nrregist.

    FOR EACH crapadm NO-LOCK WHERE crapadm.cdcooper = par_cdcooper,
        EACH crapass NO-LOCK WHERE crapass.cdcooper = par_cdcooper     AND
                                   crapass.nrdconta = crapadm.nrdconta AND
                                  (IF par_numdopac <> 0                THEN
                                   crapass.cdagenci = par_numdopac     ELSE 
                                   crapass.cdagenci > 0)
                                   BY crapass.cdagenci
                                   BY crapadm.nrdconta.

            ASSIGN par_qtregist = par_qtregist + 1.

           /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist >= 1 THEN
                DO:
                    CREATE tt-admiss.
                    ASSIGN tt-admiss.cdagenci = crapass.cdagenci
                           tt-admiss.nrdconta = crapass.nrdconta
                           tt-admiss.nrmatric = crapadm.nrmatric
                           par_qtadmmes       = par_qtadmmes + 1.
                   
                    IF  crapass.inpessoa = 1 THEN
                        DO:
                            FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                                     crapttl.nrdconta = crapass.nrdconta AND
                                                     crapttl.nrcpfcgc = crapass.nrcpfcgc
                                                     NO-LOCK NO-ERROR.
                   
                            IF  AVAIL crapttl THEN
                                ASSIGN tt-admiss.nmprimtl = crapttl.nmextttl.
                        END.
                    ELSE
                        DO:
                            FIND FIRST crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND
                                                     crapjur.nrdconta = crapass.nrdconta 
                                                     NO-LOCK NO-ERROR.
                   
                            IF  AVAIL crapjur THEN
                                ASSIGN tt-admiss.nmprimtl = crapjur.nmextttl.
                        END.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
    END. 

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Lista demissões de um PAC na tela ADMISS
******************************************************************************/
PROCEDURE lista-demiss-pac:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_numdopac AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nriniseq AS INTE                           NO-UNDO.
                                                                     
    DEF  OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.     
    DEF  OUTPUT PARAM par_qtdemmes AS INTE                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-demiss.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrregist           AS INT                            NO-UNDO.

    DEF VAR aux_cdcritic           AS INTE                           NO-UNDO.
    DEF VAR aux_dscritic           AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-demiss.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN par_qtdemmes = 0
           aux_nrregist = par_nrregist.

    IF par_dtdemiss = ? THEN DO:

        ASSIGN aux_dscritic = "Data 'A partir de:' " +
                              "deve ser informado.".

        RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".


    END.

    FOR EACH crapass NO-LOCK WHERE crapass.cdcooper = par_cdcooper   AND
                                   crapass.dtdemiss >= par_dtdemiss  AND
                                  (IF par_numdopac <> 0              THEN
                                   crapass.cdagenci = par_numdopac   ELSE 
                                   crapass.cdagenci > 0)
                                   BY crapass.dtdemiss
                                   BY crapass.cdagenci
                                   BY crapass.nrdconta.

        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginação */
        IF  (par_qtregist < par_nriniseq) OR
            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
            NEXT.

        IF  aux_nrregist >= 1 THEN
            DO:
                CREATE tt-demiss.
                ASSIGN tt-demiss.dtdemiss = crapass.dtdemiss
                       tt-demiss.cdagenci = crapass.cdagenci
                       tt-demiss.nrdconta = crapass.nrdconta
                       tt-demiss.cdmotdem = crapass.cdmotdem
                       par_qtdemmes       = par_qtdemmes + 1.
            
           
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
                /* Efetuar a chamada a rotina Oracle  */
                RUN STORED-PROCEDURE prc_busca_motivo_demissao
                aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT par_cdcooper      /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT crapass.cdmotdem  /* pr_cdmotdem --> Código Motivo Demissao */
                   /* --------- OUT --------- */
                   ,OUTPUT ""           /* pr_dsmotdem --> Descriçao Motivo Demissao */
                   ,OUTPUT 0            /* pr_cdcritic --> Codigo da critica    */
                   ,OUTPUT "" ).        /* pr_dscritic --> Descriçao da critica).     */
                                        
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC prc_busca_motivo_demissao
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.                 
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_cdcritic = prc_busca_motivo_demissao.pr_cdcritic
                                 WHEN prc_busca_motivo_demissao.pr_cdcritic <> ?.
                                  
                IF   aux_cdcritic = 848   THEN
                     ASSIGN tt-demiss.dsmotdem = "MOTIVO NAO CADASTRADO".
                ELSE
                     ASSIGN tt-demiss.dsmotdem = prc_busca_motivo_demissao.pr_dsmotdem
                                                 WHEN prc_busca_motivo_demissao.pr_dsmotdem <> ?.

            
                IF  crapass.inpessoa = 1 THEN
                    DO:
                        FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                                 crapttl.nrdconta = crapass.nrdconta AND
                                                 crapttl.nrcpfcgc = crapass.nrcpfcgc
                                                 NO-LOCK NO-ERROR.
            
                        IF  AVAIL crapttl THEN
                            ASSIGN tt-demiss.nmprimtl = crapttl.nmextttl.
                    END.
                ELSE
                    DO:
                        FIND FIRST crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND
                                                 crapjur.nrdconta = crapass.nrdconta 
                                                 NO-LOCK NO-ERROR.
            
                        IF  AVAIL crapjur THEN
                            ASSIGN tt-demiss.nmprimtl = crapjur.nmextttl.
                    END.
            END.

        ASSIGN aux_nrregist = aux_nrregist - 1.

    END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
  Rotina de impressão da tela ADMISS      
******************************************************************************/
PROCEDURE impressao-admiss:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_numdopac AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtdecons AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtatecon AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                            NO-UNDO.
    
    DEF OUTPUT  PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                     NO-UNDO.

    DEF VAR aux_nrramfon AS CHAR    FORMAT "x(19)"                   NO-UNDO.
    DEF VAR aux_totdopac AS INTE    FORMAT "z,zz9"                    NO-UNDO.
    DEF VAR aux_totdorel AS INTE    FORMAT "zzz,zz9"                  NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                   NO-UNDO.

    FORM HEADER
           crapcop.nmrescop                 NO-LABEL
           " - NOVOS ASSOCIADOS - "
           "De:"
           par_dtdecons FORMAT "99/99/9999" NO-LABEL
           "Ate:"
           par_dtatecon FORMAT "99/99/9999" NO-LABEL     
           "PAG:" PAGE-NUMBER(str_1) FORMAT "99999"
           SKIP(1)
           WITH PAGE-TOP FRAME f_admiss_rel. 

    FORM SKIP(1)
           "PA:" crapage.cdagenci 
           "-" crapage.nmresage
           SKIP(1)
           "Conta/dv"     AT 4
           "Nome"         AT 13
           "Admissao"     AT 47
           "Contato"      AT 58
           WITH NO-BOX NO-LABELS OVERLAY FRAME f_admiss_rel_dados_pac. 

    FORM   crapass.nrdconta       FORMAT "z,zzz,zzz,9"
           crapass.nmprimtl AT 13 FORMAT "x(33)"
           crapass.dtadmiss AT 47 FORMAT "99/99/9999"
           aux_nrramfon     AT 58  
           WITH NO-BOX NO-LABELS DOWN OVERLAY FRAME f_admiss_rel_dados. 
    
    FORM   SKIP(1)
           "Total de novos associados do PA:"
           aux_totdopac               
           SKIP(1)
           WITH NO-BOX NO-LABELS OVERLAY FRAME f_total_pac.
         
    FORM   SKIP(1)
           "Total de novos associados do relatorio:"
           aux_totdorel NO-LABEL
           SKIP(1)
           WITH NO-BOX NO-LABELS OVERLAY FRAME f_total_rel.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_totdopac = 0
           aux_totdorel = 0.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.
    
    IF   par_dsiduser <> ""  THEN
             UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2> /dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_admiss_rel.
    
    FOR EACH crapass NO-LOCK WHERE crapass.cdcooper = par_cdcooper   AND
                                  (crapass.dtmvtolt >= par_dtdecons  AND
                                   crapass.dtmvtolt <= par_dtatecon) AND
                                  (IF par_numdopac <> 0              THEN
                                   crapass.cdagenci = par_numdopac   ELSE 
                                   crapass.cdagenci > 0)
                                  AND crapass.dtdemiss = ?
                                   BREAK BY crapass.cdagenci
                                         BY crapass.nrdconta:
   
        IF  FIRST-OF(crapass.cdagenci) THEN
            DO:
                FIND FIRST crapage 
                           WHERE crapage.cdcooper = crapass.cdcooper AND
                                 crapage.cdagenci = crapass.cdagenci
                                 NO-LOCK NO-ERROR.
                                 
                IF  AVAIL crapage  THEN
                    DISPLAY STREAM str_1 crapage.cdagenci
                                         crapage.nmresage
                                         WITH FRAME f_admiss_rel_dados_pac.
                ELSE                     
                    DISPLAY STREAM str_1 "" @ crapage.cdagenci
                    "** NAO CADASTRADO** "    crapage.nmresage
                                         WITH FRAME f_admiss_rel_dados_pac.
            END.
            
        IF  LINE-COUNTER(str_1) > 80  THEN
            DO:
                PAGE STREAM str_1.
                FIND FIRST crapage 
                           WHERE crapage.cdcooper = crapass.cdcooper AND
                                 crapage.cdagenci = crapass.cdagenci
                                 NO-LOCK NO-ERROR.
                                 
                IF  AVAIL crapage  THEN
                    DISPLAY STREAM str_1 crapage.cdagenci
                                         crapage.nmresage
                                         WITH FRAME f_admiss_rel_dados_pac.
                ELSE                     
                    DISPLAY STREAM str_1 "" @ crapage.cdagenci
                    "** NAO CADASTRADO** "    crapage.nmresage
                                         WITH FRAME f_admiss_rel_dados_pac.
            END.
        
        ASSIGN aux_nrramfon = "".
                      
        /* fone */
        FIND FIRST craptfc WHERE
                   craptfc.cdcooper = crapass.cdcooper AND
                   craptfc.nrdconta = crapass.nrdconta AND
                   craptfc.tptelefo = IF crapass.inpessoa = 1 THEN 1 ELSE 3
                   NO-LOCK NO-ERROR.
                      
        IF   AVAILABLE craptfc   THEN  
             aux_nrramfon = STRING(craptfc.nrdddtfc) +
                            STRING(craptfc.nrtelefo).
                    
        /* cel */
       FIND FIRST craptfc WHERE  craptfc.cdcooper = crapass.cdcooper AND
                                 craptfc.nrdconta = crapass.nrdconta AND
                                 craptfc.tptelefo = 2  
                                 NO-LOCK NO-ERROR.
                      
       IF   AVAILABLE craptfc   THEN
            DO:
                IF  aux_nrramfon <> ""   THEN
                    ASSIGN aux_nrramfon = aux_nrramfon + "/".
         
                ASSIGN aux_nrramfon = aux_nrramfon +
                                      STRING(craptfc.nrtelefo).
            END.
   
        /* busca o ramal da empresa */
        IF   aux_nrramfon = ""   THEN
             DO:
                 FIND FIRST craptfc WHERE 
                            craptfc.cdcooper = crapass.cdcooper AND
                            craptfc.nrdconta = crapass.nrdconta AND
                            craptfc.tptelefo = IF  crapass.inpessoa = 1 THEN 1 ELSE 3
                            NO-LOCK NO-ERROR.
                
                 IF   AVAILABLE craptfc   THEN  
                      ASSIGN aux_nrramfon = STRING(craptfc.nrdddtfc) +
                                            STRING(craptfc.nrtelefo).
             END.                        
             
        ASSIGN aux_totdopac = aux_totdopac + 1.     
   
        DISPLAY STREAM str_1 crapass.nrdconta NO-LABEL
                             crapass.nmprimtl NO-LABEL
                             crapass.dtadmiss NO-LABEL
                             aux_nrramfon     NO-LABEL
                             WITH FRAME f_admiss_rel_dados.
   
        IF  LAST-OF(crapass.cdagenci)  THEN
            DO:
                DISPLAY STREAM str_1
                        aux_totdopac
                        WITH FRAME f_total_pac.
                
                aux_totdorel = aux_totdorel + aux_totdopac.        
   
                aux_totdopac = 0.
            END.
            
        DOWN WITH FRAME f_admiss_rel_dados.                    
        
    END. /* Final do FOR EACH */
    
    DISPLAY STREAM str_1 aux_totdorel WITH FRAME f_total_rel.
    
    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            /* Gera relatorio em PDF */ 
            RUN sistema/generico/procedures/b1wgen0024.p
                PERSISTENT SET h-b1wgen0024.

            
            RUN envia-arquivo-web IN h-b1wgen0024
                                     (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT aux_nmarqimp,
                                      OUTPUT par_nmarqpdf,
                                      OUTPUT TABLE tt-erro).     

            DELETE PROCEDURE h-b1wgen0024.
        
            IF  RETURN-VALUE <> "OK"   THEN
                RETURN "NOK".

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                               
                    RETURN "NOK".

                END.

        END.

    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    RETURN "OK".

END PROCEDURE.


