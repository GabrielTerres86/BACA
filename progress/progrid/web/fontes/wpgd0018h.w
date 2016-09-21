/*...............................................................................
JMD
Alterações:
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
  FIELD aux_idevento AS INTEGER
  FIELD aux_cdcooper AS INTEGER
  FIELD aux_dtanoage AS INTEGER
  FIELD aux_qtocoeve AS INTEGER
  FIELD aux_qtpareve AS DECIMAL
  FIELD aux_vlporins AS DECIMAL
  FIELD aux_vldeseve AS DECIMAL
  FIELD aux_vlrtotal AS DECIMAL
  FIELD aux_cdcopope AS CHARACTER
  FIELD aux_cdevento AS CHARACTER
  FIELD aux_cdoperad AS CHARACTER
  FIELD aux_cddopcao AS CHARACTER
  FIELD aux_lspermis AS CHARACTER
  FIELD aux_strsalva AS CHARACTER.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------
  File: 
  Description: 
  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with AppBuilder.                  */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0018"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0018h.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE vetorpa               AS CHARACTER FORMAT "X(16)".
DEFINE VARIABLE vetorev               AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0018          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratced NO-UNDO     LIKE crapced.
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0018h.htm

/* Name of first Frame and/or Browse and/or first Query */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions */
&Scoped-Define ENABLED-FIELDS
&Scoped-define ENABLED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapced
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_idevento ab_unmap.aux_cdcooper ~
ab_unmap.aux_dtanoage ab_unmap.aux_cdevento ab_unmap.aux_qtocoeve ~
ab_unmap.aux_qtpareve ab_unmap.aux_vlporins ab_unmap.aux_vldeseve ~
ab_unmap.aux_vlrtotal ab_unmap.aux_cdoperad ab_unmap.aux_cddopcao ~
ab_unmap.aux_lspermis ab_unmap.aux_strsalva ab_unmap.aux_cdcopope
&Scoped-Define DISPLAYED-FIELDS
&Scoped-define DISPLAYED-TABLES ab_unmap crapced
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapced
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_idevento ab_unmap.aux_cdcooper ~
ab_unmap.aux_dtanoage ab_unmap.aux_cdevento ab_unmap.aux_qtocoeve ~
ab_unmap.aux_qtpareve ab_unmap.aux_vlporins ab_unmap.aux_vldeseve ~
ab_unmap.aux_vlrtotal ab_unmap.aux_cdoperad ab_unmap.aux_cddopcao ~
ab_unmap.aux_lspermis ab_unmap.aux_strsalva ab_unmap.aux_cdcopope

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtocoeve AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtpareve AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_vlporins AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1  
     ab_unmap.aux_vldeseve AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.aux_vlrtotal AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1  
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1  
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1  
     ab_unmap.aux_strsalva AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1    
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 50.2 BY 25.67.         
         
/* ******aux_cdoperad***************** Procedure Settings ************************ */

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
          FIELD aux_idevento AS INTEGER
          FIELD aux_cdcooper AS INTEGER
          FIELD aux_dtanoage AS INTEGER
          FIELD aux_qtocoeve AS INTEGER
          FIELD aux_qtpareve AS DECIMAL
          FIELD aux_vlporins AS DECIMAL
          FIELD aux_vldeseve AS DECIMAL
          FIELD aux_vlrtotal AS DECIMAL
          FIELD aux_cdevento AS CHARACTER
          FIELD aux_cdoperad AS CHARACTER
          FIELD aux_cddopcao AS CHARACTER
          FIELD aux_lspermis AS CHARACTER
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 25.67
         WIDTH              = 50.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPA w-html 
PROCEDURE CriaListaPA:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR aux_qtregist AS INT  INIT 0 NO-UNDO.
DEF VAR aux_registro AS INT  INIT 0 NO-UNDO.
    
  ASSIGN vetorpa = "".
  
  IF ab_unmap.aux_cddopcao <> "co" THEN
    RUN RodaJavaScript("var meadcons = new Array();").
    
  RUN RodaJavaScript("var mpa = new Array();").
  
  FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                         crapage.flgdopgd = TRUE NO-LOCK BY crapage.nmresage:
	    
    IF NOT vetorpa = "" THEN
      ASSIGN  vetorpa = vetorpa + ",".
        
    ASSIGN vetorpa = vetorpa + "~{" + "cdagenci:'" + STRING(crapage.cdagenci) + "'," +
                                      "nmresage:'" + STRING(crapage.nmresage) + "'" + "~}".
              
    ASSIGN aux_registro  = aux_registro + 1.
    
    IF aux_registro > 50 THEN
      DO:
        RUN RodaJavaScript("mpa.push(" + STRING(vetorpa) + ");").
        ASSIGN vetorpa = ""
               aux_registro = 0.
      END.
  END.
        
  RUN RodaJavaScript("mpa.push(" + STRING(vetorpa) + ");").

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEvento:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEF VAR aux_qtregist AS INT  INIT 0 NO-UNDO.
  DEF VAR aux_registro AS INT  INIT 0 NO-UNDO.
    
  ASSIGN vetorev = "-- SELECIONE --,0".
      
  FOR EACH crapedp NO-LOCK  WHERE crapedp.tpevento = 10 /* EAD */
                              AND crapedp.flgativo = TRUE  /* Evento Ativo */
                              AND crapedp.idevento = 1  /* PROGRID */
                              AND crapedp.cdcooper = 0  /* Evento Raiz */
                              AND crapedp.dtanoage = 0  /* Evento Raiz */
                              AND (crapedp.cdevento = INT(ab_unmap.aux_cdevento) OR 0 = INT(ab_unmap.aux_cdevento)) BY crapedp.nmevento:
                              
    FIND FIRST crapced WHERE crapced.idevento = crapedp.idevento
                         AND crapced.cdcooper = INT(ab_unmap.aux_cdcooper) /* Cooperativa da Tela */
                         AND crapced.dtanoage = INT(ab_unmap.aux_dtanoage) /* ano da tela */                        
                         AND crapced.cdevento = crapedp.cdevento NO-LOCK NO-ERROR NO-WAIT.
                         
	  IF NOT AVAILABLE crapced OR (AVAILABLE crapced AND INT(ab_unmap.aux_cdevento) <> 0) THEN   
      ASSIGN vetorev = vetorev + "," + REPLACE(TRIM(crapedp.nmevento), ",", ".") + "," + STRING(crapedp.cdevento).
    
  END.
    
  ASSIGN ab_unmap.aux_cdevento:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = vetorev.
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventosPa w-html 
PROCEDURE CriaListaEventoPa:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEF VAR aux_qtregist AS INT  INIT 0 NO-UNDO.
  DEF VAR aux_registro AS INT  INIT 0 NO-UNDO.
  DEF VAR vetoread     AS CHAR        NO-UNDO.
  DEF VAR aux_nmevento AS CHAR        NO-UNDO.
  
  RUN RodaJavaScript("var meadcons = new Array();").
  
  FOR EACH crapced WHERE crapced.idevento = INT(ab_unmap.aux_idevento)
                     AND crapced.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND crapced.dtanoage = INT(ab_unmap.aux_dtanoage)
                     AND crapced.cdevento = INT(ab_unmap.aux_cdevento) NO-LOCK:

    FOR FIRST crapedp FIELDS(nmevento) WHERE crapedp.idevento = INT(ab_unmap.aux_idevento)
                                         AND crapedp.cdcooper = 0
                                         AND crapedp.dtanoage = 0
                                         AND crapedp.cdevento = INT(crapced.cdevento)
                                         AND crapedp.tpevento = 10 NO-LOCK. END.
                                         
    ASSIGN aux_nmevento = ""
           aux_registro = aux_registro + 1.
    
    IF AVAILABLE crapedp THEN
      DO:
        ASSIGN aux_nmevento = TRIM(STRING(crapedp.nmevento)).
      END.
    ELSE
      DO:
        ASSIGN aux_nmevento = "SEM NOME".
      END.
    
		IF NOT vetoread = "" THEN
      DO:
        ASSIGN vetoread = vetoread + ",".
      END.
		
    FIND FIRST crapage WHERE crapage.cdcooper = crapced.cdcooper
                         AND crapage.cdagenci = crapced.cdagenci NO-LOCK NO-ERROR NO-WAIT.
    
    ASSIGN aux_qtocoeve = aux_qtocoeve + crapced.qtocoeve
           aux_qtpareve = aux_qtpareve + crapced.qtpareve
           aux_vlporins = aux_vlporins + crapced.vlporins
           aux_vldeseve = aux_vldeseve + crapced.vldeseve
           aux_vlrtotal = aux_vlrtotal + (crapced.qtocoeve * (crapced.qtpareve * crapced.vlporins) + crapced.vldeseve).
    
		vetoread = vetoread + "~{" + "  cdagenci:'" + TRIM(STRING(crapced.cdagenci))
                               + "',nmagenci:'" + TRIM(STRING(crapage.nmresage))
                               + "',nmevento:'" + TRIM(STRING(aux_nmevento))
															 + "',qtocoeve:'" + TRIM(STRING(crapced.qtocoeve))
															 + "',qtpareve:'" + TRIM(STRING(crapced.qtpareve))
															 + "',vlporins:'" + TRIM(STRING(crapced.vlporins,"zzz,zzz,zz9.99"))
															 + "',vldeseve:'" + TRIM(STRING(crapced.vldeseve,"zzz,zzz,zz9.99"))
                               + "',vlrtotal:'" + TRIM(STRING((crapced.qtocoeve * (crapced.qtpareve * crapced.vlporins) + crapced.vldeseve),"zzz,zzz,zz9.99")) + "'~}".
                               
    IF aux_registro > 50 THEN
      DO:
        RUN RodaJavaScript("meadcons.push(" + STRING(vetoread) + ");").
        ASSIGN vetoread = ""
               aux_registro = 0.
      END.
	END.
  
  RUN RodaJavaScript("meadcons.push(" + STRING(vetoread) + ");").
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE salvaEventosEAD w-html 
PROCEDURE salvaEventosEAD:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  DEF VAR aux_contador AS INTEGER NO-UNDO.
  DEF VAR aux_strdados AS CHARACTER NO-UNDO.
  
  IF INT(ab_unmap.aux_cdevento) = 0 THEN
    DO:
      ASSIGN msg-erro-aux = 12.
      LEAVE.
    END.
  
  DO aux_contador = 1 TO NUM-ENTRIES(TRIM(ab_unmap.aux_strsalva),"|"):
    
    ASSIGN aux_strdados = ENTRY(aux_contador,ab_unmap.aux_strsalva,"|").
        
    FIND crapced WHERE crapced.idevento = INT(ab_unmap.aux_idevento)
                   AND crapced.cdcooper = INT(ab_unmap.aux_cdcooper)
                   AND crapced.dtanoage = INT(ab_unmap.aux_dtanoage)
                   AND crapced.cdevento = INT(ab_unmap.aux_cdevento)
                   AND crapced.cdagenci = INT(ENTRY(1,aux_strdados,"#"))
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
    IF AVAILABLE crapced THEN
      DO:
        ASSIGN crapced.qtocoeve = DEC(ENTRY(2,aux_strdados,"#"))
               crapced.qtpareve = DEC(ENTRY(3,aux_strdados,"#")) 
               crapced.vlporins = DEC(ENTRY(4,aux_strdados,"#"))
               crapced.vldeseve = DEC(ENTRY(5,aux_strdados,"#"))
               crapced.cdcopope = INT(ab_unmap.aux_cdcopope)
               crapced.cdoperad = ab_unmap.aux_cdoperad
               crapced.cdprogra = "WPGD0018h"
               crapced.dtatuali = TODAY.
               
        RELEASE crapced.        
      END.
    ELSE
      DO:
        CREATE crapced.
        ASSIGN crapced.idevento = INT(ab_unmap.aux_idevento)
               crapced.dtanoage = INT(ab_unmap.aux_dtanoage)
               crapced.cdcooper = INT(ab_unmap.aux_cdcooper)
               crapced.cdevento = INT(ab_unmap.aux_cdevento)
               crapced.cdagenci = INT(ENTRY(1,aux_strdados,"#"))
               crapced.qtocoeve = DEC(ENTRY(2,aux_strdados,"#"))
               crapced.qtpareve = DEC(ENTRY(3,aux_strdados,"#"))
               crapced.vlporins = DEC(ENTRY(4,aux_strdados,"#"))
               crapced.vldeseve = DEC(ENTRY(5,aux_strdados,"#"))
               crapced.cdcopope = INT(ab_unmap.aux_cdcopope)
               crapced.cdoperad = ab_unmap.aux_cdoperad
               crapced.cdprogra = "WPGD0018h"
               crapced.dtatuali = TODAY.
               
        VALIDATE crapced.       
      END.
      
  END. /*DO TO */
  
  RETURN "OK".
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html

/*************************  Main Code Block  **************************/

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtocoeve":U,"ab_unmap.aux_qtocoeve":U,ab_unmap.aux_qtocoeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtpareve":U,"ab_unmap.aux_qtpareve":U,ab_unmap.aux_qtpareve:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_vlporins":U,"ab_unmap.aux_vlporins":U,ab_unmap.aux_vlporins:HANDLE IN FRAME {&FRAME-NAME}).      
  RUN htmAssociate
    ("aux_vldeseve":U,"ab_unmap.aux_vldeseve":U,ab_unmap.aux_vldeseve:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_vlrtotal":U,"ab_unmap.aux_vlrtotal":U,ab_unmap.aux_vlrtotal:HANDLE IN FRAME {&FRAME-NAME}).      
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_strsalva":U,"ab_unmap.aux_strsalva":U,ab_unmap.aux_strsalva:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}). 
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields:
  RUN displayFields.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  output-content-type ("text/html":U).
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
  {includes/wpgd0009.i}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/webreq.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Processo de requisição web p/ cadastros simples na web - Versão WebSpeed 3.0
  Notas: Este é o procedimento principal onde terá as requisições GET e POST.
         GET - É ativa quando o formulário é chamado pela 1a vez
         POST - Após o get somente ocorrerá POST no formulário      
         Caso seja necessário custimizá-lo para algum programa específico 
         Favor cópiar este procedimento para dentro do procedure process-web-requeste 
         faça lá alterações necessárias.

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN msg-erro-aux          = 0
       ab_unmap.aux_idevento = INT(GET-VALUE("aux_idevento"))
       ab_unmap.aux_cdcooper = INT(GET-VALUE("aux_cdcooper"))
       ab_unmap.aux_dtanoage = INT(GET-VALUE("aux_dtanoage"))       
       ab_unmap.aux_qtocoeve = INT(GET-VALUE("aux_qtocoeve"))
       ab_unmap.aux_qtpareve = DEC(GET-VALUE("aux_qtpareve"))
       ab_unmap.aux_vlporins = DEC(GET-VALUE("aux_vlporins"))
       ab_unmap.aux_vldeseve = DEC(GET-VALUE("aux_vldeseve"))
       ab_unmap.aux_vlrtotal = DEC(GET-VALUE("aux_vlrtotal"))
       ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
       ab_unmap.aux_cddopcao = GET-VALUE("aux_cddopcao")
       ab_unmap.aux_strsalva = GET-VALUE("aux_strsalva")
       ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad")
       ab_unmap.aux_cdcopope = GET-VALUE("aux_cdcopope").
      
RUN outputHeader.
  
/* método POST */
IF REQUEST_METHOD = "POST":U THEN
   DO:
      
      TRANSACAO:
    
      DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
        RUN inputFields.

        CASE ab_unmap.aux_cddopcao:
         WHEN "sa" THEN /* salvar */
            DO:
              ASSIGN msg-erro-aux = 10.
              
              RUN salvaEventosEAD.
              
              IF RETURN-VALUE <> "OK" THEN
                ASSIGN msg-erro-aux = 11.
            END.    
        END CASE.
        
        RUN CriaListaEvento.
        RUN CriaListaEventoPa.         
        RUN CriaListaPA.
                
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
                  END.
             WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.
             WHEN 10 THEN
              DO:
                 RUN RodaJavaScript('window.opener.Recarrega();').
                 RUN RodaJavaScript('self.close();').
                 RUN RodaJavaScript('alert("Atualização executada com sucesso.")'). 
              END.   
             WHEN 11 THEN
              DO:
                 RUN RodaJavaScript('alert("Erro ao atualizar registros.")'). 
              END.
             WHEN 12 THEN
              DO:
                 RUN RodaJavaScript('alert("Código do evento não pode ser vazio.")').
              END.
           
        END CASE.
     END. /* Fim do método POST */
   END.
ELSE /* Método GET */ 
   DO:
    
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).
      
      CASE ab_unmap.aux_lspermis:
           WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

           WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                    DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                    RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                END.
  
           WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').          
           OTHERWISE
                DO:
                  CASE TRIM(ab_unmap.aux_cddopcao):
                    WHEN "sa" THEN /* salvar */
                      DO:
                        RUN salvaEventosEAD.
                      END.    
                    WHEN "co" THEN /* Consulta */
                      DO:
                        RUN CriaListaEventoPa.
                      END.
                  END CASE.
                 
                  RUN CriaListaPA. 
                  RUN CriaListaEvento.
                  
                  RUN displayFields.
                  RUN enableFields.
                  RUN outputFields.
                                           
                END. /* fim otherwise */                  
      END CASE. 
      
END. /* fim do método GET */

/* Show error messages. */
IF AnyMessage() THEN 
DO:
   /* ShowDataMessage may return a Progress column name. This means you
    * can use the function as a parameter to HTMLSetFocus instead of 
    * calling it directly.  The first parameter is the form name.   
    *
    * HTMLSetFocus("document.DetailForm",ShowDataMessages()). */
   ShowDataMessages().
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :
{includes/rodajava.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME