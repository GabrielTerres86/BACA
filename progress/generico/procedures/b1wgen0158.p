/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0158.p
    Autor   : Jorge I. Hamaguchi
    Data    : Julho/2013                Ultima Atualizacao: 05/08/2014.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela RELINT
                 
    Alteracoes: 
    
    26/08/2013 - Alterado para nao usar mais informações de telefone 
                 da tabela CRAPASS para usar a CRAPTFC (Daniele).
                 
    10/09/2013 - Ajustar carregamento dos parametros do bloqueio (David).
    
    06/01/2014 - Criticas de busca de crapage alteradas de 0 para 962 (Carlos)
    
    05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
                 
.............................................................................*/

{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0158tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

/*****************************************************************************
  Gerar arquivo de relatórios da Internet      
******************************************************************************/
PROCEDURE gerar_relatorio_relint:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagetel AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nmarqtel AS CHAR                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    IF par_cddopcao = "V" OR par_cddopcao = "R" THEN
    DO:
        RUN Gera_Impressao(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_idorigem,
                           INPUT par_nmdatela,
                           INPUT par_dtmvtolt,
                           INPUT par_cddopcao,
                           INPUT par_cdagetel,
                           INPUT par_nmarqtel,
                          OUTPUT par_nmarquiv,
                          OUTPUT TABLE tt-erro).

    END.
    IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.


/** Impressao da OPCAO R e Opcao V **/
PROCEDURE Gera_Impressao:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmarqtel AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    DEF VAR aux_flgccblq  AS LOGI                                       NO-UNDO.

    DEF VAR aux_cdcritic  AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdtotblq AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdtotbq1 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdtotbq2 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdvaiblq AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdvaibq1 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdvaibq2 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdiauso1 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdiaalt1 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdiablq1 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdiauso2 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdiaalt2 AS INTE                                       NO-UNDO.
    DEF VAR aux_qtdiablq2 AS INTE                                       NO-UNDO.
    DEF VAR aux_qttitula  AS INTE                                       NO-UNDO.
    DEF VAR aux_conttitu  AS INTE                                       NO-UNDO.
    DEF VAR aux_contador  AS INTE                                       NO-UNDO.

    DEF VAR aux_nmpessoa  AS CHAR                                       NO-UNDO.
    DEF VAR aux_dscritic  AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarquiv  AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqimp  AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdquery  AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrramfon  AS CHAR                                       NO-UNDO.
    DEF VAR aux_tptelefo  AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmresage  AS CHAR                                       NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
    
    DEF BUFFER crabttl  FOR crapttl.
    DEF QUERY q_crapass FOR crapass.
    

    EMPTY TEMP-TABLE tt-erro.

    FORM SKIP(1)
         "RELACAO DE SENHAS DE ACESSO A INTERNET BLOQUEADAS" 
         SKIP(1)
         tt-blqsnh.cdagenci AT  1 LABEL "PA" FORMAT "zz9"
         "-"                AT  9
         aux_nmresage       AT 11 NO-LABEL
         WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab_bloqueio_1.

    FORM SKIP(1)
         "RELACAO DE SENHAS DE ACESSO A INTERNET QUE SERAO BLOQUEADAS" 
         SKIP(1)
         tt-blqsnh.cdagenci AT  1 LABEL "PA" FORMAT "zz9"
         "-"                AT  9
         aux_nmresage       AT 11 NO-LABEL
         WITH NO-BOX SIDE-LABEL DOWN WIDTH 132 FRAME f_cab_bloqueio_2.

    FORM tt-blqsnh.nrdconta AT  1 LABEL "Conta/dv"     FORMAT "zzzz,zzz,9"
         tt-blqsnh.idseqttl AT 12 LABEL "Titular"      FORMAT "9"
         tt-blqsnh.nmpessoa AT 20 LABEL "Nome"         FORMAT "X(50)"
         tt-blqsnh.dtblutsh AT 71 LABEL "Dt.Bloqueio"  FORMAT "99/99/9999"
         tt-blqsnh.dtaltsnh AT 83 LABEL "Dt.Alt.Senha" FORMAT "99/99/9999"
         tt-blqsnh.nrtelefo AT 96 LABEL "Telefone"     FORMAT "X(25)"
    WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_blqsentit_1.

    FORM tt-blqsnh.nrdconta AT  1 LABEL "Conta/dv"     FORMAT "zzzz,zzz,9"
         tt-blqsnh.idseqttl AT 12 LABEL "Titular"      FORMAT "9"
         tt-blqsnh.nmpessoa AT 20 LABEL "Nome"         FORMAT "X(50)"
         tt-blqsnh.dtaltsnh AT 71 LABEL "Dt.Alt.Senha" FORMAT "99/99/9999"
         tt-blqsnh.nrtelefo AT 84 LABEL "Telefone"     FORMAT "X(37)"
    WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_blqsentit_2.

    FORM tt-blqsnh.nrdconta AT  1 LABEL "Conta/dv"     FORMAT "zzzz,zzz,9"
         tt-blqsnh.nrcpfope AT 12 LABEL "CPF"          FORMAT "99999999999"
         tt-blqsnh.nmpessoa AT 24 LABEL "Nome"         FORMAT "X(46)"
         tt-blqsnh.dtblutsh AT 71 LABEL "Dt.Bloqueio"  FORMAT "99/99/9999"
         tt-blqsnh.dtaltsnh AT 83 LABEL "Dt.Alt.Senha" FORMAT "99/99/9999"
         tt-blqsnh.nrtelefo AT 96 LABEL "Telefone"     FORMAT "X(25)"
    WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_blqsenope_1.

    FORM tt-blqsnh.nrdconta AT  1 LABEL "Conta/dv"     FORMAT "zzzz,zzz,9"
         tt-blqsnh.nrcpfope AT 12 LABEL "CPF"          FORMAT "99999999999"
         tt-blqsnh.nmpessoa AT 24 LABEL "Nome"         FORMAT "X(46)"
         tt-blqsnh.dtaltsnh AT 71 LABEL "Dt.Alt.Senha" FORMAT "99/99/9999"
         tt-blqsnh.nrtelefo AT 84 LABEL "Telefone"     FORMAT "X(37)"
    WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_blqsenope_2.


    /***********************************************************************/
    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
                             NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Cooperativa nao encontrada!".
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
  
        RETURN "NOK".
    END.

    IF par_cdagetel <> 0 THEN
    DO:
        IF NOT CAN-FIND(crapage WHERE crapage.cdcooper = par_cdcooper 
                                  AND crapage.cdagenci = par_cdagetel
                                  NO-LOCK) THEN
        DO:
            ASSIGN aux_cdcritic = 962
                   aux_dscritic = "".
      
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
      
            RETURN "NOK".
        END.
    END.
    
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper 
                       AND craptab.nmsistem = "CRED" 
                       AND craptab.tptabela = "GENERI" 
                       AND craptab.cdempres = 0 
                       AND craptab.cdacesso = "LIMINTERNT" 
                       AND (craptab.tpregist = 1 OR craptab.tpregist = 2)
                       NO-LOCK:
        /* PF */
        IF  craptab.tpregist = 1 THEN
            ASSIGN aux_qtdiauso1 = INTEGER(ENTRY(17,craptab.dstextab,";"))
                   aux_qtdiaalt1 = INTEGER(ENTRY(18,craptab.dstextab,";"))
                   aux_qtdiablq1 = INTEGER(ENTRY(19,craptab.dstextab,";"))
                   aux_qtdvaibq1 = aux_qtdiauso1 + aux_qtdiaalt1
                   aux_qtdtotbq1 = aux_qtdvaibq1 + aux_qtdiablq1.

        ELSE
            ASSIGN aux_qtdiauso2 = INTEGER(ENTRY(17,craptab.dstextab,";"))
                   aux_qtdiaalt2 = INTEGER(ENTRY(18,craptab.dstextab,";"))
                   aux_qtdiablq2 = INTEGER(ENTRY(19,craptab.dstextab,";"))
                   aux_qtdvaibq2 = aux_qtdiauso2 + aux_qtdiaalt2
                   aux_qtdtotbq2 = aux_qtdvaibq2 + aux_qtdiablq2.

    END. /* for each craptab */
    
    ASSIGN aux_dsdquery = "FOR EACH crapass NO-LOCK " + 
                          "WHERE crapass.cdcooper = " + STRING(par_cdcooper).
    
    IF  par_cdagetel <> 0 THEN
        ASSIGN aux_dsdquery = aux_dsdquery + " AND crapass.cdagenci = " + 
                              STRING(par_cdagetel).

    ASSIGN aux_dsdquery = aux_dsdquery + ":".

    QUERY q_crapass:QUERY-CLOSE().
    QUERY q_crapass:QUERY-PREPARE(aux_dsdquery).
    QUERY q_crapass:QUERY-OPEN().
    
    GET FIRST q_crapass.
    DO  WHILE AVAILABLE(crapass):
        
        ASSIGN aux_qttitula = 0
               aux_nrramfon = "".
        
        IF  crapass.inpessoa = 1  THEN
            ASSIGN aux_qtdvaiblq = aux_qtdvaibq1
                   aux_qtdtotblq = aux_qtdtotbq1
                   aux_tptelefo = "1,2,3,4".
        ELSE
            ASSIGN aux_qtdvaiblq = aux_qtdvaibq2
                   aux_qtdtotblq = aux_qtdtotbq2
                   aux_tptelefo = "3,2,1,4".
        
        /* titulares */
        FOR EACH crapsnh WHERE crapsnh.cdcooper = crapass.cdcooper
                           AND crapsnh.nrdconta = crapass.nrdconta
                           AND crapsnh.tpdsenha = 1
                           NO-LOCK:

            IF crapsnh.dtblutsh <> ? OR 
                (aux_datdodia >= (crapsnh.dtaltsnh + aux_qtdvaiblq)) THEN
            DO:
                /* se for Pessoa Fisisca */
                IF crapass.inpessoa = 1 THEN
                DO:
                    FIND FIRST crapttl WHERE crapttl.cdcooper = crapsnh.cdcooper
                                         AND crapttl.nrdconta = crapsnh.nrdconta
                                         AND crapttl.idseqttl = crapsnh.idseqttl
                                         NO-LOCK NO-ERROR.
                    IF NOT AVAIL crapttl THEN
                    DO:
                       NEXT.
                    END.

                    ASSIGN aux_nmpessoa = crapttl.nmextttl.
                END.
                ELSE 
                    ASSIGN aux_nmpessoa = crapass.nmprimtl.

                /*** Se PF :  Residencial/Celular/Comercial/Contato ***/
                /*** Se PJ: Comercial/Celular/Residencial/Contato ***/
                TIPO:
                DO aux_contador = 1 TO 4:
            
                    FIND FIRST craptfc WHERE 
                               craptfc.cdcooper = crapass.cdcooper   AND
                               craptfc.nrdconta = crapass.nrdconta   AND
                               craptfc.idseqttl = crapsnh.idseqttl   AND
                               craptfc.tptelefo = INTE(ENTRY(
                                                  aux_contador,
                                                  aux_tptelefo))
                               NO-LOCK NO-ERROR.
                    
                    IF  AVAIL craptfc   THEN
                        DO:
                            IF  craptfc.nrdddtfc <> 0  THEN
                                aux_nrramfon = "(" + 
                                               STRING(craptfc.nrdddtfc) 
                                               + ")".
                    
                            ASSIGN aux_nrramfon = aux_nrramfon + 
                                                  STRING(craptfc.nrtelefo).
                    
                            LEAVE TIPO.
                        END.
            
                END. /** Fim do DO ... TO - TIPO **/
                
                IF  aux_nrramfon = ""  THEN
                    ASSIGN aux_nrramfon = STRING(craptfc.nrtelefo). 
            
              IF  crapsnh.dtblutsh <> ? OR 
                    (aux_datdodia >= (crapsnh.dtaltsnh + aux_qtdtotblq)) THEN
                    ASSIGN aux_flgccblq = TRUE.
                ELSE
                    ASSIGN aux_flgccblq = FALSE.

                CREATE tt-blqsnh.
                ASSIGN tt-blqsnh.cdagenci = crapass.cdagenci
                       tt-blqsnh.nrdconta = crapass.nrdconta
                       tt-blqsnh.idseqttl = crapsnh.idseqttl
                       tt-blqsnh.nmpessoa = aux_nmpessoa
                       tt-blqsnh.dtblutsh = crapsnh.dtblutsh
                       tt-blqsnh.dtaltsnh = crapsnh.dtaltsnh
                       tt-blqsnh.nrtelefo = aux_nrramfon
                       tt-blqsnh.flgcbloq = aux_flgccblq
                       tt-blqsnh.cdtpbloq = 1. /* titulares */

            END.
        END. /* titulares */
               
        GET NEXT q_crapass.

    END. /* DO  WHILE AVAILABLE(crapass) */

    /* operadores */
    FOR EACH crapopi WHERE crapopi.cdcooper = par_cdcooper NO-LOCK:
        
        FIND FIRST crapass WHERE crapass.cdcooper = crapopi.cdcooper
                             AND crapass.nrdconta = crapopi.nrdconta
                             NO-LOCK NO-ERROR.
        IF NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta nao encontrada!".
      
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
      
           RETURN "NOK".
        END.

        IF  par_cdagetel <> 0 AND crapass.cdagenci <> par_cdagetel THEN
            NEXT.

        IF crapass.inpessoa = 1 THEN
            ASSIGN aux_qtdvaiblq = aux_qtdvaibq1
                   aux_qtdtotblq = aux_qtdtotbq1
                   aux_tptelefo = "1,2,3,4".
        ELSE 
            ASSIGN aux_qtdvaiblq = aux_qtdvaibq2
                   aux_qtdtotblq = aux_qtdtotbq2
                   aux_tptelefo = "3,2,1,4".

        IF crapopi.dtblutsh <> ? OR 
            (aux_datdodia >= (crapopi.dtaltsnh + aux_qtdvaiblq)) THEN 
        DO:
            /*** Se PF :  Residencial/Celular/Comercial/Contato ***/
            /*** Se PJ: Comercial/Celular/Residencial/Contato ***/
            TIPO:
            DO aux_contador = 1 TO 4:
        
                FIND FIRST craptfc WHERE 
                           craptfc.cdcooper = crapass.cdcooper   AND
                           craptfc.nrdconta = crapass.nrdconta   AND
                           craptfc.idseqttl = 1                  AND
                           craptfc.tptelefo = INTE(ENTRY(
                                              aux_contador,
                                              aux_tptelefo))
                           NO-LOCK NO-ERROR.
                
                IF  AVAIL craptfc   THEN
                DO:
                    IF  craptfc.nrdddtfc <> 0  THEN
                        aux_nrramfon = "(" + 
                                       STRING(craptfc.nrdddtfc) 
                                       + ")".
            
                    ASSIGN aux_nrramfon = aux_nrramfon + 
                                          STRING(craptfc.nrtelefo).
            
                    LEAVE TIPO.
                END.
        
            END. /** Fim do DO ... TO - TIPO **/
            
            IF  aux_nrramfon = ""  THEN
                ASSIGN aux_nrramfon = STRING(craptfc.nrtelefo). 


            IF  crapopi.dtblutsh <> ? OR 
                (aux_datdodia >= (crapopi.dtaltsnh + aux_qtdtotblq)) THEN
                ASSIGN aux_flgccblq = TRUE.
            ELSE
                ASSIGN aux_flgccblq = FALSE.

            CREATE tt-blqsnh.
            ASSIGN tt-blqsnh.cdagenci = crapass.cdagenci
                   tt-blqsnh.nrdconta = crapass.nrdconta
                   tt-blqsnh.nrcpfope = crapopi.nrcpfope
                   tt-blqsnh.nmpessoa = crapopi.nmoperad
                   tt-blqsnh.dtblutsh = crapopi.dtblutsh
                   tt-blqsnh.dtaltsnh = crapopi.dtaltsnh
                   tt-blqsnh.nrtelefo = aux_nrramfon
                   tt-blqsnh.flgcbloq = aux_flgccblq
                   tt-blqsnh.cdtpbloq = 2. /* operadores */
        END.
    END. /* for each crapopi */

    IF par_cddopcao = "V" THEN
    DO:
        ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                              "/rl/rel_bloqsenha".

        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
        
        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               aux_nmarqimp = aux_nmarquiv + ".ex"
               aux_nmarqpdf = aux_nmarquiv + ".pdf".
    END.
    ELSE IF par_cddopcao = "R" THEN
    DO:
        IF par_nmarqtel = "" THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nome do arquivo invalido!".
      
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
         
            RETURN "NOK".
        END.

        ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop   +  
                              "/" + par_nmarqtel.

        UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2>/dev/null").

        ASSIGN aux_nmarqimp = aux_nmarquiv
               aux_nmarqpdf = aux_nmarquiv.
    END.
    ELSE
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Opcao invalida!".
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
     
        RETURN "NOK".
    END.

    IF par_cddopcao = "V" THEN
        OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGE-SIZE 80 PAGED.
    ELSE IF par_cddopcao = "R" THEN
        OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp).

    FOR EACH tt-blqsnh NO-LOCK BREAK BY tt-blqsnh.cdagenci
                                     BY tt-blqsnh.flgcbloq DESC
                                     BY tt-blqsnh.cdtpbloq
                                     BY tt-blqsnh.nrdconta:
           
        IF FIRST-OF(tt-blqsnh.cdagenci) THEN
        DO:
            FIND FIRST crapage WHERE crapage.cdcooper = par_cdcooper
                                 AND crapage.cdagenci = tt-blqsnh.cdagenci
                                 NO-LOCK NO-ERROR.
              
            IF NOT AVAIL crapage THEN
            DO:
                ASSIGN aux_cdcritic = 962
                       aux_dscritic = "".
          
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
          
               RETURN "NOK".
            END.

            ASSIGN aux_nmresage = crapage.nmresage.

        END.

        IF par_cddopcao = "V" AND FIRST-OF(tt-blqsnh.flgcbloq) THEN
        DO:
            PAGE STREAM str_1.

            PUT STREAM str_1 crapcop.nmrescop     AT  1    FORMAT "x(20)"
                       "-"                        AT 22
                       "BLOQUEIO DE SENHAS INTERNET" AT 24 FORMAT "x(40)"
                       "- REF."                   AT 65
                       TODAY                      AT 72   FORMAT "99/99/9999"
                       "AS"                       AT 83
                       STRING(TIME,"HH:MM")       AT 86   FORMAT "x(5)"
                       "HR PAG.:"                 AT 92 
                       PAGE-NUMBER(str_1)         AT 101   FORMAT "zzzz9".
        END.
        
        IF FIRST-OF(tt-blqsnh.flgcbloq) AND tt-blqsnh.flgcbloq = TRUE THEN
        DO:
            /* cabecalho de senhas bloqueadas */
            DISP STREAM str_1 tt-blqsnh.cdagenci
                              aux_nmresage
                              WITH FRAME f_cab_bloqueio_1.
            DOWN STREAM str_1 WITH FRAME f_cab_bloqueio_1.
        END.

        IF FIRST-OF(tt-blqsnh.flgcbloq) AND tt-blqsnh.flgcbloq = FALSE THEN
        DO:
            /* cabecalho de senhas q serao bloqueadas */
            DISP STREAM str_1 tt-blqsnh.cdagenci
                              aux_nmresage
                              WITH FRAME f_cab_bloqueio_2.
            DOWN STREAM str_1 WITH FRAME f_cab_bloqueio_2.
        END.

        IF tt-blqsnh.flgcbloq  AND tt-blqsnh.cdtpbloq = 1 THEN
        DO:
            /* contas bloqueadas TITULAR */
            IF FIRST-OF(tt-blqsnh.cdtpbloq) THEN
                PUT STREAM str_1 SKIP(1) "TITULARES" AT 1 SKIP(1).

            DISP STREAM str_1 tt-blqsnh.nrdconta 
                              tt-blqsnh.idseqttl 
                              tt-blqsnh.nmpessoa 
                              tt-blqsnh.dtblutsh 
                              tt-blqsnh.dtaltsnh 
                              tt-blqsnh.nrtelefo 
                              WITH FRAME f_blqsentit_1.
            DOWN STREAM str_1 WITH FRAME f_blqsentit_1.
        END.
        ELSE IF tt-blqsnh.flgcbloq  AND tt-blqsnh.cdtpbloq = 2 THEN
        DO:
            /* contas bloqueadas OPERADORES PJ */
            IF FIRST-OF(tt-blqsnh.cdtpbloq) THEN
                PUT STREAM str_1 SKIP(1) "OPERADORES PJ" AT 1 SKIP(1).

            DISP STREAM str_1 tt-blqsnh.nrdconta 
                              tt-blqsnh.nrcpfope 
                              tt-blqsnh.nmpessoa 
                              tt-blqsnh.dtblutsh 
                              tt-blqsnh.dtaltsnh 
                              tt-blqsnh.nrtelefo 
                              WITH FRAME f_blqsenope_1.
            DOWN STREAM str_1 WITH FRAME f_blqsenope_1.
        END.
        ELSE IF NOT tt-blqsnh.flgcbloq AND tt-blqsnh.cdtpbloq = 1 THEN
        DO:
            /* Contas que serao bloqueadas TITULAR */
            IF FIRST-OF(tt-blqsnh.cdtpbloq) THEN
                PUT STREAM str_1 SKIP(1) "TITULARES" AT 1 SKIP(1).

            DISP STREAM str_1 tt-blqsnh.nrdconta 
                              tt-blqsnh.idseqttl 
                              tt-blqsnh.nmpessoa 
                              tt-blqsnh.dtaltsnh 
                              tt-blqsnh.nrtelefo 
                              WITH FRAME f_blqsentit_2.
            DOWN STREAM str_1 WITH FRAME f_blqsentit_2.
        END.
        ELSE IF NOT tt-blqsnh.flgcbloq AND tt-blqsnh.cdtpbloq = 2 THEN
        DO:
            /* contas que serao bloqueadas OPERADORES PJ */
            IF FIRST-OF(tt-blqsnh.cdtpbloq) THEN
                PUT STREAM str_1 SKIP(1) "OPERADORES PJ" AT 1 SKIP(1).

            DISP STREAM str_1 tt-blqsnh.nrdconta 
                              tt-blqsnh.nrcpfope 
                              tt-blqsnh.nmpessoa 
                              tt-blqsnh.dtaltsnh 
                              tt-blqsnh.nrtelefo 
                              WITH FRAME f_blqsenope_2.
            DOWN STREAM str_1 WITH FRAME f_blqsenope_2.
        END.
           
    END.

    OUTPUT STREAM str_1 CLOSE.
    
    IF par_cddopcao = "V" THEN
    DO:

        /* Gera relatorio em PDF */
        RUN sistema/generico/procedures/b1wgen0024.p
            PERSISTENT SET h-b1wgen0024.
        
        RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                               INPUT 1, /* cdagenci */
                                               INPUT 0, /* nrdcaixa */
                                               INPUT aux_nmarqimp,
                                              OUTPUT aux_nmarqpdf,
                                              OUTPUT TABLE tt-erro).     
            
        DELETE PROCEDURE h-b1wgen0024.
        
        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

     END.
     ELSE
     DO:
         UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + 
                           aux_nmarqimp + "_copy").
                               
         UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_copy" +
                           ' | tr -d "\032" > ' + aux_nmarqimp +
                           " 2>/dev/null").
            
         UNIX SILENT VALUE("rm " + aux_nmarqimp + "_copy").
     END.

    RETURN "OK".

END PROCEDURE.
