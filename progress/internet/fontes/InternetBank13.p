/*..............................................................................

   Programa: siscaixa/web/InternetBank13.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2008.                      Ultima atualizacao: 08/11/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar emprestimos do cooperado.
   
   Alteracoes: 17/03/2008 - Fechar tag xml "dsmsgerr" quando nao houver 
                            emprestimos (David).
                            
               03/11/2008 - Inclusao widget-pool (martin)             
               
               04/02/2011 - Incluir parametro par_flgcondc na procedure 
                            obtem-dados-emprestimos  (Gabriel - DB1).
                            
               03/07/2012 - Tratar novo emprestimo (Gabriel)
               
               24/04/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
   
               10/09/2014 - Incluir flgpreap no retorno do XML. (James)
               
               24/11/2014 - Incluido cdorigem no retorno do XML. (James)
               
               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
               23/11/2015 - Incluso novo campo dtapgoib no retorno do XML (Daniel)
               
               22/01/2016 - Inclusao do campo nrdrecid para o XML de retorno para 
                            tela, utilizado em gera-impressao-empr da b1wgen0002i.p
                            (Carlos Rafael Tanholi - Prj 261 - Pre-Aprovado Fase 2)
               
               08/11/2017 - Retornar nome do produto e separar codigo e descricao
                            da linha de credito e finalidade (David).
               
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0002tt.i }

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtopr LIKE crapdat.dtmvtopr                    NO-UNDO.
DEF INPUT  PARAM par_inproces LIKE crapdat.inproces                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT 
    SET h-b1wgen0002.
                
IF  VALID-HANDLE(h-b1wgen0002)  THEN
    DO: 
        RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                     INPUT 90,                  /* par_cdagenci */
                                                     INPUT 900,                 /* par_nrdcaixa */
                                                     INPUT "996",               /* par_cdoperad */
                                                     INPUT "INTERNETBANK",      /* par_nmdatela */
                                                     INPUT 3,                   /* par_idorigem = Internet */
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtmvtopr,
                                                     INPUT ?,                   /* par_dtcalcul */
                                                     INPUT 0,                   /* par_nrctremp */
                                                     INPUT "InternetBank13",    /* par_cdprogra */
                                                     INPUT par_inproces,
                                                     INPUT TRUE,                /* par_flgerlog */
                                                     INPUT FALSE,               /* par_flgcondc */
                                                     INPUT 0,                   /* par_nriniseq */
                                                     INPUT 0,                   /* par_nrregist */
                                                    OUTPUT aux_qtregist,
                                                    OUTPUT TABLE tt-erro,
                                                    OUTPUT TABLE tt-dados-epr).
        
        DELETE PROCEDURE h-b1wgen0002.
                             
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel consultar emprestimos.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.
                 
        FIND FIRST tt-dados-epr NO-LOCK NO-ERROR.
                                   
        IF  NOT AVAILABLE tt-dados-epr  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>Nao ha contratos de " +
                                      "emprestimo para esta conta.</dsmsgerr>".
                RETURN "NOK".
            END.
         
        FOR EACH tt-dados-epr NO-LOCK:
                 
            CREATE xml_operacao.         
            ASSIGN xml_operacao.dslinxml = "<EMPRESTIMO><dtmvtolt>" +
                                   STRING(tt-dados-epr.dtmvtolt,"99/99/9999") +
                                           "</dtmvtolt><nrctremp>" +
                              TRIM(STRING(tt-dados-epr.nrctremp,"zz,zzz,zz9")) +
                                           "</nrctremp><vlemprst>" +
                     TRIM(STRING(tt-dados-epr.vlemprst,"zzz,zzz,zzz,zz9.99")) +
                                           "</vlemprst><qtpreemp>" +
                                          STRING(tt-dados-epr.qtpreemp,"zz9") +
                                           "</qtpreemp><qtprecal>" +
                          TRIM(STRING(tt-dados-epr.qtprecal,"zzz,zz9.9999-")) +
                                           "</qtprecal><vlpreemp>" +
                           STRING(tt-dados-epr.vlpreemp,"zzz,zzz,zzz,zz9.99") +
                                           "</vlpreemp><vlsdeved>" +
                     TRIM(STRING(tt-dados-epr.vlsdeved,"zzz,zzz,zzz,zz9.99")) +
                                           "</vlsdeved><dslcremp>" +
                                             TRIM(tt-dados-epr.dslcremp) +
                                           "</dslcremp><dsfinemp>" +
                                             TRIM(tt-dados-epr.dsfinemp) +
                                           "</dsfinemp><nmprimtl>" +
                                           TRIM(tt-dados-epr.nmprimtl) +
                                           "</nmprimtl><tpemprst>" +
                                              STRING(tt-dados-epr.tpemprst,"9") +
                                           "</tpemprst><flgpreap>" +
                                              STRING(tt-dados-epr.flgpreap) +
                                           "</flgpreap><cdorigem>" +
                                              STRING(tt-dados-epr.cdorigem) +
                                           "</cdorigem><dtapgoib>" +
                                           (IF tt-dados-epr.dtapgoib = ? THEN "" ELSE STRING(tt-dados-epr.dtapgoib,"99/99/9999")) + 
                                           "</dtapgoib><nrdrecid>" +
                                             TRIM(STRING(tt-dados-epr.nrdrecid)) +
                                           "</nrdrecid><qtpreres>" +
                                           TRIM(STRING(tt-dados-epr.qtpreemp - tt-dados-epr.qtprecal)) +
                                           "</qtpreres><dsprodut>" +
                                           (IF tt-dados-epr.tpemprst = 1 THEN "Price Pré-Fixado" ELSE IF tt-dados-epr.tpemprst = 2 THEN "Price Pós-Fixado" ELSE "Price TR") +
                                           "</dsprodut><cddlinha>" +
                                           STRING(tt-dados-epr.cdlcremp) +
                                           "</cddlinha><dsdlinha>" +
                                           TRIM(SUBSTR(tt-dados-epr.dslcremp,INDEX(tt-dados-epr.dslcremp,"-",1) + 1)) +
                                           "</dsdlinha><cdfinali>" +
                                           STRING(tt-dados-epr.cdfinemp) +
                                           "</cdfinali><dsfinali>" +
                                           TRIM(SUBSTR(tt-dados-epr.dsfinemp,INDEX(tt-dados-epr.dsfinemp,"-",1) + 1)) +
                                           "</dsfinali><flgrelat>" +
                                           (IF tt-dados-epr.flgpreap AND (tt-dados-epr.cdorigem = 3 OR tt-dados-epr.cdorigem = 4) THEN "1" ELSE "0") +
                                           "</flgrelat></EMPRESTIMO>".
                        
        END. 
                                
        RETURN "OK".
    END.

/*............................................................................*/
