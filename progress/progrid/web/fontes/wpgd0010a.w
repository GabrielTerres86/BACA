/*...............................................................................

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
            
            24/08/2010 - Lista eventos ativos e inativos no combo-box da Analise
                         de Sugestoes (Elton).
                                                 
            05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                                                 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                         
            17/12/2013 - Retirado condição de eventos inativos, listar somente 
                         eventos ativos (Lucas R.)
                         
            15/06/2015 - Melhorias OQS (Gabriel-RKAM). 
            
            14/07/2015 - Melhorias OQS - cadastro por temas e retirada do evento (Vanessa).
            
            25/08/2015 - Ajustes de homologaçao( Vanessa)
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD idevento     AS CHARACTER FORMAT "X(256)":U 
       FIELD cdcooper     AS CHARACTER FORMAT "X(256)":U 
       FIELD dtafim       AS CHARACTER FORMAT "X(256)":U 
       FIELD dtaini       AS CHARACTER FORMAT "X(256)":U
       FIELD flgsugca     AS LOGICAL 
       FIELD nrseqtem     AS CHARACTER
       FIELD tpfiltro     AS CHARACTER FORMAT "X(256)":U .
                          

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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0010a"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0010a.w"].

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
DEFINE VARIABLE h-b1wpgd0011          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratsdp             LIKE crapsdp.

DEF VAR aux_crapedp  AS CHAR NO-UNDO.
DEF VAR aux_craptem  AS CHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0010a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapsdp.dssugeve crapsdp.nrseqdig crapsdp.flgsugca
&Scoped-define ENABLED-TABLES ab_unmap crapsdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapsdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.dtafim ab_unmap.dtaini ab_unmap.nrseqtem ab_unmap.tpfiltro 
&Scoped-Define DISPLAYED-FIELDS crapsdp.dssugeve crapsdp.nrseqdig crapsdp.flgsugca
&Scoped-define DISPLAYED-TABLES ab_unmap crapsdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapsdp
&Scoped-Define DISPLAYED-OBJECTS  ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.dtafim ab_unmap.dtaini ab_unmap.nrseqtem  ab_unmap.tpfiltro 
/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     crapsdp.flgsugca AT ROW 1 COL 1 HELP
          ""
          LABEL "flgsugca"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
     crapsdp.dssugeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     ab_unmap.dtafim AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.dtaini AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
        ab_unmap.nrseqtem AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
    
     crapsdp.nrseqdig AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.tpfiltro AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL  FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL  FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71 BY 11.81.


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
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD dtafim AS CHARACTER FORMAT "X(256)":U 
          FIELD dtaini AS CHARACTER FORMAT "X(256)":U 
          FIELD flgsugca AS LOGICAL 
          FIELD nmevento AS CHARACTER 
          FIELD tpfiltro AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 11.81
         WIDTH              = 71.
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR EDITOR crapsdp.dssugeve IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ab_unmap.dtafim IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.dtaini IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR TOGGLE-BOX ab_unmap.flgsugca IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.nmevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN crapsdp.nrseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.tpfiltro IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
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
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dssugeve":U,"crapsdp.dssugeve":U,crapsdp.dssugeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtafim":U,"ab_unmap.dtafim":U,ab_unmap.dtafim:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtaini":U,"ab_unmap.dtaini":U,ab_unmap.dtaini:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgsugca":U,"crapsdp.flgsugca":U,crapsdp.flgsugca:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqtem":U,"ab_unmap.nrseqtem":U,ab_unmap.nrseqtem:HANDLE IN FRAME {&FRAME-NAME}).
  
  RUN htmAssociate
    ("nrseqdig":U,"crapsdp.nrseqdig":U,crapsdp.nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("tpfiltro":U,"ab_unmap.tpfiltro":U,ab_unmap.tpfiltro:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idevento":U,"ab_unmap.idevento":U,ab_unmap.idevento:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
      ("cdcooper":U,"ab_unmap.cdcooper":U,ab_unmap.cdcooper:HANDLE IN FRAME {&FRAME-NAME}). 
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
   
   DEFINE INPUT PARAMETER opcao AS CHARACTER.
   
   /* Instancia a BO para executar as procedures */
   RUN dbo/b1wpgd0011.p PERSISTENT SET h-b1wpgd0011.
   
   /* Se BO foi instanciada */
   IF VALID-HANDLE(h-b1wpgd0011) THEN
      DO:
         DO WITH FRAME {&FRAME-NAME}:
            IF opcao = "inclusao" THEN
               DO: 
                   /* não executa */
                   CREATE cratsdp.
   
                   RUN inclui-registro IN h-b1wpgd0011(INPUT TABLE cratsdp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
               END.
            ELSE  /* alteracao */
               DO:      
                   
                            /* cria a temp-table e joga o novo valor digitado para o campo */
                            CREATE cratsdp.
                            BUFFER-COPY crapsdp TO cratsdp.
       
                            ASSIGN cratsdp.nrseqtem = INT(INPUT ab_unmap.nrseqtem)
                                   cratsdp.flgsugca = (GET-VALUE("flgsugca") = "on")
                                   cratsdp.dssugeve = INPUT crapsdp.dssugeve.
                     
                            RUN altera-registro IN h-b1wpgd0011 (INPUT TABLE cratsdp, 
                                                                OUTPUT msg-erro).
   
                       
              
               END.    
         END. /* DO WITH FRAME {&FRAME-NAME} */
      
         /* "mata" a instância da BO */
         DELETE PROCEDURE h-b1wpgd0011 NO-ERROR.
      
      END. /* IF VALID-HANDLE(h-b1wpgd0011) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
   /* Instancia a BO para executar as procedures */
   RUN dbo/b1wpgd0011.p PERSISTENT SET h-b1wpgd0011.
    
   /* Se BO foi instanciada */
   IF VALID-HANDLE(h-b1wpgd0011) THEN
      DO:
         CREATE cratsdp.
         BUFFER-COPY crapsdp TO cratsdp.
             
         RUN exclui-registro IN h-b1wpgd0011(INPUT TABLE cratsdp, OUTPUT msg-erro).
   
         /* "mata" a instância da BO */
         DELETE PROCEDURE h-b1wpgd0011 NO-ERROR.
      END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 

PROCEDURE local-display-fields :

    RUN displayFields.
                                         
    IF  NOT AVAIL crapsdp THEN
        RETURN.
    
    ASSIGN ab_unmap.nrseqtem:SCREEN-VALUE IN FRAME {&FRAME-NAME} = 
                                     STRING(crapsdp.nrseqtem).
    
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
          FIND PREV {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)*/ NO-LOCK NO-WAIT NO-ERROR.
   
          IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
              DO:
                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).
   
                  FIND PREV {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)*/ NO-LOCK NO-WAIT NO-ERROR.
   
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

    FIND FIRST {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)*/ NO-LOCK NO-WAIT NO-ERROR.

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
       FIND NEXT {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)*/ NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)*/ NO-LOCK NO-WAIT NO-ERROR.

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
   
   FIND LAST {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
                                                                             
   
   IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
       ASSIGN ab_unmap.aux_nrdrowid = "?".
   ELSE
       ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
              ab_unmap.aux_stdopcao = "".  
   
   END PROCEDURE.

   &ANALYZE-RESUME
   
   &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
   PROCEDURE process-web-request :
   
   v-identificacao = get-cookie("cookie-usuario-em-uso").
   
   /* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
   FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
       LEAVE.
   END.
     
   ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
          FlagPermissoes           = GET-VALUE("aux_lspermis")
          msg-erro-aux             = 0
          ab_unmap.cdcooper        = get-value("cdcooper")
          ab_unmap.idevento        = get-value("idevento")   
          ab_unmap.aux_dsendurl    = AppURL                        
          ab_unmap.aux_lspermis    = FlagPermissoes                
          ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
          ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
          ab_unmap.dtaini          = GET-VALUE("dtaini")
          ab_unmap.dtafim          = GET-VALUE("dtafim")
          ab_unmap.tpfiltro        = GET-VALUE("tpfiltro").
   
   RUN outputHeader.
      
   ASSIGN aux_craptem  = ",0,".
          
   
   FOR EACH craptem NO-LOCK WHERE
            craptem.cdcooper = 0 AND
            craptem.idsittem = 'A'
            BY craptem.dstemeix:           
       

       ASSIGN aux_craptem  = aux_craptem  + REPLACE(craptem.dstemeix,",","§§") + 
                             "," + STRING(craptem.nrseqtem) + ",".
                                                             
             
  END.

  aux_craptem = SUBSTRING(aux_craptem,1, (LENGTH(aux_craptem) - 1) ).
  
  ASSIGN ab_unmap.nrseqtem:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_craptem. 
  
  
  /* método POST */
  IF REQUEST_METHOD = "POST":U THEN 
     DO:
        RUN inputFields.
  
        /* Instancia a BO para executar as procedures */
        RUN dbo/b1wpgd0011.p PERSISTENT SET h-b1wpgd0011.
  
        /* Se BO foi instanciada */
        IF VALID-HANDLE(h-b1wpgd0011) THEN
           DO:
              RUN posiciona-registro IN h-b1wpgd0011(INPUT TO-ROWID(ab_unmap.aux_nrdrowid), OUTPUT msg-erro).
              DELETE PROCEDURE h-b1wpgd0011 NO-ERROR.
           END.

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
                          CLEAR FRAME {&FRAME-NAME}.
                          ASSIGN ab_unmap.aux_stdopcao = "i".
                       END.
                END. /* fim inclusao */

           WHEN "ex" THEN /* exclusao */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    /* busca o próximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)*/ NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = int(ab_unmap.aux_idevento)*/ NO-LOCK NO-WAIT NO-ERROR.

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

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" top.frames[0].MostraMsg('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('alert("' + v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 10 THEN DO:
               RUN RodaJavaScript('window.opener.AtualizaDados();').
               RUN RodaJavaScript('window.close();').
           END.
               /* RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). */
         
      END CASE.     

      /*RUN RodaJavaScript('top.frames[0].ZeraOp()').  */ 

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
                                         /*ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)*/ .

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
                    ELSE                    
                       RUN PosicionaNoPrimeiro.

                    /*RUN displayFields.*/
                    RUN local-display-fields.
                    RUN enableFields.
                    RUN outputFields.
                    /*RUN RodaJavaScript('top.frcod.FechaZoom()').*/
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('LimparCampos();').
                           RUN RodaJavaScript('Incluir();').
                       END.
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

