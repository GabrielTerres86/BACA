
/* ............................................................................

   Programa: sistema/generico/procedures/xb1wgen0194.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Janeiro/2015.                       Ultima atualizacao:  /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Interacao da CONTAS - Convenio CDC Web com BO 194
               referente ao Cadastro de Convenio CDC

   Alteracoes:
   
............................................................................ */

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci LIKE crapass.cdagenci                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_flgativo AS LOG                                            NO-UNDO.
DEF VAR aux_dtcnvcdc AS DATE                                           NO-UNDO.

DEF VAR aux_nrdcaixa AS INT                                            NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0002tt.i }

/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:
    
    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = STRING(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = STRING(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = STRING(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "flgativo" THEN aux_flgativo = LOGICAL(tt-param.valorCampo).
            WHEN "dtcnvcdc" THEN aux_dtcnvcdc = DATE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


PROCEDURE pc-busca-convenios:

    RUN pc-busca-convenios IN hBO
                          (INPUT aux_cdcooper,
                           INPUT aux_dtmvtolt,
                           INPUT aux_nmdatela,
                           INPUT aux_cddopcao,
                           INPUT aux_idorigem,
                           INPUT aux_cdoperad,
                           INPUT aux_nrdconta,
                           OUTPUT aux_flgativo,
                           OUTPUT aux_dtcnvcdc,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.
        
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        
    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "flgativo",INPUT STRING(aux_flgativo)).
        RUN piXmlAtributo (INPUT "dtcnvcdc",INPUT STRING(aux_dtcnvcdc)).
        RUN piXmlSave.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE pc-alterar-convenios:

    RUN pc-alterar-convenios IN hBO
                            (INPUT aux_cdcooper,
                             INPUT aux_dtmvtolt,
                             INPUT aux_nmdatela,
                             INPUT aux_cddopcao,
                             INPUT aux_idorigem,
                             INPUT aux_cdoperad,
                             INPUT aux_nrdconta,
                             INPUT aux_flgativo,
                             INPUT aux_dtcnvcdc,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

