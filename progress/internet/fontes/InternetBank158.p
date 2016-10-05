/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank158.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann
   Data    : Setembro/2015.                       Ultima atualizacao: 05/10/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Efetua pagamento contrato
   
   Alteracoes: 05/10/2016 - Incluido tratamento no retorno da procedrure
							valida_pagamentos_geral, Prj. 302 (Jean Michel).

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0084a AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0084b AS HANDLE                                        NO-UNDO.

DEF VAR aux_cont      AS INT                                           NO-UNDO.   
DEF VAR aux_excluir   AS LOGICAL                                       NO-UNDO. 
DEF VAR aux_totatual  AS DECI                                          NO-UNDO.
DEF VAR aux_totpagto  AS DECI                                          NO-UNDO.
DEF VAR aux_qtddeprc  AS INT                                           NO-UNDO.
DEF VAR aux_vlsomato  AS DECI                                          NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_nrctremp AS INTE                                  NO-UNDO. 
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtoan AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_ordempgo AS CHAR                                  NO-UNDO. 
DEF  INPUT PARAM par_qtdprepr AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_listapar AS CHAR                                  NO-UNDO. 
DEF  INPUT PARAM par_tipopgto AS INTE                                  NO-UNDO. 
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

/* par_ordempgo 1 - Inicio para Final   2 - Final para Inicio 
   par_tipopgto 1 - Contrato 2 - Parcela */

IF par_tipopgto = 2 THEN /* 2 - Parcela */
DO:
    IF par_qtdprepr <> NUM-ENTRIES(par_listapar,',') THEN
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível efetuar a " +
                                         "operação.</dsmsgerr>".
        RETURN "NOK".
    END.
END.


RUN sistema/generico/procedures/b1wgen0084a.p PERSISTENT SET h-b1wgen0084a.

IF VALID-HANDLE(h-b1wgen0084a) THEN
   DO: 
       /* Incluir BO */ 
       RUN busca_pagamentos_parcelas IN h-b1wgen0084a
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT 3,     /* aux_idorigem, */
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT FALSE, /*  aux_flgerlog, */
                                  INPUT par_nrctremp,
                                  INPUT par_dtmvtoan,
                                  INPUT 0,     /* aux_nrparepr, */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-pagamentos-parcelas,
                                 OUTPUT TABLE tt-calculado).


       DELETE PROCEDURE h-b1wgen0084a.
       IF RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar as " +
                                    "parcelas do contratos.</dsmsgerr>".
              RETURN "NOK".
          END.

      ASSIGN aux_qtddeprc = 0.

      IF NUM-ENTRIES(par_listapar,',') > 0 THEN
      DO:
    
        FOR EACH tt-pagamentos-parcelas EXCLUSIVE-LOCK:
    
           aux_totatual = aux_totatual + tt-pagamentos-parcelas.vlatrpag.
    
           aux_excluir = TRUE.
    
           DO aux_cont=1 TO NUM-ENTRIES(par_listapar,','):

             IF tt-pagamentos-parcelas.nrparepr = INTE(ENTRY(aux_cont,par_listapar,','))  THEN
               DO:

                 aux_qtddeprc = aux_qtddeprc + 1. 

                 aux_excluir = FALSE.
                 aux_totpagto = aux_totpagto + tt-pagamentos-parcelas.vlatrpag.

                 ASSIGN tt-pagamentos-parcelas.vlpagpar = tt-pagamentos-parcelas.vlatrpag.
               END.
    
           END.
    
           /* Caso a parcela nao esteja na lista deve ser excluida */
           IF aux_excluir = TRUE THEN
               DELETE tt-pagamentos-parcelas.
    
        END.

        IF NUM-ENTRIES(par_listapar,',') <> aux_qtddeprc THEN
        DO: /*
            ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar as " +
                                    "parcelas do contratos.</dsmsgerr>".
            */                        
            ASSIGN xml_dsmsgerr = "<dsmsgerr>Ha valores pagos na(s) parcela(s) selecionada(s), " +
                                  "consulte o extrato do seu contrato.</dsmsgerr>".
            RETURN "NOK".
        END.


      END.
      ELSE
      DO:
        /* Soma valores totais a pagar */
        FOR EACH tt-pagamentos-parcelas NO-LOCK:
          aux_totatual = aux_totatual + tt-pagamentos-parcelas.vlatrpag.
          aux_totpagto = aux_totpagto + tt-pagamentos-parcelas.vlatrpag.

          ASSIGN tt-pagamentos-parcelas.vlpagpar = tt-pagamentos-parcelas.vlatrpag.
        END.

      END.


      RUN sistema/generico/procedures/b1wgen0084b.p PERSISTENT SET h-b1wgen0084b.

      IF VALID-HANDLE(h-b1wgen0084b) THEN
      DO:
    
        RUN valida_pagamentos_geral IN h-b1wgen0084b
                                     (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT 3,                /* aux_idorigem, */
                                      INPUT par_nrdconta,
                                      INPUT par_nrctremp,
                                      INPUT par_idseqttl,
                                      INPUT par_dtmvtolt,
                                      INPUT FALSE,            /*  aux_flgerlog, */
                                      INPUT par_dtmvtolt,
                                      INPUT aux_totpagto,     /* aux_vlapagar, */
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT aux_vlsomato,
                                     OUTPUT TABLE tt-msg-confirma).

           DELETE PROCEDURE h-b1wgen0084b.
           IF RETURN-VALUE = "NOK" THEN
              DO:

				  FIND FIRST tt-erro NO-LOCK NO-ERROR.

				  IF AVAILABLE tt-erro THEN
				    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + tt-erro.dscritic + "</dsmsgerr>".
				  ELSE
					ASSIGN xml_dsmsgerr = "<dsmsgerr>Erro Saldo</dsmsgerr>".
                  RETURN "NOK".
              END.
           ELSE
           DO:
             FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
         
             IF AVAILABLE tt-msg-confirma  THEN
                 DO:
                      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + tt-msg-confirma.dsmensag + "</dsmsgerr>".
                      RETURN "NOK".
                 END.


           END.
       END.

      RUN sistema/generico/procedures/b1wgen0084a.p 
        PERSISTENT SET h-b1wgen0084a.

      IF VALID-HANDLE(h-b1wgen0084a) THEN
      DO: 

       RUN gera_pagamentos_parcelas IN h-b1wgen0084a
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT 3, /* aux_idorigem, 3-Internet */
                                  INPUT 90, /* par_cdpactra Verificar */
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT FALSE, /*  aux_flgerlog, */
                                  INPUT par_nrctremp,
                                  INPUT par_dtmvtoan,
                                  INPUT aux_totatual,
                                  INPUT aux_totpagto,
                                  INPUT 0, /* par_nrseqava, */
                                  INPUT TABLE tt-pagamentos-parcelas,
                                 OUTPUT TABLE tt-erro).

       IF  VALID-HANDLE(h-b1wgen0084a) THEN
            DELETE PROCEDURE h-b1wgen0084a.

         IF RETURN-VALUE = "NOK" THEN
         DO:
             /*
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
             IF AVAILABLE tt-erro  THEN
                 DO:
                     MESSAGE  tt-erro.dscritic
                         VIEW-AS ALERT-BOX INFO BUTTONS OK.
                 END.
*/

              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível efetuar o " +
                                    "pagamento das parcelas do contratos.</dsmsgerr>".
              RETURN "NOK".
         END.

      END.
      ELSE
      DO :
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível efetuar a " +
                                     "operação.</dsmsgerr>".
        RETURN "NOK".
      END.
  END.
ELSE
   DO :
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível efetuar a " +
                                    "operação.</dsmsgerr>".
              RETURN "NOK".
   END.
