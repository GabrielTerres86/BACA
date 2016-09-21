/* ........................................................................... 

   Programa: xb1wgen0084b.p
   Autor   : Gabriel
   Data    : Outubro/2012                      Ultima atualizacao: 25/02/2013
           
   Dados referentes ao programa:
   
   Objetivo  : BO de comunicacao XML VS BO
   
   Alteracoes: 25/02/2013 - Passar o numero do contrato para a procedure
                            de validacao de pagamento (Gabriel).   
                                                                              
........................................................................... */

DEF VAR aux_cdcooper AS INTE                                          NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                          NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                          NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                          NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                          NO-UNDO.
DEF VAR aux_idorigem AS INTE                                          NO-UNDO. 
DEF VAR aux_nrdconta AS INTE                                          NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                          NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                          NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                          NO-UNDO.
DEF VAR aux_vlapagar AS DECI                                          NO-UNDO.
DEF VAR aux_vlsomato AS DECI                                          NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                          NO-UNDO.

{ sistema/generico/includes/var_internet.i  }
{ sistema/generico/includes/supermetodos.i  }

PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
             WHEN "dtrefere" THEN aux_dtrefere = DATE(tt-param.valorCampo).
             WHEN "vlapagar" THEN aux_vlapagar = DEC(tt-param.valorCampo).
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
             WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).

        END.

    END.

END.



PROCEDURE valida_pagamentos_geral:
    
    RUN valida_pagamentos_geral IN hBo (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrctremp,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_flgerlog,
                                        INPUT aux_dtrefere,
                                        INPUT aux_vlapagar,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT aux_vlsomato,
                                        OUTPUT TABLE tt-msg-confirma).

    IF   RETURN-VALUE <> "OK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
             IF  NOT AVAILABLE tt-erro  THEN
                 DO:
                     CREATE tt-erro.
                     ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                               "operacao.".
                 END.
                 
             RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
         END.
    ELSE 
         DO:  
             RUN piXmlNew.   
             RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                              INPUT "Pagamentos").
             RUN piXmlSave.   
         END.

END PROCEDURE. /* valida pagamentos geral */


/* ......................................................................... */
