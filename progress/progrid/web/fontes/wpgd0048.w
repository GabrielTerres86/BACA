/*...............................................................................

Alterações: 18/03/2009 - Criado a partir do WPGD0038.W (Martin).
			
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
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD cdagenci     AS CHARACTER FORMAT "X(256)":U 
       FIELD cdeixtem     AS CHARACTER FORMAT "X(256)":U 
       FIELD consideraEventosForaDaAgenda AS LOGICAL  INITIAL no
       FIELD dataFinal    AS DATE FORMAT "99/99/9999":U  INITIAL ?
       FIELD dataInicial  AS DATE FORMAT "99/99/9999":U  INITIAL ?
       FIELD tipoDeRelatorio AS CHARACTER 
       FIELD cdcooper     AS CHARACTER.


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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0048"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0048.w"].

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


DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorevento           AS CHAR                           NO-UNDO.

DEFINE VARIABLE anoBase               AS INTEGER INITIAL [2005].
DEFINE VARIABLE conta                 AS INTEGER.

DEFINE VARIABLE vetormes              AS CHAR EXTENT 12
    INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
             "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0033          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratidp             LIKE crapidp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0048.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapidp.idevento 
&Scoped-define ENABLED-TABLES ab_unmap crapidp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapidp
&Scoped-Define ENABLED-OBJECTS ab_unmap.consideraEventosForaDaAgenda ~
ab_unmap.tipoDeRelatorio ab_unmap.cdagenci ab_unmap.dataFinal ~
ab_unmap.dataInicial ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.cdeixtem     ab_unmap.cdcooper
&Scoped-Define DISPLAYED-FIELDS crapidp.idevento 
&Scoped-define DISPLAYED-TABLES ab_unmap crapidp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapidp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.consideraEventosForaDaAgenda ~
ab_unmap.tipoDeRelatorio ab_unmap.cdagenci ab_unmap.dataFinal ~
ab_unmap.dataInicial ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.cdeixtem     ab_unmap.cdcooper

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
/*     ab_unmap.consideraEventosForaDaAgenda AT ROW 1 COL 1 HELP
          ""
          LABEL "consideraEventosForaDaAgenda"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
*/          
     ab_unmap.tipoDeRelatorio AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG SORT 
          LIST-ITEM-PAIRS "Inscrições via Internet","1",
                          "Participações por Eixo Temático","2",
                          "Cooperados sem Integração","3" ,
                          "Questionários entregues e devolvidos","4",
                          "Questionários entregues e não devolvidos","5"
          SIZE 20 BY 4
     ab_unmap.cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.dataFinal AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "99/99/9999":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.dataInicial AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "99/99/9999":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
/*     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
*/          
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsretorn AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
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
     ab_unmap.cdeixtem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.idevento AT ROW 1 COL 1 NO-LABEL
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
          FIELD aux_cdagenci AS CHARACTER 
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD cdeixtem AS CHARACTER FORMAT "X(256)":U 
          FIELD consideraEventosForaDaAgenda AS LOGICAL  INITIAL no
          FIELD dataFinal AS DATE FORMAT "99/99/9999":U  INITIAL ?
          FIELD dataInicial AS DATE FORMAT "99/99/9999":U  INITIAL ?
          FIELD tipoDeRelatorio AS CHARACTER 
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




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdagenci IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_dtanoage IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdeixtem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR TOGGLE-BOX ab_unmap.consideraEventosForaDaAgenda IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.dataFinal IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.dataInicial IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapidp.idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR SELECTION-LIST ab_unmap.tipoDeRelatorio IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
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
DEFINE VARIABLE aux_tppartic AS CHAR NO-UNDO.
DEFINE VARIABLE aux_flgcompr AS CHAR NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur AS CHAR NO-UNDO.
DEFINE VARIABLE aux_nrinscri AS INT  NO-UNDO.
DEFINE VARIABLE aux_nrconfir AS INT  NO-UNDO.
DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
DEFINE VARIABLE aux_nrdturma AS INT  NO-UNDO.
DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.

/* se informado o pac, lista cada evento dele */  
IF  int(ab_unmap.cdagenci) > 0  THEN
    DO: 
        FOR EACH crapeap WHERE crapeap.idevento = int(ab_unmap.aux_idevento)    AND
                               crapeap.cdcooper = int(ab_unmap.cdcooper)        AND
                              (crapeap.cdagenci = int(ab_unmap.cdagenci)   OR
                               /* Assembleias */
                              (crapeap.cdagenci = 0       AND
                               INT(ab_unmap.aux_idevento) = 2))                 AND
                               crapeap.dtanoage = int(ab_unmap.aux_dtanoage)    AND
                               crapeap.flgevsel = YES                           NO-LOCK, 
           FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento              AND
                               crapedp.idevento = crapeap.idevento              AND
                               crapedp.cdcooper = crapeap.cdcooper              AND
                               crapedp.dtanoage = crapeap.dtanoage              NO-LOCK,
            EACH crapadp WHERE crapadp.idevento = crapeap.idevento              AND
                               crapadp.cdcooper = crapeap.cdcooper              AND
                               crapadp.cdagenci = crapeap.cdagenci              AND
                               crapadp.dtanoage = crapeap.dtanoage              AND
                               crapadp.cdevento = crapeap.cdevento              NO-LOCK
                               BREAK BY crapadp.cdagenci
                                        BY crapedp.nmevento
                                           BY crapadp.nrseqdig:

            IF   FIRST-OF(crapedp.nmevento)   THEN
                 DO:
                     ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0
                            aux_nmevento = crapedp.nmevento.
                    
                     IF vetorevento = "" THEN
                         vetorevento = "~{" +
                             "cdagenci:'" +  STRING(INT(ab_unmap.cdagenci)) + "'," + 
                             "cdcooper:'" +  STRING(crapeap.cdcooper)       + "'," +
                             "cdevento:'" +  STRING(crapeap.cdevento)       + "'," +
                             "nmevento:'" +  STRING(aux_nmevento)           + "'," +
                             "idstaeve:'" +  STRING(0)                      + "'," +
                             "flgcompr:'" +  STRING(0)                      + "'," +
                             "qtmaxtur:'" +  STRING(0)                      + "'," +
                             "nrinscri:'" +  STRING(0)                      + "'," +
                             "nrconfir:'" +  STRING(0)                      + "'," +
                             "nrseqeve:'" +  STRING(aux_nrseqeve)           + "'," +
                             "tppartic:'" +  STRING(0)                      + "'" + "~}".
                     ELSE
                         vetorevento = vetorevento + "," + "~{" +
                             "cdagenci:'" +  STRING(INT(ab_unmap.cdagenci)) + "'," + 
                             "cdcooper:'" +  STRING(crapeap.cdcooper)       + "'," +
                             "cdevento:'" +  STRING(crapeap.cdevento)       + "'," +
                             "nmevento:'" +  STRING(aux_nmevento)           + "'," +
                             "idstaeve:'" +  STRING(crapadp.idstaeve)       + "'," +
                             "flgcompr:'" +  STRING(0)                      + "'," +
                             "qtmaxtur:'" +  STRING(0)                      + "'," +
                             "nrinscri:'" +  STRING(0)                      + "'," +
                             "nrconfir:'" +  STRING(0)                      + "'," +
                             "nrseqeve:'" +  STRING(aux_nrseqeve)           + "'," +
                             "tppartic:'" +  STRING(0)                      + "'" + "~}".
            END.
        END.
    END.
ELSE
    DO:
        FOR EACH  crapadp WHERE crapadp.idevento = int(ab_unmap.aux_idevento) AND
                                crapadp.cdcooper = int(ab_unmap.cdcooper)     AND
                                crapadp.dtanoage = int(ab_unmap.aux_dtanoage) NO-LOCK,
            FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento           AND
                                crapedp.idevento = crapadp.idevento           AND
                                crapedp.cdcooper = crapadp.cdcooper           AND
                                crapedp.dtanoage = crapadp.dtanoage           NO-LOCK
                                BREAK BY crapedp.nmevento:

            IF   FIRST-OF(crapedp.nmevento)   THEN
                 DO:
                     aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0.
                 
                     ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0
                            aux_nmevento = crapedp.nmevento.
                 
                     IF vetorevento = "" THEN
                         vetorevento = "~{" +
                             "cdagenci:'" +  STRING(0) + "'," + 
                             "cdcooper:'" +  STRING(crapadp.cdcooper) + "'," +
                             "cdevento:'" +  STRING(crapadp.cdevento) + "'," +
                             "nmevento:'" +  STRING(aux_nmevento)     + "'," +
                             "idstaeve:'" +  STRING(0)                + "'," +
                             "flgcompr:'" +  STRING(0)                + "'," +
                             "qtmaxtur:'" +  STRING(0)                + "'," +
                             "nrinscri:'" +  STRING(0)                + "'," +
                             "nrconfir:'" +  STRING(0)                + "'," +
                             "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                             "tppartic:'" +  STRING(0)                + "'" + "~}".
                     ELSE
                         vetorevento = vetorevento + "," + "~{" +
                             "cdagenci:'" +  STRING(0) + "'," + 
                             "cdcooper:'" +  STRING(crapadp.cdcooper) + "'," +
                             "cdevento:'" +  STRING(crapadp.cdevento) + "'," +
                             "nmevento:'" +  STRING(aux_nmevento)     + "'," +
                             "idstaeve:'" +  STRING(0)                + "'," +
                             "flgcompr:'" +  STRING(0)                + "'," +
                             "qtmaxtur:'" +  STRING(0)                + "'," +
                             "nrinscri:'" +  STRING(0)                + "'," +
                             "nrconfir:'" +  STRING(0)                + "'," +
                             "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                             "tppartic:'" +  STRING(0)                + "'" + "~}".
                 END.
        END.
    END.
  
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
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"ab_unmap.cdcooper":U,ab_unmap.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
/*  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
*/    
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
    ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdeixtem":U,"ab_unmap.cdeixtem":U,ab_unmap.cdeixtem:HANDLE IN FRAME {&FRAME-NAME}).
/*  RUN htmAssociate
    ("consideraEventosForaDaAgenda":U,"ab_unmap.consideraEventosForaDaAgenda":U,ab_unmap.consideraEventosForaDaAgenda:HANDLE IN FRAME {&FRAME-NAME}).
*/    
  RUN htmAssociate
    ("dataFinal":U,"ab_unmap.dataFinal":U,ab_unmap.dataFinal:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dataInicial":U,"ab_unmap.dataInicial":U,ab_unmap.dataInicial:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idevento":U,"crapidp.idevento":U,crapidp.idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("tipoDeRelatorio":U,"ab_unmap.tipoDeRelatorio":U,ab_unmap.tipoDeRelatorio:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
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
-------------------------------------------------------------------------------*/

DEFINE VARIABLE aux_flgfirst AS LOGICAL    INIT TRUE NO-UNDO.

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
       ab_unmap.cdagenci        = GET-VALUE("cdagenci")
       ab_unmap.cdcooper        = GET-VALUE("cdcooper").
       

RUN outputHeader.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.cdcooper) = 0   THEN
     ab_unmap.cdcooper = STRING(gnapses.cdcooper).

/* Se o PAC ainda não foi escolhido, pega o da sessão do usuário */
IF   INT(ab_unmap.cdagenci) = 0   AND
     ab_unmap.cdagenci      = ""  THEN
     ab_unmap.cdagenci = STRING(gnapses.cdagenci).

   
/* Posiciona por default, na agenda atual */
IF   ab_unmap.aux_dtanoage = ""   THEN
     FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                             gnpapgd.cdcooper = INT(ab_unmap.cdcooper)     AND 
                             gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
ELSE
     /* Se informou a data da agenda, permite que veja a agenda de um ano não atual */
     FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                             gnpapgd.cdcooper = INT(ab_unmap.cdcooper)     AND 
                             gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF   ab_unmap.aux_dtanoage <> ""   THEN
           RUN RodaJavaScript("alert('Nao existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").

      FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                              gnpapgd.cdcooper = INT(ab_unmap.cdcooper)     NO-LOCK NO-ERROR.
   END.


IF AVAILABLE gnpapgd THEN
   DO:
       IF   ab_unmap.aux_dtanoage = ""   THEN
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanoage).
       ELSE
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
   END.
ELSE
   ASSIGN ab_unmap.aux_dtanoage = "".

/* gera lista de cooperativas */
{includes/wpgd0098.i}
ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.


/* Progrid - PACS Agrupados */
IF   INT(ab_unmap.aux_idevento) = 1   THEN
     DO:
         { includes/wpgd0099.i ab_unmap.aux_dtanoage }
     END.
ELSE
/* Assembleias - PACS Nao Agrupados */
     DO:
         { includes/wpgd0097.i }
     END.

/* Cria o array com os pacs */
RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]"). 

/* gera lista de eventos */
RUN CriaListaEventos. 

IF ab_unmap.aux_dtanoage <> "" THEN
   ASSIGN dataInicial = DATE(01,01,INTEGER(ab_unmap.aux_dtanoage))
          dataFinal   = DATE(12,31,INTEGER(ab_unmap.aux_dtanoage)).


/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.
      RUN displayFields.
      RUN enableFields.
      RUN outputFields.

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
                    ELSE                    
                       RUN PosicionaNoPrimeiro.


                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('LimparCampos();').
                           RUN RodaJavaScript('top.frcod.Incluir();').
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

