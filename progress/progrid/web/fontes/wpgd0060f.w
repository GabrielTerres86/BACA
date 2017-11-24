/*...............................................................................
  Alterações: 14/07/2017 - Criação da tela PRJ 322 (Jean Michel)
...............................................................................*/

{ sistema/generico/includes/var_log_progrid.i }

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
  FIELD aux_cddopcao AS CHARACTER 
  FIELD aux_stdopcao AS CHARACTER 
  FIELD aux_lspermis AS CHARACTER 
  FIELD aux_nrdrowid AS CHARACTER
  FIELD aux_idevento AS CHARACTER 
  FIELD aux_nrsdirec AS CHARACTER
  FIELD aux_cdevento AS CHARACTER 
  FIELD aux_dsendurl AS CHARACTER 
  FIELD aux_dsretorn AS CHARACTER 
  FIELD aux_idrecpor AS CHARACTER
  FIELD aux_cdtiprec AS CHARACTER
  FIELD aux_cdcopope AS CHARACTER
  FIELD aux_cdoperad AS CHARACTER
  FIELD nrsdirec     AS CHARACTER 
  FIELD qtreceve     AS CHARACTER
  FIELD qtgrppar     AS CHARACTER
  FIELD aux_cdcooper AS CHARACTER
  FIELD aux_dtanoage AS CHARACTER
  FIELD aux_cdagenci AS CHARACTER
  FIELD aux_nrseqeve AS CHARACTER.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0060f"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0060f.w"].
DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
  
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE h-b1wpgd0060f         AS HANDLE                         NO-UNDO.

DEFINE TEMP-TABLE cratree             LIKE crapree.

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0060f.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS 
&Scoped-define ENABLED-TABLES crapree ab_unmap
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapree
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cddopcao ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_nrsdirec ~
ab_unmap.aux_stdopcao ab_unmap.aux_dsendurl ab_unmap.aux_idrecpor ab_unmap.aux_cdcopope  ab_unmap.aux_cdevento ~
ab_unmap.aux_cdtiprec ab_unmap.aux_cdoperad ab_unmap.nrsdirec ab_unmap.qtreceve ab_unmap.qtgrppar ~
ab_unmap.aux_cdcooper ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ab_unmap.aux_nrseqeve
&Scoped-Define DISPLAYED-FIELDS 
&Scoped-define DISPLAYED-TABLES crapree ab_unmap
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapree
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cddopcao ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_nrsdirec ab_unmap.aux_stdopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_idrecpor ab_unmap.aux_cdcopope ab_unmap.aux_cdevento ~
ab_unmap.aux_cdtiprec ab_unmap.aux_cdoperad ab_unmap.nrsdirec ab_unmap.qtreceve ab_unmap.qtgrppar ~
ab_unmap.aux_cdcooper ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ab_unmap.aux_nrseqeve

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

DEFINE FRAME Web-Frame
     ab_unmap.qtreceve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.qtgrppar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsendurl  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsretorn  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrsdirec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4    
    ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.nrsdirec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
    ab_unmap.aux_idrecpor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
    ab_unmap.aux_cdtiprec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN            
    ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1		  
   ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
  ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1		  		  
	ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 47.6 BY 20.1.

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES

{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* **********************  Internal Procedures  *********************** */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaRecursos w-html 

PROCEDURE CriaListaRecursos :

  DEF VAR aux_contador AS INTEGER INIT 0 NO-UNDO.
     
	RUN RodaJavaScript("var recursos = new Array();").
   
  FOR EACH gnaprdp NO-LOCK WHERE gnaprdp.idsitrec = 1 
														 AND gnaprdp.idevento = INT(ab_unmap.aux_idevento)
														 AND gnaprdp.cdtiprec <> 0
															BY gnaprdp.dsrecurs:
         
    RUN RodaJavaScript("recursos.push(~{nrsdirec:'" + TRIM(STRING(gnaprdp.nrseqdig))
                                   + "',dsrecurs:'" + TRIM(STRING(gnaprdp.dsrecurs))
                                   + "',idrecpor:'" + TRIM(STRING(gnaprdp.idrecpor))
                                   + "',cdtiprec:'" + TRIM(STRING(gnaprdp.cdtiprec))+ "'~});").
		
	END. /* for each */

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrsdirec":U,"ab_unmap.aux_nrsdirec":U,ab_unmap.aux_nrsdirec:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrsdirec":U,"ab_unmap.nrsdirec":U,ab_unmap.nrsdirec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtreceve":U,"ab_unmap.qtreceve":U,ab_unmap.qtreceve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtgrppar":U,"ab_unmap.qtgrppar":U,ab_unmap.qtgrppar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idrecpor":U,"ab_unmap.aux_idrecpor":U,ab_unmap.aux_idrecpor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdtiprec":U,"ab_unmap.aux_cdtiprec":U,ab_unmap.aux_cdtiprec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html
PROCEDURE local-assign-record:
	DEFINE INPUT PARAMETER opcao AS CHARACTER.

	/* Instancia a BO para executar as procedures */
	RUN dbo/b1wpgd0060f.p PERSISTENT SET h-b1wpgd0060f.

	EMPTY TEMP-TABLE cratree.

	/* Se BO foi instanciada */
	IF VALID-HANDLE(h-b1wpgd0060f) THEN
		DO:
			DO WITH FRAME {&FRAME-NAME}:
			 IF opcao = "inclusao" THEN
				 DO: 
					CREATE cratree.
					ASSIGN cratree.nrsdieve = INT(ab_unmap.aux_nrseqeve)
						     cratree.nrsdirec = INT(ab_unmap.nrsdirec)
						     cratree.qtreceve = (IF INT(ab_unmap.aux_cdtiprec) = 5 OR INT(ab_unmap.aux_cdtiprec) = 2 THEN 0 ELSE INT(ab_unmap.qtreceve))
								 cratree.qtgrppar = INT(ab_unmap.qtgrppar)
						     cratree.cdoperad = ab_unmap.aux_cdoperad
						     cratree.cdprogra = "WPGD0060f"
						     cratree.dtatuali = TODAY.
					
					RUN inclui-registro IN h-b1wpgd0060f(INPUT TABLE cratree, OUTPUT msg-erro).
					
				END.
			 ELSE  /* alteracao */
				DO: 
					/* cria a temp-table e joga o novo valor digitado para o campo */
					CREATE cratree.
					BUFFER-COPY crapree TO cratree.
								   
					ASSIGN cratree.nrsdieve = INT(ab_unmap.aux_nrseqeve)
						     cratree.nrsdirec = INT(ab_unmap.nrsdirec)
						     cratree.qtreceve = (IF INT(ab_unmap.aux_cdtiprec) = 5 OR INT(ab_unmap.aux_cdtiprec) = 2 THEN 0 ELSE INT(ab_unmap.qtreceve)) /* INT(INPUT crapree.qtreceve) */
						     cratree.qtgrppar = INT(ab_unmap.qtgrppar)
						     cratree.cdoperad = ab_unmap.aux_cdoperad
						     cratree.cdprogra = "WPGD0060f"
						     cratree.dtatuali = TODAY.
			  
					RUN altera-registro IN h-b1wpgd0060f(INPUT TABLE cratree, OUTPUT msg-erro).
				END.    
			END. /* DO WITH FRAME {&FRAME-NAME} */
		 
			/* "mata" a instância da BO */
			DELETE PROCEDURE h-b1wpgd0060f NO-ERROR.
     
		END. /* IF VALID-HANDLE(h-b1wpgd0060f) */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CalculoCustosOrcados w-html 
PROCEDURE CalculoCustosOrcados:
  
  DEF VAR aux_contador AS INTEGER   NO-UNDO.
  DEF VAR aux_dscritic AS CHARACTER NO-UNDO.
      			  
  { sistema/ayllos/includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
  
  RUN STORED-PROCEDURE pc_calc_custo_eve_ass
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT INT(ab_unmap.aux_idevento) /* ID do Evento */
                                        ,INPUT INT(ab_unmap.aux_cdcooper) /* Codigo da Cooperativa */
                                        ,INPUT INT(ab_unmap.aux_dtanoage) /* Ano Agenda */
                                        ,INPUT INT(ab_unmap.aux_cdagenci) /* Codigo do PA */
                                        ,INPUT INT(ab_unmap.aux_cdevento) /* Codigo do Evento */
                                        ,INPUT INT(ab_unmap.aux_nrseqeve) /* Codigo do Evento */
                                        ,INPUT v-identificacao            /* ID da sessao */
                                       ,OUTPUT "").                       /* Descriçao da crítica */
  
  CLOSE STORED-PROC pc_calc_custo_eve_ass
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
  
  { sistema/ayllos/includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
  
  ASSIGN aux_dscritic = ""
         aux_dscritic = pc_calc_custo_eve_ass.pr_dscritic 
                          WHEN pc_calc_custo_eve_ass.pr_dscritic <> ?.
       
  IF (TRIM(aux_dscritic) <> "") THEN
    DO:
			ASSIGN aux_dscritic = REPLACE(REPLACE(aux_dscritic,"\"",""),"'","").	
						 msg-erro = aux_dscritic.
					 
			DO aux_contador = 2 TO (NUM-ENTRIES(aux_dscritic, "#")):
				ASSIGN msg-erro = msg-erro + STRING(ENTRY(aux_contador, aux_dscritic,"#")) + "\\r".
			END.
    		
	    RUN RodaJavaScript("alert('" + msg-erro + "');").
	  
      RETURN "NOK".
    END.
  
  RETURN "OK".
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
  /* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0060f.p PERSISTENT SET h-b1wpgd0060f.
   
  /* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0060f) THEN
     DO:
        CREATE cratree.
        BUFFER-COPY crapree TO cratree.
            
        RUN exclui-registro IN h-b1wpgd0060f(INPUT TABLE cratree, OUTPUT msg-erro).

        /* "mata" a instância da BO */
        DELETE PROCEDURE h-b1wpgd0060f NO-ERROR.
     END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
  RUN displayFields.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
  output-content-type ("text/html":U).  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
  {includes/wpgd0009.i}

  ASSIGN v-identificacao = get-cookie("cookie-usuario-em-uso")
       v-permissoes    = "IAEPLU".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :

  v-identificacao = get-cookie("cookie-usuario-em-uso").

  /* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
  FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
      LEAVE.
  END.

  ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
         FlagPermissoes        = GET-VALUE("aux_lspermis")
         msg-erro-aux          = 0
         ab_unmap.aux_idevento = GET-VALUE("aux_idevento")
         ab_unmap.aux_dsendurl = AppURL                        
         ab_unmap.aux_lspermis = FlagPermissoes                
         ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
         ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
         ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
         ab_unmap.nrsdirec     = GET-VALUE("aux_nrsdirec")
         ab_unmap.aux_cdtiprec = GET-VALUE("aux_cdtiprec")
         ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad")
         ab_unmap.qtgrppar     = IF GET-VALUE("qtgrppar") = "" THEN "0" ELSE GET-VALUE("qtgrppar")
         ab_unmap.qtreceve     = GET-VALUE("qtreceve")		 
				 ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
				 ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage")
				 ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
				 ab_unmap.aux_nrseqeve = GET-VALUE("aux_nrseqeve").
          
  RUN outputHeader.

  /* método POST */
  IF REQUEST_METHOD = "POST":U THEN 
       DO:
          RUN inputFields.
        
          CASE opcao:
               WHEN "sa" THEN /* salvar */
                    DO:
                      IF ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
                        DO: 
                          RUN local-assign-record("inclusao").                                        
                             
                            IF msg-erro <> "" THEN
															DO:
																ASSIGN msg-erro-aux = 3 /* erros da validação de dados */
																			 ab_unmap.aux_stdopcao = "i".
															END.		 
														ELSE 
															DO: 
																ASSIGN msg-erro-aux = 10.
														
																RUN CalculoCustosOrcados.
														
																IF RETURN-VALUE <> "OK" THEN
																	ASSIGN msg-erro-aux = 3 /* erros da validação de dados */
																				 ab_unmap.aux_stdopcao = "i"
																				 msg-erro = "Erro no cálculo de Custo Orçado".
																ELSE
																	ASSIGN msg-erro-aux = 10.
															END.							
							
									   
												END.  /* fim inclusao */
                      ELSE IF ab_unmap.aux_stdopcao = "al" THEN    /* alteração */ 
                        DO: 
                          FIND FIRST crapree WHERE crapree.nrsdieve = INT(ab_unmap.aux_nrseqeve)
                                               AND crapree.nrsdirec = INT(ab_unmap.nrsdirec) NO-LOCK NO-ERROR.
                     
                          IF NOT AVAILABLE crapree THEN
                            DO:
                              RUN RodaJavaScript('alert("Registro nao encontrado.");').
                              RUN RodaJavaScript('self.close();').
                            END.
                          ELSE	
                            DO:
															RUN local-assign-record("alteracao").

                              IF msg-erro = "" THEN
                                 ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                              ELSE
                                 ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
															
															FIND FIRST crapree WHERE crapree.nrsdieve = INT(ab_unmap.aux_nrseqeve)
                                                   AND crapree.nrsdirec = INT(ab_unmap.nrsdirec) NO-LOCK NO-ERROR.
															
															RUN CalculoCustosOrcados.
															
															IF RETURN-VALUE <> "OK" THEN
																ASSIGN msg-erro-aux = 3 /* erros da validação de dados */
																			 ab_unmap.aux_stdopcao = "i"
																			 msg-erro = "Erro no cálculo de Custo Orçado".
															ELSE
																ASSIGN msg-erro-aux = 10
																		   ab_unmap.aux_stdopcao = "al".
                            END.
                                                          
                        END. /* fim alteração */
												
                  END. /* fim salvar */
      
          END CASE.
       
        RUN CriaListaRecursos.
        
        IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
           RUN displayFields.
   
        RUN enableFields.
        RUN outputFields.

          CASE msg-erro-aux:
             WHEN 1 THEN
                  DO:
                      ASSIGN v-qtdeerro      = 1
                             v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                      RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                  END.
             WHEN 2 THEN
                  RUN RodaJavaScript("alert('Registro foi excluído. Solicitação não pode ser executada.')").
        
             WHEN 3 THEN
                  DO:
                      ASSIGN v-qtdeerro      = 1
                             v-descricaoerro = msg-erro.

                      RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
											
											IF ab_unmap.aux_stdopcao = 'i' THEN
												RUN RodaJavaScript('$("#aux_nrsdirec").removeAttr("disabled");').
					  
                  END.
             WHEN 4 THEN
                  DO:
                      ASSIGN v-qtdeerro      = 1
                             v-descricaoerro = m-erros.

                      RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                  END.
               WHEN 10 THEN
                    DO:
                      RUN RodaJavaScript('alert("Atualização executada com sucesso.");').
                      RUN RodaJavaScript('window.opener.location.reload();').
                      RUN RodaJavaScript('self.close();').
                    END.       
          END CASE.     
       END. /* Fim do método POST */
  ELSE /* Método GET */ 
       DO:
          RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).
     
          CASE ab_unmap.aux_lspermis:
               WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                  RUN RodaJavaScript('close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
     
               WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                    DO: 
                       DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                      RUN RodaJavaScript('close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                    END.
               WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                    RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
               OTHERWISE
                  DO: 
                    IF INT(ab_unmap.aux_cdevento) <> 0 AND INT(ab_unmap.nrsdirec) <> 0 THEN
                       DO:           
                          FIND FIRST crapree WHERE crapree.nrsdieve = INT(ab_unmap.aux_nrseqeve)
                                               AND crapree.nrsdirec = INT(ab_unmap.nrsdirec) NO-LOCK NO-ERROR.
                     
                          IF NOT AVAILABLE crapree THEN
                            DO:
                              RUN RodaJavaScript('alert("Registro nao encontrado.");').
                              RUN RodaJavaScript('self.close();').
                            END.
                          ELSE
                            DO:
                              ASSIGN ab_unmap.qtreceve = STRING(crapree.qtreceve)
                                     ab_unmap.qtgrppar = STRING(crapree.qtgrppar).
                            END.                             
                       END.  
                       
                     RUN CriaListaRecursos.
                     RUN displayFields.
                     RUN enableFields.
                     RUN outputFields.
                     RUN RodaJavaScript('CarregaPrincipal();').
                                        
                  END. /* fim otherwise */                  
          END CASE. 

       END. /* fim do método GET */

  /* Show error messages. */
  IF AnyMessage() THEN 
       DO:
          ShowDataMessages().
       END.

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :
  {includes/rodajava.i}
END PROCEDURE.