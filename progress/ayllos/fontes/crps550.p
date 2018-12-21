/*..............................................................................

   Programa: fontes/crps550.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Marco/2010                        Ultima atualizacao: 29/11/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps470
               Tratar arquivo retorno CECRED de INCLUSAO NO CCF.
               Emite relatorio crrl549.

   Alteracoes: 05/04/2010 - Alterado para processar todas cooperativas, nao
                            mais por cooperativa Singular (Guilherme/Supero)
                            
               01/06/2010 - Acertos Gerais (Guilherme).
               
               06/07/2010 - Alterar nomenclatura dos arquivos (Guilherme).
               
               16/09/2010 - Utilizar o imprim_unif (Guilherme).
               
               02/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               05/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)  
                            
               20/06/2014 - Corrigida utilizacao do codigo da cooperativa
                            no arquivo de LOG (Diego).   
               
               12/09/2014 - Tratar importaçao informaçoes de contas migradas
                            das cooperativas Concredi e Credimilsul
                            (Odirlei/Amcom).                                                 

               25/11/2014 - Incluir clausula no craptco flgativo = TRUE
                            (Lucas R./Rodrigo)  

               29/11/2016 - Incorporacao Transulcred (Guilherme/SUPERO)
               
			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

               29/05/2018 - Alteracao no layout. Sera gerado respeitando o layout CCF607 da ABBC. 
                            Chamado SCTASK0012791 (Heitor - Mouts)

			   04/09/2018 - Inclusão de nova regra para validar o HEADER. Verificar se a data do arquivo 
							é diferente que a data do movimento anterior, se for, gerar a critica: 
							"Data invalida no arquivo" e enviar um e-mail para a COMPE. Chamado PRB0040283 (Douglas - Mouts)
              
               28/11/2018 - SCTASK0029243 - Inclusão da data de regularizaçao e limpeza do relatório.
                            INC0027500 - Inclusao da cdobserv no FIND da crapneg para retornar
                              linha exata em casos de lançamento manual. (Jefferson - Mouts)
                            
               
              

..............................................................................*/

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF   VAR b1wgen0011   AS HANDLE                                       NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3. /* arquivo anexo para enviar via email */

DEF BUFFER crabtab FOR craptab.

DEF TEMP-TABLE cratrej                                                 NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrcheque AS INTE
    FIELD idseqttl AS INTE
    FIELD tpregist AS CHAR
    FIELD dsmotivo AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD dtocorre AS DATE
    FIELD dtfimest AS DATE
    FIELD vlcheque AS DECI
    FIELD nmextttl AS CHAR
    FIELD cdderros AS CHAR.
    
DEF TEMP-TABLE crawarq                                                 NO-UNDO
    FIELD nmarquiv AS CHAR
    FIELD nrsequen AS INTE
    INDEX crawarq1 AS PRIMARY nmarquiv nrsequen.

DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_nrcheque AS INTE                                           NO-UNDO.
DEF VAR aux_tpregist AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqarq AS INTE                                           NO-UNDO.
DEF VAR aux_cdmotivo AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_tppessoa AS INTE                                           NO-UNDO.
DEF VAR aux_qtderros AS INTE                                           NO-UNDO.
DEF VAR aux_cddoerro AS INTE                                           NO-UNDO.
DEF VAR aux_nrposica AS INTE                                           NO-UNDO.

DEF VAR aux_cdderros AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextttl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdoerro AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0011 AS HANDLE										   NO-UNDO.
DEF VAR aux_dscritic AS CHAR										   NO-UNDO.

DEF VAR aux_vlcheque AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.

DEF VAR aux_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR aux_flgrejei AS LOGI                                           NO-UNDO.

DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.

DEF VAR aux_dtiniest LIKE crapneg.dtiniest                             NO-UNDO.
DEF VAR aux_dtfimest LIKE crapneg.dtfimest                             NO-UNDO.

DEF VAR rel_nmempres AS CHAR     FORMAT "x(15)"                        NO-UNDO.
DEF VAR rel_nmrelato AS CHAR     FORMAT "x(40)" EXTENT 5               NO-UNDO.

DEF VAR rel_nrmodulo AS INT      FORMAT "9"                            NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR     FORMAT "x(15)" EXTENT 5
                                 INIT ["DEP. A VISTA   ","CAPITAL        ",
                                       "EMPRESTIMOS    ","DIGITACAO      ",
                                       "GENERICO       "]              NO-UNDO.

FORM
    cratrej.nrdconta  AT  1  FORMAT "zzzz,zzz,z"      NO-LABEL
    cratrej.nmextttl  AT 12  FORMAT "x(30)"           NO-LABEL
    cratrej.idseqttl  AT 49  FORMAT "9"               NO-LABEL
    cratrej.nrcheque  AT 51  FORMAT "999999"          NO-LABEL
    cratrej.vlcheque  AT 58  FORMAT "zzz,zz9.99"      NO-LABEL
    cratrej.dtocorre  AT 69  FORMAT "99/99/9999"      NO-LABEL
    cratrej.dtfimest  AT 80  FORMAT "99/99/9999"      NO-LABEL
    aux_dsdoerro      AT 91  FORMAT "x(41)"           NO-LABEL
    WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_rejeitados.

FORM
    "CONTA/DV"                 AT  3  
    "NOME"                     AT 12
    "SEQ.TTL"                  AT 43
    "CHEQUE"                   AT 51
    "VALOR"                    AT 63
    "DATA DEV."                AT 69
    "DATA REG."                AT 80
    "DESCRICAO DO(S) ERRO(S)"  AT 91
    WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_rejeitados.

FORM 
    aux_setlinha   FORMAT "x(200)"
    WITH NO-BOX NO-LABELS WIDTH 200 FRAME f_linha.

ASSIGN glb_cdprogra = "crps550"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.


ASSIGN aux_nmarqlog = "/usr/coop/cecred/log/prcctl_" + 
                      STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).

        RUN fontes/fimprg.p.
        RETURN.
    END.

/* Baixar arquivos do FTP da ABBC */
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_busca_ccf_transabbc.

IF  ERROR-STATUS:ERROR  THEN DO:
	DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
		ASSIGN aux_msgerora = aux_msgerora + 
			   ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
	END.
		
	UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
					  " - " + glb_cdprogra + "' --> '"  +
				 "Erro ao executar Stored Procedure: '" +
				 aux_msgerora + "' >> log/proc_message.log").

	RETURN.
END.

CLOSE STORED-PROCEDURE pc_busca_ccf_transabbc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


EMPTY TEMP-TABLE crawarq.
EMPTY TEMP-TABLE cratrej.

/* SER00 + Cod Produto "999" + . + 3 digitos aleatorios */
ASSIGN aux_nmarquiv = "/micros/cecred/abbc/CCF617* /micros/cecred/abbc/CCF627*"
       aux_dscooper = "/usr/coop/cecred/"
       aux_flgfirst = TRUE
       aux_contador = 0.

INPUT STREAM str_1 
     THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

    ASSIGN aux_contador = aux_contador + 1
           aux_nmarqdat = aux_dscooper + IF aux_nmarquiv MATCHES("*CCF617*") THEN "integra/CCF617" +
                          STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(aux_contador,"999")
						                                                     ELSE "integra/CCF627" +
                          STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(aux_contador,"999").

    UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                      aux_nmarqdat + " 2> /dev/null").

    /*UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").*/

    UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").

    INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") NO-ECHO.

    SET STREAM str_2 aux_setlinha WITH FRAME f_linha.

    CREATE crawarq.
    ASSIGN crawarq.nrsequen = aux_contador
           crawarq.nmarquiv = aux_nmarqdat
           aux_flgfirst     = FALSE.

    INPUT STREAM str_2 CLOSE.

END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

IF  aux_flgfirst  THEN
    DO: 
        ASSIGN glb_cdcritic = 182.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - Coop:" + STRING(crapcop.cdcooper,"99") +
                          " - Processar: CCF" +
                          " - CCF617 - " + glb_cdprogra + "' --> '" +
                          glb_dscritic + " >> " + aux_nmarqlog).

        NEXT.
    END.

FIND FIRST craptab WHERE craptab.cdcooper = 3        AND
                         craptab.nmsistem = "CRED"   AND
                         craptab.tptabela = "GENERI" AND
                         craptab.cdempres = 00       AND
                         craptab.cdacesso = "CDERROSSER" NO-LOCK NO-ERROR.

IF  NOT AVAILABLE craptab  THEN
    DO:
        ASSIGN glb_cdcritic = 886.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - Coop:" + STRING(crapcop.cdcooper,"99") +
                          " - Processar: CCF" +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).

        NEXT.
    END.    

ASSIGN aux_flgfirst = FALSE.

FOR EACH crawarq BREAK BY crawarq.nrsequen
                       BY crawarq.nmarquiv:  

    RUN proc_processa_arquivo.

    IF  glb_cdcritic = 0  THEN
        DO:
            IF  aux_flgrejei  THEN
                ASSIGN glb_cdcritic = 191.
            ELSE
                ASSIGN glb_cdcritic = 190.

            RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - Coop:" + STRING(glb_cdcooper,"99") +
                          " - Processar: CCF" +
                          " - CCF617 - " + glb_cdprogra + "' --> '"
                          + glb_dscritic + " - " +
                          crawarq.nmarquiv + " >> " + aux_nmarqlog).
        END.

END.  /*** Fim do FOR EACH crawarq ***/   

IF  aux_flgfirst  THEN
    RUN rel_rejeitados.

RUN fontes/fimprg.p.                   

/*-------------------------------- PROCEDURES --------------------------------*/

PROCEDURE proc_processa_arquivo:

    ASSIGN glb_cdcritic = 0
           aux_qtregist = 1
           aux_flgrejei = FALSE.
             
    INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv + ".q") NO-ECHO.
   
    /*** Header ***/
    SET STREAM str_1 aux_setlinha WITH FRAME f_linha.

	IF  SUBSTR(aux_setlinha,1,3) <> "000"  THEN
        ASSIGN glb_cdcritic = 468.
   
    IF  SUBSTR(aux_setlinha,4,6) <> "CCF617"
    AND SUBSTR(aux_setlinha,4,6) <> "CCF627" THEN
        ASSIGN glb_cdcritic = 887.

	
	IF  SUBSTR(aux_setlinha,10,8) <> STRING(YEAR(glb_dtmvtoan),"9999") + 
									 STRING(MONTH(glb_dtmvtoan),"99") + 
									 STRING(DAY(glb_dtmvtoan),"99")  then 
    do:  
    ASSIGN glb_cdcritic = 789.     
    
  

/* enviar email */ 

       RUN sistema/generico/procedures/b1wgen0011.p
                        PERSISTENT SET h-b1wgen0011.
         
                IF VALID-HANDLE(h-b1wgen0011) THEN
                  do:
                 RUN solicita_email_oracle IN h-b1wgen0011
				 (  INPUT  1
                   ,INPUT  "CRPS550"    
                   ,INPUT  "compe@ailos.coop.br"       
                   ,INPUT "Arquivo de retorno da ABBC-CCF - " + STRING(glb_dtmvtolt,"99/99/9999") 
                   ,INPUT "O arquivo lido na ABBC no momento do processo do dia" 
                + " " + STRING(glb_dtmvtolt,"99/99/9999")  + " " + STRING(TIME,"HH:MM:SS") + ", não é o arquivo referente ao movimento anterior que é de" + " " + STRING(glb_dtmvtoan,"99/99/9999") + " " 
                + "É necessário verificar com a ABBC a disponibilização do arquivo correto em seu FTP, e em seguida efetuar a execução manual do arquivo através da tela PRCCTL." 
				+ "Arquivo:" + SUBSTR(aux_setlinha,4,6) + "Data do arquivo:" + SUBSTR(aux_setlinha,16,2) + "/" + SUBSTR(aux_setlinha,14,2) + "/" + SUBSTR(aux_setlinha,10,4)                                       
                   ,INPUT   " "              
                   ,INPUT  "N"                
                   ,INPUT  "N"                
                   ,INPUT  " "
                   ,INPUT  " " 
                   ,INPUT  "N"                 
                   ,INPUT  "N"                 
                   ,OUTPUT aux_dscritic 
				).      
				END.
	END.					

	

	/*** CCF617 ***/
	IF SUBSTR(aux_setlinha,4,6) = "CCF617" THEN
	DO:
    IF  glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_1 CLOSE.
            
            RUN fontes/critic.p.
            ASSIGN aux_nmarquiv = "integra/err" + 
                                  SUBSTR(crawarq.nmarquiv,
                                         R-INDEX(crawarq.nmarquiv,"/") + 1,
                                         LENGTH(crawarq.nmarquiv)).

            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Coop:" + STRING(crapcop.cdcooper,"99") +
                              " - Processar: CCF" +
                              " - CCF617 - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " - " + aux_nmarquiv +
                              " >> " + aux_nmarqlog).
            RETURN.
        END.

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_setlinha WITH FRAME f_linha.

        ASSIGN glb_cdcritic = 0
               aux_qtregist = aux_qtregist + 1.
        
        /*** Trailer ***/ 
        IF  SUBSTR(aux_setlinha,1,3) = "999"  THEN DO:
            /*** Verifica contagem dos registros ***/
            IF  aux_qtregist <> INT(SUBSTR(aux_setlinha,191,10))  THEN
                ASSIGN glb_cdcritic = 504.

            IF  glb_cdcritic > 0  THEN DO:
                RUN fontes/critic.p.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Coop:" + STRING(glb_cdcooper,"99") +
                              " - Processar: CCF" +
                              " - CCF617 - " + glb_cdprogra + 
                              "' --> '" +
                              glb_dscritic + 
                              " - ARQUIVO PROCESSADO - " + 
                              aux_nmarquiv +
                              " >> " + aux_nmarqlog).
                
                LEAVE.
            END.
        END.
        ELSE
            DO:
                /*** Detalhe ***/
				/* So processar registros da CECRED */
                IF SUBSTR(aux_setlinha,18,3) <> "085" THEN
                  NEXT.

                ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,25,12))
                       aux_nrcheque = INT(SUBSTR(aux_setlinha,37,6))
                       aux_tpregist = INT(SUBSTR(aux_setlinha,2,2))
                       aux_cdmotivo = INT(SUBSTR(aux_setlinha,60,2))
                       aux_tppessoa = INT(SUBSTR(aux_setlinha,112,2))
                       aux_nrcpfcgc = DECI(SUBSTR(aux_setlinha,4,14))
                       aux_dtiniest = DATE(INT(SUBSTRING(aux_setlinha,66,2)),
                                           INT(SUBSTRING(aux_setlinha,68,2)),
                                           INT(SUBSTRING(aux_setlinha,62,4)))
                       aux_vlcheque = DECI(SUBSTR(aux_setlinha,43,17)) / 100
                       aux_nmextttl = TRIM(SUBSTR(aux_setlinha,70,40))
                       aux_idseqttl = INT(SUBSTR(aux_setlinha,110,2)).
                                       
                IF  aux_idseqttl = 0  THEN
                    aux_idseqttl = 1.
                    
                FIND crapcop WHERE crapcop.cdagectl = 
                                   INT(SUBSTR(aux_setlinha,21,4))
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapcop  THEN
                DO:
                    ASSIGN glb_cdcritic = 651.
                    RUN fontes/critic.p.

                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - Coop:" + 
                                      STRING(glb_cdcooper,"99") +
                                      " - Processar: CCF" +
                                      " - CCF617 - " + 
                                      glb_cdprogra + "' --> '" +
                                      glb_dscritic + 
                                      " - CONTA/DV: " + 
                                      STRING(aux_nrdconta,"zzzz,zzz,z") + 
                                      " - Registro " + 
                                      STRING(aux_qtregist,"9999999") +
                                      " - " + aux_nmarquiv + " >> " + 
                                      aux_nmarqlog).
                    
                    NEXT.
                END.
                
                /* se for uma das cooperativas migradas, 
                  deve buscar a nova conta e coop */
                IF crapcop.cdcooper =  4 OR
                   crapcop.cdcooper = 15 OR
                   crapcop.cdcooper = 17 THEN DO:

                  /*verifica se é uma conta migrada da:
                      concredi
                      credimilsul
                      transulcred */
                  FIND FIRST craptco 
                    WHERE craptco.cdcopant = crapcop.cdcooper 
                      AND craptco.nrctaant = aux_nrdconta 
                      AND craptco.flgativo = TRUE
                      NO-LOCK NO-ERROR.
            
                  /* se encontrar deve utilizar o novo
                    numero de conta na coop nova*/
                  IF AVAIL(craptco) THEN DO:

                    /* Busca dados da nova Cooperativa */
                    FIND FIRST crapcop 
                         WHERE crapcop.cdcooper = craptco.cdcooper
                            NO-LOCK NO-ERROR.
                    ASSIGN aux_nrdconta = craptco.nrdconta.
                    
                  END.    
                END.

                FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                   crapass.nrdconta = aux_nrdconta 
                                   NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAILABLE crapass  THEN DO:
                    ASSIGN glb_cdcritic = 9.
                    RUN fontes/critic.p.

                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - Coop:" + STRING(glb_cdcooper,"99") +
                                  " - Processar: CCF" +
                                  " - CCF617 - " + 
                                  glb_cdprogra + "' --> '" +
                                  glb_dscritic + 
                                  " - CONTA/DV: " + 
                                  STRING(aux_nrdconta,"zzzz,zzz,z") + 
                                  " - Registro " + 
                                  STRING(aux_qtregist,"9999999") +
                                  " - " + aux_nmarquiv + " >> " + 
                                  aux_nmarqlog).
                    NEXT.
                END.
                    
                        /*** Se registro detalhe foi processado com sucesso ***/
                        FIND crapneg WHERE 
                             crapneg.cdcooper = crapcop.cdcooper AND
                             crapneg.cdbanchq = crapcop.cdbcoctl AND
                             crapneg.nrdconta = aux_nrdconta     AND
                             crapneg.dtiniest = aux_dtiniest     AND
                             crapneg.cdobserv = aux_cdmotivo     AND
                             INT(SUBSTR(STRING(crapneg.nrdocmto,"9999999"),1,6))
                                              = aux_nrcheque 
                             USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR.
                                          
                        IF  AVAILABLE crapneg  THEN
                            ASSIGN crapneg.flgctitg = 2. 
                    END.
		    END.  /*** Fim do DO WHILE TRUE ***/
		END.
	ELSE   /*** CCF627 ***/
	DO:
		IF  glb_cdcritic <> 0 THEN
			DO:
				INPUT STREAM str_1 CLOSE.
				
				RUN fontes/critic.p.
				ASSIGN aux_nmarquiv = "integra/err" + 
									  SUBSTR(crawarq.nmarquiv,
											 R-INDEX(crawarq.nmarquiv,"/") + 1,
											 LENGTH(crawarq.nmarquiv)).

				UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").

				UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).

				UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
								  " - Coop:" + STRING(crapcop.cdcooper,"99") +
								  " - Processar: CCF" +
								  " - CCF627 - " + glb_cdprogra + "' --> '" +
								  glb_dscritic + " - " + aux_nmarquiv +
								  " >> " + aux_nmarqlog).
				RETURN.
			END. 

		DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

			SET STREAM str_1 aux_setlinha WITH FRAME f_linha.

			ASSIGN glb_cdcritic = 0
				   aux_qtregist = aux_qtregist + 1.
			
			/*** Trailer ***/ 
			IF  SUBSTR(aux_setlinha,1,3) = "999"  THEN DO:
				/*** Verifica contagem dos registros ***/
				IF  aux_qtregist <> INT(SUBSTR(aux_setlinha,191,10))  THEN
					ASSIGN glb_cdcritic = 504.

				IF  glb_cdcritic > 0  THEN DO:
					RUN fontes/critic.p.

				UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
								  " - Coop:" + STRING(glb_cdcooper,"99") +
								  " - Processar: CCF" +
								  " - CCF627 - " + glb_cdprogra + 
								  "' --> '" +
								  glb_dscritic + 
								  " - ARQUIVO PROCESSADO - " + 
								  aux_nmarquiv +
								  " >> " + aux_nmarqlog).
					
					LEAVE.
				END. 
			END. 
                ELSE
                    DO:
					/*** Detalhe ***/
					/* So processar registros tipo 1 */
					IF SUBSTR(aux_setlinha,1,1) <> "1" THEN
					  NEXT.

					/* So processar registros da CECRED */
					IF SUBSTR(aux_setlinha,18,3) <> "085" THEN
					  NEXT.

					ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,25,12))
						   aux_nrcheque = INT(SUBSTR(aux_setlinha,37,6))
						   aux_tpregist = INT(SUBSTR(aux_setlinha,2,2))
						   aux_cdmotivo = INT(SUBSTR(aux_setlinha,60,2))
						   aux_tppessoa = INT(SUBSTR(aux_setlinha,112,2))
						   aux_nrcpfcgc = DECI(SUBSTR(aux_setlinha,4,14))
						   aux_dtiniest = DATE(INT(SUBSTRING(aux_setlinha,66,2)),
											   INT(SUBSTRING(aux_setlinha,68,2)),
											   INT(SUBSTRING(aux_setlinha,62,4)))
						   aux_vlcheque = DECI(SUBSTR(aux_setlinha,43,17)) / 100
						   aux_nmextttl = TRIM(SUBSTR(aux_setlinha,70,40))
						   aux_idseqttl = INT(SUBSTR(aux_setlinha,110,2))
						   aux_cdderros = SUBSTR(aux_setlinha,183,3).

					IF  aux_idseqttl = 0  THEN
						aux_idseqttl = 1.

					FIND crapcop WHERE crapcop.cdagectl = 
									   INT(SUBSTR(aux_setlinha,21,4))
									   NO-LOCK NO-ERROR.

					IF  NOT AVAIL crapcop  THEN
					DO:
						ASSIGN glb_cdcritic = 651.
						RUN fontes/critic.p.

						UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
										  " - Coop:" + 
										  STRING(glb_cdcooper,"99") +
										  " - Processar: CCF" +
										  " - CCF627 - " + 
										  glb_cdprogra + "' --> '" +
										  glb_dscritic + 
										  " - CONTA/DV: " + 
										  STRING(aux_nrdconta,"zzzz,zzz,z") + 
										  " - Registro " + 
										  STRING(aux_qtregist,"9999999") +
										  " - " + aux_nmarquiv + " >> " + 
										  aux_nmarqlog).
						
						NEXT.
					END. 
					
					/* se for uma das cooperativas migradas, 
					  deve buscar a nova conta e coop */
					IF crapcop.cdcooper =  4 OR
					   crapcop.cdcooper = 15 OR
					   crapcop.cdcooper = 17 THEN DO:

					  /*verifica se é uma conta migrada da:
						  concredi
						  credimilsul
						  transulcred */
					  FIND FIRST craptco 
						WHERE craptco.cdcopant = crapcop.cdcooper 
						  AND craptco.nrctaant = aux_nrdconta 
						  AND craptco.flgativo = TRUE
						  NO-LOCK NO-ERROR.
				
					  /* se encontrar deve utilizar o novo
						numero de conta na coop nova*/
					  IF AVAIL(craptco) THEN DO:

						/* Busca dados da nova Cooperativa */
						FIND FIRST crapcop 
							 WHERE crapcop.cdcooper = craptco.cdcooper
								NO-LOCK NO-ERROR.
						ASSIGN aux_nrdconta = craptco.nrdconta.
						
					  END.     
					END. 

					FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
									   crapass.nrdconta = aux_nrdconta 
									   NO-LOCK NO-ERROR.
									   
					IF  NOT AVAILABLE crapass  THEN DO:
						ASSIGN glb_cdcritic = 9.
						RUN fontes/critic.p.

						UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
									  " - Coop:" + STRING(glb_cdcooper,"99") +
									  " - Processar: CCF" +
									  " - CCF627 - " + 
									  glb_cdprogra + "' --> '" +
									  glb_dscritic + 
									  " - CONTA/DV: " + 
									  STRING(aux_nrdconta,"zzzz,zzz,z") + 
									  " - Registro " + 
									  STRING(aux_qtregist,"9999999") +
									  " - " + aux_nmarquiv + " >> " + 
									  aux_nmarqlog).
						NEXT.
					END. 
						
                        /*** Se registro teve erro, atualiza para Reenviar ***/
                        FIND crapneg WHERE 
                             crapneg.cdcooper = crapcop.cdcooper AND
                             crapneg.cdbanchq = crapcop.cdbcoctl AND
                             crapneg.nrdconta = aux_nrdconta     AND 
                             crapneg.flgctitg = 1                AND 
                             crapneg.dtiniest = aux_dtiniest     AND
                             crapneg.cdobserv = aux_cdmotivo     AND
                             INT(SUBSTR(STRING(crapneg.nrdocmto,"9999999"),1,6))
                                              = aux_nrcheque 
                             USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR.
                                          
                        IF  AVAILABLE crapneg  THEN
                            DO:
                                ASSIGN aux_dtfimest = crapneg.dtfimest.
                                IF crapneg.dtiniest >= (glb_dtmvtolt - 60) THEN
                                    ASSIGN crapneg.flgctitg = 4.
                                ELSE
                                    ASSIGN crapneg.flgctitg = 2.
                            END.

                        RUN cria_rejeitado.
                        
                        ASSIGN aux_flgfirst = TRUE
                               aux_flgrejei = TRUE.

                    END.
    END. /*** Fim do DO WHILE TRUE ***/
            END. 
           
    INPUT STREAM str_1 CLOSE.
   
    UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
   
    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_dscooper + "salvar").
   
END PROCEDURE. 

PROCEDURE cria_rejeitado:

    CREATE cratrej.
    ASSIGN cratrej.nrdconta = aux_nrdconta
           cratrej.cdcooper = crapcop.cdcooper
           cratrej.cdagenci = crapass.cdagenci
           cratrej.nrcheque = aux_nrcheque
           cratrej.idseqttl = aux_idseqttl
           cratrej.tpregist = IF  aux_tpregist = 2  THEN
                                  "EXCLUSAO"
                              ELSE
                              IF  aux_tpregist = 4  THEN
                                  "INCLUSAO"
                              ELSE
                                  "ALTERACAO"
           cratrej.dsmotivo = IF  aux_cdmotivo = 12  THEN
                                  "CHEQUE SEM FUNDO"
                              ELSE
                              IF  aux_cdmotivo = 13  THEN
                                  "CONTA ENCERRADA"
                              ELSE
                                  ""
           cratrej.nrcpfcgc = aux_nrcpfcgc
           cratrej.dtocorre = aux_dtiniest
           cratrej.dtfimest = aux_dtfimest
           cratrej.vlcheque = aux_vlcheque
           cratrej.nmextttl = aux_nmextttl
           cratrej.cdderros = aux_cdderros.

END PROCEDURE.

PROCEDURE rel_rejeitados:

    FOR EACH cratrej NO-LOCK BREAK BY cratrej.cdcooper
                                   BY cratrej.cdagenci
                                   BY cratrej.nrdconta:
        IF  FIRST-OF(cratrej.cdcooper)  THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = cratrej.cdcooper
                                   NO-LOCK NO-ERROR.
                ASSIGN aux_dscooper = "/usr/coop/" +
                                      crapcop.dsdircop + "/"
                       aux_nmarqrel = aux_dscooper + "rl/crrl549_999.lst".

                /*** Monta o cabecalho ***/
                { includes/cabrel132_1.i }
            
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) APPEND PAGED 
                       PAGE-SIZE 84.
            
                VIEW STREAM str_1 FRAME f_cabrel132_1.
            
                VIEW STREAM str_1 FRAME f_cab_rejeitados.
            END.
        
        IF  FIRST-OF(cratrej.cdagenci)  THEN
            DO:
                ASSIGN aux_nmarqrel = aux_dscooper + "rl/crrl549_" + 
                                      STRING(cratrej.cdagenci,"999") + ".lst".

                OUTPUT STREAM str_2 TO VALUE(aux_nmarqrel) 
                                    APPEND PAGED PAGE-SIZE 84.
                
                VIEW STREAM str_2 FRAME f_cabrel132_1.

                FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper     AND
                                   crapage.cdagenci = cratrej.cdagenci 
                                   NO-LOCK NO-ERROR.

                PUT STREAM str_2 SKIP
                                 "PA:  " crapage.cdagenci " - " 
                                 crapage.nmresage FORMAT "x(15)"
                                 SKIP(1).
                
                VIEW STREAM str_2 FRAME f_cab_rejeitados.
            END.
                                  
        ASSIGN aux_qtderros = LENGTH(cratrej.cdderros) / 3
               aux_nrposica = 1.
        
        RUN procura_erro.
        
        DISPLAY STREAM str_1
                       cratrej.nrdconta
                       cratrej.nmextttl
                       cratrej.idseqttl
                       cratrej.nrcheque
                       cratrej.vlcheque
                       cratrej.dtocorre
                       cratrej.dtfimest
                       aux_dsdoerro
                       WITH FRAME f_rejeitados.
                      
        DISPLAY STREAM str_2
                       cratrej.nrdconta
                       cratrej.nmextttl
                       cratrej.idseqttl
                       cratrej.nrcheque
                       cratrej.vlcheque
                       cratrej.dtocorre
                       cratrej.dtfimest
                       aux_dsdoerro
                       WITH FRAME f_rejeitados.               
                       
        DOWN STREAM str_1 WITH FRAME f_rejeitados.
        
        DOWN STREAM str_2 WITH FRAME f_rejeitados.
        
        DO aux_contador = 2 TO aux_qtderros:
        
            ASSIGN aux_nrposica = aux_nrposica + 3.
                
            RUN procura_erro.
            
            DISPLAY STREAM str_1 aux_dsdoerro WITH FRAME f_rejeitados.
            
            DISPLAY STREAM str_2 aux_dsdoerro WITH FRAME f_rejeitados.
            
            DOWN STREAM str_1 WITH FRAME f_rejeitados.
            
            DOWN STREAM str_2 WITH FRAME f_rejeitados.
        
        END. /*** Fim do DO TO ***/
        
        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.
                VIEW STREAM str_1 FRAME f_cab_rejeitados.
            END.

        IF  LINE-COUNTER(str_2) > PAGE-SIZE(str_2)  THEN
            DO:
                PAGE STREAM str_2.
                VIEW STREAM str_2 FRAME f_cab_rejeitados.
            END.

        IF  LAST-OF(cratrej.cdagenci)  THEN
            DO:
                OUTPUT STREAM str_2 CLOSE.

                ASSIGN glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqrel
                       glb_nrcopias = 1.
                
                RUN fontes/imprim_unif.p (INPUT cratrej.cdcooper).
                
                /*** Se nao estiver rodando no PROCESSO copia relatorio ***/
                IF  glb_inproces = 1  THEN
                    UNIX SILENT VALUE("cp " + aux_nmarqrel + " " + aux_dscooper
                                      + "rlnsv/" +
                         SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                         LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).
            END.

        IF  LAST-OF(cratrej.cdcooper)  THEN
            DO:
                OUTPUT STREAM str_1 CLOSE.
    
                ASSIGN aux_nmarqrel = aux_dscooper + "rl/crrl549_999.lst"
                       glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqrel
                       glb_nrcopias = 1.
    
                RUN fontes/imprim_unif.p (INPUT cratrej.cdcooper).
                
                /*** Se nao estiver rodando no PROCESSO 
                     copia relatorio para "/rlnsv" ***/
                IF  glb_inproces = 1  THEN
                    UNIX SILENT VALUE("cp " + aux_nmarqrel + " " + 
                                      aux_dscooper + "rlnsv/" +
                                      SUBSTRING(aux_nmarqrel,
                                                R-INDEX(aux_nmarqrel,"/") + 1,
                                                LENGTH(aux_nmarqrel) - 
                                                R-INDEX(aux_nmarqrel,"/"))).

            END.
    
    END. /*** Fim do FOR EACH cratrej ***/

END PROCEDURE.

PROCEDURE procura_erro:

    ASSIGN aux_cddoerro = INT(SUBSTR(cratrej.cdderros,aux_nrposica,3))
           aux_dsdoerro = "".

    FIND FIRST craptab WHERE craptab.cdcooper = 3            AND
                             craptab.nmsistem = "CRED"       AND
                             craptab.tptabela = "GENERI"     AND
                             craptab.cdempres = 00           AND
                             craptab.cdacesso = "CDERROSSER617" AND
                             craptab.tpregist = aux_cddoerro  
                             NO-ERROR NO-WAIT.
                             
    IF  AVAILABLE craptab  THEN
        ASSIGN aux_dsdoerro = CAPS(TRIM(craptab.dstextab)).
 
END PROCEDURE.

/*...........................................................................*/
