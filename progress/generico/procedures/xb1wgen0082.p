/* ........................................................................... 

   Programa: xb1wgen0082.p
   Autor   : Gabriel
   Data    : Dezembro/2010                  Ultima atualizacao: 23/11/2015
           
   Dados referentes ao programa:
   
   Objetivo  : BO de comunicacao XML VS BO da Rotina de COBRANCA da ATENDA.
   
   Alteracoes: 19/05/2011 - Tratar flgregis p/ cobranca registrada (Guilherme).
   
               21/07/2011 - Tratar impressao da cobranca registrada (Gabriel).
               
               10/05/2013 - Apagado proc. valida-dados-titulares-limites.
                            Retirado valor maximo de boleto. (Jorge) 
                            
               19/09/2013 - Inclusao do parametro flgcebhm, procedure
                            habilita-convenio (Carlos)
                                              
               07/08/2014 - Inserir o parametro de nrconven na chamada da 
                            rotina obtem-dados-adesao  (Renato - Supero)                                
                            
               28/04/2015 - Ajustes referente ao projeto DP 219 - Cooperativa
                            emite e expede. (Reinert)
               
               23/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                            (Jaison/Andrino)
                            
               14/01/2016 - Incluso no parametro flserasa na procedure
                            valida-habilitacao (Daniel/Projeto Neg. Serasa) 
               
........................................................................... */

DEF VAR aux_cdcooper AS INTE                                          NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                          NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                          NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                          NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                          NO-UNDO.
DEF VAR aux_idorigem AS INTE                                          NO-UNDO. 
DEF VAR aux_nrdconta AS INTE                                          NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                          NO-UNDO.
DEF VAR aux_flcooexp AS INTE                                          NO-UNDO.
DEF VAR aux_flceeexp AS INTE                                          NO-UNDO.
DEF VAR aux_nrconven AS INTE                                          NO-UNDO.
DEF VAR aux_nrcnvceb AS INTE                                          NO-UNDO.
DEF VAR aux_dsdmesag AS CHAR                                          NO-UNDO.
DEF VAR aux_flgbolet AS LOGI                                          NO-UNDO.
DEF VAR aux_inarqcbr AS INTE                                          NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                          NO-UNDO.
DEF VAR aux_dsorgarq AS CHAR                                          NO-UNDO.
DEF VAR aux_dssitceb AS LOGI                                          NO-UNDO.
DEF VAR aux_cddemail AS INTE                                          NO-UNDO.
DEF VAR aux_flgcruni AS LOGI                                          NO-UNDO.
DEF VAR aux_flgcebhm AS LOGI                                          NO-UNDO.
DEF VAR aux_dsdregis AS CHAR                                          NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                          NO-UNDO.
DEF VAR aux_flgregis AS CHAR                                          NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                          NO-UNDO.
DEF VAR aux_nmdtest1 AS CHAR                                          NO-UNDO.
DEF VAR aux_cpftest1 AS DECI                                          NO-UNDO.
DEF VAR aux_nmdtest2 AS CHAR                                          NO-UNDO.
DEF VAR aux_cpftest2 AS DECI                                          NO-UNDO.
DEF VAR aux_flserasa AS INTE                                          NO-UNDO.

DEF VAR par_dsdmesag AS CHAR                                          NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                          NO-UNDO.
DEF VAR par_dsdtitul AS CHAR                                          NO-UNDO.
DEF VAR par_flgregis AS LOGI                                          NO-UNDO.
DEF VAR par_flgimpri AS LOGI                                          NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0082tt.i }


/*............................... PROCEDURES ...............................*/

PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "flcooexp" THEN aux_flcooexp = INTE(tt-param.valorCampo).
            WHEN "flceeexp" THEN aux_flceeexp = INTE(tt-param.valorCampo).                
            WHEN "nrconven" THEN aux_nrconven = INTE(tt-param.valorCampo).
            WHEN "nrcnvceb" THEN aux_nrcnvceb = INTE(tt-param.valorCampo).
            WHEN "flgbolet" THEN aux_flgbolet = LOGICAL(tt-param.valorCampo).
            WHEN "inarqcbr" THEN aux_inarqcbr = INTE(tt-param.valorCampo).
            WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "dssitceb" THEN aux_dssitceb = LOGICAL(tt-param.valorCampo).
            WHEN "cddemail" THEN aux_cddemail = INTE(tt-param.valorCampo).
            WHEN "flgcruni" THEN aux_flgcruni = LOGICAL(tt-param.valorCampo).
            WHEN "flgcebhm" THEN aux_flgcebhm = LOGICAL(tt-param.valorCampo).
            WHEN "dsdregis" THEN aux_dsdregis = tt-param.valorCampo.
            WHEN "dsorgarq" THEN aux_dsorgarq = tt-param.valorCampo.
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "dsdtitul" THEN par_dsdtitul = tt-param.valorCampo.
            WHEN "flgregis" THEN par_flgregis = LOGICAL(tt-param.valorCampo).
            WHEN "nmdtest1" THEN aux_nmdtest1 = tt-param.valorCampo.
            WHEN "cpftest1" THEN aux_cpftest1 = DECI(tt-param.valorCampo).
            WHEN "nmdtest2" THEN aux_nmdtest2 = tt-param.valorCampo.
            WHEN "cpftest2" THEN aux_cpftest2 = DECI(tt-param.valorCampo).
            WHEN "flserasa" THEN aux_flserasa = INTE(tt-param.valorCampo).
                               
       END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/*****************************************************************************
 Procedure que traz os convenios do cooperado.
*****************************************************************************/
PROCEDURE carrega-convenios-ceb:

    RUN carrega-convenios-ceb IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_dtmvtolt,
                                      INPUT TRUE,
                                     OUTPUT par_dsdmesag,
                                     OUTPUT TABLE tt-cadastro-bloqueto,
                                     OUTPUT TABLE tt-crapcco,
                                     OUTPUT TABLE tt-titulares,
                                     OUTPUT TABLE tt-emails-titular).

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
             RUN piXmlExport (INPUT TEMP-TABLE tt-cadastro-bloqueto:HANDLE,
                              INPUT "Convenios").                                   
             RUN piXmlExport (INPUT TEMP-TABLE tt-titulares:HANDLE,
                              INPUT "Titulares").      
             RUN piXmlExport (INPUT TEMP-TABLE tt-emails-titular:HANDLE,
                              INPUT "Emails").
             RUN piXmlAtributo (INPUT "dsdmesag", INPUT par_dsdmesag).
             RUN piXmlSave.   
         END.

END PROCEDURE.


/******************************************************************************
 Procedure que valida a exclusao do convenio CEB.
******************************************************************************/
PROCEDURE valida-exclusao-convenio:

    RUN valida-exclusao-convenio IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrconven,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT TRUE,
                                        OUTPUT TABLE tt-erro).

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
             RUN piXmlSave.
         END. 

END PROCEDURE.


/******************************************************************************
 Procedure que exclui o convenio CEB cadastrado para o cooperado.
******************************************************************************/
PROCEDURE exclui-convenio:

    RUN exclui-convenio IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_nrconven,
                                INPUT aux_nrcnvceb,
                                INPUT aux_idseqttl,
                                INPUT aux_dtmvtolt,
                                INPUT TRUE,
                               OUTPUT TABLE tt-erro).

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
             RUN piXmlSave.
         END. 

END PROCEDURE.


/******************************************************************************
  Procedure que valida a habilitacao do convenio 
******************************************************************************/
PROCEDURE valida-habilitacao:

    RUN valida-habilitacao IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrconven,
                                   INPUT aux_idseqttl,
                                   INPUT aux_dtmvtolt,
                                   INPUT TRUE,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT aux_dsorgarq,
                                  OUTPUT aux_flgregis,
                                  OUTPUT aux_cddbanco,
                                  OUTPUT aux_flserasa).

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
             RUN piXmlAtributo (INPUT "dsorgarq", INPUT aux_dsorgarq).
             RUN piXmlAtributo (INPUT "flgregis", INPUT aux_flgregis).
             RUN piXmlAtributo (INPUT "cddbanco", INPUT aux_cddbanco).
             RUN piXmlAtributo (INPUT "flserasa", INPUT aux_flserasa).
             RUN piXmlSave.
         END. 

END PROCEDURE.


/******************************************************************************
              Procedure validar limites de operacoes na Internet           
******************************************************************************/
PROCEDURE valida-dados-limites:

    RUN valida-dados-limites IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dsorgarq,
                                     INPUT aux_inarqcbr,
                                     INPUT aux_cddemail,
                                     INPUT TRUE,
                                    OUTPUT TABLE tt-erro).

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
             RUN piXmlSave.
         END. 

END PROCEDURE.



/*****************************************************************************
 Procedure que habilita o convenio do cooperado.
*****************************************************************************/
PROCEDURE habilita-convenio:

    RUN habilita-convenio IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_nrconven,
                                  INPUT aux_dssitceb,
                                  INPUT aux_inarqcbr,
                                  INPUT aux_cddemail,
                                  INPUT aux_flgcruni,
                                  INPUT aux_flgcebhm,
                                  INPUT aux_dsdregis,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_flcooexp,
                                  INPUT aux_flceeexp,
                                  INPUT aux_flserasa,
                                  INPUT TRUE,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT aux_dsdmesag,
                                 OUTPUT par_dsdtitul,
                                 OUTPUT par_flgimpri).

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
             RUN piXmlAtributo (INPUT "dsdmesag", INPUT aux_dsdmesag).
             RUN piXmlAtributo (INPUT "dsdtitul", INPUT par_dsdtitul).
             RUN piXmlAtributo (INPUT "flgimpri", INPUT par_flgimpri).
             RUN piXmlSave.
         END. 

END PROCEDURE.


/*****************************************************************************
 Procedure que gera o arquivo para impressao do termo de adesao.
*****************************************************************************/
PROCEDURE obtem-dados-adesao:

    RUN obtem-dados-adesao IN hBo (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT par_flgregis,
                                   INPUT aux_nmdtest1,
                                   INPUT aux_cpftest1,
                                   INPUT aux_nmdtest2,
                                   INPUT aux_cpftest2,
                                   INPUT aux_dsiduser,
                                   INPUT par_dsdtitul,
                                   INPUT aux_dtmvtolt,
                                   INPUT TRUE,
                                   INPUT aux_nrconven,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT par_nmarqimp,
                                  OUTPUT par_nmarqpdf).

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
             RUN piXmlAtributo (INPUT "nmarqpdf", INPUT par_nmarqpdf).
             RUN piXmlSave.
         END. 

END PROCEDURE.

/* ........................................................................ */


