/*...............................................................................
  Alterações: 18/07/2017 - Criação da tela PRJ 322 (Jean Michel)
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW

DEFINE TEMP-TABLE ab_unmap
  FIELD aux_cddopcao AS CHARACTER 
  FIELD aux_lspermis AS CHARACTER 
  FIELD aux_idevento AS CHARACTER 
  FIELD aux_nrseqfea AS CHARACTER
  FIELD aux_cdevento AS CHARACTER
  FIELD aux_dsendurl AS CHARACTER
  FIELD aux_dsretorn AS CHARACTER  
  FIELD aux_cdcooper AS CHARACTER
  FIELD aux_dtanoage AS CHARACTER
  FIELD aux_cdagenci AS CHARACTER
  FIELD aux_nrseqdig AS CHARACTER.  

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0060h"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0060h.w"].
DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
  
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER.

DEFINE VARIABLE i                     AS INTEGER   NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER NO-UNDO.
DEFINE VARIABLE vetorFacilitador      AS CHAR      NO-UNDO.    

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0060h.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS 
&Scoped-define ENABLED-TABLES crapadp ab_unmap
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapadp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cddopcao ab_unmap.aux_lspermis ab_unmap.aux_idevento ~
ab_unmap.aux_nrseqfea ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_cdcooper ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ab_unmap.aux_nrseqdig
&Scoped-Define DISPLAYED-FIELDS 
&Scoped-define DISPLAYED-TABLES crapadp ab_unmap
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapadp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cddopcao ab_unmap.aux_lspermis ab_unmap.aux_idevento ~
ab_unmap.aux_nrseqfea ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_cdcooper ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ab_unmap.aux_nrseqdig

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

DEFINE FRAME Web-Frame
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqfea AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
    ab_unmap.aux_cdcooper  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dtanoage  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1      
    ab_unmap.aux_cdagenci  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_nrseqdig  AT ROW 1 COL 1 HELP
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ListaFacilitadores w-html 

PROCEDURE ListaFacilitadores:

  RUN RodaJavaScript("var arrFacilitador = new Array();").
     
  FOR EACH crapfea NO-LOCK WHERE crapfea.cdcooper = INT(ab_unmap.aux_cdcooper)
                             AND crapfea.idsitfea = 1 /* ATIVOS */
                              BY crapfea.nmfacili:

		RUN RodaJavaScript("arrFacilitador.push(~{nrseqfea:'" + TRIM(STRING(crapfea.nrseqfea))
                                         + "',nmfacili:'" + TRIM(STRING(crapfea.nmfacili)) + "'~});").
  END. /* for each */
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqfea":U,"ab_unmap.aux_nrseqfea":U,ab_unmap.aux_nrseqfea:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"ab_unmap.aux_nrseqdig":U,ab_unmap.aux_nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html
PROCEDURE local-assign-record:

  FIND crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)
                 AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                 AND crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)
                 AND crapadp.cdagenci = INT(ab_unmap.aux_cdagenci)
                 AND crapadp.cdevento = INT(ab_unmap.aux_cdevento)
                 AND crapadp.nrseqdig = INT(ab_unmap.aux_nrseqdig) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  
  IF AVAILABLE crapadp THEN
    DO:
		  ASSIGN crapadp.nrseqfea = IF ab_unmap.aux_nrseqfea = "NA" THEN ? ELSE INT(ab_unmap.aux_nrseqfea).
    END.
  Else
    DO:
      ASSIGN msg-erro-aux = 2.
    END.
    
END PROCEDURE.

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

  ASSIGN msg-erro-aux          = 0
         ab_unmap.aux_dsendurl = AppURL                        
         ab_unmap.aux_lspermis = FlagPermissoes
         opcao                 = GET-FIELD("aux_cddopcao")
         FlagPermissoes        = GET-VALUE("aux_lspermis")
         ab_unmap.aux_idevento = get-value("aux_idevento")
         ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")       
         ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
         ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage")
         ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
         ab_unmap.aux_nrseqdig = GET-VALUE("aux_nrseqdig")
         ab_unmap.aux_nrseqfea = GET-VALUE("aux_nrseqfea").
    
  RUN outputHeader.

  /* método POST */
  IF REQUEST_METHOD = "POST":U THEN 
    DO:
      RUN inputFields.
        
      CASE opcao:
        WHEN "sa" THEN /* salvar */
          DO:            
            RUN local-assign-record.
               
            IF msg-erro <> "" THEN
              ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
            ELSE 
              DO: 
                ASSIGN msg-erro-aux = 10.
              END.
          END. /* fim salvar */  
      END CASE.
       
      RUN ListaFacilitadores.
        
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
          RUN RodaJavaScript("alert('Registro não encontrado. Solicitação não pode ser executada.')").
    
        WHEN 3 THEN
          DO:
            ASSIGN v-qtdeerro      = 1
                   v-descricaoerro = msg-erro.

            RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
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
            RUN RodaJavaScript('window.opener.Recarrega();').
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
            RUN ListaFacilitadores.
            RUN displayFields.
            RUN enableFields.
            RUN outputFields.
            RUN RodaJavaScript('document.form.aux_nrseqfea.value = 0;').
          END. /* fim otherwise */                  
      END CASE. 
    END. /* fim do método GET */

  IF AnyMessage() THEN 
    DO:
      ShowDataMessages().
    END.

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript:
  {includes/rodajava.i}
END PROCEDURE.