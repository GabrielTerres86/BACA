/*...........................................................................

    Programa: sistema/generico/procedures/b1wgen0100.p
    Autor   : Gabriel
    Data    : Junho/2011               Ultima Atualizacao:
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela MUDSEN.
                 
    Alteracoes: 

...........................................................................*/

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/gera_log.i     }                              
{ sistema/generico/includes/gera_erro.i    }


DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.                         
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.


/* Procedure para validar os dados da tela MUDEN */
PROCEDURE valida-altera-senha:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsenha1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsenha2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsenha3 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.


    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

       FIND crapope WHERE crapope.cdcooper = par_cdcooper    AND
                          crapope.cdoperad = par_cdoperad    NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapope   THEN
            DO:
                ASSIGN aux_cdcritic = 67
                       par_nmdcampo = "cdoperad".
                LEAVE.
            END.

       IF   par_cdsenha1 = crapope.cddsenha   THEN
            IF   par_cdsenha2 = par_cdsenha3   THEN
                 IF   par_cdsenha2 = crapope.cddsenha   THEN
                      DO:
                          ASSIGN aux_cdcritic = 6
                                 par_nmdcampo = "cdsenha2".
                          LEAVE.
                      END.
                 ELSE
                 IF   par_cdsenha2 = ""   THEN
                      DO:
                          ASSIGN aux_cdcritic = 5
                                 par_nmdcampo = "cdsenha2".
                          LEAVE.
                      END.
                 ELSE
                      . /* Validacao Ok */
            ELSE
                 DO:
                     ASSIGN aux_cdcritic = 7
                            par_nmdcampo = "cdsenha3".
                     LEAVE.
                 END.
       ELSE
            DO:
                ASSIGN aux_cdcritic = 3
                       par_nmdcampo = "cdsenha1".
                LEAVE.
            END.

       RUN altera-senha (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_dtmvtolt,
                         INPUT par_cdoperad,
                         INPUT par_cdsenha2,
                        OUTPUT TABLE tt-erro).

       IF   RETURN-VALUE <> "OK"   THEN
            LEAVE.

       ASSIGN aux_flgtrans = TRUE.
       LEAVE.

    END. /* Tratamento de criticas */             

    IF   NOT aux_flgtrans   THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,           
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).         
             RETURN "NOK".
         END.
         
    RETURN "OK".

END PROCEDURE.


/* Procedure para gravar nova Senha para o Operador */
PROCEDURE altera-senha:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsenha2 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF  VAR aux_contador AS INTE                                   NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO aux_contador = 1 TO 10 TRANSACTION:

       FIND crapope WHERE crapope.cdcooper = par_cdcooper    AND
                          crapope.cdoperad = par_cdoperad    
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAIL crapope   THEN
            IF   LOCKED crapope THEN
                 DO:
                     ASSIGN aux_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
             ELSE
                 DO:              
                     ASSIGN aux_cdcritic = 67.
                     LEAVE.
                 END.

       ASSIGN crapope.cddsenha = par_cdsenha2
              crapope.dtaltsnh = par_dtmvtolt
              aux_cdcritic     = 0.

       /* Tirar exclusive-lock */
       FIND CURRENT crapope NO-LOCK NO-ERROR.

       LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,           
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).         
             RETURN "NOK".
         END.
         
    RETURN "OK".

END PROCEDURE.


/* ........................................................................*/
