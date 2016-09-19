/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank80.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2012.                       Ultima atualizacao: 26/02/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Validar e executar cadastramento de favorecido.
   
   Alteracoes: 03/07/2012 - Ajuste de parametro na procedure
                            valida-inclusao-conta-transferencia (David Kistner)
                            
               15/12/2014 - Melhorias Cadastro de Favorecidos TED
                           (Andr� Santos - SUPERO)
                           
               15/04/2015 - Inclus�o do campo ISPB SD271603 FDR041 (Vanessa)
               
			   17/02/2016 - Melhorias para o envio e cadastro de contas para
                            efetivar TED, M. 118 (Jean Michel). 

               26/02/2016 - Inclus�o da tag <gravafav> no xml de retorno para
                            cadastro de favorecidos no Mobile (Dionathan) 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }

DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dscpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitula AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_msgaviso AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF  INPUT PARAM par_cddbanco AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdispbif AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdageban AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf                    NO-UNDO.
DEF  INPUT PARAM par_intipdif AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_intipcta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inpessoa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nmtitula AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfcgc AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_insitcta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flgexecu AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_rowidcti AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_flexclui AS CHAR                                  NO-UNDO.
                                                              
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

/* Verifica se o registro deve ser desativado */
IF  par_rowidcti <> "" AND
    par_flexclui <> "" THEN DO:

    /* Procedimento que ira remover o desativar o registro */
    RUN exclui-conta-transferencia IN h-b1wgen0015 
                                  (INPUT par_cdcooper,
                                   INPUT 90,
                                   INPUT 900,
                                   INPUT "996",
                                   INPUT "INTERNETBANK",
                                   INPUT 3,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_rowidcti,
                                   OUTPUT TABLE tt-erro).

    /* Verifica se ocorreu algum erro */
    IF  RETURN-VALUE <> "OK"  THEN DO:
        DELETE PROCEDURE h-b1wgen0015.

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erro  THEN
            ASSIGN aux_dscritic = tt-erro.dscritic. /* Critica */
        ELSE
            ASSIGN aux_dscritic = "Nao foi possivel remover o cadastro de favorecido.".
       
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>" +
                              "<nmdcampo>" + aux_nmdcampo + "</nmdcampo>".
        
        RETURN "NOK". /* Finaliza a operacao */
    END.

   RETURN "OK". /* Finaliza a operacao */
END.


/* Se for incluir ou alterar, validar o registro */
IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
    DO: 
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).
                
        RETURN "NOK".
    END.

ASSIGN aux_nmtitula = par_nmtitula.

FOR FIRST crapcti FIELDS(cdcooper) WHERE crapcti.cdcooper = par_cdcooper
                                     AND crapcti.nrdconta = par_nrdconta
                                     AND crapcti.cddbanco = par_cddbanco
                                     AND crapcti.cdageban = par_cdageban
                                     AND crapcti.nrcpfcgc = par_nrcpfcgc
                                     AND crapcti.nrctatrf = par_nrctatrf NO-LOCK. END.

IF NOT AVAIL crapcti THEN
    DO:

RUN valida-inclusao-conta-transferencia IN h-b1wgen0015 
                                       (INPUT par_cdcooper,
                                        INPUT 90,
                                        INPUT 900,
                                        INPUT "996",
                                        INPUT "INTERNETBANK",
                                        INPUT 3,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_dtmvtolt,
                                        INPUT TRUE,
                                        INPUT par_cddbanco,
                                        INPUT par_cdispbif,
                                        INPUT par_cdageban,
                                        INPUT par_nrctatrf,
                                        INPUT par_intipdif,
                                        INPUT par_intipcta,
                                        INPUT par_insitcta,
                                        INPUT par_inpessoa,
                                        INPUT par_nrcpfcgc,
                                        INPUT TRUE,
                                        INPUT par_rowidcti, /* Validacao de Registro */
                                        INPUT-OUTPUT aux_nmtitula,
                                       OUTPUT aux_dscpfcgc,
                                       OUTPUT aux_nmdcampo,
                                       OUTPUT TABLE tt-erro).


                               
IF  RETURN-VALUE <> "OK"  THEN
    DO: 
        DELETE PROCEDURE h-b1wgen0015.

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erro  THEN
            ASSIGN aux_dscritic = tt-erro.dscritic.
        ELSE
            ASSIGN aux_dscritic = "Nao foi possivel validar o cadastro.".

        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>" +
                              "<nmdcampo>" + aux_nmdcampo + "</nmdcampo>".
        
        RETURN "NOK".
    END.

/** Executar cadastramento do favorecido **/
IF  par_flgexecu  THEN
    DO: 
       
        RUN inclui-conta-transferencia IN h-b1wgen0015 
                                      (INPUT par_cdcooper,
                                       INPUT 90,
                                       INPUT 900,
                                       INPUT "996",
                                       INPUT "INTERNETBANK",
                                       INPUT 3,
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT par_dtmvtolt,
                                       INPUT par_nrcpfope,
                                       INPUT TRUE,
                                       INPUT par_cddbanco,
                                       INPUT par_cdageban,
                                       INPUT par_nrctatrf,
                                       INPUT par_nmtitula,
                                       INPUT par_nrcpfcgc,
                                       INPUT par_inpessoa,
                                       INPUT par_intipcta,
                                       INPUT par_intipdif,
                                       INPUT par_insitcta,
                                       INPUT par_rowidcti, /* Alteracao de Registro */
                                       INPUT par_cdispbif,
                                       OUTPUT aux_msgaviso,
                                      OUTPUT TABLE tt-autorizacao-favorecido,
                                      OUTPUT TABLE tt-erro).
    
        IF  RETURN-VALUE <> "OK"  THEN
            DO: 
                DELETE PROCEDURE h-b1wgen0015.
        
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                IF  AVAIL tt-erro  THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                ELSE
                    ASSIGN aux_dscritic = "Nao foi possivel efetuar o cadastro.".
        
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>" +
                                      "<nmdcampo>" + aux_nmdcampo + "</nmdcampo>".
                
                RETURN "NOK".
            END.

        FIND FIRST tt-autorizacao-favorecido NO-LOCK NO-ERROR.
            
        IF  AVAIL tt-autorizacao-favorecido  THEN
            DO: 
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<AUTORIZACAO><nmextcop>" + 
                                  tt-autorizacao-favorecido.nmextcop +
                                             "</nmextcop><nmrescop>" +
                                  tt-autorizacao-favorecido.nmrescop +
                                             "</nmrescop><cdbcoctl>" +
                                  STRING(tt-autorizacao-favorecido.cdbcoctl,
                                         "999") +
                                             "</cdbcoctl><cdagectl>" +
                                  STRING(tt-autorizacao-favorecido.cdagectl,
                                         "9999") +
                                             "</cdagectl><nrdconta>" +
                                  TRIM(STRING(tt-autorizacao-favorecido.nrdconta,
                                       "zzzz,zzz,9")) +
                                             "</nrdconta><nmextttl>" +
                                  tt-autorizacao-favorecido.nmextttl +
                                             "</nmextttl><nmprimtl>" +
                                  tt-autorizacao-favorecido.nmprimtl +
                                             "</nmprimtl><nmsegttl>" +
                                  tt-autorizacao-favorecido.nmsegttl +
                                             "</nmsegttl><cddbanco>" +
                                  STRING(tt-autorizacao-favorecido.cddbanco,
                                         "999") +
                                             "</cddbanco><cdageban>" +
                                  STRING(tt-autorizacao-favorecido.cdageban,
                                         "9999") +
                                             "</cdageban><nrctatrf>" +
                                  TRIM(STRING(tt-autorizacao-favorecido.nrctatrf,
                                              "zzzzzzzzzzzzzz,9")) +
                                             "</nrctatrf><nmtitula>" +
                                  tt-autorizacao-favorecido.nmtitula +
                                             "</nmtitula><dsprotoc>" +
                                  tt-autorizacao-favorecido.dsprotoc +
                                             "</dsprotoc><nrtelfax>" +
                                  tt-autorizacao-favorecido.nrtelfax +
                                             "</nrtelfax><dsdemail>" +
                                  tt-autorizacao-favorecido.dsdemail +
                                             "</dsdemail><nmopecad>" +
                                  tt-autorizacao-favorecido.nmopecad +
                                             "</nmopecad><idsequen>" +
                                  STRING(tt-autorizacao-favorecido.idsequen) +
                                             "</idsequen><dttransa>" +
                                  STRING(tt-autorizacao-favorecido.dttransa,
                                         "99/99/9999") +
                                             "</dttransa><hrtransa>" +
                                  STRING(tt-autorizacao-favorecido.hrtransa,
                                         "HH:MM:SS") +
                                             "</hrtransa><nmbcoctl>" +
                                  tt-autorizacao-favorecido.nmbcoctl +
                                             "</nmbcoctl><nmdbanco>" +
                                  tt-autorizacao-favorecido.nmdbanco +
                                             "</nmdbanco><nrispbif>" +
                                  STRING(tt-autorizacao-favorecido.nrispbif,
                                                 "zzzzzzzzz9") +
                                           "</nrispbif></AUTORIZACAO>".
            END.                
    END.
        ELSE
            DO:
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = '<gravafav>1</gravafav>'.
            END.

DELETE PROCEDURE h-b1wgen0015.
    END.
ELSE IF NOT par_flgexecu THEN
    DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = '<gravafav>0</gravafav>'.
    END.

RETURN "OK".
            
/*............................................................................*/


