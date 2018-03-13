/*****************************************************************************

  Programa wpgd0023a.w

  Alterações: 25/07/2017 - Criaçao da Tela para Eventos Assembleares, fonte 
                           cópia da tela WPGD0019, Prj. 322 (Jean Michel).

*****************************************************************************/

{ sistema/generico/includes/var_log_progrid.i }

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
  FIELD aux_nrseqfea AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U      
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idfernac AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idfermun AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idfimsem AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idvapost AS CHARACTER FORMAT "X(256)":U
  FIELD aux_vercoope AS CHARACTER FORMAT "X(256)":U
  FIELD aux_verregio AS CHARACTER FORMAT "X(256)":U
  FIELD aux_preferna AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_prefermu AS CHARACTER FORMAT "X(256)":U
  FIELD aux_posferna AS CHARACTER FORMAT "X(256)":U
  FIELD aux_posfermu AS CHARACTER FORMAT "X(256)":U
  FIELD aux_semanadi AS CHARACTER FORMAT "X(256)":U
  FIELD aux_semapost AS CHARACTER FORMAT "X(256)":U
  FIELD aux_verfimes AS CHARACTER FORMAT "X(256)":U
  FIELD aux_alteraca AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nmevento AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_cdoperad AS CHARACTER FORMAT "X(256)":U
  FIELD tel_cdoperad AS CHARACTER FORMAT "X(256)":U
  FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nmresage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrmeseve AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_qtparpre AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_motivo   AS CHARACTER        
  FIELD aux_cdlocali AS CHARACTER 
  FIELD aux_idinseve AS CHARACTER
  FIELD aux_dsjustif AS CHARACTER
  FIELD tel_dsdiaeve AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_mesevent AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_dsdiaeve AS LOGICAL
  FIELD aux_idstagen AS CHARACTER FORMAT "X(256)":U
  FIELD aux_pessoapost AS CHARACTER
  FIELD aux_pessoaab AS CHARACTER.

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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0023"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0023a.w"].

DEFINE VARIABLE aux_idstaeve LIKE crapadp.idstaeve NO-UNDO.
DEFINE VARIABLE aux_cor AS CHAR NO-UNDO.
DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER   NO-UNDO.
DEFINE VARIABLE aux_contacop          AS INTEGER   NO-UNDO.
DEFINE VARIABLE aux_contareg          AS INTEGER   NO-UNDO.

DEFINE VARIABLE aux_concopdi          AS INTEGER   NO-UNDO.
DEFINE VARIABLE aux_conregdi          AS INTEGER   NO-UNDO.

DEFINE VARIABLE aux_regiopri          AS INTEGER   NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER NO-UNDO.
DEFINE VARIABLE vr_errfacil           AS CHARACTER NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0030          AS HANDLE NO-UNDO.
DEFINE VARIABLE h-b1wpgd0009          AS HANDLE NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratadp             LIKE crapadp.
/*DEFINE TEMP-TABLE crabadp NO-UNDO     LIKE crapadp.*/
DEFINE TEMP-TABLE cratidp  NO-UNDO    LIKE crapidp.

DEFINE BUFFER crabadp FOR crapadp.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE P:/web/fontes/wpgd0023a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapadp.idstaeve crapadp.qtdiaeve crapadp.qtparpre ~
crapadp.nrseqfea crapadp.cdlocali crapadp.cdcooper crapadp.cdagenci ~
crapadp.dshroeve crapadp.dtfineve crapadp.dtinieve crapadp.nrseqdig ~
crapadp.dsjustif
&Scoped-define ENABLED-TABLES ab_unmap crapadp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapadp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_motivo ~
ab_unmap.aux_nrseqfea ab_unmap.aux_cdlocali ab_unmap.aux_nmresage ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ~
ab_unmap.aux_nmevento ab_unmap.aux_nmpagina ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrmeseve ab_unmap.aux_stdopcao ab_unmap.aux_idinseve ~
ab_unmap.aux_dsjustif ab_unmap.aux_cdoperad ab_unmap.aux_dsdiaeve ~
ab_unmap.aux_idfernac ab_unmap.aux_idfermun ab_unmap.aux_idfimsem ~
ab_unmap.aux_idvapost ab_unmap.aux_preferna ab_unmap.aux_prefermu ~
ab_unmap.aux_posferna ab_unmap.aux_posfermu ab_unmap.aux_vercoope ~
ab_unmap.aux_verregio ab_unmap.aux_pessoapost ab_unmap.aux_pessoaab ~
ab_unmap.aux_cdevento ab_unmap.aux_dtanoage ab_unmap.aux_nrcpfcgc ~
ab_unmap.aux_semanadi ab_unmap.aux_semapost ~
ab_unmap.aux_verfimes ab_unmap.aux_cdcopope ab_unmap.tel_cdoperad ~
ab_unmap.tel_dsdiaeve ab_unmap.aux_mesevent ab_unmap.aux_alteraca ab_unmap.aux_idstagen
&Scoped-Define DISPLAYED-FIELDS crapadp.idstaeve crapadp.qtdiaeve crapadp.qtparpre ~
crapadp.nrseqfea crapadp.cdlocali crapadp.cdcooper crapadp.cdagenci ~
crapadp.dshroeve crapadp.dtfineve crapadp.dtinieve crapadp.nrseqdig ~
crapadp.dsjustif
&Scoped-define DISPLAYED-TABLES ab_unmap crapadp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapadp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_motivo ~
ab_unmap.aux_nrseqfea ab_unmap.aux_cdlocali ab_unmap.aux_nmresage ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ~
ab_unmap.aux_nmevento ab_unmap.aux_nmpagina ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrmeseve ab_unmap.aux_stdopcao ab_unmap.aux_idinseve ~
ab_unmap.aux_dsjustif ab_unmap.aux_cdoperad ab_unmap.aux_dsdiaeve ~
ab_unmap.aux_idfernac ab_unmap.aux_idfermun ab_unmap.aux_idfimsem ~
ab_unmap.aux_idvapost ab_unmap.aux_preferna ab_unmap.aux_prefermu ~
ab_unmap.aux_posferna ab_unmap.aux_posfermu ab_unmap.aux_vercoope ~
ab_unmap.aux_verregio ~
ab_unmap.aux_cdevento ab_unmap.aux_dtanoage ab_unmap.aux_nrcpfcgc ~
ab_unmap.aux_semanadi ab_unmap.aux_semapost ~
ab_unmap.aux_verfimes ab_unmap.aux_cdcopope ab_unmap.tel_cdoperad ~
ab_unmap.tel_dsdiaeve ab_unmap.aux_mesevent ab_unmap.aux_alteraca ~
ab_unmap.aux_idstagen ab_unmap.aux_pessoapost ab_unmap.aux_pessoaab

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_motivo AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     crapadp.idstaeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "->,>>>,>>9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.qtdiaeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.qtparpre AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.tel_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_nrcpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.nrseqfea AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "zzz,zz9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.cdlocali AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "zzz,zz9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqfea AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
	 ab_unmap.aux_dsjustif AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4		  
     ab_unmap.aux_cdlocali AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     crapadp.cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "zz,zz9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmresage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
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
	 ab_unmap.aux_idfernac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_idfermun AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_idfimsem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_idvapost AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1			  
   ab_unmap.aux_vercoope AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1			  
   ab_unmap.aux_verregio AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1			         
   ab_unmap.aux_preferna AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1	
   ab_unmap.aux_prefermu AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_posferna AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1	  
	 ab_unmap.aux_posfermu AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_semanadi AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1			  
   ab_unmap.aux_semapost AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1			  
   ab_unmap.aux_verfimes AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1	
   ab_unmap.aux_alteraca AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1	       
          
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idexclui AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmpagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrmeseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.cdagenci AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_dsdiaeve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     crapadp.dshroeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.dtfineve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   crapadp.nrseqdig AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_cdcopope  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.tel_dsdiaeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_mesevent AT ROW 1 COL 1 NO-LABEL
          FORMAT "X(256)":U 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
          
   ab_unmap.aux_idstagen  AT ROW 1 COL 1 NO-LABEL
          FORMAT "X(256)":U 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
  ab_unmap.aux_pessoapost AT ROW 1 COL 1 NO-LABEL
          FORMAT "X(256)":U 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
  ab_unmap.aux_pessoaab AT ROW 1 COL 1 NO-LABEL
          FORMAT "X(256)":U 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 24.71.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     crapadp.dtinieve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idinseve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 24.71.

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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqfea IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsjustif IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdlocali IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idfernac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idfermun IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idfimsem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idvapost IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */     
/* SETTINGS FOR FILL-IN ab_unmap.aux_vercoope IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_verregio IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */      
/* SETTINGS FOR FILL-IN ab_unmap.aux_preferna IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_prefermu IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_posferna IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_posfermu IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_semanadi IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_semapost IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_verfimes IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idexclui IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR editor ab_unmap.aux_motivo IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdoperad IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.tel_cdoperad IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrcpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmpagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmresage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrmeseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.nrseqfea IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.cdlocali IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsdiaeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.dshroeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.dtfineve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.nrseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.dtinieve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.idstaeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.tel_dsdiaeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_mesevent IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.qtdiaeve IN FRAME Web-Frame
   ALIGN-L                                                              */
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaDescricao w-html 
PROCEDURE carregaDescricao :
DEF VAR aux_meses AS CHAR EXTENT 12 INIT ["JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].

	FIND FIRST crapage WHERE crapage.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper
						 AND crapage.cdagenci = {&SECOND-ENABLED-TABLE}.cdagenci NO-LOCK NO-ERROR.
		
	IF AVAILABLE crapage THEN
    DO:
      ab_unmap.aux_nmresage = crapage.nmresage.
    END.
  ELSE If {&SECOND-ENABLED-TABLE}.cdagenci = 0 THEN
    DO:
      ab_unmap.aux_nmresage = "TODOS".
    END.
		
    ab_unmap.aux_nrmeseve =  aux_meses[{&SECOND-ENABLED-TABLE}.nrmeseve].

  FIND FIRST crapedp WHERE crapedp.idevento = {&SECOND-ENABLED-TABLE}.idevento
                       AND crapedp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper
                       AND crapedp.dtanoage = {&SECOND-ENABLED-TABLE}.dtanoage
                       AND crapedp.cdevento = {&SECOND-ENABLED-TABLE}.cdevento NO-LOCK NO-ERROR.
                       
  IF AVAILABLE crapedp THEN
    DO:
      ASSIGN ab_unmap.aux_nmevento = crapedp.nmevento.
             /*ab_unmap.tel_cdoperad = crapedp.cdoperad.*/
    END.
    
  /* Localiza fornecedor */
  FIND FIRST crapcdp WHERE crapcdp.idevento = {&SECOND-ENABLED-TABLE}.idevento
                       AND crapcdp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper
                       AND crapcdp.cdagenci = {&SECOND-ENABLED-TABLE}.cdagenci
                       AND crapcdp.dtanoage = {&SECOND-ENABLED-TABLE}.dtanoage
                       AND crapcdp.tpcuseve = 1 
                       AND crapcdp.cdevento = {&SECOND-ENABLED-TABLE}.cdevento
                       AND crapcdp.cdcuseve = 1 NO-LOCK NO-ERROR.
        
  /* Busca o facilitador associado a proposta */
  FIND gnfacep WHERE gnfacep.idevento = crapcdp.idevento
                 AND gnfacep.cdcooper = 0
                 AND gnfacep.nrcpfcgc = crapcdp.nrcpfcgc
                 AND gnfacep.nrpropos = crapcdp.nrpropos NO-LOCK NO-ERROR.

  /* Busca o Facilitador */
  FIND gnapfep WHERE gnapfep.nrcpfcgc = gnfacep.nrcpfcgc
                 AND gnapfep.cdfacili = gnfacep.cdfacili NO-LOCK NO-ERROR.

  IF AVAILABLE gnapfep THEN
    DO:
      ASSIGN ab_unmap.aux_nrcpfcgc = STRING(crapcdp.nrcpfcgc).
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaLista w-html 
PROCEDURE CriaLista :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEF VAR aux_crapldp AS CHAR NO-UNDO.
  DEF VAR aux_crapaep AS CHAR NO-UNDO.

  /* Cria as Listas que são mostradas na tela */
      
  /* Lista de Pessoas para Abertura do Evento */
  aux_crapaep = ",0,".
    
  FOR EACH crapfea WHERE crapfea.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper
                     AND crapfea.idsitfea = 1 NO-LOCK
                      BY crapfea.nmfacili:
      ASSIGN aux_crapaep = aux_crapaep + crapfea.nmfacili + "," + STRING(crapfea.nrseqfea) + ",".
END.
                
  ASSIGN aux_crapaep = SUBSTRING(aux_crapaep, 1, LENGTH(aux_crapaep) - 1).

    /* Preenche as listas com os elementos encontrados */
  ASSIGN ab_unmap.aux_nrseqfea:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapaep.
    
  /* Lista de Locais */
  aux_crapldp = ",0,".
      
  FOR EACH crapldp WHERE crapldp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper
                     AND (crapldp.cdagenci = {&SECOND-ENABLED-TABLE}.cdagenci OR {&SECOND-ENABLED-TABLE}.cdagenci = 0)
                     AND crapldp.idloceva = 1 NO-LOCK
                      BY crapldp.dslocali:
      ASSIGN aux_crapldp = aux_crapldp + crapldp.dslocali + "," + STRING(crapldp.nrseqdig) + ",".
  END.

  aux_crapldp = SUBSTRING(aux_crapldp, 1, LENGTH(aux_crapldp) - 1).            
  
  /* Preenche as listas com os elementos encontrados */
  ASSIGN ab_unmap.aux_cdlocali:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapldp.
         
  IF REQUEST_METHOD = "POST" THEN DO: /* manter o valor informado (nao sobrepor com o valor do banco)*/
     ASSIGN ab_unmap.aux_cdlocali:SCREEN-VALUE IN FRAME {&FRAME-NAME} = GET-VALUE("aux_cdlocali")
	        ab_unmap.aux_nrseqfea:SCREEN-VALUE IN FRAME {&FRAME-NAME} = GET-VALUE("aux_nrseqfea"). 
  END.                                 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListahistoricos w-html 
PROCEDURE CriaListahistoricos :

	RUN RodaJavaScript("var mhistorico = new Array();").
	
	FOR EACH craphep WHERE craphep.cdcooper = 0
                     AND craphep.cdagenci = crapadp.nrseqdig NO-LOCK:                        
		
		RUN RodaJavaScript("mhistorico.push(~{dthist:'" + STRING(craphep.dtmvtolt) 
																		 + "',dshist:'" + craphep.dshiseve + "'~});").
		
END.                                    


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :

  RUN readOffsets ("{&WEB-FILE}":U).

  RUN htmAssociate
    ("nrseqfea":U,"crapadp.nrseqfea":U,crapadp.nrseqfea:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"crapadp.cdagenci":U,crapadp.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"crapadp.cdcooper":U,crapadp.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdlocali":U,"crapadp.cdlocali":U,crapadp.cdlocali:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dshroeve":U,"crapadp.dshroeve":U,crapadp.dshroeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtfineve":U,"crapadp.dtfineve":U,crapadp.dtfineve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"crapadp.nrseqdig":U,crapadp.nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtinieve":U,"crapadp.dtinieve":U,crapadp.dtinieve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idstaeve":U,"crapadp.idstaeve":U,crapadp.idstaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtdiaeve":U,"crapadp.qtdiaeve":U,crapadp.qtdiaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc":U,"ab_unmap.aux_nrcpfcgc":U,ab_unmap.aux_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_motivo":U,"ab_unmap.aux_motivo":U,ab_unmap.aux_motivo:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_nrseqfea":U,"ab_unmap.aux_nrseqfea":U,ab_unmap.aux_nrseqfea:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsjustif":U,"crapadp.dsjustif":U,ab_unmap.aux_dsjustif:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdlocali":U,"ab_unmap.aux_cdlocali":U,ab_unmap.aux_cdlocali:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idfernac":U,"ab_unmap.aux_idfernac":U,ab_unmap.aux_idfernac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idfermun":U,"ab_unmap.aux_idfermun":U,ab_unmap.aux_idfermun:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idfimsem":U,"ab_unmap.aux_idfimsem":U,ab_unmap.aux_idfimsem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idvapost":U,"ab_unmap.aux_idvapost":U,ab_unmap.aux_idvapost:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_vercoope":U,"ab_unmap.aux_vercoope":U,ab_unmap.aux_vercoope:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_verregio":U,"ab_unmap.aux_verregio":U,ab_unmap.aux_verregio:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_preferna":U,"ab_unmap.aux_preferna":U,ab_unmap.aux_preferna:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_prefermu":U,"ab_unmap.aux_prefermu":U,ab_unmap.aux_prefermu:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_posferna":U,"ab_unmap.aux_posferna":U,ab_unmap.aux_posferna:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_posfermu":U,"ab_unmap.aux_posfermu":U,ab_unmap.aux_posfermu:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_semanadi":U,"ab_unmap.aux_semanadi":U,ab_unmap.aux_semanadi:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_semapost":U,"ab_unmap.aux_semapost":U,ab_unmap.aux_semapost:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_verfimes":U,"ab_unmap.aux_verfimes":U,ab_unmap.aux_verfimes:HANDLE IN FRAME {&FRAME-NAME}).	
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idexclui":U,"ab_unmap.aux_idexclui":U,ab_unmap.aux_idexclui:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmevento":U,"ab_unmap.aux_nmevento":U,ab_unmap.aux_nmevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("tel_cdoperad":U,"ab_unmap.tel_cdoperad":U,ab_unmap.tel_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmpagina":U,"ab_unmap.aux_nmpagina":U,ab_unmap.aux_nmpagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmresage":U,"ab_unmap.aux_nmresage":U,ab_unmap.aux_nmresage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrmeseve":U,"ab_unmap.aux_nrmeseve":U,ab_unmap.aux_nrmeseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaeve":U,"ab_unmap.aux_dsdiaeve":U,ab_unmap.aux_dsdiaeve:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_idinseve":U,"ab_unmap.aux_idinseve":U,ab_unmap.aux_idinseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("tel_dsdiaeve":U,"ab_unmap.tel_dsdiaeve":U,ab_unmap.tel_dsdiaeve:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_mesevent":U,"ab_unmap.aux_mesevent":U,ab_unmap.aux_mesevent:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_alteraca":U,"ab_unmap.aux_alteraca":U,ab_unmap.aux_alteraca:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idstagen":U,"ab_unmap.aux_idstagen":U,ab_unmap.aux_idstagen:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("qtparpre":U,"crapadp.qtparpre":U,crapadp.qtparpre:HANDLE IN FRAME {&FRAME-NAME}).
	
  RUN htmAssociate
    ("aux_pessoapost":U,"ab_unmap.aux_pessoapost":U,ab_unmap.aux_pessoapost:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_pessoaab":U,"ab_unmap.aux_pessoaab":U,ab_unmap.aux_pessoaab:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record:

DEFINE INPUT PARAMETER opcao AS CHARACTER.

  DEFINE VARIABLE aux_cdcritic AS INTEGER.  
  DEFINE VARIABLE aux_dscritic AS CHARACTER.

  DEFINE VARIABLE aux_dtinieve AS DATE.
  DEFINE VARIABLE aux_dtfineve AS DATE.

  DEFINE VARIABLE aux_qtturant AS INTEGER INIT 0.
  DEFINE VARIABLE aux_contador AS INTEGER INIT 0.

	IF NOT VALID-HANDLE(h-b1wpgd0030) THEN
		DO:
/* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgd0030.p PERSISTENT SET h-b1wpgd0030.
		END.

/* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0030) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:
         IF opcao = "inclusao" THEN
         DO: 
            CREATE cratadp.
            RUN inclui-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
          END.
        ELSE  /* Alteracao */
          DO:

            /* PRJ 322 */
            FIND crapadp WHERE ROWID(crapadp) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-ERROR NO-WAIT.
                  
            IF AVAILABLE crapadp THEN
              ASSIGN aux_qtturant = crapadp.qtparpre
                     aux_dtinieve = crapadp.dtinieve
                     aux_dtfineve = crapadp.dtfineve.
                    
            /* Verifica o Tipo de Evento */
            FIND crapedp WHERE crapedp.idevento = crapadp.idevento
                           AND crapedp.cdcooper = crapadp.cdcooper
                           AND crapedp.cdevento = crapadp.cdevento
                           AND crapedp.dtanoage = crapadp.dtanoage NO-LOCK NO-ERROR NO-WAIT.
                                      
            IF AVAILABLE crapedp THEN
                 DO:  
				IF crapedp.tpevento = 7  OR /* AGO AGE*/
                   crapedp.tpevento = 12 THEN
                     DO:
					/* EMAIL */
                    IF INPUT crapadp.dtinieve <> ? OR INPUT crapadp.dtfineve <> ? THEN  
                      DO:
                        FOR EACH crabadp WHERE (crabadp.dtinieve = INPUT crapadp.dtinieve
                                              OR crabadp.dtfineve = INPUT crapadp.dtfineve)
											 AND crabadp.nrseqdig <> crapadp.nrseqdig
											, EACH crapedp WHERE crapedp.idevento = crabadp.idevento
											                AND crapedp.cdcooper = crabadp.cdcooper
											                AND crapedp.cdevento = crabadp.cdevento
											                AND crapedp.dtanoage = crabadp.dtanoage
															AND (crapedp.tpevento = 7 
															OR crapedp.tpevento = 12) NO-LOCK:
                        /*IF AVAILABLE crabadp THEN
                          DO:*/
							/*FOR FIRST crapedp FIELDS(nmevento) WHERE crapedp.cdevento = crabadp.cdevento NO-LOCK. END.*/
							FOR FIRST crapcop FIELDS(nmrescop) WHERE crapcop.cdcooper = crabadp.cdcooper NO-LOCK. END.
							ASSIGN msg-erro-aux = 4
                                   m-erros      = "O Evento: " + STRING(crapedp.nmevento) + ", da Cooperativa: " + crapcop.nmrescop + ", já foi agendado para esta data. Favor informar outra data para realização deste evento!".
                            RETURN "NOK".
                          /*END.*/
                         END.
                      END.
                         
                  END. /* TIPO DE EVENTO AGO/AGE */
              END. /* IF CRAPEDP AVAILABLE */
            /* PRJ 322 */                     

            /* EMAIL */
    
            ASSIGN aux_contador = 0.
    
            IF INTEGER(GET-VALUE("aux_nrseqfea")) <> 0 THEN
              DO:
                FOR EACH crabadp WHERE crabadp.nrseqfea = INTEGER(GET-VALUE("aux_nrseqfea"))
                                   AND crabadp.dtinieve >= INPUT crapadp.dtinieve
                                   AND crabadp.dtfineve <= INPUT crapadp.dtfineve
                                   AND crabadp.nrseqdig  <> INT(GET-VALUE("aux_nrseqdig")) NO-LOCK:
                  ASSIGN aux_contador = aux_contador + 1.
                END.
                
                IF aux_contador > 0 THEN
                  DO:
					IF GET-VALUE("aux_pessoapost") = "N" THEN
					  DO:
						ASSIGN msg-erro-aux = 23
							   m-erros      = "Pessoa para Abertura já associado a outro(s) evento(s):" + STRING(aux_contador) + " evento(s).".
						RETURN "NOK".
					  END.
                  END.
              END.
                                        
            /* cria a temp-table e joga o novo valor digitado para o campo */
            CREATE cratadp.
            BUFFER-COPY crapadp TO cratadp.
            				   
            ASSIGN aux_idstaeve     = cratadp.idstaeve  
                   cratadp.cdlocali = INTEGER(GET-VALUE("aux_cdlocali"))
                   cratadp.nrseqfea = INTEGER(GET-VALUE("aux_nrseqfea"))
                   cratadp.dtinieve = INPUT crapadp.dtinieve        
                   cratadp.dtfineve = INPUT crapadp.dtfineve         
                   cratadp.dshroeve = INPUT crapadp.dshroeve            
                   cratadp.dsdiaeve = GET-VALUE("aux_dsdiaeve")
                   cratadp.qtdiaeve = INPUT crapadp.qtdiaeve
                   cratadp.idstaeve = INPUT crapadp.idstaeve
                   cratadp.dsjustif = GET-VALUE("aux_dsjustif")
                   cratadp.cdcopope = INT(GET-VALUE("aux_cdcopope"))
                   cratadp.cdoperad = GET-VALUE("aux_cdoperad")
                   cratadp.qtparpre = INPUT crapadp.qtparpre.

            ASSIGN ab_unmap.aux_dsjustif = STRING(cratadp.dsjustif)
                   ab_unmap.aux_cdcopope = STRING(cratadp.cdcopope)
                   ab_unmap.tel_cdoperad = STRING(cratadp.cdoperad)
                   ab_unmap.tel_dsdiaeve = GET-VALUE("aux_dsdiaeve").

            FOR FIRST crapope FIELDS(nmoperad) WHERE crapope.cdcooper = INT(ab_unmap.aux_cdcopope)
                                                 AND crapope.cdoperad = ab_unmap.tel_cdoperad NO-LOCK. END.

            IF AVAILABLE crapope THEN
                 DO:
                ASSIGN ab_unmap.tel_cdoperad = ab_unmap.tel_cdoperad + " - " + crapope.nmoperad.
              END.
            ELSE
                     DO:
                ASSIGN ab_unmap.tel_cdoperad = 'SEM OPERADOR'.
              END.
    
            CASE cratadp.idstaeve :
              WHEN 0  THEN aux_cor = '#FFFF99'.
              WHEN 1  THEN aux_cor = '#FFFF99'.
              WHEN 2  THEN aux_cor = 'tomato'.
              WHEN 3  THEN aux_cor = '#FFFF99'. 
              WHEN 4  THEN aux_cor = '#FFFF99'.
              WHEN 5  THEN aux_cor = '#FFFF99'.
              WHEN 6  THEN aux_cor = '#FFFF99'.
            END CASE.
    
            IF cratadp.idstaeve <> 2 THEN /* verificando se evento está com os dados completos e não cancelado */
              IF cratadp.cdlocali <> 0 AND 
                 cratadp.dtinieve <> ? AND
                 cratadp.dtfineve <> ? AND   
                 cratadp.dshroeve <> "" THEN 
                ASSIGN aux_cor = '#66CC66'.
                 
            RUN altera-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT msg-erro).
    
            IF msg-erro = "" THEN 
              DO:
                IF INPUT crapadp.idstaeve <> aux_idstaeve THEN /* mudança no status do evento  */
                  DO: 
                    IF INPUT crapadp.idstaeve = 2 THEN /* cancelamento */
                      DO: 
                        CREATE craphep.
                        ASSIGN craphep.nrseqdig  = NEXT-VALUE(nrseqhep)
                               craphep.cdagenci  = cratadp.nrseqdig
                               craphep.dshiseve  = "Evento cancelado em " + STRING(TODAY,"99/99/9999") + " pelo usuário " + gnapses.cdoperad + " Motivo : " + INPUT ab_unmap.aux_idexclui
                               craphep.dtmvtolt  = TODAY. 
                         END.
    
                    IF cratadp.idstaeve <> 2 THEN /* Reativando */
                         DO:
                        CREATE craphep.
                        ASSIGN craphep.nrseqdig  = NEXT-VALUE(nrseqhep)
                               craphep.cdagenci  = cratadp.nrseqdig
                               craphep.dshiseve  = "Evento reativado em " + STRING(TODAY,"99/99/9999") + " pelo usuário "  + gnapses.cdoperad + " Motivo : " + INPUT ab_unmap.aux_idexclui
                               craphep.dtmvtolt  = TODAY. 
                      END.
        
                    VALIDATE craphep.
                  END.
              END.
          END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
        
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0030 NO-ERROR.

    END. /* IF VALID-HANDLE(h-b1wpgd0030) */

	{ sistema/ayllos/includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

	RUN STORED-PROCEDURE pc_calc_custo_eve_ass
	  aux_handproc = PROC-HANDLE NO-ERROR (INPUT INT(crapadp.idevento) /* ID do Evento */
										  ,INPUT INT(crapadp.cdcooper) /* Codigo da Cooperativa */
										  ,INPUT INT(crapadp.dtanoage) /* Ano Agenda */
										  ,INPUT INT(crapadp.cdagenci) /* Codigo do PA */
										  ,INPUT INT(crapadp.cdevento) /* Codigo do Evento */
										  ,INPUT INT(crapadp.nrseqdig) /* Codigo do Evento */
										  ,INPUT v-identificacao       /* ID da sessao */
										 ,OUTPUT "").                  /* Descriçao da crítica */
    
	CLOSE STORED-PROC pc_calc_custo_eve_ass
			aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
	{ sistema/ayllos/includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
	ASSIGN aux_dscritic = ""
		   aux_dscritic = pc_calc_custo_eve_ass.pr_dscritic 
						  WHEN pc_calc_custo_eve_ass.pr_dscritic <> ?.
        
	IF (TRIM(aux_dscritic) <> "" AND aux_dscritic <> ?) OR 
	   (aux_cdcritic <> 0 AND aux_cdcritic <> ?) THEN
                         DO:
    
		DO i = 1 TO NUM-ENTRIES(aux_dscritic,"#"):
		  ASSIGN m-erros = m-erros + TRIM(REPLACE(REPLACE(STRING(ENTRY(i,aux_dscritic,"#")),"\"",""),"'","")) + "\\r".	
         END.
                 
		ASSIGN msg-erro-aux = 4.
		RETURN "NOK".
            END.    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
	
	IF NOT VALID-HANDLE(h-b1wpgd0030) THEN
		DO:
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0030.p PERSISTENT SET h-b1wpgd0030.
		END.
		
	IF NOT VALID-HANDLE(h-b1wpgd0009) THEN
		DO:
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
		END.	
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0030) AND
   VALID-HANDLE(h-b1wpgd0009) THEN
   DO:
      CREATE cratadp.
      BUFFER-COPY crapadp TO cratadp.

      /* Exclui os pré-inscritos */
			FOR EACH crapidp WHERE crapidp.idevento = cratadp.idevento
                         AND crapidp.cdcooper = cratadp.cdcooper
                         AND crapidp.dtanoage = cratadp.dtanoage
                         AND crapidp.cdageins = cratadp.cdagenci
                         AND crapidp.cdevento = cratadp.cdevento
                         AND crapidp.nrseqeve = cratadp.nrseqdig NO-LOCK:

          EMPTY TEMP-TABLE cratidp.
			  
          CREATE cratidp.
          BUFFER-COPY crapidp TO cratidp.

          RUN exclui-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT msg-erro).
			END. /* Fim dos pré-inscritos */

      RUN RodaJavaScript("window.opener.mudaCorDiv('" + STRING(ROWID({&SECOND-ENABLED-TABLE})) + "','#000000');").       
          
      RUN exclui-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0030 NO-ERROR.
      DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
   END.

RUN RodaJavaScript("window.close();").

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
PROCEDURE PosicionaNoSeguinte:

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
       ab_unmap.aux_cdlocali    = GET-VALUE("aux_cdlocali")
       ab_unmap.aux_nrseqfea    = GET-VALUE("aux_nrseqfea")
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_cdevento    = GET-VALUE("aux_cdevento")
       ab_unmap.aux_cdcopope    = GET-VALUE("aux_cdcopope")
       ab_unmap.aux_cdoperad    = GET-VALUE("aux_cdoperad")
       ab_unmap.tel_cdoperad    = GET-VALUE("tel_cdoperad")
       ab_unmap.tel_dsdiaeve    = GET-VALUE("aux_dsdiaeve")
       ab_unmap.aux_mesevent    = GET-VALUE("aux_mesevent")
       ab_unmap.aux_alteraca    = GET-VALUE("aux_alteraca")
       ab_unmap.aux_idstagen    = GET-VALUE("aux_idstagen").

RUN outputHeader.

/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      
      RUN inputFields.
      
			ASSIGN msg-erro-aux = 0
             msg-erro = "".			
      
      /* Verifica se data de inicio do evento esta correta */
      IF GET-VALUE("aux_verfimes") = "N" THEN
				DO:  
          FOR FIRST crapadp FIELDS(nrmeseve) WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)
                                               AND crapadp.cdcooper = INT(GET-VALUE("cdcooper"))
                                               AND crapadp.dtanoage = INT(GET-VALUE("aux_dtanoage"))
                                               AND crapadp.cdagenci = INT(GET-VALUE("cdagenci"))
                                               AND crapadp.cdevento = INT(ab_unmap.aux_cdevento)
                                               AND crapadp.nrseqdig = INT(GET-VALUE("aux_nrseqdig")) NO-LOCK. END.
                  
          IF AVAILABLE crapadp THEN
            DO: 
              IF INT(crapadp.nrmeseve) <> INT(SUBSTR(GET-VALUE("dtinieve"),4,2)) THEN
                DO:
                  ASSIGN msg-erro-aux = 22
                         msg-erro = "Mês de início de evento, diferente do informado no cadastro.".
                END.
                 
            END.
            
          RELEASE crapadp.
        END.
      
			/* Verifica se é final de semana */
			IF GET-VALUE("aux_idfimsem") = "N" THEN
				DO:
					IF CAN-DO(GET-VALUE("tel_dsdiaeve"),"6") OR  
					   CAN-DO(GET-VALUE("tel_dsdiaeve"),"0") THEN
						DO:
							ASSIGN msg-erro-aux = 11
								     msg-erro     = "Final de Semana".
						END.
				END.
						
			/* INICIO Verificacao de Feriados Nacionais */
			IF GET-VALUE("aux_idfernac") = "N" THEN
				DO:					
					/* Verificacao de feriado da data inicial/final do evento */
					FOR FIRST crapfer FIELDS(cdcooper) NO-LOCK WHERE crapfer.cdcooper = gnapses.cdcooper
                                                       AND crapfer.dtferiad = DATE(GET-VALUE("dtinieve")):
												
						ASSIGN msg-erro-aux = 12
							   msg-erro = "Feriado Nacional".
					END.

					/* Verificacao de feriado da data final do evento */
					FOR FIRST crapfer FIELDS(cdcooper) NO-LOCK WHERE crapfer.cdcooper = gnapses.cdcooper
																 AND crapfer.dtferiad = DATE(GET-VALUE("dtfineve")): 
												
						ASSIGN msg-erro-aux = 12
							   msg-erro = "Feriado Nacional".	
					END.
				END.
			
			/* INICIO Verificacao de Feriados Municipais */
			IF GET-VALUE("aux_idfermun") = "N" THEN
				DO:        
					/* Consulta de codigo de cidade */
					FOR FIRST crapcop FIELDS(cdbcoctl) WHERE crapcop.cdcooper = gnapses.cdcooper:
						FOR FIRST crapban FIELDS(cdbccxlt) WHERE crapban.cdbccxlt = crapcop.cdbcoctl:
							FOR FIRST crapage FIELDS(cdagepac) WHERE crapage.cdcooper = gnapses.cdcooper
																 AND crapage.cdagenci = INT(GET-VALUE("cdagenci")):
								FOR FIRST crapagb FIELDS(cdcidade) WHERE crapagb.cddbanco = crapban.cdbccxlt
																	 AND crapagb.cdageban = crapage.cdagepac:
								END.						
							END.
						END.				
					END.
                    
					/* Verificacao de feriados municipais pela data de inicio */			
					FOR FIRST crapfsf FIELDS(cdcidade) NO-LOCK WHERE crapfsf.cdcidade = crapagb.cdcidade
                                                       AND crapfsf.dtferiad = DATE(GET-VALUE("dtinieve")):
						ASSIGN msg-erro-aux = 13
							   msg-erro = "Feriado Municipal".
					END.

					/* Verificacao de feriados municipais pela data de fim */
					FOR FIRST crapfsf FIELDS(cdcidade) NO-LOCK WHERE crapfsf.cdcidade = crapagb.cdcidade
                                                       AND crapfsf.dtferiad = DATE(GET-VALUE("dtfineve")):
												
						ASSIGN msg-erro-aux = 13
							   msg-erro = "Feriado Municipal".
					END.
				END.
			
			/* Verifica pre feriado nacional */
			IF GET-VALUE("aux_preferna") = "N" THEN
				DO:
										
					/* Verificacao de feriado da data inicial/final do evento */
					FOR FIRST crapfer FIELDS(cdcooper) NO-LOCK WHERE crapfer.cdcooper = gnapses.cdcooper
                                                       AND crapfer.dtferiad = (DATE(GET-VALUE("dtinieve")) + 1): 
						
						
						ASSIGN msg-erro-aux = 14
							   msg-erro = "Pré Feriado Nacional".
					END.

					/* Verificacao de feriado da data final do evento */
					FOR FIRST crapfer FIELDS(cdcooper) NO-LOCK WHERE crapfer.cdcooper = gnapses.cdcooper
                                                       AND crapfer.dtferiad = (DATE(GET-VALUE("dtfineve")) + 1): 
												
						ASSIGN msg-erro-aux = 14
							   msg-erro = "Pré Feriado Nacional".	
					END.
				END.
			
			/* Verifica pre feriado municipal */
			IF GET-VALUE("aux_prefermu") = "N" THEN
				DO:
					/* Consulta de codigo de cidade */
					FOR FIRST crapcop FIELDS(cdbcoctl) WHERE crapcop.cdcooper = gnapses.cdcooper:
						FOR FIRST crapban FIELDS(cdbccxlt) WHERE crapban.cdbccxlt = crapcop.cdbcoctl:
							FOR FIRST crapage FIELDS(cdagepac) WHERE crapage.cdcooper = gnapses.cdcooper
																 AND crapage.cdagenci = INT(GET-VALUE("cdagenci")):
								FOR FIRST crapagb FIELDS(cdcidade) WHERE crapagb.cddbanco = crapban.cdbccxlt
																	 AND crapagb.cdageban = crapage.cdagepac:
								END.						
							END.
						END.				
					END.

					/* Verificacao de feriados municipais pela data de inicio */			
					FOR FIRST crapfsf FIELDS(cdcidade) NO-LOCK WHERE crapfsf.cdcidade = crapagb.cdcidade
                                                       AND crapfsf.dtferiad = (DATE(GET-VALUE("dtinieve")) + 1):
						ASSIGN msg-erro-aux = 15
							     msg-erro = "Pre Feriado Municipal".
					END.

					/* Verificacao de feriados municipais pela data de fim */
					FOR FIRST crapfsf FIELDS(cdcidade) NO-LOCK WHERE crapfsf.cdcidade = crapagb.cdcidade
                                                       AND crapfsf.dtferiad = (DATE(GET-VALUE("dtfineve")) + 1):
												
						ASSIGN msg-erro-aux = 15
							     msg-erro = "Pre Feriado Municipal".
					END.
				END.
			
			/* Verifica pos feriado nacional */
			IF GET-VALUE("aux_posferna") = "N" THEN
				DO:
					
					/* Verificacao de feriado da data inicial/final do evento */
					FOR FIRST crapfer FIELDS(cdcooper) NO-LOCK WHERE crapfer.cdcooper = gnapses.cdcooper
																 AND crapfer.dtferiad = (DATE(GET-VALUE("dtinieve")) - 1): 
												
						ASSIGN msg-erro-aux = 16
							     msg-erro = "Pos Feriado Nacional".
					END.
					
					/* Verificacao de feriado da data final do evento */
					FOR FIRST crapfer FIELDS(cdcooper) NO-LOCK WHERE crapfer.cdcooper = gnapses.cdcooper
																 AND crapfer.dtferiad = (DATE(GET-VALUE("dtfineve")) - 1): 
																	
						ASSIGN msg-erro-aux = 16
							   msg-erro = "Pos Feriado Nacional".	
					END.
					
				END.
			
			/* Verifica pos feriado municipal */
			IF GET-VALUE("aux_posfermu") = "N" THEN
				DO:
					/* Consulta de codigo de cidade */
					FOR FIRST crapcop FIELDS(cdbcoctl) WHERE crapcop.cdcooper = gnapses.cdcooper:
						FOR FIRST crapban FIELDS(cdbccxlt) WHERE crapban.cdbccxlt = crapcop.cdbcoctl:
							FOR FIRST crapage FIELDS(cdagepac) WHERE crapage.cdcooper = gnapses.cdcooper
																 AND crapage.cdagenci = INT(GET-VALUE("cdagenci")):
								FOR FIRST crapagb FIELDS(cdcidade) WHERE crapagb.cddbanco = crapban.cdbccxlt
																	 AND crapagb.cdageban = crapage.cdagepac:
								END.						
							END.
						END.				
					END.

					/* Verificacao de feriados municipais pela data de inicio */			
					FOR FIRST crapfsf FIELDS(cdcidade) NO-LOCK WHERE crapfsf.cdcidade = crapagb.cdcidade
                                                       AND crapfsf.dtferiad = (DATE(GET-VALUE("dtinieve")) - 1):
						ASSIGN msg-erro-aux = 17
							   msg-erro = "Pos Feriado Municipal".
					END.

					/* Verificacao de feriados municipais pela data de fim */
					FOR FIRST crapfsf FIELDS(cdcidade) NO-LOCK WHERE crapfsf.cdcidade = crapagb.cdcidade
                                                       AND crapfsf.dtferiad = (DATE(GET-VALUE("dtfineve")) - 1):
												
						ASSIGN msg-erro-aux = 17
							     msg-erro = "Pos Feriado Municipal".
					END.
				END.	
			/* FIM Verificacao de Feriados */
			
      /* Verifica se eventos por cooperativa */
      IF GET-VALUE("aux_vercoope") = "N" THEN
				DO: 
          ASSIGN aux_concopdi = 0.
          
          /* Verificar quantidade de eventos permitidos na cooperativa */
          FOR FIRST crapppc FIELDS(qtevedia) NO-LOCK WHERE crapppc.cdcooper = INT(GET-VALUE("cdcooper"))
                                                       AND crapppc.dtanoage = INT(GET-VALUE("aux_dtanoage")). END.
          
          IF AVAILABLE crapppc THEN
            DO:
              ASSIGN aux_concopdi = crapppc.qtevedia.
            END.
          
          ASSIGN aux_contacop = 0.
          
          FOR EACH crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)
                             AND crapadp.cdcooper = INT(GET-VALUE("cdcooper"))
                             AND crapadp.dtanoage = INT(GET-VALUE("aux_dtanoage")) 
                             AND crapadp.dtinieve = DATE(GET-VALUE("dtinieve")) 
                             AND crapadp.nrseqdig <> INT(GET-VALUE("aux_nrseqdig"))  NO-LOCK:
                             
              ASSIGN aux_contacop = aux_contacop + 1.               
              
          END.
          
          IF AVAILABLE crapppc THEN
            DO:
              IF aux_contacop >= crapppc.qtevedia THEN
                DO:
				  IF GET-VALUE("dtinieve") <> ? AND GET-VALUE("dtinieve") <> "" AND GET-VALUE("dtinieve") <> "/  /" THEN
				    DO:	
					  /* Verifica o Tipo de Evento */
				      FIND crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento)
						  		     AND crapedp.cdcooper = INT(GET-VALUE("cdcooper"))
									 AND crapedp.cdevento = INT(ab_unmap.aux_cdevento)
									 AND crapedp.dtanoage = INT(GET-VALUE("aux_dtanoage"))  NO-LOCK NO-ERROR NO-WAIT.
												  
					  
					  IF crapedp.tpevento = 7  OR /* AGO AGE*/
						 crapedp.tpevento = 12 THEN
						DO:
						  ASSIGN msg-erro-aux = 4
								 m-erros = "A cooperativa já possui (" + STRING(aux_contacop) + ") evento(s) nesta data.".
						END.
					  ELSE
					    DO:
						  /* Verificar quantidade de eventos ja cadastrados na cooperativa */
						  ASSIGN msg-erro-aux = 18.
					    END.
					END.
                END.          
            END.
        END.
      
      /* Verifica se eventos por regional */
      IF GET-VALUE("aux_verregio") = "N" THEN
				DO:
          ASSIGN aux_contareg = 0
                 aux_regiopri = 0
                 aux_conregdi = 0.
              
          FOR FIRST crabadp FIELDS(cdagenci) WHERE crabadp.cdcooper = INT(GET-VALUE("cdcooper"))
                                               AND crabadp.nrseqdig = INT(GET-VALUE("aux_nrseqdig")). END.
                                               
          FOR FIRST crapage FIELDS(cddregio) WHERE crapage.cdcooper = INT(GET-VALUE("cdcooper"))
                                               AND crapage.cdagenci = crabadp.cdagenci NO-LOCK. END.
          
          IF AVAILABLE crapage THEN
            ASSIGN aux_regiopri = crapage.cddregio.
          
          FOR EACH crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)
                             AND crapadp.cdcooper = INT(GET-VALUE("cdcooper"))
                             AND crapadp.dtanoage = INT(GET-VALUE("aux_dtanoage"))
                             AND crapadp.dtinieve = DATE(GET-VALUE("dtinieve")) NO-LOCK:
              
              FOR FIRST crapage FIELDS(cddregio) WHERE crapage.cdcooper = crapadp.cdcooper
                                                   AND crapage.cdagenci = crapadp.cdagenci NO-LOCK. END.
                    
              IF AVAILABLE crapage THEN
                DO:
                  IF aux_regiopri = crapage.cddregio AND crapage.cddregio <> 0 THEN
                    DO:
                      ASSIGN aux_contareg = aux_contareg + 1.
                    END.
                END.
          END.          
                    
          /* Verificar quantidade de eventos permitidos na regional */
          FOR FIRST crapppr FIELDS(qtevedia) NO-LOCK WHERE crapppr.cdcooper = INT(GET-VALUE("cdcooper"))
                                                       AND crapppr.cddregio = aux_regiopri
                                                       AND crapppr.dtanoage = INT(GET-VALUE("aux_dtanoage")). END.
          
          /* FAZER LEITURA DA ADP E AGE PRA VERIFICAR AS REGIONAIS */                                             
          IF AVAILABLE crapppr THEN
            DO:
              ASSIGN aux_conregdi = crapppr.qtevedia.
              
              IF aux_contareg >= crapppr.qtevedia THEN
                DO:
                  /* Verificar quantidade de eventos ja cadastrados na cooperativa */
                  ASSIGN msg-erro-aux = 19
                         msg-erro = "Quantidade de eventos por regional ultrapassado. Já existem " + STRING(aux_contareg) + " eventos cadastrados.".
                END. 
            END.
        END.
      
      /*Verifica semana de inicio diferente da semana de termino */
      IF GET-VALUE("aux_semanadi") = "S" AND
         GET-VALUE("aux_semapost") = "N"  THEN
				DO:
          ASSIGN msg-erro-aux = 21
							   msg-erro = "Semana de inicio de evento diferente da semana final.".
        END.
        
			/* Se BO foi instanciada */
			IF NOT VALID-HANDLE(h-b1wpgd0030) THEN
				DO:
      /* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgd0030.p PERSISTENT SET h-b1wpgd0030.

            RUN posiciona-registro IN h-b1wpgd0030(INPUT TO-ROWID(ab_unmap.aux_nrdrowid), OUTPUT msg-erro).
            DELETE PROCEDURE h-b1wpgd0030 NO-ERROR.
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
                              ASSIGN msg-erro-aux = 10
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
										IF NOT CAN-DO(STRING(msg-erro-aux),"11")
											AND NOT CAN-DO(STRING(msg-erro-aux),"12")
											AND NOT CAN-DO(STRING(msg-erro-aux),"13")
											AND NOT CAN-DO(STRING(msg-erro-aux),"14")
											AND NOT CAN-DO(STRING(msg-erro-aux),"15")
											AND NOT CAN-DO(STRING(msg-erro-aux),"16")
											AND NOT CAN-DO(STRING(msg-erro-aux),"17")
                      AND NOT CAN-DO(STRING(msg-erro-aux),"18")
                      AND NOT CAN-DO(STRING(msg-erro-aux),"19")
                      AND NOT CAN-DO(STRING(msg-erro-aux),"20")
                      AND NOT CAN-DO(STRING(msg-erro-aux),"21")
                      AND NOT CAN-DO(STRING(msg-erro-aux),"22")THEN											
											DO:
                                  IF msg-erro = "" THEN
                          DO:
                                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                            RUN local-assign-record ("alteracao").  
                          END.
                                  ELSE
                          DO:
                                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                               END.     
											END.
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

       RUN CriaLista.   
       RUN CriaListaHistoricos.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN DO:
          RUN carregaDescricao.
         RUN displayFields.
      END.
 
      RUN enableFields.
      RUN outputFields.
      RUN RodaJavaScript("window.opener.mudaCorDiv('" + STRING(ROWID({&SECOND-ENABLED-TABLE})) + "','" + aux_cor + "');"). 
      RUN RodaJavaScript('preencheDiaSalvo("' + GET-VALUE("aux_dsdiaeve") + '");').
      /*RUN RodaJavaScript("diasEvento();"). */



      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' alert("' + v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" alert('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript(' alert("' + TRIM(v-descricaoerro) + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript(' alert("' + TRIM(v-descricaoerro) + '"); ').
                END.

           WHEN 10 THEN
					RUN RodaJavaScript('alert("Atualização executada com sucesso.")').
				WHEN 11 THEN
					DO:
						RUN RodaJavaScript('var conf = confirm("Data do evento contém dias no fim de semana, desejar confirmar?");').
						RUN RodaJavaScript('((!conf) ? document.form.aux_idfimsem.value = "N" : document.form.aux_idfimsem.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.
				WHEN 12 THEN
					DO:
						RUN RodaJavaScript('var conf = confirm("Data do evento é feriado nacional, confirma inclusão?");').
						RUN RodaJavaScript('((!conf) ? document.form.aux_idfernac.value = "N" : document.form.aux_idfernac.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.
				WHEN 13 THEN
					DO:
						RUN RodaJavaScript('var conf = confirm("Data do evento é feriado municipal, confirma inclusão?");'). 
						RUN RodaJavaScript('((!conf) ? document.form.aux_idfermun.value = "N" : document.form.aux_idfermun.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.	
				WHEN 14 THEN
					DO:
						RUN RodaJavaScript('var conf = confirm("Data do evento antecede um feriado nacional, confirma inclusão?");'). 
						RUN RodaJavaScript('((!conf) ? document.form.aux_preferna.value = "N" : document.form.aux_preferna.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.	
				WHEN 15 THEN
					DO:
						RUN RodaJavaScript('var conf = confirm("Data do evento antecede um feriado municipal, confirma inclusão?");'). 
						RUN RodaJavaScript('((!conf) ? document.form.aux_prefermu.value = "N" : document.form.aux_prefermu.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.
				WHEN 16 THEN
					DO:
						RUN RodaJavaScript('var conf = confirm("Data do evento posterior a um feriado nacional, confirma inclusão?");'). 
						RUN RodaJavaScript('((!conf) ? document.form.aux_posferna.value = "N" : document.form.aux_posferna.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.	
				WHEN 17 THEN
					DO:
						RUN RodaJavaScript('var conf = confirm("Data do evento posterior a um feriado municipal, confirma inclusão?");'). 
						RUN RodaJavaScript('((!conf) ? document.form.aux_posfermu.value = "N" : document.form.aux_posfermu.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.
        WHEN 18 THEN 
					DO:
						RUN RodaJavaScript('var conf = confirm("A cooperativa já possui (' + STRING(aux_contacop) + ') eventos nesta data. Deseja confirmar?");'). 
						RUN RodaJavaScript('((!conf) ? document.form.aux_vercoope.value = "N" : document.form.aux_vercoope.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END. 
        WHEN 19 THEN
					DO: 
						RUN RodaJavaScript('var conf = confirm("A regional já possui (' + STRING(aux_contareg) + ') eventos nesta data. Deseja confirmar?");'). 
						RUN RodaJavaScript('((!conf) ? document.form.aux_verregio.value = "N" : document.form.aux_verregio.value = "S")').
						RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
					END.  
        WHEN 21 THEN
			DO:
				RUN RodaJavaScript('var conf = confirm("Semana de início de evento diferente da semana final. Deseja continuar?");'). 
				RUN RodaJavaScript('((!conf) ? document.form.aux_semanadi.value = "N" : document.form.aux_semanadi.value = "S")').
				RUN RodaJavaScript('document.form.aux_semapost.value = "S";').
				RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
			END.
        WHEN 22 THEN
			DO:
				RUN RodaJavaScript('alert("Mês de início de evento, diferente do informado no cadastro.");'). 
				RUN RodaJavaScript('document.form.aux_verfimes.value = "N";').
				RUN RodaJavaScript('limpaDados();').
			END.
		WHEN 23 THEN
           DO:
				RUN RodaJavaScript('var conf = confirm("' + m-erros + '. Deseja continuar?");'). 
				RUN RodaJavaScript('((!conf) ? document.form.aux_pessoaab.value = "N" : document.form.aux_pessoaab.value = "S")').
				RUN RodaJavaScript('document.form.aux_pessoapost.value = "S";').
				RUN RodaJavaScript('((!conf) ? limpaDados() : document.getElementById("form").submit())').
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
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-ERROR.
                           
                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              DO:
										IF INT(GET-VALUE("mes")) <> {&SECOND-ENABLED-TABLE}.nrmeseve THEN
											DO:
                                      ASSIGN {&SECOND-ENABLED-TABLE}.nrmeseve = INT(GET-VALUE("mes"))
                                             {&SECOND-ENABLED-TABLE}.nrseqfea = 0
                                             {&SECOND-ENABLED-TABLE}.cdlocali = 0
                                             {&SECOND-ENABLED-TABLE}.dtinieve = ?
                                             {&SECOND-ENABLED-TABLE}.dtfineve = ?
                                             {&SECOND-ENABLED-TABLE}.dshroeve = ""
                                             {&SECOND-ENABLED-TABLE}.dsdiaeve = ""
                                             {&SECOND-ENABLED-TABLE}.qtdiaeve = 0
                                             {&SECOND-ENABLED-TABLE}.nrseqdig = 0
                                             {&SECOND-ENABLED-TABLE}.qtparpre = 0.
											END.
										
                    IF ({&SECOND-ENABLED-TABLE}.cdcopope) <> 0 THEN DO:
                        ab_unmap.aux_cdcopope = STRING({&SECOND-ENABLED-TABLE}.cdcopope).
                                  END.
										
                                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                         ab_unmap.aux_nrseqfea = STRING({&SECOND-ENABLED-TABLE}.nrseqfea)
                                         ab_unmap.aux_cdlocali = STRING({&SECOND-ENABLED-TABLE}.cdlocali)
                                         ab_unmap.aux_dsjustif = STRING({&SECOND-ENABLED-TABLE}.dsjustif)
                                         ab_unmap.aux_cdcopope = STRING(ab_unmap.aux_cdcopope) 
                                         ab_unmap.tel_cdoperad = STRING({&SECOND-ENABLED-TABLE}.cdoperad)
                                         ab_unmap.tel_dsdiaeve = STRING({&SECOND-ENABLED-TABLE}.dsdiaeve).
  
                    FOR FIRST crapope FIELDS(nmoperad) WHERE crapope.cdcooper = INT(ab_unmap.aux_cdcopope)
                                                         AND crapope.cdoperad = ab_unmap.tel_cdoperad NO-LOCK. END.

                    IF AVAILABLE crapope THEN
                      DO:
                        ASSIGN ab_unmap.tel_cdoperad = ab_unmap.tel_cdoperad + " - " + crapope.nmoperad.
                      END.
                                  /* Verifica se existe algum inscrito no evento com status "pendente" ou "confirmado" */
										IF CAN-FIND(FIRST crapidp WHERE crapidp.idevento = {&SECOND-ENABLED-TABLE}.idevento
                                                AND crapidp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper
                                                AND crapidp.dtanoage = {&SECOND-ENABLED-TABLE}.dtanoage
                                                AND crapidp.cdageins = {&SECOND-ENABLED-TABLE}.cdagenci
                                                AND crapidp.cdevento = {&SECOND-ENABLED-TABLE}.cdevento
                                                AND crapidp.nrseqeve = {&SECOND-ENABLED-TABLE}.nrseqdig
                                                AND (crapidp.idstains = 1  /*Pendente*/
                                                 OR  crapidp.idstains = 2) /*Confirmado*/ NO-LOCK) THEN
                                       ab_unmap.aux_idinseve = "yes".
                                  ELSE
                                       ab_unmap.aux_idinseve = "no".

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

            FIND FIRST crabadp WHERE crabadp.idevento = {&SECOND-ENABLED-TABLE}.idevento
                                 AND crabadp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper
                                 AND crabadp.dtanoage = {&SECOND-ENABLED-TABLE}.dtanoage
                                 AND crabadp.cdevento = {&SECOND-ENABLED-TABLE}.cdevento
                                 AND crabadp.nrseqdig = {&SECOND-ENABLED-TABLE}.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
                  
            IF AVAILABLE crabadp THEN
              DO:    
                ASSIGN ab_unmap.aux_mesevent =  STRING('01/' + STRING(crabadp.nrmeseve,'99') + '/' + STRING(crabadp.dtanoage,'9999')).
              END.
            ELSE
              DO:    
                ASSIGN ab_unmap.aux_mesevent = STRING(TODAY).
              END.  

                    RUN CriaListaHistoricos.
                    RUN CriaLista.   
                    RUN carregaDescricao.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('LimparCampos();').
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
PROCEDURE RodaJavaScript:
{includes/rodajava.i}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
