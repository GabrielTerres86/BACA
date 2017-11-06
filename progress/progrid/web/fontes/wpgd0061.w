/*............................................................................................................
  Altera��es: 28/07/2017 - Cria�ao da tela, Prj. 322. (Jean Michel)													
............................................................................................................*/

{ sistema/generico/includes/var_log_progrid.i }

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
  FIELD aux_cdagenci AS CHARACTER 
  FIELD aux_cdcooper AS CHARACTER 
  FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_cdgraupr AS CHARACTER 
  FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_flgcompr AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_flgrest  AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idstaeve AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_lscoment AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_lsfaleve AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_lsconfir AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_lsseqdig AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nminseve AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrconfir AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrcompar AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_excrowid AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrinscri AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nrseqeve AS CHARACTER 
  FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_tpinseve AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_tppartic AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_idademin AS CHARACTER FORMAT "X(256)":U 
  FIELD aux_nmcooper AS CHARACTER FORMAT "X(256)":U 
  FIELD nmresage     AS CHARACTER
  FIELD origem       AS CHARACTER FORMAT "X(256)":U 
  FIELD pagina       AS CHARACTER FORMAT "X(256)":U 
  FIELD cdageins     AS CHARACTER 
  FIELD nrseqeve     AS CHARACTER 
  FIELD aux_carregar AS CHARACTER
  FIELD aux_reginils AS CHARACTER
  FIELD aux_regfimls AS CHARACTER
  FIELD aba          AS CHARACTER
  FIELD aux_flgalter AS CHARACTER
  FIELD aux_flginscr AS CHARACTER
  FIELD aux_dsinscri AS CHARACTER FORMAT "X(2000)":U
  FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
  FIELD aux_nminscri AS CHARACTER FORMAT "X(256)":U
  FIELD aux_tpfiltro AS CHARACTER
  FIELD aux_nrcpfcgc AS CHARACTER
  FIELD aux_nrcpfcgc_fil AS CHARACTER
  FIELD aux_nrdconta_cpfcgc AS CHARACTER
  FIELD aux_pesqorde AS CHARACTER
  FIELD aux_nriniseq AS CHARACTER
  FIELD aux_qtdregis AS CHARACTER
  FIELD aux_nrficpre AS CHARACTER
  FIELD aux_indicdiv AS CHARACTER
  FIELD aux_dsurlphp AS CHARACTER
  FIELD aux_idcookie AS CHARACTER
  FIELD aux_cdoperad AS CHARACTER
  FIELD aux_indficin AS CHARACTER
	FIELD aux_encerrar AS CHARACTER.

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE tt-status
  FIELD cdstatus AS INTEGER
  FIELD dsstatus AS CHARACTER.
  
/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE tt-inscritos
  FIELD nminseve AS CHARACTER
  FIELD nmextttl AS CHARACTER
  FIELD idseqttl AS CHARACTER 
  FIELD nrdconta AS CHARACTER
  FIELD nrdddins AS CHARACTER 
  FIELD nrtelins AS CHARACTER 
  FIELD dsobsins AS CHARACTER 
  FIELD nrficpre AS CHARACTER 
  FIELD cdagenci AS CHARACTER 
  FIELD cdageins AS CHARACTER
  FIELD cdcooper AS CHARACTER
  FIELD cdevento AS CHARACTER
  FIELD nrseqdig AS CHARACTER 
  FIELD nrseqeve AS CHARACTER
  FIELD dtconins AS CHARACTER 
  FIELD cdgraupr AS CHARACTER 
  FIELD nmresage AS CHARACTER 
  FIELD idstains AS CHARACTER 
  FIELD nrdrowid AS CHARACTER
  FIELD prgrecid AS CHARACTER
  FIELD dtpreins AS CHARACTER 
  FIELD qtfaleve AS CHARACTER 
  FIELD flginsin AS CHARACTER.
  
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0061"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0061.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER             NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER           NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER             NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER           NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER           NO-UNDO.

/*** Declara�ao de BOs ***/
DEFINE VARIABLE h-b1wpgd0061          AS HANDLE              NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratidp             LIKE crapidp.

DEFINE VARIABLE vetorpac              AS CHAR                NO-UNDO.
DEFINE VARIABLE vetorinscri           AS CHAR                NO-UNDO.
DEFINE VARIABLE aux_dadoseve          AS CHAR                NO-UNDO.

DEFINE VARIABLE aux_crapcop           AS CHAR                NO-UNDO.
DEFINE VARIABLE aux_contador          AS INT                 NO-UNDO.
DEFINE VARIABLE aux_nrdconta          AS INT                 NO-UNDO.
DEFINE VARIABLE aux_idseqttl          AS INT                 NO-UNDO.
DEFINE VARIABLE aux_idstains          LIKE crapidp.idstains  NO-UNDO.
DEFINE VARIABLE aux_cdevento          LIKE crapadp.cdevento  NO-UNDO.

DEFINE BUFFER crabidp FOR crapidp.
DEFINE BUFFER crabedp FOR crapedp.   
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0061.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapidp.cdcooper crapidp.cdgraupr ~
crapidp.dsdemail crapidp.flgdispe ~
crapidp.idseqttl crapidp.nminseve crapidp.nrdconta crapidp.nrdddins ~
crapidp.nrtelins crapidp.tpinseve crapidp.dsobsins crapidp.nrficpre
&Scoped-define ENABLED-TABLES ab_unmap crapidp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapidp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_nminseve ~
ab_unmap.aux_tpinseve ab_unmap.aux_nrseqeve ab_unmap.aux_nrconfir ab_unmap.aux_nrcompar ~
ab_unmap.aux_nrinscri ab_unmap.aux_flgcompr ab_unmap.aux_flgrest ab_unmap.aux_qtmaxtur ~
ab_unmap.aux_idstaeve ab_unmap.origem ab_unmap.aux_cdagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_cdgraupr ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ~
ab_unmap.aux_idevento ab_unmap.aux_lscoment ab_unmap.aux_lsconfir ab_unmap.aux_lsfaleve ~
ab_unmap.aux_lspermis ab_unmap.aux_lsseqdig ab_unmap.aux_nrdrowid ab_unmap.aux_excrowid ~
ab_unmap.aux_stdopcao ab_unmap.aux_tppartic ab_unmap.aux_nmcooper ab_unmap.aux_nrdconta_cpfcgc ~
ab_unmap.nmresage     ab_unmap.pagina       ab_unmap.cdageins ~
ab_unmap.nrseqeve     ab_unmap.aux_carregar ab_unmap.aux_reginils ~
ab_unmap.aux_regfimls ab_unmap.aba          ab_unmap.aux_flgalter ~
ab_unmap.aux_flginscr ab_unmap.aux_dsinscri ab_unmap.aux_idademin ~
ab_unmap.aux_fechamen ab_unmap.aux_nminscri ab_unmap.aux_tpfiltro ~
ab_unmap.aux_nrcpfcgc ab_unmap.aux_nrcpfcgc_fil ab_unmap.aux_nrficpre ~
ab_unmap.aux_pesqorde ab_unmap.aux_nriniseq ab_unmap.aux_qtdregis ~
ab_unmap.aux_indicdiv ab_unmap.aux_dsurlphp ab_unmap.aux_idcookie ~
ab_unmap.aux_cdoperad ab_unmap.aux_indficin ab_unmap.aux_encerrar
&Scoped-Define DISPLAYED-FIELDS crapidp.cdcooper crapidp.cdgraupr ~
crapidp.dsdemail crapidp.flgdispe ~
crapidp.idseqttl crapidp.nminseve crapidp.nrdconta crapidp.nrdddins ~
crapidp.nrtelins crapidp.tpinseve crapidp.dsobsins crapidp.nrficpre
&Scoped-define DISPLAYED-TABLES ab_unmap crapidp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapidp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_nminseve ~
ab_unmap.aux_tpinseve ab_unmap.aux_nrseqeve ~
ab_unmap.aux_nrconfir ab_unmap.aux_nrinscri ab_unmap.aux_flgcompr ab_unmap.aux_flgrest ~
ab_unmap.aux_nrcompar ab_unmap.aux_qtmaxtur ab_unmap.aux_idstaeve ab_unmap.origem ~
ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ~
ab_unmap.aux_cdgraupr ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lscoment ab_unmap.aux_lsfaleve ~
ab_unmap.aux_lsconfir ab_unmap.aux_lspermis ab_unmap.aux_lsseqdig ~
ab_unmap.aux_nrdrowid ab_unmap.aux_excrowid ab_unmap.aux_stdopcao ab_unmap.aux_tppartic ~
ab_unmap.aux_nmcooper ab_unmap.aux_nrdconta_cpfcgc ab_unmap.nmresage ab_unmap.pagina ~
ab_unmap.cdageins     ab_unmap.nrseqeve     ab_unmap.aux_carregar ~
ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aba ~
ab_unmap.aux_flgalter ab_unmap.aux_flginscr ab_unmap.aux_dsinscri ~
ab_unmap.aux_idademin ab_unmap.aux_fechamen ab_unmap.aux_nminscri ~
ab_unmap.aux_tpfiltro ab_unmap.aux_nrcpfcgc ab_unmap.aux_nrcpfcgc_fil ~
ab_unmap.aux_pesqorde ab_unmap.aux_nriniseq ab_unmap.aux_nrficpre ~
ab_unmap.aux_qtdregis ab_unmap.aux_indicdiv ab_unmap.aux_dsurlphp ~
ab_unmap.aux_idcookie ab_unmap.aux_cdoperad ab_unmap.aux_indficin ~
ab_unmap.aux_encerrar

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

DEFINE FRAME Web-Frame
     crapidp.dsobsins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.nrficpre AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nminseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_tpinseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.nrseqeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrconfir AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrcompar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrinscri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgcompr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_flgrest AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtmaxtur AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idstaeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.origem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
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
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdgraupr AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
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
     ab_unmap.aux_nrcpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1            
     ab_unmap.aux_nrcpfcgc_fil AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lscoment AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsfaleve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1   
     ab_unmap.aux_lsconfir AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsseqdig AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_excrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrficpre AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_indicdiv AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_pesqorde AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4  
     ab_unmap.aux_dsurlphp AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idcookie AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_indficin AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 57.2 BY 15.19.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up */
DEFINE FRAME Web-Frame
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_tppartic AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_idademin AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	  ab_unmap.aux_fechamen AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_tpfiltro  AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
    ab_unmap.aux_nminscri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdageins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nriniseq AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtdregis AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     crapidp.cdcooper AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.cdgraupr AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.dsdemail AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.flgdispe AT ROW 1 COL 1
          LABEL "Dispensa Confirmacao"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1 
     crapidp.idseqttl AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_nrdconta_cpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4    
     crapidp.nminseve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nmresage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.nrdconta AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.nrdddins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.nrtelins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.pagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.tpinseve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "tpinseve 2", 2, "tpinseve 1", 1
          SIZE 20 BY 3
     ab_unmap.aux_carregar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_reginils AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_regfimls AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aba AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgalter AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_flginscr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dsinscri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(2000)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
		ab_unmap.aux_encerrar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(2000)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 57.2 BY 15.19.

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
          FIELD aux_cdgraupr AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_flgcompr AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_flgrest  AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idstaeve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lscoment AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsconfir AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsseqdig AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nminseve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrconfir AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrinscri AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrseqeve AS CHARACTER 
          FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_tpinseve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idademin AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_tppartic AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmcooper AS CHARACTER
          FIELD nmresage AS CHARACTER FORMAT "X(256)":U 
          FIELD origem AS CHARACTER FORMAT "X(256)":U 
          FIELD pagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
          FIELD aux_nminscri AS CHARACTER FORMAT "X(256)":U
          FIELD aux_tpfiltro AS CHARACTER
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 15.19
         WIDTH              = 57.2.
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdgraupr IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_flgcompr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_flgrest IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idstaeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lscoment IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsconfir IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nminseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrconfir IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrinscri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqeve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_qtmaxtur IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_tpinseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_tppartic IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idademin IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_fechamen IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_tpfiltro IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nminscri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapidp.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.cdgraupr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.dsdemail IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR TOGGLE-BOX crapidp.flgdispe IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN crapidp.idseqttl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nmcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN crapidp.nminseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.nmresage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapidp.nrdconta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.nrdddins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.nrseqeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.nrtelins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.origem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.pagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR RADIO-SET crapidp.tpinseve IN FRAME Web-Frame
   EXP-LABEL                                                            */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AtualizaConfirm w-html 
PROCEDURE AtualizaConfirm :

  DEF VAR i              AS INT        NO-UNDO.
  DEF VAR aux_msg-erro   AS CHAR       NO-UNDO.

  DEF BUFFER bf1-crapidp FOR crapidp.
   
  /* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0061.p PERSISTENT SET h-b1wpgd0061.
     
  /* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0061) THEN
    DO:
      /* Encontra o codigo do evento */
      FIND crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                         NO-LOCK NO-ERROR.

      DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsseqdig): 

        /* se campo dispensar confirmacao tiver checkado, status sera confirmado */
        IF INPUT FRAME {&frame-name} crapidp.flgdispe THEN
          ASSIGN aux_idstains = 2. /* confirmado */
        ELSE
          ASSIGN aux_idstains = 1. /* pendente */ 

        /* se evento estiver encerrado e nao tiver sido realizado a inscri�ao sera pendente */
        IF  crapadp.idstaeve = 4 AND crapadp.dtfineve > TODAY THEN
          ASSIGN aux_idstains = 1. /* pendente */ 
                
        FIND bf1-crapidp WHERE bf1-crapidp.idevento = INT(ab_unmap.aux_idevento)
                           AND bf1-crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                           AND bf1-crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           AND bf1-crapidp.cdageins = INT(ab_unmap.cdageins)    
                           AND bf1-crapidp.cdevento = crapadp.cdevento          
                           AND bf1-crapidp.nrseqeve = INT(ab_unmap.nrseqeve)    
                           AND bf1-crapidp.nrseqdig = INT(ENTRY(i, ab_unmap.aux_lsseqdig)) NO-LOCK NO-ERROR.
          
        IF AVAILABLE bf1-crapidp THEN
          DO:
            FOR EACH cratidp EXCLUSIVE-LOCK:
              DELETE cratidp NO-ERROR.
            END.
          
            CREATE cratidp.
            BUFFER-COPY bf1-crapidp TO cratidp.
          
            ASSIGN cratidp.dsobsins = ENTRY(i, ab_unmap.aux_lscoment, "�")
                   cratidp.qtfaleve = INT(ENTRY(i, ab_unmap.aux_lsfaleve, "�"))
                   cratidp.idstains = INT(ENTRY(i, ab_unmap.aux_lsconfir)) 
                   cratidp.dtaltera = TODAY
                   cratidp.cdopinsc = gnapses.cdoperad.
                   
				   
            /* Grava data de confirma�ao somente se for 2 - Confirmacao */
            IF  cratidp.idstains = 2 THEN
              DO:
                /* Caso a situacao selecionada for igual a anterior nao deve atualizar os registros */
                IF INT(ENTRY(i, ab_unmap.aux_lsconfir)) <> bf1-crapidp.idstains THEN
                  DO:
                    ASSIGN cratidp.dtconins = TODAY.

                    FIND FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento            
                                         AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  
                                         AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                                         AND crapedp.idevento = INT(ab_unmap.aux_idevento) NO-LOCK NO-ERROR.
                                         
                    IF crapedp.tpevento = 7 OR crapedp.tpevento = 12 THEN
                      DO:
                        RUN verificaFichaPresenca(INPUT INT(ab_unmap.aux_idevento)
                                                 ,INPUT INT(ab_unmap.aux_cdcooper)
                                                 ,INPUT INT(ab_unmap.aux_dtanoage)
                                                 ,INPUT INT(ab_unmap.cdageins)
                                                 ,INPUT crapadp.cdevento
                                                 ,INPUT INT(ab_unmap.nrseqeve)
                                                 ,INPUT IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre)).
                                                        
                        IF RETURN-VALUE = "NOK" THEN
                          DO:
                            RETURN "NOK".
                          END.
                        
                        ASSIGN cratidp.nrficpre = IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre).
                      END.
                  END.
              END.
            ELSE
              DO:
                IF cratidp.idstains = 1 THEN
                  ASSIGN cratidp.dtconins = ?
												 cratidp.nrficpre = ?.
              END.
          
            RUN altera-registro IN h-b1wpgd0061(INPUT TABLE cratidp, OUTPUT aux_msg-erro).
      
            ASSIGN msg-erro = msg-erro + aux_msg-erro.
          END. /* IF AVAILABLE bf1-crapidp */
      END. /* DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsseqdig) */
    
      /* "mata" a inst�ncia da BO */
      DELETE PROCEDURE h-b1wpgd0061 NO-ERROR.

    END.
		
		IF msg-erro <> ? AND msg-erro = "" THEN
			RETURN "NOK".
		ELSE
			RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos:

    DEFINE VARIABLE aux_tppartic AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_idademin AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgcompr AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgrest  AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_qtmaxtur AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrinscri AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrconfir AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrfaltan AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrcompar AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrdturma AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
    DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
           INITIAL ["Janeiro","Fevereiro","Mar�o","Abril","Maio","Junho",
                    "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
    DEFINE VARIABLE aux_fechamen AS CHAR NO-UNDO.
                
    DEFINE VARIABLE aux_idstaeve AS INTEGER NO-UNDO.       
    
    DEF VAR cont AS INTE NO-UNDO.

    DEFINE BUFFER bf-crapidp FOR crapidp.

    FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                            gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                            gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

    FIND FIRST craptab WHERE craptab.cdcooper = 0              AND
                             craptab.nmsistem = "CRED"         AND
                             craptab.tptabela = "CONFIG"       AND
                             craptab.cdempres = 0              AND
                             craptab.cdacesso = "PGTPPARTIC"   AND
                             craptab.tpregist = 0
                             NO-LOCK NO-ERROR.
    
		RUN RodaJavaScript("var mevento = new Array();"). 
                          
    /* PROGRID */
    FOR EACH  crapeap WHERE (crapeap.idevento = INT(ab_unmap.aux_idevento)   AND
                             crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                             crapeap.cdagenci = INT(ab_unmap.cdageins)       AND
                             crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                             crapeap.flgevsel = YES)                               OR

                             /* ASSEMBLEIAS */
                            (crapeap.idevento = INT(ab_unmap.aux_idevento)   AND
                             crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                             crapeap.cdagenci = 0                            AND
                             crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                             crapeap.flgevsel = YES)                         NO-LOCK,

        FIRST crapedp WHERE  crapedp.cdevento = crapeap.cdevento             AND
                             crapedp.idevento = crapeap.idevento             AND
                             crapedp.cdcooper = crapeap.cdcooper             AND
                             crapedp.dtanoage = crapeap.dtanoage             AND
                             crapedp.tpevento <> 10                          AND
                             crapedp.tpevento <> 11 NO-LOCK,

        EACH  crapadp WHERE  crapadp.idevento = crapeap.idevento             AND
                             crapadp.cdcooper = crapeap.cdcooper             AND
                             crapadp.cdagenci = crapeap.cdagenci             AND
                             crapadp.dtanoage = crapeap.dtanoage             AND
                             crapadp.cdevento = crapeap.cdevento             NO-LOCK
                             BREAK BY crapadp.cdagenci
                                   BY crapedp.nmevento
                                   BY crapadp.nrseqdig:

				ASSIGN aux_qtmaxtur = STRING(crapadp.qtparpre).
				
        /*
        IF crapeap.qtmaxtur > 0 THEN
          ASSIGN aux_qtmaxtur = STRING(crapadp.QTPARPRE ).
        ELSE
          DO:
            /* para a frequencia minima */
            FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento) AND 
                                     crabedp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                                     crabedp.dtanoage = INT(ab_unmap.aux_dtanoage) AND 
                                     crabedp.cdevento = crapadp.cdevento NO-LOCK. 
            IF AVAILABLE crabedp THEN
              DO:
                IF crabedp.qtmaxtur > 0 THEN
                  ASSIGN aux_qtmaxtur = STRING(crabedp.qtmaxtur).
                ELSE
                  DO:
                    FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento) AND 
                                             crabedp.cdcooper = 0 AND
                                             crabedp.dtanoage = 0 AND 
                                             crabedp.cdevento = crapadp.cdevento NO-LOCK.
                                        
                    IF AVAILABLE crabedp THEN
                      ASSIGN aux_qtmaxtur = STRING(crabedp.qtmaxtur).
                  END.
              END.
          END.
        */
				
        /* Para o PROGRID, verifica se a agenda do PA esta com situacao "5-Enviada aos pa's", senao ignora */
        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                                 crapagp.cdcooper = crapeap.cdcooper            AND
                                 crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                 crapagp.cdagenci = crapeap.cdagenci            AND
                                 crapagp.idstagen = 5                           NO-LOCK NO-ERROR.
     
        ASSIGN aux_tppartic = "".
               
        IF   crapedp.flgcompr = TRUE  THEN
             aux_flgcompr = "TERMO DE COMPROMISSO".
        ELSE
             aux_flgcompr = "".
        
        IF   crapedp.flgrest = TRUE   THEN
             aux_flgrest = "PR�-INSCRI��ES SOMENTE PARA ASSOCIADOS DO PA".
        ELSE
             aux_flgrest = "".
       
        
		ASSIGN aux_idademin = ""
           aux_nrinscri = 0
           aux_nrconfir = 0.

        /* Somente contabiliza os inscritos do evento que ja tiver sido escolhido */
        IF  crapadp.nrseqdig = INT(GET-VALUE("aux_nrseqeve"))   THEN
		    DO: 
                 /* Assembleias */
                 IF   crapeap.idevento = 2   AND
                      crapeap.cdagenci = 0   THEN
                      FOR EACH bf-crapidp WHERE bf-crapidp.idevento = crapeap.idevento
                                            AND bf-crapidp.cdcooper = crapeap.cdcooper
                                            AND bf-crapidp.dtanoage = crapeap.dtanoage
                                            AND bf-crapidp.cdagenci = 0
                                            AND bf-crapidp.cdevento = crapeap.cdevento
                                            AND bf-crapidp.nrseqeve = crapadp.nrseqdig NO-LOCK:
     
                          /* Pendentes e Confirmados */
                          IF   bf-crapidp.idstains < 5   THEN
                               aux_nrinscri = aux_nrinscri + 1.
        
                          /* Somente Confirmados */            
                          IF   bf-crapidp.idstains = 2   THEN
                               aux_nrconfir = aux_nrconfir + 1.
                               
                          /**** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas 
                               (extraido da wpgd0038a)****/
                          IF bf-crapidp.IdStaIns = 2  AND bf-crapidp.QtFalEve > 0 AND crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                            IF ((bf-crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
                                ASSIGN aux_nrfaltan = aux_nrfaltan + 1.
                      END.
                          END.     
                               
                      END.
                 ELSE 
                      FOR EACH bf-crapidp WHERE bf-crapidp.idevento = int(crapeap.idevento)
                                            AND bf-crapidp.cdcooper = crapeap.cdcooper
                                            AND bf-crapidp.dtanoage = crapeap.dtanoage
                                            AND bf-crapidp.cdageins = crapeap.cdagenci
                                            AND bf-crapidp.cdevento = crapeap.cdevento   
                                            AND bf-crapidp.nrseqeve = crapadp.nrseqdig NO-LOCK:

                          /* Pendentes e Confirmados */
                          IF   bf-crapidp.idstains < 5   THEN
                               aux_nrinscri = aux_nrinscri + 1.
                 
                          /* Somente Confirmados */            
                          IF   bf-crapidp.idstains = 2   THEN
                               aux_nrconfir = aux_nrconfir + 1.

                          /* *** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas
                                (extraido da wpgd0038a) ****/
                          IF bf-crapidp.IdStaIns = 2  AND bf-crapidp.QtFalEve > 0 AND crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                             IF ((bf-crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
                                 ASSIGN aux_nrfaltan = aux_nrfaltan + 1.
                      END.
            END.

                      END.
            END.
        
        IF crapadp.dtfineve < TODAY AND crapadp.idstaeve <> 2  THEN
        DO:   
          ASSIGN aux_nrcompar = aux_nrconfir - aux_nrfaltan.
        END.
        
        ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN
                                 crapadp.nrseqdig
                              ELSE 0
               aux_nmevento = crapedp.nmevento.
                                                                                   
       IF  crapadp.dtinieve <> ?   THEN
           aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
       ELSE
       IF  crapadp.nrmeseve <> 0   AND
           crapadp.nrmeseve <> ?   THEN
           aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
    
       IF  crapadp.dshroeve <> ""   THEN
           aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
       
       aux_fechamen = "N�o".  
       DO  aux_contador = 1 TO NUM-ENTRIES(gnpapgd.lsmesctb):

           IF INT(ENTRY(aux_contador,gnpapgd.lsmesctb)) = MONTH(crapadp.dtfineve) THEN
               DO:
	              ASSIGN aux_fechamen = "Sim".
	              LEAVE.
	           END.
       END.              
      
      ASSIGN aux_idstaeve = crapadp.idstaeve.
      
			IF AVAILABLE gnpapgd THEN
				DO:
					IF CAN-DO(STRING(gnpapgd.lsmesctb),STRING(crapadp.nrmeseve)) THEN
						DO:
							ASSIGN aux_fechamen = "Sim".
						END.
				END.
             
       RUN RodaJavaScript("mevento.push(~{cdagenci:'" +  STRING(crapeap.cdagenci) 
																		 + "',cdcooper:'" +  STRING(crapeap.cdcooper) 
																		 + "',cdevento:'" +  STRING(crapeap.cdevento) 
																		 + "',nmevento:'" +  STRING(aux_nmevento)     
																		 + "',idstaeve:'" +  STRING(aux_idstaeve)     
																		 + "',flgcompr:'" +  STRING(aux_flgcompr)     
																		 + "',flgrest:'"  +  STRING(aux_flgrest)      
																		 + "',qtmaxtur:'" +  STRING(aux_qtmaxtur)     
																		 + "',nrinscri:'" +  STRING(aux_nrinscri)     
																		 + "',nrconfir:'" +  STRING(aux_nrconfir)     
																		 + "',nrcompar:'" +  STRING(aux_nrcompar)     
																		 + "',nrfaltan:'" +  STRING(aux_nrfaltan)     
																		 + "',nrseqeve:'" +  STRING(aux_nrseqeve)     
																		 + "',idademin:'" +  STRING(aux_idademin)     
																		 + "',tppartic:'" +  STRING(aux_tppartic)     
																		 + "',tpevento:'" +  STRING(crapedp.tpevento) 
																		 + "',dtfineve:'" + (IF  crapadp.dtfineve = ? THEN "" ELSE STRING(crapadp.dtfineve))
																		 + "',dsfineve:'" + (IF  crapadp.dtfineve <= TODAY THEN "N" ELSE "S" ) /* facilitar validacao no javascript, enviar S se ja finalizou o evento */                                         
																		 + "',dtmvtolt:'" +  STRING(TODAY)
																		 + "',fechamen:'" +  STRING(aux_fechamen) +  "'~});").		
						
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaInscritos w-html 
PROCEDURE CriaListaInscritos:

  /* Variaveis para o XML */ 
  DEF VAR xDoc          AS HANDLE   NO-UNDO.   
  DEF VAR xRoot         AS HANDLE   NO-UNDO.  
  DEF VAR xRoot2        AS HANDLE   NO-UNDO.
  DEF VAR xRoot3        AS HANDLE   NO-UNDO.   
  DEF VAR xField        AS HANDLE   NO-UNDO.
  DEF VAR xField2       AS HANDLE   NO-UNDO.  
  DEF VAR xField3       AS HANDLE   NO-UNDO. 
  DEF VAR xText         AS HANDLE   NO-UNDO. 
  DEF VAR hTextTag      AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont2     AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont3     AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
  DEF VAR xml_status    AS LONGCHAR NO-UNDO. 
  DEF VAR xml_inscritos AS LONGCHAR NO-UNDO. 
  
  DEF VAR aux_cont_status AS INTEGER NO-UNDO.
  DEF VAR aux_cont_inscri AS INTEGER NO-UNDO.

  DEF VAR xml_req      AS LONGCHAR  NO-UNDO.
  DEF VAR aux_cdcritic AS DECIMAL   NO-UNDO.    
  DEF VAR aux_dscritic AS CHARACTER NO-UNDO.
  DEF VAR aux_nminscri AS CHARACTER NO-UNDO.
    
  DEF VAR aux_qtdregis AS DECIMAL NO-UNDO.
  
  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xRoot3.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xField2.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
  CREATE X-NODEREF  hTextTag. /* Vai conter o texto que existe dentro da tag xField */ 
   
  RUN RodaJavaScript("var minscri = new Array();").
  RUN RodaJavaScript("var mstatus = new Array();"). 
  
  ASSIGN aux_nminscri = IF TRIM(ab_unmap.aux_nminscri) <> ? THEN ab_unmap.aux_nminscri ELSE "".
    
  { sistema/ayllos/includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
  
  RUN STORED-PROCEDURE pc_lista_inscritos_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT DECIMAL(ab_unmap.aux_cdcooper) /* Codigo da Cooperativa        */
                                        ,INPUT DECIMAL(ab_unmap.cdageins)     /* Codigo do PA                 */
                                        ,INPUT TRIM(STRING(aux_nminscri))     /* Nome do Inscrito             */
                                        ,INPUT DECIMAL(ab_unmap.nrseqeve)     /* Sequencial de Evento         */
                                        ,INPUT DECIMAL(ab_unmap.aux_tpfiltro) /* Tipo de Filtro               */
                                        ,INPUT DECIMAL(ab_unmap.aux_pesqorde) /* Tipo de Ordenacao            */
                                        ,INPUT DECIMAL(ab_unmap.aux_dtanoage) /* Ano Agenda                   */
                                        ,INPUT DECIMAL(ab_unmap.aux_idevento) /* ID do Evento                 */
                                        ,INPUT DECIMAL(ab_unmap.aux_nriniseq) /* Registro Inicial             */
																				,INPUT 0 /*DECIMAL(ab_unmap.aux_nrficpre)*/ /* Numero da Ficha de Presen�a */
                                       ,OUTPUT 0                              /* Quantidade de registros      */ 
                                       ,OUTPUT ?                              /* XML com informa�oes de LOG   */
                                       ,OUTPUT 0                              /* C�digo da cr�tica            */
                                       ,OUTPUT "").                           /* Descri�ao da cr�tica         */
  
  CLOSE STORED-PROC pc_lista_inscritos_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
  
  { sistema/ayllos/includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
  
  ASSIGN aux_qtdregis = 0
         aux_cdcritic = 0
         aux_dscritic = ""
         aux_qtdregis = pc_lista_inscritos_car.pr_qtdregis 
                          WHEN pc_lista_inscritos_car.pr_qtdregis <> 0
         aux_cdcritic = pc_lista_inscritos_car.pr_cdcritic 
                          WHEN pc_lista_inscritos_car.pr_cdcritic <> 0
         aux_dscritic = pc_lista_inscritos_car.pr_dscritic 
                          WHEN pc_lista_inscritos_car.pr_dscritic <> ?.
       
  IF (TRIM(aux_dscritic) <> "" AND aux_dscritic <> ?) OR 
     (aux_cdcritic <> 0 AND aux_cdcritic <> ?) THEN
    DO:
      RUN RodaJavaScript("alert('" + aux_dscritic + "');").
      RETURN "NOK".
    END.
  
  ASSIGN ab_unmap.aux_qtdregis = STRING(aux_qtdregis).
  
  EMPTY TEMP-TABLE tt-status.
  EMPTY TEMP-TABLE tt-inscritos.
  
  /* Buscar o XML na tabela de retorno da procedure Progress */ 
  ASSIGN xml_req = pc_lista_inscritos_car.pr_clobxmlc. 
  
  /* Efetuar a leitura do XML*/ 
  SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
  PUT-STRING(ponteiro_xml,1) = xml_req. 
  
  IF  ponteiro_xml <> ? THEN
    DO: 
      xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE) NO-ERROR. 
      xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
      
      DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
         
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

        IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
          NEXT.            

        IF xRoot2:name = "status" THEN
          DO:
            
            DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

              xRoot2:GET-CHILD(xField,aux_cont). 

              IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 

              IF xRoot2:NUM-CHILDREN > 0 THEN
                CREATE tt-status.
       
              DO aux_cont2 = 1 TO xField:NUM-CHILDREN: 
            
                xField:GET-CHILD(xField2,aux_cont2) no-error. 
      
                IF xField2:SUBTYPE <> "ELEMENT" THEN 
                  NEXT. 

                DO aux_cont3 = 1 TO xField2:NUM-CHILDREN: 
         
                  xField2:GET-CHILD(hTextTag,1) NO-ERROR.
             
                  /* Se nao vier conteudo na TAG */ 
                  IF ERROR-STATUS:ERROR             OR  
                    ERROR-STATUS:NUM-MESSAGES > 0  THEN
                    NEXT.
             
                  ASSIGN tt-status.cdstatus =    INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdstatus".
                  ASSIGN tt-status.dsstatus = STRING(hTextTag:NODE-VALUE) WHEN xField2:NAME = "dsstatus".
     
                  VALIDATE tt-status.
                END. 
         
              END. 
       
            END. 
    
          END. 
        ELSE IF xRoot2:name = "inscritos" THEN
          DO:
            
            DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

              xRoot2:GET-CHILD(xField,aux_cont). 

              IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 

              IF xRoot2:NUM-CHILDREN > 0 THEN
                CREATE tt-inscritos.
                  
              DO aux_cont2 = 1 TO xField:NUM-CHILDREN: 
                
                xField:GET-CHILD(xField2,aux_cont2) no-error. 
      
                IF xField2:SUBTYPE <> "ELEMENT" THEN 
                  NEXT.                
                
                DO aux_cont3 = 1 TO xField2:NUM-CHILDREN: 
       
                  xField2:GET-CHILD(hTextTag,1) NO-ERROR.
           
                  /* Se nao vier conteudo na TAG */ 
                  IF ERROR-STATUS:ERROR             OR  
                    ERROR-STATUS:NUM-MESSAGES > 0  THEN
                    NEXT.
           
                  ASSIGN tt-inscritos.nminseve = hTextTag:NODE-VALUE WHEN xField2:NAME = "nminseve".
                  ASSIGN tt-inscritos.nmextttl = hTextTag:NODE-VALUE WHEN xField2:NAME = "nmextttl".
                  ASSIGN tt-inscritos.idseqttl = hTextTag:NODE-VALUE WHEN xField2:NAME = "idseqttl".
                  ASSIGN tt-inscritos.nrdconta = hTextTag:NODE-VALUE WHEN xField2:NAME = "nrdconta".
                  ASSIGN tt-inscritos.nrdddins = hTextTag:NODE-VALUE WHEN xField2:NAME = "nrdddins".
                  ASSIGN tt-inscritos.nrtelins = hTextTag:NODE-VALUE WHEN xField2:NAME = "nrtelins".
                  ASSIGN tt-inscritos.dsobsins = hTextTag:NODE-VALUE WHEN xField2:NAME = "dsobsins".
                  ASSIGN tt-inscritos.nrficpre = hTextTag:NODE-VALUE WHEN xField2:NAME = "nrficpre" AND hTextTag:NODE-VALUE <> "0".
                  ASSIGN tt-inscritos.cdagenci = hTextTag:NODE-VALUE WHEN xField2:NAME = "cdagenci".
                  ASSIGN tt-inscritos.cdageins = hTextTag:NODE-VALUE WHEN xField2:NAME = "cdageins".
                  ASSIGN tt-inscritos.cdcooper = hTextTag:NODE-VALUE WHEN xField2:NAME = "cdcooper".
                  ASSIGN tt-inscritos.cdevento = hTextTag:NODE-VALUE WHEN xField2:NAME = "cdevento".
                  ASSIGN tt-inscritos.nrseqdig = hTextTag:NODE-VALUE WHEN xField2:NAME = "nrseqdig".
                  ASSIGN tt-inscritos.nrseqeve = hTextTag:NODE-VALUE WHEN xField2:NAME = "nrseqeve".
                  ASSIGN tt-inscritos.dtconins = hTextTag:NODE-VALUE WHEN xField2:NAME = "dtconins".
                  ASSIGN tt-inscritos.cdgraupr = hTextTag:NODE-VALUE WHEN xField2:NAME = "cdgraupr".
                  ASSIGN tt-inscritos.nmresage = hTextTag:NODE-VALUE WHEN xField2:NAME = "nmresage".
                  ASSIGN tt-inscritos.idstains = hTextTag:NODE-VALUE WHEN xField2:NAME = "idstains".
                  ASSIGN tt-inscritos.nrdrowid = hTextTag:NODE-VALUE WHEN xField2:NAME = "nrdrowid".
                  ASSIGN tt-inscritos.prgrecid = hTextTag:NODE-VALUE WHEN xField2:NAME = "progress".
                  ASSIGN tt-inscritos.dtpreins = hTextTag:NODE-VALUE WHEN xField2:NAME = "dtpreins".
                  ASSIGN tt-inscritos.qtfaleve = hTextTag:NODE-VALUE WHEN xField2:NAME = "qtfaleve".
                  ASSIGN tt-inscritos.flginsin = hTextTag:NODE-VALUE WHEN xField2:NAME = "flginsin".
                                    
                  VALIDATE tt-inscritos.
   
                END. 
         
              END. 
       
          END. /* INSCRITOS */
    
      END. /* DO aux_cont_raiz */
       
    END.    
     
    SET-SIZE(ponteiro_xml) = 0.    
  END.           

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xRoot2. 
  DELETE OBJECT xRoot3. 
  DELETE OBJECT xField. 
  DELETE OBJECT xField2. 
  DELETE OBJECT xText.
  DELETE OBJECT hTextTag.
  
  /* Monta arrray de inscritos */
  FOR EACH tt-inscritos NO-LOCK:
  
    FOR FIRST crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)
                        AND crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                        AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                        AND crapidp.cdagenci = INT(tt-inscritos.cdagenci)
                        AND crapidp.cdevento = INT(tt-inscritos.cdevento)
                        AND crapidp.nrseqeve = INT(tt-inscritos.nrseqeve)
                        AND crapidp.nrseqdig = INT(tt-inscritos.nrseqdig) NO-LOCK. END.
        
    RUN RodaJavaScript('minscri.push(~{nminseve:"' + STRING(tt-inscritos.nminseve) + 
                                    '",nmextttl:"' + STRING(tt-inscritos.nmextttl) + 
                                    '",idseqttl:"' + STRING(tt-inscritos.idseqttl) +
                                    '",nrdconta:"' + STRING(tt-inscritos.nrdconta) +
                                    '",nrdddins:"' + STRING(tt-inscritos.nrdddins) +
                                    '",nrtelins:"' + STRING(tt-inscritos.nrtelins) +
                                    '",dsobsins:"' + STRING(tt-inscritos.dsobsins) +
                                    '",nrficpre:"' + STRING(tt-inscritos.nrficpre) +
                                    '",cdagenci:"' + STRING(tt-inscritos.cdagenci) +
                                    '",cdageins:"' + STRING(tt-inscritos.cdageins) +
                                    '",cdcooper:"' + STRING(tt-inscritos.cdcooper) +
                                    '",cdevento:"' + STRING(tt-inscritos.cdevento) +
                                    '",nrseqdig:"' + STRING(tt-inscritos.nrseqdig) +
                                    '",nrseqeve:"' + STRING(tt-inscritos.nrseqeve) +
                                    '",dtconins:"' + STRING(tt-inscritos.dtconins) +
                                    '",cdgraupr:"' + STRING(tt-inscritos.cdgraupr) +
                                    '",nmresage:"' + STRING(tt-inscritos.nmresage) +
                                    '",idstains:"' + STRING(tt-inscritos.idstains) +
                                    '",nrdrowid:"' + STRING(ROWID(crapidp))        +
                                    '",progress:"' + STRING(tt-inscritos.prgrecid) +
                                    '",dtpreins:"' + STRING(tt-inscritos.dtpreins) +
                                    '",qtfaleve:"' + STRING(tt-inscritos.qtfaleve) +
                                    '",flginsin:"' + STRING(tt-inscritos.flginsin) + '"~});').
  END.
    
  /* Monta arrray de status */
  FOR EACH tt-status NO-LOCK:
    RUN RodaJavaScript('mstatus.push(~{cdstatus:"' + STRING(tt-status.cdstatus) + 
                                    '",dsstatus:"' + STRING(tt-status.dsstatus) + '"~});').
  END.
    
  RETURN "OK".
     
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac:

  DEFINE VARIABLE aux_nmresag2 AS CHAR NO-UNDO.

  RUN RodaJavaScript("var mpac = new Array();"). 
    
  /* Se abriu a tela wpgd0061 ou foi chamado por outra tela sem passagem de PA por parametro */
  IF ab_unmap.origem        = "" OR
     INT(ab_unmap.cdageins) = 0  THEN
    DO:
      { includes/wpgd0097.i }
    END.
  ELSE  /* Chamado por outra tela */
    DO:
      /* Se abrir por outra tela passando o PA por parametro */
      FIND crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND crapage.cdagenci = INT(ab_unmap.cdageins) NO-LOCK NO-ERROR.

      IF AVAILABLE crapage THEN
       vetorpac = "~{cdcooper:'" + TRIM(STRING(crapage.cdcooper))
                + "',cdagenci:'" + TRIM(STRING(crapage.cdagenci))
                + "',nmresage:'" + crapage.nmresage + "'~}".
    END.
  
    RUN RodaJavaScript("mpac.push(" + vetorpac + ");").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EncerraMatricula w-html 
PROCEDURE EncerraMatricula:

  DEF VAR i AS INT NO-UNDO.
	DEF VAR aux_cdagenci AS INT NO-UNDO.
  DEF VAR aux_msg-erro AS CHAR NO-UNDO.

  FIND crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                     crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR.

  FIND FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento            
                       AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  
                       AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                       AND crapedp.idevento = INT(ab_unmap.aux_idevento) NO-LOCK NO-ERROR.
   
	/**/
	/* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0061.p PERSISTENT SET h-b1wpgd0061.
    
  FIND FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento            
                       AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  
                       AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                       AND crapedp.idevento = INT(ab_unmap.aux_idevento) NO-LOCK NO-ERROR.
                       
  IF NOT AVAILABLE crapedp THEN
    DO:
      ASSIGN msg-erro = "Registro de Evento n�o encontrado!".
      RETURN "NOK". 
    END.                     
    
  /* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0061) THEN
    DO:
      FOR EACH crapidp WHERE crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                         AND crapidp.idevento = INT(ab_unmap.aux_idevento)
                         AND crapidp.cdevento = crapadp.cdevento          
                         AND crapidp.nrseqeve = crapadp.nrseqdig          
                         AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                         AND crapidp.cdageins = INT(ab_unmap.cdageins) NO-LOCK:
        
        IF crapedp.tpevento = 7 OR crapedp.tpevento = 12 THEN
          DO:
            IF (crapidp.nrficpre = 0 OR crapidp.nrficpre = ? OR STRING(crapidp.nrficpre) = "") AND crapidp.dtconins <> ? THEN
              DO:
                ASSIGN msg-erro = "Existem inscritos confirmados e sem n�mero de ficha de presen�a informado. Encerramento n�o permitido".
                RETURN "NOK".
              END.
          END.

        EMPTY TEMP-TABLE cratidp.
        
        CREATE cratidp.
        BUFFER-COPY crapidp TO cratidp.

        IF cratidp.idstains = 1 THEN
					DO:
						ASSIGN cratidp.idstains = 4
									 cratidp.nrficpre = ?.
					END.
				
        IF crapedp.tpevento = 8 OR crapedp.tpevento = 13 OR crapedp.tpevento = 14 OR crapedp.tpevento = 15 OR crapedp.tpevento = 16 THEN
          DO:
						IF cratidp.idstains = 4 THEN
							DO:
								ASSIGN cratidp.qtfaleve = crapadp.qtdiaeve.
							END.
          END.

        RUN altera-registro IN h-b1wpgd0061(INPUT TABLE cratidp, OUTPUT aux_msg-erro).

        msg-erro = msg-erro + aux_msg-erro.

      END.

      /* "mata" a inst�ncia da BO */
      DELETE PROCEDURE h-b1wpgd0061 NO-ERROR.
    END.
	/**/
	 
  IF crapedp.tpevento = 7 OR crapedp.tpevento = 12 THEN
    DO:
      FOR EACH crapfpa NO-LOCK:
        FIND FIRST crapidp WHERE crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             AND crapidp.idevento = INT(ab_unmap.aux_idevento) 
                             AND crapidp.cdevento = crapadp.cdevento           
                             AND crapidp.nrseqeve = crapadp.nrseqdig           
                             AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                             AND crapidp.cdageins = INT(ab_unmap.cdageins)     
                             AND crapidp.nrficpre = crapfpa.nrficpre NO-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAILABLE crapfpa THEN
          DO:
            ASSIGN msg-erro = "Existem fichas de presen�as relacionadas ao evento e que n�o possuem inscritos lan�ados!".
            RETURN "NOK". 
          END.                           
                            
      END.
    END.
  							
		IF crapedp.tpevento = 7 OR crapedp.tpevento = 12 THEN 
			ASSIGN aux_cdagenci = 0.
		ELSE
			ASSIGN aux_cdagenci = INT(ab_unmap.cdageins).
			
		RELEASE crapadp.	
			
    FIND crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)
                   AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                   AND crapadp.cdagenci = aux_cdagenci					    
                   AND crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)
                   AND crapadp.nrseqdig = INT(ab_unmap.nrseqeve) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF AVAILABLE crapadp THEN
      DO:
        ASSIGN crapadp.idstaeve = 4
               crapadp.cdcopope = INT(ab_unmap.aux_cdcooper)
               crapadp.cdoperad = ab_unmap.aux_cdoperad. 
			  VALIDATE crapadp.
				
        CREATE craphep.
        ASSIGN craphep.nrseqdig  = NEXT-VALUE(nrseqhep)
				   		 craphep.cdagenci  = crapadp.nrseqdig
							 craphep.dshiseve  = "Evento encerrado em " + STRING(TODAY,"99/99/9999") + " pelo usu�rio " + gnapses.cdoperad + "."
							 craphep.dtmvtolt  = TODAY.  
			  VALIDATE craphep.                 
	    END.     
    ELSE
      msg-erro = msg-erro + "Problemas para encerrar matr�culas. AGE: " + string(aux_cdagenci) + ", nrseqeve: " + string(ab_unmap.nrseqeve) + ", IDEVE: " + string(INT(ab_unmap.aux_idevento)) + ", CDCOOPER: " + string(INT(ab_unmap.aux_cdcooper)) + ", Dt: " + string(INT(ab_unmap.aux_dtanoage)).

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verificaFichaNaoLancada w-html 
PROCEDURE verificaFichaNaoLancada:

  /* Verifica se ja foi feita essa leitura de fichas, caso tenha sido pode ser encerradas as inscricoes */
  IF ab_unmap.aux_indficin = "S" THEN
		DO:
			ASSIGN ab_unmap.aux_encerrar = "S".
			RETURN "OK".
		END.
    
  FIND crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                 AND crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR.

  FIND FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento            
                       AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  
                       AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                       AND crapedp.idevento = INT(ab_unmap.aux_idevento) NO-LOCK NO-ERROR.
   
  IF crapedp.tpevento = 7 OR crapedp.tpevento = 12 THEN
    DO:
			
      FOR EACH crapfpa WHERE crapfpa.cdcopfic = INT(ab_unmap.aux_cdcooper)
                         AND crapfpa.cdagefic = INT(ab_unmap.cdageins)
												 AND crapfpa.nrseqdig = crapadp.nrseqdig NO-LOCK:
                         
        FIND FIRST crapidp WHERE crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             AND crapidp.idevento = INT(ab_unmap.aux_idevento) 
                             AND crapidp.cdevento = crapadp.cdevento           
                             AND crapidp.nrseqeve = crapadp.nrseqdig           
                             AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage) 
                             AND crapidp.cdageins = INT(ab_unmap.cdageins)     
                             AND crapidp.nrficpre = crapfpa.nrficpre NO-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAILABLE crapidp THEN
          DO:
            ASSIGN msg-erro = "Existem fichas de presen�a relacionadas ao evento e que n�o possuem inscritos lan�ados! Para confirmar o encerramento pressione o bot�o 'OK'. Para visualizar as informa��es das fichas, pressione o bot�o 'Cancelar' e o bot�o 'Vizualizar Relat�rio' na tela de confirma��es."
									 msg-erro-aux = 15.
            RETURN "NOK". 
          END.                           
                            
      END.
    END.
  
	ASSIGN ab_unmap.aux_encerrar = "S".
	
  RETURN "OK".
  
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EncerraMatricula w-html 
PROCEDURE ExcluirInscricao:

    DEF VAR i AS INT NO-UNDO.
    DEF VAR aux_msg-erro AS CHAR NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0061.p PERSISTENT SET h-b1wpgd0061.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0061) THEN
       DO:
           FOR EACH crapidp 
              WHERE ROWID(crapidp) = TO-ROWID(ab_unmap.aux_excrowid) NO-LOCK:
           
               FOR EACH cratidp EXCLUSIVE-LOCK:
                   DELETE cratidp NO-ERROR.
               END.
       
               CREATE cratidp.
               BUFFER-COPY crapidp TO cratidp.
               
               /*Atribuir a situacao de excluido para nao validar a situacao na exclusao */
               ASSIGN cratidp.idstains = 5.
               
               RUN exclui-registro IN h-b1wpgd0061(INPUT TABLE cratidp, OUTPUT aux_msg-erro).       
               msg-erro = msg-erro + aux_msg-erro.
               
           END.
       
           /* "mata" a inst�ncia da BO */
           DELETE PROCEDURE h-b1wpgd0061 NO-ERROR.
       END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :

  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdgraupr":U,"ab_unmap.aux_cdgraupr":U,ab_unmap.aux_cdgraupr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobsins":U,"crapidp.dsobsins":U,crapidp.dsobsins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrficpre":U,"crapidp.nrficpre":U,crapidp.nrficpre:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgcompr":U,"ab_unmap.aux_flgcompr":U,ab_unmap.aux_flgcompr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgrest":U,"ab_unmap.aux_flgrest":U,ab_unmap.aux_flgrest:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idstaeve":U,"ab_unmap.aux_idstaeve":U,ab_unmap.aux_idstaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lscoment":U,"ab_unmap.aux_lscoment":U,ab_unmap.aux_lscoment:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsfaleve":U,"ab_unmap.aux_lsfaleve":U,ab_unmap.aux_lsfaleve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsconfir":U,"ab_unmap.aux_lsconfir":U,ab_unmap.aux_lsconfir:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsseqdig":U,"ab_unmap.aux_lsseqdig":U,ab_unmap.aux_lsseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nminseve":U,"ab_unmap.aux_nminseve":U,ab_unmap.aux_nminseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrconfir":U,"ab_unmap.aux_nrconfir":U,ab_unmap.aux_nrconfir:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcompar":U,"ab_unmap.aux_nrcompar":U,ab_unmap.aux_nrcompar:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_excrowid":U,"ab_unmap.aux_excrowid":U,ab_unmap.aux_excrowid:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_nrinscri":U,"ab_unmap.aux_nrinscri":U,ab_unmap.aux_nrinscri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtmaxtur":U,"ab_unmap.aux_qtmaxtur":U,ab_unmap.aux_qtmaxtur:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tpinseve":U,"ab_unmap.aux_tpinseve":U,ab_unmap.aux_tpinseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tppartic":U,"ab_unmap.aux_tppartic":U,ab_unmap.aux_tppartic:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idademin":U,"ab_unmap.aux_idademin":U,ab_unmap.aux_idademin:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_fechamen":U,"ab_unmap.aux_fechamen":U,ab_unmap.aux_fechamen:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tpfiltro":U,"ab_unmap.aux_tpfiltro":U,ab_unmap.aux_tpfiltro:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nminscri":U,"ab_unmap.aux_nminscri":U,ab_unmap.aux_nminscri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdageins":U,"ab_unmap.cdageins":U,ab_unmap.cdageins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"crapidp.cdcooper":U,crapidp.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdgraupr":U,"crapidp.cdgraupr":U,crapidp.cdgraupr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsdemail":U,"crapidp.dsdemail":U,crapidp.dsdemail:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgdispe":U,"crapidp.flgdispe":U,crapidp.flgdispe:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("idseqttl":U,"crapidp.idseqttl":U,crapidp.idseqttl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmcooper":U,"ab_unmap.aux_nmcooper":U,ab_unmap.aux_nmcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdconta_cpfcgc":U,"ab_unmap.aux_nrdconta_cpfcgc":U,ab_unmap.aux_nrdconta_cpfcgc:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("nminseve":U,"crapidp.nminseve":U,crapidp.nminseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmresage":U,"ab_unmap.nmresage":U,ab_unmap.nmresage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdconta":U,"crapidp.nrdconta":U,crapidp.nrdconta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddins":U,"crapidp.nrdddins":U,crapidp.nrdddins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqeve":U,"ab_unmap.nrseqeve":U,ab_unmap.nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrtelins":U,"crapidp.nrtelins":U,crapidp.nrtelins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("origem":U,"ab_unmap.origem":U,ab_unmap.origem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("pagina":U,"ab_unmap.pagina":U,ab_unmap.pagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("tpinseve":U,"crapidp.tpinseve":U,crapidp.tpinseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_carregar":U,"ab_unmap.aux_carregar":U,ab_unmap.aux_carregar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_reginils":U,"ab_unmap.aux_reginils":U,ab_unmap.aux_reginils:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_regfimls":U,"ab_unmap.aux_regfimls":U,ab_unmap.aux_regfimls:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aba":U,"ab_unmap.aba":U,ab_unmap.aba:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgalter":U,"ab_unmap.aux_flgalter":U,ab_unmap.aux_flgalter:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flginscr":U,"ab_unmap.aux_flginscr":U,ab_unmap.aux_flginscr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsinscri":U,"ab_unmap.aux_dsinscri":U,ab_unmap.aux_dsinscri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc":U,"ab_unmap.aux_nrcpfcgc":U,ab_unmap.aux_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc_fil":U,"ab_unmap.aux_nrcpfcgc_fil":U,ab_unmap.aux_nrcpfcgc_fil:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_pesqorde":U,"ab_unmap.aux_pesqorde":U,ab_unmap.aux_pesqorde:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nriniseq":U,"ab_unmap.aux_nriniseq":U,ab_unmap.aux_nriniseq:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_qtdregis":U,"ab_unmap.aux_qtdregis":U,ab_unmap.aux_qtdregis:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_nrficpre":U,"ab_unmap.aux_nrficpre":U,ab_unmap.aux_nrficpre:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_indicdiv":U,"ab_unmap.aux_indicdiv":U,ab_unmap.aux_indicdiv:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_dsurlphp":U,"ab_unmap.aux_dsurlphp":U,ab_unmap.aux_dsurlphp:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_idcookie":U,"ab_unmap.aux_idcookie":U,ab_unmap.aux_idcookie:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_indficin":U,"ab_unmap.aux_indficin":U,ab_unmap.aux_indficin:HANDLE IN FRAME {&FRAME-NAME}).
	RUN htmAssociate
    ("aux_encerrar":U,"ab_unmap.aux_encerrar":U,ab_unmap.aux_encerrar:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
  
  DEFINE INPUT PARAMETER opcao AS CHARACTER.
  
  DEFINE VARIABLE tmp_cdevento AS INT                NO-UNDO.
  DEFINE VARIABLE tmp_cdagenci LIKE crapidp.cdagenci NO-UNDO.
      
  /* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0061.p PERSISTENT SET h-b1wpgd0061.
    
  /* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0061) THEN
    DO:          
      DO WITH FRAME {&FRAME-NAME}:
        				
        IF opcao = "inclusao" THEN
          DO: 
            FIND FIRST crapadp WHERE crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                                 AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

            IF NOT AVAIL crapadp THEN NEXT.
              
            ASSIGN tmp_cdevento = crapadp.cdevento.

            /* se evento estiver encerrado e nao tiver sido realizado a inscri�ao sera pendente */
            IF crapadp.idstaeve = 4 AND crapadp.dtfineve > TODAY THEN
              ASSIGN aux_idstains = 1. /* pendente */
                        
            /* se campo dispensar confirmacao tiver checkado, status sera confirmado */
            IF INPUT FRAME {&frame-name} crapidp.flgdispe THEN
              ASSIGN aux_idstains = 2. /* confirmado */
            ELSE
              ASSIGN aux_idstains = 1. /* pendente */ 

            FIND FIRST crapedp WHERE crapedp.cdevento = tmp_cdevento                AND
                                     crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                     crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                     crapedp.idevento = INT(ab_unmap.aux_idevento)  
                                     NO-LOCK NO-ERROR.
            
            IF crapedp.tpevento = 7 OR crapedp.tpevento = 12 THEN /* � assembl�ia */
              ASSIGN tmp_cdagenci = 0.
            ELSE
              ASSIGN tmp_cdagenci = INT(ab_unmap.cdageins).
                    
            /* a conta pode nao ser informada */
            IF aux_nrdconta <> 0 THEN 
              DO:
                FOR FIRST crapass FIELDS(inpessoa) WHERE crapass.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                     AND crapass.nrdconta = aux_nrdconta NO-LOCK. END.                    
              END.
            
            RUN verificaInscricao(INPUT INT(ab_unmap.aux_idevento)
                                 ,INPUT INT(ab_unmap.aux_cdcooper)
                                 ,INPUT INT(ab_unmap.aux_dtanoage)
                                 ,INPUT aux_nrdconta
                                 ,INPUT tmp_cdevento
                                 ,INPUT INT(ab_unmap.nrseqeve)
                                 ,INPUT INT(ab_unmap.cdageins)
                                 ,INPUT INPUT crapidp.nminseve).
  
            IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".
  					
						IF INPUT crapidp.flgdispe THEN
							DO:
								IF (crapedp.tpevento = 7 OR crapedp.tpevento = 12) /*AND aux_idstains = 2*/ THEN
									DO:
										RUN verificaFichaPresenca(INPUT INT(ab_unmap.aux_idevento)
																						 ,INPUT INT(ab_unmap.aux_cdcooper)
																						 ,INPUT INT(ab_unmap.aux_dtanoage)
																						 ,INPUT INT(ab_unmap.cdageins)
																						 ,INPUT tmp_cdevento
																						 ,INPUT INT(ab_unmap.nrseqeve)
																						 ,INPUT IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre)).
																	
										IF RETURN-VALUE = "NOK" THEN
											DO:
												RETURN "NOK".
											END.                     
									END.
							END.
						ELSE
							DO:
								IF (crapedp.tpevento = 7 OR crapedp.tpevento = 12) /*AND aux_idstains = 2*/ THEN
									DO:
										IF INPUT crapidp.nrficpre <> "" AND INPUT crapidp.nrficpre <> ? AND INPUT crapidp.nrficpre <> 0 THEN
											DO:
												RUN verificaFichaPresenca(INPUT INT(ab_unmap.aux_idevento)
																								 ,INPUT INT(ab_unmap.aux_cdcooper)
																								 ,INPUT INT(ab_unmap.aux_dtanoage)
																								 ,INPUT INT(ab_unmap.cdageins)
																								 ,INPUT tmp_cdevento
																								 ,INPUT INT(ab_unmap.nrseqeve)
																								 ,INPUT IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre)).
																			
												IF RETURN-VALUE = "NOK" THEN
													DO:
														RETURN "NOK".
													END.                     
											END.
									END.
							END.
						
            CREATE cratidp.
            ASSIGN cratidp.cdagenci = tmp_cdagenci
                   cratidp.cdageins = INT(ab_unmap.cdageins)
                   cratidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                   cratidp.cdevento = tmp_cdevento
                   cratidp.nrseqeve = INT(ab_unmap.nrseqeve)
                   cratidp.cdgraupr = IF INT(ab_unmap.aux_cdgraupr) = 0 THEN 5 
                                      ELSE INT(ab_unmap.aux_cdgraupr)
                   cratidp.cdoperad = gnapses.cdoperad  
                   cratidp.dsdemail = INPUT crapidp.dsdemail
                   cratidp.flgdispe = INPUT crapidp.flgdispe 
                   cratidp.tpinseve = INT(ab_unmap.aux_tpinseve)
                   cratidp.dsobsins = INPUT crapidp.dsobsins
                   cratidp.nrficpre = INPUT crapidp.nrficpre
                   cratidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                   cratidp.dtconins = IF cratidp.flgdispe THEN TODAY 
                                      ELSE ?
                   cratidp.dtpreins = TODAY
                   cratidp.idevento = INT(ab_unmap.aux_idevento)
                   cratidp.idseqttl = aux_idseqttl
                   cratidp.idstains = aux_idstains
                   cratidp.nminseve = INPUT crapidp.nminseve
                   cratidp.nrdconta = aux_nrdconta
                   cratidp.nrdddins = INPUT crapidp.nrdddins
                   cratidp.nrseqdig = 0
                   cratidp.cdopeori = gnapses.cdoperad
                   cratidp.cdageori = 999 
                   cratidp.dtinsori = TODAY
                   cratidp.nrtelins = INPUT crapidp.nrtelins.
                   
            IF cratidp.flgdispe THEN
              DO:
                ASSIGN cratidp.nrficpre = IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre).
              END.
                           
            /* valida a execucao da consulta e o tipo da conta */
            IF AVAILABLE crapass AND crapass.inpessoa = 2 THEN       
              DO:
                        
                FIND FIRST crapavt WHERE crapavt.cdcooper = INT(ab_unmap.aux_cdcooper)
                                     AND crapavt.nrdconta = aux_nrdconta 
                                     AND crapavt.tpctrato = 6
                                     AND crapavt.nrctremp = 0 NO-LOCK.
                                             
                ASSIGN cratidp.cdcopavl = INT(ab_unmap.aux_cdcooper)
                       cratidp.tpctrato = 6
                       cratidp.nrctremp = 0
                       cratidp.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc).
              END.

            RUN inclui-registro IN h-b1wpgd0061(INPUT  TABLE cratidp, 
                                               OUTPUT msg-erro, 
                                               OUTPUT ab_unmap.aux_nrdrowid). 
          END. /* Inclusao */
        ELSE  /* Alteracao */
          DO:
            
            FIND FIRST crapadp WHERE crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                                 AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

            IF NOT AVAIL crapadp THEN NEXT.
             
            /* se campo dispensar confirmacao tiver checkado, status sera confirmado */
            IF INPUT FRAME {&frame-name} crapidp.flgdispe THEN
              ASSIGN aux_idstains = 2. /* confirmado */
            ELSE
              ASSIGN aux_idstains = 1. /* pendente */ 

            /* se evento estiver encerrado e nao tiver sido realizado a inscri�ao sera pendente */
            IF crapadp.idstaeve = 4 AND crapadp.dtfineve > TODAY THEN
              ASSIGN aux_idstains = 1. /* pendente */ 
            
            RUN verificaInscricao(INPUT INT(ab_unmap.aux_idevento)
                                 ,INPUT INT(ab_unmap.aux_cdcooper)
                                 ,INPUT INT(ab_unmap.aux_dtanoage)
                                 ,INPUT aux_nrdconta
                                 ,INPUT tmp_cdevento
                                 ,INPUT INT(ab_unmap.nrseqeve)
                                 ,INPUT INT(ab_unmap.cdageins)
                                 ,INPUT INPUT crapidp.nminseve).
  
            IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".
            
						FIND FIRST crapedp WHERE crapedp.cdevento = tmp_cdevento              
																 AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
																 AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)
																 AND crapedp.idevento = INT(ab_unmap.aux_idevento) NO-LOCK NO-ERROR.
													 
						IF (crapedp.tpevento = 7 OR crapedp.tpevento = 12) /*AND aux_idstains = 2*/ THEN
							DO:
								IF INPUT crapidp.flgdispe THEN
									DO:
										RUN verificaFichaPresenca(INPUT INT(ab_unmap.aux_idevento)
																						 ,INPUT INT(ab_unmap.aux_cdcooper)
																						 ,INPUT INT(ab_unmap.aux_dtanoage)
																						 ,INPUT tmp_cdagenci
																						 ,INPUT tmp_cdevento
																						 ,INPUT INT(ab_unmap.nrseqeve)
																						 ,INPUT IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre)).
																	
										IF RETURN-VALUE = "NOK" THEN
											DO:
												RETURN "NOK".
											END.  
									END.
							END.
            ELSE
							DO:
								IF (crapedp.tpevento = 7 OR crapedp.tpevento = 12) /*AND aux_idstains = 2*/ THEN
									DO:
										IF INPUT crapidp.nrficpre <> "" AND INPUT crapidp.nrficpre <> ? AND INPUT crapidp.nrficpre <> 0 THEN
											DO:
												RUN verificaFichaPresenca(INPUT INT(ab_unmap.aux_idevento)
																								 ,INPUT INT(ab_unmap.aux_cdcooper)
																								 ,INPUT INT(ab_unmap.aux_dtanoage)
																								 ,INPUT INT(ab_unmap.cdageins)
																								 ,INPUT tmp_cdevento
																								 ,INPUT INT(ab_unmap.nrseqeve)
																								 ,INPUT IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre)).
																			
												IF RETURN-VALUE = "NOK" THEN
													DO:
														RETURN "NOK".
													END.                     
										  END.
									END.
							END.
							
            ASSIGN cratidp.cdgraupr = IF INT(ab_unmap.aux_cdgraupr) = 0 THEN 9
                                      ELSE INT(ab_unmap.aux_cdgraupr)
                   cratidp.cdoperad = gnapses.cdoperad
                   cratidp.dsdemail = INPUT crapidp.dsdemail
                   cratidp.dtpreins = TODAY
                   cratidp.nminseve = INPUT crapidp.nminseve
                   cratidp.nrdddins = INPUT crapidp.nrdddins
                   cratidp.nrtelins = INPUT crapidp.nrtelins
                   cratidp.flgdispe = INPUT crapidp.flgdispe 
                   cratidp.tpinseve = INT(ab_unmap.aux_tpinseve)
                   cratidp.dtconins = IF cratidp.flgdispe THEN TODAY ELSE ? 
                   cratidp.idstains = aux_idstains
                   cratidp.dsobsins = INPUT crapidp.dsobsins
                   cratidp.nrficpre = INPUT crapidp.nrficpre
                   cratidp.nrdconta = aux_nrdconta
                   cratidp.idseqttl = aux_idseqttl
                   cratidp.nminseve = INPUT crapidp.nminseve
                   cratidp.nrdddins = INPUT crapidp.nrdddins
                   cratidp.nrseqdig = ?
                   cratidp.nrtelins = INPUT crapidp.nrtelins.
                   
            IF cratidp.flgdispe THEN
              DO:
                ASSIGN cratidp.nrficpre = IF INT(ab_unmap.aux_indicdiv) = 0 THEN INPUT crapidp.nrficpre ELSE INT(ab_unmap.aux_nrficpre).
              END.

            RUN altera-registro IN h-b1wpgd0061(INPUT TABLE cratidp, OUTPUT msg-erro). 

          END. /* Fim Alteracao */   
          
          ASSIGN aux_nrdconta = 0. 
          
        END. /* DO WITH FRAME {&FRAME-NAME} */
       
        /* "mata" a inst�ncia da BO */
        DELETE PROCEDURE h-b1wpgd0061 NO-ERROR.
       
      END. /* IF VALID-HANDLE(h-b1wpgd0061) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
  RUN displayFields.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NomeCooperado w-html 
PROCEDURE NomeCooperado :

    DEFINE BUFFER bf1-crapidp FOR crapidp.

    DEF VAR aux_nmtitular  AS CHAR NO-UNDO.
    DEF VAR aux_cdcooper   AS INTE NO-UNDO.
    DEF VAR aux_cdagenci   AS INTE NO-UNDO.
    DEF VAR aux_conta      AS INTE NO-UNDO.
    DEF VAR aux_seqttl     AS INTE NO-UNDO.
    DEF VAR aux_flgcrapass AS LOG  NO-UNDO.
    DEF VAR aux_flgcrapttl AS LOG  NO-UNDO.
    
    DEF VAR aux_nrtelefo AS CHAR NO-UNDO.
    DEF VAR aux_nrdddtfc AS CHAR NO-UNDO.
    DEF VAR aux_dsdemail AS CHAR NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR NO-UNDO.
    DEF VAR aux_nmresage AS CHAR NO-UNDO.
            
    IF INT(aux_nrdconta) = 0 THEN
      RETURN "NOK".
    		
    FOR FIRST crapass FIELDS(inpessoa nmprimtl cdagenci) WHERE crapass.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                           AND crapass.nrdconta = INT(aux_nrdconta) NO-LOCK. END.
    
    IF NOT AVAILABLE crapass THEN                    
      DO:
        ASSIGN msg-erro-aux = 11.
        RETURN "NOK".
      END.
    
    ASSIGN aux_nmprimtl = STRING(crapass.nmprimtl).
    
    FOR FIRST crapage FIELDS(nmresage) WHERE crapage.cdcooper = crapass.cdcooper
                                         AND crapage.cdagenci = crapass.cdagenci NO-LOCK. END.
    
    /* Insere valor no campo de PA */
    IF NOT AVAILABLE crapass THEN                    
      DO:
        ASSIGN ab_unmap.nmresage = "SEM PA"
                    aux_nmresage = "SEM PA".
      END.
    ELSE
      DO:
        ASSIGN ab_unmap.nmresage = STRING(crapage.nmresage)
                    aux_nmresage = STRING(crapage.nmresage).
      END.
    
    IF crapass.inpessoa = 1 THEN /* PESSOA FISICA */
      DO:
        FOR EACH crapttl WHERE crapttl.cdcooper = INT(ab_unmap.aux_cdcooper) 
                           AND crapttl.nrdconta = INT(aux_nrdconta) NO-LOCK:
      
          ASSIGN aux_dsinscri = ''
                 aux_flginscr = ''.	
              
          FOR EACH crapidp WHERE crapidp.idevento = INTEGER(ab_unmap.aux_idevento) 
                             AND crapidp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                             AND crapidp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                             AND crapidp.nrdconta = aux_nrdconta                  
                             AND crapidp.idseqttl = crapttl.idseqttl              
                             AND crapidp.cdevento = INT(aux_cdevento) 		    
                             AND crapidp.nrseqeve = INT(ab_unmap.nrseqeve)
                             AND crapidp.cdageins = INT(ab_unmap.cdageins) NO-LOCK:
          
            ASSIGN aux_flginscr = "S".
          
            FIND FIRST crapage WHERE crapage.cdcooper = crapidp.cdcooper
                                 AND crapage.cdagenci = crapidp.cdageins NO-LOCK NO-ERROR.
           
            IF AVAILABLE crapage THEN  
              ASSIGN aux_dsinscri = aux_dsinscri + " Pa: " + crapage.nmresage + " Inscrito: " + crapidp.nminseve.
            ELSE /* para assembleias o pa = 0 */ 
              ASSIGN aux_dsinscri = aux_dsinscri + "Inscrito: " + crapidp.nminseve.
          
          END.
      
          ASSIGN aux_nrtelefo = ""
                 aux_dsdemail = "".
          
          FOR FIRST crapcem FIELDS(dsdemail cddemail) WHERE crapcem.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                        AND crapcem.nrdconta = INT(aux_nrdconta) 
                                                        AND crapcem.idseqttl = crapttl.idseqttl NO-LOCK. END.  
                                                      
          IF AVAILABLE crapcem THEN
            DO:
              ASSIGN aux_dsdemail = crapcem.dsdemail.
            END.
      
          /* Busca algum dos telefones do titular */
          FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper
                               AND craptfc.nrdconta = crapttl.nrdconta
                               AND craptfc.idseqttl = crapttl.idseqttl
                               AND craptfc.tptelefo = 2 /*Celular*/ NO-LOCK NO-ERROR.

          IF NOT AVAILABLE craptfc   THEN
             FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                      craptfc.nrdconta = crapttl.nrdconta AND
                                      craptfc.idseqttl = crapttl.idseqttl AND
                                      craptfc.tptelefo = 1 /*Residencial*/ 
                                      NO-LOCK NO-ERROR.

          IF NOT AVAIL craptfc   THEN
             FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                      craptfc.nrdconta = crapttl.nrdconta AND
                                      craptfc.idseqttl = crapttl.idseqttl AND
                                      craptfc.tptelefo = 3 /*Comercial*/  
                                      NO-LOCK NO-ERROR.
                         
          IF AVAILABLE craptfc THEN
             ASSIGN aux_nrtelefo = STRING(craptfc.nrtelefo)
                    aux_nrdddtfc = STRING(craptfc.nrdddtfc).
                        
           RUN RodaJavaScript("vetNome.push(~{nmextttl:" + "'" + TRIM(crapttl.nmextttl)
                                           + "',idseqttl:" + "'" + STRING(crapttl.idseqttl)
                                           + "',nrdddtfc:" + "'" + STRING(aux_nrdddtfc)
                                           + "',nrtelefo:" + "'" + STRING(aux_nrtelefo) 
                                           + "',dsdemail:" + "'" + TRIM(aux_dsdemail)
                                           + "',nmprimtl:" + "'" + STRING(aux_nmprimtl)
                                           + "',tppessoa:" + "'F" 
                                           + "',nmresage:" + "'" + STRING(aux_nmresage)                                           
                                           + "',flginscr:" + "'" + STRING(aux_flginscr)										   
                                           + "',dsinscri:" + "'" + STRING(aux_dsinscri)											   
                                           + "',nrcpfcgc:" + "'" + STRING(crapttl.nrcpfcgc) + "'~});").  
                                           
        END. /* FIM FOR EACH CRAPTTL */
      END. /* FIM PESSOA FISICA */
    ELSE IF crapass.inpessoa = 2 THEN /* PESSOA JURIDICA */
      DO:
        FOR EACH crapavt WHERE crapavt.cdcooper = INT(ab_unmap.aux_cdcooper)
                           AND crapavt.nrdconta = INT(aux_nrdconta)
                           AND crapavt.tpctrato = 6
                           AND crapavt.nrctremp = 0 NO-LOCK:
      
          IF crapavt.nrdctato <> 0 AND crapavt.nrdctato <> ? THEN
            DO:
            
              FOR EACH crapttl WHERE crapttl.cdcooper = crapavt.cdcooper AND 
                                     crapttl.nrdconta = crapavt.nrdctato NO-LOCK:
      
              ASSIGN aux_dsinscri = ''
                     aux_flginscr = ''.	
                                 
                      
              FOR EACH crapidp WHERE crapidp.idevento = INTEGER(ab_unmap.aux_idevento) 
                                 AND crapidp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                 AND crapidp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                 AND crapidp.nrdconta = aux_nrdconta                  
                                     /* Alterado para validar atraves do CNPJ, pois como
                                        � gravado o idseqttl das contas do socio, ocorre de 
                                        apresentar dados do titular do outro socio */
                                     /*crapidp.idseqttl = crapttl.idseqttl         */
                                 AND crapidp.nrcpfcgc = crapttl.nrcpfcgc               
                                 AND crapidp.cdevento = INT(aux_cdevento) /*crapadp.cdevento*/
                                 AND crapidp.nrseqeve = INT(ab_unmap.nrseqeve) 		     
                                 AND crapidp.cdageins = INT(ab_unmap.cdageins) NO-LOCK:
                            
                ASSIGN aux_flginscr = "S".
                
                  FIND FIRST crapage WHERE crapage.cdcooper = crapidp.cdcooper AND
                               crapage.cdagenci = crapidp.cdageins 
                             NO-LOCK NO-ERROR.
               
                IF  AVAIL crapage THEN  
                  ASSIGN aux_dsinscri = aux_dsinscri + " Pa: " + crapage.nmresage + " Inscrito: " + crapidp.nminseve.
                ELSE /* para assembleias o pa = 0 */ 
                    ASSIGN aux_dsinscri = aux_dsinscri + "Inscrito: " + crapidp.nminseve.
                
              END.								  
	  
                ASSIGN aux_nrtelefo = ""
                       aux_dsdemail = "".
                
                FOR FIRST crapcem FIELDS(dsdemail cddemail) WHERE crapcem.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                              AND crapcem.nrdconta = INT(aux_nrdconta) 
                                                              AND crapcem.idseqttl = crapttl.idseqttl NO-LOCK. END.  
                                                      
                IF AVAILABLE crapcem THEN                    
                  DO:
                    ASSIGN aux_dsdemail = crapcem.dsdemail.
                  END. 
      
                /* Busca algum dos telefones do titular */
                FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                         craptfc.nrdconta = crapttl.nrdconta AND
                                         craptfc.idseqttl = crapttl.idseqttl AND
                                         craptfc.tptelefo = 2 /*Celular*/    
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL craptfc THEN
                   FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                            craptfc.nrdconta = crapttl.nrdconta AND
                                            craptfc.idseqttl = crapttl.idseqttl AND
                                            craptfc.tptelefo = 1 /*Residencial*/ 
                                            NO-LOCK NO-ERROR.

                IF NOT AVAIL craptfc   THEN
                   FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                            craptfc.nrdconta = crapttl.nrdconta AND
                                            craptfc.idseqttl = crapttl.idseqttl AND
                                            craptfc.tptelefo = 3 /*Comercial*/  
                                            NO-LOCK NO-ERROR.
                               
                IF AVAILABLE craptfc THEN
                   ASSIGN aux_nrtelefo = STRING(craptfc.nrtelefo)
                          aux_nrdddtfc = STRING(craptfc.nrdddtfc).
                                
                RUN RodaJavaScript("vetNome.push(~{nmextttl:'" + TRIM(STRING(crapttl.nmextttl))
                                                 + "',idseqttl:'" + STRING(crapttl.idseqttl)
                                                 + "',nrdddtfc:'" + STRING(aux_nrdddtfc)
                                                 + "',nrtelefo:'" + STRING(aux_nrtelefo) 
                                                 + "',dsdemail:'" + STRING(aux_dsdemail)
                                                 + "',nmprimtl:'" + STRING(aux_nmprimtl)
                                                 + "',tppessoa:'J" 
                                                 + "',nmresage:'" + STRING(aux_nmresage)                                                 
                                                 + "',flginscr:'" + STRING(aux_flginscr)      
                                                 + "',dsinscri:'" + STRING(aux_dsinscri)													 
                                                 + "',nrcpfcgc:'" + STRING(crapttl.nrcpfcgc) + "'~});").  
                  
                                                 
              END.
            END. /* FIM IF NRDCTATO THEN*/
          ELSE
            DO:
            
              RUN RodaJavaScript("vetNome.push(~{" + "nmextttl:'" + TRIM(STRING(crapavt.nmdavali))
																									 + "',idseqttl:'0" 
																									 + "',nrdddtfc:'"  
																									 + "',nrtelefo:'" + STRING(crapavt.nrfonres)
																									 + "',dsdemail:'" + STRING(crapavt.dsdemail)
																									 + "',nmprimtl:'" + STRING(aux_nmprimtl)
																									 + "',tppessoa:'J" 
																									 + "',nmresage:'" + STRING(aux_nmresage)                                             
																									 + "',flginscr:'" + STRING(aux_flginscr)		
																									 + "',dsinscri:'" + STRING(aux_dsinscri)												 
																									 + "',nrcpfcgc:'" + STRING(crapavt.nrcpfcgc) + "'~});").                   
            END.                                           
        END. /* FIM FOR EACH CRAPAVT PESSOA JURIDICA */
        
      END. /* FIM PESSOA JURIDICA */    
       
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NomeCooperado w-html 
PROCEDURE BuscarCooperadoCPFCGC:
      
  RUN RodaJavaScript("var vetCoopCpfCgc = new Array();"). 
  
  FOR EACH crapass 
     WHERE crapass.cdcooper = INT(ab_unmap.aux_cdcooper)
       AND crapass.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc_fil)
       AND crapass.dtdemiss = ?
       NO-LOCK:
      
      RUN RodaJavaScript("vetCoopCpfCgc.push(~{nrdconta:'" + STRING(crapass.nrdconta)
                                          + "',nmprimtl:'" + crapass.nmprimtl + "'~});").
  END.     
  
  /* Titulares */
  FOR EACH crapttl 
     WHERE crapttl.cdcooper = INT(ab_unmap.aux_cdcooper)
       AND crapttl.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc_fil)
       AND crapttl.idseqttl <> 1
       NO-LOCK,
      EACH crapass 
     WHERE crapass.cdcooper = crapttl.cdcooper
       AND crapass.nrdconta = crapttl.nrdconta
       AND crapass.dtdemiss = ?
       NO-LOCK:
      
      RUN RodaJavaScript("vetCoopCpfCgc.push(~{nrdconta:'" + STRING(crapttl.nrdconta)
                                          + "',nmprimtl:'" + crapass.nmprimtl + "'~});").
  END. 
  
  /* Avalistas */
  FOR EACH crapavt 
     WHERE crapavt.cdcooper = INT(ab_unmap.aux_cdcooper)
       AND crapavt.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc_fil)
       AND crapavt.tpctrato = 6 
       NO-LOCK,
      EACH crapass 
     WHERE crapass.cdcooper = crapavt.cdcooper
       AND crapass.nrdconta = crapavt.nrdconta
       AND crapass.dtdemiss = ?
       NO-LOCK:
      
		RUN RodaJavaScript("vetCoopCpfCgc.push(~{nrdconta:'" + STRING(crapavt.nrdconta)
                                        + "',nmprimtl:'" + crapass.nmprimtl + "'~});").
              
	END. /* FIM FOR EACH CRAPAVT PESSOA JURIDICA */
    	
 
   
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verificaFichaPresenca w-html 
PROCEDURE verificaFichaPresenca:
  
  DEFINE INPUT PARAMETER par_idevento LIKE crapidp.idevento.
  DEFINE INPUT PARAMETER par_cdcooper LIKE crapidp.cdcooper.
  DEFINE INPUT PARAMETER par_dtanoage LIKE crapidp.dtanoage.
  DEFINE INPUT PARAMETER par_cdagenci LIKE crapidp.cdagenci.
  DEFINE INPUT PARAMETER par_cdevento LIKE crapidp.cdevento.
  DEFINE INPUT PARAMETER par_nrseqeve LIKE crapidp.nrseqeve.
  DEFINE INPUT PARAMETER par_nrficpre LIKE crapfpa.nrficpre.
  
  DEFINE VARIABLE aux_contador AS INTEGER INIT 0.
		
  /* Primeiro verifica se ficha de presenca existe */
  FIND crapfpa WHERE crapfpa.nrficpre = par_nrficpre
                 AND crapfpa.cdcopfic = par_cdcooper
                 AND crapfpa.cdagefic = par_cdagenci
								 AND crapfpa.nrseqdig = par_nrseqeve	NO-LOCK NO-ERROR NO-WAIT.
  
	IF NOT AVAILABLE crapfpa THEN
    DO:
			ASSIGN msg-erro-aux = 13
             msg-erro = "Ficha de Presen�a n�o cadastrada.".
             
      RETURN "NOK".       
    END.
  /* Fim verificacao ficha de presenca */
  			
  /* Verifica quantidade de inscritos por ficha */
	FOR EACH crapidp where crapidp.idevento = par_idevento
                     AND crapidp.cdcooper = par_cdcooper
                     AND crapidp.dtanoage = par_dtanoage
                     AND crapidp.cdagenci = 0
                     AND crapidp.cdevento = par_cdevento
                     AND crapidp.nrseqeve = par_nrseqeve
									   AND crapidp.nrficpre = par_nrficpre NO-LOCK:
    
    ASSIGN aux_contador = aux_contador + 1.
    
  END.
 	
  IF aux_contador < 25 THEN
    RETURN "OK".
  ELSE
    DO:
      ASSIGN msg-erro-aux = 12
             msg-erro = "Limite m�ximo de inscritos(25), para esta Ficha de Presen�a foi excedido.".
             
      RETURN "NOK".
    END.
  
  /* Fim verifica quantidade de inscritos por ficha */
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verificaInscricao w-html 
PROCEDURE verificaInscricao:
  
  DEFINE INPUT PARAMETER par_idevento LIKE crapidp.idevento.
  DEFINE INPUT PARAMETER par_cdcooper LIKE crapidp.cdcooper.
  DEFINE INPUT PARAMETER par_dtanoage LIKE crapidp.dtanoage.
  DEFINE INPUT PARAMETER par_nrdconta LIKE crapidp.nrdconta.
  DEFINE INPUT PARAMETER par_cdevento LIKE crapidp.cdevento.
  DEFINE INPUT PARAMETER par_nrseqeve LIKE crapidp.nrseqeve.
  DEFINE INPUT PARAMETER par_cdagenci LIKE crapidp.cdagenci.
  DEFINE INPUT PARAMETER par_nminseve LIKE crapidp.nminseve.
    
  FIND FIRST crapidp WHERE crapidp.idevento = par_idevento
                       AND crapidp.cdcooper = par_cdcooper
                       AND crapidp.dtanoage = par_dtanoage
                       AND crapidp.nrdconta = par_nrdconta
                       AND crapidp.cdevento = par_cdevento
                       AND crapidp.nrseqeve = par_nrseqeve
                       AND crapidp.cdageins = par_cdagenci
                       AND crapidp.nminseve = par_nminseve NO-LOCK NO-ERROR NO-WAIT.
     
  IF AVAILABLE crapidp THEN
    DO:
      ASSIGN msg-erro-aux = 14
             msg-erro = "J� existe uma inscri��o realizada para esta pessoa. Inclus�o duplicada nao permitida!".
      RETURN "NOK".
    END.
  ELSE
    DO:
      RETURN "OK".
    END.
    
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
               RUN RodaJavaScript("alert('Este j� � o primeiro registro.')").
               
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
    
    /* Nao traz inicialmente nenhum registro */ 
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
               RUN RodaJavaScript("alert('Este j� � o �ltimo registro.')").

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

  ASSIGN v-identificacao = get-cookie("cookie-usuario-em-uso").

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
         ab_unmap.aux_dsurlphp    = aux_srvprogrid + "-" + v-identificacao
         ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
         ab_unmap.aux_excrowid    = GET-VALUE("aux_excrowid") 
         ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
         ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
         ab_unmap.aux_lsconfir    = GET-VALUE("aux_lsconfir")
         ab_unmap.aux_lscoment    = GET-VALUE("aux_lscoment")
         ab_unmap.aux_lsfaleve    = GET-VALUE("aux_lsfaleve")
         ab_unmap.aux_lsseqdig    = GET-VALUE("aux_lsseqdig")
         ab_unmap.aux_cdgraupr    = GET-VALUE("aux_cdgraupr")
         ab_unmap.aux_idstaeve    = GET-VALUE("aux_idstaeve")
         ab_unmap.pagina          = GET-VALUE("pagina")
         ab_unmap.origem          = GET-VALUE("origem")
         ab_unmap.aux_tpinseve    = GET-VALUE("aux_tpinseve")
         ab_unmap.aux_nminseve    = GET-VALUE("aux_nminseve")
         ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
         ab_unmap.cdageins        = GET-VALUE("cdageins")
         ab_unmap.nrseqeve        = GET-VALUE("nrseqeve")
         ab_unmap.aux_carregar    = GET-VALUE("aux_carregar")
         ab_unmap.aux_reginils    = GET-VALUE("aux_reginils")
         ab_unmap.aux_regfimls    = GET-VALUE("aux_regfimls")
         ab_unmap.aba             = GET-VALUE("aba")
         ab_unmap.aux_dsinscri    = GET-VALUE("aux_nminseve")
         ab_unmap.aux_nminscri    = GET-VALUE("aux_nminscri")
         ab_unmap.aux_tpfiltro    = GET-VALUE("aux_tpfiltro")
         ab_unmap.aux_nrcpfcgc    = GET-VALUE("aux_nrcpfcgc")
         ab_unmap.aux_nrcpfcgc_fil= GET-VALUE("aux_nrcpfcgc_fil")
         ab_unmap.aux_nrdconta_cpfcgc = GET-VALUE("aux_nrdconta_cpfcgc")
         ab_unmap.aux_pesqorde = GET-VALUE("aux_pesqorde")
         ab_unmap.aux_nriniseq = GET-VALUE("aux_nriniseq")
         ab_unmap.aux_qtdregis = GET-VALUE("aux_qtdregis")
         ab_unmap.aux_nrficpre = GET-VALUE("aux_nrficpre")
         ab_unmap.aux_indicdiv = GET-VALUE("aux_indicdiv")
         ab_unmap.aux_idcookie = v-identificacao
         ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad")
         ab_unmap.aux_indficin = GET-VALUE("aux_indficin")
				 ab_unmap.aux_encerrar = GET-VALUE("aux_encerrar").

  RUN outputHeader.

  {includes/wpgd0098.i}

  ASSIGN ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.
        
  /* Se a cooperativa ainda nao foi escolhida, pega a da sessao do usu�rio */
  IF INT(ab_unmap.aux_cdcooper) = 0   THEN
    ASSIGN ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

  /* Se o PA ainda nao foi escolhido, pega o da sessao do usu�rio */
  IF INT(ab_unmap.cdageins) = 0   THEN
    ASSIGN ab_unmap.cdageins = STRING(gnapses.cdagenci).

  /* Posiciona por default, na agenda atual */
  IF ab_unmap.aux_dtanoage = "" THEN
    FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)
                        AND gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper)
                        AND gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
  ELSE
    /* Se informou a data da agenda, permite que veja a agenda de um ano nao atual */
    FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)
                        AND gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper)
                        AND gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

  IF NOT AVAILABLE gnpapgd THEN
    DO:
      IF ab_unmap.aux_dtanoage <> "" THEN
        DO:
          RUN RodaJavaScript("alert('N�o existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").
          opcao = "".
        END.
    
      FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)
                          AND gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.
    
    END.

  IF AVAILABLE gnpapgd THEN
    DO:
      IF ab_unmap.aux_dtanoage = ""   THEN
        ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanoage).
      ELSE
        ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
    END.
  ELSE
    ASSIGN ab_unmap.aux_dtanoage = "".

  ASSIGN ab_unmap.aux_tpfiltro:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "Conta,2,Pr�-Inscrito,1".
  ASSIGN ab_unmap.aux_pesqorde:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "Pr�-Inscrito,1,Conta,2,Situa��o,3".

  FIND FIRST craptab WHERE craptab.cdcooper = INT(ab_unmap.aux_cdcooper)
                       AND craptab.nmsistem = "CRED"                    
                       AND craptab.tptabela = "GENERI"                  
                       AND craptab.cdempres = 0                         
                       AND craptab.cdacesso = "VINCULOTTL"              
                       AND craptab.tpregist = 0  NO-LOCK NO-ERROR.

  IF AVAILABLE craptab   THEN
    ASSIGN ab_unmap.aux_cdgraupr:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = craptab.dstextab.

  RUN insere_log_progrid("WPGD0061.w",STRING(opcao) + "|" + STRING(ab_unmap.aux_idevento) + "|" +
              STRING(ab_unmap.aux_tpinseve) + "|" + STRING(ab_unmap.nrseqeve) + "|" +
              STRING(ab_unmap.aux_nminscri)).

  FIND crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                 AND crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR NO-WAIT.
                       
  IF AVAILABLE crapadp THEN                     
    ASSIGN aux_cdevento = crapadp.cdevento.
      
  /* m�todo POST */
  IF REQUEST_METHOD = "POST":U THEN
    DO:
      RUN inputFields.           
   
      IF INPUT FRAME {&frame-name} crapidp.nrdconta <> 0 THEN
          ASSIGN aux_nrdconta = INPUT FRAME {&frame-name} crapidp.nrdconta
                 aux_idseqttl = INPUT FRAME {&frame-name} crapidp.idseqttl
                 ab_unmap.aux_cdagenci    = GET-VALUE("aux_cdagenci").
        
      ELSE
          ASSIGN aux_nrdconta = 0
                 aux_idseqttl = 0
                 ab_unmap.aux_cdagenci = "1". 
   	 
      CASE opcao:
        WHEN "sa" THEN /* salvar */
          DO: 
			
            IF  ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
              DO:
                RUN local-assign-record ("inclusao"). 
                IF msg-erro <> "" THEN
                 ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
                ELSE 
                DO:
                   ASSIGN msg-erro-aux = 10
                          ab_unmap.aux_stdopcao = "al".

                   FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                   IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                      IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                         DO:
                             ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */  
                             FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                         END.
                END.

              END.  /* fim inclusao */
            ELSE     /* altera�ao */ 
              DO: 
                FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN msg-erro = "Registro n�o encontrado para altera�ao"
                          msg-erro-aux = 3.
                ELSE
                    DO:
                        RUN local-assign-record ("alteracao").   
                        IF msg-erro <> "" THEN
                          ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
                        ELSE 
                           ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                   END.
              END.    /* fim altera�ao */ 

          END.   /* fim salvar */

        WHEN "in" THEN /* inclusao */
                DO:
					IF ab_unmap.aux_stdopcao <> "i" THEN
                       DO:
                           CLEAR FRAME {&FRAME-NAME}.
                           ASSIGN ab_unmap.aux_stdopcao = "i".
                       END.
                END. /* fim inclusao */ 
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
			DO:
				RUN PosicionaNoPrimeiro.
			END.
           WHEN "ul" THEN /* ultimo */
			DO:
				RUN PosicionaNoUltimo.
			END.
      
           WHEN "an" THEN /* anterior */
			DO:
				RUN PosicionaNoAnterior.
			END.
           WHEN "se" THEN /* seguinte */
             DO:
				RUN PosicionaNoSeguinte.
			END.

          WHEN "conf" THEN /* salva confirma�oes */
               DO:
			      RUN AtualizaConfirm.  

                   IF msg-erro = "" THEN
                      ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                   ELSE
                      ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
               END.
          
          WHEN "enc" THEN /* encerra incri�oes */
               DO:
								IF ab_unmap.aux_indficin = "N" AND ab_unmap.aux_encerrar = "N" THEN
									DO:
										RUN verificaFichaNaoLancada.
										
										IF RETURN-VALUE = "OK" THEN
											DO:
												IF ab_unmap.aux_encerrar = "S" THEN
													DO:
														RUN EncerraMatricula.
														
														IF msg-erro = "" THEN
															ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
														ELSE
															ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
													END.
											END.
								  END.
								ELSE
									DO:
										
										IF ab_unmap.aux_encerrar = "S" THEN
											DO:
												RUN EncerraMatricula.
												
												IF msg-erro = "" THEN
													ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
												ELSE
													ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
											END.
									END.

               END.
          WHEN "exi" THEN /* Excluir inscri�ao */
               DO:
				   RUN ExcluirInscricao.
                   IF msg-erro = "" THEN
                      ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                   ELSE
                      ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
               END.
          WHEN "bcc" THEN /* buscar cooperado pelo cpf\cnpj */   
            DO:
              RUN buscarCooperadoCPFCGC.
            
            END.
      END CASE. 
	  
      RUN CriaListaPac.
      RUN CriaListaEventos.
      RUN CriaListaInscritos.
    		
      RUN RodaJavaScript("var vetNome = new Array();").
      
      IF aux_nrdconta <> 0 AND aux_nrdconta <> ? THEN
        DO:
          RUN NomeCooperado.
        END.
      
      /* limpar variavel para nao apresentar critica ao carregar tela */  
      ab_unmap.aux_cdagenci = "".
      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.
      
     CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usu�rio. Solicita�ao n�o pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN RUN RodaJavaScript("alert('Registro foi exclu�do. Solicita��o n�o pode ser executada.')").
      
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
               IF  GET-VALUE("origem") <> "" THEN 
                   DO:
                       RUN RodaJavaScript("window.opener.Recarrega();").
                       RUN RodaJavaScript("self.close();").
                   END.
               ELSE
                   DO:
                      IF opcao <> "exi" THEN 
												DO:
													RUN RodaJavaScript('alert("Atualiza��o executada com sucesso.");'). 
													IF opcao = "enc" THEN
														DO:
															RUN RodaJavaScript('geraRelatorio();').
														END.
												END.
                      ELSE
                        RUN RodaJavaScript('alert("Inscri��o exclu�da com sucesso.");'). 
                      
                      IF  opcao <> "conf" AND 
                          opcao <> "enc"  AND
                          opcao <> "exi"  THEN
                          RUN RodaJavaScript(" FocaCampo(); ").
                   END.
               RUN RodaJavaScript("document.form.aux_indficin.value = 'N'").
           END.

           /* Conta e titularidade nao encontrados no cadastro */
           WHEN 11 THEN RUN RodaJavaScript('alert("Cooperado n�o encontrado.");'). 
           
           /* Ficha de Inscricao com Limite Excedido */
           WHEN 12 THEN RUN RodaJavaScript('alert("Limite m�ximo de inscritos(25), para esta Ficha de Presen�a foi excedido.");'). 
           
           /* Ficha de Inscricao nao existente */
           WHEN 13 THEN RUN RodaJavaScript('alert("Ficha de Presen�a n�o cadastrada.");'). 
           
           /* Inscricao existente */
           WHEN 14 THEN RUN RodaJavaScript('alert("' + STRING(msg-erro) + '");').
           
           /* Fichas de Inscricoes nao lancadas */
           WHEN 15 THEN
            DO:
							RUN RodaJavaScript('var conf = confirm("' + STRING(msg-erro) + '");'). 
							RUN RodaJavaScript('((!conf) ? $("#indficin").show() : document.form.aux_encerrar.value = "S")').
							RUN RodaJavaScript('((conf) ? $("#indficin").show() : "")').
							RUN RodaJavaScript('((conf) ? document.form.aux_indficin.value = "S" : "" )').
							RUN RodaJavaScript('((conf) ? document.form.aux_cddopcao.value = "enc" : "" )').
							RUN RodaJavaScript('((conf) ? document.getElementById("form").submit() : "")').
            END.
					/* Existem inscri��es confirmadas sem ficha de presen�a */
           WHEN 16 THEN
            DO:
              RUN RodaJavaScript('alert("' + STRING(msg-erro) + '"); ').
            END.	
           
      END CASE.

      IF GET-VALUE("origem") <> "" THEN
      DO:
         RUN RodaJavaScript("TravaTudo();").
         RUN RodaJavaScript("document.form.cdageins.value = '" + GET-VALUE('cdageins') + "'").
         RUN RodaJavaScript("PosicionaPAC();").         
      END.
     
      IF opcao = "bcc" THEN
      DO:
         RUN RodaJavaScript("carregaContaNrcpccgc(" + ab_unmap.aux_nrdconta_cpfcgc + ");").
      END.
   END. /* Fim do m�todo POST */
ELSE /* M�todo GET */ 
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
                                     ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                     ab_unmap.aux_tpinseve = STRING(crapidp.tpinseve)
                                     ab_unmap.aux_nminseve = crapidp.nminseve
                                     ab_unmap.aux_dtanoage = STRING(crapidp.dtanoage)
                                     ab_unmap.aux_cdcooper = STRING(crapidp.cdcooper)
                                     ab_unmap.nrseqeve     = STRING(crapidp.nrseqeve)
                                     ab_unmap.cdageins     = STRING(crapidp.cdageins)
                                     ab_unmap.aux_dsinscri = crapidp.nminseve.
                          END.  
                       ELSE
                          ASSIGN ab_unmap.aux_nrdrowid = "?"
                                 ab_unmap.aux_stdopcao = "?".
                   END.  
               ELSE
                   RUN PosicionaNoPrimeiro.

               RUN CriaListaPac.
               RUN CriaListaEventos.
               RUN CriaListaInscritos.

               IF aux_nrdconta <> 0 AND aux_nrdconta <> ? THEN
                  RUN NomeCooperado.
		    		
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

               IF GET-VALUE("origem") <> "" THEN
                  DO:
                      RUN RodaJavaScript("document.form.cdageins.value = '" + GET-VALUE('cdageins') + "'").
                      RUN RodaJavaScript("PosicionaPAC();").
                      RUN RodaJavaScript("document.form.nrseqeve.value = '" + GET-VALUE('nrseqeve') + "'").
                      RUN RodaJavaScript("PosicionaEventos();").
                      RUN RodaJavaScript("TravaTudo();").
                      /* Seguran�a de PAs */
                      IF (gnapses.nvoperad = 1 OR gnapses.nvoperad = 2)  AND 
                          gnapses.cdagenci <> int(GET-VALUE('cdageins')) AND 
                          INT(GET-VALUE('cdageins')) <> 0                THEN DO: 
                          /* Se este PA nao � o seu, nao pode efetuar confirma�ao nem dispens�-la */
                          RUN RodaJavaScript("document.all.salvaconfirm.style.visibility = 'hidden';").
                      END.
                  
                  END.

           END. /* fim otherwise */                  
      END CASE. 
END. /* fim do m�todo GET */

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