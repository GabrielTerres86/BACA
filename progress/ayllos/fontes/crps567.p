/*..............................................................................

   Programa: fontes/crps567.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2010                         Ultima atualizacao: 05/11/2018

   Dados referentes ao programa:

   Frequencia: Diario. (Batch)
   Objetivo  : Fonte baseado no crps487
               Tratar arquivo CAF502 - CADASTRO DE BANCOS E AGENCIAS.
               Atualizar tabela crapagb e crapban.

   Alteracoes:  14/03/2013 - verificar a situação da Agência na importação 
                             do CAF502 (Daniele).
                
                13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
                09/04/2014 - Ajuste no tratamento da importacao CAF (Ze). 
                
                18/01/2016 - Quando encontrar agencia de codigo "9999" desativar
                             todas as agencias do banco correspondente
                             (Douglas - Chamado 361760)
                             
                22/09/2016 - Ajuste para não desativar o banco 7 - BNDS, conforme
                             solicitado no chamado 507147. (Kelvin)

			    22/09/2017 - Ajuste para que as agencias do banco 128 permancecam ativos
				 		     (Adriano - SD 72388).
				
				13/06/2018 - Ajustes referente revitalizacao, para que caso ocorra alguma falha
							 no processo, seja gerado log e enviado e-mail para os responsaveis.
							 (SCTASK0013365 - Kelvin)

				03/08/2018 - Ajuste para não desativar as agencias dos bancos 91,130
				 		    (Adriano - REQ0022269).

				05/11/2018 - Ajuste para não desativar as agencias dos bancos 260
						   (Adriano - SCTASK0034371).
						   
..............................................................................*/

{ includes/var_batch.i {1} }
                         
DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.

DEF VAR aux_cdbccxlt AS INT  FORMAT "999"                              NO-UNDO.
DEF VAR aux_nmdbanco AS CHAR FORMAT "x(50)"                            NO-UNDO.
DEF VAR aux_cdageban AS INT  FORMAT "zzz9"                             NO-UNDO.
DEF VAR aux_nmageban AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR aux_cdcidade AS INT  FORMAT "999999"                           NO-UNDO.
DEF VAR aux_cdsitagb AS CHAR FORMAT "x(1)"                             NO-UNDO.
DEF VAR aux_nrcnpjag AS DEC  FORMAT "99999999999999"                   NO-UNDO.

ASSIGN glb_cdprogra = "crps567".
DEF VAR aux_nrispbif AS INT                                            NO-UNDO.
DEF VAR aux_flgativa AS CHAR FORMAT "x(1)"                             NO-UNDO.
DEF  VAR aux_flgexarq  AS LOGICAL                                      NO-UNDO.
DEF VAR aux_dsmoterr  AS CHAR                                          NO-UNDO.
DEF VAR aux_dstextab LIKE craptab.dstextab                             NO-UNDO.

DEF  VAR h-b1wgen0011 AS HANDLE                                  	   NO-UNDO.

ASSIGN aux_flgexarq	= FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.
	
FIND craptab WHERE
	 craptab.cdcooper = 0                 AND       
	 craptab.nmsistem = "CRED"            AND
	 craptab.tptabela = "GENERI"          AND
	 craptab.cdempres = 0                 AND         
	 craptab.cdacesso = "AGE_ATIVAS_CAF"  AND
	 craptab.tpregist = 0                 
	 NO-LOCK NO-ERROR.
				 
ASSIGN aux_dstextab	= craptab.dstextab.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop  THEN DO:
     ASSIGN glb_cdcritic = 651.
     RUN fontes/critic.p.

     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                       " - " + glb_cdprogra + "' --> '"  +
                       glb_dscritic + " >> log/proc_batch.log").
    
     RUN fontes/fimprg.p.
     RETURN.
END.

ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/abbc/*CAF502*".

INPUT STREAM str_1 
             THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

    ASSIGN aux_nmarqdat = "integra/CAF502" +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999").

    UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                      aux_nmarqdat + " 2> /dev/null").

    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

    INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO.

    /* Pula Header */ 
    IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

    IF SUBSTR(aux_setlinha,8,6) <> "CAF502" THEN DO: 
		
	   ASSIGN aux_dsmoterr = "Arquivo nao correspondente ao CAF502 (Problemas no HEADER do arquivo)".	   
	   
	   RUN enviar_email_erro(aux_dsmoterr).
		
       ASSIGN glb_cdcritic = 173.
       RUN fontes/critic.p.

       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").

       RUN fontes/fimprg.p.
       RETURN.       
    END.

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

        /*  Verifica se eh final do Arquivo  */
        IF   INT(SUBSTR(aux_setlinha,1,1)) = 9  THEN
             LEAVE.

        ASSIGN aux_cdbccxlt = INTE(SUBSTR(aux_setlinha,1,3)) 
               aux_nmdbanco = SUBSTR(aux_setlinha,8,50) 
               aux_cdageban = INTE(SUBSTR(aux_setlinha,4,4)) 
               aux_nmageban = SUBSTR(aux_setlinha,58,30)
               aux_cdcidade = INTE(SUBSTR(aux_setlinha,102,6))
               aux_cdsitagb = SUBSTR(aux_setlinha,148,1)
                   aux_nrcnpjag = DECI(SUBSTR(aux_setlinha,88,14))
                   aux_nrispbif = INTE(SUBSTR(aux_setlinha,222,7))
                   aux_flgativa = SUBSTR(aux_setlinha,221,1).

        IF   aux_cdbccxlt = 0   THEN DO: 
             ASSIGN glb_dscritic = "Arquivo importado - " + 
                                   aux_nmarqdat + " - esta corrompido."
					aux_dsmoterr = glb_dscritic.

			 RUN enviar_email_erro(aux_dsmoterr).

             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> log/proc_batch.log").

             RUN fontes/fimprg.p.
             RETURN.                
         END.

         DO WHILE TRUE:    

            FIND crapban WHERE crapban.cdbccxlt = aux_cdbccxlt 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crapban  THEN DO:
                IF  LOCKED crapban THEN DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                      
               
                  END.
           
                            IF aux_flgativa = "S" THEN
                               DO:
                CREATE crapban.
                ASSIGN crapban.cdbccxlt = aux_cdbccxlt.
                                ASSIGN crapban.nrispbif = aux_nrispbif.
             END.
 
                     END.
                IF aux_flgativa = "S" THEN
                   DO:
            ASSIGN crapban.nmresbcc = aux_nmdbanco
                   crapban.nmextbcc = aux_nmdbanco
                   crapban.dtmvtolt = glb_dtmvtolt
                   crapban.cdoperad = glb_cdoperad.
            VALIDATE crapban.
                  END.
            LEAVE.
 
         END.    /** Fim do WHILE TRUE **/               
        
         DO WHILE TRUE:      
 
            FIND crapagb WHERE crapagb.cdageban = aux_cdageban AND
                               crapagb.cddbanco = aux_cdbccxlt
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
 
            IF  NOT AVAIL crapagb THEN DO:
                IF  LOCKED crapagb THEN DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                END.
                           
                CREATE crapagb.
                ASSIGN crapagb.cdageban = aux_cdageban
                       crapagb.cddbanco = aux_cdbccxlt
                       crapagb.nmageban = aux_nmageban 
                       crapagb.cdcidade = aux_cdcidade                
                       crapagb.nrcnpjag = aux_nrcnpjag
                       crapagb.cdsitagb = aux_cdsitagb 
                       crapagb.dtmvtolt = glb_dtmvtolt 
                       crapagb.cdoperad = glb_cdoperad.
                VALIDATE crapagb.
            END.        
            ELSE DO:
			    /*Alterar a situacao apenas para agencias que
				  nao estejam parametrizadas.*/
                IF   crapagb.cdsitagb <> aux_cdsitagb              AND
                     NOT CAN-DO(aux_dstextab,STRING(aux_cdbccxlt)) THEN 
                     ASSIGN crapagb.cdsitagb = aux_cdsitagb
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.

                IF   crapagb.nrcnpjag <> aux_nrcnpjag   THEN
                     ASSIGN crapagb.nrcnpjag = aux_nrcnpjag
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.

                IF   crapagb.cdcidade <> aux_cdcidade   THEN 
                     ASSIGN crapagb.cdcidade = aux_cdcidade
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.

                IF   crapagb.nmageban <> aux_nmageban   THEN   
                     ASSIGN crapagb.nmageban = aux_nmageban
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.
                        
            END.    

                         
            LEAVE.

         END. /*** Fim do DO WHILE TRUE ***/
         
            /*Alterar a situacao apenas para agencias que
			  nao estejam parametrizadas.*/
            IF NOT CAN-DO(aux_dstextab,STRING(aux_cdbccxlt)) THEN
            DO:
				 /* Se a agencia em questao eh "9999" */
				 IF aux_cdageban = 9999 THEN
				 DO:
					 FOR EACH crapagb WHERE crapagb.cddbanco = aux_cdbccxlt
									  EXCLUSIVE-LOCK:
						
                 /* desativar todas as agencias do banco */
                 ASSIGN crapagb.cdsitagb = "N".

				END.
			END.
               
    END.                 
            
    END.                 

    UNIX SILENT VALUE("mv " + aux_nmarqdat + " salvar").

    INPUT STREAM str_2 CLOSE.

	ASSIGN aux_flgexarq = TRUE.
	
END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

IF aux_flgexarq = FALSE THEN DO:
    ASSIGN aux_dsmoterr = "Arquivo nao foi localizado em: " + aux_nmarquiv.
	
	UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> Arquivo nao encontrado: CAF502 - Cadastro de bancos e agencias'"  +
                            " >> log/proc_batch.log").	
		
	RUN enviar_email_erro(aux_dsmoterr).
	
END.

PROCEDURE enviar_email_erro:
    
    DEF  INPUT PARAM par_dsmoterr AS CHAR                           NO-UNDO.    
	
	FIND FIRST crapprm WHERE crapprm.cdcooper = 0 
	                     AND crapprm.cdacesso = 'PRM_EMA_CAF501ECAF502'
						 AND crapprm.nmsistem = 'CRED' NO-LOCK NO-ERROR.
	
	/* envio de email */ 
	RUN sistema/generico/procedures/b1wgen0011.p
	  PERSISTENT SET h-b1wgen0011.

	RUN enviar_email_completo IN h-b1wgen0011 (INPUT glb_cdcooper,
											   INPUT glb_cdprogra,
											   INPUT "CECRED<cecred@cecred.coop.br>",
											   INPUT crapprm.dsvlrprm,
											   INPUT "CAF502 - Cadastro de bancos e agencias - Problemas no processo",
											   INPUT "",			
											   INPUT "",
											   INPUT "\nO programa crps567.p nao conseguiu efetuar o cadastramento dos bancos e agencias."+											         
													 "\nMotivo: " + par_dsmoterr +													 
													 "\nNecessario efetuar o processo manualmente, atraves da tela PRCCTL.",
											   INPUT TRUE).
	
	
	 DELETE PROCEDURE h-b1wgen0011.
	 
END PROCEDURE. /* enviar_email_erro*/


RUN fontes/fimprg.p.                   

/*............................................................................*/

