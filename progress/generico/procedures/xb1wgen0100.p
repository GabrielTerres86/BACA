/*..........................................................................

    Programa: sistema/generico/procedures/xb1wgen0100.p
    Autor   : Gabriel
    Data    : Junho/2011               Ultima Atualizacao:
     
    Dados referentes ao programa:
   
    Objetivo  : BO de comunicacao para a B1wgen0100.p.
                 
    Alteracoes: 

..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                        NO-UNDO.
DEF VAR aux_cdsenha1 AS CHAR                                        NO-UNDO.
DEF VAR aux_cdsenha2 AS CHAR                                        NO-UNDO.
DEF VAR aux_cdsenha3 AS CHAR                                        NO-UNDO.

DEF VAR par_nmdcampo AS CHAR                                        NO-UNDO.


{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ........................... */


/**************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML **/
/**************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:
    
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "cdsenha1" THEN aux_cdsenha1 = tt-param.valorCampo.
            WHEN "cdsenha2" THEN aux_cdsenha2 = tt-param.valorCampo.
            WHEN "cdsenha3" THEN aux_cdsenha3 = tt-param.valorCampo.

        END.

    END.

END PROCEDURE.


/* Procedure para validar/alterar os dados da tela MUDEN */
PROCEDURE valida-altera-senha:

    RUN valida-altera-senha IN hBo(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_cdoperad,
                                   INPUT aux_cdsenha1,
                                   INPUT aux_cdsenha2,
                                   INPUT aux_cdsenha3,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT par_nmdcampo).

    IF   RETURN-VALUE <> "OK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
             IF  NOT AVAILABLE tt-erro  THEN
                 DO:
                     CREATE tt-erro.
                     ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                               "operacao.".
                 END.
                 
             RUN piXmlNew.
             RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                              INPUT "Erro").
             RUN piXmlAtributo (INPUT "nmdcampo",INPUT par_nmdcampo).
             RUN piXmlSave.
         END.
    ELSE
         DO:
             RUN piXmlNew.
             RUN piXmlSave.
         END.

END PROCEDURE.

/* .......................................................................*/
