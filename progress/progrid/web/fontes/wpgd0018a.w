/*...............................................................................

Alterações: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
            
            19/11/2009 - Na operacao de inclusao, verificado se registro a ser
                         incluido ja existe na tabela crapcdp (Elton).
						 
            05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevesel AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U .


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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0018a"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0018a.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0018          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratcdp NO-UNDO     LIKE crapcdp.

DEFINE VARIABLE vetorevento AS CHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0018a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapcdp.dtanoage 
&Scoped-define ENABLED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapcdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_dtanoage ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdevesel ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao 
&Scoped-Define DISPLAYED-FIELDS crapcdp.dtanoage 
&Scoped-define DISPLAYED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapcdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_dtanoage ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_cdevesel ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevesel AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapcdp.dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 20.14.

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
          FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevesel AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
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
         HEIGHT             = 20.14
         WIDTH              = 71.4.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevesel IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapcdp.dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 

/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   /* Progrid */
   IF INT(ab_unmap.aux_idevento) = 1 THEN
   DO:
       FOR EACH crapsdp WHERE string(crapsdp.dtanoage) = ?      AND 
                              crapsdp.flgsugca         = FALSE  AND /* Somente sugestões que não foram canceladas */
                              crapsdp.cdcooper         = INT(ab_unmap.aux_cdcooper) NO-LOCK,
          FIRST crapedp WHERE crapedp.cdevento = crapsdp.cdevento NO-LOCK 
                              BREAK BY crapedp.nmevento
                                    BY crapsdp.cdevento:
    
          FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                AND
                                   gnapetp.cdeixtem = crapedp.cdeixtem NO-LOCK NO-ERROR.
    
          IF NOT AVAIL gnapetp THEN NEXT.

          IF FIRST-OF(crapsdp.cdevento) THEN
          DO:
              IF  vetorevento = "" THEN
                  vetorevento =
                                "~{" + "nmevento:"    + "'" + REPLACE(TRIM(string(crapedp.nmevento)),"'","`")
                                     + "',dseixtem:"    + "'" + REPLACE(TRIM(string(gnapetp.dseixtem)),"'","`")
                                     + "',cdevento:"  + "'"  + string(crapedp.cdevento) + "'~}".
              ELSE
                 vetorevento = vetorevento + "," + 
                                "~{" + "nmevento:"    + "'" + REPLACE(TRIM(string(crapedp.nmevento)),"'","`")
                                     + "',dseixtem:"    + "'" + REPLACE(TRIM(string(gnapetp.dseixtem)),"'","`")
                                     + "',cdevento:"  + "'"  + string(crapedp.cdevento) + "'~}".
          END.
       END. /* for each */
   END. /* progrid */
   /* Assembléia */
   IF INT(ab_unmap.aux_idevento) = 2 THEN
   DO:
       FOR EACH crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento) AND 
                              crapedp.cdcooper = 0                          NO-LOCK 
          BREAK BY crapedp.nmevento:

           FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                AND
                                    gnapetp.cdeixtem = crapedp.cdeixtem NO-LOCK NO-ERROR.
    
           IF NOT AVAIL gnapetp THEN NEXT.
              
           IF  vetorevento = "" THEN
               vetorevento = "~{" + "nmevento:"    + "'" + REPLACE(TRIM(string(crapedp.nmevento)),"'","`")
                                + "',dseixtem:"    + "'" + REPLACE(TRIM(string(gnapetp.dseixtem)),"'","`")
                                + "',cdevento:"  + "'"  + string(crapedp.cdevento) + "'~}".
           ELSE
               vetorevento = vetorevento + "," + 
                      "~{" + "nmevento:"    + "'" + REPLACE(TRIM(string(crapedp.nmevento)),"'","`")
                         + "',dseixtem:"    + "'" + REPLACE(TRIM(string(gnapetp.dseixtem)),"'","`")
                         + "',cdevento:"  + "'"  + string(crapedp.cdevento) + "'~}".
       END. /* for each */
   END. /* Assembléias */

   RUN RodaJavaScript("var mevento=new Array();mevento=["  + vetorevento + "]").  


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
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
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevesel":U,"ab_unmap.aux_cdevesel":U,ab_unmap.aux_cdevesel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanoage":U,"crapcdp.dtanoage":U,crapcdp.dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    DEF VAR aux_qtevesel AS INT  NO-UNDO.
    DEF VAR aux_tpcuseve AS INT  NO-UNDO.
    DEF VAR aux_msgderro AS CHAR NO-UNDO.    
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.
                    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0018) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN
                DO: 
                    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                             craptab.nmsistem = "CRED"          AND
                                             craptab.tptabela = "CONFIG"        AND
                                             craptab.cdempres = 0               AND
                                             craptab.cdacesso = "PGDCUSTEVE"    AND
                                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
                                         
                    /* Para todos os eventos selecionados */
                    DO aux_qtevesel = 1 TO NUM-ENTRIES(ab_unmap.aux_cdevesel):
                        /* Se já tem criado, não precisa criar de novo */ 
                        FIND FIRST crapcdp WHERE 
                                   crapcdp.idevento = INT(ab_unmap.aux_idevento) AND
                                   crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                                   crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage) AND
                                   crapcdp.cdevento = INT(ENTRY(aux_qtevesel, ab_unmap.aux_cdevesel)) 
                                   NO-LOCK NO-ERROR.
                        
                        IF AVAIL crapcdp THEN NEXT. 
                        
                        /* Para todos os tipos de custo dos eventos */
                        DO aux_tpcuseve = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
     
                            FIND FIRST cratcdp NO-ERROR.
                            IF AVAIL cratcdp THEN
                                DELETE cratcdp.
                            
                            CREATE cratcdp.
                            ASSIGN
                                cratcdp.cdagenci = 0
                                cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                cratcdp.cdcuseve = INT(ENTRY(aux_tpcuseve * 2, craptab.dstextab))
                                cratcdp.cdevento = INT(ENTRY(aux_qtevesel, ab_unmap.aux_cdevesel))
                                cratcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                                cratcdp.idevento = INT(ab_unmap.aux_idevento)
                                cratcdp.tpcuseve = 1 /* Sempre cria registro pra custos diretos */ 
                                cratcdp.vlcuseve = 0.
                            
                            FIND FIRST crapcdp WHERE 
                                       crapcdp.cdagenci = cratcdp.cdagenci  AND
                                       crapcdp.idevento = cratcdp.idevento  AND
                                       crapcdp.cdcooper = cratcdp.cdcooper  AND
                                       crapcdp.dtanoage = cratcdp.dtanoage  AND
                                       crapcdp.cdevento = cratcdp.cdevento  AND
                                       crapcdp.cdcuseve = cratcdp.cdcuseve  AND    
                                       crapcdp.tpcuseve = cratcdp.tpcuseve 
                                       NO-LOCK NO-ERROR.
                        
                            IF NOT AVAIL crapcdp THEN  
                               RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).
                            
                            msg-erro = msg-erro + aux_msgderro.
                           
                        END. /* DO aux_tpcuseve */
                        
                        /* Cria o registro do custo dos termos de compromisso */
                        EMPTY TEMP-TABLE cratcdp.

                        CREATE cratcdp.
                        ASSIGN cratcdp.cdagenci = 0
                               cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                               cratcdp.cdcuseve = 1
                               cratcdp.cdevento = INT(ENTRY(aux_qtevesel, ab_unmap.aux_cdevesel))
                               cratcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                               cratcdp.idevento = INT(ab_unmap.aux_idevento)
                               cratcdp.tpcuseve = 4
                               cratcdp.vlcuseve = 0
                               cratcdp.prdescon = 0.

                        /* Verifica se já existe registro de custo criado para este evento */
                        FIND FIRST crapcdp WHERE crapcdp.idevento = cratcdp.idevento AND
                                                 crapcdp.cdcooper = cratcdp.cdcooper AND
                                                 crapcdp.cdagenci = cratcdp.cdagenci AND
                                                 crapcdp.dtanoage = cratcdp.dtanoage AND
                                                 crapcdp.tpcuseve = cratcdp.tpcuseve AND
                                                 crapcdp.cdevento = cratcdp.cdevento AND
                                                 crapcdp.cdcuseve = cratcdp.cdcuseve NO-LOCK NO-ERROR.
                        
                        /* Se não tem, cria */
                        IF NOT AVAIL crapcdp THEN
                           RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).

                        msg-erro = msg-erro + aux_msgderro.
                    
                    END. /* DO aux_qtevesel */
                END. /* IF opcao = "inclusao" */
             ELSE  /* alteracao */
                DO:
                    /* cria a temp-table e joga o novo valor digitado para o campo */
                    CREATE cratcdp.
                    BUFFER-COPY crapcdp TO cratcdp.
                     
                    RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro).
                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0018) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0018) THEN
       DO:
          CREATE cratcdp.
          BUFFER-COPY crapcdp TO cratcdp.
              
          RUN exclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro).
    
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
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
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
{includes/wpgd0009.i}

ASSIGN 
    v-identificacao = get-cookie("cookie-usuario-em-uso")
    v-permissoes    = "IAEPLU".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoAnterior w-html 
PROCEDURE PosicionaNoAnterior :
/* O pre-processador {&SECOND-ENABLED-TABLE} tem como valor, o nome da tabela usada */

FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
   DO:
       FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este já é o primeiro registro.')"). 
               
               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".

           END.
   END.
ELSE 
   RUN PosicionaNoPrimeiro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoPrimeiro w-html 
PROCEDURE PosicionaNoPrimeiro :
FIND FIRST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid  = "?"
           ab_unmap.aux_stdopcao = "".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".  /* aqui p */

/* Não traz inicialmente nenhum registro */ 
RELEASE {&SECOND-ENABLED-TABLE}.

ASSIGN ab_unmap.aux_nrdrowid  = "?"
       ab_unmap.aux_stdopcao = "".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :
FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    DO:
       FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este já é o último registro.')").

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".
           END.
    END.
ELSE
    RUN PosicionaNoUltimo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoUltimo w-html 
PROCEDURE PosicionaNoUltimo :
FIND LAST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid = "?".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".   /* aqui u */

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
  
ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_cdevesel    = GET-VALUE("aux_cdevesel")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper").

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
                            RUN local-assign-record ("inclusao"). 
                            IF msg-erro <> "" THEN
                               ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                            ELSE 
                            DO:
                               ASSIGN 
                                   msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                              /* FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                  IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */  
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     END.
                                  ELSE
                                     DO: 
                                         ASSIGN msg-erro-aux = 2. /* registro não existe */
                                         RUN PosicionaNoSeguinte.
                                     END.*/

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* alteração */ 
                        DO: 
                            FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                  DO:
                                      ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */  
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                  END.
                               ELSE
                                  DO: 
                                      ASSIGN msg-erro-aux = 2. /* registro não existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                               END.     
                        END. /* fim alteração */
                END. /* fim salvar */

           WHEN "in" THEN /* inclusao */
                DO:
                    IF ab_unmap.aux_stdopcao <> "i" THEN
                       DO:
                          ASSIGN ab_unmap.aux_stdopcao = "i".
                       END.
                END. /* fim inclusao */

           WHEN "ex" THEN /* exclusao */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    /* busca o próximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                           ELSE
                              ASSIGN aux_nrdrowid-auxiliar = "?".
                       END.          
                       
                    /*** PROCURA TABELA PARA VALIDAR -> COM NO-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    
                    /*** PROCURA TABELA PARA EXCLUIR -> COM EXCLUSIVE-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                          DO:
                              ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */ 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                          END.
                       ELSE
                          ASSIGN msg-erro-aux = 2. /* registro não existe */
                    ELSE
                       DO:
                          IF msg-erro = "" THEN
                             DO:
                                RUN local-delete-record.
                                DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                   ASSIGN msg-erro = msg-erro + ERROR-STATUS:GET-MESSAGE(i).
                                END.    

                                IF msg-erro = " " THEN
                                   DO:
                                       IF aux_nrdrowid-auxiliar = "?" THEN
                                          RUN PosicionaNoPrimeiro.
                                       ELSE
                                          DO:
                                              ASSIGN ab_unmap.aux_nrdrowid = aux_nrdrowid-auxiliar.
                                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                              
                                              IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                                 RUN PosicionaNoSeguinte.
                                          END.   
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                       END.  
                END. /* fim exclusao */

           WHEN "pe" THEN /* pesquisar */
                DO:   
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim pesquisar */

           WHEN "li" THEN /* listar */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim listar */

           WHEN "pr" THEN /* primeiro */
                RUN PosicionaNoPrimeiro.
      
           WHEN "ul" THEN /* ultimo */
                RUN PosicionaNoUltimo.
      
           WHEN "an" THEN /* anterior */
                RUN PosicionaNoAnterior.
      
           WHEN "se" THEN /* seguinte */
                RUN PosicionaNoSeguinte.
    
      END CASE.

      RUN CriaListaEventos.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' alert("'+ v-descricaoerro + '"); ').
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
                 
             END.
                         
      END CASE.     

   END. /* Fim do método POST */
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
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
          
           OTHERWISE
                DO:  
                    IF GET-VALUE("LinkRowid") <> "" THEN
                       DO:
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                           
                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              DO:
                                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento).

                                  FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                  IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                     ASSIGN ab_unmap.aux_stdopcao = "u".
                                  ELSE
                                     DO:
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                         
                                         FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                         IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                            ASSIGN ab_unmap.aux_stdopcao = "p".        
                                         ELSE
                                            ASSIGN ab_unmap.aux_stdopcao = "?".
                                     END.

                                  FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                              END.  
                           ELSE
                              ASSIGN ab_unmap.aux_nrdrowid = "?"
                                     ab_unmap.aux_stdopcao = "?".
                       END.  
                    
                    RUN CriaListaEventos.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('CarregaPrincipal()').

                    IF GET-VALUE("LinkRowid") = "" THEN
                      RUN RodaJavaScript('Incluir();').                    
                    
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