/*.............................................................................

    Programa: b1wgen0051.p
    Autor   : Jose Luis (DB1)
    Data    : Janeiro/2010                   Ultima atualizacao: 17/10/2017

    Objetivo  : Tranformacao BO tela CONTAS

    Alteracoes: 07/12/2010 - Passado tratamento de mensagens da procedure
                             Busca-Associado e Obtem-Cabecalho para 
                             b1wgen0031.p (Gabriel - DB1).
                             
                29/05/2012 - Alimentado os campos tt-cabec.dtnasttl,
                             tt-cabec.inhabmen na procedure obtem-cabecalho
                             (Adriano).  
                             
                22/02/2013 - Incluido a chamada da procedure bloqueio_prova_vida
                             dentro da procedure obtem-cabecalho (Adriano).
   
				17/10/2017 - Adicionando a informacao nmctajur no cabecalho 
				             da tela contas (Kelvin - PRJ339).

.............................................................................*/


/*................................. DEFINICOES ..............................*/

{ sistema/generico/includes/b1wgen0031tt.i}
{ sistema/generico/includes/b1wgen0051tt.i}
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.

FUNCTION BuscaSitConta RETURNS CHARACTER
    ( INPUT par_cdsitdct AS INTEGER ) FORWARD:


/*................................. PROCEDURES ..............................*/
PROCEDURE Busca-Associado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-mensagens-contas. 
    DEF OUTPUT PARAM TABLE FOR tt-crapass. 
    DEF OUTPUT PARAM TABLE FOR tt-crapttl. 
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    
    DEF VAR h-b1wgen0031 AS HANDLE                                  NO-UNDO.

    ASSIGN 
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-crapass.
        EMPTY TEMP-TABLE tt-crapttl.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        CREATE tt-crapass.
        BUFFER-COPY crapass TO tt-crapass.

        /* Tipo da conta */
        FIND craptip WHERE craptip.cdcooper = tt-crapass.cdcooper AND
                           craptip.cdtipcta = tt-crapass.cdtipcta 
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craptip   THEN
             DO:
                ASSIGN aux_cdcritic = 017.
                LEAVE Busca.
             END.

        ASSIGN tt-crapass.dstipcta = CAPS(craptip.dstipcta).

        FIND crapage WHERE crapage.cdcooper = tt-crapass.cdcooper AND
                           crapage.cdagenci = tt-crapass.cdagenci 
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapage   THEN
             DO:
                ASSIGN aux_cdcritic = 015.
                LEAVE Busca.
             END.

        ASSIGN 
            tt-crapass.dsagenci = CAPS(crapage.nmresage)
            tt-crapass.dssitdct = IF tt-crapass.cdsitdct = 1
                                     THEN "NORMAL"
                                  ELSE
                                  IF tt-crapass.cdsitdct = 2
                                     THEN "ENCERRADA PELO ASSOCIADO"
                                  ELSE
                                  IF tt-crapass.cdsitdct = 3
                                     THEN "ENCERRADA PELA COOP"
                                  ELSE
                                  IF tt-crapass.cdsitdct = 4
                                     THEN "ENCERRADA PELA DEMISSAO"
                                  ELSE
                                  IF tt-crapass.cdsitdct = 5
                                     THEN "NAO APROVADA"
                                  ELSE
                                  IF tt-crapass.cdsitdct = 6
                                     THEN "NORMAL - SEM TALAO"
                                  ELSE
                                  IF tt-crapass.cdsitdct = 9
                                     THEN "ENCERRADA P/ OUTRO MOTIVO"
                                  ELSE "".

        /* PESSOA FISICA */
        FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta NO-LOCK:

            CREATE tt-crapttl.
            BUFFER-COPY crapttl TO tt-crapttl.

            /* Estado civil */
            FIND gnetcvl WHERE gnetcvl.cdestcvl = tt-crapttl.cdestcvl 
                NO-LOCK NO-ERROR.

            ASSIGN 
               tt-crapttl.dsgraupr = IF tt-crapttl.cdgraupr = 1
                                        THEN "CONJUGE"
                                     ELSE
                                     IF tt-crapttl.cdgraupr = 2
                                        THEN "PAI/MAE"
                                     ELSE
                                     IF tt-crapttl.cdgraupr = 3
                                        THEN "FILHO/FILHA"
                                     ELSE
                                     IF tt-crapttl.cdgraupr = 4
                                        THEN "COMPANHEIRO(A)"
                                     ELSE
                                     IF tt-crapttl.cdgraupr = 9
                                        THEN "NENHUM"
                                     ELSE ""
               tt-crapttl.dsestcvl = IF AVAILABLE gnetcvl 
                                        THEN CAPS(gnetcvl.rsestcvl)
                                        ELSE "NAO INFORMADO"
               tt-crapttl.tpsexotl = IF tt-crapttl.cdsexotl = 1 
                                        THEN "M" ELSE "F".
        END.

        /* PESSOA JURIDICA */
        FOR FIRST crapjur FIELDS(nmfansia)
                          WHERE crapjur.cdcooper = par_cdcooper AND
                                crapjur.nrdconta = par_nrdconta NO-LOCK:

            ASSIGN tt-crapass.nmfansia = crapjur.nmfansia.

            /* Procura registro de recadastramento */
            FIND LAST crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                                    crapalt.nrdconta = par_nrdconta AND
                                    crapalt.tpaltera = 1                
                                    NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapalt THEN
                 DO:
                     ASSIGN tt-crapass.dtaltera = ?.
                 END.
            ELSE
                 ASSIGN tt-crapass.dtaltera = crapalt.dtaltera.
        END.

        RUN sistema/generico/procedures/b1wgen0031.p 
            PERSISTENT SET h-b1wgen0031.
    
        IF  VALID-HANDLE(h-b1wgen0031)  THEN
            DO:
                RUN obtem-mensagens-alerta-contas IN h-b1wgen0031 
                                              (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nrdconta,
                                               INPUT par_idorigem,
                                               INPUT par_nmdatela,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-mensagens-contas).
                       
                DELETE PROCEDURE h-b1wgen0031.
    
                IF  RETURN-VALUE = "NOK"  THEN
                    LEAVE Busca.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Busca.
    END.
    
    IF  aux_returnvl = "NOK"         AND 
        NOT CAN-FIND(FIRST tt-erro)  THEN
        DO:
           IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
               ASSIGN aux_dscritic = "Falha na leitura dos dados.". 

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE obtem-cabecalho:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-mensagens-contas.
    DEF OUTPUT PARAM TABLE FOR tt-erro. 
    DEF OUTPUT PARAM TABLE FOR tt-cabec. 

    DEF VAR h-b1wgen0031 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.

    EMPTY TEMP-TABLE tt-erro. 
    EMPTY TEMP-TABLE tt-cabec.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados da conta do associado"
           aux_retorno  = "NOK"
           aux_cdcritic = 0
           aux_dscritic = "".

    Cabec: DO ON ERROR UNDO Cabec, LEAVE Cabec:
        FOR FIRST crapass FIELDS(cdcooper nrdconta inpessoa cdagenci 
                                 cdtipcta nrmatric nmprimtl nrcpfcgc 
                                 cdsitdct nrdctitg dtdemiss)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK: 
        END.

        IF  NOT AVAILABLE crapass   THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Cabec.
            END.

            
        CASE crapass.inpessoa:
            WHEN 1 THEN DO:
                FOR FIRST crapttl FIELDS(cdcooper nrdconta cdestcvl nmextttl
                                         idseqttl cdsexotl nrcpfcgc dtnasttl
                                         inhabmen)
                                  WHERE crapttl.cdcooper = crapass.cdcooper AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = par_idseqttl
                                        NO-LOCK: 
                    
                END.

                IF   NOT AVAILABLE crapttl   THEN
                     DO:
                        aux_dscritic = "Titular da conta nao cadastrado".
                        LEAVE Cabec.
                     END.

                 FOR FIRST gnetcvl FIELDS(rsestcvl)
                                   WHERE gnetcvl.cdestcvl = crapttl.cdestcvl
                                   NO-LOCK:
                 END.

            END.
            OTHERWISE DO:
                FOR FIRST crapjur FIELDS(cdcooper nrdconta nmfansia nmctajur)
                                  WHERE crapjur.cdcooper = crapass.cdcooper AND
                                        crapjur.nrdconta = crapass.nrdconta 
                                        NO-LOCK:
                END.

                IF  NOT AVAILABLE  crapjur THEN
                    DO:
                       ASSIGN aux_dscritic = "Dados da pessoa Juridica nao " +
                                             "encontrados".
                       LEAVE Cabec.
                    END.

            END.

        END CASE.
    
        /* Dados da agencia */
        FOR FIRST crapage FIELDS(cdagenci nmresage)
                          WHERE crapage.cdcooper = crapass.cdcooper AND
                                crapage.cdagenci = crapass.cdagenci NO-LOCK:
        END.
    
        IF   NOT AVAILABLE crapage   THEN
             DO:
                 ASSIGN aux_cdcritic = 015.
                 LEAVE Cabec.
             END.

        /* Tipo da conta */
        FOR FIRST craptip FIELDS(dstipcta)
                          WHERE craptip.cdcooper = crapass.cdcooper AND
                                craptip.cdtipcta = crapass.cdtipcta NO-LOCK:
        END.

        IF   NOT AVAILABLE craptip THEN
             DO:
                 ASSIGN aux_cdcritic = 017.
                 LEAVE Cabec.
             END.

        CREATE tt-cabec.
        ASSIGN
            tt-cabec.nrmatric = crapass.nrmatric
            tt-cabec.nmextttl = IF   AVAILABLE crapttl 
                                THEN crapttl.nmextttl
                                ELSE crapass.nmprimtl 
            tt-cabec.nmfansia = (IF   AVAILABLE crapjur
                                 THEN crapjur.nmfansia
                                 ELSE "") 
            tt-cabec.nrdconta = crapass.nrdconta
            tt-cabec.cdagenci = crapage.cdagenci
            tt-cabec.dsagenci = crapage.nmresage
            tt-cabec.idseqttl = IF   AVAILABLE crapttl
                                THEN crapttl.idseqttl
                                ELSE 1
            tt-cabec.inpessoa = crapass.inpessoa
            tt-cabec.dspessoa = IF   crapass.inpessoa = 1 
                                THEN "FISICA"
                                ELSE "JURIDICA"
            tt-cabec.nrcpfcgc = IF crapass.inpessoa = 1 
                                THEN STRING(STRING(crapttl.nrcpfcgc,
                                                   "99999999999"),
                                            "XXX.XXX.XXX-XX")
                                ELSE STRING(STRING(crapass.nrcpfcgc,
                                                   "99999999999999"),
                                            "XX.XXX.XXX/XXXX-XX")
            tt-cabec.cdsexotl = IF   AVAILABLE crapttl    AND 
                                     crapttl.cdsexotl = 1 AND
                                     crapass.inpessoa = 1
                                THEN "M"
                                ELSE "F"
            tt-cabec.cdestcvl = IF   AVAILABLE crapttl
                                THEN crapttl.cdestcvl
                                ELSE 0
            tt-cabec.dsestcvl = IF   AVAILABLE gnetcvl
                                THEN CAPS(gnetcvl.rsestcvl)
                                ELSE "NAO INFORMADO"
            tt-cabec.cdtipcta = crapass.cdtipcta
            tt-cabec.dstipcta = CAPS(craptip.dstipcta)
            tt-cabec.cdsitdct = crapass.cdsitdct
            tt-cabec.dssitdct = BuscaSitConta(tt-cabec.cdsitdct)
            tt-cabec.nrdctitg = crapass.nrdctitg 
            tt-cabec.dtnasttl = IF AVAIL crapttl THEN 
                                   crapttl.dtnasttl 
                                ELSE 
                                   ?
            tt-cabec.inhabmen = IF AVAIL crapttl THEN 
                                   crapttl.inhabmen 
                                ELSE 
                                   0 
			tt-cabec.nmctajur = IF AVAIL crapjur THEN 
								   crapjur.nmctajur
								ELSE
								   ""
            NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = "Erro ao criar o cabecalho. " + 
                                     ERROR-STATUS:GET-MESSAGE(1).
               LEAVE Cabec.
            END.

        RUN sistema/generico/procedures/b1wgen0031.p 
            PERSISTENT SET h-b1wgen0031.
    
        IF  VALID-HANDLE(h-b1wgen0031)  THEN
            DO: 
                RUN obtem-mensagens-alerta-contas IN h-b1wgen0031 
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nrdconta,
                                             INPUT par_idorigem,
                                             INPUT par_nmdatela,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-mensagens-contas).
    
                IF RETURN-VALUE = "NOK"  THEN
                   DO:
                      DELETE PROCEDURE h-b1wgen0031.
                      LEAVE Cabec.

                   END.
                
                IF AVAIL crapttl THEN
                   DO:  
                      RUN bloqueio_prova_vida IN h-b1wgen0031
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_dtmvtolt,
                                        INPUT crapttl.nrdconta,
                                        INPUT crapttl.idseqttl,
                                        INPUT-OUTPUT TABLE tt-mensagens-contas,
                                        OUTPUT TABLE tt-erro).
                      
                      IF RETURN-VALUE <> "OK"  THEN
                         DO:
                            DELETE PROCEDURE h-b1wgen0031.
                            LEAVE Cabec.
                         END.
                      
                   END.

                DELETE PROCEDURE h-b1wgen0031.

            END.

        ASSIGN aux_retorno = "OK".

        LEAVE Cabec.
    END.
    
    IF  aux_retorno = "NOK"          AND 
        NOT CAN-FIND(FIRST tt-erro)  THEN
        DO:
           IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
               ASSIGN aux_dscritic = "Falha na leitura dos dados.". 

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT aux_dscritic,
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                        INPUT par_idseqttl, 
                        INPUT par_nmdatela, 
                        INPUT par_nrdconta, 
                        OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE busca_titular:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 
    DEF OUTPUT PARAM TABLE FOR tt-titular. 

    EMPTY TEMP-TABLE tt-erro. 
    EMPTY TEMP-TABLE tt-titular.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter os titulares da conta para tela CONTAS"
           aux_retorno  = "NOK"
           aux_cdcritic = 0
           aux_dscritic = "".


    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    END.
    ELSE ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE busca_dados_associado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 
    DEF OUTPUT PARAM TABLE FOR tt-dados-ass. 
    DEF OUTPUT PARAM TABLE FOR tt-titular.

    EMPTY TEMP-TABLE tt-erro. 
    EMPTY TEMP-TABLE tt-dados-ass.
    EMPTY TEMP-TABLE tt-titular.

    ASSIGN aux_retorno  = "NOK"
           aux_cdcritic = 0
           aux_dscritic = "".

    Associado: DO ON ERROR UNDO, RETURN:
        FOR FIRST crapass FIELD(inpessoa)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK: END.

        IF  AVAILABLE crapass THEN
            DO:
               CREATE tt-dados-ass.
               ASSIGN tt-dados-ass.inpessoa = crapass.inpessoa NO-ERROR.

               IF  ERROR-STATUS:ERROR THEN
                   DO:
                       ASSIGN aux_dscritic = "Erro ao buscar o tipo da pessoa"
                                             + " do associado. "
                                             + ERROR-STATUS:GET-MESSAGE(1).
                       LEAVE Associado.
                   END.
            END.

        LEAVE Associado.
    END.

    IF  aux_dscritic = "" AND aux_cdcritic = 0 THEN
        Titular: DO ON ERROR UNDO, RETURN:
            Busca: FOR EACH crapttl FIELDS(idseqttl nmextttl nrcpfcgc) 
                             WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta NO-LOCK
                             BY crapttl.idseqttl:
    
                FIND tt-titular WHERE tt-titular.idseqttl = crapttl.idseqttl 
                                      NO-ERROR.
    
                IF   NOT AVAILABLE tt-titular THEN
                     DO:
                         CREATE tt-titular.
                         ASSIGN 
                             tt-titular.idseqttl = crapttl.idseqttl 
                             tt-titular.nmextttl = crapttl.nmextttl NO-ERROR.
    
                         IF  ERROR-STATUS:ERROR THEN
                             DO:
                                 ASSIGN aux_dscritic = "Erro ao criar os dados"
                                                       + " do titular." + 
                                                    ERROR-STATUS:GET-MESSAGE(1).
                                 LEAVE Busca.
                             END.
                     END.
            END.

            LEAVE Titular.
        END.

    IF   aux_dscritic <> "" OR aux_cdcritic <> 0 THEN 
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
         END.
    ELSE ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

/*................................. FUNCTIONS ................................*/
FUNCTION BuscaSitConta RETURNS CHARACTER
    ( INPUT par_cdsitdct AS INTEGER ):

    RETURN (IF par_cdsitdct = 1
               THEN "NORMAL"
            ELSE
            IF par_cdsitdct = 2
               THEN "ENCERRADA PELO ASSOCIADO"
            ELSE
            IF par_cdsitdct = 3
               THEN "ENCERRADA PELA COOP"
            ELSE
            IF par_cdsitdct = 4
               THEN "ENCERRADA PELA DEMISSAO"
            ELSE
            IF par_cdsitdct = 5
               THEN "NAO APROVADA"
            ELSE
            IF par_cdsitdct = 6
               THEN "NORMAL - SEM TALAO"
			ELSE
            IF par_cdsitdct = 9
               THEN "ENCERRADA P/ OUTRO MOTIVO"
            ELSE "").

END FUNCTION.

/*............................................................................*/
