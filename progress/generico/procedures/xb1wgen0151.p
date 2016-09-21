/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0151.p
     Autor   : Gabriel Capoia
     Data    : 26/01/2013                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela CTASAL

     Alteracoes: 23/04/2015 - Ajustando a tela CTASAL
                              Projeto 158 - Servico Folha de Pagto
                              (Andre Santos - SUPERO)

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
DEF VAR aux_cddopcao  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmfuncio  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdigtrf  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmprimtl  AS CHAR                                        NO-UNDO.
DEF VAR aux_cdagenca  AS INTE                                        NO-UNDO.
DEF VAR aux_cdempres  AS INTE                                        NO-UNDO.
DEF VAR aux_cdbantrf  AS INTE                                        NO-UNDO.
DEF VAR aux_cdagetrf  AS INTE                                        NO-UNDO.
DEF VAR aux_nrctatrf  AS INTE                                        NO-UNDO.
DEF VAR aux_nrcpfcgc  AS DECI                                        NO-UNDO.
DEF VAR aux_flgsolic  AS LOGI                                        NO-UNDO.

DEF VAR aux_nmdcampo  AS CHAR                                        NO-UNDO.
DEF VAR aux_msgconfi  AS CHAR                                        NO-UNDO.
DEF VAR aux_dtcantrf  AS DATE                                        NO-UNDO.
DEF VAR aux_dtadmiss  AS DATE                                        NO-UNDO.
DEF VAR aux_cdsitcta  AS CHAR                                        NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0151tt.i }

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
             WHEN "nmprimtl"  THEN aux_nmprimtl = tt-param.valorCampo.
             WHEN "nrdconta"  THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "cddopcao"  THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "nmfuncio"  THEN aux_nmfuncio = tt-param.valorCampo.
             WHEN "nrdigtrf"  THEN aux_nrdigtrf = tt-param.valorCampo.
             WHEN "inproces"  THEN aux_inproces = INTE(tt-param.valorCampo).
             WHEN "cdagenca"  THEN aux_cdagenca = INTE(tt-param.valorCampo).
             WHEN "cdempres"  THEN aux_cdempres = INTE(tt-param.valorCampo).
             WHEN "cdbantrf"  THEN aux_cdbantrf = INTE(tt-param.valorCampo).
             WHEN "cdagetrf"  THEN aux_cdagetrf = INTE(tt-param.valorCampo).
             WHEN "nrctatrf"  THEN aux_nrctatrf = INTE(tt-param.valorCampo).
             WHEN "nrcpfcgc"  THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
             WHEN "flgsolic"  THEN aux_flgsolic = IF   tt-param.valorCampo = "YES" THEN
                                                       TRUE
                                                  ELSE FALSE.
                 
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_nmdatela,
                    INPUT aux_idorigem,
                    INPUT aux_nrdconta,
                    INPUT aux_cddopcao,
                    INPUT TRUE, /* flgerlog */
                   OUTPUT aux_msgconfi, 
                   OUTPUT TABLE tt-crapccs,
                   OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro  THEN DO:
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
    IF  RETURN-VALUE = "OK" AND aux_msgconfi <> "" THEN DO:
        /* Opcoes que nao podem ser executadas
        porque a conta esta cancelada */
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro  THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_msgconfi.
        END.
        
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                         INPUT "Erro").
        RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
        RUN piXmlSave.
    END.
    ELSE DO:
       RUN piXmlNew.
       RUN piXmlExport (INPUT TEMP-TABLE tt-crapccs:HANDLE,
                       INPUT "Contas").
       RUN piXmlAtributo (INPUT "msgconfi", INPUT aux_msgconfi).
       RUN piXmlSave.
    END.

END PROCEDURE. /* Busca_Dados */

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_idorigem,
                    INPUT aux_nrdconta,
                    INPUT aux_cddopcao,
                    INPUT aux_cdagenca,
                    INPUT aux_cdempres,
                    INPUT aux_cdbantrf,
                    INPUT aux_cdagetrf,
                    INPUT aux_nrctatrf,
                    INPUT aux_nrdigtrf,
                    INPUT aux_nrcpfcgc,
                   OUTPUT aux_nmdcampo, 
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
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Dados */

PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_dtmvtolt,
                    INPUT aux_idorigem,
                    INPUT aux_nrdconta,
                    INPUT aux_cddopcao,
                    INPUT aux_cdagenca,
                    INPUT aux_cdempres,
                    INPUT aux_nmfuncio,
                    INPUT aux_cdagetrf,
                    INPUT aux_cdbantrf,
                    INPUT aux_nrdigtrf,
                    INPUT aux_nrctatrf,
                    INPUT aux_nrcpfcgc,
                    INPUT TRUE, /* flgerlog */
                   OUTPUT aux_nmdcampo,
                   OUTPUT aux_dtcantrf,
                   OUTPUT aux_dtadmiss,
                   OUTPUT aux_cdsitcta,
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
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlAtributo (INPUT "dtcantrf", INPUT aux_dtcantrf).
           RUN piXmlAtributo (INPUT "dtadmiss", INPUT aux_dtadmiss).
           RUN piXmlAtributo (INPUT "cdsitcta", INPUT aux_cdsitcta).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Grava_Dados */

PROCEDURE Gera_Impressao:

    RUN Gera_Impressao IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_dtmvtolt,
                       INPUT aux_idorigem,
                       INPUT aux_nrdconta,
                       INPUT aux_cdagenca,
                       INPUT aux_cdempres,
                       INPUT aux_cdbantrf,
                       INPUT aux_cdagetrf,
                       INPUT aux_flgsolic,
                       INPUT aux_dsiduser,
                       INPUT TRUE, /* flgerlog */
                      OUTPUT aux_nmarqimp,
                      OUTPUT aux_nmarqpdf,
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
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Impressao */

PROCEDURE Pesquisa_Nome:

    RUN Pesquisa_Nome IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_nmprimtl,
                   OUTPUT TABLE tt-crapccs,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapccs:HANDLE,
                            INPUT "Contas").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Pesquisa_Nome */
