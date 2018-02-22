/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank9.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2008.                       Ultima atualizacao: 22/02/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar lancamentos futuros para Internet.
   
   Alteracoes: 20/05/2008 - Novos campos para totais (Credito e Debito) (David)
               03/11/2008 - Inclusao widget-pool (martin).
               26/09/2014 - Inclusao do periodo de consulta e tipo de operacao
                            Chamado: 161874 (Jonathan/RKAM).
               22/02/2016 - Alterado chamada da procedure consulta-lancamento-periodo para
                            conulta-lancto-car  - Projeto melhoria 157 (Lucas Ranghetti #330322)              
..............................................................................*/
    
create widget-pool.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0003tt.i }

DEF VAR h-b1wgen0003 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_indebcre AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao9.

RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT SET h-b1wgen0003.
                
IF  VALID-HANDLE(h-b1wgen0003)  THEN
    DO: 

        RUN consulta-lancto-car  IN h-b1wgen0003 
                                (INPUT par_cdcooper,
                                 INPUT 90,
                                 INPUT 900,
                                 INPUT "996",
                                 INPUT par_nrdconta,
                                 INPUT 3,
                                 INPUT par_idseqttl,
                                 INPUT "INTERNETBANK",
                                 INPUT TRUE,
                                 INPUT par_dtiniper,
                                 INPUT par_dtfimper,
                                 INPUT par_indebcre,
                                OUTPUT TABLE tt-totais-futuros, 
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-lancamento_futuro).
           
        DELETE PROCEDURE h-b1wgen0003.
           
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel consultar os " + 
                                   "lancamentos futuros.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.
               
        FOR EACH tt-lancamento_futuro NO-LOCK BY tt-lancamento_futuro.dtmvtolt:
       
            CREATE xml_operacao9.
            ASSIGN xml_operacao9.dscabini = "<LANCAMENTO>"
                   xml_operacao9.dtmvtolt = "<dtlancto>" +
                              IF tt-lancamento_futuro.dtmvtolt = 01/01/1099 THEN
                                 "FOLHA</dtlancto>" 
                              ELSE   
                                 TRIM(STRING(tt-lancamento_futuro.dtmvtolt,
                                            "99/99/9999")) + "</dtlancto>"
                   xml_operacao9.dshistor = "<dshistor>" + 
                                          TRIM(tt-lancamento_futuro.dshistor) +
                                            "</dshistor>"
                   xml_operacao9.nrdocmto = "<nrdocmto>" +
                                  TRIM(STRING(tt-lancamento_futuro.nrdocmto)) +
                                            "</nrdocmto>"
                   xml_operacao9.indebcre = "<indebcre>" + 
                                          TRIM(tt-lancamento_futuro.indebcre) +
                                            "</indebcre>"
                   xml_operacao9.vllanmto = "<vllanmto>" +
                                     TRIM(STRING(tt-lancamento_futuro.vllanmto,
                                                 "zzz,zzz,zz9.99-")) +
                                            "</vllanmto>"
                   xml_operacao9.cdtiptra = "<cdtiptra>" + STRING(tt-lancamento_futuro.cdtiptra) + "</cdtiptra>"                      
                   xml_operacao9.idlstdom = "<idlstdom>" + STRING(tt-lancamento_futuro.idlstdom) + "</idlstdom>"                       
                   xml_operacao9.idlancto = "<idlancto>" + STRING(tt-lancamento_futuro.idlancto) + "</idlancto>"                      
                   xml_operacao9.incancel = "<incancel>" + STRING(tt-lancamento_futuro.incancel) + "</incancel>"                                                
                   xml_operacao9.dscabfim = "</LANCAMENTO>".
        END.

        FIND FIRST tt-totais-futuros NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-totais-futuros  THEN
            DO:
                CREATE xml_operacao9.
                ASSIGN xml_operacao9.dscabini = "<LANCAMENTO>"
                       xml_operacao9.dtmvtolt = "<dtlancto></dtlancto>"
                       xml_operacao9.dshistor = "<dshistor>" + 
                                                "TOTAL LANCAMENTOS FUTUROS " +
                                                "PARA CREDITO" +
                                                "</dshistor>"
                       xml_operacao9.nrdocmto = "<nrdocmto></nrdocmto>"
                       xml_operacao9.indebcre = "<indebcre>C</indebcre>"
                       xml_operacao9.vllanmto = "<vllanmto>" +
                                        TRIM(STRING(tt-totais-futuros.vllaucre,
                                                    "zzz,zzz,zz9.99-")) +
                                                "</vllanmto>"
                       xml_operacao9.dscabfim = "</LANCAMENTO>".

                CREATE xml_operacao9.
                ASSIGN xml_operacao9.dscabini = "<LANCAMENTO>"
                       xml_operacao9.dtmvtolt = "<dtlancto></dtlancto>"
                       xml_operacao9.dshistor = "<dshistor>" + 
                                                "TOTAL LANCAMENTOS FUTUROS " +
                                                "PARA DEBITO" +
                                                "</dshistor>"
                       xml_operacao9.nrdocmto = "<nrdocmto></nrdocmto>"
                       xml_operacao9.indebcre = "<indebcre>D</indebcre>"
                       xml_operacao9.vllanmto = "<vllanmto>" +
                                        TRIM(STRING(tt-totais-futuros.vllaudeb,
                                                    "zzz,zzz,zz9.99-")) +
                                                "</vllanmto>"
                       xml_operacao9.dscabfim = "</LANCAMENTO>".
            END.
               
        RETURN "OK".
    END.

/*............................................................................*/
