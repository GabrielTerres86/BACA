/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0145.p
     Autor   : Gabriel Capoia
     Data    : 07/01/2013                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela AVALIS

     Alteracoes: 

............................................................................*/



/*..........................................................................*/

DEF VAR aux_cdcooper  AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa  AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela  AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem  AS INTE                                        NO-UNDO.
DEF VAR aux_cdprogra  AS CHAR                                        NO-UNDO.
DEF VAR aux_dsiduser  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdconta  AS INTE                                        NO-UNDO.
DEF VAR aux_nrcpfcgc  AS DECI                                        NO-UNDO.

DEF VAR aux_nmdcampo  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmprimtl  AS CHAR                                        NO-UNDO.


{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0145tt.i }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper"  THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci"  THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa"  THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad"  THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela"  THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "dtmvtolt"  THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtopr"  THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
             WHEN "idorigem"  THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "cdprogra"  THEN aux_cdprogra = tt-param.valorCampo.
             
             WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmarqimp"  THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf"  THEN aux_nmarqpdf = tt-param.valorCampo.
             WHEN "nrdconta"  THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "nrcpfcgc"  THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
             WHEN "inproces"  THEN aux_inproces = INTE(tt-param.valorCampo).
             WHEN "nmprimtl"  THEN aux_nmprimtl = tt-param.valorCampo.

                 
                 
             
                 
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                EFETUA A CONSULTA DOS CONTRATOS AVALIZADOS                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_nmdatela,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_dtmvtopr,
                    INPUT aux_inproces,
                    INPUT aux_nrdconta,
                    INPUT aux_nrcpfcgc,
                    INPUT TRUE, /* flgerlog */
                   OUTPUT aux_nmdcampo, 
                   OUTPUT aux_nmprimtl, 
                   OUTPUT aux_nrdconta,
                   OUTPUT aux_nrcpfcgc,
                   OUTPUT TABLE tt-contras,
                   OUTPUT TABLE tt-msgconta,
                   OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-contras:HANDLE,
                            INPUT "Contrato").
           RUN piXmlAtributo (INPUT "nmprimtl", INPUT aux_nmprimtl).
           RUN piXmlAtributo (INPUT "nrdconta", INPUT aux_nrdconta).
           RUN piXmlAtributo (INPUT "nrcpfcgc", INPUT aux_nrcpfcgc).
           RUN piXmlExport (INPUT TEMP-TABLE tt-msgconta:HANDLE,
                            INPUT "Mensagem").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/*                EFETUA A CONSULTA DOS CONTRATOS AVALIZADOS                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Avalista:

    RUN Busca_Avalista IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_nmprimtl,
                       INPUT TRUE, /* flgerlog */
                      OUTPUT TABLE tt-avalistas,
                      OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-avalistas:HANDLE,
                            INPUT "Avalista").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Avalista */
