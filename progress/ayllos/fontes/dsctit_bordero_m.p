/* .............................................................................

   Programa: Fontes/dsctit_bordero_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2008.                     Ultima atualizacao: 30/05/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer o tratamento para impressao da proposta e dos titulos do  
               bordero de desconto.

   Alteracoes: 22/01/2009 - Alteracao cdempres (Diego).
               
               28/04/2009 - Permitir valor negativo no prazo - rel_qtdprazo
                            (Fernando).
                            
               12/11/2010- Incluida a palavra "CADIN" na proposta de desconto
                           de titulos (Vitor).             

               12/01/2011 - Alterado o format do campo nmprimtl para 50
                            (Kbase - Gilnei)
                            
               09/02/2011 - Incluir insittit na leitura da craptdb (Guilherme).
               
               23/02/2011 - Substituida temp-table workepr por
                            tt-dados-epr. (Gabriel/DB1)
                            
               21/07/2011 - Não gerar a proposta quando a impressão for completa 
                            (Isara - RKAM)                            
                            
               14/10/2011 - Aumento do formato do percentual de titulos nao
                            pagos (Gabriel).              
                            
               03/11/2011 - Realizado correcao para que seja impresso uma
                            folha em branco quando for solicitado a impressao
                            completa (Adriano).
                            
               19/03/2012 - Adicionada área para uso da Digitalização (Lucas).
               
               27/04/2012 - Incluído item de digitalização na impressão de 
                            desconto de títulos (Guilherme Maba).
                            
               21/06/2012 - Adicionado área para uso da Digitalização no documento
                            de analise de desconto de títulos (Lucas).
                            
               20/08/2012 - Alterações para trabalhar com a procedure 
                            'carrega-impressao-dsctit' da BO30 (Lucas).
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

/* Reutilizacao da include de Desconto de Cheques */
{ includes/var_bordero_m.i "NEW" }

DEF  INPUT PARAM par_nrdconta AS INTE                                   NO-UNDO.
DEF  INPUT PARAM par_nrborder AS INTE                                   NO-UNDO.

DEF VAR aux_nmarqpdf  AS CHAR                                           NO-UNDO.
DEF VAR aux_idimpres  AS INTE                                           NO-UNDO.
DEF VAR aux_contador  AS INTE                                           NO-UNDO.
DEF VAR aux_flgescra  AS LOGICAL                                        NO-UNDO.

DEF VAR h-b1wgen0030 AS HANDLE                                         NO-UNDO.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN par_flgrodar = TRUE
       aux_idimpres = 0.

ASSIGN tel_contrato = "Titulos".

DISPLAY tel_completa  tel_contrato  tel_proposta  tel_dscancel
        WITH FRAME f_imprime.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   CHOOSE FIELD tel_completa tel_contrato tel_proposta  tel_dscancel
                WITH FRAME f_imprime.

   IF   FRAME-VALUE = tel_completa   THEN
        DO:
            ASSIGN aux_idimpres = 5.
            IF   glb_cdcooper = 1   AND
                 glb_nmdafila = "FINANCEIRO"   THEN
                 DO:
                     MESSAGE "Imprima a Proposta na impressora CAIXAS e".
                     MESSAGE "os titulos na impressora FINANCEIRO.".
                     NEXT.
                 END.
        END.
   ELSE
   IF   FRAME-VALUE = tel_contrato   THEN
        ASSIGN aux_idimpres = 7.
   ELSE
   IF   FRAME-VALUE = tel_proposta   THEN
        DO:
            ASSIGN aux_idimpres = 6.
            IF   glb_cdcooper = 1   AND
                 glb_nmdafila = "FINANCEIRO"   THEN
                 DO:
                     MESSAGE "A proposta NAO pode ser impressa"
                             "nesta impressora.".
                     NEXT.
                 END.
        END.
   ELSE
   IF   FRAME-VALUE = tel_dscancel   THEN
        DO:
            HIDE FRAME f_imprime NO-PAUSE.
            HIDE MESSAGE NO-PAUSE.
            RETURN.
        END.

   HIDE FRAME f_imprime NO-PAUSE.
   LEAVE.
         
END.  /*  Fim do DO WHILE TRUE  */

IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR 
   aux_idimpres = 0                   THEN   /*   F4 OU FIM   */
   DO:
       HIDE FRAME f_imprime NO-PAUSE.
       HIDE MESSAGE NO-PAUSE.
       RETURN.
   END.

VIEW FRAME f_aguarde_titulos.

RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0030.".
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.

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
                                              INPUT 0,
                                              INPUT par_nrborder,
                                              INPUT aux_nmendter,
                                              INPUT FALSE,
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

        HIDE FRAME f_aguarde NO-PAUSE.

        RETURN.
    END.

HIDE FRAME f_aguarde_titulos NO-PAUSE.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

{ includes/impressao.i }

RETURN.

/* .......................................................................... */
