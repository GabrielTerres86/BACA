/*...............................................................................

Alterações: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).

			      05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            15/10/2015 - Inclusão dos Campos UF e Cidade PRJ 229 (Vanessa).
      
            30/05/2016 - Ajustes navegaçao com a tela fornecedor wpgd0012c
                         PRJ229 - Melhorias OQS (Odirlei-AMcom)

            28/11/2016 - Ajustes de carragamento de UF e cidades, SD - 563601
                         (Jean Michel).
            
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          gener            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdfacili AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dsestado AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdcidade AS CHARACTER FORMAT "X(256)":U
       FIELD dtmvtolt AS CHARACTER FORMAT "X(256)":U
       FIELD dtvalpro AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdtemeix AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdeixtem AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U
       FIELD nmevefor AS CHARACTER FORMAT "X(256)":U
       FIELD dsobjeti AS CHARACTER FORMAT "X(256)":U
       FIELD dsconteu AS CHARACTER FORMAT "X(256)":U
       FIELD dsmetodo AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dspublic AS CHARACTER FORMAT "X(256)":U
       FIELD dsobserv AS CHARACTER FORMAT "X(256)":U
       FIELD dsidadpa AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idforrev AS CHARACTER FORMAT "X(256)":U
       FIELD dsprereq AS CHARACTER FORMAT "X(256)":U
       FIELD txfacili AS CHARACTER FORMAT "X(256)":U
       FIELD vlinvest AS CHARACTER FORMAT "X(256)":U
       FIELD aux_flgtrinc AS CHARACTER FORMAT "X(256)":U
       FIELD qtcarhor AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idvapost AS CHARACTER FORMAT "X(256)":U
       FIELD aux_lsfacili AS CHARACTER FORMAT "X(256)":U
       FIELD aux_hdcidade AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dsturind_M AS LOGICAL
       FIELD aux_dsturind_V AS LOGICAL
       FIELD aux_dsturind_N AS LOGICAL
       FIELD aux_dsdiaind_2 AS LOGICAL
       FIELD aux_dsdiaind_3 AS LOGICAL
       FIELD aux_dsdiaind_4 AS LOGICAL
       FIELD aux_dsdiaind_5 AS LOGICAL
       FIELD aux_dsdiaind_6 AS LOGICAL
       FIELD aux_dsdiaind_7 AS LOGICAL
       FIELD aux_dsdiaind_1 AS LOGICAL.

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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0016"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0016.w"].

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
DEFINE VARIABLE vetorestados           AS CHAR NO-UNDO.  
DEFINE VARIABLE vetorcidades           AS CHAR NO-UNDO.  

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0016          AS HANDLE                         NO-UNDO.

DEF VAR aux_hdcidade AS INTEGER NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE gnatfep             LIKE gnapfep.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0016.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS gnapfep.nrdddfon[1] gnapfep.nrdddfon[2] ~
gnapfep.nrdddfon[3] gnapfep.nrtelefo[1] gnapfep.nrtelefo[2] ~
gnapfep.nrtelefo[3] gnapfep.dsavalia gnapfep.dscurric gnapfep.nmfacili ~
crapmun.cdestado gnapfep.cdcidade gnapfep.dsforaca gnapfep.dsforcom ~
gnapfep.dstemexp gnapfep.dspublic gnapfep.idnivfac gnapfep.dsturind gnapfep.dsdiaind
&Scoped-define ENABLED-TABLES gnapfep ab_unmap crapmun
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE gnapfep
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cddopcao ab_unmap.aux_cdfacili ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrcpfcgc ab_unmap.aux_nrdrowid  ~
ab_unmap.aux_stdopcao ab_unmap.aux_dsestado ab_unmap.aux_cdcidade ab_unmap.dtmvtolt ab_unmap.dtvalpro ab_unmap.aux_cdtemeix ab_unmap.aux_cdeixtem ~
ab_unmap.nmevefor ab_unmap.dsobjeti ab_unmap.dsconteu ab_unmap.aux_cdevento ab_unmap.dsmetodo ab_unmap.aux_dspublic ab_unmap.dsobserv ab_unmap.dsidadpa ~
ab_unmap.aux_idforrev ab_unmap.dsprereq ab_unmap.txfacili ab_unmap.vlinvest ~
ab_unmap.aux_flgtrinc ab_unmap.qtcarhor ab_unmap.aux_idvapost ab_unmap.aux_lsfacili ~
ab_unmap.aux_dsturind_M ab_unmap.aux_dsturind_V ab_unmap.aux_dsturind_N ~
ab_unmap.aux_dsdiaind_1 ab_unmap.aux_dsdiaind_2 ab_unmap.aux_dsdiaind_3 ab_unmap.aux_dsdiaind_4 ~
ab_unmap.aux_dsdiaind_5 ab_unmap.aux_dsdiaind_6 ab_unmap.aux_dsdiaind_7 ab_unmap.aux_hdcidade
&Scoped-Define DISPLAYED-FIELDS gnapfep.nrdddfon[1] gnapfep.nrdddfon[2] ~
gnapfep.nrdddfon[3] gnapfep.nrtelefo[1] gnapfep.nrtelefo[2] ~
gnapfep.nrtelefo[3] gnapfep.dsavalia gnapfep.dscurric gnapfep.nmfacili ~
crapmun.cdestado gnapfep.cdcidade gnapfep.dsforaca gnapfep.dsforcom ~
gnapfep.dstemexp gnapfep.dspublic gnapfep.idnivfac gnapfep.dsturind gnapfep.dsdiaind
&Scoped-define DISPLAYED-TABLES gnapfep ab_unmap crapmun
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE gnapfep
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cddopcao ab_unmap.aux_cdfacili ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrcpfcgc ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.aux_dsestado ab_unmap.aux_cdcidade ab_unmap.dtmvtolt ab_unmap.dtvalpro ab_unmap.aux_cdtemeix ab_unmap.aux_cdeixtem ~
ab_unmap.nmevefor ab_unmap.dsobjeti ab_unmap.dsconteu ab_unmap.aux_cdevento ab_unmap.dsmetodo ab_unmap.aux_dspublic ab_unmap.dsobserv ab_unmap.dsidadpa ~
ab_unmap.aux_idforrev ab_unmap.dsprereq ab_unmap.txfacili ab_unmap.vlinvest ~
ab_unmap.aux_flgtrinc ab_unmap.qtcarhor ab_unmap.aux_idvapost ab_unmap.aux_lsfacili ~
ab_unmap.aux_dsturind_M ab_unmap.aux_dsturind_V ab_unmap.aux_dsturind_N ~
ab_unmap.aux_dsdiaind_1 ab_unmap.aux_dsdiaind_2 ab_unmap.aux_dsdiaind_3 ab_unmap.aux_dsdiaind_4 ~
ab_unmap.aux_dsdiaind_5 ab_unmap.aux_dsdiaind_6 ab_unmap.aux_dsdiaind_7 ab_unmap.aux_hdcidade

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     gnapfep.nrdddfon[1] AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfep.nrdddfon[2] AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfep.nrdddfon[3] AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfep.nrtelefo[1] AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfep.nrtelefo[2] AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfep.nrtelefo[3] AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
          
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdfacili AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_nrcpfcgc AT ROW 1 COL 1 HELP
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
     gnapfep.dsavalia AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfep.dscurric AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfep.dsforaca AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfep.dsforcom AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfep.dstemexp AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfep.dspublic AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfep.idnivfac AT ROW 1 COL 1 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "idnivfac B", "B",
                    "idnivfac I", "I",
                    "idnivfac A", "A"
          SIZE 20 BY 3
     gnapfep.dsturind AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfep.dsdiaind AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfep.nmfacili AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     
     crapmun.cdestado AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1      
     gnapfep.cdcidade  AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1  
     ab_unmap.aux_dsestado AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4    
     
     ab_unmap.aux_cdcidade AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4    
      ab_unmap.dtmvtolt AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.dtvalpro AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_cdtemeix AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_cdeixtem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    
    ab_unmap.nmevefor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.dsobjeti AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.dsconteu AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.dsmetodo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dspublic AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.dsobserv AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.dsidadpa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
          
    ab_unmap.aux_idforrev AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.dsprereq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.txfacili AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vlinvest AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgtrinc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.qtcarhor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_lsfacili AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dsturind_M AT ROW 1 COL 1
          LABEL "Matutino"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsturind_V AT ROW 1 COL 1
          LABEL "Vespertino"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsturind_N AT ROW 1 COL 1
          LABEL "Noturno"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsdiaind_1 AT ROW 1 COL 1
          LABEL "Dom"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsdiaind_2 AT ROW 1 COL 1
          LABEL "Seg"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsdiaind_3 AT ROW 1 COL 1
          LABEL "Ter"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsdiaind_4 AT ROW 1 COL 1
          LABEL "Qua"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsdiaind_5 AT ROW 1 COL 1
          LABEL "Qui"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsdiaind_6 AT ROW 1 COL 1
          LABEL "Sex"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_dsdiaind_7 AT ROW 1 COL 1
          LABEL "Sab"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    ab_unmap.aux_hdcidade AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 47.6 BY 20.1.

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
          FIELD aux_cdfacili AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsestado AS CHARACTER FORMAT "X(256)":U
          FIELD aux_cdcidade AS CHARACTER FORMAT "X(256)":U          
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 20.1
         WIDTH              = 47.6.
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdfacili IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrcpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR EDITOR gnapfep.dsavalia IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfep.dscurric IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfep.dsforaca IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfep.dsforcom IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfep.dstemexp IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfep.dsturind IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfep.dsdiaind IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR RADIO-SET gnapfep.idnivfac IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfep.dspublic IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN gnapfep.nmfacili IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnapfep.nrdddfon[1] IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnapfep.nrdddfon[2] IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnapfep.nrdddfon[3] IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnapfep.nrtelefo[1] IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnapfep.nrtelefo[2] IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnapfep.nrtelefo[3] IN FRAME Web-Frame
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEstados w-html 

PROCEDURE CriaListaEstados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEF VAR aux_contador AS INTEGER INIT 0 NO-UNDO.
  
  RUN RodaJavaScript("var estados = new Array();").
  
  FOR EACH crapmun NO-LOCK WHERE BREAK BY crapmun.cdestado:
   
    IF FIRST-OF(crapmun.cdestado) THEN
      DO:
		RUN RodaJavaScript("estados.push(~{cdestado:'" + TRIM(STRING(crapmun.cdestado))+ "'~});").
      END.   
  END. /* for each */  
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaCidades w-html 

PROCEDURE CriaListaCidades :

  DEF VAR aux_contador AS INTEGER INIT 0 NO-UNDO.
  
  RUN RodaJavaScript("var cidades = new Array();").
  
  FOR EACH crapmun NO-LOCK WHERE crapmun.cdestado = ab_unmap.aux_dsestado 
                             AND crapmun.cdcidade <> 0
                             AND TRIM(STRING(crapmun.cdcidade)) <> "" BY crapmun.dscidade:
       
	RUN RodaJavaScript("cidades.push(~{cdestado:'" + TRIM(string(crapmun.cdestado))
                                  + "',dscidade:'" + TRIM(string(crapmun.dscidade))
                                  + "',cdcidade:'" + TRIM(string(crapmun.cdcidade))+ "'~});").
	    
  END. /* for each */ 
  
END PROCEDURE.

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
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdfacili":U,"ab_unmap.aux_cdfacili":U,ab_unmap.aux_cdfacili:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc":U,"ab_unmap.aux_nrcpfcgc":U,ab_unmap.aux_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsavalia":U,"gnapfep.dsavalia":U,gnapfep.dsavalia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dscurric":U,"gnapfep.dscurric":U,gnapfep.dscurric:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsforaca":U,"gnapfep.dsforaca":U,gnapfep.dsforaca:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsforcom":U,"gnapfep.dsforcom":U,gnapfep.dsforcom:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dstemexp":U,"gnapfep.dstemexp":U,gnapfep.dstemexp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idnivfac":U,"gnapfep.idnivfac":U,gnapfep.idnivfac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsturind":U,"gnapfep.dsturind":U,gnapfep.dsturind:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsdiaind":U,"gnapfep.dsdiaind":U,gnapfep.dsdiaind:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dspublic":U,"gnapfep.dspublic":U,gnapfep.dspublic:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmfacili":U,"gnapfep.nmfacili":U,gnapfep.nmfacili:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddfon1":U,"gnapfep.nrdddfon[1]":U,gnapfep.nrdddfon[1]:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddfon2":U,"gnapfep.nrdddfon[2]":U,gnapfep.nrdddfon[2]:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddfon3":U,"gnapfep.nrdddfon[3]":U,gnapfep.nrdddfon[3]:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrtelefo1":U,"gnapfep.nrtelefo[1]":U,gnapfep.nrtelefo[1]:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrtelefo2":U,"gnapfep.nrtelefo[2]":U,gnapfep.nrtelefo[2]:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrtelefo3":U,"gnapfep.nrtelefo[3]":U,gnapfep.nrtelefo[3]:HANDLE IN FRAME {&FRAME-NAME}).
   RUN htmAssociate
    ("cdestado":U,"crapmun.cdestado":U, crapmun.cdestado:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcidade":U,"gnapfep.cdcidade":U,gnapfep.cdcidade:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsestado":U,"ab_unmap.aux_dsestado":U, ab_unmap.aux_dsestado:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcidade":U,"ab_unmap.aux_cdcidade":U,ab_unmap.aux_cdcidade:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_hdcidade":U,"ab_unmap.aux_hdcidade":U, ab_unmap.aux_hdcidade:HANDLE IN FRAME {&FRAME-NAME}).
 RUN htmAssociate
    ("dtmvtolt":U,"ab_unmap.dtmvtolt":U,ab_unmap.dtmvtolt:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("dtvalpro":U,"ab_unmap.dtvalpro":U,ab_unmap.dtvalpro:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_cdtemeix":U,"ab_unmap.aux_cdtemeix":U,ab_unmap.aux_cdtemeix:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_cdeixtem":U,"ab_unmap.aux_cdeixtem":U,ab_unmap.aux_cdeixtem:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("nmevefor":U,"ab_unmap.nmevefor":U,ab_unmap.nmevefor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobjeti":U,"ab_unmap.dsobjeti":U,ab_unmap.dsobjeti:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("dsconteu":U,"ab_unmap.dsconteu":U,ab_unmap.dsconteu:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("dsmetodo":U,"ab_unmap.dsmetodo":U,ab_unmap.dsmetodo:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_dspublic":U,"ab_unmap.aux_dspublic":U,ab_unmap.aux_dspublic:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("dsobserv":U,"ab_unmap.dsobserv":U,ab_unmap.dsobserv:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("dsidadpa":U,"ab_unmap.dsidadpa":U,ab_unmap.dsidadpa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idforrev":U,"ab_unmap.aux_idforrev":U,ab_unmap.aux_idforrev:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("dsprereq":U,"ab_unmap.dsprereq":U,ab_unmap.dsprereq:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("txfacili":U,"ab_unmap.txfacili":U,ab_unmap.txfacili:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("vlinvest":U,"ab_unmap.vlinvest":U,ab_unmap.vlinvest:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_flgtrinc":U,"ab_unmap.aux_flgtrinc":U,ab_unmap.aux_flgtrinc:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("qtcarhor":U,"ab_unmap.qtcarhor":U,ab_unmap.qtcarhor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsfacili":U,"ab_unmap.aux_lsfacili":U,ab_unmap.aux_lsfacili:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsturind_M":U,"ab_unmap.aux_dsturind_M":U,ab_unmap.aux_dsturind_M:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsturind_V":U,"ab_unmap.aux_dsturind_V":U,ab_unmap.aux_dsturind_V:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsturind_N":U,"ab_unmap.aux_dsturind_N":U,ab_unmap.aux_dsturind_N:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind_1":U,"ab_unmap.aux_dsdiaind_1":U,ab_unmap.aux_dsdiaind_1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind_2":U,"ab_unmap.aux_dsdiaind_2":U,ab_unmap.aux_dsdiaind_2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind_3":U,"ab_unmap.aux_dsdiaind_3":U,ab_unmap.aux_dsdiaind_3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind_4":U,"ab_unmap.aux_dsdiaind_4":U,ab_unmap.aux_dsdiaind_4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind_5":U,"ab_unmap.aux_dsdiaind_5":U,ab_unmap.aux_dsdiaind_5:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind_6":U,"ab_unmap.aux_dsdiaind_6":U,ab_unmap.aux_dsdiaind_6:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind_7":U,"ab_unmap.aux_dsdiaind_7":U,ab_unmap.aux_dsdiaind_7:HANDLE IN FRAME {&FRAME-NAME}).
  
 
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.


/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0016.p PERSISTENT SET h-b1wpgd0016.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0016) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:
         IF opcao = "inclusao" THEN
            DO: 
              
                CREATE gnatfep.
                ASSIGN
                    gnatfep.cdcooper = 0
                    gnatfep.cdfacili = ?
                    gnatfep.dsavalia = INPUT gnapfep.dsavalia
                    gnatfep.dscurric = INPUT gnapfep.dscurric
                    gnatfep.dsforaca = INPUT gnapfep.dsforaca
                    gnatfep.dsforcom = INPUT gnapfep.dsforcom
                    gnatfep.dstemexp = INPUT gnapfep.dstemexp
                    gnatfep.idnivfac = INPUT gnapfep.idnivfac
                    gnatfep.dsturind = INPUT gnapfep.dsturind
                    gnatfep.dsdiaind = INPUT gnapfep.dsdiaind
                    gnatfep.dspublic = INPUT gnapfep.dspublic
                    gnatfep.idevento = INT(ab_unmap.aux_idevento)
                    gnatfep.nmfacili = INPUT gnapfep.nmfacili
                    gnatfep.nrcpfcgc = DECIMAL(ab_unmap.aux_nrcpfcgc)

                    gnatfep.nrdddfon[1] = INPUT gnapfep.nrdddfon[1]
                    gnatfep.nrdddfon[2] = INPUT gnapfep.nrdddfon[2]
                    gnatfep.nrdddfon[3] = INPUT gnapfep.nrdddfon[3]

                    gnatfep.nrtelefo[1] = dec(string(INPUT gnapfep.nrtelefo[1],'999999999'))
                    gnatfep.nrtelefo[2] = dec(string(INPUT gnapfep.nrtelefo[2],'999999999'))
                    gnatfep.nrtelefo[3] = dec(string(INPUT gnapfep.nrtelefo[3],'999999999'))
                    gnatfep.cdcidade    = DECIMAL(ab_unmap.aux_cdcidade).

                RUN inclui-registro IN h-b1wpgd0016(INPUT TABLE gnatfep, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                 
            END.
         ELSE  /* alteracao */
            DO:
                /* cria a temp-table e joga o novo valor digitado para o campo */
                CREATE gnatfep.
                BUFFER-COPY gnapfep TO gnatfep.

                ASSIGN
                    gnatfep.cdcooper = 0
                    gnatfep.dsavalia = INPUT gnapfep.dsavalia
                    gnatfep.dscurric = INPUT gnapfep.dscurric
                    gnatfep.dsforaca = INPUT gnapfep.dsforaca
                    gnatfep.dsforcom = INPUT gnapfep.dsforcom
                    gnatfep.dstemexp = INPUT gnapfep.dstemexp
                    gnatfep.idnivfac = INPUT gnapfep.idnivfac
                    gnatfep.dsturind = INPUT gnapfep.dsturind
                    gnatfep.dsdiaind = INPUT gnapfep.dsdiaind
                    gnatfep.dspublic = INPUT gnapfep.dspublic
                    gnatfep.idevento = INT(ab_unmap.aux_idevento)
                    gnatfep.nmfacili = INPUT gnapfep.nmfacili
                    gnatfep.nrcpfcgc = DECIMAL(ab_unmap.aux_nrcpfcgc)

                    gnatfep.nrdddfon[1] = INPUT gnapfep.nrdddfon[1]
                    gnatfep.nrdddfon[2] = INPUT gnapfep.nrdddfon[2]
                    gnatfep.nrdddfon[3] = INPUT gnapfep.nrdddfon[3]

                    gnatfep.nrtelefo[1] = INPUT gnapfep.nrtelefo[1]
                    gnatfep.nrtelefo[2] = INPUT gnapfep.nrtelefo[2]
                    gnatfep.nrtelefo[3] = INPUT gnapfep.nrtelefo[3]
                    gnatfep.cdcidade    = DECIMAL(ab_unmap.aux_cdcidade).
                 
                RUN altera-registro IN h-b1wpgd0016(INPUT TABLE gnatfep, OUTPUT msg-erro).
                
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0016 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0016) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0016.p PERSISTENT SET h-b1wpgd0016.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0016) THEN
   DO:
      CREATE gnatfep.
      BUFFER-COPY gnapfep TO gnatfep.
          
      RUN exclui-registro IN h-b1wpgd0016(INPUT TABLE gnatfep, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0016 NO-ERROR.
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
       FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

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
FIND FIRST {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.


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
       FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

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
  
ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
       FlagPermissoes        = GET-VALUE("aux_lspermis")
       msg-erro-aux          = 0
       ab_unmap.aux_idevento = get-value("aux_idevento")
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdfacili = GET-VALUE("aux_cdfacili")
       ab_unmap.aux_nrcpfcgc = GET-VALUE("aux_nrcpfcgc")
       ab_unmap.aux_dsestado = GET-VALUE("aux_dsestado")
       ab_unmap.aux_cdcidade = GET-VALUE("aux_cdcidade")
       ab_unmap.dtmvtolt = GET-VALUE("dtmvtolt")
       ab_unmap.dtvalpro = GET-VALUE("dtvalpro")
       ab_unmap.aux_cdtemeix = GET-VALUE("aux_cdtemeix")
       ab_unmap.aux_cdeixtem = GET-VALUE("aux_cdeixtem")
       ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
       ab_unmap.nmevefor = GET-VALUE("nmevefor")
       ab_unmap.dsobjeti = GET-VALUE("dsobjeti")
       ab_unmap.dsconteu = GET-VALUE("dsconteu")
       ab_unmap.dsmetodo = GET-VALUE("dsmetodo")
       ab_unmap.aux_dspublic = GET-VALUE("aux_dspublic")
       ab_unmap.dsobserv = GET-VALUE("dsobserv")
       ab_unmap.dsidadpa = GET-VALUE("dsidadpa")
       ab_unmap.aux_idforrev = GET-VALUE("aux_idforrev")
       ab_unmap.dsprereq = GET-VALUE("dsprereq")
       ab_unmap.txfacili = GET-VALUE("txfacili")
       ab_unmap.vlinvest = GET-VALUE("vlinvest")
       ab_unmap.aux_flgtrinc = GET-VALUE("aux_flgtrinc")
       ab_unmap.qtcarhor = GET-VALUE("qtcarhor")
       ab_unmap.aux_idvapost = GET-VALUE("aux_idvapost")
       ab_unmap.aux_lsfacili = GET-VALUE("aux_lsfacili").

RUN outputHeader.
/* método POST crampmun.cdestado crapmun.cdcidade*/
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
                                  DO: 
                                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                  END.   
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
                    FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

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
                                          
                                       ASSIGN msg-erro-aux = 11. /* Solicitação realizada com sucesso */ 
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
           WHEN "ci" THEN /* seguinte */
                RUN CriaListaCidades.
    
      END CASE.

      RUN CriaListaEstados.
             
      IF msg-erro-aux = 10 OR  msg-erro-aux = 11 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      IF opcao = "ex" AND msg-erro-aux > 0 THEN
      DO: 
        IF gnapfep.cdcidade > 0 THEN
          DO:
              FIND FIRST crapmun WHERE crapmun.cdcidade = gnapfep.cdcidade  NO-LOCK NO-ERROR. 
                          
              IF AVAIL crapmun  THEN
              DO:
                 ASSIGN ab_unmap.aux_dsestado = crapmun.cdestado.
                 RUN CriaListaCidades.
              END.
          END.
          ELSE DO: 
            RUN RodaJavaScript("var cidades=new Array();").
          END.
          RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")').
          RUN RodaJavaScript('window.opener.Restaurar();').
          RUN RodaJavaScript('self.close();').
      END.
      
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
                    
                   /*RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")').
                   RUN RodaJavaScript('window.opener.Restaurar();').
                   RUN RodaJavaScript('self.close();').
                   RUN RodaJavaScript('window.opener.location.reload(); ').*/
                   /*RUN RodaJavaScript('self.close();').*/
                   /*RUN RodaJavaScript('window.opener.Recarrega(); ').*/
                   /*RUN RodaJavaScript('window.opener.restaurar(); ').*/ 
                   
                   /* Alterado pois ao criar uma proposta e adicionar um facilitador
                     ao retornar estava sendo apagados alguns dados da proposta */
                   RUN RodaJavaScript('self.close();').
                   RUN RodaJavaScript('window.opener.Recarrega(); ').
                   
                   
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
                    IF GET-VALUE("LinkRowid") <> "" THEN
                       DO:
                        
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                           
                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              DO:
                                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                         ab_unmap.aux_nrcpfcgc = STRING({&SECOND-ENABLED-TABLE}.nrcpfcgc)
                                         aux_hdcidade = INT({&SECOND-ENABLED-TABLE}.cdcidade).

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


                    FIND FIRST gnapfdp WHERE
                        gnapfdp.cdcooper = 0                          AND
                        gnapfdp.nrcpfcgc = dec(ab_unmap.aux_nrcpfcgc) NO-LOCK NO-ERROR.

                    IF AVAIL gnapfdp THEN
                        IF gnapfdp.inpessoa = 1 THEN
                            ab_unmap.aux_nrcpfcgc = STRING(ab_unmap.aux_nrcpfcgc, "999.999.999-99").
                        ELSE
                            ab_unmap.aux_nrcpfcgc = STRING(ab_unmap.aux_nrcpfcgc, "99.999.999/9999-99").

                    
                    FIND FIRST crapmun WHERE crapmun.cdcidade = {&SECOND-ENABLED-TABLE}.cdcidade  NO-LOCK NO-ERROR. 
                    
                    IF AVAIL crapmun  THEN
                    DO:
                      ASSIGN ab_unmap.aux_dsestado = crapmun.cdestado.
                       RUN CriaListaCidades.
                    END.
                    ELSE 
                      RUN RodaJavaScript("var cidades = new Array();").
                    
                    ASSIGN ab_unmap.aux_hdcidade = STRING(aux_hdcidade).
                    
                    RUN CriaListaEstados.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('FechaZoom()').
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

