/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank156.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann
   Data    : Setembro/2015.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Busca totais para liquidacao contrato
   
   Alteracoes: 

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0084a AS HANDLE                                        NO-UNDO.

DEF VAR aux_qtregist   AS INTE                                         NO-UNDO.

DEF VAR vlatraso       AS DEC                                          NO-UNDO.     
DEF VAR vlatrpag       AS DEC                                          NO-UNDO. 
DEF VAR vldespar       AS DEC                                          NO-UNDO. 
DEF VAR parcelas       AS DEC                                          NO-UNDO. 
DEF VAR aux_declaracao AS CHAR                                         NO-UNDO. 
DEF VAR aux_exibir     AS CHAR                                         NO-UNDO. 

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


       FOR EACH tt-pagamentos-parcelas NO-LOCK:

           parcelas = parcelas + 1.

           vlatraso = vlatraso + tt-pagamentos-parcelas.vlmtapar +
                                 tt-pagamentos-parcelas.vljinpar +
                                 tt-pagamentos-parcelas.vlmrapar.

           vlatrpag = vlatrpag +  tt-pagamentos-parcelas.vlatrpag.

           vldespar = vldespar + tt-pagamentos-parcelas.vldespar.
                                                                                         
       END.


       FIND FIRST crapepr 
           WHERE crapepr.cdcooper = par_cdcooper
             AND crapepr.nrdconta = par_nrdconta
             AND crapepr.nrctremp = par_nrctremp
             NO-LOCK NO-ERROR.

       IF NOT AVAIL(crapepr) THEN
       DO:
            ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar as " +
                                    "parcelas do contratos.</dsmsgerr>".
              RETURN "NOK".
       END.

       /* CAso tenha data cadastrada nao deve exibir a declaracao */
       IF crapepr.dtapgoib <> ? THEN
       DO:
            aux_declaracao = "".
            aux_exibir = "N".
       END.
       ELSE
       DO:
           aux_declaracao = "Declaro ter ciência que, além da possibilidade de liquidação antecipada da operação de crédito, prevista na Cédula de "
                          + "Crédito Bancário e/ou Contrato de Crédito Simplificado assinada(o) por mim no momento da contratação, também poderei "
                          + "efetuar o pagamento de parcelas em atraso, bem como, realizar a liquidação antecipada parcial ou total, por meio de acesso "
                          + "a minha conta online, mediante digitação de senha eletrônica, observadas as regras estipuladas pela Cooperativa. "
                          + "Ficam ratificadas todas as demais condições desta contratação, constantes na Cédula de Crédito Bancário e/ou Contrato de "
                          + "Crédito Simplificado, sendo que a senha eletrônica aqui digitada, necessária à aceitação deste conteúdo, substitui minha assinatura física.".
           aux_exibir = "S".
       END.
           

       CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml =  "<VALORES>"
                   + "<vlatrpag>" + STRING(vlatrpag,"zzz,zzz,zzz,zz9.99") + "</vlatrpag>"  
                   + "<vlatraso>" + STRING(vlatraso,"zzz,zzz,zzz,zz9.99") + "</vlatraso>"
                   + "<vldespar>" + TRIM(STRING(vldespar,"zzz,zzz,zzz,zz9.99")) + "</vldespar>"
                   + "<vlpreemp>" + TRIM(STRING(crapepr.vlpreemp * parcelas ,"zzz,zzz,zzz,zz9.99")) + "</vlpreemp>"
                   + "<exibir>" + aux_exibir +  "</exibir>"
                   + "<declaracao>" + aux_declaracao + "</declaracao>" 
                   + "</VALORES>". 

       IF  VALID-HANDLE(h-b1wgen0084a) THEN
            DELETE PROCEDURE h-b1wgen0084a.
       
       RETURN "OK".
       
   END.

/*...........................................................................*/



