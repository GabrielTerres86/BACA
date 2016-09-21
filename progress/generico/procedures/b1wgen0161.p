/* ..........................................................................

   Programa: Fontes/b1wgen0161.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Julho/2013                         Ultima atualizacao: 25/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO referente a LISEPR

   Alteracoes: 12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
   
               25/02/2015 - Correcao e validacao para liberacao da conversao
                            realizada pela SUPERO 
                            (Adriano)    
    
............................................................................. */
DEF STREAM str_1.  /*  Para relatorio de entidade  */

{ sistema/generico/includes/b1wgen0161tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

/******************************************************************************/

PROCEDURE busca_emprestimos:

   DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                                NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_dtmvtopr AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_cdagesel AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_dtinicio AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_dttermin AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_cdlcremp LIKE crapepr.cdlcremp                 NO-UNDO.
   DEF INPUT PARAM par_cddotipo AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_nrregist AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_nriniseq AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_dsiduser AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_nmarquiv AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_tipsaida AS INT                                NO-UNDO.

   DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO. 
   DEF OUTPUT PARAM par_vlrtotal AS DEC                               NO-UNDO. 
   DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR tt-emprestimo_pag.

   DEF VAR aux_vlsdeved AS DECI                                       NO-UNDO.
   DEF VAR aux_qtprecal AS INTE                                       NO-UNDO.
   DEF VAR aux_diaprmed AS INTE                                       NO-UNDO.
   DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
   DEF VAR aux_contador AS INTE                                       NO-UNDO.
   DEF VAR aux_qtdregis AS INTE                                       NO-UNDO.

   DEF VAR aux_cdcritic AS INTE                                       NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.

   DEF VAR h_b1wgen0009 AS HANDLE                                     NO-UNDO.
   DEF VAR h_b1wgen0030 AS HANDLE                                     NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.
   EMPTY TEMP-TABLE tt-emprestimo_pag.
   EMPTY TEMP-TABLE tt-emprestimo.

   IF par_cdagesel <> 0 THEN  
      DO:
         FOR FIRST crapage FIELDS(cdagenci)
                           WHERE crapage.cdcooper = par_cdcooper AND
                                 crapage.cdagenci = par_cdagesel
                                 NO-LOCK:

         END.
        
         IF NOT AVAILABLE crapage THEN 
            DO:
               ASSIGN aux_cdcritic = 015
                      aux_dscritic = ""
                      par_nmdcampo = "cdagenci".
              
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
              
               RETURN "NOK".
              
            END.

      END.

   IF par_dtinicio = ? THEN
      ASSIGN par_dtinicio = DATE("01/" + STRING(MONTH(par_dtmvtolt)) + "/" + 
                            STRING(YEAR(par_dtmvtolt))).

   IF par_dttermin = ? THEN
      ASSIGN par_dttermin = par_dtmvtolt.

   IF par_dtinicio > par_dttermin THEN
      DO:
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "Data final deve ser maior que a " + 
                               "data inicial."
                par_nmdcampo = "dtinicio".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".

      END.                

   IF NOT CAN-DO("X,E,T,C",par_cddotipo) THEN 
      DO:
         ASSIGN aux_cdcritic = 014
                aux_dscritic = ""
                par_nmdcampo = "cddotipo".
        
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
        
         RETURN "NOK".

      END.

   /* Todas ou Emprestimos */
   IF par_cddotipo = "X" OR 
      par_cddotipo = "E" THEN 
      DO:
         RUN busca_emprestimos_descontos(INPUT par_cdcooper,       
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa, 
                                         INPUT par_cdoperad,
                                         INPUT par_idorigem,
                                         INPUT par_nmdatela,
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtopr,
                                         INPUT par_cdagesel,
                                         INPUT par_dtinicio,
                                         INPUT par_dttermin,
                                         INPUT par_cdlcremp,
                                         OUTPUT par_nmdcampo,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-emprestimo).
        
         IF RETURN-VALUE <> "OK" THEN
            RETURN "NOK".
        
      END.

   /* Todas ou Titulos */ 
   IF par_cddotipo = "X" OR 
      par_cddotipo = "T"   THEN
      DO:
         IF NOT VALID-HANDLE(h_b1wgen0030) THEN
            RUN sistema/generico/procedures/b1wgen0030.p
                PERSISTENT SET h_b1wgen0030.
        
         RUN busca_desconto_titulos  IN h_b1wgen0030
                                    (INPUT  par_cdcooper,
                                     INPUT  par_dtinicio,
                                     INPUT  par_dttermin,
                                     INPUT  par_dtmvtolt, 
                                     INPUT  par_cdlcremp,
                                     INPUT  par_cdagesel,
                                     OUTPUT TABLE tt-erro,
                                     INPUT-OUTPUT TABLE tt-emprestimo).
        
         IF VALID-HANDLE(h_b1wgen0030) THEN
            DELETE PROCEDURE h_b1wgen0030.
        
         IF RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".
        
      END.

   /* Todas ou Cheque */
   IF par_cddotipo = "X" OR 
      par_cddotipo = "C"   THEN 
      DO:
         IF NOT VALID-HANDLE(h_b1wgen0009) THEN
            RUN sistema/generico/procedures/b1wgen0009.p
                PERSISTENT SET h_b1wgen0009.
        
         RUN busca_desconto_cheques IN h_b1wgen0009
                                   (INPUT  par_cdcooper,
                                    INPUT  par_dtinicio,
                                    INPUT  par_dttermin,
                                    INPUT  par_dtmvtolt, 
                                    INPUT  par_cdlcremp,
                                    INPUT  par_cdagesel,
                                   OUTPUT TABLE tt-erro,
                                   INPUT-OUTPUT TABLE tt-emprestimo).
        
         IF VALID-HANDLE(h_b1wgen0009) THEN
            DELETE PROCEDURE h_b1wgen0009.
        
         IF RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

      END.

   /* Somente tratar paginacao para a web e quando for saida para arquivo.*/
   IF par_idorigem = 5 AND 
      par_tipsaida = 0 THEN 
      DO:
         FOR EACH tt-emprestimo NO-LOCK:
         
             ASSIGN aux_contador = aux_contador + 1
                    par_qtregist = par_qtregist + 1
                    par_vlrtotal = par_vlrtotal + tt-emprestimo.vlemprst.
         
             IF (aux_contador < par_nriniseq                   OR
                 aux_contador > (par_nriniseq + par_nrregist)) THEN 
                NEXT.
         
             IF aux_qtdregis = par_nrregist THEN 
                NEXT.
         
             ASSIGN aux_qtdregis = aux_qtdregis + 1.
         
             CREATE tt-emprestimo_pag.
             BUFFER-COPY tt-emprestimo TO tt-emprestimo_pag.
         
         END.

      END.
   ELSE 
      DO:
         IF par_tipsaida = 0 THEN /*TELA*/
            DO:
               FOR EACH tt-emprestimo NO-LOCK:
               
                   ASSIGN par_qtregist = par_qtregist + 1
                          par_vlrtotal = par_vlrtotal + tt-emprestimo.vlemprst.
                         
                   CREATE tt-emprestimo_pag.
                   BUFFER-COPY tt-emprestimo TO tt-emprestimo_pag.
               
               END.

            END.
         ELSE
            DO:       
               RUN imprime-lisepr(INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_idorigem,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_dsiduser,
                                  INPUT par_nmarquiv,
                                  INPUT par_dtinicio,
                                  INPUT par_dttermin,
                                  INPUT par_tipsaida,
                                  INPUT TABLE tt-emprestimo,
                                  OUTPUT par_nmdcampo,
                                  OUTPUT par_nmarqimp,
                                  OUTPUT par_nmarqpdf,
                                  OUTPUT TABLE tt-erro).

               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                        DO:
                           ASSIGN aux_cdcritic = 0.
                                  aux_dscritic = "Nao foi possivel gerar o " +
                                                 "arquivo".
                          
                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT 1, /*sequencia*/
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).
                          
                        END.

                     RETURN "NOK".

                  END.

            END.                   

      END.

   RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE busca_emprestimos_descontos:

   DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                                NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INT                                NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_dtmvtopr AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_cdagesel AS INTE                               NO-UNDO.
   DEF INPUT PARAM par_dtinicio AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_dttermin AS DATE                               NO-UNDO.
   DEF INPUT PARAM par_cdlcremp LIKE crapepr.cdlcremp                 NO-UNDO.

   DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR tt-emprestimo.

   DEF VAR aux_vlsdeved AS DECI                                       NO-UNDO.
   DEF VAR aux_vltotpre AS DECI                                       NO-UNDO.
   DEF VAR aux_qtprecal AS INTE                                       NO-UNDO.
   DEF VAR aux_diaprmed AS INTE                                       NO-UNDO.
   DEF VAR aux_cdcritic AS INTE                                       NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.

   DEF VAR h-b1wgen0002 AS HANDLE                                     NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.
   EMPTY TEMP-TABLE tt-emprestimo.

   FOR EACH crapepr FIELDS ( cdcooper nrdconta nrctremp dtmvtolt 
                             vlsdeved vlemprst cdlcremp )
                    WHERE crapepr.cdcooper  = par_cdcooper  AND
                          crapepr.dtmvtolt >= par_dtinicio  AND
                          crapepr.dtmvtolt <= par_dttermin  AND 
                        ((crapepr.cdlcremp  = par_cdlcremp)  OR
                          par_cdlcremp = 0) 
                          NO-LOCK,

       FIRST crawepr FIELDS (dtmvtolt) 
                     WHERE crawepr.cdcooper  = crapepr.cdcooper AND
                           crawepr.nrdconta  = crapepr.nrdconta AND
                           crawepr.nrctremp  = crapepr.nrctremp
                           NO-LOCK,
       
             FIRST crapass FIELDS (nrdconta cdagenci nmprimtl) 
                           WHERE crapass.cdcooper  = par_cdcooper     AND
                                 crapass.nrdconta  = crapepr.nrdconta AND
                               ((crapass.cdagenci  = par_cdagesel)     OR
                                 par_cdagesel = 0)                      
                                 NO-LOCK BREAK BY crapass.cdagenci 
                                                BY crapass.nrdconta
                                                 BY crapepr.nrctremp:
             
              ASSIGN aux_vlsdeved = 0 
                     aux_qtprecal = 0
                     aux_diaprmed = crapepr.dtmvtolt - crawepr.dtmvtolt.  
              
              IF (MONTH(par_dtmvtolt) <> MONTH(par_dtmvtopr)) THEN
                  ASSIGN aux_vlsdeved = crapepr.vlsdeved.
              ELSE 
                 DO:
                  IF NOT VALID-HANDLE(h-b1wgen0002) THEN
                     RUN sistema/generico/procedures/b1wgen0002.p
                         PERSISTENT SET h-b1wgen0002.

                    RUN saldo-devedor-epr IN h-b1wgen0002
                                    (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa, 
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT par_idorigem, 
                                     INPUT crapass.nrdconta,
                                     INPUT 1, /* idseqttl  */
                                     INPUT par_dtmvtolt,
                                     INPUT par_dtmvtopr,
                                     INPUT crapepr.nrctremp,
                                     INPUT par_nmdatela, /*cdprogra*/
                                     INPUT 0,         /*inproces*/
                                     INPUT FALSE,     /*flgerlog*/
                                    OUTPUT aux_vlsdeved,
                                    OUTPUT aux_vltotpre,
                                    OUTPUT aux_qtprecal,
                                    OUTPUT TABLE tt-erro).
                   
                    IF VALID-HANDLE(h-b1wgen0002) THEN
                       DELETE PROCEDURE h-b1wgen0002.
                   
                    IF RETURN-VALUE <> "OK"   THEN
                       RETURN "NOK".
             
              END.
             
              CREATE tt-emprestimo.

              ASSIGN tt-emprestimo.cdagenci = crapass.cdagenci 
                     tt-emprestimo.nrdconta = crapepr.nrdconta
                     tt-emprestimo.nmprimtl = crapass.nmprimtl
                     tt-emprestimo.nrctremp = crapepr.nrctremp
                     tt-emprestimo.dtmvtolt = crapepr.dtmvtolt
                     tt-emprestimo.vlemprst = crapepr.vlemprst
                     tt-emprestimo.vlsdeved = aux_vlsdeved
                     tt-emprestimo.cdlcremp = crapepr.cdlcremp
                     tt-emprestimo.dtmvtprp = crawepr.dtmvtolt
                     tt-emprestimo.diaprmed = aux_diaprmed
                     tt-emprestimo.dsorigem = "emprestimo".
           
   END. /* FOR EACH crapepr */

   RETURN "OK".

END PROCEDURE. /* Fim busca_emprestimos */

/******************************************************************************/

PROCEDURE imprime-lisepr:

   DEF INPUT PARAM par_cdcooper AS INTE                                NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                                 NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                                 NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                                NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                                NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                                NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                                NO-UNDO.
   DEF INPUT PARAM par_dsiduser AS CHAR                                NO-UNDO.
   DEF INPUT PARAM par_nmarquiv AS CHAR                                NO-UNDO.
   DEF INPUT PARAM par_dtinicio AS DATE                                NO-UNDO.
   DEF INPUT PARAM par_dttermin AS DATE                                NO-UNDO.
   DEF INPUT PARAM par_tipsaida AS INT                                 NO-UNDO.
   DEF INPUT PARAM TABLE FOR tt-emprestimo.

   DEF OUTPUT PARAM par_nmdcampo AS CHAR                               NO-UNDO.
   DEF OUTPUT PARAM par_nmarqimp AS CHAR   FORMAT "x(30)"              NO-UNDO.
   DEF OUTPUT PARAM par_nmarqpdf AS CHAR   FORMAT "x(50)"              NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_contador AS INTE                                        NO-UNDO.
   
   /* variaveis para valores totais */
   DEF VAR aux_vlemprst AS DECI     FORMAT "zz,zzz,zzz,zz9.99"         NO-UNDO.
   DEF VAR aux_vlsdeved AS DECI     FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
   DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
   DEF VAR aux_nmarquiv AS CHAR                                        NO-UNDO.

   DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
   DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

   FORM tt-emprestimo.cdagenci LABEL "PA"             
        tt-emprestimo.nrdconta LABEL "CONTA"           
        tt-emprestimo.nmprimtl LABEL "NOME"            
        tt-emprestimo.nrctremp LABEL "CONTRATO"          
        tt-emprestimo.dtmvtprp LABEL "DATA PROP"            
        tt-emprestimo.dtmvtolt LABEL "DATA EMP"        
        tt-emprestimo.diaprmed LABEL "PRAZO MED"       
        tt-emprestimo.vlemprst LABEL "VALOR EMP"       
        tt-emprestimo.vlsdeved LABEL "SALDO DEV"       
        tt-emprestimo.cdlcremp LABEL "LINHA"           
        WITH NO-BOX NO-LABEL DOWN FRAME f_rel_historico WIDTH 132.

   FORM "De:"   par_dtinicio    SPACE(3)
        "Ate:"  par_dttermin    SPACE(3) 
        SKIP(1) WITH FRAME f_dados2 NO-LABEL NO-BOX WIDTH 132.

   FORM SKIP(1)    
        "Qtde.Registros:" 
        aux_contador      
        "Total:"      AT 81         
        aux_vlemprst  AT 94     
        aux_vlsdeved  AT 112   
        WITH FRAME f_dados3 NO-LABEL NO-BOX WIDTH 132.

   EMPTY TEMP-TABLE tt-erro.

   /* Busca descricao da Cooperativa */
   FOR FIRST crapcop FIELDS(crapcop.dsdircop)
                     WHERE crapcop.cdcooper = par_cdcooper
                           NO-LOCK:

       ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser
              aux_nmendter = aux_nmendter + STRING(TIME)
              par_nmarqimp = aux_nmendter + ".ex"
              par_nmarqpdf = aux_nmendter + ".pdf"
              aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + 
                             par_nmarquiv + ".lst".

   END.

   IF NOT AVAIL crapcop THEN
      DO:
         ASSIGN aux_cdcritic = 651
                aux_dscritic = "".
         
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
         
         RETURN "NOK".
         
      END.

   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

   { sistema/generico/includes/b1cabrelvar.i }
   { sistema/generico/includes/b1cabrel132.i "11" "451" }

   VIEW STREAM str_1 FRAME f_cabrel132_1.

   DISPLAY STREAM str_1 par_dtinicio   
                        par_dttermin   
                        WITH FRAME f_dados2.

   ASSIGN aux_contador = 0
          aux_vlemprst = 0
          aux_vlsdeved = 0.

   FOR EACH tt-emprestimo:

       DISP STREAM str_1 tt-emprestimo.cdagenci  
                         tt-emprestimo.nrdconta  
                         tt-emprestimo.nmprimtl  
                         tt-emprestimo.nrctremp 
                         tt-emprestimo.dtmvtprp
                         tt-emprestimo.dtmvtolt
                         tt-emprestimo.diaprmed
                         tt-emprestimo.vlemprst
                         tt-emprestimo.vlsdeved 
                         tt-emprestimo.cdlcremp
                         WITH FRAME f_rel_historico.

       DOWN STREAM str_1 WITH FRAME f_rel_historico.

       IF LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN 
          DO:
             PAGE STREAM str_1.
             VIEW STREAM str_1 FRAME f_cabrel132_1.
          END.   
                        
       ASSIGN aux_vlemprst = aux_vlemprst + tt-emprestimo.vlemprst
              aux_vlsdeved = aux_vlsdeved + tt-emprestimo.vlsdeved
              aux_contador = aux_contador + 1. 

   END.

   DISP STREAM str_1 aux_contador
                     aux_vlemprst 
                     aux_vlsdeved 
                     WITH FRAME f_dados3.
    
   OUTPUT STREAM str_1 CLOSE.

   /*ARQUIVO*/
   IF par_tipsaida = 1 THEN
      DO:
         UNIX SILENT VALUE("mv " + par_nmarqimp + " " + aux_nmarquiv + 
                           "_copy").
                                                
         UNIX SILENT VALUE("ux2dos " + aux_nmarquiv + "_copy" + 
                           ' | tr -d "\032" > ' + aux_nmarquiv +
                           " 2>/dev/null").

         IF SEARCH(aux_nmarquiv + "_copy") <> ? THEN
            UNIX SILENT VALUE("rm " + aux_nmarquiv + "_copy " + 
                              "2>/dev/null").
      END.
   ELSE
   IF par_idorigem = 5 THEN 
      DO: 
         RUN sistema/generico/procedures/b1wgen0024.p 
             PERSISTENT SET h-b1wgen0024.
         
         IF NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO " +
                                     "b1wgen0024.".
         
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
         
               RETURN "NOK".
            END.
             
         RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                 INPUT 1, /* cdagenci */
                                                 INPUT 1, /* nrdcaixa */
                                                 INPUT par_nmarqimp,
                                                 OUTPUT par_nmarqpdf,
                                                 OUTPUT TABLE tt-erro ).
         
         IF VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.
         
         IF RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

      END.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
