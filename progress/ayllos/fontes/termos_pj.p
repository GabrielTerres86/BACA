/* ............................................................................

   Programa: Fontes/termos_pj.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gati
   Data    : Outubro/2010                           Ultima atualizacao: 02/06/2014

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Rotina para impressao de cartoes de pessoa juridica.

   Alteracoes: 21/02/2011 - Incluida a procedure termo_encerra_cartao para
                            atender a opcão de Encerramento dos cartões BB.
                            (Isara - RKAM)
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                                                                                    
............................................................................ */
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_sldccr.i }
                                                                     
/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF        VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF        VAR par_flgfirst AS LOGI    INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGI    INIT TRUE                     NO-UNDO.
/**************************************************************/

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_dsmesano AS CHAR    EXTENT 15 INIT
                                       ["de  Janeiro  de","de Fevereiro de",
                                        "de   Marco   de","de    Abril  de",
                                        "de    Maio   de","de    Junho  de",
                                        "de    Julho  de","de   Agosto  de",
                                        "de  Setembro de","de  Outubro  de",
                                        "de  Novembro de","de  Dezembro de"]
                                                                     NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR h_b1wgen0028 AS HANDLE                                NO-UNDO.
DEF        VAR aux_contador AS INTE                                  NO-UNDO.



PROCEDURE imprime_entrega:
    DEF  INPUT  PARAM par_nrctrcrd   AS  INTEGER       NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta   AS  INTEGER       NO-UNDO.

    FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

    FORM " Aguarde... Imprimindo termo de entrega cartao de credito! "
         WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.
       
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    VIEW FRAME f_aguarde.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN gera_impressao_entrega_carta   IN h_b1wgen0028 ( INPUT glb_cdcooper,
                                                         INPUT 1, /* par_idorigem */
                                                         INPUT glb_cdoperad,
                                                         INPUT glb_nmdatela,
                                                         INPUT par_nrdconta,
                                                         INPUT glb_dtmvtolt,
                                                         INPUT glb_dtmvtopr,
                                                         INPUT glb_inproces,
                                                         INPUT par_nrctrcrd,
                                                         INPUT aux_nmendter,
                                                         OUTPUT aux_nmarqimp,
                                                         OUTPUT aux_nmarqpdf,
                                                         OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h_b1wgen0028.
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
    
            HIDE FRAME f_aguarde NO-PAUSE.
    
            RETURN "NOK".
        END.
         
    HIDE FRAME f_aguarde NO-PAUSE.
    
    glb_nrdevias = 1.

    FIND crapass WHERE
         crapass.cdcooper = glb_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
         
    { includes/impressao.i }     

END PROCEDURE.

PROCEDURE segunda_via_cartao:
    DEF  INPUT  PARAM par_cdcooper  AS INT                         NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta  AS INTE                        NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt  AS DATE                        NO-UNDO.
    DEF  INPUT  PARAM par_nrctrcrd  AS INTE                        NO-UNDO.
    
    DEF    VAR  aux_nmendter        AS CHAR    FORMAT "x(20)"      NO-UNDO.

    FORM " Aguarde... Imprimindo Solicitacao de Segunda Via de Cartao de Credito ! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    VIEW FRAME f_aguarde.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN segunda_via_cartao IN  h_b1wgen0028 (INPUT par_cdcooper,
                                             INPUT 1, /* par_idorigem */
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_nrdconta,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nrctrcrd,
                                             INPUT aux_nmendter,
                                             OUTPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h_b1wgen0028.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
    
            HIDE FRAME f_aguarde NO-PAUSE.
    
            RETURN "NOK".
        END.
         
    HIDE FRAME f_aguarde NO-PAUSE.
               
    glb_nrdevias = 1.

    FIND crapass WHERE
         crapass.cdcooper = glb_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
         
    { includes/impressao.i } 
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE segunda_via_senha_cartao:
    DEF  INPUT  PARAM par_cdcooper  AS INT                         NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta  AS INTE                        NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt  AS DATE                        NO-UNDO.
    DEF  INPUT  PARAM par_nrctrcrd  AS INTE                        NO-UNDO.
    
    DEF    VAR  aux_nmendter        AS CHAR    FORMAT "x(20)"      NO-UNDO.

    FORM " Aguarde... Imprimindo Solicitacao de Segunda Via de Senha de Cartao! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    VIEW FRAME f_aguarde.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN segunda_via_senha_cartao IN  h_b1wgen0028 ( INPUT par_cdcooper,
                                                    INPUT 1, /* par_idorigem */
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT par_nrctrcrd,
                                                    INPUT aux_nmendter,
                                                   OUTPUT aux_nmarqimp,
                                                   OUTPUT aux_nmarqpdf,
                                                   OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h_b1wgen0028.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
    
            HIDE FRAME f_aguarde NO-PAUSE.
    
            RETURN "NOK".
        END.
         
    HIDE FRAME f_aguarde NO-PAUSE.
               
    glb_nrdevias = 1.

    FIND crapass WHERE
         crapass.cdcooper = glb_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
         
    { includes/impressao.i } 
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE termo_cancela_cartao:
    DEF  INPUT  PARAM par_cdcooper  AS INT                         NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta  AS INTE                        NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt  AS DATE                        NO-UNDO.
    DEF  INPUT  PARAM par_nrctrcrd  AS INTE                        NO-UNDO.
    
    DEF    VAR  aux_nmendter        AS CHAR    FORMAT "x(20)"      NO-UNDO.

    FORM " Aguarde... Imprimindo Termo de Cancelamento de Cartao de Credito! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    VIEW FRAME f_aguarde.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN termo_cancela_cartao IN  h_b1wgen0028 ( INPUT par_cdcooper,
                                                INPUT 1, /* par_idorigem */
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nrctrcrd,
                                                INPUT aux_nmendter,
                                               OUTPUT aux_nmarqimp,
                                               OUTPUT aux_nmarqpdf,
                                               OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h_b1wgen0028.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
    
            HIDE FRAME f_aguarde NO-PAUSE.
    
            RETURN "NOK".
        END.
         
    HIDE FRAME f_aguarde NO-PAUSE.
               
    glb_nrdevias = 1.

    FIND crapass WHERE
         crapass.cdcooper = glb_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
         
    { includes/impressao.i } 
    
    RETURN "OK".
END PROCEDURE.


PROCEDURE imprime_Alt_data_PJ:
    DEF  INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.
   
    DEF    VAR  aux_nmendter        AS CHAR    FORMAT "x(20)"      NO-UNDO.

    FORM " Aguarde... Imprimindo carta para alteracao de data! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    VIEW FRAME f_aguarde.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

    RUN imprime_Alt_data_PJ IN h_b1wgen0028 (INPUT par_cdcooper,
                                             INPUT 1, /* par_idorigem */
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nrctrcrd,
                                             INPUT par_nrdconta,
                                             INPUT aux_nmendter,
                                             OUTPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
                    
    DELETE PROCEDURE h_b1wgen0028.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
    
            HIDE FRAME f_aguarde NO-PAUSE.
    
            RETURN "NOK".
        END.
         
    HIDE FRAME f_aguarde NO-PAUSE.
               
    glb_nrdevias = 1.

    FIND crapass WHERE
         crapass.cdcooper = glb_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
         
    { includes/impressao.i } 

END PROCEDURE.

PROCEDURE altera_limite_pj:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
       
    DEF    VAR  aux_nmendter        AS CHAR    FORMAT "x(20)"      NO-UNDO.

    FORM " Aguarde... Imprimindo proposta de alteracao de limite! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    VIEW FRAME f_aguarde.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
   
    RUN altera_limite_pj IN h_b1wgen0028 (INPUT par_cdcooper,
                                          INPUT 1, /* par_idorigem */
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_dtmvtolt,
                                          INPUT par_nrctrcrd,
                                          INPUT par_nrdconta,
                                          INPUT aux_nmendter,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
    
            HIDE FRAME f_aguarde NO-PAUSE.
    
            RETURN "NOK".
        END.
         
    HIDE FRAME f_aguarde NO-PAUSE.
               
    glb_nrdevias = 1.

    FIND crapass WHERE
         crapass.cdcooper = glb_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
         
    { includes/impressao.i } 
   
    DELETE PROCEDURE  h_b1wgen0028. 
END PROCEDURE.

PROCEDURE termo_encerra_cartao:
    DEF  INPUT  PARAM par_cdcooper  AS INT                         NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela  AS CHAR                        NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta  AS INTE                        NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt  AS DATE                        NO-UNDO.
    DEF  INPUT  PARAM par_nrctrcrd  AS INTE                        NO-UNDO.
    
    DEF    VAR  aux_nmendter        AS CHAR    FORMAT "x(20)"      NO-UNDO.

    FORM " Aguarde... Imprimindo Termo de Encerramento de Cartao de Credito! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    VIEW FRAME f_aguarde.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN termo_encerra_cartao IN  h_b1wgen0028 ( INPUT par_cdcooper,
                                                INPUT 1, /* par_idorigem */
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nrctrcrd,
                                                INPUT aux_nmendter,
                                               OUTPUT aux_nmarqimp,
                                               OUTPUT aux_nmarqpdf,
                                               OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h_b1wgen0028.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
    
            HIDE FRAME f_aguarde NO-PAUSE.
    
            RETURN "NOK".
        END.
         
    HIDE FRAME f_aguarde NO-PAUSE.
               
    glb_nrdevias = 1.

    FIND crapass WHERE
         crapass.cdcooper = glb_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
         
    { includes/impressao.i } 
    
    RETURN "OK".
END PROCEDURE.

/* ......................................................................... */
