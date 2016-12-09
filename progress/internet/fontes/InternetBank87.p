
/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank87.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonata (RKAM)
   Data    : Junho/2014.                       Ultima atualizacao: 11/11/2016 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Ativar / Desativar contas benefiriciaras de TED.
   
   Alteracoes: 11/11/2016 - Ajuste seja logado as alteracoes de favorecido
							(Adriano - SD 547975)
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }


DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT PARAM par_nmtitula AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_nrcpfcgc AS DECI                                  NO-UNDO.
DEF INPUT PARAM par_inpessoa AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_intipcta AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_insitcta AS INTE                                  NO-UNDO. 
DEF INPUT PARAM par_intipdif AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_cddbanco AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_cdageban AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                 NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.


ASSIGN aux_dstransa = "Ativar/Desativar conta do beneficiario do TED".

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
    DO: 
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                              "</dsmsgerr>".
                              
        RUN proc_geracao_log (INPUT FALSE).                      
                                   
        RETURN "NOK".
    END.

RUN altera-dados-cont-cadastrada IN h-b1wgen0015 
                               (INPUT par_cdcooper,
                                INPUT 90,             /** PA      **/
                                INPUT 900,            /** Caixa    **/
                                INPUT "996",          /** Operador **/
                                INPUT "INTERNETBANK", /** Tela     **/
                                INPUT 3,              /** Origem   **/
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_dtmvtolt,
                                INPUT TRUE,
                                INPUT par_nmtitula,
                                INPUT par_nrcpfcgc,
                                INPUT par_inpessoa,
                                INPUT par_intipcta,
                                INPUT par_insitcta,
                                INPUT par_intipdif,
                                INPUT par_cddbanco,
                                INPUT par_cdageban,
                                INPUT par_nrctatrf,
                               OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0015.
                                                                                    
IF  RETURN-VALUE <> 'OK' THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF   AVAIL tt-erro THEN
             ASSIGN aux_dscritic = tt-erro.dscritic.
        ELSE 
             ASSIGN aux_dscritic = "Erro na alteracao do beneficiario.".
             
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                              "</dsmsgerr>".
                                  
        RUN proc_geracao_log (INPUT FALSE).                      
                                       
        RETURN "NOK".

    END.          

RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                                            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE. 

/*............................................................................*/

