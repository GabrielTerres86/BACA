/* ...........................................................................

   Programa: Fontes/dsctit_limite_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2008.                     Ultima atualizacao: 25/07/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer o tratamento para impressao do contrato, proposta e  
               nota promissoria para limite de desconto de titulos.

   Alteracoes: 22/01/2009 - Alteracao cdempres (Diego).

               05/08/2009 - Enviar proposta via email (David).
               
               06/11/2009 - Impressao do rating. Incluir impressao
                            do Rating atual e historico do Rating
                            (Gabriel).
                            
               21/06/2010 - Usar a BO 24 ao inves da 9999 para o envio dos 
                            contratos a sede (Gabriel).             
                            
               23/09/2010 - Utilizar BO para gerar impressao (David).
               
               20/08/2012 - Alterações para trabalhar com a procedure 
                            'carrega-impressao-dsctit' da BO30 (Lucas).
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                                                            
               25/07/2014 - Incluido botao para imprimir o cet - Projeto CET
                            (Lucas R./Gielow).
............................................................................. */

{ includes/var_online.i }
{ includes/var_deschq_m.i "NEW" } /** Reutilizar include de Descto.Cheques **/
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctrlim AS INTE                                  NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_idimpres AS INTE                                           NO-UNDO.

DEF VAR tel_flgemail AS LOGI                                           NO-UNDO.
                                                                    
DEF VAR h-b1wgen0030 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     "Efetuar envio de e-mail para Sede?" AT 3
     tel_flgemail NO-LABEL FORMAT "S/N"
     SKIP(1)
     WITH OVERLAY ROW 14 CENTERED WIDTH 42 TITLE COLOR NORMAL "Destino"
     FRAME f_email.

DISPLAY tel_completa  tel_contrato  tel_impricet
        tel_proposta  tel_notaprom  tel_dsrating  
        tel_dscancel
        WITH FRAME f_imprime.

ASSIGN aux_idimpres = 0
       par_flgrodar = TRUE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   CHOOSE FIELD tel_completa  tel_contrato  tel_impricet
                tel_proposta  tel_notaprom  tel_dsrating  
                tel_dscancel
                WITH FRAME f_imprime.

   IF  FRAME-VALUE = tel_completa  THEN
        ASSIGN aux_idimpres = 1.
    ELSE
    IF  FRAME-VALUE = tel_dsrating  THEN
        DO:
            RUN fontes/gera_rating.p (INPUT glb_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT 3,
                                      INPUT par_nrctrlim,
                                      INPUT FALSE). /** Nao grava **/
            LEAVE.
        END.
    ELSE
    IF  FRAME-VALUE = tel_contrato  THEN
        ASSIGN aux_idimpres = 2.
    ELSE
    IF  FRAME-VALUE = tel_proposta  THEN
        ASSIGN aux_idimpres = 3.
    ELSE
    IF  FRAME-VALUE = tel_notaprom  THEN
        ASSIGN aux_idimpres = 4.
    ELSE
    IF  FRAME-VALUE = tel_impricet THEN
        ASSIGN aux_idimpres = 9.  /* Cet */
    ELSE
    IF  FRAME-VALUE = tel_dscancel  THEN
        .

    LEAVE.

END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_imprime NO-PAUSE.
         
IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
    aux_idimpres = 0                    THEN 
    DO: 
        HIDE MESSAGE NO-PAUSE.
        RETURN.
    END.

ASSIGN tel_flgemail = FALSE.
    
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    UPDATE tel_flgemail WITH FRAME f_email.
    LEAVE.

END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_email NO-PAUSE.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
    ASSIGN tel_flgemail = FALSE.

IF  aux_idimpres = 9 THEN
    VIEW FRAME f_aguarde_cet.
ELSE
    VIEW FRAME f_aguarde.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.


RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030. 

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0030.".
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.

        HIDE FRAME f_aguarde_cet NO-PAUSE.
        HIDE FRAME f_aguarde NO-PAUSE.
        
        RETURN.
    END.

RUN carrega-impressao-dsctit IN h-b1wgen0030 (INPUT glb_cdcooper,
                                              INPUT glb_cdagenci,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT 1,
                                              INPUT par_nrdconta,
                                              INPUT 1,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_dtmvtopr,
                                              INPUT glb_inproces,
                                              INPUT aux_idimpres,
                                              INPUT par_nrctrlim,
                                              INPUT 0,
                                              INPUT aux_nmendter,
                                              INPUT tel_flgemail,
                                              INPUT TRUE,
                                             OUTPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0030.

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

        HIDE FRAME f_aguarde_cet NO-PAUSE.
        HIDE FRAME f_aguarde NO-PAUSE.

        RETURN.
    END.
     
HIDE FRAME f_aguarde_cet NO-PAUSE.
HIDE FRAME f_aguarde NO-PAUSE.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

{ includes/impressao.i }

RETURN.

/* .......................................................................... */
