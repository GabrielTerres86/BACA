/*.............................................................................
    Programa: sistema/generico/procedures/b1wgen0185.p
    Autor   : Jéssica Laverde Gracino (DB1)
    Data    : 24/02/2014                     Ultima atualizacao: 05/12/2016

    Objetivo  : Tranformacao BO tela MOVTOS.

    Alteracoes: 11/06/2014 - Adicionado condicao para dtdemiss = ? quando
                             gerar as informações na "Gera_Dados_L"
                             (Douglas - Chamado 159143)
                             
                11/09/2014 - Incluir tratamentdo para as contas migradas das 
                             cooperativas Concredi e credimilsul 
                             (Odirlei/AMcom).             
                             
                27/11/2014 - Ajustes para liberacao (Adriano).
                
                13/03/2015 - Ajustando format "zzz,zz9" p/ "zzzz,zz9".
                             Foi identificado que a tela MOVTOS tambem
                             possui variavel com esse formato, porem
                             o erro ocorre somente na opcao L - Relatorio
                             SD264377. (Andre Santos - SUPERO)
                             
                18/05/2015 - #286172 Procedure Gera_Dados_L:
                           - Correcao dos totais dos acessos das 
                             cooperativas. Temp-tables nao estavam sendo
                             limpas para cada cooperativa;
                           - Melhoria de performance iterando os registros
                             craplgm dia a dia;
                           - Melhoria de performance capturando o ultimo
                             titular da conta;
                           - Correcao de alinhamento dos meses;
                           - Melhoria de performance agrupando os registros
                             craplgm de ATENDA e INTERNETBANK na mesma busca
                             (Carlos)
                            
               03/11/2015 - Ajustes referente Projeto de Assinatura Multipla.
                          (Daniel)          

			         11/10/2016 - M172 - Ajuste do formato do número de celular devido
							              ao acrescimo de mais um digito.
							              (Ricardo Linhares)
              
              05/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0185tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0002tt.i }

DEF STREAM str_1.
DEF STREAM str_2.

/************************ FUNCTIONS *****************************************/

FUNCTION Retira_Caracteres RETURN CHAR PRIVATE
    (INPUT par_string   AS CHARACTER,
     INPUT par_listacar AS CHARACTER) FORWARD.


/******************************************************************************/
FUNCTION Retira_Caracteres RETURN CHAR(INPUT par_string   AS CHARACTER,
                                       INPUT par_listacar AS CHARACTER):

    DEF VAR aux_contador AS INTEGER NO-UNDO.
    
    DO aux_contador = 1 TO NUM-ENTRIES(par_listacar,";") ON ERROR UNDO, RETURN "NOK":
        ASSIGN par_string = REPLACE(par_string,ENTRY(aux_contador,par_listacar,";"),"").
    END.
    
    RETURN par_string.
  
END. /* Retira_Caracteres */ 


/*................................ PROCEDURES ..............................*/

/* -------------------------------------------------------------------------- */
/*                      GERA A IMPRESSAO DOS MOVIMENTOS                       */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

    DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.    
    DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.    
    DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.    
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.    
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.    
    DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO.    
    DEF INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                           NO-UNDO.    
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.    
    DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.    
    DEF INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.    
    DEF INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"       NO-UNDO.    
    DEF INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.    
    DEF INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.    
    DEF INPUT PARAM par_cdempres AS INTE                           NO-UNDO.    
    DEF INPUT PARAM par_tppessoa AS INTE                           NO-UNDO.    
    DEF INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.    
    DEF INPUT PARAM par_lgvisual AS CHAR                           NO-UNDO.    
    DEF INPUT PARAM par_ddtfinal AS DATE                           NO-UNDO.    
    DEF INPUT PARAM par_cdultrev AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_tpcontas AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dsadmcrd AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_tpdomvto AS CHAR  FORMAT "X(1)"            NO-UNDO.
    DEF INPUT PARAM par_situacao AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_sellincr AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_selfinal AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cartoes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR par_nmdcampo AS CHAR                                   NO-UNDO.
    DEF VAR aux_cdultrev AS INTE                                   NO-UNDO.
    DEF VAR aux_idseqttl AS INTE                                   NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                   NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                   NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                   NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                  NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do Historico".

    EMPTY TEMP-TABLE tt-cartoes.
    EMPTY TEMP-TABLE tt-erro.

    Imprime:
    DO ON ERROR UNDO Imprime, LEAVE Imprime:

       IF par_cddopcao = "F" THEN
          DO:
              RUN Gera_Dados_F(INPUT par_cdcooper,    
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_inproces,
                               INPUT par_cddepart,
                               INPUT par_dtmvtopr,
                               INPUT par_dtmvtolt,
                               INPUT par_flgerlog,
                               INPUT par_cddopcao,
                               INPUT par_cdempres,
                               INPUT par_dsiduser,
                               INPUT par_lgvisual,
                               INPUT par_nmarquiv,
                               OUTPUT par_nmdcampo,
                               OUTPUT par_nmarqimp,
                               OUTPUT par_nmarqpdf,
                               OUTPUT TABLE tt-erro).     

              IF RETURN-VALUE <> "OK" THEN
                 DO:
                    IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel consultar " + 
                                             "por empresa os contratos dos " + 
                                             "cooperados.".
                
                    LEAVE Imprime.
                
                 END.

          END.

       ELSE
       IF par_cddopcao = "L" THEN
          DO:
              RUN Gera_Dados_L(INPUT par_cdcooper,       
                               INPUT par_cdagenci,       
                               INPUT par_nrdcaixa,       
                               INPUT par_cdoperad,       
                               INPUT par_nmdatela,       
                               INPUT par_idorigem,       
                               INPUT par_cddepart,       
                               INPUT par_dtmvtolt,       
                               INPUT par_flgerlog,       
                               INPUT par_cddopcao,       
                               INPUT par_dtinicio,       
                               INPUT par_ddtfinal,       
                               INPUT par_dsiduser,       
                               INPUT par_lgvisual,       
                               INPUT par_nmarquiv,
                               OUTPUT par_nmarqimp,       
                               OUTPUT par_nmarqpdf,       
                               OUTPUT par_nmdcampo,       
                               OUTPUT TABLE tt-erro).  

              IF RETURN-VALUE <> "OK" THEN
               DO:
                  IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Nao foi possivel consultar "      +
                                           "a quantidade de liberacoes para " +
                                           "o uso da Internet.".

                  LEAVE Imprime.

               END.

          END.

       ELSE
       IF par_cddopcao = "R" THEN
          DO:
             RUN Gera_Dados_R(INPUT par_cdcooper,                  
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_cddepart,
                              INPUT par_dtmvtolt,
                              INPUT par_flgerlog,
                              INPUT par_cddopcao,
                              INPUT par_tppessoa,
                              INPUT par_cdultrev,
                              INPUT par_dsiduser,
                              INPUT par_lgvisual,
                              INPUT par_cdagenca,
                              INPUT par_nmarquiv,
                              OUTPUT par_nmarqimp,
                              OUTPUT par_nmarqpdf,
                              OUTPUT par_nmdcampo,       
                              OUTPUT TABLE tt-erro). 

             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Nao foi possivel visualizar a " +
                                            "data do ultimo recadastramento" +
                                            " de conta.".
             
                   LEAVE Imprime.
             
                END.

          END.

       ELSE 
       IF par_cddopcao = "S" THEN
          DO: 
              RUN Gera_Dados_S(INPUT par_cdcooper,     
                               INPUT par_cdagenci,     
                               INPUT par_nrdcaixa,     
                               INPUT par_cdoperad,     
                               INPUT par_nmdatela,     
                               INPUT par_idorigem,     
                               INPUT par_cddepart,     
                               INPUT par_dtmvtolt,     
                               INPUT par_flgerlog,     
                               INPUT par_cddopcao,     
                               INPUT par_tppessoa,     
                               INPUT par_dtinicio,     
                               INPUT par_ddtfinal,     
                               INPUT par_cdempres,     
                               INPUT par_tpcontas,     
                               INPUT par_dsiduser,     
                               INPUT par_lgvisual, 
                               INPUT par_cdagenca,
                               INPUT par_nmarquiv,
                               OUTPUT par_nmarqimp,     
                               OUTPUT par_nmarqpdf,     
                               OUTPUT par_nmdcampo,     
                               OUTPUT TABLE tt-erro).  

              IF RETURN-VALUE <> "OK" THEN
                 DO:
                    IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel consultar " + 
                                             "dados para gerar o relatorio.".

                    LEAVE Imprime.

                 END.
                                          
          END.                            
       ELSE 
       IF par_cddopcao = "E" THEN
          DO:
              RUN Gera_Dados_E(INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_cddepart,
                               INPUT par_dtmvtolt,
                               INPUT par_flgerlog,
                               INPUT par_dsiduser,
                               INPUT par_lgvisual,
                               INPUT par_nmarquiv,
                               OUTPUT par_nmarqimp, 
                               OUTPUT par_nmarqpdf,
                               OUTPUT par_nmdcampo,       
                               OUTPUT TABLE tt-erro).  

              IF RETURN-VALUE <> "OK" THEN
                 DO:
                    IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel consultar " + 
                                             "dados para gerar o arquivo.".

                    LEAVE Imprime.

                 END.

          END.
       ELSE
       IF par_cddopcao = "C" THEN
          DO:                
             RUN Gera_Dados_C(INPUT par_cdcooper,  
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_cddepart,
                              INPUT par_dtmvtolt,
                              INPUT par_flgerlog,
                              INPUT par_cddopcao,
                              INPUT par_tppessoa,
                              INPUT par_cdultrev,
                              INPUT par_dtinicio,
                              INPUT par_ddtfinal,
                              INPUT par_cdempres,
                              INPUT par_dsiduser,
                              INPUT par_lgvisual,
                              INPUT par_tpdopcao,
                              INPUT par_dsadmcrd,
                              INPUT par_tpdomvto,
                              INPUT par_situacao,
                              INPUT par_nmarquiv,
                              OUTPUT par_nmarqimp,
                              OUTPUT par_nmarqpdf,
                              OUTPUT par_nmdcampo,
                              OUTPUT TABLE tt-cartoes,
                              OUTPUT TABLE tt-erro).
              
             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Nao foi possivel consultar " + 
                                            "dados para gerar o arquivo.".

                   LEAVE Imprime.

                END.
                 
          END.
       ELSE
       IF par_cddopcao = "A" THEN
          DO: 
             RUN Gera_Arquivo(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_dtmvtolt,
                              INPUT par_dtmvtopr,
                              INPUT par_flgerlog,
                              INPUT par_sellincr,
                              INPUT par_selfinal,
                              INPUT par_dsiduser,
                              INPUT par_nmarquiv,
                              OUTPUT par_nmarqimp, 
                              OUTPUT TABLE tt-erro).

             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Nao foi possivel gerar o " + 
                                            "arquivo.".

                   LEAVE Imprime.

                END.

          END.

       ASSIGN aux_returnvl = "OK".

       LEAVE Imprime.

    END. /* Imprime */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog THEN
              RUN proc_gerar_log (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT NO,
                                  INPUT 1, /** idseqttl **/
                                  INPUT par_nmdatela,
                                  INPUT 0, /* nrdconta */
                                 OUTPUT aux_nrdrowid).

       END.
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao*/

/* -------------------------------------------------------------------------- */
/*                  EFETUA A BUSCA DAS MOVIMENTAÇÕES DA OPÇÃO C               */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados_C:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INT                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_tppessoa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdultrev AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_ddtfinal AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdempres AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_tpdopcao AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dsadmcrd AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_tpdomvto AS CHAR  FORMAT "X(1)"             NO-UNDO.
    DEF INPUT PARAM par_lgvisual AS CHAR  FORMAT "!(1)"             NO-UNDO.
    DEF INPUT PARAM par_situacao AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cartoes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmrescop AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Relacao de cartao de credito".              

    EMPTY TEMP-TABLE tt-cartoes.
    EMPTY TEMP-TABLE tt-erro.
                
    Busca:
    DO ON ERROR UNDO Busca, LEAVE Busca:

       IF par_tpdopcao = "Por Periodo" THEN
          DO:
             /*Por questoes de performance na leitura da lcm,
               o periodo informado sera limitado em no maximo
               um mes para realizacao da consulta. Quando nao
               informado, consulta os ultimos tres meses em relacao
               a data de movimento do sistema.*/
             IF ADD-INTERVAL(par_ddtfinal,-(par_ddtfinal - 
                             par_dtinicio),"DAY") < ADD-INTERVAL(par_ddtfinal,-1,"MONTH") THEN
                DO:
                    ASSIGN aux_cdcritic = 0 
                           aux_dscritic = "Periodo de consulta deve "    +
                                          "contemplar no maximo um mes."
                           par_nmdcampo = "".

                    LEAVE Busca.

                END.

             IF par_ddtfinal < par_dtinicio THEN
                DO:
                   ASSIGN aux_cdcritic = 0 
                          aux_dscritic = "Data inicial deve ser menor " + 
                                         "que a final."
                          par_nmdcampo = "".
                
                   LEAVE Busca.
                
                END.
             
          END.
       ELSE
       IF par_tpdopcao = "Todos Cartoes" THEN
          DO:
             IF par_dsadmcrd <> "BRADESCO" THEN
                DO:
                   IF par_tpdomvto = "D" THEN
                      DO:
                         /*Por questoes de performance na leitura da lcm,
                         o periodo informado sera limitado em no maximo
                         um mes para realizacao da consulta.*/
                         IF ADD-INTERVAL(par_ddtfinal, -(par_ddtfinal - 
                                         par_dtinicio),"DAY") <
                            ADD-INTERVAL(par_ddtfinal,-1,"MONTH") THEN
                            DO:
                               ASSIGN aux_cdcritic = 0 
                                      aux_dscritic = "Periodo de consulta deve "    +
                                                     "contemplar no maximo um mes."
                                      par_nmdcampo = "".

                               LEAVE Busca.
                                
                            END.

                         IF par_ddtfinal < par_dtinicio THEN
                            DO:
                               ASSIGN aux_cdcritic = 0 
                                      aux_dscritic = "Data inicial deve ser menor " + 
                                                     "que a final."
                                      par_nmdcampo = "".

                               LEAVE Busca.

                            END.

                      END.
                            
                END.
             
          END.

       IF par_cdcooper = 3 THEN
          DO:
	   	     FOR EACH crapcop FIELDS(nmrescop dsdircop cdcooper) 
	   	   	                   WHERE crapcop.cdcooper <> 3 
                                     NO-LOCK BY crapcop.cdcooper:

	   	   	     IF par_tpdomvto = "C" THEN 
	   	   	     	DO:
	   	   	     	   RUN carrega_dados_c(INPUT par_cdcooper,
	   	   	     	   				       INPUT par_cdagenci,
	   	   	     	   				       INPUT par_nrdcaixa,
	   	   	     	   				       INPUT par_cdoperad,
	   	   	     	   				       INPUT par_nmdatela,
	   	   	     	   				       INPUT par_idorigem,
	   	   	     	   				       INPUT par_cddepart,
	   	   	     	   				       INPUT par_dtmvtolt,
	   	   	     	   				       INPUT par_nrregist,
	   	   	     	   				       INPUT par_nriniseq,
	   	   	     	   				       INPUT par_flgerlog,
	   	   	     	   				       INPUT par_cddopcao,
	   	   	     	   				       INPUT par_tppessoa,
	   	   	     	   				       INPUT par_cdultrev,
	   	   	     	   				       INPUT par_dtinicio,
	   	   	     	   				       INPUT par_ddtfinal,
                                           INPUT par_cdempres,
	   	   	     	   				       INPUT par_tpdopcao,
	   	   	     	   				       INPUT par_dsadmcrd,
                                           INPUT par_situacao,
                                           INPUT crapcop.cdcooper,
                                           INPUT par_lgvisual,
                                           INPUT par_dsiduser,
                                           INPUT par_nmarquiv,
	   	   	     	   				       OUTPUT par_qtregist,
	   	   	     	   				       OUTPUT par_nmdcampo,
	   	   	     	   				       OUTPUT par_nmarqimp,
	   	   	     	   				       OUTPUT par_nmarqpdf,
	   	   	     	   				       OUTPUT TABLE tt-cartoes,
	   	   	     	   				       OUTPUT TABLE tt-erro).  

                       IF RETURN-VALUE <> "OK" THEN
                          DO:
                             IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Nao foi possivel " + 
                                                      "carregar informacoes.".
                      
                             LEAVE Busca.
                      
                          END.
                 
	   	   	     	END.
	   	   	     ELSE
	   	   	     	DO:
	   	   	     	   RUN carrega_dados_cartoes_bb_debito
                                     (INPUT par_cdcooper,  
	   	   	     	   		          INPUT par_cdagenci, 
	   	   	     	   			      INPUT par_nrdcaixa, 
	   	   	     	   			      INPUT par_idorigem,   
	   	   	     	   			      INPUT par_dtmvtolt,  
	   	   	     	   			      INPUT par_cddopcao,
	   	   	     	   			      INPUT par_cdoperad,  
                                      INPUT crapcop.cdcooper,
                                      INPUT par_dsadmcrd,
                                      INPUT par_situacao,
                                      INPUT par_lgvisual,   
	   	   	     	   			      INPUT par_dsiduser, 
                                      INPUT par_dtinicio,
                                      INPUT par_ddtfinal,
	   	   	     	   			      INPUT par_flgerlog,
	   	   	     	   			      INPUT par_nmdatela,
                                      INPUT par_nmarquiv,
	   	   	     	   			      OUTPUT par_nmarqimp, 
	   	   	     	   			      OUTPUT par_nmarqpdf, 
	   	   	     	   			      OUTPUT TABLE tt-cartoes,
                                      OUTPUT TABLE tt-erro).
                              
                       IF RETURN-VALUE <> "OK" THEN
                          DO:
                             IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Nao foi possivel " + 
                                                      "carregar informacoes.".
                        
                             LEAVE Busca.
                        
                          END.

	   	   	     	END.

	   	     END.

	   	  END.
	   ELSE
	   	  DO: 
	   	  	 IF par_tpdomvto = "C" THEN
	   	  	 	DO:    
	   	  	 	   RUN carrega_dados_c(INPUT par_cdcooper,  
	   	  	 	   				       INPUT par_cdagenci,
	   	  	 	   				       INPUT par_nrdcaixa,
	   	  	 	   				       INPUT par_cdoperad,
	   	  	 	   				       INPUT par_nmdatela,
	   	  	 	   				       INPUT par_idorigem,
	   	  	 	   				       INPUT par_cddepart,
	   	  	 	   				       INPUT par_dtmvtolt,
	   	  	 	   				       INPUT par_nrregist,
	   	  	 	   				       INPUT par_nriniseq,
	   	  	 	   				       INPUT par_flgerlog,
	   	  	 	   				       INPUT par_cddopcao,
	   	  	 	   				       INPUT par_tppessoa,
	   	  	 	   				       INPUT par_cdultrev,
	   	  	 	   				       INPUT par_dtinicio,
	   	  	 	   				       INPUT par_ddtfinal,
                                       INPUT par_cdempres,
	   	  	 	   				       INPUT par_tpdopcao,
	   	  	 	   				       INPUT par_dsadmcrd,
                                       INPUT par_situacao,
                                       INPUT par_cdcooper,
                                       INPUT par_lgvisual,
                                       INPUT par_dsiduser,
                                       INPUT par_nmarquiv,
	   	  	 	   				       OUTPUT par_qtregist,
	   	  	 	   				       OUTPUT par_nmdcampo,
	   	  	 	   				       OUTPUT par_nmarqimp,
	   	  	 	   				       OUTPUT par_nmarqpdf,
	   	  	 	   				       OUTPUT TABLE tt-cartoes,
	   	  	 	   				       OUTPUT TABLE tt-erro).

                   IF RETURN-VALUE <> "OK" THEN
                      DO:
                         IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Nao foi possivel " + 
                                                  "carregar informacoes.".
                      
                         LEAVE Busca.
                      
                      END.

	   	  	 	END.
	   	  	 ELSE
	   	  	 	DO: 
	   	  	 	   RUN carrega_dados_cartoes_bb_debito               
                                       (INPUT par_cdcooper,             
	   	  	 	   					    INPUT par_cdagenci,
	   	  	 	   					    INPUT par_nrdcaixa,
	   	  	 	   					    INPUT par_idorigem,
	   	  	 	   					    INPUT par_dtmvtolt,
	   	  	 	   					    INPUT par_cddopcao,
	   	  	 	   					    INPUT par_cdoperad,
                                        INPUT par_cdcooper,
                                        INPUT par_dsadmcrd,
                                        INPUT par_situacao,
                                        INPUT par_lgvisual,
	   	  	 	   					    INPUT par_dsiduser,                                        
                                        INPUT par_dtinicio,
                                        INPUT par_ddtfinal,
	   	  	 	   					    INPUT par_flgerlog,
	   	  	 	   					    INPUT par_nmdatela,
                                        INPUT par_nmarquiv,
	   	  	 	   					    OUTPUT par_nmarqimp,
	   	  	 	   					    OUTPUT par_nmarqpdf,
	   	  	 	   					    OUTPUT TABLE tt-cartoes,
                                        OUTPUT TABLE tt-erro).      

                   IF RETURN-VALUE <> "OK" THEN
                      DO:
                         IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Nao foi possivel " + 
                                                  "carregar informacoes.".
                     
                         LEAVE Busca.
                     
                      END.

	   	  	 	END.
             
	      END.                 

       ASSIGN aux_returnvl = "OK".

       LEAVE Busca.

    END. /* Busca */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           ASSIGN aux_returnvl = "NOK".    

           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog THEN
              RUN proc_gerar_log (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT NO,
                                  INPUT 1, /** idseqttl **/
                                  INPUT par_nmdatela,
                                  INPUT 0, /* nrdconta */
                                 OUTPUT aux_nrdrowid).
    
       END.
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* Busca_Dados_C */


/* -------------------------------------------------------------------------- */
/*                  EFETUA A BUSCA DAS MOVIMENTAÇÕES DA OPÇÃO F               */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Dados_F:

    DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_lgvisual AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtultdia AS DATE                                   NO-UNDO.
    DEF VAR aux_dtcalcul AS DATE                                   NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                   NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                   NO-UNDO.
    DEF VAR aux_nrparres AS DECI                                   NO-UNDO.
    DEF VAR aux_qtprecal AS DECIMAL                                NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                   NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                   NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                   NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                  NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                   NO-UNDO.
    DEF VAR aux_txdjuros AS DECI DECIMALS 7                        NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                   NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                   NO-UNDO.
    
    DEF VAR aux_vlsdeved AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"      NO-UNDO.
    DEF VAR aux_vljuracu AS DECI FORMAT "zzz,zzz,zz9.99-"          NO-UNDO.
    DEF VAR aux_vlprepag AS DECI                                   NO-UNDO.
    DEF VAR aux_qtmesdec AS DECI                                   NO-UNDO.
    DEF VAR aux_vlpreapg AS DECI                                   NO-UNDO.
    DEF VAR aux_vlprvenc AS DECI                                   NO-UNDO.
    DEF VAR aux_vlpraven AS DECI                                   NO-UNDO.
    DEF VAR aux_vlmtapar LIKE crappep.vlmtapar                     NO-UNDO.
    DEF VAR aux_vlmrapar LIKE crappep.vlmrapar                     NO-UNDO.
    DEF VAR aux_vlpreemp LIKE crapepr.vlpreemp                     NO-UNDO.
    DEF VAR aux_qtpreemp AS DECI                                   NO-UNDO.
    DEF VAR tab_diapagto AS INTE                                   NO-UNDO.
    DEF VAR aux_dtmesant AS DATE                                   NO-UNDO.
    DEF VAR aux_nrdiacal AS INTE                                   NO-UNDO.
    DEF VAR aux_vljurmes AS DECI                                   NO-UNDO.
    DEF VAR aux_inhst093 AS LOGI                                   NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                   NO-UNDO.
    DEF VAR aux_nrctremp AS INTE                                   NO-UNDO.
    DEF VAR aux_ddlanmto AS INTE                                   NO-UNDO.
    DEF VAR aux_dtultpag AS DATE                                   NO-UNDO.
    DEF VAR aux_qtprepag AS INTE                                   NO-UNDO.
    DEF VAR aux_nrdiames AS INTE                                   NO-UNDO.
    DEF VAR aux_nrdiamss AS INTE                                   NO-UNDO.
    DEF VAR aux_inusatab AS LOG                                    NO-UNDO.
    DEF VAR tab_dtcalcul AS DATE                                   NO-UNDO.
    DEF VAR tab_flgfolha AS LOGI                                   NO-UNDO.

    /*Variaveis para uso da b1wgen0002.i*/
    DEF VAR par_cdprogra AS CHAR                                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                 NO-UNDO.

    DEF BUFFER b-crawepr1 FOR crawepr.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Emprestimos em aberto da empresa"
           par_cdprogra = "".              

    EMPTY TEMP-TABLE tt-erro.

    Imprime:
    DO ON ERROR UNDO Imprime, LEAVE Imprime:

       FOR FIRST crapcop FIELDS(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:
       
       END.

       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Imprime.
          END.

       IF par_lgvisual = "A" AND
          par_nmarquiv = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nome do arquivo nao foi informado.".
             LEAVE Imprime.
          END.

       FOR FIRST crapemp FIELDS(crapemp.cdcooper crapemp.cdempres)
                         WHERE crapemp.cdcooper = par_cdcooper AND
                               crapemp.cdempres = par_cdempres 
                               NO-LOCK:

       END.

       IF NOT AVAILABLE crapemp THEN
          DO:
              ASSIGN aux_cdcritic = 40 
                     aux_dscritic = ""
                     par_nmdcampo = "".

              LEAVE Imprime.
  
          END.                                                                                           

       ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser
              aux_nmendter = aux_nmendter + STRING(TIME)    
              aux_nmarqimp = aux_nmendter + ".ex"          
              aux_nmarqpdf = aux_nmendter + ".pdf"
              aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + 
                             par_nmarquiv + ".txt".

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.

       /*** Inicializacao das variaveis para uso da b1wgen0002.i ***/
       FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                          craptab.nmsistem = "CRED"        AND
                          craptab.tptabela = "USUARI"      AND
                          craptab.cdempres = 11            AND
                          craptab.cdacesso = "TAXATABELA"  AND
                          craptab.tpregist = 0             
                          NO-LOCK NO-ERROR.

       IF NOT AVAILABLE craptab   THEN
          ASSIGN aux_inusatab = FALSE.
       ELSE
          ASSIGN aux_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0" THEN
                                   FALSE
                                ELSE 
                                   TRUE.

       FOR EACH crapttl FIELDS (cdcooper nrdconta) 
                         WHERE crapttl.cdcooper = crapemp.cdcooper AND
                               crapttl.idseqttl = 1                AND
                               crapttl.cdempres = crapemp.cdempres
                               NO-LOCK,

           EACH crapass FIELDS (cdtipsfx cdagenci nrdconta nmprimtl)
                         WHERE crapass.cdcooper = crapttl.cdcooper AND
                               crapass.nrdconta = crapttl.nrdconta 
                               NO-LOCK, 

           EACH b-crawepr1 FIELDS (nrctremp)
                            WHERE b-crawepr1.cdcooper = crapttl.cdcooper AND
                                  b-crawepr1.nrdconta = crapttl.nrdconta 
                                  NO-LOCK,

           EACH crapepr FIELDS (cdlcremp txjuremp nrdconta nrctremp vlsdeved
                                vljuracu qtprepag inliquid qtprecal qtpreemp
                                vlpreemp qttolatr vlemprst dtdpagto txmensal
                                qtmesdec tpemprst cdempres flgpagto dtmvtolt) 
                         WHERE crapepr.cdcooper = crapttl.cdcooper    AND
                               crapepr.nrdconta = crapttl.nrdconta    AND
                               crapepr.nrctremp = b-crawepr1.nrctremp AND
                               crapepr.inliquid = 0 
                               NO-LOCK:

           /* Inicialiazacao das variaves para a rotina de calculo */
           FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                              craptab.nmsistem = "CRED"         AND
                              craptab.tptabela = "GENERI"       AND
                              craptab.cdempres = 00             AND
                              craptab.cdacesso = "DIADOPAGTO"   AND
                              craptab.tpregist = par_cdempres 
                              NO-LOCK NO-ERROR.

           IF NOT AVAILABLE craptab   THEN
              DO:
                 ASSIGN aux_cdcritic = 55 
                        aux_dscritic = ""
                        par_nmdcampo = "".

                 LEAVE Imprime.

              END.

           IF CAN-DO("1,3,4",STRING(crapass.cdtipsfx))   THEN
              ASSIGN tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)). /* Mensal */
           ELSE
              ASSIGN tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)). /* Horis. */
    
           /* Verifica se data pagamento da empresa cai num dia util */
           ASSIGN tab_dtcalcul = DATE(MONTH(par_dtmvtolt),
                                            tab_diapagto,
                                 YEAR(par_dtmvtolt)).

           Calc: 
           DO WHILE TRUE:

              IF WEEKDAY(tab_dtcalcul) = 1  OR
                 WEEKDAY(tab_dtcalcul) = 7  THEN
                 DO:
                    ASSIGN tab_dtcalcul = tab_dtcalcul + 1.
                    NEXT Calc.
                 END.
           
              FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                 crapfer.dtferiad = tab_dtcalcul  
                                 NO-LOCK NO-ERROR.
         
              IF AVAILABLE crapfer   THEN
                 DO:
                     ASSIGN tab_dtcalcul = tab_dtcalcul + 1.
                     NEXT Calc.
                 END.
           
              ASSIGN tab_diapagto = DAY(tab_dtcalcul).
                
              LEAVE Calc.
                
           END.  /*  Fim do DO WHILE TRUE  */
         
           ASSIGN tab_flgfolha = IF SUBSTRING(craptab.dstextab,14,1) = "0" THEN
                                    FALSE
                                 ELSE 
                                    TRUE.

           IF aux_inusatab THEN
              DO:
                 FOR FIRST craplcr FIELDS(craplcr.txdiaria)
                                   WHERE craplcr.cdcooper = par_cdcooper AND
                                         craplcr.cdlcremp = crapepr.cdlcremp
                                         NO-LOCK:

                     ASSIGN aux_txdjuros = craplcr.txdiaria.

                 END.

                 IF NOT AVAILABLE craplcr THEN
                    NEXT.
                 
              END.
           ELSE
              ASSIGN aux_txdjuros = crapepr.txjuremp.
         
           ASSIGN aux_nrdconta = crapepr.nrdconta
                  aux_nrctremp = crapepr.nrctremp
                  aux_vlsdeved = crapepr.vlsdeved
                  aux_vljuracu = crapepr.vljuracu
                  aux_qtprepag = crapepr.qtprepag
                  aux_qtprecal = IF crapepr.inliquid = 0 THEN 
                                    crapepr.qtprecal
                                 ELSE
                                    crapepr.qtpreemp           
                  aux_dtcalcul = ?
                  aux_dtultdia = ((DATE(MONTH(par_dtmvtolt),28,
                                        YEAR(par_dtmvtolt)) + 4) -
                                        DAY(DATE(
                                            MONTH(par_dtmvtolt),28,
                                            YEAR(par_dtmvtolt)) + 4)).

                                      
           /* Calcular o valor em atraso */
           { sistema/generico/includes/b1wgen0002.i }

           ASSIGN aux_nrparres = IF crapepr.qtpreemp < aux_qtprecal THEN
                                    0
                                 ELSE 
                                    crapepr.qtpreemp - aux_qtprecal.

           DISPLAY STREAM str_1 
                   crapass.cdagenci COLUMN-LABEL "PA"
                   crapass.nrdconta COLUMN-LABEL "Conta/Dv" 
                   crapass.nmprimtl COLUMN-LABEL "Associado" 
                                    FORMAT "x(40)"
                   crapepr.nrctremp COLUMN-LABEL "Contrato"
                   aux_nrparres     COLUMN-LABEL "Faltam"    
                                    FORMAT "zzz,zzz"
                   crapepr.vlpreemp COLUMN-LABEL "Prestacao"
                                    FORMAT "z,zz9.99"
                   aux_vlsdeved     COLUMN-LABEL "Saldo Devedor"
                   WITH WIDTH 132 NO-BOX.
           
       END.

       OUTPUT STREAM str_1 CLOSE.

       ASSIGN par_nmarqimp = aux_nmarqimp.

       IF par_lgvisual = "A" THEN
          DO: 
             UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + 
                               aux_nmarquiv).
                     
             IF SEARCH(aux_nmarqimp) <> ? THEN
                UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

          END.
       ELSE 
          DO:
             IF par_idorigem = 5  THEN  /** Ayllos Web **/                     
                DO: 
                   IF NOT VALID-HANDLE(h-b1wgen0024) THEN
                      RUN sistema/generico/procedures/b1wgen0024.p 
                          PERSISTENT SET h-b1wgen0024. 
                                                                              
                   IF NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                      DO:                                                    
                         ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                               "b1wgen0024.".               
                         LEAVE Imprime.                                     
                      END.                                                   
                                                                              
                   RUN envia-arquivo-web IN h-b1wgen0024                      
                       ( INPUT par_cdcooper,                                  
                         INPUT par_cdagenci,                                  
                         INPUT par_nrdcaixa,                                  
                         INPUT aux_nmarqimp,                                  
                        OUTPUT par_nmarqpdf,                                  
                        OUTPUT TABLE tt-erro ).                               
                                                                              
                   IF VALID-HANDLE(h-b1wgen0024)  THEN                       
                      DELETE PROCEDURE h-b1wgen0024.                         
                                                                             
                   IF RETURN-VALUE <> "OK" THEN                              
                      LEAVE Imprime.

                END.
          END.

       LEAVE Imprime.

    END. /* Imprime */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO: 
          ASSIGN aux_returnvl = "NOK".    

          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
    
          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* Gera_Dados_F */


/* -------------------------------------------------------------------------- */
/*                  EFETUA A BUSCA DAS MOVIMENTAÇÕES DA OPÇÃO L               */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Dados_L:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_ddtfinal AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_lgvisual AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                            NO-UNDO.
                                         
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtrefere AS CHAR EXTENT 3                           NO-UNDO.
    DEF VAR aux_qtlibera AS INTE EXTENT 3                           NO-UNDO.
    DEF VAR aux_qtacesso AS INTE EXTENT 3                           NO-UNDO.
    DEF VAR aux_qtacetri AS INTE EXTENT 3                           NO-UNDO.
    DEF VAR aux_qtcopace AS INTE                                    NO-UNDO.    
                                                                    
    DEF VAR aux_idseqttl AS INTE                                    NO-UNDO.
    DEF VAR aux_qttitula AS INTE                                    NO-UNDO.
    DEF VAR aux_qtlibnet AS INTE                                    NO-UNDO.
    DEF VAR aux_qtlibbol AS INTE                                    NO-UNDO.
    DEF VAR aux_qtlibura AS INTE                                    NO-UNDO.
                                                                    
    DEF VAR tmp_dtrefere AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_dia      AS DATE                                    NO-UNDO.

    FORM crapcop.nmrescop NO-LABEL
	   	SKIP(1)
		aux_dtrefere[1] NO-LABEL FORMAT "x(7)"    AT 26
		aux_dtrefere[2] NO-LABEL FORMAT "x(7)"    AT 37
		aux_dtrefere[3] NO-LABEL FORMAT "x(7)"    AT 48
		SKIP
		"-------    -------    -------" AT 26
		SKIP
		"Liberacoes de acesso:"
		aux_qtlibera[1] NO-LABEL FORMAT "zzzzzz,zz9" AT 23
		aux_qtlibera[2] NO-LABEL FORMAT "zzzzzz,zz9"
		aux_qtlibera[3] NO-LABEL FORMAT "zzzzzz,zz9"
		SKIP
		"Contas que acessaram:"
		aux_qtacetri[1] NO-LABEL FORMAT "zzzzzz,zz9" AT 23
		aux_qtacetri[2] NO-LABEL FORMAT "zzzzzz,zz9"
		aux_qtacetri[3] NO-LABEL FORMAT "zzzzzz,zz9"
		SKIP
		"    Total de acessos:"
		aux_qtacesso[1] NO-LABEL FORMAT "zzzzzz,zz9" AT 23
		aux_qtacesso[2] NO-LABEL FORMAT "zzzzzz,zz9"
		aux_qtacesso[3] NO-LABEL FORMAT "zzzzzz,zz9"
		SKIP(1)
		aux_qtcopace LABEL "Cooperados com acesso liberado" FORMAT "zzzzzz,zz9"
		SKIP(2)
        WITH NO-BOX SIDE-LABELS FRAME f_totais.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Qtde liberacoes para uso Internet, emissao " + 
                          "boletos e Ura no periodo".              

    EMPTY TEMP-TABLE tt-erro.
    
    Imprime:
    DO ON ERROR UNDO Imprime, LEAVE Imprime:

	   FOR FIRST crapcop FIELDS(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:
       
       END.

       IF NOT AVAIL crapcop THEN
          DO:
             ASSIGN aux_cdcritic = 651.
             LEAVE Imprime.
          END.
                                                                                          
       IF par_lgvisual = "A" AND
          par_nmarquiv = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nome do arquivo nao foi informado.".
             LEAVE Imprime.
          END.

       IF par_dtinicio = ? THEN 
          DO:
             ASSIGN aux_cdcritic = 0 
                    aux_dscritic = "Informe a data inicial."
                    par_nmdcampo = "".

             LEAVE Imprime.

          END.

       IF par_ddtfinal = ? THEN 
          DO:
             ASSIGN aux_cdcritic = 0 
                    aux_dscritic = "Informe a data final"
                    par_nmdcampo = "".

             LEAVE Imprime.

           END.

       ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser
              aux_nmendter = aux_nmendter + STRING(TIME)      
              aux_nmarqimp = aux_nmendter + ".ex"             
              aux_nmarqpdf = aux_nmendter + ".pdf"
              aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + 
                             par_nmarquiv
              aux_nmarquiv = aux_nmarquiv + ".txt".

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

       IF par_cdcooper = 3 THEN
          DO:

             FOR EACH crapcop FIELDS(cdcooper nmrescop) NO-LOCK:
                 
                 ASSIGN aux_qtcopace = 0.
          
                 FOR EACH crapass FIELDS(cdcooper nrdconta inpessoa idastcjt) 
                                  WHERE crapass.cdcooper = crapcop.cdcooper AND
                                        crapass.dtdemiss = ? 
                                        NO-LOCK:
          
                     FOR EACH crapsnh FIELDS( cdcooper )
                         WHERE crapsnh.cdcooper = crapass.cdcooper AND
                               crapsnh.nrdconta = crapass.nrdconta AND
                               crapsnh.tpdsenha = 1                AND
                               crapsnh.cdsitsnh = 1                
                               NO-LOCK:
          
                         ASSIGN aux_qtcopace = aux_qtcopace + 1.
          
                     END.
          
                     IF crapass.inpessoa = 1  THEN
                     DO:
                       FIND LAST crapttl WHERE 
                           crapttl.cdcooper = crapass.cdcooper AND
                           crapttl.nrdconta = crapass.nrdconta NO-LOCK.
                        
                        ASSIGN aux_qttitula = crapttl.idseqttl.

                     END.
                     ELSE
                     DO:

                        IF crapass.idastcjt = 0 THEN
                          ASSIGN aux_qttitula = 1.
                        ELSE
                        DO:
                            
                            FIND LAST crapsnh
                             WHERE crapsnh.cdcooper = crapass.cdcooper
                               AND crapsnh.nrdconta = crapass.nrdconta
                               AND crapsnh.tpdsenha = 1
                               NO-LOCK NO-ERROR.
    
                            IF  AVAIL crapsnh  THEN
                                ASSIGN aux_qttitula = crapsnh.idseqttl.
                            ELSE
                                NEXT.
                        END.

                     END.
                        
          
                     DO aux_idseqttl = 1 TO aux_qttitula:

                       DO aux_dia = par_dtinicio TO par_ddtfinal:

                        FOR EACH craplgm FIELDS(nrdconta dttransa dstransa)
                                 WHERE craplgm.cdcooper = crapass.cdcooper AND
                                       craplgm.nrdconta = crapass.nrdconta AND
                                       craplgm.idseqttl = aux_idseqttl     AND
                                       craplgm.dttransa = aux_dia          AND
                                       craplgm.flgtrans = TRUE             AND
                                       (craplgm.nmdatela = "ATENDA" OR
                                        craplgm.nmdatela = "INTERNETBANK")
                                       USE-INDEX craplgm4 NO-LOCK:
          
                            IF craplgm.nmdatela = "ATENDA" AND 
                               (craplgm.dstransa = "Internet - Liberacao"  OR 
                                craplgm.dstransa = "Liberar senha de acesso ao InternetBank")  THEN
                            DO:
                                CREATE tt-craplgm1.
                                ASSIGN tt-craplgm1.nrdconta = craplgm.nrdconta
                                     tt-craplgm1.dttransa = craplgm.dttransa.
                            END.
                            ELSE IF craplgm.nmdatela = "INTERNETBANK" AND 
                                   (craplgm.dstransa = 
                                    "Efetuado login de acesso a conta on-line."  OR 
                                    craplgm.dstransa = 
                                    "Cadastrar frase secreta para acesso a conta on-line")
                                    THEN
                            DO:
                                CREATE tt-craplgm2.
                                ASSIGN tt-craplgm2.nrdconta = craplgm.nrdconta
                                       tt-craplgm2.dttransa = craplgm.dttransa.
                            END.
          
                        END. /* Fim do FOR EACH craplgm */


                       END. /* Fim DO .. TO data */
                     END. /* Fim do DO .. TO */
          
                 END. /* Fim do FOR EACH crapass */
          
                 FOR EACH tt-craplgm1 NO-LOCK:
          
                     ASSIGN tmp_dtrefere = STRING(MONTH(tt-craplgm1.dttransa),"99") + "/" +
                                           STRING(YEAR(tt-craplgm1.dttransa),"9999").
          
                     FIND tt-dados WHERE tt-dados.dtrefere = tmp_dtrefere
                                         EXCLUSIVE-LOCK NO-ERROR.
          
                     IF NOT AVAIL tt-dados  THEN
                        DO:
                           CREATE tt-dados.
                           ASSIGN tt-dados.dtrefere = tmp_dtrefere.
                        END.    
          
                     ASSIGN tt-dados.qtlibera = tt-dados.qtlibera + 1.
          
                 END. /* Fim do FOR EACH tt-craplgm1 */
          
                 FOR EACH tt-craplgm2 NO-LOCK:
          
                     ASSIGN tmp_dtrefere = STRING(MONTH(tt-craplgm2.dttransa),"99") + "/" +
                                           STRING(YEAR(tt-craplgm2.dttransa),"9999").
          
                     FIND tt-dados WHERE tt-dados.dtrefere = tmp_dtrefere
                                         EXCLUSIVE-LOCK NO-ERROR.
          
                     IF NOT AVAIL tt-dados THEN
                        DO:
                           CREATE tt-dados.
                           ASSIGN tt-dados.dtrefere = tmp_dtrefere.
                        END.    
          
                     ASSIGN tt-dados.qtacesso = tt-dados.qtacesso + 1.
          
                     FIND tt-acesso-trimestre WHERE 
                          tt-acesso-trimestre.dtrefere = tmp_dtrefere         AND
                          tt-acesso-trimestre.nrdconta = tt-craplgm2.nrdconta
                          NO-LOCK NO-ERROR.
          
                     IF NOT AVAIL tt-acesso-trimestre  THEN
                        DO:
                           CREATE tt-acesso-trimestre.
                           ASSIGN tt-acesso-trimestre.dtrefere = tmp_dtrefere
                                  tt-acesso-trimestre.nrdconta = tt-craplgm2.nrdconta.
                        END.
          
                 END. /* Fim do FOR EACH tt-craplgm2 */

                 ASSIGN aux_dtrefere = ""
                        aux_qtlibera = 0
                        aux_qtacesso = 0
                        aux_contador = 0.
          
                 FOR EACH tt-dados NO-LOCK:
          
                     ASSIGN aux_contador = aux_contador + 1
                            aux_dtrefere[aux_contador] = tt-dados.dtrefere
                            aux_qtlibera[aux_contador] = tt-dados.qtlibera
                            aux_qtacesso[aux_contador] = tt-dados.qtacesso.
          
                 END. /* Fim do FOR EACH tt-dados */
          
                 ASSIGN aux_qtacetri = 0
                        aux_contador = 0.
          
                 FOR EACH tt-acesso-trimestre 
                          NO-LOCK BREAK BY tt-acesso-trimestre.dtrefere:
          
                     IF FIRST-OF(tt-acesso-trimestre.dtrefere)  THEN
                        ASSIGN aux_contador = aux_contador + 1.

                     ASSIGN aux_qtacetri[aux_contador] = aux_qtacetri[aux_contador] + 1.
          
                 END. /* Fim do FOR EACH tt-acesso-trimestre */

                 EMPTY TEMP-TABLE tt-craplgm1.
                 EMPTY TEMP-TABLE tt-craplgm2.
                 EMPTY TEMP-TABLE tt-dados.
                 EMPTY TEMP-TABLE tt-acesso-trimestre.

                 DISPLAY STREAM str_1 crapcop.nmrescop 
                                      aux_dtrefere
                                      aux_qtlibera   
                                      aux_qtacesso
                                      aux_qtacetri     
                                      aux_qtcopace
                                      WITH FRAME f_totais.
                 DOWN WITH FRAME f_totais.
                 
                 ASSIGN aux_dtrefere = ""
                        aux_qtlibera = 0   
                        aux_qtacesso = 0
                        aux_qtacetri = 0
                        aux_dtrefere[1] = ""
                        aux_dtrefere[2] = ""
                        aux_dtrefere[3] = ""
                        aux_qtlibera[1] = 0
                        aux_qtlibera[2] = 0
                        aux_qtlibera[3] = 0
                        aux_qtacesso[1] = 0
                        aux_qtacesso[2] = 0
                        aux_qtacesso[3] = 0
                        aux_qtacetri[1] = 0
                        aux_qtacetri[2] = 0
                        aux_qtacetri[3] = 0
                        aux_contador    = 0
                        aux_qtcopace    = 0.

             END. /* Fim do FOR EACH crapcop */ 
              
          END.
       ELSE
          DO:
             FOR EACH crapass FIELDS(cdagenci cdcooper nrdconta inpessoa)
                              WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.dtdemiss = ? AND
                                    crapass.cdagenci = 1
                                    NO-LOCK BREAK BY crapass.cdagenci:

                  IF FIRST-OF(crapass.cdagenci)  THEN
                     ASSIGN aux_qtlibnet = 0
                            aux_qtlibbol = 0
                            aux_qtlibura = 0.

                  IF crapass.inpessoa = 1  THEN
                     DO:
                        ASSIGN aux_qttitula = 0.

                        FOR EACH crapttl FIELDS(cdcooper)
                            WHERE crapttl.cdcooper = par_cdcooper AND
                                  crapttl.nrdconta = crapass.nrdconta
                                  NO-LOCK:

                            ASSIGN aux_qttitula = aux_qttitula + 1.

                        END.
                     END.
                  ELSE
                     ASSIGN aux_qttitula = 1.
              
                  DO aux_idseqttl = 1 TO aux_qttitula:

	   	   		     FOR EACH craplgm FIELDS(dstransa cdcooper nrdconta 
                                             idseqttl nrsequen dttransa 
                                             hrtransa)
	   	   		        WHERE craplgm.cdcooper = crapass.cdcooper AND
                              craplgm.nrdconta = crapass.nrdconta AND
                              craplgm.idseqttl = aux_idseqttl     AND
                              craplgm.nmdatela = "ATENDA"         AND
                              craplgm.dttransa >= par_dtinicio    AND
                              craplgm.dttransa <= par_ddtfinal    AND
                              craplgm.flgtrans  = TRUE
                              USE-INDEX craplgm2 NO-LOCK:
                     
                            /* Descricao antiga */
	   	   		     	IF craplgm.dstransa = "Internet - Liberacao"      OR
	   	   		     	   /* Descricao nova   */
                           craplgm.dstransa =
                                "Liberar senha de acesso ao InternetBank" THEN
                            ASSIGN aux_qtlibnet = aux_qtlibnet + 1.
                     
	   	   		     	IF craplgm.dstransa = "Incluir/Alterar convenio " +
                                              "de cobranca."               OR
                           craplgm.dstransa
                             MATCHES "Incluir convenio de cobranca*"       OR
                           craplgm.dstransa
                             MATCHES "Alterar convenio de cobranca*"       THEN
                           DO:
                              FOR EACH craplgi FIELDS( nmdcampo dsdadatu)
                                 WHERE craplgi.cdcooper = craplgm.cdcooper AND
                                       craplgi.nrdconta = craplgm.nrdconta AND
                                       craplgi.idseqttl = craplgm.idseqttl AND
                                       craplgi.nrsequen = craplgm.nrsequen AND
                                       craplgi.dttransa = craplgm.dttransa AND
                                       craplgi.hrtransa = craplgm.hrtransa
                                       USE-INDEX craplgi1 NO-LOCK:
                     
                                  IF craplgi.nmdcampo = "insitceb" AND
                                     craplgi.dsdadatu = "ATIVO"    THEN
                                     ASSIGN aux_qtlibbol = aux_qtlibbol + 1.
                     
                              END. /* fim for each craplgi */

                           END.
                     
	   	   		     END. /* fim for each craplgm */
              
	   	   		     FOR FIRST crapsnh 
                               FIELDS(crapsnh.dtaltsnh crapsnh.dtlibera)
                               WHERE crapsnh.cdcooper = crapass.cdcooper AND
                                     crapsnh.nrdconta = crapass.nrdconta AND
                                     crapsnh.tpdsenha = 2                AND
                                     crapsnh.idseqttl = 0                
                                     USE-INDEX crapsnh1 NO-LOCK:
                   
                         IF crapsnh.dtaltsnh >= par_dtinicio     AND
                            crapsnh.dtaltsnh <= par_ddtfinal     AND
                            crapsnh.dtaltsnh <> crapsnh.dtlibera THEN
                            ASSIGN aux_qtlibura = aux_qtlibura + 1.
                  
                     END.
                  
                  END. 

                  IF LAST-OF(crapass.cdagenci) THEN
                     DISPLAY STREAM str_1
                         crapass.cdagenci COLUMN-LABEL "PA"
                                          FORMAT "zz9"
                         aux_qtlibnet     COLUMN-LABEL "INTERNETBANK"
                                          FORMAT "zzz,zzz,zz9"
                         aux_qtlibbol     COLUMN-LABEL "BOLETOS"
                                          FORMAT "zzz,zzz,zz9"
                         aux_qtlibura     COLUMN-LABEL "URA (0800)"
                                          FORMAT "zzz,zzz,zz9"
                     WITH WIDTH 132 NO-BOX.

              END. /* fim for each crapass */
              
          END.

       OUTPUT STREAM str_1 CLOSE.

       ASSIGN par_nmarqimp = aux_nmarqimp.

       IF par_lgvisual = "A"  THEN
          DO:
             UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + 
                                aux_nmarquiv).

             IF SEARCH(aux_nmarqimp) <> ? THEN
                UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

          END.
       ELSE 
          DO:
             IF par_idorigem = 5  THEN  /** Ayllos Web **/                     
                DO: 
                   RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT    
                       SET h-b1wgen0024.                                      
                                                                              
                   IF NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                      DO:                                                    
                         ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                               "b1wgen0024.".               
                         LEAVE Imprime.                                     

                      END.                                                   
                                                                              
                   RUN envia-arquivo-web IN h-b1wgen0024                      
                       ( INPUT par_cdcooper,                                  
                         INPUT par_cdagenci,                                  
                         INPUT par_nrdcaixa,                                  
                         INPUT aux_nmarqimp,                                  
                        OUTPUT par_nmarqpdf,                                  
                        OUTPUT TABLE tt-erro ).                               
                                                                              
                   IF VALID-HANDLE(h-b1wgen0024)  THEN                       
                      DELETE PROCEDURE h-b1wgen0024.                         
                                                                              
                   IF RETURN-VALUE <> "OK" THEN                              
                      RETURN "NOK".                                       

                END.

          END.

       LEAVE Imprime.

    END. /* Imprime */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          ASSIGN aux_returnvl = "NOK".    

          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
    
          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* Gera_Dados_L */

/* -------------------------------------------------------------------------- */
/*                  EFETUA A BUSCA DAS MOVIMENTAÇÕES DA OPÇÃO R               */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Dados_R:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tppessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdultrev AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_lgvisual AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR flg_imprimi  AS LOGI                                    NO-UNDO.
    DEF VAR flg_crapalt  AS LOGI                                    NO-UNDO.
    DEF VAR aux_dtaltera AS DATE                                    NO-UNDO.
    DEF VAR aux_data     AS DATE                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_telresid LIKE craptfc.nrtelefo                      NO-UNDO.
    DEF VAR aux_telcelul LIKE craptfc.nrtelefo                      NO-UNDO.
    DEF VAR aux_telcomer LIKE craptfc.nrtelefo                      NO-UNDO.
    DEF VAR aux_telconta LIKE craptfc.nrtelefo                      NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cooperados e data do ultimo recadastramento".              

    EMPTY TEMP-TABLE tt-erro.
    
    Imprime:
    DO ON ERROR UNDO Imprime, LEAVE Imprime:

       FOR FIRST crapcop FIELDS(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:

       END.
       
       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Imprime.
          END.

       IF par_lgvisual = "A" AND
          par_nmarquiv = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nome do arquivo nao foi informado.".
             LEAVE Imprime.
          END.
                                                                                          
       ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser
              aux_nmendter = aux_nmendter + STRING(TIME)       
              aux_nmarqimp = aux_nmendter + ".ex"          
              aux_nmarqpdf = aux_nmendter + ".pdf"
              aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + 
                             par_nmarquiv
              aux_nmarquiv = aux_nmarquiv + ".txt".

       IF par_cdultrev <= 0 THEN 
          DO:
             ASSIGN aux_cdcritic = 0 
                    aux_dscritic = "O período deve ser superior a 0."
                    par_nmdcampo = "".

             LEAVE Imprime.

          END.

       IF (NOT CAN-FIND(crapage WHERE crapage.cdcooper = par_cdcooper AND
                                      crapage.cdagenci = par_cdagenca
                                      NO-LOCK))                       THEN 
          DO:
              ASSIGN aux_cdcritic = 0 
                     aux_dscritic = "PA nao cadastrado."
                     par_nmdcampo = "".

              LEAVE Imprime.

          END.

       IF par_tppessoa <> 1 AND 
          par_tppessoa <> 2 THEN 
          DO:
              ASSIGN aux_cdcritic = 014 
                     aux_dscritic = ""
                     par_nmdcampo = "".

              LEAVE Imprime.

           END.

       ASSIGN flg_imprimi = NO
	   	      aux_data    = DATE(STRING("01") + STRING(MONTH(par_dtmvtolt - 
                                                (30 * par_cdultrev)),"99") +
                           STRING(YEAR(par_dtmvtolt - 
                                       (30 * par_cdultrev)),"9999")).

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

       FOR EACH crapass FIELDS( cdcooper nrdconta cdagenci nmprimtl dtadmiss )
                        WHERE crapass.cdcooper = par_cdcooper  AND
                              crapass.cdagenci = par_cdagenca  AND
                              crapass.inpessoa = par_tppessoa  AND
                              crapass.dtdemiss = ?             AND
                              crapass.dtadmiss < aux_data
                              USE-INDEX crapass2
                              NO-LOCK:

           ASSIGN flg_crapalt = FALSE.

           FOR LAST crapalt FIELDS(dtaltera) 
                            WHERE crapalt.cdcooper = crapass.cdcooper AND
                                  crapalt.nrdconta = crapass.nrdconta AND
                                  crapalt.tpaltera = 1
                                  NO-LOCK:

               ASSIGN flg_crapalt = TRUE.
           
               IF crapalt.dtaltera < aux_data THEN
                  ASSIGN aux_dtaltera = crapalt.dtaltera
                         flg_imprimi  = YES.

           END.

           IF flg_crapalt = FALSE THEN 
              ASSIGN aux_dtaltera = ?
                     flg_imprimi  = YES.

           IF flg_imprimi = NO THEN
              NEXT.

           ASSIGN aux_telresid = 0
                  aux_telcelul = 0
                  aux_telcomer = 0
                  aux_telconta = 0.
           
           FOR FIRST craptfc FIELDS(nrtelefo) 
                             WHERE craptfc.cdcooper = crapass.cdcooper AND
                                   craptfc.nrdconta = crapass.nrdconta AND
                                   craptfc.tptelefo = 1 
                                   NO-LOCK:
           
               ASSIGN aux_telresid = craptfc.nrtelefo.

           END.
             
           FOR FIRST craptfc FIELDS(nrtelefo) 
                             WHERE craptfc.cdcooper = crapass.cdcooper AND
                                   craptfc.nrdconta = crapass.nrdconta AND
                                   craptfc.tptelefo = 2 
                                   NO-LOCK:
                                   
               ASSIGN aux_telcelul = craptfc.nrtelefo.

           END.
                 
           FOR FIRST craptfc FIELDS(nrtelefo) 
                             WHERE craptfc.cdcooper = crapass.cdcooper AND
                                   craptfc.nrdconta = crapass.nrdconta AND
                                   craptfc.tptelefo = 3 
                                   NO-LOCK:
           
               ASSIGN aux_telcomer = craptfc.nrtelefo.

           END.

           FOR FIRST craptfc FIELDS(nrtelefo) 
                             WHERE craptfc.cdcooper = crapass.cdcooper AND
                                   craptfc.nrdconta = crapass.nrdconta AND
                                   craptfc.tptelefo = 4                    
                                   NO-LOCK:
           
               ASSIGN aux_telconta = craptfc.nrtelefo.

           END.

           IF flg_imprimi THEN
              DISPLAY STREAM str_1 
                  crapass.cdagenci COLUMN-LABEL "PA"
                  crapass.nrdconta COLUMN-LABEL "Conta"
                  crapass.nmprimtl COLUMN-LABEL "Nome" FORMAT "x(35)"
                  crapass.dtadmiss COLUMN-LABEL "Admissao"
                  aux_dtaltera     COLUMN-LABEL "Ult. Recadastro"
                  aux_telresid     COLUMN-LABEL "Residencial"
                  aux_telcelul     COLUMN-LABEL "Celular"
                  aux_telcomer     COLUMN-LABEL "Comercial"
                  aux_telconta     COLUMN-LABEL "Contato"
                  WITH WIDTH 132 NO-BOX.
               
           ASSIGN flg_imprimi = NO.
               
       END. /* Fim for each crapass */

       OUTPUT STREAM str_1 CLOSE.

       ASSIGN par_nmarqimp = aux_nmarqimp.

       IF par_lgvisual = "A"  THEN
          DO:
             UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + 
                                aux_nmarquiv).

             IF SEARCH(aux_nmarqimp) <> ? THEN
                UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

          END.
       ELSE 
          DO:
             IF par_idorigem = 5  THEN  /** Ayllos Web **/                     
                DO: 
                   RUN sistema/generico/procedures/b1wgen0024.p 
                       PERSISTENT SET h-b1wgen0024.                                      
                                                                              
                   IF NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                      DO:                                                    
                          ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                                "b1wgen0024.".               
                          LEAVE Imprime.                                     
                      END.                                                   
                                                                              
                   RUN envia-arquivo-web IN h-b1wgen0024                      
                       ( INPUT par_cdcooper,                                  
                         INPUT par_cdagenci,                                  
                         INPUT par_nrdcaixa,                                  
                         INPUT aux_nmarqimp,                                  
                        OUTPUT par_nmarqpdf,                                  
                        OUTPUT TABLE tt-erro ).                               
                                                                              
                   IF VALID-HANDLE(h-b1wgen0024)  THEN                       
                      DELETE PROCEDURE h-b1wgen0024.                         
                                                                             
                   IF RETURN-VALUE <> "OK" THEN                              
                      RETURN "NOK".                                       

                END.

          END.

       LEAVE Imprime.

    END. /* Imprime */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          ASSIGN aux_returnvl = "NOK".    

          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
   
END PROCEDURE. /* Gera_Dados_R */

/* -------------------------------------------------------------------------- */
/*                  EFETUA A BUSCA DAS MOVIMENTAÇÕES DA OPÇÃO S               */
/* -------------------------------------------------------------------------- */

PROCEDURE Gera_Dados_S:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_tppessoa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_ddtfinal AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_cdempres AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_tpcontas AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_lgvisual AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_cdagenca AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtmvtolt AS DATE FORMAT "99/99/9999"                  NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                      NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                     NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_telresid LIKE craptfc.nrtelefo                        NO-UNDO.
    DEF VAR aux_telcelul LIKE craptfc.nrtelefo                        NO-UNDO.
    DEF VAR aux_telcomer LIKE craptfc.nrtelefo                        NO-UNDO.
    DEF VAR aux_telconta LIKE craptfc.nrtelefo                        NO-UNDO.
    DEF VAR aux_dssitdct AS CHAR FORMAT "x(13)"                       NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                      NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Contas sem movimentacao a mais de seis meses no PA".              

    EMPTY TEMP-TABLE tt-erro.
    
    Imprime:
    DO ON ERROR UNDO Imprime, LEAVE Imprime:

       FOR FIRST crapcop FIELDS(crapcop.dsdircop crapcop.cdcooper )
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:
       
       END.

       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Imprime.
          END.

       FOR FIRST crapage FIELDS(crapage.cdagenci)
                         WHERE crapage.cdcooper = crapcop.cdcooper AND
                               crapage.cdagenci = par_cdagenca 
                               NO-LOCK:

       END.

       IF NOT AVAIL crapage  THEN
          DO:
              ASSIGN aux_cdcritic = 962.
              LEAVE Imprime.
          END.

       IF par_lgvisual = "A" AND
          par_nmarquiv = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nome do arquivo nao foi informado.".
             LEAVE Imprime.
          END.

       ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser
	   	      aux_nmendter = aux_nmendter + STRING(TIME)          
              aux_nmarqimp = aux_nmendter + ".ex"          
              aux_nmarqpdf = aux_nmendter + ".pdf"
              aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + 
                             par_nmarquiv
              aux_nmarquiv = aux_nmarquiv + ".txt".

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

       ASSIGN aux_dtmvtolt = DATE(STRING("01")
                            + STRING(MONTH(par_dtmvtolt - 180 ),"99")
                            + STRING(YEAR(par_dtmvtolt - 180 ),"9999")).
       
	   FOR EACH crapass FIELDS(cdcooper nrdconta cdsitdct 
                               cdagenci dtmvtolt nmprimtl 
                               cdtipcta )  
                WHERE (IF par_tpcontas = "TODAS"  THEN
         	   	           (crapass.cdcooper = par_cdcooper  AND
	     	   	            crapass.cdagenci = par_cdagenca  AND
	     	   	            crapass.dtdemiss = ?               )
	                   ELSE
	     	               (crapass.cdcooper = par_cdcooper  AND
	         	            crapass.cdagenci = par_cdagenca  AND
	   	   	            crapass.dtdemiss = ?             AND
	         	            crapass.flgctitg = 2  ))
	                   USE-INDEX crapass2 NO-LOCK,

	       LAST craplcm FIELDS(dtmvtolt)
	                    WHERE craplcm.cdcooper = crapass.cdcooper AND
	       	                craplcm.nrdconta = crapass.nrdconta
	       	                NO-LOCK USE-INDEX craplcm2
	       	                BREAK BY crapass.cdagenci:
                        
	            IF craplcm.dtmvtolt > aux_dtmvtolt   THEN
	               NEXT.
                
	            ASSIGN aux_telresid = 0
	            	     aux_telcelul = 0
	            	     aux_telcomer = 0
	            	     aux_telconta = 0.
                
	            FOR FIRST craptfc FIELD(nrtelefo)
	                WHERE craptfc.cdcooper = crapass.cdcooper AND
	                      craptfc.nrdconta = crapass.nrdconta AND
	            	      craptfc.tptelefo = 1
	            		  NO-LOCK:

	            	   ASSIGN aux_telresid = craptfc.nrtelefo.

	            END.
                
	            FOR FIRST craptfc FIELDS(nrtelefo)
	                WHERE craptfc.cdcooper = crapass.cdcooper AND
	            	      craptfc.nrdconta = crapass.nrdconta AND
	            	      craptfc.tptelefo = 2
	            	      NO-LOCK:

	            	   ASSIGN aux_telcelul = craptfc.nrtelefo.

	            END.
                
	            FOR FIRST craptfc FIELDS(nrtelefo)
	            	   WHERE craptfc.cdcooper = crapass.cdcooper AND
	            	         craptfc.nrdconta = crapass.nrdconta AND
	            	         craptfc.tptelefo = 3
	            		     NO-LOCK:

	            	   ASSIGN aux_telcomer = craptfc.nrtelefo.

	            END.
                
	            FOR FIRST craptfc FIELDS(nrtelefo)
	            	   WHERE craptfc.cdcooper = crapass.cdcooper AND
	            	         craptfc.nrdconta = crapass.nrdconta AND
	            		     craptfc.tptelefo = 4
	            		     NO-LOCK:

	                ASSIGN aux_telconta = craptfc.nrtelefo.

	            END.
                
	            ASSIGN aux_dssitdct = STRING(crapass.cdsitdct,"9") + " " +
	            			          IF crapass.cdsitdct = 1 THEN
	            					     "NORMAL"
	            					  ELSE
	            					  IF crapass.cdsitdct = 2 THEN
	            						 "ENCER.P/ASSOCIADO"
	            					  ELSE
	            						 IF crapass.cdsitdct = 3 THEN
	            						    "ENCER.P/COOP"
	            					  ELSE
	            						 IF crapass.cdsitdct = 4 THEN
	            						    "ENCER.P/DEMISSAO"
	            					  ELSE
	            						 IF crapass.cdsitdct = 5 THEN
	            						    "NAO APROVADA"
	            					  ELSE
	            						 IF crapass.cdsitdct = 6 THEN
	            						    "NORMAL-SEM TL"
	            					  ELSE
	            						 IF crapass.cdsitdct = 9 THEN
	            						    "ENCER.P/OUTRO"
	            					  ELSE "".
                
	            DISPLAY STREAM str_1
	            	      crapass.cdagenci COLUMN-LABEL "PA"
	            	      crapass.dtmvtolt COLUMN-LABEL "Data Abert"
	            	      craplcm.dtmvtolt COLUMN-LABEL "Ult.Movto"
	            	      crapass.nrdconta COLUMN-LABEL "Conta D/v"
	            	      crapass.nmprimtl COLUMN-LABEL "Cooperado"
	            	      				   FORMAT "x(20)"
	            	      crapass.cdtipcta COLUMN-LABEL "T.Cta"
	            	      aux_dssitdct     COLUMN-LABEL "Sit.Cta"
	            	      aux_telresid     COLUMN-LABEL "Residencial"
	            	      aux_telcelul     COLUMN-LABEL "Celular"
	            	      aux_telcomer     COLUMN-LABEL "Comercial"
	            	      aux_telconta     COLUMN-LABEL "Contato"
	                    WITH WIDTH 132 NO-BOX.
                
	            ASSIGN aux_telresid = 0
                       aux_telcelul = 0
                       aux_telcomer = 0
                       aux_telconta = 0.
                
	            IF LAST-OF(crapass.cdagenci) THEN
	               PAGE STREAM str_1.

	   END.

       OUTPUT STREAM str_1 CLOSE.

       ASSIGN par_nmarqimp = aux_nmarqimp.

       IF par_lgvisual = "A" THEN
          DO:
             UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + 
                                aux_nmarquiv).

             IF SEARCH(aux_nmarqimp) <> ? THEN
                UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

          END.
       ELSE 
          DO:
             IF par_idorigem = 5  THEN  /** Ayllos Web **/                     
                DO: 
                   RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT    
                       SET h-b1wgen0024.                                      
                                                                              
                   IF NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                      DO:                                                    
                         ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                               "b1wgen0024.".               
                         LEAVE Imprime.                                     
                      END.                                                   
                                                                              
                   RUN envia-arquivo-web IN h-b1wgen0024                      
                       ( INPUT par_cdcooper,                                  
                         INPUT par_cdagenci,                                  
                         INPUT par_nrdcaixa,                                  
                         INPUT aux_nmarqimp,                                  
                        OUTPUT par_nmarqpdf,                                  
                        OUTPUT TABLE tt-erro ).                               
                                                                              
                   IF  VALID-HANDLE(h-b1wgen0024)  THEN                       
                       DELETE PROCEDURE h-b1wgen0024.                         
                                                                              
                   IF  RETURN-VALUE <> "OK" THEN                              
                       RETURN "NOK".                                       
                END.
          END.

       LEAVE Imprime.

    END. /* Imprime */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           ASSIGN aux_returnvl = "NOK".    

           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog THEN
              RUN proc_gerar_log (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT NO,
                                  INPUT 1, /** idseqttl **/
                                  INPUT par_nmdatela,
                                  INPUT 0, /* nrdconta */
                                 OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* Gera_Dados_S */

/* -------------------------------------------------------------------------- */
/*                        GERA IMPRESSAO DA OPÇÃO C                           */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Dados_C:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_tppessoa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdultrev AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_ddtfinal AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdempres AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_lgvisual AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_tpdopcao AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dsadmcrd AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_tpdomvto AS CHAR  FORMAT "X(1)"             NO-UNDO.
    DEF INPUT PARAM par_situacao AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cartoes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nrregist AS INTE                                    NO-UNDO.
    DEF VAR aux_nriniseq AS INTE                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR par_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gera Dados dos Cartoes".              

    EMPTY TEMP-TABLE tt-cartoes.
    EMPTY TEMP-TABLE tt-erro.
    
    Imprime:
    DO ON ERROR UNDO Imprime, LEAVE Imprime:

       FOR FIRST crapcop FIELD(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:

       END.

       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Imprime.
          END.

       IF par_tpdopcao = "Gerar Base" THEN
          DO: 
             RUN importa_cartao(INPUT par_cdcooper,       
                                INPUT par_cdagenci,  
                                INPUT par_nrdcaixa,  
                                INPUT par_cdoperad,  
                                INPUT par_nmdatela,  
                                INPUT par_idorigem,  
                                INPUT par_nmarquiv,  
                                INPUT par_flgerlog,
                                OUTPUT par_nmarqimp,
                                OUTPUT par_nmarqpdf,
                                OUTPUT TABLE tt-erro).

              IF RETURN-VALUE <> "OK" THEN
                 DO: 
                     IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                        ASSIGN aux_dscritic = "Nao foi possivel importar " +
                                              "o arquivo.".
                     LEAVE Imprime.

                 END.
          END.
       ELSE 
          DO: 
             RUN Busca_Dados_C(INPUT par_cdcooper,          
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_cddepart,
                               INPUT par_dtmvtolt,
                               INPUT aux_nrregist,
                               INPUT aux_nriniseq,
                               INPUT par_flgerlog,
                               INPUT par_cddopcao,
                               INPUT par_tppessoa,
                               INPUT par_cdultrev,
                               INPUT par_dtinicio,
                               INPUT par_ddtfinal,
                               INPUT par_cdempres,
                               INPUT par_tpdopcao,
                               INPUT par_dsadmcrd,
                               INPUT par_tpdomvto,
                               INPUT par_lgvisual,
                               INPUT par_situacao,
                               INPUT par_dsiduser,
                               INPUT par_nmarquiv,
                               OUTPUT par_qtregist,
                               OUTPUT par_nmdcampo,
                               OUTPUT par_nmarqimp,
                               OUTPUT par_nmarqpdf,
                               OUTPUT TABLE tt-cartoes,
                               OUTPUT TABLE tt-erro).

             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      ASSIGN aux_dscritic = "Nao foi possivel consultar as " + 
                                            "informacoes.".

                   LEAVE Imprime.

                END.
             
          END.
       
       LEAVE Imprime.

    END. /* Imprime */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           ASSIGN aux_returnvl = "NOK".    

           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog THEN
              RUN proc_gerar_log (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT NO,
                                  INPUT 1, /** idseqttl **/
                                  INPUT par_nmdatela,
                                  INPUT 0, /* nrdconta */
                                 OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* Gera_Dados_C */

/* -------------------------------------------------------------------------- */
/*                  EFETUA A BUSCA DAS MOVIMENTAÇÕES DA OPÇÃO E               */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Dados_E:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_lgvisual AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                            NO-UNDO.
    
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Relacao de autorizacoes de debito".              

    EMPTY TEMP-TABLE tt-erro.
    
    Imprime:
    DO ON ERROR UNDO Imprime, LEAVE Imprime:

       FOR FIRST crapcop FIELDS(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:

       END.
       
       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Imprime.
          END.

       IF par_lgvisual = "A" AND
          par_nmarquiv = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nome do arquivo nao foi informado.".
             LEAVE Imprime.
          END.
                                                                                          
	   ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser
	   	      aux_nmendter = aux_nmendter + STRING(TIME)                              
	   	      aux_nmarqimp = aux_nmendter + ".ex"         
	   	      aux_nmarqpdf = aux_nmendter + ".pdf"
	   	      aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + 
                             par_nmarquiv
	   	      aux_nmarquiv = aux_nmarquiv + ".txt".

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

       FOR EACH crapass FIELDS(cdcooper nrdconta)
                        WHERE crapass.cdcooper = par_cdcooper AND
                              crapass.dtdemiss = ? 
                              NO-LOCK,

           EACH crapatr FIELDS(crapatr.nrdconta crapatr.cdhistor
                               crapatr.cdrefere crapatr.dtiniatr
                               crapatr.dtfimatr crapatr.dtultdeb
                               crapatr.ddvencto crapatr.nmfatura
                               crapatr.nmempres)
                        WHERE crapatr.cdcooper = crapass.cdcooper AND
                              crapatr.nrdconta = crapass.nrdconta 
                              NO-LOCK:

                DISP STREAM str_1 crapatr.nrdconta COLUMN-LABEL "Conta/dv"
	   	                   crapatr.cdhistor COLUMN-LABEL "Hist."
	   	                   crapatr.cdrefere FORMAT "zzzzzzzzzzzzzzzzzzzzzz9"
	   	                   crapatr.dtiniatr COLUMN-LABEL "Autorizacao"
	   	                   crapatr.dtfimatr COLUMN-LABEL "Cancelamento"
	   	                   crapatr.dtultdeb COLUMN-LABEL "Ult.Debito"
	   	                   crapatr.ddvencto COLUMN-LABEL "Dia Vencto."
	   	                   crapatr.nmfatura FORMAT "x(35)"
	   	                   crapatr.nmempres FORMAT "x(15)"
                           WITH DOWN WIDTH 260 NO-BOX.
       END.

       OUTPUT STREAM str_1 CLOSE.

       ASSIGN par_nmarqimp = aux_nmarqimp.

       IF par_lgvisual = "A"  THEN
          DO:
             UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + 
                               aux_nmarquiv).

             IF SEARCH(aux_nmarqimp) <> ? THEN
                UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").


          END.
       ELSE 
          DO:
             IF par_idorigem = 5  THEN  /** Ayllos Web **/                     
                DO: 
                   RUN sistema/generico/procedures/b1wgen0024.p 
                       PERSISTENT SET h-b1wgen0024.   
                                                                              
                   IF NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                      DO:                                                    
                          ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                                "b1wgen0024.".               
                          LEAVE Imprime.                                     
                      END.                                                   
                                                                              
                   RUN envia-arquivo-web IN h-b1wgen0024                      
                       ( INPUT par_cdcooper,                                  
                         INPUT par_cdagenci,                                  
                         INPUT par_nrdcaixa,                                  
                         INPUT aux_nmarqimp,                                  
                        OUTPUT par_nmarqpdf,                                  
                        OUTPUT TABLE tt-erro ).                               
                                                                              
                   IF  VALID-HANDLE(h-b1wgen0024)  THEN                       
                       DELETE PROCEDURE h-b1wgen0024.                         
                                                                              
                   IF  RETURN-VALUE <> "OK" THEN                              
                       RETURN "NOK".                                       
                END.
          END.

       LEAVE Imprime.

    END. /* Imprime */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          ASSIGN aux_returnvl = "NOK".    

          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* Gera_Dados_E */

/* -------------------------------------------------------------------------
                  EFETUA A BUSCA DES LINHAS DE CREDITO E FINALIDADES
                  A SEREM UTILIZADAS NA OPCAO "A"              
-------------------------------------------------------------------------- */
PROCEDURE busca_linhas_finalidades:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-lincred.
    DEF OUTPUT PARAM TABLE FOR tt-finalidade.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsdircop AS CHAR 									NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gerar arquivo de empr/fin. por linha de credito e finalidade.".              

    EMPTY TEMP-TABLE tt-lincred.
    EMPTY TEMP-TABLE tt-finalidade.
    EMPTY TEMP-TABLE tt-erro.
    
    Busca:
    DO ON ERROR UNDO Busca, LEAVE Busca:

       FOR FIRST crapcop FIELD(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:

       END.

       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Busca.
          END.

       IF par_cddepart = 20  OR    /* TI         */
          par_cddepart = 11  OR    /* FINANCEIRO */
          par_cddepart = 18  THEN  /* SUPORTE    */
	   	  DO:
	   	     FOR EACH craplcr FIELDS(craplcr.cdlcremp craplcr.dslcremp)
                              WHERE craplcr.cdcooper = par_cdcooper 
                                    NO-LOCK:
          
	   	  	     CREATE tt-lincred.

	   	  	     ASSIGN tt-lincred.cdcodigo = craplcr.cdlcremp
	   	  	            tt-lincred.dsdescri = craplcr.dslcremp.

	   	     END.
          
	   	  	 FOR EACH crapfin FIELDS(crapfin.cdfinemp crapfin.dsfinemp)
                              WHERE crapfin.cdcooper = par_cdcooper 
                                    NO-LOCK:
             
	   	  	     CREATE tt-finalidade.

	   	  	 	  ASSIGN tt-finalidade.cdcodigo = crapfin.cdfinemp
	   	  	 	         tt-finalidade.dsdescri = crapfin.dsfinemp.

	   	  	 END.
             
             ASSIGN aux_dsdircop = "".

	   	  	 FOR FIRST crapcop FIELDS(crapcop.dsdircop)
                               WHERE crapcop.cdcooper = par_cdcooper 
                                     NO-LOCK:
             
	   	  	    ASSIGN aux_dsdircop = crapcop.dsdircop.

             END.
	      	 
	   	  END.
       ELSE 
	      DO:
	         ASSIGN aux_cdcritic = 0 
	       	        aux_dscritic = "Acesso negado." 
	       	        par_nmdcampo = "".

	       	 LEAVE Busca.

	      END.

       LEAVE Busca.

    END. /* Busca */

    IF aux_dscritic <> "" OR
       aux_cdcritic <> 0  THEN
       DO:
          ASSIGN aux_returnvl = "NOK".    

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
    
          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. 

/* -------------------------------------------------------------------------- */
/*                        GERA ARQUIVO DOS MOVIMENTOS                         */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Arquivo:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_sellincr AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_selfinal AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_finalidades AS CHAR EXTENT               			NO-UNDO.
    DEF VAR aux_linhacredit AS CHAR EXTENT               			NO-UNDO.
    DEF VAR aux_contador    AS INTE                          		NO-UNDO.
    DEF VAR aux_qtregist    AS INTE                                 NO-UNDO.
    DEF VAR aux_nrdrowid    AS ROWID                                NO-UNDO.
    DEF VAR aux_returnvl    AS CHAR                                 NO-UNDO.
    DEF VAR aux_cdcritic    AS INTE                                 NO-UNDO.
    DEF VAR aux_dscritic    AS CHAR                                 NO-UNDO.
    DEF VAR aux_stringsl    AS CHAR                			        NO-UNDO.
    DEF VAR aux_ctrlregi    AS INTE                 			    NO-UNDO.
    DEF VAR aux_sellincr    AS INTE 							    NO-UNDO.
    DEF VAR aux_selfinal    AS INTE 							    NO-UNDO.
    DEF VAR aux_nmarquiv    AS CHAR                                 NO-UNDO.
    DEF VAR aux_dstransa    AS CHAR                                 NO-UNDO.
    DEF VAR aux_dsorigem    AS CHAR                                 NO-UNDO.
    DEF VAR aux_inpessoa    AS CHAR                                 NO-UNDO.
    DEF VAR aux_nmarqimp    AS CHAR                                 NO-UNDO.
    DEF VAR aux_nmarqpdf    AS CHAR                                 NO-UNDO.
    DEF VAR h-b1wgen0002    AS HANDLE                               NO-UNDO.
    DEF VAR aux_nmendter    AS CHAR                                 NO-UNDO.

    ASSIGN aux_sellincr = NUM-ENTRIES(par_sellincr) - 1
		   aux_selfinal = NUM-ENTRIES(par_selfinal) - 1
		   aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gera arquivo de movimentos".              

    EMPTY TEMP-TABLE tt-erro.
     
    Arquivo:
    DO ON ERROR UNDO Arquivo, LEAVE Arquivo:

       FOR FIRST crapcop FIELDS(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:
       
       END.

       IF NOT AVAIL crapcop THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Arquivo.
          END.
                     
       IF par_nmarquiv = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nome do arquivo nao foi informado.".
             LEAVE Arquivo.
          END.

       IF par_sellincr = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nenhuma linha de credito foi selecionada.".
             LEAVE Arquivo.
          END.

       IF par_selfinal = "" THEN
          DO:
             ASSIGN aux_dscritic = "Nenhuma finalidade foi selecionada.".
             LEAVE Arquivo.
          END.

	   ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser
	   	      aux_nmendter = aux_nmendter + STRING(TIME)      
	   	      aux_nmarqimp = aux_nmendter + ".ex"            
	   	      aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + 
                             par_nmarquiv
	   	      aux_nmarquiv = aux_nmarquiv + ".txt".

       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

       IF NOT VALID-HANDLE(h-b1wgen0002) THEN
          RUN sistema/generico/procedures/b1wgen0002.p
              PERSISTENT SET h-b1wgen0002.

       EXTENT(aux_linhacredit) = aux_sellincr.
       EXTENT(aux_finalidades) = aux_selfinal.

       DO aux_contador = 1 TO aux_sellincr:
          ASSIGN aux_linhacredit[aux_contador] = ENTRY(aux_contador,par_sellincr).
       END.

       DO aux_contador = 1 TO aux_selfinal:
          ASSIGN aux_finalidades[aux_contador] = ENTRY(aux_contador,par_selfinal).
       END.

       DISPLAY STREAM str_1
           "Geracao do relatorio: " + STRING(par_dtmvtolt) + " " +   
                                      STRING(TIME,"HH:MM:SS")
               FORMAT "x(255)"
           SKIP(1)
           WITH WIDTH 382 NO-LABEL NO-BOX NO-UNDERLINE FRAME f_cab_movtos_a.

       ASSIGN aux_stringsl = "Linhas Credito: ".

       DO aux_contador = 1 TO aux_sellincr:

          ASSIGN aux_stringsl = aux_stringsl + aux_linhacredit[aux_contador] 
                            + ", "
                 aux_ctrlregi = aux_ctrlregi + 1.
    
          IF aux_ctrlregi = 30 THEN
             DO:
                 DISPLAY STREAM str_1 aux_stringsl FORMAT "x(255)"
	   	   	                          SKIP(1)
	   	   	     WITH WIDTH 382 DOWN NO-LABEL NO-BOX NO-UNDERLINE 
                                FRAME f_lincred_movtos_a.

                 DOWN WITH FRAME f_lincred_movtos_a.
    
                 ASSIGN aux_stringsl = ""
                        aux_ctrlregi = 0.
             END.
          ELSE
             DO:
                IF aux_contador =  aux_selfinal THEN
                   DO:
                      DISPLAY STREAM str_1 aux_stringsl FORMAT "x(255)"
	   	   	   	                           SKIP
                              WITH WIDTH 382 DOWN NO-LABEL NO-BOX NO-UNDERLINE 
                                             FRAME f_lincred_movtos_a.
       
                      DOWN WITH FRAME f_lincred_movtos_a.

                   END.
             END.
       END.

       ASSIGN aux_stringsl = "Finalidades: "
              aux_ctrlregi = 0.

       DO aux_contador = 1 TO aux_selfinal:
          
          ASSIGN aux_stringsl = aux_stringsl + aux_finalidades[aux_contador] 
                                + ", "
                 aux_ctrlregi = aux_ctrlregi + 1.
    
          IF aux_ctrlregi = 30 THEN
             DO:
                 DISPLAY STREAM str_1 aux_stringsl FORMAT "x(255)" SKIP
                         WITH WIDTH 382 DOWN NO-LABEL NO-BOX NO-UNDERLINE 
                                        FRAME f_finali_movtos_a.
    
                 DOWN WITH FRAME f_finali_movtos_a.
    
                 ASSIGN aux_stringsl = ""
                        aux_ctrlregi = 0.
             END.
          ELSE
             DO:
                IF aux_contador = aux_selfinal THEN
                   DO:
                       DISPLAY STREAM str_1 aux_stringsl FORMAT "x(255)" SKIP
                               WITH WIDTH 382 DOWN NO-LABEL NO-BOX NO-UNDERLINE
                                              FRAME f_finali_movtos_a.
       
                       DOWN WITH FRAME f_finali_movtos_a.
                   END.
             END.       
       END.

       DISPLAY STREAM str_1 SKIP(2)
               WITH WIDTH 382 DOWN NO-LABEL NO-BOX NO-UNDERLINE. 

       FOR EACH crapcop FIELDS(cdcooper) 
                        WHERE crapcop.cdcooper = par_cdcooper 
                              NO-LOCK:
    
           FOR EACH crapepr FIELDS(cdcooper nrdconta nrctremp cdlcremp cdfinemp
                                   dtmvtolt qtpreemp vlpreemp vlemprst )    
                    WHERE crapepr.cdcooper = crapcop.cdcooper           AND
                          crapepr.inliquid = 0                          AND
                          CAN-DO(par_sellincr,STRING(crapepr.cdlcremp)) AND
                          CAN-DO(par_selfinal,STRING(crapepr.cdfinemp))
                          NO-LOCK,
    
               FIRST crawepr FIELDS( dtmvtolt )
                             WHERE crawepr.cdcooper = crapepr.cdcooper   AND
                                   crawepr.nrdconta = crapepr.nrdconta   AND
                                   crawepr.nrctremp = crapepr.nrctremp
                                   NO-LOCK,
    
	   		   FIRST crapass FIELDS( inpessoa cdagenci nrdconta nmprimtl ) 
                             WHERE crapass.cdcooper = crapepr.cdcooper   AND
                                   crapass.nrdconta = crapepr.nrdconta  
                                   NO-LOCK,
                  
	   		   FIRST craplcr FIELDS( cdlcremp dslcremp )
                             WHERE craplcr.cdcooper = crapepr.cdcooper   AND
                                   craplcr.cdlcremp = crapepr.cdlcremp   
                                   NO-LOCK,
               
	   		   FIRST crapfin FIELDS( cdfinemp dsfinemp )
                             WHERE crapfin.cdcooper = crapepr.cdcooper   AND
                                   crapfin.cdfinemp = crapepr.cdfinemp
                                   BY crapass.cdagenci
                                    BY crapass.nrdconta
                                     BY crapepr.nrctremp:

               ASSIGN aux_inpessoa = IF crapass.inpessoa = 1   THEN
                                        "FISICA"
                                     ELSE
                                        "JURIDICA".
 
               RUN obtem-dados-emprestimos IN h-b1wgen0002 
                                (INPUT crapepr.cdcooper,
                                 INPUT 0, /*cdagenci*/ 
                                 INPUT 0, /*nrdcaixa*/
                                 INPUT "1", /*cdoperad*/ 
                                 INPUT "baca", /*nmdatela*/
                                 INPUT 1, /*idorigem*/
                                 INPUT crapepr.nrdconta,
                                 INPUT 1, /*idseqttl*/
                                 INPUT par_dtmvtolt,
                                 INPUT par_dtmvtopr, 
                                 INPUT par_dtmvtolt,  
                                 INPUT crapepr.nrctremp, 
                                 INPUT "baca", /*cdprogra*/
                                 INPUT 0, /*inproces*/
                                 INPUT FALSE, /*flgerlog*/
                                 INPUT FALSE, /*flgcondc*/
                                 INPUT 0, /** nriniseq **/
                                 INPUT 0, /** nrregist **/
                                 OUTPUT aux_qtregist,     
                                 OUTPUT TABLE tt-erro,   
                                 OUTPUT TABLE tt-dados-epr).  

               FIND FIRST tt-dados-epr NO-LOCK NO-ERROR.
       
               DISP STREAM str_1
	   			    crapass.cdagenci LABEL "PA;"               ";"
	   			    crapass.nrdconta LABEL "CONTA/DV;"         ";"
	   			    crapass.nmprimtl LABEL "TITULAR;"          ";"
	   			    aux_inpessoa     LABEL "TIPO PESSOA;"      ";"
	   			    crapepr.nrctremp LABEL "CONTRATO;"         ";"
	   			    crapepr.dtmvtolt LABEL "DT. OPERACAO;"     ";"
	   			    crawepr.dtmvtolt LABEL "DT. PROPOSTA;"     ";"
	   			    crapepr.qtpreemp LABEL "QTDE. PARCELAS;"   ";"
	   			    tt-dados-epr.qtprecal LABEL "QTD.PAGAS;"    ";"
	   			    crapepr.vlpreemp LABEL "VLR. PARCELA;"     ";"
	   			    craplcr.cdlcremp LABEL "COD. LINHA;"       ";"
	   			    craplcr.dslcremp LABEL "DESC LINHA;"       ";"
	   			    crapfin.cdfinemp LABEL "CD. FIN;"  ";"
	   			    crapfin.dsfinemp LABEL "DESC. FINALIDADE;" ";"
	   			    crapepr.vlemprst LABEL "VALOR EMPRESTIMO;" ";"    
	   			    tt-dados-epr.vlsdeved LABEL "SALDO DEVEDOR;"
	   			    				FORMAT "zz,zzz,zz9.99" ";"
	   		        WITH WIDTH 382 DOWN NO-LABEL NO-BOX NO-UNDERLINE
	   		                       FRAME f_detalhe.
	    	
               DOWN WITH FRAME f_detalhe.

           END.
       END.

       OUTPUT STREAM str_1 CLOSE.
       
       UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + aux_nmarquiv).

       ASSIGN par_nmarqimp = aux_nmarqimp.

       LEAVE Arquivo.

    END. /* Arquivo */

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE OBJECT h-b1wgen0002.       

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           ASSIGN aux_returnvl = "NOK".    

           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

           IF  par_flgerlog THEN
               RUN proc_gerar_log (INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT aux_dscritic,
                                   INPUT aux_dsorigem,
                                   INPUT aux_dstransa,
                                   INPUT NO,
                                   INPUT 1, /** idseqttl **/
                                   INPUT par_nmdatela,
                                   INPUT 0, /* nrdconta */
                                  OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* Gera_Arquivo */

/* -------------------------------------------------------------------------- */
/*                           LISTA AS SITUAÇÕES                               */
/* -------------------------------------------------------------------------- */
PROCEDURE carrega_situacao:

    DEF INPUT PARAM par_dsadmcrd AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_flgconsu AS LOG                             NO-UNDO.
    DEF INPUT PARAM par_situacao AS CHAR                            NO-UNDO.
   
    DEF OUTPUT PARAM TABLE FOR tt-situacao.

    DEF VAR aux_contador AS INT  							        NO-UNDO.
    DEF VAR aux_qtdsitua AS INT                                     NO-UNDO.

    /* limpa a tabela */ 
    EMPTY TEMP-TABLE tt-situacao.
                           
    IF par_dsadmcrd = "BRADESCO" THEN
       DO aux_contador = 1 TO 7:
          
          /*Se nao for consulta desacartados todas as situacoes que nao
           foram escolhidas para geracao dos relatorios.)*/
          IF NOT par_flgconsu                                  AND 
             LOOKUP(STRING(aux_contador),par_situacao,",") = 0 THEN
             NEXT.

          CREATE tt-situacao.
          
          /* Somente Bradesco */
          CASE aux_contador:
              WHEN 1 THEN
                  ASSIGN tt-situacao.sqsitcrd = 1 
                         tt-situacao.dssitcrd = "Sol.2v"
                         tt-situacao.insitcrd = 7.
           
              WHEN 2 THEN
                  ASSIGN tt-situacao.sqsitcrd = 2 
                         tt-situacao.dssitcrd = "Estudo"
                         tt-situacao.insitcrd = 0.
       
              WHEN 3 THEN
                  ASSIGN tt-situacao.sqsitcrd = 3
                         tt-situacao.dssitcrd = "Aprov."
                         tt-situacao.insitcrd = 1.
       
              WHEN 4 THEN
                  ASSIGN tt-situacao.sqsitcrd = 4
                         tt-situacao.dssitcrd = "Solic."
                         tt-situacao.insitcrd = 2.
          
              WHEN 5 THEN
                  ASSIGN tt-situacao.sqsitcrd = 5
                         tt-situacao.dssitcrd = "Liber."
                         tt-situacao.insitcrd = 3.
              WHEN 6 THEN
                  ASSIGN tt-situacao.sqsitcrd = 6
                         tt-situacao.dssitcrd = "Em uso"
                         tt-situacao.insitcrd = 4.
              WHEN 7 THEN
                  ASSIGN tt-situacao.sqsitcrd = 7
                         tt-situacao.dssitcrd = "Cancel"
                         tt-situacao.insitcrd = 5.
          END CASE.
        
       END.  /*  Fim DO .. TO  */
    ELSE    
       DO aux_contador = 1 TO 5:
          
          /*Se nao for consulta desacartados todas as situacoes que nao
           foram escolhidas para geracao dos relatorios.)*/
          IF NOT par_flgconsu                                  AND 
             LOOKUP(STRING(aux_contador),par_situacao,",") = 0 THEN
             NEXT.

          CREATE tt-situacao.

          /* Somente BB */
          CASE aux_contador:
              WHEN 1 THEN 
                  ASSIGN tt-situacao.sqsitcrd = 1 
                         tt-situacao.dssitcrd = "Estudo"
                         tt-situacao.insitcrd = 0.
         
              WHEN 2 THEN
                  ASSIGN tt-situacao.sqsitcrd = 2
                         tt-situacao.dssitcrd = "Aprov."
                         tt-situacao.insitcrd = 1.
       
              WHEN 3 THEN
                  ASSIGN tt-situacao.sqsitcrd = 3
                         tt-situacao.dssitcrd = "Prc.BB"
                         tt-situacao.insitcrd = 4.
          
              WHEN 4 THEN
                  ASSIGN tt-situacao.sqsitcrd = 4
                         tt-situacao.dssitcrd = "Bloque"
                         tt-situacao.insitcrd = 5.
          
              WHEN 5 THEN
                  ASSIGN tt-situacao.sqsitcrd = 5
                         tt-situacao.dssitcrd = "Encer."
                         tt-situacao.insitcrd = 6.

          END CASE.
        
       END.  /*  Fim DO .. TO  */

    RETURN "OK".
    
END PROCEDURE.


/* -------------------------------------------------------------------------- */
/*        CARREGA OS DADOS DA OPÇÃO C QUANDO O TIPO DO MOVIMENTO FOR C        */
/* -------------------------------------------------------------------------- */

PROCEDURE carrega_dados_c:

    DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_tppessoa AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cdultrev AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_ddtfinal AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_cdempres AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_tpdopcao AS CHAR                             NO-UNDO. 
    DEF INPUT PARAM par_dsadmcrd AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_situacao AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_cdcopaux LIKE crapcop.cdcooper               NO-UNDO.
    DEF INPUT PARAM par_lgvisual AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                             NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cartoes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcrcard AS CHAR FORMAT "x(19)"                      NO-UNDO.
    DEF VAR aux_lbfatdb1 AS CHAR                                     NO-UNDO.
    DEF VAR aux_lbfatdb2 AS CHAR                                     NO-UNDO.
    DEF VAR aux_lbfatdb3 AS CHAR                                     NO-UNDO.
    DEF VAR aux_vlfatdb1 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR aux_vlfatdb2 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR aux_vlfatdb3 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
    DEF VAR h-b1wgen0028 AS HANDLE                                   NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                   NO-UNDO.
    DEF VAR aux_flgercab AS LOGI INIT FALSE                          NO-UNDO.
    DEF VAR aux_vlrrendi AS DECI FORMAT "zzz,zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR aux_outroren AS DECI FORMAT "zzz,zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_dssitcrd AS CHAR                                     NO-UNDO.
    DEF VAR aux_vllimcrd LIKE craptlc.vllimcrd                       NO-UNDO. 
    DEF VAR aux_nrreside AS CHAR FORMAT "(xx)xxxx-xxxx"              NO-UNDO.
    DEF VAR aux_nrcelula AS CHAR FORMAT "(xx)xxxxx-xxxx"             NO-UNDO.
    DEF VAR aux_cartaobb AS LOGI INIT YES                            NO-UNDO.
    DEF VAR aux_nrcpftit AS CHAR                                     NO-UNDO. 
    DEF VAR aux_nmrescop LIKE crapcop.nmrescop                       NO-UNDO.
    DEF VAR aux_dsadmcrd AS CHAR                                     NO-UNDO. 
    DEF VAR aux_vllimdeb LIKE crapass.vllimdeb                       NO-UNDO.
    DEF VAR aux_flgprreg AS LOGI INIT YES                            NO-UNDO. 
    DEF VAR par_nrcctitg LIKE crawcrd.nrcctitg                       NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
    DEF VAR aux_cdadmcrd1 AS INTE                                    NO-UNDO.
    DEF VAR aux_cdadmcrd2 AS INTE                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                     NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                     NO-UNDO.
        
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Relacao de autorizacoes de debito".              

    DEF BUFFER b-crapcop1 FOR crapcop.

    EMPTY TEMP-TABLE tt-cartoes.
    EMPTY TEMP-TABLE tt-situacao.
    EMPTY TEMP-TABLE tt-erro.
    
    Busca:
    DO ON ERROR UNDO Busca, LEAVE Busca:

       FOR FIRST b-crapcop1 FIELDS(b-crapcop1.cdcooper b-crapcop1.dsdircop 
                                   b-crapcop1.nmrescop)
                            WHERE b-crapcop1.cdcooper = par_cdcopaux 
                                  NO-LOCK:

           ASSIGN aux_nmrescop = b-crapcop1.nmrescop.

       END.

       IF NOT AVAIL b-crapcop1 THEN
          DO:
              ASSIGN aux_cdcritic = 651.
              LEAVE Busca.
          END.

       IF par_dsadmcrd = "" THEN
          DO:
              ASSIGN aux_dscritic = "Administradora nao informada.".
              LEAVE Busca.
          END.

       IF par_lgvisual <> "T"  THEN
          DO:
             IF par_lgvisual = "A" AND
                par_nmarquiv = "" THEN
                DO:
                   ASSIGN aux_dscritic = "Nome do arquivo nao foi informado.".
                   LEAVE Busca.
                END.
                
             ASSIGN aux_nmendter = "/usr/coop/" + b-crapcop1.dsdircop + 
                                   "/rl/" + par_dsiduser
                    aux_nmendter = aux_nmendter + STRING(TIME)    
                    aux_nmarqimp = aux_nmendter + ".ex"          
                    aux_nmarqpdf = aux_nmendter + ".pdf"
                    aux_nmarquiv = "/micros/" + b-crapcop1.dsdircop + "/" + 
                                   par_nmarquiv + ".txt".
          
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

          END.

       ASSIGN aux_flgprreg = YES
              aux_vlrrendi = 0
              aux_outroren = 0
              aux_contador = 0.
	   	   
	   IF NOT VALID-HANDLE(h-b1wgen0028) THEN
	      RUN sistema/generico/procedures/b1wgen0028.p 
              PERSISTENT SET h-b1wgen0028.

       CASE par_dsadmcrd:

           WHEN "BRADESCO" THEN 
             DO:
                ASSIGN aux_cdadmcrd1 = 2
                       aux_cdadmcrd2 = 3.
             END.

           WHEN "BANCO DO BRASIL" THEN 
             DO:
                ASSIGN aux_cdadmcrd1 = 83
                       aux_cdadmcrd2 = 88.
             END.

       END CASE.

       RUN carrega_situacao(INPUT par_dsadmcrd,
                            INPUT FALSE, /*flgconsu*/
                            INPUT par_situacao,
                            OUTPUT TABLE tt-situacao).            

       FOR EACH crawcrd FIELDS(crawcrd.insitcrd crawcrd.dtsol2vi
                               crawcrd.cdadmcrd crawcrd.cdcooper
                               crawcrd.nrdconta crawcrd.tpcartao
                               crawcrd.cdlimcrd crawcrd.nrcctitg
                               crawcrd.nrcrcard crawcrd.nrcpftit
                               crawcrd.nmtitcrd crawcrd.dtpropos
                               crawcrd.dtsolici crawcrd.dtcancel
                               crawcrd.dtentreg crawcrd.dddebito
                               crawcrd.dtmvtolt crawcrd.dtlibera
                               crawcrd.dtentr2v)
                        WHERE crawcrd.cdcooper = b-crapcop1.cdcooper AND
                              crawcrd.cdadmcrd >= aux_cdadmcrd1      AND
                              crawcrd.cdadmcrd <= aux_cdadmcrd2  
                              NO-LOCK: 

           FIND FIRST tt-situacao WHERE tt-situacao.insitcrd = crawcrd.insitcrd
                                        USE-INDEX id-tt-situacao2 
                                        NO-LOCK NO-ERROR.

           IF NOT AVAILABLE tt-situacao THEN
	   		  DO:
	   		  	 IF (crawcrd.insitcrd  = 4)  AND
	   		  	    (crawcrd.dtsol2vi <> ?) THEN
	   		  	   	DO:
	   		  		   IF par_dsadmcrd = "BRADESCO" THEN
	   		  		      NEXT.
              
	   		  		END.
	   		  	ELSE
	   		  	   NEXT.
              
	   		  END.

           /**nao permitir a exibição de cartoes sicobb nos relatorios*/
           IF crawcrd.cdadmcrd >= 10 AND
              crawcrd.cdadmcrd <= 80 THEN
              NEXT.

           FOR FIRST crapadc FIELDS(crapadc.insitadc crapadc.nmresadm)
                             WHERE crapadc.cdcooper = crawcrd.cdcooper AND
                                   crapadc.cdadmcrd = crawcrd.cdadmcrd
                                   NO-LOCK:

           END.

           IF NOT AVAILABLE crapadc THEN
              NEXT.

           IF crapadc.insitadc = 1 THEN
              NEXT.

           FOR FIRST crapass FIELDS(cdcooper cdagenci vllimdeb inpessoa
                                    nrdconta nrdctitg)
                             WHERE crapass.cdcooper = crawcrd.cdcooper AND
                                   crapass.nrdconta = crawcrd.nrdconta 
                                   NO-LOCK:

	   		   /* Migracao AcrediCoop - entra em vigor em 01/01/2014 */
	   		   IF crapass.cdcooper = 2                           AND
	   		      CAN-DO("2,4,6,7,11", STRING(crapass.cdagenci)) THEN
	   		      DO:
	   		         FOR FIRST craptco FIELDS(craptco.cdcooper)
                               WHERE craptco.cdcopant = crawcrd.cdcooper AND
	   		       			         craptco.nrctaant = crawcrd.nrdconta
	   		      			         USE-INDEX craptco2 NO-LOCK:
                  
                     END.

	   		      	 IF AVAIL craptco THEN
	   		      		NEXT.

	   		      END.
               
	   		   /* Migracao Altovale - entra em vigor 01/01/2013 */
	   		   IF crapass.cdcooper = 1                                 AND
	   		   	  CAN-DO("7,33,38,60,62,66", STRING(crapass.cdagenci)) THEN
	   		   	  DO:
	   		   	     FOR FIRST craptco FIELDS(craptco.cdcooper)
                               WHERE craptco.cdcopant = crawcrd.cdcooper AND
	   		   	  	      	         craptco.nrctaant = crawcrd.nrdconta
	   		   	  			         USE-INDEX craptco2 NO-LOCK:

                     END.
                  
                     /* antes estava crapass - Fabricio */
	   		   	  	 IF AVAIL craptco THEN 
	   		   	  	    NEXT.
                  
	   		   	  END.
                  
	   		   /* Migracao Concredi e Credimilsul - entra em vigor 30/11/2014 */
	   		   IF crapass.cdcooper = 4 OR
	   		      crapass.cdcooper = 15 THEN
	   		      DO:
	   		         FOR FIRST craptco FIELDS(craptco.cdcooper)
                               WHERE craptco.cdcopant = crawcrd.cdcooper AND
	   		         		         craptco.nrctaant = crawcrd.nrdconta
	   		         			     USE-INDEX craptco2 NO-LOCK:

                     END.
                 
	   		         IF AVAIL craptco THEN
	   		            NEXT.
	   		      END.                       
               
	   		   ASSIGN aux_dsadmcrd = crapadc.nmresadm
	   		   	      aux_cartaobb = IF crawcrd.cdadmcrd >= 83  AND
	   		   	        				crawcrd.cdadmcrd <= 88  THEN
	   		   	       				    YES
	   		   	       			     ELSE
	   		   	       				    NO
	   		   	      aux_vllimdeb = IF aux_cartaobb THEN
	   		   	       				    crapass.vllimdeb
	   		   	       			     ELSE
	   		   	       				    0
	   		   	      aux_vlrrendi = 0
	   		   	      aux_outroren = 0
	   		   	      aux_dssitcrd = DYNAMIC-FUNCTION("retorna-situacao" 
                                                      IN h-b1wgen0028,
	   		   	       						  INPUT crawcrd.insitcrd,
	   		   	       						  INPUT crawcrd.dtsol2vi,
	   		   	       						  INPUT crawcrd.cdadmcrd)
	   		   	      aux_vllimcrd = 0.
               
	   		   FOR FIRST craptlc FIELDS(vllimcrd)
	   		   			 WHERE craptlc.cdcooper = crawcrd.cdcooper AND
	   		   				   craptlc.cdadmcrd = crawcrd.cdadmcrd AND
	   		   				   craptlc.tpcartao = crawcrd.tpcartao AND
	   		   				   craptlc.cdlimcrd = crawcrd.cdlimcrd AND
	   		   				   craptlc.dddebito = 0
	   		   				   NO-LOCK:
               
	   		   	    ASSIGN aux_vllimcrd = craptlc.vllimcrd.
               
	   		   END.
               
	   		   IF par_tpdopcao = "Por Periodo" THEN
	   		   	  DO:
	   		   	     RUN verifica_periodo (INPUT par_dtinicio, 
                                           INPUT par_ddtfinal, 
                                           INPUT crawcrd.insitcrd, 
                                           INPUT crawcrd.dtsol2vi, 
                                           INPUT crawcrd.dtpropos, 
                                           INPUT crawcrd.dtmvtolt, 
                                           INPUT crawcrd.dtsolici, 
                                           INPUT crawcrd.dtlibera, 
                                           INPUT crawcrd.dtentreg, 
                                           INPUT crawcrd.dtentr2v, 
                                           INPUT crawcrd.dtcancel). 
               
	   		   		 IF RETURN-VALUE <> "OK" THEN
	   		   		   	NEXT.
               
                  END.
               
	   		   ASSIGN aux_nrreside = "".
               
	   		   FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
	   		   				   WHERE craptfc.cdcooper = crawcrd.cdcooper AND
	   		   						 craptfc.nrdconta = crawcrd.nrdconta AND
	   		   						 craptfc.tptelefo = 1
	   		   						 NO-LOCK:
               
	   		       ASSIGN aux_nrreside = STRING(craptfc.nrdddtfc) +
	   		   	    				     STRING(craptfc.nrtelefo).

	   		   END.
               
	   		   ASSIGN aux_nrcelula = "".
               
	   		   FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
	   		   				   WHERE craptfc.cdcooper = crawcrd.cdcooper AND
	   		   						 craptfc.nrdconta = crawcrd.nrdconta AND
	   		   						 craptfc.tptelefo = 2
	   		   						 NO-LOCK:
               
	   		   	   ASSIGN aux_nrcelula = STRING(craptfc.nrdddtfc) +
	   		   	         				 STRING(craptfc.nrtelefo).
	   		   END.
               
	   		   RUN busca_valores_cartao(INPUT par_cdagenci,
	   		   				    		INPUT par_nrdcaixa,
	   		   				    		INPUT par_cdoperad,
	   		   				    		INPUT par_nmdatela,
	   		   				    		INPUT par_idorigem,
	   		   				    		INPUT par_cddepart,
	   		   				    		INPUT par_dtmvtolt,
                                        INPUT par_flgerlog,
	   		   				    		INPUT par_cddopcao,
                                        INPUT par_dsadmcrd,
	   		   				    		INPUT crawcrd.cdcooper,
	   		   				    		INPUT crawcrd.nrdconta,
	   		   				    		INPUT crawcrd.nrcctitg,
                                        INPUT crawcrd.nrcrcard,
	   		   				    		OUTPUT aux_vlfatdb1,
	   		   				    		OUTPUT aux_vlfatdb2,
	   		   				    		OUTPUT aux_vlfatdb3,
	   		   				    		OUTPUT TABLE tt-erro).
               
	   		   IF crapass.inpessoa = 1 THEN
	   		   	  DO:
	   		   	  	 FOR EACH crapttl FIELDS(vlsalari vldrendi[1] 
                                             vldrendi[2] vldrendi[3] 
                                             vldrendi[4] vldrendi[5] 
                                             vldrendi[6] )
	   		   	  	         WHERE crapttl.cdcooper = crapass.cdcooper AND
	   		   	  	 	           crapttl.nrdconta = crapass.nrdconta AND
	   		   	  	 	           crapttl.nrcpfcgc = crawcrd.nrcpftit
	   		   	  	 	           NO-LOCK USE-INDEX crapttl6:
                                    
	   		   	  	 	 ASSIGN aux_vlrrendi = crapttl.vlsalari.
                     
	   		   	  	 	 DO aux_contador = 1 TO 6:
                     
	   		   	  	 		ASSIGN aux_outroren = aux_outroren +
	   		   	  	 		       crapttl.vldrendi[aux_contador].
                     
	   		   	  	 	 END.
                     
	   		   	  	 END.
	   		   	  END.
	   		   ELSE
	   		      DO:
	   		    	 FOR FIRST crapjur FIELDS(vlfatano)
	   		    	      	   WHERE crapjur.cdcooper = crapass.cdcooper AND
	   		    			         crapjur.nrdconta = crapass.nrdconta
	   		    				     NO-LOCK:
                
	   		    		 ASSIGN aux_vlrrendi =  crapjur.vlfatano / 12.
	   		    	 END.
                
                
	   		      END.
               
	   		   ASSIGN aux_lbfatdb1 = "Fatura " +
	   		   	   STRING(MONTH(ADD-INTERVAL(par_dtmvtolt, -3, "months")),"99") + "/" +
	   		   	   STRING(YEAR(ADD-INTERVAL(par_dtmvtolt, -3, "months")))
               
	   		          aux_lbfatdb2 = "Fatura " +
	   		   	   STRING(MONTH(ADD-INTERVAL(par_dtmvtolt, -2, "months")),"99") + "/" +
	   		   	   STRING(YEAR(ADD-INTERVAL(par_dtmvtolt, -2, "months")))
               
	   		   	      aux_lbfatdb3 = "Fatura " +
	   		   	   STRING(MONTH(ADD-INTERVAL(par_dtmvtolt, -1, "months")),"99") + "/" +
	   		   	   STRING(YEAR(ADD-INTERVAL(par_dtmvtolt, -1, "months"))).
               
	   		   IF par_lgvisual <> "T"  THEN
	   		      DO:
	   		   	     ASSIGN aux_nrcrcard = "".
                     
	   		   	     IF aux_cartaobb THEN
	   		   	        ASSIGN aux_nrcrcard = "Conta Cartao".
	   		   	     ELSE
	   		   	        ASSIGN aux_nrcrcard = "Numero do Cartao".
                     
	   		   	     ASSIGN aux_nrcpftit = STRING(crawcrd.nrcpftit,"99999999999")
	   		   	      	    aux_nrcpftit = STRING(aux_nrcpftit,"xxx.xxx.xxx-xx").
	   		   	     	  
	   		   	     IF NOT aux_flgercab                        OR
	   		   	        LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
	   		   	        PUT STREAM str_1 UNFORMATTED
                            "Cooperativa  PA   Conta/DV   "
                            "Conta/ITG Titular do Cartao"
                            "           CPF Titular    Administradora  Sit."
                            aux_nrcrcard AT 114 FORMAT "x(12)"
                            "Dt.Proposta Dt.Pedido  Dt.Cancelamento " AT 127
                            "Dt.Entrega Dia do debito C/C "
                            "Limite de Credito  Limite de Debito   "
                            "Telefone Res. Telefone Cel. "
                            "Rendimento         Outros Rendimentos"
                            aux_lbfatdb1 AT 299 FORMAT "X(14)"
                            aux_lbfatdb2 AT 318 FORMAT "X(14)"
                            aux_lbfatdb3 AT 337 FORMAT "X(14)"
                            SKIP
                            "----------- --- ---------- ----------- "
                            "--------------------------- -------------- "
                            "--------------- ------- "
                            "------------------- ----------- ---------- "
                            "--------------- ---------- "
                            "----------------- ------------------ "
                            "------------------ ------------- ------------- "
                            "------------------ ------------------ "
                            "------------------ ------------------ "
                            "------------------ "
                            SKIP.
                     
	   		   	     ASSIGN aux_flgercab = TRUE.			   
                     
	   		   	     PUT STREAM str_1
                                aux_nmrescop      AT 1 FORMAT "x(11)"
	   		   	     	        crapass.cdagenci  AT 13
	   		   	     	        crawcrd.nrdconta  AT 17
	   		   	     	        crapass.nrdctitg  AT 28
	   		   	     	        crawcrd.nmtitcrd  AT 40 FORMAT "x(27)"
	   		   	     	        aux_nrcpftit      AT 68 FORMAT "99999999999999"
	   		   	     	        aux_dsadmcrd      AT 83 FORMAT "x(15)"
	   		   	     	        aux_dssitcrd      AT 99 FORMAT "x(7)"
	   		   	     	        crawcrd.nrcrcard  AT 107
	   		   	     	        crawcrd.dtpropos  AT 127
	   		   	     	        crawcrd.dtsolici  AT 139
	   		   	     	        crawcrd.dtcancel  AT 150
	   		   	     	        crawcrd.dtentreg  AT 166
	   		   	     	        crawcrd.dddebito  AT 192
	   		   	     	        aux_vllimcrd      AT 195
	   		   	     	        aux_vllimdeb      AT 214
	   		   	     	        aux_nrreside      AT 233
	   		   	     	        aux_nrcelula      AT 247
	   		   	     	        aux_vlrrendi      AT 261
	   		   	     	        aux_outroren      AT 280
	   		   	     	        aux_vlfatdb1      AT 299
	   		   	     	        aux_vlfatdb2      AT 318
	   		   	     	        aux_vlfatdb3      AT 337
	   		   	     	        SKIP.
               
	   		   	  END.
	   		   ELSE
	   		   	  DO:
	   		   	  	 CREATE tt-cartoes.
                     
	   		   	  	 ASSIGN tt-cartoes.nmrescop = aux_nmrescop
	   		   	  	 	    tt-cartoes.cdagenci = crapass.cdagenci
	   		   	  	 	    tt-cartoes.nrdconta = crawcrd.nrdconta
	   		   	  	 	    tt-cartoes.nrdctitg = crapass.nrdctitg
	   		   	  	 	    tt-cartoes.nmtitcrd = crawcrd.nmtitcrd
	   		   	  	 	    tt-cartoes.nrcpftit = STRING(crawcrd.nrcpftit, "99999999999")
	   		   	  	 	    tt-cartoes.dsadmcrd = aux_dsadmcrd
	   		   	  	 	    tt-cartoes.dssitcrd = aux_dssitcrd
	   		   	  	 	    tt-cartoes.nrcrcard = crawcrd.nrcrcard
	   		   	  	 	    tt-cartoes.dtpropos = crawcrd.dtpropos
	   		   	  	 	    tt-cartoes.dtsolici = crawcrd.dtsolici
	   		   	  	 	    tt-cartoes.dtcancel = crawcrd.dtcancel
	   		   	  	 	    tt-cartoes.dtentreg = crawcrd.dtentreg
	   		   	  	 	    tt-cartoes.dddebito = crawcrd.dddebito
	   		   	  	 	    tt-cartoes.nrreside = aux_nrreside
	   		   	  	 	    tt-cartoes.nrcelula = aux_nrcelula
	   		   	  	 	    tt-cartoes.vllimdeb = aux_vllimdeb
	   		   	  	 	    tt-cartoes.vllimcrd = aux_vllimcrd
	   		   	  	 	    tt-cartoes.vlfatdb1 = aux_vlfatdb1
	   		   	  	 	    tt-cartoes.vlfatdb2 = aux_vlfatdb2
	   		   	  	 	    tt-cartoes.vlfatdb3 = aux_vlfatdb3
	   		   	  	 	    tt-cartoes.vlrrendi = aux_vlrrendi
	   		   	  	 	    tt-cartoes.outroren = aux_outroren.
                     
	   		   	  END.
               
           END. /* crapass*/

       END.

       IF VALID-HANDLE(h-b1wgen0028) THEN
          DELETE PROCEDURE h-b1wgen0028.
       
       OUTPUT STREAM str_1 CLOSE.

       ASSIGN par_nmarqimp = aux_nmarqimp.

       IF par_lgvisual = "T" THEN
          LEAVE Busca.
       ELSE
       IF par_lgvisual = "A"  THEN
          DO: 
             UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + 
                               aux_nmarquiv).

             IF SEARCH(aux_nmarqimp) <> ? THEN
                UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

          END.
       ELSE 
          DO:
             IF par_idorigem = 5  THEN  /** Ayllos Web **/                     
                DO: 
                   RUN sistema/generico/procedures/b1wgen0024.p 
                       PERSISTENT SET h-b1wgen0024.   
                                                                              
                   IF NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                      DO:                                                    
                          ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                                "b1wgen0024.".               
                          LEAVE Busca.                                     
                      END.                                                   

                   RUN envia-arquivo-web IN h-b1wgen0024                      
                       ( INPUT par_cdcooper,                                  
                         INPUT par_cdagenci,                                  
                         INPUT par_nrdcaixa,                                  
                         INPUT aux_nmarqimp,                                  
                        OUTPUT par_nmarqpdf,                                  
                        OUTPUT TABLE tt-erro ).                               
                   
                   IF VALID-HANDLE(h-b1wgen0024)  THEN                       
                      DELETE PROCEDURE h-b1wgen0024.                         
                                                                             
                   IF RETURN-VALUE <> "OK" THEN                              
                      RETURN "NOK". 

                END.

          END.

       LEAVE Busca.
                           
    END. /* Busca */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           ASSIGN aux_returnvl = "NOK".    

           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog THEN
              RUN proc_gerar_log (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT NO,
                                  INPUT 1, /** idseqttl **/
                                  INPUT par_nmdatela,
                                  INPUT 0, /* nrdconta */
                                 OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* carrega_dados_c */

PROCEDURE carrega_dados_cartoes_bb_debito:         
    
   DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                            	 NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR                            	 NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                            	 NO-UNDO.
   DEF INPUT PARAM par_cdcopaux AS INT                               NO-UNDO.
   DEF INPUT PARAM par_dsadmcrd AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_situacao AS CHAR                              NO-UNDO.
   DEF INPUT PARAM par_lgvisual AS CHAR                            	 NO-UNDO.
   DEF INPUT PARAM par_dsiduser AS CHAR                            	 NO-UNDO.
   DEF INPUT PARAM par_dtinicio AS DATE                              NO-UNDO.
   DEF INPUT PARAM par_ddtfinal AS DATE                              NO-UNDO.
   DEF INPUT PARAM par_flgerlog AS LOGI                            	 NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                            	 NO-UNDO.
   DEF INPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
                                                   
   DEF OUTPUT PARAM par_nmarqimp AS CHAR                           	 NO-UNDO.
   DEF OUTPUT PARAM par_nmarqpdf AS CHAR        		             NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-cartoes.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_cdcritic AS INT                                       NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
   DEF VAR aux_nrdocmto AS DECI                                      NO-UNDO.
   DEF VAR aux_contador AS DATE                                      NO-UNDO.
   DEF VAR aux_contado2 AS INTE                                      NO-UNDO.
   DEF VAR aux_vlrrendi AS DECI FORMAT "zzz,zzz,zzz,zz9.99"          NO-UNDO.
   DEF VAR aux_outroren AS DECI FORMAT "zzz,zzz,zzz,zz9.99"          NO-UNDO.
   DEF VAR aux_histo613 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"          NO-UNDO.
   DEF VAR aux_histo614 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"          NO-UNDO.
   DEF VAR aux_histo668 AS DECI FORMAT "zzz,zzz,zzz,zz9.99"          NO-UNDO.
   DEF VAR aux_flgercab AS LOGI INIT FALSE                           NO-UNDO.
   DEF VAR aux_dsadmcrd AS CHAR                                      NO-UNDO.
   DEF VAR aux_vllimdeb LIKE crapass.vllimdeb                        NO-UNDO.
   DEF VAR aux_dssitcrd AS CHAR                                      NO-UNDO.
   DEF VAR aux_vllimcrd LIKE craptlc.vllimcrd                        NO-UNDO.
   DEF VAR aux_nrreside AS CHAR FORMAT "(xx)xxxx-xxxx"               NO-UNDO. 
   DEF VAR aux_nrcelula AS CHAR FORMAT "(xx)xxxxx-xxxx"              NO-UNDO. 
   DEF VAR aux_returnvl AS CHAR                                      NO-UNDO.
   DEF VAR aux_nrdrowid AS ROWID                                     NO-UNDO.
   DEF VAR aux_nmarquiv AS CHAR                                      NO-UNDO.
   DEF VAR aux_dsorigem AS CHAR                                      NO-UNDO.
   DEF VAR aux_dstransa AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmarqpdf AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmrescop AS CHAR                                      NO-UNDO.

   DEF VAR h-b1wgen0028 AS HANDLE                                    NO-UNDO.
   DEF VAR h-b1wgen0024 AS HANDLE                                    NO-UNDO.
   
   DEF BUFFER b-crapcop1 FOR crapcop.

   EMPTY TEMP-TABLE tt-lancamentos.
   EMPTY TEMP-TABLE tt-cartoes.
   EMPTY TEMP-TABLE tt-situacao.
   
   ASSIGN aux_contador = ?
          aux_contado2 = 0
          aux_nrdocmto = 0
          aux_vlrrendi = 0
          aux_outroren = 0
          aux_histo613 = 0
          aux_histo614 = 0
          aux_histo668 = 0.

   Busca:
   DO ON ERROR UNDO Busca, LEAVE Busca:

      FOR FIRST b-crapcop1 FIELDS(b-crapcop1.dsdircop b-crapcop1.nmrescop)
                           WHERE b-crapcop1.cdcooper = par_cdcopaux
                                 NO-LOCK:

          ASSIGN aux_nmrescop = b-crapcop1.nmrescop.
      
      END.

      IF NOT AVAIL b-crapcop1 THEN
         DO:
             ASSIGN aux_cdcritic = 651.
             LEAVE Busca.
         END.
      
	  IF NOT VALID-HANDLE(h-b1wgen0028) THEN
         RUN sistema/generico/procedures/b1wgen0028.p 
             PERSISTENT SET h-b1wgen0028.
    
      /*Acumula os lancamentos em uma temp-table de cada conta para cada
       data de movimento do periodo de consulta.*/
	  DO aux_contador = par_dtinicio TO par_ddtfinal:
    
	  	 FOR EACH craplcm FIELDS(cdcooper dtmvtolt vllanmto cdhistor nrdconta)
             WHERE (craplcm.cdcooper = par_cdcopaux  AND
                    craplcm.dtmvtolt = aux_contador  AND
                    craplcm.cdhistor = 613)          OR /*Debito*/
                   (craplcm.cdcooper = par_cdcopaux  AND
                    craplcm.dtmvtolt = aux_contador  AND
                    craplcm.cdhistor = 614)          OR /*Saque*/
                   (craplcm.cdcooper = par_cdcopaux  AND
                    craplcm.dtmvtolt = aux_contador  AND
                    craplcm.cdhistor = 668)             /*Tarifa*/
                    NO-LOCK:
             
	  	 	 FIND FIRST tt-lancamentos 
	  	 	  	  WHERE tt-lancamentos.cdcooper = craplcm.cdcooper AND
	  	 	 	        tt-lancamentos.dtmvtolt = craplcm.dtmvtolt AND
                        tt-lancamentos.nrdconta = craplcm.nrdconta
                        NO-LOCK NO-ERROR.
              
	  	 	 IF AVAIL tt-lancamentos THEN
	  	 	 	CASE craplcm.cdhistor:
                     
	  	 	 	   WHEN 613 THEN
	  	 	 	      ASSIGN tt-lancamentos.histo613 = tt-lancamentos.histo613 +
	  	 	 		    							   craplcm.vllanmto.
                     
	  	 	 	   WHEN 614 THEN
	  	 	 	      ASSIGN tt-lancamentos.histo614 = tt-lancamentos.histo614 +
	  	 	 										   craplcm.vllanmto.
             
	  	 	 	   WHEN 668 THEN
	  	 	 	      ASSIGN tt-lancamentos.histo668 = tt-lancamentos.histo668 +
	  	 	 										   craplcm.vllanmto.    
             
	  	 	 	END CASE.
	  	 	 ELSE
	  	 	 	DO:
	  	 	 	   CREATE tt-lancamentos.
             
	  	 	 	   ASSIGN tt-lancamentos.cdcooper = craplcm.cdcooper
	  	 	 	     	  tt-lancamentos.nrdconta = craplcm.nrdconta
	  	 	 	     	  tt-lancamentos.dtmvtolt = craplcm.dtmvtolt
	  	 	 	     	  tt-lancamentos.cdhistor = craplcm.cdhistor.
	         
	  	 	 	   CASE craplcm.cdhistor:
                   
	  	 	 	   	  WHEN 613 THEN
	  	 	 	   	    ASSIGN tt-lancamentos.histo613 = craplcm.vllanmto.
	  	 	 	        
	  	 	 	   	  WHEN 614 THEN
	  	 	 	   	  	ASSIGN tt-lancamentos.histo614 = craplcm.vllanmto.
	  	 	 	        
	  	 	 	   	  WHEN 668 THEN
	  	 	 	   	  	ASSIGN tt-lancamentos.histo668 = craplcm.vllanmto.    
	  	 	 	      
	  	 	 	   END CASE.
                    
	  	 	 	END.
             
	  	 END.
    
	  END.
    
      RUN carrega_situacao(INPUT par_dsadmcrd,
                           INPUT FALSE, /*flgconsu*/
                           INPUT par_situacao,
                           OUTPUT TABLE tt-situacao).                       

	  /*Busca todos os cartoes B.B. da cooperativa em questao.*/
	  FOR EACH crawcrd FIELDS(crawcrd.insitcrd crawcrd.dtsol2vi 
                              crawcrd.cdcooper crawcrd.cdadmcrd
                              crawcrd.nrdconta crawcrd.tpcartao 
                              crawcrd.nrcpftit crawcrd.cdlimcrd
                              crawcrd.nrcctitg crawcrd.nmtitcrd
                              crawcrd.dtpropos crawcrd.dtsolici
                              crawcrd.dtcancel crawcrd.dtentreg
                              crawcrd.dddebito crawcrd.nrcrcard)
                       WHERE crawcrd.cdcooper = par_cdcopaux AND
	  					     crawcrd.cdadmcrd > 82           AND
	  					     crawcrd.cdadmcrd < 89 
	  					     NO-LOCK:
         
	  	  FIND FIRST tt-situacao WHERE tt-situacao.insitcrd = crawcrd.insitcrd
                                       NO-LOCK NO-ERROR.
                           
	  	  IF NOT AVAILABLE tt-situacao THEN
	  	  	 DO:
	  	  	 	IF (crawcrd.insitcrd  = 4) AND
	  	  	 	   (crawcrd.dtsol2vi <> ?) THEN
	  	  	 		DO:
	  	  	 		   FIND FIRST tt-situacao WHERE tt-situacao.insitcrd = 7 
	  	  	 		        					    NO-LOCK NO-ERROR.
                           
	  	  	 		   IF NOT AVAILABLE tt-situacao THEN
	  	  	 		      NEXT.
             
	  	  	 		END.
	  	  	 	ELSE
	  	  	 	   NEXT.
             
	  	  	 END.
               
	  	  FOR FIRST crapadc FIELDS(crapadc.insitadc crapadc.nmresadm)
                            WHERE crapadc.cdcooper = crawcrd.cdcooper AND
                                  crapadc.cdadmcrd = crawcrd.cdadmcrd
                                  NO-LOCK:
          
          END.

	  	  IF NOT AVAILABLE crapadc THEN
	  	     NEXT.
              
	  	  IF crapadc.insitadc = 1 THEN
             NEXT.
          
	  	  FOR FIRST crapass FIELDS(crapass.cdcooper crapass.cdagenci
                                   crapass.inpessoa crapass.vllimdeb
                                   crapass.nrdconta crapass.nrdctitg)
                            WHERE crapass.cdcooper = crawcrd.cdcooper AND
                                  crapass.nrdconta = crawcrd.nrdconta
                                  NO-LOCK:
                                 
          END.

	  	  IF NOT AVAILABLE crapass THEN
	  	     NEXT.
                                     
	  	  /* Migracao AcrediCoop - entra em vigor em 01/01/2014 */
	  	  IF crapass.cdcooper = 2 AND
             CAN-DO("2,4,6,7,11", STRING(crapass.cdagenci)) THEN
	  	  	 DO:
	  	  	    FOR FIRST craptco FIELDS(craptco.cdcooper)
                                  WHERE craptco.cdcopant = crawcrd.cdcooper AND
	  	  					            craptco.nrctaant = crawcrd.nrdconta 
	  	  						        NO-LOCK:

                END.
          
	  	  		IF AVAIL craptco THEN
	  	  		   NEXT.

	  	  	 END.
           
	  	  /* Migracao Altovale - entra em vigor 01/01/2013 */
	  	  IF crapass.cdcooper = 1                                 AND
	  	  	 CAN-DO("7,33,38,60,62,66", STRING(crapass.cdagenci)) THEN
	  	     DO:
	  	  	    FOR FIRST craptco FIELDS(craptco.cdcooper)
                                  WHERE craptco.cdcopant = crawcrd.cdcooper AND
	  	  						        craptco.nrctaant = crawcrd.nrdconta 
	  	  						        NO-LOCK:

                END.
              
	  	  		IF AVAIL craptco THEN
	  	  	       NEXT.
          
	  	  	 END.
            
	  	  /* Migracao Concredi e Credimilsul - entra em vigor 30/11/2014 */
	  	  IF crapass.cdcooper = 4 OR
	  	  	 crapass.cdcooper = 15 THEN
	  	  	 DO:
	  	  	    FOR FIRST craptco FIELDS(craptco.cdcooper)
                                  WHERE craptco.cdcopant = crawcrd.cdcooper AND
                                        craptco.nrctaant = crawcrd.nrdconta
                                        USE-INDEX craptco2 NO-LOCK:

                END.
             
	  	  	    IF AVAIL craptco THEN
	  	  	 	   NEXT.

	  	  	 END.  
          
	  	  ASSIGN aux_dsadmcrd = crapadc.nmresadm
                 aux_vllimdeb = crapass.vllimdeb
                 aux_vlrrendi = 0
                 aux_outroren = 0
	  	         aux_dssitcrd = DYNAMIC-FUNCTION("retorna-situacao" 
                                               IN h-b1wgen0028,
                                               INPUT crawcrd.insitcrd,
                                               INPUT crawcrd.dtsol2vi,
                                               INPUT crawcrd.cdadmcrd).
          
          ASSIGN aux_vllimcrd = 0.

	  	  FOR FIRST craptlc FIELDS(craptlc.vllimcrd)
                            WHERE craptlc.cdcooper = crawcrd.cdcooper AND
                                  craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                                  craptlc.tpcartao = crawcrd.tpcartao AND
                                  craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                                  craptlc.dddebito = 0 
                                  NO-LOCK:

              ASSIGN aux_vllimcrd = craptlc.vllimcrd.

          END.

	  	  ASSIGN aux_nrreside = ""
                 aux_nrcelula = ""
                 aux_nrdocmto = DECI(SUBSTR(STRING(crawcrd.nrcctitg), 
                                                     3, 9)).
          
	  	  FOR FIRST craptfc FIELDS(craptfc.nrdddtfc craptfc.nrtelefo)
                            WHERE craptfc.cdcooper = crawcrd.cdcooper AND
                                  craptfc.nrdconta = crawcrd.nrdconta AND
                                  craptfc.tptelefo = 1 
                                  NO-LOCK:

	  	  	  ASSIGN aux_nrreside = STRING(craptfc.nrdddtfc) +  
	  	  	      				    STRING(craptfc.nrtelefo).

          END.
	  	               
	  	  FOR FIRST craptfc FIELDS(craptfc.nrdddtfc craptfc.nrtelefo)
                            WHERE craptfc.cdcooper = crawcrd.cdcooper AND
	  	  	   				      craptfc.nrdconta = crawcrd.nrdconta AND
                                  craptfc.tptelefo = 2 
                                  NO-LOCK:

	  	  	  ASSIGN aux_nrcelula = STRING(craptfc.nrdddtfc) +  
                                    STRING(craptfc.nrtelefo).

          END.
                 
	  	  IF crapass.inpessoa = 1 THEN
	  	  	 DO:
	  	  	 	FOR EACH crapttl FIELD(crapttl.vlsalari crapttl.vldrendi)
                                 WHERE crapttl.cdcooper = crapass.cdcooper AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.nrcpfcgc = crawcrd.nrcpftit
                                       NO-LOCK:
             
	  	  	 		ASSIGN aux_vlrrendi = crapttl.vlsalari.
             
	  	  	 		DO aux_contado2 = 1 TO 6:
             
	  	  	 		   ASSIGN aux_outroren = aux_outroren +
                                             crapttl.vldrendi[aux_contado2].
             
	  	  	 		END.
             
	  	  	 	END.
	  	  	 END.
	  	  ELSE
	  	  	 DO:
                FOR FIRST crapjur FIELDS(vlfatano)
	   		                      WHERE crapjur.cdcooper = crapass.cdcooper AND
	   		      			            crapjur.nrdconta = crapass.nrdconta
	   		    				        NO-LOCK:
                
	   		        ASSIGN aux_vlrrendi =  crapjur.vlfatano / 12.
	   		    END.

             END.
             
	  	  FIND FIRST tt-lancamentos 
               WHERE tt-lancamentos.cdcooper = crawcrd.cdcooper AND
                     tt-lancamentos.nrdconta = crawcrd.nrdconta
                     NO-LOCK NO-ERROR.
          
	  	  IF AVAIL tt-lancamentos THEN
	  	  	 FOR EACH tt-lancamentos 
	  	  	     WHERE tt-lancamentos.cdcooper = crawcrd.cdcooper AND
                       tt-lancamentos.nrdconta = crawcrd.nrdconta
                       NO-LOCK:
              
	  	  		 CREATE tt-cartoes.
                   
	  	  		 ASSIGN tt-cartoes.cdcooper = crawcrd.cdcooper
                        tt-cartoes.nmrescop = aux_nmrescop
                        tt-cartoes.cdagenci = crapass.cdagenci
                        tt-cartoes.nrdconta = crawcrd.nrdconta
                        tt-cartoes.nrdctitg = crapass.nrdctitg
                        tt-cartoes.nmtitcrd = crawcrd.nmtitcrd
                        tt-cartoes.nrcpftit = STRING(crawcrd.nrcpftit, 
                                                     "99999999999")
                        tt-cartoes.nrcpftit = STRING(tt-cartoes.nrcpftit,
                                                     "xxx.xxx.xxx-xx")
                        tt-cartoes.dsadmcrd = aux_dsadmcrd    
                        tt-cartoes.dssitcrd = aux_dssitcrd    
                        tt-cartoes.nrcrcard = crawcrd.nrcrcard
                        tt-cartoes.dtpropos = crawcrd.dtpropos
                        tt-cartoes.dtsolici = crawcrd.dtsolici
                        tt-cartoes.dtcancel = crawcrd.dtcancel
                        tt-cartoes.dtentreg = crawcrd.dtentreg
                        tt-cartoes.dddebito = crawcrd.dddebito
                        tt-cartoes.nrreside = aux_nrreside
                        tt-cartoes.nrcelula = aux_nrcelula
                        tt-cartoes.vllimdeb = aux_vllimdeb
                        tt-cartoes.vllimcrd = aux_vllimcrd
                        tt-cartoes.dtmvtolt = tt-lancamentos.dtmvtolt
                        tt-cartoes.vlrrendi = aux_vlrrendi
                        tt-cartoes.outroren = aux_outroren.
                   
	  	  		 CASE tt-lancamentos.cdhistor:
                   
	  	  		 	WHEN 613 THEN
	  	  		 		ASSIGN tt-cartoes.histo613 = tt-lancamentos.histo613.
                   
	  	  		 	WHEN 614 THEN
	  	  		 		ASSIGN tt-cartoes.histo614 = tt-lancamentos.histo614.
                   
	  	  		 	WHEN 668 THEN
	  	  		 		ASSIGN tt-cartoes.histo668 = tt-lancamentos.histo668.    
                   
	  	  		 END CASE.
              
	  	  	 END.
	  	  ELSE
	  	  	 DO:
	  	  	  	CREATE tt-cartoes.
                   
	  	  	 	ASSIGN tt-cartoes.cdcooper = crawcrd.cdcooper
                       tt-cartoes.nmrescop = aux_nmrescop
                       tt-cartoes.cdagenci = crapass.cdagenci
                       tt-cartoes.nrdconta = crawcrd.nrdconta
                       tt-cartoes.nrdctitg = crapass.nrdctitg
                       tt-cartoes.nmtitcrd = crawcrd.nmtitcrd
                       tt-cartoes.nrcpftit = STRING(crawcrd.nrcpftit, 
                                                    "99999999999")
                       tt-cartoes.nrcpftit = STRING(tt-cartoes.nrcpftit,
                                                    "xxx.xxx.xxx-xx")
                       tt-cartoes.dsadmcrd = aux_dsadmcrd    
                       tt-cartoes.dssitcrd = aux_dssitcrd    
                       tt-cartoes.nrcrcard = crawcrd.nrcrcard
                       tt-cartoes.dtpropos = crawcrd.dtpropos
                       tt-cartoes.dtsolici = crawcrd.dtsolici
                       tt-cartoes.dtcancel = crawcrd.dtcancel
                       tt-cartoes.dtentreg = crawcrd.dtentreg
	  	  	 		   tt-cartoes.dddebito = crawcrd.dddebito
                       tt-cartoes.nrreside = aux_nrreside
                       tt-cartoes.nrcelula = aux_nrcelula
                       tt-cartoes.vllimdeb = aux_vllimdeb
                       tt-cartoes.vllimcrd = aux_vllimcrd
                       tt-cartoes.vlrrendi = aux_vlrrendi
                       tt-cartoes.outroren = aux_outroren.
             
	  	  	 END.
             
	  END.

	  IF VALID-HANDLE(h-b1wgen0028) THEN
	  	DELETE PROCEDURE h-b1wgen0028.
    
	  IF par_lgvisual <> "T" THEN
	  	 DO:                    
            ASSIGN aux_nmendter = "/usr/coop/" + b-crapcop1.dsdircop + "/rl/" +
                                   par_dsiduser
	    	       aux_nmendter = aux_nmendter + STRING(TIME)       
	    	       aux_nmarqimp = aux_nmendter + ".ex"          
	    	       aux_nmarqpdf = aux_nmendter + ".pdf"
	    	       aux_nmarquiv = "/micros/" + b-crapcop1.dsdircop + "/" + 
                                  par_nmarquiv
	    	       aux_nmarquiv = aux_nmarquiv + ".txt".

            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

	  	 	FOR EACH tt-cartoes WHERE tt-cartoes.cdcooper = par_cdcopaux 
                                      NO-LOCK BY tt-cartoes.cdcooper
                                               BY tt-cartoes.dtmvtolt
                                                BY tt-cartoes.nrdconta:
         
	  	 		IF NOT aux_flgercab                         OR
	  	 		   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
	  	 		   PUT STREAM str_1 UNFORMATTED
                          "Data       Cooperativa  PA   Conta/DV   "
                          "Conta/ITG Titular do Cartao"
                          "           CPF Titular    Administradora  Sit."
                          "Conta Cartao " AT 121
                          "Dt.Proposta Dt.Pedido  Dt.Cancelamento " AT 138
                          "Dt.Entrega Dia do debito C/C "
                          "Limite de Credito  Limite de Debito   "
                          "Telefone Res. Telefone Cel. "
                          "Rendimento         Outros Rendimentos"
                          "Hist.613 DB"       AT 310
                          "Hist.614 SAQ"      AT 329
                          "Hist.668 TRF"      AT 348
                          SKIP
                          "---------- ----------- --- ---------- "
                          "----------- --------------------------- "
                          "-------------- --------------- ------- "
                          "------------------- ----------- ---------- "
                          "--------------- ---------- "
                          "----------------- ------------------ "
                          "------------------ ------------- ------------- "
                          "------------------ ------------------ "
                          "------------------ ------------------ "
                          "------------------"
                          SKIP.
         
	  	 		ASSIGN aux_flgercab = TRUE.
         
	  	 		PUT STREAM str_1 
	  	 			tt-cartoes.dtmvtolt AT 1
                    tt-cartoes.nmrescop AT 12  FORMAT "x(11)"
                    tt-cartoes.cdagenci AT 24
                    tt-cartoes.nrdconta AT 28
                    tt-cartoes.nrdctitg AT 39
                    tt-cartoes.nmtitcrd AT 51  FORMAT "x(27)"
                    tt-cartoes.nrcpftit AT 79  FORMAT "99999999999999"
                    tt-cartoes.dsadmcrd AT 94  FORMAT "x(15)"
                    tt-cartoes.dssitcrd AT 110 FORMAT "x(7)"
                    tt-cartoes.nrcrcard AT 118
                    tt-cartoes.dtpropos AT 138
                    tt-cartoes.dtsolici AT 150
                    tt-cartoes.dtcancel AT 161
                    tt-cartoes.dtentreg AT 177
                    tt-cartoes.dddebito AT 203
                    tt-cartoes.vllimcrd AT 206 FORMAT "zzz,zzz,zzz,zz9.99"
                    tt-cartoes.vllimdeb AT 225 FORMAT "zzz,zzz,zzz,zz9.99"
                    tt-cartoes.nrreside AT 244
                    tt-cartoes.nrcelula AT 258
                    tt-cartoes.vlrrendi AT 272
                    tt-cartoes.outroren AT 291
                    tt-cartoes.histo613 AT 310
                    tt-cartoes.histo614 AT 329
                    tt-cartoes.histo668 AT 348
                    SKIP.
         
	  	 	END.
               
            OUTPUT STREAM str_1 CLOSE.

	  	 END.
    
      ASSIGN aux_returnvl = "OK"
             par_nmarqimp = aux_nmarqimp.

      IF par_lgvisual = "T" THEN
         LEAVE Busca.
      ELSE
      IF par_lgvisual = "A"  THEN
         DO:
            UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + 
                              aux_nmarquiv).

            IF SEARCH(aux_nmarqimp) <> ? THEN
               UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

         END.
      ELSE 
         DO:
            IF par_idorigem = 5  THEN  /** Ayllos Web **/                     
               DO: 
                  RUN sistema/generico/procedures/b1wgen0024.p 
                      PERSISTENT SET h-b1wgen0024.   
                                                                             
                  IF NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                     DO:                                                    
                         ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                               "b1wgen0024.".               
                         LEAVE Busca.                                     
                     END.                                                   
                                                                             
                  RUN envia-arquivo-web IN h-b1wgen0024                      
                      ( INPUT par_cdcooper,                                  
                        INPUT par_cdagenci,                                  
                        INPUT par_nrdcaixa,                                  
                        INPUT aux_nmarqimp,                                  
                       OUTPUT par_nmarqpdf,                                  
                       OUTPUT TABLE tt-erro ).                               
                                                                             
                  IF VALID-HANDLE(h-b1wgen0024)  THEN                       
                     DELETE PROCEDURE h-b1wgen0024.                         
                                                                            
                  IF RETURN-VALUE <> "OK" THEN                              
                     RETURN "NOK".                                       

               END.

         END.

	  LEAVE Busca.

	END. /* Busca */

    IF aux_dscritic <> ""             OR
       aux_cdcritic <> 0              OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          ASSIGN aux_returnvl = "NOK".    

          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    
    RETURN aux_returnvl.

END PROCEDURE.


PROCEDURE verifica_periodo:

    DEF INPUT PARAM par_dtinicio AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_ddtfinal AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_insitcrd LIKE crawcrd.insitcrd                NO-UNDO.
    DEF INPUT PARAM par_dtsol2vi LIKE crawcrd.dtsol2vi                NO-UNDO.
    DEF INPUT PARAM par_dtpropos LIKE crawcrd.dtpropos                NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crawcrd.dtmvtolt                NO-UNDO.
    DEF INPUT PARAM par_dtsolici LIKE crawcrd.dtsolici                NO-UNDO.
    DEF INPUT PARAM par_dtlibera LIKE crawcrd.dtlibera                NO-UNDO.
    DEF INPUT PARAM par_dtentreg LIKE crawcrd.dtentreg                NO-UNDO.
    DEF INPUT PARAM par_dtentr2v LIKE crawcrd.dtentr2v                NO-UNDO.
    DEF INPUT PARAM par_dtcancel LIKE crawcrd.dtcancel                NO-UNDO.

    DEF VAR aux_dtinici AS DATE INIT 01/01/0001 FORMAT "99/99/9999"   NO-UNDO.
    DEF VAR aux_dtfinal AS DATE INIT 12/30/9999 FORMAT "99/99/9999"   NO-UNDO.
    
    IF par_dtinicio = ? AND
       par_ddtfinal = ? THEN
       RETURN "OK".

    IF par_dtinicio <> ? THEN
       ASSIGN aux_dtinici = par_dtinicio.
    
    IF par_ddtfinal <> ? THEN
       ASSIGN aux_dtfinal = par_ddtfinal.
    
    IF ((par_insitcrd  = 4  		  AND 
         par_dtsol2vi <> ?) 		  OR
        (par_insitcrd  = 7))  		  AND  
        (par_dtsol2vi >= aux_dtinici  AND
         par_dtsol2vi <= aux_dtfinal) THEN
       RETURN "OK". 
  
    IF par_insitcrd  = 0           AND  
       par_dtpropos >= aux_dtinici AND
       par_dtpropos <= aux_dtfinal THEN
       RETURN "OK".

    IF par_insitcrd  = 1            AND  
       par_dtmvtolt >= aux_dtinici  AND
       par_dtmvtolt <= aux_dtfinal  THEN
       RETURN "OK".
                
    IF par_insitcrd = 2            AND 
       par_dtsolici >= aux_dtinici AND
       par_dtsolici <= aux_dtfinal THEN
       RETURN "OK".

    IF par_insitcrd = 3            AND 
       par_dtlibera >= aux_dtinici AND
       par_dtlibera <= aux_dtfinal THEN
       RETURN "OK".

    IF (par_insitcrd = 4) 		     AND     
       (par_dtentreg >= aux_dtinici  AND
        par_dtentreg <= aux_dtfinal) OR 
       (par_dtentr2v >= aux_dtinici  AND
        par_dtentr2v <= aux_dtfinal) THEN
       RETURN "OK".

    IF par_insitcrd = 5            AND   
       par_dtcancel >= aux_dtinici AND
       par_dtcancel <= aux_dtfinal THEN
       RETURN "OK".

    IF par_insitcrd = 6            AND  
       par_dtcancel >= aux_dtinici AND
       par_dtcancel <= aux_dtfinal THEN
       RETURN "OK".

    RETURN "NOK".
   
END PROCEDURE.


/* -------------------------------------------------------------------------- */
/*                             BUSCA VALORES                                  */
/* -------------------------------------------------------------------------- */

PROCEDURE busca_valores_cartao:

    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_dsadmcrd AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_cdcooper LIKE crawcrd.cdcooper                NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE crawcrd.nrdconta                NO-UNDO.
    DEF INPUT PARAM par_nrcctitg LIKE crawcrd.nrcctitg                NO-UNDO.
    DEF INPUT PARAM par_nrcrcard LIKE crawcrd.nrcrcard                NO-UNDO.
   
    DEF OUTPUT PARAM par_vlfatdb1 AS DECI                			  NO-UNDO.
    DEF OUTPUT PARAM par_vlfatdb2 AS DECI                			  NO-UNDO.
    DEF OUTPUT PARAM par_vlfatdb3 AS DECI                			  NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtmesant AS DATE                				      NO-UNDO.
    DEF VAR aux_nrdocmto AS DECI                				      NO-UNDO.
    DEF VAR aux_dtmesint AS DATE                				      NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                				      NO-UNDO.
    DEF VAR aux_dstransa  AS CHAR                                     NO-UNDO.
    DEF VAR aux_dsorigem  AS CHAR                                     NO-UNDO.
    DEF VAR aux_cdcritic  AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic  AS CHAR                                     NO-UNDO.
    DEF VAR aux_returnvl  AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrdrowid  AS ROWID                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Relacao de autorizacoes de debito".              

    EMPTY TEMP-TABLE tt-erro.         
    
    Busca:
    DO ON ERROR UNDO Busca, LEAVE Busca:

       ASSIGN aux_dtmesint = DATE("01/" + STRING( MONTH(par_dtmvtolt), "99" ) +
                             "/" + STRING( YEAR(par_dtmvtolt), "9999" ) )
              aux_dtmesint = ADD-INTERVAL(aux_dtmesint, -3, "months")

              aux_dtmvtolt = DATE("01/" + STRING( MONTH(par_dtmvtolt), "99" ) +
                             "/" + STRING( YEAR(par_dtmvtolt), "9999" ) )
              aux_dtmvtolt = aux_dtmvtolt - 1 

              aux_dtmesant = ADD-INTERVAL(aux_dtmvtolt, -3, "months") 
                            /*usada para pegar os 3 ultimos meses*/   

              aux_nrdocmto = DECI(SUBSTR(STRING(par_nrcctitg), 3, 9))
              par_vlfatdb1 = 0
              par_vlfatdb2 = 0
              par_vlfatdb3 = 0.

       IF par_dsadmcrd = "BANCO DO BRASIL" THEN /*BANCO BRASIL*/
          DO:
             FOR EACH craplcm FIELDS(dtmvtolt vllanmto)
                              WHERE (craplcm.cdcooper = par_cdcooper  AND
                                     craplcm.nrdconta = par_nrdconta  AND
                                     /* 658-PGT.CARTAO BB */ 
                                     craplcm.cdhistor = 658           AND 
                                     craplcm.nrdocmto = aux_nrdocmto  AND   
                                     craplcm.dtmvtolt >= aux_dtmesint AND
                                     craplcm.dtmvtolt <= aux_dtmvtolt)
                                     NO-LOCK:

                 CASE MONTH(craplcm.dtmvtolt):
                     WHEN MONTH(ADD-INTERVAL(aux_dtmesant, 1, "months")) THEN
                         ASSIGN par_vlfatdb1 = 
                                par_vlfatdb1 + 
                                craplcm.vllanmto.

                     WHEN MONTH(ADD-INTERVAL(aux_dtmesant, 2, "months")) THEN
                         ASSIGN par_vlfatdb2 = 
                                par_vlfatdb2 + 
                                craplcm.vllanmto.

                     WHEN MONTH(ADD-INTERVAL(aux_dtmesant, 3, "months")) THEN
                         ASSIGN par_vlfatdb3 = 
                                par_vlfatdb3 + 
                                craplcm.vllanmto.

                 END CASE.

             END.
          END.
       ELSE /*BRADESCO*/
          DO: 
             FOR EACH crapdcd FIELDS(dtdebito vldebito)
                              WHERE crapdcd.cdcooper = par_cdcooper   AND
                                    crapdcd.nrdconta = par_nrdconta   AND
                                    crapdcd.nrcrcard = par_nrcrcard   AND
                                    crapdcd.dtdebito >= aux_dtmesint  AND
                                    crapdcd.dtdebito <= aux_dtmvtolt 
                                    NO-LOCK:

                 CASE MONTH(crapdcd.dtdebito):
                     WHEN MONTH(ADD-INTERVAL(aux_dtmesant, 1, "months")) THEN
                         ASSIGN par_vlfatdb1 = 
                                par_vlfatdb1 + 
                                crapdcd.vldebito.

                     WHEN MONTH(ADD-INTERVAL(aux_dtmesant, 2, "months")) THEN
                         ASSIGN par_vlfatdb2 = 
                                par_vlfatdb2 + 
                                crapdcd.vldebito.

                     WHEN MONTH(ADD-INTERVAL(aux_dtmesant, 3, "months")) THEN
                         ASSIGN par_vlfatdb3 = 
                                par_vlfatdb3 + 
                                crapdcd.vldebito.

                 END CASE.                  

             END.

          END.

       LEAVE Busca.

    END. /* Busca */

    IF aux_dscritic <> "" OR
       aux_cdcritic <> 0  THEN
       DO:
          ASSIGN aux_returnvl = "NOK".    

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
    
          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    ELSE
       ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.
    
END PROCEDURE. /* busca_valores_cartao */

PROCEDURE importa_cartao:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nmarqimp AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
                                                                  
    DEF VAR aux_nmrescop AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdireto AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqrel AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqdst AS CHAR                                    NO-UNDO.
    DEF VAR aux_setlinha AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgregis AS LOGI                                    NO-UNDO.
                                                                  
    DEF VAR aux_nrcrcard AS CHAR                                    NO-UNDO.
    DEF VAR aux_vllimcrd AS DECI                                    NO-UNDO.
    DEF VAR aux_nrdoccrd LIKE crawcrd.nrdoccrd                      NO-UNDO.
    DEF VAR aux_dtnasccr LIKE crawcrd.dtnasccr                      NO-UNDO.
    DEF VAR aux_dsendere LIKE crapenc.dsendere                      NO-UNDO.
    DEF VAR aux_nrendere LIKE crapenc.nrendere                      NO-UNDO.
    DEF VAR aux_nmbairro LIKE crapenc.nmbairro                      NO-UNDO.
    DEF VAR aux_nmcidade LIKE crapenc.nmcidade                      NO-UNDO.
    DEF VAR aux_cdufende LIKE crapenc.cdufende                      NO-UNDO.
    DEF VAR aux_nrcepend LIKE crapenc.nrcepend                      NO-UNDO.
    DEF VAR aux_dssitcrd AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscomple AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0028 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

    FORM crapcrd.nrcrcard COLUMN-LABEL "Numero do cartao"  FORMAT "9999,9999,9999,9999"
         crapcrd.nmtitcrd COLUMN-LABEL "Titular do cartao" FORMAT "x(40)"
         crapcrd.cdcooper COLUMN-LABEL "Cod.Coop."         FORMAT "zz9"
         crapcrd.nrdconta COLUMN-LABEL "Conta/dv"          FORMAT "zzzz,zzz,9"
         crapass.cdagenci COLUMN-LABEL "PA "               FORMAT "zz9"
         crapcrd.nrcpftit COLUMN-LABEL "CPF do titular"    FORMAT "zzzzzzzzzz9"
         aux_dssitcrd     COLUMN-LABEL "Sit.Cartao."       FORMAT "x(15)"
         crapcrd.dddebito COLUMN-LABEL "Dia debito"
         crapcrd.dtvalida COLUMN-LABEL "Validade cartao"
         aux_vllimcrd     COLUMN-LABEL "Lim.Cartao "       FORMAT "zzz,zzz,zzz,zz9.99"
         aux_dsendere     COLUMN-LABEL "Endereco"          FORMAT "x(35)"
         aux_dscomple     COLUMN-LABEL "Complemento"       FORMAT "x(25)"
         aux_nrendere     COLUMN-LABEL "Nro."
         aux_nmbairro     COLUMN-LABEL "Bairro"            FORMAT "x(25)"
         aux_nmcidade     COLUMN-LABEL "Cidade"            FORMAT "x(25)"
         aux_cdufende     COLUMN-LABEL "U.F."
         aux_nrcepend     COLUMN-LABEL "C.E.P."
         WITH DOWN WIDTH 362 FRAME f_list_cartoes.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Importacao de cartoes (MOVTOS)"
           aux_nmrescop = "".              

    EMPTY TEMP-TABLE tt-erro.

    Importa: 
    DO ON ERROR UNDO Importa, LEAVE Importa:

       FOR FIRST crapcop FIELDS(crapcop.cdcooper crapcop.dsdircop)
                         WHERE crapcop.cdcooper = par_cdcooper 
                               NO-LOCK:

           ASSIGN aux_nmrescop = crapcop.dsdircop.

       END.
       
       ASSIGN aux_nmdireto = "/micros/" + aux_nmrescop + "/"
              aux_nmarquiv = aux_nmdireto + par_nmarqimp
              aux_nmarqrel = "/micros/" + crapcop.dsdircop + "/movtos_" + 
                             STRING(TIME) + "_2.txt"
              aux_nmarqdst = "/micros/" + crapcop.dsdircop + "/movtos_" + 
                             STRING(TIME) + ".txt".
       
       IF SEARCH(aux_nmarquiv) = ?   THEN
          DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Arquivo informado nao foi encontrado.".

             LEAVE Importa.
          END.
       
       INPUT  STREAM str_1 FROM VALUE(aux_nmarquiv).
       OUTPUT STREAM str_2 TO VALUE(aux_nmarqrel).
       
       IF NOT VALID-HANDLE(h-b1wgen0028) THEN
          RUN sistema/generico/procedures/b1wgen0028.p 
              PERSISTENT SET h-b1wgen0028.
       
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE
                     ON ERROR  UNDO, LEAVE:
       
          IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
       
          ASSIGN aux_flgregis = FALSE.
       
          FOR EACH crapcop FIELDS(crapcop.cdcooper) NO-LOCK,
         
              EACH crapcrd FIELDS(crapcrd.cdcooper crapcrd.nrdconta
                                  crapcrd.nrctrcrd crapcrd.cdadmcrd
                                  crapcrd.tpcartao crapcrd.cdlimcrd
                                  crapcrd.nmtitcrd crapcrd.nrcrcard
                                  crapcrd.nrcpftit crapcrd.dddebito 
                                  crapcrd.dtvalida )
                           WHERE crapcrd.cdcooper = crapcop.cdcooper AND
                                 crapcrd.nrcrcard = DECIMAL(aux_setlinha)
                                 USE-INDEX crapcrd3 
                                 NO-LOCK:
       
              /* Se foi uma conta migrada, next */
              FOR FIRST craptco FIELDS(craptco.cdcooper)
                                WHERE craptco.cdcopant = crapcrd.cdcooper AND
                                      craptco.nrctaant = crapcrd.nrdconta AND
                                      craptco.tpctatrf <> 3                  
                                      NO-LOCK:
       
              END.

              IF AVAIL craptco THEN
                 NEXT.
       
              ASSIGN aux_flgregis = TRUE.
       
              FOR FIRST crapass FIELDS(crapass.cdagenci)
                                WHERE crapass.cdcooper = crapcrd.cdcooper AND
                                      crapass.nrdconta = crapcrd.nrdconta
                                      NO-LOCK:

              END.

              ASSIGN aux_nrdoccrd = ""
                     aux_dtnasccr = ?
                     aux_dssitcrd = "".

              FOR FIRST crawcrd FIELDS(crawcrd.nrdoccrd crawcrd.dtnasccr
                                       crawcrd.nrdconta crawcrd.cdcooper
                                       crawcrd.cdgraupr crawcrd.insitcrd
                                       crawcrd.dtsol2vi crawcrd.cdadmcrd)
                                WHERE crawcrd.cdcooper = crapcrd.cdcooper AND
                                      crawcrd.nrdconta = crapcrd.nrdconta AND
                                      crawcrd.nrctrcrd = crapcrd.nrctrcrd 
                                      USE-INDEX crawcrd1 NO-LOCK:

                  ASSIGN aux_nrdoccrd = crawcrd.nrdoccrd
                         aux_dtnasccr = crawcrd.dtnasccr
                         aux_dssitcrd = 
                            DYNAMIC-FUNCTION("retorna-situacao" IN h-b1wgen0028,
                                          INPUT crawcrd.insitcrd,
                                          INPUT crawcrd.dtsol2vi,
                                          INPUT crawcrd.cdadmcrd).

              END.

              ASSIGN aux_vllimcrd = 0.

              FOR FIRST craptlc FIELDS(craptlc.vllimcrd)
                                WHERE craptlc.cdcooper = crapcrd.cdcooper AND
                                      craptlc.cdadmcrd = crapcrd.cdadmcrd AND
                                      craptlc.tpcartao = crapcrd.tpcartao AND
                                      craptlc.cdlimcrd = crapcrd.cdlimcrd AND
                                      craptlc.dddebito = 0  
                                      NO-LOCK:
              
                  ASSIGN aux_vllimcrd = craptlc.vllimcrd.

              END.

              ASSIGN aux_dsendere = ""
                     aux_dscomple = ""
                     aux_nrendere = 0
                     aux_nmbairro = ""
                     aux_nmcidade = ""
                     aux_cdufende = ""
                     aux_nrcepend = 0.
       
              FOR FIRST crapenc FIELDS(crapenc.complend crapenc.nrendere
                                       crapenc.nmbairro crapenc.nmcidade
                                       crapenc.dsendere crapenc.cdufende
                                       crapenc.nrcepend)
                                WHERE crapenc.cdcooper = crapcrd.cdcooper AND
                                      crapenc.nrdconta = crawcrd.nrdconta AND
                                      crapenc.idseqttl = 1                AND
                                      crapenc.cdseqinc = 1 
                                      USE-INDEX crapenc1 NO-LOCK:
       
                    IF crawcrd.cdgraupr = 5 OR    /* Primeiro Titular */
                       crawcrd.cdgraupr = 6 THEN  /* Segundo Titular */
                       ASSIGN aux_dsendere = REPLACE(SUBSTRING(crapenc.dsendere,1,33),",","")
                              aux_dsendere = Retira_Caracteres(aux_dsendere,".;/;-;:;=")
                              aux_dscomple = crapenc.complend
                              aux_nrendere = crapenc.nrendere
                              aux_nmbairro = Retira_Caracteres(crapenc.nmbairro,".")
                              aux_nmcidade = Retira_Caracteres(crapenc.nmcidade,".;-;,")
                              aux_cdufende = crapenc.cdufende
                              aux_nrcepend = crapenc.nrcepend.

              END.
       
              DISPLAY STREAM str_2 crapcrd.nrcrcard
                                   crapcrd.nmtitcrd
                                   crapcrd.cdcooper
                                   crapcrd.nrdconta
                                   crapass.cdagenci WHEN AVAIL crapass
                                   crapcrd.nrcpftit
                                   aux_dssitcrd    
                                   crapcrd.dddebito
                                   crapcrd.dtvalida
                                   aux_vllimcrd    
                                   aux_dsendere    
                                   aux_dscomple    
                                   aux_nrendere    
                                   aux_nmbairro    
                                   aux_nmcidade    
                                   aux_cdufende    
                                   aux_nrcepend    
                                   WITH FRAME f_list_cartoes.
       
              DOWN WITH FRAME f_list_cartoes.

          END.
       
          IF NOT aux_flgregis THEN
             DO:
                ASSIGN aux_nrcrcard = REPLACE(STRING(aux_setlinha,"9999,9999,9999,9999"),",",".").
       
                DISPLAY STREAM str_2  
                    aux_nrcrcard FORMAT "x(19)" @ crapcrd.nrcrcard 
                    "0"                         @ crapcrd.nmtitcrd
                     0                          @ crapcrd.cdcooper
                     0                          @ crapcrd.nrdconta
                     0                          @ crapass.cdagenci
                     0                          @ crapcrd.nrcpftit
                    "0"                         @ aux_dssitcrd    
                     0                          @ crapcrd.dddebito
                     0                          @ crapcrd.dtvalida
                     0                          @ aux_vllimcrd    
                    "0"                         @ aux_dsendere    
                    "0"                         @ aux_dscomple    
                     0                          @ aux_nrendere    
                    "0"                         @ aux_nmbairro    
                    "0"                         @ aux_nmcidade    
                    "0"                         @ aux_cdufende    
                     0                          @ aux_nrcepend    
                WITH FRAME f_list_cartoes.
       
                DOWN WITH FRAME f_list_cartoes.
                                       
             END.     

       END.
       
       IF VALID-HANDLE(h-b1wgen0028) THEN
          DELETE PROCEDURE h-b1wgen0028.

       ASSIGN aux_returnvl = "OK".
       
       LEAVE Importa.

    END. /* Importa */

    IF aux_dscritic <> "" OR
       aux_cdcritic <> 0  THEN
       DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
    
          IF par_flgerlog THEN
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT NO,
                                 INPUT 1, /** idseqttl **/
                                 INPUT par_nmdatela,
                                 INPUT 0, /* nrdconta */
                                OUTPUT aux_nrdrowid).
    
       END.
    
    RETURN aux_returnvl.

END PROCEDURE.
