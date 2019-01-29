/*..............................................................................

   Programa: siscaixa/web/InternetBank14.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2008.                      Ultima atualizacao: 09/11/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar extrato de emprestimo
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               04/02/2011 - Incluir parametro par_flgcondc na procedure 
                            obtem-dados-emprestimos  (Gabriel - DB1).
                            
               03/07/2012 - Tratar novo emprestimo (Gabriel).      
               
               08/10/2012 - Alterar dshistor pelo dsextrat (Lucas R).       
               
               19/07/2013 - 2a. fase do Projeto do Credito (Gabriel).
                
               24/04/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
               
               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714) 
                            
               16/11/2015 - Incluso campo cdorigem na montagem do xml_operacao14b.
                            (Daniel)           

               21/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
                            
               09/11/2017 - Separar codigo e descricao da linha de credito e 
                            finalidade (David).
                            
               29/01/2019 - INC0031641 - Ajustes na exibiçao de contratos de empréstimo
                            com mais de 8 digitos (Jefferson - MoutS)

..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0112tt.i }

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0112 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO. 

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtopr LIKE crapdat.dtmvtopr                    NO-UNDO.
DEF INPUT  PARAM par_inproces LIKE crapdat.inproces                    NO-UNDO.
DEF INPUT  PARAM par_dtiniper LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtfimper LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_nrctremp LIKE crapepr.nrctremp                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao14a.
DEF OUTPUT PARAM TABLE FOR xml_operacao14b.

RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT 
    SET h-b1wgen0002.
                
IF  VALID-HANDLE(h-b1wgen0002)  THEN
    DO: 
        RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                     INPUT 90,
                                                     INPUT 900,
                                                     INPUT "996",
                                                     INPUT "INTERNETBANK",
                                                     INPUT 3,
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtmvtopr,
                                                     INPUT ?,
                                                     INPUT par_nrctremp,
                                                     INPUT "InternetBank14",
                                                     INPUT par_inproces,
                                                     INPUT FALSE,
                                                     INPUT FALSE, /*par_flgcondc*/
                                                     INPUT 0, /** nriniseq **/
                                                     INPUT 0, /** nrregist **/
                                                    OUTPUT aux_qtregist,
                                                    OUTPUT TABLE tt-erro,
                                                    OUTPUT TABLE tt-dados-epr).
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel consultar extrato do " + 
                                   "emprestimo.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                DELETE PROCEDURE h-b1wgen0002.
                
                RETURN "NOK".
            END.

        FIND FIRST tt-dados-epr NO-LOCK NO-ERROR.      

        IF  AVAILABLE tt-dados-epr  THEN
            DO:
                CREATE xml_operacao14a.
                ASSIGN xml_operacao14a.dscabini = "<EMPRESTIMO>"
                       xml_operacao14a.dtmvtolt = "<dtmvtolt>" +
                                   STRING(tt-dados-epr.dtmvtolt,"99/99/9999") +
                                                  "</dtmvtolt>"
                       xml_operacao14a.nmprimtl = "<nmprimtl>" +
                                                  TRIM(tt-dados-epr.nmprimtl) +
                                                  "</nmprimtl>"
                       xml_operacao14a.nrctremp = "<nrctremp>" +
                              TRIM(STRING(tt-dados-epr.nrctremp,"zzz,zzz,zzz,zz9")) +
                                                  "</nrctremp>"
                       xml_operacao14a.vlemprst = "<vlemprst>" +
                         TRIM(STRING(tt-dados-epr.vlemprst,"zzz,zzz,zz9.99")) +
                                                  "</vlemprst>"
                       xml_operacao14a.qtpreemp = "<qtpreemp>" +
                                          STRING(tt-dados-epr.qtpreemp,"zz9") +
                                                  "</qtpreemp>"
                       xml_operacao14a.qtprecal = "<qtprecal>" +
                          TRIM(STRING(tt-dados-epr.qtprecal,"zzz,zz9.9999-")) +
                                                  "</qtprecal>"
                       xml_operacao14a.vlpreemp = "<vlpreemp>" +
                         TRIM(STRING(tt-dados-epr.vlpreemp,"zzz,zzz,zz9.99")) +
                                                  "</vlpreemp>"
                       xml_operacao14a.vlsdeved = "<vlsdeved>" +
                         TRIM(STRING(tt-dados-epr.vlsdeved,"zzz,zzz,zz9.99")) +
                                                  "</vlsdeved>"
                       xml_operacao14a.dslcremp = "<dslcremp>" +
                                                  tt-dados-epr.dslcremp +
                                                  "</dslcremp>"
                       xml_operacao14a.dsfinemp = "<dsfinemp>" +
                                                  tt-dados-epr.dsfinemp +
                                                  "</dsfinemp>"
                                                  
                       xml_operacao14a.qtpreres = "<qtpreres>" +
                                                  TRIM(STRING(tt-dados-epr.qtpreemp - tt-dados-epr.qtprecal)) +
                                                  "</qtpreres>"
                       xml_operacao14a.dsprodut = "<dsprodut>" +
                                                  (IF tt-dados-epr.tpemprst = 1 THEN "Price Pré-Fixado" ELSE IF tt-dados-epr.tpemprst = 2 THEN "Price Pós-Fixado" ELSE "Price TR") +
                                                  "</dsprodut>"
                       xml_operacao14a.cddlinha = "<cddlinha>" +
                                                  STRING(tt-dados-epr.cdlcremp) +
                                                  "</cddlinha>"
                       xml_operacao14a.dsdlinha = "<dsdlinha>" +
                                                  TRIM(SUBSTR(tt-dados-epr.dslcremp,INDEX(tt-dados-epr.dslcremp,"-",1) + 1)) +
                                                  "</dsdlinha>"
                       xml_operacao14a.cdfinali = "<cdfinali>" +
                                                  STRING(tt-dados-epr.cdfinemp) +
                                                  "</cdfinali>"
                       xml_operacao14a.dsfinali = "<dsfinali>" +
                                                  TRIM(SUBSTR(tt-dados-epr.dsfinemp,INDEX(tt-dados-epr.dsfinemp,"-",1) + 1)) +
                                                  "</dsfinali>"
                                                  
                       xml_operacao14a.tpemprst = "<tpemprst>" +
                                                  STRING(tt-dados-epr.tpemprst,"9") +
                                                  "</tpemprst>"
                                                  
                       xml_operacao14a.dscabfim = "</EMPRESTIMO>".
            END.         
        
        IF   tt-dados-epr.tpemprst = 0   THEN
             DO:
                 RUN obtem-extrato-emprestimo IN h-b1wgen0002 (
                                                    INPUT par_cdcooper,
                                                    INPUT 90,
                                                    INPUT 900,
                                                    INPUT "996",
                                                    INPUT "INTERNETBANK",
                                                    INPUT 3,
                                                    INPUT par_nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nrctremp,
                                                    INPUT par_dtiniper,
                                                    INPUT par_dtfimper,
                                                    INPUT TRUE,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-extrato_epr).                                              
                 DELETE PROCEDURE h-b1wgen0002.             
             END.
        ELSE IF   tt-dados-epr.tpemprst = 1   THEN
             DO:
                 RUN sistema/generico/procedures/b1wgen0112.p
                     PERSISTENT SET h-b1wgen0112.

                 RUN imprime_extrato IN h-b1wgen0112 ( 
                                              INPUT par_cdcooper,
                                              INPUT 90,
                                              INPUT 900,
                                              INPUT "996",
                                              INPUT "INTERNETBANK",
                                              INPUT 3,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT TODAY,
                                              INPUT par_nrctremp,
                                              INPUT TRUE,
                                              INPUT par_dtiniper,
                                              INPUT par_dtfimper,
                                              INPUT 2, /* Detalhado */
                                              INPUT "",
                                              INPUT FALSE, /* Nao imprime*/
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-extrato_epr_aux).
           
                 DELETE PROCEDURE h-b1wgen0112.
             END.
        ELSE IF   tt-dados-epr.tpemprst = 2   THEN
             DO:
                 RUN sistema/generico/procedures/b1wgen0112.p
                     PERSISTENT SET h-b1wgen0112.
                                        
                 RUN extrato_pos_fixado IN h-b1wgen0112 ( 
                                              INPUT par_cdcooper,
                                              INPUT 90,
                                              INPUT 900,
                                              INPUT "996",
                                              INPUT "INTERNETBANK",
                                              INPUT 3,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_nrctremp,
                                              INPUT TRUE,
                                              INPUT par_dtiniper,
                                              INPUT par_dtfimper,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-extrato_epr_aux).
           
                 DELETE PROCEDURE h-b1wgen0112.
             END.
                                        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel consultar extrato do " +
                                   "emprestimo.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.
             
        IF   tt-dados-epr.tpemprst = 0   THEN
             DO:  
                 FOR EACH tt-extrato_epr NO-LOCK:
                            
                     CREATE xml_operacao14b.
                     ASSIGN xml_operacao14b.dscabini = "<EXTRATO>"
                            xml_operacao14b.dtmvtolt = "<dtmvtolt>" +
                             STRING(tt-extrato_epr.dtmvtolt,"99/99/9999") +
                                                        "</dtmvtolt>"
                            xml_operacao14b.dshistor = "<dsextrat>" +
                                            tt-extrato_epr.dsextrat +
                                                        "</dsextrat>"
                            xml_operacao14b.nrdocmto = "<nrdocmto>" +
                             TRIM(STRING(tt-extrato_epr.nrdocmto,"zzz,zzz,zz9")) +
                                                       "</nrdocmto>"
                            xml_operacao14b.vllanmto = "<vllanmto>" +
                             TRIM(STRING(tt-extrato_epr.vllanmto,"zzz,zzz,zz9.99-")) +
                                                       "</vllanmto>"
                            
                        
                            xml_operacao14b.indebcre = "<indebcre>" +
                                                       tt-extrato_epr.indebcre +
                                                       "</indebcre>"
                            xml_operacao14b.dscabfim = "</EXTRATO>".                                         
                 END.
             END.
        ELSE IF   tt-dados-epr.tpemprst = 1   THEN
             DO:
                 FOR EACH tt-extrato_epr_aux WHERE 
                          tt-extrato_epr_aux.flglista = TRUE NO-LOCK 
                          BY tt-extrato_epr_aux.dtmvtolt
                             BY tt-extrato_epr_aux.nrparepr
                                BY tt-extrato_epr_aux.dsextrat:
                        
                     CREATE xml_operacao14b.
                     ASSIGN xml_operacao14b.dscabini = "<EXTRATO>"
                            xml_operacao14b.dtmvtolt = "<dtmvtolt>" +
                             STRING(tt-extrato_epr_aux.dtmvtolt,"99/99/9999") +
                                                        "</dtmvtolt>"

                            xml_operacao14b.dshistor = "<dsextrat>" +
                                        tt-extrato_epr_aux.dsextrat +
                                                       "</dsextrat>"

                            xml_operacao14b.nrparepr = "<nrparepr>" +
                                    STRING(tt-extrato_epr_aux.nrparepr) +
                                                       "</nrparepr>"

                            xml_operacao14b.vldebito = "<vldebito>" +
                             STRING(tt-extrato_epr_aux.vldebito,"zzz,zzz,zz9.99") +
                                                       "</vldebito>"

                            xml_operacao14b.vlcredit = "<vlcredit>" +
                             STRING(tt-extrato_epr_aux.vlcredit,"zzz,zzz,zz9.99") +
                                                       "</vlcredit>"

                            xml_operacao14b.vldsaldo = "<vlsaldo>" +
                             STRING(tt-extrato_epr_aux.vlsaldo,"zzz,zzz,zz9.99") +
                                                       "</vlsaldo>".

                            ASSIGN aux_dsorigem = "".

                            /* Deve lista apenas origem para historicos de
                               pagamento. */
                            IF ( tt-extrato_epr_aux.cdhistor = 1039 OR
                                 tt-extrato_epr_aux.cdhistor = 1044 OR
                                 tt-extrato_epr_aux.cdhistor = 1045 OR
                                 tt-extrato_epr_aux.cdhistor = 1057 ) THEN
                            DO:
                            
                                IF ( tt-extrato_epr_aux.nrparepr <> "" ) THEN
                                DO:
                                  CASE tt-extrato_epr_aux.cdorigem:
                                        WHEN 1 THEN
                                            aux_dsorigem = "Debito CC". /* Ayllos */
                                        WHEN 2 THEN
                                            aux_dsorigem = "Caixa".
                                        WHEN 3 THEN
                                            aux_dsorigem = "Internet".
                                        WHEN 4 THEN
                                            aux_dsorigem = "Cash".
                                        WHEN 5 THEN
                                            aux_dsorigem = "Debito CC". /* Ayllos Web */
                                        WHEN 6 THEN
                                            aux_dsorigem = "URA".
                                        WHEN 7 THEN
                                            aux_dsorigem = "Debito CC". /* Batch */
                                        WHEN 8 THEN
                                            aux_dsorigem = "Mensageria".
                                        OTHERWISE
                                            aux_dsorigem = "".
                                    END CASE.
                                END.

                            END.
                            
                            xml_operacao14b.cdorigem = "<cdorigem>" + aux_dsorigem + "</cdorigem>". 

                            xml_operacao14b.dscabfim = "</EXTRATO>".      

                 END.            
             END.
        ELSE IF   tt-dados-epr.tpemprst = 2   THEN
             DO:
                 FOR EACH tt-extrato_epr_aux WHERE 
                          tt-extrato_epr_aux.flglista = TRUE NO-LOCK 
                          BY tt-extrato_epr_aux.dtmvtolt
                             BY tt-extrato_epr_aux.nrparepr
                                BY tt-extrato_epr_aux.dsextrat:
                        
                     CREATE xml_operacao14b.
                     ASSIGN xml_operacao14b.dscabini = "<EXTRATO>"
                            xml_operacao14b.dtmvtolt = "<dtmvtolt>" +
                             STRING(tt-extrato_epr_aux.dtmvtolt,"99/99/9999") +
                                                        "</dtmvtolt>"

                            xml_operacao14b.dshistor = "<dsextrat>" +
                                        tt-extrato_epr_aux.dsextrat +
                                                       "</dsextrat>"

                            xml_operacao14b.nrparepr = "<nrparepr>" +
                                    STRING(tt-extrato_epr_aux.nrparepr) +
                                                       "</nrparepr>"

                            xml_operacao14b.vldebito = "<vldebito>" +
                             STRING(tt-extrato_epr_aux.vldebito,"zzz,zzz,zz9.99") +
                                                       "</vldebito>"

                            xml_operacao14b.vlcredit = "<vlcredit>" +
                             STRING(tt-extrato_epr_aux.vlcredit,"zzz,zzz,zz9.99") +
                                                       "</vlcredit>"

                            xml_operacao14b.vldsaldo = "<vlsaldo>" +
                             STRING(tt-extrato_epr_aux.vlsaldo,"zzz,zzz,zz9.99") +
                                                       "</vlsaldo>"

                            xml_operacao14b.qtdiacal = "<qtdiacal>" +
                             STRING(tt-extrato_epr_aux.qtdiacal) +
                                                       "</qtdiacal>"

                            xml_operacao14b.vlrdtaxa = "<vlrdtaxa>" +
                             STRING(tt-extrato_epr_aux.vlrdtaxa,"zzz,zzz,zz9.99") +
                                                       "%</vlrdtaxa>". 

                            xml_operacao14b.dscabfim = "</EXTRATO>".      

                 END.            
             END.

        RETURN "OK".
    END.

/*............................................................................*/
