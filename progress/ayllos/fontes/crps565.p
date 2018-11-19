/*..............................................................................

   Programa: fontes/crps565.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2010                         Ultima atualizacao: 05/11/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps473
               Tratar arquivo CAF502 - CADASTRO DE BANCOS E AGENCIAS.
               Atualizar tabelas crapagb e crapban.

   Alteracoes: 07/07/2010 - Acerto para ler arquivo com referencia na CECRED
                            (Guilherme).
                            
               14/03/2013 - verificar a situação da Agência na importação 
                            do CAF502 (Daniele).
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               09/04/2014 - Ajuste no tratamento da importacao CAF (Ze).
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa) 
                           
               08/04/2015 - Alteração no cadastro/consulta de bancos colocando 
                            o ISPB como chave SD271603 (Vanessa)

               18/01/2016 - Quando encontrar agencia de codigo "9999" desativar
                            todas as agencias do banco correspondente
                            (Douglas - Chamado 361760)

               22/09/2016 - Ajuste para não desativar o banco 7 - BNDS, conforme
                            solicitado no chamado 507147. (Kelvin)

			   06/09/2017 - Ajuste para que as agencias do banco 128 permancecam ativos
						   (Adriano - SD 72388).

			   03/08/2018 - Ajuste para não desativar as agencias dos bancos 91,130
						   (Adriano - REQ0022269).
				
			   05/11/2018 - Ajuste para não desativar as agencias dos bancos 260
						   (Adriano - SCTASK0034371).
						   

..............................................................................*/

{ includes/var_online.i} 
                         
DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
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
DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR par_numipusr AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR aux_dstextab LIKE craptab.dstextab                             NO-UNDO.

DEF VAR aux_nrispbif AS INT                                            NO-UNDO.
DEF VAR aux_flgativa AS CHAR FORMAT "x(1)"                             NO-UNDO.

ASSIGN glb_cdprogra = "crps565"
       glb_flgbatch = FALSE.

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

/*............................................................................*/
FOR EACH crapcop
   WHERE crapcop.cdcooper = 3 NO-LOCK:

    ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

               
    ASSIGN aux_nmarqlog = "log/prcctl_" +
                          STRING(YEAR(glb_dtmvtolt),"9999") + 
                          STRING(MONTH(glb_dtmvtolt),"99") + 
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/abbc/*CAF502*".
     
    INPUT STREAM str_1 
               THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
                                                  
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
        SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .
    
        ASSIGN aux_nmarqdat = aux_dscooper + "integra/CAF502" +
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
           ASSIGN glb_cdcritic = 173.
           RUN fontes/critic.p.
         
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Coop:" + STRING(crapcop.cdcooper,"99") +
                              " - Processar: CAF502" +
                              " - " + glb_cdprogra + "' --> '"  +
                              glb_dscritic + " >> " + aux_nmarqlog).
        
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
                                       aux_nmarqdat + " - esta corrompido.".

                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - Coop:" + STRING(crapcop.cdcooper,"99") +
                                   " - Processar: CAF502" +
                                   " - " + glb_cdprogra + "' --> '"  +
                                   glb_dscritic + " >> " + aux_nmarqlog).

                 RUN fontes/fimprg.p.
                 RETURN.                
            END.
            
            DO  WHILE TRUE:    
                FIND crapban WHERE crapban.cdbccxlt = aux_cdbccxlt 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                                       
                IF   NOT AVAIL crapban  THEN
                     DO:
                        IF  LOCKED crapban THEN
                            DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapban),
                                                     INPUT "banco",
                                                     INPUT "crapban",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                                                
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
            
            DO  WHILE TRUE:      
                
                FIND crapagb WHERE crapagb.cdageban = aux_cdageban AND
                                   crapagb.cddbanco = aux_cdbccxlt
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF  NOT AVAIL crapagb THEN 
                    DO:
                        IF  LOCKED crapagb THEN
                            DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapagb),
                                                     INPUT "banco",
                                                     INPUT "crapagb",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
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
                ELSE
                    DO: 
						/*Alterar a situacao apenas para agencias que
						  nao estejam parametrizadas.*/
                        IF   crapagb.cdsitagb <> aux_cdsitagb               AND
                             NOT CAN-DO(aux_dstextab, STRING(aux_cdbccxlt)) THEN 
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
            
        UNIX SILENT VALUE("mv " + aux_nmarqdat + " " + aux_dscooper + "salvar").
        
        UNIX SILENT VALUE("rm " + aux_nmarqdat + " 2> /dev/null").
       
        INPUT STREAM str_2 CLOSE.
                                                           
    END. /*** Fim do DO WHILE TRUE ***/
    
    INPUT STREAM str_1 CLOSE.
    
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Processar: CAF502" +
                      " - " + glb_cdprogra + "' --> '"  +
                      " Arquivo integrado com sucesso! >> " + aux_nmarqlog).

END. /** END do FOR EACH da CRAPCOP **/

RUN fontes/fimprg.p.                   

/*............................................................................*/

