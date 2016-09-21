
/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank159.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann
   Data    : Novembro/2015.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Imprime declaracao pagamento internet bank
   
   Alteracoes: 

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctremp AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR par_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR    FORMAT "x(200)"                        NO-UNDO.
DEF VAR aux_setlinha_1 AS CHAR  FORMAT "x(200)"                        NO-UNDO.
DEF VAR h-b1wgen0084b AS HANDLE                                         NO-UNDO.

DEF STREAM str_1.

IF NOT VALID-HANDLE(h-b1wgen0084b) THEN
   RUN sistema/generico/procedures/b1wgen0084b.p PERSISTENT SET h-b1wgen0084b.
                
IF VALID-HANDLE(h-b1wgen0084b) THEN
   DO: 
      RUN imprime_declaracao_pagamento IN h-b1wgen0084b 
                                    (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT 3, /* par_cdorigem */
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrctremp,
                                     OUTPUT par_nmarqimp,
                                     OUTPUT TABLE tt-erro).
   
       DELETE PROCEDURE h-b1wgen0084b.
       
       IF RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível imprimir a " +
                                    "declaracao.</dsmsgerr>".
              RETURN "NOK".
          END.

       /* Le o arquivo formatado */
       INPUT STREAM str_1 FROM VALUE(par_nmarqimp) NO-ECHO.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "<DADOS><PARAGRAFO>".

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

          IF aux_setlinha = "" THEN
             DO:
                 CREATE xml_operacao.
                 ASSIGN xml_operacao.dslinxml = "</PARAGRAFO><PARAGRAFO>".
             END.
          ELSE
             DO:
                 CREATE xml_operacao.
                 ASSIGN xml_operacao.dslinxml = "<conteudo>" + aux_setlinha + "</conteudo>".
             END.

       END.   /*  Fim do DO WHILE TRUE  */

       INPUT STREAM str_1 CLOSE.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "</PARAGRAFO></DADOS>".

       RETURN "OK".
       
   END.

/*...........................................................................*/

