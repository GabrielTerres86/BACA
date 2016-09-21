/* .............................................................................

   Programa: Fontes/deschq_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                     Ultima atualizacao: 25/08/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer o tratamento para impressao do contrato, proposta e  
               cancelamento para limite de desconto de cheques.

   Alteracoes: 21/07/2003 - Inclusao do nro CI do cooperado, descricao por
                            extenso, da quantidade de dias de vigencia e
                            multa por inadimplencia (Julio).
                 
               22/07/2003 - Inclusao da rotina de quebra para um string
                            (Fernando/Julio).

               22/08/2003 - observacao justificada (Julio).

               08/09/2003 - Se nao encontrar a tabela LOCALIDADE, deixar o nome
                            da cidade em branco (Fernando).
                            
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               12/07/2004 - Inclusao do campo CPF/CNPJ e das datas das consul-
                            tas do SPC e da Central de Risco (Evandro).

               20/07/2004 - Impressao Valor Utilizado(Mirtes)

               20/06/2005 - Permitir a reimpressao do contrato/proposta (Edson)
               
               26/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               12/01/2006 - Incluido campo Bens (Diego).
               
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               23/05/2006 - Modificados campos referente endereco para a
                            estrutura crapenc (Diego).
               
               12/01/2007 - Substituido dados da cidade do PAC da tabela craptab
                            por informacoes da tabela crapage (Elton).
                            
               25/10/2007 - Mostrar secao a partir da ttl.nmdsecao (Guilherme).
               
               09/05/2008 - Ajustar dspreapg para 11 posicoes (Magui).
               
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               18/09/2008 - Alteracao na chave de acesso a tabela crapldc
                            (Gabriel).
                          - Alterado UF "SC" fixo para o do crapcop (Guilherme).

               05/08/2009 - Enviar proposta via email (David).
               
               06/11/2009 - Realizar impressao do Rating (Gabriel).
               
               21/06/2010 - Substituir BO 9999 para a 24 na procedure 
                            que envia os contratos para a sede (Gabriel).
                            
               22/09/2010 - Utilizar BO para gerar impressao (David).
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
               
               25/08/2014 - Incluir Ajustes referentes ao Projeto CET
                            (Lucas Ranghetti/Gielow)
............................................................................. */

{ includes/var_online.i }
{ includes/var_deschq_m.i "NEW" }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctrlim AS INTE                                  NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_idimpres AS INTE                                           NO-UNDO.

DEF VAR tel_flgemail AS LOGI                                           NO-UNDO.

DEF VAR h-b1wgen0009 AS HANDLE                                         NO-UNDO.

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
                                      INPUT 2,
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

IF  aux_idimpres = 9 THEN /* CET */
    VIEW FRAME f_aguarde_cet.
ELSE
    VIEW FRAME f_aguarde.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 
                                              
RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.
                                                
IF  NOT VALID-HANDLE(h-b1wgen0009)  THEN
    DO:
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0009.".
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.

        HIDE FRAME f_aguarde NO-PAUSE.
        HIDE FRAME f_aguarde_cet NO-PAUSE.
        
        RETURN.
    END.

RUN gera-impressao-limite IN h-b1wgen0009 (INPUT glb_cdcooper,
                                           INPUT 0,
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
                                           INPUT aux_nmendter,
                                           INPUT tel_flgemail,
                                           INPUT TRUE,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0009.

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
        HIDE FRAME f_aguarde_cet NO-PAUSE.

        RETURN.
    END.
     
HIDE FRAME f_aguarde NO-PAUSE.
HIDE FRAME f_aguarde_cet NO-PAUSE.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

{ includes/impressao.i }

RETURN.
            
/* .......................................................................... */
