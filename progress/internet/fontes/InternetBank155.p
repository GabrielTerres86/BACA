

/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank155.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann
   Data    : Setembro/2015.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Busca parcelas para pagamento
   
   Alteracoes: 

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF VAR h-b1wgen0084a AS HANDLE                                        NO-UNDO.

DEF VAR aux_qtregist AS INTE NO-UNDO.

DEF VAR vlatraso     AS DEC                                            NO-UNDO.     
DEF VAR aux_vencida  AS CHAR                                           NO-UNDO. 
DEF VAR aux_vldespar AS CHAR                                           NO-UNDO.

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
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0084a.p PERSISTENT SET h-b1wgen0084a.

IF VALID-HANDLE(h-b1wgen0084a) THEN
   DO: 

       FIND FIRST crapdat WHERE cdcooper = par_cdcooper NO-LOCK.
       

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
              ASSIGN xml_dsmsgerr = "<dsmsgerr>N�o foi poss�vel consultar as " +
                                    "parcelas do contratos.</dsmsgerr>".
              RETURN "NOK".
          END.

       FIND FIRST crapepr 
           WHERE crapepr.cdcooper = par_cdcooper
             AND crapepr.nrdconta = par_nrdconta
             AND crapepr.nrctremp = par_nrctremp
             NO-LOCK NO-ERROR.

       IF NOT AVAIL(crapepr) THEN
       DO:
            ASSIGN xml_dsmsgerr = "<dsmsgerr>N�o foi poss�vel consultar as " +
                                    "parcelas do contratos.</dsmsgerr>".
              RETURN "NOK".
       END.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "<PARCELAS>".

       FOR EACH tt-pagamentos-parcelas NO-LOCK:

           vlatraso = tt-pagamentos-parcelas.vlmtapar +
                      tt-pagamentos-parcelas.vljinpar +
                      tt-pagamentos-parcelas.vlmrapar.

            aux_vencida = "0". /* Parcela nao esta vencida */

            aux_vldespar = TRIM(STRING(tt-pagamentos-parcelas.vldespar,"zzz,zzz,zzz,zz9.99")).

            IF tt-pagamentos-parcelas.dtvencto < crapdat.dtmvtolt THEN
            DO:
                aux_vencida = "1". /* Parcela Vencida */
                aux_vldespar = "0,00".
            END.
                

            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml =  "<PARCELA>"
                   + "<nrctremp>" + TRIM(STRING(tt-pagamentos-parcelas.nrctremp,"zz,zzz,zz9")) + "</nrctremp>" 
                   + "<nrparepr>" + STRING(tt-pagamentos-parcelas.nrparepr,"zz9") + "</nrparepr>"
                   + "<dtvencto>" + TRIM(STRING(tt-pagamentos-parcelas.dtvencto,"99/99/9999")) + "</dtvencto>" 
                   + "<vldespar>" + aux_vldespar + "</vldespar>"
                   + "<vlatraso>" + STRING(vlatraso,"zzz,zzz,zzz,zz9.99") + "</vlatraso>"
                   + "<vlatrpag>" + STRING(tt-pagamentos-parcelas.vlatrpag,"zzz,zzz,zzz,zz9.99") + "</vlatrpag>"
                   + "<vlpreemp>" + TRIM(STRING(crapepr.vlpreemp,"zzz,zzz,zzz,zz9.99")) + "</vlpreemp>"
                   + "<vencida>" + aux_vencida + "</vencida>"
                   + "</PARCELA>".
       END.

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "</PARCELAS>".

       IF  VALID-HANDLE(h-b1wgen0084a) THEN
            DELETE PROCEDURE h-b1wgen0084a.
       
       RETURN "OK".
       
   END.

/*...........................................................................*/


