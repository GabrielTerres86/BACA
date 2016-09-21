

/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank137.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jorge Issamu Hamaguchi
   Data    : Abril/2015                        Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Verificacao de mensagem de atraso em operacao de credito
   
   Alteracoes: 
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0031tt.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_idorigem AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdprogra AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF VAR h-b1wgen0031 AS HANDLE                                         NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.


RUN sistema/generico/procedures/b1wgen0031.p PERSISTENT SET h-b1wgen0031.

IF  NOT VALID-HANDLE(h-b1wgen0031)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0031.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN obtem-msg-credito-atraso IN h-b1wgen0031
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_idorigem,
                             INPUT par_cdprogra,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic).

DELETE PROCEDURE h-b1wgen0031.

IF  aux_cdcritic <> 0   OR
    aux_dscritic <> ""  THEN DO: 

     IF  aux_dscritic = "" THEN DO:
         FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                    NO-LOCK NO-ERROR.

         IF  AVAIL crapcri THEN
             ASSIGN aux_dscritic = crapcri.dscritic.
     END.

     ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

     RETURN "NOK".

 END.


RETURN "OK".

/*............................................................................*/
