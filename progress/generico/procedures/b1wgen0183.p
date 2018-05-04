
/*..............................................................................

  Programa: generico/procedures/b1wgen0183.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Tiago
  Data    : Fevereiro/14                           Ultima alteracao: 08/03/2018

  Objetivo  : Procedures referentes a tela HRCOMP.

  Alteracao : 25/07/2014 - Incluido opcao TODAS para alteração de horarios
                           para todas cooperativas de uma vez so 
                           (Tiago/Elton SD172634).
                           
			  10/06/2016 - Alteracao para reagendar o JOB (DEBSIC,DEBNET,688)
			               (Tiago/Thiago SD402010)             
						           
              13/06/2016 - Incluir flgativo na busca das cooperativas na PROCEDURE
                           grava_dados (Lucas Ranghetti #462237)

	            25/08/2016 - Alteracao para reagendar o JOB (DEBSIC,DEBNET) e
			                     nao permitir alterar o horario para antes do horario
						               atual (Tiago/Thiago #493693).
                           
              21/09/2016 - Na procedure grava_dados incluir tratamento para caso 
                           alterar a cooperativa cecred e escolher o programa
                           "DEVOLUCAO DOC" - Melhoria 316 (Lucas Ranghetti #525623)
			  10/06/2016 - Alteracao para reagendar o JOB (DEBSIC,DEBNET,688)
			               (Tiago/Thiago SD402010)             
						           
              13/06/2016 - Incluir flgativo na busca das cooperativas na PROCEDURE
                           grava_dados (Lucas Ranghetti #462237)

	          25/08/2016 - Alteracao para reagendar o JOB (DEBSIC,DEBNET) e
			               nao permitir alterar o horario para antes do horario
						   atual (Tiago/Thiago #493693).

			  24/10/2016 - Ajustes referentes a melhoria349 (Tiago/Elton).
              
              02/12/2016 - Alterado campo dsdepart para cddepart.
                           PRJ341 - BANCENJUD (Odirlei-AMcom)   
                           
            17/10/2017 - Formatado o numero da coop de uma forma diferente qdo 
                         for reagendar o job na procedure reagenda_job pois
                         nao estava encontrando o job fazendo com que as 
                         alteracoes na HRCOMP nao surtissem o efeito desejado
                         (Tiago #753784).

            22/01/2018 - Ajustado para aplicar as mesmas regras da DEBSIC ao procedimento
                         DEBBAN. PRJ406 - FGTS(Odirlei-AMcom)

		    08/03/2018 - Removida DEVOLUCAO VLB - COMPE Sessao Unica (Diego).

............................................................................ */

{ sistema/generico/includes/b1wgen0183tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }   
{ sistema/generico/includes/var_oracle.i }

PROCEDURE busca_dados:

    DEF INPUT  PARAM par_cdcooper    LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    LIKE crapope.cdagenci              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_idorigem    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS   DATE                          NO-UNDO.
    DEF INPUT  PARAM par_cdcoopex    AS   INT                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-processos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE  aux_cdcritic AS    INTEGER                         NO-UNDO.
    DEFINE VARIABLE  aux_dscritic AS    CHARACTER                       NO-UNDO.


    ASSIGN  aux_cdcritic = 0
            aux_dscritic = "".


    /*tratamento para quando for mudanca de horario
      para todas as cooperativas*/
    IF  par_cdcoopex = 0 THEN
        par_cdcoopex = 1. /*assume como viacredi*/

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-craphec.
    EMPTY TEMP-TABLE tt-processos.

    RUN cria_reg_proc(INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_cddepart,
                      INPUT par_idorigem,
                      INPUT par_dtmvtolt,
                      INPUT-OUTPUT TABLE tt-processos,
                      OUTPUT TABLE tt-erro).

    FOR EACH craphec WHERE craphec.cdcooper = par_cdcoopex NO-LOCK:
        CREATE tt-craphec.
        BUFFER-COPY craphec TO tt-craphec.
    END.
    
    FIND FIRST tt-craphec WHERE tt-craphec.cdcooper = par_cdcoopex 
                                NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(tt-craphec) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Erro na consulta dos dados".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.


    FOR EACH tt-craphec NO-LOCK:

        FIND tt-processos WHERE tt-processos.nmproces = tt-craphec.dsprogra
                                NO-LOCK NO-ERROR.

        IF  AVAIL(tt-processos) THEN
            DO:
                ASSIGN tt-processos.ageinihr = 
                        INTE( SUBSTR(STRING(tt-craphec.hriniexe,"HH:MM"),1,2) )
                       tt-processos.ageinimm = 
                        INTE( SUBSTR(STRING(tt-craphec.hriniexe,"HH:MM"),4,2) )
                       tt-processos.hrageini = 
                        SUBSTR(STRING(tt-craphec.hriniexe,"HH:MM"),1,2) + 
                        ":" +
                        SUBSTR(STRING(tt-craphec.hriniexe,"HH:MM"),4,2)
                       tt-processos.agefimhr = 
                        INTE( SUBSTR(STRING(tt-craphec.hrfimexe,"HH:MM"),1,2) )
                       tt-processos.agefimmm = 
                        INTE( SUBSTR(STRING(tt-craphec.hrfimexe,"HH:MM"),4,2) )
                       tt-processos.hragefim = 
                        SUBSTR(STRING(tt-craphec.hrfimexe,"HH:MM"),1,2) + 
                        ":" +
                        SUBSTR(STRING(tt-craphec.hrfimexe,"HH:MM"),4,2)
                       tt-processos.flgativo = tt-craphec.flgativo.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Erro na consulta dos dados".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 0,
                               INPUT 1,     /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
    
                RETURN "NOK".
            END.
    END.


    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega_cooperativas:

    DEF INPUT  PARAM par_cdcooper    LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    LIKE crapope.cdagenci              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_idorigem    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS   DATE                          NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-coop.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE  aux_cdcritic AS    INTEGER                         NO-UNDO.
    DEFINE VARIABLE  aux_dscritic AS    CHARACTER                       NO-UNDO.


    ASSIGN  aux_cdcritic = 0
            aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-coop.

    CREATE tt-coop.
    ASSIGN tt-coop.cdcooper = 0
           tt-coop.nmrescop = "TODAS".

    FOR EACH crapcop WHERE crapcop.flgativo = TRUE 
                     NO-LOCK BY crapcop.dsdircop:

        CREATE tt-coop.
        ASSIGN tt-coop.cdcooper = crapcop.cdcooper
               tt-coop.nmrescop = crapcop.nmrescop.

    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE grava_dados:

    DEF INPUT  PARAM par_cdcooper    LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    LIKE crapope.cdagenci              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_idorigem    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS   DATE                          NO-UNDO.
    DEF INPUT  PARAM par_cdcoopex    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dsprogra    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_flgativo    AS   LOGICAL                       NO-UNDO.
    DEF INPUT  PARAM par_ageinihr    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_ageinimm    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_agefimhr    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_agefimmm    AS   INTE                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR aux_hriniexe    AS   INTEGER                                NO-UNDO.
    DEF VAR aux_hrfimexe    AS   INTEGER                                NO-UNDO.
    DEF VAR aux_cdcritic    AS   INTEGER                                NO-UNDO.
    DEF VAR aux_dscritic    AS   CHAR                                   NO-UNDO.      

    DEF VAR aux_flgtodas    AS   LOGICAL                                NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    /* Validacoes */

    /* indica que a gravacao vai ser para 
       todas coops ou nao*/
    IF par_cdcoopex = 0 THEN 
       ASSIGN aux_flgtodas = TRUE.
    ELSE
       ASSIGN aux_flgtodas = FALSE.

    IF  par_ageinihr = 00 AND
        par_ageinimm = 00 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O horario de inicio deve ser maior que zero.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    IF  par_agefimhr = 00 AND
        par_agefimmm = 00 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O horario final deve ser maior que zero.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.


    IF  (par_ageinihr > 23  OR
         par_ageinimm > 59) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Horario de inicio errado.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    IF  (par_agefimhr > 23 OR
         par_agefimmm > 59) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Horario final errado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.


    ASSIGN aux_hriniexe = (par_ageinihr * 3600) + (par_ageinimm * 60)
           aux_hrfimexe = (par_agefimhr * 3600) + (par_agefimmm * 60).


    /*horario final nao pode ser menor ou igual ao inicial*/
    IF  aux_hriniexe >= aux_hrfimexe THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Horario final deve ser maior que horario inicial.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
    /* Fim Validacoes */

    TRANS_HEC:
    DO TRANSACTION ON ENDKEY UNDO TRANS_HEC, LEAVE TRANS_HEC
                   ON ERROR  UNDO TRANS_HEC, LEAVE TRANS_HEC
                   ON STOP   UNDO TRANS_HEC, LEAVE TRANS_HEC:

    /*gravar para todas coops*/
    IF  aux_flgtodas = TRUE THEN
        DO:

            FOR EACH crapcop WHERE crapcop.flgativo = TRUE NO-LOCK:
            
                /* Para a cecred somente alteramos o DEVOLUCAO DOC */
                IF  crapcop.cdcooper = 3 AND 
                    par_dsprogra <> "DEVOLUCAO DOC" THEN
                    NEXT.
                               
                /*Valida sequencia da execucao dos processos para nao deixar cadastrar
                  horarios de forma que altere essa sequencia de execucao. */
                RUN valida_seq_execucao(INPUT crapcop.cdcooper,
                                        INPUT par_dsprogra,
                                        INPUT aux_hriniexe,
                                        INPUT aux_hrfimexe,
                                        OUTPUT TABLE tt-erro).

                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL(tt-erro) THEN
                    RETURN "NOK".

                FIND craphec WHERE craphec.cdcooper = crapcop.cdcooper  AND
                                   craphec.dsprogra = par_dsprogra  
                                   EXCLUSIVE-LOCK NO-ERROR.

                IF  AVAIL(craphec) THEN
                    DO: 

                        IF  craphec.hriniexe <> aux_hriniexe THEN
                            DO:   
                                UNIX SILENT
                                      VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                                      " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                      "Operador " + par_cdoperad                        +
                                      " alterou o campo Horario de inicio "             +
                                      " do Arquivo " + par_dsprogra + " da Coop "       +
                                      crapcop.nmrescop + " de "                         +
                                      TRIM(STRING(craphec.hriniexe,"HH:MM")) + " para  " +
                                      TRIM(STRING(aux_hriniexe,"HH:MM")) +
                                      " >> /usr/coop/cecred/log/hrcomp.log"). 
                            END.

                        IF  craphec.hrfimexe <> aux_hrfimexe THEN
                            DO:
                                UNIX SILENT
                                      VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                                      " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                      "Operador " + par_cdoperad                        +
                                      " alterou o campo Horario de fim " +
                                      " do Arquivo " + par_dsprogra + " da Coop "       +
                                      crapcop.nmrescop + " de "                         +
                                      TRIM(STRING(craphec.hrfimexe,"HH:MM")) + " para  " +
                                      TRIM(STRING(aux_hrfimexe,"HH:MM")) +
                                      " >> /usr/coop/cecred/log/hrcomp.log").
                            END.

                        IF  craphec.flgativo <> par_flgativo THEN
                            DO:
                                UNIX SILENT
                                      VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                                      " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                      "Operador " + par_cdoperad                        +
                                      " alterou o campo Ativo " +
                                      " do Arquivo " + par_dsprogra + " da Coop "       +
                                      crapcop.nmrescop + " de "                         +
                                      STRING(craphec.flgativo,"Sim/Nao")  + " para  "   +
                                      STRING(par_flgativo,"Sim/Nao")                    +
                                      " >> /usr/coop/cecred/log/hrcomp.log").
                            END.  

						IF (craphec.cdprogra = "CRPS688" OR 
						    craphec.cdprogra = "DEBNET"  OR 
						    craphec.cdprogra = "DEBSIC"  OR 
						    craphec.cdprogra = "DEBBAN") AND
						    aux_hriniexe < TIME THEN
						   DO:
								ASSIGN aux_cdcritic = 0
									   aux_dscritic = "O horario do reagendamento deve ser superior a hora atual.".
    
								RUN gera_erro (INPUT par_cdcooper,
										       INPUT par_cdagenci,
											   INPUT 0,
											   INPUT 1,     /** Sequencia **/
											   INPUT aux_cdcritic,
											   INPUT-OUTPUT aux_dscritic).
    
								RETURN "NOK".
						   END.


                        ASSIGN  craphec.hriniexe =   (par_ageinihr * 3600) 
                                                   + (par_ageinimm * 60)
                                craphec.hrfimexe =   (par_agefimhr * 3600) 
                                                   + (par_agefimmm * 60)
                                craphec.flgativo = par_flgativo.

                        VALIDATE craphec.

    					IF  craphec.cdprogra = "CRPS688" OR 
						    craphec.cdprogra = "DEBNET"  OR 
						    craphec.cdprogra = "DEBSIC"  OR 
						    craphec.cdprogra = "DEBBAN" THEN
    						DO:                                
                                RUN reagenda_job(INPUT crapcop.cdcooper
                								                ,INPUT craphec.cdprogra
                                                ,INPUT craphec.dsprogra
                                                ,INPUT par_dtmvtolt
                                                ,INPUT par_ageinihr
                                                ,INPUT par_ageinimm
                                                ,OUTPUT aux_dscritic).

                                IF aux_dscritic <> '' THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Problema na gravacao dos dados.".
    
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT 0,
                                                   INPUT 1,     /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
    
                                    RETURN "NOK".
                    END.
    						END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Problema na gravacao dos dados.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".

                    END.


            END.

        END.
    ELSE
        DO:
            IF  par_cdcoopex = 3 AND 
                par_dsprogra <> "DEVOLUCAO DOC" THEN
                DO:
                    ASSIGN aux_cdcritic = 0
    								       aux_dscritic = "Cooperativa nao permite alteracao.".
    
    							  RUN gera_erro (INPUT par_cdcooper,
    							  			         INPUT par_cdagenci,
    							  			         INPUT 0,
    							  			         INPUT 1,     /** Sequencia **/
    							  			         INPUT aux_cdcritic,
    							  			         INPUT-OUTPUT aux_dscritic).
                    
    							  RETURN "NOK". 
                END.
            
            /*Valida sequencia da execucao dos processos para nao deixar cadastrar
              horarios de forma que altere essa sequencia de execucao. */
            RUN valida_seq_execucao(INPUT par_cdcoopex,
                                    INPUT par_dsprogra,
                                    INPUT aux_hriniexe,
                                    INPUT aux_hrfimexe,
                                    OUTPUT TABLE tt-erro).
    
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAIL(tt-erro) THEN
                RETURN "NOK".
    
    
            FIND craphec WHERE craphec.cdcooper = par_cdcoopex  AND
                               craphec.dsprogra = par_dsprogra  
                               EXCLUSIVE-LOCK NO-ERROR.
    
            IF  AVAIL(craphec) THEN
                DO:     
    
                    FIND crapcop WHERE crapcop.cdcooper = par_cdcoopex
                                       NO-LOCK NO-ERROR.
    
                    IF  NOT AVAIL(crapcop) THEN
                        RETURN "NOK".
    
                    IF  craphec.hriniexe <> aux_hriniexe THEN
                        DO:   
                            UNIX SILENT
                                  VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                                  " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                  "Operador " + par_cdoperad                        +
                                  " alterou o campo Horario de inicio "             +
                                  " do Arquivo " + par_dsprogra + " da Coop "       +
                                  crapcop.nmrescop + " de "                         +
                                  TRIM(STRING(craphec.hriniexe,"HH:MM")) + " para  " +
                                  TRIM(STRING(aux_hriniexe,"HH:MM")) +
                                  " >> /usr/coop/cecred/log/hrcomp.log"). 
                        END.
    
                    IF  craphec.hrfimexe <> aux_hrfimexe THEN
                        DO:
                            UNIX SILENT
                                  VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                                  " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                  "Operador " + par_cdoperad                        +
                                  " alterou o campo Horario de fim " +
                                  " do Arquivo " + par_dsprogra + " da Coop "       +
                                  crapcop.nmrescop + " de "                         +
                                  TRIM(STRING(craphec.hrfimexe,"HH:MM")) + " para  " +
                                  TRIM(STRING(aux_hrfimexe,"HH:MM")) +
                                  " >> /usr/coop/cecred/log/hrcomp.log").
                        END.
    
                    IF  craphec.flgativo <> par_flgativo THEN
                        DO:
                            UNIX SILENT
                                  VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                                  " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                  "Operador " + par_cdoperad                        +
                                  " alterou o campo Ativo " +
                                  " do Arquivo " + par_dsprogra + " da Coop "       +
                                  crapcop.nmrescop + " de "                         +
                                  STRING(craphec.flgativo,"Sim/Nao")  + " para  "   +
                                  STRING(par_flgativo,"Sim/Nao")                    +
                                  " >> /usr/coop/cecred/log/hrcomp.log").
                        END.  
    
					IF (craphec.cdprogra = "CRPS688" OR 
						craphec.cdprogra = "DEBNET"  OR 
						craphec.cdprogra = "DEBSIC"  OR 
						craphec.cdprogra = "DEBBAN") AND
						aux_hriniexe < TIME THEN
						DO:
							ASSIGN aux_cdcritic = 0
									aux_dscritic = "O horario do reagendamento deve ser superior a hora atual.".
    
							RUN gera_erro (INPUT par_cdcooper,
										    INPUT par_cdagenci,
											INPUT 0,
											INPUT 1,     /** Sequencia **/
											INPUT aux_cdcritic,
											INPUT-OUTPUT aux_dscritic).
    
							RETURN "NOK".
						END.


                    ASSIGN  craphec.hriniexe =   (par_ageinihr * 3600) 
                                               + (par_ageinimm * 60)
                            craphec.hrfimexe =   (par_agefimhr * 3600) 
                                               + (par_agefimmm * 60)
                            craphec.flgativo = par_flgativo.
    
                    VALIDATE craphec.
    
    					IF craphec.cdprogra = "CRPS688" OR 
						   craphec.cdprogra = "DEBNET"  OR 
						   craphec.cdprogra = "DEBSIC"  OR 
						   craphec.cdprogra = "DEBBAN"  THEN
    					DO:                           

                            RUN reagenda_job(INPUT craphec.cdcooper
							                              ,INPUT craphec.cdprogra
                                            ,INPUT craphec.dsprogra
                                            ,INPUT par_dtmvtolt
                                            ,INPUT par_ageinihr
                                            ,INPUT par_ageinimm
                                            ,OUTPUT aux_dscritic).

    						IF aux_dscritic <> '' THEN
    						DO:
    							ASSIGN aux_cdcritic = 0
    								   aux_dscritic = "Problema na gravacao dos dados.".
    
    							RUN gera_erro (INPUT par_cdcooper,
    										   INPUT par_cdagenci,
    										   INPUT 0,
    										   INPUT 1,     /** Sequencia **/
    										   INPUT aux_cdcritic,
    										   INPUT-OUTPUT aux_dscritic).
    
    							RETURN "NOK".
                END.
                END.
                    END.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Problema na gravacao dos dados.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT 0,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
    
                    RETURN "NOK".
    
                END.
        END.
    END. /* fim TRANS_HEC*/

    RETURN "OK".

END PROCEDURE.

PROCEDURE acesso_opcao:

    DEF INPUT  PARAM par_cdcooper    AS  INTEGER                        NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    AS  INTEGER                        NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS  INTEGER                        NO-UNDO.
    DEF INPUT  PARAM par_cddopcao    AS  CHARACTER                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE  aux_cdcritic    AS  INTEGER                        NO-UNDO.
    DEFINE VARIABLE  aux_dscritic    AS  CHARACTER                      NO-UNDO.

    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    IF  par_cddepart <>  4    AND   /* COMPE */
        par_cddepart <> 20    AND   /* TI    */
        par_cddopcao <> "C"   THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Permissao de acesso negada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.
        

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_seq_execucao:

    DEF INPUT PARAM par_cdcooper    LIKE crapcop.cdcooper               NO-UNDO.
    DEF INPUT PARAM par_dsprogra    AS   CHAR                           NO-UNDO.
    DEF INPUT PARAM par_hriniexe    AS   INTEGER                        NO-UNDO.
    DEF INPUT PARAM par_hrfimexe    AS   INTEGER                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabhec FOR craphec.

    DEF VAR aux_cdcritic    AS  INTE                                    NO-UNDO.
    DEF VAR aux_dscritic    AS  CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.


    CASE par_dsprogra:

        WHEN "DEVOLUCAO DIURNA" THEN
            DO:
                FIND crabhec WHERE crabhec.cdcooper  = par_cdcooper        AND
                                   crabhec.dsprogra  = "DEVOLUCAO NOTURNA" AND
                                  (crabhec.hriniexe <= par_hriniexe OR
                                   crabhec.hrfimexe <= par_hrfimexe)
                                   NO-LOCK NO-ERROR.

                IF  AVAIL(crabhec) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Devolucao Diurna deve rodar antes da Devolucao Noturna.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".

                    END.
            END.

        WHEN "DEVOLUCAO FRAUDES E IMPEDIMENTOS" THEN
            DO:
                FIND crabhec WHERE crabhec.cdcooper  = par_cdcooper       AND
                                   crabhec.dsprogra  = "DEVOLUCAO DIURNA" AND
                                  ((crabhec.hriniexe >= par_hriniexe   OR
                                   crabhec.hrfimexe >= par_hrfimexe)   OR
                                   crabhec.hrfimexe >= par_hriniexe)
                                   NO-LOCK NO-ERROR.

                IF  AVAIL(crabhec) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Devolucao Fraudes e Impedimentos deve rodar apos Devolucao Diurna.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".

                    END.
            END.

        WHEN "REMCOB" THEN
            DO:
            
                FIND crabhec WHERE crabhec.cdcooper  = par_cdcooper       AND
                                   crabhec.dsprogra  = "ARQUIVOS NOTURNOS" AND
                                  (crabhec.hriniexe >= par_hriniexe OR
                                   crabhec.hrfimexe >= par_hrfimexe)
                                   NO-LOCK NO-ERROR.
    
                IF  AVAIL(crabhec) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "REMCOB deve rodar apos Arquivos Noturnos.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".
                    END.

                /*se for menor ou igual a 18:31*/
                IF  par_hriniexe <= ((18 * 3600)+(31 * 60)) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "REMCOB deve rodar apos as 18:31.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".
                    END. 
            END.

        WHEN "DEBNET VESPERTINA" THEN
            DO:
                FIND crabhec WHERE crabhec.cdcooper  = par_cdcooper       AND
                                   crabhec.dsprogra  = "DEBNET NOTURNA" AND
                                  (crabhec.hriniexe <= par_hriniexe OR
                                   crabhec.hrfimexe <= par_hrfimexe)
                                   NO-LOCK NO-ERROR.
    
                IF  AVAIL(crabhec) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "DEBNET VESPERTINA deve rodar antes do DEBNET NOTURNA.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".
                    END.
            END.

        WHEN "DEBNET NOTURNA" THEN
            DO:
                FIND crabhec WHERE crabhec.cdcooper  = par_cdcooper       AND
                                   crabhec.dsprogra  = "DEBNET VESPERTINA" AND
                                   crabhec.hrfimexe >= par_hriniexe
                                   NO-LOCK NO-ERROR.
    
                IF  AVAIL(crabhec) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "DEBNET NOTURNA deve rodar depois do DEBNET VESPERTINA.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".
                    END.

                FIND crabhec WHERE crabhec.cdcooper  = par_cdcooper       AND
                                   crabhec.dsprogra  = "TAA E INTERNET" AND
                                   crabhec.hrfimexe <= par_hriniexe 
                                   NO-LOCK NO-ERROR.
    
                IF  AVAIL(crabhec) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "DEBNET NOTURNA deve rodar antes do TAA E INTERNET.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".
                    END.
            END.

        WHEN "TAA E INTERNET" THEN
            DO:
                FIND crabhec WHERE crabhec.cdcooper  = par_cdcooper       AND
                                   crabhec.dsprogra  = "DEBNET NOTURNA" AND
                                  (crabhec.hriniexe >= par_hriniexe OR
                                   crabhec.hrfimexe >= par_hrfimexe)
                                   NO-LOCK NO-ERROR.
    
                IF  AVAIL(crabhec) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "TAA E INTERNET deve rodar depois do DEBNET NOTURNA.".
    
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".
                    END.
            END.


    END CASE.

    RETURN "OK".
END PROCEDURE.

PROCEDURE cria_reg_proc:

    DEF INPUT  PARAM par_cdcooper    LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    LIKE crapope.cdagenci              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS   INT                          NO-UNDO.
    DEF INPUT  PARAM par_idorigem    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS   DATE                          NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-processos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEFINE VARIABLE  aux_cdcritic    AS  INTEGER                        NO-UNDO.
    DEFINE VARIABLE  aux_dscritic    AS  CHARACTER                      NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-processos.
    EMPTY TEMP-TABLE tt-erro.

    FOR EACH craphec WHERE craphec.cdcooper = 1 NO-LOCK:
        CREATE tt-processos.
        ASSIGN tt-processos.nmproces = craphec.dsprogra
               tt-processos.hrageini = "00:00"
               tt-processos.hragefim = "00:00"
               tt-processos.nrseqexe = craphec.nrseqexe.
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE reagenda_job:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper    NO-UNDO.
	  DEF INPUT PARAM par_cdprogra    LIKE    craphec.cdprogra    NO-UNDO.
    DEF INPUT PARAM par_dsprogra    LIKE    craphec.dsprogra    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    LIKE    crapdat.dtmvtolt    NO-UNDO.
    DEF INPUT PARAM par_ageinihr    AS      INTEGER             NO-UNDO.
    DEF INPUT PARAM par_ageinimm    AS      INTEGER             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic   LIKE    crapcri.dscritic    NO-UNDO.


    DEF VAR         vr_jobname      AS      CHAR                NO-UNDO.

    ASSIGN par_dscritic = "".
    
    /*M349 DEBNET e DEBSIC Passam a ter 3 execucoes diarias
      uma logo apos o processo uma durante a tarde e uma a noite
      por este motivo o JOB que se chamava apenas _DIA agora foi 
      criado mais um com _NOT pra noite*/      
      
    /* 23/01/2017 - PRJ406 - Alterado pois DEBNET E DEBSIC nao rodaram assim 
       que concluir o processo, ira respeitar os horarios configurados da craphec 
       para isso utilizara o nome diurna(1-execucao),vespertino e noturno */  
       
    IF  par_dsprogra MATCHES '*VESPERTINA*' THEN
    DO:
      ASSIGN vr_jobname = par_cdprogra + "_" + TRIM(STRING(par_cdcooper,"99")) + "\_VES". 
    END.
    ELSE     
    DO:
      IF  par_dsprogra MATCHES '*NOTURNA*' THEN
          DO:
            ASSIGN vr_jobname = par_cdprogra + "_" + TRIM(STRING(par_cdcooper,"99")) + "\_NOT". 
          END.
      ELSE IF  par_dsprogra MATCHES '*DIURNA*' THEN
          DO:
            ASSIGN vr_jobname = par_cdprogra + "_" + TRIM(STRING(par_cdcooper,"99")) + "\_DIA". 
          END.
      ELSE
          DO:
            ASSIGN vr_jobname = par_cdprogra + "_" + TRIM(STRING(par_cdcooper,"99")) + "\_DIA". /*No caso do CRPS688 continua como esta 2 exec por dia*/
          END.
    END.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_reagenda_job
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT vr_jobname, /* jobname */
                                          INPUT par_dtmvtolt, /* data */
                                          INPUT par_ageinihr, /* hora  */
                                          INPUT par_ageinimm, /* minuto */
                                          OUTPUT "").         /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_reagenda_job
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


    ASSIGN par_dscritic = pc_reagenda_job.pr_dscritic
                          WHEN pc_reagenda_job.pr_dscritic <> ?.

    IF par_dscritic <> "" THEN
       RETURN "NOK".

    RETURN "OK".
END PROCEDURE.
