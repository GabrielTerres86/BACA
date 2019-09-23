/*.............................................................................
    Programa: b1wgen0149.p
    Autor   : David Kruger
    Data    : Janeiro/2013                     Ultima Atualizacao: 30/11/2016
           
    Dados referentes ao programa:
                
    Objetivo  : BO de uso para tela AGENCI.
                    
    Alteracoes: 08/01/2014 - Ajustes homologacao (Adriano).
				
				06/09/2016 - Adicionado filtro pelo nome da agencia e do banco, conforme solicitado
						 	 no chamado 504477 (Kelvin).
                
                30/11/2016 - Alterado campo dsdepart para cddepart.
                             PRJ341 - BANCENJUD (Odirlei-AMcom)
               
.............................................................................*/

{ sistema/generico/includes/b1wgen0149tt.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

/** Busca Dados do Banco  **/
PROCEDURE busca-banco:
     
  DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cddepart AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cddbanco AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_nrregist AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nriniseq AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nmextbcc AS CHAR                            NO-UNDO.
                                                              
  DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-banco.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
  DEF VAR aux_cddbanco AS INTE                                    NO-UNDO.
  DEF VAR aux_nrregist AS INTE                                    NO-UNDO.
  
  EMPTY TEMP-TABLE tt-erro.
  EMPTY TEMP-TABLE tt-banco.
 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cddbanco = INTE(par_cddbanco).

  IF CAN-DO("A,E,I",par_cddopcao)  THEN
     DO:
        IF par_cddepart <> 20  AND   /* TI */                    
           par_cddepart <> 8   AND   /* COORD.ADM/FINANCEIRO */  
           par_cddepart <> 9   AND   /* COORD.PRODUTOS       */   
           par_cddepart <> 4   THEN  /* COMPE                */   
           DO:
              ASSIGN aux_cdcritic = 36
                     par_nmdcampo = "cddbanco". 
     
              RUN gera_erro(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
         
              RETURN "NOK".

           END.
           
     END.
 
  IF par_idorigem = 5 THEN
     DO:
        ASSIGN aux_nrregist = par_nrregist.

        FOR EACH crapban WHERE (IF par_cddbanco <> ""              THEN
                                   crapban.cdbccxlt = aux_cddbanco
                                 ELSE 
                                    TRUE)  AND
							    crapban.nmextbcc MATCHES "*" + par_nmextbcc + "*" 
                                NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF (par_qtregist < par_nriniseq)                  OR
               (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.
         
            IF aux_nrregist > 0 THEN
               DO:
                  CREATE tt-banco.

                  ASSIGN tt-banco.cddbanco = crapban.cdbccxlt
                         tt-banco.nmextbcc = crapban.nmextbcc.

               END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END. 

        IF NOT TEMP-TABLE tt-banco:HAS-RECORDS THEN
           DO:
              ASSIGN aux_cdcritic = 57
                     par_nmdcampo = "cddbanco". 

              RUN gera_erro(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
         
              RETURN "NOK".  
          
           END.  
     END.
  ELSE
     DO:
        FIND crapban WHERE crapban.cdbccxlt = aux_cddbanco 
                           NO-LOCK NO-ERROR. 
     
        IF NOT AVAILABLE crapban  THEN
           DO:
               ASSIGN aux_cdcritic = 57
                      par_nmdcampo = "cddbanco". 
     
               RUN gera_erro(INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic ).
         
                RETURN "NOK".
     
            END.
        
        
        CREATE tt-banco.
     
        ASSIGN tt-banco.cddbanco = crapban.cdbccxlt
               tt-banco.nmextbcc = crapban.nmextbcc.
     
     END. 

  RETURN "OK".

END PROCEDURE.

/** Busca Dados das Agencias  **/
PROCEDURE busca-agencia:
     
  DEF INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_cddepart AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cdageban AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cddbanco AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_nrregist AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_nriniseq AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_nmageban AS CHAR                          NO-UNDO.
  
                                                           
  DEF OUTPUT PARAM par_nmdcampo AS CHAR                         NO-UNDO.
  DEF OUTPUT PARAM par_qtregist AS INTE                         NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-agencia.                    
  DEF OUTPUT PARAM TABLE FOR tt-feriados.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
  DEF VAR aux_nrregist AS INTE                                  NO-UNDO.

  EMPTY TEMP-TABLE tt-agencia.
  EMPTY TEMP-TABLE tt-feriados.
  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = "".

  IF CAN-DO("A,E,I",par_cddopcao)  THEN
     DO:
        IF par_cddepart <> 20  AND   /* TI */                    
           par_cddepart <> 8   AND   /* COORD.ADM/FINANCEIRO */  
           par_cddepart <> 9   AND   /* COORD.PRODUTOS       */   
           par_cddepart <> 4   THEN  /* COMPE                */   
           DO:
              ASSIGN aux_cdcritic = 36
                     par_nmdcampo = "cddbanco". 
     
              RUN gera_erro(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
         
              RETURN "NOK".

           END.
           
     END.

  IF par_nmageban <> ""	 THEN
     DO: 
		ASSIGN aux_nrregist = par_nrregist.
        
        FOR EACH crapagb WHERE crapagb.cddbanco = par_cddbanco AND
						       crapagb.nmageban MATCHES "*" + par_nmageban + "*"
                               NO-LOCK BY crapagb.cddbanco
                                        BY crapagb.cdageban.
			
			IF par_cdageban > 0 AND
			   par_cdageban <> crapagb.cdageban THEN
			   NEXT.
			   
            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF (par_qtregist < par_nriniseq) OR
               (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF aux_nrregist > 0 THEN
               DO: 
                  FIND tt-agencia WHERE tt-agencia.cddbanco = crapagb.cddbanco AND
                                        tt-agencia.cdageban = crapagb.cdageban
                                        NO-LOCK NO-ERROR.

                  IF NOT AVAIL tt-agencia THEN
                     DO:
                        FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade 
                                           NO-LOCK NO-ERROR.
         
                        CREATE tt-agencia.
                     
                        ASSIGN tt-agencia.nrdrowid = ROWID(crapagb)
                               tt-agencia.cddbanco = crapagb.cddbanco
                               tt-agencia.cdageban = crapagb.cdageban
                               tt-agencia.dgagenci = crapagb.dgagenci
                               tt-agencia.nmageban = crapagb.nmageban
                               tt-agencia.nmcidade = (IF AVAIL crapcaf THEN
                                                        crapcaf.nmcidade
                                                     ELSE 
                                                        "")
                               tt-agencia.cdufresd = (IF AVAIL crapcaf THEN
                                                        crapcaf.cdufresd
                                                     ELSE 
                                                        "")
                               tt-agencia.cdcompen = (IF AVAIL crapcaf THEN
                                                        crapcaf.cdcompen
                                                    ELSE 
                                                       0)
                               tt-agencia.cdsitagb = crapagb.cdsitagb. 
                        
                        FOR EACH crapfsf WHERE crapfsf.cdcidade = crapagb.cdcidade 
                                               NO-LOCK:
                                      
                            IF ABS(crapfsf.dtferiad - par_dtmvtolt) > 365 THEN 
                               NEXT.
                        
                            CREATE tt-feriados.
                        
                            ASSIGN tt-feriados.nrdrowid = tt-agencia.nrdrowid
                                   tt-feriados.dtferiad = crapfsf.dtferiad
                                   tt-feriados.flgbaixa = IF crapfsf.dtdbaixa = ? THEN 0 ELSE 1.
                        
                        END.

                     END.

               END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
            
        END.

        IF NOT TEMP-TABLE tt-agencia:HAS-RECORDS THEN
           DO:
              ASSIGN aux_cdcritic = 15
                     par_nmdcampo = "cdageban". 
           
              RUN gera_erro(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
           
              RETURN "NOK".
           
           END.		

     END.

  IF par_cddbanco <> 0 AND
     par_cdageban <> 0 AND
	 par_nmageban = "" THEN
     DO:  
         IF par_cddopcao = "I" THEN
            DO:
               ASSIGN aux_cdcritic = 787
                      par_nmdcampo = "cdageban". 

               RUN gera_erro(INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic ).
  
               RETURN "NOK".

            END.
         
		 FIND crapagb WHERE crapagb.cddbanco = par_cddbanco AND
                            crapagb.cdageban = par_cdageban 
							NO-LOCK NO-ERROR.
  
        IF NOT AVAIL crapagb THEN
           DO: 
               IF par_cddopcao = "I" THEN
                  RETURN "OK".
                         
               ASSIGN aux_cdcritic = 15
                      par_nmdcampo = "cdageban". 

               RUN gera_erro(INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic ).
  
               RETURN "NOK".

           END.
		   
         FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade 
                            NO-LOCK NO-ERROR.
         
         CREATE tt-agencia.

         ASSIGN tt-agencia.nrdrowid = ROWID(crapagb)
                tt-agencia.cddbanco = crapagb.cddbanco
                tt-agencia.cdageban = crapagb.cdageban
                tt-agencia.dgagenci = crapagb.dgagenci
                tt-agencia.nmageban = crapagb.nmageban
                tt-agencia.nmcidade = (IF AVAILABLE crapcaf THEN
                                         crapcaf.nmcidade
                                      ELSE 
                                         "")
                tt-agencia.cdufresd = (IF AVAILABLE crapcaf THEN
                                         crapcaf.cdufresd
                                      ELSE 
                                         "")
                tt-agencia.cdcompen = (IF AVAILABLE crapcaf THEN
                                         crapcaf.cdcompen
                                     ELSE 
                                        0)
                tt-agencia.cdsitagb = crapagb.cdsitagb. 
         
         FOR EACH crapfsf WHERE crapfsf.cdcidade = crapagb.cdcidade 
                                NO-LOCK:
                       
             IF ABS(crapfsf.dtferiad - par_dtmvtolt) > 365 THEN 
                NEXT.
         
             CREATE tt-feriados.
             
             ASSIGN tt-feriados.nrdrowid = tt-agencia.nrdrowid
                    tt-feriados.dtferiad = crapfsf.dtferiad
                    tt-feriados.flgbaixa = IF crapfsf.dtdbaixa = ? THEN 0 ELSE 1.
         
         END.

     END.
  ELSE
     DO:
		IF par_nmageban = "" THEN
		   DO:
		
				ASSIGN aux_nrregist = par_nrregist.
				
				FOR EACH crapagb WHERE crapagb.cddbanco = par_cddbanco
									   NO-LOCK BY crapagb.cddbanco
												BY crapagb.cdageban.

					ASSIGN par_qtregist = par_qtregist + 1.

					/* controles da paginação */
					IF (par_qtregist < par_nriniseq) OR
					   (par_qtregist > (par_nriniseq + par_nrregist)) THEN
						NEXT.

					IF aux_nrregist > 0 THEN
					   DO: 
						  FIND tt-agencia WHERE tt-agencia.cddbanco = crapagb.cddbanco AND
												tt-agencia.cdageban = crapagb.cdageban
												NO-LOCK NO-ERROR.

						  IF NOT AVAIL tt-agencia THEN
							 DO:
								FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade 
												   NO-LOCK NO-ERROR.
				 
								CREATE tt-agencia.
							 
								ASSIGN tt-agencia.nrdrowid = ROWID(crapagb)
									   tt-agencia.cddbanco = crapagb.cddbanco
									   tt-agencia.cdageban = crapagb.cdageban
									   tt-agencia.dgagenci = crapagb.dgagenci
									   tt-agencia.nmageban = crapagb.nmageban
									   tt-agencia.nmcidade = (IF AVAIL crapcaf THEN
																crapcaf.nmcidade
															 ELSE 
																"")
									   tt-agencia.cdufresd = (IF AVAIL crapcaf THEN
																crapcaf.cdufresd
															 ELSE 
																"")
									   tt-agencia.cdcompen = (IF AVAIL crapcaf THEN
																crapcaf.cdcompen
															ELSE 
															   0)
									   tt-agencia.cdsitagb = crapagb.cdsitagb. 
								
								FOR EACH crapfsf WHERE crapfsf.cdcidade = crapagb.cdcidade 
													   NO-LOCK:
											  
									IF ABS(crapfsf.dtferiad - par_dtmvtolt) > 365 THEN 
									   NEXT.
								
									CREATE tt-feriados.
								
									ASSIGN tt-feriados.nrdrowid = tt-agencia.nrdrowid
										   tt-feriados.dtferiad = crapfsf.dtferiad
                       tt-feriados.flgbaixa = IF crapfsf.dtdbaixa = ? THEN 0 ELSE 1.
								
								END.

							 END.

					   END.

					ASSIGN aux_nrregist = aux_nrregist - 1.
					
				END.

				IF NOT TEMP-TABLE tt-agencia:HAS-RECORDS THEN
				   DO:
					  ASSIGN aux_cdcritic = 15
							 par_nmdcampo = "cdageban". 
				   
					  RUN gera_erro(INPUT par_cdcooper,
									INPUT par_cdagenci,
									INPUT par_nrdcaixa,
									INPUT 1,            /** Sequencia **/
									INPUT aux_cdcritic,
									INPUT-OUTPUT aux_dscritic ).
				   
					  RETURN "NOK".
				   
				   END.
			END.	 
	END.

  RETURN "OK".

END PROCEDURE.

/** Altera cadastro das Agencias **/
PROCEDURE altera-agencia:

  DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cddepart AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cdageban AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cddbanco AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_dgagenci AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_nmageban AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cdsitagb AS CHAR                            NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
  DEF VAR aux_contador AS INTE                                    NO-UNDO.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = "".

  EMPTY TEMP-TABLE tt-erro.

  IF CAN-DO("A,E,I",par_cddopcao)  THEN
     DO:
        IF par_cddepart <> 20  AND   /* TI */                    
           par_cddepart <> 8   AND   /* COORD.ADM/FINANCEIRO */  
           par_cddepart <> 9   AND   /* COORD.PRODUTOS       */   
           par_cddepart <> 4   THEN  /* COMPE                */   
           DO:
              ASSIGN aux_cdcritic = 36
                     par_nmdcampo = "cddbanco". 
     
              RUN gera_erro(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
         
              RETURN "NOK".

           END.
           
     END.

  Altera:
  DO TRANSACTION ON ERROR  UNDO Altera, LEAVE Altera
                 ON QUIT   UNDO Altera, LEAVE Altera
                 ON STOP   UNDO Altera, LEAVE Altera
                 ON ENDKEY UNDO Altera, LEAVE Altera:

     ContadorAltera:
     DO aux_contador = 1 TO 10:
    
        FIND crapagb WHERE crapagb.cddbanco = par_cddbanco AND
                           crapagb.cdageban = par_cdageban
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAILABLE crapagb THEN
           IF LOCKED crapagb  THEN
              DO:
                 IF aux_contador = 10 THEN
                    DO:
                       ASSIGN aux_cdcritic = 77.

                       LEAVE ContadorAltera.

                    END.
                  
                 PAUSE 1 NO-MESSAGE.
                 NEXT ContadorAltera.

              END.
           ELSE
              DO:
                 ASSIGN aux_cdcritic = 15.

                 LEAVE ContadorAltera.

              END.
               
        LEAVE ContadorAltera.
         
     END. /** Fim do DO ... TO **/
    
     IF aux_cdcritic > 0   OR 
        aux_dscritic <> "" THEN
        UNDO Altera, LEAVE Altera.
    
     ASSIGN crapagb.dgagenci = par_dgagenci
            crapagb.nmageban = CAPS(par_nmageban)
            crapagb.cdoperad = par_cdoperad
            crapagb.dtmvtolt = par_dtmvtolt
            crapagb.cdsitagb = par_cdsitagb.

     LEAVE Altera.
     
  END. /** Fim do DO TRANSACTION **/

  RELEASE crapagb.

  IF aux_cdcritic <> 0  AND 
     aux_dscritic <> "" THEN
     DO:
        ASSIGN par_nmdcampo = "cdageban".

        RUN gera_erro(INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,            /** Sequencia **/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic ).
        RETURN "NOK".

     END.

  RETURN "OK".


END PROCEDURE.


PROCEDURE deleta-agencia:

  DEF INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_cddepart AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_cdageban AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_cddbanco AS INTE                          NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
  DEF INPUT PARAM par_dgagenci AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_nmageban AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_cdsitagb AS CHAR                          NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                         NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
  DEF VAR aux_contador AS INTE                                  NO-UNDO.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = "".

  EMPTY TEMP-TABLE tt-erro.

  IF CAN-DO("A,E,I",par_cddopcao)  THEN
     DO:
        IF par_cddepart <> 20  AND   /* TI */                    
           par_cddepart <> 8   AND   /* COORD.ADM/FINANCEIRO */  
           par_cddepart <> 9   AND   /* COORD.PRODUTOS       */   
           par_cddepart <> 4   THEN  /* COMPE                */   
           DO:
              ASSIGN aux_cdcritic = 36
                     par_nmdcampo = "cddbanco". 
     
              RUN gera_erro(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
         
              RETURN "NOK".

           END.
           
     END.

  Deleta:
  DO TRANSACTION ON ERROR  UNDO Deleta, LEAVE Deleta
                 ON QUIT   UNDO Deleta, LEAVE Deleta
                 ON STOP   UNDO Deleta, LEAVE Deleta
                 ON ENDKEY UNDO Deleta, LEAVE Deleta:

     ContadorDeleta:
     DO aux_contador = 1 TO 10:

        FIND crapagb WHERE crapagb.cddbanco = par_cddbanco AND
                           crapagb.cdageban = par_cdageban
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAILABLE crapagb  THEN
           IF LOCKED crapagb  THEN
               DO:
                  IF aux_contador = 10 THEN
                     DO:
                        ASSIGN aux_cdcritic = 77.
                        LEAVE ContadorDeleta.

                     END.
                     
                  PAUSE 1 NO-MESSAGE.
                  NEXT ContadorDeleta.

               END.
           ELSE
              DO:
                 ASSIGN aux_cdcritic = 15.
                 LEAVE ContadorDeleta.

              END.  
      
        LEAVE ContadorDeleta.

     END. /** Fim do DO ... TO **/

     IF aux_cdcritic > 0   OR
        aux_dscritic <> "" THEN
        UNDO Deleta, LEAVE Deleta.

     DELETE crapagb.
    
     LEAVE Deleta.

  END. /** Fim do DO TRANSACTION **/

  IF aux_cdcritic <> 0 AND 
     aux_dscritic <> "" THEN
     DO:
        ASSIGN par_nmdcampo = "cdageban".

        RUN gera_erro(INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,            /** Sequencia **/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic ).

        RETURN "NOK".

     END.

  RETURN "OK".

END PROCEDURE.


PROCEDURE nova-agencia.

  DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cddepart AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cdageban AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cddbanco AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_dgagenci AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_nmageban AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_cdsitagb AS CHAR                            NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
  DEF VAR aux_contador AS INT                                     NO-UNDO.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_contador = 0.

  EMPTY TEMP-TABLE tt-erro.

  IF CAN-DO("A,E,I",par_cddopcao)  THEN
     DO:
        IF par_cddepart <> 20  AND   /* TI */                    
           par_cddepart <> 8   AND   /* COORD.ADM/FINANCEIRO */  
           par_cddepart <> 9   AND   /* COORD.PRODUTOS       */   
           par_cddepart <> 4   THEN  /* COMPE                */   
           DO:
              ASSIGN aux_cdcritic = 36
                     par_nmdcampo = "cddbanco". 
     
              RUN gera_erro(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
         
              RETURN "NOK".

           END.
           
     END.

  Grava:
  DO TRANSACTION ON ERROR  UNDO Grava, LEAVE Grava
                 ON QUIT   UNDO Grava, LEAVE Grava
                 ON STOP   UNDO Grava, LEAVE Grava
                 ON ENDKEY UNDO Grava, LEAVE Grava:

     ContadorAgb:
     DO aux_contador = 1 TO 10:

        FIND crapagb WHERE crapagb.cddbanco = par_cddbanco AND
                           crapagb.cdageban = par_cdageban 
                           NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crapagb THEN
           DO:
              IF LOCKED crapagb THEN
                 DO:
                    IF aux_contador = 10 THEN
                       DO:
                          ASSIGN aux_cdcritic = 77.
                          LEAVE ContadorAgb.
              
                       END.

                    PAUSE 1 NO-MESSAGE.
                    NEXT ContadorAgb.

                 END.
              ELSE
                 DO:
                    CREATE crapagb.
              
                    ASSIGN crapagb.cddbanco = par_cddbanco
                           crapagb.cdageban = par_cdageban
                           crapagb.dgagenci = par_dgagenci
                           crapagb.nmageban = CAPS(par_nmageban)
                           crapagb.cdoperad = par_cdoperad
                           crapagb.dtmvtolt = par_dtmvtolt
                           crapagb.cdsitagb = par_cdsitagb.  
              
                    LEAVE ContadorAgb.
              
                 END.
           END.
        ELSE
           DO:
              ASSIGN aux_cdcritic = 787. 
        
              LEAVE ContadorAgb.
        
           END. 

     END. /* Fim ContadorAgb */

     LEAVE Grava.
     
  END. /** Fim do DO TRANSACTION **/

  RELEASE crapagb.

  IF aux_cdcritic <> 0  AND 
     aux_dscritic <> "" THEN
     DO:
        ASSIGN par_nmdcampo = "cdageban".

        RUN gera_erro(INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,            /** Sequencia **/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic ).

        RETURN "NOK".

     END.

  RETURN "OK".

END PROCEDURE.




