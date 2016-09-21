/* ............................................................................
               
   Programa: Fontes/criticas_rating.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Março/2010                       Ultima atualizaçao: 20/04/2010
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que chamado no final das propostas de operacoes
               (Inclusao e alteraçao).
               
   Objetivo  : Listar todas as criticas referente ao calculo do Rating.
   
   Alteracoes: 20/04/2010 - Chamar fonte lista_criticas_rating. Alteracao
                            devido a adaptacao para Ayllos Web (David).

.............................................................................*/

{ includes/var_online.i }         
{ sistema/generico/includes/var_internet.i }               

DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO. 
DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
DEF INPUT PARAM par_tpctrrat AS INTE                              NO-UNDO.
DEF INPUT PARAM par_nrctrrat AS INTE                              NO-UNDO.

DEF VAR         h-b1wgen0043 AS HANDLE                            NO-UNDO.

RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

IF   NOT VALID-HANDLE (h-b1wgen0043)  THEN
     DO:
         MESSAGE "Handle invalida para a BO h-b1wgen0043.".
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
     END.

RUN lista_criticas IN h-b1wgen0043 (INPUT par_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_dtmvtolt,
                                    INPUT par_nrdconta,
                                    INPUT par_tpctrrat,
                                    INPUT par_nrctrrat,
                                    INPUT 1,
                                    INPUT 1,
                                    INPUT glb_nmdatela,
                                    INPUT glb_inproces,
                                    INPUT FALSE,
                                    OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0043.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        RUN fontes/lista_criticas_rating.p (INPUT TABLE tt-erro).
        RETURN "NOK".
    END.

RETURN "OK".

/*...........................................................................*/
