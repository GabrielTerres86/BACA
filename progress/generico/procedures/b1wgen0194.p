/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0194.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Janeiro/2015.                       Ultima atualizacao:  /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO referente ao Cadastro de Convenio CDC

   Alteracoes:
   
............................................................................ */

DEF STREAM str_1.  /*  Para relatorio  */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

/******************************************************************************/

PROCEDURE pc-busca-convenios:

    /* Busca dados de convenio CDC */

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                 NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM ret_flgativo AS LOGI                              NO-UNDO.
    DEF OUTPUT PARAM ret_dtcnvcdc AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    /* Verifica a opcao da tela */
    IF  NOT CAN-DO(par_cddopcao,"C") THEN DO:
        ASSIGN aux_cdcritic = 14.
               aux_dscritic = "".
    
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        RETURN "NOK".
    END.

    /* Busca Convenio CDC */
    FIND FIRST crapcdr WHERE crapcdr.cdcooper = par_cdcooper
                         AND crapcdr.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.

    IF  AVAIL crapcdr THEN
        ASSIGN ret_flgativo = crapcdr.flgconve
               ret_dtcnvcdc = crapcdr.dtinicon.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE pc-alterar-convenios:

    /* Alteracao de convenio CDC */

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                 NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_flgativo AS LOGI                               NO-UNDO.
    DEF INPUT PARAM par_dtcnvcdc AS DATE                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.


    /* Verifica a opcao da tela */
    IF  NOT CAN-DO(par_cddopcao,"A") THEN DO:
        ASSIGN aux_cdcritic = 14.
               aux_dscritic = "".
    
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        RETURN "NOK".
    END.

    /* Se for incluir o convenio e a data nao
    for informado, grava a data do movimento */
    IF  par_flgativo AND par_dtcnvcdc = ? THEN
        ASSIGN par_dtcnvcdc = par_dtmvtolt.
    ELSE
    IF  NOT par_flgativo THEN
        ASSIGN par_dtcnvcdc = ?. /* Limpa Variavel */

    /* Busca Convenio CDC */
    FIND FIRST crapcdr WHERE crapcdr.cdcooper = par_cdcooper
                         AND crapcdr.nrdconta = par_nrdconta
                         EXCLUSIVE-LOCK NO-ERROR.

    IF  AVAIL crapcdr THEN DO:

        ASSIGN crapcdr.flgconve = par_flgativo
               crapcdr.dtinicon = par_dtcnvcdc
               crapcdr.cdoperad = par_cdoperad.

        RETURN "OK".
    END.
    
    CREATE crapcdr.
    ASSIGN crapcdr.cdcooper = par_cdcooper
           crapcdr.nrdconta = par_nrdconta
           crapcdr.flgconve = par_flgativo
           crapcdr.dtinicon = par_dtcnvcdc
           crapcdr.cdoperad = par_cdoperad.

    VALIDATE crapcdr.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
