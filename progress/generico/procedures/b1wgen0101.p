/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0101.p
   Autor  : Adriano
   Data   : Agosto/2011                      Ultima alteracao: 27/07/2017

   Dados referentes ao programa:

   Objetivo  : BO referente a tela PESQTI.
   
   Alteracoes: 06/08/2012 - Criada a procedure 'lista-historicos'
                          - Alterada a procedure 'consulta_faturas' para
                            considerar historico informado na consulta 
                          - Procedure 'consulta_faturas' retornar Vl. FOZ 
                          - Criada a procedure 'grava-dados-fatura' (Lucas).
                          
               18/04/2013 - Criação da procedure 'lista-empresas-conv'.
                          - Alteração na procedure 'consulta_faturas' para
                            tratar consulta de Conv. SICREDI (Lucas).
                            
               28/05/2013 - Alteração para listar DARFs (Lucas).
               
               28/06/2013 - Alteração para considerar valor de lançamento, 
                            valor de multa e valor de juros somados no filtro
                            por valor (Lucas).
                         
               13/08/2013 - Nova forma de chamar as agências, alterado para
                         "Posto de Atendimento" (PA). (André Santos - SUPERO)
                         
               03/06/2014 - Adição de campos para listagem detalhada de DARFs
                            adquiridas através da Rot. 41. (Lunelli) 
                            [SD 75897 - Guilherme Fernando Gielow]
                            
               12/06/2014 - Alteração para exibir detalhes de DARFs 
                            arrecadadas na Rot. 41 (SD. 75897 Lunelli)
                            
               16/12/2014 - #203812 Para as faturas (Cecred e Sicredi) no lugar 
                            da descrição do Banco Destino e o nome do banco, 
                            apresentar: Convênio e Nome do convênio (Carlos)
                            
               06/01/2015 - #203812 Tratamento p/ identificacao de DARFS (Carlos)
               
               23/06/2015 - Ajustes realizados:
                            - Na rotina consulta_faturas, foi retirado o 
                              tratamento de substr ao alimentar o campo 
                              tt-dados-pesqti.nrdocmto; 
                            - Na rotina grava-dados-fatura, foi incluido uma
                              validacao para restringir a alterecao de
                              faturas.
                            (Adriano).
                            
               24/08/2015 - Incluido gravacao de dados no campo tpcptdoc da
                            tt-dados-pesqti (Melhoria 21 Tiago/Fabricio).
                            
               13/05/2016 - Adicionado o campo de linha digitavel na 
                            tt-dados-pesqti (Douglas - Chamado 426870)		 

               19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS 
                            pelo InternetBanking (Projeto 338 - Lucas Lunelli)
				
			   27/07/2017 - Ajuste realizado na ordenacao da consulta das faturas, conforme
							solicitado no chamado 684865. (Kelvin)
              
               12/12/2017 - Alterar campo flgcnvsi por tparrecd.
                           PRJ406-FGTS (Odirlei-AMcom)                 
               
               14/12/2017 - Incluido campo na tt-empr-conve.
                             PRJ406-FGTS(Odirlei-AMcom)      
                                     
               17/01/2018 - Alteraçoes referente ao PJ406
..............................................................................*/

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/b1wgen0101tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdigito AS INTE                                           NO-UNDO.
DEF VAR aux_retorno  AS LOG                                            NO-UNDO.

PROCEDURE consulta_titulos:

    DEF INPUT PARAM par_cdcooper AS INT  NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtdpagto AS DATE NO-UNDO.
    DEF INPUT PARAM par_vldpagto AS DEC  NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT  NO-UNDO.
    DEF INPUT PARAM par_flgpagin AS LOG  NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INT  NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INT  NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INT NO-UNDO.
    DEF OUTPUT PARAM par_vlrtotal AS DEC NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dados-pesqti.

    DEF VAR aux_nrregist AS INT  NO-UNDO.
    DEF VAR aux_dslindig AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-dados-pesqti.

    ASSIGN aux_nrregist = par_nrregist. 

    IF  par_dtdpagto = ?  THEN
        ASSIGN par_dtdpagto = par_dtmvtolt.

    FOR EACH craptit WHERE craptit.cdcooper =  par_cdcooper AND
                           craptit.dtdpagto =  par_dtdpagto AND
                           craptit.vldpagto >= par_vldpagto AND
                         ((par_cdagenci = 0                 AND
                           craptit.cdagenci > 0           ) OR
                           craptit.cdagenci = par_cdagenci)
                           NO-LOCK BY craptit.vldpagto:

        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginação */
        IF  par_flgpagin  AND
           (par_qtregist < par_nriniseq  OR
            par_qtregist > (par_nriniseq + par_nrregist))  THEN
            NEXT.
        
        IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
            DO:
                ASSIGN par_vlrtotal = par_vlrtotal + craptit.vldpagto.

                FIND crapope WHERE crapope.cdcooper = craptit.cdcooper AND
                                   crapope.cdoperad = craptit.cdoperad
                                   NO-LOCK NO-ERROR.

                CREATE tt-dados-pesqti.
                ASSIGN tt-dados-pesqti.cdbandst = craptit.cdbandst
                       tt-dados-pesqti.dscodbar = craptit.dscodbar
                       tt-dados-pesqti.nrautdoc = craptit.nrautdoc
                       tt-dados-pesqti.nrdocmto = craptit.nrdocmto
                       tt-dados-pesqti.flgpgdda = craptit.flgpgdda
                       tt-dados-pesqti.nrdconta = craptit.nrdconta
                       tt-dados-pesqti.nmoperad = IF  AVAIL crapope  THEN 
                                                          crapope.nmoperad
                                                      ELSE
                                                          "       *********"
                       tt-dados-pesqti.nrdolote = craptit.nrdolote
                       tt-dados-pesqti.vldpagto = craptit.vldpagto
                       tt-dados-pesqti.cdagenci = craptit.cdagenci
                       tt-dados-pesqti.tpcptdoc = craptit.tpcptdoc.

                IF  tt-dados-pesqti.tpcptdoc = 1 THEN
                    DO:
                        tt-dados-pesqti.dscptdoc = "leitura do codigo de barras".
                    END.
                ELSE
                    DO:
                        IF  tt-dados-pesqti.tpcptdoc = 2 THEN
                            tt-dados-pesqti.dscptdoc = "digitado manualmente".
                        ELSE
                            tt-dados-pesqti.dscptdoc = "".
                    END.

                FIND crapban WHERE crapban.cdbccxlt = craptit.cdbandst
                                   NO-LOCK NO-ERROR.
                
                IF  AVAIL crapban THEN
                    ASSIGN tt-dados-pesqti.nmextbcc = crapban.nmextbcc.
                ELSE
                    ASSIGN tt-dados-pesqti.nmextbcc = 
                                                    "** BANCO NAO CADASTRADO **".
                
                IF  craptit.cdagenci = 91  THEN /** TAA **/
                    DO:
                        FIND crapcop WHERE crapcop.cdcooper = craptit.cdcoptfn
                                           NO-LOCK NO-ERROR.
                
                        IF  AVAIL crapcop  THEN
                            ASSIGN tt-dados-pesqti.dspactaa = 
                                               STRING(crapcop.cdagectl,"9999") +
                                               "/" +
                                               STRING(craptit.cdagetfn,"9999") +
                                               "/" +
                                               STRING(craptit.nrterfin,"9999").
                    END.

                /* Gerar a linha digitavel a partir do codigo de barras */
                ASSIGN aux_dslindig = "".
                
                { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

                RUN STORED-PROCEDURE pc_calc_linha_digitavel
                                     aux_handproc = PROC-HANDLE NO-ERROR ( INPUT tt-dados-pesqti.dscodbar
                                                                         ,OUTPUT "").
 
                CLOSE STORED-PROC pc_calc_linha_digitavel
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_dslindig = pc_calc_linha_digitavel.pr_lindigit
                                          WHEN pc_calc_linha_digitavel.pr_lindigit <> ?
                
                       tt-dados-pesqti.dslindig = aux_dslindig.

            END.
          
        IF  par_flgpagin  THEN
            ASSIGN aux_nrregist = aux_nrregist - 1.
    
    END.

    RETURN "OK".

END PROCEDURE. 

PROCEDURE consulta_faturas:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtdpagto AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_vldpagto AS DECI                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_flgpagin AS LOGI                              NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE                              NO-UNDO.
    
    /* PJ406 */
    DEF INPUT PARAM par_dtipagto AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtfpagto AS DATE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT  NO-UNDO.
    DEF INPUT PARAM par_nrautdoc AS CHAR NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INT NO-UNDO.
    DEF OUTPUT PARAM par_vlrtotal AS DEC NO-UNDO.
                                 
    DEF OUTPUT PARAM TABLE FOR tt-dados-pesqti.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrregist AS INT    NO-UNDO.
    
    DEF VAR aux_lindigi1 AS DECI   NO-UNDO.
    DEF VAR aux_lindigi2 AS DECI   NO-UNDO.
    DEF VAR aux_lindigi3 AS DECI   NO-UNDO.
    DEF VAR aux_lindigi4 AS DECI   NO-UNDO.
    DEF VAR aux_dslindig AS CHAR   NO-UNDO.
    DEF VAR aux_cdcalcul AS DECI   NO-UNDO.
    DEF VAR aux_nrdigito AS INTE   NO-UNDO.
    DEF VAR aux_flgretor AS LOGI   NO-UNDO.
    DEF VAR h_b1crap14   AS HANDLE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-pesqti.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nrregist = par_nrregist.

    IF  par_dtdpagto = ?  THEN
        ASSIGN par_dtdpagto = par_dtmvtolt.

    /* Verifica Empr. e Segmto. */
    IF  par_cdempcon <> 0 AND
        par_cdsegmto <> 0 THEN
        DO:
            RUN lista-empresas-conv (INPUT par_cdcooper,
                                     INPUT par_cdempcon,
                                     INPUT par_cdsegmto,
                                     INPUT "",
                                     INPUT 999,
                                     INPUT 0,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE tt-empr-conve).
                            
            IF  RETURN-VALUE = "NOK"  THEN
                RETURN "NOK".

            IF  NOT CAN-FIND(tt-empr-conve WHERE tt-empr-conve.cdempcon = par_cdempcon) OR
                NOT CAN-FIND(tt-empr-conve WHERE tt-empr-conve.cdsegmto = par_cdsegmto) THEN
                DO:
                    /* PJ406 */
                    ASSIGN aux_dscritic = "Empresa e Segmento nao conferem"
                           aux_cdcritic = 0.

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    
                    RETURN "NOK".
                    
                END.
        END.

    FOR EACH craplft WHERE craplft.cdcooper =  par_cdcooper    AND
                           craplft.dtmvtolt >= par_dtipagto    AND
                           craplft.dtmvtolt <= par_dtfpagto    AND
                          (IF par_cdagenci > 0 THEN           
                           craplft.cdagenci = par_cdagenci    
                           ELSE craplft.cdagenci > 0)         AND
                          (IF par_cdempcon > 0 THEN           
                              craplft.cdempcon = par_cdempcon    
                           ELSE 
                              TRUE)                         AND
                          (IF par_cdsegmto > 0 THEN           
                              craplft.cdsegmto = par_cdsegmto    
                           ELSE 
                              TRUE) AND
                          (IF par_nrdconta > 0 THEN           
                              craplft.nrdconta = par_nrdconta    
                           ELSE 
                              TRUE) AND
                          (IF par_nrautdoc <> "" THEN           
                              craplft.cdbarras = par_nrautdoc    
                           ELSE 
                              TRUE)            
                           NO-LOCK BY (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros):

        IF  par_vldpagto <> 0 THEN
            IF  (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros) < par_vldpagto THEN
                NEXT.

        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginação */
        IF  par_flgpagin  AND
           (par_qtregist < par_nriniseq  OR
            par_qtregist > (par_nriniseq + par_nrregist)) THEN
            NEXT.

        IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
            DO:
                ASSIGN par_vlrtotal = par_vlrtotal + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).
    
                CREATE tt-dados-pesqti.
                ASSIGN tt-dados-pesqti.cdbandst = craplft.cdbccxlt 
                       tt-dados-pesqti.dscodbar = craplft.cdbarras
                       tt-dados-pesqti.nrautdoc = craplft.nrautdoc
                       tt-dados-pesqti.nrdocmto = craplft.cdseqfat
                       tt-dados-pesqti.nrdconta = craplft.nrdconta
                       tt-dados-pesqti.nmoperad = "       *********"
                       tt-dados-pesqti.nrdolote = craplft.nrdolote
                       tt-dados-pesqti.vldpagto = (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros)
                       tt-dados-pesqti.cdagenci = craplft.cdagenci
                       tt-dados-pesqti.vlconfoz = DECI(SUBSTR(craplft.cdbarras,24,10)) / 100
                       tt-dados-pesqti.insitfat = craplft.insitfat
                       tt-dados-pesqti.dtapurac = craplft.dtapurac
                       tt-dados-pesqti.nrcpfcgc = craplft.nrcpfcgc
                       tt-dados-pesqti.cdtribut = craplft.cdtribut
                       tt-dados-pesqti.nrrefere = craplft.nrrefere
                       tt-dados-pesqti.dtlimite = craplft.dtlimite
                       tt-dados-pesqti.vllanmto = craplft.vllanmto
                       tt-dados-pesqti.vlrmulta = craplft.vlrmulta
                       tt-dados-pesqti.vlrjuros = craplft.vlrjuros
                       tt-dados-pesqti.vlrecbru = craplft.vlrecbru   
                       tt-dados-pesqti.vlpercen = craplft.vlpercen
                       tt-dados-pesqti.vlrtotal = (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros)
                       tt-dados-pesqti.tpcptdoc = craplft.tpcptdoc
                       tt-dados-pesqti.dsnomfon = craplft.dsnomfon.

                IF  tt-dados-pesqti.tpcptdoc = 1 THEN
                    DO:
                        tt-dados-pesqti.dscptdoc = "leitura do codigo de barras".
                    END.
                ELSE
                    DO:
                        IF  tt-dados-pesqti.tpcptdoc = 2 THEN
                            tt-dados-pesqti.dscptdoc = "digitado manualmente".
                        ELSE
                            tt-dados-pesqti.dscptdoc = "".
                    END.

                
                FIND crapage WHERE crapage.cdagenci = craplft.cdagenci AND
                                   crapage.cdcooper = craplft.cdcooper
                                   NO-LOCK NO-ERROR.
                
                ASSIGN tt-dados-pesqti.nmresage = crapage.nmresage.
                
                FIND crapcon WHERE crapcon.cdcooper = craplft.cdcooper AND
                                   crapcon.cdempcon = craplft.cdempcon AND
                                   crapcon.cdsegmto = craplft.cdsegmto
                                   NO-LOCK NO-ERROR.
                
                IF crapcon.tparrecd = 2 THEN
                  ASSIGN tt-dados-pesqti.nmempres = crapcon.nmextcon.
                ELSE IF crapcon.tparrecd = 3 THEN /* Convenios CECRED */ 
                DO:
                    FIND FIRST gnconve WHERE gnconve.cdhiscxa = craplft.cdhistor NO-LOCK NO-ERROR.
                    ASSIGN tt-dados-pesqti.nmempres = gnconve.nmempres.
                END.
                ELSE /* Convenios SICREDI */
                DO: 
                    IF craplft.tpfatura <> 2 OR 
                       craplft.cdempcon <> 0 THEN  
                    DO: 
                        /* Para convenios sicredi, pegar nome do convenio na crapscn */
                        FIND FIRST crapscn WHERE crapscn.cdempcon  = craplft.cdempcon and
                                                 crapscn.cdsegmto  = STRING(craplft.cdsegmto) and
                                                 crapscn.dsoparre <> 'E'
                                                 NO-LOCK NO-ERROR.
                        IF NOT AVAIL crapscn THEN
                        DO:
                            FIND FIRST crapscn WHERE crapscn.cdempco2  = craplft.cdempcon and
                                                     crapscn.cdsegmto  = STRING(craplft.cdsegmto) and
                                                     crapscn.dsoparre <> 'E'
                                                     NO-LOCK NO-ERROR.
                        END.                        
                    END.
                    ELSE /* DARF */
                    DO: /* darf simples */
                        IF craplft.cdtribut = "6106" THEN 
                            FIND FIRST crapscn WHERE crapscn.cdempres = "D0"
                                                     NO-LOCK NO-ERROR NO-WAIT.
                        /* darf preto europa */
                        ELSE                              
                            FIND FIRST crapscn WHERE crapscn.cdempres = "A0"
                                                     NO-LOCK NO-ERROR NO-WAIT.
                    END. 
                
                    ASSIGN tt-dados-pesqti.nmempres = crapscn.dsnomcnv.
                END.

                FIND crapban WHERE crapban.cdbccxlt = craplft.cdbccxlt 
                                   NO-LOCK NO-ERROR.
               
                IF  AVAIL crapban THEN
                    ASSIGN tt-dados-pesqti.nmextbcc = crapban.nmextbcc.
                ELSE
                    ASSIGN tt-dados-pesqti.nmextbcc = 
                                                    "** BANCO NAO CADASTRADO **".
               
                IF  craplft.cdagenci = 91  THEN /** TAA **/
                    DO:
                        FIND crapcop WHERE crapcop.cdcooper = craplft.cdcoptfn
                                           NO-LOCK NO-ERROR.
               
                        IF  AVAIL crapcop  THEN
                            ASSIGN tt-dados-pesqti.dspactaa = 
                                               STRING(crapcop.cdagectl,"9999") +
                                               "/" +
                                               STRING(craplft.cdagetfn,"9999") +
                                               "/" +
                                               STRING(craplft.nrterfin,"9999").
                    END.
                    
                /* Geracao da linha digitavel */
                /* Monta os campos manuais e pega o digito */
                ASSIGN aux_dslindig = "".
                /* Campo 1 */
                ASSIGN aux_lindigi1 = DECIMAL(SUBSTRING(tt-dados-pesqti.dscodbar,1,11)).
                IF  SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "6" OR
                    SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "7" THEN
                    DO: /** Verificacao pelo modulo 10**/   
                        RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigi1,
                                           OUTPUT       aux_nrdigito,
                                           OUTPUT       aux_flgretor).
                    END.
                ELSE
                    DO:
                        RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
                        IF   VALID-HANDLE(h_b1crap14)   THEN
                              DO: /** Verificacao pelo modulo 11 **/
                                  RUN verifica_digito IN h_b1crap14 (INPUT aux_lindigi1,
                                                                    OUTPUT aux_nrdigito).
                                  DELETE PROCEDURE h_b1crap14.
                              END.
                    END.
                
                ASSIGN aux_dslindig = aux_dslindig + 
                                      STRING(SUBSTRING(tt-dados-pesqti.dscodbar,1,11),"99999999999") + "-" +
                                      STRING(aux_nrdigito,"9").
                                       
                /* Campo 2 */
                ASSIGN aux_lindigi2 = DECIMAL(SUBSTRING(tt-dados-pesqti.dscodbar,12,11)).
                IF  SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "6" OR
                    SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "7" THEN
                    DO: /** Verificacao pelo modulo 10**/   
                        RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigi2,
                                           OUTPUT       aux_nrdigito,
                                           OUTPUT       aux_flgretor).
                    END.
                ELSE
                    DO:
                        RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
                        IF   VALID-HANDLE(h_b1crap14)   THEN
                              DO:  /** Verificacao pelo modulo 11 **/
                                  RUN verifica_digito IN h_b1crap14 (INPUT aux_lindigi2,
                                                                     OUTPUT aux_nrdigito).
                                  DELETE PROCEDURE h_b1crap14.
                              END.
                    END. 
               
                ASSIGN aux_dslindig = aux_dslindig + " " +
                                      STRING(SUBSTRING(tt-dados-pesqti.dscodbar,12,11),"99999999999") + "-" +
                                      STRING(aux_nrdigito,"9").
                                       
                /* Campo 3 */
                ASSIGN aux_lindigi3 = DECIMAL(SUBSTRING(tt-dados-pesqti.dscodbar,23,11)).
                IF  SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "6" OR
                    SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "7" THEN
                    DO: /** Verificacao pelo modulo 10**/   
                        RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigi3,
                                           OUTPUT       aux_nrdigito,
                                           OUTPUT       aux_flgretor).
                    END.
                ELSE
                    DO:
                        RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
                        IF   VALID-HANDLE(h_b1crap14)   THEN
                              DO: /** Verificacao pelo modulo 11 **/
                                  RUN verifica_digito IN h_b1crap14 (INPUT aux_lindigi3,
                                                                     OUTPUT aux_nrdigito).
                                  DELETE PROCEDURE h_b1crap14.
                              END.
                    END.
               
                ASSIGN aux_dslindig = aux_dslindig + " " +
                                      STRING(SUBSTRING(tt-dados-pesqti.dscodbar,23,11),"99999999999") + "-" +
                                      STRING(aux_nrdigito,"9").
                                       
                /* Campo 4 */
                ASSIGN aux_lindigi4 = DECIMAL(SUBSTRING(tt-dados-pesqti.dscodbar,34,11)).
                IF  SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "6" OR
                    SUBSTR(tt-dados-pesqti.dscodbar, 3, 1) = "7" THEN
                    DO: /** Verificacao pelo modulo 10**/   
                        RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigi4,
                                           OUTPUT       aux_nrdigito,
                                           OUTPUT       aux_flgretor).
                    END.
                ELSE
                    DO:
                        RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
                        IF   VALID-HANDLE(h_b1crap14)   THEN
                              DO: /** Verificacao pelo modulo 11 **/
                                  RUN verifica_digito IN h_b1crap14 (INPUT aux_lindigi4,
                                                                     OUTPUT aux_nrdigito).
                                  DELETE PROCEDURE h_b1crap14.
                              END.
                    END.
                
                ASSIGN aux_dslindig = aux_dslindig + " " +
                                      STRING(SUBSTRING(tt-dados-pesqti.dscodbar,34,11),"99999999999") + "-" +
                                      STRING(aux_nrdigito,"9").
               
                ASSIGN tt-dados-pesqti.dslindig = aux_dslindig.
                 
            END.

        IF  par_flgpagin  THEN
            ASSIGN aux_nrregist = aux_nrregist - 1.

    END.

    RETURN "OK".                                  

END PROCEDURE.

PROCEDURE lista-historicos:

    DEF INPUT PARAM par_cdhiscxa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmempres AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-historicos.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-historicos.

    ASSIGN aux_nrregist = par_nrregist.

    FOR EACH gnconve WHERE (IF par_cdhiscxa <> 0 THEN
                           gnconve.cdhiscxa = par_cdhiscxa ELSE 
                           gnconve.cdhiscxa > 0)                                        AND
                           (IF par_nmempres <> "" THEN
                           gnconve.nmempres MATCHES "*" + par_nmempres + "*" ELSE TRUE) AND
                           gnconve.flgativo = TRUE                                      NO-LOCK
                           BREAK BY gnconve.cdhiscxa:

        IF  FIRST-OF(gnconve.cdhiscxa) THEN
            DO:
                ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginação */
                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.

                IF  aux_nrregist >= 1 THEN
                DO:
                    CREATE tt-historicos.
                    ASSIGN tt-historicos.cdhiscxa = gnconve.cdhiscxa
                           tt-historicos.nmempres = gnconve.nmempres.
                END.
                
                ASSIGN aux_nrregist = aux_nrregist - 1.

            END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista-empresas-conv:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmextcon AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-empr-conve.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-empr-conve.

    ASSIGN aux_nrregist = par_nrregist.

    FOR EACH crapcon WHERE crapcon.cdcooper = par_cdcooper AND
                           (crapcon.tparrecd = 1  OR		   /* SCIREDI */
                            crapcon.tparrecd = 2 )         AND /* Bancoob */
                          (IF par_cdempcon <> 0 THEN
                           crapcon.cdempcon = par_cdempcon ELSE 
                           crapcon.cdempcon > 0)           AND
                          (IF par_cdsegmto <> 0 THEN
                           crapcon.cdsegmto = par_cdsegmto ELSE 
                           crapcon.cdsegmto > 0)           AND
                          (IF par_nmextcon <> "" THEN
                           crapcon.nmrescon MATCHES "*" + par_nmextcon + "*" ELSE TRUE)
                           NO-LOCK BREAK BY crapcon.cdempcon.

       ASSIGN par_qtregist = par_qtregist + 1.

           /* controles da paginação */
       IF  (par_qtregist < par_nriniseq) OR
           (par_qtregist > (par_nriniseq + par_nrregist)) THEN
           NEXT.

       IF  aux_nrregist >= 1 THEN
           DO:
               CREATE tt-empr-conve.
               ASSIGN tt-empr-conve.nmextcon  =  crapcon.nmextcon
                      tt-empr-conve.nmrescon  =  crapcon.nmrescon
                      tt-empr-conve.cdempcon  =  crapcon.cdempcon
                      tt-empr-conve.cdsegmto  =  crapcon.cdsegmto
                      tt-empr-conve.flgcnvsi  =  IF crapcon.tparrecd = 1 THEN "SIM"
                                                 ELSE "NAO".
           END.
       
       ASSIGN aux_nrregist = aux_nrregist - 1.

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE grava-dados-fatura:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM par_cdagefat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.

    DEF  INPUT PARAM par_dscodbar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_insitfat AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgtrans         AS LOGI                           NO-UNDO.
    DEF  VAR aux_contador         AS INTE                           NO-UNDO.
    /* Vars para log */
    DEF  VAR log_dscodbar         AS CHAR                           NO-UNDO.
    DEF  VAR log_antsitfa         AS CHAR                           NO-UNDO.
    DEF  VAR log_detsitfa         AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    DEF BUFFER b-craplft1 FOR craplft.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

    TRANS_FAT:
    DO TRANSACTION ON ENDKEY UNDO TRANS_FAT, LEAVE TRANS_FAT
                   ON ERROR  UNDO TRANS_FAT, LEAVE TRANS_FAT:

       Contador:
       DO aux_contador = 1 TO 10:

           ASSIGN aux_cdcritic = 0.

           FIND craplft WHERE craplft.cdcooper = par_cdcooper AND
                              craplft.dtmvtolt = par_dtdpagto AND
                              craplft.cdagenci = par_cdagefat AND
                              craplft.cdbccxlt = par_cdbccxlt AND
                              craplft.nrdolote = par_nrdolote AND
                              STRING(craplft.cdseqfat) = STRING(par_nrdocmto)
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
           IF NOT AVAILABLE craplft THEN
              IF LOCKED craplft  THEN
                 DO: 
                    IF aux_contador = 10 THEN
                       DO:
                          ASSIGN aux_cdcritic = 77.
                          LEAVE Contador.
                       END.
                    ELSE
                       DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT Contador.
                       END.
                     
                 END. 
              ELSE
                 DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Lancamento de Fatura" + 
                                          " nao encontrado.".

                    LEAVE Contador.

                 END.

           IF (craplft.tpfatura <> 2       AND 
               par_dscodbar     <= 0)      OR 
              (craplft.tpfatura = 2        AND 
               DEC(craplft.cdbarras) > 0   AND
               par_dscodbar     <= 0)      THEN
              DO:
                 ASSIGN aux_dscritic = "Cod. de Barras invalido.". 
                 
                 LEAVE Contador.

              END.

           LEAVE Contador.

       END. /* FIM do DO ... TO */

       /* PJ406 */
       FIND crapcon WHERE crapcon.cdcooper = craplft.cdcooper AND
                          crapcon.cdsegmto = craplft.cdsegmto AND 
                          crapcon.cdempcon = craplft.cdempcon
                          NO-LOCK NO-ERROR.
       
       IF crapcon.tparrecd = 2 THEN /* BANCOOB */
         DO:
           FIND FIRST craptab WHERE craptab.cdcooper = par_cdcooper  AND
                                    craptab.nmsistem = 'CRED'        AND
                                    craptab.tptabela = 'GENERI'      AND
                                    craptab.cdempres = 0             AND
                                    craptab.cdacesso = 'HRPGBANCOOB' AND
                                    craptab.tpregist = par_cdagenci
                                    NO-LOCK NO-ERROR.
          
           IF TIME < INT(ENTRY(1, craptab.dstextab, " ")) OR /* hora inicial */
              TIME > INT(ENTRY(2, craptab.dstextab, " "))    /* hora final */ THEN
             ASSIGN aux_dscritic = "Horario p/ inclusao BANCOOB esta " + 
                                   "fora do estabelecido na tela CADPAC".

           IF (aux_dscritic <> "") THEN
             DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).
               RETURN "NOK".
               UNDO TRANS_FAT, LEAVE TRANS_FAT.
             END.
         END.

       IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
          UNDO TRANS_FAT, LEAVE TRANS_FAT.

       FIND gnconve WHERE gnconve.cdhiscxa = craplft.cdhistor AND
                          gnconve.flgenvpa = TRUE
                          NO-LOCK NO-ERROR.

       IF AVAIL gnconve THEN
          DO:
             ASSIGN aux_dscritic = "Convenio nao permite alteracoes.".
             UNDO TRANS_FAT, LEAVE TRANS_FAT.
          END.

       /* Valida Sit. da Fatura informada */
       IF NOT CAN-DO("1,2",STRING(par_insitfat)) THEN
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Situacao da Fatura invalida.".

              UNDO TRANS_FAT, LEAVE TRANS_FAT.
       
          END.

       ASSIGN log_dscodbar = craplft.cdbarras
              log_antsitfa = STRING(craplft.insitfat).

       /* Se o codigo de barras foi atualizado */
       IF DEC(log_dscodbar) <> par_dscodbar THEN 
          DO:
             /* Calculo Digito Verificador */
             RUN dbo/pcrap04.p (INPUT-OUTPUT par_dscodbar,
                                OUTPUT aux_nrdigito,
                                OUTPUT aux_retorno).
             
             IF aux_retorno = NO THEN 
                DO:
                   /*** Verificacao do digito no modulo 11 ***/
                   RUN dbo/pcrap14.p (INPUT-OUTPUT par_dscodbar,
                                      OUTPUT aux_nrdigito,
                                      OUTPUT aux_retorno).
             
                   IF aux_retorno = NO THEN
                      DO: 
                         ASSIGN aux_cdcritic = 0
                                aux_dscritic = "Cod. de Barras invalido.". 
             
                         UNDO TRANS_FAT, LEAVE TRANS_FAT.
                      END.

                END.
             
             FIND FIRST b-craplft1 
                   WHERE b-craplft1.cdcooper = par_cdcooper AND
                         b-craplft1.dtmvtolt = par_dtdpagto AND
                         b-craplft1.cdagenci = par_cdagefat AND
                         b-craplft1.cdbccxlt = par_cdbccxlt AND
                         b-craplft1.nrdolote = par_nrdolote AND
                         STRING(b-craplft1.cdseqfat) = SUBSTR(STRING(par_dscodbar),7,38)
                         NO-LOCK NO-ERROR.
             
             IF AVAIL b-craplft1 THEN
                DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Ja existe fatura com o codigo " +
                                         "de barras informado.". 
             
                   UNDO TRANS_FAT, LEAVE TRANS_FAT.

                END.
             
             ASSIGN craplft.cdbarras = STRING(par_dscodbar)
                    craplft.cdseqfat = DECIMAL(SUBSTR(craplft.cdbarras,7,38))
                    craplft.vllanmto = DECIMAL(SUBSTR(craplft.cdbarras,5,11)) / 100.

          END.

       ASSIGN craplft.insitfat = par_insitfat.
       
       /* Se mudar Enviado de SIM para NÃO, atualiza vencto */
       IF par_insitfat = 1 THEN
          ASSIGN craplft.dtvencto = par_dtmvtolt.
               
       ASSIGN aux_flgtrans = TRUE.

    END. /* FIM do TRANSACTION */

    IF NOT aux_flgtrans THEN
       DO:
          IF aux_cdcritic = 0 AND aux_dscritic = ""  THEN
             ASSIGN aux_dscritic = "Nao foi possivel atualizar os valores.".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

       END.
    ELSE
       DO:
          /* Se a trans. ocorreu corretamente, grava o log */
          IF log_dscodbar <> STRING(par_dscodbar)   THEN 
             DO:
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")              + 
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"                      +
                            "Operador " + par_cdoperad                                     +
                            " alterou o codigo de barras da fatura do dia "                +
                            STRING(craplft.dtmvtolt) + ", PA  " + STRING(craplft.cdagenci) +
                            ", Historico " + STRING(craplft.cdhistor) + ", com valor de "  +
                            STRING(craplft.vllanmto,"zzz,zzz,zzz,zz9.99") + " de "         + 
                            STRING(log_dscodbar) + " para " + STRING(par_dscodbar) + "."   +
                            " >> /usr/coop/" + TRIM(crapcop.dsdircop)                      +
                            "/log/pesqti.log").
             END.

          IF log_antsitfa <> STRING(par_insitfat) THEN 
             DO:
                ASSIGN log_antsitfa = IF INT(log_antsitfa) = 1 THEN "Nao"
                                      ELSE "Sim".

                ASSIGN log_detsitfa = IF par_insitfat = 1 THEN "Nao"
                                      ELSE "Sim".

                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")              + 
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"                      +
                            "Operador " + par_cdoperad                                     +
                            " alterou o campo Enviado da fatura do dia "                   +
                            STRING(craplft.dtmvtolt) + ", PA  " + STRING(craplft.cdagenci) +
                            ", Historico " + STRING(craplft.cdhistor) + ", com valor de "  +
                            STRING(craplft.vllanmto,"zzz,zzz,zzz,zz9.99") + " de "         +
                            STRING(log_antsitfa) + " para "          +
                            STRING(log_detsitfa) + "."                   + 
                            " >> /usr/coop/" + TRIM(crapcop.dsdircop)                      +
                            "/log/pesqti.log").

             END.

       END.

    RETURN "OK".

END PROCEDURE.

/*...........................................................................*/
