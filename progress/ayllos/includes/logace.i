/* .............................................................................

   Programa: includes/logace.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / SUPERO
   Data    : Marco/2013                        Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Gerar dados de Log de Acesso a Telas (craplgt)

   Alteracoes:
   ...........................................................................*/

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEF VAR h-b1wgen0013 AS HANDLE                                         NO-UNDO.

RUN sistema/generico/procedures/b1wgen0013.p 
    PERSISTENT SET h-b1wgen0013.
    
IF   NOT VALID-HANDLE(h-b1wgen0013)  THEN
  DO:
     BELL.
     MESSAGE "Handle invalido para BO b1wgen0013.".
  END.

RUN registra-log-acesso-telas IN h-b1wgen0013 (INPUT glb_cdcooper,
                                               INPUT TRIM(glb_nmdatela),
                                               INPUT 1, /* 1 = Ayllos Caracter*/
                                               INPUT glb_cdoperad,
                                               INPUT glb_dtmvtolt,
                                              OUTPUT TABLE tt-erro).
DELETE PROCEDURE h-b1wgen0013.

