/*...............................................................................
  Alteracoes: 19/07/2017 - Criação da tela PRJ 322 (Jean Michel)
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW

DEFINE TEMP-TABLE ab_unmap
  FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrseqcma AS CHARACTER FORMAT "X(256)":U
  FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U
  FIELD aux_cdagenci AS CHARACTER FORMAT "X(256)":U
  FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U
  FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U
  FIELD aux_cdoperad AS CHARACTER FORMAT "X(256)":U
  FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U.
  
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0060g"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0060g.w"].

DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".

DEFINE VARIABLE i                     AS INTEGER   NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER NO-UNDO.

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0060g.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS 
&Scoped-define ENABLED-TABLES ab_unmap crapcma
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapcma
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_cdcooper ab_unmap.aux_nrseqcma ab_unmap.aux_dtanoage ~
ab_unmap.aux_cdagenci ab_unmap.aux_cdevento ab_unmap.aux_nrseqdig ~
ab_unmap.aux_cdoperad ab_unmap.aux_cdcopope
&Scoped-Define DISPLAYED-FIELDS 
&Scoped-define DISPLAYED-TABLES ab_unmap crapcma
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapcma
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_cdcooper ab_unmap.aux_nrseqcma ab_unmap.aux_dtanoage ~
ab_unmap.aux_cdagenci ab_unmap.aux_cdevento ab_unmap.aux_nrseqdig ~
ab_unmap.aux_cdoperad ab_unmap.aux_cdcopope

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

DEFINE FRAME Web-Frame
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsretorn AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_nrseqcma AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.aux_nrseqdig AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 24.71.

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ab_unmap W "?" ?  
      ADDITIONAL-FIELDS:
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdeixsel AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmfornec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 24.71
         WIDTH              = 71.4.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 

{src/web2/template/hmapmain.i}

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ListaMesa w-html 
PROCEDURE ListaMesa:
  
  /* Mesa de Autoridades Cadastradas Sistema */
  RUN RodaJavaScript("var arrMesa = new Array();").  
  
  FOR EACH crapcma NO-LOCK WHERE crapcma.cdcooper = INT(ab_unmap.aux_cdcooper) 
                             AND crapcma.idsitcma = 1 /* Ativo */
                              BY crapcma.nmcompon:
  		
		RUN RodaJavaScript("arrMesa.push(~{nrseqcma:'" + STRING(crapcma.nrseqcma) 
                                  + "',nmcompon:" + "'" + STRING(crapcma.nmcompon)
                                  + "',dscarcom:" + "'" + STRING(crapcma.dscarcom) + "'~});").
		
  END.
  
  /* Fim Mesa de Autoridades Cadastradas Sistema */

  /* Mesa de Autoridades Cadastradas Evento */
  RUN RodaJavaScript("var arrMesaEve = new Array();").
    
  FOR EACH crapcmp WHERE crapcmp.idevento = INT(ab_unmap.aux_idevento)
                     AND crapcmp.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND crapcmp.dtanoage = INT(ab_unmap.aux_dtanoage)
                     AND crapcmp.cdagenci = INT(ab_unmap.aux_cdagenci)
                     AND crapcmp.cdevento = INT(ab_unmap.aux_cdevento)
                     AND crapcmp.nrseqdig = INT(ab_unmap.aux_nrseqdig) NO-LOCK:
      
		RUN RodaJavaScript("arrMesaEve.push(~{nrseqcma:'" + STRING(crapcmp.nrseqcma) + "'~});").
   
  END.
  
  /* Fim Mesa de Autoridades Cadastradas Evento */
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqcma":U,"ab_unmap.aux_nrseqcma":U,ab_unmap.aux_nrseqcma:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"ab_unmap.aux_nrseqdig":U,ab_unmap.aux_nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record:

  DEF VAR aux_contador AS INT NO-UNDO.

  FOR EACH crapcmp WHERE crapcmp.idevento = INT(ab_unmap.aux_idevento)
                     AND crapcmp.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND crapcmp.dtanoage = INT(ab_unmap.aux_dtanoage)
                     AND crapcmp.cdagenci = INT(ab_unmap.aux_cdagenci)
                     AND crapcmp.cdevento = INT(ab_unmap.aux_cdevento)
                     AND crapcmp.nrseqdig = INT(ab_unmap.aux_nrseqdig) EXCLUSIVE-LOCK:
    DELETE crapcmp.
  END.
  
  DO aux_contador = 1 TO NUM-ENTRIES(aux_nrseqcma,","):
  
    CREATE crapcmp.
    ASSIGN crapcmp.idevento = INT(ab_unmap.aux_idevento)
           crapcmp.cdcooper = INT(ab_unmap.aux_cdcooper) 
           crapcmp.dtanoage = INT(ab_unmap.aux_dtanoage)
           crapcmp.cdagenci = INT(ab_unmap.aux_cdagenci)
           crapcmp.cdevento = INT(ab_unmap.aux_cdevento)
           crapcmp.nrseqdig = INT(ab_unmap.aux_nrseqdig)
           crapcmp.nrseqcma = INT(ENTRY(aux_contador,aux_nrseqcma))
           crapcmp.cdcopope = INT(ab_unmap.aux_cdcopope)
           crapcmp.cdoperad = ab_unmap.aux_cdoperad
           crapcmp.cdprogra = "wpgd0060g"
           crapcmp.dtatuali = TODAY.
           
  END.

  ASSIGN msg-erro = ?.
  
  RETURN "OK".
  
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
		 FlagPermissoes        = GET-VALUE("aux_lspermis")
         ab_unmap.aux_lspermis = FlagPermissoes               
         ab_unmap.aux_cddopcao = GET-VALUE("aux_cddopcao") 
         ab_unmap.aux_idevento = GET-VALUE("aux_idevento")         
         ab_unmap.aux_dsretorn = GET-VALUE("aux_dsretorn") 
         ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper") 
         ab_unmap.aux_nrseqcma = GET-VALUE("aux_nrseqcma") 
         ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage") 
         ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci") 
         ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento") 
         ab_unmap.aux_nrseqdig = GET-VALUE("aux_nrseqdig") 
         ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad") 
         ab_unmap.aux_cdcopope = GET-VALUE("aux_cdcopope").
                                                           
  RUN outputHeader.                                        

  IF REQUEST_METHOD = "POST":U THEN 
     DO:
        RUN inputFields.

        CASE ab_unmap.aux_cddopcao:
          WHEN "sa" THEN /* salvar */
            DO:
              RUN local-assign-record. 
              
              IF msg-erro <> "" AND msg-erro <> ? THEN
                DO:
                  ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                END.
              ELSE 
                DO:
                  ASSIGN  msg-erro-aux = 10.
                END.
            END.    
        END CASE.
        
        RUN ListaMesa.
        
        IF msg-erro-aux = 10 OR (ab_unmap.aux_cddopcao <> "sa" AND ab_unmap.aux_cddopcao <> "ex" AND ab_unmap.aux_cddopcao <> "in") THEN
           RUN displayFields.
   
        RUN enableFields.
        RUN outputFields.

        CASE msg-erro-aux:
          WHEN 1 THEN
            DO:
              ASSIGN v-qtdeerro      = 1
                     v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

              RUN RodaJavaScript('alert("' + v-descricaoerro + '");').
            END.

          WHEN 2 THEN
            RUN RodaJavaScript("alert('Registro foi excluído. Solicitação não pode ser executada.');").
        
          WHEN 3 THEN
            DO:
              ASSIGN v-qtdeerro      = 1
                     v-descricaoerro = msg-erro.

              RUN RodaJavaScript('alert("' + v-descricaoerro + '");').
            END.

          WHEN 4 THEN
            DO:
              ASSIGN v-qtdeerro      = 1
                     v-descricaoerro = m-erros.

              RUN RodaJavaScript('alert("' + v-descricaoerro + '");').
            END.

          WHEN 10 THEN
            DO:
              RUN RodaJavaScript('alert("Atualização efetuada com sucesso!");').
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
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");').

             WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                  DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                  RUN RodaJavaScript('top.close();window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");').
                END.
    
             WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
            
            OTHERWISE
              DO:
                RUN ListaMesa.

                RUN displayFields.
                RUN enableFields.
                RUN outputFields.

              END. /* fim otherwise */                  
        END CASE. 
  END. /* fim do método GET */

  IF AnyMessage() THEN 
    DO:
       ShowDataMessages().
    END.
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :
  {includes/rodajava.i}
END PROCEDURE.