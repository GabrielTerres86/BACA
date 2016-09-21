/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0152.p
     Autor   : Gabriel Capoia
     Data    : 20/02/2013                    Ultima atualizacao: 01/07/2013

     Objetivo  : BO de Comunicacao XML x BO - Tela CLDPAC

     Alteracoes: Inclusão de parametro na grava_dados: par_confirem
                 (Reinert)

                10/06/2014 - Incluido rotina verifica_fechamento 
				             (Chamado 143945) - (Andrino-RKAM).

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
DEF VAR aux_cddopcao  AS CHAR                                        NO-UNDO.
DEF VAR aux_cdagenca  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdconta  AS INTE                                        NO-UNDO.
DEF VAR aux_nrcpfcgc  AS DECI                                        NO-UNDO.
DEF VAR aux_dtmvtola  AS DATE                                        NO-UNDO.
DEF VAR aux_flextjus  AS LOGI                                        NO-UNDO.
DEF VAR aux_cddjusti  AS INTE                                        NO-UNDO.
DEF VAR aux_dsdjusti  AS CHAR                                        NO-UNDO.
DEF VAR aux_dsobserv  AS CHAR                                        NO-UNDO.
DEF VAR aux_cdopera1  AS INTE                                        NO-UNDO.
DEF VAR aux_nrdrowid  AS ROWID                                       NO-UNDO.
DEF VAR aux_confirem  AS CHAR                                        NO-UNDO.



DEF VAR aux_nmdcampo  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmprimtl  AS CHAR                                        NO-UNDO.


{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0152tt.i }

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
             WHEN "cddopcao"  THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "cdagenca"  THEN aux_cdagenca = tt-param.valorCampo.
             WHEN "dtmvtola"  THEN aux_dtmvtola = DATE(tt-param.valorCampo).
             WHEN "dtmvtoan"  THEN aux_dtmvtoan = DATE(tt-param.valorCampo).

             WHEN "flextjus"  THEN aux_flextjus = IF  tt-param.valorCampo = "YES" THEN
                                                       YES
                                                  ELSE NO.
             WHEN "cddjusti"  THEN aux_cddjusti = INTE(tt-param.valorCampo).
             WHEN "dsdjusti"  THEN aux_dsdjusti = tt-param.valorCampo.
             WHEN "dsobserv"  THEN aux_dsobserv = tt-param.valorCampo.
             WHEN "cdopera1"  THEN aux_cdopera1 = INTE(tt-param.valorCampo).
             WHEN "nrdrowid"  THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
             WHEN "confirem"  THEN aux_confirem = tt-param.valorCampo.
                 
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
                    INPUT aux_cddopcao,
                    INPUT aux_cdagenca,
                    INPUT aux_dtmvtola,
                    INPUT TRUE, /* flgerlog */
                    INPUT aux_dtmvtoan,
                   OUTPUT aux_nmdcampo, 
                   OUTPUT TABLE tt-creditos,
                   OUTPUT TABLE tt-just,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-creditos:HANDLE,
                            INPUT "Credito").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlExport (INPUT TEMP-TABLE tt-just:HANDLE,
                            INPUT "Justificativa").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*                EFETUA A CONSULTA DOS CONTRATOS AVALIZADOS                */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_nmdatela,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_flextjus,
                    INPUT aux_cddjusti,
                    INPUT aux_dsdjusti,
                    INPUT aux_dsobserv,
                    INPUT aux_cdopera1,
                    INPUT aux_nrdrowid,
                    INPUT aux_confirem,
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
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */


/* ------------------------------------------------------------------------ */
/*                EFETUA A VALIDACAO DO FECHAMENTO DO PERIODO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Fechamento:

    RUN Verifica_Fechamento IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_dtmvtolt,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_nmdatela,
                    INPUT aux_idorigem,
                   OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "verificacao de fechamento.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE. /* Verifica_Fechamento */
